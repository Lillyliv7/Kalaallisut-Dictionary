import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'variables.dart';

class CacheEntry {
  late String req;
  late String type;
  late String? join;
  late String res;
}

String? getCache(String req, String type, String? join) {
  for (CacheEntry obj in cache) {
    if (req == obj.req && type == obj.type) {
      if (join != null && join == obj.join) {
        return obj.res;
      } else if (join == null) {
        return obj.res;
      }
    }
  }
  return null;
}

void saveCache(String req, String res, String type, String? join) {
  CacheEntry entry = CacheEntry();
  entry.req = req;
  entry.res = res;
  entry.type = type;
  entry.join = join;

  cache.add(entry);

  return;
}
