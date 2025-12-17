import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/models/mypet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/shared/pawloading.dart';
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

  //User? currentUser; 

  @override
  void initState() {
    super.initState();
    loadPets('');
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
              loadPets('');
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column( 
                  mainAxisAlignment: MainAxisAlignment.start, 
                  mainAxisSize: MainAxisSize.min, 
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
                    // Login Button Box - only show when user is not logged in
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
                                //intead of currentUser = result;
                                widget.user == result;
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
                                    height: 10),
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
              //Pets List 
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: listPets.isEmpty
                      ? Center(
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
                      : ListView.builder(
                          itemCount: listPets.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8, 
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
                                        child: listPets[index].imagePaths!.isNotEmpty
                                            ? ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: listPets[index].imagePaths!.length,
                                                itemBuilder: (context, imgIndex) {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                                    child: Image.network(
                                                      '${MyConfig.baseUrl}/pawpal/assets/pets/pets_${listPets[index].imagePaths?[imgIndex]}',
                                                      fit: BoxFit.cover,
                                                      width: screenWidth * 0.28,
                                                      height: screenWidth * 0.22,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.broken_image, size: 60, color: Colors.grey);
                                                      },
                                                    ),
                                                  );
                                                },
                                              )
                                            : const Icon(Icons.broken_image, size: 60, color: Colors.grey),
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
                                              color: Color.fromRGBO(215, 54, 138, 1),
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
                                              color: Color.fromRGBO(215, 54, 138, 1),
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
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
              //pagination controls
              SizedBox(
                height: screenHeight * 0.05,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: numOfPage,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    color = (currentPage == index + 1)
                        ? mainPink
                        : Colors.black;
                    return TextButton(
                      onPressed: () {
                        currentPage = index + 1;
                        loadPets('');
                      }, 
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(color: color, fontSize: 16),
                      ),
                    );
                  }
                )
              )
            ],
          ),
        ),
      ),
      //floating action button to add new pet
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if(widget.user?.user_id == '0') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please login first/or register first"),
                backgroundColor: Colors.redAccent,
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
            loadPets('');
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
      statusMsg = "Loading...";
      PawLoading();
    });
    http
      .get(
        Uri.parse(
          "${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?search=$searchQuery&curPage=$currentPage"
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
              numOfPage = int.parse(jsonResponse['numOfPage'].toString());
              numOfResult = int.parse(
                jsonResponse['numOfResult'].toString(),
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
                      '${MyConfig.baseUrl}/pawpal/assets/pets/pets_/${listPets[index].imagePaths}.png', 
                      fit: BoxFit.cover,
                    )
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
                      // TableRow(
                      //   children: [
                      //     TableCell(
                      //       verticalAlignment:
                      //           TableCellVerticalAlignment.middle,
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Text('Image'),
                      //       ),
                      //     ),
                      //     TableCell(
                      //       verticalAlignment:
                      //           TableCellVerticalAlignment.middle,
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: Text(
                      //           listPets[index].imagePaths.toString(),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
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

  Future<User> getServiceOwnerDetails(int index) async {
    String ownerid = listPets[index].user_id.toString();
    User owner = User();
    try {
      final response = await http.get(
        Uri.parse(
          '${MyConfig.baseUrl}/pawpal/api/get_user_details.php?userid=$ownerid',
        ),
      );
      if (response.statusCode == 200) {
        var jsonResponse = response.body;
        var resarray = jsonDecode(jsonResponse);
        if (resarray['status'] == 'success') {
          owner = User.fromJson(resarray['data'][0]);
        }
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
    return owner;
  }
}