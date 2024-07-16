import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:tycg/models/lack_data.dart';
import 'package:tycg/screens/error/error_screen.dart';
import 'package:tycg/screens/lack/inner_select_screen.dart';
import 'package:tycg/screens/lack/third_select_screen.dart';
import 'package:tycg/screens/login/login_screen.dart';
import 'package:tycg/screens/splash/splash_screen.dart';
import 'package:tycg/screens/home/home_screen.dart';
import 'package:tycg/screens/lack/lack_screen.dart';
import 'package:tycg/screens/lack/lack_edit_screen.dart';
import 'package:tycg/screens//lack/lack_select_screen.dart';
import 'package:tycg/screens/operation/operation_screen.dart';

GoRouter routes = GoRouter(routes: [
  GoRoute(
      name: 'login',
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        var loginValue = state.extra == true;
        return LoginScreen(extra: loginValue);
      }),
  GoRoute(
      name: 'search',
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      }),
  GoRoute(
      name: 'error',
      path: '/error',
      builder: (BuildContext context, GoRouterState state) {
        return const ErrorScreen();
      }),
  GoRoute(
      name: 'home',
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      }),
  GoRoute(
      name: 'operation',
      path: '/operation',
      builder: (BuildContext context, GoRouterState state) {
        return const OperationItemScreen();
      }),
  GoRoute(
      name: 'lack',
      path: '/lack',
      builder: (BuildContext context, GoRouterState state) {
        return const LackScreen();
      }),
  GoRoute(
      name: 'lack-edit',
      path: '/lack-edit',
      builder: (BuildContext context, GoRouterState state) {
        return LackEditScreen(extra: (state.extra as Map)['lack'] as Lack?);
      }),
  GoRoute(
      name: 'lack-select',
      path: '/lack-select',
      builder: (BuildContext context, GoRouterState state) {
        return LackSelectScreen(
            extra: (state.extra as Map)['list'] as List<dynamic>);
      }),
  GoRoute(
      name: 'inner-select',
      path: '/inner-select',
      builder: (BuildContext context, GoRouterState state) {
        return InnerSelectScreen(
            extra: (state.extra as Map)['list'] as List<dynamic>);
      }),
  GoRoute(
      name: 'third-select',
      path: '/third-select',
      builder: (BuildContext context, GoRouterState state) {
        return ThirdSelectScreen(
            extra: (state.extra as Map)['list'] as List<dynamic>);
      }),
]);
