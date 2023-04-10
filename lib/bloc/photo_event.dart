part of 'photo_bloc.dart';

abstract class PhotoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PhotoFetched extends PhotoEvent {}

class PhotoSearched extends PhotoEvent {
  PhotoSearched(this.query);
  final String? query;
}
