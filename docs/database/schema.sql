-- Database Schema Extraction
-- Schemas: public, pet, business, social
-- Generated from Supabase MCP
-- Date: 2025-12-06
-- Includes: Tables, Columns, Constraints, Foreign Keys, RLS Policies, Functions, Triggers, Indexes

-- ============================================
-- PET SCHEMA
-- ============================================

CREATE TABLE pet.characters (
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

CREATE TABLE pet.health_parameter_definitions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_category_id uuid NOT NULL,
  parameter_key text NOT NULL,
  parameter_name_id text NOT NULL,
  parameter_name_en text NOT NULL,
  parameter_type text NOT NULL,
  is_required boolean DEFAULT false,
  affects_health_score boolean DEFAULT true,
  display_order integer,
  icon text,
  color text,
  description text,
  CONSTRAINT health_parameter_definitions_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.pet_categories (
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

CREATE TABLE pet.pet_characters (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_id uuid NOT NULL,
  character_id uuid NOT NULL,
  CONSTRAINT pet_characters_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.pet_health_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  pet_id uuid NOT NULL,
  parameter_key text NOT NULL,
  old_value jsonb,
  new_value jsonb,
  changed_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  changed_by uuid,
  notes text,
  CONSTRAINT pet_health_history_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.pet_healths (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  pet_id uuid NOT NULL,
  weight numeric,
  is_sterilized boolean DEFAULT false,
  is_vaccinated boolean DEFAULT false,
  CONSTRAINT pet_healths_pkey PRIMARY KEY (id),
  CONSTRAINT pet_healths_pet_id_key UNIQUE (pet_id)
);

CREATE TABLE pet.pet_medical_records (
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

CREATE TABLE pet.pet_photos (
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
  caption text,
  hashtags text[],
  mime_type text,
  file_size integer,
  CONSTRAINT pet_photos_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.pet_scan_logs (
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
  qr_id character varying,
  CONSTRAINT pet_scan_logs_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.pet_schedules (
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

CREATE TABLE pet.pet_timelines (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  pet_id uuid NOT NULL,
  timeline_type text NOT NULL,
  title text NOT NULL,
  caption text,
  media_url text,
  media_type text,
  visibility text NOT NULL DEFAULT 'public'::text,
  event_date timestamp with time zone NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT pet_timelines_pkey PRIMARY KEY (id),
  CONSTRAINT pet_timelines_timeline_type_check CHECK (timeline_type = ANY (ARRAY['birthday'::text, 'welcome'::text, 'schedule'::text, 'activity'::text, 'media'::text, 'weight_update'::text, 'health_update'::text])),
  CONSTRAINT pet_timelines_media_type_check CHECK (media_type IS NULL OR (media_type = ANY (ARRAY['image'::text, 'video'::text]))),
  CONSTRAINT pet_timelines_visibility_check CHECK (visibility = ANY (ARRAY['public'::text, 'private'::text]))
);

CREATE TABLE pet.pet_weight_histories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  pet_id uuid NOT NULL,
  weight numeric NOT NULL,
  notes text,
  CONSTRAINT pet_weight_histories_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.pets (
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
  microchip_id text,
  picture_url text,
  story text,
  adoption_date date,
  microchip_number text,
  activated_at timestamp without time zone,
  qr_id character varying,
  CONSTRAINT pets_pkey PRIMARY KEY (id),
  CONSTRAINT pets_qr_id_key UNIQUE (qr_id)
);

CREATE TABLE pet.photo_comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  photo_id uuid NOT NULL,
  commenter_id uuid,
  commenter_name text,
  commenter_ip text,
  comment_text text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  CONSTRAINT photo_comments_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.photo_likes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  photo_id uuid NOT NULL,
  liker_id uuid,
  liker_ip text,
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT photo_likes_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.photo_shares (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  photo_id uuid NOT NULL,
  shared_by_user_id uuid,
  shared_by_ip text,
  shared_to_platform text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT photo_shares_pkey PRIMARY KEY (id)
);

CREATE TABLE pet.schedule_recurring_patterns (
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

CREATE TABLE pet.schedule_types (
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

-- ============================================
-- BUSINESS SCHEMA
-- ============================================

-- ============================================
-- ENUM TYPES
-- ============================================

CREATE TYPE business.user_role_assignment_status AS ENUM ('invited', 'active', 'suspended');

-- ============================================
-- TABLES
-- ============================================

CREATE TABLE business.attendance_records (
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
  total_hours numeric,
  overtime_hours numeric,
  status character varying NOT NULL DEFAULT 'present'::character varying,
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

CREATE TABLE business.billing_invoices (
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

CREATE TABLE business.billing_payments (
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

CREATE TABLE business.billing_transactions (
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

CREATE TABLE business.cities (
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

CREATE TABLE business.commission_records (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  sale_id uuid,
  commission_type character varying DEFAULT 'sales'::character varying,
  commission_rate numeric NOT NULL,
  commission_amount numeric NOT NULL,
  pay_period_id uuid,
  description text,
  calculated_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT commission_records_pkey PRIMARY KEY (id),
  CONSTRAINT commission_records_commission_type_check CHECK (commission_type::text = ANY (ARRAY['sales'::character varying, 'service'::character varying, 'bonus'::character varying, 'other'::character varying]::text[]))
);

CREATE TABLE business.countries (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  name text NOT NULL,
  CONSTRAINT countries_pkey PRIMARY KEY (id)
);

CREATE TABLE business.employee_documents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  user_id uuid NOT NULL,
  document_type character varying NOT NULL,
  document_name character varying NOT NULL,
  file_path text NOT NULL,
  file_size integer,
  mime_type character varying,
  description text,
  is_required boolean DEFAULT false,
  expires_at date,
  uploaded_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT employee_documents_pkey PRIMARY KEY (id),
  CONSTRAINT employee_documents_document_type_check CHECK (document_type::text = ANY (ARRAY['contract'::character varying, 'certificate'::character varying, 'id_card'::character varying, 'tax_id'::character varying, 'bank_account'::character varying, 'medical_certificate'::character varying, 'other'::character varying]::text[]))
);

CREATE TABLE business.feature_flags (
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

CREATE TABLE business.feature_usage (
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

CREATE TABLE business.inventory_transactions (
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

CREATE TABLE business.leave_balances (
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
  CONSTRAINT leave_balances_pkey PRIMARY KEY (id)
);

CREATE TABLE business.leave_requests (
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
  status character varying DEFAULT 'pending'::character varying,
  approved_by uuid,
  approved_at timestamp with time zone,
  rejection_reason text,
  requested_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT leave_requests_pkey PRIMARY KEY (id),
  CONSTRAINT leave_requests_status_check CHECK (status::text = ANY (ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying, 'cancelled'::character varying]::text[]))
);

CREATE TABLE business.leave_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  name character varying NOT NULL,
  description text,
  max_days_per_year integer,
  is_paid boolean DEFAULT true,
  requires_approval boolean DEFAULT true,
  advance_notice_days integer DEFAULT 1,
  is_active boolean DEFAULT true,
  CONSTRAINT leave_types_pkey PRIMARY KEY (id)
);

CREATE TABLE business.marketplace_transactions (
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

CREATE TABLE business.merchant_customers (
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

CREATE TABLE business.merchant_partnerships (
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

CREATE TABLE business.merchant_service_availability (
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

CREATE TABLE business.merchants (
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

CREATE TABLE business.partners (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  updated_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  deleted_at timestamp with time zone,
  merchant_id uuid NOT NULL,
  name text NOT NULL,
  address text,
  contact_info text,
  is_active boolean DEFAULT true,
  CONSTRAINT partners_pkey PRIMARY KEY (id)
);

CREATE TABLE business.merch_imports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  merchant_id uuid NOT NULL,
  imported_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  source text NOT NULL,
  csv_file_url text,
  total_revenue numeric DEFAULT 0,
  remaining_balance numeric DEFAULT 0,
  CONSTRAINT merch_imports_pkey PRIMARY KEY (id)
);

CREATE TABLE business.payment_methods (
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

CREATE TABLE business.payment_types (
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

CREATE TABLE business.payroll_records (
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
  base_salary numeric NOT NULL,
  overtime_pay numeric DEFAULT 0,
  commission numeric DEFAULT 0,
  bonus numeric DEFAULT 0,
  allowances numeric DEFAULT 0,
  gross_pay numeric NOT NULL,
  tax_deduction numeric DEFAULT 0,
  insurance_deduction numeric DEFAULT 0,
  other_deductions numeric DEFAULT 0,
  net_pay numeric NOT NULL,
  status character varying DEFAULT 'pending'::character varying,
  processed_at timestamp with time zone,
  paid_at timestamp with time zone,
  payment_method character varying,
  payment_reference text,
  CONSTRAINT payroll_records_pkey PRIMARY KEY (id),
  CONSTRAINT payroll_records_status_check CHECK (status::text = ANY (ARRAY['pending'::character varying, 'processed'::character varying, 'paid'::character varying, 'cancelled'::character varying]::text[]))
);

CREATE TABLE business.plan_change_requests (
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

CREATE TABLE business.pricing_faq (
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

CREATE TABLE business.product_images (
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

CREATE TABLE business.products (
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

CREATE TABLE business.products_categories (
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

CREATE TABLE business.provinces (
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

CREATE TABLE business.referral_agents (
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
  CONSTRAINT referral_agents_email_key UNIQUE (email),
  CONSTRAINT referral_agents_phone_key UNIQUE (phone),
  CONSTRAINT referral_agents_referral_code_key UNIQUE (referral_code)
);

CREATE TABLE business.referral_commissions (
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

CREATE TABLE business.referral_payments (
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

CREATE TABLE business.referral_settings (
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

CREATE TABLE business.role_assignments (
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
  status business.user_role_assignment_status DEFAULT 'invited'::business.user_role_assignment_status,
  need_change_password boolean NOT NULL DEFAULT false,
  CONSTRAINT role_assignments_pkey PRIMARY KEY (id)
);

CREATE TABLE business.roles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  code text NOT NULL,
  name text NOT NULL,
  permissions text[],
  CONSTRAINT roles_pkey PRIMARY KEY (id)
);

CREATE TABLE business.sales (
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

CREATE TABLE business.sales_items (
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

CREATE TABLE business.service_bookings (
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

CREATE TABLE business.store_business_hours (
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
  CONSTRAINT store_business_hours_day_of_week_check CHECK (day_of_week >= 0 AND day_of_week <= 6)
);

CREATE TABLE business.store_cart_items (
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

CREATE TABLE business.store_carts (
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

CREATE TABLE business.store_payment_methods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  store_id uuid NOT NULL,
  payment_method_id uuid NOT NULL,
  is_active boolean DEFAULT true,
  CONSTRAINT store_payment_methods_pkey PRIMARY KEY (id)
);

CREATE TABLE business.stores (
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

CREATE TABLE business.subscription_notifications (
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

CREATE TABLE business.subscription_plans (
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

CREATE TABLE business.subscription_usage_analytics (
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

CREATE TABLE business.user_subscriptions (
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

CREATE TABLE business.programs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  created_by uuid NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'::uuid,
  updated_at timestamp with time zone,
  updated_by uuid,
  deleted_at timestamp with time zone,
  merchant_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  clinic_name text NOT NULL,
  date date NOT NULL,
  location text NOT NULL,
  banner_url text,
  quota_total integer NOT NULL DEFAULT 0,
  quota_used integer NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'Draft'::text,
  type text NOT NULL DEFAULT 'Subsidi'::text,
  budget numeric DEFAULT 0,
  budget_allocated numeric DEFAULT 0,
  doctor_fee_per_cat numeric DEFAULT 0,
  consumables_cost numeric DEFAULT 0,
  venue_cost numeric DEFAULT 0,
  partner_id uuid,
  CONSTRAINT programs_pkey PRIMARY KEY (id)
);

CREATE TABLE business.program_registrations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  updated_at timestamp with time zone,
  deleted_at timestamp with time zone,
  program_id uuid NOT NULL,
  cat_id uuid,
  owner_name text NOT NULL,
  owner_contact text NOT NULL,
  cat_description text NOT NULL,
  cat_photo_url text NOT NULL,
  status text NOT NULL DEFAULT 'Pending'::text,
  attended boolean DEFAULT false,
  rejection_reason text,
  ticket_code text,
  CONSTRAINT program_registrations_pkey PRIMARY KEY (id),
  CONSTRAINT program_registrations_ticket_code_key UNIQUE (ticket_code)
);

-- ============================================
-- PUBLIC SCHEMA
-- ============================================

CREATE TABLE public.activity_logs (
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

CREATE TABLE public.app_settings (
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

CREATE TABLE public.customer_devices (
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
  CONSTRAINT customer_devices_pkey PRIMARY KEY (id)
);

CREATE TABLE public.customers (
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
  auth_id text,
  gender character varying,
  birth_date date,
  auth_provider text NOT NULL DEFAULT 'SUPABASE'::text,
  CONSTRAINT customers_pkey PRIMARY KEY (id),
  CONSTRAINT customers_phone_key UNIQUE (phone),
  CONSTRAINT customers_gender_check CHECK (gender::text = ANY (ARRAY['male'::character varying::text, 'female'::character varying::text, 'other'::character varying::text, 'prefer_not_to_say'::character varying::text]))
);

CREATE TABLE public.user_devices (
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
  CONSTRAINT user_devices_device_fingerprint_check CHECK (length(device_fingerprint) > 0),
  CONSTRAINT user_devices_device_name_check CHECK (device_name IS NULL OR length(device_name) <= 100)
);

CREATE TABLE public.users (
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
  auth_id uuid,
  username text,
  birth_date date,
  gender character varying(10),
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_phone_key UNIQUE (phone),
  CONSTRAINT users_email_key UNIQUE (email),
  CONSTRAINT users_username_key UNIQUE (username),
  CONSTRAINT users_gender_check CHECK (gender::text = ANY (ARRAY['male'::character varying, 'female'::character varying, 'other'::character varying]::text[]))
);

COMMENT ON COLUMN public.users.auth_id IS 'Supabase auth ID for staff authentication';
COMMENT ON COLUMN public.users.username IS 'Username for staff login (used to find email for Supabase auth)';
COMMENT ON COLUMN public.users.birth_date IS 'Employee birth date';
COMMENT ON COLUMN public.users.gender IS 'Employee gender';

-- ============================================
-- SOCIAL SCHEMA
-- ============================================

CREATE TABLE social.community_events (
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

CREATE TABLE social.content_reports (
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

CREATE TABLE social.course_categories (
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

CREATE TABLE social.course_enrollments (
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
  CONSTRAINT course_enrollments_payment_status_check CHECK (payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'refunded'::text]))
);

CREATE TABLE social.courses (
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

CREATE TABLE social.event_participants (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  registration_date timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  attendance_status text DEFAULT 'registered'::text,
  payment_status text DEFAULT 'pending'::text,
  notes text,
  CONSTRAINT event_participants_pkey PRIMARY KEY (id),
  CONSTRAINT event_participants_attendance_status_check CHECK (attendance_status = ANY (ARRAY['registered'::text, 'attended'::text, 'no_show'::text, 'cancelled'::text])),
  CONSTRAINT event_participants_payment_status_check CHECK (payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'refunded'::text]))
);

CREATE TABLE social.faqs (
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

CREATE TABLE social.forum_categories (
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

CREATE TABLE social.forum_post_likes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  post_id uuid NOT NULL,
  user_id uuid NOT NULL,
  CONSTRAINT forum_post_likes_pkey PRIMARY KEY (id)
);

CREATE TABLE social.forum_posts (
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

CREATE TABLE social.forum_replies (
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

CREATE TABLE social.kb_articles (
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

CREATE TABLE social.kb_categories (
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

CREATE TABLE social.product_favorites (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  product_id uuid NOT NULL,
  user_id uuid NOT NULL,
  CONSTRAINT product_favorites_pkey PRIMARY KEY (id)
);

CREATE TABLE social.product_reviews (
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
  CONSTRAINT product_reviews_review_type_check CHECK (review_type = ANY (ARRAY['product'::text, 'service'::text])),
  CONSTRAINT product_reviews_rating_check CHECK (rating >= 1 AND rating <= 5),
  CONSTRAINT product_reviews_professionalism_rating_check CHECK (professionalism_rating >= 1 AND professionalism_rating <= 5),
  CONSTRAINT product_reviews_expertise_rating_check CHECK (expertise_rating >= 1 AND expertise_rating <= 5),
  CONSTRAINT product_reviews_facilities_rating_check CHECK (facilities_rating >= 1 AND facilities_rating <= 5),
  CONSTRAINT product_reviews_results_rating_check CHECK (results_rating >= 1 AND results_rating <= 5)
);

CREATE TABLE social.push_notifications (
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

CREATE TABLE social.user_achievement_unlocks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  user_id uuid NOT NULL,
  achievement_id uuid NOT NULL,
  unlocked_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
  CONSTRAINT user_achievement_unlocks_pkey PRIMARY KEY (id)
);

CREATE TABLE social.user_achievements (
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

CREATE TABLE social.user_levels (
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

CREATE TABLE social.user_preferences (
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

CREATE TABLE social.user_warnings (
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

CREATE TABLE social.xp_transactions (
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

-- ============================================
-- FOREIGN KEY CONSTRAINTS
-- ============================================
-- All foreign key relationships extracted from Supabase database

-- PET SCHEMA Foreign Keys
ALTER TABLE pet.pet_characters ADD CONSTRAINT pet_characters_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_characters ADD CONSTRAINT pet_characters_character_id_fkey FOREIGN KEY (character_id) REFERENCES pet.characters(id);
ALTER TABLE pet.pet_health_history ADD CONSTRAINT pet_health_history_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_healths ADD CONSTRAINT pet_healths_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_medical_records ADD CONSTRAINT pet_medical_records_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_photos ADD CONSTRAINT pet_photos_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_scan_logs ADD CONSTRAINT pet_scan_logs_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_schedules ADD CONSTRAINT pet_schedules_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_schedules ADD CONSTRAINT pet_schedules_schedule_type_id_fkey FOREIGN KEY (schedule_type_id) REFERENCES pet.schedule_types(id);
ALTER TABLE pet.pet_timelines ADD CONSTRAINT pet_timelines_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pet_weight_histories ADD CONSTRAINT pet_weight_history_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE pet.pets ADD CONSTRAINT pets_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE pet.pets ADD CONSTRAINT pets_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.customers(id);
ALTER TABLE pet.health_parameter_definitions ADD CONSTRAINT health_parameter_definitions_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE pet.photo_comments ADD CONSTRAINT photo_comments_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES pet.pet_photos(id);
ALTER TABLE pet.photo_comments ADD CONSTRAINT photo_comments_commenter_id_fkey FOREIGN KEY (commenter_id) REFERENCES public.customers(id);
ALTER TABLE pet.photo_likes ADD CONSTRAINT photo_likes_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES pet.pet_photos(id);
ALTER TABLE pet.photo_likes ADD CONSTRAINT photo_likes_liker_id_fkey FOREIGN KEY (liker_id) REFERENCES public.customers(id);
ALTER TABLE pet.photo_shares ADD CONSTRAINT photo_shares_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES pet.pet_photos(id);
ALTER TABLE pet.pet_health_history ADD CONSTRAINT pet_health_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES auth.users(id);

-- BUSINESS SCHEMA Foreign Keys
ALTER TABLE business.cities ADD CONSTRAINT cities_province_id_fkey FOREIGN KEY (province_id) REFERENCES business.provinces(id);
ALTER TABLE business.provinces ADD CONSTRAINT provinces_country_id_fkey FOREIGN KEY (country_id) REFERENCES business.countries(id);
ALTER TABLE business.payment_methods ADD CONSTRAINT payment_methods_payment_type_id_fkey FOREIGN KEY (payment_type_id) REFERENCES business.payment_types(id);
ALTER TABLE business.merchants ADD CONSTRAINT merchants_city_id_fkey FOREIGN KEY (city_id) REFERENCES business.cities(id);
ALTER TABLE business.merchants ADD CONSTRAINT merchants_province_id_fkey FOREIGN KEY (province_id) REFERENCES business.provinces(id);
ALTER TABLE business.merchants ADD CONSTRAINT merchants_country_id_fkey FOREIGN KEY (country_id) REFERENCES business.countries(id);
ALTER TABLE business.stores ADD CONSTRAINT stores_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES business.merchants(id);
ALTER TABLE business.partners ADD CONSTRAINT partners_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES business.merchants(id);
ALTER TABLE business.merch_imports ADD CONSTRAINT merch_imports_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES business.merchants(id);
ALTER TABLE business.stores ADD CONSTRAINT stores_city_id_fkey FOREIGN KEY (city_id) REFERENCES business.cities(id);
ALTER TABLE business.stores ADD CONSTRAINT stores_province_id_fkey FOREIGN KEY (province_id) REFERENCES business.provinces(id);
ALTER TABLE business.stores ADD CONSTRAINT stores_country_id_fkey FOREIGN KEY (country_id) REFERENCES business.countries(id);
ALTER TABLE business.products_categories ADD CONSTRAINT products_categories_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE business.products ADD CONSTRAINT products_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.products ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES business.products_categories(id);
ALTER TABLE business.products ADD CONSTRAINT products_location_city_id_fkey FOREIGN KEY (location_city_id) REFERENCES business.cities(id);
ALTER TABLE business.products ADD CONSTRAINT products_target_pet_category_id_fkey FOREIGN KEY (target_pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE business.products ADD CONSTRAINT products_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.users(id);
ALTER TABLE business.product_images ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES business.products(id);
ALTER TABLE business.inventory_transactions ADD CONSTRAINT inventory_transactions_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.inventory_transactions ADD CONSTRAINT inventory_transactions_product_id_fkey FOREIGN KEY (product_id) REFERENCES business.products(id);
ALTER TABLE business.sales ADD CONSTRAINT sales_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.sales ADD CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE business.sales ADD CONSTRAINT sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE business.sales ADD CONSTRAINT sales_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES business.payment_methods(id);
ALTER TABLE business.sales_items ADD CONSTRAINT sales_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES business.sales(id);
ALTER TABLE business.sales_items ADD CONSTRAINT sales_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES business.products(id);
ALTER TABLE business.sales_items ADD CONSTRAINT fk_sales_items_assigned_staff FOREIGN KEY (assigned_staff_id) REFERENCES public.users(id);
ALTER TABLE business.store_payment_methods ADD CONSTRAINT store_payment_methods_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.store_payment_methods ADD CONSTRAINT store_payment_methods_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES business.payment_methods(id);
ALTER TABLE business.store_carts ADD CONSTRAINT store_carts_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.store_carts ADD CONSTRAINT store_carts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE business.store_cart_items ADD CONSTRAINT store_cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES business.store_carts(id);
ALTER TABLE business.store_cart_items ADD CONSTRAINT store_cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES business.products(id);
ALTER TABLE business.store_cart_items ADD CONSTRAINT fk_cart_items_assigned_staff FOREIGN KEY (assigned_staff_id) REFERENCES public.users(id);
ALTER TABLE business.store_business_hours ADD CONSTRAINT store_business_hours_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.merchant_customers ADD CONSTRAINT merchant_customers_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES business.merchants(id);
ALTER TABLE business.merchant_customers ADD CONSTRAINT merchant_customers_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE business.merchant_customers ADD CONSTRAINT merchant_customers_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.merchant_partnerships ADD CONSTRAINT merchant_partnerships_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES business.merchants(id);
ALTER TABLE business.merchant_partnerships ADD CONSTRAINT merchant_partnerships_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.merchant_service_availability ADD CONSTRAINT merchant_service_availability_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.merchant_service_availability ADD CONSTRAINT merchant_service_availability_service_product_id_fkey FOREIGN KEY (service_product_id) REFERENCES business.products(id);
ALTER TABLE business.service_bookings ADD CONSTRAINT service_bookings_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE business.service_bookings ADD CONSTRAINT service_bookings_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id);
ALTER TABLE business.service_bookings ADD CONSTRAINT service_bookings_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.service_bookings ADD CONSTRAINT service_bookings_service_product_id_fkey FOREIGN KEY (service_product_id) REFERENCES business.products(id);
ALTER TABLE business.service_bookings ADD CONSTRAINT service_bookings_assigned_staff_id_fkey FOREIGN KEY (assigned_staff_id) REFERENCES public.users(id);
ALTER TABLE business.service_bookings ADD CONSTRAINT service_bookings_partnership_id_fkey FOREIGN KEY (partnership_id) REFERENCES business.merchant_partnerships(id);
ALTER TABLE business.service_bookings ADD CONSTRAINT service_bookings_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES business.sales(id);
ALTER TABLE business.role_assignments ADD CONSTRAINT role_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE business.role_assignments ADD CONSTRAINT role_assignments_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES business.merchants(id);
ALTER TABLE business.role_assignments ADD CONSTRAINT role_assignments_role_id_fkey FOREIGN KEY (role_id) REFERENCES business.roles(id);
ALTER TABLE business.role_assignments ADD CONSTRAINT role_assignments_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.attendance_records ADD CONSTRAINT attendance_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE business.attendance_records ADD CONSTRAINT attendance_records_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.attendance_records ADD CONSTRAINT attendance_records_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);
ALTER TABLE business.leave_types ADD CONSTRAINT leave_types_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.leave_requests ADD CONSTRAINT leave_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE business.leave_requests ADD CONSTRAINT leave_requests_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES business.leave_types(id);
ALTER TABLE business.leave_requests ADD CONSTRAINT leave_requests_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id);
ALTER TABLE business.leave_balances ADD CONSTRAINT leave_balances_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE business.leave_balances ADD CONSTRAINT leave_balances_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES business.leave_types(id);
ALTER TABLE business.payroll_records ADD CONSTRAINT payroll_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE business.payroll_records ADD CONSTRAINT payroll_records_store_id_fkey FOREIGN KEY (store_id) REFERENCES business.stores(id);
ALTER TABLE business.commission_records ADD CONSTRAINT commission_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE business.commission_records ADD CONSTRAINT commission_records_pay_period_id_fkey FOREIGN KEY (pay_period_id) REFERENCES business.payroll_records(id);
ALTER TABLE business.employee_documents ADD CONSTRAINT employee_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE business.feature_flags ADD CONSTRAINT feature_flags_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES business.subscription_plans(id);
ALTER TABLE business.user_subscriptions ADD CONSTRAINT user_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE business.user_subscriptions ADD CONSTRAINT user_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES business.subscription_plans(id);
ALTER TABLE business.user_subscriptions ADD CONSTRAINT user_subscriptions_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES business.referral_agents(id);
ALTER TABLE business.billing_invoices ADD CONSTRAINT billing_invoices_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE business.billing_invoices ADD CONSTRAINT billing_invoices_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES business.user_subscriptions(id);
ALTER TABLE business.billing_payments ADD CONSTRAINT billing_payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES business.billing_invoices(id);
ALTER TABLE business.billing_transactions ADD CONSTRAINT billing_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE business.feature_usage ADD CONSTRAINT feature_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE business.plan_change_requests ADD CONSTRAINT plan_change_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE business.plan_change_requests ADD CONSTRAINT plan_change_requests_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES business.user_subscriptions(id);
ALTER TABLE business.plan_change_requests ADD CONSTRAINT plan_change_requests_from_plan_id_fkey FOREIGN KEY (from_plan_id) REFERENCES business.subscription_plans(id);
ALTER TABLE business.plan_change_requests ADD CONSTRAINT plan_change_requests_to_plan_id_fkey FOREIGN KEY (to_plan_id) REFERENCES business.subscription_plans(id);
ALTER TABLE business.subscription_usage_analytics ADD CONSTRAINT subscription_usage_analytics_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE business.subscription_usage_analytics ADD CONSTRAINT subscription_usage_analytics_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES business.user_subscriptions(id);
ALTER TABLE business.subscription_notifications ADD CONSTRAINT subscription_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE business.subscription_notifications ADD CONSTRAINT subscription_notifications_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES business.user_subscriptions(id);
ALTER TABLE business.referral_commissions ADD CONSTRAINT referral_commissions_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES business.referral_agents(id);
ALTER TABLE business.referral_commissions ADD CONSTRAINT referral_commissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);
ALTER TABLE business.referral_commissions ADD CONSTRAINT referral_commissions_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES business.user_subscriptions(id);
ALTER TABLE business.referral_payments ADD CONSTRAINT referral_payments_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES business.referral_agents(id);
ALTER TABLE business.marketplace_transactions ADD CONSTRAINT marketplace_transactions_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public.users(id);
ALTER TABLE business.marketplace_transactions ADD CONSTRAINT marketplace_transactions_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.users(id);
ALTER TABLE business.marketplace_transactions ADD CONSTRAINT marketplace_transactions_product_id_fkey FOREIGN KEY (product_id) REFERENCES business.products(id);
ALTER TABLE business.programs ADD CONSTRAINT programs_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES business.merchants(id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE business.programs ADD CONSTRAINT programs_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES business.partners(id);
ALTER TABLE business.program_registrations ADD CONSTRAINT program_registrations_program_id_fkey FOREIGN KEY (program_id) REFERENCES business.programs(id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE business.program_registrations ADD CONSTRAINT program_registrations_cat_id_fkey FOREIGN KEY (cat_id) REFERENCES pet.pets(id) ON DELETE SET NULL ON UPDATE CASCADE;

-- PUBLIC SCHEMA Foreign Keys
ALTER TABLE public.user_devices ADD CONSTRAINT user_devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE public.customer_devices ADD CONSTRAINT customer_devices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);
ALTER TABLE public.activity_logs ADD CONSTRAINT activity_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);

-- SOCIAL SCHEMA Foreign Keys
ALTER TABLE social.forum_categories ADD CONSTRAINT forum_categories_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE social.forum_posts ADD CONSTRAINT forum_posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);
ALTER TABLE social.forum_posts ADD CONSTRAINT forum_posts_category_id_fkey FOREIGN KEY (category_id) REFERENCES social.forum_categories(id);
ALTER TABLE social.forum_replies ADD CONSTRAINT forum_replies_post_id_fkey FOREIGN KEY (post_id) REFERENCES social.forum_posts(id);
ALTER TABLE social.forum_replies ADD CONSTRAINT forum_replies_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);
ALTER TABLE social.forum_replies ADD CONSTRAINT forum_replies_parent_reply_id_fkey FOREIGN KEY (parent_reply_id) REFERENCES social.forum_replies(id);
ALTER TABLE social.forum_post_likes ADD CONSTRAINT forum_post_likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES social.forum_posts(id);
ALTER TABLE social.forum_post_likes ADD CONSTRAINT forum_post_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.product_reviews ADD CONSTRAINT product_reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES business.products(id);
ALTER TABLE social.product_reviews ADD CONSTRAINT product_reviews_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id);
ALTER TABLE social.product_reviews ADD CONSTRAINT product_reviews_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES business.service_bookings(id);
ALTER TABLE social.product_favorites ADD CONSTRAINT product_favorites_product_id_fkey FOREIGN KEY (product_id) REFERENCES business.products(id);
ALTER TABLE social.product_favorites ADD CONSTRAINT product_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.community_events ADD CONSTRAINT community_events_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE social.community_events ADD CONSTRAINT community_events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES public.users(id);
ALTER TABLE social.community_events ADD CONSTRAINT community_events_location_city_id_fkey FOREIGN KEY (location_city_id) REFERENCES business.cities(id);
ALTER TABLE social.event_participants ADD CONSTRAINT event_participants_event_id_fkey FOREIGN KEY (event_id) REFERENCES social.community_events(id);
ALTER TABLE social.event_participants ADD CONSTRAINT event_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.course_categories ADD CONSTRAINT course_categories_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE social.courses ADD CONSTRAINT courses_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES public.users(id);
ALTER TABLE social.courses ADD CONSTRAINT courses_category_id_fkey FOREIGN KEY (category_id) REFERENCES social.course_categories(id);
ALTER TABLE social.course_enrollments ADD CONSTRAINT course_enrollments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.course_enrollments ADD CONSTRAINT course_enrollments_course_id_fkey FOREIGN KEY (course_id) REFERENCES social.courses(id);
ALTER TABLE social.kb_categories ADD CONSTRAINT kb_categories_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id);
ALTER TABLE social.kb_articles ADD CONSTRAINT kb_articles_category_id_fkey FOREIGN KEY (category_id) REFERENCES social.kb_categories(id);
ALTER TABLE social.kb_articles ADD CONSTRAINT kb_articles_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);
ALTER TABLE social.faqs ADD CONSTRAINT faqs_category_id_fkey FOREIGN KEY (category_id) REFERENCES social.kb_categories(id);
ALTER TABLE social.user_preferences ADD CONSTRAINT user_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.user_achievement_unlocks ADD CONSTRAINT user_achievement_unlocks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.user_achievement_unlocks ADD CONSTRAINT user_achievement_unlocks_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES social.user_achievements(id);
ALTER TABLE social.xp_transactions ADD CONSTRAINT xp_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.push_notifications ADD CONSTRAINT push_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.content_reports ADD CONSTRAINT content_reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.users(id);
ALTER TABLE social.content_reports ADD CONSTRAINT content_reports_moderator_id_fkey FOREIGN KEY (moderator_id) REFERENCES public.users(id);
ALTER TABLE social.user_warnings ADD CONSTRAINT user_warnings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
ALTER TABLE social.user_warnings ADD CONSTRAINT user_warnings_moderator_id_fkey FOREIGN KEY (moderator_id) REFERENCES public.users(id);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================
-- RLS policies have been moved to docs/rls.sql
-- See that file for all RLS enable statements and policy definitions

-- ============================================
-- FUNCTIONS
-- ============================================

-- Pet schema functions
CREATE OR REPLACE FUNCTION pet.calculate_health_score(p_health_parameters jsonb, p_pet_category_id uuid)
RETURNS text
LANGUAGE plpgsql
AS $function$
DECLARE
  v_parameter record;
  v_value jsonb;
  v_has_issue boolean := false;
BEGIN
  FOR v_parameter IN 
    SELECT parameter_key, parameter_type
    FROM pet.health_parameter_definitions
    WHERE pet_category_id = p_pet_category_id
      AND affects_health_score = true
      AND deleted_at IS NULL
  LOOP
    v_value := p_health_parameters -> v_parameter.parameter_key;
    
    IF v_value IS NOT NULL THEN
      CASE v_parameter.parameter_type
        WHEN 'boolean' THEN
          IF v_parameter.parameter_key IN ('is_vaccinated', 'is_sterilized', 'calcium_phosphorus_balanced', 'diet_appropriate') THEN
            IF (v_value)::boolean = false THEN
              v_has_issue := true;
              EXIT;
            END IF;
          ELSIF v_parameter.parameter_key IN ('has_fungus', 'has_worms', 'has_fleas', 'has_mites') THEN
            IF (v_value)::boolean = true THEN
              v_has_issue := true;
              EXIT;
            END IF;
          END IF;
        WHEN 'select' THEN
          IF (v_value)::text IN ('"bad"', '"needs_check"') THEN
            v_has_issue := true;
            EXIT;
          END IF;
      END CASE;
    END IF;
  END LOOP;
  
  IF v_has_issue THEN
    RETURN 'needs_attention';
  ELSE
    RETURN 'healthy';
  END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION pet.generate_qr_id()
RETURNS character varying
LANGUAGE plpgsql
AS $function$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result VARCHAR(6) := '';
  i INT;
  attempts INT := 0;
  max_attempts INT := 100;
BEGIN
  LOOP
    result := '';
    FOR i IN 1..6 LOOP
      result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
    END LOOP;
    
    IF NOT EXISTS (SELECT 1 FROM pet.pets WHERE qr_id = result) THEN
      RETURN result;
    END IF;
    
    attempts := attempts + 1;
    IF attempts >= max_attempts THEN
      RAISE EXCEPTION 'Unable to generate unique QR ID after % attempts', max_attempts;
    END IF;
  END LOOP;
END;
$function$;

-- Public schema functions (key functions only - full list available in Supabase)
CREATE OR REPLACE FUNCTION public.ensure_single_primary_image()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.is_primary = true THEN
        UPDATE business.product_images 
        SET is_primary = false, updated_at = NOW()
        WHERE product_id = NEW.product_id 
        AND id != NEW.id
        AND deleted_at IS NULL;
    END IF;
    
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.update_user_devices_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$;

-- Note: Additional functions are available in the database
-- Use pg_proc view to get complete function definitions

-- ============================================
-- TRIGGERS
-- ============================================

CREATE TRIGGER trigger_ensure_single_primary_image 
BEFORE INSERT OR UPDATE ON business.product_images 
FOR EACH ROW EXECUTE FUNCTION public.ensure_single_primary_image();

CREATE TRIGGER trigger_update_user_devices_updated_at 
BEFORE UPDATE ON public.user_devices 
FOR EACH ROW EXECUTE FUNCTION public.update_user_devices_updated_at();

-- ============================================
-- INDEXES
-- ============================================

-- Note: Primary key indexes are automatically created
-- Below are additional indexes for performance optimization

-- Business schema indexes (key indexes - full list available via pg_indexes view)
CREATE INDEX IF NOT EXISTS idx_attendance_records_date ON business.attendance_records USING btree (attendance_date);
CREATE INDEX IF NOT EXISTS idx_attendance_records_status ON business.attendance_records USING btree (status);
CREATE INDEX IF NOT EXISTS idx_attendance_records_store_id ON business.attendance_records USING btree (store_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_user_id ON business.attendance_records USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_billing_invoices_status ON business.billing_invoices USING btree (status);
CREATE INDEX IF NOT EXISTS idx_billing_invoices_subscription_id ON business.billing_invoices USING btree (subscription_id);
CREATE INDEX IF NOT EXISTS idx_billing_invoices_user_id ON business.billing_invoices USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_products_store_id ON business.products USING btree (store_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON business.products USING btree (category_id);
CREATE INDEX IF NOT EXISTS idx_sales_store_id ON business.sales USING btree (store_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON business.sales USING btree (customer_id);
CREATE INDEX IF NOT EXISTS idx_service_bookings_store_id ON business.service_bookings USING btree (store_id);
CREATE INDEX IF NOT EXISTS idx_service_bookings_booking_date ON business.service_bookings USING btree (booking_date);
CREATE INDEX IF NOT EXISTS idx_service_bookings_status ON business.service_bookings USING btree (status);
CREATE INDEX IF NOT EXISTS idx_stores_merchant_id ON business.stores USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS idx_partners_merchant_id ON business.partners USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS idx_merch_imports_merchant_id ON business.merch_imports USING btree (merchant_id);
CREATE INDEX IF NOT EXISTS idx_programs_partner_id ON business.programs USING btree (partner_id);
CREATE INDEX IF NOT EXISTS idx_role_assignments_user_id ON business.role_assignments USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_role_assignments_store_id ON business.role_assignments USING btree (store_id);

-- Pet schema indexes
CREATE INDEX IF NOT EXISTS idx_pets_pet_category_id ON pet.pets USING btree (pet_category_id);
CREATE INDEX IF NOT EXISTS idx_pets_qr_id ON pet.pets USING btree (qr_id);
CREATE INDEX IF NOT EXISTS idx_pet_photos_pet_id ON pet.pet_photos USING btree (pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_timelines_pet_id ON pet.pet_timelines USING btree (pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_timelines_event_date ON pet.pet_timelines USING btree (event_date DESC);
CREATE INDEX IF NOT EXISTS idx_pet_medical_records_pet_id ON pet.pet_medical_records USING btree (pet_id);
CREATE INDEX IF NOT EXISTS idx_pet_scan_logs_pet_id ON pet.pet_scan_logs USING btree (pet_id);

-- Public schema indexes
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON public.users USING btree (auth_id);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users USING btree (phone);
CREATE INDEX IF NOT EXISTS idx_users_username ON public.users USING btree (username);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON public.customers USING btree (phone);
CREATE INDEX IF NOT EXISTS idx_customers_auth_id ON public.customers USING btree (auth_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id ON public.user_devices USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_user_devices_fingerprint ON public.user_devices USING btree (device_fingerprint);
CREATE INDEX IF NOT EXISTS idx_activity_logs_user_id ON public.activity_logs USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_activity_logs_created_at ON public.activity_logs USING btree (created_at DESC);

-- Social schema indexes
CREATE INDEX IF NOT EXISTS idx_forum_posts_author_id ON social.forum_posts USING btree (author_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_category_id ON social.forum_posts USING btree (category_id);
CREATE INDEX IF NOT EXISTS idx_forum_posts_created_at ON social.forum_posts USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_reviews_product_id ON social.product_reviews USING btree (product_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_reviewer_id ON social.product_reviews USING btree (reviewer_id);
CREATE INDEX IF NOT EXISTS idx_push_notifications_user_id ON social.push_notifications USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_community_events_event_date ON social.community_events USING btree (event_date);

-- Unique indexes
CREATE UNIQUE INDEX IF NOT EXISTS products_code_key ON business.products USING btree (code) WHERE code IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS pets_qr_id_key ON pet.pets USING btree (qr_id) WHERE qr_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS users_email_key ON public.users USING btree (email);
CREATE UNIQUE INDEX IF NOT EXISTS users_phone_key ON public.users USING btree (phone);
CREATE UNIQUE INDEX IF NOT EXISTS users_username_key ON public.users USING btree (username) WHERE username IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS customers_phone_key ON public.customers USING btree (phone);
CREATE UNIQUE INDEX IF NOT EXISTS unique_user_device ON public.user_devices USING btree (user_id, device_fingerprint);
CREATE UNIQUE INDEX IF NOT EXISTS service_bookings_booking_reference_key ON business.service_bookings USING btree (booking_reference) WHERE booking_reference IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS program_registrations_ticket_code_key ON business.program_registrations USING btree (ticket_code) WHERE ticket_code IS NOT NULL;

-- Note: Complete index list is available via pg_indexes view
-- Use: SELECT * FROM pg_indexes WHERE schemaname IN ('public', 'pet', 'business', 'social');
