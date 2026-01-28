import 'package:shelf/shelf.dart';
import 'package:logging/logging.dart';

final _logger = Logger('campusconnect');

Middleware logRequests() {
  return (Handler innerHandler) {
    return (Request request) async {
      final startTime = DateTime.now();
      
      _logger.info('${request.method} ${request.requestedUri}');
      
      try {
        final response = await innerHandler(request);
        final duration = DateTime.now().difference(startTime);
        
        _logger.info(
          '${request.method} ${request.requestedUri} - ${response.statusCode} - ${duration.inMilliseconds}ms'
        );
        
        return response;
      } catch (error, stackTrace) {
        final duration = DateTime.now().difference(startTime);
        
        _logger.severe(
          '${request.method} ${request.requestedUri} - ERROR - ${duration.inMilliseconds}ms',
          error,
          stackTrace,
        );
        
        rethrow;
      }
    };
  };
}
