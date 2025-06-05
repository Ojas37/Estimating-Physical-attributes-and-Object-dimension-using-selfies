// lib/features/converter/presentation/pages/unit_converter_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({Key? key}) : super(key: key);

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  final _controller = TextEditingController();
  String _fromUnit = 'cm';
  String _toUnit = 'inches';
  double _result = 0;

  final _units = ['cm', 'inches', 'meters', 'feet'];

  void _convert() {
    final input = double.tryParse(_controller.text) ?? 0;
    setState(() {
      _result = _calculateConversion(input);
    });
  }

  double _calculateConversion(double value) {
    // Add conversion logic based on _fromUnit and _toUnit
    switch ('${_fromUnit}_$_toUnit') {
      case 'cm_inches':
        return value / 2.54;
      case 'inches_cm':
        return value * 2.54;
      case 'cm_meters':
        return value / 100;
      case 'meters_cm':
        return value * 100;
      case 'inches_feet':
        return value / 12;
      case 'feet_inches':
        return value * 12;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit Converter', style: AppTheme.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter value',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromUnit,
                    items: _units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromUnit = value!;
                        _convert();
                      });
                    },
                  ),
                ),
                const Icon(Icons.arrow_forward),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toUnit,
                    items: _units.map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _toUnit = value!;
                        _convert();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Result: ${_result.toStringAsFixed(2)} $_toUnit',
              style: AppTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
