import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadBytes(Uint8List bytes, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putData(bytes);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }

  Future<String> getDownloadURL(String path) async {
    return await _storage.ref().child(path).getDownloadURL();
  }
}
