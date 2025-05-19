import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class GroupInfoPage extends StatefulWidget {
  final String groupId;

  const GroupInfoPage({super.key, required this.groupId});

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  Group? group;
  List<GroupMember> groupMembers = [];
  User? currentUser;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchGroupInfo();
    fetchGroupMembers();
    fetchCurrentUser();

    // Auto-refresh every 2 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      fetchGroupInfo();
      fetchGroupMembers();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Stop timer
    super.dispose();
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
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      debugPrint("❌ Exception: $e");
    }
  }

  Future<void> fetchGroupMembers() async {
    try {
      final groupMembersRequest = GroupMembersRequestBuilder(widget.groupId)
        ..limit = 50;

      final request = groupMembersRequest.build();

      request.fetchNext(
        onSuccess: (List<GroupMember> members) {
          // Sort so that admins come first
          members.sort((a, b) {
            if (a.scope == 'admin' && b.scope != 'admin') return -1;
            if (a.scope != 'admin' && b.scope == 'admin') return 1;
            return 0;
          });

          setState(() {
            groupMembers = members;
          });
        },
        onError: (CometChatException e) {
          debugPrint("❌ Error fetching members: ${e.message}");
        },
      );
    } catch (e) {
      debugPrint("❌ Exception while fetching group members: $e");
    }
  }

  Future<void> fetchCurrentUser() async {
    currentUser = await CometChat.getLoggedInUser();
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

  void showMemberActions(GroupMember member) {
    final isAdmin = currentUser != null && groupMembers.any((m) => m.uid == currentUser!.uid && m.scope == 'admin');
    final isSelf = currentUser?.uid == member.uid;
    final isOwner = currentUser?.uid == group?.owner;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            if ((isAdmin || isOwner) && !isSelf)
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red),
                title: const Text("Remove from Group", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await CometChat.kickGroupMember(
                    guid: widget.groupId,
                    uid: member.uid,
                    onSuccess: (_) {
                      setState(() {
                        groupMembers.removeWhere((m) => m.uid == member.uid);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${member.name} removed from group")),
                      );
                    },
                    onError: (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ Failed to remove: ${e.message}")),
                      );
                    },
                  );
                },
              ),
            if ((isAdmin || isOwner) && !isSelf)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                title: const Text("Change Member Scope"),
                onTap: () {
                  Navigator.pop(ctx);
                  _showChangeScopeDialog(member);
                },
              ),
            if (isOwner && !isSelf && member.scope == 'admin')
              ListTile(
                leading: const Icon(Icons.transfer_within_a_station, color: Colors.green),
                title: const Text("Transfer Ownership"),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTransferOwnershipDialog(member);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showChangeScopeDialog(GroupMember member) {
    String? newScope = member.scope; // Default to current scope
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Member Scope"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Admin"),
                value: "admin",
                groupValue: newScope,
                onChanged: (value) {
                  setState(() {
                    newScope = value;
                  });
                  Navigator.pop(context);
                  _updateMemberScope(member, value!);
                },
              ),
              RadioListTile<String>(
                title: const Text("Participant"),
                value: "participant",
                groupValue: newScope,
                onChanged: (value) {
                  setState(() {
                    newScope = value;
                  });
                  Navigator.pop(context);
                  _updateMemberScope(member, value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showTransferOwnershipDialog(GroupMember member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Transfer Ownership"),
          content: Text("Are you sure you want to transfer ownership to ${member.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _transferOwnership(member);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _transferOwnership(GroupMember member) async {
    try {
      await CometChat.transferGroupOwnership(
        guid: widget.groupId,
        uid: member.uid,
        onSuccess: (String message) {
          debugPrint("Group Ownership Transferred Successfully: $message");
          fetchGroupInfo(); // Refresh group info to update owner
          fetchGroupMembers(); // Refresh member list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ownership transferred to ${member.name}")),
          );
        },
        onError: (CometChatException e) {
          debugPrint("Group Ownership Transfer failed: ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to transfer ownership: ${e.message}")),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _updateMemberScope(GroupMember member, String newScope) async {
    try {
      await CometChat.updateGroupMemberScope(
        guid: widget.groupId,
        uid: member.uid,
        scope: newScope,
        onSuccess: (String message) {
          debugPrint("Group Member Scope Changed Successfully: $message");
          fetchGroupMembers(); // Refresh member list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${member.name}'s scope changed to $newScope")),
          );
        },
        onError: (CometChatException e) {
          debugPrint("Group Member Scope Change failed: ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to change scope: ${e.message}")),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Group"),
          content: const Text("Are you sure you want to delete this group? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteGroup();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _showLeaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Leave Group"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await leaveGroup();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Leave"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteGroup() async {
    try {
      await CometChat.deleteGroup(
        widget.groupId,
        onSuccess: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Group deleted successfully")),
          );
          Navigator.pop(context); // Return to previous screen
        },
        onError: (CometChatException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete group: ${e.message}")),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> leaveGroup() async {
    try {
      await CometChat.leaveGroup(
        widget.groupId,
        onSuccess: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You have left the group")),
          );
          Navigator.pop(context); // Return to previous screen
        },
        onError: (CometChatException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to leave group: ${e.message}")),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Group Info")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
            Text(
              "📅 Created On: ${formatDateTime(group?.createdAt)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              "👥 Total Members: ${group?.membersCount ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 32),
            const Text(
              "Group Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (groupMembers.isEmpty)
              const Text("No members found."),
            ...groupMembers.map(
                  (member) {
                final isSelf = currentUser?.uid == member.uid;
                final displayName = isSelf ? "${member.name} (you)" : member.name;

                return ListTile(
                  onTap: () => showMemberActions(member),
                  leading: CircleAvatar(
                    child: Text(member.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(displayName),
                  trailing: Text(member.scope ?? "participant"),
                );
              },
            ),
            const SizedBox(height: 20),
            if (currentUser?.uid == group?.owner)
              ElevatedButton(
                onPressed: () => _showDeleteConfirmation(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete Group", style: TextStyle(color: Colors.white)),
              ),
            if (currentUser?.uid != group?.owner)
              ElevatedButton(
                onPressed: () => _showLeaveConfirmation(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text("Leave Group", style: TextStyle(color: Colors.white)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}