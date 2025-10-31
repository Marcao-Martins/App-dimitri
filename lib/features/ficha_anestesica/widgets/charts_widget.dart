import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/parametro_monitorizacao.dart';

class ChartsWidget extends StatelessWidget {
  final List<ParametroMonitorizacao> data;

  const ChartsWidget({super.key, required this.data});

  List<FlSpot> _toSpots(List<int?> values) {
    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v != null) spots.add(FlSpot(i.toDouble(), v.toDouble()));
    }
    return spots;
  }

  List<FlSpot> _toSpotsDouble(List<double?> values) {
    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v != null) spots.add(FlSpot(i.toDouble(), v));
    }
    return spots;
  }

  Widget _buildChart(BuildContext context, String title, List<LineChartBarData> lineBars, {double? minY, double? maxY}) {
    if (lineBars.every((bar) => bar.spots.isEmpty)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 16),
              const Text('Sem dados para exibir', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  lineBarsData: lineBars,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) => Text(
                          'T${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (maxY != null && minY != null) ? (maxY - minY) / 5 : null,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'T${spot.x.toInt()}\n${spot.y.toStringAsFixed(1)}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Gráficos de Tendência', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              const Text(
                'Adicione parâmetros de monitorização para visualizar os gráficos',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final fcList = data.map((e) => e.fc).toList();
    final frList = data.map((e) => e.fr).toList();
    final spo2List = data.map((e) => e.spo2).toList();
    final etco2List = data.map((e) => e.etco2).toList();
    final pasList = data.map((e) => e.pas).toList();
    final padList = data.map((e) => e.pad).toList();
    final pamList = data.map((e) => e.pam).toList();
    final tempList = data.map((e) => e.temp).toList();

    return Column(
      children: [
        Text('Gráficos de Tendência', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        
        // Gráfico de Frequência Cardíaca
        _buildChart(
          context,
          'Frequência Cardíaca (bpm)',
          [
            LineChartBarData(
              spots: _toSpots(fcList),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          minY: 0,
          maxY: 200,
        ),
        const SizedBox(height: 12),

        // Gráfico de Pressão Arterial
        _buildChart(
          context,
          'Pressão Arterial (mmHg)',
          [
            LineChartBarData(
              spots: _toSpots(pasList),
              isCurved: true,
              color: Colors.red.shade700,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: _toSpots(padList),
              isCurved: true,
              color: Colors.blue.shade700,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: _toSpots(pamList),
              isCurved: true,
              color: Colors.green.shade700,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
          ],
          minY: 0,
          maxY: 200,
        ),
        const SizedBox(height: 12),

        // Gráfico de Frequência Respiratória
        _buildChart(
          context,
          'Frequência Respiratória (mpm)',
          [
            LineChartBarData(
              spots: _toSpots(frList),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
          minY: 0,
          maxY: 60,
        ),
        const SizedBox(height: 12),

        // Gráfico de SpO2 e ETCO2
        _buildChart(
          context,
          'SpO2 (%) / ETCO2 (mmHg)',
          [
            LineChartBarData(
              spots: _toSpots(spo2List),
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: _toSpots(etco2List),
              isCurved: true,
              color: Colors.orange,
              barWidth: 2,
              dotData: FlDotData(show: true),
            ),
          ],
          minY: 0,
          maxY: 100,
        ),
        const SizedBox(height: 12),

        // Gráfico de Temperatura
        _buildChart(
          context,
          'Temperatura (°C)',
          [
            LineChartBarData(
              spots: _toSpotsDouble(tempList),
              isCurved: true,
              color: Colors.purple,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
          minY: 35,
          maxY: 40,
        ),
      ],
    );
  }
}
