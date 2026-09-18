import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import '../services/transaction_api_service.dart';
import 'server_provider.dart';

final transactionsProvider =
AsyncNotifierProvider<TransactionNotifier, List<Transaction>>(
  TransactionNotifier.new,
);

class TransactionNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final serverState = ref.watch(serverProvider);

    final serverAddress = serverState.ipAddress;

    if (serverAddress.isEmpty) {
      return [];
    }

    final service =
    TransactionApiService(serverAddress);

    return service.getTransactions();
  }

  Future<void> refreshTransactions() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final serverState = ref.read(serverProvider);

      final serverAddress = serverState.ipAddress;

      if (serverAddress.isEmpty) {
        return [];
      }

      final service =
      TransactionApiService(serverAddress);

      return service.getTransactions();
    });
  }

  Future<void> deleteTransaction(int id) async {
    final serverState = ref.read(serverProvider);

    final serverAddress = serverState.ipAddress;

    if (serverAddress.isEmpty) {
      throw Exception('Server address is not available.');
    }

    final service =
    TransactionApiService(serverAddress);

    await service.deleteTransaction(id);

    await refreshTransactions();
  }
}