import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const DAndCoApp());
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
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
      title: 'DC PRIME BY S TECH',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        primaryColor: const Color(0xFF1E88E5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        primaryColor: const Color(0xFF2979FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF171A21),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: const Color(0xFF1A1E26),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2979FF).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'DC',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'DC PRIME',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'DAVIS & COMPANY',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'DEVELOPED BY S TECH',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.8,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
  String companyLocation = 'ALUVA, ERNAKULAM';
  final String appVersion = '1.0.4';

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

  void _openQuickCompanyEdit() {
    final compController = TextEditingController(text: companyName);
    final locController = TextEditingController(text: companyLocation);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.business, color: Color(0xFF2979FF)),
            SizedBox(width: 8),
            Text('Edit Company Details', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: compController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: const InputDecoration(labelText: 'Company Name *'),
            ),
            TextField(
              controller: locController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: const InputDecoration(labelText: 'Location / City'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                companyName = compController.text.trim().isEmpty
                    ? 'DAVIS & COMPANY'
                    : compController.text.trim().toUpperCase();
                companyLocation = locController.text.trim().isEmpty
                    ? 'ALUVA, ERNAKULAM'
                    : locController.text.trim().toUpperCase();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _openSettingsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    Icon(Icons.tune, color: Color(0xFF2979FF)),
                    SizedBox(width: 8),
                    Text('Settings & Preferences',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Appearance',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
                const SizedBox(height: 10),
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
                const Divider(height: 32),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_pin, color: Colors.amberAccent),
                  title: const Text('Developer & Contact Info'),
                  subtitle: const Text('Sudhi (S Tech) - Contact details'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
            Icon(Icons.terminal, color: Color(0xFF2979FF)),
            SizedBox(width: 8),
            Text('About & Developer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DC PRIME BY S TECH',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Version: v$appVersion',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 20),
            const Text('👨‍💻 Developer Details:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
            const SizedBox(height: 6),
            const Text('• Name: Sudheesh P U (Sudhi)'),
            const Text('• Organization: S Tech Innovations'),
            const SizedBox(height: 12),
            const Text('📞 Contact Number:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
            const SizedBox(height: 4),
            InkWell(
              onTap: () async {
                final url = Uri.parse("tel:+918590656096");
                if (await canLaunchUrl(url)) launchUrl(url);
              },
              child: const Row(
                children: [
                  Icon(Icons.call, size: 16, color: Colors.greenAccent),
                  SizedBox(width: 6),
                  Text('+91 85906 56096',
                      style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
            const Divider(height: 20),
            const Text('🏢 Client Organization:'),
            const Text('Davis & Company, Aluva, Kerala',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
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
        titleSpacing: 12,
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _openQuickCompanyEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('DC',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(companyName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                fontSize: 16)),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit, size: 14, color: Colors.grey),
                      ],
                    ),
                    Text(companyLocation,
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune_outlined), onPressed: _openSettingsDialog),
          IconButton(icon: const Icon(Icons.sync), onPressed: fetchData),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Estimate'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Invoices'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Price List'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Calculator'),
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
        title: Text('Edit: ${item['name']}', style: const TextStyle(fontSize: 16, color: Color(0xFF2979FF))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity / Bags / KG'),
            ),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  Future<void> _generatePdfInvoice(String estNo, String date, String cust,
      List<Map<String, dynamic>> items, double total) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(widget.companyName,
                          style: pw.TextStyle(
                              fontSize: 22, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 3),
                      pw.Text(widget.companyLocation,
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 6),
                      pw.Text('ESTIMATE INVOICE',
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5)),
                    ],
                  ),
                ),
                pw.Divider(thickness: 1.2),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Invoice No: $estNo',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $date'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text('Customer: $cust',
                    style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('#',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Item Description',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Qty',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Rate (INR)',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Total (INR)',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...items.asMap().entries.map((entry) {
                      int idx = entry.key + 1;
                      var it = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('$idx')),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${it['name']}')),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${it['qty']}',
                                  textAlign: pw.TextAlign.right)),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${it['rate']}',
                                  textAlign: pw.TextAlign.right)),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${it['total']}',
                                  textAlign: pw.TextAlign.right)),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Grand Total:  ',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('INR ${total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(thickness: 0.5),
                pw.Center(
                  child: pw.Text(
                      'Generated via DC PRIME by S Tech | Thank you for your business!',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '$estNo.pdf',
    );
  }

  void _shareViaWhatsApp(String estNo, String date, String cust,
      List<Map<String, dynamic>> items, double total) async {
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

  void _showSavedOptions(String estNo, String date, String cust,
      List<Map<String, dynamic>> items, double total) {
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
        content: const Text('Invoice saved! Choose an option below:'),
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
            child: const Text('Done', style: TextStyle(color: Colors.grey)),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 16),
            label: const Text('PDF / Print', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              Navigator.pop(ctx);
              _generatePdfInvoice(estNo, date, cust, items, total);
              setState(() {
                billItems.clear();
                selectedCustomer = '';
                currentEditingEstNo = null;
              });
            },
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white),
            icon: const Icon(Icons.share, size: 16),
            label: const Text('WhatsApp'),
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
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Customer Name *'),
              ),
              TextField(
                controller: b2bCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'B2B Name'),
              ),
              TextField(
                controller: b2cCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'B2C Name'),
              ),
              TextField(
                controller: remarksCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Remarks'),
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
              final ok = await widget.onAddCustomer({
                'SL NO': '',
                'NAME': nameCtrl.text.trim().toUpperCase(),
                'B2C': b2cCtrl.text.trim().toUpperCase(),
                'B2B': b2bCtrl.text.trim().toUpperCase(),
                'REMARKS': remarksCtrl.text.trim().toUpperCase(),
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
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Item Name *'),
              ),
              TextField(
                controller: rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Rate (₹) *'),
              ),
              TextField(
                controller: tallyCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Name on Tally'),
              ),
              TextField(
                controller: rateTypeCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
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
              await widget.onAddItem({
                'ITEM NAME': nameCtrl.text.trim().toUpperCase(),
                'RATE PER KG/BAG': rateTypeCtrl.text.trim().toUpperCase(),
                'RATE': double.tryParse(rateCtrl.text) ?? 0,
                'NAME OF ITEM IN TALLY': tallyCtrl.text.trim().toUpperCase(),
                'ITEM NAME ON TALLY': tallyCtrl.text.trim().toUpperCase(),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                        icon: const Icon(Icons.person_add, color: Color(0xFF2979FF)),
                        label: const Text('New Customer', style: TextStyle(color: Color(0xFF2979FF))),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddCustomerDialog();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    onChanged: (val) => setModalState(() => filter = val),
                    decoration: InputDecoration(
                      hintText: 'Search customer name...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCusts.length,
                      itemBuilder: (context, idx) {
                        final c = filteredCusts[idx];
                        final name = c['NAME'] ?? '';
                        final b2b = c['B2B'] ?? '';
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2979FF)),
                        label: const Text('New Item', style: TextStyle(color: Color(0xFF2979FF))),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddItemDialog();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [UpperCaseTextFormatter()],
                    onChanged: (val) => setModalState(() => filter = val),
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, idx) {
                        final item = filteredItems[idx];
                        final name = item['ITEM NAME'] ?? '';
                        final rate = double.tryParse(item['RATE']?.toString() ?? '0') ?? 0.0;
                        final unit = item['RATE PER KG/BAG'] ?? '';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: Text('₹$rate', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF), fontSize: 15)),
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
        title: Text(item['ITEM NAME'] ?? 'Quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity / Bags / KG'),
            ),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            child: const Text('Add to Bill'),
          ),
        ],
      ),
    );
  }

  void _saveEstimate() async {
    if (selectedCustomer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer first')));
      return;
    }
    if (billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    setState(() => isSaving = true);

    String summary = billItems.map((b) => "${b['name']} (${b['qty']} x ${b['rate']})").join(", ");
    final estNo = currentEditingEstNo ?? 'EST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

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

    _showSavedOptions(estNo, date, currentCustomer, currentBillItems, currentTotal);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (currentEditingEstNo != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.amber.shade900.withOpacity(0.25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note, color: Colors.amberAccent, size: 20),
                    const SizedBox(width: 8),
                    Text('Editing: $currentEditingEstNo',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                  ],
                ),
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
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _openCustomerPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF242A36) : const Color(0xFFEDF2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            selectedCustomer.isEmpty ? 'Select Customer *' : selectedCustomer,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: selectedCustomer.isEmpty ? Colors.grey : const Color(0xFF2979FF),
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2979FF)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2979FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _openItemPicker,
              ),
            ],
          ),
        ),
        Expanded(
          child: billItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_outlined, size: 54, color: Colors.grey.withOpacity(0.4)),
                      const SizedBox(height: 10),
                      const Text('Bill is empty', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                      const SizedBox(height: 4),
                      const Text('Choose customer and tap + Item to begin', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: billItems.length,
                  itemBuilder: (context, idx) {
                    final item = billItems[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        title: Text(item['name'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(
                          '${item['qty']} × ₹${item['rate']}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${item['total']}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.greenAccent),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.orangeAccent, size: 20),
                              tooltip: 'Edit Qty / Rate',
                              onPressed: () => _editBillItem(idx),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grand Total', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(
                    '₹${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.greenAccent),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline),
                label: Text(currentEditingEstNo != null ? 'Update Bill' : 'Save & Options'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      try {
        DateTime dt = DateTime.parse(s).toLocal();
        return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
      } catch (_) {
        s = s.split('T').first;
      }
    }
    return s;
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

  Future<void> _generatePdfInvoice(String estNo, String date, String cust,
      List<Map<String, dynamic>> items, String total) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(widget.companyName,
                          style: pw.TextStyle(
                              fontSize: 22, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 3),
                      pw.Text(widget.companyLocation,
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 6),
                      pw.Text('ESTIMATE INVOICE',
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5)),
                    ],
                  ),
                ),
                pw.Divider(thickness: 1.2),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Invoice No: $estNo',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $date'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text('Customer: $cust',
                    style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('#',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Item Description',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Qty',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Rate (INR)',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Total (INR)',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...items.asMap().entries.map((entry) {
                      int idx = entry.key + 1;
                      var it = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('$idx')),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${it['name']}')),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${it['qty']}',
                                  textAlign: pw.TextAlign.right)),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${it['rate']}',
                                  textAlign: pw.TextAlign.right)),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('${it['total']}',
                                  textAlign: pw.TextAlign.right)),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Grand Total:  ',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('INR $total',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(thickness: 0.5),
                pw.Center(
                  child: pw.Text(
                      'Generated via DC PRIME by S Tech | Thank you for your business!',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '$estNo.pdf',
    );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(widget.companyName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
                    Text(widget.companyLocation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    const Text('ESTIMATE INVOICE',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  ],
                ),
              ),
              const Divider(height: 22),
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
              const Divider(height: 22),
              const Text('Items Breakdown:',
                  style: TextStyle(fontSize: 13, color: Color(0xFF2979FF), fontWeight: FontWeight.bold)),
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
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
              const Divider(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₹${est['TOTAL AMOUNT'] ?? '0'}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16, color: Colors.orangeAccent),
                    label: const Text('Edit Bill', style: TextStyle(color: Colors.orangeAccent)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onEditInvoice(est);
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _generatePdfInvoice(
                        est['ESTIMATE NO'] ?? 'EST',
                        _cleanDate(est['DATE']),
                        est['CUSTOMER NAME'] ?? 'Customer',
                        parsedItems,
                        est['TOTAL AMOUNT']?.toString() ?? '0',
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('WhatsApp'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _shareSavedInvoice(est);
                    },
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
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (selectedFilter == 'Today') {
      return formattedDate == todayStr;
    } else if (selectedFilter == 'Yesterday') {
      final yest = now.subtract(const Duration(days: 1));
      final yestStr =
          "${yest.year}-${yest.month.toString().padLeft(2, '0')}-${yest.day.toString().padLeft(2, '0')}";
      return formattedDate == yestStr;
    } else if (selectedFilter == 'This Month') {
      final monthPrefix =
          "${now.year}-${now.month.toString().padLeft(2, '0')}";
      return formattedDate.startsWith(monthPrefix);
    } else if (selectedFilter == 'Custom' && customDate != null) {
      final cStr =
          "${customDate!.year}-${customDate!.month.toString().padLeft(2, '0')}-${customDate!.day.toString().padLeft(2, '0')}";
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
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [UpperCaseTextFormatter()],
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search customer or invoice no...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2979FF)),
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
                        ? 'No invoices recorded today.\nSelect "All Invoices" to browse history.'
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
                    final parsed = _parseSummary(est['ITEMS SUMMARY'] ?? '');
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _viewInvoiceDetails(est),
                        title: Text(est['CUSTOMER NAME'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${est['ESTIMATE NO']} • ${_cleanDate(est['DATE'])}\nTap to preview items",
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
                              icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                              tooltip: 'Print / Save PDF',
                              onPressed: () {
                                _generatePdfInvoice(
                                  est['ESTIMATE NO'] ?? 'EST',
                                  _cleanDate(est['DATE']),
                                  est['CUSTOMER NAME'] ?? 'Customer',
                                  parsed,
                                  est['TOTAL AMOUNT']?.toString() ?? '0',
                                );
                              },
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
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Item Name *'),
              ),
              TextField(
                controller: rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Rate (₹) *'),
              ),
              TextField(
                controller: tallyCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Name on Tally'),
              ),
              TextField(
                controller: rateTypeCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
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
                'RATE PER KG/BAG': rateTypeCtrl.text.trim().toUpperCase(),
                'RATE': double.tryParse(rateCtrl.text) ?? 0,
                'NAME OF ITEM IN TALLY': tallyCtrl.text.trim().toUpperCase(),
                'ITEM NAME ON TALLY': tallyCtrl.text.trim().toUpperCase(),
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
        backgroundColor: const Color(0xFF2979FF),
        onPressed: () => _showItemDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search items or tally names...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2979FF)),
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
                      mainAxisSize: growthAxisSize.min,
                      children: [
                        Text('₹$rate',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
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
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Customer Name *'),
              ),
              TextField(
                controller: b2bCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'B2B / GST Name'),
              ),
              TextField(
                controller: b2cCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'B2C Name'),
              ),
              TextField(
                controller: remarksCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Remarks'),
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
                'NAME': nameCtrl.text.trim().toUpperCase(),
                'B2B': b2bCtrl.text.trim().toUpperCase(),
                'B2C': b2cCtrl.text.trim().toUpperCase(),
                'REMARKS': remarksCtrl.text.trim().toUpperCase(),
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
        backgroundColor: const Color(0xFF2979FF),
        onPressed: () => _showCustomerDialog(),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2979FF)),
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
  String expression = '';
  String display = '0';
  double? firstOperand;
  String? operator;
  bool shouldResetDisplay = false;

  void onBtnClick(String text) {
    setState(() {
      if (text == 'C') {
        expression = '';
        display = '0';
        firstOperand = null;
        operator = null;
        shouldResetDisplay = false;
      } else if (text == '⌫') {
        if (display.length > 1) {
          display = display.substring(0, display.length - 1);
        } else {
          display = '0';
        }
      } else if (text == '+' || text == '-' || text == '×' || text == '÷') {
        firstOperand = double.tryParse(display) ?? 0;
        operator = text;
        expression = '$display $operator';
        shouldResetDisplay = true;
      } else if (text == '=') {
        if (firstOperand != null && operator != null) {
          double secondOperand = double.tryParse(display) ?? 0;
          double res = 0;
          if (operator == '+') res = firstOperand! + secondOperand;
          if (operator == '-') res = firstOperand! - secondOperand;
          if (operator == '×') res = firstOperand! * secondOperand;
          if (operator == '÷') res = secondOperand != 0 ? firstOperand! / secondOperand : 0;

          expression = '$firstOperand $operator $secondOperand =';
          display = res.toString().endsWith('.0') ? res.toInt().toString() : res.toString();
          firstOperand = null;
          operator = null;
          shouldResetDisplay = true;
        }
      } else if (text == '.') {
        if (shouldResetDisplay) {
          display = '0.';
          shouldResetDisplay = false;
        } else if (!display.contains('.')) {
          display += '.';
        }
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
        padding: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg ?? Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
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
    final numBtnColor = isDark ? const Color(0xFF1E232D) : const Color(0xFFE2E8F0);
    final numTextColor = isDark ? Colors.white : Colors.black87;

    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  expression,
                  style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    display,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF2979FF)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Row(children: [
                calcBtn('C', bg: Colors.redAccent.withOpacity(0.85)),
                calcBtn('⌫', bg: Colors.blueGrey.withOpacity(0.5)),
                calcBtn('÷', bg: Colors.orangeAccent),
                calcBtn('×', bg: Colors.orangeAccent),
              ]),
              Row(children: [
                calcBtn('7', bg: numBtnColor, fg: numTextColor),
                calcBtn('8', bg: numBtnColor, fg: numTextColor),
                calcBtn('9', bg: numBtnColor, fg: numTextColor),
                calcBtn('-', bg: Colors.orangeAccent),
              ]),
              Row(children: [
                calcBtn('4', bg: numBtnColor, fg: numTextColor),
                calcBtn('5', bg: numBtnColor, fg: numTextColor),
                calcBtn('6', bg: numBtnColor, fg: numTextColor),
                calcBtn('+', bg: Colors.orangeAccent),
              ]),
              Row(children: [
                calcBtn('1', bg: numBtnColor, fg: numTextColor),
                calcBtn('2', bg: numBtnColor, fg: numTextColor),
                calcBtn('3', bg: numBtnColor, fg: numTextColor),
                calcBtn('=', bg: const Color(0xFF2E7D32)),
              ]),
              Row(children: [
                calcBtn('0', bg: numBtnColor, fg: numTextColor),
                calcBtn('.', bg: numBtnColor, fg: numTextColor),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
