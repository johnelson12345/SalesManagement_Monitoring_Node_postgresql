import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/user_model.dart';
import 'package:sales_managementv5/services/user_service.dart';
import 'package:sales_managementv5/widgets/confirmation_delete_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_managementv5/admin_screen/loginscreen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  ApiService apiService = ApiService();
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      List<User> fetchedUsers = await apiService.getUsers();
      print("DEBUG: Loaded users count: ${fetchedUsers.length}");
      if (!mounted) return;
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        users = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load users: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void showUserDialog({User? user}) {
    TextEditingController nameController = TextEditingController(text: user?.name ?? "");
    TextEditingController emailController = TextEditingController(text: user?.email ?? "");
    TextEditingController passwordController = TextEditingController();
    String selectedRole = user?.role ?? "kitchen";
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(user == null ? "Add User" : "Edit User", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration("Name", Icons.person),
                  validator: (value) => value!.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: _inputDecoration("Email", Icons.email),
                  validator: (value) => value!.isEmpty ? "Email is required" : null,
                ),
                if (user == null) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: _inputDecoration("Password", Icons.lock),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? "Password is required" : null,
                  ),
                ],
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: _inputDecoration("Role", Icons.admin_panel_settings),
                  items: const [
                    DropdownMenuItem(value: "kitchen", child: Text("Kitchen")),
                    DropdownMenuItem(value: "cashier", child: Text("Cashier")),
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    ElevatedButton(
                      style: _elevatedButtonStyle(),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (user == null) {
                            apiService.addUser(nameController.text, emailController.text, passwordController.text, selectedRole).then((success) {
                              _handleResponse(success, "User added successfully");
                            });
                          } else {
                            apiService.updateUser(user.id, nameController.text, emailController.text, selectedRole).then((success) {
                              _handleResponse(success, "User updated successfully");
                            });
                          }
                        }
                      },
                      child: Text(user == null ? "Add User" : "Update User"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void confirmDeleteUser(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Delete", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: _elevatedButtonStyle(),
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              try {
                bool success = await apiService.deleteUser(userId);
                if (success) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  int? currentUserId = prefs.getInt('userId');
                  if (currentUserId != null && currentUserId == userId) {
                    // If deleting own account, log out immediately and avoid setState
                    await prefs.clear();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                    return; // Prevent further UI updates
                  }

                  if (!mounted) return;
                  _handleResponse(true, "User deleted successfully");
                } else {
                  if (!mounted) return;
                  _handleResponse(false, "Operation failed");
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to delete user"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Delete", ),
          ),
        ],
      ),
    );
  }


  void _handleResponse(bool success, String message) {
    if (success) {
      print("DEBUG: _handleResponse success: $success, message: $message");
      if (!mounted) return;
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Operation failed"), backgroundColor: Colors.red));
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }

  ButtonStyle _elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: const Color.fromARGB(255, 88, 101, 122),
      foregroundColor: Colors.white
      
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      print("Building UserListScreen with users count: ${users?.length ?? 0}");
      return Scaffold(
        appBar: AppBar(title: const Text("User List"), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 🔹 Added "Add User" button for desktop-friendly design
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => showUserDialog(),
                  style: _elevatedButtonStyle(),
                  icon: const Icon(Icons.person_add),
                  label: const Text("Add User"),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (users == null || users.isEmpty)
                        ? const Center(child: Text("No users found"))
                        : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              if (user == null || user.name == null || user.email == null) {
                                return Card(
                                  child: ListTile(
                                    title: const Text("Invalid user data"),
                                  ),
                                );
                              }
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(user.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => showUserDialog(user: user)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => confirmDeleteUser(user.id)),
                                ],
                              ),
                            ),
                          );
                          print("DEBUG: User at index $index: id=\${user.id}, name=\${user.name}, email=\${user.email}");
                            },
                          ),
              ),
            ],
          ),
        ),
      );
    } catch (e, stacktrace) {
      print("Error building UserListScreen: $e");
      print(stacktrace);
      return Scaffold(
        appBar: AppBar(title: const Text("User List"), centerTitle: true),
        body: Center(child: Text("Error loading users: $e")),
      );
    }
  }
}
