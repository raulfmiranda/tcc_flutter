import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  
  final _title = "TCC Flutter";
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: _title,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: _title),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title});

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File picture;

  Future _takePicture() async {
    var tempPicture = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      picture = tempPicture; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            picture == null ? Text('Take a picture.') : _uploadWidget(),
            RaisedButton(
              child: Text('Take Picture'),
              onPressed: () {
                _takePicture();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(picture, height: 300.0, width: 300.0),
        ],
      ),
    );
  }
}
