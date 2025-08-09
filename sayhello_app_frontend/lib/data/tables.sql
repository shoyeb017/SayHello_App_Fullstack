-- ==============================
-- ENUMS (all lowercase)
-- ==============================
CREATE TYPE gender_enum AS ENUM ('male', 'female');
CREATE TYPE country_enum AS ENUM ('usa', 'spain', 'japan', 'korea', 'bangladesh');
CREATE TYPE language_enum AS ENUM ('english', 'spanish', 'japanese', 'korean', 'bangla');
CREATE TYPE language_level_enum AS ENUM ('beginner', 'elementary', 'intermediate', 'advanced', 'proficient');
CREATE TYPE message_type_enum AS ENUM ('text', 'image');
CREATE TYPE message_status_enum AS ENUM ('read', 'unread');
CREATE TYPE course_level_enum AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE course_status_enum AS ENUM ('upcoming', 'active', 'expired');
CREATE TYPE session_platform_enum AS ENUM ('meet', 'zoom');
CREATE TYPE material_type_enum AS ENUM ('pdf', 'document', 'image');
CREATE TYPE group_chat_sender_enum AS ENUM ('learner', 'instructor');
CREATE TYPE feedback_type_enum AS ENUM ('learner', 'instructor', 'course');
CREATE TYPE notification_type_enum AS ENUM ('session alert', 'feedback');

-- ==============================
-- 1. learners
-- ==============================
CREATE TABLE learners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_image TEXT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    date_of_birth DATE,
    gender gender_enum,
    country country_enum,
    bio TEXT,
    native_language language_enum,
    learning_language language_enum,
    language_level language_level_enum,
    interests TEXT[], -- Array of strings
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 2. instructors
-- ==============================
CREATE TABLE instructors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_image TEXT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    date_of_birth DATE,
    gender gender_enum,
    country country_enum,
    bio TEXT,
    native_language language_enum,
    teaching_language language_enum,
    years_of_experience INT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 3. followers (learner only)
-- ==============================
CREATE TABLE followers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_user_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    followed_user_id UUID REFERENCES learners(id) ON DELETE CASCADE
);

-- ==============================
-- 4. chats (learner only)
-- ==============================
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    user2_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 5. messages
-- ==============================
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    content_text TEXT,
    type message_type_enum,
    status message_status_enum,
    correction TEXT,
    translated_content TEXT,
    parent_msg_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 6. feed
-- ==============================
CREATE TABLE feed (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    content_text TEXT,
    content_image_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 7. feed_likes
-- ==============================
CREATE TABLE feed_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feed_id UUID REFERENCES feed(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 8. feed_comments
-- ==============================
CREATE TABLE feed_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feed_id UUID REFERENCES feed(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    content_text TEXT,
    translated_content TEXT,
    parent_comment_id UUID REFERENCES feed_comments(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 9. courses
-- ==============================
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instructor_id UUID REFERENCES instructors(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    language language_enum,
    level course_level_enum,
    total_sessions INT,
    price NUMERIC(10,2),
    thumbnail_url TEXT,
    start_date DATE,
    end_date DATE,
    status course_status_enum,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 10. course_sessions
-- ==============================
CREATE TABLE course_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    session_name TEXT,
    session_description TEXT,
    session_date DATE,
    session_time TEXT,
    session_duration TEXT,
    session_link TEXT,
    session_password TEXT,
    session_platform session_platform_enum,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 11. recorded_classes
-- ==============================
CREATE TABLE recorded_classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    recorded_name TEXT,
    recorded_description TEXT,
    recorded_duration TEXT,
    recorded_size TEXT,
    recorded_link TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 12. study_materials
-- ==============================
CREATE TABLE study_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    material_title TEXT,
    material_description TEXT,
    material_link TEXT,
    material_type material_type_enum,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 13. group_chat
-- ==============================
CREATE TABLE group_chat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    sender_id UUID, -- can be learner or instructor
    sender_type group_chat_sender_enum,
    content_text TEXT,
    parent_message_id UUID REFERENCES group_chat(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 14. course_enrollments
-- ==============================
CREATE TABLE course_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 15. feedback
-- ==============================
CREATE TABLE feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    instructor_id UUID REFERENCES instructors(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    feedback_type feedback_type_enum,
    feedback_text TEXT,
    feedback_about TEXT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 16. notifications
-- ==============================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    learner_id UUID REFERENCES learners(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
    notification_type notification_type_enum,
    content_title TEXT,
    content_text TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);
