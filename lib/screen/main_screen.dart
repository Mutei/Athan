// lib/screens/prayer_times_screen.dart

import 'package:athan/widgets/custom_drawer.dart';
import 'package:athan/widgets/reused_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity_plus
import 'dart:async'; // Import dart:async

import '../localization/language_constants.dart';
import '../prayer_time_services.dart';
import '../utils/numeral_convertor.dart'; // Ensure the path is correct

class PrayerTimesScreen extends StatefulWidget {
  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  Map<String, String>? _prayerTimes;
  String? _errorMessage;
  bool _isLoading = true;

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

  // Check the initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(connectivityResult);
  }

  // Update the connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    bool previousConnection = _isConnected;
    if (result == ConnectivityResult.none) {
      _isConnected = false;
      if (previousConnection != _isConnected) {
        _showNoConnectionDialog();
      }
    } else {
      _isConnected = true;
      // Optionally, you can retry fetching prayer times when the connection is restored
      if (!previousConnection) {
        _fetchPrayerTimes();
      }
    }
  }

  // Show Alert Dialog for No Internet Connection
  void _showNoConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
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
                // Optionally, you can exit the app or navigate back
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
      final times = await _prayerTimesService.getPrayerTimes();
      setState(() {
        _prayerTimes = times;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = getTranslated(context, 'Error fetching prayer times');
        _isLoading = false;
      });
      _showErrorDialog(_errorMessage!);
    }
  }

  // Show Error Dialog
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

  // Helper method to translate AM/PM to Arabic
  String _translateAmPm(String time) {
    return time
        .replaceAll(RegExp(r'AM', caseSensitive: false), 'ص')
        .replaceAll(RegExp(r'PM', caseSensitive: false), 'م');
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
            'EEEE, MMMM d, yyyy', Localizations.localeOf(context).toString())
        .format(DateTime.now());

    return Scaffold(
      appBar: ReusedAppBar(
        title: getTranslated(context, 'Prayer Times'), // Use translated title
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              formattedDate,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
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
                                getTranslated(context,
                                    entry.key), // Translate prayer names
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
