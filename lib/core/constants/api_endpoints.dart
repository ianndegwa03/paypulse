class ApiEndpoints {
  // API Base URL
  static String get baseUrl => 'https://api.paypulse.com/v1';
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyPhone = '/auth/verify-phone';
  
  // User Endpoints
  static const String getProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String updatePreferences = '/users/preferences';
  static const String updateSecuritySettings = '/users/security-settings';
  
  // Wallet Endpoints
  static const String getWallets = '/wallets';
  static const String getWallet = '/wallets/{id}';
  static const String createWallet = '/wallets';
  static const String updateWallet = '/wallets/{id}';
  static const String deleteWallet = '/wallets/{id}';
  static const String transferFunds = '/wallets/transfer';
  static const String getWalletAnalytics = '/wallets/{id}/analytics';
  
  // Transaction Endpoints
  static const String getTransactions = '/transactions';
  static const String getTransaction = '/transactions/{id}';
  static const String createTransaction = '/transactions';
  static const String updateTransaction = '/transactions/{id}';
  static const String deleteTransaction = '/transactions/{id}';
  static const String categorizeTransaction = '/transactions/{id}/categorize';
  static const String exportTransactions = '/transactions/export';
  
  // Analytics Endpoints
  static const String getSpendingInsights = '/analytics/spending';
  static const String getFinancialHealth = '/analytics/health';
  static const String getPredictions = '/analytics/predictions';
  static const String getReports = '/analytics/reports';
  
  // Investment Endpoints
  static const String getInvestments = '/investments';
  static const String createInvestment = '/investments';
  static const String updateInvestment = '/investments/{id}';
  static const String getInvestmentPerformance = '/investments/{id}/performance';
  static const String rebalancePortfolio = '/investments/rebalance';
  
  // AI Endpoints
  static const String aiChat = '/ai/chat';
  static const String aiRecommendations = '/ai/recommendations';
  static const String aiPredictions = '/ai/predictions';
  static const String aiCategorization = '/ai/categorize';
  
  // Third-party Integrations
  static const String plaidLink = '/integrations/plaid/link';
  static const String stripePayment = '/integrations/stripe/payment';
  static const String marketData = '/integrations/market-data';
  
  // WebSocket Endpoints
  static const String wsBaseUrl = 'wss://ws.paypulse.com';
  static const String wsAuth = '$wsBaseUrl/auth';
  static const String wsNotifications = '$wsBaseUrl/notifications';
  static const String wsTransactions = '$wsBaseUrl/transactions';
  
  // Headers
  static const String appVersion = '1.0.0';
  static const String platform = 'flutter';
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}