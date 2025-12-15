-- Row Level Security (RLS) Policies
-- Generated from Supabase database using MCP
-- Date: 2025-12-06
-- This file contains all RLS policies extracted from the database

-- ============================================
-- ENABLE ROW LEVEL SECURITY ON ALL TABLES
-- ============================================

-- Business Schema
ALTER TABLE business.billing_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.billing_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.billing_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.feature_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.inventory_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.merchant_customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.merchant_partnerships ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.merchant_service_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.merch_imports ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.payment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.plan_change_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.pricing_faq ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.products_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.provinces ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.referral_agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.referral_commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.referral_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.referral_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.role_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.sales_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.service_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.store_business_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.store_cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.store_carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.store_payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.subscription_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.subscription_usage_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE business.user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Pet Schema
ALTER TABLE pet.characters ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.customers_pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.health_parameter_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_characters ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_healths ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_scan_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_timelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_weight_histories ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.photo_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.photo_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.photo_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.qr_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.schedule_recurring_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.schedule_types ENABLE ROW LEVEL SECURITY;

-- Public Schema
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Social Schema
ALTER TABLE social.community_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.content_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.course_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.event_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.forum_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.forum_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.forum_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.kb_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.kb_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.product_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.product_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.push_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_achievement_unlocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_warnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.xp_transactions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS POLICIES
-- ============================================
-- Note: Policies are extracted from pg_policies view
-- For complete policy definitions with actual SQL, refer to Supabase dashboard

-- Business Schema Policies
-- (Policies are defined in Supabase dashboard)
-- Use: SELECT * FROM pg_policies WHERE schemaname = 'business';

-- Pet Schema Policies  
-- (Policies are defined in Supabase dashboard)
-- Use: SELECT * FROM pg_policies WHERE schemaname = 'pet';

-- Public Schema Policies
-- (Policies are defined in Supabase dashboard)
-- Use: SELECT * FROM pg_policies WHERE schemaname = 'public';

-- Social Schema Policies
-- (Policies are defined in Supabase dashboard)
-- Use: SELECT * FROM pg_policies WHERE schemaname = 'social';

-- Storage Schema Policies
-- (Policies are defined in Supabase dashboard)
-- Use: SELECT * FROM pg_policies WHERE schemaname = 'storage';

-- ============================================
-- NOTE
-- ============================================
-- This file contains RLS enable statements only.
-- Actual policy definitions (CREATE POLICY statements) are managed through
-- Supabase dashboard and stored in the database.
-- 
-- To view all policies:
-- SELECT schemaname, tablename, policyname, cmd, qual, with_check
-- FROM pg_policies
-- ORDER BY schemaname, tablename, policyname;
--
-- To regenerate this file with full policy definitions, use:
-- SELECT pg_get_policy_definition(pol.oid) FROM pg_policy pol;
