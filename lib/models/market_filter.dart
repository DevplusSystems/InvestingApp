class MarketFilter {
  final String region;     // Global, USA, Pakistan, Asia
  final String category;   // Stocks, Indices, Commodities, Crypto
  final String type;       // Gainers, Losers, Most Active
  final String searchQuery;

  const MarketFilter({
    this.region = 'Global',
    this.category = 'All',
    this.type = 'Gainers',
    this.searchQuery = '',
  });

  MarketFilter copyWith({
    String? region,
    String? category,
    String? type,
    String? searchQuery,
  }) {
    return MarketFilter(
      region: region ?? this.region,
      category: category ?? this.category,
      type: type ?? this.type,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarketFilter &&
        other.region == region &&
        other.category == category &&
        other.type == type &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return region.hashCode ^
        category.hashCode ^
        type.hashCode ^
        searchQuery.hashCode;
  }

  @override
  String toString() {
    return 'MarketFilter(region: $region, category: $category, type: $type, searchQuery: $searchQuery)';
  }
}
