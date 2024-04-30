import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter/foundation.dart';
import 'package:parallel/models/customer.dart'; // Import compute

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sequential DART'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late final MySqlConnection _connection;
  List<Customer> list = <Customer>[];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _connectToMySQL();
  }

  void printGetRow(MySqlConnection connection) {
    setState(() {
      isLoading = true;
    });

    // Execute the query in a separate isolate
    compute(_fetchData, connection).then((result) {
      setState(() {
        list = result;
        isLoading = false;
      });
    });
  }

  static Future<List<Customer>> _fetchData(MySqlConnection connection) async {
    List<Customer> result = [];

    String sql =
        "SELECT o.id, c.last_name , c.first_name, o.payment_type, stats.status_name , order_date, od.unit_price, od.quantity FROM northwind.orders o \n" +
            "left join northwind.customers c on c.id = o.customer_id\n" +
            "left join order_details od on od.order_id = o.id\n" +
            "left join northwind.orders_status stats on stats.id = o.status_id";

    var results = await connection.query(sql);

    for (var row in results) {
      Customer c = Customer(
        id: row[0],
        lastName: row[1],
        firstName: row[2],
        dateOrdered: row[5],
      );

      result.add(c);
    }

    return result;
  }

  Future<void> _connectToMySQL() async {
    final settings = ConnectionSettings(
      host: 'localhost',
      port: 3306, // Your MySQL port, usually 3306
      user: 'root',
      password: 'root',
      db: 'northwind',
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      print('Connected to MySQL database');
    } catch (e) {
      print('Error connecting to MySQL database: $e');
    }
  }

  void _incrementCounter() {
    printGetRow(_connection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: isLoading
              ? const CircularProgressIndicator()
              : list.isEmpty
                  ? const Text('Click the button!')
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        return ListTile(
                          title: Text(
                            '${list[index].lastName}, ${list[index].firstName}',
                          ),
                          subtitle: Text(
                            'Order Date: ${DateFormat('yyyy-MM-dd').format(list[index].dateOrdered)}',
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
