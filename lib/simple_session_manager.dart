import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const kDefaultTimeout = 5;

/// This SessionManager Monitors the users inactivity and calls the registered
/// callbacks for the corresponding functionalities
///
/// Wrap your Material Widget with this Widget
class SimpleSessionManager extends StatefulWidget {

  /// Your MaterialApp widget or the corresponding root widget
  final Widget child;

  /// Whether to Monitor Inactivity
  final bool inactivity;

  /// Duration before Inactivity Timeout (Duration)
  final Duration inactivityTimeoutDuration;

  /// Whether to Monitor Inactivity
  final bool sessionMonitor;

  /// Duration before Session Timeout (Duration)
  final Duration sessionTimeoutDuration;

  /// Callback for session Expiration
  final VoidCallback? onSessionTimeout;

  /// Callback for Inactivity Expiration
  final VoidCallback? onInactivityTimeout;

  /// Boolean to disable or enable logging
  final bool enableLogging;

  const SimpleSessionManager({
    Key? key,
    required this.child,
    this.inactivity = false,
    this.inactivityTimeoutDuration = const Duration(minutes: kDefaultTimeout),
    this.sessionMonitor = true,
    this.sessionTimeoutDuration = const Duration(minutes: kDefaultTimeout),
    this.onSessionTimeout,
    this.onInactivityTimeout,
    this.enableLogging = kDebugMode,
  }) : super(key: key);

  @override
  State<SimpleSessionManager> createState() => _SimpleSessionManagerState();
}

class _SimpleSessionManagerState extends State<SimpleSessionManager>
    with WidgetsBindingObserver {

  Timer? _inactivityTimer;
  Timer? _sessionTimer;

  /// Inactivity Monitor
  void _startInactivityTimer() {
    _inactivityTimer?.cancel(); // Reset the timer if already started.
    _inactivityTimer = Timer(widget.inactivityTimeoutDuration, () {
      // getLogger("App Keep Alive Observer").v("Timer Elapsed");
      if (widget.onInactivityTimeout != null){
        widget.onInactivityTimeout!();
      }
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel(); // Reset the timer if already started.
    _sessionTimer = Timer(widget.sessionTimeoutDuration, () {
      if (widget.onSessionTimeout != null){
        widget.onSessionTimeout!();
      }
    });
  }

  /// Reset the inactivity timer when a user interaction occurs.
  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  /// Stops the session timer when the user is back into the app
  void _stopSessionTimer() {
    _sessionTimer?.cancel();
  }


  @override
  void initState() {
    /// Only use the timer resource when necessary
    if (widget.inactivity){
      _startInactivityTimer();
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (widget.sessionMonitor){
          _stopSessionTimer();
        }

      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        if (widget.sessionMonitor){
          _startSessionTimer();
        }
        break;
    }

    if (widget.inactivity){
      _startInactivityTimer();
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.inactivity){
      _inactivityTimer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (_) {
          if (widget.inactivity){
            _resetInactivityTimer();
          }
        },
        child: widget.child);
  }
}
