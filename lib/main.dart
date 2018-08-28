import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mlkit/mlkit.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/services.dart';
import 'package:flutter_mlkit_sample/registration.dart';

Future<Null> main() async {
  runApp(new MyApp());
}
//void main() => runApp(new MyApp());

// ログイン.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'HealtheeOne',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LoginPage(title: 'HealtheeOne'),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new SafeArea(
          top: false,
          bottom: false,
          child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.local_hospital),
                      hintText: 'Enter hotpital name',
                      labelText: 'Hotpital',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: 'Enter your user name',
                      labelText: 'User',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.vpn_key),
                      hintText: 'Enter your password',
                      labelText: 'Password',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                  ),
                  new Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                      child: new RaisedButton(
                        child: const Text('Login'),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              new MaterialPageRoute(
                                  settings: const RouteSettings(name: "/home"),
                                  builder: (BuildContext context) =>
                                      _MyHomePage()));
//                          Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) =>
//                                    MaterialApp(home: _MyHomePage())),
//                          );
                        },
                      )),
                ],
              ))),
    );
  }
}

// OCR.
class _MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  File _imageFile;
  Size _imageSize;
  List<dynamic> _scanResults;
  final result_list = List<String>();

  Future<void> _getAndScanImage() async {
    setState(() {
      _imageFile = null;
      _imageSize = null;
    });

    final File imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _getImageSize(imageFile);
      _scanImage(imageFile);
    }

    setState(() {
      _imageFile = imageFile;
      result_list.clear();
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = new Completer<Size>();

    final Image image = new Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      (ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      },
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });

    try {
      FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;
      var results =
          await detector.detectFromBinary(imageFile.readAsBytesSync());

//    final FirebaseVisionImage visionImage =
//        FirebaseVisionImage.fromFile(imageFile);
//
//    FirebaseVisionDetector detector = FirebaseVision.instance.textDetector();
//    final List<dynamic> results =
//        await detector.detectInImage(visionImage) ?? <dynamic>[];

      setState(() {
        _scanResults = results;
        print('_scanImage:${results.length}');
      });
    } catch (e) {
      print('_scanImage:error:${e.toString()}');
    }
  }

  _buildResults(Size imageSize, List<dynamic> results) {
//    CustomPainter painter;
    print('_buildResults[in]');

    if (result_list.isEmpty) {
      for (VisionText block in results) {
        result_list.add(block.text);
      }

      _showDialog();
    }
    return Center();
  }

  Widget _buildImage() {
    return new Container(
      constraints: const BoxConstraints.expand(),
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: Image.file(_imageFile).image,
          fit: BoxFit.fill,
        ),
      ),
      child: _imageSize == null || _scanResults == null
          ? const Center(
              child: const Text(
                'Scanning...',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : _buildResults(_imageSize, _scanResults),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('HealtheeOne'),
//          actions: _scanResults != null && _scanResults.isNotEmpty
//              ? <Widget>[
//                  IconButton(
//                      icon: const Icon(Icons.arrow_forward), onPressed: () {})
//                ]
//              : null
      ),
      body: _imageFile == null
          ? const Center(child: const Text('No image selected.'))
          : _buildImage(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _getAndScanImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Future<Null> _showDialog() async {
    if (result_list.isEmpty) return;

    var list = List<Widget>();
    result_list.forEach((value) => list.add(createOption(value)));
    print('_askedToLead:${list.length}');

    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
              title: RaisedButton(
                child: const Text('進む'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  Navigator.push(
                      context,
                      new MaterialPageRoute<Null>(
//                settings: const RouteSettings(name: "/detail"),
                          builder: (BuildContext context) =>
                              ResultPage(result_list)));
//                  Navigator.of(context).pop(true);
                },
              ),
              children: list);
        })) {
//      case Department.treasury:
//      // Let's go.
//      // ...
//        break;
//      case Department.state:
//      // ...
//        break;
    }
  }

  SimpleDialogOption createOption(String item) {
    return SimpleDialogOption(
      child: Text(item),
    );
  }
}
