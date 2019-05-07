import 'package:flutter/widgets.dart';

import 'utils.dart';

/// A mixin to add to your [State]
mixin Fragments<W extends StatefulWidget> on State<W> {
  /// Create a cached subtree.
  /// [builder] will be called only when [deps] is different (not shallowly equal)
  /// from the previous pass.
  T fragment<T>(T builder(T prev), {Iterable deps = const [], Key key}) {
    if (root.isLocked.now) {
      final parent = root.container.now;
      final self = parent.children[parent.childCursor.now];
      assert(self.childCursor.now == 0);

      if (self.item.value is! T || !shallowEquals(self.item.deps, deps)) {
        root.container.now = self;
        self.item = _CacheItem(builder(self.item.value), deps);
        assert(identical(root.container.now, self));
        root.container.now = parent;
      }

      self.childCursor.now = 0;
      parent.childCursor.now++;
      return self.item.value;
    } else {
      // FIXME lock disappears sometimes
      final parent = root.container.now;
      final self = _CacheNode();
      parent.children.add(self);
      assert(identical(parent.children[parent.childCursor.now], self));

      root.container.now = self;
      self.item = _CacheItem(builder(null), deps);
      assert(identical(root.container.now, self));
      root.container.now = parent;

      self.childCursor.now = 0;
      parent.childCursor.now++;
      return self.item.value;
    }
  }

  @override
  @mustCallSuper
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    root.childCursor.now = 0;
    root.isLocked.now = true;
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (didInit.now) {
      root.childCursor.now = 0;
      root.isLocked.now = true;
    } else {
      didInit.now = true;
    }
  }

  @override
  @mustCallSuper
  void setState(VoidCallback fn) {
    super.setState(fn);
    root.childCursor.now = 0;
    root.isLocked.now = true;
  }

  @override
  void reassemble() {
    super.reassemble();
    root.reset();
  }

  final root = _CacheRoot();
  final didInit = _Ref(false);
}

class _CacheItem {
  final Object value;
  final Iterable deps;

  _CacheItem(this.value, this.deps);
}

class _CacheRoot with _HasChildren {
  final container = _Ref<_HasChildren>(null);

  final isLocked = _Ref(false);

  void reset() {
    super.reset();
    isLocked.now = false;
    container.now = this;
  }

  _CacheRoot() {
    container.now = this;
  }
}

class _CacheNode with _HasChildren {
  _CacheItem item;
}

mixin _HasChildren {
  @protected
  final children = List<_CacheNode>();
  final childCursor = _Ref(0);

  @mustCallSuper
  void reset() {
    children.clear();
    childCursor.now = 0;
  }
}

class _Ref<T> {
  _Ref(T init) : now = init;
  T now;
}
