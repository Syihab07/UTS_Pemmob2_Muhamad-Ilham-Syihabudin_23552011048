import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      final deviceSupport = await FlutterQiblah.androidDeviceSensorSupport();

      setState(() {
        _hasPermission = deviceSupport ?? false;
        _isLoading = false;
        if (!_hasPermission) {
          _errorMessage = 'Device does not support compass sensor';
        }
      });
    } else {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
        _errorMessage = 'Location permission is required';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Direction'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasPermission
          ? const QiblaCompass()
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await openAppSettings();
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Open Settings'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class QiblaCompass extends StatelessWidget {
  const QiblaCompass({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final qiblahDirection = snapshot.data;

        if (qiblahDirection == null) {
          return const Center(child: Text('Unable to get Qibla direction'));
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Point your device to',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'QIBLA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00897B),
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: (qiblahDirection.direction * (pi / 180) * -1),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00897B),
                          width: 3,
                        ),
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 10,
                            child: Icon(
                              Icons.navigation,
                              size: 60,
                              color: Color(0xFF00897B),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Text(
                              'S',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            child: Text(
                              'W',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            child: Text(
                              'E',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00897B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${qiblahDirection.direction.toStringAsFixed(1)}°',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                qiblahDirection.offset < 5
                    ? '✓ Facing Qibla'
                    : 'Rotate your device',
                style: TextStyle(
                  fontSize: 18,
                  color: qiblahDirection.offset < 5
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
