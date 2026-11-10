import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutterapp/complaint_api_page.dart';
import 'package:flutterapp/complaint_api_service.dart';

const String _listBody = '''
[
  {
    "id": 7,
    "complaint_type": "Flickering Light",
    "location": "MG Road, Bengaluru",
    "description": "Streetlight flickers after 9pm every night.",
    "priority": "High",
    "status": "Pending",
    "created_at": "2026-03-14T18:30:00.000Z"
  },
  {
    "id": 12,
    "complaint_type": "No Power",
    "location": "4th Cross, Indiranagar",
    "description": "Pole is completely dark since the storm.",
    "priority": "Medium",
    "status": "In Progress",
    "created_at": "2026-03-15T09:05:00.000Z"
  }
]
''';

ComplaintApiService _serviceReturning(String body, {int statusCode = 200}) {
  return ComplaintApiService(
    client: MockClient((request) async {
      return http.Response(body, statusCode);
    }),
  );
}

Widget _wrap(ComplaintApiService service) {
  return MaterialApp(home: Scaffold(body: ComplaintApiPage(service: service)));
}

/// The page is built from ambient looping widgets (BlinkingDot,
/// StatusIndicator), so `pumpAndSettle` never returns. Pump fixed frames
/// instead, long enough for the entry animations to finish.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  group('Complaint parsing', () {
    test('maps a JSON array into complaints', () {
      final complaints = ComplaintApiService.parseComplaints(_listBody);

      expect(complaints, hasLength(2));
      expect(complaints.first.id, 7);
      expect(complaints.first.type, 'Flickering Light');
      expect(complaints.first.location, 'MG Road, Bengaluru');
      expect(complaints.first.priority, 'High');
      expect(complaints.first.status, 'Pending');
      expect(complaints.first.reference, 'SL-007');
    });

    test('unwraps a list nested under data', () {
      final complaints = ComplaintApiService.parseComplaints(
        json.encode({
          'data': [
            {
              'id': 3,
              'complaint_type': 'Broken Pole',
              'location': 'Anna Salai',
              'description': 'Pole leaning badly.',
              'priority': 'Low',
              'status': 'Resolved',
              'created_at': '2026-01-02',
            },
          ],
        }),
      );

      expect(complaints, hasLength(1));
      expect(complaints.single.status, 'Resolved');
    });

    test('throws when the payload holds no list', () {
      expect(
        () => ComplaintApiService.parseComplaints('{"message": "ok"}'),
        throwsA(isA<ComplaintApiException>()),
      );
    });

    test('throws on malformed JSON', () {
      expect(
        () => ComplaintApiService.parseComplaints('not json'),
        throwsA(isA<ComplaintApiException>()),
      );
    });
  });

  group('fetchComplaints', () {
    test('returns complaints on 200', () async {
      final complaints = await _serviceReturning(_listBody).fetchComplaints();
      expect(complaints, hasLength(2));
    });

    test('throws ComplaintApiException on non-200', () async {
      await expectLater(
        _serviceReturning('{}', statusCode: 500).fetchComplaints(),
        throwsA(
          isA<ComplaintApiException>().having(
            (e) => e.message,
            'message',
            contains('500'),
          ),
        ),
      );
    });

    test('throws ComplaintApiException when the client fails', () async {
      final service = ComplaintApiService(
        client: MockClient((request) async => throw http.ClientException('down')),
      );

      await expectLater(
        service.fetchComplaints(),
        throwsA(isA<ComplaintApiException>()),
      );
    });
  });

  group('ComplaintApiPage', () {
    testWidgets('shows a spinner while loading', (tester) async {
      final gate = Completer<void>();
      final service = ComplaintApiService(
        client: MockClient((request) async {
          await gate.future;
          return http.Response(_listBody, 200);
        }),
      );

      await tester.pumpWidget(_wrap(service));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gate.complete();
      await _settle(tester);

      expect(find.text('Flickering Light'), findsOneWidget);
    });

    testWidgets('renders a ComplaintCard per complaint', (tester) async {
      await tester.pumpWidget(_wrap(_serviceReturning(_listBody)));
      await _settle(tester);

      expect(find.text('Flickering Light'), findsOneWidget);
      expect(find.text('No Power'), findsOneWidget);
      expect(find.textContaining('SL-007'), findsOneWidget);
      expect(find.text('Add to Cart'), findsNWidgets(2));
    });

    testWidgets('adds to cart, shows a SnackBar and rebuilds', (tester) async {
      await tester.pumpWidget(_wrap(_serviceReturning(_listBody)));
      await _settle(tester);

      expect(find.text('Cart: 0 items'), findsNothing);

      await tester.tap(find.text('Add to Cart').first);
      await tester.pump();

      expect(find.textContaining('SL-007 added to cart'), findsOneWidget);
      expect(find.text('Cart: 1 item'), findsOneWidget);
      expect(find.text('In Cart'), findsOneWidget);
    });

    testWidgets('clear empties the cart', (tester) async {
      await tester.pumpWidget(_wrap(_serviceReturning(_listBody)));
      await _settle(tester);

      await tester.tap(find.text('Add to Cart').first);
      await _settle(tester);
      expect(find.text('Cart: 1 item'), findsOneWidget);

      // Let the confirmation SnackBar finish so it stops covering the cart bar.
      await tester.pump(const Duration(seconds: 3));
      await _settle(tester);

      await tester.tap(find.text('Clear'));
      await _settle(tester);

      expect(find.text('Cart: 0 items'), findsNothing);
      expect(find.text('In Cart'), findsNothing);
      expect(find.text('Add to Cart'), findsWidgets);
    });

    testWidgets('shows the error state and retries', (tester) async {
      var calls = 0;
      final service = ComplaintApiService(
        client: MockClient((request) async {
          calls++;
          if (calls == 1) return http.Response('{}', 503);
          return http.Response(_listBody, 200);
        }),
      );

      await tester.pumpWidget(_wrap(service));
      await _settle(tester);

      expect(find.text('Could not load complaints'), findsOneWidget);
      expect(find.textContaining('503'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await _settle(tester);

      expect(find.text('Flickering Light'), findsOneWidget);
      expect(calls, 2);
    });

    testWidgets('shows the empty state for an empty list', (tester) async {
      await tester.pumpWidget(_wrap(_serviceReturning('[]')));
      await _settle(tester);

      expect(find.text('No complaints yet'), findsOneWidget);
    });
  });
}
