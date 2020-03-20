import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AFE Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AFE Flutter Module'),
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

  //variables

  int _result = 0;

  int _first = 0;
  int _second = 0;

  String resultStr = "";

  //creating the platForm channel
  static const platForm = const MethodChannel('com.aravnd.in/data');

  _MyHomePageState() {
    platForm.setMethodCallHandler(_receiveFromHost);
  }

  //create a method to receive the information from the native android app
  Future<void> _receiveFromHost(MethodCall call) async {
    int f = 0;
    int s = 0;

    try {
      print(call.method);

      if (call.method == "fromHostToClient") {
        final String data = call.arguments;
        print(call.arguments);
        final jData = jsonDecode(data);

        f = jData['first'];
        s = jData['second'];
      }
    } on PlatformException catch (e) {
      //platform may not able to send proper data.
    }

    setState(() {
      _first = f;
      _second = s;
    });
  }

  String dropdownValue = 'Add';

  _addNumbers(int n1, int n2) {
    return n1 + n2;
  }

  _multiplyNumbers(int n1, int n2) {
    return n1 * n2;
  }

  _setResults(int n1, int n2) {
    setState(() {
      if (dropdownValue == 'Add') {
       _result = _addNumbers(n1, n2);
      } else {
        _result = _multiplyNumbers(n1, n2);
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Center(child: Text(widget.title)),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('First Number: ',
                            style:
                            TextStyle(color: Colors.black, fontSize: 16)),
                        Text('$_first',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ])),
              Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Second Number: ',
                            style:
                            TextStyle(color: Colors.black, fontSize: 16)),
                        Text('$_second',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ])),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<String>(
                        value: dropdownValue,
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                        items: <String>['Add', 'Multiply']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                          });
                        },
                      )
                    ],
                  )),
              RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                ),
                onPressed: () {
                  _setResults(10, 20);
                  _sendResultsToAndroidiOS();
                   Future.delayed(Duration(milliseconds: 300),(){
                     resultStr = '0';
                     SystemNavigator.pop();
                   });
                },
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                child: Container(
                    decoration: BoxDecoration(color: Colors.blue,
                    borderRadius: BorderRadius.circular(20.0)),
                    padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 10.0),
                    child: const Text('Send Results to Android/iOS module',
                        style: TextStyle(fontSize: 16))),
              ),
              Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'Result: $resultStr',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ))
            ],
          ),
        ));
  }

  void _sendResultsToAndroidiOS() {
    if (dropdownValue == 'Add') {
      _result = _addNumbers(_first, _second);
    } else {
      _result = _multiplyNumbers(_first, _second);
    }

    Map<String, dynamic> resultMap = Map();
    resultMap['operation'] = dropdownValue;
    resultMap['result'] = _result;

    setState(() {
      resultStr = resultMap.toString();
    });

    platForm.invokeMethod("FromClientToHost", resultMap);
  }
}