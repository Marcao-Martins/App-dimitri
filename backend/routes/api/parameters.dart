import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final dataFile = File('data/veterinary_parameters.json');
  if (!await dataFile.exists()) {
    return Response(statusCode: 404, body: 'Data not found');
  }

  final content = await dataFile.readAsString();
  final jsonList = jsonDecode(content) as List;

  final species = context.request.uri.queryParameters['species'];
  final category = context.request.uri.queryParameters['category'];

  var filteredList = jsonList;

  if (species != null) {
    filteredList = filteredList.where((item) => item['species'] == species).toList();
  }

  if (category != null) {
    filteredList = filteredList.where((item) => item['category'] == category).toList();
  }

  return Response.json(body: filteredList);
}
