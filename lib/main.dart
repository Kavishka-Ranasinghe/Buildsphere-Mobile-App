import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart'; // Added import
import 'splash_screen.dart'; // Your custom splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // CometChat Initialization
  String appID = "272345917d37d43c";
  String region = "in";

  AppSettings appSettings = (AppSettingsBuilder()
    ..subscriptionType = CometChatSubscriptionType.allUsers
    ..region = region)
      .build();

  await CometChat.init(appID, appSettings, onSuccess: (String successMessage) {
    print("CometChat initialized successfully: $successMessage");
  }, onError: (CometChatException e) {
    print("CometChat initialization failed: ${e.message}");
  });

  // CometChat Calls Initialization
  CallAppSettings callAppSettings = (CallAppSettingBuilder()
    ..appId = appID
    ..region = region
  ).build();

  CometChatCalls.init(callAppSettings, onSuccess: (String successMessage) {
    debugPrint("CometChat Calls initialized successfully: $successMessage");
  }, onError: (CometChatCallsException e) {
    debugPrint("CometChat Calls initialization failed: ${e.message}");
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildSphere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}