import 'package:flutter/material.dart';

import 'domain/show.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowTable extends StatelessWidget {
  ShowTable({super.key});
  static List<int> list = List.empty(growable: true);
  Future<List<Show>> fetchShows() async {
    final response =
    await http.get(Uri.parse('http://localhost:8080/ticket-master/show'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Show> shows = Show.listFromJson(jsonResponse);
      list.clear();
      list.addAll(shows.map((e) => e.id));
      return shows;
    } else {
      return List.empty();
    }
  }
  static List<int> getIdsOfShows(){
    return list;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Show>>(
      future: fetchShows(),
      builder: (BuildContext context, AsyncSnapshot<List<Show>> snapshot) {
        if (snapshot.hasData) {
          return DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Artist')),
              DataColumn(label: Text('Location')),
              DataColumn(label: Text('Show Date')),
              DataColumn(label: Text('Available Seats')),
              DataColumn(label: Text('Sold Seats')),
            ],
            rows: snapshot.data!.map((Show show) => DataRow(
              cells: <DataCell>[
                DataCell(Text('${show.id}')),
                DataCell(Text(show.artist!.name)), // Assuming Artist has a name property
                DataCell(Text(show.location)),
                DataCell(Text('${show.showDate}')),
                DataCell(Text('${show.availableSeats}')),
                DataCell(Text('${show.soldSeats}')),
              ],
            )).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}