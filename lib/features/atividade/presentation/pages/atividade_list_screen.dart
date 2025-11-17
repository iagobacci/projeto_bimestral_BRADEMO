import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/atividade_controller.dart';
import 'atividade_form_screen.dart';

class AtividadeListScreen extends StatefulWidget {
  const AtividadeListScreen({super.key});

  @override
  State<AtividadeListScreen> createState() => _AtividadeListScreenState();
}

class _AtividadeListScreenState extends State<AtividadeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AtividadeController>().loadAtividades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AtividadeController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Atividades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AtividadeFormScreen(),
                ),
              );
              if (result == true) {
                controller.loadAtividades();
              }
            },
          ),
        ],
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: baseGreen))
          : controller.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.loadAtividades(),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : controller.atividades.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma atividade cadastrada',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.atividades.length,
                      itemBuilder: (context, index) {
                        final atividade = controller.atividades[index];
                        return Card(
                          color: widgetsColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              atividade.tipo,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  atividade.descricao,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(atividade.dataInicio)}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                if (atividade.duracaoMinutos != null)
                                  Text(
                                    'Duração: ${atividade.duracaoMinutos!.toStringAsFixed(0)} min',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                if (atividade.calorias != null)
                                  Text(
                                    'Calorias: ${atividade.calorias}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: baseGreen),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AtividadeFormScreen(atividade: atividade),
                                      ),
                                    );
                                    if (result == true) {
                                      controller.loadAtividades();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar exclusão'),
                                        content: Text('Deseja realmente excluir esta atividade?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && context.mounted) {
                                      final success = await controller.deleteAtividade(atividade.id!);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Atividade excluída com sucesso')),
                                        );
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(controller.error ?? 'Erro ao excluir atividade')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

