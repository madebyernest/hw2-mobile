import 'package:cloud_firestore/cloud_firestore.dart' show QueryDocumentSnapshot;
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/board_service.dart';

class BoardScreen extends StatefulWidget {
  final String uid, authorName;
  final AuthService auth;
  final BoardService board;
  const BoardScreen(
      {super.key,
      required this.uid,
      required this.authorName,
      required this.auth,
      required this.board});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final _text = TextEditingController();
  late String _draftId = widget.board.newMessageId();
  bool _sending = false;
  late final _stream = widget.board.messageBoard();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _post() async {
    final text = _text.text.trim();
    if (_sending) return;
    if (text.isEmpty || text.length > 500) {
      _snack('Message must be 1–500 characters.');
      return;
    }
    setState(() => _sending = true);
    try {
      await widget.board.postMessage(
        messageId: _draftId,
        authorUid: widget.uid,
        authorName: widget.authorName,
        text: text,
      );
      _text.clear();
      _draftId = widget.board.newMessageId();
    } catch (e) {
      _snack(BoardService.message(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _edit(String id, String current) async {
    final c = TextEditingController(text: current);
    final newText = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(controller: c, maxLength: 500),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, c.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    c.dispose();
    if (newText == null || newText.isEmpty) return;
    try {
      await widget.board.editMessage(messageId: id, newText: newText);
    } catch (e) {
      _snack(BoardService.message(e));
    }
  }

  Future<void> _delete(String id) async {
    try {
      await widget.board.deleteMessage(messageId: id);
    } catch (e) {
      _snack(BoardService.message(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Board'),
        actions: [
          IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout),
              onPressed: widget.auth.signOut),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return const Center(child: Text('Could not load the board.'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                    child: Text('No messages yet. Be the first to post!'));
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) => _tile(docs[i]),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  maxLength: 500,
                  decoration: const InputDecoration(
                      hintText: 'Write a message', counterText: ''),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sending ? null : _post,
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _tile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final mine = d['authorUid'] == widget.uid;
    return ListTile(
      title: Text(d['text'] ?? ''),
      subtitle: Text('${d['authorName'] ?? 'Unknown'}'
          '${d['editedAt'] != null ? ' · edited' : ''}'),
      trailing: mine
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _edit(doc.id, d['text'] ?? '')),
              IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _delete(doc.id)),
            ])
          : null,
    );
  }
}
