import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Shopping List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textEditingController = TextEditingController();
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: _getAppbarActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream:
                  Firestore.instance.collection('shopping_list').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LinearProgressIndicator();
                }

                String content =
                    (snapshot.data.documents.last['content'] as String)
                        .replaceAll("\\n", "\n");

                return Expanded(
                  child: _getContent(content),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getAppbarActions() {
    if (isEdit) {
      return [
        FlatButton(
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              isEdit = !isEdit;
              _updateContent();
            });
          },
          child: Text("UPDATE"),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        )
      ];
    } else {
      return [
        FlatButton(
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              isEdit = !isEdit;
            });
          },
          child: Text("EDIT"),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        )
      ];
    }
  }

  Widget _getContent(String content) {
    if (isEdit) {
      textEditingController.text = content;
      return TextField(
        controller: textEditingController,
        maxLines: 999,
      );
    } else {
      return ListView(
        children: <Widget>[
          Text(
            content,
          ),
        ],
      );
    }
  }

  void _updateContent() {
    final DocumentReference postRef =
        Firestore.instance.document('shopping_list/Kv8FxV5BKKPKuPZgnFgL');
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(postRef);
      if (postSnapshot.exists) {
        await tx.update(
            postRef, <String, dynamic>{'content': textEditingController.text});
      }
    });
  }
}
