enum LoadStatus {
  idle,
  loading,
  success,
  failure;

  bool get isIdle => this == LoadStatus.idle;
  bool get isLoading => this == LoadStatus.loading;
  bool get isSuccess => this == LoadStatus.success;
  bool get isFailure => this == LoadStatus.failure;
}
