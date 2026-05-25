import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course_model.dart';
import '../viewmodels/course_viewmodel.dart';

class AddCourseView extends StatefulWidget {
  final Course? courseToEdit;

  const AddCourseView({super.key, this.courseToEdit});

  @override
  State<AddCourseView> createState() => _AddCourseViewState();
}

class _AddCourseViewState extends State<AddCourseView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool get _isEditing => widget.courseToEdit != null;

  @override
  void initState() {
    super.initState();
    final course = widget.courseToEdit;
    if (course != null) {
      _titleController.text = course.title;
      _descriptionController.text = course.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Título é obrigatório';
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) return 'Descrição é obrigatória';
    return null;
  }

  Future<void> _onSubmit(CourseViewModel viewModel) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (_isEditing) {
      final updatedCourse = Course(
        id: widget.courseToEdit!.id,
        title: title,
        description: description,
      );
      final success = await viewModel.updateCourse(updatedCourse);
      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.errorMessage ?? 'Não foi possível atualizar o curso.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Curso "$title" atualizado com sucesso!'),
          backgroundColor: const Color(0xFF6A1B9A),
        ),
      );
    } else {
      final newCourse = Course(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
      );
      await viewModel.addCourse(newCourse);
      if (!mounted) return;

      if (viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Curso "$title" cadastrado com sucesso!'),
          backgroundColor: const Color(0xFF6A1B9A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isEditing ? 'Editar Curso' : 'Cadastrar Curso',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<CourseViewModel>(
        builder: (context, viewModel, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        enabled: !viewModel.isLoading,
                        decoration: InputDecoration(
                          labelText: 'Título do curso',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF6A1B9A),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: _validateTitle,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        enabled: !viewModel.isLoading,
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF6A1B9A),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 4,
                        validator: _validateDescription,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _onSubmit(viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF6A1B9A,
                            ).withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isEditing
                                      ? 'Salvar Alterações'
                                      : 'Cadastrar Curso',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
