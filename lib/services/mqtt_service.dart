import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService with ChangeNotifier {
  MqttClient? client;

  String status = 'Disconnected';
  String lastEvent = 'No events yet';

  static const String topic = 'flutter/todo/events';
  static final String clientId =
      'flutter_${DateTime.now().millisecondsSinceEpoch}';

  Future<void> connect() async {
    status = 'Connecting...';
    notifyListeners();

    // 🔹 1. ВИБІР КЛІЄНТА ТА АДРЕСИ
    if (kIsWeb) {
      // 👉 БРАУЗЕР (Chrome)
      client = MqttBrowserClient(
        'wss://broker.hivemq.com:8884/mqtt',
        clientId,
      );
    } else {
      // 👉 МОБІЛЬНИЙ / ЕМУЛЯТОР
      client = MqttServerClient(
        'broker.hivemq.com',
        clientId,
      );
      client!.port = 1883;
    }

    // 🔹 2. НАЛАШТУВАННЯ
    client!.keepAlivePeriod = 20;
    client!.autoReconnect = true;
    client!.logging(on: true);

    client!.onConnected = () {
      status = 'Connected';
      notifyListeners();

      client!.subscribe(topic, MqttQos.atLeastOnce);
      status = 'Subscribed: $topic';
      notifyListeners();
    };

    client!.onDisconnected = () {
      status = 'Disconnected';
      notifyListeners();
    };

    client!.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();

    // 🔹 3. ПІДКЛЮЧЕННЯ
    try {
      await client!.connect();

      client!.updates?.listen((events) {
        final rec = events.first.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(
                rec.payload.message);

        lastEvent = payload;
        notifyListeners();
      });
    } catch (e) {
      status = 'ERROR: $e';
      notifyListeners();
      client!.disconnect();
    }
  }

  void disconnect() {
    client?.disconnect();
    status = 'Disconnected';
    notifyListeners();
  }
}
