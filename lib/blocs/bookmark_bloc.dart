import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/bookmark.dart';
import '../models/word.dart';
import '../data/database_helper.dart';

// Events
abstract class BookmarkEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBookmarksEvent extends BookmarkEvent {}

class AddBookmarkEvent extends BookmarkEvent {
  final Word word;
  AddBookmarkEvent(this.word);
  @override
  List<Object?> get props => [word];
}

class RemoveBookmarkEvent extends BookmarkEvent {
  final int wordId;
  RemoveBookmarkEvent(this.wordId);
  @override
  List<Object?> get props => [wordId];
}

class SearchBookmarksEvent extends BookmarkEvent {
  final String query;
  SearchBookmarksEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class CheckBookmarkEvent extends BookmarkEvent {
  final int wordId;
  CheckBookmarkEvent(this.wordId);
  @override
  List<Object?> get props => [wordId];
}

// States
abstract class BookmarkState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarksLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;
  
  BookmarksLoaded(this.bookmarks);
  
  @override
  List<Object?> get props => [bookmarks];
}

class BookmarkAdded extends BookmarkState {}

class BookmarkRemoved extends BookmarkState {}

class BookmarkCheckResult extends BookmarkState {
  final bool isBookmarked;
  
  BookmarkCheckResult(this.isBookmarked);
  
  @override
  List<Object?> get props => [isBookmarked];
}

class BookmarkError extends BookmarkState {
  final String message;
  
  BookmarkError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final DatabaseHelper dbHelper;

  BookmarkBloc(this.dbHelper) : super(BookmarkInitial()) {
    on<LoadBookmarksEvent>(_onLoadBookmarks);
    on<AddBookmarkEvent>(_onAddBookmark);
    on<RemoveBookmarkEvent>(_onRemoveBookmark);
    on<SearchBookmarksEvent>(_onSearchBookmarks);
    on<CheckBookmarkEvent>(_onCheckBookmark);
  }

  Future<void> _onLoadBookmarks(LoadBookmarksEvent event, Emitter<BookmarkState> emit) async {
    emit(BookmarkLoading());
    try {
      final bookmarks = await dbHelper.getBookmarks();
      emit(BookmarksLoaded(bookmarks));
    } catch (e) {
      emit(BookmarkError('Failed to load bookmarks: ${e.toString()}'));
    }
  }

  Future<void> _onAddBookmark(AddBookmarkEvent event, Emitter<BookmarkState> emit) async {
    try {
      final bookmark = Bookmark(
        wordId: event.word.id,
        wordText: event.word.word,
        definition: event.word.definition,
        partOfSpeech: event.word.partOfSpeech,
        addedAt: DateTime.now(),
      );
      await dbHelper.addBookmark(bookmark);
      emit(BookmarkAdded());
      add(LoadBookmarksEvent());
    } catch (e) {
      emit(BookmarkError('Failed to add bookmark: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveBookmark(RemoveBookmarkEvent event, Emitter<BookmarkState> emit) async {
    try {
      await dbHelper.removeBookmark(event.wordId);
      emit(BookmarkRemoved());
      add(LoadBookmarksEvent());
    } catch (e) {
      emit(BookmarkError('Failed to remove bookmark: ${e.toString()}'));
    }
  }

  Future<void> _onSearchBookmarks(SearchBookmarksEvent event, Emitter<BookmarkState> emit) async {
    emit(BookmarkLoading());
    try {
      final bookmarks = await dbHelper.searchBookmarks(event.query);
      emit(BookmarksLoaded(bookmarks));
    } catch (e) {
      emit(BookmarkError('Failed to search bookmarks: ${e.toString()}'));
    }
  }

  Future<void> _onCheckBookmark(CheckBookmarkEvent event, Emitter<BookmarkState> emit) async {
    try {
      final isBookmarked = await dbHelper.isBookmarked(event.wordId);
      emit(BookmarkCheckResult(isBookmarked));
    } catch (e) {
      emit(BookmarkError('Failed to check bookmark: ${e.toString()}'));
    }
  }
}
