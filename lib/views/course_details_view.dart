import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course_model.dart';
import '../viewmodels/course_viewmodel.dart';

class CourseDetailsView extends StatelessWidget {
  final Course course;

  const CourseDetailsView({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobre o curso',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    course.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF444444),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Consumer<CourseViewModel>(
              builder: (context, viewModel, _) {
                final bool alreadyEnrolled = viewModel.enrolledCourses
                    .any((c) => c.id == course.id);

                if (alreadyEnrolled) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.green.shade600, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Você já está inscrito neste curso',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      viewModel.enroll(course);
                      final String? message = viewModel.enrollmentMessage;
                      if (message != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        viewModel.clearEnrollmentMessage();
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Inscrever-se'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}