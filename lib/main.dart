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
    // Reading exact keys from Google Sheets API
    List<dynamic> itemsList = _allData['ITEM '] ?? _allData['ITEM'] ?? [];
    List<dynamic> billsList = _allData['BILL'] ?? [];
    List<dynamic> cooliList = _allData['COOLI CALCULATOR'] ?? [];

    List<Widget> screens = [
      PriceListTab(items: itemsList),
      BillsTab(bills: billsList),
      CooliTab(cooli: cooliList),
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
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Price List'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Bills'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Cooli'),
        ],
      ),
    );
  }
}

// 1. PRICE LIST TAB (Search & Item Details)
class PriceListTab extends StatefulWidget {
  final List<dynamic> items;
  const PriceListTab({super.key, required this.items});

  @override
  State<PriceListTab> createState() => _PriceListTabState();
}

class _PriceListTabState extends State<PriceListTab> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((rawItem) {
      final item = rawItem as Map<String, dynamic>;
      final name = (item['ITEM NAME'] ?? '').toString().toLowerCase();
      final tally = (item['ITEM NAME ON TALLY'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase();
      return name.contains(q) || tally.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search 500+ items or tally names...',
              prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No items found'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index] as Map<String, dynamic>;
                    final name = item['ITEM NAME'] ?? '-';
                    final rate = item['RATE']?.toString() ?? '-';
                    final rateType = item['RATE PER KG/BAG'] ?? '';
                    final tally = item['ITEM NAME ON TALLY'] ?? '-';
                    final taxable = item['TAXABLE OR NOT'] ?? '';

                    if (name.toString().trim().isEmpty) return const SizedBox.shrink();

                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Tally: $tally', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            if (taxable.toString().isNotEmpty)
                              Text(
                                taxable.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: taxable.toString().contains('NON') ? Colors.greenAccent : Colors.orangeAccent,
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹$rate',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            Text(rateType.toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// 2. BILLS TAB
class BillsTab extends StatelessWidget {
  final List<dynamic> bills;
  const BillsTab({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    final validBills = bills.where((b) => (b['BILL ID'] ?? '').toString().isNotEmpty).toList();

    if (validBills.isEmpty) {
      return const Center(child: Text('No bills available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: validBills.length,
      itemBuilder: (context, index) {
        final bill = validBills[index] as Map<String, dynamic>;
        final billId = bill['BILL ID'] ?? '-';
        final tallyId = bill['TALLY INVOICE ID'] ?? '-';
        final customer = bill['CUSTOMER']?.toString() ?? '-';
        final amount = bill['AMOUNT']?.toString() ?? '0';

        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(billId.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Customer ID: $customer', style: const TextStyle(color: Colors.grey)),
                    Text('Invoice: $tallyId', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Text('₹$amount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 3. COOLI TAB
class CooliTab extends StatelessWidget {
  final List<dynamic> cooli;
  const CooliTab({super.key, required this.cooli});

  @override
  Widget build(BuildContext context) {
    if (cooli.isEmpty) {
      return const Center(child: Text('No calculation records found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cooli.length,
      itemBuilder: (context, index) {
        final c = cooli[index] as Map<String, dynamic>;
        final customer = c['CUSTOMER']?.toString() ?? '-';
        final rice50 = c['RICE 50KG']?.toString() ?? '0';
        final rice26 = c['RICE 26KG']?.toString() ?? '0';
        final cooliCharge = c['COOLI']?.toString() ?? '0';

        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text('Customer: $customer', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Rice 50kg: $rice50 | Rice 26kg: $rice26', style: const TextStyle(color: Colors.grey)),
            trailing: Text('Cooli: ₹$cooliCharge', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
        );
      },
    );
  }
}
