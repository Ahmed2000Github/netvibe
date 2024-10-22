import 'package:http/http.dart' as http;
import 'package:netvibe/core/models/net_speed_info.dart';
import 'package:netvibe/enums/speed_type.dart';
import 'package:netvibe/utils/app_utils.dart';

class NetworkSevices {
  Future<NetSpeedInfos> checkDownloadSpeed() async {
    const url =
        'https://i70ava.db.files.1drv.com/y4m5ZRe7WOBM4KkVTY6F9t1rTewofPVzOczGjwXYlWkJsQl3LWmF1Of6UhUi6zgDfXqQXD1buHU80yZv9AuaCalbau8IvqSxfcJifjTxo6bKkOB2g7fHIf2bWxc7v3gAN2L8ggF_cYy65PELqg08-C_ycQPArdG5RF7-34xlQwH-QGyx8Op1ox0IZH66Kg1Fb73Zmlmx7QzS1UiNzKp8DT-WA';
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final elapsed = stopwatch.elapsedMilliseconds;
        final speedInKbps =
            ((response.bodyBytes.length / 1024) / (elapsed / 1000)) * 8;
        return NetSpeedInfos(
            type: SpeedType.DOWNLOAD,
            speed: AppUtils.fromKBytesToMBytes(speedInKbps));
      } else {
        return NetSpeedInfos(
            error:
                "Failed to download the file. Status code: ${response.statusCode}");
      }
    } catch (e) {
      return NetSpeedInfos(error: 'Error: $e');
    }
  }

  Future<NetSpeedInfos> checkUploadSpeed() async {
    int dataSizeInBytes =   512 * 1024;
    List<int> dummyData =
        List<int>.generate(dataSizeInBytes, (index) => index % 256);

    DateTime startTime = DateTime.now();
    try {
      var response = await http.post(
        Uri.parse('https://httpbin.org/post'), // Test endpoint
        headers: {"Content-Type": "application/octet-stream"},
        body: dummyData,
      );

      if (response.statusCode == 200) {
        DateTime endTime = DateTime.now();

        double timeTaken = endTime.difference(startTime).inMilliseconds / 1000;

        final uploadSpeed = (dataSizeInBytes / timeTaken) / (1024 * 1024);
        return NetSpeedInfos(type: SpeedType.UPLOAD, speed: uploadSpeed);
      } else {
        return NetSpeedInfos(
            error:
                "Failed to upload the file. Status code: ${response.statusCode}");
      }
    } catch (e) {
      return NetSpeedInfos(error: 'Error: $e');
    }
  }
}
