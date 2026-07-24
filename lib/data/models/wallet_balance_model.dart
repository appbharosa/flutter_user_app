class WalletBalanceModel {
  final double walletAmount; // or int, depending on your API

  WalletBalanceModel({required this.walletAmount});

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    final amount = result['wallet_amount'] ?? 0;
    // Convert safely (handles int or double)
    return WalletBalanceModel(
      walletAmount: (amount is num) ? amount.toDouble() : 0.0,
    );
  }
}