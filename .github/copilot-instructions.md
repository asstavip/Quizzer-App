# Custom Instruction for Copilot

When writing Flutter code with Clean Architecture and MVVM using Cubit:

## Architecture

1. **Domain Layer**
    - Entities (pure business objects)
    - Repository interfaces
    - Use cases/interactors (business logic)

2. **Data Layer**
    - Models (data objects with JSON serialization)
    - Repository implementations
    - Data sources (API clients, local storage)

3. **Presentation Layer**
    - Cubits (view models)
    - States (UI states)
    - Views/Widgets (UI components)

## Naming Conventions

- Cubits: `*Cubit` (e.g., `LoginCubit`)
- States: `*State` (e.g., `LoginState`)
- Views: `*Page` or `*Screen`
- Models: `*Model`
- Entities: simple name (e.g., `User`)
- Use cases: `*UseCase` (e.g., `GetUserUseCase`)

## Best Practices

- Create immutable state classes with copyWith methods
- Handle loading, error, and success states
- Use dependency injection for testability
- Keep presentation logic in Cubits
- Separate UI from business logic
- Use repositories to abstract data sources
- Use interfaces for repositories to enable mocking
- Use data transfer objects (DTOs) for API responses
- Use extension methods for common operations
- Use Result types for error handling
- Write unit tests for all layers
- Avoid using `setState` in widgets
- Use streams or Cubit states for reactive UI updates

## Coding Style

- Follow Dart's effective dart guidelines:
   - https://dart.dev/guides/language/effective-dart
- Consistent naming conventions
- Use `final` and `const` where appropriate
- Avoid using `dynamic` type as much as possible
- Keep methods small and focused on a single task


## External Libraries and Tools

To simplify your work and reduce the amount of code you need to write, always search for and utilize
external libraries that align with your project's architecture and requirements. Here are some
recommended libraries for common tasks in Flutter with Clean Architecture and MVVM using Cubit:

1. **State Management**
    - **flutter_bloc**: Official package for using Cubit and Bloc. It provides a simple and
      predictable state management solution.
      dependencies:
      flutter_bloc: ^8.1.3


2. **Dependency Injection**
    - **get_it**: A simple service locator for dependency injection.
      dependencies:
      get_it: ^7.6.4

    - **injectable**: A code generation package that works with `get_it` to simplify dependency
      injection setup.
      dependencies:
      injectable: ^2.1.0
      dev_dependencies:
      injectable_generator: ^2.1.0
      build_runner: ^2.3.3


3. **Networking**
    - **dio**: A powerful HTTP client for Dart, which supports interceptors, global configuration,
      and more.
      dependencies:
      dio: ^5.3.2


4. **JSON Serialization/Deserialization**
    - **json_serializable**: Automatically generates code for converting to and from JSON.
      dependencies:
      json_annotation: ^4.8.1
      dev_dependencies:
      json_serializable: ^6.7.1
      build_runner: ^2.3.3


5. **Local Storage**
    - **shared_preferences**: For simple key-value storage.
      dependencies:
      shared_preferences: ^2.2.2

    - **hive**: A lightweight and fast NoSQL database.
      dependencies:
      hive: ^2.2.3
      hive_flutter: ^1.1.0
      dev_dependencies:
      hive_generator: ^2.0.1


6. **Error Handling**
    - **dartz**: Provides functional programming concepts like `Either` and `Option`, which can be
      used for error handling.
      dependencies:
      dartz: ^0.10.1


7. **Routing**
    - **go_router**: A declarative routing package for Flutter.
      dependencies:
      go_router: ^6.5.7


8. **Testing**
    - **mockito**: A mocking framework for Dart.
      dev_dependencies:
      mockito: ^5.4.2


9. **UI Components**
    - **fluttertoast**: For displaying toast messages.
      dependencies:
      fluttertoast: ^8.2.2

    - **flutter_spinkit**: A collection of loading indicators.
      dependencies:
      flutter_spinkit: ^5.2.0


10. **Logging**

- **logger**: A small, easy-to-use logging package.
  dependencies:
  logger: ^1.4.0
     
## Example Workflow

1. **Identify the Task**: Determine what functionality you need to implement.
2. **Search for Libraries**: Look for existing libraries that can help you achieve the task with
   minimal code.
3. **Evaluate**: Check the library's documentation, popularity, and maintenance status to ensure it
   fits your needs.
4. **Integrate**: Add the library to your `pubspec.yaml` and follow the setup instructions.
5. **Implement**: Use the library in your code, adhering to your project's architecture and best
   practices.
6. **Test**: Write unit and integration tests to ensure the functionality works as expected.

By leveraging external libraries, you can significantly reduce the amount of boilerplate code you
need to write, focus more on the core business logic, and maintain a clean and maintainable
codebase. Always ensure that the libraries you choose are well-maintained and widely used in the
Flutter community to avoid potential issues.