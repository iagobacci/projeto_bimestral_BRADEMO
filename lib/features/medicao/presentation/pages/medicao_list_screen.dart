import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/medicao_controller.dart';
import 'medicao_form_screen.dart';

class MedicaoListScreen extends StatefulWidget {
  const MedicaoListScreen({super.key});

  @override
  State<MedicaoListScreen> createState() => _MedicaoListScreenState();
}

class _MedicaoListScreenState extends State<MedicaoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicaoController>().loadMedicoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MedicaoController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Medições'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicaoFormScreen(),
                ),
              );
              if (result == true) {
                controller.loadMedicoes();
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
                        onPressed: () => controller.loadMedicoes(),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : controller.medicoes.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma medição cadastrada',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.medicoes.length,
                      itemBuilder: (context, index) {
                        final medicao = controller.medicoes[index];
                        return Card(
                          color: widgetsColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              '${medicao.batimentosPorMinuto} bpm',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(medicao.dataMedicao)}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                if (medicao.pressaoSistolica != null && medicao.pressaoDiastolica != null)
                                  Text(
                                    'Pressão: ${medicao.pressaoSistolica}/${medicao.pressaoDiastolica} mmHg',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                if (medicao.temperatura != null)
                                  Text(
                                    'Temperatura: ${medicao.temperatura}°C',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                if (medicao.latitude != null && medicao.longitude != null)
                                  Text(
                                    'Localização: ${medicao.latitude!.toStringAsFixed(4)}, ${medicao.longitude!.toStringAsFixed(4)}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                                        builder: (context) => MedicaoFormScreen(medicao: medicao),
                                      ),
                                    );
                                    if (result == true) {
                                      controller.loadMedicoes();
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
                                        content: const Text('Deseja realmente excluir esta medição?'),
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
                                      final success = await controller.deleteMedicao(medicao.id!);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Medição excluída com sucesso')),
                                        );
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(controller.error ?? 'Erro ao excluir medição')),
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

