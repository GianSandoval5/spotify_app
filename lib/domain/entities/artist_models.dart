import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final int followers;
  final List<String> genres;

  const Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.followers,
    required this.genres,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, followers, genres];
}
