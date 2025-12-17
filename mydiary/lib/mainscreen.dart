import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mydiary/databasehelper.dart';
import 'package:mydiary/diarylist.dart';
import 'package:mydiary/journallogscreen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  //main pink palette
  final darkpink = Color.fromRGBO(252, 128, 159, 1);
  final midpink = Color.fromRGBO(255, 188, 205, 1);
  final lightpink = Color.fromRGBO(255, 228, 233, 1);

  late double screenWidth, screenHeight;

  List<DiaryList> diaryList = [];
  int currentpagenum = 1;
  int limit = 5;
  int pages = 1;
  
  String status = 'Loading...';

  bool isSearching = false;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadDiary();
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
      backgroundColor: lightpink,
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkpink,
        foregroundColor: lightpink,
        onPressed: () async{
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JournalLogScreen()),
          );
          loadDiary();
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top:60, bottom:20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lightpink,
                  midpink,
                  darkpink,
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Text(
                        'My Diary',
                        style: TextStyle(
                          fontFamily: 'DancingScript',
                          fontWeight: FontWeight.w900,
                          fontSize: 40,
                          color: Colors.white,
                          // shadows: const [
                          //   Shadow(
                          //     color: Colors.white,
                          //     offset: Offset(1, 1),
                          //     blurRadius: 3,
                          //   ),
                          // ],
                        ),

                      )
                    ),
                    Positioned(
                      right: 40,
                      child: IconButton(
                        icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 30,),
                        onPressed: (){
                          loadDiary();
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 30,),
                        onPressed: () {
                          showLogoutDialog();
                        },
                      )
                    )
                  ]
                ),
                SizedBox(height: 10,),
                //Search bar
                Container(
                  width: screenWidth * 0.7, //to make it smaller
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5), //alpha: 0.1
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: midpink,),
                      SizedBox(width: 10,),
                      Expanded(
                        child: GestureDetector(
                          onTap: showSearchDialog,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              "Search journal entries",
                              style: TextStyle(
                                color: midpink,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: darkpink),
                        tooltip: "Clear search", 
                        onPressed: () {
                          isSearching = false;
                          searchText = '';
                          currentpagenum = 1;
                          loadDiary();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Search cleared and reset", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16),), 
                              duration: Duration(seconds: 1), 
                              backgroundColor: darkpink,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ]
            ),
          ),
          //Content 
          Expanded(
            child: diaryList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: midpink,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.book,
                            size: 60,
                            color: lightpink,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkpink,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: diaryList.length,
                    itemBuilder: (_, index) {
                      final item = diaryList[index];
                      return InkWell(
                        onTap: () => showJournalDetailsDialog(item),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: darkpink.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            //alignment: center,
                            children: [
                              //Image
                              SizedBox(
                                width: screenWidth * 0.25,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: loadImageWidget(item.image),
                                ),
                              ),
                              SizedBox(width: 10,),
                              //Content
                              SizedBox(
                                width: screenWidth * 0.50 - 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  //mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: darkpink,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      item.date,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: midpink,
                                      ),
                                    ),
                                  ],
                                ),

                              ),
                              //Action btn
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Edit btn
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            size: 30,
                                            color: midpink,
                                          ),
                                          onPressed: () => editDiaryDialog(item),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            size: 30,
                                            color: const Color.fromARGB(255, 230, 107, 107),
                                          ),
                                          onPressed: () =>
                                              deleteDiaryDialog(item.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Pagination
          if (diaryList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios, 
                      color: currentpagenum > 1 && currentpagenum <= pages
                        ? darkpink 
                        : midpink.withValues(alpha: 0.7),
                    ),
                    onPressed: currentpagenum > 1
                        ? () {
                            setState(() {
                              currentpagenum--;
                            });
                            loadDiary();
                          }
                        : null,
                  ),
                  Text(
                    "Page $currentpagenum of $pages",
                    style: TextStyle(fontWeight: FontWeight.bold,color: darkpink),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios, 
                      color: currentpagenum < pages && currentpagenum >= 1
                      ? darkpink
                      : midpink.withValues(alpha: 0.7) ,
                    ),
                    onPressed: currentpagenum < pages
                        ? () {
                            setState(() {
                              currentpagenum++;
                            });
                            loadDiary();
                          }
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.logout, size: 42, color: Colors.redAccent),
                ),
                const SizedBox(height: 15),
                const Text(
                  "EXIT?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(height: 15),
                Text(
                  "Are you sure you want to exit?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: midpink,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    //cancel btn
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkpink,
                          side: BorderSide(color: darkpink),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    //Logout btn
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkpink,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Exit"),
                        onPressed: () {
                          exit(0);
                        },
                      ),
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
  
  Widget loadImageWidget(String image) {
    if (image == "NA") {
      return const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey,
      );
    }
    final file = File(image);
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.cover)
        : const Icon(Icons.broken_image, size: 40, color: Colors.grey);
  }
  
  Future<void> loadDiary() async {
    setState(() {
      status = "Loading...";
      diaryList = [];
    });
    int offset = (currentpagenum - 1) * limit;

    if (isSearching) {
      // search
      final total = await DatabaseHelper().getSearchCount(searchText);
      pages = (total / limit).ceil();

      diaryList = await DatabaseHelper().searchDiaryList(
        searchText,
        limit,
        offset,
      );

      if (diaryList.isEmpty) {
        status = "No results found.";
      }
    } else {
      // normal
      final total = await DatabaseHelper().getTotalCount();
      pages = (total / limit).ceil();

      diaryList = await DatabaseHelper().getDiaryListsPaginated(limit, offset);

      if (diaryList.isEmpty) {
        status = "No journal found. Press + to add.";
      }
    }

    setState(() {});
  }
  
  void showJournalDetailsDialog(DiaryList item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: screenWidth,
                      width: double.infinity,
                      child: loadImageWidget(item.image),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    item.date,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: midpink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: darkpink
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.notes,
                    style: TextStyle(fontSize: 16, color: midpink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkpink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text("Close"),
                      onPressed: () => Navigator.pop(context),
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
  
  void showSearchDialog() {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: midpink, width: 2),
              boxShadow: [
                BoxShadow(
                  color: midpink,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Search Diary Entry",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:darkpink ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: searchController,
                  autofocus: true,
                  cursorColor: darkpink,    
                  style: TextStyle(color: darkpink),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _performSearch(searchController.text),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: midpink),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              isSearching = false;
                              searchText = '';
                              currentpagenum = 1;
                              loadDiary();
                              setState(() {});
                            },
                          )
                        : null,
                    hintText: "Search by title or description...",
                    hintStyle: TextStyle(color: midpink),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: midpink),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: midpink, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: midpink),
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkpink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: const Text("Search"),
                      onPressed: () {
                        _performSearch(searchController.text);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        );
      },
    );
  }

  Future<void> _performSearch(String text) async {
    searchText = text.trim();
    isSearching = searchText.isNotEmpty;
    currentpagenum = 1;

    diaryList = await DatabaseHelper().searchDiaryList(searchText, limit, 0);
    final total = await DatabaseHelper().getSearchCount(searchText);
    pages = (total / limit).ceil();
    
    status = diaryList.isEmpty ? "No results found." : "";
    setState(() {});
  }

  void editDiaryDialog(DiaryList item) {
    TextEditingController titleController = TextEditingController(
      text: item.title,
    );

    TextEditingController notesController = TextEditingController(
      text: item.notes,
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: midpink, width: 2),
          ),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit Entry",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkpink,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      cursorColor: darkpink,    
                      style: TextStyle(color: darkpink),
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle: TextStyle(color: darkpink),
                        filled: true,
                        fillColor: lightpink,
                        prefixIcon: Icon(Icons.title_outlined, color: darkpink),
                        hintStyle: TextStyle(color: midpink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: midpink),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: darkpink, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: midpink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      cursorColor: darkpink,    
                      style: TextStyle(color: darkpink),
                      controller: notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Description",
                        labelStyle: TextStyle(color: darkpink),
                        //alignLabelWithHint: true,
                        hintStyle: TextStyle(color: darkpink),
                        filled: true,
                        fillColor: lightpink,
                        prefixIcon: Icon(Icons.description_outlined, color: darkpink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: darkpink, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: midpink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkpink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Update"),
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Title cannot be empty.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16),),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            item.title = titleController.text.trim();
                            item.notes = notesController.text.trim();
                            await DatabaseHelper().updateDiaryList(item);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            loadDiary();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  void deleteDiaryDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: lightpink
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.redAccent,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Delete Entry?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(height: 10),
                Text(
                  "This action cannot be undone.\nAre you sure you want to delete this entry?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: darkpink,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: darkpink, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: TextStyle(color: darkpink),),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Delete 
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          await DatabaseHelper().deleteDiaryList(id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.greenAccent,
                                content: Text("Entry deleted successfully", textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 16),),
                              ),
                            );
                          }
                          loadDiary();
                        },
                        child: const Text("Delete"),
                      ),
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
}

  

  