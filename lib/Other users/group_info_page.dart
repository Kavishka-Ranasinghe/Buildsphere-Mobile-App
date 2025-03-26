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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
            _nameController.text = group?.name ?? "";
            _passwordController.text = group?.password ?? "";
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

  void updateGroupInfo() async {
    if (group == null) return;

    Group updatedGroup = Group(
      guid: group!.guid,
      name: _nameController.text,
      type: group!.type,
      password: _passwordController.text,
    );

    await CometChat.updateGroup(
      group: updatedGroup,
      onSuccess: (Group updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Group info updated")),
        );
        setState(() {
          group = updated;
        });
      },
      onError: (CometChatException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to update: ${e.message}")),
        );
      },
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
            // ✅ Editable Group Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 16),

            // ✅ Editable password + copy
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Group Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    copyToClipboard(_passwordController.text, "Password");
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: updateGroupInfo,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
