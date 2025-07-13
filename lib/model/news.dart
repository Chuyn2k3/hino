import 'dart:ffi';

class News {

  int? newsManagement;
  String? urlImage;
  String? urlLink;

  News({this.newsManagement, this.urlImage, this.urlLink});

  News.fromJson(Map<String, dynamic> json) {
    newsManagement = json['news_management'];
    urlImage = json['url_image'];
    urlLink = json['url_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['news_management'] = this.newsManagement;
    data['url_image'] = this.urlImage;
    data['url_link'] = this.urlLink;
    return data;
  }
}

