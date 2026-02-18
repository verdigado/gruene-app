// ignore_for_file: public_member_api_docs, sort_constructors_first

class SearchActionState {
  final bool isEnabled;
  final String actionText;

  SearchActionState.enabled({required this.actionText}) : isEnabled = true;
  SearchActionState.disabled({required this.actionText}) : isEnabled = false;
}
