#!/bin/bash
# Batch reorganize schema.sql tables to correct schemas

cd "$(dirname "$0")"

echo "🔄 Reorganizing schema.sql..."

# Backup
cp schema.sql schema_backup_before_reorg_$(date +%Y%m%d_%H%M%S).sql

# PET SCHEMA TABLES (12)
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pet_categories/CREATE TABLE IF NOT EXISTS pet.pet_categories/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.characters /CREATE TABLE IF NOT EXISTS pet.characters /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pets /CREATE TABLE IF NOT EXISTS pet.pets /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pet_characters/CREATE TABLE IF NOT EXISTS pet.pet_characters/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pet_healths/CREATE TABLE IF NOT EXISTS pet.pet_healths/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pet_medical_records/CREATE TABLE IF NOT EXISTS pet.pet_medical_records/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pet_breeding_pairs/CREATE TABLE IF NOT EXISTS pet.pet_breeding_pairs/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pet_weight_history/CREATE TABLE IF NOT EXISTS pet.pet_weight_history/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pet_care_reminders/CREATE TABLE IF NOT EXISTS pet.pet_care_reminders/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.schedule_types/CREATE TABLE IF NOT EXISTS pet.schedule_types/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.schedule_recurring_patterns/CREATE TABLE IF NOT EXISTS pet.schedule_recurring_patterns/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pet_schedules/CREATE TABLE IF NOT EXISTS pet.pet_schedules/g' schema.sql

# SOCIAL SCHEMA TABLES (23)
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.forum_categories/CREATE TABLE IF NOT EXISTS social.forum_categories/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.forum_posts/CREATE TABLE IF NOT EXISTS social.forum_posts/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.forum_replies/CREATE TABLE IF NOT EXISTS social.forum_replies/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.forum_post_likes/CREATE TABLE IF NOT EXISTS social.forum_post_likes/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.community_events/CREATE TABLE IF NOT EXISTS social.community_events/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.event_participants/CREATE TABLE IF NOT EXISTS social.event_participants/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.course_categories/CREATE TABLE IF NOT EXISTS social.course_categories/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.courses /CREATE TABLE IF NOT EXISTS social.courses /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.course_enrollments/CREATE TABLE IF NOT EXISTS social.course_enrollments/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.kb_categories/CREATE TABLE IF NOT EXISTS social.kb_categories/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.kb_articles/CREATE TABLE IF NOT EXISTS social.kb_articles/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.faqs /CREATE TABLE IF NOT EXISTS social.faqs /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.content_reports/CREATE TABLE IF NOT EXISTS social.content_reports/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.user_warnings/CREATE TABLE IF NOT EXISTS social.user_warnings/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.user_preferences/CREATE TABLE IF NOT EXISTS social.user_preferences/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.push_notifications/CREATE TABLE IF NOT EXISTS social.push_notifications/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.user_levels/CREATE TABLE IF NOT EXISTS social.user_levels/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.user_achievements /CREATE TABLE IF NOT EXISTS social.user_achievements /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.user_achievement_unlocks/CREATE TABLE IF NOT EXISTS social.user_achievement_unlocks/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.xp_transactions/CREATE TABLE IF NOT EXISTS social.xp_transactions/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.product_reviews/CREATE TABLE IF NOT EXISTS social.product_reviews/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.product_favorites/CREATE TABLE IF NOT EXISTS social.product_favorites/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.marketplace_transactions/CREATE TABLE IF NOT EXISTS social.marketplace_transactions/g' schema.sql

# POS SCHEMA TABLES (Remaining ~38 tables)
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.merchants /CREATE TABLE IF NOT EXISTS pos.merchants /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.stores /CREATE TABLE IF NOT EXISTS pos.stores /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.store_business_hours/CREATE TABLE IF NOT EXISTS pos.store_business_hours/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.store_carts/CREATE TABLE IF NOT EXISTS pos.store_carts/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.store_cart_items/CREATE TABLE IF NOT EXISTS pos.store_cart_items/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.store_payment_methods/CREATE TABLE IF NOT EXISTS pos.store_payment_methods/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.products_categories/CREATE TABLE IF NOT EXISTS pos.products_categories/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.products /CREATE TABLE IF NOT EXISTS pos.products /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.product_images/CREATE TABLE IF NOT EXISTS pos.product_images/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.inventory_transactions/CREATE TABLE IF NOT EXISTS pos.inventory_transactions/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.sales /CREATE TABLE IF NOT EXISTS pos.sales /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.sales_items/CREATE TABLE IF NOT EXISTS pos.sales_items/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.merchant_customers/CREATE TABLE IF NOT EXISTS pos.merchant_customers/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.merchant_partnerships/CREATE TABLE IF NOT EXISTS pos.merchant_partnerships/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.merchant_service_availability/CREATE TABLE IF NOT EXISTS pos.merchant_service_availability/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.service_bookings/CREATE TABLE IF NOT EXISTS pos.service_bookings/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.subscription_plans/CREATE TABLE IF NOT EXISTS pos.subscription_plans/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.user_subscriptions/CREATE TABLE IF NOT EXISTS pos.user_subscriptions/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.plan_change_requests/CREATE TABLE IF NOT EXISTS pos.plan_change_requests/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.subscription_usage_analytics/CREATE TABLE IF NOT EXISTS pos.subscription_usage_analytics/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.subscription_notifications/CREATE TABLE IF NOT EXISTS pos.subscription_notifications/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.pricing_faq/CREATE TABLE IF NOT EXISTS pos.pricing_faq/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.feature_flags/CREATE TABLE IF NOT EXISTS pos.feature_flags/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.feature_usage/CREATE TABLE IF NOT EXISTS pos.feature_usage/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.referral_agents/CREATE TABLE IF NOT EXISTS pos.referral_agents/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.referral_commissions/CREATE TABLE IF NOT EXISTS pos.referral_commissions/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.referral_payments/CREATE TABLE IF NOT EXISTS pos.referral_payments/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.referral_settings/CREATE TABLE IF NOT EXISTS pos.referral_settings/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.employee_documents/CREATE TABLE IF NOT EXISTS pos.employee_documents/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.leave_types/CREATE TABLE IF NOT EXISTS pos.leave_types/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.leave_requests/CREATE TABLE IF NOT EXISTS pos.leave_requests/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.leave_balances/CREATE TABLE IF NOT EXISTS pos.leave_balances/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.payroll_records/CREATE TABLE IF NOT EXISTS pos.payroll_records/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.commission_records/CREATE TABLE IF NOT EXISTS pos.commission_records/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.countries /CREATE TABLE IF NOT EXISTS pos.countries /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.provinces /CREATE TABLE IF NOT EXISTS pos.provinces /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.cities /CREATE TABLE IF NOT EXISTS pos.cities /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.payment_types/CREATE TABLE IF NOT EXISTS pos.payment_types/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.payment_methods/CREATE TABLE IF NOT EXISTS pos.payment_methods/g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.roles /CREATE TABLE IF NOT EXISTS pos.roles /g' schema.sql
sed -i '' 's/CREATE TABLE IF NOT EXISTS public\.role_assignments/CREATE TABLE IF NOT EXISTS pos.role_assignments/g' schema.sql

echo "✅ All POS tables updated"

