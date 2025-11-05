// lib/core/testing/test_data_factories/user_factory.dart
class UserFactory {
  static UserEntity createUser({
    String? id,
    String name = 'Test User',
    String email = 'test@paypulse.com',
    double balance = 1000.0,
  }) {
    return UserEntity(
      id: id ?? const Uuid().v4(),
      name: name,
      email: email,
      wallet: WalletFactory.createWallet(balance: balance),
      preferences: UserPreferences.defaults(),
    );
  }
  
  static List<UserEntity> createUsers(int count) {
    return List.generate(count, (index) => createUser(
      name: 'User $index',
      email: 'user$index@paypulse.com',
    ));
  }
}