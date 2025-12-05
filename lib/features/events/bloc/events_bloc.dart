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
  final List<Calendar>? calendars;
  final Set<CalendarEventAttendanceStatus>? attendanceStatuses;
  final List<String>? categories;
  final DateTimeRange? dateRange;

  final bool force;

  LoadEvents({
    this.query,
    this.calendars,
    this.attendanceStatuses,
    this.categories,
    this.dateRange,
    this.force = false,
  });
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
  final List<CalendarEvent> allEventsInDateRange;
  final bool loading;
  final Object? error;

  final String query;
  final List<Calendar> calendars;
  final Set<CalendarEventAttendanceStatus> attendanceStatuses;
  final List<String> categories;
  final DateTimeRange dateRange;

  List<CalendarEvent> get events => allEventsInDateRange.filter(
    query: query,
    calendars: calendars,
    attendanceStatuses: attendanceStatuses,
    categories: categories,
  );

  EventsState({
    List<CalendarEvent>? allEventsInDateRange,
    this.loading = false,
    this.error,
    this.query = '',
    List<Calendar>? calendars,
    Set<CalendarEventAttendanceStatus>? attendanceStatuses,
    List<String>? categories,
    DateTimeRange? dateRange,
  }) : allEventsInDateRange = allEventsInDateRange ?? [],
       calendars = calendars ?? [],
       attendanceStatuses = attendanceStatuses ?? defaultAttendanceStatuses,
       categories = categories ?? defaultCategories,
       dateRange = dateRange ?? defaultDateRange;

  EventsState copyWith({
    List<CalendarEvent>? allEventsInDateRange,
    bool? loading,
    Wrapped<Object?>? error,
    String? query,
    List<Calendar>? calendars,
    Set<CalendarEventAttendanceStatus>? attendanceStatuses,
    List<String>? categories,
    DateTimeRange? dateRange,
  }) {
    return EventsState(
      allEventsInDateRange: allEventsInDateRange ?? this.allEventsInDateRange,
      loading: loading ?? this.loading,
      error: error == null ? this.error : error.value,
      query: query ?? this.query,
      calendars: calendars ?? this.calendars,
      attendanceStatuses: attendanceStatuses ?? this.attendanceStatuses,
      categories: categories ?? this.categories,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  List<Object?> get props => [events, loading, error, query, calendars, attendanceStatuses, categories, dateRange];
}

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsState()) {
    on<LoadEvents>((event, emit) async {
      final reload = event.force || (event.dateRange != null && event.dateRange != state.dateRange);

      emit(
        state.copyWith(
          loading: reload,
          query: event.query,
          calendars: event.calendars,
          attendanceStatuses: event.attendanceStatuses,
          categories: event.categories,
          dateRange: event.dateRange,
        ),
      );

      if (reload) {
        try {
          final allEventsInDateRange = await getEvents(state.dateRange);
          emit(state.copyWith(allEventsInDateRange: allEventsInDateRange, loading: false, error: Wrapped.value(null)));
        } catch (error) {
          emit(state.copyWith(loading: false, error: Wrapped.value(error)));
        }
      }
    });

    on<AddOrUpdateEvent>((event, emit) async {
      final newCalendarEvent = event.calendarEvent;
      final events = state.allEventsInDateRange.where((calendarEvent) => calendarEvent.id != newCalendarEvent.id);
      emit(state.copyWith(allEventsInDateRange: [...events, newCalendarEvent]));
    });

    on<DeleteEvent>((event, emit) async {
      final events = state.allEventsInDateRange
          .where((calendarEvent) => calendarEvent.id != event.calendarEvent.id)
          .toList();
      emit(state.copyWith(allEventsInDateRange: events));
    });
  }
}
