import 'package:flutter/widgets.dart';

import 'utils.dart';

/// A mixin to add to your [State]
mixin Fragments<W extends StatefulWidget> on State<W> {
  /// Create a cached subtree.
  /// [builder] will be called only when [keys] is different (not shallowly equal)
  /// from the previous pass.
  T fragment<T>(T builder(T prev, Iterable prevKeys),
      {Iterable keys = const []}) {
    final parent = root.container.now;
    final isInit = parent.children.length <= parent.childCursor.now;
    final _CacheNode self =
        isInit ? _CacheNode() : parent.children[parent.childCursor.now];
    if (isInit) parent.children.add(self);
    assert(self.childCursor.now == 0);
    assert(identical(parent.children[parent.childCursor.now], self));

    if (isInit || !shallowEquals(self.item.keys, keys)) {
      root.container.now = self;
      self.item = _CacheItem(builder(self.item?.value, self.item?.keys), keys);
      assert(identical(root.container.now, self));
      root.container.now = parent;
    }

    self.childCursor.now = 0;
    parent.childCursor.now++;
    return self.item.value;
  }

  @override
  void reassemble() {
    root.reset();
    didInit.now = false;
    super.reassemble();
  }

  @override
  void didChangeDependencies() {
    root.childCursor.now = 0;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(oldWidget) {
    root.childCursor.now = 0;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void setState(fn) {
    root.childCursor.now = 0;
    super.setState(fn);
  }

  final root = _CacheRoot();
  final justReassembled = _Ref(false);
  final didInit = _Ref(false);
}

class _CacheItem {
  final Object value;
  final Iterable keys;

  _CacheItem(this.value, this.keys);
}

class _CacheRoot with _HasChildren {
  final container = _Ref<_HasChildren>(null);

  void reset() {
    super.reset();
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

  @override
  String toString() {
    return "Ref:" + now.toString();
  }
}
