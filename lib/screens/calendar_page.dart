import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../meal.dart';
import 'edit_meal_page.dart';
 
class CalendarPage extends StatefulWidget {
  final List<Meal> allMeals;
  final VoidCallback onDataChanged;
  const CalendarPage(
      {super.key, required this.allMeals, required this.onDataChanged});
 
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}
 
class _CalendarPageState extends State<CalendarPage> {
  DateTime _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;
 
  List<Meal> _mealsForDay(DateTime day) {
    return widget.allMeals.where((m) {
      return m.createdAt.year == day.year &&
          m.createdAt.month == day.month &&
          m.createdAt.day == day.day;
    }).toList();
  }
 
  double _totalForDay(DateTime day) {
    return _mealsForDay(day).fold(0.0, (s, m) => s + m.amount);
  }
 
  DateTime? _highestSpendDay() {
    final days = <String, double>{};
    for (final m in widget.allMeals) {
      if (m.createdAt.year == _displayMonth.year &&
          m.createdAt.month == _displayMonth.month) {
        final key =
            '${m.createdAt.year}-${m.createdAt.month}-${m.createdAt.day}';
        days[key] = (days[key] ?? 0) + m.amount;
      }
    }
    if (days.isEmpty) return null;
    final maxKey = days.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final parts = maxKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
 
  double _monthTotal() {
    return widget.allMeals
        .where((m) =>
            m.createdAt.year == _displayMonth.year &&
            m.createdAt.month == _displayMonth.month)
        .fold(0.0, (s, m) => s + m.amount);
  }
 
  int _daysTracked() {
    final days = <String>{};
    for (final m in widget.allMeals) {
      if (m.createdAt.year == _displayMonth.year &&
          m.createdAt.month == _displayMonth.month) {
        days.add('${m.createdAt.day}');
      }
    }
    return days.length;
  }
 
  double _avgPerDay() {
    final tracked = _daysTracked();
    return tracked == 0 ? 0 : _monthTotal() / tracked;
  }
 
  double _highestDayAmount() {
    final hd = _highestSpendDay();
    if (hd == null) return 0;
    return _totalForDay(hd);
  }
 
  @override
  Widget build(BuildContext context) {
    final firstDay =
        DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final highestDay = _highestSpendDay();
    final today = DateTime.now();
 
    final cells = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayMonth.year, _displayMonth.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);
 
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Calendar Header
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_displayMonth),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0EDE6),
                    ),
                  ),
                  Row(
                    children: [
                      _navButton('‹', () {
                        setState(() {
                          _displayMonth = DateTime(
                              _displayMonth.year, _displayMonth.month - 1);
                          _selectedDay = null;
                        });
                      }),
                      const SizedBox(width: 8),
                      _navButton('›', () {
                        setState(() {
                          _displayMonth = DateTime(
                              _displayMonth.year, _displayMonth.month + 1);
                          _selectedDay = null;
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
 
            // Day of week labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
                return SizedBox(
                  width: 30,
                  height: 34,
                  child: Center(
                    child: Text(d,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C5A56),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
 
            const SizedBox(height: 8),
 
            // Calendar Grid
            ...List.generate(cells.length ~/ 7, (row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (col) {
                    final day = cells[row * 7 + col];
                    if (day == null) {
                      return const SizedBox(width: 30, height: 34);
                    }
 
                    final hasMeals = _mealsForDay(day).isNotEmpty;
                    final isSelected = _selectedDay != null &&
                        _selectedDay!.year == day.year &&
                        _selectedDay!.month == day.month &&
                        _selectedDay!.day == day.day;
                    final isHighest = highestDay != null &&
                        highestDay.day == day.day &&
                        highestDay.month == day.month;
                    final isToday = today.year == day.year &&
                        today.month == day.month &&
                        today.day == day.day;
 
                    Color bg = Colors.transparent;
                    Color textColor = const Color(0xFF5C5A56);
                    Color? borderColor;
 
                    if (isSelected) {
                      bg = const Color(0xFFD4A853);
                      textColor = const Color(0xFF1A1A18);
                    } else if (isHighest) {
                      bg = const Color(0xFF4A2E2E);
                      textColor = const Color(0xFFE07070);
                      borderColor = const Color(0xFFE07070);
                    } else if (isToday) {
                      textColor = const Color(0xFFD4A853);
                    }
 
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay =
                              (_selectedDay?.day == day.day && _selectedDay?.month == day.month)
                                  ? null
                                  : day;
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 34,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(6),
                          border: borderColor != null
                              ? Border.all(color: borderColor)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${day.day}',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (hasMeals && !isSelected)
                              Container(
                                width: 5, height: 5,
                                decoration: BoxDecoration(
                                  color: isHighest
                                      ? const Color(0xFFE07070)
                                      : const Color(0xFF7EB98A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
 
            const SizedBox(height: 8),
 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1806), Color(0xFF130F03)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3A2A0C)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('MONTHLY TOTAL',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA07830),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('₹${_monthTotal().toStringAsFixed(1)}', // ✅ INR
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4A853),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMMM yyyy').format(_displayMonth)} · ${_daysTracked()} days tracked',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: const Color(0xFF7A6030),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _miniBadge(
                          '₹${_highestDayAmount().toStringAsFixed(0)}', 'Highest'), // ✅ INR
                      const SizedBox(width: 10),
                      _miniBadge('₹${_avgPerDay().toStringAsFixed(0)}', 'Avg/day'), // ✅ INR
                    ],
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 16),
 
            if (_selectedDay != null) _buildSelectedDayPanel(),
 
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
 
  Widget _navButton(String arrow, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 41, height: 41,
        decoration: const BoxDecoration(
          color: Color(0xFF222220),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(arrow,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w200,
              color: const Color(0xFF9B9890),
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _miniBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4A853).withOpacity(0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD4A853),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 7,
              color: const Color(0xFFA07830).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildSelectedDayPanel() {
    final meals = _mealsForDay(_selectedDay!);
    final total = _totalForDay(_selectedDay!);
    final dateStr = DateFormat('EEEE, MMMM d').format(_selectedDay!);
 
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2E2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$dateStr — Selected',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF9B9890),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (meals.isEmpty)
            Text('No meals on this day',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: const Color(0xFF5C5A56),
              ),
            )
          else
            ...meals.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditMealPage(
                          meal: m, onSaved: widget.onDataChanged),
                    ),
                  );
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${m.type} · ${m.name}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFFF0EDE6),
                      ),
                    ),
                    Text('₹${m.amount.toStringAsFixed(2)}', // ✅ INR
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4A853),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          const Divider(color: Color(0xFF2E2E2B)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day Total',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF9B9890),
                ),
              ),
              Text('₹${total.toStringAsFixed(2)}', // ✅ INR
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  color: const Color(0xFFF0EDE6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}