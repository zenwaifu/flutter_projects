class Donation {
  String? donationId;
  String? petId;
  String? userId;
  String? donationType; // Food, Medical, Money
  String? amount; // for money donations
  String? description; // for food/medical donations
  String? donationDate;

  // Pet info
  String? petName;
  String? petType;
  String? petImage;
  
  // User info
  String? userName;
  String? userEmail;
  String? userPhone;

  Donation({
    this.donationId,
    this.petId,
    this.userId,
    this.donationType,
    this.amount,
    this.description,
    this.donationDate,
    this.petName,
    this.petType,
    this.petImage,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  Donation.fromJson(Map<String, dynamic> json) {
    donationId = json['donation_id']?.toString();
    petId = json['pet_id']?.toString();
    userId = json['user_id']?.toString();
    donationType = json['donation_type'];
    amount = json['amount']?.toString();
    description = json['description'];
    donationDate = json['created_at'];
    
    // Pet info
    petName = json['pet_name'];
    petType = json['pet_type'];
    petImage = json['pet_image'];
    
    // User info
    userName = json['user_name'];
    userEmail = json['user_email'];
    userPhone = json['user_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['donation_id'] = donationId;
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['donation_type'] = donationType;
    data['amount'] = amount;
    data['description'] = description;
    data['created_at'] = donationDate;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['pet_image'] = petImage;
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['user_phone'] = userPhone;
    return data;
  }
}