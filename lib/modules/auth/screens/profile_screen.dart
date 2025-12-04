import 'package:flutter/material.dart';
import 'package:flutter_app/utils/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/modules/auth/logic/auth_cubit.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  final String? tabId;
  const ProfileScreen({super.key, this.tabId});

  void _showChangePasswordDialog(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldController,
                decoration: const InputDecoration(labelText: 'Old Password'),
                obscureText: true,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: newController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: confirmController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  if (v != newController.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await context.read<AuthCubit>().changePassword(
                    oldController.text,
                    newController.text,
                    confirmController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password changed successfully')),
                    );
                  }
                } catch (e) {
                   if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String? currentFirst, String? currentLast, String? currentPhone) {
    final firstController = TextEditingController(text: currentFirst);
    final lastController = TextEditingController(text: currentLast);
    final phoneController = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
             TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
           TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
               context.read<AuthCubit>().updateProfile(
                 firstName: firstController.text,
                 lastName: lastController.text,
                 phone: phoneController.text,
               );
               Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (context.mounted) {
        context.read<AuthCubit>().uploadLogo(pickedFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
           if (state is AuthFailure) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.message)),
             );
           }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            final fullAvatarUrl = getFullMediaUrl(user.avatarUrl);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 32),
                    Center(
                      child: Stack(
                        children: [
                           CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).primaryColor,
                              backgroundImage: fullAvatarUrl != null
                                 ? NetworkImage(fullAvatarUrl)
                                 : null,
                              child: fullAvatarUrl == null
                                  ? Text(
                                      user.initials,
                                      style: const TextStyle(fontSize: 40, color: Colors.white),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                onPressed: () => _pickImage(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.username,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (user.isStaff) ...[
                          const SizedBox(width: 8),
                          const Tooltip(
                            message: 'Staff Member',
                            child: Icon(Icons.verified, color: Colors.blue),
                          )
                        ]
                      ],
                    ),
                    if (user.companyName != null)
                      Center(child: Text(user.companyName!, style: Theme.of(context).textTheme.titleMedium)),
                     const SizedBox(height: 24),

                    const Divider(),
                    ListTile(
                      title: const Text('Information'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user.firstName != null || user.lastName != null)
                             Text('Name: ${user.firstName ?? ''} ${user.lastName ?? ''}'),
                          if (user.email != null) Text('Email: ${user.email}'),
                          if (user.phone != null) Text('Phone: ${user.phone}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditProfileDialog(
                          context,
                          user.firstName,
                          user.lastName,
                          user.phone
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.password),
                      title: const Text('Change Password'),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                     const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout', style: TextStyle(color: Colors.red)),
                      onTap: () {
                         context.read<AuthCubit>().logout();
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is AuthLoading) {
             return const Center(child: CircularProgressIndicator());
          } else {
             return const Center(child: Text('Not authenticated'));
          }
        },
      ),
    );
  }
}
