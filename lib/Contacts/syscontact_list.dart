import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class _SystemContactsListState extends State<SystemContactsList> {
  List<Contact>? _systemContacts;

  bool get _isLoadingContacts => _systemContacts == null;

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  Future<void> _getContacts() async {
    final PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) {
      final Iterable<Contact> systemContacts =
          await ContactsService.getContacts(withThumbnails: false);
      setState(() {
        _systemContacts = systemContacts.toList();
      });
    } else if (status.isDenied) {
      _requestPermission();
    } else {
      // Prompt the user to open the app settings to grant permissions
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _requestPermission() async {
    final PermissionStatus status = await Permission.contacts.request();
    if (status.isGranted) {
      _getContacts();
    } else {
      // Permission not granted
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
            'Please enable contact access for this app in the settings.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Contacts'),
      ),
      body: _isLoadingContacts
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _systemContacts?.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = _systemContacts?[index];
                return ListTile(
                  title: Text('${contact!.displayName}'),
                  onTap: () {
                    // Return the selected contact to the caller screen
                    Navigator.pop(context, contact);
                  },
                );
              },
            ),
    );
  }
}

// The function to show the System Contacts list on button click and return the selected contact
Future<Contact?> showSystemContactList(BuildContext context) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SystemContactsList(),
    ),
  );
}

class SystemContactsList extends StatefulWidget {
  const SystemContactsList({super.key});

  @override
  _SystemContactsListState createState() => _SystemContactsListState();
}
