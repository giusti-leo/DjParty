import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:djparty/utils/formFactor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils/formFactor_mocks.dart';

@GenerateMocks([BuildContext])
BuildContext _createContext(Size size) {
  final context = MockBuildContext();
  final mediaQuery = MediaQuery(
    data: MediaQueryData(size: size),
    child: const SizedBox(),
  );
  when(context.widget).thenReturn(const SizedBox());
  when(context.findAncestorWidgetOfExactType()).thenReturn(mediaQuery);
  when(context.dependOnInheritedWidgetOfExactType<MediaQuery>())
      .thenReturn(mediaQuery);
  when(context.getElementForInheritedWidgetOfExactType())
      .thenReturn(InheritedElement(mediaQuery));

  return context;
}

void main() {
  group('Given a context return the device form factor', () {
    test('Handset device', () {
      var result = getFormFactor(_createContext(Size(350, 800)));
      expect(result, ScreenType.Handset);
    });

    test('Tablet device', () {
      var result = getFormFactor(_createContext(Size(650, 900)));
      expect(result, ScreenType.Tablet);
    });
  });
}
