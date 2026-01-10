import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pawpal/models/mypet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/shared/pawloading.dart';
import 'package:pawpal/views/adoptionsubmitscreen.dart';
import 'package:pawpal/views/donationsubmitscreen.dart';
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
  final midPink = const Color.fromRGBO(245, 154, 185, 1); //245, 210, 210
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);

  List<MyPet> listPets = [];
  String statusMsg = 'Loading...';
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenHeight, screenWidth;
  int numOfPage = 1;
  int currentPage = 1;
  int numOfResult = 0;

  User? currentUser; 

  String selectedType = 'All';
  String lastSearch = '';

  String getPetImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return "${MyConfig.baseUrl}/pawpal/assets/$imagePath";
  }

  @override
  void initState() {
    currentUser = widget.user;
    super.initState();
    loadPets('');
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    final contentWidth = screenWidth > 900 ? 900.0 : screenWidth;

    
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: bgCream,
        /*========================APP BAR========================*/
        appBar: buildNewAppBar(),
        /*========================BODY========================*/
        body: Center(
          child: SizedBox(
            width: contentWidth,
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
                                  if (currentUser != null)
                                    TextSpan(
                                        text: "Hi, ${currentUser!.user_name}!\n",
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
                            // SizedBox(width: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      /*======================================================
                        Login Btn Box - only show when user is not logged in
                      ========================================================*/
                      if (currentUser == null)
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
                      // SizedBox(height: 10),
                    ],
                  ),
                ),
                /*======================================================
                  PET LIST BOX - show list of pets
                ========================================================*/
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: listPets.isEmpty
                        ? _buildEmptyState()
                        : _buildPetList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        /* ======================================================
          bottomnavigation bar - pagination controls
        ========================================================*/
        bottomNavigationBar: listPets.isNotEmpty
            ? Container(
              height: 60,
              //color: bgCream,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: bgCream,
                border: Border(
                  top: BorderSide(
                    color: mainPink,
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: mainPink.withValues(alpha: 0.08),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, -3),
                  ),
                ]
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: numOfPage,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final isActive = (currentPage -1) == index;
                  return Padding (
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: isActive ? mainPink : bgCream,
                      ),
                      onPressed: () {
                        setState(() {
                          currentPage = index + 1;
                        });
                        loadPets(lastSearch);
                      }, 
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : mainPink, 
                          fontSize: 16),
                      ),
                    )
                  );
                }
              )
            )
            : null,
        /*======================================================
                        FLOATING ACTION BUTTON
        ========================================================*/
        //floating action button to add new pet
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if(currentUser?.user_id == null){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Please login or register first"),
                  backgroundColor: Colors.redAccent,
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            } else {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubmitPetScreen(user: currentUser),
                ),
              );
              loadPets('');
            }
          },
          backgroundColor: mainPink,
          icon: const Icon(Icons.add),
          label: const Text('Add Pet'),
        ),
        drawer: MyDrawer(user: currentUser,),
      ),
    );

  }
  
  void loadPets(String searchQuery) {
    lastSearch = searchQuery;

    listPets.clear();
    setState(() {
      statusMsg = "Loading...";
      PawLoading();
    });

    final String url = "${MyConfig.baseUrl}/pawpal/api/get_my_pets.php"
        "?search=$lastSearch"
        "&filter=$selectedType"
        "&curpage=$currentPage";

    http.get(Uri.parse(url)).then((response) {
      if (response.body.trim().isEmpty) {
        print("Server returned absolutely nothing.");
        return;
      }

      try {
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
          numOfResult = int.parse(jsonResponse['numOfResult'].toString(),);
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
    
      } catch (e) {
        print("Format error: $e. Actual body: ${response.body}");
      }
    });
  }
  
void showSearchDialog() {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                const Text(
                  "Search Pets",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                // SEARCH FIELD
                TextField(
                  controller: searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _performSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: "Finding your furry best friend...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: bgCream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: mainPink,
                      ),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainPink,
                        foregroundColor: bgCream,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        _performSearch(searchController.text);
                      },
                      child: const Text("Search", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performSearch(String query) {
    Navigator.pop(context);

    if (query.trim().isEmpty) {
      loadPets('');
    } else {
      loadPets(query.trim());
    }
  }
  
  void showDetailsDialog(int index) {
    final petslist = listPets[index];
    DateTime? parsedDate = DateTime.tryParse(petslist.dateCreated?.toString() ?? "");

    // Only format if the parsing was successful, otherwise show "N/A"
    final formattedDate = parsedDate != null 
        ? formatter.format(parsedDate) 
        : "Date not available";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller){
            return Container(
              decoration: BoxDecoration(
                color: bgCream,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DRAG HANDLE
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // IMAGE
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        itemCount: listPets[index].imagePaths!.length,
                        itemBuilder: (context, imgIndex) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Image.network(
                              getPetImageUrl(listPets[index].imagePaths![imgIndex]),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 60),
                            ),
                          );
                        },
                      ),
                    ),
                    // TITLE
                    Text(
                      listPets[index].petName.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: mainPink,
                      ),
                    ),
                    SizedBox(height: 10),

                    // //AGE
                    // Text(
                    //   listPets[index].petAge.toString(),
                    //   style: const TextStyle(
                    //     fontSize: 22,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),

                    SizedBox(height: 10),
                    // CATEGORY
                    Row(
                      children: [
                        _chip(
                          Icons.pets,
                          petslist.petType.toString(),
                        ),
                        const SizedBox(width: 8),
                        _chip(
                          Icons.info,
                          petslist.petCategory.toString(),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    //DESCRIPTION
                    Text(
                      petslist.petDescription.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),

                    SizedBox(height: 20),

                    const Divider(),

                    //DETAILS TABLE
                    _infoRow("Name", petslist.petName.toString()),
                    _infoRow("Age", petslist.petAge.toString()),
                    _infoRow("Type", petslist.petType.toString()),
                    _infoRow("Date Created", formattedDate),
                    _infoRow("Latitude", petslist.latitude.toString()),
                    _infoRow("Longitude", petslist.longitude.toString()),
                    _infoRow("Owner Name", petslist.user_name.toString()),
                    _infoRow("Owner Email", petslist.user_email.toString()),
                    _infoRow("Owner Phone", petslist.user_phone.toString()),  

                    const SizedBox(height: 20,),

                    //CONTACT ACTION
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
                        icon: Icon(Icons.call, color: mainPink),
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
                        icon: Icon(Icons.message, color: mainPink),
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
                        icon: Icon(Icons.email, color: mainPink),
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
                        icon: Icon(Icons.wechat, color: mainPink),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20,),
                  const Divider(),
                  if(listPets[index].petCategory == 'Adoption' &&
                    currentUser?.user_id != listPets[index].user_id)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainPink,
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdoptionSubmitScreen(
                              user: currentUser!,
                              pet: listPets[index],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Text(
                        'Request to Adopt',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  if ((listPets[index].petCategory == 'Donation Request' ||
                        listPets[index].petCategory == 'Help/Rescue') &&
                    currentUser?.user_id != listPets[index].user_id)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonationSubmitScreen(
                                user: currentUser!,
                                pet: listPets[index],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                        label: const Text(
                          'Make a Donation',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  ]
                )
              )
            );
          }
        );
      }
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 154, 185, 1).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: mainPink),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
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
  
  Future<bool> _showExitDialog() async {
    return await showDialog<bool> (
      context: context,
      barrierDismissible: false,
      builder:(context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('Exit App'),
        content: Text('Are you sure you want to exit PawPal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  Widget _buildEmptyState() {
    return Center(
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
    );
  }
  
  Widget _buildPetList() {
    return ListView.builder(
      itemCount: listPets.length,
      itemBuilder: (context, index) {
        return Card(
          //elevation: 2,
          margin: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 8, 
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              showDetailsDialog(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: mainPink.withValues(alpha: 0.8),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    
                    child: Stack(
                      children: [
                        Image.network(
                          getPetImageUrl(listPets[index].imagePaths!.first),
                          width: screenWidth * 0.28,
                          height: screenWidth * 0.22,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 60),
                        ),
                  
                        // Show +N badge if more images exist
                        if (listPets[index].imagePaths!.length > 1)
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "+${listPets[index].imagePaths!.length - 1}",
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                      ],
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
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: mainPink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  
                        const SizedBox(height: 4),
                  
                        // TYPE
                        Text(
                          listPets[index].petType.toString(),
                          style:  TextStyle(
                            fontSize: 14,
                            color: mainPink,
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
                            color: midPink.withOpacity(
                              0.15,
                            ),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text(
                            listPets[index].petDescription.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(245, 154, 185, 1),
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
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: mainPink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
   Widget _buildAppBarIcon({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Tooltip(
          message: tooltip ?? '',
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }

  AppBar buildNewAppBar() {
    return AppBar(
      title: Text(
        currentUser != null
            ? "Welcome, ${currentUser!.user_name}"
            : "PAWPAL",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        _buildAppBarIcon(
          icon: Icons.search,
          onTap: (){
            showSearchDialog();
          },
          tooltip: 'Search',
        ),
        _buildAppBarIcon(
          icon: Icons.filter_alt,
          onTap: (){
            showFilterDialog();
          },
          tooltip: 'Filter',
        ),
        _buildAppBarIcon(
          icon:Icons.refresh,
          onTap: (){
            loadPets('');
          },
          tooltip: 'Refresh',
        ),
        _buildAppBarIcon(
          icon: Icons.login,
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          },
          tooltip: 'Login',
        )
      ]
    );
  }
  
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: mainPink,
              ),
            ),
          ),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }
  
  void showFilterDialog() {
    List<String> types = ["All", "Cat", "Dog", "Rabbit", "Other"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Filter by Type"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: types.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedType = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: mainPink)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: mainPink),
              onPressed: () {
                    _performFilter(selectedType); 
              },
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _performFilter(String type) {
    Navigator.pop(context);
    setState(() {
      selectedType = type;
      currentPage = 1; // Reset to first page when filtering
    });
    loadPets(lastSearch);
  }

  // void showAdoptionRequestDialog(int index) {
  //   if (currentUser == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please login to request adoption'),
  //         backgroundColor: Colors.redAccent,
  //       ),
  //     );
  //     return;
  //   }

  //   TextEditingController motivationController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Request to Adopt ${listPets[index].petName}'),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Tell ${listPets[index].user_name} why you want to adopt this pet:',
  //               style: const TextStyle(fontSize: 14),
  //             ),
  //             const SizedBox(height: 12),
  //             TextField(
  //               controller: motivationController,
  //               maxLines: 5,
  //               maxLength: 500,
  //               decoration: InputDecoration(
  //                 hintText: 'I would love to adopt this pet because...',
  //                 border: const OutlineInputBorder(),
  //                 filled: true,
  //                 fillColor: bgCream,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: mainPink),
  //           onPressed: () {
  //             if (motivationController.text.trim().length < 20) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                   content: Text('Please write at least 20 characters'),
  //                   backgroundColor: Colors.redAccent,
  //                 ),
  //               );
  //               return;
  //             }
  //             Navigator.pop(context);
  //             submitAdoptionRequest(index, motivationController.text.trim());
  //           },
  //           child: const Text(
  //             'Submit Request',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> submitAdoptionRequest(int index, String motivation) async {
  //   try {
  //     final body = {
  //       'pet_id': listPets[index].petId,
  //       'user_id': currentUser?.user_id,
  //       'owner_id': listPets[index].user_id,
  //       'motivation': motivation,
  //     };

  //     final response = await http.post(
  //       Uri.parse('${MyConfig.baseUrl}/pawpal/api/request_adoption.php'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(response.body);
  //       if (result['success']) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(result['message']),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(result['message'] ?? 'Failed to send request'),
  //             backgroundColor: Colors.redAccent,
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         backgroundColor: Colors.redAccent,
  //       ),
  //     );
  //   }
  // }

  // void showDonationDialog(int index) {
  //   if (currentUser == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please login to make a donation'),
  //         backgroundColor: Colors.redAccent,
  //       ),
  //     );
  //     return;
  //   }

  //   String? selectedDonationType;
  //   TextEditingController amountController = TextEditingController();
  //   TextEditingController descriptionController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setDialogState) {
  //         return AlertDialog(
  //           title: Text('Donate to ${listPets[index].petName}'),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text(
  //                   'Select Donation Type:',
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 const SizedBox(height: 8),
                  
  //                 DropdownButtonFormField<String>(
  //                   value: selectedDonationType,
  //                   hint: const Text('Choose type'),
  //                   decoration: InputDecoration(
  //                     border: const OutlineInputBorder(),
  //                     filled: true,
  //                     fillColor: bgCream,
  //                   ),
  //                   items: ['Food', 'Medical', 'Money']
  //                       .map((type) => DropdownMenuItem(
  //                             value: type,
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   type == 'Food'
  //                                       ? Icons.fastfood
  //                                       : type == 'Medical'
  //                                           ? Icons.medical_services
  //                                           : Icons.monetization_on,
  //                                   size: 20,
  //                                 ),
  //                                 const SizedBox(width: 8),
  //                                 Text(type),
  //                               ],
  //                             ),
  //                           ))
  //                       .toList(),
  //                   onChanged: (value) {
  //                     setDialogState(() {
  //                       selectedDonationType = value;
  //                     });
  //                   },
  //                 ),
                  
  //                 const SizedBox(height: 16),
                  
  //                 // Show amount field for Money
  //                 if (selectedDonationType == 'Money')
  //                   TextField(
  //                     controller: amountController,
  //                     keyboardType: TextInputType.number,
  //                     decoration: InputDecoration(
  //                       labelText: 'Amount (RM)',
  //                       prefixText: 'RM ',
  //                       border: const OutlineInputBorder(),
  //                       filled: true,
  //                       fillColor: bgCream,
  //                     ),
  //                   ),
                  
  //                 // Show description field for Food/Medical
  //                 if (selectedDonationType == 'Food' ||
  //                     selectedDonationType == 'Medical')
  //                   TextField(
  //                     controller: descriptionController,
  //                     maxLines: 4,
  //                     maxLength: 200,
  //                     decoration: InputDecoration(
  //                       labelText: 'Description',
  //                       hintText: 'What are you donating?',
  //                       border: const OutlineInputBorder(),
  //                       filled: true,
  //                       fillColor: bgCream,
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(backgroundColor: mainPink),
  //               onPressed: () {
  //                 // Validation
  //                 if (selectedDonationType == null) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text('Please select donation type'),
  //                       backgroundColor: Colors.redAccent,
  //                     ),
  //                   );
  //                   return;
  //                 }

  //                 if (selectedDonationType == 'Money') {
  //                   if (amountController.text.trim().isEmpty ||
  //                       double.tryParse(amountController.text.trim()) == null ||
  //                       double.parse(amountController.text.trim()) <= 0) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                         content: Text('Please enter valid amount'),
  //                         backgroundColor: Colors.redAccent,
  //                       ),
  //                     );
  //                     return;
  //                   }
  //                 } else {
  //                   if (descriptionController.text.trim().length < 10) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                         content: Text('Description must be at least 10 characters'),
  //                         backgroundColor: Colors.redAccent,
  //                       ),
  //                     );
  //                     return;
  //                   }
  //                 }

  //                 Navigator.pop(context);
  //                 submitDonation(
  //                   index,
  //                   selectedDonationType!,
  //                   amountController.text.trim(),
  //                   descriptionController.text.trim(),
  //                 );
  //               },
  //               child: const Text(
  //                 'Donate',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  // Future<void> submitDonation(
  //   int index,
  //   String donationType,
  //   String amount,
  //   String description,
  // ) async {
  //   try {
  //     final body = {
  //       'pet_id': listPets[index].petId,
  //       'user_id': currentUser?.user_id,
  //       'donation_type': donationType,
  //       'amount': donationType == 'Money' ? amount : null,
  //       'description': donationType != 'Money' ? description : null,
  //     };

  //     final response = await http.post(
  //       Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_donation.php'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(response.body);
  //       if (result['success']) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(result['message']),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(result['message'] ?? 'Failed to submit donation'),
  //             backgroundColor: Colors.redAccent,
  //           ),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         backgroundColor: Colors.redAccent,
  //       ),
  //     );
  //   }
  // }
}