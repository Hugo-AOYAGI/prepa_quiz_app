import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';


class SheetMenu extends StatelessWidget {

  final url;

  SheetMenu({@required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoView(
        backgroundDecoration: BoxDecoration(
          color: Colors.white
        ),
        imageProvider: NetworkImage(url),
      )
    );
  }


}