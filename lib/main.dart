import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
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
      'https://script.google.com/macros/s/AKfycbz23YaHbMW2qXKCOeOSgwZbJb6O-U4Xcfh7LdHhiSF4BrV6tt9alOPd8Z7bkwn62HJdIg/exec';

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

  Future<bool> sendSheetRequest(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(payload),
      );
      if (response.statusCode == 200) {
        await fetchData();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> itemsList = _allData['ITEMS'] ?? _allData['ITEM '] ?? [];
    List<dynamic> customersList = _allData['CUSTOMERS'] ?? [];
    List<dynamic> estimatesList = _allData['ESTIMATES'] ?? [];

    List<Widget> screens = [
      EstimateScreen(
        items: itemsList,
        customers: customersList,
        onSaveEstimate: (estData) async => await sendSheetRequest({
          'action': 'add',
          'tab': 'ESTIMATES',
          'data': estData,
        }),
        onAddCustomer: (custData) async => await sendSheetRequest({
          'action': 'add',
          'tab': 'CUSTOMERS',
          'data': custData,
        }),
        onAddItem: (itemData) async => await sendSheetRequest({
          'action': 'add',
          'tab': 'ITEMS',
          'data': itemData,
        }),
      ),
      PriceListTab(
        items: itemsList,
        onAddItem: (itemData) async => await sendSheetRequest({
          'action': 'add',
          'tab': 'ITEMS',
          'data': itemData,
        }),
        onEditItem: (itemName, updatedData) async => await sendSheetRequest({
          'action': 'edit',
          'tab': 'ITEMS',
          'keyName': 'ITEM NAME',
          'keyValue': itemName,
          'data': updatedData,
        }),
      ),
      CustomersTab(
        customers: customersList,
        onAddCustomer: (custData) async => await sendSheetRequest({
          'action': 'add',
          'tab': 'CUSTOMERS',
          'data': custData,
        }),
        onEditCustomer: (custName, updatedData) async => await sendSheetRequest({
          'action': 'edit',
          'tab': 'CUSTOMERS',
          'keyName': 'NAME',
          'keyValue': custName,
          'data': updatedData,
        }),
      ),
      const CalculatorTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('DC PRIME', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)),
                  ),
                )
              : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Estimate'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Price List'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 1. ESTIMATE BILLING SCREEN (Multi-Item Invoice)
// -------------------------------------------------------------
class EstimateScreen extends StatefulWidget {
  final List<dynamic> items;
  final List<dynamic> customers;
  final Future<bool> Function(Map<String, dynamic>) onSaveEstimate;
  final Future<bool> Function(Map<String, dynamic>) onAddCustomer;
  final Future<bool> Function(Map<String, dynamic>) onAddItem;

  const EstimateScreen({
    super.key,
    required this.items,
    required this.customers,
    required this.onSaveEstimate,
    required this.onAddCustomer,
    required this.onAddItem,
  });

  @override
  State<EstimateScreen> createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> {
  String selectedCustomer = '';
  List<Map<String, dynamic>> billItems = [];
  bool isSaving = false;

  double get grandTotal {
    double sum = 0;
    for (var b in billItems) {
      sum += (b['total'] as num).toDouble();
    }
    return sum;
  }

  void _openCustomerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredCusts = widget.customers.where((c) {
              final name = (c['NAME'] ?? '').toString().toLowerCase();
              return name.contains(filter.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: const Icon(Icons.person_add, color: Colors.blueAccent),
                        label: const Text('New', style: TextStyle(color: Colors.blueAccent)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddCustomerDialog();
                        },
                      )
                    ],
                  ),
                  TextField(
                    onChanged: (val) => setModalState(() => filter = val),
                    decoration: InputDecoration(
                      hintText: 'Search customer name...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCusts.length,
                      itemBuilder: (context, idx) {
                        final c = filteredCusts[idx];
                        final name = c['NAME'] ?? '';
                        final b2b = c['B2B'] ?? '';
                        return ListTile(
                          title: Text(name.toString()),
                          subtitle: b2b.toString().isNotEmpty ? Text(b2b.toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)) : null,
                          onTap: () {
                            setState(() => selectedCustomer = name.toString());
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openItemPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredItems = widget.items.where((it) {
              final name = (it['ITEM NAME'] ?? '').toString().toLowerCase();
              return name.contains(filter.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Add Item to Bill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: const Icon(Icons.add_box, color: Colors.blueAccent),
                        label: const Text('New Item', style: TextStyle(color: Colors.blueAccent)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddItemDialog();
                        },
                      )
                    ],
                  ),
                  TextField(
                    onChanged: (val) => setModalState(() => filter = val),
                    decoration: InputDecoration(
                      hintText: 'Search 500+ items...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, idx) {
                        final item = filteredItems[idx];
                        final name = item['ITEM NAME'] ?? '';
                        final rate = double.tryParse(item['RATE']?.toString() ?? '0') ?? 0.0;
                        final unit = item['RATE PER KG/BAG'] ?? '';

                        return ListTile(
