import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/models/mypet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/views/loginpage.dart';
import 'package:pawpal/views/submitpetscreen.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  final User? user;
  const MainPage({super.key, required this.user});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);

  List<MyPet> listPets = [];
  String statusMsg = 'Loading...';
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenHeight, screenWidth;
  int numOfPage = 1;
  int currentPage = 1;
  int numOfResult = 0;
  var color;

  User? currentUser; 

  @override
  void initState() {
    super.initState();
    loadPets("");
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      screenWidth = 600;
    } else {
      screenWidth = screenWidth;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user != null
              ? "Welcome, ${widget.user!.user_name}"
              : "PAWPAL",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
              showSearchDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: (){
              loadPets("");
            },
          ),
          IconButton(
            icon: Icon(Icons.login),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          )
        ]
      ),
      body: Center(
        child: SizedBox(
          width: screenWidth,
          // The main Column needs to be wrapped by a widget that gives it a constrained height,
          // such as an Expanded, if you want the inner list to take up the remaining space.
          // Since the outer 'body' is usually a Scaffold's body, its height is constrained.
          // However, if the Center/SizedBox doesn't give a height, we need to ensure the list
          // is properly constrained. Assuming 'screenWidth' is the width of the screen,
          // we assume the parent (body) provides the height constraint, but since Column's height is
          // unbounded here, the best fix is to only have ONE Expanded for the list part.
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column( // This inner Column is where the issue is.
                  mainAxisAlignment: MainAxisAlignment.start, // Changed to 'start' as 'center' will push the content to the center of the available space, which is usually not what you want for a scrollable view setup.
                  mainAxisSize: MainAxisSize.min, // Keep top elements tightly packed
                  children: [
                    //Welcome Message box
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: mainPink,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                        color: bgCream,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset('assets/images/puppy1.png', scale: 4),
                          SizedBox(width: 10),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                                color: mainPink,
                              ),
                              children: [
                                if (widget.user != null)
                                  TextSpan(
                                      text: "Hi, ${widget.user!.user_name}!\n",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: 'Find your'),
                                TextSpan(
                                    text: '\nfurry best friend',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '\ntoday!'),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Image.asset('assets/images/paw.png', width: 50, height: 50),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // Login Button Box -- only show when user is not logged in
                    if (widget.user == null)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: mainPink,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          color: bgCream,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                            if (result != null && result is User) {
                              setState(() {
                                currentUser = result;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login,
                                  size: 40,
                                  color: mainPink,
                                ),
                                SizedBox(
                                    height:
                                        10), // This should likely be SizedBox(width: 10) for horizontal space
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: mainPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              //Pets List - This MUST be an Expanded to consume the remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10), // Padding applied here for the list
                  child: listPets.isEmpty
                      ? Center( // No need for Expanded around Center here
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.find_in_page_outlined, size: 64, color: mainPink),
                              SizedBox(height: 12),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: mainPink,
                                  ),
                                  children: [
                                    listPets.isEmpty
                                        ? TextSpan(
                                            text: "No submission yet.\nNo pets found.\n",
                                            style: TextStyle(fontWeight: FontWeight.bold))
                                        : TextSpan(text:statusMsg),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder( // No need for Expanded around ListView.builder here
                          itemCount: listPets.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8, // Horizontal margin inside the 10 padding
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // IMAGE
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: screenWidth * 0.28,
                                        height: screenWidth * 0.22,
                                        color: mainPink,
                                        child: Image.network(
                                          '${MyConfig.baseUrl}/myfuwu/assets/services/service_${listPets[index].petId}.png',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.broken_image,
                                              size: 60,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // TEXT AREA
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // NAME
                                          Text(
                                            listPets[index].petName.toString(),
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 4),

                                          // TYPE
                                          Text(
                                            listPets[index].petType.toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          const SizedBox(height: 6),

                                          // Description
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey.withOpacity(
                                                0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              listPets[index].petDescription.toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.blueGrey,
                                              ),
                                              maxLines: 1, // Added to prevent overflow
                                              overflow: TextOverflow.ellipsis, // Added to prevent overflow
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // TRAILING ARROW BUTTON
                                    IconButton(
                                      onPressed: () {
                                        showDetailsDialog(index);
                                      },
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if(widget.user?.user_id == '0') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please login first/or register first"),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmitPetScreen(user: widget.user),
              ),
            );
            loadPets("");
          }
        },
        backgroundColor: mainPink,
        child: const Icon(Icons.add),
      ),
      drawer: MyDrawer(user: widget.user,),
    );

  }
  
  void loadPets(String searchQuery) {
    listPets.clear();
    setState(() {
      statusMsg = statusMsg;
    });
    http
      .get(
        Uri.parse(
          "${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?search=$searchQuery&currentpage=$currentPage"
        )
      )
      .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            // log(jsonResponse.toString());
            if (jsonResponse['status'] == 'success' &&
                jsonResponse['data'] != null &&
                jsonResponse['data'].isNotEmpty) {
              // has data → load to list
              listPets.clear();
              for (var item in jsonResponse['data']) {
                listPets.add(MyPet.fromJson(item));
              }
              numOfPage = int.parse(jsonResponse['numofpage'].toString());
              numOfResult = int.parse(
                jsonResponse['numberofresult'].toString(),
              );
              print(numOfPage);
              print(numOfResult);
              setState(() {
                statusMsg = "";
              });
            } else {
              // success but EMPTY data
              setState(() {
                listPets.clear();
                statusMsg = "No pets found";
              });
            }
          } else {
            // request failed
            setState(() {
              listPets.clear();
              statusMsg = "Failed to load pets";
            });
          }
      });
  }
  
  void showSearchDialog() {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'Finding your furry friend?'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () {
                String search = searchController.text;
                if (search.isEmpty) {
                  loadPets('');
                } else {
                  loadPets(search);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  void showDetailsDialog(int index) {
    String formattedDate = formatter.format(
      DateTime.parse(listPets[index].dateCreated.toString()),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(listPets[index].petName.toString()),
          content: SizedBox(
            width: screenWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child: Image.network(
                      '${MyConfig.baseUrl}/pawpal/assets/services/service_${listPets[index].petId}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 128,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(
                      color: Colors.grey,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    columnWidths: {
                      0: FixedColumnWidth(100.0),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            // Use TableCell to apply consistent styling/padding
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Name'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].petName.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Type'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].petType.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Category'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].petCategory.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Description'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].petDescription.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Latitude'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].latitude.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Longitude'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].longitude.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Date Created'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(formattedDate),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Owner Name'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].user_name.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Image'),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                listPets[index].imagePaths.toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              'tel:${listPets[index].user_phone.toString()}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(Icons.call),
                      ),
                      IconButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              'sms:${listPets[index].user_phone.toString()}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(Icons.message),
                      ),
                      IconButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              'mailto:${listPets[index].user_email.toString()}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(Icons.email),
                      ),
                      IconButton(
                        onPressed: () async {
                          await launchUrl(
                            Uri.parse(
                              'https://wa.me/${listPets[index].user_phone.toString()}',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: Icon(Icons.wechat),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}