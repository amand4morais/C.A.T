import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../repositories/course_repository.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseRepository _repository = CourseRepository();

  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  List<Course> _enrolledCourses = [];
  String _searchQuery = '';
  String? _enrollmentMessage;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentRa;

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
      _allCourses = await _repository.getAllCourses();
      _applyFilter();
      if (_currentRa != null) {
        _enrolledCourses = await _repository.getEnrolledCourses(_currentRa!);
      }
    } catch (e) {
      _errorMessage = 'Não foi possível carregar os cursos. Tente novamente.';
    } finally {
      _setLoading(false);
    }
  }

  void updateAuth(String? ra) {
    if (_currentRa != ra) {
      _currentRa = ra;
      if (ra != null) {
        _loadEnrolledCoursesForCurrentUser();
      } else {
        _enrolledCourses = [];
        notifyListeners();
      }
    }
  }

  Future<void> _loadEnrolledCoursesForCurrentUser() async {
    try {
      _enrolledCourses = await _repository.getEnrolledCourses(_currentRa!);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Não foi possível carregar suas inscrições.';
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredCourses = List.of(_allCourses);
      return;
    }
    final lower = _searchQuery.toLowerCase();
    _filteredCourses = _allCourses
        .where(
          (c) =>
              c.title.toLowerCase().contains(lower) ||
              c.description.toLowerCase().contains(lower),
        )
        .toList();
  }

  Future<void> enroll(Course course) async {
    if (_currentRa == null) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _repository.enroll(_currentRa!, course);
      _enrolledCourses = await _repository.getEnrolledCourses(_currentRa!);
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

  Future<bool> addCourse(Course course) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _repository.addCourse(course);
      if (!success) {
        _errorMessage = 'Erro ao cadastrar curso. Tente novamente.';
        return false;
      }
      await _reloadAll();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cadastrar curso no repositório: $e');
      }
      _errorMessage = 'Erro ao cadastrar curso. Tente novamente.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCourse(Course course) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _repository.updateCourse(course);
      if (success) await _reloadAll();
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
      final success = await _repository.removeCourse(courseId);
      if (success) await _reloadAll();
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao remover curso. Tente novamente.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _reloadAll() async {
    _allCourses = await _repository.getAllCourses();
    _applyFilter();
    if (_currentRa != null) {
      _enrolledCourses = await _repository.getEnrolledCourses(_currentRa!);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
