// supabase_ui icon builder.
//
//   dart run supabase_ui:build_icons [options]
//
// Scans the consuming app's lib/ for SupabaseIcons.<name> and
// SupabaseIconAssets.<name> usages, fetches only those SVGs from Lucide,
// compiles them to .vec under assets/supabase_icons/, removes unused compiled
// icons safely, generates lib/generated/supabase_icon_assets.dart, and
// registers the asset directory in pubspec.yaml.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

const String _assetDir = 'assets/supabase_icons';
const String _generatedFile = 'lib/generated/supabase_icon_assets.dart';
const String _usagePattern =
    r'(?:SupabaseIcons|SupabaseIconAssets)\.([A-Za-z_$][A-Za-z0-9_$]*)';

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('ref', defaultsTo: 'main', help: 'Lucide git ref to fetch.')
    ..addFlag(
      'clean',
      negatable: false,
      help: 'Re-fetch and recompile every used icon.',
    )
    ..addFlag(
      'keep-unused',
      negatable: false,
      help: 'Do not delete compiled icons that are no longer referenced.',
    )
    ..addFlag(
      'prune-empty',
      negatable: false,
      help: 'Delete all compiled icons when no icon usages are found.',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.');

  final ArgResults args;
  try {
    args = parser.parse(argv);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exit(64);
  }

  if (args.flag('help')) {
    stdout.writeln('Usage: dart run supabase_ui:build_icons [options]\n');
    stdout.writeln(parser.usage);
    return;
  }

  final ref = args.option('ref')!;
  final clean = args.flag('clean');
  final keepUnused = args.flag('keep-unused');
  final pruneEmpty = args.flag('prune-empty');
  final appRoot = Directory.current.path;

  final nameMap = await _loadIdentifierMap(appRoot);
  if (nameMap.isEmpty) {
    stderr.writeln(
      'Could not locate supabase_ui icon names. Run `flutter pub get` first.',
    );
    exit(1);
  }

  final assetDir = Directory(p.join(appRoot, _assetDir));
  await assetDir.create(recursive: true);

  final used = _scanUsedIdentifiers(appRoot);

  if (used.isEmpty) {
    await _writeAssetMap(appRoot, const {});
    await _ensurePubspecAsset(appRoot);

    final removed = !keepUnused && pruneEmpty
        ? await _removeUnusedIcons(assetDir, const {})
        : 0;

    stdout.writeln(
      pruneEmpty
          ? 'No icon usages found. removed=$removed total=0.'
          : 'No icon usages found. Skipped pruning. Use --prune-empty to delete cached icons.',
    );
    return;
  }

  final resolved = <String, String>{};
  final unknown = <String>[];

  for (final ident in used) {
    final kebab = nameMap[ident];
    if (kebab == null) {
      unknown.add(ident);
    } else {
      resolved[ident] = kebab;
    }
  }

  unknown.sort();
  for (final ident in unknown) {
    stderr.writeln('warning: SupabaseIcons.$ident is not a known Lucide icon.');
  }

  if (resolved.isEmpty) {
    await _writeAssetMap(appRoot, const {});
    await _ensurePubspecAsset(appRoot);
    stdout.writeln(
      'No known Lucide icon usages resolved. Skipped pruning to avoid deleting valid cached icons.',
    );
    return;
  }

  stdout.writeln('${resolved.length} icon(s) referenced.');

  var compiled = 0;
  var cached = 0;
  var failed = 0;

  final client = http.Client();

  try {
    final entries = resolved.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final entry in entries) {
      final kebab = entry.value;
      final outFile = File(p.join(assetDir.path, '$kebab.vec'));

      if (!clean && outFile.existsSync()) {
        cached++;
        continue;
      }

      try {
        final svg = await _fetchSvg(client, kebab, ref);
        final bytes = encodeSvg(
          xml: svg,
          debugName: kebab,
          enableMaskingOptimizer: false,
          enableClippingOptimizer: false,
          enableOverdrawOptimizer: false,
        );

        await outFile.writeAsBytes(bytes, flush: true);
        compiled++;
        stdout.writeln('  compiled $kebab.vec');
      } catch (e) {
        failed++;
        stderr.writeln('  failed $kebab: $e');
      }
    }
  } finally {
    client.close();
  }

  final present = <String, String>{
    for (final entry in resolved.entries)
      if (File(p.join(assetDir.path, '${entry.value}.vec')).existsSync())
        entry.key: entry.value,
  };

  final expectedFiles = present.values.map((name) => '$name.vec').toSet();

  var removed = 0;
  if (keepUnused) {
    removed = 0;
  } else if (failed > 0) {
    stderr.writeln(
      'Skipped pruning because one or more icons failed to compile.',
    );
  } else {
    removed = await _removeUnusedIcons(assetDir, expectedFiles);
  }

  await _writeAssetMap(appRoot, present);
  await _ensurePubspecAsset(appRoot);

  stdout.writeln(
    'Done. compiled=$compiled cached=$cached removed=$removed '
    'failed=$failed total=${present.length}.',
  );

  if (failed > 0) exit(1);
}

Future<Map<String, String>> _loadIdentifierMap(String appRoot) async {
  final packageRoot = await _resolvePackageRoot(appRoot, 'supabase_ui');
  if (packageRoot == null) return <String, String>{};

  final namesFile = File(
    p.join(packageRoot, 'lib', 'src', 'icons', 'supabase_icons.dart'),
  );

  if (!namesFile.existsSync()) return <String, String>{};

  final source = await namesFile.readAsString();
  final re = RegExp(r"static const String (\w+) = '([^']+)';");
  final map = <String, String>{};

  for (final match in re.allMatches(source)) {
    map[match.group(1)!] = match.group(2)!;
  }

  return map;
}

Future<String?> _resolvePackageRoot(String appRoot, String package) async {
  final configFile = File(p.join(appRoot, '.dart_tool', 'package_config.json'));
  if (!configFile.existsSync()) return null;

  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;

  final packages = (config['packages'] as List<dynamic>)
      .cast<Map<String, dynamic>>();

  for (final pkg in packages) {
    if (pkg['name'] != package) continue;

    final rootUri = pkg['rootUri'] as String;
    final base = Uri.file(p.join(appRoot, '.dart_tool') + p.separator);
    final resolved = base.resolve(rootUri);

    return p.normalize(resolved.toFilePath());
  }

  return null;
}

Set<String> _scanUsedIdentifiers(String appRoot) {
  final libDir = Directory(p.join(appRoot, 'lib'));
  if (!libDir.existsSync()) return <String>{};

  final re = RegExp(_usagePattern);
  final used = <String>{};
  final generatedPath = p.normalize(p.join(appRoot, _generatedFile));

  for (final entity in libDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;

    final path = p.normalize(entity.path);
    if (path == generatedPath) continue;

    final source = entity.readAsStringSync();
    for (final match in re.allMatches(source)) {
      used.add(match.group(1)!);
    }
  }

  return used;
}

Future<String> _fetchSvg(http.Client client, String name, String ref) async {
  final uri = Uri.parse(
    'https://raw.githubusercontent.com/lucide-icons/lucide/$ref/icons/$name.svg',
  );

  final response = await client.get(uri);

  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode} for $uri');
  }

  return response.body;
}

Future<int> _removeUnusedIcons(
  Directory assetDir,
  Set<String> expectedFiles,
) async {
  if (!assetDir.existsSync()) return 0;

  var removed = 0;

  for (final entity in assetDir.listSync(followLinks: false)) {
    if (entity is! File) continue;
    if (p.extension(entity.path) != '.vec') continue;

    final fileName = p.basename(entity.path);
    if (expectedFiles.contains(fileName)) continue;

    await entity.delete();
    removed++;
    stdout.writeln('  removed unused $fileName');
  }

  return removed;
}

Future<void> _writeAssetMap(String appRoot, Map<String, String> icons) async {
  final sorted = icons.keys.toList()..sort();

  final lines = <String>[
    for (final ident in sorted)
      "  static const String $ident = '$_assetDir/${icons[ident]}.vec';",
  ];

  final content =
      '''
// GENERATED CODE — DO NOT EDIT BY HAND.
//
// Produced by: dart run supabase_ui:build_icons
// Maps the SupabaseIcons your app uses to their compiled `.vec` asset paths.

/// Compiled vector asset paths for icons referenced in this app.
abstract final class SupabaseIconAssets {
  const SupabaseIconAssets._();

${lines.join('\n')}
}
''';

  final file = File(p.join(appRoot, _generatedFile));
  await file.parent.create(recursive: true);
  await file.writeAsString(content);
  stdout.writeln('Generated $_generatedFile (${icons.length} icons).');
}

Future<void> _ensurePubspecAsset(String appRoot) async {
  final pubspec = File(p.join(appRoot, 'pubspec.yaml'));

  if (!pubspec.existsSync()) {
    stderr.writeln(
      'warning: no pubspec.yaml found. Add `$_assetDir/` under flutter > assets manually.',
    );
    return;
  }

  final lines = pubspec.readAsLinesSync();
  const assetEntry = '    - $_assetDir/';

  if (lines.any((line) => line.trimRight() == assetEntry.trimRight())) {
    return;
  }

  final flutterIdx = lines.indexWhere((line) => line.trimRight() == 'flutter:');

  if (flutterIdx == -1) {
    lines.addAll(<String>['', 'flutter:', '  assets:', assetEntry]);
  } else {
    var assetsIdx = -1;

    for (var i = flutterIdx + 1; i < lines.length; i++) {
      final line = lines[i];

      if (line.isNotEmpty && !line.startsWith(' ')) break;

      if (line.trimRight() == '  assets:') {
        assetsIdx = i;
        break;
      }
    }

    if (assetsIdx == -1) {
      lines.insertAll(flutterIdx + 1, <String>['  assets:', assetEntry]);
    } else {
      lines.insert(assetsIdx + 1, assetEntry);
    }
  }

  await pubspec.writeAsString('${lines.join('\n')}\n');
  stdout.writeln('Registered $_assetDir/ in pubspec.yaml.');
}
