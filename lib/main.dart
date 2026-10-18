import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/database.dart';

late final AppDatabase db;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // تُفتح قاعدة البيانات مرة واحدة، ولا يُعاد إنشاؤها عند كل تشغيل.
  db = AppDatabase(driftDatabase(name: 'knowledge'));
  runApp(const KnowledgeApp());
}

class KnowledgeApp extends StatelessWidget {
  const KnowledgeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'معرفتي',
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark),
        home: const Scaffold(body: Center(child: Text('المرحلة 1: قاعدة البيانات جاهزة'))),
      );
}
