import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/course_model.dart';
import '../views/add_course_view.dart';
import '../views/admin_home_view.dart';
import '../views/available_courses_view.dart';
import '../views/course_details_view.dart';
import '../views/home_view.dart';
import '../views/login_view.dart';
import '../views/profile_view.dart';
import '../views/register_view.dart';

class AppRouter {
  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginView(),
        ),
        GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) =>
              const RegisterView(),
        ),
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeView(),
        ),
        GoRoute(
          path: '/admin-home',
          builder: (BuildContext context, GoRouterState state) =>
              const AdminHomeView(),
        ),
        GoRoute(
          path: '/add-course',
          builder: (BuildContext context, GoRouterState state) =>
              const AddCourseView(),
        ),
        GoRoute(
          path: '/edit-course',
          builder: (BuildContext context, GoRouterState state) {
            final Course course = state.extra! as Course;
            return AddCourseView(courseToEdit: course);
          },
        ),
        GoRoute(
          path: '/available-courses',
          builder: (BuildContext context, GoRouterState state) =>
              const AvailableCoursesView(),
        ),
        GoRoute(
          path: '/course-details',
          builder: (BuildContext context, GoRouterState state) {
            final Course course = state.extra! as Course;
            return CourseDetailsView(course: course);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) =>
              const ProfileView(),
        ),
      ],
    );
  }
}
