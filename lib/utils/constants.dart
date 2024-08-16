
import 'package:flutter_dotenv/flutter_dotenv.dart' ; 

class Constants{

  static String? baseUrl = dotenv.env['BASE_URL'];
}