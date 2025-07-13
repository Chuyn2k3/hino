class LastEvaluatedKey {
  int? eventId;
  int? gpsdateUnix;
  int? custId;
  String? unix;

  LastEvaluatedKey({this.eventId, this.gpsdateUnix, this.custId, this.unix});

  LastEvaluatedKey.fromJson(Map<String, dynamic> json) {
    eventId = json['event_id'];
    gpsdateUnix = json['gpsdate_unix'];
    custId = json['cust_id'];
    unix = json['unix'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['event_id'] = this.eventId;
    data['gpsdate_unix'] = this.gpsdateUnix;
    data['cust_id'] = this.custId;
    data['unix'] = this.unix;
    return data;
  }
}