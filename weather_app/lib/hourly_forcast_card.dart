import 'package:flutter/material.dart';

class HourlyFocastCard extends StatelessWidget {
  final String label;
  final String iconUrl;
  final String time;
  final String temperature;
  const HourlyFocastCard({
    super.key,
    required this.label,
    required this.iconUrl,
    required this.time,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16.0,
        ), // Added rounded corners for better Card style
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 120,
        height: 180,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(90.0),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.network(
              iconUrl,
              height: 64,
              width: 64,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, size: 64, color: Colors.red),
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$temperature°C',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

