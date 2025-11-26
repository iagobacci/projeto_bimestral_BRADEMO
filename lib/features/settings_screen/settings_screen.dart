import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:trabalho01/core/theme/app_theme.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../aluno/presentation/controller/aluno_controller.dart';
import '../aluno/domain/entities/aluno_entity.dart';
import '../home/presentation/controller/home_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool receiveNotifications = true;
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _senhaController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = true;
  AlunoEntity? _aluno;
  DateTime? _dataNascimento;

  @override
  void initState() {
    super.initState();
    _loadAlunoData();
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _senhaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadAlunoData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final alunoQuery = await FirebaseFirestore.instance
          .collection('alunos')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (alunoQuery.docs.isNotEmpty) {
        final aluno = AlunoEntity.fromMap(
          alunoQuery.docs.first.id,
          alunoQuery.docs.first.data(),
        );
        setState(() {
          _aluno = aluno;
          _pesoController.text = aluno.peso?.toStringAsFixed(1) ?? '';
          _alturaController.text = aluno.altura?.toStringAsFixed(2) ?? '';
          _dataNascimento = aluno.dataNascimento;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_aluno == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Aluno não encontrado')),
      );
      return;
    }

    final peso = _pesoController.text.trim().isEmpty
        ? null
        : double.tryParse(_pesoController.text.trim());
    final altura = _alturaController.text.trim().isEmpty
        ? null
        : double.tryParse(_alturaController.text.trim());

    if (peso != null && (peso < 0 || peso > 500)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peso inválido')),
      );
      return;
    }

    if (altura != null && (altura < 0 || altura > 3)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Altura inválida')),
      );
      return;
    }

    // Atualizar senha se fornecida
    final senha = _senhaController.text.trim();
    if (senha.isNotEmpty) {
      if (senha.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A senha deve ter pelo menos 6 caracteres')),
        );
        return;
      }
      
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePassword(senha);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar senha: ${e.toString()}')),
        );
        return;
      }
    }

    // Atualizar email se fornecido
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      if (!email.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email inválido')),
        );
        return;
      }
      
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateEmail(email);
          // Atualizar também no Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'email': email});
          
          // Atualizar também no documento do aluno se existir
          if (_aluno!.id != null) {
            await FirebaseFirestore.instance
                .collection('alunos')
                .doc(_aluno!.id!)
                .update({'email': email});
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar email: ${e.toString()}')),
        );
        return;
      }
    }

    final controller = context.read<AlunoController>();
    final alunoAtualizado = _aluno!.copyWith(
      peso: peso,
      altura: altura,
      dataNascimento: _dataNascimento ?? _aluno!.dataNascimento,
      email: email.isNotEmpty ? email : _aluno!.email,
    );

    final success = await controller.updateAluno(_aluno!.id!, alunoAtualizado);

    if (success && mounted) {
      // Atualizar HomeController
      final homeController = context.read<HomeController>();
      await homeController.refresh();

      // Limpar campos de senha e email após salvar
      _senhaController.clear();
      _emailController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error ?? 'Erro ao atualizar dados')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Configurações",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.all(2), // espessura da borda
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green, // cor da borda
                  width: 3, // largura da borda
                ),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage("assets/images/homem_icon.jpg"),
              ),
            ),
          ),
        ],
      ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildButtonCard(
              icon: Icons.person,
              text: "Alterar Foto de Perfil",
              onTap: () {},
            ),

            const SizedBox(height: 15),

            _buildAccountManagementCard(),

            const SizedBox(height: 15),

            _buildPersonalDataCard(),

            const SizedBox(height: 15),

            _buildNotificationsCard(),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(41, 227, 60, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Salvar",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Barra de navegação inferior
      bottomNavigationBar: CustomBottomNav(
      componentColor: widgetsColor,
      activeKey: 'config',
     onHomeTap: () => Navigator.pushNamed(context, '/home'),
     onTreinoTap: () => Navigator.pushNamed(context, '/treino'),
     onAtividadesTap: () => Navigator.pushNamed(context, '/atividades'),
     onConfigTap: () => Navigator.pushNamed(context, '/settings'),
    ),
      
    );
  }



  Widget _buildButtonCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color.fromRGBO(41, 227, 60, 1)),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountManagementCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.settings, color: const Color.fromRGBO(41, 227, 60, 1)),
              SizedBox(width: 10),
              Text(
                "Gerenciamento da Conta",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),
          const Text(
            "Alterar Senha:",
            style: TextStyle(color: Color.fromRGBO(41, 227, 60, 1)),
          ),
          const SizedBox(height: 5),

          TextField(
            controller: _senhaController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade800,
              hintText: "Nova senha (deixe em branco para não alterar)",
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 15),
          const Text(
            "Alterar E-mail:",
            style: TextStyle(color: Color.fromRGBO(41, 227, 60, 1)),
          ),
          const SizedBox(height: 5),

          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade800,
              hintText: "Novo email (deixe em branco para não alterar)",
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.notifications_active,
                color: const Color.fromRGBO(41, 227, 60, 1),
              ),
              SizedBox(width: 10),
              Text(
                "Preferência de Notificações",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Receber notificações\nsobre treinos",
                style: TextStyle(color: Colors.white70),
              ),
              Switch(
                value: receiveNotifications,
                activeColor: Colors.greenAccent,
                onChanged: (v) {
                  setState(() {
                    receiveNotifications = v;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.monitor_weight, color: Color.fromRGBO(41, 227, 60, 1)),
              SizedBox(width: 10),
              Text(
                "Dados Pessoais",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            "Peso (kg):",
            style: TextStyle(color: Color.fromRGBO(41, 227, 60, 1)),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _pesoController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade800,
              hintText: "Ex: 70.5",
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Altura (m):",
            style: TextStyle(color: Color.fromRGBO(41, 227, 60, 1)),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _alturaController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade800,
              hintText: "Ex: 1.75",
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          // Data de Nascimento
          Row(
            children: [
              const Icon(Icons.cake, color: Color.fromRGBO(41, 227, 60, 1)),
              const SizedBox(width: 10),
              const Text(
                "Data de Nascimento:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dataNascimento != null 
                        ? DateFormat('dd/MM/yyyy').format(_dataNascimento!)
                        : 'Selecione a data',
                    style: TextStyle(
                      color: _dataNascimento != null ? Colors.white : Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: Color.fromRGBO(41, 227, 60, 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? now,
      firstDate: hundredYearsAgo,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color.fromRGBO(41, 227, 60, 1),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dataNascimento = picked;
      });
    }
  }
}
