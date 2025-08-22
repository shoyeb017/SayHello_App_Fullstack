-- ==============================
-- DROP TABLES (in safe order)
-- ==============================
DROP TABLE IF EXISTS withdrawal CASCADE;
DROP TABLE IF EXISTS withdrawal_info CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS feedback CASCADE;
DROP TABLE IF EXISTS course_enrollments CASCADE;
DROP TABLE IF EXISTS group_chat CASCADE;
DROP TABLE IF EXISTS study_materials CASCADE;
DROP TABLE IF EXISTS recorded_classes CASCADE;
DROP TABLE IF EXISTS course_sessions CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS feed_comments CASCADE;
DROP TABLE IF EXISTS feed_likes CASCADE;
DROP TABLE IF EXISTS feed_images CASCADE;
DROP TABLE IF EXISTS feed CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS chats CASCADE;
DROP TABLE IF EXISTS followers CASCADE;
DROP TABLE IF EXISTS instructors CASCADE;
DROP TABLE IF EXISTS learners CASCADE;

-- ==============================
-- DROP ENUMS
-- ==============================
DROP TYPE IF EXISTS notification_type_enum CASCADE;
DROP TYPE IF EXISTS feedback_type_enum CASCADE;
DROP TYPE IF EXISTS group_chat_sender_enum CASCADE;
DROP TYPE IF EXISTS material_type_enum CASCADE;
DROP TYPE IF EXISTS session_platform_enum CASCADE;
DROP TYPE IF EXISTS course_status_enum CASCADE;
DROP TYPE IF EXISTS course_level_enum CASCADE;
DROP TYPE IF EXISTS message_status_enum CASCADE;
DROP TYPE IF EXISTS message_type_enum CASCADE;
DROP TYPE IF EXISTS language_level_enum CASCADE;
DROP TYPE IF EXISTS language_enum CASCADE;
DROP TYPE IF EXISTS country_enum CASCADE;
DROP TYPE IF EXISTS gender_enum CASCADE;


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
    created_at TIMESTAMP DEFAULT NOW()
);

-- ==============================
-- 6.1. feed images
-- ==============================

CREATE TABLE feed_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feed_id UUID REFERENCES feed(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    position INT, -- optional, to order multiple images
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

-- ==============================
-- 17. withdrawls
-- ==============================

-- Main withdrawal transaction table
CREATE TABLE withdrawal (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instructor_id UUID REFERENCES instructors(id) ON DELETE CASCADE,
    amount NUMERIC(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'COMPLETED',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Withdrawal payment info table
CREATE TABLE withdrawal_info (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    withdrawal_id UUID REFERENCES withdrawal(id) ON DELETE CASCADE,
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('CARD', 'PAYPAL', 'BANK')),
    
    -- Card details (nullable, only if method = CARD)
    card_number VARCHAR(20),
    expiry_date VARCHAR(7), -- MM/YYYY
    cvv VARCHAR(4),
    card_holder_name VARCHAR(255),
    
    -- PayPal (nullable, only if method = PAYPAL)
    paypal_email VARCHAR(255),
    
    -- Bank statement (nullable, only if method = BANK)
    bank_account_number VARCHAR(50),
    bank_name VARCHAR(100),
    swift_code VARCHAR(20)
);



-- -----------------------------
-- Learners Batch 1
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Alice Johnson', 'alice.johnson@example.com', 'alice_j', 'password123', '1995-03-12', 'female', 'usa', 'I love learning Japanese and exploring new cultures.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['anime','travel','music']),
('Bob Smith', 'bob.smith@example.com', 'bob_s', 'password123', '1992-07-25', 'male', 'usa', 'Learning Japanese to speak fluently with native speakers.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['gaming','reading','cooking']),
('Carol Davis', 'carol.davis@example.com', 'carol_d', 'password123', '1998-11-02', 'female', 'usa', 'I enjoy practicing Japanese daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['travel','calligraphy','photography']),
('David Lee', 'david.lee@example.com', 'david_l', 'password123', '1990-06-15', 'male', 'usa', 'Passionate about Japanese culture and language.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['martial arts','reading','music']),
('Emma Wilson', 'emma.wilson@example.com', 'emma_w', 'password123', '1997-01-30', 'female', 'usa', 'Learning Japanese to travel and communicate better.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['travel','anime','yoga']),
('Frank Taylor', 'frank.taylor@example.com', 'frank_t', 'password123', '1993-09-21', 'male', 'usa', 'I want to understand Japanese media in original language.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['movies','gaming','language exchange']),
('Grace Martinez', 'grace.martinez@example.com', 'grace_m', 'password123', '1996-04-18', 'female', 'usa', 'Learning Japanese for work and personal growth.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['reading','travel','cooking']),
('Henry Brown', 'henry.brown@example.com', 'henry_b', 'password123', '1991-08-09', 'male', 'usa', 'Interested in Japanese language and culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['music','sports','anime']),
('Isabella Garcia', 'isabella.garcia@example.com', 'isabella_g', 'password123', '1994-12-05', 'female', 'usa', 'Practicing Japanese to communicate with friends.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['photography','travel','music']),
('Jack Wilson', 'jack.wilson@example.com', 'jack_w', 'password123', '1990-02-17', 'male', 'usa', 'Learning Japanese is my passion.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['anime','gaming','reading']);

-- -----------------------------
-- Learners Batch 2
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Akira Tanaka', 'akira.tanaka@example.com', 'akira_t', 'password123', '1995-05-22', 'male', 'japan', 'I love learning English to communicate worldwide.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'beginner', ARRAY['music','travel','anime']),
('Emiko Sato', 'emiko.sato@example.com', 'emiko_s', 'password123', '1997-11-11', 'female', 'japan', 'Learning English to improve my career prospects.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'elementary', ARRAY['reading','cooking','yoga']),
('Hiroshi Yamamoto', 'hiroshi.yamamoto@example.com', 'hiroshi_y', 'password123', '1990-03-14', 'male', 'japan', 'I practice English to enjoy movies and media.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'intermediate', ARRAY['movies','sports','gaming']),
('Yuki Nakamura', 'yuki.nakamura@example.com', 'yuki_n', 'password123', '1992-07-30', 'female', 'japan', 'Passionate about English literature and language.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'advanced', ARRAY['reading','travel','writing']),
('Kenta Suzuki', 'kenta.suzuki@example.com', 'kenta_s', 'password123', '1998-01-25', 'male', 'japan', 'Learning English to travel abroad and meet people.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'proficient', ARRAY['travel','music','gaming']),
('Miyuki Kobayashi', 'miyuki.kobayashi@example.com', 'miyuki_k', 'password123', '1996-06-05', 'female', 'japan', 'I enjoy practicing English daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'beginner', ARRAY['writing','reading','cooking']),
('Ryo Takahashi', 'ryo.takahashi@example.com', 'ryo_t', 'password123', '1993-09-19', 'male', 'japan', 'Learning English for professional development.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'elementary', ARRAY['reading','travel','movies']),
('Sakura Ito', 'sakura.ito@example.com', 'sakura_i', 'password123', '1994-12-07', 'female', 'japan', 'I want to improve my English speaking skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'intermediate', ARRAY['travel','music','yoga']),
('Takumi Watanabe', 'takumi.watanabe@example.com', 'takumi_w', 'password123', '1991-04-21', 'male', 'japan', 'English learning is fun and exciting.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'advanced', ARRAY['gaming','reading','travel']),
('Aya Mori', 'aya.mori@example.com', 'aya_m', 'password123', '1997-08-13', 'female', 'japan', 'I enjoy learning English with friends.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'proficient', ARRAY['music','travel','writing']);


-- -----------------------------
-- Learners Batch 3
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Liam White', 'liam.white@example.com', 'liam_w', 'password123', '1992-02-18', 'male', 'usa', 'I want to practice Japanese daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['anime','music','travel']),
('Olivia King', 'olivia.king@example.com', 'olivia_k', 'password123', '1995-06-28', 'female', 'usa', 'Learning Japanese to enjoy Japanese media.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['reading','movies','gaming']),
('Noah Scott', 'noah.scott@example.com', 'noah_s', 'password123', '1990-09-10', 'male', 'usa', 'Interested in Japanese culture and language.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['travel','music','sports']),
('Sophia Adams', 'sophia.adams@example.com', 'sophia_a', 'password123', '1998-01-15', 'female', 'usa', 'Learning Japanese to communicate with friends.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['anime','reading','travel']),
('Ethan Clark', 'ethan.clark@example.com', 'ethan_c', 'password123', '1993-05-20', 'male', 'usa', 'Passionate about Japanese language learning.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['gaming','travel','movies']),
('Mia Turner', 'mia.turner@example.com', 'mia_t', 'password123', '1996-03-03', 'female', 'usa', 'I enjoy learning Japanese daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['music','writing','travel']),
('Lucas Evans', 'lucas.evans@example.com', 'lucas_e', 'password123', '1991-07-27', 'male', 'usa', 'Learning Japanese for professional purposes.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['reading','movies','sports']),
('Ava Baker', 'ava.baker@example.com', 'ava_b', 'password123', '1994-11-19', 'female', 'usa', 'Practicing Japanese to travel and meet people.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['travel','gaming','music']),
('James Carter', 'james.carter@example.com', 'james_c', 'password123', '1990-08-23', 'male', 'usa', 'I want to master Japanese language skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['reading','travel','anime']),
('Charlotte Nelson', 'charlotte.nelson@example.com', 'charlotte_n', 'password123', '1997-12-01', 'female', 'usa', 'Learning Japanese for fun and culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['music','travel','reading']);


-- -----------------------------
-- Instructors Batch 1 (English)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('William Johnson', 'william.johnson@example.com', 'william_j', 'password123', '1980-03-12', 'male', 'usa', 'Experienced English instructor passionate about teaching.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 10),
('Olivia Smith', 'olivia.smith@example.com', 'olivia_s', 'password123', '1985-07-25', 'female', 'usa', 'Helping learners improve their English skills daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 8),
('James Davis', 'james.davis@example.com', 'james_d', 'password123', '1978-11-02', 'male', 'usa', 'English language coach with 15 years experience.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 15),
('Sophia Miller', 'sophia.miller@example.com', 'sophia_m', 'password123', '1982-06-15', 'female', 'usa', 'Passionate about teaching English to learners worldwide.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 12),
('Benjamin Wilson', 'benjamin.wilson@example.com', 'benjamin_w', 'password123', '1987-01-30', 'male', 'usa', 'Focused on practical English and communication skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 7);


-- -----------------------------
-- Instructors Batch 1 (English)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('William Johnson', 'william.johnson@example.com', 'william_j', 'password123', '1980-03-12', 'male', 'usa', 'Experienced English instructor passionate about teaching.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 10),
('Olivia Smith', 'olivia.smith@example.com', 'olivia_s', 'password123', '1985-07-25', 'female', 'usa', 'Helping learners improve their English skills daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 8),
('James Davis', 'james.davis@example.com', 'james_d', 'password123', '1978-11-02', 'male', 'usa', 'English language coach with 15 years experience.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 15),
('Sophia Miller', 'sophia.miller@example.com', 'sophia_m', 'password123', '1982-06-15', 'female', 'usa', 'Passionate about teaching English to learners worldwide.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 12),
('Benjamin Wilson', 'benjamin.wilson@example.com', 'benjamin_w', 'password123', '1987-01-30', 'male', 'usa', 'Focused on practical English and communication skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 7);


-- -----------------------------
-- Instructors Batch 2 (Japanese)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('Hiroshi Tanaka', 'hiroshi.tanaka@example.com', 'hiroshi_t', 'password123', '1979-05-22', 'male', 'japan', 'Japanese instructor with passion for teaching foreign learners.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 12),
('Emiko Sato', 'emiko.sato@example.com', 'emiko_s', 'password123', '1983-11-11', 'female', 'japan', 'Helping students understand Japanese language and culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 10),
('Takeshi Yamamoto', 'takeshi.yamamoto@example.com', 'takeshi_y', 'password123', '1975-03-14', 'male', 'japan', 'Experienced in teaching Japanese to English speakers.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 15),
('Yuki Nakamura', 'yuki.nakamura@example.com', 'yuki_n', 'password123', '1982-07-30', 'female', 'japan', 'Passionate about Japanese language education.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 11),
('Kenta Suzuki', 'kenta.suzuki@example.com', 'kenta_s', 'password123', '1988-01-25', 'male', 'japan', 'Teaching Japanese with focus on culture and communication.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 9);


-- -----------------------------
-- Followers (Learners following each other)
-- -----------------------------
-- Using usernames to map to actual learner UUIDs
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO followers (follower_user_id, followed_user_id)
VALUES
-- English native learners following each other
((SELECT id FROM learner_map WHERE username='alice_j'), (SELECT id FROM learner_map WHERE username='bob_s')),
((SELECT id FROM learner_map WHERE username='alice_j'), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT id FROM learner_map WHERE username='bob_s'), (SELECT id FROM learner_map WHERE username='alice_j')),
((SELECT id FROM learner_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='david_l')),
((SELECT id FROM learner_map WHERE username='david_l'), (SELECT id FROM learner_map WHERE username='emma_w')),
((SELECT id FROM learner_map WHERE username='frank_t'), (SELECT id FROM learner_map WHERE username='grace_m')),
((SELECT id FROM learner_map WHERE username='henry_b'), (SELECT id FROM learner_map WHERE username='isabella_g')),
((SELECT id FROM learner_map WHERE username='jack_w'), (SELECT id FROM learner_map WHERE username='alice_j')),

-- Japanese native learners following each other
((SELECT id FROM learner_map WHERE username='akira_t'), (SELECT id FROM learner_map WHERE username='emiko_s')),
((SELECT id FROM learner_map WHERE username='hiroshi_y'), (SELECT id FROM learner_map WHERE username='yuki_n')),
((SELECT id FROM learner_map WHERE username='kenta_s'), (SELECT id FROM learner_map WHERE username='miyuki_k')),
((SELECT id FROM learner_map WHERE username='ryo_t'), (SELECT id FROM learner_map WHERE username='sakura_i')),
((SELECT id FROM learner_map WHERE username='takumi_w'), (SELECT id FROM learner_map WHERE username='aya_m')),

-- Cross-group follower relationships for demonstration
((SELECT id FROM learner_map WHERE username='alice_j'), (SELECT id FROM learner_map WHERE username='akira_t')),
((SELECT id FROM learner_map WHERE username='akira_t'), (SELECT id FROM learner_map WHERE username='alice_j')),
((SELECT id FROM learner_map WHERE username='bob_s'), (SELECT id FROM learner_map WHERE username='yuki_n')),
((SELECT id FROM learner_map WHERE username='yuki_n'), (SELECT id FROM learner_map WHERE username='bob_s'));



-- -----------------------------
-- Chats between learners
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO chats (user1_id, user2_id)
VALUES
-- Chat 1 (Demo learners)
((SELECT id FROM learner_map WHERE username='alice_j'), (SELECT id FROM learner_map WHERE username='akira_t')),
-- Chat 2
((SELECT id FROM learner_map WHERE username='bob_s'), (SELECT id FROM learner_map WHERE username='emiko_s')),
-- Chat 3
((SELECT id FROM learner_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='hiroshi_y')),
-- Chat 4
((SELECT id FROM learner_map WHERE username='david_l'), (SELECT id FROM learner_map WHERE username='yuki_n')),
-- Chat 5
((SELECT id FROM learner_map WHERE username='emma_w'), (SELECT id FROM learner_map WHERE username='kenta_s')),
-- Chat 6
((SELECT id FROM learner_map WHERE username='frank_t'), (SELECT id FROM learner_map WHERE username='miyuki_k')),
-- Chat 7
((SELECT id FROM learner_map WHERE username='grace_m'), (SELECT id FROM learner_map WHERE username='ryo_t')),
-- Chat 8
((SELECT id FROM learner_map WHERE username='henry_b'), (SELECT id FROM learner_map WHERE username='sakura_i')),
-- Chat 9
((SELECT id FROM learner_map WHERE username='isabella_g'), (SELECT id FROM learner_map WHERE username='takumi_w')),
-- Chat 10
((SELECT id FROM learner_map WHERE username='jack_w'), (SELECT id FROM learner_map WHERE username='aya_m'));


-- -----------------------------
-- Messages in chats
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
), chat_map AS (
    SELECT id, user1_id, user2_id FROM chats
)
INSERT INTO messages (chat_id, sender_id, content_text, type, status)
VALUES
-- Chat 1 messages between alice_j and akira_t
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='alice_j')), (SELECT id FROM learner_map WHERE username='alice_j'), 'Hi Akira! How are your Japanese lessons going?', 'text', 'read'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='alice_j')), (SELECT id FROM learner_map WHERE username='akira_t'), 'Hi Alice! They are going well, thank you. How is your English practice?', 'text', 'read'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='alice_j')), (SELECT id FROM learner_map WHERE username='alice_j'), 'Pretty good! I practiced reading a Japanese article today.', 'text', 'unread'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='alice_j')), (SELECT id FROM learner_map WHERE username='akira_t'), 'That’s great! Keep it up!', 'text', 'unread'),

-- Chat 2 messages between bob_s and emiko_s
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='bob_s')), (SELECT id FROM learner_map WHERE username='bob_s'), 'Emiko, did you try the English exercise from last session?', 'text', 'read'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='bob_s')), (SELECT id FROM learner_map WHERE username='emiko_s'), 'Yes Bob! It was challenging but fun.', 'text', 'read'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='bob_s')), (SELECT id FROM learner_map WHERE username='bob_s'), 'I found some vocabulary difficult.', 'text', 'unread');


-- -----------------------------
-- Feed posts
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO feed (learner_id, content_text)
VALUES
-- Demo learners posts
((SELECT id FROM learner_map WHERE username='alice_j'), 'Practiced writing kanji today! Feeling more confident.'),
((SELECT id FROM learner_map WHERE username='akira_t'), 'Learned some new English idioms today. Exciting!'),
-- Other learners posts
((SELECT id FROM learner_map WHERE username='bob_s'), 'Trying to improve my Japanese pronunciation.'),
((SELECT id FROM learner_map WHERE username='emiko_s'), 'Read a short English story today. Fun!'),
((SELECT id FROM learner_map WHERE username='carol_d'), 'Practicing listening skills with English podcasts.');


-- -----------------------------
-- Feed images
-- -----------------------------
WITH feed_map AS (
    SELECT id, learner_id FROM feed
)
INSERT INTO feed_images (feed_id, image_url, position)
VALUES
-- Alice's feed images
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='alice_j')), 'https://images.unsplash.com/photo-1601050690224-6a8d1f7f8a99', 1),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='alice_j')), 'https://images.unsplash.com/photo-1581090700227-6b9c2c0b8d76', 2),

-- Akira's feed images
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='akira_t')), 'https://images.unsplash.com/photo-1567016548540-08c4fc00df22', 1),

-- Bob's feed image
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='bob_s')), 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1', 1);


-- -----------------------------
-- Feed likes
-- -----------------------------
WITH feed_map AS (
    SELECT id, learner_id FROM feed
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO feed_likes (feed_id, learner_id)
VALUES
-- Likes on Alice's post
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='alice_j')), (SELECT id FROM learner_map WHERE username='akira_t')),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='alice_j')), (SELECT id FROM learner_map WHERE username='bob_s')),

-- Likes on Akira's post
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='akira_t')), (SELECT id FROM learner_map WHERE username='alice_j')),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='akira_t')), (SELECT id FROM learner_map WHERE username='emiko_s'));


-- -----------------------------
-- Feed comments
-- -----------------------------
WITH feed_map AS (
    SELECT id, learner_id FROM feed
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO feed_comments (feed_id, learner_id, content_text)
VALUES
-- Comments on Alice's post
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='alice_j')), (SELECT id FROM learner_map WHERE username='akira_t'), 'Wow Alice! Your kanji is improving quickly!'),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='alice_j')), (SELECT id FROM learner_map WHERE username='bob_s'), 'Great work! Keep practicing.'),

-- Comments on Akira's post
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='akira_t')), (SELECT id FROM learner_map WHERE username='alice_j'), 'Interesting idioms! Can you share some examples?'),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='akira_t')), (SELECT id FROM learner_map WHERE username='emiko_s'), 'I love learning idioms too!');


-- -----------------------------
-- Courses
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO courses (instructor_id, title, description, language, level, total_sessions, price, thumbnail_url, start_date, end_date, status)
VALUES
-- Demo English course (William Johnson)
((SELECT id FROM instructor_map WHERE username='william_j'), 'English Mastery 101', 'Learn basic to advanced English in a structured course.', 'english', 'beginner', 5, 49.99, 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f', '2025-08-01', '2025-08-31', 'active'),

-- Demo Japanese course (Hiroshi Tanaka)
((SELECT id FROM instructor_map WHERE username='hiroshi_t'), 'Japanese for Beginners', 'Comprehensive Japanese course from basics to intermediate.', 'japanese', 'beginner', 5, 59.99, 'https://images.unsplash.com/photo-1558021212-51b6b6bbaed0', '2025-09-01', '2025-09-30', 'upcoming'),

-- Other courses (examples)
((SELECT id FROM instructor_map WHERE username='olivia_s'), 'English Speaking Practice', 'Improve your spoken English skills with fun exercises.', 'english', 'intermediate', 4, 39.99, 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b', '2025-06-01', '2025-06-30', 'expired'),
((SELECT id FROM instructor_map WHERE username='james_d'), 'Advanced English Grammar', 'Deep dive into English grammar rules and usage.', 'english', 'advanced', 5, 69.99, 'https://images.unsplash.com/photo-1498050108023-c5249f4df085', '2025-07-01', '2025-07-31', 'active'),
((SELECT id FROM instructor_map WHERE username='sophia_m'), 'Conversational English', 'Practice real-life conversations with native instructors.', 'english', 'beginner', 4, 44.99, 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d', '2025-08-05', '2025-09-05', 'active'),

-- Japanese courses
((SELECT id FROM instructor_map WHERE username='emiko_s'), 'Japanese Reading Skills', 'Learn to read Hiragana, Katakana, and basic Kanji.', 'japanese', 'beginner', 4, 49.99, 'https://images.unsplash.com/photo-1551462273-3e14e3fc27d5', '2025-06-01', '2025-06-30', 'expired'),
((SELECT id FROM instructor_map WHERE username='takeshi_y'), 'Intermediate Japanese Grammar', 'Improve your grammar with structured lessons.', 'japanese', 'intermediate', 5, 59.99, 'https://images.unsplash.com/photo-1520697230480-2b529a9f8ff3', '2025-07-01', '2025-07-31', 'active'),
((SELECT id FROM instructor_map WHERE username='yuki_n'), 'Japanese Conversation Practice', 'Practice speaking Japanese with native instructors.', 'japanese', 'beginner', 4, 54.99, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c', '2025-08-01', '2025-08-31', 'active'),
((SELECT id FROM instructor_map WHERE username='kenta_s'), 'Japanese Writing Skills', 'Learn how to write Kanji and sentences properly.', 'japanese', 'intermediate', 5, 59.99, 'https://images.unsplash.com/photo-1529243856184-6e0a0c95e4e0', '2025-09-01', '2025-09-30', 'upcoming'),
((SELECT id FROM instructor_map WHERE username='emiko_s'), 'Business Japanese', 'Learn Japanese used in business settings.', 'japanese', 'advanced', 5, 69.99, 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f', '2025-09-05', '2025-10-05', 'upcoming');



-- -----------------------------
-- Course sessions
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
)
INSERT INTO course_sessions (course_id, session_name, session_description, session_date, session_time, session_duration, session_link, session_password, session_platform)
VALUES
-- Sessions for English Mastery 101
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 1: Greetings', 'Learn basic English greetings', '2025-08-02', '10:00', '1h', 'https://zoom.us/j/123456', '1111', 'zoom'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 2: Introductions', 'How to introduce yourself in English', '2025-08-05', '10:00', '1h', 'https://meet.google.com/abc-defg-hij', '2222', 'meet'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 3: Numbers', 'Learn numbers and counting in English', '2025-08-08', '10:00', '1h', 'https://zoom.us/j/654321', '3333', 'zoom'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 4: Days & Months', 'Learn days of the week and months', '2025-08-12', '10:00', '1h', 'https://meet.google.com/xyz-uvw-rst', '4444', 'meet'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 5: Review', 'Review all lessons', '2025-08-15', '10:00', '1h', 'https://zoom.us/j/789012', '5555', 'zoom'),

-- Sessions for Japanese for Beginners
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 1: Hiragana', 'Introduction to Hiragana', '2025-09-02', '15:00', '1h', 'https://zoom.us/j/223344', '1111', 'zoom'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 2: Katakana', 'Learn Katakana characters', '2025-09-05', '15:00', '1h', 'https://meet.google.com/def-ghi-jkl', '2222', 'meet'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 3: Basic Phrases', 'Useful phrases for daily conversation', '2025-09-08', '15:00', '1h', 'https://zoom.us/j/334455', '3333', 'zoom'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 4: Numbers', 'Learn numbers in Japanese', '2025-09-12', '15:00', '1h', 'https://meet.google.com/mno-pqr-stu', '4444', 'meet'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 5: Review', 'Review all lessons', '2025-09-15', '15:00', '1h', 'https://zoom.us/j/445566', '5555', 'zoom');




-- -----------------------------
-- Recorded classes
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
)
INSERT INTO recorded_classes (course_id, recorded_name, recorded_description, recorded_link)
VALUES
-- English Mastery 101 recorded classes
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Recorded Session 1: Greetings', 'Recorded video for greetings lesson', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Recorded Session 2: Introductions', 'Recorded video for introductions lesson', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Recorded Session 3: Numbers', 'Recorded video for numbers lesson', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Recorded Session 4: Days & Months', 'Recorded video for days & months lesson', 'https://www.youtube.com/watch?v=E6588DlZW-c'),

-- Japanese for Beginners recorded classes
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Recorded Session 1: Hiragana', 'Recorded video for Hiragana lesson', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Recorded Session 2: Katakana', 'Recorded video for Katakana lesson', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Recorded Session 3: Basic Phrases', 'Recorded video for phrases lesson', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Recorded Session 4: Numbers', 'Recorded video for numbers lesson', 'https://www.youtube.com/watch?v=E6588DlZW-c');



-- -----------------------------
-- Study materials
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
)
INSERT INTO study_materials (course_id, material_title, material_description, material_link, material_type)
VALUES
-- English Mastery 101
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Greetings PDF', 'PDF guide for greetings', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_pdf.pdf', 'pdf'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Introductions Doc', 'Document for introductions', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_doc.docx', 'document'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Numbers Image', 'Image for numbers practice', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_image.png', 'image'),

-- Japanese for Beginners
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Hiragana PDF', 'PDF guide for Hiragana', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_pdf.pdf', 'pdf'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Katakana Doc', 'Document for Katakana', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_doc.docx', 'document'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Numbers Image', 'Image for numbers practice', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_image.png', 'image');



-- -----------------------------
-- Course enrollments (Learners)
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO course_enrollments (course_id, learner_id)
VALUES
-- Enroll demo learners in their respective courses
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='alice_j')),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='bob_s')),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='carol_d')),

((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='akira_t')),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='emiko_s')),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='hiroshi_y'));


-- -----------------------------
-- Group Chat (within courses)
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
), instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO group_chat (course_id, sender_id, sender_type, content_text)
VALUES
-- English Mastery 101 group chat
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='alice_j'), 'learner', 'Hello everyone! Excited for this course.'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='bob_s'), 'learner', 'Hi Alice! Let’s practice together.'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='william_j'), 'instructor', 'Welcome everyone! I will guide you through the lessons.'),

-- Japanese for Beginners group chat
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='akira_t'), 'learner', 'Hello Hiroshi-sensei! Looking forward to learning Japanese.'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='emiko_s'), 'learner', 'Hi Akira! Let’s study together.'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM instructor_map WHERE username='hiroshi_t'), 'instructor', 'Welcome to the course! I hope you enjoy learning Japanese.');



-- -----------------------------
-- Feedback
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
), instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO feedback (course_id, instructor_id, learner_id, feedback_type, feedback_text, rating)
VALUES
-- Learner feedback for English course
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='william_j'), (SELECT id FROM learner_map WHERE username='alice_j'), 'learner', 'Great teaching! Very clear explanations.', 5),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='william_j'), (SELECT id FROM learner_map WHERE username='bob_s'), 'learner', 'Loved the exercises and examples.', 4),

-- Instructor feedback for English course
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='william_j'), (SELECT id FROM learner_map WHERE username='alice_j'), 'instructor', 'Alice participates actively and asks good questions.', 5),

-- Course feedback
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='william_j'), (SELECT id FROM learner_map WHERE username='bob_s'), 'course', 'The course content is structured and useful.', 5),

-- Learner feedback for Japanese course
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM instructor_map WHERE username='hiroshi_t'), (SELECT id FROM learner_map WHERE username='akira_t'), 'learner', 'Sensei explains clearly and is very patient.', 5),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM instructor_map WHERE username='hiroshi_t'), (SELECT id FROM learner_map WHERE username='emiko_s'), 'learner', 'I learned a lot from the exercises.', 4);


-- -----------------------------
-- Notifications
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO notifications (learner_id, course_id, notification_type, content_title, content_text, is_read)
VALUES
-- English course notifications
((SELECT id FROM learner_map WHERE username='alice_j'), (SELECT id FROM course_map WHERE title='English Mastery 101'), 'session alert', 'Session Reminder', 'Don’t forget Session 1 starts tomorrow at 10:00 AM.', FALSE),
((SELECT id FROM learner_map WHERE username='bob_s'), (SELECT id FROM course_map WHERE title='English Mastery 101'), 'feedback', 'New Feedback', 'You received new feedback from your instructor.', TRUE),

-- Japanese course notifications
((SELECT id FROM learner_map WHERE username='akira_t'), (SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'session alert', 'Session Reminder', 'Session 1 will start on 2nd September at 15:00.', FALSE),
((SELECT id FROM learner_map WHERE username='emiko_s'), (SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'feedback', 'New Feedback', 'You received new feedback from your instructor.', TRUE);



-- -----------------------------
-- Withdrawals
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO withdrawal (instructor_id, amount, status)
VALUES
((SELECT id FROM instructor_map WHERE username='william_j'), 500.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='william_j'), 200.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='hiroshi_t'), 600.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='hiroshi_t'), 150.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='olivia_s'), 320.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='james_d'), 480.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='sophia_m'), 290.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='benjamin_w'), 350.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='emiko_s'), 220.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='takeshi_y'), 540.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='yuki_n'), 380.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='kenta_s'), 275.00, 'COMPLETED');


-- -----------------------------
-- Withdrawal Info
-- -----------------------------
WITH withdrawal_map AS (
    SELECT w.id, i.username 
    FROM withdrawal w
    JOIN instructors i ON w.instructor_id = i.id
)
INSERT INTO withdrawal_info (withdrawal_id, payment_method, card_number, expiry_date, cvv, card_holder_name, paypal_email, bank_account_number, bank_name, swift_code)
VALUES
-- Card payments
((SELECT id FROM withdrawal_map WHERE username='william_j' LIMIT 1), 'CARD', '1234567812345678', '12/2028', '123', 'William Johnson', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='olivia_s'), 'CARD', '8765432187654321', '06/2027', '456', 'Olivia Smith', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='sophia_m'), 'CARD', '5555444433332222', '09/2029', '789', 'Sophia Miller', NULL, NULL, NULL, NULL),

-- PayPal payments
((SELECT id FROM withdrawal_map WHERE username='hiroshi_t' LIMIT 1), 'PAYPAL', NULL, NULL, NULL, NULL, 'hiroshi.tanaka@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='james_d'), 'PAYPAL', NULL, NULL, NULL, NULL, 'james.davis@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='emiko_s'), 'PAYPAL', NULL, NULL, NULL, NULL, 'emiko.sato@example.com', NULL, NULL, NULL),

-- Bank transfers
((SELECT id FROM withdrawal_map WHERE username='benjamin_w'), 'BANK', NULL, NULL, NULL, NULL, NULL, '1234567890', 'Chase Bank', 'CHASUS33'),
((SELECT id FROM withdrawal_map WHERE username='takeshi_y'), 'BANK', NULL, NULL, NULL, NULL, NULL, '9876543210', 'MUFG Bank', 'BOTKJPJT'),
((SELECT id FROM withdrawal_map WHERE username='yuki_n'), 'BANK', NULL, NULL, NULL, NULL, NULL, '5555666677', 'Sumitomo Bank', 'SMBCJPJT'),
((SELECT id FROM withdrawal_map WHERE username='kenta_s'), 'BANK', NULL, NULL, NULL, NULL, NULL, '3333444455', 'Mizuho Bank', 'MHCBJPJT');


-- ========================================
-- ADDITIONAL LEARNERS (Part 2)
-- ========================================

-- -----------------------------
-- Additional Japanese learners (Batch 4)
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Kenji Watanabe', 'kenji.watanabe@example.com', 'kenji_w', 'password123', '1996-02-12', 'male', 'japan', 'I want to improve my English for international business.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'beginner', ARRAY['business','travel','technology']),
('Haruka Okamoto', 'haruka.okamoto@example.com', 'haruka_o', 'password123', '1994-08-25', 'female', 'japan', 'Learning English to study abroad next year.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'elementary', ARRAY['studying','books','music']),
('Daiki Ishikawa', 'daiki.ishikawa@example.com', 'daiki_i', 'password123', '1991-11-30', 'male', 'japan', 'English is essential for my tech career.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'intermediate', ARRAY['programming','gaming','anime']),
('Nanami Hayashi', 'nanami.hayashi@example.com', 'nanami_h', 'password123', '1998-04-18', 'female', 'japan', 'I love American movies and want to understand them without subtitles.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'advanced', ARRAY['movies','culture','photography']),
('Sho Matsumoto', 'sho.matsumoto@example.com', 'sho_m', 'password123', '1993-09-07', 'male', 'japan', 'Practicing English for my dream to work in Silicon Valley.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'proficient', ARRAY['technology','innovation','travel']);

-- -----------------------------
-- Additional English learners (Batch 4)
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Ryan Thompson', 'ryan.thompson@example.com', 'ryan_t', 'password123', '1995-01-20', 'male', 'usa', 'Fascinated by Japanese history and culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['history','martial arts','culture']),
('Madison Davis', 'madison.davis@example.com', 'madison_d', 'password123', '1997-06-14', 'female', 'usa', 'Learning Japanese to teach English in Japan someday.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['teaching','travel','language exchange']),
('Tyler Rodriguez', 'tyler.rodriguez@example.com', 'tyler_r', 'password123', '1992-03-08', 'male', 'usa', 'Japanese language helps me understand anime and manga better.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['anime','manga','art']),
('Paige Wilson', 'paige.wilson@example.com', 'paige_w', 'password123', '1990-12-22', 'female', 'usa', 'I want to connect with Japanese friends and learn their culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['friendship','culture','cooking']),
('Brandon Miller', 'brandon.miller@example.com', 'brandon_m', 'password123', '1996-07-11', 'male', 'usa', 'Japanese business culture interests me greatly.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['business','culture','economics']);

-- -----------------------------
-- Additional Mixed Language Learners (Batch 5)
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Yuka Taniguchi', 'yuka.taniguchi@example.com', 'yuka_t', 'password123', '1995-05-03', 'female', 'japan', 'Studying English literature and poetry.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'beginner', ARRAY['literature','poetry','writing']),
('Austin Lee', 'austin.lee@example.com', 'austin_l', 'password123', '1994-10-16', 'male', 'usa', 'Learning Japanese to understand traditional arts.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['traditional arts','meditation','philosophy']),
('Ami Fujiwara', 'ami.fujiwara@example.com', 'ami_f', 'password123', '1999-01-29', 'female', 'japan', 'English opens doors to global opportunities.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'intermediate', ARRAY['global culture','travel','food']),
('Caleb Johnson', 'caleb.johnson@example.com', 'caleb_j', 'password123', '1991-08-05', 'male', 'usa', 'Japanese video games inspired my language learning journey.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['video games','technology','programming']),
('Rei Kimura', 'rei.kimura@example.com', 'rei_k', 'password123', '1993-12-13', 'female', 'japan', 'I love English music and want to understand lyrics perfectly.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'proficient', ARRAY['music','concerts','singing']);


-- ========================================
-- ADDITIONAL INSTRUCTORS
-- ========================================

-- -----------------------------
-- Additional English Instructors (Batch 3)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('Michael Brown', 'michael.brown@example.com', 'michael_b', 'password123', '1976-04-22', 'male', 'usa', 'Specialist in business English and professional communication.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 18),
('Jennifer Taylor', 'jennifer.taylor@example.com', 'jennifer_t', 'password123', '1984-09-18', 'female', 'usa', 'Expert in English literature and creative writing.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 11),
('Robert Garcia', 'robert.garcia@example.com', 'robert_g', 'password123', '1979-12-07', 'male', 'usa', 'Helping students master English pronunciation and speaking.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 14),
('Emily Anderson', 'emily.anderson@example.com', 'emily_a', 'password123', '1981-06-25', 'female', 'usa', 'Passionate about teaching English to international students.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 13),
('Daniel Wilson', 'daniel.wilson@example.com', 'daniel_w', 'password123', '1985-02-14', 'male', 'usa', 'Focused on conversational English and cultural exchange.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 9);

-- -----------------------------
-- Additional Japanese Instructors (Batch 3)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('Satoshi Nakamura', 'satoshi.nakamura@example.com', 'satoshi_n', 'password123', '1977-08-30', 'male', 'japan', 'Traditional Japanese language and culture specialist.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 16),
('Akiko Yamada', 'akiko.yamada@example.com', 'akiko_y', 'password123', '1980-11-15', 'female', 'japan', 'Expert in Japanese writing systems and calligraphy.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 14),
('Masaki Sato', 'masaki.sato@example.com', 'masaki_s', 'password123', '1982-03-28', 'male', 'japan', 'Business Japanese and professional communication expert.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 12),
('Yumiko Takahashi', 'yumiko.takahashi@example.com', 'yumiko_t', 'password123', '1986-07-09', 'female', 'japan', 'Making Japanese language learning fun and engaging.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 8),
('Tetsuya Kobayashi', 'tetsuya.kobayashi@example.com', 'tetsuya_k', 'password123', '1983-01-12', 'male', 'japan', 'Specialist in Japanese grammar and conversation skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 10);
-- ========================================
-- ADDITIONAL FOLLOWERS
-- ========================================

-- -----------------------------
-- More Follower Relationships
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO followers (follower_user_id, followed_user_id)
VALUES
-- New learners following existing ones
((SELECT id FROM learner_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='alice_j')),
((SELECT id FROM learner_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='bob_s')),
((SELECT id FROM learner_map WHERE username='daiki_i'), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT id FROM learner_map WHERE username='nanami_h'), (SELECT id FROM learner_map WHERE username='david_l')),
((SELECT id FROM learner_map WHERE username='sho_m'), (SELECT id FROM learner_map WHERE username='emma_w')),

-- English learners following Japanese learners
((SELECT id FROM learner_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='akira_t')),
((SELECT id FROM learner_map WHERE username='madison_d'), (SELECT id FROM learner_map WHERE username='emiko_s')),
((SELECT id FROM learner_map WHERE username='tyler_r'), (SELECT id FROM learner_map WHERE username='hiroshi_y')),
((SELECT id FROM learner_map WHERE username='paige_w'), (SELECT id FROM learner_map WHERE username='yuki_n')),
((SELECT id FROM learner_map WHERE username='brandon_m'), (SELECT id FROM learner_map WHERE username='kenta_s')),

-- Japanese learners following English learners
((SELECT id FROM learner_map WHERE username='yuka_t'), (SELECT id FROM learner_map WHERE username='liam_w')),
((SELECT id FROM learner_map WHERE username='ami_f'), (SELECT id FROM learner_map WHERE username='olivia_k')),
((SELECT id FROM learner_map WHERE username='rei_k'), (SELECT id FROM learner_map WHERE username='noah_s')),

-- Mutual follows between new learners
((SELECT id FROM learner_map WHERE username='austin_l'), (SELECT id FROM learner_map WHERE username='yuka_t')),
((SELECT id FROM learner_map WHERE username='yuka_t'), (SELECT id FROM learner_map WHERE username='austin_l')),
((SELECT id FROM learner_map WHERE username='caleb_j'), (SELECT id FROM learner_map WHERE username='ami_f')),
((SELECT id FROM learner_map WHERE username='ami_f'), (SELECT id FROM learner_map WHERE username='caleb_j')),

-- Additional cross-follows
((SELECT id FROM learner_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='ryan_t')),
((SELECT id FROM learner_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='kenji_w')),
((SELECT id FROM learner_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='madison_d')),
((SELECT id FROM learner_map WHERE username='madison_d'), (SELECT id FROM learner_map WHERE username='haruka_o'));


-- ========================================
-- ADDITIONAL CHATS
-- ========================================

-- -----------------------------
-- More Chats between learners
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO chats (user1_id, user2_id)
VALUES
-- Chats between new learners and existing ones
((SELECT id FROM learner_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='ryan_t')),
((SELECT id FROM learner_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='madison_d')),
((SELECT id FROM learner_map WHERE username='daiki_i'), (SELECT id FROM learner_map WHERE username='tyler_r')),
((SELECT id FROM learner_map WHERE username='nanami_h'), (SELECT id FROM learner_map WHERE username='paige_w')),
((SELECT id FROM learner_map WHERE username='sho_m'), (SELECT id FROM learner_map WHERE username='brandon_m')),
((SELECT id FROM learner_map WHERE username='yuka_t'), (SELECT id FROM learner_map WHERE username='austin_l')),
((SELECT id FROM learner_map WHERE username='ami_f'), (SELECT id FROM learner_map WHERE username='caleb_j')),
((SELECT id FROM learner_map WHERE username='rei_k'), (SELECT id FROM learner_map WHERE username='liam_w')),

-- More chats between existing learners
((SELECT id FROM learner_map WHERE username='liam_w'), (SELECT id FROM learner_map WHERE username='miyuki_k')),
((SELECT id FROM learner_map WHERE username='olivia_k'), (SELECT id FROM learner_map WHERE username='ryo_t')),
((SELECT id FROM learner_map WHERE username='noah_s'), (SELECT id FROM learner_map WHERE username='sakura_i')),
((SELECT id FROM learner_map WHERE username='sophia_a'), (SELECT id FROM learner_map WHERE username='takumi_w')),
((SELECT id FROM learner_map WHERE username='ethan_c'), (SELECT id FROM learner_map WHERE username='aya_m'));


-- ========================================
-- ADDITIONAL MESSAGES
-- ========================================

-- -----------------------------
-- Messages in new chats
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
), chat_map AS (
    SELECT id, user1_id, user2_id FROM chats
)
INSERT INTO messages (chat_id, sender_id, content_text, type, status, correction, translated_content)
VALUES
-- Chat between kenji_w and ryan_t
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='kenji_w') AND user2_id=(SELECT id FROM learner_map WHERE username='ryan_t')), (SELECT id FROM learner_map WHERE username='kenji_w'), 'Hello Ryan! I heard you are learning Japanese. どうですか？', 'text', 'read', NULL, 'Hello Ryan! I heard you are learning Japanese. How is it going?'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='kenji_w') AND user2_id=(SELECT id FROM learner_map WHERE username='ryan_t')), (SELECT id FROM learner_map WHERE username='ryan_t'), 'Hi Kenji! It''s challenging but fun. Can you help me with pronunciation?', 'text', 'read', NULL, NULL),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='kenji_w') AND user2_id=(SELECT id FROM learner_map WHERE username='ryan_t')), (SELECT id FROM learner_map WHERE username='kenji_w'), 'Of course! Let''s practice together. 一緒に頑張りましょう！', 'text', 'unread', NULL, 'Of course! Let''s practice together. Let''s work hard together!'),

-- Chat between haruka_o and madison_d
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='haruka_o') AND user2_id=(SELECT id FROM learner_map WHERE username='madison_d')), (SELECT id FROM learner_map WHERE username='haruka_o'), 'Hi Madison! I saw your post about teaching English. That''s amazing!', 'text', 'read', NULL, NULL),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='haruka_o') AND user2_id=(SELECT id FROM learner_map WHERE username='madison_d')), (SELECT id FROM learner_map WHERE username='madison_d'), 'Thank you Haruka! Maybe we can do language exchange?', 'text', 'read', NULL, NULL),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='haruka_o') AND user2_id=(SELECT id FROM learner_map WHERE username='madison_d')), (SELECT id FROM learner_map WHERE username='haruka_o'), 'Yes! I would love that. When are you free?', 'text', 'unread', 'Yes! I would love that. When are you available?', NULL),

-- Chat between daiki_i and tyler_r
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='daiki_i') AND user2_id=(SELECT id FROM learner_map WHERE username='tyler_r')), (SELECT id FROM learner_map WHERE username='daiki_i'), 'Hey Tyler! I noticed you like anime. Have you watched any recent ones?', 'text', 'read', NULL, NULL),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='daiki_i') AND user2_id=(SELECT id FROM learner_map WHERE username='tyler_r')), (SELECT id FROM learner_map WHERE username='tyler_r'), 'Yes! I just finished watching Demon Slayer. The Japanese voice acting is incredible!', 'text', 'read', NULL, NULL),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='daiki_i') AND user2_id=(SELECT id FROM learner_map WHERE username='tyler_r')), (SELECT id FROM learner_map WHERE username='daiki_i'), 'Great choice! それは本当に人気ですね。Do you understand without subtitles?', 'text', 'unread', NULL, 'Great choice! That''s really popular. Do you understand without subtitles?'),

-- Chat between yuka_t and austin_l
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='yuka_t') AND user2_id=(SELECT id FROM learner_map WHERE username='austin_l')), (SELECT id FROM learner_map WHERE username='yuka_t'), 'Austin, I read that you''re interested in traditional Japanese arts. That''s wonderful!', 'text', 'read', NULL, NULL),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='yuka_t') AND user2_id=(SELECT id FROM learner_map WHERE username='austin_l')), (SELECT id FROM learner_map WHERE username='austin_l'), 'Thank you Yuka! I''m particularly fascinated by tea ceremony and meditation.', 'text', 'read', NULL, NULL),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='yuka_t') AND user2_id=(SELECT id FROM learner_map WHERE username='austin_l')), (SELECT id FROM learner_map WHERE username='yuka_t'), 'I can teach you some basics! 茶道は美しい文化です。', 'text', 'unread', NULL, 'I can teach you some basics! Tea ceremony is a beautiful culture.');


-- ========================================
-- ADDITIONAL FEED POSTS
-- ========================================

-- -----------------------------
-- More Feed Posts
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO feed (learner_id, content_text)
VALUES
-- New learners posts
((SELECT id FROM learner_map WHERE username='kenji_w'), 'Started my first English business presentation today. Nervous but excited! 📊💼'),
((SELECT id FROM learner_map WHERE username='haruka_o'), 'Reading my first English novel! It''s challenging but so rewarding. 📚✨'),
((SELECT id FROM learner_map WHERE username='daiki_i'), 'Finally understood a complex programming tutorial in English without translation! 💻🎉'),
((SELECT id FROM learner_map WHERE username='nanami_h'), 'Watched Avengers without subtitles and understood 80%! Progress! 🎬🦸‍♀️'),
((SELECT id FROM learner_map WHERE username='sho_m'), 'Had my first job interview in English today. Silicon Valley, here I come! 🚀💼'),

((SELECT id FROM learner_map WHERE username='ryan_t'), 'Learned my first 50 kanji characters! Each one tells a story. 漢字は面白い！'),
((SELECT id FROM learner_map WHERE username='madison_d'), 'Practicing Japanese tongue twisters. My pronunciation is getting better! 👅🗣️'),
((SELECT id FROM learner_map WHERE username='tyler_r'), 'Read my first manga in Japanese without translation. Small victories! 📖⭐'),
((SELECT id FROM learner_map WHERE username='paige_w'), 'Cooked my first traditional Japanese meal with instructions in Japanese! 🍱👩‍🍳'),
((SELECT id FROM learner_map WHERE username='brandon_m'), 'Understanding Japanese business etiquette is as important as the language itself. 🏢🙇‍♂️'),

((SELECT id FROM learner_map WHERE username='yuka_t'), 'Wrote my first poem in English today. Language is poetry in motion. ✍️🌸'),
((SELECT id FROM learner_map WHERE username='austin_l'), 'Learned the Japanese names for all meditation poses. Mind and language in harmony. 🧘‍♂️☯️'),
((SELECT id FROM learner_map WHERE username='ami_f'), 'Ordered food in English while traveling. Small steps, big confidence! 🍕🌍'),
((SELECT id FROM learner_map WHERE username='caleb_j'), 'Finally beat a Japanese RPG in its original language! ゲームクリア！🎮🏆'),
((SELECT id FROM learner_map WHERE username='rei_k'), 'Sang my favorite English song at karaoke. Language through music! 🎤🎵'),

-- More posts from existing learners
((SELECT id FROM learner_map WHERE username='grace_m'), 'Japanese grammar is like a puzzle. Each piece makes the picture clearer! 🧩'),
((SELECT id FROM learner_map WHERE username='henry_b'), 'Watched a Japanese sports match and understood the commentary! ⚽🗣️'),
((SELECT id FROM learner_map WHERE username='isabella_g'), 'Learning photography terms in Japanese. Pictures speak all languages! 📸🗾'),
((SELECT id FROM learner_map WHERE username='lucas_e'), 'Read Japanese news article about technology. My two passions combined! 📱📰'),
((SELECT id FROM learner_map WHERE username='ava_b'), 'Planning my first solo trip to Japan. Language learning in action! ✈️🗾');
-- ========================================
-- ADDITIONAL FEED IMAGES
-- ========================================

-- -----------------------------
-- More Feed Images
-- -----------------------------
WITH feed_map AS (
    SELECT f.id, l.username 
    FROM feed f
    JOIN learners l ON f.learner_id = l.id
)
INSERT INTO feed_images (feed_id, image_url, position)
VALUES
-- Kenji's business presentation images
((SELECT id FROM feed_map WHERE username='kenji_w'), 'https://images.unsplash.com/photo-1552664730-d307ca884978', 1),
((SELECT id FROM feed_map WHERE username='kenji_w'), 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40', 2),

-- Haruka's reading images
((SELECT id FROM feed_map WHERE username='haruka_o'), 'https://images.unsplash.com/photo-1544947950-fa07a98d237f', 1),
((SELECT id FROM feed_map WHERE username='haruka_o'), 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570', 2),

-- Daiki's programming images
((SELECT id FROM feed_map WHERE username='daiki_i'), 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6', 1),

-- Nanami's movie images
((SELECT id FROM feed_map WHERE username='nanami_h'), 'https://images.unsplash.com/photo-1489599809804-28b3a3b2b8f3', 1),
((SELECT id FROM feed_map WHERE username='nanami_h'), 'https://images.unsplash.com/photo-1536440136628-849c177e76a1', 2),

-- Ryan's kanji learning images
((SELECT id FROM feed_map WHERE username='ryan_t'), 'https://images.unsplash.com/photo-1545558014-8692077e9b5c', 1),
((SELECT id FROM feed_map WHERE username='ryan_t'), 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', 2),

-- Tyler's manga reading images
((SELECT id FROM feed_map WHERE username='tyler_r'), 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', 1),

-- Paige's cooking images
((SELECT id FROM feed_map WHERE username='paige_w'), 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351', 1),
((SELECT id FROM feed_map WHERE username='paige_w'), 'https://images.unsplash.com/photo-1551218808-94e220e084d2', 2),

-- Austin's meditation images
((SELECT id FROM feed_map WHERE username='austin_l'), 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b', 1),

-- Caleb's gaming images
((SELECT id FROM feed_map WHERE username='caleb_j'), 'https://images.unsplash.com/photo-1511512578047-dfb367046420', 1),
((SELECT id FROM feed_map WHERE username='caleb_j'), 'https://images.unsplash.com/photo-1493711662062-fa541adb3fc8', 2);


-- ========================================
-- ADDITIONAL FEED LIKES
-- ========================================

-- -----------------------------
-- More Feed Likes
-- -----------------------------
WITH feed_map AS (
    SELECT f.id, l.username 
    FROM feed f
    JOIN learners l ON f.learner_id = l.id
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO feed_likes (feed_id, learner_id)
VALUES
-- Likes on new feed posts
((SELECT id FROM feed_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='ryan_t')),
((SELECT id FROM feed_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='alice_j')),
((SELECT id FROM feed_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='madison_d')),

((SELECT id FROM feed_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='madison_d')),
((SELECT id FROM feed_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT id FROM feed_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='yuka_t')),

((SELECT id FROM feed_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='kenji_w')),
((SELECT id FROM feed_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='akira_t')),
((SELECT id FROM feed_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='david_l')),

((SELECT id FROM feed_map WHERE username='tyler_r'), (SELECT id FROM learner_map WHERE username='daiki_i')),
((SELECT id FROM feed_map WHERE username='tyler_r'), (SELECT id FROM learner_map WHERE username='caleb_j')),

((SELECT id FROM feed_map WHERE username='austin_l'), (SELECT id FROM learner_map WHERE username='yuka_t')),
((SELECT id FROM feed_map WHERE username='austin_l'), (SELECT id FROM learner_map WHERE username='sophia_a')),

-- More likes on existing posts
((SELECT id FROM feed_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='haruka_o')),
((SELECT id FROM feed_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='kenji_w')),
((SELECT id FROM feed_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='ryan_t'));


-- ========================================
-- ADDITIONAL FEED COMMENTS
-- ========================================

-- -----------------------------
-- More Feed Comments
-- -----------------------------
WITH feed_map AS (
    SELECT f.id, l.username 
    FROM feed f
    JOIN learners l ON f.learner_id = l.id
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO feed_comments (feed_id, learner_id, content_text, translated_content)
VALUES
-- Comments on new posts
((SELECT id FROM feed_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='ryan_t'), 'That''s amazing Kenji! How did you prepare for it?', NULL),
((SELECT id FROM feed_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='madison_d'), 'Business English is challenging but you''ve got this! 💪', NULL),

((SELECT id FROM feed_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='carol_d'), 'What novel are you reading? I need recommendations!', NULL),
((SELECT id FROM feed_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='yuka_t'), 'Reading novels in English helps so much with vocabulary!', NULL),

((SELECT id FROM feed_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='kenji_w'), 'Kanji is beautiful! Each character has such deep meaning. 頑張って！', 'Kanji is beautiful! Each character has such deep meaning. Keep it up!'),
((SELECT id FROM feed_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='akira_t'), 'Your dedication is inspiring! 漢字を覚えるのは大変ですが、面白いです。', 'Your dedication is inspiring! Learning kanji is difficult but interesting.'),

((SELECT id FROM feed_map WHERE username='tyler_r'), (SELECT id FROM learner_map WHERE username='daiki_i'), 'Which manga did you read? I''m looking for beginner-friendly ones.', NULL),
((SELECT id FROM feed_map WHERE username='tyler_r'), (SELECT id FROM learner_map WHERE username='caleb_j'), 'Reading manga in Japanese is the best way to learn! すごいですね！', 'Reading manga in Japanese is the best way to learn! That''s awesome!'),

((SELECT id FROM feed_map WHERE username='austin_l'), (SELECT id FROM learner_map WHERE username='yuka_t'), 'Meditation and language learning complement each other beautifully. 心を静めて学ぶ。', 'Meditation and language learning complement each other beautifully. Learn with a calm heart.'),

-- Comments on existing posts
((SELECT id FROM feed_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='haruka_o'), 'Podcasts are great for listening practice! Any recommendations?', NULL),
((SELECT id FROM feed_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='kenji_w'), 'I should try English podcasts too. What topics do you listen to?', NULL);


-- ========================================
-- ADDITIONAL COURSES
-- ========================================

-- -----------------------------
-- More Courses
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO courses (instructor_id, title, description, language, level, total_sessions, price, thumbnail_url, start_date, end_date, status)
VALUES
-- New English courses
((SELECT id FROM instructor_map WHERE username='michael_b'), 'Business English Mastery', 'Professional English for workplace communication and presentations.', 'english', 'intermediate', 6, 79.99, 'https://images.unsplash.com/photo-1521791055366-0d553872125f', '2025-08-15', '2025-09-15', 'active'),
((SELECT id FROM instructor_map WHERE username='jennifer_t'), 'English Literature & Creative Writing', 'Explore classic and modern English literature while improving writing skills.', 'english', 'advanced', 8, 89.99, 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570', '2025-09-01', '2025-10-15', 'upcoming'),
((SELECT id FROM instructor_map WHERE username='robert_g'), 'English Pronunciation Clinic', 'Master American English pronunciation and accent reduction.', 'english', 'beginner', 4, 54.99, 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173', '2025-07-15', '2025-08-15', 'active'),
((SELECT id FROM instructor_map WHERE username='emily_a'), 'TOEFL Preparation Course', 'Comprehensive TOEFL test preparation with practice tests.', 'english', 'intermediate', 10, 99.99, 'https://images.unsplash.com/photo-1434596922112-19c563067271', '2025-09-10', '2025-11-10', 'upcoming'),
((SELECT id FROM instructor_map WHERE username='daniel_w'), 'English Conversation Café', 'Casual English conversation practice in small groups.', 'english', 'beginner', 5, 39.99, 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d', '2025-08-20', '2025-09-20', 'active'),

-- New Japanese courses
((SELECT id FROM instructor_map WHERE username='satoshi_n'), 'Traditional Japanese Culture & Language', 'Learn Japanese through cultural contexts and traditional practices.', 'japanese', 'intermediate', 7, 74.99, 'https://images.unsplash.com/photo-1528164344705-47542687000d', '2025-08-10', '2025-09-25', 'active'),
((SELECT id FROM instructor_map WHERE username='akiko_y'), 'Japanese Calligraphy & Writing', 'Master beautiful Japanese writing from hiragana to advanced kanji.', 'japanese', 'beginner', 6, 64.99, 'https://images.unsplash.com/photo-1545558014-8692077e9b5c', '2025-09-05', '2025-10-20', 'upcoming'),
((SELECT id FROM instructor_map WHERE username='masaki_s'), 'Business Japanese Communication', 'Professional Japanese for business meetings and email communication.', 'japanese', 'advanced', 8, 94.99, 'https://images.unsplash.com/photo-1497032205916-ac775f0649ae', '2025-09-15', '2025-11-15', 'upcoming'),
((SELECT id FROM instructor_map WHERE username='yumiko_t'), 'Japanese Through Anime & Pop Culture', 'Learn modern Japanese using anime, manga, and J-pop.', 'japanese', 'beginner', 5, 49.99, 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', '2025-08-05', '2025-09-05', 'active'),
((SELECT id FROM instructor_map WHERE username='tetsuya_k'), 'JLPT N3 Preparation', 'Intensive preparation for Japanese Language Proficiency Test N3.', 'japanese', 'intermediate', 10, 89.99, 'https://images.unsplash.com/photo-1551218808-94e220e084d2', '2025-09-20', '2025-12-20', 'upcoming');


-- ========================================
-- ADDITIONAL COURSE SESSIONS
-- ========================================

-- -----------------------------
-- Sessions for new courses
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
)
INSERT INTO course_sessions (course_id, session_name, session_description, session_date, session_time, session_duration, session_link, session_password, session_platform)
VALUES
-- Business English Mastery sessions
((SELECT id FROM course_map WHERE title='Business English Mastery'), 'Session 1: Professional Introductions', 'Learn to introduce yourself in business settings', '2025-08-16', '14:00', '1.5h', 'https://zoom.us/j/111222', 'biz001', 'zoom'),
((SELECT id FROM course_map WHERE title='Business English Mastery'), 'Session 2: Email Communication', 'Professional email writing and etiquette', '2025-08-20', '14:00', '1.5h', 'https://meet.google.com/biz-email-001', 'biz002', 'meet'),
((SELECT id FROM course_map WHERE title='Business English Mastery'), 'Session 3: Presentation Skills', 'Delivering effective business presentations', '2025-08-23', '14:00', '1.5h', 'https://zoom.us/j/111333', 'biz003', 'zoom'),

-- English Pronunciation Clinic sessions
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'Session 1: Vowel Sounds', 'Master American English vowel pronunciation', '2025-07-16', '10:00', '1h', 'https://zoom.us/j/222333', 'pron01', 'zoom'),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'Session 2: Consonant Clusters', 'Practice difficult consonant combinations', '2025-07-19', '10:00', '1h', 'https://meet.google.com/pron-cons-01', 'pron02', 'meet'),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'Session 3: Rhythm and Stress', 'English sentence rhythm and word stress patterns', '2025-07-23', '10:00', '1h', 'https://zoom.us/j/222444', 'pron03', 'zoom'),

-- Japanese Through Anime sessions
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'Session 1: Basic Anime Vocabulary', 'Common words and phrases from popular anime', '2025-08-06', '16:00', '1h', 'https://zoom.us/j/333444', 'anime01', 'zoom'),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'Session 2: Casual vs Formal Speech', 'Understanding different speech levels in anime', '2025-08-09', '16:00', '1h', 'https://meet.google.com/anime-speech-01', 'anime02', 'meet'),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'Session 3: Cultural References', 'Understanding cultural context in anime and manga', '2025-08-13', '16:00', '1h', 'https://zoom.us/j/333555', 'anime03', 'zoom');


-- ========================================
-- ADDITIONAL COURSE ENROLLMENTS
-- ========================================

-- -----------------------------
-- More Course Enrollments
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO course_enrollments (course_id, learner_id)
VALUES
-- English courses enrollments
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM learner_map WHERE username='kenji_w')),
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM learner_map WHERE username='haruka_o')),
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM learner_map WHERE username='sho_m')),

((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM learner_map WHERE username='akira_t')),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM learner_map WHERE username='emiko_s')),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM learner_map WHERE username='yuka_t')),

((SELECT id FROM course_map WHERE title='English Conversation Café'), (SELECT id FROM learner_map WHERE username='daiki_i')),
((SELECT id FROM course_map WHERE title='English Conversation Café'), (SELECT id FROM learner_map WHERE username='ami_f')),
((SELECT id FROM course_map WHERE title='English Conversation Café'), (SELECT id FROM learner_map WHERE username='rei_k')),

-- Japanese courses enrollments
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM learner_map WHERE username='ryan_t')),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM learner_map WHERE username='tyler_r')),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM learner_map WHERE username='caleb_j')),

((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), (SELECT id FROM learner_map WHERE username='austin_l')),
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), (SELECT id FROM learner_map WHERE username='paige_w')),
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), (SELECT id FROM learner_map WHERE username='madison_d')),

-- More enrollments in existing courses
((SELECT id FROM course_map WHERE title='Conversational English'), (SELECT id FROM learner_map WHERE username='nanami_h'));
-- ========================================
-- ADDITIONAL RECORDED CLASSES
-- ========================================

-- -----------------------------
-- More Recorded Classes
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
)
INSERT INTO recorded_classes (course_id, recorded_name, recorded_description, recorded_link)
VALUES
-- Business English Mastery recordings
((SELECT id FROM course_map WHERE title='Business English Mastery'), 'Recorded Session 1: Professional Introductions', 'Recorded video for business introductions', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Business English Mastery'), 'Recorded Session 2: Email Communication', 'Recorded video for business email writing', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),

-- English Pronunciation Clinic recordings
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'Recorded Session 1: Vowel Sounds', 'Recorded video for vowel pronunciation', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'Recorded Session 2: Consonant Clusters', 'Recorded video for consonant practice', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),

-- Japanese Through Anime recordings
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'Recorded Session 1: Basic Anime Vocabulary', 'Recorded video for anime vocabulary', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'Recorded Session 2: Casual vs Formal Speech', 'Recorded video for speech levels', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),

-- Traditional Japanese Culture recordings
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), 'Recorded Session 1: Cultural Context', 'Recorded video for cultural understanding', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), 'Recorded Session 2: Traditional Expressions', 'Recorded video for traditional language', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');


-- ========================================
-- ADDITIONAL STUDY MATERIALS
-- ========================================

-- -----------------------------
-- More Study Materials
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
)
INSERT INTO study_materials (course_id, material_title, material_description, material_link, material_type)
VALUES
-- Business English materials
((SELECT id FROM course_map WHERE title='Business English Mastery'), 'Business Vocabulary PDF', 'Essential business English vocabulary list', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/business_vocab.pdf', 'pdf'),
((SELECT id FROM course_map WHERE title='Business English Mastery'), 'Email Templates Doc', 'Professional email templates and examples', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/email_templates.docx', 'document'),
((SELECT id FROM course_map WHERE title='Business English Mastery'), 'Presentation Guide Image', 'Visual guide for business presentations', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/presentation_guide.png', 'image'),

-- Pronunciation materials
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'IPA Chart PDF', 'International Phonetic Alphabet reference chart', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/ipa_chart.pdf', 'pdf'),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'Pronunciation Exercises Doc', 'Practice exercises for pronunciation improvement', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/pronunciation_exercises.docx', 'document'),

-- Anime course materials
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'Anime Vocabulary PDF', 'Common anime and manga vocabulary', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/anime_vocab.pdf', 'pdf'),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'Cultural References Doc', 'Guide to cultural references in anime', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/cultural_refs.docx', 'document'),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'Character Expressions Image', 'Visual guide to anime character expressions', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/anime_expressions.png', 'image'),

-- Traditional culture materials
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), 'Cultural Etiquette PDF', 'Guide to Japanese cultural etiquette', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/cultural_etiquette.pdf', 'pdf'),
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), 'Traditional Arts Doc', 'Introduction to traditional Japanese arts', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/traditional_arts.docx', 'document'),

-- Calligraphy materials
((SELECT id FROM course_map WHERE title='Japanese Calligraphy & Writing'), 'Stroke Order PDF', 'Kanji stroke order reference guide', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/stroke_order.pdf', 'pdf'),
((SELECT id FROM course_map WHERE title='Japanese Calligraphy & Writing'), 'Brush Techniques Image', 'Visual guide to brush calligraphy techniques', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/brush_techniques.png', 'image');


-- ========================================
-- ADDITIONAL GROUP CHATS
-- ========================================

-- -----------------------------
-- More Group Chat Messages
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
), instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO group_chat (course_id, sender_id, sender_type, content_text)
VALUES
-- Business English group chat
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM instructor_map WHERE username='michael_b'), 'instructor', 'Welcome to Business English Mastery! Let''s start with professional introductions.'),
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM learner_map WHERE username='kenji_w'), 'learner', 'Hello everyone! I''m Kenji from Japan. Excited to improve my business English!'),
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM learner_map WHERE username='haruka_o'), 'learner', 'Hi! I''m Haruka. Looking forward to learning with you all!'),
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM learner_map WHERE username='sho_m'), 'learner', 'Hey team! Sho here. Ready to master professional communication!'),

-- Anime course group chat
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM instructor_map WHERE username='yumiko_t'), 'instructor', 'みなさん、こんにちは！Welcome to our anime Japanese class! This will be fun!'),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM learner_map WHERE username='ryan_t'), 'learner', 'This is so cool! I can''t wait to understand anime without subtitles!'),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM learner_map WHERE username='tyler_r'), 'learner', 'Same here! Anime got me interested in Japanese in the first place.'),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM learner_map WHERE username='caleb_j'), 'learner', 'Perfect! Now I can understand what the characters are really saying!'),

-- Pronunciation clinic group chat
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM instructor_map WHERE username='robert_g'), 'instructor', 'Welcome to Pronunciation Clinic! We''ll work on clear American English pronunciation together.'),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM learner_map WHERE username='akira_t'), 'learner', 'Thank you! I really want to improve my pronunciation.'),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM learner_map WHERE username='emiko_s'), 'learner', 'This is exactly what I need for my job interviews!'),

-- Traditional culture group chat
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), (SELECT id FROM instructor_map WHERE username='satoshi_n'), 'instructor', '日本の伝統文化へようこそ！Welcome to traditional Japanese culture! Let''s explore together.'),
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), (SELECT id FROM learner_map WHERE username='austin_l'), 'learner', 'I''m fascinated by Japanese philosophy and tea ceremony. Thank you for this course!'),
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), (SELECT id FROM learner_map WHERE username='paige_w'), 'learner', 'Looking forward to learning about the cultural context behind the language!');


-- ========================================
-- ADDITIONAL FEEDBACK
-- ========================================

-- -----------------------------
-- More Feedback
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
), instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO feedback (course_id, instructor_id, learner_id, feedback_type, feedback_text, rating)
VALUES
-- Business English course feedback
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM instructor_map WHERE username='michael_b'), (SELECT id FROM learner_map WHERE username='kenji_w'), 'learner', 'Excellent course! Very practical for real business situations.', 5),
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM instructor_map WHERE username='michael_b'), (SELECT id FROM learner_map WHERE username='haruka_o'), 'learner', 'The email writing section was incredibly helpful!', 5),
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM instructor_map WHERE username='michael_b'), (SELECT id FROM learner_map WHERE username='kenji_w'), 'instructor', 'Kenji shows great improvement in business vocabulary and confidence.', 5),

-- Pronunciation clinic feedback
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM instructor_map WHERE username='robert_g'), (SELECT id FROM learner_map WHERE username='akira_t'), 'learner', 'My pronunciation has improved dramatically! Thank you!', 5),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM instructor_map WHERE username='robert_g'), (SELECT id FROM learner_map WHERE username='emiko_s'), 'learner', 'The IPA chart explanation was very clear and helpful.', 4),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM instructor_map WHERE username='robert_g'), (SELECT id FROM learner_map WHERE username='akira_t'), 'instructor', 'Akira is very dedicated and practices regularly. Great progress!', 5),

-- Anime course feedback
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM instructor_map WHERE username='yumiko_t'), (SELECT id FROM learner_map WHERE username='ryan_t'), 'learner', 'This makes learning Japanese so much fun! Love the approach.', 5),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM instructor_map WHERE username='yumiko_t'), (SELECT id FROM learner_map WHERE username='tyler_r'), 'learner', 'Finally understanding anime dialogue! This course is amazing.', 5),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM instructor_map WHERE username='yumiko_t'), (SELECT id FROM learner_map WHERE username='caleb_j'), 'learner', 'Perfect combination of learning and entertainment.', 4),

-- Traditional culture feedback
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), (SELECT id FROM instructor_map WHERE username='satoshi_n'), (SELECT id FROM learner_map WHERE username='austin_l'), 'learner', 'Deep cultural insights that help understand the language better.', 5),
((SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), (SELECT id FROM instructor_map WHERE username='satoshi_n'), (SELECT id FROM learner_map WHERE username='paige_w'), 'learner', 'Beautiful way to learn language through culture.', 5),

-- Course feedback
((SELECT id FROM course_map WHERE title='Business English Mastery'), (SELECT id FROM instructor_map WHERE username='michael_b'), (SELECT id FROM learner_map WHERE username='sho_m'), 'course', 'Well-structured course with practical applications.', 5),
((SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), (SELECT id FROM instructor_map WHERE username='yumiko_t'), (SELECT id FROM learner_map WHERE username='ryan_t'), 'course', 'Innovative teaching method that makes learning enjoyable.', 5);


-- ========================================
-- ADDITIONAL NOTIFICATIONS
-- ========================================

-- -----------------------------
-- More Notifications
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO notifications (learner_id, course_id, notification_type, content_title, content_text, is_read)
VALUES
-- Business course notifications
((SELECT id FROM learner_map WHERE username='kenji_w'), (SELECT id FROM course_map WHERE title='Business English Mastery'), 'session alert', 'Session Reminder', 'Business English Session 2 starts tomorrow at 14:00.', FALSE),
((SELECT id FROM learner_map WHERE username='haruka_o'), (SELECT id FROM course_map WHERE title='Business English Mastery'), 'feedback', 'New Feedback', 'You received positive feedback on your presentation skills!', TRUE),
((SELECT id FROM learner_map WHERE username='sho_m'), (SELECT id FROM course_map WHERE title='Business English Mastery'), 'session alert', 'Session Reminder', 'Don''t miss Session 3: Presentation Skills tomorrow!', FALSE),

-- Anime course notifications
((SELECT id FROM learner_map WHERE username='ryan_t'), (SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'session alert', 'Session Reminder', 'Anime Japanese session starts in 2 hours!', FALSE),
((SELECT id FROM learner_map WHERE username='tyler_r'), (SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'feedback', 'New Feedback', 'Great progress in understanding anime dialogue!', TRUE),
((SELECT id FROM learner_map WHERE username='caleb_j'), (SELECT id FROM course_map WHERE title='Japanese Through Anime & Pop Culture'), 'session alert', 'Session Reminder', 'Cultural References session tomorrow at 16:00.', FALSE),

-- Pronunciation clinic notifications
((SELECT id FROM learner_map WHERE username='akira_t'), (SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'feedback', 'New Feedback', 'Your pronunciation has improved significantly!', TRUE),
((SELECT id FROM learner_map WHERE username='emiko_s'), (SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'session alert', 'Session Reminder', 'Rhythm and Stress session starts tomorrow.', FALSE),

-- Traditional culture notifications
((SELECT id FROM learner_map WHERE username='austin_l'), (SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), 'session alert', 'Session Reminder', 'Tea Ceremony Language session this afternoon.', FALSE),
((SELECT id FROM learner_map WHERE username='paige_w'), (SELECT id FROM course_map WHERE title='Traditional Japanese Culture & Language'), 'feedback', 'New Feedback', 'Excellent understanding of cultural context!', TRUE),

-- General notifications for other learners
((SELECT id FROM learner_map WHERE username='nanami_h'), (SELECT id FROM course_map WHERE title='Conversational English'), 'session alert', 'Session Reminder', 'Conversation practice starts in 1 hour.', FALSE),
((SELECT id FROM learner_map WHERE username='brandon_m'), (SELECT id FROM course_map WHERE title='Japanese Conversation Practice'), 'feedback', 'New Feedback', 'Your speaking confidence has increased greatly!', TRUE),
((SELECT id FROM learner_map WHERE username='ami_f'), (SELECT id FROM course_map WHERE title='English Conversation Café'), 'session alert', 'Session Reminder', 'Casual conversation session tomorrow morning.', FALSE),
((SELECT id FROM learner_map WHERE username='rei_k'), (SELECT id FROM course_map WHERE title='English Conversation Café'), 'feedback', 'New Feedback', 'Wonderful participation in group discussions!', TRUE);


-- ========================================
-- ADDITIONAL WITHDRAWALS
-- ========================================

-- -----------------------------
-- More Withdrawals for all instructors
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO withdrawal (instructor_id, amount, status)
VALUES
-- Additional withdrawals for new instructors
((SELECT id FROM instructor_map WHERE username='michael_b'), 450.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='michael_b'), 280.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='jennifer_t'), 380.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='robert_g'), 320.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='robert_g'), 195.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='emily_a'), 410.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='daniel_w'), 240.00, 'COMPLETED'),

((SELECT id FROM instructor_map WHERE username='satoshi_n'), 520.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='satoshi_n'), 290.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='akiko_y'), 360.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='masaki_s'), 480.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='yumiko_t'), 310.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='yumiko_t'), 180.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='tetsuya_k'), 420.00, 'COMPLETED'),

-- More withdrawals for existing instructors
((SELECT id FROM instructor_map WHERE username='william_j'), 350.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='olivia_s'), 280.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='james_d'), 390.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='sophia_m'), 260.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='benjamin_w'), 310.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='hiroshi_t'), 440.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='emiko_s'), 190.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='takeshi_y'), 380.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='yuki_n'), 270.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='kenta_s'), 325.00, 'COMPLETED');


-- -----------------------------
-- Withdrawal Info for new withdrawals
-- -----------------------------
WITH withdrawal_map AS (
    SELECT w.id, i.username, w.amount
    FROM withdrawal w
    JOIN instructors i ON w.instructor_id = i.id
    WHERE w.amount IN (450.00, 280.00, 380.00, 320.00, 195.00, 410.00, 240.00, 520.00, 290.00, 360.00, 480.00, 310.00, 180.00, 420.00, 350.00, 390.00, 260.00, 440.00, 190.00, 270.00, 325.00)
)
INSERT INTO withdrawal_info (withdrawal_id, payment_method, card_number, expiry_date, cvv, card_holder_name, paypal_email, bank_account_number, bank_name, swift_code)
VALUES
-- Card payments for new instructors
((SELECT id FROM withdrawal_map WHERE username='michael_b' AND amount=450.00), 'CARD', '4444333322221111', '03/2028', '567', 'Michael Brown', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='jennifer_t'), 'CARD', '5555666677778888', '08/2029', '890', 'Jennifer Taylor', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='emily_a'), 'CARD', '6666777788889999', '11/2027', '234', 'Emily Anderson', NULL, NULL, NULL, NULL),

-- PayPal payments for new instructors
((SELECT id FROM withdrawal_map WHERE username='robert_g' AND amount=320.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'robert.garcia@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='daniel_w'), 'PAYPAL', NULL, NULL, NULL, NULL, 'daniel.wilson@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='yumiko_t' AND amount=310.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'yumiko.takahashi@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='akiko_y'), 'PAYPAL', NULL, NULL, NULL, NULL, 'akiko.yamada@example.com', NULL, NULL, NULL),

-- Bank transfers for new instructors
((SELECT id FROM withdrawal_map WHERE username='satoshi_n' AND amount=520.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '1111222233', 'Bank of America', 'BOFAUS3N'),
((SELECT id FROM withdrawal_map WHERE username='masaki_s'), 'BANK', NULL, NULL, NULL, NULL, NULL, '4444555566', 'JPMorgan Chase', 'CHASUS33'),
((SELECT id FROM withdrawal_map WHERE username='tetsuya_k'), 'BANK', NULL, NULL, NULL, NULL, NULL, '7777888899', 'Wells Fargo', 'WFBIUS6S'),

-- Mixed payment methods for remaining withdrawals
((SELECT id FROM withdrawal_map WHERE username='michael_b' AND amount=280.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'michael.brown@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='robert_g' AND amount=195.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '2222333344', 'Citibank', 'CITIUS33'),
((SELECT id FROM withdrawal_map WHERE username='satoshi_n' AND amount=290.00), 'CARD', '9999888877776666', '05/2030', '123', 'Satoshi Nakamura', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='yumiko_t' AND amount=180.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '5555666677', 'Resona Bank', 'RRBJJPJT'),

-- Additional payment info for existing instructor withdrawals
((SELECT id FROM withdrawal_map WHERE username='william_j' AND amount=350.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '9999000011', 'US Bank', 'USBKUS44'),
((SELECT id FROM withdrawal_map WHERE username='olivia_s' AND amount=280.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'olivia.smith.instructor@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='james_d' AND amount=390.00), 'CARD', '1111222233334444', '12/2028', '789', 'James Davis', NULL, NULL, NULL, NULL);
