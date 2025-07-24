import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../view_models/dashboard_view_model.dart';
import 'daily_transactions_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final theme = Theme.of(context);
    print('rebuilt');
    print(vm.hasData);
    return Scaffold(
      appBar: AppBar(
        title: Text("Fresh & Clean Laundry Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Analytics Overview", style: theme.textTheme.titleLarge),
            SizedBox(height: 24),

            // Toggle Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _FilterButton(
                      label: "Today's Stats",
                      icon: Icons.today,
                      isSelected: vm.selectedPeriod == DashboardPeriod.today,
                      onTap: () => vm.loadDashboardStats(period: DashboardPeriod.today),
                    ),
                    SizedBox(width: 16),
                    _FilterButton(
                      label: "This Month",
                      icon: Icons.calendar_month,
                      isSelected: vm.selectedPeriod == DashboardPeriod.month,
                      onTap: () => vm.loadDashboardStats(period: DashboardPeriod.month),
                    ),
                    SizedBox(width: 16),
                    _FilterButton(
                      label: "Active Orders",
                      icon: Icons.list_alt,
                      isSelected: vm.selectedPeriod == DashboardPeriod.activeOrders, // add this new enum value
                      onTap: () async {
                        // Load active orders from the ViewModel
                        await vm.loadActiveOrders();
                        vm.selectedPeriod = DashboardPeriod.activeOrders; // set selectedPeriod accordingly
                        // Notify listeners or rebuild since vm is watched via context.watch<>
                      },
                    ),

                    SizedBox(width: 16),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text("Choose Day"),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              final normalized = DateTime(picked.year, picked.month, picked.day);
                              await vm.loadDashboardStats(period: DashboardPeriod.customDay, targetDate: normalized);
                              // vm.loadDashboardStats(period: DashboardPeriod.customDay, customDate: picked);
                            }
                          },
                        ),
                        SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: Icon(Icons.date_range),
                          label: Text("Choose Month"),
                          onPressed: () async {
                            final selectedMonth = await showDialog<DateTime>(context: context, builder: (context) => MonthPickerDialog());

                            if (selectedMonth != null) {
                              final monthDate = DateTime(selectedMonth.year, selectedMonth.month);
                              vm.loadDashboardStats(period: DashboardPeriod.customMonth, targetDate: monthDate);
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(width: 16),

                    ElevatedButton.icon(
                      icon: Icon(Icons.search),
                      label: Text("View a Day’s Transactions"),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => DailyTransactionsView(selectedDate: picked)));
                        }
                      },
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      child: Text("Download CSV"),
                      onPressed: () async {
                        // Let the user pick the date if you want:
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );
                        if (picked == null) return;

                        // Fetch & build CSV
                        final orders = await vm.fetchOrdersForDay(picked);
                        final csv = vm.buildCsv(orders);

                        // Create a blob from the CSV string
                        final blob = html.Blob([csv], 'text/csv');

                        // Generate a download URL and trigger the download
                        final url = html.Url.createObjectUrlFromBlob(blob);
                        final anchor =
                            html.document.createElement('a') as html.AnchorElement
                              ..href = url
                              ..style.display = 'none'
                              ..download = 'transactions_${picked.toIso8601String().split("T").first}.csv';
                        html.document.body!.append(anchor);
                        anchor.click();
                        html.document.body!.children.remove(anchor);
                        html.Url.revokeObjectUrl(url);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            // if (vm.isLoading)
            //   Center(child: CircularProgressIndicator())
            // else if (vm.hasData)
            //   Wrap(
            //     spacing: 24,
            //     runSpacing: 24,
            //     children: [
            //       if (vm.selectedPeriod == DashboardPeriod.today) ...[
            //         _StatCard(title: "Orders Today", value: "${vm.ordersToday}", icon: Icons.shopping_bag, color: Colors.deepPurple),
            //         _StatCard(title: "Sales Today", value: "Dhs ${vm.salesToday.toStringAsFixed(2)}", icon: Icons.attach_money, color: Colors.green),
            //       ] else if (vm.selectedPeriod == DashboardPeriod.month) ...[
            //         _StatCard(title: "Monthly Orders", value: "${vm.ordersThisMonth}", icon: Icons.insert_chart, color: Colors.orange),
            //         _StatCard(
            //           title: "Monthly Sales",
            //           value: "Dhs ${vm.salesThisMonth.toStringAsFixed(2)}",
            //           icon: Icons.trending_up,
            //           color: Colors.blue,
            //         ),
            //       ] else if (vm.selectedPeriod == DashboardPeriod.customDay || vm.selectedPeriod == DashboardPeriod.customMonth) ...[
            //         _StatCard(title: "Orders in selected period", value: "${vm.customOrders}", icon: Icons.insert_chart, color: Colors.orange),
            //         _StatCard(
            //           title: "Sales in selected period",
            //           value: "Dhs ${vm.customSales.toStringAsFixed(2)}",
            //           icon: Icons.trending_up,
            //           color: Colors.blue,
            //         ),
            //       ],
            //     ],
            //   )
            // else
            //   Center(child: Text("Select a period to view stats")),
            if (vm.isLoading || vm.isLoadingActiveOrders)
              Center(child: CircularProgressIndicator())
            else if (vm.hasData || (vm.selectedPeriod == DashboardPeriod.activeOrders && vm.activeOrders.isNotEmpty))
              vm.selectedPeriod == DashboardPeriod.activeOrders
                  ?
                  // Expanded(
                  //   child: ListView.builder(
                  //     itemCount: vm.activeOrders.length,
                  //     itemBuilder: (context, index) {
                  //       final order = vm.activeOrders[index];
                  //       return Card(
                  //         margin: EdgeInsets.symmetric(vertical: 6),
                  //         child: ListTile(
                  //           title: Text("Order ID: ${order.id}"),
                  //           subtitle: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               // Text("Customer: ${order.}"),
                  //               Text("Total: AED ${order.total.toStringAsFixed(2)}"),
                  //               Text("Date: ${order.timestamp.toString().split('.').first}"),
                  //             ],
                  //           ),
                  //           trailing: ElevatedButton(
                  //             child: Text("Complete"),
                  //             onPressed: () {
                  //               // TODO: Add complete order action
                  //             },
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // )
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Active Orders Summary
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("Total Active Orders: ${vm.activeOrders.length}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),

                        // Orders grouped by month and day
                        Expanded(
                          child: ListView(
                            children:
                                vm.groupedActiveOrders.entries.map((monthEntry) {
                                  final month = monthEntry.key;
                                  final dailyOrders = monthEntry.value;

                                  final monthDate = DateTime.parse("$month-01");
                                  final formattedMonth = DateFormat("MMMM yyyy").format(monthDate);

                                  final totalOrdersInMonth = dailyOrders.values.fold<int>(0, (sum, list) => sum + list.length);

                                  return ExpansionTile(
                                    initiallyExpanded: true,
                                    title: Text(
                                      "$formattedMonth • ${dailyOrders.length} day${dailyOrders.length > 1 ? 's' : ''} • $totalOrdersInMonth order${totalOrdersInMonth > 1 ? 's' : ''}",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    children:
                                        dailyOrders.entries.map((dayEntry) {
                                          final day = dayEntry.key;
                                          final orders = dayEntry.value;
                                          final formattedDay = DateFormat("dd-MM-yyyy").format(DateTime.parse(day));

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                                            child: Card(
                                              elevation: 2,
                                              child: ExpansionTile(
                                                title: Text(
                                                  "$formattedDay – ${orders.length} order${orders.length > 1 ? 's' : ''}",
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                ),
                                                children:
                                                    orders.map((order) {
                                                      return ListTile(
                                                        title: Text("${order.customerCode}", style: TextStyle(fontWeight: FontWeight.bold)),
                                                        subtitle: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("Order ID: ${order.id}"),
                                                            Text("Total: AED ${order.total.toStringAsFixed(2)}"),
                                                            Text(
                                                              "Time: ${order.timestamp.hour.toString().padLeft(2, '0')}:${order.timestamp.minute.toString().padLeft(2, '0')}",
                                                            ),
                                                            Divider(),
                                                          ],
                                                        ),
                                                        trailing: ElevatedButton(
                                                          child: Text("Complete"),
                                                          onPressed: () {
                                                            // TODO: Add complete order logic
                                                          },
                                                        ),
                                                      );
                                                    }).toList(),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      if (vm.selectedPeriod == DashboardPeriod.today) ...[
                        _StatCard(title: "Orders Today", value: "${vm.ordersToday}", icon: Icons.shopping_bag, color: Colors.deepPurple),
                        _StatCard(
                          title: "Sales Today",
                          value: "Dhs ${vm.salesToday.toStringAsFixed(2)}",
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                        _StatCard(
                          title: "Amount In Today",
                          value: "Dhs ${vm.amountInToday.toStringAsFixed(2)}",
                          icon: Icons.attach_money,
                          color: Colors.red,
                        ),
                      ] else if (vm.selectedPeriod == DashboardPeriod.month) ...[
                        _StatCard(title: "Monthly Orders", value: "${vm.ordersThisMonth}", icon: Icons.insert_chart, color: Colors.orange),
                        _StatCard(
                          title: "Monthly Sales",
                          value: "Dhs ${vm.salesThisMonth.toStringAsFixed(2)}",
                          icon: Icons.trending_up,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: "Monthly Amount In",
                          value: "Dhs ${vm.amountInThisMonth.toStringAsFixed(2)}",
                          icon: Icons.attach_money,
                          color: Colors.red,
                        ),
                      ] else if (vm.selectedPeriod == DashboardPeriod.customDay || vm.selectedPeriod == DashboardPeriod.customMonth) ...[
                        _StatCard(title: "Orders in selected period", value: "${vm.customOrders}", icon: Icons.insert_chart, color: Colors.orange),
                        _StatCard(
                          title: "Sales in selected period",
                          value: "Dhs ${vm.customSales.toStringAsFixed(2)}",
                          icon: Icons.trending_up,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: "Amount In during selected period",
                          value: "Dhs ${vm.customAmountIn.toStringAsFixed(2)}",
                          icon: Icons.trending_up,
                          color: Colors.red,
                        ),
                      ],
                    ],
                  )
            else
              Center(child: Text("Select a period to view stats")),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, color: color)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class MonthPickerDialog extends StatefulWidget {
  @override
  _MonthPickerDialogState createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  final List<int> years = List.generate(10, (index) => 2024 + index); // From 2024 to 2033
  final List<String> months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Month'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton<int>(
            value: selectedYear,
            onChanged: (val) => setState(() => selectedYear = val!),
            items:
                years.map((year) {
                  return DropdownMenuItem<int>(value: year, child: Text(year.toString()));
                }).toList(),
          ),
          DropdownButton<int>(
            value: selectedMonth,
            onChanged: (val) => setState(() => selectedMonth = val!),
            items: List.generate(12, (index) {
              return DropdownMenuItem<int>(value: index + 1, child: Text(months[index]));
            }),
          ),
        ],
      ),
      actions: [
        TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context)),
        ElevatedButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context, DateTime(selectedYear, selectedMonth));
          },
        ),
      ],
    );
  }
}
