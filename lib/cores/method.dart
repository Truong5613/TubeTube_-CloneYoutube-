// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tubetube/features/upload/long_video/video_details_page.dart';
import 'package:tubetube/features/upload/short_video/short_video_screen_edit.dart';

void showErrorSnackBar(String message, BuildContext context, {int seconds = 2}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: seconds),
    ),
  );
}
Future pickVideo(BuildContext context) async {
  try {
    XFile? file = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (file == null) {
      showErrorSnackBar('No video selected', context);
      return;
    }

    File video = File(file.path);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoDetailsPage(video: video),
      ),
    );
  } catch (e) {
    showErrorSnackBar('Failed to pick video: $e', context);
  }
}
Future<String> putFileInStorage(File? file, String number, String fileType) async {
  final ref = FirebaseStorage.instance.ref().child("$fileType/$number");

  try {
    // Add metadata to avoid null issues
    final metadata = SettableMetadata(
      cacheControl: 'public, max-age=3600', // Example: Set cache control
      contentType: fileType == "video" ? "video/mp4" : "image/jpeg", // Specify content type
    );

    final upload = ref.putFile(file!, metadata);
    final snapshot = await upload.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print('Error uploading file: $e');
    throw Exception('Failed to upload file');
  }
}

Future<File?> pickImage() async {
  try {
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (file == null) return null;

    return File(file.path);
  } catch (e) {
    throw Exception("Failed to pick image: $e");
  }
}
Future pickShortVideo(BuildContext context) async {
  try {
    XFile? file = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (file == null) {
      showErrorSnackBar('No video selected', context);
      return;
    }

    File video = File(file.path);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShortVideoScreen(shortVideo: video,),
      ),
    );
  } catch (e) {
    showErrorSnackBar('Failed to pick video: $e', context);
  }
}
Future<void> deleteFileInStorage(String number, String fileType) async {
  final ref = FirebaseStorage.instance.ref().child("$fileType/$number");

  try {
    // Delete the file from storage
    await ref.delete();
    print('File deleted successfully');
  } catch (e) {
    print('Error deleting file: $e');
    throw Exception('Failed to delete file');
  }
}
Future<void> deleteFileFromUrl(String url) async {
  try {
    // Extract the file path from the URL
    final Uri uri = Uri.parse(url);
    final String filePath = Uri.decodeFull(uri.pathSegments.last);

    // Get a reference to the file in Firebase Storage
    final ref = FirebaseStorage.instance.ref().child(filePath);

    // Delete the file from Firebase Storage
    await ref.delete();
    print('File deleted successfully');
  } catch (e) {
    print('Error deleting file: $e');
    throw Exception('Failed to delete file');
  }
}