import 'package:flutter/material.dart';
import 'package:sales_managementv5/model/user_model.dart';
import 'package:sales_managementv5/services/user_service.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  ApiService apiService = ApiService();
  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    users = apiService.getUsers();
  }

  void showUserDialog({User? user}) {
    TextEditingController nameController = TextEditingController(text: user?.name ?? "");
    TextEditingController emailController = TextEditingController(text: user?.email ?? "");
    TextEditingController passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(user == null ? "Add User" : "Edit User", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    ElevatedButton(
                      style: _elevatedButtonStyle(),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (user == null) {
                            apiService.addUser(nameController.text, emailController.text, passwordController.text).then((success) {
                              _handleResponse(success, "User added successfully");
                            });
                          } else {
                            apiService.updateUser(user.id, nameController.text, emailController.text).then((success) {
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
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: _elevatedButtonStyle(),
            onPressed: () {
              apiService.deleteUser(userId).then((success) {
                _handleResponse(success, "User deleted successfully");
              });
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _handleResponse(bool success, String message) {
    if (success) {
      setState(() {
        users = apiService.getUsers();
      });
      Navigator.pop(context);
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
              child: FutureBuilder<List<User>>(
                future: users,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final user = snapshot.data![index];
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
