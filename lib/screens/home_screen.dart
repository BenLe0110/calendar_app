import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/daily_view.dart';
import '../widgets/monthly_view.dart';
import '../widgets/loading_animation.dart';
import '../widgets/status_animation.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
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
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Future.wait([
        _loadEvents(),
        _checkAuthState(),
      ]);
    } catch (e) {
      _showStatusMessage('Failed to initialize app', false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAuthState() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _isLoggedIn = user != null;
      });
    }
  }

  Future<void> _loadEvents() async {
    await _eventService.loadEvents();
  }

  Future<void> _addEvent() async {
    if (!_isLoggedIn) {
      _showAuthDialog();
      return;
    }

    final event = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(
          selectedDate: _selectedDay,
        ),
      ),
    );

    if (event != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _eventService.insertEvent(event);
        _showStatusMessage('Event added successfully', true);
        await _loadEvents();
      } catch (e) {
        _showStatusMessage('Failed to add event', false);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showStatusMessage(String message, bool isSuccess) {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content:
            const Text('Please sign in or create an account to add events.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/register');
            },
            child: const Text('Create Account'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _authService.logout();
      setState(() {
        _isLoggedIn = false;
      });
      _showStatusMessage('Logged out successfully', true);
    } catch (e) {
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
                  color: Colors.white,
                  size: 48,
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
