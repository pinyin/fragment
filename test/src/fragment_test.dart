import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragment/fragment.dart';

// TODO test context

void main() {
  group('Fragment', () {
    testWidgets('should rebuild subtree when deps are not identical',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
        child: Container(),
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
        child: Container(),
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: -3,
        child: Container(),
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
        child: Container(),
      ));
      expect(buildLog, [1, 2, 3, 1, 3, 2, 3]);
    });
    testWidgets('should rebuild subtree when new root is of another type',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
        child: Container(),
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
        child: Text('', textDirection: TextDirection.ltr),
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
        child: Text('', textDirection: TextDirection.ltr),
      ));
      expect(buildLog, [1, 2, 3, 1, 2, 3, 1]);
    });
  });
}

class TestFragment<T extends Widget> extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;
  final T child;

  const TestFragment(
      {Key key, this.reportBuild, this.key1, this.key2, this.key3, this.child})
      : super(key: key);

  @override
  _TestFragmentState<T> createState() => _TestFragmentState<T>();
}

class _TestFragmentState<T extends Widget> extends State<TestFragment<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Fragment(
          builder: (context) {
            context.widget;
            widget.reportBuild(1);
            return widget.child;
          },
          deps: [widget.key1],
        ),
        Fragment(
          builder: (context) {
            widget.reportBuild(2);
            return widget.child;
          },
          deps: [widget.key2],
        ),
        Fragment(
          builder: (context) {
            widget.reportBuild(3);
            return widget.child;
          },
          deps: [widget.key3],
        ),
      ],
    );
  }
}
