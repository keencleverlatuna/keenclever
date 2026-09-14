import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ServerStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class ServerState {
  final String ipAddress;
  final ServerStatus status;
  final String? errorMessage;

  const ServerState({
    this.ipAddress = '',
    this.status = ServerStatus.disconnected,
    this.errorMessage,
  });

  ServerState copyWith({
    String? ipAddress,
    ServerStatus? status,
    String? errorMessage,
  }) {
    return ServerState(
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class ServerNotifier extends Notifier<ServerState> {
  @override
  ServerState build() {
    return const ServerState();
  }

  void setIpAddress(String ipAddress) {
    state = state.copyWith(
      ipAddress: ipAddress,
      errorMessage: null,
    );
  }

  void setConnecting() {
    state = state.copyWith(
      status: ServerStatus.connecting,
      errorMessage: null,
    );
  }

  void setConnected() {
    state = state.copyWith(
      status: ServerStatus.connected,
      errorMessage: null,
    );
  }

  void setDisconnected() {
    state = state.copyWith(
      status: ServerStatus.disconnected,
      errorMessage: null,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      status: ServerStatus.error,
      errorMessage: message,
    );
  }
}

final serverProvider =
NotifierProvider<ServerNotifier, ServerState>(
  ServerNotifier.new,
);
//latuna
