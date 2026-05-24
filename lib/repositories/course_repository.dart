import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course_model.dart';

class CourseRepository {
  CourseRepository._internal();
  static final CourseRepository _instance = CourseRepository._internal();
  factory CourseRepository() => _instance;

  Course _mapToCourse(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

  Future<String?> _getUserId(String ra) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('ra', ra)
        .maybeSingle();
    return response?['id'] as String?;
  }

  Future<List<Course>> getAllCourses() async {
    final response = await Supabase.instance.client
        .from('courses')
        .select();
    return (response as List)
        .map((e) => _mapToCourse(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Course>> getEnrolledCourses(String ra) async {
    final userId = await _getUserId(ra);
    if (userId == null) return [];
    final response = await Supabase.instance.client
        .from('enrollments')
        .select('courses(*)')
        .eq('user_id', userId);
    return (response as List)
        .map((e) => _mapToCourse(e['courses'] as Map<String, dynamic>))
        .toList();
  }

  Future<bool> addCourse(Course course) async {
    try {
      await Supabase.instance.client.from('courses').insert({
        'id': course.id,
        'title': course.title,
        'description': course.description,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCourse(Course updatedCourse) async {
    try {
      await Supabase.instance.client
          .from('courses')
          .update({
            'title': updatedCourse.title,
            'description': updatedCourse.description,
          })
          .eq('id', updatedCourse.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeCourse(String courseId) async {
    try {
      await Supabase.instance.client
          .from('courses')
          .delete()
          .eq('id', courseId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> enroll(String ra, Course course) async {
    try {
      final userId = await _getUserId(ra);
      if (userId == null) return false;
      final existing = await Supabase.instance.client
          .from('enrollments')
          .select()
          .eq('user_id', userId)
          .eq('course_id', course.id)
          .maybeSingle();
      if (existing != null) return false;
      await Supabase.instance.client.from('enrollments').insert({
        'user_id': userId,
        'course_id': course.id,
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}