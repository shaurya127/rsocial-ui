import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> getFunc({String url, String token}) async {
  try {
    var uri = Uri.parse(url);
    var response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer: $token",
        "Content-Type": "application/json",
        "Accept": "*/*"
      },
    );
    return response;
  } catch (e) {
    print("Exception in get");
    return null;
  }
}

Future<http.Response> postFunc({String url, String token, String body}) async {
  try {
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        encoding: Encoding.getByName("utf-8"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          //"Accept": "*/*"
        },
        body: body);

    return response;
  } catch (e) {
    print("Exception in post");
    return null;
  }
}

Future<http.Response> putFunc({String url, String token, String body}) async {
  try {
    var uri = Uri.parse(url);
    var response = await http.put(uri,
        encoding: Encoding.getByName("utf-8"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          //"Accept": "*/*"
        },
        body: body);

    return response;
  } catch (e) {
    print("Exception in post");
    return null;
  }
}
