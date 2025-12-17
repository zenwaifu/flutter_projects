class DiaryList {
  int id;
  String title;
  String notes;
  String date;
  String image;

  DiaryList(
    this.id,
    this.title,
    this.notes,
    this.date,
    this.image,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'date': date,
      'image': image,
    };
  }

  factory DiaryList.fromMap(Map<String, dynamic> map) {
    return DiaryList(
      map['id'],
      map['title'],
      map['notes'],
      map['date'],
      map['image'],
    );
  }
}