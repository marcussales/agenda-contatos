import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;
  var _userEdited = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _phoneController.text = _editedContact.phone;
      _emailController.text = _editedContact.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.red,
                title: Text(_editedContact.name ?? "Novo Contato"),
                centerTitle: true),
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(Icons.save),
                onPressed: () {
                  if (_editedContact.name != null &&
                      _editedContact.name.isNotEmpty) {
                    Navigator.pop(context, _editedContact);
                  } else {
                    FocusScope.of(context).requestFocus(_nameFocus);
                  }
                }),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        child: Container(
                      height: 140.0,
                      width: 140.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: _editedContact.img != null
                                  ? FileImage(File(_editedContact.img))
                                  : AssetImage('images/person.jpg'))),
                    ),
                    onTap: () {
                        ImagePicker.pickImage(source: ImageSource.camera).then((file) {
                          if(file == null) return;
                          setState(() {
                            _editedContact.img = file.path;
                          });
                        });
                    }
                    ),
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      decoration: InputDecoration(labelText: "Nome"),
                      onChanged: (value) {
                        setState(() {
                          _editedContact.name = value;
                          _userEdited = true;
                        });
                      },
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      onChanged: (value) {
                        _editedContact.email = value;
                        _userEdited = true;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: "Telefone"),
                      onChanged: (value) {
                        _editedContact.phone = value;
                        _userEdited = true;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ))));
  }

  Future<bool> _requestPop() {
    if(_userEdited) {
      showDialog(context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text('Deseja descartar as alterações?'),
          content: Text('Ao sair as alterações serão perdidas'),
          actions: [
            FlatButton(onPressed: () { Navigator.pop(context); }, child: Text('Cancelar')),
            FlatButton(
              onPressed: () { 
                  Navigator.pop(context); 
                  Navigator.pop(context);
              }, child: Text('Sim')),
          ],
        );  
      }
      );
      return Future.value(false);
    }
    else {
      return Future.value(true);
    }
  }
}
