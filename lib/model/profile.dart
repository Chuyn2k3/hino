class UserTokenInfo {
  String? accessToken;
  String? expiresIn;
  String? idToken;
  String? refreshToken;
  String? tokenType;

  UserTokenInfo.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    expiresIn = json['expiresIn']?.toString();
    idToken = json['idToken'];
    refreshToken = json['refreshToken'];
    tokenType = json['tokenType'];
  }
}

class UserAction {
  int? actionId;
  int? actionLevelMax;

  UserAction.fromJson(Map<String, dynamic> json) {
    actionId = json['actionId'];
    actionLevelMax = json['actionLevelMax'];
  }
}

class Profile {
  var userId;
  var userLevelId;
  var displayName;
  var avatarUrl;
  var mobile;
  var email;

  var lineId;
  var expiredDate;
  var lastChangePassword;
  var defaultLanguageId;
  var language;
  var redisKey;

  UserTokenInfo? userTokenInfo;
  List<UserAction>? userActions;

  Profile.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userLevelId = json['userLevelId'];
    displayName = json['displayName'];
    avatarUrl = json['avatarUrl'];
    mobile = json['mobile'];
    email = json['email'];
    lineId = json['lineId'];
    expiredDate = json['expiredDate'];
    lastChangePassword = json['lastChangePassword'];
    defaultLanguageId = json['defaultLanguageId'];
    language = json['language'];
    redisKey = json['redisKey'];

    if (json['userTokenInfo'] != null) {
      userTokenInfo = UserTokenInfo.fromJson(json['userTokenInfo']);
    }

    if (json['userActions'] != null) {
      userActions = (json['userActions'] as List)
          .map((e) => UserAction.fromJson(e))
          .toList();
    }
  }
}
