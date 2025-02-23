class SearchHistoryEntity {
  final String id;
  final String keyword;
  final DateTime searchedAt;

  SearchHistoryEntity({
    required this.id,
    required this.keyword,
    required this.searchedAt,
  });
}
