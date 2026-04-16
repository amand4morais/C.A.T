import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/course_viewmodel.dart';
import '../widgets/course_card.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    CourseViewModel viewModel,
    Course course,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover curso'),
        content: Text('Deseja remover o curso "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = viewModel.removeCourse(course.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Curso "${course.title}" removido com sucesso!'
              : 'Não foi possível remover o curso.',
        ),
        backgroundColor: success
            ? const Color(0xFF6A1B9A)
            : Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Gerenciar Cursos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/add-course'),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
            ),
            tooltip: 'Cadastrar novo curso',
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                context.read<AuthViewModel>().logout().then((_) {
                  if (context.mounted) context.go('/login');
                });
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF6A1B9A),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Painel do Administrador',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<CourseViewModel>(
              builder: (context, viewModel, _) {
                final List<Course> courses = viewModel.filteredCourses;

                if (courses.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum curso cadastrado na plataforma',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/add-course'),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Cadastrar curso'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6A1B9A),
                              side: const BorderSide(color: Color(0xFF6A1B9A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: courses.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemBuilder: (context, index) {
                      final Course course = courses[index];
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CourseCard(
                              course: course,
                              onTap: () => context.push(
                                '/course-details',
                                extra: course,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: PopupMenuButton<String>(
                              tooltip: 'Ações do curso',
                              onSelected: (value) {
                                if (value == 'edit') {
                                  context.push('/edit-course', extra: course);
                                  return;
                                }
                                if (value == 'delete') {
                                  _confirmDelete(context, viewModel, course);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Remover'),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert_rounded),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
