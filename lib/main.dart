import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import './home.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consultas Medicas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Registrar Consulta Medica'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Registra tu Consulta medica ",
                  style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 30,
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic)),
              RegisterPet(),
            ]),
      )),
    );
  }
}

class RegisterPet extends StatefulWidget {
  RegisterPet({Key key}) : super(key: key);

  @override
  _RegisterPetState createState() => _RegisterPetState();
}

class _RegisterPetState extends State<RegisterPet> {
  final _formKey = GlobalKey<FormState>();
  final listOfConsultas = ["Medicina General", "Medicina Especializada", "Ortodoncia"];
  String dropdownValue = 'Medicina General';
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  
  final dbRef = FirebaseDatabase.instance.reference().child("Consulta_medica");

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(children: <Widget>[
          _textFormField(
            "nombre" , 
            nameController , 
            TextInputType.name,
            (String value){
              if (value.isEmpty) return 'Ingrese el nombre';
              return null;
            }
          ),
          _textFormField(
            "edad" , 
            ageController , 
            TextInputType.number,
            (String value){
              if (value.isEmpty) return 'Ingrese la edad';
              return null;
            }
          ),
          _textFormField(
            "correo" , 
            emailController , 
            TextInputType.emailAddress,
            (String value){
              Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regExp = new RegExp(pattern);
              if ( regExp.hasMatch(value)  ) return null;
              return 'Email no válido';
            }
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: DropdownButtonFormField(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              decoration: InputDecoration(
                labelText: "Tipo",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              items: listOfConsultas.map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              validator: (value) {
                if (value.isEmpty) {
                  return 'Seleccione el tipo';
                }
                return null;
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        dbRef.push().set({
                          "nombre": nameController.text,
                          "edad": ageController.text,
                          "email": emailController.text,
                          "type": dropdownValue
                        }).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Consulta Medica agregada con exito')));
                          ageController.clear();
                          nameController.clear();
                          emailController.clear();
                        }).catchError((onError) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(onError)));
                        });
                      }
                    },

                    child: Text('Agregar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.amber),
                    //color: Colors.amber,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Home(title: "Pagina principal")),
                      );
                    },
                    child: Text('Listar'),
                  ),
                ],
              )),
        ])));
  }

  Widget _textFormField( labelText, controller ,  keyboardType, callback ){
          return Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                keyboardType: keyboardType,
                controller: controller,
                decoration: InputDecoration(
                  labelText: labelText,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: callback,
              ),
            );
    }

  @override
  void dispose() {
    super.dispose();
    ageController.dispose();
    nameController.dispose();
    emailController.dispose();
  }
}
