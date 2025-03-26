import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:intl/intl.dart';

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

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat('yyyy-MM-dd – h:mm a').format(dateTime.toLocal());
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Group Name (readonly + copy)
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

            // ✅ Group ID (readonly + copy)
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
            const SizedBox(height: 24),

            // ✅ Created On (shown as topic)
            Text(
              "📅 Created On: ${formatDateTime(group?.createdAt)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Total Members (shown as topic)
            Text(
              "👥 Total Members: ${group?.membersCount ?? 'N/A'}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
