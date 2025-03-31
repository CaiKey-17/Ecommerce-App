import 'package:app/ui/admin/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesData {
  final DateTime date;
  final double revenue;
  final double profit;
  final int orders;
  final String topProduct;

  SalesData(this.date, this.revenue, this.profit, this.orders, this.topProduct);
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedFilter = "Năm";
  DateTime? startDate;
  DateTime? endDate;
  List<SalesData> salesData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await fetchSalesData(selectedFilter, start: startDate, end: endDate);
    setState(() => salesData = data);
  }

  Future<List<SalesData>> fetchSalesData(String filter, {DateTime? start, DateTime? end}) async {
    List<SalesData> allData = [
      SalesData(DateTime(2025, 1, 1), 10000000, 2500000, 50, "SP001"),
      SalesData(DateTime(2025, 2, 1), 15000000, 3750000, 75, "SP002"),
      SalesData(DateTime(2025, 3, 1), 20000000, 5000000, 100, "SP003"),
      SalesData(DateTime(2025, 4, 1), 12000000, 3000000, 60, "SP004"),
      SalesData(DateTime(2025, 5, 1), 18000000, 4500000, 90, "SP005"),
      SalesData(DateTime(2025, 6, 1), 22000000, 5500000, 110, "SP006"),
      SalesData(DateTime(2025, 7, 1), 13000000, 3250000, 65, "SP007"),
      SalesData(DateTime(2025, 8, 1), 17000000, 4250000, 85, "SP008"),
      SalesData(DateTime(2025, 9, 1), 19000000, 4750000, 95, "SP009"),
      SalesData(DateTime(2025, 10, 1), 14000000, 3500000, 70, "SP010"),
      SalesData(DateTime(2025, 11, 1), 16000000, 4000000, 80, "SP011"),
      SalesData(DateTime(2025, 12, 1), 21000000, 5250000, 105, "SP012"),
    ];

    DateTime now = DateTime.now();
    if (start != null && end != null) {
      return allData.where((data) => data.date.isAfter(start.subtract(Duration(days: 1))) && data.date.isBefore(end.add(Duration(days: 1)))).toList();
    }

    switch (filter) {
      case "Tuần":
        DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
        return allData.where((data) => data.date.isAfter(weekStart.subtract(Duration(days: 1)))).toList();
      case "Tháng":
        return allData.where((data) => data.date.month == now.month && data.date.year == now.year).toList();
      case "Quý":
        int quarter = (now.month - 1) ~/ 3 + 1;
        int startMonth = (quarter - 1) * 3 + 1;
        int endMonth = quarter * 3;
        return allData.where((data) => data.date.year == now.year && data.date.month >= startMonth && data.date.month <= endMonth).toList();
      case "Năm":
      default:
        return allData.where((data) => data.date.year == now.year).toList();
    }
  }

  Widget _buildStatCard(String title, String value, String subValue, Color color) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 4),
          Text(subValue, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLegend({bool includeOrders = true}) {
    List<Widget> items = [
      _buildLegendItem(Colors.blue, "Doanh thu (triệu VNĐ)"),
      SizedBox(width: 16),
      _buildLegendItem(Colors.green, "Lợi nhuận (triệu VNĐ)"),
    ];
    if (includeOrders) {
      items.addAll([
        SizedBox(width: 16),
        _buildLegendItem(Colors.orange, "Số đơn hàng"),
      ]);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLineChart(List<SalesData> data) {
  return Container(
    height: 350,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5),
      ],
    ),
    child: Column(
      children: [
        Text(
          "Doanh thu và lợi nhuận theo thời gian",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, horizontalInterval: 5000000),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // Tăng không gian để chứa nhãn nghiêng
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return Transform.rotate(
                          angle: -45 * 3.14159 / 180, // Xoay 45 độ ngược chiều kim đồng hồ
                          child: Padding(
                            padding: EdgeInsets.only(top: 8), // Thêm khoảng cách để tránh chồng lấn
                            child: Text(
                              "${data[index].date.month}/${data[index].date.year}",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      }
                      return Text("");
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.revenue)).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.profit)).toList(),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        _buildLegend(includeOrders: false), // Không cần số đơn hàng ở đây
      ],
    ),
  );
}

  Widget _buildRevenueProfitChart(List<SalesData> data) {
    double totalRevenue = data.fold(0.0, (sum, e) => sum + e.revenue) / 1000000; // Triệu VNĐ
    double totalProfit = data.fold(0.0, (sum, e) => sum + e.profit) / 1000000;   // Triệu VNĐ

    return Container(
      height: 350,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Text("Tổng doanh thu và lợi nhuận", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: totalRevenue, color: Colors.blue, width: 20),
                      BarChartRodData(toY: totalProfit, color: Colors.green, width: 20),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text("Tổng"),
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                ),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
          SizedBox(height: 8),
          _buildLegend(includeOrders: false), // Không cần số đơn hàng ở đây
        ],
      ),
    );
  }

  Widget _buildOrdersChart(List<SalesData> data) {
    int totalOrders = data.fold(0, (sum, e) => sum + e.orders);

    return Container(
      height: 350,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Text("Tổng số đơn hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: totalOrders.toDouble(), color: Colors.orange, width: 20),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text("Tổng"),
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                ),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.orange, "Số đơn hàng"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange: startDate != null && endDate != null
                  ? DateTimeRange(start: startDate!, end: endDate!)
                  : null,
            );
            if (picked != null) {
              setState(() {
                startDate = picked.start;
                endDate = picked.end;
                selectedFilter = "Tùy chỉnh";
                _fetchData();
              });
            }
          },
          child: Text("Chọn khoảng thời gian"),
        ),
        SizedBox(width: 16),
        Text(
          startDate != null && endDate != null
              ? "${startDate!.day}/${startDate!.month} - ${endDate!.day}/${endDate!.month}"
              : "Chưa chọn",
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String title) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: selectedFilter == title ? Colors.white : Colors.black,
        backgroundColor: selectedFilter == title ? Colors.blue : Colors.grey[300],
      ),
      onPressed: () {
        setState(() {
          selectedFilter = title;
          startDate = null;
          endDate = null;
          _fetchData();
        });
      },
      child: Text(title),
    );
  }

  Widget _buildStatisticsTable(List<SalesData> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thống kê chi tiết", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            DataTable(
              columns: [DataColumn(label: Text("Chỉ số")), DataColumn(label: Text("Giá trị"))],
              rows: [
                DataRow(cells: [
                  DataCell(Text("Doanh thu")),
                  DataCell(Text("${data.fold(0.0, (sum, e) => sum + e.revenue)} VNĐ")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Lợi nhuận")),
                  DataCell(Text("${data.fold(0.0, (sum, e) => sum + e.profit)} VNĐ")),
                ]),
                DataRow(cells: [
                  DataCell(Text("Sản phẩm bán chạy")),
                  DataCell(Text(data.isNotEmpty ? data[0].topProduct : "N/A")),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
       drawer: SideBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard("Tổng người dùng", "15,234", "+1,234 mới", Colors.blue),
                _buildStatCard(
                  "Số đơn hàng",
                  "${salesData.fold(0, (sum, e) => sum + e.orders)}",
                  "Tăng 15%",
                  Colors.green,
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["Tuần", "Tháng", "Quý", "Năm"].map((e) => _buildFilterButton(e)).toList(),
            ),
            SizedBox(height: 16),
            _buildDateRangePicker(),
            SizedBox(height: 24),
            _buildLineChart(salesData),
            SizedBox(height: 24),
            _buildRevenueProfitChart(salesData),
            SizedBox(height: 24),
            _buildOrdersChart(salesData), 
            SizedBox(height: 24),
            _buildStatisticsTable(salesData),
          ],
        ),
      ),
    );
  }
}