import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:web3_wallet/providers/wallet_provider.dart';
import 'package:web3dart/web3dart.dart';

class HistoryPage extends StatefulWidget {
  final String privateKey;

  HistoryPage({Key? key, required this.privateKey}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  List<dynamic> _transactionsList = [];

  Future<String> getHistory(String privateKey) async {
    final walletProvider = WalletProvider();
    await walletProvider.loadPrivateKey();
    EthereumAddress address = await walletProvider.getPublicKey(privateKey);

    print(address);

    final response = await http.get(
        Uri.parse(
            'https://api-sepolia.etherscan.io/api?module=account&action=txlist&address=${address}&startblock=0&endblock=99999999&page=1&offset=10&sort=asc&apikey=1JwWG7sNarPdotXbJrw8Kzab-a_rd1jf'),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
        _transactionsList = jsonData['result'];
        print(_transactionsList);

        if(_transactionsList.length == 0) {
          _transactionsList = [
            {
              'hash': 'No transactions found',
              'blockNumber': '',
              'gasPrice': '',
              'from': '',
              'to': '',
              'value': 0,
              'timeStamp': ''
            }
          ];
        }
    } else {
      throw Exception('Failed to load NFT list');
    }

    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: FutureBuilder(
        future: getHistory(widget.privateKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Failed to get history'),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var transaction in _transactionsList)
                    Card(
                      margin: EdgeInsets.all(16),
                      color: MaterialColor(0xFF021322, {
                        50: Color(0xFF021322),
                        100: Color(0xFF021322),
                        200: Color(0xFF021322),
                        300: Color(0xFF021322),
                        400: Color(0xFF021322),
                        500: Color(0xFF021322),
                        600: Color(0xFF021322),
                        700: Color(0xFF021322),
                        800: Color(0xFF021322),
                        900: Color(0xFF021322),
                      }),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Hash: ${transaction['hash']}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Block Number: ${transaction['blockNumber']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Gas Price: ${transaction['gasPrice']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'From: ${transaction['from']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'To: ${transaction['to']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Value: ${transaction['value']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Time Stamp: ${transaction['timeStamp']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],

                        ),
                      
                    ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
