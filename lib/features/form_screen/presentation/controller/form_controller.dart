import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:trabalho01/features/form_screen/data/repositories/auth_repository_impl.dart';
import 'package:trabalho01/features/aluno/data/datasources/aluno_firebase_datasource.dart';
import 'package:trabalho01/features/aluno/domain/entities/aluno_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class FormController extends ChangeNotifier {
  String? email;
  String? nome;
  String? genero;
  String? senha;
  bool lembrarSenha = false;
  bool notificacoes = false;
  bool isPersonal = false;
  String? codigoPersonal;
  
  String? loginEmail;
  String? loginPassword; 

  final AuthRepositoryImpl authRepository; 
  
  FormController({required this.authRepository});
  void setNome(String? value) { nome = value; }
  void setEmail(String? value) { email = value; }
  void setSenha(String? value) { senha = value; }
  void setLoginEmail(String? value) { loginEmail = value; }
  void setLoginPassword(String? value) { loginPassword = value; }
  void setLembrarSenha(bool? value) { lembrarSenha = value ?? false; notifyListeners(); }
  void setNotificacoes(bool value) { notificacoes = value; notifyListeners(); }
  void setGenero(String? value) { genero = value; notifyListeners(); }
  void setIsPersonal(bool value) { isPersonal = value; codigoPersonal = null; notifyListeners(); }
  void setCodigoPersonal(String? value) { codigoPersonal = value; notifyListeners(); }


  void handleSubmit(BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save(); 
      
      if (isPersonal) {
        if (codigoPersonal != '1') {
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text("Código Inválido"),
              content: Text("O código de personal está incorreto."),
            ),
          );
          return;
        }
      }
      
      try {
        final tipoUsuario = isPersonal ? 'personal' : 'aluno';
        await authRepository.registerNewUser(
          email: email!, 
          nome: nome!,
          senha: senha!,
          genero: genero,
          lembrarSenha: lembrarSenha,
          notificacoes: notificacoes,
          tipoUsuario: tipoUsuario,
        );

        if (tipoUsuario == 'aluno') {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            final alunoDataSource = AlunoFirebaseDataSource();
            final aluno = AlunoEntity(
              nome: nome!,
              email: email!,
              dataNascimento: DateTime.now(),
              genero: genero,
              userId: currentUser.uid,
              createdAt: DateTime.now(),
            );
            try {
              await alunoDataSource.createAluno(aluno);
            } catch (e) {
              debugPrint('Erro ao criar aluno após cadastro: $e');
            }
          }
        }

        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Cadastrado com sucesso!"),
            content: Text(
              "Nome: $nome\nEmail: $email\nGênero: $genero\nLembrar senha: ${lembrarSenha ? "Sim" : "Não"}\nNotificações: ${notificacoes ? "Sim" : "Não"}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  if (!context.mounted) return;
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
      } on FirebaseAuthException catch (e) {
        if (!context.mounted) return;
        String message;
        if (e.code == 'email-already-in-use') {
          message = 'Erro: Este e-mail já está sendo usado.';
        } else if (e.code == 'invalid-email') {
          message = 'Erro: O formato do e-mail é inválido.';
        } else if (e.code == 'weak-password') {
          message = 'Erro: A senha é muito fraca (mínimo 6 caracteres).';
        } else if (e.message != null && e.message!.contains('CONFIGURATION_NOT_FOUND')) {
          message = 'Erro de configuração do Firebase: A configuração de autenticação não foi encontrada.\n\n'
              'Soluções:\n'
              '1. Verifique se o Firebase Authentication está habilitado no Firebase Console\n'
              '2. Adicione o SHA-1 do seu app no Firebase Console (Project Settings > Your apps)\n'
              '3. Baixe o arquivo google-services.json atualizado e substitua o atual\n'
              '4. Limpe e reconstrua o projeto (flutter clean && flutter pub get)';
        } else {
          message = 'Erro de autenticação: ${e.message ?? e.code}.';
        }
        showDialog(
          context: context,
          builder: (_) => AlertDialog(title: const Text("Falha na Autenticação"), content: Text(message)),
        );
      } on FirebaseException catch (e) {
        if (!context.mounted) return;
        String message = 'Erro de Banco de Dados: ${e.code}. Verifique as Regras de Segurança.';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(title: const Text("Falha no Banco de Dados"), content: Text(message)),
        );
      } catch (e) {
        if (!context.mounted) return;
        String errorMessage = 'Não foi possível concluir o cadastro.';
        if (e is Exception) {
          errorMessage = 'Erro: ${e.toString()}';
        } else if (e is Error) {
          errorMessage = 'Erro: ${e.toString()}';
        }
        debugPrint('Erro no cadastro: $e');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Erro Inesperado"), 
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> handleLogin(BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      
      try {
        final userEntity = await authRepository.signIn(
            loginEmail!,
            loginPassword!,
        );

        if (!context.mounted) return;
        Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: userEntity.nome,
        );

      } on FirebaseAuthException catch (e) {
         if (!context.mounted) return;
         String message = 'Falha no login. Verifique suas credenciais.';
         if (e.code == 'user-not-found' || e.code == 'wrong-password') {
             message = 'Usuário ou senha inválidos.';
         } else if (e.code == 'invalid-email') {
             message = 'O formato do e-mail é inválido.';
         }
         showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Erro de Login"), content: Text(message)),);
      } catch (e) {
          if (!context.mounted) return;
          showDialog(context: context, builder: (_) => const AlertDialog(title: Text("Erro Inesperado"), content: Text("Não foi possível realizar o login.")),);
      }
    }
  }
}