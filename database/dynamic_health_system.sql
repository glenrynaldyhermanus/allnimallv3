-- Dynamic Health System Migration
-- Created: 2025-10-23
-- Description: Implements dynamic health parameters per pet category with historical tracking

-- ============================================================================
-- 1. CREATE health_parameter_definitions TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS pet.health_parameter_definitions (
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
  CONSTRAINT health_parameter_definitions_pkey PRIMARY KEY (id),
  CONSTRAINT health_parameter_definitions_pet_category_id_fkey FOREIGN KEY (pet_category_id) REFERENCES pet.pet_categories(id),
  CONSTRAINT health_parameter_definitions_parameter_type_check CHECK (parameter_type = ANY (ARRAY['boolean'::text, 'date'::text, 'text'::text, 'number'::text, 'select'::text])),
  CONSTRAINT health_parameter_definitions_unique_key UNIQUE (pet_category_id, parameter_key)
);

COMMENT ON TABLE pet.health_parameter_definitions IS 'Defines health parameters per pet category for dynamic health tracking';
COMMENT ON COLUMN pet.health_parameter_definitions.parameter_key IS 'Unique key for parameter, e.g., is_vaccinated, has_fleas';
COMMENT ON COLUMN pet.health_parameter_definitions.parameter_type IS 'Data type: boolean, date, text, number, select';
COMMENT ON COLUMN pet.health_parameter_definitions.affects_health_score IS 'Whether this parameter affects overall health score calculation';

-- ============================================================================
-- 2. CREATE pet_health_history TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS pet.pet_health_history (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  pet_id uuid NOT NULL,
  parameter_key text NOT NULL,
  old_value jsonb,
  new_value jsonb,
  changed_at timestamp with time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc'::text),
  changed_by uuid,
  notes text,
  CONSTRAINT pet_health_history_pkey PRIMARY KEY (id),
  CONSTRAINT pet_health_history_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES pet.pets(id) ON DELETE CASCADE,
  CONSTRAINT pet_health_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES auth.users(id)
);

COMMENT ON TABLE pet.pet_health_history IS 'Historical tracking of all pet health parameter changes';
COMMENT ON COLUMN pet.pet_health_history.parameter_key IS 'The health parameter that was changed';
COMMENT ON COLUMN pet.pet_health_history.old_value IS 'Previous value in JSONB format';
COMMENT ON COLUMN pet.pet_health_history.new_value IS 'New value in JSONB format';

-- ============================================================================
-- 3. ALTER pet_healths TABLE
-- ============================================================================

-- Add new columns
ALTER TABLE pet.pet_healths
  ADD COLUMN IF NOT EXISTS health_parameters jsonb DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS health_score text DEFAULT 'healthy',
  ADD COLUMN IF NOT EXISTS last_scored_at timestamp with time zone;

-- Add check constraint for health_score
ALTER TABLE pet.pet_healths
  DROP CONSTRAINT IF EXISTS pet_healths_health_score_check;

ALTER TABLE pet.pet_healths
  ADD CONSTRAINT pet_healths_health_score_check 
  CHECK (health_score IN ('healthy', 'needs_attention'));

COMMENT ON COLUMN pet.pet_healths.health_parameters IS 'Dynamic health parameters stored as JSONB key-value pairs';
COMMENT ON COLUMN pet.pet_healths.health_score IS 'Calculated health score: healthy or needs_attention';
COMMENT ON COLUMN pet.pet_healths.last_scored_at IS 'Timestamp when health score was last calculated';

-- NOTE: Old columns (vaccination_status, last_vaccination_date, next_vaccination_date, 
-- medical_conditions, allergies) are kept for backward compatibility during migration.
-- They can be dropped after data migration is complete.

-- ============================================================================
-- 4. CREATE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_health_parameter_definitions_category 
  ON pet.health_parameter_definitions(pet_category_id) 
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_health_parameter_definitions_key 
  ON pet.health_parameter_definitions(parameter_key);

CREATE INDEX IF NOT EXISTS idx_pet_health_history_pet_id 
  ON pet.pet_health_history(pet_id);

CREATE INDEX IF NOT EXISTS idx_pet_health_history_parameter 
  ON pet.pet_health_history(parameter_key);

CREATE INDEX IF NOT EXISTS idx_pet_health_history_changed_at 
  ON pet.pet_health_history(changed_at DESC);

CREATE INDEX IF NOT EXISTS idx_pet_healths_health_score 
  ON pet.pet_healths(health_score);

-- ============================================================================
-- 5. INSERT DEFAULT HEALTH PARAMETERS
-- ============================================================================

-- Get pet category IDs (assuming these UUIDs from the codebase)
-- Kucing: e76601d1-eaf1-42fc-ad9c-d49821518e4a
-- Anjing: b30f979e-df0d-4151-ba0e-a958093f2ae3
-- You'll need to add Sugar Glider category first or use actual UUID

-- KUCING (Cat) Health Parameters
INSERT INTO pet.health_parameter_definitions (
  pet_category_id, 
  parameter_key, 
  parameter_name_id, 
  parameter_name_en, 
  parameter_type, 
  affects_health_score, 
  display_order, 
  icon, 
  color,
  description
) VALUES
  (
    'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
    'is_vaccinated',
    'Sudah Divaksin',
    'Vaccinated',
    'boolean',
    true,
    1,
    'syringe',
    '#3B82F6',
    'Status vaksinasi kucing'
  ),
  (
    'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
    'vaccination_date',
    'Tanggal Vaksinasi Terakhir',
    'Last Vaccination Date',
    'date',
    false,
    2,
    'calendar',
    '#3B82F6',
    'Tanggal vaksinasi terakhir'
  ),
  (
    'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
    'is_sterilized',
    'Sudah Disteril',
    'Sterilized',
    'boolean',
    true,
    3,
    'shield',
    '#10B981',
    'Status sterilisasi/kastrasi'
  ),
  (
    'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
    'sterilization_date',
    'Tanggal Sterilisasi',
    'Sterilization Date',
    'date',
    false,
    4,
    'calendar',
    '#10B981',
    'Tanggal sterilisasi'
  ),
  (
    'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
    'has_fungus',
    'Ada Jamur',
    'Has Fungus',
    'boolean',
    true,
    5,
    'alert-circle',
    '#F59E0B',
    'Apakah ada infeksi jamur'
  ),
  (
    'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
    'has_worms',
    'Ada Cacing',
    'Has Worms',
    'boolean',
    true,
    6,
    'alert-triangle',
    '#EF4444',
    'Apakah ada cacingan'
  ),
  (
    'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
    'has_fleas',
    'Ada Kutu',
    'Has Fleas',
    'boolean',
    true,
    7,
    'bug',
    '#DC2626',
    'Apakah ada kutu'
  ),
  (
    'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
    'stool_quality',
    'Kualitas Kotoran',
    'Stool Quality',
    'select',
    true,
    8,
    'clipboard-check',
    '#8B5CF6',
    'Kualitas feses/kotoran'
  )
ON CONFLICT (pet_category_id, parameter_key) DO NOTHING;

-- ANJING (Dog) Health Parameters (same as cat)
INSERT INTO pet.health_parameter_definitions (
  pet_category_id, 
  parameter_key, 
  parameter_name_id, 
  parameter_name_en, 
  parameter_type, 
  affects_health_score, 
  display_order, 
  icon, 
  color,
  description
) VALUES
  (
    'b30f979e-df0d-4151-ba0e-a958093f2ae3',
    'is_vaccinated',
    'Sudah Divaksin',
    'Vaccinated',
    'boolean',
    true,
    1,
    'syringe',
    '#3B82F6',
    'Status vaksinasi anjing'
  ),
  (
    'b30f979e-df0d-4151-ba0e-a958093f2ae3',
    'vaccination_date',
    'Tanggal Vaksinasi Terakhir',
    'Last Vaccination Date',
    'date',
    false,
    2,
    'calendar',
    '#3B82F6',
    'Tanggal vaksinasi terakhir'
  ),
  (
    'b30f979e-df0d-4151-ba0e-a958093f2ae3',
    'is_sterilized',
    'Sudah Disteril',
    'Sterilized',
    'boolean',
    true,
    3,
    'shield',
    '#10B981',
    'Status sterilisasi/kastrasi'
  ),
  (
    'b30f979e-df0d-4151-ba0e-a958093f2ae3',
    'sterilization_date',
    'Tanggal Sterilisasi',
    'Sterilization Date',
    'date',
    false,
    4,
    'calendar',
    '#10B981',
    'Tanggal sterilisasi'
  ),
  (
    'b30f979e-df0d-4151-ba0e-a958093f2ae3',
    'has_fungus',
    'Ada Jamur',
    'Has Fungus',
    'boolean',
    true,
    5,
    'alert-circle',
    '#F59E0B',
    'Apakah ada infeksi jamur'
  ),
  (
    'b30f979e-df0d-4151-ba0e-a958093f2ae3',
    'has_worms',
    'Ada Cacing',
    'Has Worms',
    'boolean',
    true,
    6,
    'alert-triangle',
    '#EF4444',
    'Apakah ada cacingan'
  ),
  (
    'b30f979e-df0d-4151-ba0e-a958093f2ae3',
    'has_fleas',
    'Ada Kutu',
    'Has Fleas',
    'boolean',
    true,
    7,
    'bug',
    '#DC2626',
    'Apakah ada kutu'
  ),
  (
    'b30f979e-df0d-4151-ba0e-a958093f2ae3',
    'stool_quality',
    'Kualitas Kotoran',
    'Stool Quality',
    'select',
    true,
    8,
    'clipboard-check',
    '#8B5CF6',
    'Kualitas feses/kotoran'
  )
ON CONFLICT (pet_category_id, parameter_key) DO NOTHING;

-- SUGAR GLIDER Health Parameters (different parameters)
-- Note: You need to create Sugar Glider category first and replace UUID below
-- Example UUID placeholder: '00000000-0000-0000-0000-000000000003'
/*
INSERT INTO pet.health_parameter_definitions (
  pet_category_id, 
  parameter_key, 
  parameter_name_id, 
  parameter_name_en, 
  parameter_type, 
  affects_health_score, 
  display_order, 
  icon, 
  color,
  description
) VALUES
  (
    '00000000-0000-0000-0000-000000000003', -- Replace with actual Sugar Glider UUID
    'is_vaccinated',
    'Sudah Divaksin',
    'Vaccinated',
    'boolean',
    false,
    1,
    'syringe',
    '#3B82F6',
    'Status vaksinasi (opsional untuk sugar glider)'
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'calcium_phosphorus_balanced',
    'Kalsium-Fosfor Seimbang',
    'Calcium-Phosphorus Balanced',
    'boolean',
    true,
    2,
    'activity',
    '#10B981',
    'Apakah rasio kalsium-fosfor dalam diet seimbang'
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'has_mites',
    'Ada Tungau',
    'Has Mites',
    'boolean',
    true,
    3,
    'bug',
    '#DC2626',
    'Apakah ada tungau/mites'
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'membrane_health',
    'Kesehatan Membran',
    'Membrane Health',
    'select',
    true,
    4,
    'heart',
    '#F59E0B',
    'Kondisi membran gliding'
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    'diet_appropriate',
    'Diet Sesuai',
    'Diet Appropriate',
    'boolean',
    true,
    5,
    'apple',
    '#8B5CF6',
    'Apakah diet sesuai kebutuhan sugar glider'
  )
ON CONFLICT (pet_category_id, parameter_key) DO NOTHING;
*/

-- ============================================================================
-- 6. GRANT PERMISSIONS (if using RLS)
-- ============================================================================

-- Enable RLS
ALTER TABLE pet.health_parameter_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE pet.pet_health_history ENABLE ROW LEVEL SECURITY;

-- Policy for health_parameter_definitions (read-only for authenticated users)
CREATE POLICY "Allow authenticated users to read health parameter definitions"
  ON pet.health_parameter_definitions
  FOR SELECT
  TO authenticated
  USING (deleted_at IS NULL);

-- Policy for admins to manage health parameter definitions
CREATE POLICY "Allow admins to manage health parameter definitions"
  ON pet.health_parameter_definitions
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND auth.users.role = 'admin'
    )
  );

-- Policy for pet_health_history (users can read their own pets' history)
CREATE POLICY "Allow users to read their own pet health history"
  ON pet.pet_health_history
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM pet.pets 
      WHERE pets.id = pet_health_history.pet_id 
      AND pets.owner_id = auth.uid()
    )
  );

-- Policy for inserting health history (automatic via triggers or app logic)
CREATE POLICY "Allow users to insert health history for their own pets"
  ON pet.pet_health_history
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM pet.pets 
      WHERE pets.id = pet_health_history.pet_id 
      AND pets.owner_id = auth.uid()
    )
  );

-- ============================================================================
-- 7. CREATE HELPER FUNCTION FOR HEALTH SCORE CALCULATION
-- ============================================================================

CREATE OR REPLACE FUNCTION pet.calculate_health_score(
  p_health_parameters jsonb,
  p_pet_category_id uuid
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  v_parameter record;
  v_value jsonb;
  v_has_issue boolean := false;
BEGIN
  -- Loop through all parameters that affect health score for this category
  FOR v_parameter IN 
    SELECT parameter_key, parameter_type
    FROM pet.health_parameter_definitions
    WHERE pet_category_id = p_pet_category_id
      AND affects_health_score = true
      AND deleted_at IS NULL
  LOOP
    v_value := p_health_parameters -> v_parameter.parameter_key;
    
    -- Check for issues based on parameter type
    IF v_value IS NOT NULL THEN
      CASE v_parameter.parameter_type
        WHEN 'boolean' THEN
          -- For boolean health checks:
          -- is_vaccinated, is_sterilized, calcium_phosphorus_balanced, diet_appropriate should be true
          -- has_fungus, has_worms, has_fleas, has_mites should be false
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
          -- For select parameters like stool_quality or membrane_health
          -- 'bad' or 'needs_check' = issue
          IF (v_value)::text IN ('"bad"', '"needs_check"') THEN
            v_has_issue := true;
            EXIT;
          END IF;
      END CASE;
    END IF;
  END LOOP;
  
  -- Return score
  IF v_has_issue THEN
    RETURN 'needs_attention';
  ELSE
    RETURN 'healthy';
  END IF;
END;
$$;

COMMENT ON FUNCTION pet.calculate_health_score IS 'Calculates health score based on health parameters and category-specific rules';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- To verify the migration:
-- SELECT * FROM pet.health_parameter_definitions ORDER BY pet_category_id, display_order;
-- SELECT * FROM pet.pet_health_history LIMIT 10;
-- SELECT id, pet_id, health_parameters, health_score FROM pet.pet_healths LIMIT 10;

