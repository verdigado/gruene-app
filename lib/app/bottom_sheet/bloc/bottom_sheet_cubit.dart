import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gruene_app/app/bottom_sheet/bloc/bottom_sheet_state.dart';

class BottomSheetCubit extends Cubit<BottomSheetState> {
  BottomSheetCubit() : super(const BottomSheetState());

  void show(Widget widget) => emit(BottomSheetState(content: widget));
  void hide() => emit(const BottomSheetState());
}
