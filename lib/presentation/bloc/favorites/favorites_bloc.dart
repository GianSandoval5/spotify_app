import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spotify_app/domain/entities/song_models.dart';
import 'package:spotify_app/domain/repositories/music_repository.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}

class AddToFavoritesEvent extends FavoritesEvent {
  final Song song;
  AddToFavoritesEvent(this.song);

  @override
  List<Object?> get props => [song];
}

class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String songId;
  RemoveFromFavoritesEvent(this.songId);

  @override
  List<Object?> get props => [songId];
}

// States
abstract class FavoritesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Song> favorites;
  FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final MusicRepository repository;

  FavoritesBloc(this.repository) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    await repository.addToFavorites(event.song);
    add(LoadFavoritesEvent());
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    await repository.removeFromFavorites(event.songId);
    add(LoadFavoritesEvent());
  }
}
