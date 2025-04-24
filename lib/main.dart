import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:cometchat_chat_uikit/cometchat_chat_uikit.dart';
import 'package:cometchat_calls_uikit/cometchat_calls_uikit.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // CometChat Core Initialization
  String appID = "272345917d37d43c";
  String region = "in";
  String authKey = "6d0dad629d71caa8a4f436f2920daa048feaaa8e";

  AppSettings appSettings = (AppSettingsBuilder()
    ..subscriptionType = CometChatSubscriptionType.allUsers
    ..region = region).build();

  await CometChat.init(appID, appSettings,
      onSuccess: (msg) => debugPrint("✅ CometChat initialized"),
      onError: (e) => debugPrint("❌ Initialization failed: ${e.toString()}"));

  // UIKit + Call Extension
  UIKitSettings uiKitSettings = (UIKitSettingsBuilder()
    ..appId = appID
    ..authKey = authKey
    ..region = region
    ..subscriptionType = CometChatSubscriptionType.allUsers
    ..autoEstablishSocketConnection = true
    ..callingExtension = CometChatCallingExtension()
    ..extensions = CometChatUIKitChatExtensions.getDefaultExtensions()).build();

  CometChatUIKit.init(
    uiKitSettings: uiKitSettings,
    onSuccess: (_) => debugPrint("✅ UI Kit Initialized"),
    onError: (e) => debugPrint("❌ UI Kit Init Error: ${e.toString()}"),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

// ✅ CometChat Incoming Call Listener
class _MyAppState extends State<MyApp> with CallListener {
  @override
  void initState() {
    super.initState();
    CometChat.addCallListener("main_listener", this); // Add call listener
  }

  @override
  void dispose() {
    CometChat.removeCallListener("main_listener"); // Remove on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: CallNavigationContext.navigatorKey, // Required for call overlays
      debugShowCheckedModeBanner: false,
      title: 'BuildSphere',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }

  // 🔥 Triggered when an incoming call is received
  @override
  void onIncomingCallReceived(Call call) {
    debugPrint("📞 Incoming call from: ${call.sender?.name}");

    final user = call.sender;
    if (user != null) {
      Navigator.push(
        CallNavigationContext.navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => CometChatIncomingCall(
            user: user,
            call: call,
            onAccept: (ctx, call) {
              debugPrint("✅ Call accepted");
            },
            onDecline: (ctx, call) {
              debugPrint("❌ Call declined");
            },
            onError: (e) {
              debugPrint("⚠️ Error handling call: $e");
            },
          ),
        ),
      );
    } else {
      debugPrint("⚠️ Incoming call sender is null");
    }
  }

  // ✅ Optional call lifecycle hooks
  @override void onIncomingCallCancelled(Call call) {
    debugPrint("❌ Incoming call cancelled");
  }

  @override void onOutgoingCallAccepted(Call call) {
    debugPrint("📞 Outgoing call accepted");
  }

  @override void onOutgoingCallRejected(Call call) {
    debugPrint("❌ Outgoing call rejected");
  }

  @override void onCallEndedMessageReceived(Call call) {
    debugPrint("📴 Call ended");
  }
}
