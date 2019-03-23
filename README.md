# fragment

Easily prevent unnecessary build() calls in StatefulWidget and its subtrees.

If you know React, you may consider this as a `shouldComponentUpdate` alternate for Flutter.

## Usage

The library comes with a mixin `Fragments` an a widget `Fragment`.

### Mixin API

You can add `Fragments` mixin to your `State` to get an additional method `fragment`: 

```dart

import 'package:fragment/fragment.dart';


class FragmentContainer extends StatefulWidget {
  final int key1;
  final int key2;
  final int key3;

  const FragmentContainer( {Key key, this.key1, this.key2, this.key3}) : super(key: key);

  @override
  _FragmentContainerState createState() => _FragmentContainerState();
}

class _FragmentContainerState extends State<FragmentContainer> with Fragments {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        fragment(builder: () => Container(), deps: [widget.key1]),
        fragment(builder: () => Container(), deps: [widget.key2]),
        fragment(builder: () => Container(), deps: [widget.key3]),
      ],
    );
  }
}

```

When one of `key1`, `key2` and `key3` updates, the other two `Container` widgets in other lines won't be recreated.

`fragment` method takes two parameters: a builder function which returns the target `Widget`, and an `Iterable` to determine when to call the builder. During each call, the second parameter is compared with the second parameter in previous call. If they are shallowly equal, current builder will be ignored and the cached widget is used as the return value of `fragment`, otherwise, the builder gets called and its return value is cached and returned by `fragment`.

All `fragment` calls' order must be consistent across different passes of builds, so please be careful when using `fragment` in loops and conditionals.

### Widget API

Import and use `Fragment` as a widget:

```dart

import 'package:fragment/fragment.dart';

class TestFragment extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;

  const TestFragment(
      {Key key, this.reportBuild, this.key1, this.key2, this.key3})
      : super(key: key);

  @override
  _TestFragmentState createState() => _TestFragmentState();
}

class _TestFragmentState extends State<TestFragment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Fragment(
          builder: (BuildContext context) => Container(),
          deps: [widget.key1],
        ),
        Fragment(
          builder: (BuildContext context) => Container(),
          deps: [widget.key2],
        ),
        Fragment(
          builder: (BuildContext context) => Container(),
          deps: [widget.key3],
        ),
      ],
    );
  }
}
```

This will give you a similar behavior like the mixin API.

## Q & A

Q: 
What's the difference between the mixin API and the widget API?

A:

Sadly, there's probably no prefect way to cache a widget's subtrees. Each of them have its own pros and cons.

The mixin API allows you to return anything from your `fragment`: a list, a `PreferredSizeWidget`, a builder... which makes it the only way to go in some situations like caching a [Material AppBar](https://docs.flutter.io/flutter/material/AppBar-class.html), where the parent widget `Scaffold` is expecting [a subtype of `Widget`](https://docs.flutter.io/flutter/material/Scaffold/appBar.html) instead of a `Widget` .

The widget API also has its own pros: you can use context in your builder and everything would work as expected, e.g. when you want to use `InheritedModel` in your subtree.

TL;DR: use `Fragment` widget when you want to use context, use `fragment` when you want to keep the type of your cached subtree.

## Future Plans

Add more tests.