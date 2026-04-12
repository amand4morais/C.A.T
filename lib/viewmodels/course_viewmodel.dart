import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();
  List<Course> _filteredCourses = [];
  List<Course> _enrolledCourses = [];
  String _searchQuery = '';
  String? _enrollmentMessage;

  CourseViewModel() {
    _filteredCourses = _repository.getAllCourses();
    _enrolledCourses = _repository.getEnrolledCourses();
  }

  List<Course> get filteredCourses => _filteredCourses;
  List<Course> get enrolledCourses => _enrolledCourses;
  String get searchQuery => _searchQuery;
  String? get enrollmentMessage => _enrollmentMessage;

  void search(String query) {
    _searchQuery = query;
    _filteredCourses = _repository.searchCourses(query);
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredCourses = _repository.getAllCourses();
    notifyListeners();
  }

  void enroll(Course course) {
    final success = _repository.enroll(course);
    _enrolledCourses = _repository.getEnrolledCourses();
    _enrollmentMessage = success ? 'Inscrição em "${course.title}" realizada com sucesso!' : 'Você já está inscrito em "${course.title}"';
    notifyListeners();
  }

  void clearEnrollmentMessage() {
    _enrollmentMessage = null;
    notifyListeners();
  }
}