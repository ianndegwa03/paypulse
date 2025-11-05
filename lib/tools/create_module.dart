// tools/create_module.dart
void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart create_module.dart <module_name>');
    return;
  }
  
  final moduleName = args[0];
  final generator = ModuleGenerator(moduleName);
  generator.generate();
}

class ModuleGenerator {
  final String moduleName;
  
  ModuleGenerator(this.moduleName);
  
  void generate() {
    _createDirectoryStructure();
    _generateDomainLayer();
    _generateDataLayer();
    _generatePresentationLayer();
    _generateDIModule();
    _updateFeatureRegistry();
  }
  
  void _createDirectoryStructure() {
    final directories = [
      'lib/features/$moduleName/domain/entities',
      'lib/features/$moduleName/domain/repositories',
      'lib/features/$moduleName/domain/use_cases',
      'lib/features/$moduleName/data/datasources',
      'lib/features/$moduleName/data/repositories',
      'lib/features/$moduleName/data/models',
      'lib/features/$moduleName/presentation/bloc',
      'lib/features/$moduleName/presentation/screens',
      'lib/features/$moduleName/presentation/widgets',
      'lib/features/$moduleName/di',
    ];
    
    for (final dir in directories) {
      Directory(dir).createSync(recursive: true);
    }
  }
}
