import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho01/core/theme/app_theme.dart'; 
import '../controller/pulse_controller.dart';
import '../widgets/progress_circle.dart';
import '../widgets/heartbeat_graph.dart';
import 'package:trabalho01/features/medicao/presentation/pages/medicao_list_screen.dart'; 

class PulseScreen extends StatelessWidget {
  const PulseScreen({super.key});

  void _navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  void _showHistoryMenu(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const double menuWidth = 180.0;
    
    final double centerPositionX = (screenSize.width / 2.5) - (menuWidth / 2.5); 
    final RelativeRect position = RelativeRect.fromLTRB(
      centerPositionX, 
      screenSize.height - 250, 
      screenSize.width - centerPositionX - menuWidth,
      0,
    );
    
    showMenu<String>(
      context: context,
      position: position,
      color: const Color(0xFF282A2C), 
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'history',
          child: SizedBox( 
            width: menuWidth, 
            child: const Text(
              'Histórico', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), 
              textAlign: TextAlign.center,
            ),
          ),
          onTap: () {
            Future.microtask(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicaoListScreen()),
              );
            });
            debugPrint("Opção Histórico Clicada!");
          },
        ),
      ],
      elevation: 5,
    );
  }


  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PulseController>();
    
    return Scaffold(
      backgroundColor: primaryBackground, 
      appBar: AppBar(
        backgroundColor: Colors.black, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _navigateBack(context),
        ),
        title: const Text(
          'Medição de Pulso',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, 
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/images/profile.png'), 
              backgroundColor: baseGreen.withOpacity(0.3),
            ),
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui espaço vertical
                children: [
                  
                  Column(
                    children: [
                      const SizedBox(height: 20), // Espaço superior

                      const Align(
                        alignment: Alignment.center,
                        child: ProgressCircle(
                          progress: 65,
                        ),
                      ),

                      const SizedBox(height: 50), // Espaço fixo

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0), 
                        child: HeartbeatGraph(
                          height: 100,
                        ),
                      ),
                      
                      const SizedBox(height: 155), // Espaço acima do botão flutuante

                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: baseGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: baseGreen.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () => _showHistoryMenu(context),
                            child: const Icon(Icons.history, color: Colors.black), 
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20), 
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 26.0, right: 26.0, bottom: 30.0), 
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: baseGreen), 
                        onPressed: controller.isRecording 
                            ? controller.stopRecording 
                            : null,
                        child: Text(
                          controller.isRecording ? 'PARAR' : 'MEDIÇÃO COMPLETA',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}