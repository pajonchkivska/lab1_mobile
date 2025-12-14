import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';

class MqttEventWidget extends StatelessWidget {
  const MqttEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttService>(
      builder: (_, mqtt, __) {
        final ok = mqtt.status.contains('Connected') ||
            mqtt.status.contains('Subscribed') ||
            mqtt.status.contains('Reconnected');

        return Card(
          color: Colors.blue.shade50,
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MQTT Status: ${mqtt.status}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ok ? Colors.green : Colors.red,
                  ),
                ),
                const Divider(),
                const Text('Last ToDo event:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(mqtt.lastEvent, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }
}
