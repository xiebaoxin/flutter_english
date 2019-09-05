import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/DialogUtils.dart';
import '../utils/HttpUtils.dart';

class ImageCropperPage extends StatefulWidget {
  @override
  _ImageCropperPageState createState() => _ImageCropperPageState();
}

class _ImageCropperPageState extends State<ImageCropperPage> {
  final cropKey = GlobalKey<CropState>();
  File _file;
  File _sample;
  File _lastCropped;

  @override
  void dispose() {
    super.dispose();
    _file?.delete();
    _sample?.delete();
    _lastCropped?.delete();
  }

  bool firstLoad = true;

  @override
  void initState() {
    super.initState();
    _openImage().catchError((e) {
      Navigator.of(context).pop(false);
    });
  }


  Widget _buildCroppingImage() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Crop.file(
              _sample,
              key: cropKey,
              aspectRatio: 1,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0),
            alignment: AlignmentDirectional.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    '上传图片',
                    style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
                  ),
                  onPressed: () => _cropImage(),
                ),
                _buildOpenImage(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOpenImage() {
    return FlatButton(
      child: Text(
        '选择图片',
        style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
      ),
      onPressed: () => _openImage(),
    );
  }

  Future<void> _openImage() async {
    final file = await ImagePicker.pickImage(source: ImageSource.gallery);
    final sample = await ImageCrop.sampleImage(
      file: file,
      preferredSize: context.size.longestSide.ceil(),
    );

    _sample?.delete();
    _file?.delete();

    setState(() {
      _sample = sample;
      _file = file;
    });
  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) return;

    final sample = await ImageCrop.sampleImage(
      file: _file,
      preferredSize: (640 / scale).round(),
    );
    print((640 / scale).round());

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    File compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: 100,
        targetWidth: 640,
        targetHeight: 640
    );

    sample.delete();

    _lastCropped?.delete();
    _lastCropped = file;

    uploadImage(compressedFile);
  }



  Future uploadImage(File image) async {
    String path = image.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(new File(path), name,
          contentType: ContentType.parse("image/$suffix"))
    });

    DialogUtils.showToastDialog(context,  '正在更新头像');
        await HttpUtils.dioFormAppi(
    'User/userAvatar',
            formData,
            withToken: true,
            context: context)
            .then((response) {
          if(response["msg"]!=null )
          Navigator.of(context).pop();
          DialogUtils.showToastDialog(context,  response["msg"]);
        });

  }


  Future createForm(File file) async {
    return FormData.from({
      "offset": 0,
      "md5": md5.convert(await file.readAsBytes()),
      "photo": UploadFileInfo(file, path.basename(file.path)),
      "filesize": await file.length(),
      "wizard": 1
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                Expanded(
                    child: Container(
                      child: _sample == null ? Container() : _buildCroppingImage(),
                    )
                ),
              ],
            )
        )
    );
  }
}
