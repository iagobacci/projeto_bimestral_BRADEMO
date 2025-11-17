import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/aluno_controller.dart';
import 'aluno_form_screen.dart';

class AlunoListScreen extends StatefulWidget {
  const AlunoListScreen({super.key});

  @override
  State<AlunoListScreen> createState() => _AlunoListScreenState();
}

class _AlunoListScreenState extends State<AlunoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlunoController>().loadAlunos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlunoController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Alunos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlunoFormScreen(),
                ),
              );
              if (result == true) {
                controller.loadAlunos();
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
                        onPressed: () => controller.loadAlunos(),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                )
              : controller.alunos.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum aluno cadastrado',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.alunos.length,
                      itemBuilder: (context, index) {
                        final aluno = controller.alunos[index];
                        return Card(
                          color: widgetsColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              aluno.nome,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  aluno.email,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                if (aluno.peso != null && aluno.altura != null)
                                  Text(
                                    'Peso: ${aluno.peso}kg | Altura: ${aluno.altura}m',
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
                                        builder: (context) => AlunoFormScreen(aluno: aluno),
                                      ),
                                    );
                                    if (result == true) {
                                      controller.loadAlunos();
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
                                        content: Text('Deseja realmente excluir ${aluno.nome}?'),
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
                                      final success = await controller.deleteAluno(aluno.id!);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Aluno excluído com sucesso')),
                                        );
                                      } else if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(controller.error ?? 'Erro ao excluir aluno')),
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

