import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_web/razorpay_web.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Login to Badminton Store'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Badminton World!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Login to explore and shop the best badminton equipment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _isEmailValid ? null : 'Please enter a valid email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _isPasswordValid ? null : 'Password cannot be empty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEmailValid = emailController.text.isNotEmpty;
                  _isPasswordValid = passwordController.text.isNotEmpty;
                });

                if (_isEmailValid && _isPasswordValid) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                      msg: "Please enter both email and password",
                      toastLength: Toast.LENGTH_SHORT);
                }
              },
              child: const Text('Login'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "name": "Yonex Astrox 99",
      "image": "assets/astrox99.jpg",
      "price": 1500,
    },
    {
      "name": "Li-Ning N7II",
      "image": "assets/n7ii.jpg",
      "price": 1800,
    },
    {
      "name": "Victor Brave Sword 12",
      "image": "assets/bravesword12.jpg",
      "price": 1700,
    },
    {
      "name": "Badminton Strings",
      "image": "assets/strings.jpg",
      "price": 200,
    },
    {
      "name": "Shuttlecocks",
      "image": "assets/shuttlecocks.jpg",
      "price": 100,
    },
    {
      "name": "Grips",
      "image": "assets/grips.jpg",
      "price": 50,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badminton Store'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.asset(
                        products[index]["image"],
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      products[index]["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "\$${products[index]["price"]}",
                      style: const TextStyle(
                          color: Color(0xffe01d6e),
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                PaymentPage(price: products[index]["price"]),
                          ),
                        );
                      },
                      child: const Text('Buy Now'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final int price;
  const PaymentPage({Key? key, required this.price}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': widget.price * 100, // Razorpay expects amount in paise
      'name': 'Badminton Store',
      'description': 'Badminton Product',
      'prefill': {'contact': '8838820437', 'email': 'dhivshee@gmail.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Success Response: $response');
    Fluttertoast.showToast(
        msg: "SUCCESS: ${response.paymentId!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log('Error Response: $response');
    Fluttertoast.showToast(
        msg: "ERROR: ${response.code} - ${response.message!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External SDK Response: $response');
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: ${response.walletName!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Purchase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You are purchasing the item for:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "\$${widget.price}",
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffcb50cf)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: openCheckout,
              child: const Text('Proceed to Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
