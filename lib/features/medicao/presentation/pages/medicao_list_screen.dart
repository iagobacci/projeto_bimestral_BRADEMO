import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/medicao_controller.dart';
import 'medicao_form_screen.dart';
import '../../../aluno/presentation/controller/aluno_controller.dart';

class MedicaoListScreen extends StatefulWidget {
  const MedicaoListScreen({super.key});

  @override
  State<MedicaoListScreen> createState() => _MedicaoListScreenState();
}

class _MedicaoListScreenState extends State<MedicaoListScreen> {
  String? _selectedAlunoId;
  String? _tipoUsuario;
  bool _isLoadingTipoUsuario = true;

  @override
  void initState() {
    super.initState();
    _loadTipoUsuarioAndMedicoes();
  }

  Future<void> _loadTipoUsuarioAndMedicoes() async {
    await _loadTipoUsuario();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tipoUsuario == 'aluno') {
        context.read<MedicaoController>().loadMedicoes();
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

  void _loadMedicoesByAluno() {
    if (_selectedAlunoId != null) {
      context.read<MedicaoController>().loadMedicoesByAluno(_selectedAlunoId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MedicaoController>();
    final alunoController = context.watch<AlunoController>();

    // Se for personal, carregar alunos no initState se ainda não carregou
    if (_tipoUsuario == 'personal' && alunoController.alunos.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        alunoController.loadAlunos();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histórico',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.png'),
              radius: 18,
            ),
          ),
        ],
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
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAlunoId,
                          dropdownColor: const Color(0xFF1A1A1A),
                          style: const TextStyle(color: Colors.white),
                          iconEnabledColor: baseGreen,
                          hint: const Text('Selecione um aluno', style: TextStyle(color: Colors.white70)),
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
                              controller.loadMedicoesByAluno(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                  Expanded(child: _buildHistoryList(controller)),
                  const SizedBox(height: 16),
                  _buildButtons(context, controller),
                ],
              ),
            ),
    );
  }

  Widget _buildHistoryList(MedicaoController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: baseGreen));
    }

    if (controller.error != null) {
      return Center(
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
                  controller.loadMedicoes();
                } else if (_selectedAlunoId != null) {
                  controller.loadMedicoesByAluno(_selectedAlunoId!);
                }
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_tipoUsuario == 'personal' && _selectedAlunoId == null) {
      return const Center(
        child: Text(
          'Selecione um aluno para ver as medições',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    if (controller.medicoes.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma medição cadastrada',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.medicoes.length,
      itemBuilder: (context, index) {
        final medicao = controller.medicoes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(medicao.dataMedicao),
                style: const TextStyle(
                  color: Color.fromRGBO(128, 249, 136, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                children: [
                  Text(
                    "BPM: ${medicao.batimentosPorMinuto}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (medicao.pressaoSistolica != null && medicao.pressaoDiastolica != null) ...[
                    const Text(" | ", style: TextStyle(color: Colors.white70)),
                    Text(
                      "Pressão: ${medicao.pressaoSistolica}/${medicao.pressaoDiastolica} mmHg",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                  if (medicao.temperatura != null) ...[
                    const Text(" | ", style: TextStyle(color: Colors.white70)),
                    Text(
                      "Temp: ${medicao.temperatura}°C",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ],
              ),
              if (medicao.observacoes != null && medicao.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Obs: ${medicao.observacoes}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context, MedicaoController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(41, 227, 60, 1),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          String? alunoIdToUse = _selectedAlunoId;
          
          // Se for aluno, obter o alunoId dele
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
              builder: (context) => MedicaoFormScreen(preSelectedAlunoId: alunoIdToUse),
            ),
          );
          if (result == true) {
            if (_tipoUsuario == 'aluno') {
              controller.loadMedicoes();
            } else if (_selectedAlunoId != null) {
              _loadMedicoesByAluno();
            }
          }
        },
        child: const Text(
          '+ Adicionar Medição',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

