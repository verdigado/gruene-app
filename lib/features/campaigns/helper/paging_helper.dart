class PagingHelper {
  static int getOffsetForPage(int pageKey, int pageSize) {
    return (pageKey - 1) * pageSize;
  }
}
