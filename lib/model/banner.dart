class BannerHino {
  int? bannerId;
  String? urlImage;
  String? urlLink;

  BannerHino({this.bannerId, this.urlImage, this.urlLink});

  BannerHino.fromJson(Map<String, dynamic> json) {
    bannerId = json['banner_id'];
    urlImage = json['url_image'];
    urlLink = json['url_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['banner_id'] = this.bannerId;
    data['url_image'] = this.urlImage;
    data['url_link'] = this.urlLink;
    return data;
  }
}