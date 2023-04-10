part of 'photo_bloc.dart';

class PhotoState extends Equatable {
  const PhotoState({
    this.status = PhotoStatus.initial,
    this.photos = const <Photo>[],
    this.hasReachedMax = false,
    this.pageNumber = 0,
  });

  final PhotoStatus status;
  final bool hasReachedMax;
  final List<Photo> photos;
  final int pageNumber;

  PhotoState copyWith({
    PhotoStatus? status,
    List<Photo>? photos,
    bool? hasReachedMax,
    int? pageNumber,
  }) {
    return PhotoState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${photos.length} }''';
  }

  @override
  List<Object> get props => [status, photos, hasReachedMax];
}
