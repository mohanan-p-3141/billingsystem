import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/billing_provider.dart';
import 'screens/billing_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BillingProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supermarket Billing',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BillingScreen(),
    );
  }
}
