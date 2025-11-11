class MyList{
  int id;
  String title;
  String description;
  String status;
  String imagename;

  MyList(this.id, this.title, this.description, this.status, this.imagename);

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'imagename': imagename,
    };
    return map;
  }

  factory MyList.fromMap(Map<String, dynamic> map) {
    return MyList(
      map['id'],
      map['title'],
      map['description'],
      map['status'],
      map['imagename'],
    );
  }
}