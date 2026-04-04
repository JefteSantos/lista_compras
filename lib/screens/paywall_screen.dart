import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/iap_provider.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = false;

  void _comprar(BuildContext context) async {
    setState(() => _isLoading = true);
    final iap = Provider.of<IapProvider>(context, listen: false);
    
    // Chama o Mock de compra
    final success = await iap.comprarProMock();
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Bem-vindo ao PRO! Funcionalidades desbloqueadas.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Fecha a tela de vendas
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pagamento cancelado ou falhou.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        actions: [
          TextButton(
            onPressed: () {
              // Lógica de restaurar compras
              Provider.of<IapProvider>(context, listen: false).restaurarComprasMock();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buscando compras anteriores...')),
              );
            },
            child: const Text('Restaurar'),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Icon(
                Icons.star_rounded,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              const Text(
                'Não Esquece! PRO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Desbloqueie todo o poder do aplicativo com uma \nCOMPRA ÚNICA VITALÍCIA.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const Spacer(),
              // Benefícios
              _buildFeatureRow(Icons.document_scanner, 'Scanner OCR de listas físicas'),
              _buildFeatureRow(Icons.picture_as_pdf, 'Exportação ilimitada para PDF e Excel'),
              _buildFeatureRow(Icons.trending_up, 'Histórico de Preços infinito'),
              const Spacer(),
              
              // Preço
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple.shade100, width: 2),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Pague uma vez, use para sempre!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'R\$ 19,90',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Botão de Comprar
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _comprar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'DESBLOQUEAR AGORA',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }
}
