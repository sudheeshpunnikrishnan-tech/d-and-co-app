import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  // App Settings
  String companyName = 'DAVIS & COMPANY';
  String companyLocation = 'Aluva, Ernakulam';
  String companyPhone = '';

  // For Edit Invoice relay
  Map<String, dynamic>? invoiceToEdit;

  final String apiUrl =
      'https://script.google.com/macros/s/AKfycbwRwyjkaaQZ0N4wyfNOfwZqCeJP4idUKJaINn8SQXKwEJp9hyTGv9AyJekyyicpUSWWVA/exec';

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
      fetchData();
      return true;
    } catch (e) {
      fetchData();
      return true;
    }
  }

  void _openSettingsDialog() {
    final compController = TextEditingController(text: companyName);
    final locController = TextEditingController(text: companyLocation);
    final phoneController = TextEditingController(text: companyPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('App Settings'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: compController,
                decoration: const InputDecoration(labelText: 'Company / Business Name'),
              ),
              TextField(
                controller: locController,
                decoration: const InputDecoration(labelText: 'Place / Address'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact Phone Number (Optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                companyName = compController.text.trim().isEmpty ? 'DAVIS & COMPANY' : compController.text.trim();
                companyLocation = locController.text.trim().isEmpty ? 'Aluva, Ernakulam' : locController.text.trim();
                companyPhone = phoneController.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings Saved!')));
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _handleEditInvoice(Map<String, dynamic> invoice) {
    setState(() {
      invoiceToEdit = invoice;
      _currentIndex = 0; // Switch to Estimate billing tab
    });
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
        invoiceToEdit: invoiceToEdit,
        companyName: companyName,
        companyLocation: companyLocation,
        onClearEdit: () => setState(() => invoiceToEdit = null),
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
      SavedEstimatesTab(
        estimates: estimatesList,
        companyName: companyName,
        companyLocation: companyLocation,
        onEditInvoice: _handleEditInvoice,
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
        title: Text(companyName, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _openSettingsDialog),
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
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Invoices'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Price List'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Calculator'),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 1. ESTIMATE BILLING SCREEN
// -------------------------------------------------------------
class EstimateScreen extends StatefulWidget {
  final List<dynamic> items;
  final List<dynamic> customers;
  final Map<String, dynamic>? invoiceToEdit;
  final String companyName;
  final String companyLocation;
  final VoidCallback onClearEdit;
  final Future<bool> Function(Map<String, dynamic>) onSaveEstimate;
  final Future<bool> Function(Map<String, dynamic>) onAddCustomer;
  final Future<bool> Function(Map<String, dynamic>) onAddItem;

  const EstimateScreen({
    super.key,
    required this.items,
    required this.customers,
    required this.invoiceToEdit,
    required this.companyName,
    required this.companyLocation,
    required this.onClearEdit,
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
  String? currentEditingEstNo;

  @override
  void initState() {
    super.initState();
    _checkIncomingEdit();
  }

  @override
  void didUpdateWidget(covariant EstimateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.invoiceToEdit != oldWidget.invoiceToEdit && widget.invoiceToEdit != null) {
      _checkIncomingEdit();
    }
  }

  void _checkIncomingEdit() {
    if (widget.invoiceToEdit != null) {
      final inv = widget.invoiceToEdit!;
      selectedCustomer = inv['CUSTOMER NAME'] ?? '';
      currentEditingEstNo = inv['ESTIMATE NO'] ?? '';
      billItems.clear();

      String rawSummary = inv['ITEMS SUMMARY'] ?? '';
      if (rawSummary.isNotEmpty) {
        final parts = rawSummary.split(', ');
        for (var p in parts) {
          final match = RegExp(r'^(.*?) \((\d+(?:\.\d+)?) x (\d+(?:\.\d+)?)\)$').firstMatch(p);
          if (match != null) {
            final name = match.group(1)?.trim() ?? '';
            final qty = double.tryParse(match.group(2) ?? '1') ?? 1.0;
            final rate = double.tryParse(match.group(3) ?? '0') ?? 0.0;
            billItems.add({
              'name': name,
              'rate': rate,
              'qty': qty,
              'unit': 'RATE PER KG',
              'total': qty * rate,
            });
          } else {
            billItems.add({
              'name': p,
              'rate': 0.0,
              'qty': 1.0,
              'unit': '',
              'total': 0.0,
            });
          }
        }
      }
      widget.onClearEdit();
    }
  }

  double get grandTotal {
    double sum = 0;
    for (var b in billItems) {
      sum += (b['total'] as num).toDouble();
    }
    return sum;
  }

  void _shareViaWhatsApp(String estNo, String date, String cust, List<Map<String, dynamic>> items, double total) async {
    StringBuffer sb = StringBuffer();
    sb.writeln("🧾 *${widget.companyName.toUpperCase()}*");
    sb.writeln("📍 *${widget.companyLocation}*");
    sb.writeln("──────────────────────");
    sb.writeln("📋 *ESTIMATE INVOICE*");
    sb.writeln("🔢 *Est No:* $estNo");
    sb.writeln("📅 *Date:* $date");
    sb.writeln("👤 *Customer:* $cust");
    sb.writeln("──────────────────────");
    sb.writeln("📦 *ITEMS LIST:*");

    int count = 1;
    for (var it in items) {
      sb.writeln("$count️⃣ *${it['name']}*");
      sb.writeln("   ▫️ ${it['qty']}${it['unit'].toString().replaceAll('RATE PER ', '')} × ₹${it['rate']} = *₹${it['total']}*");
      count++;
    }

    sb.writeln("──────────────────────");
    sb.writeln("💰 *GRAND TOTAL: ₹${total.toStringAsFixed(2)}*");
    sb.writeln("──────────────────────");
    sb.writeln("_Thank you for your business!_");

    final encoded = Uri.encodeComponent(sb.toString());
    final url = Uri.parse("whatsapp://send?text=$encoded");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        final webUrl = Uri.parse("https://api.whatsapp.com/send?text=$encoded");
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showWhatsAppPrompt(String estNo, String date, String cust, List<Map<String, dynamic>> items, double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text('Saved Successfully', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Text('Do you want to share this estimate via WhatsApp?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                billItems.clear();
                selectedCustomer = '';
                currentEditingEstNo = null;
              });
            },
            child: const Text('NO', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            icon: const Icon(Icons.share, size: 16),
            label: const Text('YES'),
            onPressed: () {
              Navigator.pop(ctx);
              _shareViaWhatsApp(estNo, date, cust, items, total);
              setState(() {
                billItems.clear();
                selectedCustomer = '';
                currentEditingEstNo = null;
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final b2bCtrl = TextEditingController();
    final b2cCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name *')),
              TextField(controller: b2bCtrl, decoration: const InputDecoration(labelText: 'B2B Name')),
              TextField(controller: b2cCtrl, decoration: const InputDecoration(labelText: 'B2C Name')),
              TextField(controller: remarksCtrl, decoration: const InputDecoration(labelText: 'Remarks')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final ok = await widget.onAddCustomer({
                'SL NO': '',
                'NAME': nameCtrl.text.trim().toUpperCase(),
                'B2C': b2cCtrl.text.trim(),
                'B2B': b2bCtrl.text.trim(),
                'REMARKS': remarksCtrl.text.trim(),
              });
              if (ok) {
                setState(() => selectedCustomer = nameCtrl.text.trim().toUpperCase());
              }
            },
            child: const Text('Save Customer'),
          )
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final tallyCtrl = TextEditingController();
    final rateTypeCtrl = TextEditingController(text: 'RATE PER KG');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Add New Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Item Name *')),
              TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Rate (₹) *')),
              TextField(controller: tallyCtrl, decoration: const InputDecoration(labelText: 'Name on Tally')),
              TextField(controller: rateTypeCtrl, decoration: const InputDecoration(labelText: 'Rate Per (KG / BAG)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await widget.onAddItem({
                'ITEM NAME': nameCtrl.text.trim().toUpperCase(),
                'RATE PER KG/BAG': rateTypeCtrl.text.trim(),
                'RATE': double.tryParse(rateCtrl.text) ?? 0,
                'NAME OF ITEM IN TALLY': tallyCtrl.text.trim(),
                'ITEM NAME ON TALLY': tallyCtrl.text.trim(),
                'BILLED IN': 'KILOGRAM',
                'TAXABLE OR NOT': 'NON TAXABLE',
              });
            },
            child: const Text('Save Item'),
          )
        ],
      ),
    );
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
    