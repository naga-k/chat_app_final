import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  String _enteredMessage = '';

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final userData = await FirebaseFirestore.instance.collection('users').get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'createdAt': Timestamp.now(),
      'userName': userData.docs
          .firstWhere((doc) => doc.id == FirebaseAuth.instance.currentUser?.uid)
          .data()['userName'],
      'userImage': userData.docs
          .firstWhere((doc) => doc.id == FirebaseAuth.instance.currentUser?.uid)
          .data()['image_url'],
    });
    setState(() {
      _enteredMessage = '';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(labelText: 'Send a message...'),
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  onChanged: (value) {
                    setState(() {
                      _enteredMessage = value;
                    });
                  },
                  onEditingComplete:
                      _enteredMessage.trim().isEmpty ? null : _sendMessage)),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(Icons.send),
              onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage),
        ],
      ),
    );
  }
}
