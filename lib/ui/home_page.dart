import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Meus Contatos'),
          backgroundColor: Colors.red,
          centerTitle: true,
          actions: [IconButton(icon: Icon(Icons.ac_unit), onPressed: () {})],
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showContactPage();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.red),
        body: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _contactCard(context, index);
            }));
  }

  _getAllContacts() {
    this.helper.getAllContacts().then((value) => {
          setState(() {
            contacts = value;
          })
        });
  }

  _contactCard(BuildContext context, int index) {
    return GestureDetector(
        onTap: () {
          _showOptions(context, index);
        },
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(children: [
                  Container(
                      height: 140.0,
                      width: 140.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: contacts[index].img != null
                                  ? FileImage(File(contacts[index].img))
                                  : AssetImage('images/person.jpg')))),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(contacts[index].name ?? '',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          Text(contacts[index].phone ?? '',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black)),
                          Text(contacts[index].email ?? '',
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black)),
                        ]),
                  )
                ]))));
  }

  void _showContactPage({Contact contact}) async {
    print(contact);
    final contatoRetornado = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    if (contatoRetornado != null) {
      if (contact != null) {
        await helper.updateContact(contatoRetornado);
      } else {
        await helper.saveContact(contatoRetornado);
      }
      await _getAllContacts();
    }
  }

  _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                              onPressed: () {
                                launch("tel:${contacts[index].phone}");
                                Navigator.pop(context);
                              },
                              child: Text('Ligar',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 18.0))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showContactPage(contact: contacts[index]);
                              },
                              child: Text('Editar',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 18.0))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FlatButton(
                              onPressed: () {
                                helper.deleteContact(contacts[index].id);
                                setState(() {
                                  contacts.removeAt(index);
                                  Navigator.pop(context);
                                });
                              },
                              child: Text('Excluir',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 18.0))),
                        ),
                      ],
                    ));
              });
        });
  }
}
