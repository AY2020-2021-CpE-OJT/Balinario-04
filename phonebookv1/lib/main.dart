import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp()); //responsible for running the app

class Todo {
  final String firstName;
  final String lastName;
  final List<dynamic> contactNumbers;

  Todo(this.firstName, this.lastName, this.contactNumbers);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Phonebook';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  //const InputContactForm({Key? key}) : super(key: key);
  @override
  MyCustomFormState createState() => MyCustomFormState();
}

class MyCustomFormState extends State<MyCustomForm> {
  int numberOfContactNumbers = 1;
  List<Todo> todoContacts = <Todo>[];
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  List<TextEditingController> contactNumberControllers =
  <TextEditingController>[TextEditingController()];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Add FirstName
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: TextFormField(
                keyboardType: TextInputType.name,
                controller: firstNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter First Name',
                  prefixIcon: Icon(
                    Icons.account_circle,
                    size: 30,
                  ),
                ),
              ),
            ),
            //Add Last Name
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: TextFormField(
                keyboardType: TextInputType.name,
                controller: lastNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Last Name',
                  prefixIcon: Icon(
                    Icons.account_circle,
                    size: 30,
                  ),
                ),
              ),
            ),
            //Adding the array of contact numbers
            SizedBox(
              child: Text("Contact Number/s: "),
            ),
            SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: numberOfContactNumbers,
                itemBuilder: (context, index) {
                  return TextFormField(
                    controller: contactNumberControllers[index],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Phone Number',
                        prefixIcon: Icon(
                          Icons.art_track_rounded,
                          size: 30,
                        )),
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        numberOfContactNumbers++;
                        contactNumberControllers.insert(
                            0, TextEditingController());
                      });
                    },
                    child: Icon(Icons.person_add)),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (numberOfContactNumbers != 1) {
                          numberOfContactNumbers--;
                        }
                      });
                    },
                    child: Icon(Icons.person_remove)),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                    onPressed: () {
                      List<dynamic> numbers = <dynamic>[];
                      for (int i = 0; i < numberOfContactNumbers; i++) {
                        numbers.insert(0, contactNumberControllers[i].text);
                      }
                      setState(() {
                        todoContacts.insert(
                            0,
                            Todo(firstNameController.text,
                                lastNameController.text, numbers));
                        createContacts(firstNameController.text,
                            lastNameController.text, numbers);
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ContactRoute(
                                    contactsTodo: todoContacts,
                                  )));
                    },

                    child: Text('Add to Contacts')),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ContactRoute(
                                contactsTodo: todoContacts,
                              )));
                },
                child: Text('View Contact List'))
          ],
        ),
      ),
    );
  }
}

// Go to 2nd Screen || List of contacts
class ContactRoute extends StatelessWidget {
  final List<Todo> contactsTodo;

  const ContactRoute({Key? key, required this.contactsTodo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contact List'),
        ),
        body: Center(
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                      itemCount: contactsTodo.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                                '${contactsTodo[index]
                                    .firstName} ${contactsTodo[index].lastName}'),
                            subtitle: Text(
                                '${contactsTodo[index].contactNumbers}'),
                          ),
                        );
                      }),
                ),
                DisplayContacts(),
              ],
            )));
  }
}


//
// fetch the file
//
Future<Album> fetchAlbum(int index) async {
  final response = await http.get(Uri.parse('https://warm-stream-00476.herokuapp.com/data'));

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body)[index]);
  } else {
    throw Exception('Failed to load album');
  }
}

class DisplayContacts extends StatefulWidget {
  const DisplayContacts({Key? key}) : super(key: key);

  @override
  _DisplayContactsState createState() => _DisplayContactsState();
}
//Display Data from database
class _DisplayContactsState extends State<DisplayContacts> {
  List<Future<Album>> contactsFromDatabase = <Future<Album>>[];
  late List<Future<Album>> contactsFromDB;
  late int numberOfDocuments = 0;

  getNumberOfDocuments() async {
    final request =
    await http.get(Uri.parse('https://warm-stream-00476.herokuapp.com/data/total'));
    return request.body;
  }

  @override
  void initState() {
    super.initState();
    getNumberOfDocuments().then((val) {
      setState(() {
        numberOfDocuments = int.parse(val);
        for (int i = 0; i < numberOfDocuments; i++) {
          contactsFromDatabase.insert(i, fetchAlbum(i));
        }
      });
    });
  }
  //
  //for the edit and delete
  //
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
          itemCount: numberOfDocuments,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                // if the container is tapped, the buttom sheet appears and has 2 options, the edit and delete
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Column(
                            children: [
                              FutureBuilder<Album>(
                                  future: contactsFromDatabase[index],
                                  builder: (context, snapshot) =>
                                      TextButton(onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateScreen(id: snapshot
                                                        .data!.id.toString())));
                                      }, child: Text('Edit'))),
                              FutureBuilder<Album>(
                                  future: contactsFromDatabase[index],
                                  builder: (context, snapshot) =>
                                      TextButton(
                                          onPressed: () {
                                            delete(
                                                snapshot.data!.id.toString());
                                            getNumberOfDocuments().then((val) {
                                              setState(() {
                                                numberOfDocuments =
                                                    int.parse(val);
                                                for (int i = 0;
                                                i < numberOfDocuments;
                                                i++) {
                                                  contactsFromDatabase.insert(
                                                      i, fetchAlbum(i));
                                                }
                                              });
                                            });
                                          },
                                          child: Text('Delete')))
                            ],
                          ),
                        ),
                      );
                    });
              },//Display the data fetched from the internet
              title: FutureBuilder<Album>(
                future: contactsFromDatabase[index],
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Card(
                        child: Container(
                          child: Column(
                            children: [
                              Text('${snapshot.data!.firstName.toString()} ${snapshot.data!
                                    .lastName.toString()}'),
                              Text('${snapshot.data!.phoneNumbers.toString()}')
                            ],
                          ),
                        ),
                      );
                  }
                  return Center(child: CircularProgressIndicator(backgroundColor: Colors.red,strokeWidth: 4));
                },
              ),

            );
          }),
    );
  }
}
class Album {
  final String firstName;
  final String lastName;
  final List<dynamic> phoneNumbers;
  final String id;

  Album({required this.firstName, required this.lastName,
    required this.phoneNumbers, required this.id});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
        id: json['_id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        phoneNumbers: json['phone_numbers']);

  }
}

// post to database
createContacts(String lastName, String firstName,
    List<dynamic> phoneNumbers) async {
  await http.post(Uri.parse('https://warm-stream-00476.herokuapp.com/data'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'phone_numbers': phoneNumbers
      }));
}
Future<http.Response> delete(String _id) async {
  final http.Response response = await http.delete(
    Uri.parse('https://warm-stream-00476.herokuapp.com/data/$_id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  return response;
}
// delete(String _id) async =>
//     await http.delete(Uri.parse('https://warm-stream-00476.herokuapp.com/data/$_id'));
//
// Update function
//
Future<void> updateData(String lastName, String firstName,
    List<dynamic> phoneNumbers, String _id) async {
  await http.put(
      Uri.parse('https://warm-stream-00476.herokuapp.com/data/$_id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<dynamic, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'phone_numbers': phoneNumbers,
      })
  );
}

class UpdateScreen extends StatefulWidget {
  final String id;

  UpdateScreen({Key? key, required this.id}) : super(key: key);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  int numberOfContactNumbers = 1;
  List<Todo> todoContacts = <Todo>[];
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  List<TextEditingController> contactNumberControllers =
  <TextEditingController>[TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Contact'),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //Add FirstName
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: TextField(
              keyboardType: TextInputType.name,
              controller: firstNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter First Name',
                prefixIcon: Icon(
                  Icons.account_circle,
                  size: 30,
                ),
              ),
            ),
          ),
          //Add Last Name
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: TextFormField(
              keyboardType: TextInputType.name,
              controller: lastNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Last Name',
                prefixIcon: Icon(
                  Icons.account_circle,
                  size: 30,
                ),
              ),
            ),
          ),
          //Adding the array of contact numbers
          SizedBox(
            child: Text("Contact Number/s: "),
          ),
          SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: numberOfContactNumbers,
              itemBuilder: (context, index) {
                return TextFormField(
                  controller: contactNumberControllers[index],
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Phone Number',
                      prefixIcon: Icon(
                        Icons.art_track_rounded,
                        size: 30,
                      )),
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      numberOfContactNumbers++;
                      contactNumberControllers.insert(
                          0, TextEditingController());
                    });
                  },
                  child: Icon(Icons.person_add)),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (numberOfContactNumbers != 1) {
                        numberOfContactNumbers--;
                      }
                    });
                  },
                  child: Icon(Icons.person_remove)),
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                  onPressed: () {
                    List<dynamic> numbers = <dynamic>[];
                    for (int i = 0; i < numberOfContactNumbers; i++) {
                      numbers.insert(0, contactNumberControllers[i].text);
                    }
                    setState(() {
                      updateData(firstNameController.text,
                          lastNameController.text, numbers, widget.id);
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Update to Contacts')),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'))
        ],
      ),
    );
  }
}



