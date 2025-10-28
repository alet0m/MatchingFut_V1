-- Add the missing has_completed_onboarding column to profiles table
-- This column is required for the onboarding process to work

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS has_completed_onboarding BOOLEAN DEFAULT FALSE;

-- Update existing users to have completed onboarding if they have profiles
-- (This prevents existing users from being stuck in onboarding loop)
UPDATE profiles 
SET has_completed_onboarding = TRUE 
WHERE has_completed_onboarding IS NULL OR has_completed_onboarding = FALSE;

-- Verify the column was added
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'profiles' AND column_name = 'has_completed_onboarding';