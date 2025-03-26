import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/event_service.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/common/animations/loading_animation.dart';
import 'package:calendar_app/widgets/common/animations/status_animation.dart';
import 'package:calendar_app/widgets/calendar/views/daily_view.dart';
import 'package:calendar_app/widgets/calendar/views/monthly_view.dart';
import 'package:calendar_app/services/auth_service.dart';
import 'package:calendar_app/services/logging_service.dart';
import 'package:logging/logging.dart';
import 'event_form_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  final _log = LoggingService.getLogger('HomeScreen');
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isMonthlyView = false;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _statusMessage;
  bool? _isSuccess;

  @override
  void initState() {
    super.initState();
    _log.info('Initializing HomeScreen');
    // Delay initialization to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Check auth state first
      await _checkAuthState();

      // Only load events if we're still mounted
      if (mounted) {
        await _loadEvents();
      }
    } catch (e, stackTrace) {
      _log.severe('Error initializing home screen', e, stackTrace);
      if (mounted) {
        _showStatusMessage('Failed to initialize app', false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAuthState() async {
    try {
      _log.info('Checking authentication state');
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
        });
        _log.info(
            'Auth state updated: ${_isLoggedIn ? 'Logged in' : 'Not logged in'}');
      }
    } catch (e, stackTrace) {
      _log.severe('Error checking auth state', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
  }

  Future<void> _loadEvents() async {
    try {
      _log.info('Loading events for selected day: $_selectedDay');
      await _eventService.loadEvents();
      _log.info('Events loaded successfully');
    } catch (e, stackTrace) {
      _log.severe('Error loading events', e, stackTrace);
      if (mounted) {
        _showStatusMessage('Failed to load events', false);
      }
    }
  }

  Future<void> _addEvent() async {
    _log.info('Opening event form for date: $_selectedDay');
    // Allow event creation without login
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(
          selectedDate: _selectedDay,
          isLoggedIn: _isLoggedIn,
        ),
      ),
    );

    if (result == true) {
      _log.info('Event form returned success, reloading events');
      await _loadEvents();
      _showStatusMessage('Event added successfully', true);
    } else {
      _log.info('Event form returned without success');
    }
  }

  void _showStatusMessage(String message, bool isSuccess) {
    _log.info('Showing status message: $message (Success: $isSuccess)');
    setState(() {
      _statusMessage = message;
      _isSuccess = isSuccess;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
          _isSuccess = null;
        });
      }
    });
  }

  void _showAuthDialog() {
    _log.info('Showing authentication dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'Login is required to sync with external calendars (Google, Outlook, iCloud).',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _log.info('Auth dialog cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _log.info('Auth dialog: Proceeding to login screen');
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      _log.info('Initiating logout process');
      setState(() {
        _isLoading = true;
      });
      await _authService.logout();
      setState(() {
        _isLoggedIn = false;
      });
      _log.info('Logout successful');
      _showStatusMessage('Logged out successfully', true);
    } catch (e, stackTrace) {
      _log.severe('Error during logout', e, stackTrace);
      _showStatusMessage('Failed to logout', false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.fine('Building HomeScreen');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(_isLoggedIn ? Icons.person : Icons.person_outline),
            onPressed: () {
              if (_isLoggedIn) {
                _logout();
              } else {
                _showAuthDialog();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: AppTheme.standardPadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            _log.fine('Navigating to previous day');
                            setState(() {
                              _selectedDay = _selectedDay.subtract(
                                const Duration(days: 1),
                              );
                              _focusedDay = _selectedDay;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            _log.fine('Navigating to next day');
                            setState(() {
                              _selectedDay = _selectedDay.add(
                                const Duration(days: 1),
                              );
                              _focusedDay = _selectedDay;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(_isMonthlyView
                              ? Icons.calendar_today
                              : Icons.calendar_month),
                          onPressed: () {
                            _log.info(
                                'Switching view mode to: ${_isMonthlyView ? 'daily' : 'monthly'}');
                            setState(() {
                              _isMonthlyView = !_isMonthlyView;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isMonthlyView
                    ? MonthlyView(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                      )
                    : DailyView(
                        selectedDay: _selectedDay,
                        onDaySelected: (day) {
                          setState(() {
                            _selectedDay = day;
                            _focusedDay = day;
                          });
                        },
                      ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingAnimation(
                  duration: const Duration(milliseconds: 500),
                ),
              ),
            ),
          if (_statusMessage != null && _isSuccess != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: StatusAnimation(
                isSuccess: _isSuccess!,
                message: _statusMessage!,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
