import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho01/core/theme/app_theme.dart';
import '../controller/form_controller.dart';

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Chave do formulário para validação 
    final _formKey = GlobalKey<FormState>();

    final controller = context.read<FormController>();
    final state = context.watch<FormController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Cadastre-se:",
            style: TextStyle(
              color: Color.fromARGB(255, 144, 146, 144),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(106, 0, 0, 0),
        centerTitle: true,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon_heartpulse.png',
                  color: baseGreen,
                  width: 90,
                  height: 90,
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Bem-Vindo ao ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: "HealthPulse!",
                        style: TextStyle(
                          color: baseGreen,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Vamos começar:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Formulário de Cadastro
            Form(
              key: _formKey, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Preencha seus dados:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo Nome
                  TextFormField(
                    initialValue: state.nome, 
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nome:",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira seu nome:' : null,
                    // Salva o valor imediatamente no controller
                    onChanged: controller.setNome, 
                    onSaved: (value) => controller.nome = value,
                  ),

                  const SizedBox(height: 20),

                  // Campo Senha
                  TextFormField(
                    initialValue: state.senha, 
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Senha:",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira sua senha:' : null,
                    // Salva o valor  no controller
                    onChanged: controller.setSenha,
                    onSaved: (value) => controller.senha = value,
                  ),

                  const SizedBox(height: 20),

                  // Seleção de Gênero
                  DropdownButtonFormField<String>(
                    value: state.genero, 
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      labelText: "Gênero",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                    ),
                    items: const [ // Opções pré definidas 
                      DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                      DropdownMenuItem(value: "Feminino", child: Text("Feminino")),
                      DropdownMenuItem(value: "Prefiro não informar", child: Text("Prefiro não informar")),
                    ],
                    onChanged: controller.setGenero,
                    validator: (value) => (value == null) ? 'Selecione um gênero' : null,
                  ),

                  const SizedBox(height: 20),

                  // Checkbox para lembrar senha
                  Row(
                    children: [
                      Checkbox(
                        value: state.lembrarSenha,
                        activeColor: baseGreen,
                        onChanged: controller.setLembrarSenha,
                      ),
                      const Text("Lembrar senha", style: TextStyle(color: Colors.white)),
                    ],
                  ),

                  // Switch para notificações
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Receber notificações?", style: TextStyle(color: Colors.white)),
                      Switch(
                        value: state.notificacoes, 
                        activeThumbColor: Colors.greenAccent,
                        onChanged: controller.setNotificacoes,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Botão concluir
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: baseGreen),
                      onPressed: () => controller.handleSubmit(context, _formKey),
                      child: const Text(
                        "Concluir",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}