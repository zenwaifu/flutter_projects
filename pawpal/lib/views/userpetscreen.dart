import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/models/mypet.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/views/loginpage.dart';
import 'package:pawpal/views/submitpetscreen.dart';
import 'package:pawpal/views/edituserpetscreen.dart';

class UserPetScreen extends StatefulWidget {
  final User? user;

  const UserPetScreen({super.key, this.user});

  @override
  State<UserPetScreen> createState() => _UserPetScreenState();
}

class _UserPetScreenState extends State<UserPetScreen> {
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final midPink = const Color.fromRGBO(245, 154, 185, 1);
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);

  List<MyPet> userPetList = [];
  String status = "Loading...";
  bool isLoading = false;

  // Pagination variables
  int currentPage = 1;
  int numOfPage = 1;
  int numOfResult = 0;

  @override
  void initState() {
    super.initState();
    loadUserPets();
  }

  String getPetImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) return imagePath;
    return "${MyConfig.baseUrl}/pawpal/assets/$imagePath";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: buildAppBar(),
      drawer: MyDrawer(user: widget.user),
      body: widget.user?.user_id == null || widget.user?.user_id == '0'
          ? buildNotLoggedInState()
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => loadUserPets(),
                  child: userPetList.isEmpty
                      ? buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: userPetList.length,
                          itemBuilder: (context, index) {
                            return buildPetCard(index);
                          },
                        ),
                ),
      // Pagination Bottom Bar
      bottomNavigationBar: userPetList.isNotEmpty && numOfPage > 1
          ? Container(
              height: 60,
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
                    color: mainPink.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: numOfPage,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final isActive = (currentPage - 1) == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: isActive ? mainPink : bgCream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: mainPink,
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          currentPage = index + 1;
                        });
                        loadUserPets();
                      },
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : mainPink,
                          fontSize: 16,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainPink,
        onPressed: () async {
          if (widget.user?.user_id == null || widget.user?.user_id == '0') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          } else {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmitPetScreen(user: widget.user),
              ),
            );
            if (result == true) {
              setState(() {
                currentPage = 1; // Reset to first page
              });
              loadUserPets();
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: mainPink,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Pets",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (numOfResult > 0)
            Text(
              "$numOfResult pet${numOfResult > 1 ? 's' : ''} • Page $currentPage of $numOfPage",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            )
          else
            const Text(
              "Manage your listings",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: loadUserPets,
        ),
      ],
    );
  }

  Widget buildPetCard(int index) {
    MyPet pet = userPetList[index];

    // Get first image from the image_paths array
    String? firstImage = (pet.imagePaths != null && pet.imagePaths!.isNotEmpty)
        ? pet.imagePaths!.first
        : null;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Pet Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: firstImage != null
                  ? Image.network(
                      getPetImageUrl(firstImage),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets, size: 40),
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets, size: 40),
                    ),
            ),
            const SizedBox(width: 12),

            // Pet Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.petName ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainPink,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.pets, size: 14, color: mainPink),
                      const SizedBox(width: 4),
                      Text(
                        pet.petType ?? 'N/A',
                        style: TextStyle(fontSize: 12, color: mainPink),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.category, size: 14, color: mainPink),
                      const SizedBox(width: 4),
                      Text(
                        pet.petCategory ?? 'N/A',
                        style: TextStyle(fontSize: 12, color: mainPink),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.petDescription ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: midPink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Age: ${pet.petAge ?? 'N/A'}",
                    style: TextStyle(fontSize: 12, color: midPink),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: mainPink),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserPetScreen(
                          user: widget.user,
                          pet: pet,
                        ),
                      ),
                    );
                    if (result == true) {
                      loadUserPets(); // Refresh the list
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: mainPink),
                  onPressed: () => deleteDialog(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 80, color: mainPink.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No Pets Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainPink),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add your first pet',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 70, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Please login to manage your pets"),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mainPink),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Future<void> loadUserPets() async {
    if (widget.user?.user_id == null || widget.user?.user_id == '0') {
      setState(() {
        status = "Please login";
        userPetList.clear();
      });
      return;
    }

    setState(() {
      isLoading = true;
      status = "Loading...";
      userPetList.clear();
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${MyConfig.baseUrl}/pawpal/api/get_user_pets.php?userid=${widget.user!.user_id}&curpage=$currentPage',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          final items = jsonResponse['data'] as List;
          setState(() {
            userPetList = items.map((item) => MyPet.fromJson(item)).toList();
            numOfPage = jsonResponse['numOfPage'] ?? 1;
            numOfResult = jsonResponse['numOfResult'] ?? 0;
            status = userPetList.isEmpty ? "No pets found" : "";
          });
        } else {
          setState(() {
            status = jsonResponse['message'] ?? "No pets found";
            numOfPage = 1;
            numOfResult = 0;
          });
        }
      } else {
        setState(() {
          status = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        status = "Error loading pets: $e";
      });
      log("Error loading pets: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pet?"),
        content: Text(
          "Are you sure you want to delete ${userPetList[index].petName}? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deletePet(index);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> deletePet(int index) async {
    try {
      final response = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/delete_pet.php'),
        body: {
          'userid': widget.user!.user_id.toString(),
          'petid': userPetList[index].petId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (mounted) {
          if (res['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? 'Pet deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            
            // If last item on current page is deleted, go to previous page
            if (userPetList.length == 1 && currentPage > 1) {
              setState(() {
                currentPage--;
              });
            }
            loadUserPets();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(res['message'] ?? 'Failed to delete pet'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      log("Error deleting pet: $e");
    }
  }
}