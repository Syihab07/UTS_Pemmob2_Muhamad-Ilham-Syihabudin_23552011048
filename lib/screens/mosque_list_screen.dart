import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

class MosqueListScreen extends StatefulWidget {
  const MosqueListScreen({super.key});

  @override
  State<MosqueListScreen> createState() => _MosqueListScreenState();
}

class _MosqueListScreenState extends State<MosqueListScreen> {
  final List<Map<String, dynamic>> mosques = [
    {
      'name': 'Masjid Istiqlal',
      'location': 'Jakarta Pusat',
      'distance': '2.5 km',
      'image': Icons.mosque,
      'capacity': '120,000 jamaah',
    },
    {
      'name': 'Masjid Al-Azhar',
      'location': 'Jakarta Selatan',
      'distance': '5.3 km',
      'image': Icons.mosque,
      'capacity': '10,000 jamaah',
    },
    {
      'name': 'Masjid Agung Bandung',
      'location': 'Bandung',
      'distance': '8.1 km',
      'image': Icons.mosque,
      'capacity': '15,000 jamaah',
    },
    {
      'name': 'Masjid Raya Bandung',
      'location': 'Bandung Timur',
      'distance': '12.0 km',
      'image': Icons.mosque,
      'capacity': '8,000 jamaah',
    },
    {
      'name': 'Masjid At-Taqwa',
      'location': 'Cimahi',
      'distance': '15.2 km',
      'image': Icons.mosque,
      'capacity': '5,000 jamaah',
    },
  ];

  PrayerTimes? _prayerTimes;

  @override
  void initState() {
    super.initState();
    _calculatePrayerTimes();
  }

  void _calculatePrayerTimes() {
    final coordinates = Coordinates(-6.2088, 106.8456); // Jakarta
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(coordinates, params);

    setState(() {
      _prayerTimes = prayerTimes;
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Mosques'), centerTitle: true),
      body: Column(
        children: [
          // Prayer Times Card
          if (_prayerTimes != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF004D40)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Prayer Times',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPrayerTime('Fajr', _formatTime(_prayerTimes!.fajr)),
                      _buildPrayerTime(
                        'Dhuhr',
                        _formatTime(_prayerTimes!.dhuhr),
                      ),
                      _buildPrayerTime('Asr', _formatTime(_prayerTimes!.asr)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPrayerTime(
                        'Maghrib',
                        _formatTime(_prayerTimes!.maghrib),
                      ),
                      _buildPrayerTime('Isha', _formatTime(_prayerTimes!.isha)),
                      const SizedBox(width: 60), // Spacing
                    ],
                  ),
                ],
              ),
            ),
          // Mosque List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mosques.length,
              itemBuilder: (context, index) {
                final mosque = mosques[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        mosque['image'],
                        size: 35,
                        color: const Color(0xFF00897B),
                      ),
                    ),
                    title: Text(
                      mosque['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(mosque['location']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(mosque['capacity']),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions, color: Color(0xFF00897B)),
                        const SizedBox(height: 4),
                        Text(
                          mosque['distance'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening directions to ${mosque['name']}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTime(String name, String time) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
