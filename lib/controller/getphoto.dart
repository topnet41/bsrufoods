class Getphoto {
  String name;
  String firstName;
  String lastName;
  Picture picture;
  String email;
  String id;

  Getphoto(
      {this.name,
      this.firstName,
      this.lastName,
      this.picture,
      this.email,
      this.id});

  Getphoto.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    picture =
        json['picture'] != null ? new Picture.fromJson(json['picture']) : null;
    email = json['email'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    if (this.picture != null) {
      data['picture'] = this.picture.toJson();
    }
    data['email'] = this.email;
    data['id'] = this.id;
    return data;
  }
}

class Picture {
  Data data;

  Picture({this.data});

  Picture.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  int height;
  bool isSilhouette;
  String url;
  int width;

  Data({this.height, this.isSilhouette, this.url, this.width});

  Data.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    isSilhouette = json['is_silhouette'];
    url = json['url'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['is_silhouette'] = this.isSilhouette;
    data['url'] = this.url;
    data['width'] = this.width;
    return data;
  }
}
