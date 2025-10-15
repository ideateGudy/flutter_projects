import 'package:flutter/material.dart';

class CurrencyConverterMaterialPage extends StatefulWidget {
  const CurrencyConverterMaterialPage({super.key});

  @override
  State<CurrencyConverterMaterialPage> createState() =>
      _CurrencyConverterMaterialPageState();
}

class _CurrencyConverterMaterialPageState
    extends State<CurrencyConverterMaterialPage> {
  double result = 0;
  final TextEditingController textEditingController = TextEditingController();

  void convert() {
    setState(() {
      result = (double.parse(textEditingController.text) * 1460);
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(width: 2, style: BorderStyle.solid),
    );
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text('Currency Converter'),
        elevation: 0,
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Center(
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

              TextField(
                controller: textEditingController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Please enter amount in USD',
                  hintStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixIconColor: Colors.black,
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.teal,
                      width: 2,
                      style: BorderStyle.solid,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  enabledBorder: border,
                  contentPadding: const EdgeInsets.all(8),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: convert,
                //Or
                // onPressed: () {
                //   convert();
                // },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                child: const Text('Convert', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
