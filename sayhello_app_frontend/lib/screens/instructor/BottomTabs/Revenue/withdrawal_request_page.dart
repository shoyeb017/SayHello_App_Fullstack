import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../l10n/app_localizations.dart';

class WithdrawalRequestPage extends StatefulWidget {
  final double availableBalance;

  const WithdrawalRequestPage({super.key, required this.availableBalance});

  @override
  State<WithdrawalRequestPage> createState() => _WithdrawalRequestPageState();
}

class _WithdrawalRequestPageState extends State<WithdrawalRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _accountHolderController.dispose();
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

              // Bank Information
              _buildBankInformation(isDark, localizations),
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

  Widget _buildBankInformation(bool isDark, AppLocalizations localizations) {
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
            localizations.bankInformation,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // Account Holder Name
          _buildTextField(
            controller: _accountHolderController,
            label: localizations.accountHolderName,
            hint: localizations.enterFullNameAsOnBankAccount,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.pleaseEnterAccountHolderName;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Bank Name
          _buildTextField(
            controller: _bankNameController,
            label: localizations.bankName,
            hint: localizations.enterYourBankName,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.pleaseEnterBankName;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Account Number
          _buildTextField(
            controller: _accountNumberController,
            label: localizations.accountNumber,
            hint: localizations.enterYourAccountNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.pleaseEnterAccountNumber;
              }
              if (value.length < 8) {
                return localizations.accountNumberMustBeAtLeast8Digits;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Routing Number
          _buildTextField(
            controller: _routingNumberController,
            label: localizations.routingNumber,
            hint: localizations.enter9DigitRoutingNumber,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.pleaseEnterRoutingNumber;
              }
              if (value.length != 9) {
                return localizations.routingNumberMustBe9Digits;
              }
              return null;
            },
          ),
        ],
      ),
    );
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
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to revenue page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.withdrawalRequestSubmittedSuccessfully,
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
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

  String _buildWithdrawalConfirmationMessage(AppLocalizations localizations) {
    final amount = '\$${_amountController.text}';
    final lastFour = _accountNumberController.text.length > 4
        ? _accountNumberController.text.substring(
            _accountNumberController.text.length - 4,
          )
        : "****";

    // Build message based on language structure
    final locale = Localizations.localeOf(context).languageCode;

    switch (locale) {
      case 'ja':
        return '$amount を${localizations.withdrawToAccountEndingIn}$lastFour${localizations.withdrawConfirmationQuestion}';
      case 'ko':
        return '$lastFour${localizations.withdrawToAccountEndingIn} $amount${localizations.withdrawConfirmationQuestion}';
      case 'bn':
        return '$amount $lastFour${localizations.withdrawToAccountEndingIn} ${localizations.withdrawConfirmationQuestion}';
      case 'es':
        return '${localizations.withdrawToAccountEndingIn} $amount ${localizations.withdrawConfirmationQuestion} $lastFour?';
      default: // English
        return '${localizations.withdrawToAccountEndingIn} $amount ${localizations.withdrawConfirmationQuestion} $lastFour?';
    }
  }
}
