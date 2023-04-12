part of 'photo_bloc.dart';

class PhotoState extends Equatable {
  const PhotoState({
    this.status = PhotoStatus.initial,
    this.searchStatus = SearchStatus.initial,
    this.photos = const <Photo>[],
    this.searchPages = const <PhotosPage>[],
    this.feedPages = const <PhotosPage>[],
    this.hasReachedMax = false,
    this.isSearch = false,
  });

  final PhotoStatus status;
  final SearchStatus searchStatus;
  final bool hasReachedMax;
  final bool isSearch;
  final List<Photo> photos;
  final List<PhotosPage> searchPages;
  final List<PhotosPage> feedPages;

  PhotoState copyWith({
    PhotoStatus? status,
    SearchStatus? searchStatus,
    List<Photo>? photos,
    bool? hasReachedMax,
    bool? isSearch,
    List<PhotosPage>? searchPages,
    List<PhotosPage>? feedPages,
  }) {
    return PhotoState(
      status: status ?? this.status,
      searchStatus: searchStatus ?? this.searchStatus,
      photos: photos ?? this.photos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isSearch: isSearch ?? this.isSearch,
      searchPages: searchPages ?? this.searchPages,
      feedPages: feedPages ?? this.feedPages,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${photos.length} }''';
  }

  @override
  List<Object> get props => [
        status,
        searchStatus,
        photos,
        hasReachedMax,
        searchPages,
        feedPages,
        isSearch,
      ];
}
