class MyList {
  int id;
  String title;
  String description;
  String status;
  String date;
  String imagename;

  MyList(
    this.id,
    this.title,
    this.description,
    this.status,
    this.date,
    this.imagename,
/*************  ✨ Windsurf Command ⭐  *************/
  /// Convert MyList object to a map for database operations.
  ///
  /// Return a map containing the following key-value pairs:
  /// - 'title': the title of the item
  /// - 'description': the description of the item
  /// - 'status': the status of the item
  /// - 'date': the date the item was created
  /// - 'imagename': the name of the image associated with the item
/*******  1198fdd0-b7f9-45ea-8e10-c84e6d3be389  *******/  );
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'date': date,
      'imagename': imagename,
    };
  }

  factory MyList.fromMap(Map<String, dynamic> map) {
    return MyList(
      map['id'],
      map['title'],
      map['description'],
      map['status'],
      map['date'],
      map['imagename'],
    );
  }
}