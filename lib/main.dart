import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as I;
import 'dart:ui';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as IP;
import 'package:firebase_storage/firebase_storage.dart';

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
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File _picture;
  var _isInProgress = false;
  var _toApplyFilter = false;

  Future _takePicture() async {
    var tempPicture = await IP.ImagePicker.pickImage(source: IP.ImageSource.camera);

    setState(() {
      _picture = tempPicture; 
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
            _picture == null ? Text('Take a picture.') : _uploadFilterWidget(),
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

  Widget _uploadFilterWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('Upload Picture'),
            onPressed: () {
              
              setState(() {
                _isInProgress = true;                
              });

              final filename = basename(_picture.path);
              final StorageReference storageReference = FirebaseStorage.instance.ref().child('$filename');
              final StorageUploadTask task = storageReference.putFile(_picture);
              final Future<StorageTaskSnapshot> storageTaskSnapshot = task.onComplete;
              
              storageTaskSnapshot.whenComplete(() {
                _picture.delete();
                setState(() {
                  _isInProgress = false;
                });
                setState(() {
                  _picture = null;
                });
              });
            },
          ),
          _buildImage(applyFilter: _toApplyFilter),
          _isInProgress ? const CircularProgressIndicator() : 
          RaisedButton(
            child: Text('Apply Filter'),
            onPressed: () {
              setState(() {
                _isInProgress = true;
              });
              setState(() {
                _toApplyFilter = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Image _buildImage({bool applyFilter = false}) {
     
    if(applyFilter) {
      var img = I.decodeImage(_picture.readAsBytesSync());
      var imgGray = I.grayscale(img);
      var png = I.encodePng(imgGray);

      setState(() {
        _isInProgress = false;
        _picture.writeAsBytes(png);
      });

      return Image.memory(png, height: 300.0, width: 300.0);
    }
    return Image.file(_picture, height: 300.0, width: 300.0);
  }

}
