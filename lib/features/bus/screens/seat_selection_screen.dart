import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SeatInfo {
  final int id;
  final String seatNumber;
  final bool isReserved;
  final bool isMine;

  SeatInfo({
    required this.id,
    required this.seatNumber,
    required this.isReserved,
    required this.isMine,
  });

  factory SeatInfo.fromJson(Map<String, dynamic> json) => SeatInfo(
    id: json['id'] ?? 0,
    seatNumber: json['seatNumber'] ?? '',
    isReserved: json['isReserved'] ?? false,
    isMine: json['isMine'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'seatNumber': seatNumber,
    'isReserved': isReserved,
    'isMine': isMine,
  };
}

class BusInfo {
  final String model;
  final String licensePlate;
  final int capacity;

  BusInfo({
    required this.model,
    required this.licensePlate,
    required this.capacity,
  });

  factory BusInfo.fromJson(Map<String, dynamic> json) => BusInfo(
    model: json['model'] ?? '',
    licensePlate: json['licensePlate'] ?? '',
    capacity: json['capacity'] ?? 0,
  );
}

class SeatLayoutResponse {
  final int busId;
  final String startTime;
  final BusInfo bus;
  final List<SeatInfo> seats;

  SeatLayoutResponse({
    required this.busId,
    required this.startTime,
    required this.bus,
    required this.seats,
  });

  factory SeatLayoutResponse.fromJson(Map<String, dynamic> json) => SeatLayoutResponse(
    busId: json['busId'] ?? 0,
    startTime: json['startTime'] ?? '',
    bus: BusInfo.fromJson(json['bus'] ?? {}),
    seats: (json['seats'] as List<dynamic>?)
        ?.map((seatJson) => SeatInfo.fromJson(seatJson))
        .toList() ?? [],
  );
}

class NearbyBus {
  final int busId;
  final double latitude;
  final double longitude;
  final int? driverId;
  final String? origin;
  final String? destination;

  NearbyBus({
    required this.busId,
    required this.latitude,
    required this.longitude,
    this.driverId,
    this.origin,
    this.destination,
  });

  factory NearbyBus.fromJson(Map<String, dynamic> json) => NearbyBus(
    busId: json['busId'] ?? 0,
    latitude: (json['latitude'] ?? 0.0).toDouble(),
    longitude: (json['longitude'] ?? 0.0).toDouble(),
    driverId: json['driverId'],
    origin: json['origin'],
    destination: json['destination'],
  );
}

class SeatSelectionScreen extends StatefulWidget {
  final String busId;
  final String origin;
  final String destination;

  const SeatSelectionScreen({
    super.key,
    required this.busId,
    required this.origin,
    required this.destination,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  List<SeatInfo> _seats = [];
  BusInfo? _busInfo;
  Set<String> _selectedSeats = {};
  bool _isLoading = true;
  bool _isGenerating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeSeats();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  Future<void> _initializeSeats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // First, generate seats if they don't exist
      await _generateSeats();
      
      // Then fetch the seat layout
      await _fetchSeatLayout();
    } catch (e) {
      setState(() {
        if (e.toString().contains('Authentication required')) {
          _errorMessage = 'Authentication required. Please login to access seat booking.';
        } else {
          _errorMessage = 'Failed to load seats: ${e.toString()}';
        }
        _isLoading = false;
      });
    }
  }

  void _handleAuthenticationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Authentication Required'),
          ],
        ),
        content: const Text(
          'You need to be logged in to book seats. Would you like to go to the login screen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to trip details
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSeats() async {
    setState(() => _isGenerating = true);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Seat/bus/${widget.busId}/generate-seats'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Seats generated successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please login again.');
      } else {
        debugPrint('Generate seats response: ${response.statusCode} - ${response.body}');
        // Don't throw error here as seats might already exist
      }
    } catch (e) {
      debugPrint('Error generating seats: $e');
      if (e.toString().contains('Authentication required')) {
        rethrow; // Re-throw auth errors to be handled by caller
      }
      // Continue anyway as seats might already exist for other errors
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _fetchSeatLayout() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Seat/layout/bus/${widget.busId}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final seatLayoutResponse = SeatLayoutResponse.fromJson(responseData);
        
        setState(() {
          _seats = seatLayoutResponse.seats;
          _busInfo = seatLayoutResponse.bus;
          // Initialize selectedSeats with seats that are marked as 'isMine'
          _selectedSeats = seatLayoutResponse.seats
              .where((seat) => seat.isMine)
              .map((seat) => seat.seatNumber)
              .toSet();
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please login again to view seats.');
      } else if (response.statusCode == 404) {
        throw Exception('No seats found for this bus. The bus may not have seat layout configured.');
      } else {
        throw Exception('Failed to fetch seat layout: ${response.statusCode}. ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSeatReservation(String seatNumber, bool isCurrentlyReserved) async {
    // Prevent interaction with already reserved seats by others
    if (isCurrentlyReserved && !_selectedSeats.contains(seatNumber)) {
      _showSnackBar('This seat is already reserved', Colors.red);
      return;
    }

    final bool shouldReserve = !_selectedSeats.contains(seatNumber);
    final String apiEndpoint = shouldReserve ? 'reserve' : 'unreserve';
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('http://smarttrackingapp.runasp.net/api/Seat/$apiEndpoint'),
        headers: headers,
        body: json.encode({
          'busId': int.parse(widget.busId),
          'seatNumber': seatNumber,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          if (shouldReserve) {
            _selectedSeats.add(seatNumber);
          } else {
            _selectedSeats.remove(seatNumber);
          }
        });
        
        // Update seat status in the local list
        final seatIndex = _seats.indexWhere((seat) => seat.seatNumber == seatNumber);
        if (seatIndex != -1) {
          setState(() {
            _seats[seatIndex] = SeatInfo(
              id: _seats[seatIndex].id,
              seatNumber: _seats[seatIndex].seatNumber,
              isReserved: shouldReserve,
              isMine: shouldReserve,
            );
          });
        }

        _showSnackBar(
          shouldReserve ? 'Seat $seatNumber reserved' : 'Seat $seatNumber unreserved',
          shouldReserve ? Colors.green : Colors.orange,
        );
      } else if (response.statusCode == 401) {
        _showSnackBar('Authentication required. Please login again.', Colors.red);
      } else if (response.statusCode == 409) {
        _showSnackBar('Seat already ${shouldReserve ? 'reserved' : 'available'}. Please refresh.', Colors.orange);
        _initializeSeats(); // Refresh the seat layout
      } else {
        throw Exception('${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      String errorMessage = 'Failed to ${shouldReserve ? 'reserve' : 'unreserve'} seat';
      if (e.toString().contains('401')) {
        errorMessage = 'Please login to reserve seats';
      } else if (e.toString().contains('409')) {
        errorMessage = 'Seat status changed. Please try again.';
      }
      _showSnackBar('$errorMessage: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _getSeatColor(SeatInfo seat) {
    if (seat.isMine || _selectedSeats.contains(seat.seatNumber)) {
      return Colors.blue; // Selected by current user
    } else if (seat.isReserved) {
      return Colors.red; // Reserved by others
    } else {
      return Colors.green; // Available
    }
  }

  IconData _getSeatIcon(SeatInfo seat) {
    if (seat.isMine || _selectedSeats.contains(seat.seatNumber)) {
      return Icons.event_seat; // Selected
    } else if (seat.isReserved) {
      return Icons.block; // Reserved
    } else {
      return Icons.event_seat; // Available
    }
  }

  Widget _buildSeatLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Available', Colors.green, Icons.event_seat),
          _buildLegendItem('Selected', Colors.blue, Icons.event_seat),
          _buildLegendItem('Reserved', Colors.red, Icons.block),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildBusInfo() {
    if (_busInfo == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColor.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _busInfo!.model,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'License: ${_busInfo!.licensePlate}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Capacity: ${_busInfo!.capacity} seats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    if (_seats.isEmpty) {
      return const Center(
        child: Text(
          'No seats available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 seats per row (typical bus layout)
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _seats.length,
      itemBuilder: (context, index) {
        final seat = _seats[index];
        final color = _getSeatColor(seat);
        final icon = _getSeatIcon(seat);

        return GestureDetector(
          onTap: () => _toggleSeatReservation(seat.seatNumber, seat.isReserved),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text(
                  seat.seatNumber,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionSummary() {
    if (_selectedSeats.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.confirmation_number, color: AppColor.primary),
              const SizedBox(width: 8),
              Text(
                'Selected Seats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSeats.map((seatNumber) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Seat $seatNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: ${_selectedSeats.length} seat${_selectedSeats.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.primary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Your Seat',
          style: TextStyle(
            color: AppColor.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Trip info header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_bus, color: AppColor.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.origin} → ${widget.destination}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bus ID: ${widget.busId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Seat legend
          _buildSeatLegend(),

          // Bus info
          _buildBusInfo(),

          // Loading/Error states
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading seats...'),
                  ],
                ),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load seats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_errorMessage.contains('Authentication required')) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Authentication Required'),
                                ],
                              ),
                              content: const Text(
                                'You need to be logged in to book seats. Would you like to go to the login screen?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(context); // Go back to trip details
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  child: const Text('Login'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          _initializeSeats();
                        }
                      },
                      child: Text(_errorMessage.contains('Authentication required') ? 'Login' : 'Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            // Seat grid
            Expanded(
              child: _buildSeatGrid(),
            ),

          // Selection summary
          _buildSelectionSummary(),

          // Confirm button
          if (_selectedSeats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Handle booking confirmation
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Booking'),
                      content: Text(
                        'You have selected ${_selectedSeats.length} seat${_selectedSeats.length != 1 ? 's' : ''}: ${_selectedSeats.join(', ')}\n\nProceed with booking?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Return to trip details
                            _showSnackBar('Booking confirmed!', Colors.green);
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Confirm Booking (${_selectedSeats.length} seat${_selectedSeats.length != 1 ? 's' : ''})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}