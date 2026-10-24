import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  runApp(const DAndCoApp());
}

class DAndCoApp extends StatefulWidget {
  const DAndCoApp({super.key});

  static _DAndCoAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_DAndCoAppState>();

  @override
  State<DAndCoApp> createState() => _DAndCoAppState();
}

class _DAndCoAppState extends State<DAndCoApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DC PRIME',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        primaryColor: Colors.blueAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1E1E),
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

  String companyName = 'DAVIS & COMPANY';
  String companyLocation = 'Aluva, Ernakulam';

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
      await http.post(
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

  Future<void> _checkForUpdates() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking for updates...')),
    );
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(
          'https://api.github.com/repos/sudheeshpunnikrishnan-tech/d-and-co-app/releases/latest'));

      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        String latestTag = releaseData['tag_name'] ?? '';
        String cleanLatest = latestTag.replaceAll(RegExp(r'[^0-9.]'), '');

        if (cleanLatest.isNotEmpty && cleanLatest != currentVersion) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Update Available! 🚀'),
              content: Text(
                  'A newer version ($latestTag) is available.\nInstalled: v$currentVersion'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final htmlUrl = releaseData['html_url'];
                    if (htmlUrl != null) {
                      await launchUrl(Uri.parse(htmlUrl),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text('Download Update'),
                ),
              ],
            ),
          );
          return;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are using the latest version (v$currentVersion)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App is up to date!')),
      );
    }
  }

  void _openSettingsDialog() {
    final compController = TextEditingController(text: companyName);
    final locController = TextEditingController(text: companyLocation);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.settings, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text('Settings & Preferences',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Appearance',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ChoiceChip(
                      label: const Text('Dark'),
                      selected: Theme.of(context).brightness == Brightness.dark,
                      onSelected: (_) {
                        DAndCoApp.of(context)?.changeTheme(ThemeMode.dark);
                        setModalState(() {});
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Light'),
                      selected: Theme.of(context).brightness == Brightness.light,
                      onSelected: (_) {
                        DAndCoApp.of(context)?.changeTheme(ThemeMode.light);
                        setModalState(() {});
                      },
                    ),
                    ChoiceChip(
                      label: const Text('System'),
                      selected: false,
                      onSelected: (_) {
                        DAndCoApp.of(context)?.changeTheme(ThemeMode.system);
                        setModalState(() {});
                      },
                    ),
                  ],
                ),
                const Divider(height: 30),
                const Text('Company Details',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                TextField(
                  controller: compController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
                TextField(
                  controller: locController,
                  decoration: const InputDecoration(labelText: 'Location / City'),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        companyName = compController.text.trim().isEmpty
                            ? 'DAVIS & COMPANY'
                            : compController.text.trim();
                        companyLocation = locController.text.trim().isEmpty
                            ? 'Aluva, Ernakulam'
                            : locController.text.trim();
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Details'),
                  ),
                ),
                const Divider(height: 30),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.system_update, color: Colors.greenAccent),
                  title: const Text('Check for Updates'),
                  subtitle: const Text('Verify new releases on GitHub'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    _checkForUpdates();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline, color: Colors.amberAccent),
                  title: const Text('About DC PRIME'),
                  subtitle: const Text('App version, developer & contact info'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.business, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('DC PRIME v1.0.1'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tailored Wholesale Billing System',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Designed for Davis & Company, Aluva.'),
            Divider(height: 20),
            Text('📞 Contact & Support:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('• Business: Davis & Company'),
            Text('• Location: Aluva, Ernakulam, Kerala'),
            Text('• WhatsApp Billing Integration: Active'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleEditInvoice(Map<String, dynamic> invoice) {
    setState(() {
      invoiceToEdit = invoice;
      _currentIndex = 0;
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
        title: Text(companyName,
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: 18)),
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
          final match = RegExp(r'^(.*?)\s*\((\d+(?:\.\d+)?)\s*x\s*(\d+(?:\.\d+)?)\)$').firstMatch(p.trim());
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

  void _editBillItem(int index) {
    final item = billItems[index];
    final qtyController = TextEditingController(text: item['qty'].toString());
    final rateController = TextEditingController(text: item['rate'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit: ${item['name']}', style: const TextStyle(fontSize: 16, color: Colors.blueAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity / Bags / KG'),
            ),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rate (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newQty = double.tryParse(qtyController.text) ?? item['qty'];
              final newRate = double.tryParse(rateController.text) ?? item['rate'];
              setState(() {
                billItems[index]['qty'] = newQty;
                billItems[index]['rate'] = newRate;
                billItems[index]['total'] = newQty * newRate;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
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
      sb.writeln("   ▫️ ${it['qty']} × ₹${it['rate']} = *₹${it['total']}*");
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
          ),
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
          ),
        ],
      ),
    );
  }

  void _openCustomerPicker() {
    showModalBottomSheet(
      context: context,
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
                      ),
                    ],
                  ),
                  TextField(
                    onChanged: (val) => setModalState(() => filter = val),
                    decoration: InputDecoration(
                      hintText: 'Search customer name...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
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
                      ),
                    ],
                  ),
                  TextField(
                    onChanged: (val) => setModalState(() => filter = val),
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
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
                          title: Text(name.toString()),
                          trailing: Text('₹$rate', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                          subtitle: Text(unit.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          onTap: () {
                            Navigator.pop(ctx);
                            _promptQuantity(item);
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

  void _promptQuantity(Map<String, dynamic> item) {
    final qtyController = TextEditingController(text: '1');
    final rateController = TextEditingController(text: (item['RATE'] ?? '0').toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item['ITEM NAME'] ?? 'Quantity', style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity / Bags / KG'),
            ),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rate (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 1.0;
              final rate = double.tryParse(rateController.text) ?? 0.0;
              setState(() {
                billItems.add({
                  'name': item['ITEM NAME'],
                  'rate': rate,
                  'qty': qty,
                  'unit': item['RATE PER KG/BAG'] ?? 'RATE PER KG',
                  'total': qty * rate,
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveEstimate() async {
    if (selectedCustomer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }
    if (billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    setState(() => isSaving = true);

    String summary = billItems.map((b) => "${b['name']} (${b['qty']} x ${b['rate']})").join(", ");
    final estNo = currentEditingEstNo ?? 'EST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final currentCustomer = selectedCustomer;
    final currentBillItems = List<Map<String, dynamic>>.from(billItems);
    final currentTotal = grandTotal;

    final estData = {
      'ESTIMATE NO': estNo,
      'DATE': date,
      'CUSTOMER NAME': currentCustomer,
      'ITEMS SUMMARY': summary,
      'TOTAL AMOUNT': currentTotal,
    };

    await widget.onSaveEstimate(estData);
    setState(() => isSaving = false);

    _showWhatsAppPrompt(estNo, date, currentCustomer, currentBillItems, currentTotal);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (currentEditingEstNo != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber.shade900.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Editing Invoice: $currentEditingEstNo',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.amberAccent),
                  onPressed: () => setState(() {
                    currentEditingEstNo = null;
                    billItems.clear();
                    selectedCustomer = '';
                  }),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _openCustomerPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCustomer.isEmpty ? 'Select Customer *' : selectedCustomer,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: selectedCustomer.isEmpty ? Colors.grey : Colors.blueAccent,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Item'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: _openItemPicker,
              ),
            ],
          ),
        ),
        Expanded(
          child: billItems.isEmpty
              ? const Center(child: Text('No items in bill yet. Tap + Item to add.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: billItems.length,
                  itemBuilder: (context, idx) {
                    final item = billItems[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item['qty']} x ₹${item['rate']} = ₹${item['total']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                              tooltip: 'Edit Qty / Rate',
                              onPressed: () => _editBillItem(idx),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                              onPressed: () => setState(() => billItems.removeAt(idx)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grand Total', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('₹${grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                ],
              ),
              ElevatedButton.icon(
                icon: isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle),
                label: Text(currentEditingEstNo != null ? 'Update & Save' : 'Save Estimate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: isSaving ? null : _saveEstimate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SavedEstimatesTab extends StatefulWidget {
  final List<dynamic> estimates;
  final String companyName;
  final String companyLocation;
  final Function(Map<String, dynamic>) onEditInvoice;

  const SavedEstimatesTab({
    super.key,
    required this.estimates,
    required this.companyName,
    required this.companyLocation,
    required this.onEditInvoice,
  });

  @override
  State<SavedEstimatesTab> createState() => _SavedEstimatesTabState();
}

class _SavedEstimatesTabState extends State<SavedEstimatesTab> {
  String searchQuery = '';
  String selectedFilter = 'Today';
  DateTime? customDate;

  String _cleanDate(dynamic rawDate) {
    if (rawDate == null) return '-';
    String s = rawDate.toString().trim();
    if (s.contains('T')) {
      s = s.split('T').first;
    }
    try {
      DateTime dt = DateTime.parse(s);
      return "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return s;
    }
  }

  List<Map<String, dynamic>> _parseSummary(String summary) {
    List<Map<String, dynamic>> list = [];
    if (summary.trim().isEmpty) return list;
    final parts = summary.split(', ');
    for (var p in parts) {
      final match = RegExp(r'^(.*?)\s*\((\d+(?:\.\d+)?)\s*x\s*(\d+(?:\.\d+)?)\)$').firstMatch(p.trim());
      if (match != null) {
        final name = match.group(1)?.trim() ?? '';
        final qty = double.tryParse(match.group(2) ?? '1') ?? 1.0;
        final rate = double.tryParse(match.group(3) ?? '0') ?? 0.0;
        list.add({
          'name': name,
          'qty': qty,
          'rate': rate,
          'total': (qty * rate).toStringAsFixed(2),
        });
      } else {
        list.add({
          'name': p,
          'qty': '',
          'rate': '',
          'total': '',
        });
      }
    }
    return list;
  }

  void _shareSavedInvoice(Map<String, dynamic> est) async {
    StringBuffer sb = StringBuffer();
    sb.writeln("🧾 *${widget.companyName.toUpperCase()}*");
    sb.writeln("📍 *${widget.companyLocation}*");
    sb.writeln("──────────────────────");
    sb.writeln("📋 *ESTIMATE INVOICE*");
    sb.writeln("🔢 *Est No:* ${est['ESTIMATE NO'] ?? '-'}");
    sb.writeln("📅 *Date:* ${_cleanDate(est['DATE'])}");
    sb.writeln("👤 *Customer:* ${est['CUSTOMER NAME'] ?? '-'}");
    sb.writeln("──────────────────────");
    sb.writeln("📦 *ITEMS LIST:*");

    final parsed = _parseSummary(est['ITEMS SUMMARY'] ?? '');
    int count = 1;
    for (var it in parsed) {
      if (it['qty'].toString().isNotEmpty) {
        sb.writeln("$count️⃣ *${it['name']}*");
        sb.writeln("   ▫️ ${it['qty']} × ₹${it['rate']} = *₹${it['total']}*");
      } else {
        sb.writeln("$count️⃣ ${it['name']}");
      }
      count++;
    }

    sb.writeln("──────────────────────");
    sb.writeln("💰 *GRAND TOTAL: ₹${est['TOTAL AMOUNT'] ?? '0'}*");
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

  void _viewInvoiceDetails(Map<String, dynamic> est) {
    final parsedItems = _parseSummary(est['ITEMS SUMMARY'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(widget.companyName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    Text(widget.companyLocation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    const Text('ESTIMATE INVOICE',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Invoice: ${est['ESTIMATE NO'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Date: ${_cleanDate(est['DATE'])}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              Text('Customer: ${est['CUSTOMER NAME'] ?? '-'}',
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 15, fontWeight: FontWeight.bold)),
              const Divider(height: 20),
              const Text('Items List:',
                  style: TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: parsedItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, idx) {
                    final item = parsedItems[idx];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${idx + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              if (item['qty'].toString().isNotEmpty)
                                Text('${item['qty']} × ₹${item['rate']}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (item['total'].toString().isNotEmpty)
                          Text('₹${item['total']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 13)),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₹${est['TOTAL AMOUNT'] ?? '0'}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.orangeAccent),
                      label: const Text('Edit Bill', style: TextStyle(color: Colors.orangeAccent)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onEditInvoice(est);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('WhatsApp'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _shareSavedInvoice(est);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _matchesDateFilter(String formattedDate) {
    if (selectedFilter == 'All Invoices') return true;
    final now = DateTime.now();
    final todayStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (selectedFilter == 'Today') {
      return formattedDate == todayStr;
    } else if (selectedFilter == 'Yesterday') {
      final yest = now.subtract(const Duration(days: 1));
      final yestStr =
          "${yest.year.toString().padLeft(4, '0')}-${yest.month.toString().padLeft(2, '0')}-${yest.day.toString().padLeft(2, '0')}";
      return formattedDate == yestStr;
    } else if (selectedFilter == 'This Month') {
      final monthPrefix =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";
      return formattedDate.startsWith(monthPrefix);
    } else if (selectedFilter == 'Custom' && customDate != null) {
      final cStr =
          "${customDate!.year.toString().padLeft(4, '0')}-${customDate!.month.toString().padLeft(2, '0')}-${customDate!.day.toString().padLeft(2, '0')}";
      return formattedDate == cStr;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final reversedList = widget.estimates.reversed.toList();
    final filtered = reversedList.where((raw) {
      final e = raw as Map<String, dynamic>;
      final cust = (e['CUSTOMER NAME'] ?? '').toString().toLowerCase();
      final no = (e['ESTIMATE NO'] ?? '').toString().toLowerCase();
      final dateClean = _cleanDate(e['DATE']);
      final q = searchQuery.toLowerCase();

      final matchesQuery = cust.contains(q) || no.contains(q);
      final matchesDate = _matchesDateFilter(dateClean);

      return matchesQuery && matchesDate;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search customer or invoice no...',
              prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Today'),
                selected: selectedFilter == 'Today',
                onSelected: (val) => setState(() => selectedFilter = 'Today'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Yesterday'),
                selected: selectedFilter == 'Yesterday',
                onSelected: (val) => setState(() => selectedFilter = 'Yesterday'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('This Month'),
                selected: selectedFilter == 'This Month',
                onSelected: (val) => setState(() => selectedFilter = 'This Month'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('All Invoices'),
                selected: selectedFilter == 'All Invoices',
                onSelected: (val) => setState(() => selectedFilter = 'All Invoices'),
              ),
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 14),
                label: Text(customDate != null
                    ? "${customDate!.day}/${customDate!.month}"
                    : 'Pick Date'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      customDate = picked;
                      selectedFilter = 'Custom';
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    selectedFilter == 'Today'
                        ? 'No invoices generated today.\nSelect "All Invoices" to see older records.'
                        : 'No saved estimates found for this filter.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final est = filtered[idx] as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _viewInvoiceDetails(est),
                        title: Text(est['CUSTOMER NAME'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${est['ESTIMATE NO']} • ${_cleanDate(est['DATE'])}\nTap to preview all items",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${est['TOTAL AMOUNT']}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orangeAccent, size: 20),
                              tooltip: 'Edit in Billing',
                              onPressed: () => widget.onEditInvoice(est),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.green, size: 20),
                              onPressed: () => _shareSavedInvoice(est),
                            ),
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

class PriceListTab extends StatefulWidget {
  final List<dynamic> items;
  final Future<bool> Function(Map<String, dynamic>) onAddItem;
  final Future<bool> Function(String, Map<String, dynamic>) onEditItem;

  const PriceListTab({
    super.key,
    required this.items,
    required this.onAddItem,
    required this.onEditItem,
  });

  @override
  State<PriceListTab> createState() => _PriceListTabState();
}

class _PriceListTabState extends State<PriceListTab> {
  String searchQuery = '';

  void _showItemDialog([Map<String, dynamic>? existing]) {
    final nameCtrl = TextEditingController(text: existing?['ITEM NAME'] ?? '');
    final rateCtrl = TextEditingController(text: existing?['RATE']?.toString() ?? '');
    final tallyCtrl = TextEditingController(
        text: existing?['NAME OF ITEM IN TALLY'] ?? existing?['ITEM NAME ON TALLY'] ?? '');
    final rateTypeCtrl =
        TextEditingController(text: existing?['RATE PER KG/BAG'] ?? 'RATE PER KG');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add New Item' : 'Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                enabled: existing == null,
                decoration: const InputDecoration(labelText: 'Item Name *'),
              ),
              TextField(
                controller: rateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rate (₹) *'),
              ),
              TextField(
                controller: tallyCtrl,
                decoration: const InputDecoration(labelText: 'Item Name on Tally'),
              ),
              TextField(
                controller: rateTypeCtrl,
                decoration: const InputDecoration(labelText: 'Rate Per (KG / BAG)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final payload = {
                'ITEM NAME': nameCtrl.text.trim().toUpperCase(),
                'RATE PER KG/BAG': rateTypeCtrl.text.trim(),
                'RATE': double.tryParse(rateCtrl.text) ?? 0,
                'NAME OF ITEM IN TALLY': tallyCtrl.text.trim(),
                'ITEM NAME ON TALLY': tallyCtrl.text.trim(),
              };

              if (existing == null) {
                await widget.onAddItem(payload);
              } else {
                await widget.onEditItem(existing['ITEM NAME'], payload);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((rawItem) {
      final item = rawItem as Map<String, dynamic>;
      final name = (item['ITEM NAME'] ?? '').toString().toLowerCase();
      final tally =
          (item['ITEM NAME ON TALLY'] ?? item['NAME OF ITEM IN TALLY'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase();
      return name.contains(q) || tally.contains(q);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search items or tally names...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index] as Map<String, dynamic>;
                final name = item['ITEM NAME'] ?? '-';
                final rate = item['RATE']?.toString() ?? '-';
                final rateType = item['RATE PER KG/BAG'] ?? '';
                final tally =
                    item['ITEM NAME ON TALLY'] ?? item['NAME OF ITEM IN TALLY'] ?? '-';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Tally: $tally\n$rateType', style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹$rate',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                          onPressed: () => _showItemDialog(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomersTab extends StatefulWidget {
  final List<dynamic> customers;
  final Future<bool> Function(Map<String, dynamic>) onAddCustomer;
  final Future<bool> Function(String, Map<String, dynamic>) onEditCustomer;

  const CustomersTab({
    super.key,
    required this.customers,
    required this.onAddCustomer,
    required this.onEditCustomer,
  });

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  String searchQuery = '';

  void _showCustomerDialog([Map<String, dynamic>? existing]) {
    final nameCtrl = TextEditingController(text: existing?['NAME'] ?? '');
    final b2bCtrl = TextEditingController(text: existing?['B2B'] ?? '');
    final b2cCtrl = TextEditingController(text: existing?['B2C'] ?? '');
    final remarksCtrl = TextEditingController(text: existing?['REMARKS'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add New Customer' : 'Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                enabled: existing == null,
                decoration: const InputDecoration(labelText: 'Customer Name *'),
              ),
              TextField(controller: b2bCtrl, decoration: const InputDecoration(labelText: 'B2B / GST Name')),
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
              final payload = {
                'NAME': nameCtrl.text.trim().toUpperCase(),
                'B2B': b2bCtrl.text.trim(),
                'B2C': b2cCtrl.text.trim(),
                'REMARKS': remarksCtrl.text.trim(),
              };

              if (existing == null) {
                await widget.onAddCustomer(payload);
              } else {
                await widget.onEditCustomer(existing['NAME'], payload);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers.where((rawCust) {
      final c = rawCust as Map<String, dynamic>;
      final name = (c['NAME'] ?? '').toString().toLowerCase();
      final b2b = (c['B2B'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase();
      return name.contains(q) || b2b.contains(q);
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showCustomerDialog(),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index] as Map<String, dynamic>;
                final name = c['NAME'] ?? '-';
                final b2b = c['B2B'] ?? '';
                final remarks = c['REMARKS'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (b2b.toString().isNotEmpty)
                          Text('B2B: $b2b', style: const TextStyle(fontSize: 13)),
                        if (remarks.toString().isNotEmpty)
                          Text('Remarks: $remarks', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                      onPressed: () => _showCustomerDialog(c),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  String display = '0';
  double firstOperand = 0;
  String operator = '';
  bool shouldResetDisplay = false;

  void onBtnClick(String text) {
    setState(() {
      if (text == 'C') {
        display = '0';
        firstOperand = 0;
        operator = '';
      } else if (text == '+' || text == '-' || text == '×' || text == '÷') {
        firstOperand = double.tryParse(display) ?? 0;
        operator = text;
        shouldResetDisplay = true;
      } else if (text == '=') {
        double secondOperand = double.tryParse(display) ?? 0;
        double res = 0;
        if (operator == '+') res = firstOperand + secondOperand;
        if (operator == '-') res = firstOperand - secondOperand;
        if (operator == '×') res = firstOperand * secondOperand;
        if (operator == '÷') res = secondOperand != 0 ? firstOperand / secondOperand : 0;

        display = res.toString().endsWith('.0') ? res.toInt().toString() : res.toString();
        operator = '';
      } else {
        if (display == '0' || shouldResetDisplay) {
          display = text;
          shouldResetDisplay = false;
        } else {
          display += text;
        }
      }
    });
  }

  Widget calcBtn(String text, {Color? bg, Color? fg}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg ?? Colors.white,
            padding: const EdgeInsets.all(22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () => onBtnClick(text),
          child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numBtnColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300;
    final numTextColor = isDark ? Colors.white : Colors.black87;

    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(24),
            child: Text(display,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
        ),
        Column(
          children: [
            Row(children: [
              calcBtn('C', bg: Colors.redAccent),
              calcBtn('÷', bg: Colors.orangeAccent),
              calcBtn('×', bg: Colors.orangeAccent),
              calcBtn('-', bg: Colors.orangeAccent)
            ]),
            Row(children: [
              calcBtn('7', bg: numBtnColor, fg: numTextColor),
              calcBtn('8', bg: numBtnColor, fg: numTextColor),
              calcBtn('9', bg: numBtnColor, fg: numTextColor),
              calcBtn('+', bg: Colors.orangeAccent)
            ]),
            Row(children: [
              calcBtn('4', bg: numBtnColor, fg: numTextColor),
              calcBtn('5', bg: numBtnColor, fg: numTextColor),
              calcBtn('6', bg: numBtnColor, fg: numTextColor),
              calcBtn('0', bg: numBtnColor, fg: numTextColor)
            ]),
            Row(children: [
              calcBtn('1', bg: numBtnColor, fg: numTextColor),
              calcBtn('2', bg: numBtnColor, fg: numTextColor),
              calcBtn('3', bg: numBtnColor, fg: numTextColor),
              calcBtn('=', bg: Colors.green)
            ]),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
