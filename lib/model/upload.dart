class Upload {
  var name;
  var fileName;

  Upload(
      {this.name,
      this.fileName,});

  Upload.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fileName = json['file_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['file_name'] = this.fileName;
    return data;
  }
}
