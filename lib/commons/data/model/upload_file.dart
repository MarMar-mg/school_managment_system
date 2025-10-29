import 'package:equatable/equatable.dart';
import 'package:school_managment_system/applications/get_url_from_image_name.dart';
import 'package:school_managment_system/commons/data/model/json_parser.dart';

enum FileType { audio, video, avatar }

class UploadFile extends Equatable {
  final String id;
  final String name;
  final FileType fileType;

  const UploadFile({
    required this.id,
    required this.name,
    required this.fileType,
  });

  String get url {
    switch (fileType) {
      case FileType.audio:
        return getUrlFromAudioName(name);
      case FileType.video:
        return getUrlFromVideoName(name);
      case FileType.avatar:
        return getUrlFromImageName(name);
    }
  }

  static UploadFile? parseUploadFile(Map<String, dynamic> json, String name, FileType fileType) {
    if (JsonParser.stringParser(json, [name]).length < 50) {
      return null;
    }
    return UploadFile(
      id: JsonParser.stringParser(json, [name, '_id']),
      name: JsonParser.stringParser(json, [name, 'name']),
      fileType: fileType,
    );
  }

  @override
  List<Object> get props => [id];
}
