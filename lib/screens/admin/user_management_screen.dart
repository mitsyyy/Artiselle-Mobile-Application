import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return UserModel.fromMap(doc.id, data);
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                columnSpacing: 12,
                horizontalMargin: 12,
                headingRowColor: MaterialStateProperty.all(Colors.deepPurple.shade50),
                columns: const [
                  DataColumn(label: Text('User Details', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: users.map((user) {
                  return DataRow(cells: [
                    DataCell(
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.displayName.isNotEmpty ? user.displayName : 'No Name', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis
                            ),
                            Text(
                              user.email, 
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]), 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.role.name == 'admin' ? Colors.red.shade50 : Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: user.role.name == 'admin' ? Colors.red.shade200 : Colors.deepPurple.shade200),
                        ),
                        child: Text(
                          user.role.name.toUpperCase(), 
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: user.role.name == 'admin' ? Colors.red.shade700 : Colors.deepPurple.shade700
                          )
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.info_outline, color: Colors.deepPurple, size: 22),
                            onPressed: () => _viewUserDetails(context, user),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                            onPressed: () => _deleteUser(context, user.uid),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _viewUserDetails(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID', user.uid),
                _buildDetailRow('Email', user.email),
                _buildDetailRow('Verified', user.emailVerified ? 'Yes' : 'No'),
                _buildDetailRow('Joined', user.createdAt.toString().split('.').first),
                if (user.role == UserRole.seller) ...[
                  const Divider(height: 24),
                  const Text('Seller Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple)),
                  const SizedBox(height: 12),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('stores').doc(user.uid).get(),
                    builder: (context, storeSnap) {
                      if (storeSnap.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        ));
                      }
                      if (!storeSnap.hasData || !storeSnap.data!.exists || storeSnap.data!.data() == null) {
                        return const Text('Store profile not set up yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
                      }
                      
                      final storeData = storeSnap.data!.data() as Map<String, dynamic>;
                      final storeName = storeData['storeName'] as String? ?? 'Not provided';
                      final contactInfo = storeData['contactInfo'] as String? ?? 'Not provided';
                      final description = storeData['description'] as String?;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Store Name', storeName),
                          _buildDetailRow('Contact', contactInfo),
                          if (description != null && description.isNotEmpty)
                            _buildDetailRow('Description', description),
                        ],
                      );
                    },
                  ),
                ]
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance.collection('users').doc(uid).delete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete user: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
