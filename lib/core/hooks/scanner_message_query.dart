//necessary imports
import 'package:flutter/cupertino.dart';
import 'package:fquery/fquery.dart';
import '../../app_networking.dart';
import '../models/scanner_message.dart';

//api endpoint from services folder file
const String baseEndpoint =
    'https://api-qa.ucsd.edu:8243/scandata/2.0.0/scanData/myrecentscan';

//function that returns a UseQueryResult that contains scannerMessageModel
//and the function requires an access token
UseQueryResult<ScannerMessageModel, dynamic> useFetchScannerMessageModel(
    String accessToken) {
  return useQuery(['scanner_message'], () async {
    //fetches data from endpoint using authorizedFetch from the NetworkHelper
    //http class method with a header and stored in '_response'
    String _response = await NetworkHelper().authorizedFetch(
        baseEndpoint, {"Authorization": 'Bearer $accessToken'});

    debugPrint("ScannerMessageModel Query Hook: Fetching Data!");

    //parse data, decoding '_response'  from json
    final data = scannerMessageModelFromJson(_response);
    return data;
  });
}
