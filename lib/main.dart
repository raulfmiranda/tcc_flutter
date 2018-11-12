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
  Image _imageFromPic;
  var _uploadButtonName = "UPLOAD PICTURE";
  var _isInProgress = false;

  Future _takePicture() async {
    var tempPicture = await IP.ImagePicker.pickImage(source: IP.ImageSource.camera);

    setState(() {
      _picture = tempPicture; 
      _imageFromPic = Image.file(_picture, height: 300.0, width: 300.0, gaplessPlayback: false);
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
            _picture == null ? Container() : _uploadFilterWidget(),
            RaisedButton(
              child: Text('TAKE PICTURE'),
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
            child: Text("$_uploadButtonName"),
            onPressed: () {
              
              setState(() {
                _isInProgress = true;                
              });

              final filename = basename(_picture.path);
              final StorageReference storageReference = FirebaseStorage.instance.ref().child('$filename');
              final StorageUploadTask task = storageReference.putFile(_picture);
              final Future<StorageTaskSnapshot> storageTaskSnapshot = task.onComplete;
              
              storageTaskSnapshot.whenComplete(() {
                // _picture.delete();
                setState(() {
                  _isInProgress = false;
                  _uploadButtonName = "PICTURE SENT";
                  // _picture = null;
                });
              });
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _imageFromPic,
              _isInProgress ? CircularProgressIndicator() : Container(),
            ],
          ),          
          RaisedButton(
            child: Text('APPLY FILTER'),
            onPressed: () {
              setState(() {
                _isInProgress = true;
              });
              _applyFilter();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _applyFilter() async {
    var img = await new Future(() => I.decodeImage(_picture.readAsBytesSync()));
    var imgGray = await new Future(() => I.grayscale(img));
    var png = await new Future(() => I.encodePng(imgGray));

    setState(() {
      _isInProgress = false;
      _imageFromPic = Image.memory(png, height: 300.0, width: 300.0, gaplessPlayback: false); 
    });

    _picture.writeAsBytes(png);
  }

}