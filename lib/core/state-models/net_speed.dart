import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:netvibe/core/models/net_speed_info.dart';
import 'package:netvibe/enums/speed_type.dart';
import 'package:netvibe/services/network_speed.dart';

class NetSpeedProvider extends ChangeNotifier {
  final netServices = GetIt.I<NetworkSevices>();
  NetSpeedInfos _netSpeedInfos = NetSpeedInfos();
  NetSpeedInfos get netSpeedInfos => _netSpeedInfos;

  startTest(SpeedType type) async {
    if (type == SpeedType.DOWNLOAD) {
    _netSpeedInfos = await netServices.checkDownloadSpeed();
    } else  {
       _netSpeedInfos = await netServices.checkUploadSpeed();
    } 

    notifyListeners();
  }
}
