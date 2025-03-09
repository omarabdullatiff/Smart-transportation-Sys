import 'package:flutter/material.dart';
import 'package:flutter_application_1/app_color.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _selectedSeats = [];
  final Map<String, bool> _bookedSeats = {
    'A2': true,
    'B3': true,
    'C1': true,
    'D4': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose your seat',
          style: TextStyle(
            color:AppColor.primaryLight
          ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildLegend(),
            const SizedBox(height: 30),
            _buildSeatGrid(),
            const Spacer(),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'helwan  - -> 5th settlement',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '1 - Jan - 2025 | Wednesday',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(Colors.green, 'Available'),
        _buildLegendItem(Colors.grey, 'Booked'),
        _buildLegendItem(Colors.blue, 'Your seat'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 50,
        crossAxisSpacing: 20,
      ),
      itemCount: 16,
      itemBuilder: (context, index) {
        final row = String.fromCharCode(65 + (index ~/ 4));
        final number = (index % 4) + 1;
        final seat = '$row$number';
        final isBooked = _bookedSeats.containsKey(seat);
        final isSelected = _selectedSeats.contains(seat);

        return _buildSeat(seat, isBooked, isSelected);
      },
    );
  }

  Widget _buildSeat(String seat, bool isBooked, bool isSelected) {
    return GestureDetector(
      onTap: isBooked ? null : () => _toggleSeat(seat),
      child: Container(
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey
              : isSelected
                  ? Colors.blue
                  : Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            seat,
            style: TextStyle(
              color: isBooked || isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColor.primary,
      ),
      onPressed: _selectedSeats.isEmpty ? null : () {},
      child: const Text(
        'Confirm'
        ,style: TextStyle(
          color:Colors.white,
        ),
      
      ),
    );
  }

  void _toggleSeat(String seat) {
    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
      } else {
        _selectedSeats.add(seat);
      }
    });
  }
}