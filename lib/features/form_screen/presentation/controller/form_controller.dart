import 'package:flutter/material.dart';

class FormController extends ChangeNotifier {
  // Variáveis que armazenam os dados do formulário
  String? nome;
  String? genero;
  String? senha;
  bool lembrarSenha = false;
  bool notificacoes = false;

  void setNome(String? value) {
    nome = value;
  }
  
  void setSenha(String? value) {
    senha = value;
  }

  void setLembrarSenha(bool? value) {
    lembrarSenha = value ?? false;
    notifyListeners();
  }

  void setNotificacoes(bool value) {
    notificacoes = value;
    notifyListeners();
  }

  void setGenero(String? value) {
    genero = value;
    notifyListeners();
  }

  // Lógica de submissão do formulário executada após a validação da UI
  void handleSubmit(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save(); 
      
      // Exibe o diálogo de sucesso
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Cadastrado com sucesso!"),
          content: Text(
            "Nome: $nome\nSenha: $senha\nGênero: $genero\nLembrar senha: ${lembrarSenha ? "Sim" : "Não"}\nNotificações: ${notificacoes ? "Sim" : "Não"}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Redireciona para a Home, passando o nome como argumento
                Navigator.pushReplacementNamed(
                    context, 
                    '/home',
                    arguments: nome,
                ); 
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
}