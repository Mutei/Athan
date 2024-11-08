import 'package:athan/screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

import '../localization/language_constants.dart';
import '../prayer_time_services.dart';
import '../utils/numeral_convertor.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  Map<String, String>? _prayerTimes;
  String? _errorMessage;
  bool _isLoading = true;

  DateTime _selectedDate = DateTime.now();

  // Connectivity
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _fetchPrayerTimes();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool previousConnection = _isConnected;
    if (result == ConnectivityResult.none) {
      _isConnected = false;
      if (previousConnection != _isConnected) {
        _showNoConnectionDialog();
      }
    } else {
      _isConnected = true;
      if (!previousConnection) {
        _fetchPrayerTimes();
      }
    }
  }

  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslated(context, 'No Internet')),
          content: Text(getTranslated(
              context, 'Please check your internet connection and try again.')),
          actions: <Widget>[
            TextButton(
              child: Text(getTranslated(context, 'Retry')),
              onPressed: () {
                Navigator.of(context).pop();
                _fetchPrayerTimes();
              },
            ),
            TextButton(
              child: Text(getTranslated(context, 'Exit')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchPrayerTimes() async {
    if (!_isConnected) {
      setState(() {
        _isLoading = false;
        _errorMessage = getTranslated(context, "No Internet Connection");
      });
      _showNoConnectionDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final times =
          await _prayerTimesService.getPrayerTimes(date: _selectedDate);
      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });
      _schedulePrayerNotifications(times);
    } catch (e) {
      setState(() {
        _errorMessage = getTranslated(context, 'Error fetching prayer times');
        _isLoading = false;
      });
      _showErrorDialog(_errorMessage!);
    }
  }

  void _schedulePrayerNotifications(Map<String, String> prayerTimes) {
    prayerTimes.forEach((prayer, time) {
      DateTime notificationTime = _parseTimeToToday(time);
      if (notificationTime.isAfter(DateTime.now())) {
        flutterLocalNotificationsPlugin.schedule(
          prayer.hashCode,
          'Prayer Time Alert',
          'It\'s time for $prayer prayer.',
          notificationTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_channel',
              'Prayer Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  DateTime _parseTimeToToday(String time) {
    final DateTime now = DateTime.now();
    final DateFormat timeFormat = DateFormat.jm();
    final DateTime parsedTime = timeFormat.parse(time);
    return DateTime(
        now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslated(context, 'Error')),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(getTranslated(context, 'Retry')),
              onPressed: () {
                Navigator.of(context).pop();
                _fetchPrayerTimes();
              },
            ),
            TextButton(
              child: Text(getTranslated(context, 'Cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  String _translateAmPm(String time) {
    return time
        .replaceAll(RegExp(r'AM', caseSensitive: false), 'ص')
        .replaceAll(RegExp(r'PM', caseSensitive: false), 'م');
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
            'EEEE, MMMM d, yyyy', Localizations.localeOf(context).toString())
        .format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated(context, "Prayer Times")),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen()));
            },
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              formattedDate,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(Duration(days: 1));
                  });
                  _fetchPrayerTimes();
                },
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(Duration(days: 1));
                  });
                  _fetchPrayerTimes();
                },
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView(
                        padding: EdgeInsets.all(16.0),
                        children: _prayerTimes!.entries.map((entry) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Icon(
                                _getPrayerIcon(entry.key),
                                color: _getPrayerIconColor(entry.key),
                              ),
                              title: Text(
                                getTranslated(context, entry.key),
                                style: TextStyle(fontSize: 18),
                              ),
                              trailing: Text(
                                _isArabic(context)
                                    ? convertToArabicNumerals(
                                        _translateAmPm(entry.value))
                                    : entry.value,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_sunny;
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.sunny_snowing;
      case 'sunset':
        return Icons.wb_twilight;
      case 'maghrib':
        return Icons.nights_stay;
      case 'isha':
        return Icons.nightlight_round;
      case 'imsak':
        return Icons.access_time;
      case 'midnight':
        return Icons.hourglass_empty;
      default:
        return Icons.access_time;
    }
  }

  Color? _getPrayerIconColor(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Colors.blue;
      case 'sunrise':
        return Colors.orange;
      case 'dhuhr':
        return Colors.green;
      case 'asr':
        return Colors.yellow;
      case 'sunset':
        return Colors.red;
      case 'maghrib':
        return Colors.purple;
      case 'isha':
        return Colors.indigo;
      default:
        return null;
    }
  }
}
