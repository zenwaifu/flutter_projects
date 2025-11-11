import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myplaces/placelist.dart';


class MyPlacesScreen extends StatefulWidget {
  const MyPlacesScreen({super.key});

  @override
  State<MyPlacesScreen> createState() => _MyPlacesScreenState();
}

class _MyPlacesScreenState extends State<MyPlacesScreen> {
  List<Place> places = [];
  bool isLoading = false;
  String status = "Press the button to fetch places";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      screenWidth = 600;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Malaysia Places List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchPlaces(),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth,
          child: Column(
            children: [
              Text('Welcome to Malaysia Places List',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )
              ),
              SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: () => fetchPlaces(),
                  child: const Text('Fetch Places'),
                )
              ),
              places.isEmpty
                  ? Column(
                      children: [
                        SizedBox(height: 20),
                        const Center(child: CircularProgressIndicator()),
                        SizedBox(height: 10),
                        Text(status),
                      ]
                    ) 
                  : Expanded(
                    child: ListView.builder(
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.network(
                                  place.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                              title: Text(place.name),
                              subtitle: Text('${place.state} • Rating: ${place.rating}'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => showPlaceDetail(place),
                            ),
                          );
                        },
                      ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
  
  void showPlaceDetail(Place place) {
    showDialog(
      context: context,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        if (screenWidth > 600) {
          screenWidth = 600;
          }

        return AlertDialog(
          title: Text(place.name),
          content: SizedBox(
            width: screenWidth,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    place.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        height: 200,
                        child: FittedBox(
                          child: Icon(
                            Icons.image_not_supported, 
                            size: 100,
                          )
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text('State: ${place.state}'),
                  Text('Category: ${place.category}'),
                  Text('Contact: ${place.contact}'),
                  Text('Rating: ${place.rating}'),
                  Text('Location: (${place.latitude}, ${place.longitude})'),
                  const SizedBox(height: 10),
                  Text(place.description),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'))
          ],
        );
      },
    );
  }

  Future<void> fetchPlaces() async {
    setState(() {
      isLoading = true;
      status = "Loading places...";
      places = [];
    });

    try {
      final response = await http.get(
        Uri.parse('https://slumberjer.com/teaching/a251/locations.php?state=&category=&name='),
      ).then((response,){
          if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          setState(() {
            status = "No places found";
            isLoading = false;
          });
        } else {
          setState(() {
            places = data.map((json) => Place.fromJson(json)).toList();
            isLoading = false;
          });
        }
      } else {
        setState(() {
          status = "Failed to load data: ${response.statusCode}";
          isLoading = false;
        });
      }
      });
    } catch (e) {
      setState(() {
        status = "Error fetching data: $e";
        isLoading = false;
      });
    }
  }
}
