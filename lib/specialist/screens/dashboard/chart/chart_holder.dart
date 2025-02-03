import 'package:flutter/material.dart';
import 'package:armstrong/specialist/screens/dashboard/chart/graph_chart.dart';

class ChartHolder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth * 0.9,
          height: constraints.maxHeight * 0.4, // Adjusts size dynamically
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          // child: AppointmentsChart(), // Calls the appointment chart
        );
      },
    );
  }
}