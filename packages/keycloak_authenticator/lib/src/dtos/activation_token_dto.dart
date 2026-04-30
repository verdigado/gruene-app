class ActivationTokenDto {
  final String baseUrl;
  final String realm;
  final String key;
  final String tabId;
  final String clientId;

  ActivationTokenDto({
    required this.baseUrl,
    required this.realm,
    required this.key,
    required this.tabId,
    required this.clientId,
  });

  factory ActivationTokenDto.fromUrl(String url) {
    final uri = Uri.parse(url);

    final clientId = uri.queryParameters['client_id'];
    if (clientId == null) {
      throw const FormatException('missing client_id');
    }

    final tabId = uri.queryParameters['tab_id'];
    if (tabId == null) {
      throw const FormatException('missing tab_id');
    }

    final key = uri.queryParameters['key'];
    if (key == null) {
      throw const FormatException('missing key');
    }

    RegExp exp = RegExp(r'(.*\/realms\/([^\/]+))\/');
    RegExpMatch? match = exp.firstMatch(uri.path);
    final basePath = match?[1];
    final realm = match?[2];

    if (realm == null) {
      throw const FormatException('missing realm in path');
    }

    return ActivationTokenDto(
      baseUrl: '${uri.origin}$basePath',
      realm: realm,
      clientId: clientId,
      tabId: tabId,
      key: key,
    );
  }
}
