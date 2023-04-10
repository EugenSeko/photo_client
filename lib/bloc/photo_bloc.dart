import 'dart:async';

import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../api/unsplash_api_service.dart';
import '../models/photo.dart';
import '../utils/enum.dart';

part 'photo_event.dart';
part 'photo_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  PhotoBloc({required this.apiService}) : super(const PhotoState()) {
    on<PhotoFetched>(_onPhotoFeatchedEvent,
        transformer: throttleDroppable(throttleDuration));
    on<PhotoSearched>(_onPhotoSearchedEvent,
        transformer: throttleDroppable(throttleDuration));
  }
  final UnsplashApiService apiService;

  Future<void> _onPhotoSearchedEvent(
      PhotoSearched event, Emitter<PhotoState> emit) async {
    state.photos.clear();
    final photos = await _fetchPhotos(query: event.query);
    return emit(state.copyWith(
      status: PhotoStatus.success,
      photos: photos,
      hasReachedMax: false,
      pageNumber: _pageNumber,
    ));
  }

  FutureOr<void> _onPhotoFeatchedEvent(
      PhotoFetched event, Emitter<PhotoState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PhotoStatus.initial) {
        final photos = await _fetchPhotos();
        return emit(state.copyWith(
          status: PhotoStatus.success,
          photos: photos,
          hasReachedMax: false,
          pageNumber: _pageNumber,
        ));
      }
      final photos = await _fetchPhotos();
      emit(photos.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: PhotoStatus.success,
              photos: List.of(state.photos)..addAll(photos),
              hasReachedMax: false,
              pageNumber: _pageNumber,
            ));
    } catch (_) {
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }

  int _pageNumber = 0;

  Future<List<Photo>> _fetchPhotos({String? query}) async {
    _pageNumber++;
    return await apiService.getPhotos(
      query: query,
      page: _pageNumber,
      perPage: 20,
    );
  }
}
