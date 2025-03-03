# CLAUDE.md - Stopwatch App Guidelines

## Commands
- Run app: `flutter run`
- Run tests: `flutter test`
- Run single test: `flutter test test/widget_test.dart`
- Lint/static analysis: `flutter analyze`
- Format code: `flutter format lib/`
- Generate code: `flutter pub run build_runner build`
- Watch code generation: `flutter pub run build_runner watch`

## Code Style & Architecture
- **Architecture**: Clean Architecture (Domain, Application, Presentation layers)
- **State Management**: Riverpod (using annotations & code generation)
- **Naming**: camelCase for variables/methods, PascalCase for classes
- **Imports**: Group imports by 1) Dart/Flutter 2) External packages 3) Project imports
- **Error Handling**: Use Result pattern or throw/catch with meaningful messages
- **Provider Naming**: Follow [entity]_provider.dart for state providers
- **Test Coverage**: All usecases and repositories should have tests
- **Documentation**: Document all public APIs with /// comments

Reference the project structure for examples. Keep code DRY and well-organized.