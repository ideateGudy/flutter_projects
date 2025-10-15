import 'package:flutter/cupertino.dart';

class CurrencyConverterCupertinoPage extends StatefulWidget {
  const CurrencyConverterCupertinoPage({super.key});

  @override
  State<CurrencyConverterCupertinoPage> createState() =>
      _CurrencyConverterCupertinoPageState();
}

class _CurrencyConverterCupertinoPageState
    extends State<CurrencyConverterCupertinoPage> {
  double result = 0;
  final TextEditingController textEditingController = TextEditingController();

  void convert() {
    setState(() {
      result = (double.parse(textEditingController.text) * 1460);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGrey3,
      navigationBar: const CupertinoNavigationBar(
        automaticBackgroundVisibility: false,
        backgroundColor: CupertinoColors.systemIndigo,
        middle: Text('Currency Converter'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                //naira
                result == 0 ? '0.00' : '₦ ${result.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              CupertinoTextField(
                controller: textEditingController,
                style: const TextStyle(color: CupertinoColors.black),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                    width: 2,
                  ),
                ),
                placeholder: 'Please enter amount in USD',
                placeholderStyle: const TextStyle(color: CupertinoColors.black),
                prefix: const Icon(
                  CupertinoIcons.money_dollar,
                  color: CupertinoColors.black,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 10),

              CupertinoButton(
                onPressed: convert,
                color: CupertinoColors.systemIndigo,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                minimumSize: const Size(double.infinity, 50),
                child: const Text(
                  'Convert',
                  style: TextStyle(fontSize: 20, color: CupertinoColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
