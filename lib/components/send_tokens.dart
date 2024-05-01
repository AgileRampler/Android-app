import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class SendTokensPage extends StatelessWidget {
  final String privateKey;
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  SendTokensPage({Key? key, required this.privateKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Tokens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: recipientController,
              decoration: const InputDecoration(
                labelText: 'Recipient Address',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount in USD',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String recipient = recipientController.text;
                double amountInDollars = double.parse(amountController.text);
                double amountInEth = amountInDollars * 0.001; // 1$ = 0.001 ETH
                BigInt bigIntValue = BigInt.from(amountInEth * pow(10, 18));
                EtherAmount ethAmount = EtherAmount.fromBigInt(EtherUnit.wei, bigIntValue);
                try {
                  await sendTransaction(recipient, ethAmount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transaction successful!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transaction failed!')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendTransaction(String receiver, EtherAmount txValue) async {
    var apiUrl = "https://eth-sepolia.g.alchemy.com/v2/1JwWG7sNarPdotXbJrw8Kzab-a_rd1jf"; // Replace with your API
    var httpClient = http.Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    EthPrivateKey credentials = EthPrivateKey.fromHex('0x' + privateKey);

    EtherAmount gasPrice = await ethClient.getGasPrice();

    await ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(receiver),
        gasPrice: gasPrice,
        maxGas: 100000,
        value: txValue,
      ),
      chainId: 11155111,
    );
  }
}
