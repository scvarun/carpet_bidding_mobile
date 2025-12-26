class ApiCurrency {
  String name;
  String slug;
  String symbol;

  ApiCurrency({required this.name, required this.slug, required this.symbol});

  factory ApiCurrency.fromJSON(Map<String, dynamic> json) {
    return ApiCurrency(
        name: json['name'], slug: json['slug'], symbol: json['symbol']);
  }
}
