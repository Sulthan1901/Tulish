import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../services/tts_services.dart';


// EVENTS
abstract class TtsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SpeakTextEvent extends TtsEvent {
  final String text;
  SpeakTextEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class StopTtsEvent extends TtsEvent {}


// STATES
abstract class TtsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TtsInitial extends TtsState {}
class TtsSpeaking extends TtsState {}
class TtsStopped extends TtsState {}


// BLoC
class TtsBloc extends Bloc<TtsEvent, TtsState> {
  final TtsService ttsService;

  TtsBloc(this.ttsService) : super(TtsInitial()) {
    on<SpeakTextEvent>(_onSpeak);
    on<StopTtsEvent>(_onStop);
  }

  Future<void> _onSpeak(SpeakTextEvent event, Emitter<TtsState> emit) async {
    emit(TtsSpeaking());
    await ttsService.speak(event.text);
  }

  Future<void> _onStop(StopTtsEvent event, Emitter<TtsState> emit) async {
    await ttsService.stop();
    emit(TtsStopped());
  }
}
