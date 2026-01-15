import { User, Course, Mentor, Category, Lesson, Review, Tool, Promote, SearchHistory } from '@/types';

// Mock Users
export const mockUsers: User[] = [
  {
    id: '1',
    fullName: 'John Doe',
    email: 'john@example.com',
    avatar: 'https://i.pravatar.cc/150?img=1',
    bio: 'Software Developer',
    phoneNumber: '+1234567890',
    birthday: '1990-01-01',
    location: 'New York, USA',
    role: 'student',
  },
  {
    id: '2',
    fullName: 'Jane Smith',
    email: 'jane@example.com',
    avatar: 'https://i.pravatar.cc/150?img=2',
    bio: 'Designer',
    phoneNumber: '+1234567891',
    birthday: '1992-05-15',
    location: 'Los Angeles, USA',
    role: 'student',
  },
];

// Mock Mentors
export const mockMentors: Mentor[] = [
  {
    id: '1',
    name: 'Sarah Johnson',
    title: 'Senior Full Stack Developer',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
  },
  {
    id: '2',
    name: 'Michael Chen',
    title: 'UX/UI Design Expert',
    avatarUrl: 'https://i.pravatar.cc/150?img=4',
  },
  {
    id: '3',
    name: 'Emily Davis',
    title: 'Data Science Specialist',
    avatarUrl: 'https://i.pravatar.cc/150?img=5',
  },
];

// Mock Categories
export const mockCategories: Category[] = [
  { id: '1', name: 'Programming' },
  { id: '2', name: 'Design' },
  { id: '3', name: 'Business' },
  { id: '4', name: 'Marketing' },
  { id: '5', name: 'Data Science' },
];

// Mock Tools
export const mockTools: Tool[] = [
  { name: 'VS Code', iconUrl: 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/vscode/vscode-original.svg' },
  { name: 'Git', iconUrl: 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/git/git-original.svg' },
  { name: 'Docker', iconUrl: 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/docker/docker-original.svg' },
];

// Mock Courses
export const mockCourses: Course[] = [
  {
    id: '1',
    title: 'Complete React Native Development Course',
    category: '1',
    image: 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=500',
    price: 4999,
    originalPrice: 9999,
    rating: 4.8,
    reviewsCount: 245,
    students: 1250,
    duration: 1200,
    certificate: true,
    mentor: mockMentors[0],
    tools: mockTools,
    about: 'Learn React Native from scratch and build real-world mobile applications.',
    isFavourite: false,
  },
  {
    id: '2',
    title: 'Advanced UI/UX Design Masterclass',
    category: '2',
    image: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=500',
    price: 3999,
    originalPrice: 7999,
    rating: 4.9,
    reviewsCount: 189,
    students: 890,
    duration: 900,
    certificate: true,
    mentor: mockMentors[1],
    tools: [mockTools[0], mockTools[1]],
    about: 'Master the art of UI/UX design with industry-standard practices.',
    isFavourite: true,
  },
  {
    id: '3',
    title: 'Data Science with Python',
    category: '5',
    image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500',
    price: 5999,
    originalPrice: 11999,
    rating: 4.7,
    reviewsCount: 312,
    students: 2100,
    duration: 1500,
    certificate: true,
    mentor: mockMentors[2],
    tools: mockTools,
    about: 'Comprehensive data science course covering Python, ML, and data analysis.',
    isFavourite: false,
  },
];

// Mock Lessons
export const mockLessons: Record<string, Lesson[]> = {
  '1': [
    { id: '1-1', title: 'Introduction to React Native', duration: 30, videoUrl: 'https://example.com/video1.mp4', isFree: true },
    { id: '1-2', title: 'Setting up Development Environment', duration: 45, videoUrl: 'https://example.com/video2.mp4', isFree: true },
    { id: '1-3', title: 'Components and Props', duration: 60, videoUrl: 'https://example.com/video3.mp4', isFree: false },
    { id: '1-4', title: 'State Management', duration: 75, videoUrl: 'https://example.com/video4.mp4', isFree: false },
  ],
  '2': [
    { id: '2-1', title: 'Design Principles', duration: 40, videoUrl: 'https://example.com/video5.mp4', isFree: true },
    { id: '2-2', title: 'Color Theory', duration: 50, videoUrl: 'https://example.com/video6.mp4', isFree: false },
    { id: '2-3', title: 'Typography', duration: 55, videoUrl: 'https://example.com/video7.mp4', isFree: false },
  ],
  '3': [
    { id: '3-1', title: 'Python Basics', duration: 60, videoUrl: 'https://example.com/video8.mp4', isFree: true },
    { id: '3-2', title: 'Data Analysis with Pandas', duration: 90, videoUrl: 'https://example.com/video9.mp4', isFree: false },
  ],
};

// Mock Reviews
export const mockReviews: Record<string, Review[]> = {
  '1': [
    { id: 'r1-1', courseId: '1', userId: '2', rating: 5, comment: 'Excellent course! Very comprehensive.', createdAt: '2024-01-15T10:00:00Z' },
    { id: 'r1-2', courseId: '1', userId: '1', rating: 4, comment: 'Good content, but could use more examples.', createdAt: '2024-01-20T14:30:00Z' },
  ],
  '2': [
    { id: 'r2-1', courseId: '2', userId: '1', rating: 5, comment: 'Amazing design course!', createdAt: '2024-02-01T09:15:00Z' },
  ],
  '3': [
    { id: 'r3-1', courseId: '3', userId: '2', rating: 4, comment: 'Great for beginners.', createdAt: '2024-02-10T16:45:00Z' },
  ],
};

// Mock Promotes
export const mockPromotes: Promote[] = [
  {
    id: '1',
    title: 'Summer Sale',
    description: 'Get 50% off on all courses',
    discount: '50%',
    isActive: true,
    expiryDate: '2024-12-31T23:59:59Z',
  },
  {
    id: '2',
    title: 'New Student Discount',
    description: 'Special offer for new students',
    discount: '30%',
    isActive: true,
    expiryDate: '2024-11-30T23:59:59Z',
  },
];

// Mock Search History
export const mockSearchHistory: SearchHistory[] = [
  { id: '1', keyword: 'React', searchedAt: '2024-01-10T10:00:00Z' },
  { id: '2', keyword: 'Design', searchedAt: '2024-01-11T14:30:00Z' },
  { id: '3', keyword: 'Python', searchedAt: '2024-01-12T09:15:00Z' },
];

// Mock Search Suggestions
export const mockSearchSuggestions: string[] = [
  'React Native',
  'React',
  'JavaScript',
  'Python',
  'Design',
  'UI/UX',
  'Data Science',
  'Machine Learning',
  'Web Development',
  'Mobile Development',
];

