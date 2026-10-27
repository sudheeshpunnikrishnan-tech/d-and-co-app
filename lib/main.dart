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
  final String appVersion = '1.0.9';

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
    final upiCtrl = TextEditingController(text: upiId);
    final labourCtrl = TextEditingController(text: defaultLabourPerBag.toString());

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
                const Divider(height: 28),
                const Text('Billing Controls',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
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
                    decoration: const InputDecoration(
                      labelText: 'Default Labour Rate per Bag (₹)',
                      isDense: true,
                    ),
                    onChanged: (val) {
                      defaultLabourPerBag = double.tryParse(val) ?? 3.0;
                    },
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
                    decoration: const InputDecoration(
                      labelText: 'Business UPI ID (e.g. name@okhdfcbank)',
                      isDense: true,
                    ),
                    onChanged: (val) {
                      upiId = val.trim();
                    },
                  ),
                const Divider(height: 28),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_pin, color: Colors.amberAccent),
                  title: const Text('Developer & Contact Info'),
                  subtitle: const Text('Sudhi (S Tech) - Details'),
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
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Billing'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Invoices'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Price List'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Customers'),
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
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

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
                    Text(
                      companyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('TODAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Today Sales Collection', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  '₹${todaySales.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
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
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
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
                subtitle: Text("${e['ESTIMATE NO']} • ${_cleanDate(e['DATE'])}", style: const TextStyle(fontSize: 12)),
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
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
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
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
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 20, color: color),
            ),
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
  double labourTotal = 0.0;
  final TextEditingController labourController = TextEditingController();

  @override
  void initState() {
    super.initState();
    labourController.text = '0';
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
          }
        }
      }
      widget.onClearEdit();
      _recalcLabour();
    }
  }

  void _recalcLabour() {
    if (!widget.enableLabourCharge) {
      labourTotal = 0.0;
      labourController.text = '0';
      return;
    }
    double totalBags = 0.0;
    for (var it in billItems) {
      totalBags += (it['qty'] as num).toDouble();
    }
    labourTotal = totalBags * widget.defaultLabourPerBag;
    labourController.text = labourTotal.toStringAsFixed(1);
  }

  String _getNextEstimateNumber() {
    int maxNumber = 0;
    for (var est in widget.estimates) {
      if (est is Map<String, dynamic>) {
        String estNo = (est['ESTIMATE NO'] ?? '').toString();
        final match = RegExp(r'(\d+)').allMatches(estNo);
        if (match.isNotEmpty) {
          int? parsed = int.tryParse(match.last.group(0)!);
          if (parsed != null && parsed > maxNumber && parsed < 100000) {
            maxNumber = parsed;
          }
        }
      }
    }
    int next = maxNumber + 1;
    return 'EST-${next.toString().padLeft(4, '0')}';
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
                _recalcLabour();
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
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer: $cust',
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Payment: $pMode',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
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
                pw.SizedBox(height: 10),
                if (coolie > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text('Labour / Coolie Charge:  ',
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('INR ${coolie.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                pw.SizedBox(height: 4),
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
                          pw.Text('Scan to Pay via UPI / GPay / PhonePe',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          pw.Text('UPI ID: ${widget.upiId}', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('Amount: INR ${total.toStringAsFixed(2)}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
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
      List<Map<String, dynamic>> items, double total, String pMode, double coolie) async {
    StringBuffer sb = StringBuffer();
    sb.writeln("🧾 *${widget.companyName.toUpperCase()}*");
    sb.writeln("📍 *${widget.companyLocation}*");
    sb.writeln("──────────────────────");
    sb.writeln("📋 *ESTIMATE INVOICE*");
    sb.writeln("🔢 *Est No:* $estNo");
    sb.writeln("📅 *Date:* $date");
    sb.writeln("👤 *Customer:* $cust");
    sb.writeln("💳 *Payment:* $pMode");
    sb.writeln("──────────────────────");
    sb.writeln("📦 *ITEMS LIST:*");

    int count = 1;
    for (var it in items) {
      sb.writeln("$count️⃣ *${it['name']}*");
      sb.writeln("   ▫️ ${it['qty']} × ₹${it['rate']} = *₹${it['total']}*");
      count++;
    }

    if (coolie > 0) {
      sb.writeln("──────────────────────");
      sb.writeln("🏗️ *Labour / Coolie:* ₹${coolie.toStringAsFixed(2)}");
    }

    sb.writeln("──────────────────────");
    sb.writeln("💰 *GRAND TOTAL: ₹${total.toStringAsFixed(2)}*");
    if (widget.showUpiQr && widget.upiId.isNotEmpty) {
      sb.writeln("📲 *UPI ID:* ${widget.upiId}");
    }
    sb.writeln("──────────────────────");
    sb.writeln("_Thank you for your business!_");

    String custPhone = '';
    for (var c in widget.customers) {
      if ((c['NAME'] ?? '').toString().trim().toUpperCase() == cust.trim().toUpperCase()) {
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

  void _showSavedOptions(String estNo, String date, String cust,
      List<Map<String, dynamic>> items, double total, String pMode, double coolie) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 44),
              const SizedBox(height: 6),
              const Text('Invoice Saved!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Payment Mode: $pMode', style: TextStyle(fontSize: 12, color: pMode == 'CREDIT' ? Colors.orangeAccent : Colors.greenAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pMode == 'UPI' && widget.showUpiQr) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.network(
                    upiQrUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Column(
                      children: [
                        Icon(Icons.qr_code, size: 50, color: Colors.black54),
                        Text('QR Code unavailable', style: TextStyle(color: Colors.black54, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Scan & Pay ₹${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('UPI ID: ${widget.upiId}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        billItems.clear();
                        selectedCustomer = '';
                        currentEditingEstNo = null;
                        labourController.text = '0';
                        paymentMode = 'CASH';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.greenAccent, size: 28),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Navigator.pop(ctx);
                      _generatePdfInvoice(estNo, date, cust, items, total, pMode, coolie);
                      setState(() {
                        billItems.clear();
                        selectedCustomer = '';
                        currentEditingEstNo = null;
                        labourController.text = '0';
                        paymentMode = 'CASH';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Navigator.pop(ctx);
                      _shareViaWhatsApp(estNo, date, cust, items, total, pMode, coolie);
                      setState(() {
                        billItems.clear();
                        selectedCustomer = '';
                        currentEditingEstNo = null;
                        labourController.text = '0';
                        paymentMode = 'CASH';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF25D366),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share, color: Colors.white, size: 28),
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

  void _showAddCustomerDialog() {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final b2bCtrl = TextEditingController();
    final b2cCtrl = TextEditingController();

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
              TextField(
                controller: b2bCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'B2B Names'),
              ),
              TextField(
                controller: b2cCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'B2C Names'),
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
                'CONTACT NUMBER': contactCtrl.text.trim(),
                'ADDRESS': addressCtrl.text.trim().toUpperCase(),
                'B2C NAMES': b2cCtrl.text.trim().toUpperCase(),
                'B2B NAMES': b2bCtrl.text.trim().toUpperCase(),
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
              final b2b = (c['B2B NAMES'] ?? c['B2B'] ?? '').toString().toLowerCase();
              final phone = (c['CONTACT NUMBER'] ?? '').toString();
              return name.contains(filter.toLowerCase()) ||
                     b2b.contains(filter.toLowerCase()) ||
                     phone.contains(filter);
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
                      hintText: 'Search customer name or phone...',
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
                        final b2b = c['B2B NAMES'] ?? c['B2B'] ?? '';
                        final phone = c['CONTACT NUMBER'] ?? '';
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            "${b2b.toString().isNotEmpty ? 'B2B: $b2b' : ''}${phone.toString().isNotEmpty ? ' • 📞 $phone' : ''}",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
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
        String selectedCategory = 'ALL';

        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredItems = widget.items.where((it) {
              final name = (it['ITEM NAME'] ?? '').toString().toLowerCase();
              final unit = (it['RATE PER KG/BAG'] ?? '').toString().toUpperCase();
              final matchesQuery = name.contains(filter.toLowerCase());
              if (selectedCategory == 'BAG') {
                return matchesQuery && unit.contains('BAG');
              } else if (selectedCategory == 'KG') {
                return matchesQuery && unit.contains('KG');
              }
              return matchesQuery;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All Items'),
                        selected: selectedCategory == 'ALL',
                        onSelected: (_) => setModalState(() => selectedCategory = 'ALL'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Bags (ചാക്ക്)'),
                        selected: selectedCategory == 'BAG',
                        onSelected: (_) => setModalState(() => selectedCategory = 'BAG'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('KG (കിലോ)'),
                        selected: selectedCategory == 'KG',
                        onSelected: (_) => setModalState(() => selectedCategory = 'KG'),
                      ),
                    ],
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
                        final isBag = unit.toString().toUpperCase().contains('BAG');

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isBag ? Colors.amber.withOpacity(0.15) : Colors.cyan.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isBag ? 'BAG' : 'KG',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isBag ? Colors.amberAccent : Colors.cyanAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                _recalcLabour();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add to Bill'),
          ),
        ],
      ),
    );
  }

  void _executeSave() async {
    setState(() => isSaving = true);

    String summary = billItems.map((b) => "${b['name']} (${b['qty']} x ${b['rate']})").join(", ");
    final estNo = currentEditingEstNo ?? _getNextEstimateNumber();

    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final currentCustomer = selectedCustomer;
    final currentBillItems = List<Map<String, dynamic>>.from(billItems);
    final currentTotal = grandTotal;
    final coolie = double.tryParse(labourController.text) ?? 0.0;
    final pMode = paymentMode;

    final estData = {
      'ESTIMATE NO': estNo,
      'DATE': date,
      'CUSTOMER NAME': currentCustomer,
      'ITEMS SUMMARY': summary,
      'TOTAL AMOUNT': currentTotal,
      'PAYMENT MODE': pMode,
      'PAYMENT_MODE': pMode,
      'PAYMENT': pMode,
    };

    await widget.onSaveEstimate(estData);
    setState(() => isSaving = false);

    _showSavedOptions(estNo, date, currentCustomer, currentBillItems, currentTotal, pMode, coolie);
  }

  void _saveEstimate() {
    if (selectedCustomer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a customer first')));
      return;
    }
    if (billItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    if (widget.askSaveConfirmation) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFF2979FF)),
              SizedBox(width: 8),
              Text('Confirm Invoice', style: TextStyle(fontSize: 17)),
            ],
          ),
          content: Text(
            'Customer: $selectedCustomer\nPayment: $paymentMode\nTotal: ₹${grandTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
              onPressed: () {
                Navigator.pop(ctx);
                _executeSave();
              },
              child: const Text('Yes, Save'),
            ),
          ],
        ),
      );
    } else {
      _executeSave();
    }
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
                    labourController.text = '0';
                    paymentMode = 'CASH';
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
          child: Column(
            children: [
              Row(
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Mode:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('CASH', style: TextStyle(fontSize: 11)),
                        selected: paymentMode == 'CASH',
                        selectedColor: const Color(0xFF2E7D32),
                        onSelected: (val) {
                          if (val) setState(() => paymentMode = 'CASH');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('CREDIT', style: TextStyle(fontSize: 11)),
                        selected: paymentMode == 'CREDIT',
                        selectedColor: Colors.orange.shade800,
                        onSelected: (val) {
                          if (val) setState(() => paymentMode = 'CREDIT');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('UPI', style: TextStyle(fontSize: 11)),
                        selected: paymentMode == 'UPI',
                        selectedColor: const Color(0xFF2979FF),
                        onSelected: (val) {
                          if (val) setState(() => paymentMode = 'UPI');
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (paymentMode == 'UPI' && widget.showUpiQr && billItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        upiQrUrl,
                        width: 75,
                        height: 75,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.qr_code, size: 50, color: Colors.black54),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('UPI QR Ready', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                          Text('Scan to pay ₹${grandTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                          Text(widget.upiId, style: const TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.w600, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
        if (widget.enableLabourCharge && billItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Theme.of(context).cardTheme.color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.handshake_outlined, size: 16, color: Colors.amberAccent),
                    SizedBox(width: 6),
                    Text('Labour / Coolie (₹):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(
                  width: 90,
                  height: 38,
                  child: TextField(
                    controller: labourController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF242A36) : const Color(0xFFEDF2F7),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
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
                    pw.Text('Grand Total: ',
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

  Future<void> _generateLoadingSlip(String estNo, String date, String cust,
      List<Map<String, dynamic>> items) async {
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
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('GODOWN LOADING SLIP / DELIVERY CHALLAN',
                          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
                pw.Divider(thickness: 1.2),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Slip Ref: $estNo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $date'),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text('Customer: $cust', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 14),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('#', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Quantity / Bags Loaded', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...items.asMap().entries.map((entry) {
                      int idx = entry.key + 1;
                      var it = entry.value;
                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('$idx')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['name']}')),
                          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it['qty']} BAGS / KG', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Loaded By (Godown Sign): ________________', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text('Driver Sign: ________________', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'LoadingSlip_$estNo.pdf',
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
    final pMode = (est['PAYMENT MODE'] ?? est['PAYMENT_MODE'] ?? est['PAYMENT'] ?? 'CASH').toString().toUpperCase();
    sb.writeln("💳 *Payment:* $pMode");
    sb.writeln("──────────────────────");
    sb.writeln("📦 *ITEMS LIST:*");

    final parsed = _parseSummary(est['ITEMS SUMMARY'] ?? '');
    int count = 1;
    for (var it in parsed) {
      if (it['qty'].toString().isNotEmpty) {
        sb.writeln("$count️⃣ *${it['name']}*");
        sb.writeln(" ▫️ ${it['qty']} × ₹${it['rate']} = *₹${it['total']}*");
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

  void _viewInvoiceDetails(Map<String, dynamic> est) {
    final parsedItems = _parseSummary(est['ITEMS SUMMARY'] ?? '');
    final pMode = (est['PAYMENT MODE'] ?? est['PAYMENT_MODE'] ?? est['PAYMENT'] ?? 'CASH').toString().toUpperCase();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customer: ${est['CUSTOMER NAME'] ?? '-'}',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (pMode == 'CREDIT' ? Colors.orange : (pMode == 'UPI' ? Colors.blue : Colors.green)).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(pMode,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: pMode == 'CREDIT' ? Colors.orangeAccent : (pMode == 'UPI' ? Colors.lightBlueAccent : Colors.greenAccent))),
                  ),
                ],
              ),
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
                  OutlinedButton.icon(
                    icon: const Icon(Icons.local_shipping_outlined, size: 16, color: Colors.cyanAccent),
                    label: const Text('Loading Slip', style: TextStyle(color: Colors.cyanAccent)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _generateLoadingSlip(
                        est['ESTIMATE NO'] ?? 'EST',
                        _cleanDate(est['DATE']),
                        est['CUSTOMER NAME'] ?? 'Customer',
                        parsedItems,
                      );
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

    double totalFilterSales = 0;
    int totalFilterBills = filtered.length;
    for (var e in filtered) {
      totalFilterSales += double.tryParse((e as Map<String, dynamic>)['TOTAL AMOUNT']?.toString() ?? '0') ?? 0.0;
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3C72).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$selectedFilter Summary', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('₹${totalFilterSales.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$totalFilterBills Bills', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
                avatar: const Icon(Icons.date_range, size: 14),
                label: Text(selectedDateRange != null
                    ? "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}"
                    : 'Date Range'),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2030),
                    initialDateRange: selectedDateRange ??
                        DateTimeRange(
                          start: DateTime.now().subtract(const Duration(days: 7)),
                          end: DateTime.now(),
                        ),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDateRange = picked;
                      selectedFilter = 'Date Range';
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
                    final pMode = (est['PAYMENT MODE'] ?? est['PAYMENT_MODE'] ?? est['PAYMENT'] ?? 'CASH').toString().toUpperCase();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _viewInvoiceDetails(est),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(est['CUSTOMER NAME'] ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (pMode == 'CREDIT' ? Colors.orange : (pMode == 'UPI' ? Colors.blue : Colors.green)).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(pMode,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: pMode == 'CREDIT' ? Colors.orangeAccent : (pMode == 'UPI' ? Colors.lightBlueAccent : Colors.greenAccent))),
                            ),
                          ],
                        ),
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
  String categoryFilter = 'ALL';

  void _showItemDetailModal(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.inventory_2, color: Color(0xFF2979FF)),
            const SizedBox(width: 8),
            Expanded(child: Text(item['ITEM NAME'] ?? 'Item Details', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Item Name', item['ITEM NAME']),
            _buildDetailRow('Rate', '₹${item['RATE']}'),
            _buildDetailRow('Rate Per', item['RATE PER KG/BAG']),
            _buildDetailRow('Tally Name', item['NAME OF ITEM IN TALLY'] ?? item['ITEM NAME ON TALLY']),
            _buildDetailRow('Billed In', item['BILLED IN'] ?? 'KILOGRAM'),
            _buildDetailRow('Taxable Status', item['TAXABLE OR NOT'] ?? 'NON TAXABLE'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Item'),
            onPressed: () {
              Navigator.pop(ctx);
              _showItemDialog(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(val?.toString().isNotEmpty == true ? val.toString() : '-',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
      final unit = (item['RATE PER KG/BAG'] ?? '').toString().toUpperCase();
      final q = searchQuery.toLowerCase();

      final matchesSearch = name.contains(q) || tally.contains(q);
      if (categoryFilter == 'BAG') {
        return matchesSearch && unit.contains('BAG');
      } else if (categoryFilter == 'KG') {
        return matchesSearch && unit.contains('KG');
      }
      return matchesSearch;
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Items'),
                  selected: categoryFilter == 'ALL',
                  onSelected: (_) => setState(() => categoryFilter = 'ALL'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Bags (ചാക്ക്)'),
                  selected: categoryFilter == 'BAG',
                  onSelected: (_) => setState(() => categoryFilter = 'BAG'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('KG (കിലോ)'),
                  selected: categoryFilter == 'KG',
                  onSelected: (_) => setState(() => categoryFilter = 'KG'),
                ),
              ],
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
                final isBag = rateType.toString().toUpperCase().contains('BAG');
                final tally =
                    item['ITEM NAME ON TALLY'] ?? item['NAME OF ITEM IN TALLY'] ?? '-';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => _showItemDetailModal(item),
                    title: Row(
                      children: [
                        Expanded(child: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isBag ? Colors.amber.withOpacity(0.15) : Colors.cyan.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBag ? 'BAG' : 'KG',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isBag ? Colors.amberAccent : Colors.cyanAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('Tally: $tally\n$rateType • Tap to view all', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
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

  void _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number is missing! Please edit customer.')),
      );
      return;
    }
    final url = Uri.parse("tel:$cleanPhone");
    if (await canLaunchUrl(url)) launchUrl(url);
  }

  void _whatsappPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number is missing! Please edit customer.')),
      );
      return;
    }
    final target = cleanPhone.length == 10 ? "91$cleanPhone" : cleanPhone;
    final url = Uri.parse("whatsapp://send?phone=$target");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(Uri.parse("https://wa.me/$target"), mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showCustomerDetailModal(Map<String, dynamic> c) {
    final name = c['NAME'] ?? '-';
    final contact = (c['CONTACT NUMBER'] ?? c['PHONE'] ?? c['MOBILE'] ?? '').toString();
    final address = (c['ADDRESS'] ?? '').toString();
    final b2b = (c['B2B NAMES'] ?? c['B2B'] ?? '').toString();
    final b2c = (c['B2C NAMES'] ?? c['B2C'] ?? '').toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFF2979FF)),
            const SizedBox(width: 8),
            Expanded(child: Text(name.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Customer Name', name),
            _buildDetailRow('Contact Number', contact.isNotEmpty ? contact : 'Not Added'),
            _buildDetailRow('Address', address.isNotEmpty ? address : 'Not Added'),
            _buildDetailRow('B2B Names', b2b),
            _buildDetailRow('B2C Names', b2c),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Call'),
                  onPressed: () => _callPhone(contact),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('WhatsApp'),
                  onPressed: () => _whatsappPhone(contact),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Edit Details'),
            onPressed: () {
              Navigator.pop(ctx);
              _showCustomerDialog(c);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(val?.toString().isNotEmpty == true ? val.toString() : '-',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCustomerDialog([Map<String, dynamic>? existing]) {
    final nameCtrl = TextEditingController(text: existing?['NAME'] ?? '');
    final contactCtrl = TextEditingController(
        text: (existing?['CONTACT NUMBER'] ?? existing?['PHONE'] ?? existing?['MOBILE'] ?? '').toString());
    final addressCtrl = TextEditingController(text: existing?['ADDRESS'] ?? '');
    final b2bCtrl = TextEditingController(
        text: existing?['B2B NAMES'] ?? existing?['B2B'] ?? '');
    final b2cCtrl = TextEditingController(
        text: existing?['B2C NAMES'] ?? existing?['B2C'] ?? '');

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
              TextField(
                controller: b2bCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'B2B Names'),
              ),
              TextField(
                controller: b2cCtrl,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: const InputDecoration(labelText: 'B2C Names'),
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
                'B2B NAMES': b2bCtrl.text.trim().toUpperCase(),
                'B2C NAMES': b2cCtrl.text.trim().toUpperCase(),
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
      final b2b = (c['B2B NAMES'] ?? c['B2B'] ?? '').toString().toLowerCase();
      final phone = (c['CONTACT NUMBER'] ?? '').toString();
      final address = (c['ADDRESS'] ?? '').toString().toLowerCase();
      final q = searchQuery.toLowerCase();
      return name.contains(q) || b2b.contains(q) || phone.contains(q) || address.contains(q);
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
                hintText: 'Search customer, phone, address...',
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
                final contact = (c['CONTACT NUMBER'] ?? c['PHONE'] ?? c['MOBILE'] ?? '').toString();
                final address = (c['ADDRESS'] ?? '').toString();
                final b2b = (c['B2B NAMES'] ?? c['B2B'] ?? '').toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      onTap: () => _showCustomerDetailModal(c),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2979FF).withOpacity(0.12),
                        child: Text(
                          name.toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2979FF)),
                        ),
                      ),
                      title: Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.call, size: 13, color: contact.isNotEmpty ? Colors.greenAccent : Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                contact.isNotEmpty ? contact : 'No phone added',
                                style: TextStyle(
                                  color: contact.isNotEmpty ? Colors.greenAccent : Colors.grey,
                                  fontWeight: contact.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          if (address.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(address, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ),
                          if (b2b.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text('B2B: $b2b', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.call, size: 19, color: contact.isNotEmpty ? Colors.greenAccent : Colors.grey.withOpacity(0.5)),
                            tooltip: 'Call',
                            onPressed: () => _callPhone(contact),
                          ),
                          IconButton(
                            icon: Icon(Icons.share, size: 19, color: contact.isNotEmpty ? const Color(0xFF25D366) : Colors.grey.withOpacity(0.5)),
                            tooltip: 'WhatsApp',
                            onPressed: () => _whatsappPhone(contact),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 19, color: Colors.grey),
                            tooltip: 'Edit',
                            onPressed: () => _showCustomerDialog(c),
                          ),
                        ],
                      ),
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
