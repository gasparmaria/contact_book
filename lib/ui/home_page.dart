import 'dart:io';
import 'package:contact_book/helpers/contact_helper.dart';
import 'package:contact_book/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderaz,
                child: Text('Ordenar A-Z'),
              ),
              const PopupMenuItem<OrderOptions>(
                value: OrderOptions.orderza,
                child: Text('Ordenar Z-A'),
              ),
            ],
            onSelected: orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showContactPage();
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: contacts.length,
        itemBuilder: (context, index){
          return contactCard(context, index);
        }
      ),
    );
  }

  Widget contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ?
                          FileImage(File(contacts[index].img!)) :
                          const AssetImage('assets/images/contact.png') as ImageProvider
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts[index].email!,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      contacts[index].phone!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: (){
        showOptions(context, index);
      },
    );
  }

  void getAllContacts() {
    helper.getAllContacts().then((list){
      setState((){
        contacts = list;
      });
    });
  }
  
  void showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => ContactPage(contact: contact))
    );

    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }

      getAllContacts();
    }
  }

  void showOptions(BuildContext context, int index){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextButton(
                      onPressed: contacts[index].phone == null ? null : (){
                        launch('tel:${contacts[index].phone}');
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Ligar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                        showContactPage(contact: contacts[index]);
                      },
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextButton(
                      onPressed: (){
                        helper.deleteContact(contacts[index].id!);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                      child: const Text(
                        'Excluir',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                        ),
                      )
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a, b){
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b){
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }

    setState((){});
  }
}
