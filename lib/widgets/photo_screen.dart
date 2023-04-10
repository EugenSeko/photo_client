import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoScreen extends StatelessWidget {
  final String imageUrl;

  const PhotoScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black,
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: PhotoViewComputedScale.contained,
          ),
        ),
      ),
    );
  }
}
