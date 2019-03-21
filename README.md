# fragment

Easily prevent unnecessary build() calls in StatefulWidget and its subtrees.

If you know React, you may consider this as a `shouldComponentUpdate` alternate for Flutter.

## Getting Started

The library comes with a Mixin, `Fragments`, which you can add to your `State`. 

```dart

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
        fragment(() => Container(), [widget.key1]),
        fragment(() => Container(), [widget.key2]),
        fragment(() => Container(), [widget.key3]),
      ],
    );
  }
}

```

When one of `key1`, `key2` and `key3` updates, the other two `Container`s in other lines won't be recreated.

`fragment` method takes two parameters: a factory function which returns the target `Widget`, and an `Iterable` to determine when to call the factory. During each call, the second parameter is compared with the second parameter in previous call. If they are shallowly equal, the factory will be ignored and the return value from previous factory function is used as the return value of `fragment`, otherwise, the factory function is called and its return value is returned by `fragment`.

All `fragment` calls' order must be consistent across different passes of builds, so please be careful when using `fragment` in loops and conditionals.

