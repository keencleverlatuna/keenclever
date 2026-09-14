import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../services/account_api_service.dart';
import 'server_provider.dart';

final accountApiServiceProvider = Provider<AccountApiService?>((ref) {
  final serverState = ref.watch(serverProvider);

  if (serverState.ipAddress.isEmpty) {
    return null;
  }

  return AccountApiService(
    serverAddress: serverState.ipAddress,
  );
});

final accountsProvider =
AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    final apiService = ref.watch(accountApiServiceProvider);

    if (apiService == null) {
      return [];
    }

    return apiService.getAccounts();
  }

  Future<void> refreshAccounts() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final apiService = ref.read(accountApiServiceProvider);

      if (apiService == null) {
        throw Exception('Server is not connected.');
      }

      return apiService.getAccounts();
    });
  }

  Future<void> addAccount({
    required String accountNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required double balance,
  }) async {
    final apiService = ref.read(accountApiServiceProvider);

    if (apiService == null) {
      throw Exception('Server is not connected.');
    }

    await apiService.createAccount(
      accountNumber: accountNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      balance: balance,
    );

    await refreshAccounts();
  }

  Future<void> editAccount({
    required int id,
    required String accountNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required double balance,
  }) async {
    final apiService = ref.read(accountApiServiceProvider);

    if (apiService == null) {
      throw Exception('Server is not connected.');
    }

    await apiService.updateAccount(
      id: id,
      accountNumber: accountNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      balance: balance,
    );

    await refreshAccounts();
  }

  Future<void> removeAccount(int id) async {
    final apiService = ref.read(accountApiServiceProvider);

    if (apiService == null) {
      throw Exception('Server is not connected.');
    }

    await apiService.deleteAccount(id);

    await refreshAccounts();
  }

  Future<double> withdrawFromAccount({
    required int id,
    required double amount,
  }) async {
    final apiService = ref.read(accountApiServiceProvider);

    if (apiService == null) {
      throw Exception('Server is not connected.');
    }

    if (amount <= 0) {
      throw Exception(
        'Withdrawal amount must be greater than zero.',
      );
    }

    final newBalance = await apiService.withdraw(
      id: id,
      amount: amount,
    );

    await refreshAccounts();

    return newBalance;
  }

  Future<double> depositToAccount({
    required int id,
    required double amount,
  }) async {
    final apiService = ref.read(accountApiServiceProvider);

    if (apiService == null) {
      throw Exception('Server is not connected.');
    }

    if (amount <= 0) {
      throw Exception(
        'Deposit amount must be greater than zero.',
      );
    }

    final newBalance = await apiService.deposit(
      id: id,
      amount: amount,
    );

    await refreshAccounts();

    return newBalance;
  }
}
//account provider
