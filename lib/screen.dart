/*import 'package:flutter/material.dart';

class DocumentListScreen extends StatefulWidget {
  @override
  _DocumentListScreenState createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список документів'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: documents.length,
          itemBuilder: (BuildContext context, int index) {
            final document = documents[index];
            return ListTile(
              title: Text(document.title),
              subtitle: Text(document.description),
              trailing: Text(document.date.toString()),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DocumentDetailsScreen(document: document),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentEditScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}*/