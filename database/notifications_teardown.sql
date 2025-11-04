-- Teardown script to remove notifications-related objects (devices/events/triggers/functions)
-- Run this in Supabase SQL editor if you previously applied notifications_setup.sql

begin;

-- 1) Drop triggers that enqueue events
drop trigger if exists trg_enqueue_team_invitation on public.team_invitations;
drop trigger if exists trg_enqueue_friendship_insert on public.friendships;
drop trigger if exists trg_enqueue_friendship_update on public.friendships;

-- 2) Drop trigger functions
drop function if exists public.enqueue_team_invitation_event() cascade;
drop function if exists public.enqueue_friendship_insert_event() cascade;
drop function if exists public.enqueue_friendship_update_event() cascade;

-- 3) Drop tables
-- Use CASCADE to remove dependent grants/policies if any remain
drop table if exists public.notification_events cascade;
drop table if exists public.notification_devices cascade;

commit;
