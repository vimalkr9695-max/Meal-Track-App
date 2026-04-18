import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../meal.dart';

class StatsPage extends StatelessWidget {
  final List<Meal> allMeals;
  final double budget;
  const StatsPage({super.key, required this.allMeals, required this.budget});

  List<Meal> get _monthMeals {
    final now = DateTime.now();
    return allMeals
        .where((m) =>
            m.createdAt.year == now.year && m.createdAt.month == now.month)
        .toList();
  }

  double get _totalSpend =>
      _monthMeals.fold(0.0, (s, m) => s + m.amount);

  int get _daysTracked {
    final days = <String>{};
    for (final m in _monthMeals) {
      days.add('${m.createdAt.day}');
    }
    return days.length;
  }

  double get _dailyAverage =>
      _daysTracked == 0 ? 0 : _totalSpend / _daysTracked;

  Map<String, double> _dailyTotals() {
    final map = <String, double>{};
    for (final m in _monthMeals) {
      final key = '${m.createdAt.day}';
      map[key] = (map[key] ?? 0) + m.amount;
    }
    return map;
  }

  MapEntry<String, double>? _highestDay() {
    final dt = _dailyTotals();
    if (dt.isEmpty) return null;
    return dt.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  MapEntry<String, double>? _lowestDay() {
    final dt = _dailyTotals();
    if (dt.isEmpty) return null;
    return dt.entries.reduce((a, b) => a.value < b.value ? a : b);
  }

  Map<String, double> _spendByType() {
    final map = {'Breakfast': 0.0, 'Lunch': 0.0, 'Dinner': 0.0, 'Snack': 0.0};
    for (final m in _monthMeals) {
      map[m.type] = (map[m.type] ?? 0) + m.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);
    final highest = _highestDay();
    final lowest = _lowestDay();
    final byType = _spendByType();
    final maxType =
        byType.values.isEmpty ? 1.0 : byType.values.reduce((a, b) => a > b ? a : b);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Report',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF0EDE6),
              ),
            ),
            const SizedBox(height: 4),
            Text('$monthName · $_daysTracked days tracked',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF5C5A56),
              ),
            ),

            const SizedBox(height: 16),

            _buildBudgetCard(monthName),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '₹${highest?.value.toStringAsFixed(2) ?? '0.00'}',
                    'Highest Day',
                    highest != null ? 'Day ${highest.key}' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    '₹${lowest?.value.toStringAsFixed(2) ?? '0.00'}',
                    'Lowest Day',
                    lowest != null ? 'Day ${lowest.key}' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '₹${_dailyAverage.toStringAsFixed(2)}',
                    'Daily Average',
                    null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    '${_monthMeals.length}',
                    'Meals Logged',
                    null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text('Spend by Meal Type',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF0EDE6),
              ),
            ),

            const SizedBox(height: 10),

            ...['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((type) {
              final amount = byType[type] ?? 0.0;
              final fillRatio = maxType > 0 ? amount / maxType : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(type,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFF9B9890),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E2E2B),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: fillRatio.clamp(0.0, 1.0),
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A853),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('₹${amount.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4A853),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(String monthName) {
    final fillFraction =
        budget > 0 ? (_totalSpend / budget).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF241C07), Color(0xFF110F03)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3E2F0E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("MONTHLY SPEND",
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFA07830),
            ),
          ),
          const SizedBox(height: 4),
          Text('₹${_totalSpend.toStringAsFixed(1)}',
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              color: const Color(0xFFD4A853),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$monthName budget · ₹${_totalSpend.toStringAsFixed(0)} of ₹${budget.toStringAsFixed(0)} used',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: const Color(0xFF7A6030),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2208),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Container(
                  width: constraints.maxWidth * fillFraction,
                  height: 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC09040), Color(0xFFF0C870)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹0',
                  style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF7A6030))),
              Text('₹${_totalSpend.toStringAsFixed(0)} spent',
                  style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF7A6030))),
              Text('₹${budget.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF7A6030))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, String? sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2E2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4A853),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9B9890),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: const Color(0xFF5C5A56),
              ),
            ),
          ],
        ],
      ),
    );
  }
}