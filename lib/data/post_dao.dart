import 'package:sembast/sembast.dart';
import '../model/post.dart';
import 'app_database.dart';

class PostDao {
  static const String POST_STORE_NAME = 'posts';
  final _postStore = intMapStoreFactory.store(POST_STORE_NAME);
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Post post) async {
    if (post.storyType == "Investment")
      await _postStore.add(await _db, post.toJsonInvestDao());
    else
      await _postStore.add(await _db, post.toJsonWageDao());
  }

  Future delete(Post post) async {
    final finder = Finder(filter: Filter.equals('id', post.id));
    await _postStore.delete(await _db, finder: finder);
  }

  Future<List<Post>> getAllBooks() async {
    final recordSnapshot = await _postStore.find(await _db);
    return recordSnapshot.map((snapshot) {
      print(snapshot.value);
      if (snapshot.value.containsValue('InvestingWith')) {
        final posts = Post.fromJsonI(snapshot.value);
        return posts;
      } else {
        final posts = Post.fromJsonW(snapshot.value);
        return posts;
      }
    }).toList();
  }
}
