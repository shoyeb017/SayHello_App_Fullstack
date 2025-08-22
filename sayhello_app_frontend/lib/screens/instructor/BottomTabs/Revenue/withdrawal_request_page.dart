import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../models/revenue.dart';
import '../../../../../providers/revenue_provider.dart';
import '../../../../../providers/auth_provider.dart';

class WithdrawalRequestPage extends StatefulWidget {
  final double availableBalance;

  const WithdrawalRequestPage({super.key, required this.availableBalance});

  @override
  State<WithdrawalRequestPage> createState() => _WithdrawalRequestPageState();
}

class _WithdrawalRequestPageState extends State<WithdrawalRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  // Payment method selection
  PaymentMethod _selectedPaymentMethod = PaymentMethod.bank;

  // Card details controllers
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // PayPal controllers
  final _paypalEmailController = TextEditingController();

  // Bank details controllers
  final _bankAccountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _swiftCodeController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _paypalEmailController.dispose();
    _bankAccountNumberController.dispose();
    _bankNameController.dispose();
    _swiftCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.withdrawMoney,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Available Balance Card
              _buildBalanceCard(isDark, localizations),
              const SizedBox(height: 16),

              // Withdrawal Amount
              _buildWithdrawalAmount(isDark, localizations),
              const SizedBox(height: 16),

              // Payment Method Selection
              _buildPaymentMethodSelection(isDark, localizations),
              const SizedBox(height: 16),

              // Payment Information
              _buildPaymentInformation(isDark, localizations),
              const SizedBox(height: 20),

              // Submit Button
              _buildSubmitButton(isDark, localizations),
              const SizedBox(height: 16),

              // Terms and Processing Info
              _buildTermsInfo(isDark, localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7A54FF),
            const Color(0xFF7A54FF).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.availableBalance,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${widget.availableBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.account_balance_wallet,
            color: Colors.white.withOpacity(0.8),
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalAmount(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.withdrawalAmount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _amountController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: localizations.enterAmountToWithdraw,
              hintStyle: const TextStyle(fontSize: 12),
              prefixText: '\$ ',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF7A54FF)),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.pleaseEnterWithdrawalAmount;
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return localizations.pleaseEnterValidAmount;
              }
              if (amount <= 0) {
                return localizations.amountMustBeGreaterThanZero;
              }
              if (amount > widget.availableBalance) {
                return localizations.amountExceedsAvailableBalance;
              }
              if (amount < 10) {
                return localizations.minimumWithdrawalAmountIs;
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuickAmountButton(localizations.quickAmount50, 50, isDark),
              const SizedBox(width: 6),
              _buildQuickAmountButton(
                localizations.quickAmount100,
                100,
                isDark,
              ),
              const SizedBox(width: 6),
              _buildQuickAmountButton(
                localizations.quickAmountMax,
                widget.availableBalance,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(String label, double amount, bool isDark) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          if (amount <= widget.availableBalance) {
            _amountController.text = amount.toStringAsFixed(2);
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF7A54FF),
          side: const BorderSide(color: Color(0xFF7A54FF)),
          padding: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _buildPaymentMethodSelection(
    bool isDark,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: PaymentMethod.values.map((method) {
              return RadioListTile<PaymentMethod>(
                title: Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(method),
                      size: 20,
                      color: const Color(0xFF7A54FF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      method.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                value: method,
                groupValue: _selectedPaymentMethod,
                onChanged: (PaymentMethod? value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                    // Clear form fields when changing payment method
                    _clearPaymentFields();
                  });
                },
                activeColor: const Color(0xFF7A54FF),
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethod.bank:
        return Icons.account_balance;
    }
  }

  void _clearPaymentFields() {
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
    _cardHolderController.clear();
    _paypalEmailController.clear();
    _bankAccountNumberController.clear();
    _bankNameController.clear();
    _swiftCodeController.clear();
  }

  Widget _buildPaymentInformation(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodForm(localizations),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodForm(AppLocalizations localizations) {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.card:
        return _buildCardForm(localizations);
      case PaymentMethod.paypal:
        return _buildPayPalForm(localizations);
      case PaymentMethod.bank:
        return _buildBankForm(localizations);
    }
  }

  Widget _buildCardForm(AppLocalizations localizations) {
    return Column(
      children: [
        _buildTextField(
          controller: _cardHolderController,
          label: 'Cardholder Name',
          hint: 'Enter name as on card',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _cardNumberController,
          label: 'Card Number',
          hint: 'Enter 16-digit card number',
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
            final digits = value.replaceAll(' ', '');
            if (digits.length != 16) {
              return 'Card number must be 16 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _expiryDateController,
                label: 'Expiry Date',
                hint: 'MM/YYYY',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                  _ExpiryDateFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter expiry date';
                  }
                  if (value.length != 7) {
                    return 'Invalid format';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                hint: 'Enter 3-digit CVV',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter CVV';
                  }
                  if (value.length != 3) {
                    return 'CVV must be 3 digits';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayPalForm(AppLocalizations localizations) {
    return _buildTextField(
      controller: _paypalEmailController,
      label: 'PayPal Email',
      hint: 'Enter your PayPal email address',
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter PayPal email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildBankForm(AppLocalizations localizations) {
    return Column(
      children: [
        _buildTextField(
          controller: _bankNameController,
          label: 'Bank Name',
          hint: 'Enter your bank name',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter bank name';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _bankAccountNumberController,
          label: 'Account Number',
          hint: 'Enter your account number',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            if (value.length < 8) {
              return 'Account number must be at least 8 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _swiftCodeController,
          label: 'SWIFT Code',
          hint: 'Enter SWIFT/BIC code',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter SWIFT code';
            }
            if (value.length < 8 || value.length > 11) {
              return 'SWIFT code must be 8-11 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Input formatters for card number and expiry date
  TextInputFormatter _CardNumberFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final digits = newValue.text.replaceAll(' ', '');
      if (digits.length <= 16) {
        final formatted = digits
            .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
            .trim();
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      return oldValue;
    });
  }

  TextInputFormatter _ExpiryDateFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      final digits = newValue.text.replaceAll('/', '');
      if (digits.length <= 6) {
        String formatted = digits;
        if (digits.length >= 2) {
          formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
        }
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      return oldValue;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF7A54FF)),
            ),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isDark, AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _submitWithdrawalRequest(localizations),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7A54FF),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          localizations.submitWithdrawalRequest,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsInfo(bool isDark, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF7A54FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF7A54FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF7A54FF),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                localizations.importantInformation,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7A54FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '• ${localizations.processingTime}\n'
            '• ${localizations.minimumWithdrawal}\n'
            '• ${localizations.noProcessingFees}\n'
            '• ${localizations.withdrawalsProcessedMondayFriday}\n'
            '• ${localizations.bankInformationEncrypted}',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _submitWithdrawalRequest(AppLocalizations localizations) {
    if (_formKey.currentState!.validate()) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.confirmWithdrawal),
          content: Text(_buildWithdrawalConfirmationMessage(localizations)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () => _processWithdrawal(localizations),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A54FF),
              ),
              child: Text(
                localizations.confirm,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _processWithdrawal(AppLocalizations localizations) async {
    Navigator.pop(context); // Close dialog

    // Get current user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    // Show loading
    _showLoadingDialog();

    try {
      final revenueProvider = Provider.of<RevenueProvider>(
        context,
        listen: false,
      );
      final amount = double.parse(_amountController.text);

      // Get payment method data
      final paymentData = _getPaymentMethodData();

      final success = await revenueProvider.submitWithdrawalRequest(
        instructorId: userId,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        cardNumber: paymentData['cardNumber'],
        expiryDate: paymentData['expiryDate'],
        cvv: paymentData['cvv'],
        cardHolderName: paymentData['cardHolderName'],
        paypalEmail: paymentData['paypalEmail'],
        bankAccountNumber: paymentData['bankAccountNumber'],
        bankName: paymentData['bankName'],
        swiftCode: paymentData['swiftCode'],
      );

      Navigator.pop(context); // Close loading dialog

      if (success) {
        Navigator.pop(context); // Go back to revenue page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.withdrawalRequestSubmittedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackBar(
          revenueProvider.error ?? 'Failed to submit withdrawal request',
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar('Error: $e');
    }
  }

  Map<String, dynamic> _getPaymentMethodData() {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.card:
        return {
          'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
          'expiryDate': _expiryDateController.text,
          'cvv': _cvvController.text,
          'cardHolderName': _cardHolderController.text,
        };
      case PaymentMethod.paypal:
        return {'paypalEmail': _paypalEmailController.text};
      case PaymentMethod.bank:
        return {
          'bankAccountNumber': _bankAccountNumberController.text,
          'bankName': _bankNameController.text,
          'swiftCode': _swiftCodeController.text,
        };
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing withdrawal...'),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _buildWithdrawalConfirmationMessage(AppLocalizations localizations) {
    final amount = '\$${_amountController.text}';
    String accountInfo = '';

    switch (_selectedPaymentMethod) {
      case PaymentMethod.card:
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        accountInfo = cardNumber.length >= 4
            ? '**** ${cardNumber.substring(cardNumber.length - 4)}'
            : '****';
        break;
      case PaymentMethod.paypal:
        accountInfo = _paypalEmailController.text;
        break;
      case PaymentMethod.bank:
        final accountNumber = _bankAccountNumberController.text;
        accountInfo = accountNumber.length >= 4
            ? '****${accountNumber.substring(accountNumber.length - 4)}'
            : '****';
        break;
    }

    return 'Withdraw $amount to ${_selectedPaymentMethod.displayName} ending in $accountInfo?';
  }
}
