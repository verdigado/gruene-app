import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/utils/date.dart';
import 'package:gruene_app/features/events/domain/events_api_service.dart';
import 'package:gruene_app/features/events/utils/utils.dart';
import 'package:gruene_app/swagger_generated_code/gruene_api.swagger.dart';

final String defaultQuery = '';
final Set<CalendarEventAttendanceStatus> defaultAttendanceStatuses = {};
final List<String> defaultCategories = [];
final DateTimeRange defaultDateRange = todayOrFuture();

sealed class EventsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class LoadEvents extends EventsEvent {
  final String? query;
  final Set<CalendarEventAttendanceStatus>? attendanceStatuses;
  final List<String>? categories;
  final DateTimeRange? dateRange;

  final bool force;

  LoadEvents({this.query, this.attendanceStatuses, this.categories, this.dateRange, this.force = false});
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
  final List<CalendarEvent> allEventsInDateRange;
  final bool loading;
  final Object? error;

  final String query;
  final Set<CalendarEventAttendanceStatus> attendanceStatuses;
  final List<String> categories;
  final DateTimeRange dateRange;

  EventsState({
    required this.events,
    this.loading = false,
    this.error,
    this.query = '',
    List<CalendarEvent>? allEventsInDateRange,
    Set<CalendarEventAttendanceStatus>? attendanceStatuses,
    List<String>? categories,
    DateTimeRange? dateRange,
  }) : allEventsInDateRange = allEventsInDateRange ?? events,
       attendanceStatuses = attendanceStatuses ?? defaultAttendanceStatuses,
       categories = categories ?? defaultCategories,
       dateRange = dateRange ?? defaultDateRange;

  EventsState copyWith({
    List<CalendarEvent>? events,
    List<CalendarEvent>? allEventsInDateRange,
    bool? loading,
    Wrapped<Object?>? error,
    String? query,
    Set<CalendarEventAttendanceStatus>? attendanceStatuses,
    List<String>? categories,
    DateTimeRange? dateRange,
  }) {
    return EventsState(
      events: events ?? this.events,
      allEventsInDateRange: allEventsInDateRange ?? this.allEventsInDateRange,
      loading: loading ?? this.loading,
      error: error == null ? this.error : error.value,
      query: query ?? this.query,
      attendanceStatuses: attendanceStatuses ?? this.attendanceStatuses,
      categories: categories ?? this.categories,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  List<Object?> get props => [events, loading, error, query, attendanceStatuses, categories, dateRange];
}

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsState(events: [])) {
    on<LoadEvents>((event, emit) async {
      final reload = event.force || (event.dateRange != null && event.dateRange != state.dateRange);

      emit(
        state.copyWith(
          loading: true,
          query: event.query,
          attendanceStatuses: event.attendanceStatuses,
          categories: event.categories,
          dateRange: event.dateRange,
        ),
      );

      try {
        final calendarEvents = reload ? await getEvents(state.dateRange) : state.allEventsInDateRange;
        final events = calendarEvents.filter(state.query, state.attendanceStatuses, state.categories);
        emit(
          state.copyWith(
            events: events,
            allEventsInDateRange: calendarEvents,
            loading: false,
            error: Wrapped.value(null),
          ),
        );
      } catch (error) {
        emit(state.copyWith(loading: false, error: Wrapped.value(error)));
      }
    });

    on<AddOrUpdateEvent>((event, emit) async {
      final newCalendarEvent = event.calendarEvent;
      final calendarEvents = state.events.where((calendarEvent) => calendarEvent.id != newCalendarEvent.id);
      emit(state.copyWith(events: [...calendarEvents, newCalendarEvent]));
    });

    on<DeleteEvent>((event, emit) async {
      final filteredEvents = state.events.where((calendarEvent) => calendarEvent.id != event.calendarEvent.id).toList();
      emit(state.copyWith(events: filteredEvents));
    });
  }
}
