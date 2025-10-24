import '../entities/health_parameter_definition_entity.dart';

class CalculateHealthScore {
  /// Simple binary health score calculation
  /// Returns 'healthy' if all parameters are OK
  /// Returns 'needs_attention' if any parameter has an issue
  String call({
    required Map<String, dynamic> healthParameters,
    required List<HealthParameterDefinitionEntity> parameterDefinitions,
  }) {
    // Only check parameters that affect health score
    final scoringParameters = parameterDefinitions
        .where((def) => def.affectsHealthScore)
        .toList();

    for (final definition in scoringParameters) {
      final value = healthParameters[definition.parameterKey];

      if (value == null) {
        // If a required parameter is missing, flag as needs attention
        if (definition.isRequired) {
          return 'needs_attention';
        }
        continue;
      }

      // Check for issues based on parameter type and key
      bool hasIssue = _checkParameterIssue(
        definition.parameterKey,
        definition.parameterType,
        value,
      );

      if (hasIssue) {
        return 'needs_attention';
      }
    }

    return 'healthy';
  }

  bool _checkParameterIssue(
    String parameterKey,
    String parameterType,
    dynamic value,
  ) {
    switch (parameterType) {
      case 'boolean':
        // Parameters that should be true for health
        if (_shouldBeTrueParameters.contains(parameterKey)) {
          return value != true;
        }
        // Parameters that should be false for health (has_fleas, has_worms, etc.)
        if (_shouldBeFalseParameters.contains(parameterKey)) {
          return value == true;
        }
        return false;

      case 'select':
        // Check for problematic select values
        if (value is String) {
          return _problematicSelectValues.contains(value);
        }
        return false;

      default:
        return false;
    }
  }

  // Parameters that should be true for a healthy pet
  static const _shouldBeTrueParameters = [
    'is_vaccinated',
    'is_sterilized',
    'calcium_phosphorus_balanced',
    'diet_appropriate',
  ];

  // Parameters that should be false for a healthy pet
  static const _shouldBeFalseParameters = [
    'has_fungus',
    'has_worms',
    'has_fleas',
    'has_mites',
  ];

  // Problematic values for select-type parameters
  static const _problematicSelectValues = ['bad', 'needs_check', 'poor'];
}
