abstract class Storage {
  Future<void> write({
    required String key,
    required String? value,
  });

  Future<String?> read({
    required String key,
  });

  Future<void> delete({
    required String key,
  });

  Future<bool> containsKey({required String key});
}
