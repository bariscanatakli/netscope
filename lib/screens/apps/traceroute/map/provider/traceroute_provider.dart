// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/traceroute_state.dart';
// import '../services/trace_route_service.dart';
// import '../services/notification_service.dart';

// final tracerouteProvider =
//     StateNotifierProvider<TracerouteNotifier, TracerouteState>((ref) {
//   return TracerouteNotifier(
//     TracerouteService(),
//     NotificationService(),
//   );
// });

// class TracerouteNotifier extends StateNotifier<TracerouteState> {
//   final TracerouteService _tracerouteService;
//   final NotificationService _notificationService;

//   TracerouteNotifier(this._tracerouteService, this._notificationService)
//       : super(const TracerouteState()) {
//     _notificationService.initialize();
//   }

//   Future<void> startTraceroute(String address) async {
//     if (state.isLoading) return;

//     state = state.copyWith(
//       isLoading: true,
//       targetAddress: address,
//       error: null,
//       isCompleted: false,
//     );

//     try {
//       await for (final hop in _tracerouteService.trace(address)) {
//         final currentResults = List<Map<String, dynamic>>.from(state.results);
//         currentResults.add(hop);
//         state = state.copyWith(results: currentResults);
//       }

//       state = state.copyWith(
//         isLoading: false,
//         isCompleted: true,
//       );

//       _notificationService.showNotification(
//         'Traceroute Complete',
//         'Traceroute to $address has finished',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         error: e.toString(),
//         isLoading: false,
//       );
//     }
//   }

//   void reset() {
//     state = const TracerouteState();
//   }
// }
