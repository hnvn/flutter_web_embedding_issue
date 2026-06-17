import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'browser_info.dart';

void main() {
  runApp(const WebViewReproApp());
}

class WebViewReproApp extends StatelessWidget {
  const WebViewReproApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView repro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ReproPage(),
    );
  }
}

class ReproPage extends StatefulWidget {
  const ReproPage({super.key});

  @override
  State<ReproPage> createState() => _ReproPageState();
}

class _ReproPageState extends State<ReproPage> {
  final _offscreenKey = GlobalKey();
  Uint8List? _capturedPng;
  String? _captureStatus;
  double? _expandedMaxHeight;

  static const _subtitle = '今日のラッキーカードは';
  static const _title = '『紅梅色』';

  Future<void> _captureOffscreen() async {
    setState(() {
      _captureStatus = 'Capturing…';
      _capturedPng = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;

    final boundary = _offscreenKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      setState(() => _captureStatus = 'RepaintBoundary not found');
      return;
    }

    try {
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        setState(() => _captureStatus = 'toByteData returned null');
        return;
      }
      setState(() {
        _capturedPng = byteData.buffer.asUint8List();
        _captureStatus = 'Captured ${_capturedPng!.length} bytes';
      });
    } catch (error) {
      setState(() => _captureStatus = 'Capture failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAgent = browserUserAgent();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter web × Android WebView repro'),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('UA: $userAgent', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                const Text(
                  'Issue 1 — On-screen CJK text should be visible below. '
                  'In Android WebView it is often blank while layout space remains.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _labeledTextBlock(
                  label: 'On-screen text',
                  subtitle: _subtitle,
                  title: _title,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Issue 2 — Tap capture. Off-screen RepaintBoundary is placed '
                  'at left: -400. Caption text is often missing in WebView PNG.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _captureOffscreen,
                  child: const Text('Capture off-screen card'),
                ),
                if (_captureStatus != null) ...[
                  const SizedBox(height: 8),
                  Text(_captureStatus!),
                ],
                if (_capturedPng != null) ...[
                  const SizedBox(height: 12),
                  const Text('Capture preview (check caption text):'),
                  const SizedBox(height: 8),
                  Image.memory(_capturedPng!, height: 220),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Issue 3 — Expanded maxHeight should be > 0 when parent has height.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ColoredBox(
                    color: const Color(0xFFE8EAF6),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 48,
                          child: Center(child: Text('Header (48px)')),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_expandedMaxHeight != constraints.maxHeight) {
                                  setState(() {
                                    _expandedMaxHeight = constraints.maxHeight;
                                  });
                                }
                              });
                              return Center(
                                child: Text(
                                  'Expanded maxHeight: ${constraints.maxHeight.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: constraints.maxHeight <= 0
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_expandedMaxHeight != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Last reported maxHeight: $_expandedMaxHeight',
                      style: TextStyle(
                        color: (_expandedMaxHeight ?? 0) <= 0
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: -400,
            top: 0,
            child: RepaintBoundary(
              key: _offscreenKey,
              child: _labeledTextBlock(
                label: 'Off-screen capture target',
                subtitle: _subtitle,
                title: _title,
                width: 320,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledTextBlock({
    required String label,
    required String subtitle,
    required String title,
    double width = double.infinity,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Text(subtitle, textAlign: TextAlign.center, style: _subtitleStyle),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: _titleStyle),
        ],
      ),
    );
  }

  static const _subtitleStyle = TextStyle(fontSize: 14, color: Color(0xFF222222));
  static const _titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Color(0xFF222222),
  );
}
