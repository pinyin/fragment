import 'package:collection/collection.dart';
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
        isInit ? _CacheNode(keys) : parent.children[parent.childCursor.now];
    if (isInit) parent.children.add(self);
    // TODO optimize & test
    if (parent is _CacheNode && !keys.every(parent.hasKey))
      throw 'Fragment\'s keys must be a subset of its outer fragment\'s keys.\n'
          'Received keys: $keys, outer ${parent.value ?? 'initalizing'} fragment\'s keys: ${parent.keys}.';

    assert(self.childCursor.now == 0);
    assert(identical(parent.children[parent.childCursor.now], self));

    if (isInit || !shallowEquals(self.keys, keys)) {
      root.container.now = self;
      self.value = builder(self.value, self.keys);
      assert(identical(root.container.now, self));
      root.container.now = parent;
    }

    self.childCursor.now = 0;
    parent.childCursor.now++;
    return self.value;
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
  Object value;
  Iterable keys;

  bool hasKey(Object key) {
    return keys.where((existingKey) => identical(key, existingKey)).isNotEmpty;
  }

  _CacheNode(this.keys);
}

mixin _HasChildren {
  @protected
  final children = QueueList<_CacheNode>();
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
