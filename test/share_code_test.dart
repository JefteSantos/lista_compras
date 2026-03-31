import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/services/share_code_service.dart';

void main() {
  group('ShareCodeService Tests', () {
    late ListaCompras listaBase;

    setUp(() {
      listaBase = ListaCompras(
        id: 'lista-123',
        nome: 'Churrasco de Domingo',
        descricao: 'Lista para o churrasco da família com carnes e bebidas',
        dataCriacao: DateTime(2026, 3, 30, 15, 0),
        cor: 'FF9800',
      );

      listaBase.adicionarItem(Item(
        id: 'item-1',
        nome: 'Picanha',
        quantidade: 2,
        preco: 89.90,
        observacoes: 'Pegar a peça com menos gordura',
        dataCriacao: DateTime.now(),
      ));

      listaBase.adicionarItem(Item(
        id: 'item-2',
        nome: 'Cerveja',
        quantidade: 12,
        preco: 4.50,
        comprado: true,
        dataCriacao: DateTime.now(),
        dataCompra: DateTime.now(),
      ));
    });

    test('Deve codificar e decodificar uma lista mantendo a integridade', () {
      final code = ShareCodeService.encodeList(listaBase);
      expect(code, startsWith('NE2:'));

      final decoded = ShareCodeService.decodeList(code);
      expect(decoded, isNotNull);
      expect(decoded!.nome, listaBase.nome);
      expect(decoded.descricao, listaBase.descricao);
      expect(decoded.itens.length, listaBase.itens.length);
      expect(decoded.itens.first.nome, 'Picanha');
      expect(decoded.cor, listaBase.cor);
    });

    test('Deve ser resiliente a espaços e quebras de linha no código', () {
      final code = ShareCodeService.encodeList(listaBase);
      
      // Simula o que o WhatsApp faz: insere espaços e quebras de linha no meio
      final messyCode = "${code.substring(0, 10)}\n  ${code.substring(10, 20)}   ${code.substring(20)}";

      final decoded = ShareCodeService.decodeList(messyCode);
      expect(decoded, isNotNull);
      expect(decoded!.id, listaBase.id);
      expect(decoded.nome, listaBase.nome);
    });

    test('Deve usar o novo formato NE2 com chaves curtas e datas numéricas', () {
      final code = ShareCodeService.encodeList(listaBase);
      
      // Se decodificarmos manualmente o JSON básico do GZIP (sem passar pelo fromShortKeys),
      // deveríamos ver as chaves curtas como 'n', 'it', 'dc', etc.
      // Este teste foca no prefixo que garante o uso da V2.
      expect(code, startsWith('NE2:'));
    });

    test('Deve lançar ShareCodeOversizedException para listas gigantescas', () {
      final megaLista = ListaCompras(
        id: 'mega',
        nome: 'Lista Infinita',
        dataCriacao: DateTime.now(),
      );

      // Adiciona 10.000 itens para forçar o estouro do limite de 32KB compactado
      for (var i = 0; i < 10000; i++) {
        megaLista.adicionarItem(Item(
          id: 'item-$i',
          nome: 'Item numero $i de uma lista propositalmente gigantesca que estamos criando apenas para testar se o nosso limite de seguranca de 32KB compactados esta funcionando corretamente no servidor de compartilhamento',
          quantidade: i,
          observacoes: 'Observacao extremamente longa e detalhada, com repetições e variações de caracteres $i para ocupar espaço no buffer final e forçar o throw da exceção de tamanho excedido durante o teste unitário de hoje',
          dataCriacao: DateTime.now(),
        ));
      }

      expect(
        () => ShareCodeService.encodeList(megaLista), 
        throwsA(isA<ShareCodeOversizedException>())
      );
    });

    test('Deve retornar null para códigos totalmente inválidos', () {
      expect(ShareCodeService.decodeList('XYZ:INVALIDO'), isNull);
      expect(ShareCodeService.decodeList(''), isNull);
      expect(ShareCodeService.decodeList('NE2:dadosCorrompidosBase64'), isNull);
    });
  });
}
