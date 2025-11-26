import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart' show baseGreen, scaffoldBackground, textPrimary, textSecondary, cardBackgroundAlt;
import '../../../aluno/presentation/controller/aluno_controller.dart';
import '../../../atividade/presentation/controller/atividade_controller.dart';
import '../../../medicao/presentation/controller/medicao_controller.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  String? _selectedAlunoId;
  String? _tipoUsuario;
  bool _isLoadingTipoUsuario = true;

  @override
  void initState() {
    super.initState();
    _loadTipoUsuario();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlunoController>().loadAlunos();
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
        
        // Se for aluno, carregar automaticamente o alunoId dele
        if (_tipoUsuario == 'aluno') {
          final alunoQuery = await FirebaseFirestore.instance
              .collection('alunos')
              .where('userId', isEqualTo: user.uid)
              .limit(1)
              .get();
          if (alunoQuery.docs.isNotEmpty) {
            setState(() {
              _selectedAlunoId = alunoQuery.docs.first.id;
            });
            context.read<AtividadeController>().loadAtividadesByAluno(_selectedAlunoId!);
            context.read<MedicaoController>().loadMedicoesByAluno(_selectedAlunoId!);
          }
        }
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

  @override
  Widget build(BuildContext context) {
    final alunoController = context.watch<AlunoController>();
    final atividadeController = context.watch<AtividadeController>();
    final medicaoController = context.watch<MedicaoController>();

    if (_selectedAlunoId != null) {
      atividadeController.loadAtividadesByAluno(_selectedAlunoId!);
      medicaoController.loadMedicoesByAluno(_selectedAlunoId!);
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
          'Relatórios',
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
                  // Seletor de Aluno (apenas para personal)
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
                            setState(() => _selectedAlunoId = value);
                            if (value != null) {
                              // Força recarregamento completo dos dados
                              atividadeController.loadAtividadesByAluno(value);
                              medicaoController.loadMedicoesByAluno(value);
                              // Força atualização da UI
                              Future.delayed(const Duration(milliseconds: 100), () {
                                setState(() {});
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if (_selectedAlunoId != null) ...[
                            // Estatísticas Gerais
                            _buildStatsCard(
                              'Estatísticas Gerais',
                              [
                                _buildStatItem('Total de Atividades', atividadeController.atividades.length.toString()),
                                _buildStatItem('Total de Medições', medicaoController.medicoes.length.toString()),
                                if (medicaoController.medicoes.isNotEmpty)
                                  _buildStatItem(
                                    'Média de Batimentos',
                                    (medicaoController.medicoes.map((m) => m.batimentosPorMinuto).reduce((a, b) => a + b) /
                                            medicaoController.medicoes.length)
                                        .toStringAsFixed(0),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Gráfico de Batimentos
                            if (medicaoController.medicoes.isNotEmpty)
                              _buildBatimentosChart(medicaoController.medicoes),
                            const SizedBox(height: 24),

                            // Gráfico de Atividades
                            if (atividadeController.atividades.isNotEmpty)
                              _buildAtividadesChart(atividadeController.atividades),
                          ] else
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  'Selecione um aluno para ver os relatórios',
                                  style: TextStyle(color: textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard(String title, List<Widget> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...stats,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(color: baseGreen, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBatimentosChart(List medicoes) {
    final sortedMedicoes = List.from(medicoes)
      ..sort((a, b) => a.dataMedicao.compareTo(b.dataMedicao));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolução dos Batimentos Cardíacos',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: textSecondary, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedMedicoes.length) {
                            final medicao = sortedMedicoes[value.toInt()];
                            return Text(
                              DateFormat('dd/MM').format(medicao.dataMedicao),
                              style: const TextStyle(color: textSecondary, fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        sortedMedicoes.length,
                        (index) => FlSpot(index.toDouble(), sortedMedicoes[index].batimentosPorMinuto.toDouble()),
                      ),
                      isCurved: true,
                      color: baseGreen,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAtividadesChart(List atividades) {
    final tipoCount = <String, int>{};
    for (var atividade in atividades) {
      tipoCount[atividade.tipo] = (tipoCount[atividade.tipo] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribuição de Atividades por Tipo',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: tipoCount.entries.map((entry) {
                    final colors = [baseGreen, Colors.blue, Colors.orange, Colors.purple, Colors.red];
                    final index = tipoCount.keys.toList().indexOf(entry.key);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      color: colors[index % colors.length],
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}




