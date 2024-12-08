// import 'dart:io';
// import 'package:process_run/process_run.dart';
// import 'package:logging/logging.dart';

// class TraceRouteService {
//   // Create a logger
//   final Logger _logger = Logger('TraceRouteService');

//   Future<List<Map<String, dynamic>>> performTraceRoute(
//       String destination) async {
//     try {
//       // Validate destination
//       if (destination.isEmpty) {
//         throw ArgumentError('Destination cannot be empty');
//       }

//       if (!_isValidDestination(destination)) {
//         throw FormatException('Invalid destination format');
//       }

//       // Determine the appropriate traceroute command based on the operating system
//       String command;
//       List<String> args;
//       if (Platform.isWindows) {
//         command = 'tracert';
//         args = [destination]; // Windows tracert command
//       } else if (Platform.isLinux || Platform.isMacOS) {
//         command = 'traceroute';
//         args = [destination]; // Unix-like traceroute command
//       } else {
//         throw UnsupportedError('Traceroute not supported on this platform');
//       }

//       _logger.info('Executing traceroute command: $command $destination');

//       // Run the traceroute command
//       var result = await _runCommand(command, args);

//       // Log raw output
//       _logRawOutput(result);

//       // Parse the traceroute output
//       List<Map<String, dynamic>> hops = _parseTracerouteOutput(result);

//       _logger.info('Traceroute completed. Found ${hops.length} hops.');
//       return hops;
//     } catch (e) {
//       _logger.severe('Error performing traceroute to $destination', e);
//       rethrow;
//     }
//   }

//   // Validate destination format
//   bool _isValidDestination(String destination) {
//     // Basic validation to prevent injection and ensure valid format
//     final validDestinationRegex = RegExp(
//       r'^[a-zA-Z0-9.-]+(\.[a-zA-Z]{2,})+$|^(\d{1,3}\.){3}\d{1,3}$',
//     );
//     return validDestinationRegex.hasMatch(destination);
//   }

//   // Log raw traceroute output for debugging
//   void _logRawOutput(String output) {
//     _logger.info('Raw Traceroute Output:\n$output');
//   }

//   // Run the command and return the output
//   Future<String> _runCommand(String command, List<String> args) async {
//     // Use runExecutableArguments instead of the deprecated run
//     var result = await runExecutableArguments(command, args);

//     // Access stdout from the result and return as a string
//     return result.stdout.toString();
//   }

//   // Parse the traceroute output into a structured format
//   List<Map<String, dynamic>> _parseTracerouteOutput(String output) {
//     List<Map<String, dynamic>> hops = [];
//     List<String> lines = output.split('\n');

//     // Parsing logic differs slightly between Windows and Unix-like systems
//     if (Platform.isWindows) {
//       // Windows tracert output parsing
//       for (var line in lines) {
//         // Skip header lines and empty lines
//         if (line.contains('Tracing route to') || line.trim().isEmpty) continue;

//         // Basic parsing of Windows tracert output
//         RegExp hopRegex = RegExp(
//             r'\s*(\d+)\s+(\d+\s*ms|\*)\s+(\d+\s*ms|\*)\s+(\d+\s*ms|\*)\s+(\d+\.\d+\.\d+\.\d+)?');
//         var match = hopRegex.firstMatch(line);

//         if (match != null) {
//           String ip = match.group(5) ?? 'Unknown';
//           String time = _extractTime(match.group(2) ?? '*');

//           hops.add({
//             'hop': 'Hop ${hops.length + 1}',
//             'ip': ip,
//             'time': time,
//           });
//         }
//       }
//     } else {
//       // Unix-like tracert output parsing
//       for (var line in lines) {
//         // Skip header lines and empty lines
//         if (line.contains('traceroute to') || line.trim().isEmpty) continue;

//         // Basic parsing of Unix tracert output
//         RegExp hopRegex = RegExp(
//             r'\s*(\d+)\s+(\d+\.\d+\.\d+\.\d+)\s+\((.*?)\)\s+([\d.]+\s*ms)');
//         var match = hopRegex.firstMatch(line);

//         if (match != null) {
//           String ip = match.group(2) ?? 'Unknown';
//           String time = match.group(4) ?? 'Unknown';

//           hops.add({
//             'hop': 'Hop ${hops.length + 1}',
//             'ip': ip,
//             'time': time,
//           });
//         }
//       }
//     }

//     return hops;
//   }

//   String _extractTime(String timeStr) {
//     // Extract the first time value or return '*' if no time found
//     if (timeStr == '*') return timeStr;

//     RegExp timeRegex = RegExp(r'(\d+)\s*ms');
//     var match = timeRegex.firstMatch(timeStr);

//     return match != null ? '${match.group(1)}ms' : 'Unknown';
//   }
// }
