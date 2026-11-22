import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/board_service.dart';
import '../services/user_service.dart';
import 'board_screen.dart';

class ProfileGate extends StatefulWidget {
  final User user;
  final AuthService auth;
  final UserService users;
  final BoardService board;
  const ProfileGate(
      {super.key,
      required this.user,
      required this.auth,
      required this.users,
      required this.board});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<Map<String, dynamic>> _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.users.ensureProfile(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profile,
      builder: (context, snap) {
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Account created, profile not saved.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _profile =
                      widget.users.ensureProfile(widget.user)),
                  child: const Text('Retry'),
                ),
                TextButton(
                    onPressed: widget.auth.signOut,
                    child: const Text('Sign out')),
              ]),
            ),
          );
        }
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final p = snap.data!;
        return BoardScreen(
          uid: widget.user.uid,
          authorName: '${p['firstName']} ${p['lastName']}',
          auth: widget.auth,
          board: widget.board,
        );
      },
    );
  }
}
