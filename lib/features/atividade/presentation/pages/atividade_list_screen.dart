import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart' show baseGreen, scaffoldBackground, textPrimary, textSecondary, widgetsColor, cardBackgroundAlt, errorColor;
import '../controller/atividade_controller.dart';
import 'atividade_form_screen.dart';
import '../../../aluno/presentation/controller/aluno_controller.dart';

class AtividadeListScreen extends StatefulWidget {
  const AtividadeListScreen({super.key});

  @override
  State<AtividadeListScreen> createState() => _AtividadeListScreenState();
}

class _AtividadeListScreenState extends State<AtividadeListScreen> {
  String? _selectedAlunoId;
  String? _tipoUsuario;
  bool _isLoadingTipoUsuario = true;

  @override
  void initState() {
    super.initState();
    _loadTipoUsuarioAndAtividades();
  }

  Future<void> _loadTipoUsuarioAndAtividades() async {
    await _loadTipoUsuario();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tipoUsuario == 'aluno') {
        context.read<AtividadeController>().loadAtividades();
      } else {
        // Personal precisa selecionar aluno primeiro
        context.read<AlunoController>().loadAlunos();
      }
    });
  }

  Future<void> _loadTipoUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          _tipoUsuario = userDoc.data()?['tipoUsuario'] ?? 'aluno';
          _isLoadingTipoUsuario = false;
        });
      } catch (e) {
        setState(() {
          _tipoUsuario = 'aluno';
          _isLoadingTipoUsuario = false;
        });
      }
    } else {
      setState(() {
        _tipoUsuario = 'aluno';
        _isLoadingTipoUsuario = false;
      });
    }
  }

  void _loadAtividadesByAluno() {
    if (_selectedAlunoId != null) {
      context.read<AtividadeController>().loadAtividadesByAluno(_selectedAlunoId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AtividadeController>();
    final alunoController = context.watch<AlunoController>();

    // Se for personal, carregar alunos no initState se ainda não carregou
    if (_tipoUsuario == 'personal' && alunoController.alunos.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        alunoController.loadAlunos();
      });
    }

    return Scaffold(
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Atividades',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoadingTipoUsuario
          ? const Center(child: CircularProgressIndicator(color: baseGreen))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown para seleção de aluno (apenas para personal)
                  if (_tipoUsuario == 'personal') ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardBackgroundAlt,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAlunoId,
                          dropdownColor: cardBackgroundAlt,
                          style: const TextStyle(color: textPrimary),
                          iconEnabledColor: baseGreen,
                          hint: const Text('Selecione um aluno', style: TextStyle(color: textSecondary)),
                          items: alunoController.alunos.map((aluno) {
                            return DropdownMenuItem<String>(
                              value: aluno.id,
                              child: Text(aluno.nome),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAlunoId = value;
                            });
                            if (value != null) {
                              controller.loadAtividadesByAluno(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                  // Lista de atividades dinâmica
                  Expanded(
                    child: controller.isLoading
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
                                    onPressed: () {
                                      if (_tipoUsuario == 'aluno') {
                                        controller.loadAtividades();
                                      } else if (_selectedAlunoId != null) {
                                        controller.loadAtividadesByAluno(_selectedAlunoId!);
                                      }
                                    },
                                    child: const Text('Tentar Novamente'),
                                  ),
                                ],
                              ),
                            )
                          : (_tipoUsuario == 'personal' && _selectedAlunoId == null)
                              ? const Center(
                                  child: Text(
                                    'Selecione um aluno para ver as atividades',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : controller.atividades.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Nenhuma atividade cadastrada',
                                        style: TextStyle(color: textSecondary),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: controller.atividades.length,
                                      itemBuilder: (context, index) {
                                        final atividade = controller.atividades[index];
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: cardBackgroundAlt,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      atividade.tipo,
                                                      style: const TextStyle(
                                                        color: textPrimary,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit, color: baseGreen, size: 20),
                                                        onPressed: () async {
                                                          final result = await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => AtividadeFormScreen(atividade: atividade),
                                                            ),
                                                          );
                                                          if (result == true) {
                                                            if (_tipoUsuario == 'aluno') {
                                                              controller.loadAtividades();
                                                            } else {
                                                              _loadAtividadesByAluno();
                                                            }
                                                          }
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: errorColor, size: 20),
                                                        onPressed: () async {
                                                          final confirm = await showDialog<bool>(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              backgroundColor: widgetsColor,
                                                              title: const Text('Confirmar exclusão', style: TextStyle(color: textPrimary)),
                                                              content: const Text('Deseja realmente excluir esta atividade?', style: TextStyle(color: textSecondary)),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context, false),
                                                                  child: const Text('Cancelar', style: TextStyle(color: textSecondary)),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(context, true),
                                                                  child: const Text('Excluir', style: TextStyle(color: errorColor)),
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
                                                              if (_tipoUsuario == 'aluno') {
                                                                controller.loadAtividades();
                                                              } else {
                                                                _loadAtividadesByAluno();
                                                              }
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
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                atividade.descricao,
                                                style: const TextStyle(color: textSecondary, fontSize: 14),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Data: ${DateFormat('dd/MM/yyyy').format(atividade.dataAtividade)}',
                                                style: const TextStyle(color: textSecondary, fontSize: 14),
                                              ),
                                              if (atividade.duracaoMinutos != null)
                                                Text(
                                                  'Duração: ${atividade.duracaoMinutos!.toStringAsFixed(0)} min',
                                                  style: const TextStyle(color: textSecondary, fontSize: 14),
                                                ),
                                              if (atividade.distanciaMetros != null)
                                                Text(
                                                  'Distância: ${atividade.distanciaMetros!.toStringAsFixed(0)} m',
                                                  style: const TextStyle(color: textSecondary, fontSize: 14),
                                                ),
                                              if (atividade.calorias != null)
                                                Text(
                                                  'Calorias: ${atividade.calorias}',
                                                  style: const TextStyle(color: textSecondary, fontSize: 14),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAddButton(context, controller),
                ],
              ),
            ),
    );
  }

  Widget _buildAddButton(BuildContext context, AtividadeController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: baseGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          String? alunoIdToUse = _selectedAlunoId;
          
          if (_tipoUsuario == 'aluno') {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              try {
                final alunoQuery = await FirebaseFirestore.instance
                    .collection('alunos')
                    .where('userId', isEqualTo: user.uid)
                    .limit(1)
                    .get();
                if (alunoQuery.docs.isNotEmpty) {
                  alunoIdToUse = alunoQuery.docs.first.id;
                }
              } catch (e) {
                // Erro ao buscar aluno
              }
            }
          }
          
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AtividadeFormScreen(preSelectedAlunoId: alunoIdToUse),
            ),
          );
          if (result == true) {
            if (_tipoUsuario == 'aluno') {
              controller.loadAtividades();
            } else if (_selectedAlunoId != null) {
              _loadAtividadesByAluno();
            }
          }
        },
        child: const Text(
          '+ Adicionar Atividade',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}