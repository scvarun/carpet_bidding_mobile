class QueryInput {
  int? page = 1;
  int? limit = 10;
  String? search = "";

  QueryInput({this.page, this.limit, this.search}): super();

  factory QueryInput.fromJSON(Map<String, dynamic> json) {
    return QueryInput(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }

  toJSON() {
    return {
      page: page,
      limit: limit,
      search: search,
    };
  }
}