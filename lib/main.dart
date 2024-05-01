import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallet_provider.dart';
import 'package:web3_wallet/utils/routes.dart';
import 'package:web3_wallet/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the private key
  WalletProvider walletProvider = WalletProvider();
  await walletProvider.loadPrivateKey();

  runApp(
    ChangeNotifierProvider<WalletProvider>.value(
      value: walletProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: MyRoutes.loginRoute,
      debugShowCheckedModeBanner: false,
      routes: {
        MyRoutes.loginRoute: (context) => const LoginPage(),
      },
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF021322, {
          50: Color(0xFF021322),
          100: Color(0xFF021322),
          200: Color(0xFF021322),
          300: Color.fromARGB(255, 55, 130, 196),
          400: Color(0xFF021322),
          500: Color(0xFF021322),
          600: Color(0xFF021322),
          700: Color(0xFF021322),
          800: Color(0xFF021322),
          900: Color(0xFF021322),
        }),
        scaffoldBackgroundColor: Color.fromARGB(255, 1, 5, 110),
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
