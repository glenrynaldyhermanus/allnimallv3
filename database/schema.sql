-- Allnimall Database Schema - Multi-Schema Structure
-- Updated: 2025-10-18
-- Schemas: public, pet, social, pos

-- ================================
-- EXTENSIONS
-- ================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ================================
-- CREATE SCHEMAS
-- ================================
CREATE SCHEMA IF NOT EXISTS pet;
CREATE SCHEMA IF NOT EXISTS social;
CREATE SCHEMA IF NOT EXISTS pos;

COMMENT ON SCHEMA pet IS 'Pet profile management and care';
COMMENT ON SCHEMA social IS 'Community features, forums, courses, and gamification';
COMMENT ON SCHEMA pos IS 'Business management (POS, subscriptions, billing, HR)';

-- ================================
-- PUBLIC SCHEMA TABLES (8 tables)
-- Core auth & system infrastructure
-- ================================

-- activity_logs
CREATE TABLE IF NOT EXISTS public.activity_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid,
  activity_type text NOT NULL,
  activity_description text,
  entity_type text,
  entity_id uuid,
  metadata jsonb DEFAULT '{}'::jsonb,
  ip_address inet,
  user_agent text,
  CONSTRAINT activity_logs_pkey PRIMARY KEY (id)
);

-- app_settings
CREATE TABLE IF NOT EXISTS public.app_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  updated_at timestamp with time zone,
  setting_key text NOT NULL,
  setting_value text NOT NULL,
  setting_type text DEFAULT 'string'::text,
  description text,
  is_public boolean DEFAULT false,
  CONSTRAINT app_settings_pkey PRIMARY KEY (id),
  CONSTRAINT app_settings_setting_key_key UNIQUE (setting_key),
  CONSTRAINT app_settings_setting_type_check CHECK (setting_type = ANY (ARRAY['string'::text, 'number'::text, 'boolean'::text, 'json'::text]))
);

-- ================================
-- POS SCHEMA TABLES (46 tables)
-- Business management system
-- ================================

-- attendance_records
CREATE TABLE IF NOT EXISTS pos.attendance_records (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  store_id uuid NOT NULL,
  attendance_date date NOT NULL,
  clock_in_time timestamp with time zone,
  clock_out_time timestamp with time zone,
  break_start_time timestamp with time zone,
  break_end_time timestamp with time zone,
  total_hours numeric(4,2),
  overtime_hours numeric(4,2),
  status character varying(20) NOT NULL DEFAULT 'present'::character varying,
  notes text,
  clock_in_location jsonb,
  clock_out_location jsonb,
  clock_in_photo_url text,
  clock_out_photo_url text,
  approved_by uuid,
  approved_at timestamp with time zone,
  CONSTRAINT attendance_records_pkey PRIMARY KEY (id),
  CONSTRAINT attendance_records_status_check CHECK (status::text = ANY (ARRAY['present'::character varying, 'absent'::character varying, 'late'::character varying, 'half_day'::character varying, 'sick_leave'::character varying, 'vacation_leave'::character varying]::text[]))
);

-- billing_invoices
CREATE TABLE IF NOT EXISTS pos.billing_invoices (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  subscription_id uuid,
  stripe_invoice_id text,
  invoice_number text NOT NULL,
  amount numeric NOT NULL,
  currency text DEFAULT 'IDR'::text,
  status text NOT NULL,
  due_date timestamp with time zone NOT NULL,
  paid_at timestamp with time zone,
  invoice_url text,
  pdf_url text,
  subtotal numeric DEFAULT 0,
  tax_amount numeric DEFAULT 0,
  discount_amount numeric DEFAULT 0,
  late_fee numeric DEFAULT 0,
  payment_terms_days integer DEFAULT 30,
  notes text,
  billing_address jsonb,
  line_items jsonb,
  metadata jsonb,
  CONSTRAINT billing_invoices_pkey PRIMARY KEY (id),
  CONSTRAINT billing_invoices_status_check CHECK (status = ANY (ARRAY['pending'::text, 'paid'::text, 'failed'::text, 'cancelled'::text, 'refunded'::text]))
);

-- billing_payments
CREATE TABLE IF NOT EXISTS pos.billing_payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  invoice_id uuid NOT NULL,
  stripe_payment_intent_id text,
  amount numeric NOT NULL,
  currency text DEFAULT 'IDR'::text,
  payment_method text NOT NULL,
  status text NOT NULL,
  failure_reason text,
  failure_code text,
  receipt_url text,
  payment_date timestamp with time zone,
  payment_reference text,
  payment_gateway text DEFAULT 'midtrans'::text,
  gateway_transaction_id text,
  gateway_fee numeric DEFAULT 0,
  net_amount numeric,
  refund_amount numeric DEFAULT 0,
  refund_reason text,
  refund_date timestamp with time zone,
  CONSTRAINT billing_payments_pkey PRIMARY KEY (id),
  CONSTRAINT billing_payments_status_check CHECK (status = ANY (ARRAY['succeeded'::text, 'failed'::text, 'pending'::text, 'cancelled'::text]))
);

-- billing_transactions
CREATE TABLE IF NOT EXISTS pos.billing_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  transaction_type text NOT NULL,
  amount numeric NOT NULL,
  currency text DEFAULT 'IDR'::text,
  description text,
  reference_id uuid,
  reference_type text,
  stripe_transaction_id text,
  CONSTRAINT billing_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT billing_transactions_transaction_type_check CHECK (transaction_type = ANY (ARRAY['subscription'::text, 'upgrade'::text, 'downgrade'::text, 'refund'::text, 'credit'::text]))
);

-- ================================
-- PET SCHEMA TABLES (14 tables)
-- Pet profile management and care
-- ================================

-- characters
CREATE TABLE IF NOT EXISTS pet.characters (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  character_en text NOT NULL,
  character_id text NOT NULL,
  deleted_at timestamp with time zone,
  good_character boolean NOT NULL,
  CONSTRAINT characters_pkey PRIMARY KEY (id)
);

-- pet_photos
CREATE TABLE IF NOT EXISTS pet.pet_photos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_id uuid NOT NULL,
  photo_url text NOT NULL,
  is_primary boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  CONSTRAINT pet_photos_pkey PRIMARY KEY (id)
);

-- pet_scan_logs
CREATE TABLE IF NOT EXISTS pet.pet_scan_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  pet_id uuid NOT NULL,
  latitude numeric,
  longitude numeric,
  scanned_by_ip text,
  user_agent text,
  device_info jsonb DEFAULT '{}'::jsonb,
  location_accuracy numeric,
  location_name text,
  CONSTRAINT pet_scan_logs_pkey PRIMARY KEY (id)
);

-- cities
CREATE TABLE IF NOT EXISTS pos.cities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  province_id uuid NOT NULL,
  CONSTRAINT cities_pkey PRIMARY KEY (id)
);

-- commission_records
CREATE TABLE IF NOT EXISTS pos.commission_records (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  sale_id uuid,
  commission_type character varying(50) DEFAULT 'sales'::character varying,
  commission_rate numeric(5,2) NOT NULL,
  commission_amount numeric(12,2) NOT NULL,
  pay_period_id uuid,
  description text,
  calculated_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT commission_records_pkey PRIMARY KEY (id),
  CONSTRAINT commission_records_commission_type_check CHECK (commission_type::text = ANY (ARRAY['sales'::character varying, 'service'::character varying, 'bonus'::character varying, 'other'::character varying]::text[]))
);

-- ================================
-- SOCIAL SCHEMA TABLES (23 tables)
-- Community and engagement features
-- ================================

-- community_events
CREATE TABLE IF NOT EXISTS social.community_events (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_category_id uuid NOT NULL,
  organizer_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  event_type text NOT NULL,
  event_date date NOT NULL,
  event_time time without time zone,
  end_time time without time zone,
  location_name text,
  location_address text,
  location_city_id uuid,
  max_participants integer,
  current_participants integer DEFAULT 0,
  registration_fee numeric DEFAULT 0,
  is_free boolean DEFAULT true,
  status text DEFAULT 'upcoming'::text,
  event_images jsonb DEFAULT '[]'::jsonb,
  requirements text[],
  CONSTRAINT community_events_pkey PRIMARY KEY (id),
  CONSTRAINT community_events_event_type_check CHECK (event_type = ANY (ARRAY['meetup'::text, 'workshop'::text, 'breeding_show'::text, 'veterinary_talk'::text, 'adoption_fair'::text])),
  CONSTRAINT community_events_status_check CHECK (status = ANY (ARRAY['upcoming'::text, 'ongoing'::text, 'completed'::text, 'cancelled'::text]))
);

-- content_reports
CREATE TABLE IF NOT EXISTS social.content_reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  reporter_id uuid NOT NULL,
  content_type text NOT NULL,
  content_id uuid NOT NULL,
  report_reason text NOT NULL,
  description text,
  status text DEFAULT 'pending'::text,
  moderator_id uuid,
  moderator_notes text,
  action_taken text,
  resolved_at timestamp with time zone,
  CONSTRAINT content_reports_pkey PRIMARY KEY (id),
  CONSTRAINT content_reports_content_type_check CHECK (content_type = ANY (ARRAY['forum_post'::text, 'forum_reply'::text, 'product'::text, 'review'::text, 'user_profile'::text])),
  CONSTRAINT content_reports_report_reason_check CHECK (report_reason = ANY (ARRAY['spam'::text, 'inappropriate'::text, 'harassment'::text, 'misinformation'::text, 'fake_product'::text, 'other'::text])),
  CONSTRAINT content_reports_status_check CHECK (status = ANY (ARRAY['pending'::text, 'under_review'::text, 'resolved'::text, 'dismissed'::text]))
);

-- countries
CREATE TABLE IF NOT EXISTS pos.countries (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  CONSTRAINT countries_pkey PRIMARY KEY (id)
);

-- course_categories
CREATE TABLE IF NOT EXISTS social.course_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_category_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  icon text,
  sort_order integer DEFAULT 0,
  CONSTRAINT course_categories_pkey PRIMARY KEY (id)
);

-- course_enrollments
CREATE TABLE IF NOT EXISTS social.course_enrollments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid NOT NULL,
  course_id uuid NOT NULL,
  enrollment_date timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  completion_date timestamp with time zone,
  progress_percentage integer DEFAULT 0,
  payment_status text DEFAULT 'pending'::text,
  access_expires_at timestamp with time zone,
  CONSTRAINT course_enrollments_pkey PRIMARY KEY (id),
  CONSTRAINT course_enrollments_user_id_course_id_key UNIQUE (user_id, course_id),
  CONSTRAINT course_enrollments_payment_status_check CHECK (payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'refunded'::text]))
);

-- courses
CREATE TABLE IF NOT EXISTS social.courses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  instructor_id uuid NOT NULL,
  category_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  price numeric NOT NULL,
  duration_hours numeric NOT NULL,
  level text DEFAULT 'beginner'::text,
  thumbnail_url text,
  preview_video_url text,
  rating numeric DEFAULT 0,
  student_count integer DEFAULT 0,
  is_published boolean DEFAULT false,
  CONSTRAINT courses_pkey PRIMARY KEY (id),
  CONSTRAINT courses_level_check CHECK (level = ANY (ARRAY['beginner'::text, 'intermediate'::text, 'advanced'::text]))
);

-- customer_devices
CREATE TABLE IF NOT EXISTS public.customer_devices (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  customer_id uuid NOT NULL,
  device_fingerprint text NOT NULL,
  device_name text,
  browser_info text,
  os_info text,
  ip_address text,
  is_trusted boolean DEFAULT false,
  last_used_at timestamp with time zone,
  CONSTRAINT customer_devices_pkey PRIMARY KEY (id),
  CONSTRAINT customer_devices_customer_device_unique UNIQUE (customer_id, device_fingerprint)
);

-- customers
CREATE TABLE IF NOT EXISTS public.customers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text,
  phone text NOT NULL,
  email text,
  picture_url text,
  experience_level text DEFAULT 'beginner'::text,
  total_orders integer DEFAULT 0,
  total_spent numeric DEFAULT 0,
  loyalty_points integer DEFAULT 0,
  last_order_date timestamp with time zone,
  customer_type text DEFAULT 'retail'::text,
  address text,
  city_id uuid,
  province_id uuid,
  country_id uuid,
  auth_id text,
  gender character varying,
  birth_date date,
  membership_type text DEFAULT 'free'::text,
  level integer DEFAULT 1,
  experience_points integer DEFAULT 0,
  joined_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  auth_provider text NOT NULL DEFAULT 'SUPABASE'::text,
  CONSTRAINT customers_pkey PRIMARY KEY (id),
  CONSTRAINT customers_phone_key UNIQUE (phone),
  CONSTRAINT customers_gender_check CHECK (gender::text = ANY (ARRAY['male'::character varying::text, 'female'::character varying::text, 'other'::character varying::text, 'prefer_not_to_say'::character varying::text]))
);

-- employee_documents
CREATE TABLE IF NOT EXISTS pos.employee_documents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  document_type character varying(50) NOT NULL,
  document_name character varying(255) NOT NULL,
  file_path text NOT NULL,
  file_size integer,
  mime_type character varying(100),
  description text,
  is_required boolean DEFAULT false,
  expires_at date,
  uploaded_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT employee_documents_pkey PRIMARY KEY (id),
  CONSTRAINT employee_documents_document_type_check CHECK (document_type::text = ANY (ARRAY['contract'::character varying, 'certificate'::character varying, 'id_card'::character varying, 'tax_id'::character varying, 'bank_account'::character varying, 'medical_certificate'::character varying, 'other'::character varying]::text[]))
);

-- event_participants
CREATE TABLE IF NOT EXISTS social.event_participants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  registration_date timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  attendance_status text DEFAULT 'registered'::text,
  payment_status text DEFAULT 'pending'::text,
  notes text,
  CONSTRAINT event_participants_pkey PRIMARY KEY (id),
  CONSTRAINT event_participants_event_id_user_id_key UNIQUE (event_id, user_id),
  CONSTRAINT event_participants_attendance_status_check CHECK (attendance_status = ANY (ARRAY['registered'::text, 'attended'::text, 'no_show'::text, 'cancelled'::text])),
  CONSTRAINT event_participants_payment_status_check CHECK (payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'refunded'::text]))
);

-- faqs
CREATE TABLE IF NOT EXISTS social.faqs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  category_id uuid NOT NULL,
  question text NOT NULL,
  answer text NOT NULL,
  sort_order integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  view_count integer DEFAULT 0,
  CONSTRAINT faqs_pkey PRIMARY KEY (id)
);

-- feature_flags
CREATE TABLE IF NOT EXISTS pos.feature_flags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  feature_name text NOT NULL,
  plan_id uuid,
  enabled boolean DEFAULT true,
  usage_limit integer,
  reset_period text,
  description text,
  category text,
  is_core_feature boolean DEFAULT false,
  CONSTRAINT feature_flags_pkey PRIMARY KEY (id),
  CONSTRAINT feature_flags_reset_period_check CHECK (reset_period = ANY (ARRAY['daily'::text, 'weekly'::text, 'monthly'::text, 'yearly'::text]))
);

-- feature_usage
CREATE TABLE IF NOT EXISTS pos.feature_usage (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  feature_name text NOT NULL,
  usage_count integer DEFAULT 0,
  usage_limit integer NOT NULL,
  reset_date timestamp with time zone NOT NULL,
  last_reset_date timestamp with time zone,
  usage_period text NOT NULL,
  CONSTRAINT feature_usage_pkey PRIMARY KEY (id),
  CONSTRAINT feature_usage_usage_period_check CHECK (usage_period = ANY (ARRAY['daily'::text, 'weekly'::text, 'monthly'::text, 'yearly'::text]))
);

-- forum_categories
CREATE TABLE IF NOT EXISTS social.forum_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_category_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  icon text,
  color text,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  CONSTRAINT forum_categories_pkey PRIMARY KEY (id)
);

-- forum_post_likes
CREATE TABLE IF NOT EXISTS social.forum_post_likes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  post_id uuid NOT NULL,
  user_id uuid NOT NULL,
  CONSTRAINT forum_post_likes_pkey PRIMARY KEY (id),
  CONSTRAINT forum_post_likes_post_id_user_id_key UNIQUE (post_id, user_id)
);

-- forum_posts
CREATE TABLE IF NOT EXISTS social.forum_posts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  author_id uuid NOT NULL,
  category_id uuid NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  tags text[] DEFAULT '{}'::text[],
  is_pinned boolean DEFAULT false,
  is_locked boolean DEFAULT false,
  attachments jsonb DEFAULT '[]'::jsonb,
  view_count integer DEFAULT 0,
  like_count integer DEFAULT 0,
  reply_count integer DEFAULT 0,
  CONSTRAINT forum_posts_pkey PRIMARY KEY (id)
);

-- forum_replies
CREATE TABLE IF NOT EXISTS social.forum_replies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  post_id uuid NOT NULL,
  author_id uuid NOT NULL,
  parent_reply_id uuid,
  content text NOT NULL,
  like_count integer DEFAULT 0,
  is_moderator_reply boolean DEFAULT false,
  CONSTRAINT forum_replies_pkey PRIMARY KEY (id)
);

-- inventory_transactions
CREATE TABLE IF NOT EXISTS pos.inventory_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  product_id uuid NOT NULL,
  transaction_type text NOT NULL,
  quantity integer NOT NULL,
  unit_price numeric,
  total_amount numeric,
  reference_id uuid,
  reference_type text,
  notes text,
  CONSTRAINT inventory_transactions_pkey PRIMARY KEY (id)
);

-- kb_articles
CREATE TABLE IF NOT EXISTS social.kb_articles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  category_id uuid NOT NULL,
  author_id uuid NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  excerpt text,
  tags text[] DEFAULT '{}'::text[],
  is_featured boolean DEFAULT false,
  is_expert_verified boolean DEFAULT false,
  view_count integer DEFAULT 0,
  helpful_count integer DEFAULT 0,
  status text DEFAULT 'draft'::text,
  CONSTRAINT kb_articles_pkey PRIMARY KEY (id),
  CONSTRAINT kb_articles_status_check CHECK (status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text]))
);

-- kb_categories
CREATE TABLE IF NOT EXISTS social.kb_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_category_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  icon text,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  CONSTRAINT kb_categories_pkey PRIMARY KEY (id)
);

-- leave_balances
CREATE TABLE IF NOT EXISTS pos.leave_balances (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  leave_type_id uuid NOT NULL,
  year integer NOT NULL,
  total_days integer NOT NULL DEFAULT 0,
  used_days integer DEFAULT 0,
  remaining_days integer NOT NULL DEFAULT 0,
  CONSTRAINT leave_balances_pkey PRIMARY KEY (id),
  CONSTRAINT leave_balances_user_id_leave_type_id_year_key UNIQUE (user_id, leave_type_id, year)
);

-- leave_requests
CREATE TABLE IF NOT EXISTS pos.leave_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  leave_type_id uuid NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  total_days integer NOT NULL,
  reason text,
  status character varying(20) DEFAULT 'pending'::character varying,
  approved_by uuid,
  approved_at timestamp with time zone,
  rejection_reason text,
  requested_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT leave_requests_pkey PRIMARY KEY (id),
  CONSTRAINT leave_requests_status_check CHECK (status::text = ANY (ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying, 'cancelled'::character varying]::text[]))
);

-- leave_types
CREATE TABLE IF NOT EXISTS pos.leave_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  name character varying(100) NOT NULL,
  description text,
  max_days_per_year integer,
  is_paid boolean DEFAULT true,
  requires_approval boolean DEFAULT true,
  advance_notice_days integer DEFAULT 1,
  is_active boolean DEFAULT true,
  CONSTRAINT leave_types_pkey PRIMARY KEY (id)
);

-- marketplace_transactions
CREATE TABLE IF NOT EXISTS pos.marketplace_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  transaction_number text NOT NULL,
  buyer_id uuid NOT NULL,
  seller_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity integer NOT NULL DEFAULT 1,
  unit_price numeric NOT NULL,
  total_amount numeric NOT NULL,
  payment_method text NOT NULL,
  payment_status text DEFAULT 'pending'::text,
  transaction_status text DEFAULT 'pending'::text,
  shipping_address text,
  tracking_number text,
  notes text,
  CONSTRAINT marketplace_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT marketplace_transactions_transaction_number_key UNIQUE (transaction_number),
  CONSTRAINT marketplace_transactions_payment_status_check CHECK (payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'failed'::text, 'refunded'::text])),
  CONSTRAINT marketplace_transactions_transaction_status_check CHECK (transaction_status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'shipped'::text, 'delivered'::text, 'completed'::text, 'cancelled'::text]))
);

-- merchant_customers
CREATE TABLE IF NOT EXISTS pos.merchant_customers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  merchant_id uuid NOT NULL,
  customer_id uuid NOT NULL,
  store_id uuid NOT NULL,
  joined_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  is_active boolean DEFAULT true,
  customer_code text,
  notes text,
  CONSTRAINT merchant_customers_pkey PRIMARY KEY (id)
);

-- merchant_partnerships
CREATE TABLE IF NOT EXISTS pos.merchant_partnerships (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  merchant_id uuid NOT NULL,
  store_id uuid NOT NULL,
  partnership_status text NOT NULL DEFAULT 'pending'::text,
  partnership_type text NOT NULL DEFAULT 'service_provider'::text,
  commission_rate numeric DEFAULT 0,
  service_areas jsonb,
  is_featured boolean DEFAULT false,
  partnership_start_date date,
  partnership_end_date date,
  CONSTRAINT merchant_partnerships_pkey PRIMARY KEY (id)
);

-- merchant_service_availability
CREATE TABLE IF NOT EXISTS pos.merchant_service_availability (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  service_product_id uuid NOT NULL,
  day_of_week integer NOT NULL,
  start_time time without time zone NOT NULL,
  end_time time without time zone NOT NULL,
  slot_duration_minutes integer DEFAULT 60,
  max_concurrent_bookings integer DEFAULT 1,
  is_available boolean DEFAULT true,
  CONSTRAINT merchant_service_availability_pkey PRIMARY KEY (id)
);

-- merchants
CREATE TABLE IF NOT EXISTS pos.merchants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  business_type text NOT NULL,
  phone text,
  email text,
  address text,
  city_id uuid,
  province_id uuid,
  country_id uuid,
  logo_url text,
  description text,
  is_active boolean DEFAULT true,
  owner_id uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  pet_categories_served uuid[] DEFAULT '{}'::uuid[],
  service_specializations text[] DEFAULT '{}'::text[],
  is_service_provider boolean DEFAULT false,
  CONSTRAINT merchants_pkey PRIMARY KEY (id)
);

-- payment_methods
CREATE TABLE IF NOT EXISTS pos.payment_methods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  payment_type_id uuid NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  description text,
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT payment_methods_pkey PRIMARY KEY (id)
);

-- payment_types
CREATE TABLE IF NOT EXISTS pos.payment_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  code text NOT NULL,
  name text NOT NULL,
  CONSTRAINT payment_types_pkey PRIMARY KEY (id)
);

-- payroll_records
CREATE TABLE IF NOT EXISTS pos.payroll_records (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  store_id uuid NOT NULL,
  pay_period_start date NOT NULL,
  pay_period_end date NOT NULL,
  base_salary numeric(12,2) NOT NULL,
  overtime_pay numeric(12,2) DEFAULT 0,
  commission numeric(12,2) DEFAULT 0,
  bonus numeric(12,2) DEFAULT 0,
  allowances numeric(12,2) DEFAULT 0,
  gross_pay numeric(12,2) NOT NULL,
  tax_deduction numeric(12,2) DEFAULT 0,
  insurance_deduction numeric(12,2) DEFAULT 0,
  other_deductions numeric(12,2) DEFAULT 0,
  net_pay numeric(12,2) NOT NULL,
  status character varying(20) DEFAULT 'pending'::character varying,
  processed_at timestamp with time zone,
  paid_at timestamp with time zone,
  payment_method character varying(50),
  payment_reference text,
  CONSTRAINT payroll_records_pkey PRIMARY KEY (id),
  CONSTRAINT payroll_records_status_check CHECK (status::text = ANY (ARRAY['pending'::character varying, 'processed'::character varying, 'paid'::character varying, 'cancelled'::character varying]::text[]))
);

-- pet_breeding_pairs
CREATE TABLE IF NOT EXISTS pet.pet_breeding_pairs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  male_pet_id uuid NOT NULL,
  female_pet_id uuid NOT NULL,
  pairing_date date,
  status text DEFAULT 'active'::text,
  breeding_notes text,
  offspring_count integer DEFAULT 0,
  expected_offspring_date date,
  CONSTRAINT pet_breeding_pairs_pkey PRIMARY KEY (id),
  CONSTRAINT pet_breeding_pairs_male_pet_id_female_pet_id_key UNIQUE (male_pet_id, female_pet_id),
  CONSTRAINT pet_breeding_pairs_status_check CHECK (status = ANY (ARRAY['active'::text, 'inactive'::text, 'retired'::text]))
);


-- pet_categories
CREATE TABLE IF NOT EXISTS pet.pet_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name_en text NOT NULL,
  picture_url text,
  icon_url text,
  name_id text NOT NULL,
  description text,
  CONSTRAINT pet_categories_pkey PRIMARY KEY (id)
);

-- pet_characters
CREATE TABLE IF NOT EXISTS pet.pet_characters (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_id uuid NOT NULL,
  character_id uuid NOT NULL,
  CONSTRAINT pet_characters_pkey PRIMARY KEY (id),
  CONSTRAINT pet_characters_pet_id_character_id_key UNIQUE (pet_id, character_id)
);

-- pet_healths
CREATE TABLE IF NOT EXISTS pet.pet_healths (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_id uuid NOT NULL,
  weight numeric,
  weight_history jsonb,
  vaccination_status text,
  last_vaccination_date date,
  next_vaccination_date date,
  health_notes text,
  medical_conditions text[],
  allergies text[],
  CONSTRAINT pet_healths_pkey PRIMARY KEY (id)
);

-- pet_medical_records
CREATE TABLE IF NOT EXISTS pet.pet_medical_records (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_id uuid NOT NULL,
  record_date date NOT NULL,
  record_type text NOT NULL,
  veterinarian_name text,
  veterinarian_clinic text,
  diagnosis text,
  treatment text,
  medication text,
  notes text,
  attachments jsonb DEFAULT '[]'::jsonb,
  follow_up_date date,
  cost numeric,
  CONSTRAINT pet_medical_records_pkey PRIMARY KEY (id),
  CONSTRAINT pet_medical_records_record_type_check CHECK (record_type = ANY (ARRAY['checkup'::text, 'vaccination'::text, 'treatment'::text, 'surgery'::text, 'emergency'::text]))
);

-- pet_schedules
CREATE TABLE IF NOT EXISTS pet.pet_schedules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_id uuid NOT NULL,
  schedule_type_id uuid NOT NULL,
  scheduled_at timestamp with time zone NOT NULL,
  completed_at timestamp with time zone,
  notes text,
  status text DEFAULT 'scheduled'::text,
  recurring_pattern_id uuid,
  CONSTRAINT pet_schedules_pkey PRIMARY KEY (id)
);

-- pet_weight_history
CREATE TABLE IF NOT EXISTS pet.pet_weight_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  pet_id uuid NOT NULL,
  weight_grams numeric NOT NULL,
  measurement_date date NOT NULL,
  measurement_method text DEFAULT 'manual'::text,
  notes text,
  CONSTRAINT pet_weight_history_pkey PRIMARY KEY (id),
  CONSTRAINT pet_weight_history_measurement_method_check CHECK (measurement_method = ANY (ARRAY['manual'::text, 'digital_scale'::text, 'vet_visit'::text]))
);

-- pets
CREATE TABLE IF NOT EXISTS pet.pets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  owner_id uuid NOT NULL,
  name text NOT NULL,
  pet_category_id uuid NOT NULL,
  breed text,
  birth_date date,
  gender text,
  color text,
  weight numeric,
  microchip_id text,
  picture_url text,
  story text,
  breeding_status text DEFAULT 'not_available'::text,
  color_variation text,
  adoption_date date,
  health_status text DEFAULT 'healthy'::text,
  microchip_number text,
  pedigree_info jsonb,
  activated_at timestamp without time zone,
  CONSTRAINT pets_pkey PRIMARY KEY (id),
  CONSTRAINT pets_breeding_status_check CHECK (breeding_status = ANY (ARRAY['available'::text, 'not_available'::text, 'retired'::text])),
  CONSTRAINT pets_health_status_check CHECK (health_status = ANY (ARRAY['healthy'::text, 'sick'::text, 'recovering'::text, 'needs_attention'::text]))
);

-- plan_change_requests
CREATE TABLE IF NOT EXISTS pos.plan_change_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  subscription_id uuid NOT NULL,
  from_plan_id uuid NOT NULL,
  to_plan_id uuid NOT NULL,
  change_type text NOT NULL,
  status text NOT NULL,
  effective_date timestamp with time zone,
  proration_amount numeric DEFAULT 0,
  credit_amount numeric DEFAULT 0,
  reason text,
  admin_notes text,
  processed_at timestamp with time zone,
  processed_by uuid,
  CONSTRAINT plan_change_requests_pkey PRIMARY KEY (id),
  CONSTRAINT plan_change_requests_change_type_check CHECK (change_type = ANY (ARRAY['upgrade'::text, 'downgrade'::text])),
  CONSTRAINT plan_change_requests_status_check CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'completed'::text, 'cancelled'::text]))
);

-- pricing_faq
CREATE TABLE IF NOT EXISTS pos.pricing_faq (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  question text NOT NULL,
  answer text NOT NULL,
  category text NOT NULL,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  CONSTRAINT pricing_faq_pkey PRIMARY KEY (id)
);

-- product_favorites
CREATE TABLE IF NOT EXISTS social.product_favorites (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  product_id uuid NOT NULL,
  user_id uuid NOT NULL,
  CONSTRAINT product_favorites_pkey PRIMARY KEY (id),
  CONSTRAINT product_favorites_product_id_user_id_key UNIQUE (product_id, user_id)
);

-- product_images
CREATE TABLE IF NOT EXISTS pos.product_images (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  product_id uuid NOT NULL,
  image_url text NOT NULL,
  alt_text text,
  sort_order integer DEFAULT 0,
  is_primary boolean DEFAULT false,
  file_size integer,
  mime_type text,
  width integer,
  height integer,
  CONSTRAINT product_images_pkey PRIMARY KEY (id)
);

-- product_reviews
CREATE TABLE IF NOT EXISTS social.product_reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  product_id uuid NOT NULL,
  reviewer_id uuid NOT NULL,
  booking_id uuid,
  review_type text DEFAULT 'product'::text,
  rating integer NOT NULL,
  professionalism_rating integer,
  expertise_rating integer,
  facilities_rating integer,
  results_rating integer,
  review_text text,
  review_images jsonb DEFAULT '[]'::jsonb,
  is_verified_purchase boolean DEFAULT false,
  is_anonymous boolean DEFAULT false,
  helpful_count integer DEFAULT 0,
  seller_response text,
  seller_response_date timestamp with time zone,
  CONSTRAINT product_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT product_reviews_product_id_reviewer_id_booking_id_key UNIQUE (product_id, reviewer_id, booking_id),
  CONSTRAINT product_reviews_review_type_check CHECK (review_type = ANY (ARRAY['product'::text, 'service'::text])),
  CONSTRAINT product_reviews_rating_check CHECK (rating >= 1 AND rating <= 5),
  CONSTRAINT product_reviews_professionalism_rating_check CHECK (professionalism_rating >= 1 AND professionalism_rating <= 5),
  CONSTRAINT product_reviews_expertise_rating_check CHECK (expertise_rating >= 1 AND expertise_rating <= 5),
  CONSTRAINT product_reviews_facilities_rating_check CHECK (facilities_rating >= 1 AND facilities_rating <= 5),
  CONSTRAINT product_reviews_results_rating_check CHECK (results_rating >= 1 AND results_rating <= 5)
);

-- products
CREATE TABLE IF NOT EXISTS pos.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  category_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  cost_price numeric,
  stock_quantity integer DEFAULT 0,
  min_stock_level integer DEFAULT 0,
  max_stock_level integer,
  barcode text,
  sku text,
  picture_url text,
  is_active boolean DEFAULT true,
  purchase_price numeric NOT NULL DEFAULT 0,
  min_stock integer NOT NULL DEFAULT 0,
  unit text DEFAULT 'pcs'::text,
  weight_grams integer NOT NULL DEFAULT 0,
  stock integer NOT NULL DEFAULT 0,
  code text,
  product_type text DEFAULT 'item'::text,
  duration_minutes integer,
  service_category text,
  discount_type integer NOT NULL DEFAULT 1,
  discount_value numeric NOT NULL DEFAULT 0,
  seller_id uuid,
  condition text DEFAULT 'new'::text,
  availability text DEFAULT 'available'::text,
  location_city_id uuid,
  view_count integer DEFAULT 0,
  favorite_count integer DEFAULT 0,
  rating numeric DEFAULT 0,
  review_count integer DEFAULT 0,
  sold_count integer DEFAULT 0,
  specifications jsonb DEFAULT '{}'::jsonb,
  target_pet_category_id uuid,
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_code_key UNIQUE (code),
  CONSTRAINT products_condition_check CHECK (condition = ANY (ARRAY['new'::text, 'used'::text, 'refurbished'::text])),
  CONSTRAINT products_availability_check CHECK (availability = ANY (ARRAY['available'::text, 'sold'::text, 'reserved'::text]))
);

-- products_categories
CREATE TABLE IF NOT EXISTS pos.products_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  picture_url text,
  store_id uuid NOT NULL,
  pet_category_id uuid,
  description text,
  type text NOT NULL DEFAULT 'item'::text,
  CONSTRAINT products_categories_pkey PRIMARY KEY (id)
);

-- provinces
CREATE TABLE IF NOT EXISTS pos.provinces (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  country_id uuid NOT NULL,
  CONSTRAINT provinces_pkey PRIMARY KEY (id)
);

-- push_notifications
CREATE TABLE IF NOT EXISTS social.push_notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid NOT NULL,
  title text NOT NULL,
  body text NOT NULL,
  notification_type text NOT NULL,
  data jsonb DEFAULT '{}'::jsonb,
  is_read boolean DEFAULT false,
  read_at timestamp with time zone,
  sent_at timestamp with time zone,
  fcm_message_id text,
  CONSTRAINT push_notifications_pkey PRIMARY KEY (id),
  CONSTRAINT push_notifications_notification_type_check CHECK (notification_type = ANY (ARRAY['reminder'::text, 'forum'::text, 'marketplace'::text, 'booking'::text, 'event'::text, 'system'::text]))
);

-- referral_agents
CREATE TABLE IF NOT EXISTS pos.referral_agents (
  id uuid NOT NULL,
  name text NOT NULL,
  email text NOT NULL,
  phone text,
  referral_code text NOT NULL,
  is_active boolean DEFAULT true,
  total_referrals integer DEFAULT 0,
  total_earnings numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  registered_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  bank_account text,
  bank_name text,
  account_holder_name text,
  CONSTRAINT referral_agents_pkey PRIMARY KEY (id),
  CONSTRAINT referral_agents_email_unique UNIQUE (email),
  CONSTRAINT referral_agents_phone_unique UNIQUE (phone),
  CONSTRAINT referral_agents_referral_code_key UNIQUE (referral_code)
);

-- referral_commissions
CREATE TABLE IF NOT EXISTS pos.referral_commissions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  agent_id uuid NOT NULL,
  user_id uuid NOT NULL,
  subscription_id uuid NOT NULL,
  amount numeric NOT NULL,
  status text NOT NULL,
  commission_date timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  payment_date timestamp with time zone,
  billing_period_start timestamp with time zone NOT NULL,
  billing_period_end timestamp with time zone NOT NULL,
  CONSTRAINT referral_commissions_pkey PRIMARY KEY (id),
  CONSTRAINT referral_commissions_status_check CHECK (status = ANY (ARRAY['pending'::text, 'paid'::text, 'cancelled'::text]))
);

-- referral_payments
CREATE TABLE IF NOT EXISTS pos.referral_payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  agent_id uuid NOT NULL,
  total_amount numeric NOT NULL,
  payment_date timestamp with time zone,
  status text NOT NULL,
  payment_method text NOT NULL,
  transaction_reference text,
  commission_ids uuid[] NOT NULL,
  CONSTRAINT referral_payments_pkey PRIMARY KEY (id),
  CONSTRAINT referral_payments_status_check CHECK (status = ANY (ARRAY['pending'::text, 'paid'::text, 'failed'::text, 'cancelled'::text]))
);

-- referral_settings
CREATE TABLE IF NOT EXISTS pos.referral_settings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  commission_amount numeric NOT NULL DEFAULT 20000,
  payment_frequency text NOT NULL DEFAULT 'monthly'::text,
  minimum_payout numeric NOT NULL DEFAULT 100000,
  is_active boolean DEFAULT true,
  CONSTRAINT referral_settings_pkey PRIMARY KEY (id),
  CONSTRAINT referral_settings_payment_frequency_check CHECK (payment_frequency = ANY (ARRAY['weekly'::text, 'monthly'::text, 'quarterly'::text]))
);

-- role_assignments
CREATE TABLE IF NOT EXISTS pos.role_assignments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  merchant_id uuid NOT NULL,
  role_id uuid NOT NULL,
  store_id uuid NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT role_assignments_pkey PRIMARY KEY (id)
);

-- roles
CREATE TABLE IF NOT EXISTS pos.roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  description text,
  permissions text[],
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);

-- sales
CREATE TABLE IF NOT EXISTS pos.sales (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  customer_id uuid,
  user_id uuid NOT NULL,
  sale_number text NOT NULL,
  sale_date timestamp with time zone NOT NULL,
  subtotal numeric NOT NULL,
  discount_amount numeric DEFAULT 0,
  tax_amount numeric DEFAULT 0,
  total_amount numeric NOT NULL,
  payment_method_id uuid,
  payment_status text DEFAULT 'pending'::text,
  status text DEFAULT 'completed'::text,
  notes text,
  CONSTRAINT sales_pkey PRIMARY KEY (id)
);

-- sales_items
CREATE TABLE IF NOT EXISTS pos.sales_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  sale_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity integer NOT NULL,
  unit_price numeric NOT NULL,
  discount_amount numeric DEFAULT 0,
  total_amount numeric NOT NULL,
  notes text,
  item_type text DEFAULT 'product'::text,
  booking_date date,
  booking_time time without time zone,
  duration_minutes integer,
  assigned_staff_id uuid,
  customer_notes text,
  booking_reference text,
  CONSTRAINT sales_items_pkey PRIMARY KEY (id)
);

-- schedule_recurring_patterns
CREATE TABLE IF NOT EXISTS pet.schedule_recurring_patterns (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pattern_type text NOT NULL,
  interval_value integer NOT NULL,
  end_date date,
  is_active boolean DEFAULT true,
  CONSTRAINT schedule_recurring_patterns_pkey PRIMARY KEY (id)
);

-- schedule_types
CREATE TABLE IF NOT EXISTS pet.schedule_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  description text,
  icon text,
  color text,
  is_recurring boolean DEFAULT false,
  default_duration_minutes integer DEFAULT 60,
  CONSTRAINT schedule_types_pkey PRIMARY KEY (id)
);

-- service_bookings
CREATE TABLE IF NOT EXISTS pos.service_bookings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  booking_source text NOT NULL,
  booking_reference text,
  customer_id uuid NOT NULL,
  pet_id uuid,
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  customer_email text,
  store_id uuid NOT NULL,
  service_product_id uuid NOT NULL,
  service_name text NOT NULL,
  booking_date date NOT NULL,
  booking_time time without time zone NOT NULL,
  duration_minutes integer NOT NULL,
  service_type text NOT NULL DEFAULT 'in_store'::text,
  customer_address text,
  latitude numeric,
  longitude numeric,
  status text NOT NULL DEFAULT 'pending'::text,
  payment_status text NOT NULL DEFAULT 'pending'::text,
  service_fee numeric NOT NULL DEFAULT 0,
  on_site_fee numeric DEFAULT 0,
  discount_amount numeric DEFAULT 0,
  total_amount numeric NOT NULL DEFAULT 0,
  assigned_staff_id uuid,
  staff_notes text,
  customer_notes text,
  allnimall_commission numeric DEFAULT 0,
  partnership_id uuid,
  sale_id uuid,
  CONSTRAINT service_bookings_pkey PRIMARY KEY (id),
  CONSTRAINT service_bookings_booking_reference_key UNIQUE (booking_reference)
);

-- store_business_hours
CREATE TABLE IF NOT EXISTS pos.store_business_hours (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  day_of_week integer NOT NULL,
  is_open boolean DEFAULT true,
  open_time time without time zone,
  close_time time without time zone,
  break_start_time time without time zone,
  break_end_time time without time zone,
  is_24_hours boolean DEFAULT false,
  notes text,
  CONSTRAINT store_business_hours_pkey PRIMARY KEY (id),
  CONSTRAINT store_business_hours_store_id_day_of_week_key UNIQUE (store_id, day_of_week),
  CONSTRAINT store_business_hours_day_of_week_check CHECK (day_of_week >= 0 AND day_of_week <= 6)
);

-- store_cart_items
CREATE TABLE IF NOT EXISTS pos.store_cart_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  cart_id uuid NOT NULL,
  product_id uuid NOT NULL,
  quantity smallint NOT NULL DEFAULT 1,
  unit_price numeric NOT NULL DEFAULT 0,
  item_type text DEFAULT 'product'::text,
  booking_date date,
  booking_time time without time zone,
  duration_minutes integer,
  assigned_staff_id uuid,
  customer_notes text,
  booking_reference text,
  CONSTRAINT store_cart_items_pkey PRIMARY KEY (id)
);

-- store_carts
CREATE TABLE IF NOT EXISTS pos.store_carts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  session_id text,
  customer_id uuid,
  status text NOT NULL DEFAULT 'active'::text,
  CONSTRAINT store_carts_pkey PRIMARY KEY (id)
);

-- store_payment_methods
CREATE TABLE IF NOT EXISTS pos.store_payment_methods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  payment_method_id uuid NOT NULL,
  is_active boolean DEFAULT true,
  CONSTRAINT store_payment_methods_pkey PRIMARY KEY (id),
  CONSTRAINT store_payment_methods_store_id_payment_method_id_key UNIQUE (store_id, payment_method_id)
);

-- stores
CREATE TABLE IF NOT EXISTS pos.stores (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  merchant_id uuid NOT NULL,
  name text NOT NULL,
  address text,
  city_id uuid,
  province_id uuid,
  country_id uuid,
  phone text,
  email text,
  is_active boolean DEFAULT true,
  business_field text NOT NULL DEFAULT 'pet_shop'::text,
  business_description text,
  phone_number text,
  phone_country_code text,
  timezone text DEFAULT 'Asia/Jakarta'::text,
  currency text DEFAULT 'IDR'::text,
  tax_rate numeric DEFAULT 0.11,
  tax_inclusive boolean DEFAULT true,
  receipt_format text DEFAULT 'standard'::text,
  receipt_footer text,
  low_stock_threshold integer DEFAULT 10,
  auto_reorder boolean DEFAULT false,
  customer_loyalty_enabled boolean DEFAULT false,
  loyalty_points_rate numeric DEFAULT 0.01,
  notification_email text,
  notification_sms text,
  business_license text,
  tax_id text,
  website_url text,
  social_media jsonb DEFAULT '{}'::jsonb,
  payment_methods jsonb DEFAULT '["cash", "card"]'::jsonb,
  delivery_enabled boolean DEFAULT false,
  delivery_radius integer DEFAULT 5,
  delivery_fee numeric DEFAULT 0,
  min_order_amount numeric DEFAULT 0,
  CONSTRAINT stores_pkey PRIMARY KEY (id)
);

-- subscription_notifications
CREATE TABLE IF NOT EXISTS pos.subscription_notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid NOT NULL,
  subscription_id uuid,
  notification_type text NOT NULL,
  title text NOT NULL,
  message text NOT NULL,
  is_read boolean DEFAULT false,
  read_at timestamp with time zone,
  action_url text,
  metadata jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT subscription_notifications_pkey PRIMARY KEY (id),
  CONSTRAINT subscription_notifications_notification_type_check CHECK (notification_type = ANY (ARRAY['payment_due'::text, 'payment_failed'::text, 'subscription_expiring'::text, 'subscription_expired'::text, 'usage_warning'::text, 'usage_exceeded'::text, 'plan_change'::text, 'trial_ending'::text]))
);

-- subscription_plans
CREATE TABLE IF NOT EXISTS pos.subscription_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  description text,
  price numeric NOT NULL,
  billing_cycle text NOT NULL,
  features jsonb NOT NULL DEFAULT '[]'::jsonb,
  limits jsonb NOT NULL DEFAULT '{}'::jsonb,
  restrictions jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  stripe_price_id text,
  sort_order integer DEFAULT 0,
  display_name text,
  short_description text,
  popular boolean DEFAULT false,
  badge_text text,
  badge_color text DEFAULT 'blue'::text,
  icon_url text,
  color_scheme text DEFAULT 'blue'::text,
  trial_days integer DEFAULT 14,
  setup_fee numeric DEFAULT 0,
  cancellation_fee numeric DEFAULT 0,
  max_stores integer DEFAULT 1,
  max_users integer DEFAULT 1,
  max_products integer DEFAULT 100,
  max_customers integer DEFAULT 1000,
  storage_gb integer DEFAULT 1,
  api_calls_per_month integer DEFAULT 1000,
  support_level text DEFAULT 'email'::text,
  sla_percentage integer DEFAULT 99,
  CONSTRAINT subscription_plans_pkey PRIMARY KEY (id),
  CONSTRAINT subscription_plans_billing_cycle_check CHECK (billing_cycle = ANY (ARRAY['monthly'::text, 'yearly'::text]))
);

-- subscription_usage_analytics
CREATE TABLE IF NOT EXISTS pos.subscription_usage_analytics (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid NOT NULL,
  subscription_id uuid NOT NULL,
  period_start timestamp with time zone NOT NULL,
  period_end timestamp with time zone NOT NULL,
  stores_used integer DEFAULT 0,
  users_used integer DEFAULT 0,
  products_used integer DEFAULT 0,
  customers_used integer DEFAULT 0,
  storage_used_gb numeric DEFAULT 0,
  api_calls_used integer DEFAULT 0,
  features_used jsonb DEFAULT '{}'::jsonb,
  usage_percentage jsonb DEFAULT '{}'::jsonb,
  overage_amount numeric DEFAULT 0,
  overage_fee numeric DEFAULT 0,
  CONSTRAINT subscription_usage_analytics_pkey PRIMARY KEY (id)
);

-- user_achievement_unlocks
CREATE TABLE IF NOT EXISTS social.user_achievement_unlocks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid NOT NULL,
  achievement_id uuid NOT NULL,
  unlocked_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT user_achievement_unlocks_pkey PRIMARY KEY (id),
  CONSTRAINT user_achievement_unlocks_user_id_achievement_id_key UNIQUE (user_id, achievement_id)
);

-- user_achievements
CREATE TABLE IF NOT EXISTS social.user_achievements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  name text NOT NULL,
  description text,
  icon text,
  badge_color text,
  xp_reward integer DEFAULT 0,
  achievement_type text NOT NULL,
  criteria jsonb NOT NULL,
  CONSTRAINT user_achievements_pkey PRIMARY KEY (id)
);

-- user_devices
CREATE TABLE IF NOT EXISTS public.user_devices (
  id uuid NOT NULL DEFAULT extensions.uuid_generate_v4(),
  user_id uuid NOT NULL,
  device_fingerprint text NOT NULL,
  device_name text,
  browser_info text,
  os_info text,
  ip_address inet,
  is_trusted boolean DEFAULT false,
  last_used_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_devices_pkey PRIMARY KEY (id),
  CONSTRAINT unique_user_device UNIQUE (user_id, device_fingerprint),
  CONSTRAINT device_fingerprint_not_empty CHECK (length(device_fingerprint) > 0),
  CONSTRAINT device_name_length CHECK (device_name IS NULL OR length(device_name) <= 100)
);

-- user_levels
CREATE TABLE IF NOT EXISTS social.user_levels (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  level integer NOT NULL,
  name text NOT NULL,
  min_xp integer NOT NULL,
  max_xp integer,
  badge_icon text,
  badge_color text,
  benefits jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT user_levels_pkey PRIMARY KEY (id),
  CONSTRAINT user_levels_level_key UNIQUE (level)
);

-- user_preferences
CREATE TABLE IF NOT EXISTS social.user_preferences (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  updated_at timestamp with time zone,
  user_id uuid NOT NULL,
  notification_settings jsonb DEFAULT '{"push": true, "email": true, "forum": true, "events": true, "marketplace": true}'::jsonb,
  privacy_settings jsonb DEFAULT '{"show_email": false, "show_phone": false, "profile_public": true}'::jsonb,
  language text DEFAULT 'id'::text,
  timezone text DEFAULT 'Asia/Jakarta'::text,
  CONSTRAINT user_preferences_pkey PRIMARY KEY (id),
  CONSTRAINT user_preferences_user_id_key UNIQUE (user_id)
);

-- user_subscriptions
CREATE TABLE IF NOT EXISTS pos.user_subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  plan_id uuid NOT NULL,
  status text NOT NULL,
  stripe_subscription_id text,
  stripe_customer_id text,
  start_date timestamp with time zone NOT NULL,
  end_date timestamp with time zone,
  next_billing_date timestamp with time zone,
  trial_end_date timestamp with time zone,
  cancelled_at timestamp with time zone,
  cancellation_reason text,
  auto_renew boolean DEFAULT true,
  current_period_start timestamp with time zone,
  current_period_end timestamp with time zone,
  cancel_at_period_end boolean DEFAULT false,
  proration_amount numeric DEFAULT 0,
  upgrade_credit numeric DEFAULT 0,
  downgrade_credit numeric DEFAULT 0,
  change_effective_date timestamp with time zone,
  change_reason text,
  last_payment_date timestamp with time zone,
  last_payment_amount numeric,
  payment_failure_count integer DEFAULT 0,
  grace_period_end timestamp with time zone,
  suspension_reason text,
  reactivation_date timestamp with time zone,
  referral_code text,
  agent_id uuid,
  CONSTRAINT user_subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT user_subscriptions_status_check CHECK (status = ANY (ARRAY['active'::text, 'trial'::text, 'cancelled'::text, 'expired'::text, 'past_due'::text]))
);

-- user_warnings
CREATE TABLE IF NOT EXISTS social.user_warnings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid NOT NULL,
  moderator_id uuid NOT NULL,
  warning_type text NOT NULL,
  reason text NOT NULL,
  description text,
  severity text DEFAULT 'low'::text,
  expires_at timestamp with time zone,
  is_active boolean DEFAULT true,
  CONSTRAINT user_warnings_pkey PRIMARY KEY (id),
  CONSTRAINT user_warnings_warning_type_check CHECK (warning_type = ANY (ARRAY['spam'::text, 'inappropriate_content'::text, 'harassment'::text, 'fake_listing'::text, 'violation'::text])),
  CONSTRAINT user_warnings_severity_check CHECK (severity = ANY (ARRAY['low'::text, 'medium'::text, 'high'::text]))
);

-- users
CREATE TABLE IF NOT EXISTS public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  phone text NOT NULL,
  email text NOT NULL,
  picture_url text,
  is_active boolean DEFAULT true,
  staff_type text DEFAULT 'cashier'::text,
  auth_id uuid,
  username text,
  employee_id character varying(50),
  position character varying(100),
  department character varying(100),
  hire_date date,
  salary numeric(12,2),
  employment_status character varying(20) DEFAULT 'active'::character varying,
  emergency_contact_name character varying(100),
  emergency_contact_phone character varying(20),
  address text,
  birth_date date,
  gender character varying(10),
  marital_status character varying(20),
  tax_id character varying(50),
  bank_account character varying(50),
  bank_name character varying(100),
  membership_type text DEFAULT 'free'::text,
  level integer DEFAULT 1,
  experience_points integer DEFAULT 0,
  location_city_id uuid,
  is_verified boolean DEFAULT false,
  bio text,
  forum_posts_count integer DEFAULT 0,
  transactions_count integer DEFAULT 0,
  seller_rating numeric DEFAULT 0,
  events_attended_count integer DEFAULT 0,
  joined_date timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_email_key UNIQUE (email),
  CONSTRAINT users_phone_key UNIQUE (phone),
  CONSTRAINT users_username_key UNIQUE (username),
  CONSTRAINT users_employee_id_key UNIQUE (employee_id),
  CONSTRAINT users_employment_status_check CHECK (employment_status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'terminated'::character varying, 'on_leave'::character varying]::text[])),
  CONSTRAINT users_gender_check CHECK (gender::text = ANY (ARRAY['male'::character varying, 'female'::character varying, 'other'::character varying]::text[])),
  CONSTRAINT users_marital_status_check CHECK (marital_status::text = ANY (ARRAY['single'::character varying, 'married'::character varying, 'divorced'::character varying, 'widowed'::character varying]::text[])),
  CONSTRAINT users_membership_type_check CHECK (membership_type = ANY (ARRAY['free'::text, 'premium'::text, 'professional'::text]))
);

-- xp_transactions
CREATE TABLE IF NOT EXISTS social.xp_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid NOT NULL,
  xp_amount integer NOT NULL,
  xp_type text NOT NULL,
  reference_id uuid,
  reference_type text,
  description text,
  CONSTRAINT xp_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT xp_transactions_xp_type_check CHECK (xp_type = ANY (ARRAY['forum_post'::text, 'forum_reply'::text, 'helpful_answer'::text, 'product_sold'::text, 'event_attended'::text, 'achievement'::text]))
);


-- ================================
-- FOREIGN KEY CONSTRAINTS
-- ================================

-- Public Schema
ALTER TABLE public.activity_logs ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE public.customer_devices ADD CONSTRAINT customer_devices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE public.customers ADD CONSTRAINT customers_city_id_fkey FOREIGN KEY (city_id) REFERENCES pos.cities(id);
ALTER TABLE public.customers ADD CONSTRAINT customers_province_id_fkey FOREIGN KEY (province_id) REFERENCES pos.provinces(id);
ALTER TABLE public.customers ADD CONSTRAINT customers_country_id_fkey FOREIGN KEY (country_id) REFERENCES pos.countries(id);
ALTER TABLE public.user_devices ADD CONSTRAINT user_devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE public.users ADD CONSTRAINT users_location_city_id_fkey FOREIGN KEY (location_city_id) REFERENCES pos.cities(id);

-- Pet Schema
ALTER TABLE pet.pet_breeding_pairs ADD CONSTRAINT pet_breeding_pairs_male_pet_id_fkey FOREIGN KEY (male_pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_breeding_pairs ADD CONSTRAINT pet_breeding_pairs_female_pet_id_fkey FOREIGN KEY (female_pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_characters ADD CONSTRAINT pet_characters_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_characters ADD CONSTRAINT pet_characters_character_id_fkey FOREIGN KEY (character_id) REFERENCES pet.characters(id);
ALTER TABLE pet.pet_healths ADD CONSTRAINT pet_healths_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_medical_records ADD CONSTRAINT pet_medical_records_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_photos ADD CONSTRAINT pet_photos_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_scan_logs ADD CONSTRAINT pet_scan_logs_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_schedules ADD CONSTRAINT pet_schedules_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_schedules ADD CONSTRAINT pet_schedules_schedule_type_id_fkey FOREIGN KEY (schedule_type_id) REFERENCES pet.schedule_types(id);
ALTER TABLE pet.pet_weight_history ADD CONSTRAINT pet_weight_history_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pets ADD CONSTRAINT pets_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.customers(id);
ALTER TABLE pet.pets ADD CONSTRAINT pets_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);

-- Social Schema
ALTER TABLE social.community_events ADD CONSTRAINT community_events_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE social.community_events ADD CONSTRAINT community_events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES public.users(id);
ALTER TABLE social.community_events ADD CONSTRAINT community_events_location_city_id_fkey FOREIGN KEY (location_city_id) REFERENCES pos.cities(id);
ALTER TABLE social.content_reports ADD CONSTRAINT content_reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.users(id);
ALTER TABLE social.content_reports ADD CONSTRAINT content_reports_moderator_id_fkey FOREIGN KEY (moderator_id) REFERENCES public.users(id);
ALTER TABLE social.course_categories ADD CONSTRAINT course_categories_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE social.courses ADD CONSTRAINT courses_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES public.users(id);
ALTER TABLE social.courses ADD CONSTRAINT courses_category_id_fkey FOREIGN KEY (category_id) REFERENCES social.course_categories(id);
ALTER TABLE social.course_enrollments ADD CONSTRAINT course_enrollments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.course_enrollments ADD CONSTRAINT course_enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES social.courses(id);
ALTER TABLE social.event_participants ADD CONSTRAINT event_participants_event_id_fkey FOREIGN KEY (event_id) REFERENCES social.community_events(id);
ALTER TABLE social.event_participants ADD CONSTRAINT event_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.faqs ADD CONSTRAINT faqs_category_id_fkey FOREIGN KEY (category_id) REFERENCES social.kb_categories(id);
ALTER TABLE social.forum_categories ADD CONSTRAINT forum_categories_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE social.forum_posts ADD CONSTRAINT forum_posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);
ALTER TABLE social.forum_posts ADD CONSTRAINT forum_posts_category_id_fkey FOREIGN KEY (category_id) REFERENCES social.forum_categories(id);
ALTER TABLE social.forum_replies ADD CONSTRAINT forum_replies_post_id_fkey FOREIGN KEY (post_id) REFERENCES social.forum_posts(id);
ALTER TABLE social.forum_replies ADD CONSTRAINT forum_replies_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);
ALTER TABLE social.forum_replies ADD CONSTRAINT forum_replies_parent_reply_id_fkey FOREIGN KEY (parent_reply_id) REFERENCES social.forum_replies(id);
ALTER TABLE social.forum_post_likes ADD CONSTRAINT forum_post_likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES social.forum_posts(id);
ALTER TABLE social.forum_post_likes ADD CONSTRAINT forum_post_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.kb_categories ADD CONSTRAINT kb_categories_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE social.kb_articles ADD CONSTRAINT kb_articles_category_id_fkey FOREIGN KEY (category_id) REFERENCES social.kb_categories(id);
ALTER TABLE social.kb_articles ADD CONSTRAINT kb_articles_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);
ALTER TABLE social.product_favorites ADD CONSTRAINT product_favorites_product_id_fkey FOREIGN KEY (product_id) REFERENCES pos.products(id);
ALTER TABLE social.product_favorites ADD CONSTRAINT product_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.product_reviews ADD CONSTRAINT product_reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES pos.products(id);
ALTER TABLE social.product_reviews ADD CONSTRAINT product_reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id);
ALTER TABLE social.product_reviews ADD CONSTRAINT product_reviews_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES pos.service_bookings(id);
ALTER TABLE social.push_notifications ADD CONSTRAINT push_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.user_achievement_unlocks ADD CONSTRAINT user_achievement_unlocks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.user_achievement_unlocks ADD CONSTRAINT user_achievement_unlocks_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES social.user_achievements(id);
ALTER TABLE social.user_preferences ADD CONSTRAINT user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.user_warnings ADD CONSTRAINT user_warnings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.user_warnings ADD CONSTRAINT user_warnings_moderator_id_fkey FOREIGN KEY (moderator_id) REFERENCES public.users(id);
ALTER TABLE social.xp_transactions ADD CONSTRAINT xp_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);

-- POS Schema  
ALTER TABLE pos.attendance_records ADD CONSTRAINT attendance_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE pos.attendance_records ADD CONSTRAINT attendance_records_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.attendance_records ADD CONSTRAINT attendance_records_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);
ALTER TABLE pos.billing_invoices ADD CONSTRAINT billing_invoices_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES pos.user_subscriptions(id);
ALTER TABLE pos.billing_payments ADD CONSTRAINT billing_payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES pos.billing_invoices(id);
ALTER TABLE pos.cities ADD CONSTRAINT cities_province_id_fkey FOREIGN KEY (province_id) REFERENCES pos.provinces(id);

ALTER TABLE pos.commission_records ADD CONSTRAINT commission_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE pos.commission_records ADD CONSTRAINT commission_records_pay_period_id_fkey FOREIGN KEY (pay_period_id) REFERENCES pos.payroll_records(id);
ALTER TABLE pos.employee_documents ADD CONSTRAINT employee_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE pos.feature_flags ADD CONSTRAINT feature_flags_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES pos.subscription_plans(id);
ALTER TABLE pos.inventory_transactions ADD CONSTRAINT inventory_transactions_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.inventory_transactions ADD CONSTRAINT inventory_transactions_product_id_fkey FOREIGN KEY (product_id) REFERENCES pos.products(id);
ALTER TABLE pos.leave_types ADD CONSTRAINT leave_types_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.leave_requests ADD CONSTRAINT leave_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE pos.leave_requests ADD CONSTRAINT leave_requests_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES pos.leave_types(id);
ALTER TABLE pos.leave_requests ADD CONSTRAINT leave_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);
ALTER TABLE pos.leave_balances ADD CONSTRAINT leave_balances_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE pos.leave_balances ADD CONSTRAINT leave_balances_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES pos.leave_types(id);
ALTER TABLE pos.marketplace_transactions ADD CONSTRAINT marketplace_transactions_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public.users(id);
ALTER TABLE pos.marketplace_transactions ADD CONSTRAINT marketplace_transactions_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.users(id);
ALTER TABLE pos.marketplace_transactions ADD CONSTRAINT marketplace_transactions_product_id_fkey FOREIGN KEY (product_id) REFERENCES pos.products(id);
ALTER TABLE pos.merchant_customers ADD CONSTRAINT merchant_customers_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES pos.merchants(id);
ALTER TABLE pos.merchant_customers ADD CONSTRAINT merchant_customers_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE pos.merchant_customers ADD CONSTRAINT merchant_customers_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.merchant_partnerships ADD CONSTRAINT merchant_partnerships_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES pos.merchants(id);
ALTER TABLE pos.merchant_partnerships ADD CONSTRAINT merchant_partnerships_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.merchant_service_availability ADD CONSTRAINT merchant_service_availability_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.merchant_service_availability ADD CONSTRAINT merchant_service_availability_service_product_id_fkey FOREIGN KEY (service_product_id) REFERENCES pos.products(id);
ALTER TABLE pos.merchants ADD CONSTRAINT merchants_city_id_fkey FOREIGN KEY (city_id) REFERENCES pos.cities(id);
ALTER TABLE pos.merchants ADD CONSTRAINT merchants_province_id_fkey FOREIGN KEY (province_id) REFERENCES pos.provinces(id);
ALTER TABLE pos.merchants ADD CONSTRAINT merchants_country_id_fkey FOREIGN KEY (country_id) REFERENCES pos.countries(id);
ALTER TABLE pos.payment_methods ADD CONSTRAINT payment_methods_payment_type_id_fkey FOREIGN KEY (payment_type_id) REFERENCES pos.payment_types(id);
ALTER TABLE pos.payroll_records ADD CONSTRAINT payroll_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE pos.payroll_records ADD CONSTRAINT payroll_records_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.plan_change_requests ADD CONSTRAINT plan_change_requests_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES pos.user_subscriptions(id);
ALTER TABLE pos.plan_change_requests ADD CONSTRAINT plan_change_requests_from_plan_id_fkey FOREIGN KEY (from_plan_id) REFERENCES pos.subscription_plans(id);
ALTER TABLE pos.plan_change_requests ADD CONSTRAINT plan_change_requests_to_plan_id_fkey FOREIGN KEY (to_plan_id) REFERENCES pos.subscription_plans(id);
ALTER TABLE pos.product_images ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES pos.products(id);
ALTER TABLE pos.products ADD CONSTRAINT products_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.products ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES pos.products_categories(id);
ALTER TABLE pos.products ADD CONSTRAINT products_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.users(id);
ALTER TABLE pos.products ADD CONSTRAINT products_location_city_id_fkey FOREIGN KEY (location_city_id) REFERENCES pos.cities(id);
ALTER TABLE pos.products ADD CONSTRAINT products_target_pet_category_id_fkey FOREIGN KEY (target_pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE pos.products_categories ADD CONSTRAINT products_categories_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE pos.provinces ADD CONSTRAINT provinces_country_id_fkey FOREIGN KEY (country_id) REFERENCES pos.countries(id);
ALTER TABLE pos.referral_commissions ADD CONSTRAINT referral_commissions_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES pos.referral_agents(id);
ALTER TABLE pos.referral_commissions ADD CONSTRAINT referral_commissions_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES pos.user_subscriptions(id);
ALTER TABLE pos.referral_payments ADD CONSTRAINT referral_payments_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES pos.referral_agents(id);
ALTER TABLE pos.role_assignments ADD CONSTRAINT role_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE pos.role_assignments ADD CONSTRAINT role_assignments_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES pos.merchants(id);
ALTER TABLE pos.role_assignments ADD CONSTRAINT role_assignments_role_id_fkey FOREIGN KEY (role_id) REFERENCES pos.roles(id);
ALTER TABLE pos.role_assignments ADD CONSTRAINT role_assignments_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.sales ADD CONSTRAINT sales_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.sales ADD CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE pos.sales ADD CONSTRAINT sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE pos.sales ADD CONSTRAINT sales_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES pos.payment_methods(id);
ALTER TABLE pos.sales_items ADD CONSTRAINT sales_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES pos.sales(id);
ALTER TABLE pos.sales_items ADD CONSTRAINT sales_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES pos.products(id);
ALTER TABLE pos.sales_items ADD CONSTRAINT fk_sales_items_assigned_staff FOREIGN KEY (assigned_staff_id) REFERENCES public.users(id);
ALTER TABLE pos.service_bookings ADD CONSTRAINT service_bookings_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE pos.service_bookings ADD CONSTRAINT service_bookings_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pos.service_bookings ADD CONSTRAINT service_bookings_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.service_bookings ADD CONSTRAINT service_bookings_service_product_id_fkey FOREIGN KEY (service_product_id) REFERENCES pos.products(id);
ALTER TABLE pos.service_bookings ADD CONSTRAINT service_bookings_assigned_staff_id_fkey FOREIGN KEY (assigned_staff_id) REFERENCES public.users(id);
ALTER TABLE pos.service_bookings ADD CONSTRAINT service_bookings_partnership_id_fkey FOREIGN KEY (partnership_id) REFERENCES pos.merchant_partnerships(id);
ALTER TABLE pos.service_bookings ADD CONSTRAINT service_bookings_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES pos.sales(id);
ALTER TABLE pos.store_business_hours ADD CONSTRAINT store_business_hours_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.store_cart_items ADD CONSTRAINT store_cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES pos.store_carts(id);
ALTER TABLE pos.store_cart_items ADD CONSTRAINT store_cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES pos.products(id);
ALTER TABLE pos.store_cart_items ADD CONSTRAINT fk_cart_items_assigned_staff FOREIGN KEY (assigned_staff_id) REFERENCES public.users(id);
ALTER TABLE pos.store_carts ADD CONSTRAINT store_carts_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.store_carts ADD CONSTRAINT store_carts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE pos.store_payment_methods ADD CONSTRAINT store_payment_methods_store_id_fkey FOREIGN KEY (store_id) REFERENCES pos.stores(id);
ALTER TABLE pos.store_payment_methods ADD CONSTRAINT store_payment_methods_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES pos.payment_methods(id);
ALTER TABLE pos.stores ADD CONSTRAINT stores_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES pos.merchants(id);
ALTER TABLE pos.stores ADD CONSTRAINT stores_city_id_fkey FOREIGN KEY (city_id) REFERENCES pos.cities(id);
ALTER TABLE pos.stores ADD CONSTRAINT stores_province_id_fkey FOREIGN KEY (province_id) REFERENCES pos.provinces(id);
ALTER TABLE pos.stores ADD CONSTRAINT stores_country_id_fkey FOREIGN KEY (country_id) REFERENCES pos.countries(id);
ALTER TABLE pos.subscription_notifications ADD CONSTRAINT subscription_notifications_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES pos.user_subscriptions(id);
ALTER TABLE pos.subscription_usage_analytics ADD CONSTRAINT subscription_usage_analytics_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES pos.user_subscriptions(id);
ALTER TABLE pos.user_subscriptions ADD CONSTRAINT user_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES pos.subscription_plans(id);
ALTER TABLE pos.user_subscriptions ADD CONSTRAINT user_subscriptions_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES pos.referral_agents(id);


-- ================================
-- INDEXES FOR PERFORMANCE
-- ================================

-- Public Schema Indexes
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON public.users(auth_id);
CREATE INDEX IF NOT EXISTS idx_users_username ON public.users(username);
CREATE INDEX IF NOT EXISTS idx_users_staff_type ON public.users(staff_type);
CREATE INDEX IF NOT EXISTS idx_users_level ON public.users(level);
CREATE INDEX IF NOT EXISTS idx_users_experience_points ON public.users(experience_points);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON public.customers(phone);
CREATE INDEX IF NOT EXISTS idx_customers_auth_id ON public.customers(auth_id);
CREATE INDEX IF NOT EXISTS idx_customers_membership_type ON public.customers(membership_type);
CREATE INDEX IF NOT EXISTS idx_customer_devices_customer_id ON public.customer_devices(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_devices_fingerprint ON public.customer_devices(device_fingerprint);
CREATE INDEX IF NOT EXISTS idx_customer_devices_trusted ON public.customer_devices(is_trusted);
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id ON public.user_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_fingerprint ON public.user_devices(device_fingerprint);
CREATE INDEX IF NOT EXISTS idx_user_devices_trusted ON public.user_devices(user_id, is_trusted);
CREATE INDEX IF NOT EXISTS idx_user_devices_last_used ON public.user_devices(last_used_at);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON public.activity_logs(created_at);

-- Pet Schema Indexes
CREATE INDEX IF NOT EXISTS idx_pets_owner_id ON pet.pets(owner_id);
CREATE INDEX IF NOT EXISTS idx_pets_pet_category_id ON pet.pets(pet_category_id);
CREATE INDEX IF NOT EXISTS idx_pet_medical_records_pet_id ON pet.pet_medical_records(pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_medical_records_date ON pet.pet_medical_records(record_date);
CREATE INDEX IF NOT EXISTS idx_pet_breeding_pairs_male_pet_id ON pet.pet_breeding_pairs(male_pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_breeding_pairs_female_pet_id ON pet.pet_breeding_pairs(female_pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_weight_history_pet_id ON pet.pet_weight_history(pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_weight_history_date ON pet.pet_weight_history(measurement_date);
CREATE INDEX IF NOT EXISTS idx_pet_schedules_pet_id ON pet.pet_schedules(pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_schedules_scheduled_at ON pet.pet_schedules(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_pet_photos_pet_id ON pet.pet_photos(pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_photos_is_primary ON pet.pet_photos(is_primary);
CREATE INDEX IF NOT EXISTS idx_pet_photos_deleted_at ON pet.pet_photos(deleted_at);
CREATE INDEX IF NOT EXISTS idx_pet_scan_logs_pet_id ON pet.pet_scan_logs(pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_scan_logs_created_at ON pet.pet_scan_logs(created_at);

-- Social Schema Indexes
CREATE INDEX IF NOT EXISTS idx_forum_categories_pet_category_id ON social.forum_categories(pet_category_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_author_id ON social.forum_posts(author_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_category_id ON social.forum_posts(category_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_created_at ON social.forum_posts(created_at);
CREATE INDEX IF NOT EXISTS idx_forum_posts_pinned ON social.forum_posts(is_pinned, created_at);
CREATE INDEX IF NOT EXISTS idx_forum_replies_post_id ON social.forum_replies(post_id);
CREATE INDEX IF NOT EXISTS idx_forum_replies_author_id ON social.forum_replies(author_id);
CREATE INDEX IF NOT EXISTS idx_forum_post_likes_post_id ON social.forum_post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_forum_post_likes_user_id ON social.forum_post_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_community_events_pet_category_id ON social.community_events(pet_category_id);
CREATE INDEX IF NOT EXISTS idx_community_events_organizer_id ON social.community_events(organizer_id);
CREATE INDEX IF NOT EXISTS idx_community_events_date ON social.community_events(event_date);
CREATE INDEX IF NOT EXISTS idx_community_events_type ON social.community_events(event_type);
CREATE INDEX IF NOT EXISTS idx_event_participants_event_id ON social.event_participants(event_id);
CREATE INDEX IF NOT EXISTS idx_event_participants_user_id ON social.event_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_kb_categories_pet_category_id ON social.kb_categories(pet_category_id);
CREATE INDEX IF NOT EXISTS idx_kb_articles_category_id ON social.kb_articles(category_id);
CREATE INDEX IF NOT EXISTS idx_kb_articles_author_id ON social.kb_articles(author_id);
CREATE INDEX IF NOT EXISTS idx_kb_articles_status ON social.kb_articles(status);
CREATE INDEX IF NOT EXISTS idx_kb_articles_featured ON social.kb_articles(is_featured, view_count);
CREATE INDEX IF NOT EXISTS idx_product_favorites_user_id ON social.product_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_product_id ON social.product_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_reviewer_id ON social.product_reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_user_achievement_unlocks_user_id ON social.user_achievement_unlocks(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_transactions_user_id ON social.xp_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_push_notifications_user_id ON social.push_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_push_notifications_read ON social.push_notifications(is_read, created_at);

-- POS Schema Indexes
CREATE INDEX IF NOT EXISTS idx_cities_province_id ON pos.cities(province_id);
CREATE INDEX IF NOT EXISTS idx_provinces_country_id ON pos.provinces(country_id);
CREATE INDEX IF NOT EXISTS idx_merchants_business_type ON pos.merchants(business_type);
CREATE INDEX IF NOT EXISTS idx_merchants_service_provider ON pos.merchants(is_service_provider);
CREATE INDEX IF NOT EXISTS idx_stores_merchant_id ON pos.stores(merchant_id);
CREATE INDEX IF NOT EXISTS idx_store_business_hours_store_id ON pos.store_business_hours(store_id);
CREATE INDEX IF NOT EXISTS idx_store_business_hours_day ON pos.store_business_hours(day_of_week);
CREATE INDEX IF NOT EXISTS idx_role_assignments_user_id ON pos.role_assignments(user_id);
CREATE INDEX IF NOT EXISTS idx_role_assignments_store_id ON pos.role_assignments(store_id);
CREATE INDEX IF NOT EXISTS idx_products_store_id ON pos.products(store_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON pos.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_barcode ON pos.products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_seller_id ON pos.products(seller_id);
CREATE INDEX IF NOT EXISTS idx_products_availability ON pos.products(availability);
CREATE INDEX IF NOT EXISTS idx_products_rating ON pos.products(rating);
CREATE INDEX IF NOT EXISTS idx_products_target_pet_category ON pos.products(target_pet_category_id);
CREATE INDEX IF NOT EXISTS idx_products_created_at ON pos.products(created_at);
CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON pos.product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_product_images_is_primary ON pos.product_images(is_primary);
CREATE INDEX IF NOT EXISTS idx_product_images_sort_order ON pos.product_images(sort_order);
CREATE INDEX IF NOT EXISTS idx_product_images_deleted_at ON pos.product_images(deleted_at);
CREATE INDEX IF NOT EXISTS idx_sales_store_id ON pos.sales(store_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON pos.sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON pos.sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_sales_sale_number ON pos.sales(sale_number);
CREATE INDEX IF NOT EXISTS idx_sales_items_booking_date ON pos.sales_items(booking_date);
CREATE INDEX IF NOT EXISTS idx_sales_items_item_type ON pos.sales_items(item_type);
CREATE INDEX IF NOT EXISTS idx_sales_items_assigned_staff_id ON pos.sales_items(assigned_staff_id);
CREATE INDEX IF NOT EXISTS idx_service_bookings_store_id ON pos.service_bookings(store_id);
CREATE INDEX IF NOT EXISTS idx_service_bookings_customer_id ON pos.service_bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_service_bookings_booking_date ON pos.service_bookings(booking_date);
CREATE INDEX IF NOT EXISTS idx_service_bookings_booking_reference ON pos.service_bookings(booking_reference);
CREATE INDEX IF NOT EXISTS idx_service_bookings_status ON pos.service_bookings(status);
CREATE INDEX IF NOT EXISTS idx_service_bookings_payment_status ON pos.service_bookings(payment_status);
CREATE INDEX IF NOT EXISTS idx_service_bookings_booking_source ON pos.service_bookings(booking_source);
CREATE INDEX IF NOT EXISTS idx_service_bookings_service_product_id ON pos.service_bookings(service_product_id);
CREATE INDEX IF NOT EXISTS idx_service_bookings_assigned_staff_id ON pos.service_bookings(assigned_staff_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON pos.user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_plan_id ON pos.user_subscriptions(plan_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON pos.user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_agent_id ON pos.user_subscriptions(agent_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_referral_code ON pos.user_subscriptions(referral_code);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_stripe_subscription_id ON pos.user_subscriptions(stripe_subscription_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_period ON pos.user_subscriptions(current_period_start, current_period_end);
CREATE INDEX IF NOT EXISTS idx_billing_invoices_user_id ON pos.billing_invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_billing_invoices_subscription_id ON pos.billing_invoices(subscription_id);
CREATE INDEX IF NOT EXISTS idx_billing_invoices_status ON pos.billing_invoices(status);
CREATE INDEX IF NOT EXISTS idx_billing_invoices_terms ON pos.billing_invoices(payment_terms_days);
CREATE INDEX IF NOT EXISTS idx_billing_payments_invoice_id ON pos.billing_payments(invoice_id);
CREATE INDEX IF NOT EXISTS idx_billing_payments_gateway ON pos.billing_payments(payment_gateway);
CREATE INDEX IF NOT EXISTS idx_billing_transactions_user_id ON pos.billing_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_feature_flags_plan_id ON pos.feature_flags(plan_id);
CREATE INDEX IF NOT EXISTS idx_feature_flags_feature_name ON pos.feature_flags(feature_name);
CREATE INDEX IF NOT EXISTS idx_feature_usage_user_id ON pos.feature_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_feature_usage_feature_name ON pos.feature_usage(feature_name);
CREATE INDEX IF NOT EXISTS idx_feature_usage_reset_date ON pos.feature_usage(reset_date);
CREATE INDEX IF NOT EXISTS idx_attendance_records_user_id ON pos.attendance_records(user_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_store_id ON pos.attendance_records(store_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_date ON pos.attendance_records(attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_records_status ON pos.attendance_records(status);
CREATE INDEX IF NOT EXISTS idx_payroll_records_user_id ON pos.payroll_records(user_id);
CREATE INDEX IF NOT EXISTS idx_payroll_records_store_id ON pos.payroll_records(store_id);
CREATE INDEX IF NOT EXISTS idx_payroll_records_period ON pos.payroll_records(pay_period_start, pay_period_end);
CREATE INDEX IF NOT EXISTS idx_payroll_records_status ON pos.payroll_records(status);
CREATE INDEX IF NOT EXISTS idx_leave_requests_user_id ON pos.leave_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_leave_type_id ON pos.leave_requests(leave_type_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_status ON pos.leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_leave_requests_dates ON pos.leave_requests(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_leave_balances_user_id ON pos.leave_balances(user_id);
CREATE INDEX IF NOT EXISTS idx_leave_balances_year ON pos.leave_balances(year);
CREATE INDEX IF NOT EXISTS idx_leave_types_store_id ON pos.leave_types(store_id);
CREATE INDEX IF NOT EXISTS idx_employee_documents_user_id ON pos.employee_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_employee_documents_type ON pos.employee_documents(document_type);
CREATE INDEX IF NOT EXISTS idx_employee_documents_expires ON pos.employee_documents(expires_at);
CREATE INDEX IF NOT EXISTS idx_commission_records_user_id ON pos.commission_records(user_id);
CREATE INDEX IF NOT EXISTS idx_commission_records_sale_id ON pos.commission_records(sale_id);
CREATE INDEX IF NOT EXISTS idx_commission_records_pay_period ON pos.commission_records(pay_period_id);
CREATE INDEX IF NOT EXISTS idx_merchant_customers_merchant_id ON pos.merchant_customers(merchant_id);
CREATE INDEX IF NOT EXISTS idx_merchant_customers_customer_id ON pos.merchant_customers(customer_id);
CREATE INDEX IF NOT EXISTS idx_merchant_customers_store_id ON pos.merchant_customers(store_id);
CREATE INDEX IF NOT EXISTS idx_merchant_customers_is_active ON pos.merchant_customers(is_active);
CREATE INDEX IF NOT EXISTS idx_merchant_partnerships_merchant_id ON pos.merchant_partnerships(merchant_id);
CREATE INDEX IF NOT EXISTS idx_merchant_partnerships_store_id ON pos.merchant_partnerships(store_id);
CREATE INDEX IF NOT EXISTS idx_merchant_partnerships_partnership_status ON pos.merchant_partnerships(partnership_status);
CREATE INDEX IF NOT EXISTS idx_merchant_service_availability_store_id ON pos.merchant_service_availability(store_id);
CREATE INDEX IF NOT EXISTS idx_merchant_service_availability_service_product_id ON pos.merchant_service_availability(service_product_id);
CREATE INDEX IF NOT EXISTS idx_merchant_service_availability_day_of_week ON pos.merchant_service_availability(day_of_week);
CREATE INDEX IF NOT EXISTS idx_plan_change_requests_user_id ON pos.plan_change_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_plan_change_requests_subscription_id ON pos.plan_change_requests(subscription_id);
CREATE INDEX IF NOT EXISTS idx_plan_change_requests_status ON pos.plan_change_requests(status);
CREATE INDEX IF NOT EXISTS idx_pricing_faq_category ON pos.pricing_faq(category);
CREATE INDEX IF NOT EXISTS idx_pricing_faq_active ON pos.pricing_faq(is_active);
CREATE INDEX IF NOT EXISTS idx_subscription_plans_popular ON pos.subscription_plans(popular);
CREATE INDEX IF NOT EXISTS idx_referral_agents_email ON pos.referral_agents(email);
CREATE INDEX IF NOT EXISTS idx_referral_agents_phone ON pos.referral_agents(phone);
CREATE INDEX IF NOT EXISTS idx_referral_agents_referral_code ON pos.referral_agents(referral_code);
CREATE INDEX IF NOT EXISTS idx_referral_agents_is_active ON pos.referral_agents(is_active);
CREATE INDEX IF NOT EXISTS idx_referral_commissions_agent_id ON pos.referral_commissions(agent_id);
CREATE INDEX IF NOT EXISTS idx_referral_commissions_user_id ON pos.referral_commissions(user_id);
CREATE INDEX IF NOT EXISTS idx_referral_commissions_subscription_id ON pos.referral_commissions(subscription_id);
CREATE INDEX IF NOT EXISTS idx_referral_commissions_status ON pos.referral_commissions(status);
CREATE INDEX IF NOT EXISTS idx_referral_commissions_commission_date ON pos.referral_commissions(commission_date);
CREATE INDEX IF NOT EXISTS idx_referral_payments_agent_id ON pos.referral_payments(agent_id);
CREATE INDEX IF NOT EXISTS idx_referral_payments_status ON pos.referral_payments(status);
CREATE INDEX IF NOT EXISTS idx_referral_payments_payment_date ON pos.referral_payments(payment_date);
CREATE INDEX IF NOT EXISTS idx_subscription_notifications_user_id ON pos.subscription_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_notifications_type ON pos.subscription_notifications(notification_type);
CREATE INDEX IF NOT EXISTS idx_subscription_notifications_read ON pos.subscription_notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_subscription_usage_analytics_user_id ON pos.subscription_usage_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_usage_analytics_subscription_id ON pos.subscription_usage_analytics(subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscription_usage_analytics_period ON pos.subscription_usage_analytics(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_store_cart_items_booking_date ON pos.store_cart_items(booking_date);
CREATE INDEX IF NOT EXISTS idx_store_cart_items_item_type ON pos.store_cart_items(item_type);
CREATE INDEX IF NOT EXISTS idx_store_cart_items_assigned_staff_id ON pos.store_cart_items(assigned_staff_id);
CREATE INDEX IF NOT EXISTS idx_marketplace_transactions_buyer_id ON pos.marketplace_transactions(buyer_id);
CREATE INDEX IF NOT EXISTS idx_marketplace_transactions_seller_id ON pos.marketplace_transactions(seller_id);


-- ================================
-- ENABLE ROW LEVEL SECURITY
-- ================================

-- Public Schema
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- Pet Schema
ALTER TABLE pet.pet_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.characters ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_characters ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_healths ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.schedule_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.schedule_recurring_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_breeding_pairs ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_weight_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_scan_logs ENABLE ROW LEVEL SECURITY;

-- Social Schema
ALTER TABLE social.forum_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.forum_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.forum_post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_achievement_unlocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.xp_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.product_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.product_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.community_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.event_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.course_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.kb_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.kb_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.push_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.content_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE social.user_warnings ENABLE ROW LEVEL SECURITY;

-- POS Schema
ALTER TABLE pos.countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.provinces ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.cities ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.payment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.merchants ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.store_business_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.role_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.products_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.inventory_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.sales_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.store_carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.store_cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.store_payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.merchant_customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.merchant_partnerships ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.merchant_service_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.service_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.feature_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.billing_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.billing_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.billing_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.referral_agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.referral_commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.referral_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.referral_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.employee_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.leave_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.leave_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.payroll_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.commission_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.marketplace_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.plan_change_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.subscription_usage_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.pricing_faq ENABLE ROW LEVEL SECURITY;
ALTER TABLE pos.subscription_notifications ENABLE ROW LEVEL SECURITY;

-- ================================
-- TABLE AND COLUMN COMMENTS
-- ================================

-- Public Schema
COMMENT ON TABLE public.users IS 'System users including staff and employees';
COMMENT ON TABLE public.customers IS 'End users/customers of Glideria app';
COMMENT ON TABLE public.customer_devices IS 'Trusted devices for customer authentication';
COMMENT ON TABLE public.user_devices IS 'Stores trusted devices for users to enable device-based authentication';
COMMENT ON TABLE public.app_settings IS 'Application configuration settings';
COMMENT ON TABLE public.activity_logs IS 'User activity logging for audit trail';

-- Pet Schema
COMMENT ON TABLE pet.pet_medical_records IS 'Detailed medical records for all pets';
COMMENT ON TABLE pet.pet_breeding_pairs IS 'Pet breeding pair management for all breedable pets';
COMMENT ON TABLE pet.pet_weight_history IS 'Weight tracking history for all pets';
COMMENT ON TABLE pet.pet_photos IS 'Photo gallery for pets - supports multiple photos with primary selection';
COMMENT ON TABLE pet.pet_scan_logs IS 'QR code scan history tracking for pet location and safety';

-- Social Schema
COMMENT ON TABLE social.forum_categories IS 'Categories for forum discussions';
COMMENT ON TABLE social.forum_posts IS 'Community forum posts with rich content support';
COMMENT ON TABLE social.forum_replies IS 'Threaded replies to forum posts';
COMMENT ON TABLE social.forum_post_likes IS 'User likes on forum posts';
COMMENT ON TABLE social.user_levels IS 'Gamification levels with XP requirements';
COMMENT ON TABLE social.user_achievements IS 'Available achievements for users';
COMMENT ON TABLE social.user_achievement_unlocks IS 'User achievement progress tracking';
COMMENT ON TABLE social.xp_transactions IS 'XP earning history for users';
COMMENT ON TABLE social.product_reviews IS 'Unified reviews for products and services';
COMMENT ON TABLE social.product_favorites IS 'User favorite products (wishlist)';
COMMENT ON TABLE social.community_events IS 'Community events and meetups';
COMMENT ON TABLE social.event_participants IS 'Event registration and attendance tracking';
COMMENT ON TABLE social.course_categories IS 'Categories for premium courses';
COMMENT ON TABLE social.courses IS 'Premium educational courses';
COMMENT ON TABLE social.course_enrollments IS 'Course enrollment and progress tracking';
COMMENT ON TABLE social.kb_categories IS 'Knowledge base article categories';
COMMENT ON TABLE social.kb_articles IS 'Knowledge base articles and guides';
COMMENT ON TABLE social.faqs IS 'Frequently asked questions';
COMMENT ON TABLE social.user_preferences IS 'User notification and privacy preferences';
COMMENT ON TABLE social.push_notifications IS 'Push notification history';
COMMENT ON TABLE social.content_reports IS 'User reports for inappropriate content';
COMMENT ON TABLE social.user_warnings IS 'Moderation warnings for users';

-- POS Schema
COMMENT ON TABLE pos.roles IS 'User roles and permissions for Allnimall Store CMS';
COMMENT ON TABLE pos.merchants IS 'Business entities that own stores';
COMMENT ON TABLE pos.stores IS 'Physical or virtual store locations';
COMMENT ON TABLE pos.store_business_hours IS 'Store business hours configuration for each day of the week';
COMMENT ON TABLE pos.merchant_customers IS 'Mapping table between merchants and customers. One customer can be registered with multiple merchants.';
COMMENT ON TABLE pos.merchant_partnerships IS 'Partnership antara merchant dengan Allnimall untuk layanan jasa';
COMMENT ON TABLE pos.merchant_service_availability IS 'Jadwal availability layanan per merchant';
COMMENT ON TABLE pos.service_bookings IS 'Sistem booking terpadu untuk semua jenis booking (merchant online, Allnimall app, offline store)';
COMMENT ON TABLE pos.subscription_plans IS 'Subscription plans with pricing and feature definitions';
COMMENT ON TABLE pos.user_subscriptions IS 'User subscription records and status tracking';
COMMENT ON TABLE pos.feature_flags IS 'Feature flags and access control per plan';
COMMENT ON TABLE pos.feature_usage IS 'Feature usage tracking and limits enforcement';
COMMENT ON TABLE pos.billing_invoices IS 'Billing invoices for subscription payments';
COMMENT ON TABLE pos.billing_payments IS 'Payment records for invoices';
COMMENT ON TABLE pos.billing_transactions IS 'All billing-related transactions';
COMMENT ON TABLE pos.plan_change_requests IS 'Track plan change requests and approvals';
COMMENT ON TABLE pos.subscription_usage_analytics IS 'Analytics data for subscription usage tracking';
COMMENT ON TABLE pos.pricing_faq IS 'Frequently asked questions for pricing page';
COMMENT ON TABLE pos.subscription_notifications IS 'User notifications for subscription events';
COMMENT ON TABLE pos.employee_documents IS 'Employee documents and certificates';
COMMENT ON TABLE pos.attendance_records IS 'Employee attendance tracking records';
COMMENT ON TABLE pos.leave_types IS 'Types of leave available in the store';
COMMENT ON TABLE pos.leave_requests IS 'Employee leave requests';
COMMENT ON TABLE pos.leave_balances IS 'Employee leave balances by year';
COMMENT ON TABLE pos.payroll_records IS 'Employee payroll records';
COMMENT ON TABLE pos.commission_records IS 'Employee commission tracking records';
COMMENT ON TABLE pos.product_images IS 'Stores product images with main picture selection';
COMMENT ON TABLE pos.marketplace_transactions IS 'Marketplace purchase transactions';

-- Column comments (POS Schema)
COMMENT ON COLUMN pos.merchants.owner_id IS 'Reference to the user who owns this merchant/business';
COMMENT ON COLUMN pos.stores.business_field IS 'Type of business: pet_shop, veterinary, grooming, etc.';
COMMENT ON COLUMN pos.stores.timezone IS 'Store timezone for business hours and operations';
COMMENT ON COLUMN pos.stores.currency IS 'Store currency code (IDR, USD, etc.)';
COMMENT ON COLUMN pos.stores.tax_rate IS 'Tax rate as decimal (0.11 = 11%)';
COMMENT ON COLUMN pos.stores.tax_inclusive IS 'Whether displayed prices include tax';
COMMENT ON COLUMN pos.stores.receipt_format IS 'Receipt format: standard, detailed, minimal';
COMMENT ON COLUMN pos.stores.receipt_footer IS 'Custom footer text for receipts';
COMMENT ON COLUMN pos.stores.low_stock_threshold IS 'Alert when inventory below this number';
COMMENT ON COLUMN pos.stores.auto_reorder IS 'Enable automatic reorder when stock low';
COMMENT ON COLUMN pos.stores.customer_loyalty_enabled IS 'Enable customer loyalty program';
COMMENT ON COLUMN pos.stores.loyalty_points_rate IS 'Points earned per currency unit spent';
COMMENT ON COLUMN pos.stores.notification_email IS 'Email for store notifications';
COMMENT ON COLUMN pos.stores.notification_sms IS 'SMS number for store notifications';
COMMENT ON COLUMN pos.stores.business_license IS 'Business license number';
COMMENT ON COLUMN pos.stores.tax_id IS 'Tax ID (NPWP)';
COMMENT ON COLUMN pos.stores.website_url IS 'Store website URL';
COMMENT ON COLUMN pos.stores.social_media IS 'Social media links as JSON';
COMMENT ON COLUMN pos.stores.payment_methods IS 'Available payment methods as JSON array';
COMMENT ON COLUMN pos.stores.delivery_enabled IS 'Enable delivery service';
COMMENT ON COLUMN pos.stores.delivery_radius IS 'Delivery radius in kilometers';
COMMENT ON COLUMN pos.stores.delivery_fee IS 'Delivery fee amount';
COMMENT ON COLUMN pos.stores.min_order_amount IS 'Minimum order amount for delivery';
COMMENT ON COLUMN pos.store_business_hours.day_of_week IS 'Day of week: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday';
COMMENT ON COLUMN pos.store_business_hours.break_start_time IS 'Start time of break period (optional)';
COMMENT ON COLUMN pos.store_business_hours.break_end_time IS 'End time of break period (optional)';
COMMENT ON COLUMN pos.store_business_hours.is_24_hours IS 'If true, store is open 24 hours and open_time/close_time are ignored';
COMMENT ON COLUMN pos.service_bookings.booking_source IS 'Sumber booking: merchant_online_store, allnimall_app, offline_store';
COMMENT ON COLUMN pos.service_bookings.booking_reference IS 'Nomor referensi booking unik (format: BK-YYYYMMDD-XXXX)';
COMMENT ON COLUMN pos.service_bookings.pet_id IS 'ID pet (optional - bisa NULL jika tidak ada pet)';
COMMENT ON COLUMN pos.service_bookings.service_type IS 'Tipe layanan: in_store atau on_site';
COMMENT ON COLUMN pos.service_bookings.status IS 'Status booking: pending, confirmed, in_progress, completed, cancelled, no_show';
COMMENT ON COLUMN pos.service_bookings.payment_status IS 'Status pembayaran: pending, paid, refunded';
COMMENT ON COLUMN pos.service_bookings.allnimall_commission IS 'Komisi untuk Allnimall jika booking dari Allnimall app';
COMMENT ON COLUMN pos.subscription_plans.popular IS 'Whether this plan is marked as popular/recommended';
COMMENT ON COLUMN pos.subscription_plans.badge_text IS 'Text to display on plan badge (e.g., "Most Popular")';
COMMENT ON COLUMN pos.subscription_plans.max_stores IS 'Maximum number of stores allowed (-1 for unlimited)';
COMMENT ON COLUMN pos.subscription_plans.max_users IS 'Maximum number of users allowed (-1 for unlimited)';
COMMENT ON COLUMN pos.subscription_plans.max_products IS 'Maximum number of products allowed (-1 for unlimited)';
COMMENT ON COLUMN pos.subscription_plans.max_customers IS 'Maximum number of customers allowed (-1 for unlimited)';
COMMENT ON COLUMN pos.subscription_plans.storage_gb IS 'Storage limit in GB (-1 for unlimited)';
COMMENT ON COLUMN pos.subscription_plans.api_calls_per_month IS 'API calls limit per month (-1 for unlimited)';
COMMENT ON COLUMN pos.user_subscriptions.current_period_start IS 'Start of current billing period';
COMMENT ON COLUMN pos.user_subscriptions.current_period_end IS 'End of current billing period';
COMMENT ON COLUMN pos.user_subscriptions.cancel_at_period_end IS 'Whether subscription will cancel at period end';
COMMENT ON COLUMN pos.user_subscriptions.proration_amount IS 'Amount for prorated billing';
COMMENT ON COLUMN pos.user_subscriptions.change_effective_date IS 'When plan change takes effect';
COMMENT ON COLUMN pos.billing_invoices.subtotal IS 'Amount before tax and fees';
COMMENT ON COLUMN pos.billing_invoices.tax_amount IS 'Tax amount';
COMMENT ON COLUMN pos.billing_invoices.discount_amount IS 'Discount amount applied';
COMMENT ON COLUMN pos.billing_invoices.late_fee IS 'Late payment fee';
COMMENT ON COLUMN pos.billing_invoices.billing_address IS 'Billing address information';
COMMENT ON COLUMN pos.billing_invoices.line_items IS 'Detailed line items for the invoice';
COMMENT ON COLUMN pos.billing_payments.payment_gateway IS 'Payment gateway used (midtrans, stripe, etc.)';
COMMENT ON COLUMN pos.billing_payments.gateway_transaction_id IS 'Transaction ID from payment gateway';
COMMENT ON COLUMN pos.billing_payments.gateway_fee IS 'Fee charged by payment gateway';
COMMENT ON COLUMN pos.billing_payments.net_amount IS 'Amount received after gateway fees';
COMMENT ON COLUMN pos.billing_payments.refund_amount IS 'Amount refunded';
COMMENT ON COLUMN pos.product_images.sort_order IS 'Order for displaying images in gallery';
COMMENT ON COLUMN pos.product_images.is_primary IS 'Indicates if this is the main image for the product (only one per product)';
COMMENT ON COLUMN pos.product_images.file_size IS 'File size in bytes for optimization';
COMMENT ON COLUMN pos.product_images.mime_type IS 'MIME type of the image file';
COMMENT ON COLUMN pos.product_images.width IS 'Image width in pixels';
COMMENT ON COLUMN pos.product_images.height IS 'Image height in pixels';
COMMENT ON COLUMN pos.products.purchase_price IS 'Purchase price of the product';
COMMENT ON COLUMN pos.products.min_stock IS 'Minimum stock level for reorder';
COMMENT ON COLUMN pos.products.unit IS 'Unit of measurement (pcs, kg, etc)';
COMMENT ON COLUMN pos.products.weight_grams IS 'Weight in grams';
COMMENT ON COLUMN pos.products.discount_type IS 'Discount type: 1=none, 2=percentage, 3=fixed';
COMMENT ON COLUMN pos.products.discount_value IS 'Discount amount - percentage (if discount_type=2) or fixed amount (if discount_type=3)';
COMMENT ON COLUMN pos.sales_items.item_type IS 'Tipe item: product atau service';
COMMENT ON COLUMN pos.sales_items.booking_date IS 'Tanggal booking untuk service';
COMMENT ON COLUMN pos.sales_items.booking_time IS 'Waktu booking untuk service';
COMMENT ON COLUMN pos.sales_items.duration_minutes IS 'Durasi service dalam menit';
COMMENT ON COLUMN pos.sales_items.assigned_staff_id IS 'Staff yang ditugaskan untuk service';
COMMENT ON COLUMN pos.sales_items.customer_notes IS 'Catatan customer untuk service';
COMMENT ON COLUMN pos.sales_items.booking_reference IS 'Referensi booking yang di-generate';
COMMENT ON COLUMN pos.store_cart_items.item_type IS 'Tipe item: product atau service';
COMMENT ON COLUMN pos.store_cart_items.booking_date IS 'Tanggal booking untuk service';
COMMENT ON COLUMN pos.store_cart_items.booking_time IS 'Waktu booking untuk service';
COMMENT ON COLUMN pos.store_cart_items.duration_minutes IS 'Durasi service dalam menit';
COMMENT ON COLUMN pos.store_cart_items.assigned_staff_id IS 'Staff yang ditugaskan untuk service';
COMMENT ON COLUMN pos.store_cart_items.customer_notes IS 'Catatan customer untuk service';
COMMENT ON COLUMN pos.store_cart_items.booking_reference IS 'Referensi booking yang akan di-generate';

-- Column comments (Public Schema)
COMMENT ON COLUMN public.users.auth_id IS 'Supabase auth ID for staff authentication';
COMMENT ON COLUMN public.users.username IS 'Username for staff login (used to find email for Supabase auth)';
COMMENT ON COLUMN public.users.employee_id IS 'Unique employee ID (e.g., EMP001)';
COMMENT ON COLUMN public.users.position IS 'Employee position/title';
COMMENT ON COLUMN public.users.department IS 'Employee department';
COMMENT ON COLUMN public.users.hire_date IS 'Date when employee was hired';
COMMENT ON COLUMN public.users.salary IS 'Employee base salary';
COMMENT ON COLUMN public.users.employment_status IS 'Current employment status';
COMMENT ON COLUMN public.users.emergency_contact_name IS 'Emergency contact person name';
COMMENT ON COLUMN public.users.emergency_contact_phone IS 'Emergency contact phone number';
COMMENT ON COLUMN public.users.address IS 'Employee home address';
COMMENT ON COLUMN public.users.birth_date IS 'Employee birth date';
COMMENT ON COLUMN public.users.gender IS 'Employee gender';
COMMENT ON COLUMN public.users.marital_status IS 'Employee marital status';
COMMENT ON COLUMN public.users.tax_id IS 'Employee tax ID (NPWP)';
COMMENT ON COLUMN public.users.bank_account IS 'Employee bank account number';
COMMENT ON COLUMN public.users.bank_name IS 'Employee bank name';
COMMENT ON COLUMN public.customers.auth_id IS 'Supabase auth ID for customer authentication';
COMMENT ON COLUMN public.customers.membership_type IS 'Customer membership level: free, premium, vip';
COMMENT ON COLUMN public.customers.experience_level IS 'Pet care experience: beginner, intermediate, advanced, expert';
COMMENT ON COLUMN public.customer_devices.customer_id IS 'Reference to customer who owns this device';
COMMENT ON COLUMN public.customer_devices.device_fingerprint IS 'Unique device identifier hash';
COMMENT ON COLUMN public.customer_devices.is_trusted IS 'Whether this device is trusted for PIN login';
COMMENT ON COLUMN public.user_devices.device_fingerprint IS 'SHA256 hash of device characteristics for identification';
COMMENT ON COLUMN public.user_devices.device_name IS 'User-friendly name for the device (optional)';
COMMENT ON COLUMN public.user_devices.browser_info IS 'Browser information (e.g., Chrome 120.0)';
COMMENT ON COLUMN public.user_devices.os_info IS 'Operating system information (e.g., Android 14)';
COMMENT ON COLUMN public.user_devices.ip_address IS 'IP address when device was registered';
COMMENT ON COLUMN public.user_devices.is_trusted IS 'Whether this device is trusted for password-only login';
COMMENT ON COLUMN public.user_devices.last_used_at IS 'Last time this device was used for authentication';

-- ================================
-- END OF MULTI-SCHEMA DEFINITION
-- ================================
-- 
-- Schema Organization:
-- - PUBLIC (8 tables): Core auth & system (users, customers, devices, settings)
-- - PET (13 tables): Pet profiles, health, breeding, schedules, photos, scan logs
-- - SOCIAL (23 tables): Forums, community, courses, gamification, reviews
-- - POS (46 tables): Business management, sales, subscriptions, HR, location, payment
--
-- Total: 90 tables across 4 schemas
-- Updated: 2025-10-18
-- ================================

