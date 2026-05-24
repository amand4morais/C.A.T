import 'package:flutter/foundation.dart';

import '../models/course_model.dart';
import '../repositories/course_repository.dart';
import 'auth_viewmodel.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();

  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  List<Course> _enrolledCourses = [];
  String _searchQuery = '';
  String? _enrollmentMessage;
  String? _currentUserRa;

  List<Course> get filteredCourses => _filteredCourses;
  List<Course> get enrolledCourses => _enrolledCourses;
  String get searchQuery => _searchQuery;
  String? get enrollmentMessage => _enrollmentMessage;

  Future<void> fetchInitialData() async {
    try {
      _allCourses = await _repository.getAllCourses();
      _applyCurrentSearch();
      if (_currentUserRa != null) {
        _enrolledCourses = await _repository.getEnrolledCourses(_currentUserRa!);
      } else {
        _enrolledCourses = [];
      }
      notifyListeners();
    } catch (_) {}
  }

  void updateAuth(AuthViewModel authViewModel) {
    _currentUserRa = authViewModel.currentUser?.ra;
    fetchInitialData();
  }

  void search(String query) {
    _searchQuery = query;
    _applyCurrentSearch();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredCourses = List.of(_allCourses);
    notifyListeners();
  }

  Future<void> enroll(Course course) async {
    if (_currentUserRa == null) return;
    try {
      final success = await _repository.enroll(_currentUserRa!, course);
      if (success) {
        _enrolledCourses = await _repository.getEnrolledCourses(_currentUserRa!);
        _enrollmentMessage = 'Inscrição em "${course.title}" realizada com sucesso!';
      } else {
        _enrollmentMessage = 'Você já está inscrito em "${course.title}"';
      }
      notifyListeners();
    } catch (_) {
      _enrollmentMessage = 'Erro ao realizar inscrição. Tente novamente.';
      notifyListeners();
    }
  }

  void clearEnrollmentMessage() {
    _enrollmentMessage = null;
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    try {
      final success = await _repository.addCourse(course);
      if (success) {
        _allCourses.add(course);
        _applyCurrentSearch();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> updateCourse(Course course) async {
    try {
      final success = await _repository.updateCourse(course);
      if (!success) return false;
      final index = _allCourses.indexWhere((c) => c.id == course.id);
      if (index != -1) _allCourses[index] = course;
      final enrolledIndex = _enrolledCourses.indexWhere((c) => c.id == course.id);
      if (enrolledIndex != -1) _enrolledCourses[enrolledIndex] = course;
      _applyCurrentSearch();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeCourse(String courseId) async {
    try {
      final success = await _repository.removeCourse(courseId);
      if (!success) return false;
      _allCourses.removeWhere((c) => c.id == courseId);
      _enrolledCourses.removeWhere((c) => c.id == courseId);
      _applyCurrentSearch();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _applyCurrentSearch() {
    if (_searchQuery.trim().isEmpty) {
      _filteredCourses = List.of(_allCourses);
      return;
    }
    final lower = _searchQuery.toLowerCase();
    _filteredCourses = _allCourses
        .where(
          (course) =>
              course.title.toLowerCase().contains(lower) ||
              course.description.toLowerCase().contains(lower),
        )
        .toList();
  }
}