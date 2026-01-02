import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sabor_de_casa/theme/app_theme.dart';

class FinanceSummaryChart extends StatelessWidget {
  final double ganhos;
  final double gastos;

  const FinanceSummaryChart({
    super.key,
    required this.ganhos,
    required this.gastos,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      ganhos,
      gastos,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min, // 👈 IMPORTANTE
    children: [
      const Text(
        'Resumo financeiro',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),

      SizedBox(
        height: 90,
        child: BarChart(
          BarChartData(
            maxY: maxValue == 0 ? 10 : maxValue * 1.2,
            groupsSpace: 32,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 18,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt() == 0 ? 'Ganhos' : 'Gastos',
                      style: const TextStyle(fontSize: 11),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: ganhos,
                    width: 32,
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primary,
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: gastos,
                    width: 32,
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.danger,
                  ),
                ],
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
