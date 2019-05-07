import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragment/fragment.dart';

// TODO test named subtrees

void main() {
  group('Fragments', () {
    testWidgets('should rebuild subtree only when deps are not identical',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
        key4: 4,
        child: Container(),
      ));
      expect(buildLog, [1, 4, 2, 3]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
        key4: 4,
        child: Container(),
      ));
      expect(buildLog, [1]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: -3,
        key4: 4,
        child: Container(),
      ));
      expect(buildLog, [3]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
        key4: 4,
        child: Container(),
      ));
      expect(buildLog, [2, 3]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
        key4: -4,
        child: Container(),
      ));
      expect(buildLog, [1, 4]);
      buildLog.clear();
    });
    testWidgets('should rebuild subtree when new root is of another type',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        child: Container(),
      ));
      expect(buildLog, [1, 4, 2, 3]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        child: Text('', textDirection: TextDirection.ltr),
      ));
      expect(buildLog, [1, 4, 2, 3]);
      buildLog.clear();
      await tester.pumpWidget(TestFragments(
        reportBuild: (v) => buildLog.add(v),
        child: Text('', textDirection: TextDirection.ltr),
      ));
      expect(buildLog, []);
    });
  });
}

class TestFragments<T extends Widget> extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;
  final int key4;
  final T child;

  const TestFragments(
      {Key key,
      this.reportBuild,
      this.key1,
      this.key2,
      this.key3,
      this.child,
      this.key4})
      : super(key: key);

  @override
  _TestFragmentsState<T> createState() => _TestFragmentsState<T>();
}

class _TestFragmentsState<T extends Widget> extends State<TestFragments<T>>
    with Fragments {
  @override
  Widget build(BuildContext context) {
    final s = fragment((_) => 'a', deps: []);
    assert(s is String);

    return Column(
      children: <Widget>[
        fragment((_) {
          widget.reportBuild(1);
          fragment((_) {
            widget.reportBuild(4);
          }, deps: [widget.key4]);
          return widget.child;
        }, deps: [widget.key1, widget.key4]),
        fragment((_) {
          widget.reportBuild(2);
          return widget.child;
        }, deps: [widget.key2]),
        fragment((_) {
          widget.reportBuild(3);
          return widget.child;
        }, deps: [widget.key3]),
      ],
    );
  }
}

class S extends StatefulWidget {
  @override
  _SState createState() => _SState();
}

class _SState extends State<S> with Fragments {
  String text;

  @override
  Widget build(BuildContext context) {
    return fragment((_) => Text(text), deps: [text]);
  }
}
