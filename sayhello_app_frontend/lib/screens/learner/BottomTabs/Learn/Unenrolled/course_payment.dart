import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../l10n/app_localizations.dart';
import '../Enrolled/course_portal.dart';

class CoursePaymentPage extends StatefulWidget {
  final Map<String, dynamic> course;

  const CoursePaymentPage({super.key, required this.course});

  @override
  State<CoursePaymentPage> createState() => _CoursePaymentPageState();
}

class _CoursePaymentPageState extends State<CoursePaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isProcessing = false;
  String _selectedPaymentMethod = 'card';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final price =
        double.tryParse(widget.course['price']?.toString() ?? '49.99') ?? 49.99;
    final courseName = widget.course['title'] ?? 'Course';
    final instructor = widget.course['instructor'] ?? 'Instructor';

    // Consistent color theme
    final primaryColor = Color(0xFF7A54FF);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complete Purchase',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Summary Card
                    _buildCourseSummary(
                      courseName,
                      instructor,
                      price,
                      isDark,
                      primaryColor,
                    ),

                    const SizedBox(height: 20),

                    // Payment Method Selection
                    _buildPaymentMethodSelection(isDark, primaryColor),

                    const SizedBox(height: 20),

                    // Payment Form
                    if (_selectedPaymentMethod == 'card') ...[
                      _buildPaymentForm(isDark, primaryColor),
                      const SizedBox(height: 20),
                    ],

                    // Billing Information
                    _buildBillingInformation(isDark, primaryColor),

                    const SizedBox(height: 20),

                    // Order Summary
                    _buildOrderSummary(price, isDark, primaryColor),

                    const SizedBox(height: 80), // Space for floating button
                  ],
                ),
              ),
            ),
          ),

          // Payment Button
          _buildPaymentButton(price, isDark, primaryColor),
        ],
      ),
    );
  }

  Widget _buildCourseSummary(
    String courseName,
    String instructor,
    double price,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.course['icon'] ?? Icons.school,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'by $instructor',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 14),

          // Credit/Debit Card Option
          GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = 'card'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedPaymentMethod == 'card'
                      ? primaryColor
                      : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) =>
                        setState(() => _selectedPaymentMethod = value!),
                    activeColor: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.credit_card, color: primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Credit/Debit Card',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // PayPal Option (Now Available)
          GestureDetector(
            onTap: () => setState(() => _selectedPaymentMethod = 'paypal'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedPaymentMethod == 'paypal'
                      ? primaryColor
                      : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: 'paypal',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) =>
                        setState(() => _selectedPaymentMethod = value!),
                    activeColor: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PayPal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 14),

          // Card Number
          TextFormField(
            controller: _cardNumberController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Card Number',
              labelStyle: TextStyle(fontSize: 12),
              hintText: '1234 5678 9012 3456',
              hintStyle: TextStyle(fontSize: 12),
              prefixIcon: Icon(
                Icons.credit_card,
                size: 18,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter card number';
              }
              if (value.replaceAll(' ', '').length < 16) {
                return 'Please enter a valid card number';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              // Expiry Date
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    labelStyle: TextStyle(fontSize: 12),
                    hintText: 'MM/YY',
                    hintStyle: TextStyle(fontSize: 12),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                    _ExpiryDateFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 5) {
                      return 'Invalid date';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 14),

              // CVV
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    labelStyle: TextStyle(fontSize: 12),
                    hintText: '123',
                    hintStyle: TextStyle(fontSize: 12),
                    prefixIcon: Icon(Icons.lock, size: 18, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 3) {
                      return 'Invalid CVV';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingInformation(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing Information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 14),

          // Cardholder Name
          TextFormField(
            controller: _nameController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              labelStyle: TextStyle(fontSize: 12),
              hintText: 'John Doe',
              hintStyle: TextStyle(fontSize: 12),
              prefixIcon: Icon(Icons.person, size: 18, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Email
          TextFormField(
            controller: _emailController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: TextStyle(fontSize: 12),
              hintText: 'john@example.com',
              hintStyle: TextStyle(fontSize: 12),
              prefixIcon: Icon(Icons.email, size: 18, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email address';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double price, bool isDark, Color primaryColor) {
    final tax = price * 0.1; // 10% tax
    final total = price + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Course Price',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax (10%)',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                '\$${tax.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: primaryColor.withOpacity(0.3)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(double price, bool isDark, Color primaryColor) {
    final tax = price * 0.1;
    final total = price + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            child: _isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Processing...', style: TextStyle(fontSize: 15)),
                    ],
                  )
                : Text(
                    'Pay \$${total.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  void _processPayment() async {
    if (_selectedPaymentMethod == 'paypal') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Processing PayPal payment...'),
          backgroundColor: Color(0xFF7A54FF),
        ),
      );
      // Add PayPal payment processing logic here
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(Duration(seconds: 3));

    setState(() => _isProcessing = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to ${widget.course['title']}!\nYou can now access all course materials.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close payment page
                  Navigator.of(context).pop(); // Close course details

                  // Navigate to course portal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CoursePortalPage(course: widget.course),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Start Learning'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Card number formatter
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Expiry date formatter
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Don't allow more than 4 digits
    if (digitsOnly.length > 4) {
      return oldValue;
    }

    String formattedText = digitsOnly;

    // Add slash after 2 digits
    if (digitsOnly.length >= 2) {
      formattedText =
          digitsOnly.substring(0, 2) + '/' + digitsOnly.substring(2);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
