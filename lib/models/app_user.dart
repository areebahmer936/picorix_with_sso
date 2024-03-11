class AppUser {
  AppUser(
      {required this.userName,
      required this.uid,
      required this.email,
      required this.isOnline,
      required this.mobileNo,
      required this.profilePictureUrl,
      required this.lastOnline});
  late final String userName;
  late final String uid;
  late final String email;
  late final bool isOnline;
  late final String lastOnline;
  late final String mobileNo;
  late final String profilePictureUrl;

  AppUser.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    uid = json['uid'];
    email = json['email'];
    isOnline = json['isOnline'];
    lastOnline = json['lastOnline'] ?? "";
    mobileNo = json['mobileNo'];
    profilePictureUrl = json['profilePictureUrl'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userName'] = userName;
    data['uid'] = uid;
    data['email'] = email;
    data['isOnline'] = isOnline;
    data['lastOnline'] = lastOnline;
    data['mobileNo'] = mobileNo;
    data['profilePictureUrl'] = profilePictureUrl;
    return data;
  }
}
