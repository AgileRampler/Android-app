import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3_wallet/pages/address_book.dart';
import 'package:web3_wallet/pages/history.dart';
import 'package:web3_wallet/providers/wallet_provider.dart';
import 'package:web3_wallet/pages/create_or_import.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3_wallet/utils/get_balances.dart';
import 'package:web3_wallet/components/nft_balances.dart';
import 'package:web3_wallet/components/send_tokens.dart';
import 'dart:convert';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String walletAddress = '';
  String balance = '';
  String pvKey = '';
 
  double balanceInCash = 1000, totalBalance = 1000;

  @override
  void initState() {
    super.initState();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('privateKey');
    if (privateKey != null) {
      final walletProvider = WalletProvider();
      await walletProvider.loadPrivateKey();
      EthereumAddress address = await walletProvider.getPublicKey(privateKey);
      print(address.hex);
      setState(() {
        walletAddress = address.hex;
        pvKey = privateKey;
      });
      print(pvKey);
      print(address.hex);
      String responseSepolia = await getBalances(address.hex, 'sepolia');
      //String responseGoerli = await getBalances(address.hex, 'goerli');
      dynamic data = json.decode(responseSepolia);
      //dynamic dataGoerli = json.decode(responseGoerli);
      print(data);
     // print(dataGoerli);
      String newBalance = data['balance'] ?? '0';
      //String newBitcoiuBalance = dataGoerli['balance'] ?? '0';

      // Transform balance from wei to ether
      EtherAmount latestBalance =
          EtherAmount.fromBigInt(EtherUnit.wei, BigInt.parse(newBalance));
      String latestBalanceInEther =
          latestBalance.getValueInUnit(EtherUnit.ether).toString();

      balanceInCash = 0.00006874;


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Wallet Address',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Text(
                  walletAddress,
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: walletAddress));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                      ),
                    );
                  },
                  child: const Text('Copy Address'),
                ),
                const SizedBox(height: 32.0),
                const Text(
                  'Total Balance in USD',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Text(
                  '\$${totalBalance.toString()}',
                  style: const TextStyle(
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'sendButton', // Unique tag for send button
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SendTokensPage(privateKey: pvKey)),
                      );
                    },
                    child: const Icon(Icons.send),
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Send'),
                ],
              ),
              Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'transactions', // Unique tag for send button
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HistoryPage(privateKey: pvKey)),
                      );
                    },
                    child: const Icon(Icons.history),
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Transactions'),
                ],
              ),
              Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'refreshButton', // Unique tag for send button
                    onPressed: () {
                      setState(() {
                        // Update any necessary state variables or perform any actions to refresh the widget
                        loadWalletData();
                      });
                    },
                    child: const Icon(Icons.replay_outlined),
                  ),
                  const SizedBox(height: 8.0),
                  const Text('Refresh'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30.0),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(text: 'Assets'),
                      Tab(text: 'NFTs'),
                      Tab(text: 'Options'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Assets Tab
                        Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.all(16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Sepolia ETH',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      '\$${balanceInCash.toStringAsFixed(4)}',
                                      style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                    Text(
                                      balance,
                                      style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    )
                                  ],
                                ),
                              ),
                            ),
                           
                          ],
                        ),
                        // NFTs Tab
                        SingleChildScrollView(
                            child: NFTListPage(
                                address: walletAddress, chain: 'sepolia')),
                        // Activities Tab
                        Center(
                            child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.account_balance_wallet),
                              title: const Text('Address Book', style: TextStyle(color: Colors.blue)),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressBook()));
                              },
                            ),


                            ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text('Logout',
                                  style: TextStyle(color: Colors.red)),
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('privateKey');
                                // ignore: use_build_context_synchronously
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateOrImportPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
