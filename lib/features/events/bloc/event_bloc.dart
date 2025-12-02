import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

sealed class EventsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class AddEvents extends EventsEvent {
  final List<CalendarEvent> calendarEvents;

  AddEvents({required this.calendarEvents});
}

final class AddOrUpdateEvent extends EventsEvent {
  final CalendarEvent calendarEvent;

  AddOrUpdateEvent({required this.calendarEvent});
}

final class DeleteEvent extends EventsEvent {
  final CalendarEvent calendarEvent;

  DeleteEvent({required this.calendarEvent});
}

class EventsState extends Equatable {
  final List<CalendarEvent> events;

  const EventsState(this.events);

  @override
  List<Object> get props => [events];
}

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsState([])) {
    on<AddEvents>((event, emit) async {
      emit(EventsState(event.calendarEvents));
    });

    on<AddOrUpdateEvent>((event, emit) async {
      final newCalendarEvent = event.calendarEvent;
      final calendarEvents = state.events.where((calendarEvent) => calendarEvent.id != newCalendarEvent.id);
      emit(EventsState([...calendarEvents, newCalendarEvent]));
    });

    on<DeleteEvent>((event, emit) async {
      emit(EventsState(state.events.where((calendarEvent) => calendarEvent.id != event.calendarEvent.id).toList()));
    });
  }
}
