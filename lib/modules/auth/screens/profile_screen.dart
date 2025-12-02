import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/modules/auth/logic/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  final String? tabId;
  const ProfileScreen({super.key, this.tabId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 32),
                     CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          state.username.isNotEmpty ? state.username[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        state.username,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.password),
                      title: const Text('Change Password'),
                      onTap: () {
                        // TODO: Implement change password dialog/screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Change Password not implemented yet')),
                        );
                      },
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
          } else {
             return const Center(child: Text('Not authenticated'));
          }
        },
      ),
    );
  }
}
