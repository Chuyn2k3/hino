import 'package:hino/api/api.dart';
import 'package:intl/intl.dart';

class TimeAgo {
  static String timeAgoSinceDate(String dateString,
      {bool numericDates = true}) {
    try {
      DateTime notificationDate =
          DateFormat("yyyy-MM-dd HH:mm:ss").parseUTC(dateString).toLocal();
      final date2 = DateTime.now();
      final difference = date2.difference(notificationDate);
      if (Api.language == "vi") {
        if (difference.inDays > 8) {
          return dateString;
        } else if ((difference.inDays / 7).floor() >= 1) {
          return (numericDates) ? '1 tuần trước' : 'Tuần trước';
        } else if (difference.inDays >= 2) {
          return '${difference.inDays} ngày trước';
        } else if (difference.inDays >= 1) {
          return (numericDates) ? '1 ngày trước' : 'Hôm qua';
        } else if (difference.inHours >= 2) {
          return '${difference.inHours} giờ trước';
        } else if (difference.inHours >= 1) {
          return (numericDates) ? '1 giờ trước' : 'Một giờ trước';
        } else if (difference.inMinutes >= 2) {
          return '${difference.inMinutes} phút trước';
        } else if (difference.inMinutes >= 1) {
          return (numericDates) ? '1 phút trước' : 'Một phút trước';
        } else if (difference.inSeconds >= 3) {
          return '${difference.inSeconds} giây trước';
        } else {
          return 'Ngay lúc này';
        }
      } else {
        if (difference.inDays > 8) {
          return dateString;
        } else if ((difference.inDays / 7).floor() >= 1) {
          return (numericDates) ? '1 week ago' : 'Last week';
        } else if (difference.inDays >= 2) {
          return '${difference.inDays} days ago';
        } else if (difference.inDays >= 1) {
          return (numericDates) ? '1 day ago' : 'Yesterday';
        } else if (difference.inHours >= 2) {
          return '${difference.inHours} hours ago';
        } else if (difference.inHours >= 1) {
          return (numericDates) ? '1 hour ago' : 'An hour ago';
        } else if (difference.inMinutes >= 2) {
          return '${difference.inMinutes} minutes ago';
        } else if (difference.inMinutes >= 1) {
          return (numericDates) ? '1 minute ago' : 'A minute ago';
        } else if (difference.inSeconds >= 3) {
          return '${difference.inSeconds} seconds ago';
        } else {
          return 'Just now';
        }

      }
    } catch (e) {
      return dateString;
    }
  }

  static String timeAgoSinceDateNoti(String dateString,
      {bool numericDates = true}) {
    try {
      DateTime notificationDate =
          DateFormat("dd MMM yy").parseUTC(dateString).toLocal();
      final date2 = DateTime.now();
      print("notificationDate:" + notificationDate.toString());
      print("date:" + date2.toString());

      if (date2.day == notificationDate.day) {
        if(Api.language == "en"){
          return "Today";
        }else{
          return "Hôm nay";
        }

      } else if (date2.subtract(Duration(days: 1)).day ==
          notificationDate.day) {
        if(Api.language == "en"){
          return "Yesterday";
        } else{
          return "Hôm qua";
        }
      } else {
        return dateString;
      }
    } catch (e) {
      print(e);
      return "";
    }
  }
}
