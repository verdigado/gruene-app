import 'dart:convert';
import 'dart:io';
import 'package:gruene_app/app/constants/config.dart';
import 'package:http/http.dart' as http;

class IpService {
  Future<bool> isOwnIp(String ip) async {
    final isInputIpV6 = isIpV6(ip);
    final publicIp = await getPublicIp(useIpV6: isInputIpV6);
    return ip == publicIp;
  }

  Future<String?> getPublicIp({bool useIpV6 = false}) async {
    try {
      final url = useIpV6 ? Config.ipV6ServiceUrl : Config.ipV4ServiceUrl;

      final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return jsonResponse['clientIp'] as String?;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  bool isIpV6(String ip) {
    try {
      final address = InternetAddress(ip);
      return address.type == InternetAddressType.IPv6;
    } catch (e) {
      return false;
    }
  }
}
