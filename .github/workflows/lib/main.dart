import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const DAndCoApp());
}

class DAndCoApp extends StatelessWidget {
  const DAndCoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC PRIME',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _allData = {};
  String _errorMessage = '';

  final String apiUrl =
      'https://script.google.com/macros/s/AKfycbz4vjihG3qdOxmhIaCI_Fom2YhNunczRwkc5FqDTcENFoLNPeaLu4J8jCRLnqeQO_-HzQ/exec';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _allData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load data (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error connecting to database: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      VehiclesTab(data: _allData['VEHICLE DETAILS'] ?? _allData['VEHICLES'] ?? []),
      GenericListTab(title: 'Customers', data: _allData['CUSTOMERS'] ?? _allData['CUSTOMERS LIST'] ?? []),
      GenericListTab(title: 'Price List', data: _allData['PRICE LIST'] ?? _allData['ITEMS'] ?? []),
      GenericListTab(title: 'Cooli Calculator', data: _allData['COOLI CALCULATOR'] ?? []),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('DC PRIME', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)))
              : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Vehicles'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Price List'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Cooli'),
        ],
      ),
    );
  }
}

class VehiclesTab extends StatelessWidget {
  final List<dynamic> data;
  const VehiclesTab({super.key, required this.data});

  Color getDueDateColor(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return Colors.white;
    try {
      DateTime dueDate = DateTime.parse(dateStr.toString());
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime cleanDue = DateTime(dueDate.year, dueDate.month, dueDate.day);

      if (cleanDue.isBefore(today)) {
        return Colors.redAccent;
      } else if (cleanDue.difference(today).inDays <= 7) {
        return Colors.amber;
      }
      return Colors.white;
    } catch (_) {
      return Colors.white;
    }
  }

  String formatDisplayDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return '-';
    try {
      DateTime dt = DateTime.parse(dateStr.toString());
      return DateFormat('dd-MMMM-yyyy').format(dt);
    } catch (_) {
      return dateStr.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No vehicle data found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index] as Map<String, dynamic>;
        final vehNo = item['Vehicle Number'] ?? item['VEHICLE NUMBER'] ?? '-';
        final driver = item['Driver Name'] ?? item['DRIVER NAME'] ?? '-';
        final vehType = item['Vehicle Type'] ?? item['VEHICLE TYPE'] ?? '-';

        final insDue = item['Insurance Due'] ?? item['INSURANCE DUE'] ?? '';
        final taxDue = item['Tax Due'] ?? item['TAX DUE'] ?? '';
        final permDue = item['Permit Due'] ?? item['PERMIT DUE'] ?? '';
        final fitDue = item['Fitness Due'] ?? item['FITNESS DUE'] ?? '';

        return Card(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(vehNo.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                Text(vehType.toString(), style: const TextStyle(color: Colors.grey)),
                const Divider(height: 24, color: Colors.white24),
                _dateRow('Insurance Due:', formatDisplayDate(insDue), getDueDateColor(insDue)),
                _dateRow('Tax Due:', formatDisplayDate(taxDue), getDueDateColor(taxDue)),
                _dateRow('Permit Due:', formatDisplayDate(permDue), getDueDateColor(permDue)),
                _dateRow('Fitness Due:', formatDisplayDate(fitDue), getDueDateColor(fitDue)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dateRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Row(
            children: [
              if (color == Colors.redAccent) ...[
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                const SizedBox(width: 4),
              ],
              if (color == Colors.amber) ...[
                const Icon(Icons.hourglass_empty, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
              ],
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}

class GenericListTab extends StatelessWidget {
  final String title;
  final List<dynamic> data;
  const GenericListTab({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return Center(child: Text('No data in $title'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final row = data[index] as Map<String, dynamic>;
        final entries = row.entries.toList();
        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(entries.isNotEmpty ? '${entries[0].value}' : '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entries.length > 1 ? '${entries[1].key}: ${entries[1].value}' : ''),
          ),
        );
      },
    );
  }
}
