class Adoption {
  String? adoptionId;
  String? petId;
  String? userId;
  String? ownerId;
  String? motivation;
  String? status; // pending, approved, rejected
  String? adoptionDate;
  String? updatedAt;

  // Pet info
  String? petName;
  String? petType;
  String? petImage;
  
  // Owner info
  String? ownerName;
  String? ownerEmail;
  String? ownerPhone;
  
  // Requester info
  String? requesterName;
  String? requesterEmail;
  String? requesterPhone;

  Adoption({
    this.adoptionId,
    this.petId,
    this.userId,
    this.ownerId,
    this.motivation,
    this.status,
    this.adoptionDate,
    this.updatedAt,
    this.petName,
    this.petType,
    this.petImage,
    this.ownerName,
    this.ownerEmail,
    this.ownerPhone,
    this.requesterName,
    this.requesterEmail,
    this.requesterPhone,
  });

  Adoption.fromJson(Map<String, dynamic> json) {
    adoptionId = json['adoption_id']?.toString();
    petId = json['pet_id']?.toString();
    userId = json['user_id']?.toString();
    ownerId = json['owner_id']?.toString();
    motivation = json['motivation'];
    status = json['status'];
    adoptionDate = json['created_at'];
    updatedAt = json['updated_at'];
    
    // Pet info
    petName = json['pet_name'];
    petType = json['pet_type'];
    petImage = json['pet_image'];
    
    // Owner info
    ownerName = json['owner_name'];
    ownerEmail = json['owner_email'];
    ownerPhone = json['owner_phone'];
    
    // Requester info
    requesterName = json['requester_name'];
    requesterEmail = json['requester_email'];
    requesterPhone = json['requester_phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adoption_id'] = adoptionId;
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['owner_id'] = ownerId;
    data['motivation'] = motivation;
    data['status'] = status;
    data['created_at'] = adoptionDate;
    data['updated_at'] = updatedAt;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['pet_image'] = petImage;
    data['owner_name'] = ownerName;
    data['owner_email'] = ownerEmail;
    data['owner_phone'] = ownerPhone;
    data['requester_name'] = requesterName;
    data['requester_email'] = requesterEmail;
    data['requester_phone'] = requesterPhone;
    return data;
  }
}