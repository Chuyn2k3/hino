class SnapShot {
  int? channelNo;
  String? url;
  String? takePhotoTime;
  double? lat;
  double? lng;
  int? speed;
  String? location;

  SnapShot(
      {this.channelNo,
        this.url,
        this.takePhotoTime,
        this.lat,
        this.lng,
        this.speed,
        this.location});

  SnapShot.fromJson(Map<String, dynamic> json) {
    channelNo = json['channel_no'];
    url = json['url'];
    takePhotoTime = json['take_photo_time'];
    lat = json['lat'];
    lng = json['lng'];
    speed = json['speed'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['channel_no'] = this.channelNo;
    data['url'] = this.url;
    data['take_photo_time'] = this.takePhotoTime;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['speed'] = this.speed;
    data['location'] = this.location;
    return data;
  }
}