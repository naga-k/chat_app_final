import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  const UserImagePicker({Key? key, required this.imagePickFn})
      : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    ImageSource source = ImageSource.gallery;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Center(
          child: Text(
            'Select an image',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              OutlinedButton(
                child: const Text('Take a photo'),
                onPressed: () {
                  source = ImageSource.camera;
                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                child: const Text('Choose from gallery'),
                onPressed: () {
                  source = ImageSource.gallery;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );

    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: source, imageQuality: 50, maxWidth: 150);

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _pickedImage = File(pickedFile.path);
    });

    widget.imagePickFn(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              _pickedImage == null ? null : FileImage(_pickedImage!),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          icon: const Icon(Icons.image),
          onPressed: _pickImage,
          label: const Text("Add image"),
        ),
      ],
    );
  }
}
