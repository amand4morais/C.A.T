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

  void _refreshFilteredCourses() {
    if (_searchQuery.trim().isEmpty) {
      _filteredCourses = _repository.getAllCourses();
      return;
    }
    _filteredCourses = _repository.searchCourses(_searchQuery);
  }

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
    _enrollmentMessage = success
        ? 'Inscrição em "${course.title}" realizada com sucesso!'
        : 'Você já está inscrito em "${course.title}"';
    notifyListeners();
  }

  void clearEnrollmentMessage() {
    _enrollmentMessage = null;
    notifyListeners();
  }

  void addCourse(Course course) {
    _repository.addCourse(course);
    _refreshFilteredCourses();
    notifyListeners();
  }

  bool updateCourse(Course course) {
    final success = _repository.updateCourse(course);
    if (!success) return false;
    _enrolledCourses = _repository.getEnrolledCourses();
    _refreshFilteredCourses();
    notifyListeners();
    return true;
  }

  bool removeCourse(String courseId) {
    final success = _repository.removeCourse(courseId);
    if (!success) return false;
    _enrolledCourses = _repository.getEnrolledCourses();
    _refreshFilteredCourses();
    notifyListeners();
    return true;
  }
}
