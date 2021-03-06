final bool isProd = const bool.fromEnvironment('dart.vm.product');

final String apiHost = isProd ? 'http://47.103.79.180:80' : 'http://192.168.1.4:7001';
