import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ necessário
import 'pages/splash_page.dart'; // ⬅️ IMPORTA A SPLASH
import 'pages/tela_inicial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qdsnwcbususawwgobskc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFkc253Y2J1c3VzYXd3Z29ic2tjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwOTQxOTMsImV4cCI6MjA3MzY3MDE5M30.HfQPc1gHtUjDCOIeTGhuivk9taWG4ko8EVs2--SdsoY',
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(), // ⬅️ começa pela splash

      // ✅ Configuração de localização para DatePicker e afins
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // português Brasil
        Locale('en', 'US'), // inglês
      ],
    ),
  );
}

class CaixaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Tec',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0F2C),
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0F2C),
        ),
      ),

      // ✅ também aplica localizações aqui
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],

      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: TabBarView(
            children: [
              TelaInicial(), // inicia com a tela
            ],
          ),
        ),
      ),
    );
  }
}
