import 'dart:convert';
import 'dart:typed_data';
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
        scaffoldBackgroundColor: const Color(0xFFF3F5F9),
        primaryColor: const Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C0E12),
        primaryColor: const Color(0xFF2979FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2979FF),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF14171F),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFF171B24),
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
      duration: const Duration(milliseconds: 1300),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
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
      backgroundColor: const Color(0xFF0C0E12),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF00E5FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2979FF).withOpacity(0.45),
                        blurRadius: 26,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'DC',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'DC PRIME',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'DAVIS & COMPANY',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2.2,
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DEVELOPED BY S TECH',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
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
  final String appVersion = '1.1.1';

  bool askSaveConfirmation = true;
  bool enableLabourCharge = true;
  double defaultLabourPerBag = 3.0;
  bool showUpiQr = true;
  String upiId = 'davisandco@upi';

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
      await http.post(Uri.parse(apiUrl), body: json.encode(payload));
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
    final upiCtrl = TextEditingController(text: upiId);
    final labourCtrl = TextEditingController(text: defaultLabourPerBag.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                    Text('Settings & Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
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
                const Divider(height: 28),
                const Text('Billing Controls', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Confirm Before Save'),
                  subtitle: const Text('Prompt alert before recording bill'),
                  value: askSaveConfirmation,
                  activeColor: const Color(0xFF2979FF),
                  onChanged: (val) {
                    setState(() => askSaveConfirmation = val);
                    setModalState(() {});
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Labour / Coolie Charge'),
                  subtitle: const Text('Add bag-based loading charge'),
                  value: enableLabourCharge,
                  activeColor: const Color(0xFF2979FF),
                  onChanged: (val) {
                    setState(() => enableLabourCharge = val);
                    setModalState(() {});
                  },
                ),
                if (enableLabourCharge)
                  TextField(
                    controller: labourCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Default Labour Rate per Bag (₹)', isDense: true),
                    onChanged: (val) => defaultLabourPerBag = double.tryParse(val) ?? 3.0,
                  ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('UPI Payment QR Code'),
                  subtitle: const Text('Display scanner on bill and PDF'),
                  value: showUpiQr,
                  activeColor: const Color(0xFF2979FF),
                  onChanged: (val) {
                    setState(() => showUpiQr = val);
                    setModalState(() {});
                  },
                ),
                if (showUpiQr)
                  TextField(
                    controller: upiCtrl,
                    decoration: const InputDecoration(labelText: 'Business UPI ID (e.g. name@okhdfcbank)', isDense: true),
                    onChanged: (val) => upiId = val.trim(),
                  ),
                const Divider(height: 28),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_pin, color: Colors.amberAccent),
                  title: const Text('Developer Details'),
                  subtitle: const Text('Sudhi (S Tech) • +91 85906 56096'),
                  onTap: () async {
                    final url = Uri.parse("tel:+918590656096");
                    if (await canLaunchUrl(url)) launchUrl(url);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleEditInvoice(Map<String, dynamic> invoice) {
    setState(() {
      invoiceToEdit = invoice;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> itemsList = _allData['ITEMS'] ?? _allData['ITEM '] ?? [];
    List<dynamic> customersList = _allData['CUSTOMERS'] ?? [];
    List<dynamic> estimatesList = _allData['ESTIMATES'] ?? [];

    List<Widget> screens = [
      DashboardHomeScreen(
        companyName: companyName,
        companyLocation: companyLocation,
        estimates: estimatesList,
        items: itemsList,
        customers: customersList,
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
      EstimateScreen(
        items: itemsList,
        customers: customersList,
        estimates: estimatesList,
        invoiceToEdit: invoiceToEdit,
        companyName: companyName,
        companyLocation: companyLocation,
        askSaveConfirmation: askSaveConfirmation,
        enableLabourCharge: enableLabourCharge,
        defaultLabourPerBag: defaultLabourPerBag,
        showUpiQr: showUpiQr,
        upiId: upiId,
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
        customers: customersList,
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
          onTap: _openQuickCompanyEdit,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2979FF), Color(0xFF00E5FF)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('DC', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(companyName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(companyLocation, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
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
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.redAccent)))
              : screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Billing'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Invoices'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Price List'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Calculator'),
        ],
      ),
    );
  }
}

class DashboardHomeScreen extends StatelessWidget {
  final String companyName;
  final String companyLocation;
  final List<dynamic> estimates;
  final List<dynamic> items;
  final List<dynamic> customers;
  final Function(int) onNavigateTab;

  const DashboardHomeScreen({
    super.key,
    required this.companyName,
    required this.companyLocation,
    required this.estimates,
    required this.items,
    required this.customers,
    required this.onNavigateTab,
  });

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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    double todaySales = 0.0;
    int todayBills = 0;
    double todayCredit = 0.0;

    for (var est in estimates) {
      if (est is Map<String, dynamic>) {
        final d = _cleanDate(est['DATE']);
        if (d == todayStr) {
          final amt = double.tryParse(est['TOTAL AMOUNT']?.toString() ?? '0') ?? 0.0;
          todaySales += amt;
          todayBills++;
          final pMode = (est['PAYMENT MODE'] ?? est['PAYMENT_MODE'] ?? est['PAYMENT'] ?? 'CASH').toString().toUpperCase();
          if (pMode == 'CREDIT') {
            todayCredit += amt;
          }
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3C72).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(companyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Text('TODAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Today Sales Collection', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('₹${todaySales.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCardMini('Bills', '$todayBills', Icons.receipt),
                    const SizedBox(width: 12),
                    _buildStatCardMini('Credit Out', '₹${todayCredit.toStringAsFixed(0)}', Icons.schedule),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  context,
                  title: 'New Bill',
                  subtitle: 'Create invoice',
                  icon: Icons.add_shopping_cart,
                  color: const Color(0xFF2979FF),
                  onTap: () => onNavigateTab(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionBtn(
                  context,
                  title: 'Invoices',
                  subtitle: 'View history',
                  icon: Icons.history,
                  color: const Color(0xFF00B0FF),
                  onTap: () => onNavigateTab(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  context,
                  title: 'Price List',
                  subtitle: '${items.length} items',
                  icon: Icons.inventory_2,
                  color: const Color(0xFFFF9100),
                  onTap: () => onNavigateTab(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionBtn(
                  context,
                  title: 'Customers',
                  subtitle: '${customers.length} clients',
                  icon: Icons.people,
                  color: const Color(0xFF00E676),
                  onTap: () => onNavigateTab(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Invoices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => onNavigateTab(2), child: const Text('View All')),
            ],
          ),
          ...estimates.reversed.take(4).map((est) {
            final e = est as Map<String, dynamic>;
            final pMode = (e['PAYMENT MODE'] ?? e['PAYMENT_MODE'] ?? e['PAYMENT'] ?? 'CASH').toString().toUpperCase();
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2979FF).withOpacity(0.15),
                  child: Text(
                    (e['CUSTOMER NAME'] ?? 'C').toString().substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF)),
                  ),
                ),
                title: Text(e['CUSTOMER NAME'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text("${e['ESTIMATE NO']} • ${_cleanDate(e['DATE'])} • $pMode", style: const TextStyle(fontSize: 12)),
                trailing: Text(
                  '₹${e['TOTAL AMOUNT']}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCardMini(String title, String val, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: Colors.white60)),
                Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context,
      {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 18, backgroundColor: color.withOpacity(0.15), child: Icon(icon, size: 20, color: color)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class EstimateScreen extends StatefulWidget {
  final List<dynamic> items;
  final List<dynamic> customers;
  final List<dynamic> estimates;
  final Map<String, dynamic>? invoiceToEdit;
  final String companyName;
  final String companyLocation;
  final bool askSaveConfirmation;
  final bool enableLabourCharge;
  final double defaultLabourPerBag;
  final bool showUpiQr;
  final String upiId;
  final VoidCallback onClearEdit;
  final Future<bool> Function(Map<String, dynamic>) onSaveEstimate;
  final Future<bool> Function(Map<String, dynamic>) onAddCustomer;
  final Future<bool> Function(Map<String, dynamic>) onAddItem;

  const EstimateScreen({
    super.key,
    required this.items,
    required this.customers,
    required this.estimates,
    required this.invoiceToEdit,
    required this.companyName,
    required this.companyLocation,
    required this.askSaveConfirmation,
    required this.enableLabourCharge,
    required this.defaultLabourPerBag,
    required this.showUpiQr,
    required this.upiId,
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
  String paymentMode = 'CASH';
  final TextEditingController labourController = TextEditingController(text: '0');

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
      paymentMode = (inv['PAYMENT MODE'] ?? inv['PAYMENT_MODE'] ?? inv['PAYMENT'] ?? 'CASH').toString().toUpperCase();
      billItems.clear();

      String rawSummary = inv['ITEMS SUMMARY'] ?? '';
      if (rawSummary.isNotEmpty) {
        final parts = rawSummary.split(', ');
        for (var p in parts) {
          final match = RegExp(r'^(.*?)\s*\((\d+(?:\.\d+)?)\s*(KG|BAG)?\s*x\s*(\d+(?:\.\d+)?)\)$', caseSensitive: false).firstMatch(p.trim());
          if (match != null) {
            final name = match.group(1)?.trim() ?? '';
            final qty = double.tryParse(match.group(2) ?? '1') ?? 1.0;
            final unit = match.group(3)?.toUpperCase() ?? 'KG';
            final rate = double.tryParse(match.group(4) ?? '0') ?? 0.0;
            billItems.add({
              'name': name,
              'rate': rate,
              'qty': qty,
              'unit': unit,
              'bag': unit == 'BAG' ? qty : 1.0,
              'total': qty * rate,
            });
          }
        }
      }
      widget.onClearEdit();
      _recalcLabour();
    }
  }

  void _recalcLabour() {
    if (!widget.enableLabourCharge) return;
    double totalBags = 0.0;
    for (var it in billItems) {
      totalBags += (it['bag'] as num).toDouble();
    }
    labourController.text = (totalBags * widget.defaultLabourPerBag).toStringAsFixed(1);
  }

  double get itemsSubTotal {
    double sum = 0;
    for (var b in billItems) {
      sum += (b['total'] as num).toDouble();
    }
    return sum;
  }

  double get grandTotal {
    double labour = double.tryParse(labourController.text) ?? 0.0;
    return itemsSubTotal + labour;
  }

  String get upiQrUrl {
    final amt = grandTotal.toStringAsFixed(2);
    final upiPayload = "upi://pay?pa=${widget.upiId}&pn=${Uri.encodeComponent(widget.companyName)}&am=$amt&cu=INR";
    final encoded = Uri.encodeComponent(upiPayload);
    return "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$encoded";
  }

  void _promptItemEntry(Map<String, dynamic> item, [int? editIndex]) {
    final isEdit = editIndex != null;
    final existing = isEdit ? billItems[editIndex] : null;

    final qtyController = TextEditingController(text: existing != null ? existing['qty'].toString() : '1');
    final rateController = TextEditingController(text: existing != null ? existing['rate'].toString() : (item['RATE'] ?? '0').toString());
    final bagController = TextEditingController(text: existing != null ? existing['bag'].toString() : '1');

    String selectedUnit = existing != null
        ? existing['unit']
        : (item['RATE PER KG/BAG']?.toString().toUpperCase().contains('KG') == true ? 'KG' : 'BAG');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(item['ITEM NAME'] ?? 'Item Entry', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('KG (കിലോ)'),
                      selected: selectedUnit == 'KG',
                      selectedColor: const Color(0xFF2979FF),
                      onSelected: (val) {
                        if (val) setDlgState(() => selectedUnit = 'KG');
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('BAG (ചാക്ക്)'),
                      selected: selectedUnit == 'BAG',
                      selectedColor: const Color(0xFF2979FF),
                      onSelected: (val) {
                        if (val) setDlgState(() => selectedUnit = 'BAG');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: selectedUnit == 'KG' ? 'Weight in KG' : 'Quantity / Bags',
                    isDense: true,
                  ),
                  onChanged: (val) {
                    if (selectedUnit == 'BAG') {
                      bagController.text = val;
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Rate (₹)', isDense: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: bagController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Total Bags (Coolie Calculation)', isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final qty = double.tryParse(qtyController.text) ?? 1.0;
                final rate = double.tryParse(rateController.text) ?? 0.0;
                final bag = double.tryParse(bagController.text) ?? (selectedUnit == 'BAG' ? qty : 1.0);

                setState(() {
                  final entry = {
                    'name': item['ITEM NAME'],
                    'rate': rate,
                    'qty': qty,
                    'unit': selectedUnit,
                    'bag': bag,
                    'total': qty * rate,
                  };
                  if (isEdit) {
                    billItems[editIndex] = entry;
                  } else {
                    billItems.add(entry);
                  }
                  _recalcLabour();
                });
                Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'Update' : 'Add to Bill'),
            ),
          ],
        ),
      ),
    );
  }

  void _previewPdfDocument(String estNo, String date, String cust,
      List<Map<String, dynamic>> items, double total, String pMode, double coolie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewScreen(
          title: 'Invoice $estNo',
          buildPdf: (format) => _buildPdfData(format, estNo, date, cust, items, total, pMode, coolie),
        ),
      ),
    );
  }

  Future<Uint8List> _buildPdfData(PdfPageFormat format, String estNo, String date, String cust,
      List<Map<String, dynamic>> items, double total, String pMode, double coolie) async {
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
                      pw.Text(widget.companyName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.companyLocation, style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 6),
                      pw.Text('ESTIMATE INVOICE', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Invoice No: $estNo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $date'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer: $cust', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Payment: $pMode', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('#')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item Description')),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qty / Unit', textAlign: pw.TextAlign.right)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Rate', textAlign: pw.TextAlign.right)),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total', textAlign: pw.TextAlign.right)),
                      ],
                    ),
                    ...items.asMap().entries.map((entry) {
                      var it = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${entry.key + 1}')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['name']}')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['qty']} ${it['unit']}', textAlign: pw.TextAlign.right)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['rate']}', textAlign: pw.TextAlign.right)),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['total']}', textAlign: pw.TextAlign.right)),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 12),
                if (coolie > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text('Coolie / Labour:  '),
                      pw.Text('INR ${coolie.toStringAsFixed(2)}'),
                    ],
                  ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Grand Total:  ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('INR ${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                if (widget.showUpiQr && widget.upiId.isNotEmpty) ...[
                  pw.SizedBox(height: 16),
                  pw.Divider(thickness: 0.5),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: "upi://pay?pa=${widget.upiId}&pn=${Uri.encodeComponent(widget.companyName)}&am=${total.toStringAsFixed(2)}&cu=INR",
                        width: 70,
                        height: 70,
                      ),
                      pw.SizedBox(width: 14),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Scan to Pay via UPI / GPay / PhonePe', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          pw.Text('UPI ID: ${widget.upiId}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Amount: INR ${total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
    return doc.save();
  }

  void _saveEstimate() async {
    if (selectedCustomer.isEmpty || billItems.isEmpty) return;

    setState(() => isSaving = true);
    final estNo = currentEditingEstNo ?? "EST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String summary = billItems.map((b) => "${b['name']} (${b['qty']} ${b['unit']} x ${b['rate']})").join(", ");
    final coolie = double.tryParse(labourController.text) ?? 0.0;
    final total = grandTotal;
    final pMode = paymentMode;

    await widget.onSaveEstimate({
      'ESTIMATE NO': estNo,
      'DATE': date,
      'CUSTOMER NAME': selectedCustomer,
      'ITEMS SUMMARY': summary,
      'TOTAL AMOUNT': total,
      'PAYMENT MODE': pMode,
      'PAYMENT_MODE': pMode,
      'PAYMENT': pMode,
    });
    setState(() => isSaving = false);

    _previewPdfDocument(estNo, date, selectedCustomer, List.from(billItems), total, pMode, coolie);
    setState(() {
      billItems.clear();
      selectedCustomer = '';
      currentEditingEstNo = null;
      labourController.text = '0';
      paymentMode = 'CASH';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCustomer.isEmpty ? null : selectedCustomer,
                      hint: const Text('Select Customer *'),
                      isExpanded: true,
                      items: widget.customers.map((c) => DropdownMenuItem(
                        value: c['NAME'].toString(),
                        child: Text(c['NAME'].toString(), overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedCustomer = val ?? ''),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Item'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2979FF), foregroundColor: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => ListView.builder(
                          itemCount: widget.items.length,
                          itemBuilder: (context, idx) {
                            final item = widget.items[idx];
                            return ListTile(
                              title: Text(item['ITEM NAME'] ?? ''),
                              subtitle: Text('Rate: ₹${item['RATE']} • ${item['RATE PER KG/BAG']}'),
                              onTap: () {
                                Navigator.pop(ctx);
                                _promptItemEntry(item);
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Mode:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Row(
                    children: ['CASH', 'CREDIT', 'UPI'].map((m) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(m, style: const TextStyle(fontSize: 11)),
                        selected: paymentMode == m,
                        selectedColor: m == 'CREDIT' ? Colors.orange.shade800 : (m == 'UPI' ? const Color(0xFF2979FF) : const Color(0xFF2E7D32)),
                        onSelected: (val) {
                          if (val) setState(() => paymentMode = m);
                        },
                      ),
                    )).toList(),
                  ),
                ],
              ),
              if (paymentMode == 'UPI' && widget.showUpiQr && billItems.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(upiQrUrl, width: 65, height: 65, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 40)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Scan & Pay via UPI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('₹${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        Text(widget.upiId, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: billItems.isEmpty
              ? const Center(child: Text('Bill is empty. Select customer & add items.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: billItems.length,
                  itemBuilder: (context, idx) {
                    final item = billItems[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _promptItemEntry({'ITEM NAME': item['name'], 'RATE': item['rate'], 'RATE PER KG/BAG': item['unit']}, idx),
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${item['qty']} ${item['unit']} × ₹${item['rate']} (Bags: ${item['bag']})"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₹${item['total']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () => setState(() {
                                billItems.removeAt(idx);
                                _recalcLabour();
                              }),
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
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grand Total', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text('₹${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                ],
              ),
              ElevatedButton.icon(
                icon: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.visibility),
                label: Text(isSaving ? 'Saving...' : 'Save & View PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                onPressed: isSaving ? null : _saveEstimate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PdfViewScreen extends StatelessWidget {
  final String title;
  final Future<Uint8List> Function(PdfPageFormat) buildPdf;

  const PdfViewScreen({super.key, required this.title, required this.buildPdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        build: buildPdf,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }
}

class SavedEstimatesTab extends StatefulWidget {
  final List<dynamic> estimates;
  final String companyName;
  final String companyLocation;
  final List<dynamic> customers;
  final Function(Map<String, dynamic>) onEditInvoice;

  const SavedEstimatesTab({
    super.key,
    required this.estimates,
    required this.companyName,
    required this.companyLocation,
    required this.customers,
    required this.onEditInvoice,
  });

  @override
  State<SavedEstimatesTab> createState() => _SavedEstimatesTabState();
}

class _SavedEstimatesTabState extends State<SavedEstimatesTab> {
  String searchQuery = '';
  String selectedFilter = 'Today';
  DateTimeRange? selectedDateRange;

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
      final match = RegExp(r'^(.*?)\s*\((\d+(?:\.\d+)?)\s*(KG|BAG)?\s*x\s*(\d+(?:\.\d+)?)\)$', caseSensitive: false).firstMatch(p.trim());
      if (match != null) {
        final name = match.group(1)?.trim() ?? '';
        final qty = double.tryParse(match.group(2) ?? '1') ?? 1.0;
        final unit = match.group(3)?.toUpperCase() ?? 'KG';
        final rate = double.tryParse(match.group(4) ?? '0') ?? 0.0;
        list.add({
          'name': name,
          'qty': qty,
          'unit': unit,
          'rate': rate,
          'total': (qty * rate).toStringAsFixed(2),
        });
      } else {
        list.add({
          'name': p,
          'qty': '',
          'unit': '',
          'rate': '',
          'total': '',
        });
      }
    }
    return list;
  }

  void _previewExistingPdf(Map<String, dynamic> est) {
    final parsed = _parseSummary(est['ITEMS SUMMARY'] ?? '');
    final estNo = est['ESTIMATE NO'] ?? 'EST';
    final date = _cleanDate(est['DATE']);
    final cust = est['CUSTOMER NAME'] ?? 'Customer';
    final total = double.tryParse(est['TOTAL AMOUNT']?.toString() ?? '0') ?? 0.0;
    final pMode = (est['PAYMENT MODE'] ?? est['PAYMENT_MODE'] ?? est['PAYMENT'] ?? 'CASH').toString().toUpperCase();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewScreen(
          title: 'Invoice $estNo',
          buildPdf: (format) async {
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
                              pw.Text(widget.companyName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                              pw.Text(widget.companyLocation, style: const pw.TextStyle(fontSize: 12)),
                              pw.SizedBox(height: 6),
                              pw.Text('ESTIMATE INVOICE', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Invoice No: $estNo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            pw.Text('Date: $date'),
                          ],
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Customer: $cust', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Payment: $pMode', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.grey400),
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                              children: [
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('#')),
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item Description')),
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qty / Unit', textAlign: pw.TextAlign.right)),
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Rate', textAlign: pw.TextAlign.right)),
                                pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total', textAlign: pw.TextAlign.right)),
                              ],
                            ),
                            ...parsed.asMap().entries.map((entry) {
                              var it = entry.value;
                              return pw.TableRow(
                                children: [
                                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${entry.key + 1}')),
                                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['name']}')),
                                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['qty']} ${it['unit']}', textAlign: pw.TextAlign.right)),
                                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['rate']}', textAlign: pw.TextAlign.right)),
                                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['total']}', textAlign: pw.TextAlign.right)),
                                ],
                              );
                            }),
                          ],
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Grand Total:  ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            pw.Text('INR ${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
            return doc.save();
          },
        ),
      ),
    );
  }

  void _shareSavedWhatsApp(Map<String, dynamic> est) async {
    StringBuffer sb = StringBuffer();
    sb.writeln("🧾 *${widget.companyName.toUpperCase()}*");
    sb.writeln("📍 *${widget.companyLocation}*");
    sb.writeln("──────────────────────");
    sb.writeln("📋 *ESTIMATE INVOICE*");
    sb.writeln("🔢 *Est No:* ${est['ESTIMATE NO'] ?? '-'}");
    sb.writeln("📅 *Date:* ${_cleanDate(est['DATE'])}");
    sb.writeln("👤 *Customer:* ${est['CUSTOMER NAME'] ?? '-'}");
    final pMode = (est['PAYMENT MODE'] ?? est['PAYMENT_MODE'] ?? est['PAYMENT'] ?? 'CASH').toString().toUpperCase();
    sb.writeln("💳 *Payment:* $pMode");
    sb.writeln("──────────────────────");
    sb.writeln("📦 *ITEMS LIST:*");

    final parsed = _parseSummary(est['ITEMS SUMMARY'] ?? '');
    int count = 1;
    for (var it in parsed) {
      if (it['qty'].toString().isNotEmpty) {
        sb.writeln("$count️⃣ *${it['name']}*");
        sb.writeln(" ▫️ ${it['qty']} ${it['unit']} × ₹${it['rate']} = *₹${it['total']}*");
      } else {
        sb.writeln("$count️⃣ ${it['name']}");
      }
      count++;
    }

    sb.writeln("──────────────────────");
    sb.writeln("💰 *GRAND TOTAL: ₹${est['TOTAL AMOUNT'] ?? '0'}*");
    sb.writeln("──────────────────────");
    sb.writeln("_Thank you for your business!_");

    String custPhone = '';
    final custName = (est['CUSTOMER NAME'] ?? '').toString().trim().toUpperCase();
    for (var c in widget.customers) {
      if ((c['NAME'] ?? '').toString().trim().toUpperCase() == custName) {
        custPhone = (c['CONTACT NUMBER'] ?? c['PHONE'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
        break;
      }
    }

    final encoded = Uri.encodeComponent(sb.toString());
    Uri url;
    if (custPhone.isNotEmpty) {
      final target = custPhone.length == 10 ? "91$custPhone" : custPhone;
      url = Uri.parse("whatsapp://send?phone=$target&text=$encoded");
    } else {
      url = Uri.parse("whatsapp://send?text=$encoded");
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        final webUrl = Uri.parse("https://api.whatsapp.com/send?text=$encoded");
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  bool _matchesDateFilter(String formattedDate) {
    if (selectedFilter == 'All Invoices') return true;
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (selectedFilter == 'Today') {
      return formattedDate == todayStr;
    } else if (selectedFilter == 'Yesterday') {
      final yest = now.subtract(const Duration(days: 1));
      return formattedDate == "${yest.year}-${yest.month.toString().padLeft(2, '0')}-${yest.day.toString().padLeft(2, '0')}";
    } else if (selectedFilter == 'This Month') {
      return formattedDate.startsWith("${now.year}-${now.month.toString().padLeft(2, '0')}");
    } else if (selectedFilter == 'Date Range' && selectedDateRange != null) {
      try {
        DateTime recordDate = DateTime.parse(formattedDate);
        DateTime startDate = DateTime(selectedDateRange!.start.year, selectedDateRange!.start.month, selectedDateRange!.start.day);
        DateTime endDate = DateTime(selectedDateRange!.end.year, selectedDateRange!.end.month, selectedDateRange!.end.day, 23, 59, 59);
        return recordDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               recordDate.isBefore(endDate.add(const Duration(seconds: 1)));
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.estimates.reversed.where((raw) {
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
          padding: const EdgeInsets.all(12),
          child: TextField(
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [UpperCaseTextFormatter()],
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search customer or invoice no...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Today'),
                selected: selectedFilter == 'Today',
                onSelected: (_) => setState(() => selectedFilter = 'Today'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Yesterday'),
                selected: selectedFilter == 'Yesterday',
                onSelected: (_) => setState(() => selectedFilter = 'Yesterday'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('This Month'),
                selected: selectedFilter == 'This Month',
                onSelected: (_) => setState(() => selectedFilter = 'This Month'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('All Invoices'),
                selected: selectedFilter == 'All Invoices',
                onSelected: (_) => setState(() => selectedFilter = 'All Invoices'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtered.length,
            itemBuilder: (context, idx) {
              final est = filtered[idx] as Map<String, dynamic>;
              final pMode = (est['PAYMENT MODE'] ?? est['PAYMENT_MODE'] ?? est['PAYMENT'] ?? 'CASH').toString().toUpperCase();
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => _previewExistingPdf(est),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(est['CUSTOMER NAME'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(pMode, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: pMode == 'CREDIT' ? Colors.orangeAccent : Colors.greenAccent)),
                    ],
                  ),
                  subtitle: Text("${est['ESTIMATE NO']} • ${_cleanDate(est['DATE'])}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₹${est['TOTAL AMOUNT']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
                        onPressed: () => _previewExistingPdf(est),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.green, size: 20),
                        onPressed: () => _shareSavedWhatsApp(est),
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
  final Future<bool> Function(Map<String, dynamic>)? onAddItem;
  final Future<bool> Function(String, Map<String, dynamic>)? onEditItem;

  const PriceListTab({super.key, required this.items, this.onAddItem, this.onEditItem});

  @override
  State<PriceListTab> createState() => _PriceListTabState();
}

class _PriceListTabState extends State<PriceListTab> {
  String searchQuery = '';
  String categoryFilter = 'ALL';

  void _showItemDialog([Map<String, dynamic>? existing]) {
    final nameCtrl = TextEditingController(text: existing?['ITEM NAME'] ?? '');
    final rateCtrl = TextEditingController(text: existing?['RATE']?.toString() ?? '');
    final tallyCtrl = TextEditingController(text: existing?['NAME OF ITEM IN TALLY'] ?? existing?['ITEM NAME ON TALLY'] ?? '');
    final rateTypeCtrl = TextEditingController(text: existing?['RATE PER KG/BAG'] ?? 'RATE PER KG');

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
                if (widget.onAddItem != null) await widget.onAddItem!(payload);
              } else {
                if (widget.onEditItem != null) await widget.onEditItem!(existing['ITEM NAME'], payload);
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
    final filtered = widget.items.where((raw) {
      final it = raw as Map<String, dynamic>;
      final name = (it['ITEM NAME'] ?? '').toString().toLowerCase();
      final unit = (it['RATE PER KG/BAG'] ?? '').toString().toUpperCase();
      final q = searchQuery.toLowerCase();
      final matchesQuery = name.contains(q);
      if (categoryFilter == 'BAG') return matchesQuery && unit.contains('BAG');
      if (categoryFilter == 'KG') return matchesQuery && unit.contains('KG');
      return matchesQuery;
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
            padding: const EdgeInsets.all(12),
            child: TextField(
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['ALL', 'BAG', 'KG'].map((c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(c == 'ALL' ? 'All' : (c == 'BAG' ? 'Bags' : 'KG')),
                selected: categoryFilter == c,
                onSelected: (val) {
                  if (val) setState(() => categoryFilter = c);
                },
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final it = filtered[idx] as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(it['ITEM NAME'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${it['RATE PER KG/BAG'] ?? ''}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹${it['RATE']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showItemDialog(it)),
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
  final Future<bool> Function(Map<String, dynamic>)? onAddCustomer;
  final Future<bool> Function(String, Map<String, dynamic>)? onEditCustomer;

  const CustomersTab({super.key, required this.customers, this.onAddCustomer, this.onEditCustomer});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  String searchQuery = '';

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) return;
    final url = Uri.parse("tel:$clean");
    if (await canLaunchUrl(url)) launchUrl(url);
  }

  void _whatsappPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return;
    final target = clean.length == 10 ? "91$clean" : clean;
    final url = Uri.parse("whatsapp://send?phone=$target");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(Uri.parse("https://wa.me/$target"), mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showCustomerDialog([Map<String, dynamic>? existing]) {
    final nameCtrl = TextEditingController(text: existing?['NAME'] ?? '');
    final contactCtrl = TextEditingController(text: (existing?['CONTACT NUMBER'] ?? existing?['PHONE'] ?? '').toString());
    final addressCtrl = TextEditingController(text: existing?['ADDRESS'] ?? '');

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
                controller: contactCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Contact Number'),
              ),
              TextField(
                controller: addressCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'Address'),
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
                'CONTACT NUMBER': contactCtrl.text.trim(),
                'ADDRESS': addressCtrl.text.trim().toUpperCase(),
              };

              if (existing == null) {
                if (widget.onAddCustomer != null) await widget.onAddCustomer!(payload);
              } else {
                if (widget.onEditCustomer != null) await widget.onEditCustomer!(existing['NAME'], payload);
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
    final filtered = widget.customers.where((raw) {
      final c = raw as Map<String, dynamic>;
      final name = (c['NAME'] ?? '').toString().toLowerCase();
      final phone = (c['CONTACT NUMBER'] ?? '').toString();
      final q = searchQuery.toLowerCase();
      return name.contains(q) || phone.contains(q);
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
            padding: const EdgeInsets.all(12),
            child: TextField(
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search customer or phone...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final c = filtered[idx] as Map<String, dynamic>;
                final phone = (c['CONTACT NUMBER'] ?? '').toString();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(c['NAME'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(phone.isNotEmpty ? phone : 'No contact added'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (phone.isNotEmpty) ...[
                          IconButton(icon: const Icon(Icons.call, color: Colors.greenAccent, size: 20), onPressed: () => _callPhone(phone)),
                          IconButton(icon: const Icon(Icons.share, color: Color(0xFF25D366), size: 20), onPressed: () => _whatsappPhone(phone)),
                        ],
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showCustomerDialog(c)),
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
                Text(expression, style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(display, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF2979FF))),
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
