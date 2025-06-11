// lib/services/local/post_dao.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ppx_client/data/models/post_item_model.dart';

abstract class PostDao {
  Future<List<PostItem>> getAllPosts();

  Future<void> insertPosts(List<PostItem> posts); // 通常是 "upsert" 逻辑 (更新或插入)
  Future<void> clearAllPosts();
  // Future<PostItem?> getPostById(String id); // 可能需要的其他方法
}

// 示例：基于 Hive 的 PostDao 实现 (需要添加 hive 和 hive_flutter 包)
// 你需要为 PostItem 和 UserModel 创建 Hive TypeAdapters

class HivePostDao implements PostDao {
  static const String _boxName = 'postsBox';

  Future<Box<PostItem>> _getBox() async {
    // 确保 Box 已经打开
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<PostItem>(_boxName);
    }
    return Hive.box<PostItem>(_boxName);
  }

  @override
  Future<List<PostItem>> getAllPosts() async {
    final box = await _getBox();
    // Hive 存储的是 PostItem 对象，可以直接返回
    // 你可能需要根据时间戳排序等
    return box.values.toList()..sort((a, b) => b.id.compareTo(a.id)); // 简单按ID倒序
  }

  @override
  Future<void> insertPosts(List<PostItem> posts) async {
    final box = await _getBox();
    // 使用 post.id 作为 key，实现 "upsert"
    final Map<String, PostItem> postsMap = {
      for (var post in posts) post.id.toString(): post,
    };
    await box.putAll(postsMap);
  }

  @override
  Future<void> clearAllPosts() async {
    final box = await _getBox();
    await box.clear();
  }
}

// 注意：上面的 HivePostDao 是一个示例。你需要：
// 1. 在 pubspec.yaml 中添加 hive, hive_flutter, hive_generator, build_runner。
// 2. 为 PostItem 和 UserModel 生成 TypeAdapter (使用 @HiveType 和 @HiveField 注解)。
// 3. 在 main.dart 中初始化 Hive (await Hive.initFlutter();) 并注册 Adapters。
