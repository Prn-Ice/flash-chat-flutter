import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class MessageStream extends StatelessWidget {
  MessageStream({
    @required Firestore cloud,
    @required FirebaseUser user,
  })  : _cloud = cloud,
        _user = user;

  final Firestore _cloud;
  final FirebaseUser _user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _cloud
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
//                textMessages is the list of text messages that will
//                eventually display as text bubbles on the users screen
        List<MessageBubble> textMessages = [];
//                snapshot holds the current 'snapshot' for the data which
//                is currently in the stream builder.
//                And contained in that is the QuerySnapshot we get from firebase
        if (!snapshot.hasData || _user == null) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
//                 the snapshot.data object returns the current QuerySnapshot.
//                Contained in the current QuerySnapshot is the data in our
//                collections, ie the messages

          List<DocumentSnapshot> firebaseSnapshots = snapshot.data.documents;
//                  firebaseSnapshots returns that list of messages and in the
//                  following for loop we access those individual messages
          for (DocumentSnapshot documentSnapshot in firebaseSnapshots) {
//                    we get the messageText and sender from the message
            String messageText = documentSnapshot.data['message'];
            String messageSender = documentSnapshot.data['sender'];
            bool isMe = _user.email == messageSender;
            textMessages.add(MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: isMe,
            ));
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.all(10.0),
              children: textMessages,
            ),
          );
        }
      },
    );
  }
}
