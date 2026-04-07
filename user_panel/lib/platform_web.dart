// Sovereign V15: Ultra-Modern Web Interop
// Replaced deprecated dart:html with future-proof dart:js_interop [A_124 Standard]
import 'dart:js_interop';

@JS('window.open')
external void _windowOpen(String url, String target);

void openWindow(String url) {
  _windowOpen(url, '_blank');
}
