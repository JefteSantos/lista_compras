import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/screens/list_detail_screen.dart';
import 'package:lista_compras/utils/app_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _criarNovaLista() async {
    final controller = TextEditingController();
    final String? nome = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da Lista',
            hintText: 'Ex: Supermercado Semanal',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('CRIAR'),
          ),
        ],
      ),
    );

    if (nome != null && mounted) {
      final novaLista = ListaCompras(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: nome,
        dataCriacao: DateTime.now(),
      );
      
      await Provider.of<ListasProvider>(context, listen: false)
          .adicionarLista(novaLista);

      if (mounted) {
         Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ListDetailScreen(listaId: novaLista.id),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ativas', icon: Icon(Icons.shopping_cart_outlined)),
            Tab(text: 'Histórico', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Consumer<ListasProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildListasView(provider.listasAtivas, isAtivas: true),
              _buildListasView(provider.listasFinalizadas, isAtivas: false),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarNovaLista,
        icon: const Icon(Icons.add),
        label: const Text('Nova Lista'),
      ),
    );
  }

  Widget _buildListasView(List<ListaCompras> listas, {required bool isAtivas}) {
    if (listas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAtivas ? Icons.remove_shopping_cart : Icons.history_toggle_off,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isAtivas 
                  ? 'Nenhuma lista ativa no momento.' 
                  : 'Nenhum histórico disponível.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listas.length,
      itemBuilder: (context, index) {
        final lista = listas[index];
        return _buildListaCard(lista);
      },
    );
  }

  Widget _buildListaCard(ListaCompras lista) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ListDetailScreen(listaId: lista.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lista.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(lista),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(lista.dataCriacao),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    '${lista.itensComprados}/${lista.totalItens} itens',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: lista.finalizada ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: lista.totalItens == 0 ? 0 : lista.itensComprados / lista.totalItens,
                backgroundColor: Colors.grey.shade200,
                color: lista.finalizada ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
              if (lista.precoTotal > 0) ...[
                 const SizedBox(height: 8),
                 Text(
                   'Total estimado: ${AppUtils.formatMoney(lista.precoTotal)}',
                   style: const TextStyle(fontWeight: FontWeight.w600),
                 )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ListaCompras lista) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: lista.finalizada ? Colors.green.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        lista.finalizada ? 'Concluída' : 'Em andamento',
        style: TextStyle(
          color: lista.finalizada ? Colors.green.shade800 : Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
