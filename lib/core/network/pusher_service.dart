import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../db/shared_pref_manager.dart';
import '../helper/logger_helper.dart';
import 'pusher_config.dart';

class PusherService extends GetxService {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final isConnected = false.obs;
  final connectionState = 'DISCONNECTED'.obs;

  final Map<String, List<Function(PusherEvent)>> _channelListeners = {};

  Future<PusherService> init() async {
    try {
      printMessage(
        "🔌 Initializing Pusher Service with Key: ${PusherConfig.apiKey}, Cluster: ${PusherConfig.cluster}",
      );
      await _pusher.init(
        apiKey: PusherConfig.apiKey,
        cluster: PusherConfig.cluster,
        onConnectionStateChange: _onConnectionStateChange,
        onError: _onError,
        onSubscriptionSucceeded: _onSubscriptionSucceeded,
        onEvent: _onEvent,
        onSubscriptionError: _onSubscriptionError,
        onDecryptionFailure: _onDecryptionFailure,
        onAuthorizer: _onAuthorizer,
      );
      await _pusher.connect();
    } catch (e) {
      printMessage("⚠️ Failed to initialize Pusher: $e");
    }
    return this;
  }

  dynamic _onAuthorizer(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    try {
      final token = SharedPrefManager().userToken;
      printMessage(
        "🔑 Pusher Authorizer called for $channelName with SocketID: $socketId",
      );

      final response = await dio.Dio().post(
        PusherConfig.authEndpoint,
        data: {'socket_id': socketId, 'channel_name': channelName},
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
      printMessage("⚠️ Pusher Auth Error: $e");
      return null;
    }
  }

  void _onConnectionStateChange(dynamic currentState, dynamic previousState) {
    printMessage("🔄 Pusher Connection State: $previousState ➔ $currentState");
    connectionState.value = currentState.toString();
    isConnected.value = currentState.toString().toUpperCase() == 'CONNECTED';
  }

  void _onError(String message, int? code, dynamic e) {
    printMessage("⚠️ Pusher Error [$code]: $message ($e)");
  }

  void _onSubscriptionSucceeded(String channelName, dynamic data) {
    printMessage("✅ Pusher Subscribed Succeeded: $channelName data: $data");
  }

  void _onSubscriptionError(String message, dynamic e) {
    printMessage("⚠️ Pusher Subscription Error: $message ($e)");
  }

  void _onDecryptionFailure(String event, String reason) {
    printMessage("⚠️ Pusher Decryption Failure: $event -> $reason");
  }

  void _onEvent(PusherEvent event) {
    printMessage(
      "📡 Pusher Event Received [${event.channelName}] -> ${event.eventName}: ${event.data}",
    );
    final listeners = _channelListeners[event.channelName];
    if (listeners != null && listeners.isNotEmpty) {
      for (final callback in List<Function(PusherEvent)>.from(listeners)) {
        try {
          callback(event);
        } catch (e) {
          printMessage("⚠️ Error in Pusher Event Listener: $e");
        }
      }
    }
  }

  Future<void> subscribeToChannel(
    String channelName,
    Function(PusherEvent) onEventCallback,
  ) async {
    if (channelName.isEmpty) return;

    if (!_channelListeners.containsKey(channelName)) {
      _channelListeners[channelName] = [];
      try {
        printMessage("📡 Subscribing to Pusher channel: $channelName");
        await _pusher.subscribe(channelName: channelName);
      } catch (e) {
        printMessage("⚠️ Error subscribing to channel $channelName: $e");
      }
    }

    if (!_channelListeners[channelName]!.contains(onEventCallback)) {
      _channelListeners[channelName]!.add(onEventCallback);
    }
  }

  Future<void> unsubscribeFromChannel(
    String channelName, [
    Function(PusherEvent)? callback,
  ]) async {
    if (channelName.isEmpty || !_channelListeners.containsKey(channelName)) {
      return;
    }

    if (callback != null) {
      _channelListeners[channelName]!.remove(callback);
    }

    if (callback == null || _channelListeners[channelName]!.isEmpty) {
      _channelListeners.remove(channelName);
      try {
        printMessage("🔌 Unsubscribing from Pusher channel: $channelName");
        await _pusher.unsubscribe(channelName: channelName);
      } catch (e) {
        printMessage("⚠️ Error unsubscribing from channel $channelName: $e");
      }
    }
  }

  @override
  void onClose() {
    _pusher.disconnect();
    super.onClose();
  }
}
