// lib/graphql/admin_queries.dart

class AdminQueries {
  // Get all courses for admin
  static const String getAllCourses = '''
    query GetAllCourses {
      adminCourses {
        id
        title
        description
        level
        category
        skill_focus
        thumbnail
        color
        estimatedDuration
        totalUnits
        totalLessons
        totalExercises
        isPremium
        isPublished
        publishedAt
        learningObjectives
        difficulty
        totalXP
        enrollmentCount
        completionCount
        averageRating
        completionRate
        slug
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // Create course mutation
  static const String createCourse = '''
    mutation CreateCourse(\$input: CreateCourseInput!) {
      createCourse(input: \$input) {
        id
        title
        description
        level
        category
        skill_focus
        thumbnail
        color
        estimatedDuration
        totalUnits
        totalLessons
        totalExercises
        isPremium
        isPublished
        publishedAt
        learningObjectives
        difficulty
        totalXP
        enrollmentCount
        completionCount
        averageRating
        completionRate
        slug
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // Update course mutation
  static const String updateCourse = '''
    mutation UpdateCourse(\$id: ID!, \$input: UpdateCourseInput!) {
      updateCourse(id: \$id, input: \$input) {
        id
        title
        description
        level
        category
        skill_focus
        thumbnail
        color
        estimatedDuration
        totalUnits
        totalLessons
        totalExercises
        isPremium
        isPublished
        publishedAt
        learningObjectives
        difficulty
        totalXP
        enrollmentCount
        completionCount
        averageRating
        completionRate
        slug
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // Delete course mutation
  static const String deleteCourse = '''
    mutation DeleteCourse(\$id: ID!) {
      deleteCourse(id: \$id)
    }
  ''';

  // Publish course mutation
  static const String publishCourse = '''
    mutation PublishCourse(\$id: ID!) {
      publishCourse(id: \$id) {
        id
        title
        description
        level
        category
        skill_focus
        thumbnail
        color
        estimatedDuration
        totalUnits
        totalLessons
        totalExercises
        isPremium
        isPublished
        publishedAt
        learningObjectives
        difficulty
        totalXP
        enrollmentCount
        completionCount
        averageRating
        completionRate
        slug
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // Unpublish course mutation
  static const String unpublishCourse = '''
    mutation UnpublishCourse(\$id: ID!) {
      unpublishCourse(id: \$id) {
        id
        title
        description
        level
        category
        skill_focus
        thumbnail
        color
        estimatedDuration
        totalUnits
        totalLessons
        totalExercises
        isPremium
        isPublished
        publishedAt
        learningObjectives
        difficulty
        totalXP
        enrollmentCount
        completionCount
        averageRating
        completionRate
        slug
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  // ===============================================
  // UNIT QUERIES & MUTATIONS
  // ===============================================

  static const String getAllUnits = '''
    query GetAllUnits {
      adminUnits {
        id
        title
        description
        courseId
        theme
        icon
        color
        totalLessons
        totalExercises
        estimatedDuration
        isPremium
        isPublished
        xpReward
        sortOrder
        progressPercentage
        isUnlocked
        createdAt
      }
    }
  ''';

  static const String createUnit = '''
    mutation CreateUnit(\$input: CreateUnitInput!) {
      createUnit(input: \$input) {
        id
        title
        description
        courseId
        theme
        icon
        color
        totalLessons
        totalExercises
        estimatedDuration
        isPremium
        isPublished
        xpReward
        sortOrder
        createdAt
      }
    }
  ''';

  static const String updateUnit = '''
    mutation UpdateUnit(\$id: ID!, \$input: UpdateUnitInput!) {
      updateUnit(id: \$id, input: \$input) {
        id
        title
        description
        courseId
        theme
        icon
        color
        totalLessons
        totalExercises
        estimatedDuration
        isPremium
        isPublished
        xpReward
        sortOrder
        createdAt
      }
    }
  ''';

  static const String deleteUnit = '''
    mutation DeleteUnit(\$id: ID!) {
      deleteUnit(id: \$id)
    }
  ''';

  static const String publishUnit = '''
    mutation PublishUnit(\$id: ID!) {
      publishUnit(id: \$id) {
        id
        title
        isPublished
        publishedAt
      }
    }
  ''';

  static const String unpublishUnit = '''
    mutation UnpublishUnit(\$id: ID!) {
      unpublishUnit(id: \$id) {
        id
        title
        isPublished
        publishedAt
      }
    }
  ''';
  
  // ===============================================
  // LESSON QUERIES & MUTATIONS
  // ===============================================

  static const String getAllLessons = '''
    query GetAllLessons {
      adminLessons {
        id
        title
        description
        courseId
        unitId
        type
        lesson_type
        objective
        totalExercises
        estimatedDuration
        difficulty
        isPremium
        isPublished
        publishedAt
        xpReward
        perfectScoreBonus
        targetAccuracy
        passThreshold
        sortOrder
        status
        isCompleted
        isUnlocked
        userScore
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  static const String createLesson = '''
    mutation CreateLesson(\$input: CreateLessonInput!) {
      createLesson(input: \$input) {
        id
        title
        description
        courseId
        unitId
        type
        lesson_type
        objective
        totalExercises
        estimatedDuration
        difficulty
        isPremium
        isPublished
        publishedAt
        xpReward
        perfectScoreBonus
        targetAccuracy
        passThreshold
        sortOrder
        status
        isCompleted
        isUnlocked
        userScore
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  static const String updateLesson = '''
    mutation UpdateLesson(\$id: ID!, \$input: UpdateLessonInput!) {
      updateLesson(id: \$id, input: \$input) {
        id
        title
        description
        courseId
        unitId
        type
        lesson_type
        objective
        totalExercises
        estimatedDuration
        difficulty
        isPremium
        isPublished
        publishedAt
        xpReward
        perfectScoreBonus
        targetAccuracy
        passThreshold
        sortOrder
        status
        isCompleted
        isUnlocked
        userScore
        createdBy {
          id
          username
          displayName
        }
        createdAt
        updatedAt
      }
    }
  ''';

  static const String deleteLesson = '''
    mutation DeleteLesson(\$id: ID!) {
      deleteLesson(id: \$id)
    }
  ''';

  static const String publishLesson = '''
    mutation PublishLesson(\$id: ID!) {
      publishLesson(id: \$id) {
        id
        title
        isPublished
        publishedAt
      }
    }
  ''';

  static const String unpublishLesson = '''
    mutation UnpublishLesson(\$id: ID!) {
      unpublishLesson(id: \$id) {
        id
        title
        isPublished
        publishedAt
      }
    }
  ''';
  
  // ===============================================
  // LESSON ORDER MUTATIONS
  // ===============================================
  
  static const String setLessonOrder = '''
    mutation SetLessonOrder(\$lessonId: ID!, \$newSortOrder: Int!) {
      setLessonOrder(lessonId: \$lessonId, newSortOrder: \$newSortOrder) {
        success
        message
        lesson {
          id
          title
          sortOrder
        }
      }
    }
  ''';
  
  static const String setUnitOrder = '''
    mutation SetUnitOrder(\$unitId: ID!, \$newSortOrder: Int!) {
      setUnitOrder(unitId: \$unitId, newSortOrder: \$newSortOrder) {
        success
        message
        unit {
          id
          title
          sortOrder
        }
      }
    }
  ''';
} 