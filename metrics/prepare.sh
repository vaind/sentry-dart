#!/usr/bin/env bash
set -euo pipefail

targetDir=$(
  cd $(dirname $0)
  pwd
)
[[ "$targetDir" != "" ]] || exit 1

flutterCreate() {
  name=${1//-/_}
  dir=$targetDir/$1
  rm -rf $dir
  flutter create --template=app --no-pub --org 'io.sentry.dart' --project-name $name "$dir"
}

flutterCreate 'perf-test-app-plain'
flutterCreate 'perf-test-app-sentry'

pubspec="$targetDir/perf-test-app-sentry/pubspec.yaml"
echo "Adding dependencies to $pubspec"
cat <<EOF >>"$pubspec"

dependency_overrides:
  sentry:
    path: ../../dart
  sentry_flutter:
    path: ../../flutter

EOF

patch -p0 "$targetDir/perf-test-app-sentry/lib/main.dart" <<'EOF'
@@ -1,7 +1,12 @@
 import 'package:flutter/material.dart';
+import 'package:sentry_flutter/sentry_flutter.dart';

-void main() {
-  runApp(const MyApp());
+Future<void> main() async {
+  await SentryFlutter.init(
+    (options) => options.dsn =
+        'https://e85b375ffb9f43cf8bdf9787768149e0@o447951.ingest.sentry.io/5428562',
+    appRunner: () => runApp(const MyApp()),
+  );
 }

 class MyApp extends StatelessWidget {
EOF