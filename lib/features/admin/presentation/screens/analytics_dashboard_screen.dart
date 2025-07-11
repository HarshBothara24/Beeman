import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bookings'),
            Tab(text: 'Revenue'),
            Tab(text: 'Bee Box Status'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsChart(),
          _buildRevenueChart(),
          _buildBeeBoxStatusChart(),
        ],
      ),
    );
  }

  Widget _buildBookingsChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('bookings').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No bookings data.'));
        }
        // Group by month
        final Map<String, int> bookingsPerMonth = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final createdAt = data['createdAt'];
          if (createdAt != null) {
            final date = createdAt is Timestamp ? createdAt.toDate() : DateTime.tryParse(createdAt.toString());
            if (date != null) {
              final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
              bookingsPerMonth[key] = (bookingsPerMonth[key] ?? 0) + 1;
            }
          }
        }
        final sortedKeys = bookingsPerMonth.keys.toList()..sort();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: [
                for (int i = 0; i < sortedKeys.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: bookingsPerMonth[sortedKeys[i]]!.toDouble(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= sortedKeys.length) return const SizedBox();
                      return Text(sortedKeys[idx], style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('bookings').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No revenue data.'));
        }
        // Group by month
        final Map<String, double> revenuePerMonth = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final createdAt = data['createdAt'];
          final totalAmount = (data['totalAmount'] is int)
              ? (data['totalAmount'] as int).toDouble()
              : (data['totalAmount'] is double)
                  ? data['totalAmount']
                  : double.tryParse(data['totalAmount']?.toString() ?? '0') ?? 0.0;
          if (createdAt != null) {
            final date = createdAt is Timestamp ? createdAt.toDate() : DateTime.tryParse(createdAt.toString());
            if (date != null) {
              final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
              revenuePerMonth[key] = (revenuePerMonth[key] ?? 0) + totalAmount;
            }
          }
        }
        final sortedKeys = revenuePerMonth.keys.toList()..sort();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: [
                for (int i = 0; i < sortedKeys.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: revenuePerMonth[sortedKeys[i]]!,
                        color: Colors.green,
                      ),
                    ],
                  ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= sortedKeys.length) return const SizedBox();
                      return Text(sortedKeys[idx], style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeeBoxStatusChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('bee_boxes').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No bee box data.'));
        }
        final Map<String, int> statusCounts = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] ?? 'Unknown').toString();
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }
        final sortedKeys = statusCounts.keys.toList();
        final total = statusCounts.values.fold<int>(0, (a, b) => a + b);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: PieChart(
            PieChartData(
              sections: [
                for (int i = 0; i < sortedKeys.length; i++)
                  PieChartSectionData(
                    value: statusCounts[sortedKeys[i]]!.toDouble(),
                    title: '${sortedKeys[i]}\n${((statusCounts[sortedKeys[i]]! / total) * 100).toStringAsFixed(1)}%',
                    color: i == 0
                        ? Colors.green
                        : i == 1
                            ? Colors.orange
                            : i == 2
                                ? Colors.red
                                : Colors.blueGrey,
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 