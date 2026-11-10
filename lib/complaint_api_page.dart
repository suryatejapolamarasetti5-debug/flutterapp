import 'package:flutter/material.dart';

import 'animations.dart';
import 'complaint_api_service.dart';
import 'complaint_card.dart';

/// Fetches complaints over the REST API and renders them.
///
/// The request is driven by a [FutureBuilder]: [ComplaintApiService.fetchComplaints]
/// is started once in `initState` and re-run on pull-to-refresh or retry.
class ComplaintApiPage extends StatefulWidget {
  const ComplaintApiPage({super.key, this.service});

  /// Injectable for tests; defaults to a fresh [ComplaintApiService].
  final ComplaintApiService? service;

  @override
  State<ComplaintApiPage> createState() => _ComplaintApiPageState();
}

class _ComplaintApiPageState extends State<ComplaintApiPage> {
  late final ComplaintApiService _service =
      widget.service ?? ComplaintApiService();

  late Future<List<Complaint>> _future = _fetch();

  final List<Complaint> _cart = <Complaint>[];

  Future<List<Complaint>> _fetch() => _service.fetchComplaints();

  void _reload() {
    setState(() {
      _future = _fetch();
    });
  }

  bool _isInCart(Complaint complaint) =>
      _cart.any((item) => item.id == complaint.id);

  void _addToCart(Complaint complaint) {
    setState(() {
      _cart.add(complaint);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${complaint.reference} added to cart '
            '(${_cart.length} item${_cart.length == 1 ? '' : 's'})',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _removeFromCart(Complaint complaint) {
    setState(() {
      _cart.removeWhere((item) => item.id == complaint.id);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${complaint.reference} removed from cart'),
        ),
      );
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Complaint>>(
        future: _future,
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              _header(snapshot),

              Expanded(
                child: Builder(
                  builder: (context) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return _errorView(snapshot.error);
                    }

                    final complaints = snapshot.data ?? const <Complaint>[];

                    if (complaints.isEmpty) {
                      return _emptyView();
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _reload(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: complaints.length,
                        itemBuilder: (context, index) {
                          final complaint = complaints[index];

                          return FadeSlideIn(
                            key: ValueKey<int>(complaint.id),
                            delay: Duration(
                              milliseconds: (index * 45).clamp(0, 400),
                            ),
                            slide: const Offset(0, 0.04),
                            child: ComplaintCard(
                              complaint: complaint,
                              isInCart: _isInCart(complaint),
                              onAddToCart: () => _addToCart(complaint),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              if (_cart.isNotEmpty) _cartBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _header(AsyncSnapshot<List<Complaint>> snapshot) {
    final count = snapshot.data?.length;

    return FadeSlideIn(
      duration: const Duration(milliseconds: 380),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
        child: AnimatedStatusHeader(
          title: 'Complaints API',
          subtitle: count == null
              ? 'Fetching reported streetlight issues'
              : '$count complaint${count == 1 ? '' : 's'} loaded',
          isActive: true,
        ),
      ),
    );
  }

  Widget _errorView(Object? error) {
    final message = error is ComplaintApiException
        ? error.message
        : 'Something went wrong while loading complaints.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cloud_off,
              size: 55,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),

            const SizedBox(height: 15),

            const Text(
              'Could not load complaints',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 20),

            PressScale(
              child: OutlinedButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(40),
        children: <Widget>[
          const SizedBox(height: 60),
          Icon(
            Icons.lightbulb_outline,
            size: 55,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.4),
          ),
          const SizedBox(height: 15),
          const Text(
            'No complaints yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Reported issues will appear here once they are submitted.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 8,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: <Widget>[
            BlinkingDot(color: colorScheme.primary),
            const SizedBox(width: 10),

            Expanded(
              child: Text(
                'Cart: ${_cart.length} item${_cart.length == 1 ? '' : 's'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            if (_cart.length == 1)
              Text(
                _cart.first.reference,
                style: TextStyle(
                  color:
                      colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),

            const SizedBox(width: 8),

            PressScale(
              child: TextButton.icon(
                onPressed: _cart.length == 1
                    ? () => _removeFromCart(_cart.first)
                    : null,
                icon: const Icon(Icons.remove_shopping_cart, size: 18),
                label: const Text('Remove'),
              ),
            ),

            PressScale(
              child: TextButton.icon(
                onPressed: _clearCart,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}