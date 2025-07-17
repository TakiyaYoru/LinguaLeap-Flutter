// lib/graphql/vocabulary_queries.dart
class VocabularyQueries {
  // Get user's vocabulary with filters
  static const String getMyVocabulary = '''
    query GetMyVocabulary(\$filters: VocabularyFilterInput) {
      myVocabulary(filters: \$filters) {
        id
        word
        meaning
        pronunciation
        example
        isLearned
        createdAt
        learnedAt
        difficulty
        category
        tags
        source
        reviewCount
      }
    }
  ''';

  // Get vocabulary statistics
  static const String getMyVocabularyStats = '''
    query GetMyVocabularyStats {
      myVocabularyStats {
        totalWords
        learnedWords
        unlearnedWords
        progressPercentage
        averageDifficulty
        totalReviews
      }
    }
  ''';

  // Add vocabulary word
  static const String addVocabularyWord = '''
    mutation AddVocabularyWord(\$input: VocabularyInput!) {
      addVocabularyWord(input: \$input) {
        id
        word
        meaning
        pronunciation
        example
        isLearned
        createdAt
        difficulty
        category
        tags
        source
      }
    }
  ''';

  // Toggle learned status
  static const String toggleVocabularyLearned = '''
    mutation ToggleVocabularyLearned(\$id: ID!) {
      toggleVocabularyLearned(id: \$id) {
        id
        word
        isLearned
        learnedAt
        reviewCount
      }
    }
  ''';

  // Delete vocabulary word
  static const String deleteVocabularyWord = '''
    mutation DeleteVocabularyWord(\$id: ID!) {
      deleteVocabularyWord(id: \$id)
    }
  ''';
}