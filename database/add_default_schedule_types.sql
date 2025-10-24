-- Add default schedule types for pet care
-- Migration: add_default_schedule_types
-- Created: 2025-10-19

INSERT INTO pet.schedule_types (id, name, description, icon, color, is_recurring, default_duration_minutes, created_at)
VALUES
  -- Grooming
  (
    gen_random_uuid(),
    'Grooming',
    'Pet grooming and hygiene care',
    'scissors',
    '#9333EA',
    false,
    60,
    NOW()
  ),
  -- Medical Checkup
  (
    gen_random_uuid(),
    'Medical Checkup',
    'Regular veterinary checkup',
    'stethoscope',
    '#EC4899',
    false,
    45,
    NOW()
  ),
  -- Vaccination
  (
    gen_random_uuid(),
    'Vaccination',
    'Vaccination schedule',
    'syringe',
    '#3B82F6',
    false,
    30,
    NOW()
  ),
  -- Medication
  (
    gen_random_uuid(),
    'Medication',
    'Medicine administration reminder',
    'pill',
    '#10B981',
    true,
    5,
    NOW()
  ),
  -- Birthday
  (
    gen_random_uuid(),
    'Birthday',
    'Pet birthday celebration',
    'cake',
    '#F59E0B',
    true,
    0,
    NOW()
  ),
  -- Feeding
  (
    gen_random_uuid(),
    'Feeding',
    'Regular feeding schedule',
    'utensils',
    '#6366F1',
    true,
    15,
    NOW()
  ),
  -- Playtime
  (
    gen_random_uuid(),
    'Playtime',
    'Exercise and play session',
    'gamepad2',
    '#14B8A6',
    true,
    30,
    NOW()
  ),
  -- Bath
  (
    gen_random_uuid(),
    'Bath',
    'Bathing schedule',
    'droplet',
    '#06B6D4',
    false,
    30,
    NOW()
  ),
  -- Nail Trimming
  (
    gen_random_uuid(),
    'Nail Trimming',
    'Nail care and trimming',
    'scissors',
    '#8B5CF6',
    false,
    15,
    NOW()
  ),
  -- Dental Care
  (
    gen_random_uuid(),
    'Dental Care',
    'Teeth cleaning and dental checkup',
    'stethoscope',
    '#F97316',
    false,
    20,
    NOW()
  )
ON CONFLICT DO NOTHING;

COMMENT ON TABLE pet.schedule_types IS 'Available schedule/reminder types for pet care';

