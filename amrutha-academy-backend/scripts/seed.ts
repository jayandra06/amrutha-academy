import 'dotenv/config';
import { db } from '../lib/firebase/config';
import { COLLECTIONS } from '../lib/firebase/collections';
import { mockUsers, mockMentors, mockCategories, mockCourses, mockLessons, mockReviews, mockPromotes, mockSearchSuggestions } from '../lib/data/mockData';

async function seedData() {
  console.log('🌱 Starting to seed Firestore database...\n');

  try {
    // 1. Seed Mentors
    console.log('📚 Seeding mentors...');
    for (const mentor of mockMentors) {
      await db.collection(COLLECTIONS.MENTORS).doc(mentor.id).set({
        name: mentor.name,
        title: mentor.title,
        avatarUrl: mentor.avatarUrl,
      });
    }
    console.log(`✅ Seeded ${mockMentors.length} mentors\n`);

    // 2. Seed Categories
    console.log('📂 Seeding categories...');
    for (const category of mockCategories) {
      await db.collection(COLLECTIONS.CATEGORIES).doc(category.id).set({
        name: category.name,
      });
    }
    console.log(`✅ Seeded ${mockCategories.length} categories\n`);

    // 3. Seed Users
    console.log('👥 Seeding users...');
    for (const user of mockUsers) {
      await db.collection(COLLECTIONS.USERS).doc(user.id).set({
        fullName: user.fullName,
        email: user.email,
        avatar: user.avatar,
        bio: user.bio,
        phoneNumber: user.phoneNumber,
        birthday: user.birthday,
        location: user.location,
        role: user.role,
      });
    }
    console.log(`✅ Seeded ${mockUsers.length} users\n`);

    // 4. Seed Courses (with mentorId reference)
    console.log('🎓 Seeding courses...');
    for (const course of mockCourses) {
      await db.collection(COLLECTIONS.COURSES).doc(course.id).set({
        title: course.title,
        category: course.category,
        image: course.image,
        price: course.price,
        originalPrice: course.originalPrice,
        rating: course.rating,
        reviewsCount: course.reviewsCount,
        students: course.students,
        duration: course.duration,
        certificate: course.certificate,
        mentorId: course.mentor.id, // Store mentorId reference
        tools: course.tools,
        about: course.about,
        isFavourite: course.isFavourite || false,
      });
    }
    console.log(`✅ Seeded ${mockCourses.length} courses\n`);

    // 5. Seed Lessons (with courseId and order)
    console.log('📝 Seeding lessons...');
    let lessonCount = 0;
    for (const [courseId, lessons] of Object.entries(mockLessons)) {
      for (let i = 0; i < lessons.length; i++) {
        const lesson = lessons[i];
        await db.collection(COLLECTIONS.LESSONS).doc(lesson.id).set({
          courseId: courseId,
          title: lesson.title,
          duration: lesson.duration,
          videoUrl: lesson.videoUrl,
          isFree: lesson.isFree,
          order: i + 1, // Add order field
        });
        lessonCount++;
      }
    }
    console.log(`✅ Seeded ${lessonCount} lessons\n`);

    // 6. Seed Reviews
    console.log('⭐ Seeding reviews...');
    let reviewCount = 0;
    for (const [courseId, reviews] of Object.entries(mockReviews)) {
      for (const review of reviews) {
        await db.collection(COLLECTIONS.REVIEWS).doc(review.id).set({
          courseId: courseId,
          userId: review.userId,
          rating: review.rating,
          comment: review.comment,
          createdAt: new Date(review.createdAt),
        });
        reviewCount++;
      }
    }
    console.log(`✅ Seeded ${reviewCount} reviews\n`);

    // 7. Seed Promotions
    console.log('🎉 Seeding promotions...');
    for (const promote of mockPromotes) {
      await db.collection(COLLECTIONS.PROMOTES).doc(promote.id).set({
        title: promote.title,
        description: promote.description,
        discount: promote.discount,
        isActive: promote.isActive,
        expiryDate: new Date(promote.expiryDate),
      });
    }
    console.log(`✅ Seeded ${mockPromotes.length} promotions\n`);

    // 8. Seed Search Suggestions
    console.log('🔍 Seeding search suggestions...');
    await db.collection(COLLECTIONS.SEARCH_SUGGESTIONS).doc('default').set({
      suggestions: mockSearchSuggestions,
    });
    console.log(`✅ Seeded ${mockSearchSuggestions.length} search suggestions\n`);

    console.log('🎉 Database seeding completed successfully!');
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    throw error;
  }
}

// Run the seed function
seedData()
  .then(() => {
    console.log('\n✨ All done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n💥 Seeding failed:', error);
    process.exit(1);
  });

