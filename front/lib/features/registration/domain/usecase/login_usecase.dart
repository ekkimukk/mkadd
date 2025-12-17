class LoginUseCase {
  Future<bool> execute(String username, String password) async {
    // Здесь может быть вызов репозитория
    // Для примера просто имитация
    await Future.delayed(const Duration(seconds: 1));
    return username == "user" && password == "1234";
  }
}
