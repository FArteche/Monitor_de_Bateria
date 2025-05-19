import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MonitorBateriaApp());
}

class MonitorBateriaApp extends StatelessWidget {
  const MonitorBateriaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor de Bateria',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Battery _battery = Battery();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late Timer _timer;
  int _batteryLevel = 100;

  @override
  void initState() {
    super.initState();
    _inicializarNotificacoes();
    _iniciarMonitoramentoBateria();
  }

  @override
  void dispose() {
    _timer.cancel;
    super.dispose();
  }

  void _inicializarNotificacoes() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _iniciarMonitoramentoBateria() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final level = await _battery.batteryLevel;
      setState(() {
        _batteryLevel = level;
      });

      if (_batteryLevel < 20) {
        _showLowBatteryNotification();
      }
    });
  }

  Future<void> _showLowBatteryNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'low_battery_channel',
          'Altera de Bateria Baixa',
          channelDescription: 'Notificações para nível de bateria baixo',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Bateria Baixa',
      'O nível de bateria está abaixo de 20%.',
      platformChannelSpecifics,
      payload: 'low_battery',
    );
  }

  Future<void> _openGitHubProfile() async {
    const url = 'https://github.com/FArteche';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir o link.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Nível atual de bateria: $_batteryLevel%',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openGitHubProfile,
              child: const Text('Acessar meu GitHub c:'),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
