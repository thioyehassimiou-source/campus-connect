import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campusconnect/main.dart';
import 'package:campusconnect/screens/login_screen.dart';
import 'package:campusconnect/screens/home_screen.dart';
import 'package:campusconnect/shared/models/user_model.dart';

void main() {
  group('CampusConnect App Tests', () {
    testWidgets('App should start with login screen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const CampusConnectApp());

      // Verify that login screen is displayed
      expect(find.text('CampusConnect'), findsOneWidget);
      expect(find.text('Connectez-vous à votre campus'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Login form validation', (WidgetTester tester) async {
      await tester.pumpWidget(const CampusConnectApp());

      // Try to login with empty form
      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Veuillez entrer votre email'), findsOneWidget);
      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
    });

    testWidgets('Email field validation', (WidgetTester tester) async {
      await tester.pumpWidget(const CampusConnectApp());

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      // Should show email validation error
      expect(find.text('Veuillez entrer un email valide'), findsOneWidget);
    });

    testWidgets('Password field validation', (WidgetTester tester) async {
      await tester.pumpWidget(const CampusConnectApp());

      // Enter valid email but short password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      // Should show password validation error
      expect(find.text('Le mot de passe doit contenir au moins 6 caractères'), findsOneWidget);
    });

    testWidgets('Navigation to register screen', (WidgetTester tester) async {
      await tester.pumpWidget(const CampusConnectApp());

      // Tap on register link
      await tester.tap(find.text('S\'inscrire'));
      await tester.pumpAndSettle();

      // Should navigate to register screen
      expect(find.text('Inscription'), findsOneWidget);
      expect(find.text('Créer un compte'), findsOneWidget);
    });

    testWidgets('Register form validation', (WidgetTester tester) async {
      await tester.pumpWidget(const CampusConnectApp());

      // Navigate to register screen
      await tester.tap(find.text('S\'inscrire'));
      await tester.pumpAndSettle();

      // Try to register with empty form
      await tester.tap(find.text('S\'inscrire'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Veuillez entrer votre prénom'), findsOneWidget);
      expect(find.text('Veuillez entrer votre nom'), findsOneWidget);
      expect(find.text('Veuillez entrer votre email'), findsOneWidget);
      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
    });

    testWidgets('Home screen displays user info', (WidgetTester tester) async {
      // Create a test user
      final testUser = UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Build home screen with test user
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(user: testUser),
        ),
      );

      // Verify user info is displayed
      expect(find.text('CampusConnect - Test User'), findsOneWidget);
      expect(find.text('Tableau de bord'), findsOneWidget);
      
      // Verify menu items are displayed
      expect(find.text('Emploi du temps'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Annonces'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Services'), findsOneWidget);
    });

    testWidgets('Bottom navigation works', (WidgetTester tester) async {
      final testUser = UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(user: testUser),
        ),
      );

      // Tap on different navigation items
      await tester.tap(find.text('Emploi du temps'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notes'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      // Should still be on home screen (navigation works)
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Menu cards are tappable', (WidgetTester tester) async {
      final testUser = UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(user: testUser),
        ),
      );

      // Tap on documents card
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Should show snackbar (navigation would work in real app)
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('User Model Tests', () {
    test('User model should create correctly', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.id, 'test-id');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.role, UserRole.student);
    });

    test('User model should copy with updates', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        firstName: 'Updated',
        lastName: 'Name',
      );

      expect(updatedUser.firstName, 'Updated');
      expect(updatedUser.lastName, 'Name');
      expect(updatedUser.email, 'test@example.com'); // Should remain unchanged
    });

    test('User model should convert to/from map', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = user.toMap();
      final fromMap = UserModel.fromMap(map);

      expect(fromMap.id, user.id);
      expect(fromMap.email, user.email);
      expect(fromMap.firstName, user.firstName);
      expect(fromMap.lastName, user.lastName);
      expect(fromMap.role, user.role);
    });
  });
}
