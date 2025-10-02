import 'package:flutter/material.dart';

/// Exibe um diálogo de confirmação genérico.
/// Retorna true se o usuário confirmar, e false se cancelar.
Future<bool> showGenericConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
  Color? confirmColor,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Força a interação com os botões
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          // Botão Cancelar
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          // Botão Confirmar
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: confirmColor ?? Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
  // Retorna 'false' se o diálogo for fechado de forma inesperada.
  return result ?? false;
}
