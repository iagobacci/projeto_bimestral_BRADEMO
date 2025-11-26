import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/atividade_controller.dart';
import '../../domain/entities/atividade_entity.dart';
import '../../../aluno/presentation/controller/aluno_controller.dart';

class AtividadeFormScreen extends StatefulWidget {
  final AtividadeEntity? atividade;
  final String? preSelectedAlunoId; // Para pré-selecionar aluno

  const AtividadeFormScreen({super.key, this.atividade, this.preSelectedAlunoId});

  @override
  State<AtividadeFormScreen> createState() => _AtividadeFormScreenState();
}

class _AtividadeFormScreenState extends State<AtividadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _duracaoController = TextEditingController();
  final _distanciaController = TextEditingController();
  final _caloriasController = TextEditingController();
  final _passosController = TextEditingController();
  DateTime? _dataAtividade;
  String? _selectedAlunoId;
  String? _tipoUsuario = 'aluno'; // Inicializar com 'aluno' como padrão
  Stream<Position>? _positionStream;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isRequestingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.atividade != null) {
      _tipoController.text = widget.atividade!.tipo;
      _descricaoController.text = widget.atividade!.descricao;
      _duracaoController.text = widget.atividade!.duracaoMinutos?.toString() ?? '';
      _distanciaController.text = widget.atividade!.distanciaMetros?.toString() ?? '';
      _caloriasController.text = widget.atividade!.calorias?.toString() ?? '';
      _passosController.text = widget.atividade!.passos?.toString() ?? '';
      _dataAtividade = widget.atividade!.dataAtividade;
      _selectedAlunoId = widget.atividade!.alunoId;
    } else {
      _dataAtividade = DateTime.now(); // Data atual como padrão
      _selectedAlunoId = widget.preSelectedAlunoId;
    }
    _loadTipoUsuario();
    if (widget.atividade == null) {
      _initLocationStream();
    }
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
        });
      } catch (e) {
        setState(() {
          _tipoUsuario = 'aluno';
        });
      }
    } else {
      setState(() {
        _tipoUsuario = 'aluno';
      });
    }
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _descricaoController.dispose();
    _duracaoController.dispose();
    _distanciaController.dispose();
    _caloriasController.dispose();
    _passosController.dispose();
    super.dispose();
  }

  Future<void> _initLocationStream() async {
    setState(() {
      _isRequestingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Serviços de localização estão desabilitados'),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permissão de localização negada'),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de localização negada permanentemente'),
            ),
          );
        }
        return;
      }

      setState(() {
        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingLocation = false;
        });
      }
    }
  }

  Future<void> _updateAddress(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final result = placemarks[0];
        setState(() {
          _currentAddress =
              '${result.locality ?? ''} - ${result.administrativeArea ?? ''}, ${result.country ?? ''}';
        });
      }
    } catch (_) {
      // Se der erro ao buscar endereço, apenas ignora
    }
  }

  Future<void> _selectDateAndTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dataAtividade ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: baseGreen,
              onPrimary: Colors.black,
              surface: widgetsColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _dataAtividade != null
            ? TimeOfDay.fromDateTime(_dataAtividade!)
            : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: baseGreen,
                onPrimary: Colors.black,
                surface: widgetsColor,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: Colors.black,
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _dataAtividade = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Para personal, usar o aluno selecionado ou o pré-selecionado
    final alunoIdToUse = _selectedAlunoId ?? widget.preSelectedAlunoId;
    
    if (alunoIdToUse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um aluno')),
      );
      return;
    }

    final controller = context.read<AtividadeController>();
    final atividade = AtividadeEntity(
      id: widget.atividade?.id,
      alunoId: alunoIdToUse,
      tipo: _tipoController.text.trim(),
      descricao: _descricaoController.text.trim(),
      dataAtividade: _dataAtividade ?? DateTime.now(), // Usa data atual se não tiver
      duracaoMinutos: _duracaoController.text.trim().isEmpty ? null : double.tryParse(_duracaoController.text.trim()),
      distanciaMetros: _distanciaController.text.trim().isEmpty ? null : double.tryParse(_distanciaController.text.trim()),
      calorias: _caloriasController.text.trim().isEmpty ? null : int.tryParse(_caloriasController.text.trim()),
      passos: _passosController.text.trim().isEmpty ? null : int.tryParse(_passosController.text.trim()),
      createdAt: widget.atividade?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (widget.atividade == null) {
      success = await controller.createAtividade(atividade);
    } else {
      success = await controller.updateAtividade(widget.atividade!.id!, atividade);
    }

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.atividade == null ? 'Atividade criada com sucesso' : 'Atividade atualizada com sucesso')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error ?? 'Erro ao salvar atividade')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alunoController = context.watch<AlunoController>();
    
    // Carregar alunos se ainda não foram carregados (especialmente importante para personal)
    if (alunoController.alunos.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        alunoController.loadAlunos();
      });
    }
    
    // Se for personal e não tiver alunos carregados, garantir que carregue
    if (_tipoUsuario == 'personal' && alunoController.alunos.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        alunoController.loadAlunos();
      });
    }
    
    // Se for aluno, obter automaticamente o alunoId
    if (_tipoUsuario == 'aluno' && _selectedAlunoId == null && widget.preSelectedAlunoId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            final alunoQuery = await FirebaseFirestore.instance
                .collection('alunos')
                .where('userId', isEqualTo: user.uid)
                .limit(1)
                .get();
            if (alunoQuery.docs.isNotEmpty && mounted) {
              setState(() {
                _selectedAlunoId = alunoQuery.docs.first.id;
              });
            }
          } catch (e) {
            // Erro ao buscar aluno
          }
        }
      });
    }
    

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.atividade == null ? 'Nova Atividade' : 'Editar Atividade'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Dropdown de aluno: sempre mostrar se for personal (mesmo que tenha preSelectedAlunoId)
            if (_tipoUsuario == 'personal' && widget.atividade == null)
              DropdownButtonFormField<String>(
                value: _selectedAlunoId ?? widget.preSelectedAlunoId,
                decoration: const InputDecoration(
                  labelText: 'Aluno *',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
                ),
                dropdownColor: widgetsColor,
                style: const TextStyle(color: Colors.white),
                items: alunoController.alunos.isEmpty
                    ? [const DropdownMenuItem(value: null, child: Text('Carregando alunos...'))]
                    : alunoController.alunos.map((aluno) {
                        return DropdownMenuItem<String>(
                          value: aluno.id,
                          child: Text(aluno.nome),
                        );
                      }).toList(),
                onChanged: (value) => setState(() => _selectedAlunoId = value),
                validator: (value) {
                  final selectedValue = value ?? widget.preSelectedAlunoId;
                  return selectedValue == null ? 'Selecione um aluno' : null;
                },
              ),
            // Se for aluno e não tiver pré-selecionado, mostrar dropdown também
            if (_tipoUsuario == 'aluno' && widget.preSelectedAlunoId == null && widget.atividade == null)
              DropdownButtonFormField<String>(
                value: _selectedAlunoId,
                decoration: const InputDecoration(
                  labelText: 'Aluno *',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
                ),
                dropdownColor: widgetsColor,
                style: const TextStyle(color: Colors.white),
                items: alunoController.alunos.isEmpty
                    ? [const DropdownMenuItem(value: null, child: Text('Carregando...'))]
                    : alunoController.alunos.map((aluno) {
                        return DropdownMenuItem<String>(
                          value: aluno.id,
                          child: Text(aluno.nome),
                        );
                      }).toList(),
                onChanged: (value) => setState(() => _selectedAlunoId = value),
                validator: (value) => value == null ? 'Selecione um aluno' : null,
              ),
            // Campo readonly apenas se for aluno e tiver pré-selecionado
            if (_tipoUsuario == 'aluno' && widget.preSelectedAlunoId != null && widget.atividade == null && _selectedAlunoId != null && alunoController.alunos.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: alunoController.alunos.firstWhere((a) => a.id == _selectedAlunoId, orElse: () => alunoController.alunos.first).nome,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Aluno',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _tipoController,
              decoration: const InputDecoration(
                labelText: 'Tipo *',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) => value?.isEmpty ?? true ? 'Tipo é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição *',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Descrição é obrigatória' : null,
            ),
            const SizedBox(height: 16),
            if (widget.atividade == null) ...[
              ListTile(
                title: const Text(
                  'Localização em tempo real',
                  style: TextStyle(color: Colors.white70),
                ),
                subtitle: _isRequestingLocation
                    ? const Text(
                        'Solicitando permissão...',
                        style: TextStyle(color: Colors.white),
                      )
                    : _currentPosition != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_currentPosition!.latitude.toStringAsFixed(5)}, '
                                '${_currentPosition!.longitude.toStringAsFixed(5)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              if (_currentAddress != null)
                                Text(
                                  _currentAddress!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          )
                        : const Text(
                            'Aguardando primeira posição...',
                            style: TextStyle(color: Colors.white),
                          ),
                trailing: IconButton(
                  icon: const Icon(Icons.my_location, color: baseGreen),
                  onPressed: _initLocationStream,
                ),
              ),
              const SizedBox(height: 8),
              if (_positionStream != null)
                StreamBuilder<Position>(
                  stream: _positionStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _currentPosition = snapshot.data;
                      _updateAddress(snapshot.data!);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              const SizedBox(height: 16),
            ],
            ListTile(
              title: const Text('Data e Hora da Atividade', style: TextStyle(color: Colors.white70)),
              subtitle: Text(
                _dataAtividade != null ? DateFormat('dd/MM/yyyy HH:mm').format(_dataAtividade!) : DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.calendar_today, color: baseGreen),
              onTap: () => _selectDateAndTime(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _duracaoController,
              decoration: const InputDecoration(
                labelText: 'Duração (minutos) *',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _distanciaController,
              decoration: const InputDecoration(
                labelText: 'Distância (metros) - opcional',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _caloriasController,
              decoration: const InputDecoration(
                labelText: 'Calorias - opcional',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passosController,
              decoration: const InputDecoration(
                labelText: 'Passos - opcional',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: baseGreen)),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}


