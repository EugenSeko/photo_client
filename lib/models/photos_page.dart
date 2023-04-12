import 'package:equatable/equatable.dart';
import 'package:proto_client/models/photo.dart';

class PhotosPage extends Equatable {
  const PhotosPage({
    required this.pageNumber,
    required this.photos,
    required this.urls,
    required this.photoSize,
    required this.perPage,
  });

  final int pageNumber;
  final List<Photo> photos;
  final Map urls;
  final String photoSize;
  final int perPage;

  List<Photo> get photosBySize {
    List<Photo> filteredPhotos = List.empty();
    for (var element in photos) {
      filteredPhotos.add(Photo(
          id: element.id, user: element.user, urls: element.urls[photoSize]));
    }
    return filteredPhotos;
  }

  @override
  List<Object> get props => [
        pageNumber,
        photos,
        urls,
        photoSize,
        perPage,
      ];
}
