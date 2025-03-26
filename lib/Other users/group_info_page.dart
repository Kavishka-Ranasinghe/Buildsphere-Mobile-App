import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;

  const GroupInfoPage({super.key, required this.groupId});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Group? group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGroupInfo();
  }

  Future<void> fetchGroupInfo() async {
    try {
      await CometChat.getGroup(
        widget.groupId,
        onSuccess: (Group fetchedGroup) {
          setState(() {
            group = fetchedGroup;
            _isLoading = false;
          });
        },
        onError: (CometChatException e) {
          debugPrint("❌ Error fetching group: ${e.message}");
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      debugPrint("❌ Exception: $e");
    }
  }

  void copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$label copied")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Group Info")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Read-only Group Name + copy
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: group?.name ?? "",
                    decoration: const InputDecoration(
                      labelText: "Group Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    copyToClipboard(group?.name ?? "", "Group Name");
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Read-only Group ID + copy
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: group?.guid ?? "",
                    decoration: const InputDecoration(
                      labelText: "Group ID",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    copyToClipboard(group?.guid ?? "", "Group ID");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
