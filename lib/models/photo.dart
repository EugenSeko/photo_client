import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  const Photo({required this.id, required this.user, required this.urls});

  final String id;
  final Map user;
  final Map urls;

  @override
  List<Object> get props => [id, user, urls];
}
