class ApiConfig {
  // Finnhub API Configuration
  // Get free API key at: https://finnhub.io/register
  static const String finnhubApiKey = 'd7saqb9r01qorsvi1segd7saqb9r01qorsvi1sf0';
  static const String finnhubBaseUrl = 'https://finnhub.io/api/v1';
  
  // OpenAI API Configuration
  // Get API key at: https://platform.openai.com/api-keys
  static const String openaiApiKey = 'YOUR_OPENAI_API_KEY';
  static const String openaiModel = 'gpt-4o-mini';
  
  // Twelve Data API Configuration
  // Get free API key at: https://twelvedata.com/pricing
  static const String twelveDataApiKey = 'd2ca5bdf83144ceeaccfac3f6eda775b';
  static const String twelveDataBaseUrl = 'https://api.twelvedata.com/v1';
  
  // Financial Modeling Prep API Configuration
  // Get free API key at: https://financialmodelingprep.com/developer/docs/pricing
  static const String fmpBaseUrl = 'https://financialmodelingprep.com/api/v3';
  static const String fmpApiKey = 'yDo0kgtsXFaebhuJd74q15V2C1CnbRg9';
  
  // GoldAPI Configuration
  // Get API key at: https://www.goldapi.io/
  static const String goldApiBaseUrl = 'https://api.gold-api.com';
  static const String goldApiApiKey = 'goldapi-76fe75f00c4b1e4b73e1400e1776da9f-io';
  
  // Exchange mappings
  static const Map<String, String> exchangeSymbols = {
    'PSX': 'XKAR', // Pakistan Stock Exchange
    'NYSE': 'XNYS',
    'NASDAQ': 'XNAS',
    'LSE': 'XLON', // London Stock Exchange
  };
  
  // PSX major symbols (with proper suffixes for Twelve Data)
  static const List<String> psxSymbols = [
    'OGDC.PK', // Oil & Gas Development Company
    'PSO.PK',  // Pakistan State Oil
    'HBL.PK',  // Habib Bank Limited
    'UBL.PK',  // United Bank Limited
    'ENGRO.PK', // Engro Corporation
    'MCB.PK',  // Muslim Commercial Bank
    'LUCK.PK', // Lucky Cement
    'EFERT.PK', // Engro Fertilizer
  ];
  
  // API Endpoints
  
  // Twelve Data Endpoints
  static String getStockPrice(String symbol) => 
      '$twelveDataBaseUrl/price?symbol=$symbol&apikey=$twelveDataApiKey';
  
  static String getStockQuote(String symbol) => 
      '$twelveDataBaseUrl/quote?symbol=$symbol&apikey=$twelveDataApiKey';
  
  static String getTimeSeries(String symbol, {String interval = '1min', int outputsize = 30}) =>
      '$twelveDataBaseUrl/time_series?symbol=$symbol&interval=$interval&outputsize=$outputsize&apikey=$twelveDataApiKey';
  
  // Financial Modeling Prep Endpoints
  static String getMarketMovers(String type) => 
      '$fmpBaseUrl/$type?apikey=$fmpApiKey';
  
  static String getIndicesList() => 
      '$fmpBaseUrl/indices/list?apikey=$fmpApiKey';
  
  static String getStockMarketGainers() => 
      '$fmpBaseUrl/stock_market/gainers?apikey=$fmpApiKey';
  
  static String getStockMarketLosers() => 
      '$fmpBaseUrl/stock_market/losers?apikey=$fmpApiKey';
  
  static String getStockMarketMostActive() => 
      '$fmpBaseUrl/stock_market/most_active?apikey=$fmpApiKey';
  
  // GoldAPI Endpoints
  static String getGoldPrice() => 
      '$goldApiBaseUrl/price/XAU?apikey=$goldApiApiKey';
  
  static String getSilverPrice() => 
      '$goldApiBaseUrl/price/XAG?apikey=$goldApiApiKey';
  
  // Finnhub Endpoints
  static String getCompanyProfile(String symbol) =>
      '$finnhubBaseUrl/stock/profile2?symbol=$symbol&token=$finnhubApiKey';
  
  static String getMarketNews({String category = 'general'}) =>
      '$finnhubBaseUrl/news?category=$category&token=$finnhubApiKey';
  
  // Rate limiting configuration
  static const int maxRetries = 3;
  static const Duration timeout = Duration(seconds: 30);
  static const Duration rateLimitDelay = Duration(milliseconds: 100);
  
  // API rate limits (per minute)
  static const int twelveDataRateLimit = 8; // Free tier
  static const int fmpRateLimit = 250; // Free tier
  static const int goldApiRateLimit = 100; // Free tier
  static const int finnhubRateLimit = 60; // Free tier
}
