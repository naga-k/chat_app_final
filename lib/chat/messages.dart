import 'package:chat_app/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong!'),
          );
        }
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Loading...'));
        }
        final documents = chatSnapshot.data?.docs.map(
          (document) {
            return document.data()! as Map<String, dynamic>;
          },
        ).toList();
        return ListView.builder(
          reverse: true,
          itemCount: documents?.length ?? 0,
          itemBuilder: (ctx, index) {
            final user = FirebaseAuth.instance.currentUser;
            return MessageBubble(
              message: documents?[index]['text'],
              isMe: documents?[index]['userId'] == user?.uid,
              userName: documents?[index]['userName'],
              userImage: documents?[index]['userImage'],
              key: ValueKey(documents?[index].hashCode),
            );
          },
        );
      },
    );
  }
}
