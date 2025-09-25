import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _searchMode = "press";
  String _coverSize = "M";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final mode = await SettingsManager.getSearchMode();
    final size = await SettingsManager.getCoverSize();
    setState(() {
      _searchMode = mode;
      _coverSize = size;
    });
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Cache"),
        content: const Text("Are you sure you want to clear local cache?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SettingsManager.clearCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cache cleared ✅")),
        );
      }
    }
  }

  Future<void> _openAbout() async {
    const url = "https://openlibrary.org/developers/api";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // Search Mode
          const ListTile(title: Text("Search Mode")),
          RadioListTile<String>(
            value: "on_type",
            groupValue: _searchMode,
            title: const Text("Search on Type"),
            onChanged: (val) {
              SettingsManager.setSearchMode(val!);
              setState(() => _searchMode = val);
            },
          ),
          RadioListTile<String>(
            value: "press",
            groupValue: _searchMode,
            title: const Text("Press to Search"),
            onChanged: (val) {
              SettingsManager.setSearchMode(val!);
              setState(() => _searchMode = val);
            },
          ),
          const Divider(),

          // Cover Size
          const ListTile(title: Text("Cover Size")),
          RadioListTile<String>(
            value: "S",
            groupValue: _coverSize,
            title: const Text("Small"),
            onChanged: (val) {
              SettingsManager.setCoverSize(val!);
              setState(() => _coverSize = val);
            },
          ),
          RadioListTile<String>(
            value: "M",
            groupValue: _coverSize,
            title: const Text("Medium"),
            onChanged: (val) {
              SettingsManager.setCoverSize(val!);
              setState(() => _coverSize = val);
            },
          ),
          RadioListTile<String>(
            value: "L",
            groupValue: _coverSize,
            title: const Text("Large"),
            onChanged: (val) {
              SettingsManager.setCoverSize(val!);
              setState(() => _coverSize = val);
            },
          ),
          const Divider(),

          // Clear Cache
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text("Clear Local Cache"),
            onTap: _clearCache,
          ),

          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About Open Library"),
            onTap: _openAbout,
          ),
        ],
      ),
    );
  }
}
