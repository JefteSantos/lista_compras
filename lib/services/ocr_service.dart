import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';

class OCRService {
  static final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  static final _picker = ImagePicker();

  /// Abre a câmera ou galeria para selecionar uma imagem e extrair os itens
  static Future<List<Item>> scanList({bool fromCamera = true}) async {
    final XFile? image = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (image == null) return [];

    final inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    return _parseRecognizedText(recognizedText.text);
  }

  /// Converte o texto bruto reconhecido em uma lista de modelos [Item]
  static List<Item> _parseRecognizedText(String text) {
    if (text.isEmpty) return [];

    final List<Item> items = [];
    final lines = text.split('\n');

    for (var line in lines) {
      final cleanLine = line.trim();
      if (cleanLine.isEmpty || cleanLine.length < 2) continue;

      // Tenta extrair quantidade se começar com número (ex: "2 leite")
      int quantidade = 1;
      String nome = cleanLine;

      final match = RegExp(r'^(\d+)\s*(.*)$').firstMatch(cleanLine);
      if (match != null) {
        quantidade = int.tryParse(match.group(1) ?? '1') ?? 1;
        nome = match.group(2) ?? cleanLine;
      }

      if (nome.isNotEmpty) {
        items.add(Item(
          id: const Uuid().v4(),
          nome: nome,
          quantidade: quantidade,
          dataCriacao: DateTime.now(),
        ));
      }
    }

    return items;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
