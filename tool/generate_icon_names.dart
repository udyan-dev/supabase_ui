// Generates `lib/src/icons/supabase_icons.dart` from the upstream Lucide icon
// set. Run locally or from CI (see .github/workflows/sync_lucide.yml):
//
//   dart run tool/generate_icon_names.dart [--ref <git-ref>]
//
// It lists every `*.svg` under Lucide's `icons/` directory via the GitHub Git
// Trees API, converts each kebab-case filename to a valid Dart identifier, and
// writes a `SupabaseIcons` class of `static const <ident> = '<kebab>';` entries.
// No SVG content is downloaded and no assets are bundled — names only.

import 'dart:convert';
import 'dart:io';

const String _repo = 'lucide-icons/lucide';
const String _outputPath = 'lib/src/icons/supabase_icons.dart';

Future<void> main(List<String> args) async {
  final ref = _argValue(args, '--ref') ?? 'main';
  stdout.writeln('Fetching Lucide icon list @ $ref …');

  final names = await _fetchIconNames(ref);
  if (names.isEmpty) {
    stderr.writeln('No icons found — aborting.');
    exit(1);
  }
  names.sort();
  stdout.writeln('Found ${names.length} icons.');

  final buffer = _renderSource(names, ref);
  final file = File(_outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(buffer);
  stdout.writeln('Wrote $_outputPath');
}

String? _argValue(List<String> args, String flag) {
  final i = args.indexOf(flag);
  if (i != -1 && i + 1 < args.length) return args[i + 1];
  return null;
}

/// Lists icon names using the GitHub Git Trees API (one request, recursive).
Future<List<String>> _fetchIconNames(String ref) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(
      'https://api.github.com/repos/$_repo/git/trees/$ref?recursive=1',
    );
    final request = await client.getUrl(uri);
    request.headers
      ..set(HttpHeaders.userAgentHeader, 'supabase_ui-icon-generator')
      ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    // Optional auth lifts the unauthenticated rate limit in CI.
    final token = Platform.environment['GITHUB_TOKEN'];
    if (token != null && token.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }

    final response = await request.close();
    if (response.statusCode != 200) {
      stderr.writeln('GitHub API returned ${response.statusCode}.');
      return <String>[];
    }
    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final tree = (json['tree'] as List<dynamic>).cast<Map<String, dynamic>>();

    final names = <String>{};
    for (final node in tree) {
      final path = node['path'] as String;
      if (path.startsWith('icons/') &&
          path.endsWith('.svg') &&
          !path.substring(6).contains('/')) {
        names.add(path.substring(6, path.length - 4));
      }
    }
    return names.toList();
  } finally {
    client.close();
  }
}

/// kebab-case → lowerCamelCase, guaranteed to be a valid Dart identifier.
String _identifier(String kebab) {
  final parts = kebab.split('-').where((p) => p.isNotEmpty).toList();
  final buffer = StringBuffer(parts.first.toLowerCase());
  for (var i = 1; i < parts.length; i++) {
    final p = parts[i];
    buffer
      ..write(p[0].toUpperCase())
      ..write(p.substring(1).toLowerCase());
  }
  var id = buffer.toString();
  // Identifiers can't start with a digit; prefix names like `2fa`.
  if (RegExp(r'^[0-9]').hasMatch(id)) id = 'icon$id';
  if (_dartKeywords.contains(id)) id = '${id}Icon';
  return id;
}

const Set<String> _dartKeywords = <String>{
  'abstract',
  'else',
  'import',
  'show',
  'as',
  'enum',
  'in',
  'static',
  'assert',
  'export',
  'interface',
  'super',
  'async',
  'extends',
  'is',
  'switch',
  'await',
  'extension',
  'late',
  'sync',
  'break',
  'external',
  'library',
  'this',
  'case',
  'factory',
  'mixin',
  'throw',
  'catch',
  'false',
  'new',
  'true',
  'class',
  'final',
  'null',
  'try',
  'const',
  'finally',
  'on',
  'typedef',
  'continue',
  'for',
  'operator',
  'var',
  'covariant',
  'function',
  'part',
  'void',
  'default',
  'get',
  'required',
  'while',
  'deferred',
  'hide',
  'rethrow',
  'with',
  'do',
  'if',
  'return',
  'yield',
  'dynamic',
  'implements',
  'set',
};

String _renderSource(List<String> names, String ref) {
  final seen = <String, String>{}; // identifier -> kebab
  final lines = <String>[];
  for (final kebab in names) {
    var id = _identifier(kebab);
    // De-duplicate the rare collision deterministically.
    if (seen.containsKey(id)) {
      var n = 2;
      while (seen.containsKey('$id$n')) {
        n++;
      }
      id = '$id$n';
    }
    seen[id] = kebab;
    lines.add("  static const String $id = '$kebab';");
  }

  return '''
// GENERATED CODE — DO NOT EDIT BY HAND.
//
// Source: github.com/$_repo (ref: $ref)
// Regenerate: dart run tool/generate_icon_names.dart
//
// Contains the name of every Lucide icon. No SVG/asset data is bundled — these
// strings are resolved to `.vec` assets app-side by `dart run supabase_ui:build_icons`.

/// Strongly-typed names for every Lucide icon (${names.length} total).
abstract final class SupabaseIcons {
  const SupabaseIcons._();

${lines.join('\n')}
}
''';
}
