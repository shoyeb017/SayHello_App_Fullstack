-- Complete data insertion for feedback testing (CORRECTED VERSION)
-- Course ID: 4a8b9902-0406-4382-9ac0-c191e2bf9d6e
-- Instructor ID: e75ac0bd-c253-4089-a620-fb82af3e9087
-- Learner IDs: 5b1674fb-3591-4e3f-89f7-ea857cd76a84, 7c974282-ab29-4365-8955-23e26d4336a9

-- First, delete any existing data to start fresh
DELETE FROM feedback WHERE course_id = '4a8b9902-0406-4382-9ac0-c191e2bf9d6e';
DELETE FROM course_enrollments WHERE course_id = '4a8b9902-0406-4382-9ac0-c191e2bf9d6e';

-- 1. Insert course enrollments
INSERT INTO course_enrollments (course_id, learner_id, created_at) VALUES
('4a8b9902-0406-4382-9ac0-c191e2bf9d6e', '5b1674fb-3591-4e3f-89f7-ea857cd76a84', NOW()),
('4a8b9902-0406-4382-9ac0-c191e2bf9d6e', '7c974282-ab29-4365-8955-23e26d4336a9', NOW());

-- 2. Insert course feedback (students rating the course)
INSERT INTO feedback (course_id, instructor_id, learner_id, feedback_type, feedback_text, feedback_about, rating, created_at) VALUES
('4a8b9902-0406-4382-9ac0-c191e2bf9d6e', 'e75ac0bd-c253-4089-a620-fb82af3e9087', '5b1674fb-3591-4e3f-89f7-ea857cd76a84', 'course', 'This course is excellent! The content is well-structured and easy to follow. I learned a lot from the practical exercises.', 'course_content', 5, NOW() - INTERVAL '2 days'),
('4a8b9902-0406-4382-9ac0-c191e2bf9d6e', 'e75ac0bd-c253-4089-a620-fb82af3e9087', '7c974282-ab29-4365-8955-23e26d4336a9', 'course', 'Great course material and assignments. Could use more interactive elements but overall very informative.', 'course_structure', 4, NOW() - INTERVAL '1 day');

-- 3. Insert instructor feedback (students rating the instructor)
INSERT INTO feedback (course_id, instructor_id, learner_id, feedback_type, feedback_text, feedback_about, rating, created_at) VALUES
('4a8b9902-0406-4382-9ac0-c191e2bf9d6e', 'e75ac0bd-c253-4089-a620-fb82af3e9087', '5b1674fb-3591-4e3f-89f7-ea857cd76a84', 'instructor', 'The instructor is very knowledgeable and explains concepts clearly. Always available for questions and provides detailed feedback.', 'teaching_quality', 5, NOW() - INTERVAL '3 days'),
('4a8b9902-0406-4382-9ac0-c191e2bf9d6e', 'e75ac0bd-c253-4089-a620-fb82af3e9087', '7c974282-ab29-4365-8955-23e26d4336a9', 'instructor', 'Good instructor with solid expertise. Sometimes explanations could be more detailed, but overall very helpful.', 'instructor_support', 4, NOW() - INTERVAL '2 hours');

-- 4. Insert learner feedback (instructor giving feedback to students) - USING 'learner' NOT 'student'
INSERT INTO feedback (course_id, instructor_id, learner_id, feedback_type, feedback_text, feedback_about, rating, created_at) VALUES
('4a8b9902-0406-4382-9ac0-c191e2bf9d6e', 'e75ac0bd-c253-4089-a620-fb82af3e9087', '5b1674fb-3591-4e3f-89f7-ea857cd76a84', 'learner', 'Excellent student performance! Consistently submits high-quality assignments and actively participates in discussions. Keep up the great work!', 'student_performance', 5, NOW() - INTERVAL '1 day'),
('4a8b9902-0406-4382-9ac0-c191e2bf9d6e', 'e75ac0bd-c253-4089-a620-fb82af3e9087', '7c974282-ab29-4365-8955-23e26d4336a9', 'learner', 'Good progress throughout the course. Could improve on assignment submission timing, but shows good understanding of concepts.', 'student_performance', 4, NOW() - INTERVAL '3 hours');

-- Verify the data was inserted correctly
SELECT 'Course Enrollments' as data_type, COUNT(*) as count FROM course_enrollments WHERE course_id = '4a8b9902-0406-4382-9ac0-c191e2bf9d6e'
UNION ALL
SELECT 'Course Feedback' as data_type, COUNT(*) as count FROM feedback WHERE course_id = '4a8b9902-0406-4382-9ac0-c191e2bf9d6e' AND feedback_type = 'course'
UNION ALL
SELECT 'Instructor Feedback' as data_type, COUNT(*) as count FROM feedback WHERE course_id = '4a8b9902-0406-4382-9ac0-c191e2bf9d6e' AND feedback_type = 'instructor'
UNION ALL
SELECT 'Learner Feedback' as data_type, COUNT(*) as count FROM feedback WHERE course_id = '4a8b9902-0406-4382-9ac0-c191e2bf9d6e' AND feedback_type = 'learner';
