import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/aluno_entity.dart';
import '../../domain/repositories/aluno_repository.dart';

class AlunoController extends ChangeNotifier {
  final AlunoRepository repository;

  AlunoController(this.repository);

  List<AlunoEntity> _alunos = [];
  bool _isLoading = false;
  String? _error;

  List<AlunoEntity> get alunos => _alunos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAlunos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _alunos = await repository.getAllAlunos();
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar alunos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAluno(AlunoEntity aluno, {String? senha}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? userId;
      
      // Se senha foi fornecida, criar usuário no Firebase Auth
      if (senha != null && senha.isNotEmpty) {
        try {
          final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: aluno.email,
            password: senha,
          );
          userId = userCredential.user?.uid;
          
          // Aguardar um pouco para garantir que o token esteja disponível
          await Future.delayed(const Duration(milliseconds: 200));
          
          // Salvar dados do usuário no Firestore
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && userId != null) {
            await FirebaseFirestore.instance.collection('users').doc(userId).set({
              'nome': aluno.nome,
              'email': aluno.email,
              'genero': aluno.genero,
              'tipoUsuario': 'aluno',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (e) {
          _error = 'Erro ao criar usuário: ${e.toString()}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      // Obter ID do personal logado
      final currentUser = FirebaseAuth.instance.currentUser;
      final personalId = currentUser?.uid;
      
      // Verificar se o usuário logado é personal através do Firestore
      if (personalId != null) {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(personalId).get();
          final tipoUsuario = userDoc.data()?['tipoUsuario'] ?? 'aluno';
          
          final alunoWithDates = aluno.copyWith(
            createdAt: DateTime.now(),
            userId: userId,
            personalId: tipoUsuario == 'personal' ? personalId : null,
          );
          
          await repository.createAluno(alunoWithDates);
          await loadAlunos();
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (e) {
          String errorMsg = e.toString();
          if (errorMsg.startsWith('Exception: ')) {
            errorMsg = errorMsg.substring(11);
          }
          _error = errorMsg;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Você precisa estar autenticado para criar um aluno';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      String errorMsg = e.toString();
      // Remove o prefixo "Exception: " se existir
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      _error = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAluno(String id, AlunoEntity aluno) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.updateAluno(id, aluno);
      await loadAlunos();
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar aluno: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAluno(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.deleteAluno(id);
      await loadAlunos();
      return true;
    } catch (e) {
      _error = 'Erro ao deletar aluno: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}

