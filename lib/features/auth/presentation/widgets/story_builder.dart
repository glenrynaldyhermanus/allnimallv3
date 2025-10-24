class StoryBuilder {
  static String buildStory({
    required String category,
    required String name,
    required String gender,
    String? breed,
    DateTime? birthDate,
    List<String>? characters,
    String? story,
  }) {
    final buffer = StringBuffer();

    // Start with category and name
    final categoryText = _getCategoryText(category);
    buffer.write('Ada seekor $categoryText bernama $name.');

    // Add gender description with breed (if available)
    final genderAdjective = gender == 'male' ? 'ganteng' : 'cantik';
    if (breed != null && breed.isNotEmpty) {
      buffer.write(
        ' $name adalah seekor $categoryText $breed yang $genderAdjective.',
      );
    } else {
      buffer.write(' $name adalah seekor $categoryText yang $genderAdjective.');
    }

    // Add age if birthdate available
    if (birthDate != null) {
      final ageData = _calculateDetailedAge(birthDate);
      final years = ageData['years'] ?? 0;
      final months = ageData['months'] ?? 0;

      if (years > 0 || months > 0) {
        final yearsText = years > 0 ? '$years tahun' : '';
        final monthsText = months > 0 ? '$months bulan' : '';
        final ageText = [
          yearsText,
          monthsText,
        ].where((s) => s.isNotEmpty).join(' ');
        buffer.write(' Sekarang dia berusia $ageText.');
      }
    }

    // Add character if available
    if (characters != null && characters.isNotEmpty) {
      final charactersText = characters.map((c) => c.toLowerCase()).join(', ');
      buffer.write(' Karakternya $charactersText.');
    }

    // Add custom story text if available
    if (story != null && story.isNotEmpty) {
      buffer.write(' $story');
    }

    return buffer.toString();
  }

  static String _getCategoryText(String category) {
    switch (category.toLowerCase()) {
      case 'dog':
      case 'anjing':
        return 'anjing';
      case 'cat':
      case 'kucing':
        return 'kucing';
      default:
        return category.toLowerCase();
    }
  }

  static Map<String, int> _calculateDetailedAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    // Adjust if birthday hasn't occurred this year
    if (months < 0) {
      years--;
      months += 12;
    } else if (months == 0 && now.day < birthDate.day) {
      years--;
      months = 11;
    }

    return {'years': years, 'months': months};
  }
}
