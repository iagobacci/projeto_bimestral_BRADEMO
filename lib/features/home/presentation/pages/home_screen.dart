import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fl_chart/fl_chart.dart'; 

import '../widgets/stat_card.dart'; 

import '../controller/home_controller.dart'; 

import 'package:trabalho01/features/settings_screen/settings_screen.dart';

import '../../../../core/widgets/custom_bottom_nav.dart'; 
import '../../../../core/theme/app_theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _tipoUsuario;
  bool _isLoadingTipoUsuario = true;

  @override
  void initState() {
    super.initState();
    _loadTipoUsuario();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().refreshUserData();
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

  void _navigateToPulseScreen(BuildContext context) {
    Navigator.pushNamed(context, '/pulse'); 
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final String? nome = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader( 
              decoration: const BoxDecoration(color: baseGreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(height: 10),
                  Text("Olá, ${nome ?? controller.userName}!", style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home, color: Colors.white), title: const Text('Home', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            if (!_isLoadingTipoUsuario && _tipoUsuario == 'personal')
              ListTile(leading: const Icon(Icons.person, color: Colors.white), title: const Text('Alunos', style: TextStyle(color: Colors.white)), onTap: () {Navigator.pop(context); Navigator.pushNamed(context, '/alunos');}),
            ListTile(leading: const Icon(Icons.fitness_center, color: Colors.white), title: const Text('Atividades', style: TextStyle(color: Colors.white)), onTap: () {Navigator.pop(context); Navigator.pushNamed(context, '/atividades');}),
            ListTile(leading: const Icon(Icons.favorite, color: Colors.white), title: const Text('Medições', style: TextStyle(color: Colors.white)), onTap: () {Navigator.pop(context); Navigator.pushNamed(context, '/medicoes');}),
            ListTile(leading: const Icon(Icons.bar_chart, color: Colors.white), title: const Text('Relatórios', style: TextStyle(color: Colors.white)), onTap: () {Navigator.pop(context); Navigator.pushNamed(context, '/relatorios');}),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Configurações', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),

            ListTile(leading: const Icon(Icons.help, color: Colors.white), title: const Text('Ajuda / Suporte', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.logout, color: Colors.white), title: const Text('Sair', style: TextStyle(color: Colors.white)), onTap: () {Navigator.pushNamedAndRemoveUntil(context, '/splash', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: CustomBottomNav(
        componentColor: widgetsColor,
        activeKey: 'home',
        onHomeTap: () => Navigator.pushNamed(context, '/home'),
        onTreinoTap: () => Navigator.pushNamed(context, '/atividades'),
        onAtividadesTap: () => Navigator.pushNamed(context, '/activity'),
        onConfigTap: () => Navigator.pushNamed(context, '/settings'),
      ),

      body: SafeArea(
        child: _isLoadingTipoUsuario
            ? const Center(child: CircularProgressIndicator(color: baseGreen))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(onTap: () {_scaffoldKey.currentState?.openDrawer();}, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: baseGreen, shape: BoxShape.circle,), child: const CircleAvatar(radius: 25, backgroundImage: AssetImage('assets/images/profile.png'),),),),
                            const SizedBox(width: 8),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Bem-Vindo de Volta!", style: TextStyle(color: Colors.white70, fontSize: 14)), Text(nome ?? controller.userName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),],),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await controller.forceRefresh();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Dados atualizados!'),
                                      backgroundColor: Color.fromRGBO(41, 227, 60, 1),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: const Icon(Icons.refresh, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.search, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            const Icon(Icons.notifications, color: Colors.white, size: 28),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    
                    (_tipoUsuario == 'personal')
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: Text(
                                'Tela inicial',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(text: const TextSpan(children: [TextSpan(text: "Cuide-se e mantenha-se ", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),), TextSpan(text: "saudável", style: TextStyle(color: baseGreen, fontWeight: FontWeight.bold, fontSize: 20),),],),),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StatCard(icon: Icons.monitor_weight, label: "Peso", value: controller.userWeight),
                                  StatCard(icon: Icons.height, label: "Altura", value: controller.userHeight),
                                  StatCard(icon: Icons.cake, label: "Idade", value: controller.userAge),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (controller.userDataNascimento != null)
                                Text(
                                  'Data de Nascimento: ${controller.userDataNascimento}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),

                              const SizedBox(height: 20),

                              RichText(text: TextSpan(children: [const TextSpan(text: "Média de Batimentos: ", style: TextStyle(color: Colors.white, fontSize: 16),), TextSpan(text: controller.heartRateAvg, style: const TextStyle(color: baseGreen, fontSize: 16, fontWeight: FontWeight.bold),),],),),
                              const SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: widgetsColor, borderRadius: BorderRadius.circular(20)),
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: false),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            switch (value.toInt()) {
                                              case 0: return const Text("Dom", style: TextStyle(color: Colors.white70));
                                              case 1: return const Text("Seg", style: TextStyle(color: Colors.white70));
                                              case 2: return const Text("Ter", style: TextStyle(color: Colors.white70));
                                              case 3: return const Text("Qua", style: TextStyle(color: Colors.white70));
                                              case 4: return const Text("Qui", style: TextStyle(color: Colors.white70));
                                              case 5: return const Text("Sex", style: TextStyle(color: Colors.white70));
                                              case 6: return const Text("Sab", style: TextStyle(color: Colors.white70));
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: controller.heartRateSpots,
                                        isCurved: true,
                                        color: baseGreen,
                                        dotData: FlDotData(show: false),
                                        belowBarData: BarAreaData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: widgetsColor, borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.favorite, color: Color.fromARGB(255, 255, 0, 0), size: 28),
                                        SizedBox(width: 8),
                                        Text("Bem-estar Cardíaco", style: TextStyle(color: Colors.white, fontSize: 16)),
                                      ],
                                    ),
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              controller.heartRateAvg,
                                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _navigateToPulseScreen(context),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(color: baseGreen, borderRadius: BorderRadius.circular(12)),
                                              child: const Text("Verificar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}