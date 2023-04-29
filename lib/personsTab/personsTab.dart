import 'package:flutter/material.dart';


/* Classes for user's interface */
class PersonsTab extends StatefulWidget {
  Map<String, String?> userData;
  
  PersonsTab(this.userData, {Key? key}) : super(key: key);

  @override
  _PersonsTabState createState() => _PersonsTabState();
}


class _PersonsTabState extends State<PersonsTab> {
  late Map<String, String?> user; // Has user account data

  @override
  void initState() {
    super.initState();
    user = widget.userData;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          title: const Text('Мій акаунт'),
          backgroundColor: const Color.fromARGB(255, 40, 40, 40),
          automaticallyImplyLeading: false,
          actions: [
            CircleAvatar(
              backgroundImage: Image.network(widget.userData['avatar'] ?? '').image,
              radius: 18,
            ),

            const SizedBox(width: 15),
          ],
        ),

        body: ExpansionTile(
          backgroundColor: const Color.fromARGB(70, 144, 144, 144),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          expandedAlignment: Alignment.centerLeft,
          childrenPadding: const EdgeInsets.fromLTRB(73, 0, 0, 20),
          title: Text(user['name']!),
          subtitle: Text(user['email']!),
          controlAffinity: ListTileControlAffinity.leading,
          children: [
            SelectableText('Id в системі: ${user['id']}'),
          ],
        ),
        
      );
  }
}
