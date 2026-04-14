import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course_model.dart';
import '../viewmodels/course_viewmodel.dart';

class RegistrationConfirmDialog extends StatelessWidget {
  final Course course;

  const RegistrationConfirmDialog({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Confirmar inscrição',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Deseja confirmar sua inscrição no curso "${course.title}"?',
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(88, 42),
          ),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final CourseViewModel viewModel =
                context.read<CourseViewModel>();
            viewModel.enroll(course);
            viewModel.clearEnrollmentMessage();
            Navigator.of(context).pop();
            context.go('/home');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Inscrição em "${course.title}" realizada!'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(12),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(88, 42),
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}