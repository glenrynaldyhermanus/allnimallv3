-- Migration: Add QR ID column to pets table for transferable QR collar system
-- This allows QR codes to be stored directly in pets table like microchip_id

-- Add qr_id column to pets table
ALTER TABLE pet.pets ADD COLUMN IF NOT EXISTS qr_id VARCHAR(6) UNIQUE;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_pets_qr_id ON pet.pets(qr_id);

-- Function untuk generate unique 6-char alphanumeric QR ID
CREATE OR REPLACE FUNCTION pet.generate_qr_id()
RETURNS VARCHAR(6) AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';  -- Exclude similar looking: I,O,0,1
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
    
    -- Check if QR ID already exists in pets table
    IF NOT EXISTS (SELECT 1 FROM pet.pets WHERE qr_id = result) THEN
      RETURN result;
    END IF;
    
    attempts := attempts + 1;
    IF attempts >= max_attempts THEN
      RAISE EXCEPTION 'Unable to generate unique QR ID after % attempts', max_attempts;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Add qr_id column to pet_scan_logs table
ALTER TABLE pet.pet_scan_logs ADD COLUMN IF NOT EXISTS qr_id VARCHAR(6);
CREATE INDEX IF NOT EXISTS idx_pet_scan_logs_qr_id ON pet.pet_scan_logs(qr_id);
