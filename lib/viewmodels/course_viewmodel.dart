import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();

  List<Course> _filteredCourses = [];
  List<Course> _enrolledCourses = [];
  String _searchQuery = '';
  String? _enrollmentMessage;
  bool _isLoading = false;
  String? _errorMessage;

  List<Course> get filteredCourses => _filteredCourses;
  List<Course> get enrolledCourses => _enrolledCourses;
  String get searchQuery => _searchQuery;
  String? get enrollmentMessage => _enrollmentMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CourseViewModel() {
    loadCourses();
  }

  Future<void> loadCourses() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _filteredCourses = _repository.getAllCourses();
      _enrolledCourses = _repository.getEnrolledCourses();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os cursos. Tente novamente.';
    } finally {
      _setLoading(false);
    }
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

  Future<void> enroll(Course course) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final success = _repository.enroll(course);
      _enrolledCourses = _repository.getEnrolledCourses();
      _enrollmentMessage = success
          ? 'Inscrição em "${course.title}" realizada com sucesso!'
          : 'Você já está inscrito em "${course.title}"';
    } catch (e) {
      _errorMessage = 'Erro ao realizar inscrição. Tente novamente.';
    } finally {
      _setLoading(false);
    }
  }

  void clearEnrollmentMessage() {
    _enrollmentMessage = null;
    notifyListeners();
  }

  Future<void> addCourse(Course course) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      _repository.addCourse(course);
      _refreshFilteredCourses();
    } catch (e) {
      _errorMessage = 'Erro ao cadastrar curso. Tente novamente.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCourse(Course course) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final success = _repository.updateCourse(course);
      if (success) {
        _enrolledCourses = _repository.getEnrolledCourses();
        _refreshFilteredCourses();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar curso. Tente novamente.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeCourse(String courseId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final success = _repository.removeCourse(courseId);
      if (success) {
        _enrolledCourses = _repository.getEnrolledCourses();
        _refreshFilteredCourses();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao remover curso. Tente novamente.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _refreshFilteredCourses() {
    _filteredCourses = _searchQuery.trim().isEmpty
        ? _repository.getAllCourses()
        : _repository.searchCourses(_searchQuery);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
