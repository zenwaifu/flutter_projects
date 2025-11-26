class User{
  String? user_id;
  String? user_name;
  String? user_email;
  String? user_password;
  String? user_phone;
  String? user_reg_date;

  User({
    this.user_id,
    this.user_name,
    this.user_email,
    this.user_password,
    this.user_phone,
    this.user_reg_date
  });

  User.fromJson(Map<String, dynamic> json){
    user_id = json['user_id'];
    user_name = json['name'];
    user_email = json['email'];
    user_password = json['password'];
    user_phone = json['phone'];
    user_reg_date = json['reg_date'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = this.user_id;
    data['name'] = this.user_name;
    data['email'] = this.user_email;
    data['password'] = this.user_password;
    data['phone'] = this.user_phone;
    data['reg_date'] = this.user_reg_date;
    return data;
  }
}