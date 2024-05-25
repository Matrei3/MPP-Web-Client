import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpp_rest/show_table.dart';
import 'dart:convert';

import 'domain/artist.dart';
import 'domain/show.dart';

class ShowView extends StatefulWidget {
  const ShowView({super.key});

  @override
  State<ShowView> createState() {
    return _ShowViewState();
  }
}

class _ShowViewState extends State<ShowView> {
  Artist? _selectedArtist;
  final TextEditingController _controllerLocation = TextEditingController();
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerAvailableTickets =
      TextEditingController();
  int? selectedId;
  Widget showsTable = ShowTable();
  List<int> showIds = ShowTable.getIdsOfShows();
  final ValueNotifier<Color> textColor = ValueNotifier<Color>(Colors.black);
  final TextEditingController _controllerSoldTickets = TextEditingController();

  Future<List<Artist>> fetchArtists() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/ticket-master/artist'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Artist> artists = Artist.listFromJson(jsonResponse);
      return artists;
    } else {
      return List.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.purple],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                "Ticket Master",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          body: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Table(columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FixedColumnWidth(175),
                  }, children: [
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Artist",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: FutureBuilder<List<Artist>>(
                          future: fetchArtists(),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Artist>> snapshot) {
                            if (snapshot.hasData) {
                              return DropdownButton<Artist>(
                                value: _selectedArtist,
                                hint: Text(_selectedArtist?.name ??
                                    "Select an artist"),
                                items: snapshot.data!.map((Artist artist) {
                                  return DropdownMenuItem<Artist>(
                                    value: artist,
                                    child: Text(artist
                                        .name), // Assuming 'name' is a property of Artist
                                  );
                                }).toList(),
                                onChanged: (Artist? value) {
                                  setState(() {
                                    _selectedArtist = value;
                                  });
                                },
                              );
                            }
                            return const CircularProgressIndicator();
                          },
                        ),
                      )
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Location",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          controller: _controllerLocation,
                        ),
                      )
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Show Date",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: ValueListenableBuilder(
                            valueListenable: textColor,
                            builder: (BuildContext context, Color value,
                                Widget? child) {
                              return TextField(
                                controller: _controllerDate,
                                style: TextStyle(color: value),
                                onChanged: (value) {
                                  try {
                                    DateTime.parse(value);
                                    textColor.value = Colors.black;
                                  } on Exception catch (_) {
                                    textColor.value = Colors.red;
                                  }
                                },
                              );
                            },
                          ))
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Available Tickets",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextField(
                              controller: _controllerAvailableTickets))
                    ]),
                    TableRow(children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Sold Tickets",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextField(controller: _controllerSoldTickets))
                    ])
                  ]),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            if (_controllerLocation.text.isEmpty ||
                                _controllerDate.text.isEmpty ||
                                _selectedArtist == null ||
                                _controllerAvailableTickets.text.isEmpty ||
                                _controllerSoldTickets.text.isEmpty) {
                              return;
                            } else {
                              await addShow();
                              setState(() {
                                showsTable = ShowTable();
                              });
                            }
                          },
                          child: const Text(
                            "Add",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(
                        width: 30,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (_selectedArtist != null &&
                                _controllerLocation.text.isNotEmpty &&
                                textColor.value == Colors.black &&
                                _controllerAvailableTickets.text.isNotEmpty &&
                                _controllerSoldTickets.text.isNotEmpty &&
                                selectedId != null) {
                              String resp = await updateShow(
                                  selectedId!,
                                  _controllerLocation.text,
                                  _controllerDate.text,
                                  _selectedArtist!,
                                  int.parse(_controllerAvailableTickets.text),
                                  int.parse(_controllerSoldTickets.text));
                              setState(() {
                                showsTable = ShowTable();
                              });
                            }
                          },
                          child: const Text(
                            'Update',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(
                        width: 30,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (selectedId != null) {
                              await deleteShow(selectedId!);
                              setState(() {
                                showsTable = ShowTable();
                                showIds = ShowTable.getIdsOfShows();
                                showIds.remove(selectedId);
                                selectedId = null;
                                _selectedArtist = null;
                                _controllerLocation.clear();
                                _controllerDate.clear();
                                _controllerAvailableTickets.clear();
                                _controllerSoldTickets.clear();
                              });
                            }
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Id for update/delete",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: DropdownButton<int>(
                      value: selectedId,
                      hint: const Text("Select Id"),
                      items: showIds.map((int id) {
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(id.toString()),
                        );
                      }).toList(),
                      onChanged: (int? id) async {
                        if (id != null) {
                          Show show = await getShow(id);
                          _controllerLocation.text = show.location;
                          _controllerSoldTickets.text =
                              show.soldSeats.toString();
                          _controllerAvailableTickets.text =
                              show.availableSeats.toString();
                          _controllerDate.text = show.showDate.toString();
                          _selectedArtist = show.artist;
                          setState(() {
                            selectedId = id;
                          });
                        }
                      },
                    ),
                  ),
                  showsTable
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Show> getShow(int selectedId) async {
    final response = await http
        .get(Uri.parse('http://localhost:8080/ticket-master/show/$selectedId'));
    return Show.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteShow(int selectedId) async {
    await http.delete(
        Uri.parse('http://localhost:8080/ticket-master/show/$selectedId'));
  }

  Future<String> updateShow(int selectedId, String location, String showDate,
      Artist artist, int availableSeats, int soldSeats) async {
    final response = await http.put(
        Uri.parse('http://localhost:8080/ticket-master/show/$selectedId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': selectedId,
          'location': location,
          'showDate': showDate,
          'artist': artist.toJson(),
          'availableSeats': availableSeats,
          'soldSeats': soldSeats,
        }));
    return response.body;
  }

  Future<http.Response> addShow() async {
    return http.post(
      Uri.parse('http://localhost:8080/ticket-master/show'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'location': _controllerLocation.text,
        'showDate': _controllerDate.text,
        'artist': _selectedArtist!.toJson(),
        'availableSeats': _controllerAvailableTickets.text,
        'soldSeats': _controllerSoldTickets.text,
      }),
    );
  }
}
