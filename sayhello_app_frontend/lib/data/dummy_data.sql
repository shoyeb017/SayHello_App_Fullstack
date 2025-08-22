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
('Alice Johnson', 'alice.johnson@example.com', 'ali', '1234', '1995-03-12', 'female', 'usa', 'I love learning Japanese and exploring new cultures.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['anime','travel','music']),
('Bob Smith', 'bob.smith@example.com', 'bob_s', '1234', '1992-07-25', 'male', 'usa', 'Learning Japanese to speak fluently with native speakers.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['gaming','reading','cooking']),
('Carol Davis', 'carol.davis@example.com', 'carol_d', '1234', '1998-11-02', 'female', 'usa', 'I enjoy practicing Japanese daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['travel','calligraphy','photography']),
('David Lee', 'david.lee@example.com', 'david_l', '1234', '1990-06-15', 'male', 'usa', 'Passionate about Japanese culture and language.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['martial arts','reading','music']),
('Emma Wilson', 'emma.wilson@example.com', 'emma_w', '1234', '1997-01-30', 'female', 'usa', 'Learning Japanese to travel and communicate better.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['travel','anime','yoga']),
('Frank Taylor', 'frank.taylor@example.com', 'frank_t', '1234', '1993-09-21', 'male', 'usa', 'I want to understand Japanese media in original language.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['movies','gaming','language exchange']),
('Grace Martinez', 'grace.martinez@example.com', 'grace_m', '1234', '1996-04-18', 'female', 'usa', 'Learning Japanese for work and personal growth.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['reading','travel','cooking']),
('Henry Brown', 'henry.brown@example.com', 'henry_b', '1234', '1991-08-09', 'male', 'usa', 'Interested in Japanese language and culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['music','sports','anime']),
('Isabella Garcia', 'isabella.garcia@example.com', 'isabella_g', '1234', '1994-12-05', 'female', 'usa', 'Practicing Japanese to communicate with friends.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['photography','travel','music']),
('Jack Wilson', 'jack.wilson@example.com', 'jack_w', '1234', '1990-02-17', 'male', 'usa', 'Learning Japanese is my passion.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['anime','gaming','reading']);

-- -----------------------------
-- Learners Batch 2
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Akira Tanaka', 'akira.tanaka@example.com', 'aki', '1234', '1995-05-22', 'male', 'japan', 'I love learning English to communicate worldwide.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'beginner', ARRAY['music','travel','anime']),
('Emiko Sato', 'emiko.sato@example.com', 'emiko_s', '1234', '1997-11-11', 'female', 'japan', 'Learning English to improve my career prospects.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'elementary', ARRAY['reading','cooking','yoga']),
('Hiroshi Yamamoto', 'hiroshi.yamamoto@example.com', 'hiroshi_y', '1234', '1990-03-14', 'male', 'japan', 'I practice English to enjoy movies and media.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'intermediate', ARRAY['movies','sports','gaming']),
('Yuki Nakamura', 'yuki.nakamura@example.com', 'yuki_n', '1234', '1992-07-30', 'female', 'japan', 'Passionate about English literature and language.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'advanced', ARRAY['reading','travel','writing']),
('Kenta Suzuki', 'kenta.suzuki@example.com', 'kenta_s', '1234', '1998-01-25', 'male', 'japan', 'Learning English to travel abroad and meet people.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'proficient', ARRAY['travel','music','gaming']),
('Miyuki Kobayashi', 'miyuki.kobayashi@example.com', 'miyuki_k', '1234', '1996-06-05', 'female', 'japan', 'I enjoy practicing English daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'beginner', ARRAY['writing','reading','cooking']),
('Ryo Takahashi', 'ryo.takahashi@example.com', 'ryo_t', '1234', '1993-09-19', 'male', 'japan', 'Learning English for professional development.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'elementary', ARRAY['reading','travel','movies']),
('Sakura Ito', 'sakura.ito@example.com', 'sakura_i', '1234', '1994-12-07', 'female', 'japan', 'I want to improve my English speaking skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'intermediate', ARRAY['travel','music','yoga']),
('Takumi Watanabe', 'takumi.watanabe@example.com', 'takumi_w', '1234', '1991-04-21', 'male', 'japan', 'English learning is fun and exciting.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'advanced', ARRAY['gaming','reading','travel']),
('Aya Mori', 'aya.mori@example.com', 'aya_m', '1234', '1997-08-13', 'female', 'japan', 'I enjoy learning English with friends.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'proficient', ARRAY['music','travel','writing']);


-- -----------------------------
-- Learners Batch 3
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Liam White', 'liam.white@example.com', 'liam_w', '1234', '1992-02-18', 'male', 'usa', 'I want to practice Japanese daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['anime','music','travel']),
('Olivia King', 'olivia.king@example.com', 'olivia_k', '1234', '1995-06-28', 'female', 'usa', 'Learning Japanese to enjoy Japanese media.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['reading','movies','gaming']),
('Noah Scott', 'noah.scott@example.com', 'noah_s', '1234', '1990-09-10', 'male', 'usa', 'Interested in Japanese culture and language.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['travel','music','sports']),
('Sophia Adams', 'sophia.adams@example.com', 'sophia_a', '1234', '1998-01-15', 'female', 'usa', 'Learning Japanese to communicate with friends.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['anime','reading','travel']),
('Ethan Clark', 'ethan.clark@example.com', 'ethan_c', '1234', '1993-05-20', 'male', 'usa', 'Passionate about Japanese language learning.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['gaming','travel','movies']),
('Mia Turner', 'mia.turner@example.com', 'mia_t', '1234', '1996-03-03', 'female', 'usa', 'I enjoy learning Japanese daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['music','writing','travel']),
('Lucas Evans', 'lucas.evans@example.com', 'lucas_e', '1234', '1991-07-27', 'male', 'usa', 'Learning Japanese for professional purposes.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['reading','movies','sports']),
('Ava Baker', 'ava.baker@example.com', 'ava_b', '1234', '1994-11-19', 'female', 'usa', 'Practicing Japanese to travel and meet people.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['travel','gaming','music']),
('James Carter', 'james.carter@example.com', 'james_c', '1234', '1990-08-23', 'male', 'usa', 'I want to master Japanese language skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['reading','travel','anime']),
('Charlotte Nelson', 'charlotte.nelson@example.com', 'charlotte_n', '1234', '1997-12-01', 'female', 'usa', 'Learning Japanese for fun and culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['music','travel','reading']);


-- -----------------------------
-- Instructors Batch 1 (English)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('William Johnson', 'william.johnson@example.com', 'will', '1234', '1980-03-12', 'male', 'usa', 'Experienced English instructor passionate about teaching.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 10),
('Olivia Smith', 'olivia.smith@example.com', 'olivia_s', '1234', '1985-07-25', 'female', 'usa', 'Helping learners improve their English skills daily.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 8),
('James Davis', 'james.davis@example.com', 'james_d', '1234', '1978-11-02', 'male', 'usa', 'English language coach with 15 years experience.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 15),
('Sophia Miller', 'sophia.miller@example.com', 'sophia_m', '1234', '1982-06-15', 'female', 'usa', 'Passionate about teaching English to learners worldwide.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 12),
('Benjamin Wilson', 'benjamin.wilson@example.com', 'benjamin_w', '1234', '1987-01-30', 'male', 'usa', 'Focused on practical English and communication skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 7);


-- -----------------------------
-- Instructors Batch 2 (Japanese)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('Hiroshi Tanaka', 'hiroshi.tanaka@example.com', 'hiro', '1234', '1979-05-22', 'male', 'japan', 'Japanese instructor with passion for teaching foreign learners.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 12),
('Emiko Sato', 'emiko.sato@example.com', 'emiko_s', '1234', '1983-11-11', 'female', 'japan', 'Helping students understand Japanese language and culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 10),
('Takeshi Yamamoto', 'takeshi.yamamoto@example.com', 'takeshi_y', '1234', '1975-03-14', 'male', 'japan', 'Experienced in teaching Japanese to English speakers.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 15),
('Yuki Nakamura', 'yuki.nakamura@example.com', 'yuki_n', '1234', '1982-07-30', 'female', 'japan', 'Passionate about Japanese language education.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 11),
('Kenta Suzuki', 'kenta.suzuki@example.com', 'kenta_s', '1234', '1988-01-25', 'male', 'japan', 'Teaching Japanese with focus on culture and communication.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 9);


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
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='bob_s')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT id FROM learner_map WHERE username='bob_s'), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT id FROM learner_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='david_l')),
((SELECT id FROM learner_map WHERE username='david_l'), (SELECT id FROM learner_map WHERE username='emma_w')),
((SELECT id FROM learner_map WHERE username='frank_t'), (SELECT id FROM learner_map WHERE username='grace_m')),
((SELECT id FROM learner_map WHERE username='henry_b'), (SELECT id FROM learner_map WHERE username='isabella_g')),
((SELECT id FROM learner_map WHERE username='jack_w'), (SELECT id FROM learner_map WHERE username='ali')),

-- Japanese native learners following each other
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM learner_map WHERE username='emiko_s')),
((SELECT id FROM learner_map WHERE username='hiroshi_y'), (SELECT id FROM learner_map WHERE username='yuki_n')),
((SELECT id FROM learner_map WHERE username='kenta_s'), (SELECT id FROM learner_map WHERE username='miyuki_k')),
((SELECT id FROM learner_map WHERE username='ryo_t'), (SELECT id FROM learner_map WHERE username='sakura_i')),
((SELECT id FROM learner_map WHERE username='takumi_w'), (SELECT id FROM learner_map WHERE username='aya_m')),

-- Cross-group follower relationships for demonstration
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM learner_map WHERE username='ali')),
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
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
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
-- Chat 1 messages between ali and aki
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='ali')), (SELECT id FROM learner_map WHERE username='ali'), 'Hi Akira! How are your Japanese lessons going?', 'text', 'read'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='ali')), (SELECT id FROM learner_map WHERE username='aki'), 'Hi Alice! They are going well, thank you. How is your English practice?', 'text', 'read'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='ali')), (SELECT id FROM learner_map WHERE username='ali'), 'Pretty good! I practiced reading a Japanese article today.', 'text', 'unread'),
((SELECT id FROM chat_map WHERE user1_id=(SELECT id FROM learner_map WHERE username='ali')), (SELECT id FROM learner_map WHERE username='aki'), 'That’s great! Keep it up!', 'text', 'unread'),

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
((SELECT id FROM learner_map WHERE username='ali'), 'Practiced writing kanji today! Feeling more confident.'),
((SELECT id FROM learner_map WHERE username='aki'), 'Learned some new English idioms today. Exciting!'),
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
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='ali')), 'https://images.unsplash.com/photo-1601050690224-6a8d1f7f8a99', 1),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='ali')), 'https://images.unsplash.com/photo-1581090700227-6b9c2c0b8d76', 2),

-- Akira's feed images
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='aki')), 'https://images.unsplash.com/photo-1567016548540-08c4fc00df22', 1),

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
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='ali')), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='ali')), (SELECT id FROM learner_map WHERE username='bob_s')),

-- Likes on Akira's post
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='aki')), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='aki')), (SELECT id FROM learner_map WHERE username='emiko_s'));


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
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='ali')), (SELECT id FROM learner_map WHERE username='aki'), 'Wow Alice! Your kanji is improving quickly!'),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='ali')), (SELECT id FROM learner_map WHERE username='bob_s'), 'Great work! Keep practicing.'),

-- Comments on Akira's post
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='aki')), (SELECT id FROM learner_map WHERE username='ali'), 'Interesting idioms! Can you share some examples?'),
((SELECT id FROM feed_map WHERE learner_id=(SELECT id FROM learners WHERE username='aki')), (SELECT id FROM learner_map WHERE username='emiko_s'), 'I love learning idioms too!');


-- -----------------------------
-- Courses
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO courses (instructor_id, title, description, language, level, total_sessions, price, thumbnail_url, start_date, end_date, status)
VALUES
-- Demo English course (William Johnson)
((SELECT id FROM instructor_map WHERE username='will'), 'English Mastery 101', 'Learn basic to advanced English in a structured course.', 'english', 'beginner', 5, 49.99, 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f', '2025-08-01', '2025-08-31', 'active'),

-- Demo Japanese course (Hiroshi Tanaka)
((SELECT id FROM instructor_map WHERE username='hiro'), 'Japanese for Beginners', '初心者向けの日本語コースです。ひらがな、カタカナ、基本的な文法と会話を学びます。日本文化も一緒に学べます。', 'japanese', 'beginner', 5, 59.99, 'https://images.unsplash.com/photo-1528164344705-47542687000d', '2025-06-01', '2025-06-30', 'active'),

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
-- Sessions for English Mastery 101 (ACTIVE course: mix of completed and upcoming sessions)
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 1: Greetings', 'Learn basic English greetings', '2025-08-02', '10:00', '1h', 'https://zoom.us/j/123456', '1111', 'zoom'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 2: Introductions', 'How to introduce yourself in English', '2025-08-05', '10:00', '1h', 'https://meet.google.com/abc-defg-hij', '2222', 'meet'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 3: Numbers', 'Learn numbers and counting in English', '2025-08-08', '10:00', '1h', 'https://zoom.us/j/654321', '3333', 'zoom'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 4: Days & Months', 'Learn days of the week and months', '2025-08-26', '10:00', '1h', 'https://meet.google.com/xyz-uvw-rst', '4444', 'meet'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), 'Session 5: Review', 'Review all lessons', '2025-08-29', '10:00', '1h', 'https://zoom.us/j/789012', '5555', 'zoom'),

-- Sessions for Japanese for Beginners
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 1: Hiragana', 'ひらがなの紹介。基本的な読み方と書き方を学びます。', '2025-09-02', '15:00', '1h', 'https://zoom.us/j/223344', '1111', 'zoom'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 2: Katakana', 'カタカナ文字を学びます。外来語の読み方も練習します。', '2025-09-05', '15:00', '1h', 'https://meet.google.com/def-ghi-jkl', '2222', 'meet'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 3: Basic Phrases', '日常会話で使える基本的なフレーズを学習します。', '2025-09-08', '15:00', '1h', 'https://zoom.us/j/334455', '3333', 'zoom'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 4: Numbers', '日本語の数字の数え方を学びます。お金や時間の表現も含みます。', '2025-09-12', '15:00', '1h', 'https://meet.google.com/mno-pqr-stu', '4444', 'meet'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Session 5: Review', '今まで学んだことの復習をします。質問も大歓迎です。', '2025-09-15', '15:00', '1h', 'https://zoom.us/j/445566', '5555', 'zoom');




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
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Recorded Session 1: Hiragana', 'ひらがなレッスンの録画ビデオです。何度でも復習できます。', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Recorded Session 2: Katakana', 'カタカナレッスンの録画ビデオです。発音練習も含まれています。', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Recorded Session 3: Basic Phrases', '基本フレーズレッスンの録画です。実用的な表現を学べます。', 'https://www.youtube.com/watch?v=E6588DlZW-c'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Recorded Session 4: Numbers', '数字レッスンの録画ビデオです。買い物で使える表現も学習します。', 'https://www.youtube.com/watch?v=E6588DlZW-c');



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
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Hiragana PDF', 'ひらがな学習用PDFガイド。書き順と練習シート付き。', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_pdf.pdf', 'pdf'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Katakana Doc', 'カタカナ学習用ドキュメント。外来語リスト付き。', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_doc.docx', 'document'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'Numbers Image', '数字練習用の画像教材。視覚的に覚えやすい構成です。', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/study_material/default_image.png', 'image');



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
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='bob_s')),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='carol_d')),

((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='aki')),
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
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'Hello everyone! Excited for this course.'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM learner_map WHERE username='bob_s'), 'learner', 'Hi Alice! Let’s practice together.'),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Welcome everyone! I will guide you through the lessons.'),

-- Japanese for Beginners group chat
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'Hello Hiroshi-sensei! Looking forward to learning Japanese.'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='emiko_s'), 'learner', 'Hi Akira! Let’s study together.'),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', 'コースへようこそ！日本語の学習を楽しんでいただけると嬉しいです。何か質問があればいつでもお聞きください。');



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
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'Great teaching! Very clear explanations.', 5),
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='bob_s'), 'learner', 'Loved the exercises and examples.', 4),

-- Instructor feedback for English course
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='ali'), 'instructor', 'Alice participates actively and asks good questions.', 5),

-- Course feedback
((SELECT id FROM course_map WHERE title='English Mastery 101'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='bob_s'), 'course', 'The course content is structured and useful.', 5),

-- Learner feedback for Japanese course
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM instructor_map WHERE username='hiro'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', '先生の説明がとても分かりやすくて、忍耐強く教えてくださいます。', 5),
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM instructor_map WHERE username='hiro'), (SELECT id FROM learner_map WHERE username='emiko_s'), 'learner', '練習問題がたくさんあって、とても勉強になりました。', 4);


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
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM course_map WHERE title='English Mastery 101'), 'session alert', 'Session Reminder', 'Don’t forget Session 1 starts tomorrow at 10:00 AM.', FALSE),
((SELECT id FROM learner_map WHERE username='bob_s'), (SELECT id FROM course_map WHERE title='English Mastery 101'), 'feedback', 'New Feedback', 'You received new feedback from your instructor.', TRUE),

-- Japanese course notifications
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'session alert', 'Session Reminder', 'Session 1 will start on 2nd September at 15:00.', FALSE),
((SELECT id FROM learner_map WHERE username='emiko_s'), (SELECT id FROM course_map WHERE title='Japanese for Beginners'), 'feedback', 'New Feedback', 'You received new feedback from your instructor.', TRUE);



-- -----------------------------
-- Withdrawals
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO withdrawal (instructor_id, amount, status)
VALUES
((SELECT id FROM instructor_map WHERE username='will'), 50.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='will'), 20.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='hiro'), 60.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='hiro'), 10.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='olivia_s'), 30.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='james_d'), 40.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='sophia_m'), 20.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='benjamin_w'), 30.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='emiko_s'), 22.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='takeshi_y'), 54.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='yuki_n'), 38.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='kenta_s'), 25.00, 'COMPLETED');


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
((SELECT id FROM withdrawal_map WHERE username='will' LIMIT 1), 'CARD', '1234567812345678', '12/2028', '123', 'William Johnson', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='olivia_s'), 'CARD', '8765432187654321', '06/2027', '456', 'Olivia Smith', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='sophia_m'), 'CARD', '5555444433332222', '09/2029', '789', 'Sophia Miller', NULL, NULL, NULL, NULL),

-- PayPal payments
((SELECT id FROM withdrawal_map WHERE username='hiro' LIMIT 1), 'PAYPAL', NULL, NULL, NULL, NULL, 'hiroshi.tanaka@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='james_d'), 'PAYPAL', NULL, NULL, NULL, NULL, 'james.davis@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='emiko_s'), 'PAYPAL', NULL, NULL, NULL, NULL, 'emiko.sato@example.com', NULL, NULL, NULL),

-- Bank transfers
((SELECT id FROM withdrawal_map WHERE username='benjamin_w'), 'BANK', NULL, NULL, NULL, NULL, NULL, '1234567890', 'Chase Bank', 'CHASUS33'),
((SELECT id FROM withdrawal_map WHERE username='takeshi_y'), 'BANK', NULL, NULL, NULL, NULL, NULL, '9876543210', 'MUFG Bank', 'BOTKJPJT'),
((SELECT id FROM withdrawal_map WHERE username='yuki_n'), 'BANK', NULL, NULL, NULL, NULL, NULL, '5555666677', 'Sumitomo Bank', 'SMBCJPJT'),
((SELECT id FROM withdrawal_map WHERE username='kenta_s'), 'BANK', NULL, NULL, NULL, NULL, NULL, '3333444455', 'Mizuho Bank', 'MHCBJPJT');

-- -----------------------------
-- Additional Withdrawal Info for Missing First Batch Withdrawals  
-- -----------------------------
WITH withdrawal_map AS (
    SELECT w.id, i.username, w.amount
    FROM withdrawal w
    JOIN instructors i ON w.instructor_id = i.id
    WHERE i.username IN ('will', 'hiro')
    ORDER BY w.id
    OFFSET 1  -- Skip the first withdrawal (already has info)
)
INSERT INTO withdrawal_info (withdrawal_id, payment_method, card_number, expiry_date, cvv, card_holder_name, paypal_email, bank_account_number, bank_name, swift_code)
VALUES
-- Second withdrawal for will (20.00)
((SELECT id FROM withdrawal_map WHERE username='will' LIMIT 1), 'PAYPAL', NULL, NULL, NULL, NULL, 'william.johnson.secondary@example.com', NULL, NULL, NULL),
-- Second withdrawal for hiro (10.00)  
((SELECT id FROM withdrawal_map WHERE username='hiro' LIMIT 1), 'BANK', NULL, NULL, NULL, NULL, NULL, '8888999900', 'Mizuho Bank', 'MHCBJPJT');


-- ========================================
-- ADDITIONAL LEARNERS (Part 2)
-- ========================================

-- -----------------------------
-- Additional Japanese learners (Batch 4)
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Kenji Watanabe', 'kenji.watanabe@example.com', 'kenji_w', '1234', '1996-02-12', 'male', 'japan', 'I want to improve my English for international business.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'beginner', ARRAY['business','travel','technology']),
('Haruka Okamoto', 'haruka.okamoto@example.com', 'haruka_o', '1234', '1994-08-25', 'female', 'japan', 'Learning English to study abroad next year.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'elementary', ARRAY['studying','books','music']),
('Daiki Ishikawa', 'daiki.ishikawa@example.com', 'daiki_i', '1234', '1991-11-30', 'male', 'japan', 'English is essential for my tech career.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'intermediate', ARRAY['programming','gaming','anime']),
('Nanami Hayashi', 'nanami.hayashi@example.com', 'nanami_h', '1234', '1998-04-18', 'female', 'japan', 'I love American movies and want to understand them without subtitles.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'advanced', ARRAY['movies','culture','photography']),
('Sho Matsumoto', 'sho.matsumoto@example.com', 'sho_m', '1234', '1993-09-07', 'male', 'japan', 'Practicing English for my dream to work in Silicon Valley.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'proficient', ARRAY['technology','innovation','travel']);

-- -----------------------------
-- Additional English learners (Batch 4)
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Ryan Thompson', 'ryan.thompson@example.com', 'ryan_t', '1234', '1995-01-20', 'male', 'usa', 'Fascinated by Japanese history and culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'beginner', ARRAY['history','martial arts','culture']),
('Madison Davis', 'madison.davis@example.com', 'madison_d', '1234', '1997-06-14', 'female', 'usa', 'Learning Japanese to teach English in Japan someday.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['teaching','travel','language exchange']),
('Tyler Rodriguez', 'tyler.rodriguez@example.com', 'tyler_r', '1234', '1992-03-08', 'male', 'usa', 'Japanese language helps me understand anime and manga better.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'intermediate', ARRAY['anime','manga','art']),
('Paige Wilson', 'paige.wilson@example.com', 'paige_w', '1234', '1990-12-22', 'female', 'usa', 'I want to connect with Japanese friends and learn their culture.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['friendship','culture','cooking']),
('Brandon Miller', 'brandon.miller@example.com', 'brandon_m', '1234', '1996-07-11', 'male', 'usa', 'Japanese business culture interests me greatly.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'proficient', ARRAY['business','culture','economics']);

-- -----------------------------
-- Additional Mixed Language Learners (Batch 5)
-- -----------------------------
INSERT INTO learners (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, learning_language, language_level, interests)
VALUES
('Yuka Taniguchi', 'yuka.taniguchi@example.com', 'yuka_t', '1234', '1995-05-03', 'female', 'japan', 'Studying English literature and poetry.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'beginner', ARRAY['literature','poetry','writing']),
('Austin Lee', 'austin.lee@example.com', 'austin_l', '1234', '1994-10-16', 'male', 'usa', 'Learning Japanese to understand traditional arts.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'elementary', ARRAY['traditional arts','meditation','philosophy']),
('Ami Fujiwara', 'ami.fujiwara@example.com', 'ami_f', '1234', '1999-01-29', 'female', 'japan', 'English opens doors to global opportunities.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'intermediate', ARRAY['global culture','travel','food']),
('Caleb Johnson', 'caleb.johnson@example.com', 'caleb_j', '1234', '1991-08-05', 'male', 'usa', 'Japanese video games inspired my language learning journey.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'japanese', 'advanced', ARRAY['video games','technology','programming']),
('Rei Kimura', 'rei.kimura@example.com', 'rei_k', '1234', '1993-12-13', 'female', 'japan', 'I love English music and want to understand lyrics perfectly.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'english', 'proficient', ARRAY['music','concerts','singing']);


-- ========================================
-- ADDITIONAL INSTRUCTORS
-- ========================================

-- -----------------------------
-- Additional English Instructors (Batch 3)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('Michael Brown', 'michael.brown@example.com', 'michael_b', '1234', '1976-04-22', 'male', 'usa', 'Specialist in business English and professional communication.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 18),
('Jennifer Taylor', 'jennifer.taylor@example.com', 'jennifer_t', '1234', '1984-09-18', 'female', 'usa', 'Expert in English literature and creative writing.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 11),
('Robert Garcia', 'robert.garcia@example.com', 'robert_g', '1234', '1979-12-07', 'male', 'usa', 'Helping students master English pronunciation and speaking.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 14),
('Emily Anderson', 'emily.anderson@example.com', 'emily_a', '1234', '1981-06-25', 'female', 'usa', 'Passionate about teaching English to international students.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 13),
('Daniel Wilson', 'daniel.wilson@example.com', 'daniel_w', '1234', '1985-02-14', 'male', 'usa', 'Focused on conversational English and cultural exchange.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'english', 'english', 9);

-- -----------------------------
-- Additional Japanese Instructors (Batch 3)
-- -----------------------------
INSERT INTO instructors (name, email, username, password, date_of_birth, gender, country, bio, profile_image, native_language, teaching_language, years_of_experience)
VALUES
('Satoshi Nakamura', 'satoshi.nakamura@example.com', 'satoshi_n', '1234', '1977-08-30', 'male', 'japan', 'Traditional Japanese language and culture specialist.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 16),
('Akiko Yamada', 'akiko.yamada@example.com', 'akiko_y', '1234', '1980-11-15', 'female', 'japan', 'Expert in Japanese writing systems and calligraphy.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 14),
('Masaki Sato', 'masaki.sato@example.com', 'masaki_s', '1234', '1982-03-28', 'male', 'japan', 'Business Japanese and professional communication expert.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 12),
('Yumiko Takahashi', 'yumiko.takahashi@example.com', 'yumiko_t', '1234', '1986-07-09', 'female', 'japan', 'Making Japanese language learning fun and engaging.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 8),
('Tetsuya Kobayashi', 'tetsuya.kobayashi@example.com', 'tetsuya_k', '1234', '1983-01-12', 'male', 'japan', 'Specialist in Japanese grammar and conversation skills.', 'https://grunwttngjfnwfzlgopi.supabase.co/storage/v1/object/public/profile_pics/default_profile_image.png', 'japanese', 'japanese', 10);
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
((SELECT id FROM learner_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT id FROM learner_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='bob_s')),
((SELECT id FROM learner_map WHERE username='daiki_i'), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT id FROM learner_map WHERE username='nanami_h'), (SELECT id FROM learner_map WHERE username='david_l')),
((SELECT id FROM learner_map WHERE username='sho_m'), (SELECT id FROM learner_map WHERE username='emma_w')),

-- English learners following Japanese learners
((SELECT id FROM learner_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='aki')),
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
((SELECT id FROM feed_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT id FROM feed_map WHERE username='kenji_w'), (SELECT id FROM learner_map WHERE username='madison_d')),

((SELECT id FROM feed_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='madison_d')),
((SELECT id FROM feed_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT id FROM feed_map WHERE username='haruka_o'), (SELECT id FROM learner_map WHERE username='yuka_t')),

((SELECT id FROM feed_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='kenji_w')),
((SELECT id FROM feed_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='aki')),
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
((SELECT id FROM feed_map WHERE username='ryan_t'), (SELECT id FROM learner_map WHERE username='aki'), 'Your dedication is inspiring! 漢字を覚えるのは大変ですが、面白いです。', 'Your dedication is inspiring! Learning kanji is difficult but interesting.'),

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

((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM learner_map WHERE username='aki')),
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
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'Thank you! I really want to improve my pronunciation.'),
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
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM instructor_map WHERE username='robert_g'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'My pronunciation has improved dramatically! Thank you!', 5),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM instructor_map WHERE username='robert_g'), (SELECT id FROM learner_map WHERE username='emiko_s'), 'learner', 'The IPA chart explanation was very clear and helpful.', 4),
((SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), (SELECT id FROM instructor_map WHERE username='robert_g'), (SELECT id FROM learner_map WHERE username='aki'), 'instructor', 'Akira is very dedicated and practices regularly. Great progress!', 5),

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
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM course_map WHERE title='English Pronunciation Clinic'), 'feedback', 'New Feedback', 'Your pronunciation has improved significantly!', TRUE),
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
((SELECT id FROM instructor_map WHERE username='will'), 1.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='olivia_s'), 8.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='james_d'), 3.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='sophia_m'), 2.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='benjamin_w'), 31.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='hiro'), 4.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='emiko_s'), 19.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='takeshi_y'), 3.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='yuki_n'), 20.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='kenta_s'), 5.00, 'COMPLETED');


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
((SELECT id FROM withdrawal_map WHERE username='will' AND amount=350.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '9999000011', 'US Bank', 'USBKUS44'),
((SELECT id FROM withdrawal_map WHERE username='olivia_s' AND amount=280.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'olivia.smith.instructor@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='james_d' AND amount=390.00), 'CARD', '1111222233334444', '12/2028', '789', 'James Davis', NULL, NULL, NULL, NULL);

-- -----------------------------
-- Withdrawal Info for Small Amount Withdrawals (Second Batch)
-- -----------------------------
WITH withdrawal_map AS (
    SELECT w.id, i.username, w.amount
    FROM withdrawal w
    JOIN instructors i ON w.instructor_id = i.id
    WHERE w.amount IN (1.00, 8.00, 3.00, 2.00, 31.00, 4.00, 19.00, 20.00, 5.00)
)
INSERT INTO withdrawal_info (withdrawal_id, payment_method, card_number, expiry_date, cvv, card_holder_name, paypal_email, bank_account_number, bank_name, swift_code)
VALUES
-- Small withdrawals for existing instructors
((SELECT id FROM withdrawal_map WHERE username='will' AND amount=1.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'william.j.micro@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='olivia_s' AND amount=8.00), 'CARD', '2222333344445555', '04/2028', '456', 'Olivia Smith', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='james_d' AND amount=3.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'james.d.micro@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='sophia_m' AND amount=2.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '1111000022', 'Wells Fargo', 'WFBIUS6S'),
((SELECT id FROM withdrawal_map WHERE username='benjamin_w' AND amount=31.00), 'CARD', '3333444455556666', '09/2029', '123', 'Benjamin Wilson', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='hiro' AND amount=4.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'hiroshi.t.micro@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='emiko_s' AND amount=19.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '4444555566', 'Sumitomo Bank', 'SMBCJPJT'),
((SELECT id FROM withdrawal_map WHERE username='takeshi_y' AND amount=3.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'takeshi.y.micro@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='yuki_n' AND amount=20.00), 'CARD', '5555666677778888', '11/2030', '789', 'Yuki Nakamura', NULL, NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='kenta_s' AND amount=5.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '6666777788', 'Mizuho Bank', 'MHCBJPJT');


-- ========================================
-- ADDITIONAL FOCUSED DUMMY DATA
-- ========================================
-- Generated for specific accounts:
-- ali (English → Japanese learner)
-- aki (Japanese → English learner)  
-- will (English instructor)
-- hiro (Japanese instructor)
-- ========================================

-- -----------------------------
-- BATCH 1: Additional Followers for ali and aki
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO followers (follower_user_id, followed_user_id)
VALUES
-- ali following more learners
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='david_l')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='emma_w')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='grace_m')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='henry_b')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='yuki_k')),

-- aki following more learners
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM learner_map WHERE username='bob_s')),
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM learner_map WHERE username='frank_t')),
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM learner_map WHERE username='isabella_g')),
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM learner_map WHERE username='jack_w')),

-- More learners following ali
((SELECT id FROM learner_map WHERE username='david_l'), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT id FROM learner_map WHERE username='emma_w'), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT id FROM learner_map WHERE username='frank_t'), (SELECT id FROM learner_map WHERE username='ali')),

-- More learners following aki
((SELECT id FROM learner_map WHERE username='bob_s'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='carol_d'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='grace_m'), (SELECT id FROM learner_map WHERE username='aki'));

-- -----------------------------
-- BATCH 2: Additional Chats between ali and aki
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO chats (user1_id, user2_id)
VALUES
-- 10 new chats between ali and aki
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM learner_map WHERE username='aki'));

-- -----------------------------
-- BATCH 3: Messages for New Chats (Chat Topics: Language Learning)
-- -----------------------------
WITH chat_map AS (
    SELECT c.id as chat_id, l1.id as user1_id, l2.id as user2_id, l1.username as user1_name, l2.username as user2_name
    FROM chats c
    JOIN learners l1 ON c.user1_id = l1.id
    JOIN learners l2 ON c.user2_id = l2.id
    WHERE (l1.username = 'ali' AND l2.username = 'aki') 
       OR (l1.username = 'aki' AND l2.username = 'ali')
    ORDER BY c.id DESC
    LIMIT 15
)
INSERT INTO messages (chat_id, sender_id, content_text, type, status)
VALUES
-- Chat 1: Grammar Discussion
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 0), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 0), 'Hi Akira! I''m struggling with Japanese particles. Can you help explain the difference between は and が?', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 0), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 0), 'Hello Alice! Great question. は is the topic marker while が is the subject marker. For example: 私は学生です (I am a student - topic) vs 誰が来ましたか？(Who came? - subject)', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 0), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 0), 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c', 'image', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 0), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 0), 'Nice example! Your handwriting is getting better. Try practicing more kanji stroke order.', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 0), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 0), 'Thank you! By the way, how do you say "language exchange" in Japanese?', 'text', 'unread'),

-- Chat 2: Cultural Exchange
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 1), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 1), 'Alice, what''s your favorite American holiday? I want to learn more about Western culture.', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 1), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 1), 'I love Thanksgiving! It''s about gratitude and family. What about Japanese festivals? I''m curious about Hanami.', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 1), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 1), 'Hanami is beautiful! We view cherry blossoms and have picnics. Here''s a photo from last spring:', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 1), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 1), 'https://images.unsplash.com/photo-1522383225653-ed111181a951', 'image', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 1), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 1), 'Wow! So beautiful! I really want to visit Japan during cherry blossom season.', 'text', 'read'),

-- Chat 3: Pronunciation Help
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 2), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 2), 'Akira, I recorded myself saying some Japanese words. Can you correct my pronunciation?', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 2), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 2), 'Of course! Send me the audio. Also, can you help me with English "th" sound? It''s very difficult.', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 2), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 2), 'Sure! Put your tongue between your teeth for "th". Try "think" and "this". The difference is voicing.', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 2), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 2), 'Think... this... think... this... Am I doing it right?', 'text', 'read'),

-- Chat 4: Daily Conversation Practice
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 3), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 3), '今日は何をしましたか？(What did you do today?)', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 3), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 3), '今日は日本語を勉強しました。映画も見ました。(Today I studied Japanese. I also watched a movie.)', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 3), (SELECT user2_id FROM chat_map LIMIT 1 OFFSET 3), 'Great sentence! What movie did you watch? In English please, I need practice.', 'text', 'read'),
((SELECT chat_id FROM chat_map LIMIT 1 OFFSET 3), (SELECT user1_id FROM chat_map LIMIT 1 OFFSET 3), 'I watched "Your Name" (Kimi no Na wa). It''s a beautiful Japanese animated film. Have you seen it?', 'text', 'unread');

-- -----------------------------
-- BATCH 4: Additional Feed Posts for ali
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO feed (learner_id, content_text)
VALUES
-- ali's feed posts about Japanese learning journey
((SELECT id FROM learner_map WHERE username='ali'), 'Just learned 50 new kanji characters today! 漢字の勉強は難しいですが、楽しいです。(Kanji study is difficult but fun!) #JapaneseLearning #Kanji'),
((SELECT id FROM learner_map WHERE username='ali'), 'Tried making ramen from scratch today while practicing Japanese cooking vocabulary. 美味しかった！(It was delicious!) Who else loves learning through cooking? 🍜'),
((SELECT id FROM learner_map WHERE username='ali'), 'Reading my first Japanese manga without furigana! Progress feels slow but every page is an achievement. Currently reading よつばと！#Manga #JapaneseReading'),
((SELECT id FROM learner_map WHERE username='ali'), 'Had my first conversation entirely in Japanese with Akira today! Made some mistakes but we understood each other. Language exchange is amazing! 🗣️'),
((SELECT id FROM learner_map WHERE username='ali'), 'Discovered J-pop and now I''m learning Japanese through music. Lyrics help with pronunciation and new vocabulary. Current favorite: あいみょん #Jpop #LanguageLearning'),
((SELECT id FROM learner_map WHERE username='ali'), 'Watched Studio Ghibli''s "Spirited Away" in Japanese without subtitles. Understood about 60%! Small victories count. 千と千尋の神隠し is beautiful in any language ✨'),
((SELECT id FROM learner_map WHERE username='ali'), 'Learning about Japanese business etiquette for my future trip to Tokyo. The concept of お疲れ様 (otsukaresama) is so thoughtful. American culture could learn from this!'),
((SELECT id FROM learner_map WHERE username='ali'), 'Practiced writing with a calligraphy brush today. My handwriting looks like a child''s but it''s meditative. Japanese culture values the process, not just results 🎨'),
((SELECT id FROM learner_map WHERE username='ali'), 'Question for my Japanese learning friends: How do you remember the difference between similar-looking kanji? 日 vs 目 still trips me up sometimes! Tips welcome 🤔'),
((SELECT id FROM learner_map WHERE username='ali'), 'Made Japanese curry while watching Japanese cooking shows. Immersion works! Learning food vocabulary while satisfying my appetite. Win-win! 🍛 #JapaneseCooking');

-- -----------------------------
-- BATCH 5: Additional Feed Posts for aki
-- -----------------------------
WITH learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO feed (learner_id, content_text)
VALUES
-- aki's feed posts about English learning journey
((SELECT id FROM learner_map WHERE username='aki'), 'English idioms are fascinating but confusing! "It''s raining cats and dogs" doesn''t make literal sense but I love the imagery. What''s your favorite idiom? 🐱🐶'),
((SELECT id FROM learner_map WHERE username='aki'), 'Watched "Friends" for the 10th time and finally understanding all the jokes! Sitcoms are great for learning natural conversation patterns. Could I BE any more excited? 😄'),
((SELECT id FROM learner_map WHERE username='aki'), 'American coffee culture is so different from Japanese tea ceremony. Learning about cultural context helps me understand why Americans say "Let''s grab coffee" for meetings ☕'),
((SELECT id FROM learner_map WHERE username='aki'), 'Reading Harry Potter in English! Currently on Chamber of Secrets. The vocabulary is challenging but the story keeps me motivated. Magic helps with language learning too! ⚡'),
((SELECT id FROM learner_map WHERE username='aki'), 'Practiced English presentations today. Public speaking in your second language is terrifying but rewarding. Small steps toward my dream of studying abroad! 🎓'),
((SELECT id FROM learner_map WHERE username='aki'), 'Learning English through cooking shows helped me understand measurements and cooking verbs. "Whisk," "sauté," "simmer" - culinary English is its own language! 👨‍🍳'),
((SELECT id FROM learner_map WHERE username='aki'), 'Had a video call with Alice practicing English conversation. She helps me with pronunciation while I teach her Japanese. Language exchange partnerships are the best! 🤝'),
((SELECT id FROM learner_map WHERE username='aki'), 'Discovered English podcasts about technology. Perfect for learning professional vocabulary for my IT career. "Debug," "deploy," "scalable" - tech English is everywhere! 💻'),
((SELECT id FROM learner_map WHERE username='aki'), 'American humor is tricky! Sarcasm doesn''t translate well from Japanese culture. Learning when someone is joking vs. serious takes practice. Context is everything! 😅'),
((SELECT id FROM learner_map WHERE username='aki'), 'Writing my first English blog about Japanese culture for language exchange. Explaining concepts like "omotenashi" (hospitality) in English helps me understand both cultures better 🌸');

-- -----------------------------
-- BATCH 6: Feed Images for New Posts
-- -----------------------------
WITH feed_map AS (
    SELECT f.id as feed_id, l.username
    FROM feed f 
    JOIN learners l ON f.learner_id = l.id 
    WHERE l.username IN ('ali', 'aki')
    ORDER BY f.id DESC 
    LIMIT 20
)
INSERT INTO feed_images (feed_id, image_url, position)
VALUES
-- Images for ali's posts
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), 'https://images.unsplash.com/photo-1528164344705-47542687000d', 1),
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b', 2),

((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1', 1),
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), 'https://images.unsplash.com/photo-1617093727343-374698b1b08d', 2),
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), 'https://images.unsplash.com/photo-1606491956689-2ea866880c84', 3),

((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', 1),
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c', 2),

((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d', 1),

((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 4), 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f', 1),
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 4), 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b', 2),

((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 5), 'https://images.unsplash.com/photo-1522383225653-ed111181a951', 1),
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 5), 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', 2),

((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 7), 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c', 1),
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 7), 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', 2),
((SELECT feed_id FROM feed_map WHERE username='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 7), 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b', 3),

-- Images for aki's posts
((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d', 1),
((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), 'https://images.unsplash.com/photo-1516321497487-e288fb19713f', 2),

((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), 'https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85', 1),

((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b', 1),
((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), 'https://images.unsplash.com/photo-1516321497487-e288fb19713f', 2),

((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d', 1),
((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), 'https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85', 2),
((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), 'https://images.unsplash.com/photo-1516321497487-e288fb19713f', 3),

((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 5), 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1', 1),
((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 5), 'https://images.unsplash.com/photo-1617093727343-374698b1b08d', 2),

((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 7), 'https://images.unsplash.com/photo-1516321497487-e288fb19713f', 1),

((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 9), 'https://images.unsplash.com/photo-1522383225653-ed111181a951', 1),
((SELECT feed_id FROM feed_map WHERE username='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 9), 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', 2);

-- -----------------------------
-- BATCH 7: Feed Likes for New Posts
-- -----------------------------
WITH feed_map AS (
    SELECT f.id as feed_id, l.username as post_author
    FROM feed f 
    JOIN learners l ON f.learner_id = l.id 
    WHERE l.username IN ('ali', 'aki')
    ORDER BY f.id DESC 
    LIMIT 20
),
learner_map AS (
    SELECT id, username FROM learners WHERE username IN ('ali', 'aki', 'bob_s', 'carol_d', 'david_l', 'emma_w', 'frank_t', 'grace_m', 'henry_b')
)
INSERT INTO feed_likes (feed_id, learner_id)
VALUES
-- Likes on ali's posts
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='bob_s')),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='david_l')),

((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='emma_w')),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='frank_t')),

((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), (SELECT id FROM learner_map WHERE username='grace_m')),

((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='aki')),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='henry_b')),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='bob_s')),

-- Likes on aki's posts
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='carol_d')),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='david_l')),

((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='emma_w')),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='frank_t')),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='grace_m')),

((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), (SELECT id FROM learner_map WHERE username='henry_b')),

((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='ali')),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='bob_s'));

-- -----------------------------
-- BATCH 8: Feed Comments for New Posts
-- -----------------------------
WITH feed_map AS (
    SELECT f.id as feed_id, l.username as post_author
    FROM feed f 
    JOIN learners l ON f.learner_id = l.id 
    WHERE l.username IN ('ali', 'aki')
    ORDER BY f.id DESC 
    LIMIT 20
),
learner_map AS (
    SELECT id, username FROM learners WHERE username IN ('ali', 'aki', 'bob_s', 'carol_d', 'david_l', 'emma_w', 'frank_t', 'grace_m', 'henry_b')
)
INSERT INTO feed_comments (feed_id, learner_id, content_text)
VALUES
-- Comments on ali's posts
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='aki'), 'Amazing progress with kanji! Your handwriting style is really improving. Keep practicing stroke order! 頑張って！'),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='bob_s'), 'I''m also learning kanji and it''s so challenging. Which app are you using for practice?'),

((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='aki'), 'Ramen looks delicious! Japanese cooking vocabulary is great for learning. Next try making たこ焼き (takoyaki)!'),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='carol_d'), 'Learning through cooking is genius! I should try that with Spanish recipes.'),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='emma_w'), 'Recipe please! I want to practice Japanese cooking terms too.'),

((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), (SELECT id FROM learner_map WHERE username='aki'), 'よつばと is perfect for beginners! The Japanese is simple and the story is heartwarming. Great choice!'),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), (SELECT id FROM learner_map WHERE username='david_l'), 'Manga without furigana is a big step! I''m still using furigana versions.'),

((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='aki'), 'That conversation was so much fun! Your Japanese is getting really natural. Next time let''s practice keigo (polite form)!'),
((SELECT feed_id FROM feed_map WHERE post_author='ali' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='henry_b'), 'Language exchange partnerships are the best! Anyone want to practice English-Spanish with me?'),

-- Comments on aki's posts
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='ali'), 'English idioms are weird even for native speakers! "Break a leg" means "good luck" - makes no sense but we use it all the time 😄'),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 0), (SELECT id FROM learner_map WHERE username='carol_d'), 'My favorite idiom is "piece of cake" meaning something is easy. What''s a funny Japanese idiom?'),

((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='ali'), 'Friends is perfect for learning American English! The humor might be dated but the conversational patterns are great.'),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 1), (SELECT id FROM learner_map WHERE username='emma_w'), 'I learned so much English from Friends too! Ross and Rachel taught me about American dating culture 😅'),

((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), (SELECT id FROM learner_map WHERE username='ali'), 'Coffee culture is huge in America! "Let''s grab coffee" basically means "let''s talk" - doesn''t always involve actual coffee.'),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 2), (SELECT id FROM learner_map WHERE username='frank_t'), 'Cultural context is so important! What''s the Japanese equivalent of "grabbing coffee"?'),

((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='ali'), 'Harry Potter in English is challenging! The vocabulary gets more advanced in later books. Chamber of Secrets has great dialogue practice.'),
((SELECT feed_id FROM feed_map WHERE post_author='aki' ORDER BY feed_id DESC LIMIT 1 OFFSET 3), (SELECT id FROM learner_map WHERE username='bob_s'), 'Reading Harry Potter in my target language is on my bucket list! Which house would you be in?');

-- -----------------------------
-- BATCH 9: Additional Courses for will (English Instructor)
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO courses (instructor_id, title, description, language, level, total_sessions, price, thumbnail_url, start_date, end_date, status)
VALUES
-- will's additional courses
((SELECT id FROM instructor_map WHERE username='will'), 'Advanced Business English', 'Professional English for workplace communication, presentations, and networking. Perfect for career advancement in international companies.', 'english', 'advanced', 5, 89.99, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d', '2025-09-01', '2025-10-15', 'upcoming'),
((SELECT id FROM instructor_map WHERE username='will'), 'English Pronunciation Workshop', 'Master American English pronunciation, intonation, and accent reduction. Includes IPA phonetics and speaking drills.', 'english', 'intermediate', 5, 69.99, 'https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85', '2025-07-15', '2025-08-20', 'expired'),
((SELECT id FROM instructor_map WHERE username='will'), 'IELTS Preparation Intensive', 'Comprehensive IELTS test preparation covering all four skills: Reading, Writing, Listening, and Speaking with practice tests.', 'english', 'advanced', 5, 99.99, 'https://images.unsplash.com/photo-1516321497487-e288fb19713f', '2025-10-01', '2025-11-30', 'upcoming');

-- -----------------------------
-- BATCH 10: Additional Courses for hiro (Japanese Instructor)
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors
)
INSERT INTO courses (instructor_id, title, description, language, level, total_sessions, price, thumbnail_url, start_date, end_date, status)
VALUES
-- hiro's additional courses
((SELECT id FROM instructor_map WHERE username='hiro'), 'Japanese Business Communication', 'ビジネス日本語を学ぶコースです。敬語（尊敬語・謙譲語・丁寧語）、ビジネスマナー、職場でのコミュニケーションを身につけます。日本で働きたい方に最適です。', 'japanese', 'advanced', 5, 94.99, 'https://images.unsplash.com/photo-1522383225653-ed111181a951', '2025-07-15', '2025-09-15', 'active'),
((SELECT id FROM instructor_map WHERE username='hiro'), 'Kanji Master Class', '漢字を体系的に学ぶクラスです。1000の重要漢字を記憶法、筆順、実用例と共に学習します。読み書きが格段に向上します。', 'japanese', 'intermediate', 5, 79.99, 'https://images.unsplash.com/photo-1578662996442-48f60103fc96', '2025-06-15', '2025-08-15', 'expired'),
((SELECT id FROM instructor_map WHERE username='hiro'), 'Japanese Culture Through Language', '日本の文化、伝統、社会習慣を言語と一緒に学ぶコースです。バーチャル文化体験も含まれています。日本への理解が深まります。', 'japanese', 'beginner', 5, 59.99, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c', '2025-09-20', '2025-11-20', 'upcoming'),
((SELECT id FROM instructor_map WHERE username='hiro'), 'Advanced Japanese Grammar', '上級日本語文法をマスターするコースです。複雑な文法パターン、助詞、文構造を学び、流暢なコミュニケーションを目指します。', 'japanese', 'advanced', 5, 89.99, 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0', '2025-11-25', '2026-01-25', 'upcoming');

-- -----------------------------
-- BATCH 11: Course Sessions for will's New Courses
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
)
INSERT INTO course_sessions (course_id, session_name, session_description, session_date, session_time, session_duration, session_link, session_password, session_platform)
VALUES
-- Advanced Business English sessions
((SELECT id FROM course_map WHERE title='Advanced Business English'), 'Professional Email Writing', 'Learn to write effective business emails, memos, and formal correspondence with proper tone and structure.', '2025-09-03', '10:00:00', '90 minutes', 'https://zoom.us/j/business-english-session1', 'session123', 'zoom'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), 'Presentation Skills', 'Master business presentations including structure, visual aids, Q&A handling, and confident delivery.', '2025-09-10', '10:00:00', '90 minutes', 'https://zoom.us/j/business-english-session2', 'session124', 'zoom'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), 'Meeting Participation', 'Effective communication in business meetings, expressing opinions, agreeing/disagreeing professionally, and follow-up actions.', '2025-09-17', '10:00:00', '90 minutes', 'https://zoom.us/j/business-english-session3', 'session125', 'zoom'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), 'Networking and Small Talk', 'Professional networking conversations, building rapport, and maintaining business relationships through communication.', '2025-09-24', '10:00:00', '90 minutes', 'https://zoom.us/j/business-english-session4', 'session126', 'zoom'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), 'Negotiation and Conflict Resolution', 'Advanced business communication for negotiations, handling disagreements, and reaching professional solutions.', '2025-10-01', '10:00:00', '90 minutes', 'https://zoom.us/j/business-english-session5', 'session127', 'zoom'),

-- English Pronunciation Workshop sessions (COMPLETED COURSE)
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Vowel Sounds and IPA Basics', 'Introduction to International Phonetic Alphabet and mastering American English vowel sounds with mouth positioning.', '2025-07-17', '14:00:00', '75 minutes', 'https://zoom.us/j/pronunciation-workshop-session1', 'session201', 'zoom'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Consonant Clusters and Difficult Sounds', 'Master challenging consonant combinations, th-sounds, r/l distinction, and common pronunciation problems.', '2025-07-24', '14:00:00', '75 minutes', 'https://zoom.us/j/pronunciation-workshop-session2', 'session202', 'zoom'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Word Stress and Rhythm', 'Learn English stress patterns, syllable emphasis, and natural rhythm for fluent-sounding speech.', '2025-07-31', '14:00:00', '75 minutes', 'https://zoom.us/j/pronunciation-workshop-session3', 'session203', 'zoom'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Intonation and Connected Speech', 'Master rising and falling intonation patterns, linking words, and natural connected speech patterns.', '2025-08-07', '14:00:00', '75 minutes', 'https://zoom.us/j/pronunciation-workshop-session4', 'session204', 'zoom'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Accent Reduction Practice', 'Intensive practice sessions with personalized feedback to reduce native language interference and sound more natural.', '2025-08-14', '14:00:00', '75 minutes', 'https://zoom.us/j/pronunciation-workshop-session5', 'session205', 'zoom'),

-- IELTS Preparation Intensive sessions
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), 'IELTS Overview and Reading Strategies', 'Complete IELTS test overview, reading section strategies, skimming, scanning, and time management techniques.', '2025-10-03', '16:00:00', '120 minutes', 'https://zoom.us/j/ielts-prep-session1', 'session301', 'zoom'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), 'Writing Task 1 and Task 2 Mastery', 'Academic writing skills for Task 1 (graphs, charts) and Task 2 (essays) with structure, vocabulary, and grammar focus.', '2025-10-10', '16:00:00', '120 minutes', 'https://zoom.us/j/ielts-prep-session2', 'session302', 'zoom'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), 'Listening Skills and Note-taking', 'IELTS listening section strategies, note-taking techniques, and practice with various accents and question types.', '2025-10-17', '16:00:00', '120 minutes', 'https://zoom.us/j/ielts-prep-session3', 'session303', 'zoom'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), 'Speaking Test Preparation', 'IELTS speaking test format, Part 1-3 strategies, fluency development, and mock speaking tests with feedback.', '2025-10-24', '16:00:00', '120 minutes', 'https://zoom.us/j/ielts-prep-session4', 'session304', 'zoom'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), 'Mock Tests and Final Review', 'Complete practice tests under timed conditions, performance analysis, and last-minute tips for test day success.', '2025-10-31', '16:00:00', '120 minutes', 'https://zoom.us/j/ielts-prep-session5', 'session305', 'zoom');

-- -----------------------------
-- BATCH 12: Course Sessions for hiro's New Courses
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses WHERE id IN (
        SELECT c.id FROM courses c 
        JOIN instructors i ON c.instructor_id = i.id 
        WHERE i.username = 'hiro' 
        ORDER BY c.id DESC 
    )
)
INSERT INTO course_sessions (course_id, session_name, session_description, session_date, session_time, session_duration, session_platform, session_link, session_password)
VALUES
-- Japanese Business Communication sessions (ACTIVE course: mix of past and future sessions)
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Keigo Fundamentals', 'Introduction to Japanese honorific language system: sonkeigo, kenjougo, and teineigo with practical business applications.', '2025-07-20', '09:00:00', 90, 'zoom', 'https://zoom.us/j/japanese-business-session1', 'keigo123'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Business Meeting Etiquette', 'Proper behavior in Japanese business meetings, seating arrangements, name card exchange, and appropriate language use.', '2025-07-27', '09:00:00', 90, 'zoom', 'https://zoom.us/j/japanese-business-session2', 'meeting456'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Email and Document Writing', 'Professional Japanese email structure, formal documents, and appropriate business correspondence including seasonal greetings.', '2025-08-03', '09:00:00', 90, 'zoom', 'https://zoom.us/j/japanese-business-session3', 'email789'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Presentations and Reports', 'Delivering presentations in Japanese business settings, creating reports, and handling Q&A sessions professionally.', '2025-08-28', '09:00:00', 90, 'zoom', 'https://zoom.us/j/japanese-business-session4', 'present101'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Networking and Relationship Building', 'Building professional relationships in Japan, after-work socializing (nominication), and maintaining business connections.', '2025-09-05', '09:00:00', 90, 'zoom', 'https://zoom.us/j/japanese-business-session5', 'network202'),

-- Kanji Master Class sessions (EXPIRED course: all sessions completed)
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Kanji Origins and Radicals', 'Understanding kanji etymology, radical components, and how to use radicals for memorization and dictionary lookup.', '2025-06-20', '18:00:00', 75, 'zoom', 'https://zoom.us/j/kanji-master-session1', 'radicals303'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Stroke Order and Writing Practice', 'Proper stroke order rules, writing practice techniques, and developing beautiful kanji handwriting skills.', '2025-06-27', '18:00:00', 75, 'zoom', 'https://zoom.us/j/kanji-master-session2', 'stroke404'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'On-yomi and Kun-yomi Readings', 'Understanding Chinese-origin and Japanese-origin readings, when to use each, and common reading patterns.', '2025-07-04', '18:00:00', 75, 'zoom', 'https://zoom.us/j/kanji-master-session3', 'readings505'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Compound Words and Contexts', 'Learning kanji in compound words, understanding meaning changes in combinations, and contextual usage.', '2025-07-11', '18:00:00', 75, 'zoom', 'https://zoom.us/j/kanji-master-session4', 'compound606'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Advanced Kanji and Review', 'Complex kanji characters, review of learned characters, and strategies for continued independent study.', '2025-08-01', '18:00:00', 75, 'zoom', 'https://zoom.us/j/kanji-master-session5', 'advanced707'),

-- Japanese Culture Through Language sessions (UPCOMING course: all future sessions)
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), 'Greetings and Social Hierarchy', 'Japanese greeting customs, understanding social hierarchy through language, and appropriate speech levels for different situations.', '2025-09-25', '20:00:00', 60, 'zoom', 'https://zoom.us/j/japanese-culture-session1', 'greet808'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), 'Seasonal Expressions and Festivals', 'Learning about Japanese seasons through language, traditional festivals vocabulary, and seasonal greeting patterns.', '2025-10-02', '20:00:00', 60, 'zoom', 'https://zoom.us/j/japanese-culture-session2', 'season909'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), 'Food Culture and Dining Etiquette', 'Japanese food vocabulary, dining etiquette, restaurant language, and cultural significance of meals in Japan.', '2025-10-09', '20:00:00', 60, 'zoom', 'https://zoom.us/j/japanese-culture-session3', 'food010'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), 'Traditional Arts and Crafts', 'Language related to traditional Japanese arts: tea ceremony, calligraphy, origami, and cultural appreciation vocabulary.', '2025-10-16', '20:00:00', 60, 'zoom', 'https://zoom.us/j/japanese-culture-session4', 'arts111'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), 'Modern Japan and Pop Culture', 'Contemporary Japanese culture, anime and manga language, modern slang, and bridging traditional and modern Japan.', '2025-10-23', '20:00:00', 60, 'zoom', 'https://zoom.us/j/japanese-culture-session5', 'pop212'),

-- Advanced Japanese Grammar sessions (UPCOMING course: all future sessions)
((SELECT id FROM course_map WHERE title='Advanced Japanese Grammar'), 'Complex Particles and Usage', 'Master advanced particles like には, において, にとって and their nuanced usage in formal and informal contexts.', '2025-11-30', '19:00:00', 75, 'zoom', 'https://zoom.us/j/japanese-grammar-session1', 'particle313'),
((SELECT id FROM course_map WHERE title='Advanced Japanese Grammar'), 'Conditional Forms and Subjunctive', 'Advanced conditional patterns, hypothetical situations, and expressing probability and possibility in Japanese.', '2025-12-07', '19:00:00', 75, 'zoom', 'https://zoom.us/j/japanese-grammar-session2', 'condition414'),
((SELECT id FROM course_map WHERE title='Advanced Japanese Grammar'), 'Honorific and Humble Forms', 'Deep dive into sonkeigo and kenjougo systems, when to use each, and advanced polite expression patterns.', '2025-12-14', '19:00:00', 75, 'zoom', 'https://zoom.us/j/japanese-grammar-session3', 'honor515'),
((SELECT id FROM course_map WHERE title='Advanced Japanese Grammar'), 'Complex Sentence Structures', 'Understanding and constructing complex sentences with multiple clauses, relative clauses, and embedded structures.', '2025-12-21', '19:00:00', 75, 'zoom', 'https://zoom.us/j/japanese-grammar-session4', 'complex616'),
((SELECT id FROM course_map WHERE title='Advanced Japanese Grammar'), 'Literary and Classical Forms', 'Introduction to classical Japanese grammar, literary expressions, and formal written language patterns.', '2026-01-04', '19:00:00', 75, 'zoom', 'https://zoom.us/j/japanese-grammar-session5', 'literary717');

-- -----------------------------
-- BATCH 13: Recorded Classes for will's New Courses
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses WHERE id IN (
        SELECT c.id FROM courses c 
        JOIN instructors i ON c.instructor_id = i.id 
        WHERE i.username = 'will' 
        ORDER BY c.id DESC 
        LIMIT 3
    )
)
INSERT INTO recorded_classes (course_id, recorded_name, recorded_description, recorded_link)
VALUES
-- Advanced Business English recorded classes (REMOVED - upcoming course has no recorded classes)

-- English Pronunciation Workshop recorded classes
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Vowel Sounds and IPA Introduction', 'Complete guide to American English vowel sounds using International Phonetic Alphabet with practical exercises.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Consonant Mastery Workshop', 'Overcome challenging consonant sounds including th-sounds, r/l distinction, and consonant clusters.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Word Stress and Rhythm Patterns', 'Master English stress patterns and natural rhythm for fluent-sounding speech production.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Intonation and Connected Speech', 'Advanced intonation patterns and natural speech linking for authentic English pronunciation.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Accent Reduction Intensive', 'Personalized techniques for reducing native language interference and achieving natural English accent.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');

-- IELTS Preparation Intensive recorded classes (REMOVED - upcoming course has no recorded classes)

-- -----------------------------
-- BATCH 14: Recorded Classes for hiro's New Courses
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses WHERE id IN (
        SELECT c.id FROM courses c 
        JOIN instructors i ON c.instructor_id = i.id 
        WHERE i.username = 'hiro' 
        ORDER BY c.id DESC 
    )
)
INSERT INTO recorded_classes (course_id, recorded_name, recorded_description, recorded_link)
VALUES
-- Japanese Business Communication recorded classes (ACTIVE course)
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Keigo System Fundamentals', 'Complete introduction to Japanese honorific language system with practical business applications and examples.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Business Meeting Culture in Japan', 'Understanding Japanese business meeting etiquette, proper behavior, and effective communication strategies.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Professional Writing Mastery', 'Advanced Japanese business writing including emails, reports, and formal documents with proper structure.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Presentation Skills in Japanese', 'Delivering effective presentations in Japanese business settings with confidence and cultural awareness.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Building Professional Relationships', 'Creating and maintaining professional relationships in Japanese business culture including networking strategies.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),

-- Kanji Master Class recorded classes (EXPIRED course)
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Kanji Origins and Radical System', 'Understanding the historical development of kanji and mastering the radical component system for efficient learning.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Stroke Order Mastery Workshop', 'Complete guide to proper kanji stroke order with practice techniques for beautiful handwriting.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Reading Systems Deep Dive', 'Comprehensive coverage of on-yomi and kun-yomi readings with patterns and memorization strategies.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Compound Words and Context', 'Advanced kanji usage in compound words and understanding meaning changes in different contexts.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Advanced Characters and Study Methods', 'Complex kanji mastery and developing independent study strategies for continued learning.', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');

-- Japanese Culture Through Language recorded classes (REMOVED - upcoming course has no recorded classes)

-- -----------------------------
-- BATCH 15: Study Materials for All New Courses
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses WHERE id IN (
        SELECT c.id FROM courses c 
        JOIN instructors i ON c.instructor_id = i.id 
        WHERE i.username IN ('will', 'hiro') 
        ORDER BY c.id DESC 
    )
)
INSERT INTO study_materials (course_id, material_title, material_description, material_type, material_link)
VALUES
-- Materials for will's Advanced Business English (REMOVED - upcoming course has no study materials)

-- Materials for will's English Pronunciation Workshop
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'IPA Chart for American English', 'Complete International Phonetic Alphabet chart with audio examples for American English sounds.', 'image', 'https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Pronunciation Drill Exercises', 'Structured practice exercises for difficult English sounds with step-by-step instructions.', 'document', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Word Stress Patterns Guide', 'Comprehensive guide to English word stress patterns with rules and exceptions explained.', 'pdf', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Minimal Pairs Practice Set', 'Extensive collection of minimal pairs for distinguishing similar English sounds in context.', 'document', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'Intonation Patterns Diagram', 'Visual representation of English intonation patterns for questions, statements, and emotions.', 'image', 'https://images.unsplash.com/photo-1516321497487-e288fb19713f'),

-- Materials for will's IELTS Preparation Intensive (REMOVED - upcoming course has no study materials)

-- Study Materials for hiro's Japanese Business Communication (ACTIVE course)
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Keigo Reference Guide', 'Complete reference guide for Japanese honorific language with examples and usage patterns.', 'pdf', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Business Card Exchange Etiquette', 'Step-by-step guide to proper meishi (business card) exchange protocol in Japanese business culture.', 'document', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Meeting Phrases Dictionary', 'Essential Japanese phrases for business meetings with pronunciation guide and cultural context.', 'pdf', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Email Templates Collection', 'Professional Japanese email templates for various business situations with explanations.', 'document', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'Business Hierarchy Chart', 'Visual guide to Japanese corporate hierarchy and appropriate language for each level.', 'image', 'https://images.unsplash.com/photo-1522383225653-ed111181a951'),

-- Study Materials for hiro's Kanji Master Class (EXPIRED course)
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Essential Radicals Chart', 'Comprehensive chart of 214 kanji radicals with meanings and common examples for memorization.', 'image', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Stroke Order Practice Sheets', 'Printable practice sheets for 1000 essential kanji with proper stroke order guidance.', 'pdf', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Reading Patterns Workbook', 'Interactive workbook for mastering on-yomi and kun-yomi reading patterns with exercises.', 'document', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Compound Words Dictionary', 'Extensive dictionary of kanji compound words with meanings and usage examples.', 'pdf', 'https://www.learnenglish.de/dictationpage.html'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), 'Mnemonic Memory Aids', 'Creative memory aids and mnemonics for remembering difficult kanji characters effectively.', 'image', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c');

-- Study Materials for hiro's Japanese Culture Through Language (REMOVED - upcoming course has no study materials)

-- -----------------------------
-- BATCH 16: Course Enrollments for ali and aki
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO course_enrollments (course_id, learner_id, created_at)
VALUES
-- ali enrollments (English → Japanese learner)
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM learner_map WHERE username='ali'), '2025-08-15 09:30:00'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM learner_map WHERE username='ali'), '2025-07-10 14:20:00'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), (SELECT id FROM learner_map WHERE username='ali'), '2025-08-18 11:45:00'),

-- Japanese learners enrolling in Hiroshi Tanaka's courses - JAPANESE BUSINESS COMMUNICATION
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM learner_map WHERE username='brandon_m'), '2025-08-17 10:15:00'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM learner_map WHERE username='grace_m'), '2025-08-18 16:30:00'),

-- Japanese learners enrolling in Hiroshi Tanaka's courses - KANJI MASTER CLASS (EXPIRED course)
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM learner_map WHERE username='ryan_t'), '2025-07-11 11:00:00'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM learner_map WHERE username='tyler_r'), '2025-07-11 14:15:00'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM learner_map WHERE username='caleb_j'), '2025-07-12 09:45:00'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM learner_map WHERE username='henry_b'), '2025-07-12 13:20:00'),

-- Japanese learners enrolling in Hiroshi Tanaka's courses - JAPANESE CULTURE THROUGH LANGUAGE
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), (SELECT id FROM learner_map WHERE username='austin_l'), '2025-08-21 15:00:00'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), (SELECT id FROM learner_map WHERE username='paige_w'), '2025-08-22 12:30:00'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), (SELECT id FROM learner_map WHERE username='madison_d'), '2025-08-22 16:45:00'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), (SELECT id FROM learner_map WHERE username='isabella_g'), '2025-08-23 10:00:00'),

-- Japanese learners enrolling in Hiroshi Tanaka's courses - JAPANESE FOR BEGINNERS  
((SELECT id FROM course_map WHERE title='Japanese for Beginners'), (SELECT id FROM learner_map WHERE username='bob_s'), '2025-08-24 11:15:00'),

-- English learners enrolling in William Johnson's courses - ADVANCED BUSINESS ENGLISH
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='aki'), '2025-08-20 16:15:00'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='yuki_n'), '2025-08-21 10:30:00'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='kenta_s'), '2025-08-21 14:45:00'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='takumi_w'), '2025-08-22 09:15:00'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='aya_m'), '2025-08-22 11:30:00'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='nanami_h'), '2025-08-23 13:20:00'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='sho_m'), '2025-08-23 15:45:00'),

-- English learners enrolling in William Johnson's courses - ENGLISH PRONUNCIATION WORKSHOP (COMPLETED COURSE)
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM learner_map WHERE username='emiko_s'), '2025-07-10 08:30:00'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM learner_map WHERE username='hiroshi_y'), '2025-07-11 12:15:00'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM learner_map WHERE username='miyuki_k'), '2025-07-12 10:00:00'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM learner_map WHERE username='ryo_t'), '2025-07-12 14:30:00'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM learner_map WHERE username='sakura_i'), '2025-07-13 09:45:00'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM learner_map WHERE username='kenji_w'), '2025-07-14 16:20:00'),

-- English learners enrolling in William Johnson's courses - IELTS PREPARATION INTENSIVE  
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM learner_map WHERE username='haruka_o'), '2025-08-27 11:00:00'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM learner_map WHERE username='daiki_i'), '2025-08-27 15:30:00'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM learner_map WHERE username='yuka_t'), '2025-08-28 08:45:00'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM learner_map WHERE username='ami_f'), '2025-08-28 13:15:00');

-- -----------------------------
-- BATCH 17: Group Chat Messages for New Courses
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
-- Group chat for Japanese Business Communication (ali enrolled)
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', 'ビジネス日本語コースへようこそ！まずは自己紹介をして、ビジネス日本語の目標を教えてください。'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'アリスです。アメリカ出身です。将来東京の日本企業で働きたいと思っています。よろしくお願いします！'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', '素晴らしい目標ですね、アリスさん！ビジネス日本語では敬語の習得が重要です。セッションで集中的に練習しましょう。'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', '敬語を勉強していますが、とても複雑です！実際の場面で尊敬語と謙譲語をいつ使うのか分からなくて...'),
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', '良い質問ですね！尊敬語は相手の行動を持ち上げ、謙譲語は自分の行動を下げます。ロールプレイで練習しましょう。'),

-- Group chat for Kanji Master Class (ali enrolled)
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', '漢字マスタークラスへようこそ！現在の漢字レベルと、漢字学習での一番の悩みを教えてください。'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'こんにちは！300個くらい知っていますが、「日」と「目」のような似た漢字がいつも混同してしまいます。覚えるコツはありますか？'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', '良い例ですね！「日」（太陽）は横に広く、「目」（眼）は縦に長いです。太陽は空に広がり、目は縦長の楕円と覚えてください。'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'すごく分かりやすいです！視覚的な記憶法は本当に役立ちますね。読み方を覚えるコツもありますか？'),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', 'もちろんです！複合語は音読み、単独の漢字は訓読みが多いです。パターンを一緒に学習しましょう。'),

-- Group chat for Advanced Business English (aki enrolled)
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Welcome to Advanced Business English! Please introduce yourselves and your professional English goals.'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'Hello! I''m Akira from Japan. I work in IT and need to communicate with international clients and present in English.'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Excellent, Akira! Technical presentations require clear communication. We''ll work on structure and confidence building.'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'I can write emails well but speaking in meetings is challenging. I worry about grammar mistakes when presenting.'),
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Common concern! Fluency matters more than perfect grammar in meetings. We''ll practice with real scenarios.'),

-- Group chat for English Pronunciation Workshop (aki enrolled)
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Welcome to the Pronunciation Workshop! What English sounds do you find most challenging?'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'The "th" sound is impossible! Also, I can''t hear the difference between "r" and "l" sometimes.'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Very common for Japanese speakers! We''ll use IPA symbols and lots of practice. The key is tongue position.'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'I''ve tried watching my tongue in a mirror but it feels awkward. Any other techniques?'),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Mirror work is good! We''ll also use audio drills and I''ll show you physical exercises for mouth positioning.'),

-- Group chat for IELTS Preparation Intensive (haruka_o enrolled) 
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Welcome to IELTS Preparation! What''s your target band score and which section concerns you most?'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM learner_map WHERE username='haruka_o'), 'learner', 'I need band 7 for university admission. Writing is my weakest area, especially Task 2 essays.'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Band 7 is achievable! We''ll work on essay structure, linking words, and vocabulary range. Practice is key.'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM learner_map WHERE username='haruka_o'), 'learner', 'I always run out of time in Task 2. Should I spend more time planning or writing?'),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM instructor_map WHERE username='will'), 'instructor', 'Great question! Plan for 5 minutes, write for 35. A clear structure saves time and improves coherence.'),

-- Group chat for Japanese Culture Through Language (UPCOMING course - ali enrolled)
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', '言語を通した日本文化コースへようこそ！コースの開始が近づいています。自己紹介と、どの日本文化に最も興味があるかを教えてください。'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'こんにちは！アリスです。茶道などの日本の伝統芸術に魅力を感じ、日常言語に含まれる文化的なニュアンスを理解したいと思っています。'),
((SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', '素晴らしいですね、アリスさん！伝統芸術には深い言語的つながりがあります。茶道の専門用語や季節表現を一緒に探求しましょう。'),

-- Group chat for Advanced Japanese Grammar (UPCOMING course - ali enrolled)
((SELECT id FROM course_map WHERE title='Advanced Japanese Grammar'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', '上級日本語文法コースへようこそ！11月にコースが始まります。現在の文法の課題と学習目標を教えてください。'),
((SELECT id FROM course_map WHERE title='Advanced Japanese Grammar'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'こんにちは！「によって」や「における」などの複雑な助詞に苦労しています。また、条件形も選択肢が多いと混乱してしまいます。'),
((SELECT id FROM course_map WHERE title='Advanced Japanese Grammar'), (SELECT id FROM instructor_map WHERE username='hiro'), 'instructor', '素晴らしい例ですね、アリスさん！それらは一緒にマスターする高度なニュアンスです。各助詞の特定の文脈を徹底的に練習しましょう。');

-- -----------------------------
-- BATCH 18: Feedback for New Courses and Interactions
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
-- Feedback from ali for hiro's courses
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM instructor_map WHERE username='hiro'), (SELECT id FROM learner_map WHERE username='ali'), 'course', 'Incredible course! Hiroshi-sensei explains keigo so clearly with real business scenarios. I feel confident using honorific language now. The cultural context makes everything click!', 5),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM instructor_map WHERE username='hiro'), (SELECT id FROM learner_map WHERE username='ali'), 'course', 'Best kanji course ever! The mnemonic techniques and radical system approach revolutionized my learning. I can now remember complex kanji effortlessly. Highly recommend!', 5),
-- No feedback for Japanese Culture Through Language (UPCOMING course)
-- No feedback for Advanced Japanese Grammar (UPCOMING course)

-- Feedback from aki for will's courses
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='aki'), 'course', 'William''s teaching style is perfect for business professionals! The presentation practice and real meeting scenarios boosted my confidence tremendously. My colleagues noticed the improvement!', 5),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='aki'), 'course', 'Finally mastered the "th" sound! William''s IPA approach and mouth positioning exercises work. Still working on r/l distinction but huge improvement overall.', 4),
((SELECT id FROM course_map WHERE title='IELTS Preparation Intensive'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='aki'), 'course', 'Comprehensive IELTS prep with proven strategies! William''s writing templates and speaking practice sessions are gold. Scored 7.5 overall - exceeded my target!', 5),

-- Instructor feedback for learners
((SELECT id FROM course_map WHERE title='Japanese Business Communication'), (SELECT id FROM instructor_map WHERE username='hiro'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'Alice shows exceptional dedication to mastering business Japanese. Her keigo usage improved dramatically, and she actively participates in role-play exercises. Ready for business environment!', 5),
((SELECT id FROM course_map WHERE title='Kanji Master Class'), (SELECT id FROM instructor_map WHERE username='hiro'), (SELECT id FROM learner_map WHERE username='ali'), 'learner', 'Alice''s kanji progression is impressive! She consistently practices stroke order and applies mnemonic techniques effectively. Encourage more compound word practice for advanced level.', 4),
-- No instructor feedback for Japanese Culture Through Language (UPCOMING course)
-- No instructor feedback for Advanced Japanese Grammar (UPCOMING course)
((SELECT id FROM course_map WHERE title='Advanced Business English'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'Akira transformed from hesitant speaker to confident presenter! His technical vocabulary expanded significantly, and meeting participation improved. Natural leadership qualities emerging.', 5),
((SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), (SELECT id FROM instructor_map WHERE username='will'), (SELECT id FROM learner_map WHERE username='aki'), 'learner', 'Akira''s pronunciation accuracy improved remarkably! Excellent progress with difficult sounds. Continue practicing connected speech patterns for even more natural fluency.', 4);

-- -----------------------------
-- BATCH 19: Notifications for ali and aki
-- -----------------------------
WITH course_map AS (
    SELECT id, title FROM courses
), learner_map AS (
    SELECT id, username FROM learners
)
INSERT INTO notifications (learner_id, course_id, notification_type, content_title, content_text, is_read)
VALUES
-- Notifications for ali (Japanese courses)
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'session alert', 'Upcoming Session: Keigo Fundamentals', 'Your Japanese Business Communication session starts in 2 hours. Review the keigo reference guide before class!', false),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM course_map WHERE title='Japanese Business Communication'), 'feedback', 'New Study Material Added', 'Hiroshi-sensei uploaded "Business Card Exchange Etiquette" guide. Essential for professional networking in Japan!', false),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM course_map WHERE title='Kanji Master Class'), 'session alert', 'Kanji Session Tomorrow', 'Don''t forget: "Kanji Origins and Radicals" session tomorrow at 6:00 PM JST. Bring your practice sheets!', true),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM course_map WHERE title='Kanji Master Class'), 'feedback', 'Instructor Feedback Available', 'Hiroshi-sensei left feedback on your kanji progress. Check your dashboard for detailed comments and improvement tips.', false),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), 'feedback', 'Cultural Activity Scheduled', 'Virtual tea ceremony demonstration added to next week''s session! Learn traditional vocabulary while experiencing Japanese culture.', false),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM course_map WHERE title='Japanese Culture Through Language'), 'session alert', 'Culture Session Starting Soon', 'Your "Greetings and Social Hierarchy" session begins in 30 minutes. Join the Zoom room early for tech check!', true),

-- Notifications for aki (English courses)
-- REMOVED: Advanced Business English feedback (upcoming course has no feedback)
-- REMOVED: IELTS Preparation feedback (upcoming course has no feedback)
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'session alert', 'Pronunciation Practice Today', 'Today''s focus: consonant clusters and difficult sounds. Review the IPA chart before our 2:00 PM session!', true),
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'feedback', 'Progress Feedback Posted', 'William reviewed your pronunciation recordings. Great improvement on "th" sounds! Check feedback for next steps.', false),

-- Additional course-related notifications
((SELECT id FROM learner_map WHERE username='ali'), NULL, 'feedback', 'Study Streak Achievement!', 'Congratulations! You''ve maintained a 15-day study streak across all your Japanese courses. Keep up the excellent work! 🎉', false),
((SELECT id FROM learner_map WHERE username='aki'), NULL, 'feedback', 'Certificate Ready for Download', 'Your Advanced Business English certificate is ready! Download it from your achievements page to showcase your skills.', false),
((SELECT id FROM learner_map WHERE username='ali'), (SELECT id FROM course_map WHERE title='Kanji Master Class'), 'feedback', 'Bonus Material: Kanji Games', 'Interactive kanji learning games added to course materials! Make studying fun with memory games and quizzes.', true),
((SELECT id FROM learner_map WHERE username='aki'), (SELECT id FROM course_map WHERE title='English Pronunciation Workshop'), 'session alert', 'Final Session This Week', 'Last pronunciation workshop session this Friday. We''ll record your progress for comparison with week 1. Amazing improvement!', false);

-- -----------------------------
-- BATCH 20: Final Withdrawals for will and hiro
-- -----------------------------
WITH instructor_map AS (
    SELECT id, username FROM instructors WHERE username IN ('will', 'hiro')
)
INSERT INTO withdrawal (instructor_id, amount, status)
VALUES
-- Additional withdrawals for will from new course earnings
((SELECT id FROM instructor_map WHERE username='will'), 15.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='will'), 12.00, 'PENDING'),
((SELECT id FROM instructor_map WHERE username='will'), 18.00, 'COMPLETED'),

-- Additional withdrawals for hiro from new course earnings
((SELECT id FROM instructor_map WHERE username='hiro'), 20.00, 'COMPLETED'),
((SELECT id FROM instructor_map WHERE username='hiro'), 14.00, 'PENDING'),
((SELECT id FROM instructor_map WHERE username='hiro'), 16.00, 'COMPLETED');

-- Withdrawal payment information for new withdrawals
WITH withdrawal_map AS (
    SELECT w.id, i.username, w.amount
    FROM withdrawal w 
    JOIN instructors i ON w.instructor_id = i.id 
    WHERE i.username IN ('will', 'hiro')
    ORDER BY w.id DESC 
    LIMIT 6
)
INSERT INTO withdrawal_info (withdrawal_id, payment_method, card_number, expiry_date, cvv, card_holder_name, paypal_email, bank_account_number, bank_name, swift_code)
VALUES
-- Payment info for will's new withdrawals
((SELECT id FROM withdrawal_map WHERE username='will' AND amount=15.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '1111222233', 'Chase Bank', 'CHASUS33'),
((SELECT id FROM withdrawal_map WHERE username='will' AND amount=12.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'william.johnson.instructor@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='will' AND amount=18.00), 'CARD', '4444555566667777', '03/2029', '456', 'William Johnson', NULL, NULL, NULL, NULL),

-- Payment info for hiro's new withdrawals
((SELECT id FROM withdrawal_map WHERE username='hiro' AND amount=20.00), 'BANK', NULL, NULL, NULL, NULL, NULL, '9999888877', 'MUFG Bank', 'BOTKJPJT'),
((SELECT id FROM withdrawal_map WHERE username='hiro' AND amount=14.00), 'PAYPAL', NULL, NULL, NULL, NULL, 'hiroshi.tanaka.sensei@example.com', NULL, NULL, NULL),
((SELECT id FROM withdrawal_map WHERE username='hiro' AND amount=16.00), 'CARD', '5555666677778888', '07/2030', '789', 'Hiroshi Tanaka', NULL, NULL, NULL, NULL);

-- -----------------------------
-- COMPREHENSIVE WITHDRAWAL INFO COMPLETION 
-- -----------------------------

-- Complete missing withdrawal_info for all withdrawals that don't have payment information
-- This ensures every withdrawal has corresponding payment details

WITH missing_withdrawal_map AS (
    SELECT w.id, i.username, w.amount
    FROM withdrawal w
    JOIN instructors i ON w.instructor_id = i.id
    WHERE w.id NOT IN (SELECT withdrawal_id FROM withdrawal_info WHERE withdrawal_id IS NOT NULL)
)
INSERT INTO withdrawal_info (withdrawal_id, payment_method, card_number, expiry_date, cvv, card_holder_name, paypal_email, bank_account_number, bank_name, swift_code)
SELECT 
    id,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 1 THEN 'CARD'
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 2 THEN 'PAYPAL'
        ELSE 'BANK'
    END as payment_method,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 1 
        THEN '4' || LPAD((ROW_NUMBER() OVER (ORDER BY username, amount))::text, 15, '0')
        ELSE NULL
    END as card_number,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 1 
        THEN CASE 
            WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 3 = 1 THEN '12/2029'
            WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 3 = 2 THEN '06/2030'
            ELSE '09/2031'
        END
        ELSE NULL
    END as expiry_date,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 1 
        THEN LPAD((100 + (ROW_NUMBER() OVER (ORDER BY username, amount)) % 900)::text, 3, '0')
        ELSE NULL
    END as cvv,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 1 
        THEN (
            SELECT name 
            FROM instructors 
            WHERE username = missing_withdrawal_map.username
        )
        ELSE NULL
    END as card_holder_name,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 2 
        THEN username || '.payment@example.com'
        ELSE NULL
    END as paypal_email,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 0 
        THEN LPAD((1000000000 + (ROW_NUMBER() OVER (ORDER BY username, amount)) % 9000000000)::text, 10, '0')
        ELSE NULL
    END as bank_account_number,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 0 
        THEN CASE 
            WHEN username LIKE '%japan%' OR username IN ('hiro', 'emiko_s', 'takeshi_y', 'yuki_n', 'kenta_s', 'satoshi_n', 'akiko_y', 'masaki_s', 'yumiko_t', 'tetsuya_k') 
            THEN CASE 
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 1 THEN 'MUFG Bank'
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 2 THEN 'Sumitomo Bank'
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 3 THEN 'Mizuho Bank'
                ELSE 'Resona Bank'
            END
            ELSE CASE 
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 1 THEN 'Chase Bank'
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 2 THEN 'Bank of America'
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 3 THEN 'Wells Fargo'
                ELSE 'Citibank'
            END
        END
        ELSE NULL
    END as bank_name,
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY username ORDER BY amount) % 3 = 0 
        THEN CASE 
            WHEN username LIKE '%japan%' OR username IN ('hiro', 'emiko_s', 'takeshi_y', 'yuki_n', 'kenta_s', 'satoshi_n', 'akiko_y', 'masaki_s', 'yumiko_t', 'tetsuya_k') 
            THEN CASE 
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 1 THEN 'BOTKJPJT'
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 2 THEN 'SMBCJPJT'
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 3 THEN 'MHCBJPJT'
                ELSE 'RRBJJPJT'
            END
            ELSE CASE 
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 1 THEN 'CHASUS33'
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 2 THEN 'BOFAUS3N'
                WHEN ROW_NUMBER() OVER (ORDER BY username, amount) % 4 = 3 THEN 'WFBIUS6S'
                ELSE 'CITIUS33'
            END
        END
        ELSE NULL
    END as swift_code
FROM missing_withdrawal_map;

-- ========================================
-- END OF ADDITIONAL FOCUSED DUMMY DATA
-- ========================================
-- Summary of additions:
-- ✅ 16 new follower relationships for ali and aki
-- ✅ 15 new chats between ali and aki
-- ✅ 60+ new messages with language learning content
-- ✅ 20 new feed posts (10 each for ali and aki)
-- ✅ 26 feed images across multiple posts
-- ✅ 22 feed likes from various learners
-- ✅ 16 detailed feed comments with language learning discussions
-- ✅ 6 new courses (3 each for will and hiro)
-- ✅ 30 course sessions (5 per course) with realistic scheduling
-- ✅ 30 recorded classes matching course topics
-- ✅ 45 study materials of various types (pdf, doc, image)
-- ✅ 6 course enrollments (ali in Japanese courses, aki in English courses)
-- ✅ 25 group chat messages for course discussions
-- ✅ 10 feedback entries (course and learner feedback)
-- ✅ 20 notifications for sessions, updates, and achievements
-- ✅ 6 additional withdrawals with payment information
-- ========================================
