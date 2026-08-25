import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Gerencia a autenticação com o Google.
/// Usa o escopo drive.appdata para acesso à pasta privada do app no Drive.
///
/// A partir do google_sign_in v7, a API mudou significativamente:
/// - GoogleSignIn agora é um singleton (GoogleSignIn.instance).
/// - É preciso chamar initialize() uma única vez antes de qualquer outro método.
/// - O plugin não guarda mais um "usuário atual" internamente — isso agora é
///   responsabilidade do app, via a stream `authenticationEvents`.
/// - Autenticação (login) e autorização (acesso a escopos) são passos separados.
class AuthService {
  AuthService._();

  // No Web, o clientId é obrigatório. No Android, ele deve ser null para
  // evitar conflito com o google-services.json.
  static const _webClientId =
      '958891505864-gpprnfpj92rnh1o1kp9igon9cis9g1pc.apps.googleusercontent.com';
  // O serverClientId não é suportado na Web e deve ser passado apenas em
  // outras plataformas (como Android).
  static const _serverClientId =
      '958891505864-gpprnfpj92rnh1o1kp9igon9cis9g1pc.apps.googleusercontent.com';

  /// Escopos que o app efetivamente usa para acessar o Drive.
  static const List<String> scopes = [
    'https://www.googleapis.com/auth/drive.appdata',
  ];

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _initialized = false;
  static GoogleSignInAccount? _currentUser;

  static final StreamController<GoogleSignInAccount?> _userController =
      StreamController<GoogleSignInAccount?>.broadcast();

  /// Instância interna do GoogleSignIn, usada por outros serviços (ex: DriveBackupService).
  static GoogleSignIn get googleSignIn => _googleSignIn;

  /// Deve ser chamado UMA ÚNICA VEZ, antes de qualquer outro método desta classe.
  /// Ideal: no main(), antes do runApp(), ou no initState() do widget raiz.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _googleSignIn.initialize(
      clientId: kIsWeb ? _webClientId : null,
      serverClientId: kIsWeb ? null : _serverClientId,
    );

    _googleSignIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
        .onError((Object e) {
      debugPrint('Erro no stream de autenticação: $e');
      _currentUser = null;
      _userController.add(null);
    });

    // Equivalente ao antigo signInSilently() automático: tenta restaurar
    // a sessão de um usuário que já logou antes, sem exibir tela nenhuma
    // (ou com uma interação mínima, dependendo da plataforma).
    unawaited(_googleSignIn.attemptLightweightAuthentication());
  }

  static void _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) {
    final account = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };
    _currentUser = account;
    _userController.add(account);
  }

  /// Abre a tela de login do Google.
  /// Retorna null se o usuário cancelar (mesmo comportamento de antes).
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.authenticate(scopeHint: scopes);
      return account;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      debugPrint('ERRO NO GOOGLE SIGN-IN: $e');
      rethrow;
    } catch (e) {
      debugPrint('ERRO NO GOOGLE SIGN-IN: $e');
      rethrow;
    }
  }

  /// Desloga o usuário atual.
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _userController.add(null);
    } catch (e) {
      debugPrint('Erro ao sair: $e');
    }
  }

  /// Tenta renovar a sessão silenciosamente (sem tela de login, quando possível).
  /// Retorna null se o usuário não estiver logado.
  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final result = _googleSignIn.attemptLightweightAuthentication();
      // Em algumas plataformas (ex: web) o método pode não retornar um Future
      // e a resposta chega depois via `authenticationEvents`.
      final account = result != null ? await result : _currentUser;
      return account;
    } catch (e) {
      debugPrint('Erro ao renovar sessão: $e');
      return null;
    }
  }

  static GoogleSignInAccount? get currentUser => _currentUser;
  static bool get isSignedIn => _currentUser != null;

  /// Stream que emite o usuário atual sempre que há mudança de estado de login.
  static Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _userController.stream;

  /// Retorna os headers de autorização HTTP para o usuário atual.
  /// Equivalente ao antigo `account.authHeaders`.
  /// Retorna null se não houver usuário logado.
  static Future<Map<String, String>?> getAuthHeaders() async {
    final account = _currentUser;
    if (account == null) return null;

    // Tenta pegar um token já autorizado; se o usuário ainda não autorizou
    // esse escopo, solicita a autorização (pode exibir uma UI).
    final authorization =
        await account.authorizationClient.authorizationForScopes(scopes) ??
            await account.authorizationClient.authorizeScopes(scopes);

    return {'Authorization': 'Bearer ${authorization.accessToken}'};
  }
}
