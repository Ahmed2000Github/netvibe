import 'package:netvibe/enums/speed_type.dart';

class NetSpeedInfos {
  NetSpeedInfos({this.error, this.speed, this.type});
  String? error;
  double? speed;
  SpeedType? type;
}
