-- Migration to remove feedback_about column from feedback table
-- Since feedback_type already provides the necessary categorization

-- Step 1: Drop the feedback_about column
ALTER TABLE feedback DROP COLUMN IF EXISTS feedback_about;

-- Verify the change
\d feedback;
