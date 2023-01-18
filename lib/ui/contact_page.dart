import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact? editedContact;
  bool userEdited = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if(widget.contact == null){
      editedContact = Contact();
    } else {
      editedContact = Contact.fromMap(widget.contact!.toMap());

      nameController.text = editedContact!.name!;
      emailController.text = editedContact!.email!;
      phoneController.text = editedContact!.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    return WillPopScope(
      onWillPop: requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(
            editedContact?.name ?? 'Novo contato'
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: (){
            if(editedContact?.name != null && editedContact!.name!.isNotEmpty){
              Navigator.pop(context, editedContact);
            } else {
              FocusScope.of(context).requestFocus(nameFocus);
            }
          },
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: editedContact!.img != null ?
                          FileImage(File(editedContact!.img!)) :
                          const AssetImage('assets/images/contact.png') as ImageProvider
                      )
                  ),
                ),
                onTap: () {
                  picker.getImage(source: ImageSource.camera).then((file){
                    if(file == null){
                      return;
                    } else{
                      setState(() {
                        editedContact!.img = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                focusNode: nameFocus,
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (text){
                  userEdited = true;
                  setState(() {
                    editedContact!.name = text;
                  });
                },
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                onChanged: (text){
                  userEdited = true;
                  editedContact!.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                onChanged: (text){
                  userEdited = true;
                  editedContact!.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> requestPop() async{
    if(userEdited){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text('Descartar alterações?'),
            content: const Text('Ao sair as alterações serão perdidas.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Sim'),
              ),
            ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
