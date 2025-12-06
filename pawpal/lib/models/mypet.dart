class MyPet {
  String? petId;
  String? user_id;
  String? petName;
  String? petType;
  String? petCategory;
  String? petDescription;
  String? imagePaths;
  String? latitude;
  String? longitude;
  String? dateCreated;

  //Add user info
  String? user_name;
  String? user_email;
  String? user_phone;
  String? user_reg_date;


  MyPet({
    this.petId,
    this.user_id,
    this.petName,
    this.petType,
    this.petCategory,
    this.petDescription,
    this.imagePaths,
    this.latitude,
    this.longitude,
    this.dateCreated,
    this.user_name,
    this.user_email,
    this.user_phone,
    this.user_reg_date,
  });

  MyPet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    user_id = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    petCategory = json['category'];
    petDescription = json['description'];
    imagePaths = json['image_paths'];
    latitude = json['lat'];
    longitude = json['lng'];
    dateCreated = json['created_at'];

    //mapping user fields
    user_name = json['name'];
    user_email = json['email'];
    user_phone = json['phone'];
    user_reg_date = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = user_id;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = petCategory;
    data['description'] = petDescription;
    data['image_paths'] = imagePaths;
    data['lat'] = latitude;
    data['lng'] = longitude;
    data['created_at'] = dateCreated;

    //user fields
    data['name'] = user_name;
    data['email'] = user_email;
    data['phone'] = user_phone;
    data['reg_date'] = user_reg_date;

    return data;
  }
}