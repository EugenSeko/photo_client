import 'dart:async';

import 'package:proto_client/main.dart';
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
  String? query;

  Future<void> _onPhotoSearchedEvent(
      PhotoSearched event, Emitter<PhotoState> emit) async {
    try {
      if (event.query != null) {
        query = event.query;
        if (state.photos.isNotEmpty) {
          state.photos.clear();
        }
        final photos = await _fetchPhotos(query: query);
        return emit(state.copyWith(
          searchStatus: SearchStatus.success,
          photos: photos,
          hasReachedMax: false,
          isSearch: true,
        ));
      }

      if (state.hasReachedMax) return;

      final photos = await _fetchPhotos(query: query);
      emit(photos.isEmpty
          ? state.copyWith(
              hasReachedMax: true,
            )
          : state.copyWith(
              photos: List.of(state.photos)..addAll(photos),
            ));
    } catch (_) {
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }

  FutureOr<void> _onPhotoFeatchedEvent(
      PhotoFetched event, Emitter<PhotoState> emit) async {
    try {
      if (state.status == PhotoStatus.initial) {
        final photos = await _fetchPhotos();
        return emit(state.copyWith(
          status: PhotoStatus.success,
          photos: photos,
          hasReachedMax: false,
        ));
      }
      if (state.hasReachedMax) return;

      final photos = await _fetchPhotos();
      emit(photos.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: PhotoStatus.success,
              photos: List.of(state.photos)..addAll(photos),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: PhotoStatus.failure));
    }
  }

  int _pageNumber = 0;
  int _searchPageNumber = 0;

  Future<List<Photo>> _fetchPhotos({String? query}) async {
    _pageNumber++;
    if (query == null) {
      _pageNumber++;
      return await apiService.getPhotos(
        page: _pageNumber,
        perPage: 20,
      );
    }
    _searchPageNumber++;
    return await apiService.searchPhotos(
      query: query,
      page: _pageNumber,
      perPage: 20,
    );
  }
}
