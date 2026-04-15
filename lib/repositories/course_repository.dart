import '../models/course_model.dart';

class CourseRepository {
  CourseRepository._internal();
  static final CourseRepository _instance = CourseRepository._internal();
  factory CourseRepository() => _instance;

  final List<Course> _avaliableCourses = [
    const Course(
      id: '1',
      title: 'Introdução ao Flutter',
      description:
          'Aprenda os fundamentos do Flutter e crie seus primeiros aplicativos multiplataforma com Dart.',
    ),
    const Course(
      id: '2',
      title: 'Desenvolvimento Web com HTML, CSS e JavaScript',
      description:
          'Construa sites completos e interativos, utilizando das ferramentas padrão de mercado mais utilizadas no desenvolvimento Web.',
    ),
    const Course(
      id: '3',
      title: 'Gerenciamento de Estado com Provider',
      description:
          'Entenda o padrão ChangeNotifier e implemente gerenciamento de estado reativo em apps Flutter.',
    ),
    const Course(
      id: '4',
      title: 'Programação Orientada a Objetos',
      description:
          'Aprenda sobre classes, objetos e os pilares do POO, muito utilizados no mercado atual.',
    ),
    const Course(
      id: '5',
      title: 'Consumo de APIs REST com Dart',
      description:
          'Aprenda a integrar serviços externos utilizando http, dio e tratamento de erros em aplicações Flutter.',
    ),
    const Course(
      id: '6',
      title: 'Banco de Dados Local com SQLite',
      description:
          'Persista dados localmente usando o pacote sqflite, criando migrations e queries eficientes.',
    ),
  ];

  final List<Course> _enrolledCourses = [];

  List<Course> getAllCourses() => List.unmodifiable(_avaliableCourses);
  List<Course> getEnrolledCourses() => List.unmodifiable(_enrolledCourses);

  void addCourse(Course course) {
    _avaliableCourses.add(course);
  }

  List<Course> searchCourses(String query) {
    if (query.trim().isEmpty) return getAllCourses();
    final lower = query.toLowerCase();
    return _avaliableCourses.where(
      (course) =>
          course.title.toLowerCase().contains(lower) ||
          course.description.toLowerCase().contains(lower),
    ).toList();
  }

  bool enroll(Course course) {
    final alreadyEnrolled = _enrolledCourses.any((c) => c.id == course.id);
    if (alreadyEnrolled) return false;
    _enrolledCourses.add(course);
    return true;
  }
}
