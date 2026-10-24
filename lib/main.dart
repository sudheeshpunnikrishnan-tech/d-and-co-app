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

  String companyName = 'DAVIS & COMPANY';
  String companyLocation = 'Aluva, Ernakulam';

  // Current App Version
  final String currentAppVersion = "1.0.1";

  Map<String, dynamic>? invoiceToEdit;

  final String apiUrl =
      'https://script.google.com/macros/s/AKfycbwRwyjkaaQZ0N4wyfNOfwZqCeJP4idUKJaINn8SQXKwEJp9hyTGv9AyJekyyicpUSWWVA/exec';

  @override
  void initState() {
    super.initState();
    fetchData();
    // Check for updates shortly after launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdate();
    });
  }

  Future<void> _checkForAppUpdate() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.github.com/repos/sudheeshpunnikrishnan-tech/d-and-co-app/releases/latest'));
      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        final latestTag = (releaseData['tag_name'] ?? '').toString().replaceAll('v', '');
        final assets = releaseData['assets'] as List<dynamic>? ?? [];

        String? apkDownloadUrl;
        for (var asset in assets) {
          if (asset['name'].toString().endsWith('.apk')) {
            apkDownloadUrl = asset['browser_download_url'];
            break;
          }
        }

        if (latestTag.isNotEmpty && latestTag != currentAppVersion && apkDownloadUrl != null) {
          _showUpdateDialog(latestTag, apkDownloadUrl);
        }
      }
    } catch (_) {
      // Silently pass if GitHub check fails or offline
    }
  }

  void _showUpdateDialog(String newVersion, String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('New Update Available!', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
          'A new version ($newVersion) of DC PRIME is available.\nClick update to download and install the latest features automatically.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Update Now'),
            onPressed: () async {
              Navigator.pop(ctx);
              final uri = Uri.parse(downloadUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
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

  void _openSettingsDialog() {
    final compController = TextEditingController(text: companyName);
    final locController = TextEditingController(text: companyLocation);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.blueAccent),
