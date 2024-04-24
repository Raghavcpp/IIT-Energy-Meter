import 'dart:convert';

import 'package:influxdb_client/api.dart';

class InfluxService {
  late InfluxDBClient client;
  late QueryService queryService;
  InfluxService() {
    client = InfluxDBClient(
        url: 'http://10.17.51.12:8086',
        token:
            'gD5kuHNGXz9MGzeRlJ7MGT0wPa7bNlLQ8eS8giLyqx1wXURon3ZWQ1DfyTdJ8asm1WDvgiEYgjvvhH2sZDD9pw==',
        org: 'IIT-Delhi',
        bucket: 'iitdenergy',
        debug: true);
    queryService = client.getQueryService();
  }

  Future<void> getInfluxData(String time, String sensorId) async {
    String query = '''
from(bucket: "iitdenergy")
    |> range(start: -$time)
    |> filter(fn: (r) => r["_measurement"] == "mqtt_consumer")
    |> filter(fn: (r) => r["_field"] == "AvgPF" or r["_field"] == "Freq" or r["_field"] == "I1" or r["_field"] == "I2" or r["_field"] == "I3" or r["_field"] == "PF1" or r["_field"] == "PF2" or r["_field"] == "PF3" or r["_field"] == "TkVA" or r["_field"] == "TkVAr" or r["_field"] == "TkW" or r["_field"] == "V1N" or r["_field"] == "V2N" or r["_field"] == "V3N" or r["_field"] == "kW1" or r["_field"] == "kW2" or r["_field"] == "kW3" or r["_field"] == "kWh")
    |> filter(fn: (r) => r["topic"] == "/devices/swsn/FSM-$sensorId")
    |> filter(fn: (r) => r["host"] == "baadalvm")
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
    |> yield(name: "results")
''';
    var recordStream = await queryService.query(query);
    var recordList = await recordStream.toList();
    print(jsonEncode(recordList));
    // var count = 0;
    // await recordStream.forEach((record) {
    //   print(
    //       'record: ${count++} ${record['_time']}: ${record['host']} ${record['cpu']} ${record['_value']}');
    // });
  }
}
