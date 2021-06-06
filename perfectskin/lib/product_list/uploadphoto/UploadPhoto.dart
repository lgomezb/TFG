import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:perfectskin/utils/Size_config.dart';
import './UPWidget.dart';
import 'package:perfectskin/utils/MyLocalizationsDelegate.dart';

// ignore: must_be_immutable
class ImageCapture extends StatefulWidget {
  final String name;

  ImageCapture({Key key, this.name}) : super(key: key);

  createState() =>
      _ImageCaptureState(name: this.name);
}

class _ImageCaptureState extends State<ImageCapture> {
  File _imageFile;
  String name;
  File _nonEditImage;

  _ImageCaptureState({Key key, this.name});
  final picker = ImagePicker();

  void initState() {
    super.initState();
    _pickImage(ImageSource.gallery);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
      _nonEditImage = selected;
    });
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio16x9,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: MyLocalizations.of(context).getText('resizephoto'),
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        sourcePath: _nonEditImage.path);
    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void _clear() {
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Select an image from the camera or gallery
      appBar: AppBar(
        title: Text(MyLocalizations.of(context).getText('editphoto')),
        backgroundColor: Colors.green,
      ),
      // Preview the image and crop it
      body: ListView(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                color: Colors.blue,
                child: Row(children: <Widget>[
                  Icon(Icons.photo_camera),
                  Text(MyLocalizations.of(context).getText('selectphoto'))
                ]),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
          if (_imageFile != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  color: Colors.green,
                  child: Row(children: <Widget>[
                    Icon(Icons.crop),
                    Text(MyLocalizations.of(context).getText('readjust'))
                  ]),
                  onPressed: _cropImage,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.05),
                ),
                FlatButton(
                  color: Colors.red,
                  child: Row(children: <Widget>[
                    Icon(Icons.crop),
                    Text(MyLocalizations.of(context).getText('deletephoto'))
                  ]),
                  onPressed: _clear,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.015),
            ),
            new InkWell(
              onTap: () {},
              radius: 10.0,
              splashColor: Colors.yellow,
              child: Center(
                child: new Text(
                  MyLocalizations.of(context).getText('preview'),
                  style: new TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.015),
            ),
            new Container(
                alignment: Alignment.center,
                width: getProportionateScreenWidth(167),
                child: new SizedBox(
                    width: getProportionateScreenWidth(167),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: getProportionateScreenWidth(167),
                              child: AspectRatio(
                                aspectRatio: 1.39,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      image: DecorationImage(
                                          image: FileImage(_imageFile),
                                          fit: BoxFit.cover)),
                                ),
                              ),
                            ),
                            Container(
                              width: getProportionateScreenWidth(167),
                              padding: EdgeInsets.only(
                                top: getProportionateScreenWidth(20),
                                bottom: getProportionateScreenWidth(20),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(5, 5),
                                    blurRadius: 10,
                                    color: Color(0xFFE9E9E9).withOpacity(0.56),
                                  )
                                ],
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.042,
                                    ),
                                  ),
                                  VerticalSpacing(of: 10),
                                  Text(
                                      '0' +
                                          MyLocalizations.of(context)
                                              .getText('items'),
                                      style: TextStyle(
                                          fontSize:
                                              getProportionateScreenWidth(11))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: getProportionateScreenHeight(14),
                              right: getProportionateScreenWidth(14)),
                          alignment: Alignment.topRight,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Container(
                              width: 20.0,
                              height: 20.0,
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(width: 1.0)),
                                child: Container(
                                  padding: const EdgeInsets.all(0.0),
                                  child: new Divider(),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ))),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width * 0.02),
            ),
            Uploader(
                file: _imageFile, nombre: name),
          ]
        ],
      ),
    );
  }
}
