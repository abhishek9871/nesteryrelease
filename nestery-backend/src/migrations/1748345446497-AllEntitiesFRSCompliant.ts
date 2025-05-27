import { MigrationInterface, QueryRunner } from 'typeorm';

export class AllEntitiesFRSCompliant1748345446497 implements MigrationInterface {
  name = 'AllEntitiesFRSCompliant1748345446497';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "properties" DROP CONSTRAINT "FK_97ae9ee8402b8d8d167fa7352ce"`,
    );
    await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "FK_d3998945517e0cac384f573b3cb"`);
    await queryRunner.query(
      `ALTER TABLE "bookings" DROP CONSTRAINT "FK_38a69a58a323647f2e75eb994de"`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" DROP CONSTRAINT "FK_cf064476d403971270369232d80"`,
    );
    await queryRunner.query(
      `CREATE TABLE "property_availability" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "property_id" uuid NOT NULL, "date" date NOT NULL, "is_available" boolean NOT NULL DEFAULT true, "price" numeric(10,2) NOT NULL, "currency" character varying(3) NOT NULL, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_77c4273139b3d4987b6353503d5" UNIQUE ("property_id", "date"), CONSTRAINT "PK_cb34e181b77cc6add128c0b40c1" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."nestery_master_properties_property_type_enum" AS ENUM('hotel', 'apartment', 'resort', 'villa', 'hostel', 'guesthouse')`,
    );
    await queryRunner.query(
      `CREATE TABLE "nestery_master_properties" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying(255) NOT NULL, "description" text NOT NULL, "address" character varying(255) NOT NULL, "city" character varying(100) NOT NULL, "state" character varying(100), "country" character varying(100) NOT NULL, "zip_code" character varying(20), "latitude" numeric(10,7) NOT NULL, "longitude" numeric(10,7) NOT NULL, "property_type" "public"."nestery_master_properties_property_type_enum" NOT NULL, "star_rating" numeric(2,1), "max_guests" integer NOT NULL, "bedrooms" integer, "bathrooms" integer, "amenities" text array, "images" text array, "thumbnail_image" character varying(255), "chain_affiliation" character varying(100), "phone_number" character varying(20), "nestery_rating" numeric(3,2), "review_count" integer NOT NULL DEFAULT '0', "metadata" jsonb, "is_active" boolean NOT NULL DEFAULT true, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_54fd52ef5a491ff86a39bfacd18" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."suppliers_type_enum" AS ENUM('booking', 'oyo', 'goibibo', 'makemytrip', 'agoda', 'expedia', 'other')`,
    );
    await queryRunner.query(
      `CREATE TABLE "suppliers" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying(100) NOT NULL, "type" "public"."suppliers_type_enum" NOT NULL, "api_endpoint" character varying(255), "api_key" character varying(255), "commission_rate" numeric(5,4), "is_active" boolean NOT NULL DEFAULT true, "configuration" jsonb, "contact_email" character varying(255), "contact_phone" character varying(20), "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_b70ac51766a9e3144f778cfe81e" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "supplier_properties" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "supplier_id" uuid NOT NULL, "nestery_master_property_id" uuid NOT NULL, "supplier_native_property_id" character varying(255) NOT NULL, "supplier_property_name" character varying(255) NOT NULL, "supplier_property_url" character varying(255), "base_price" numeric(10,2), "currency" character varying(3) NOT NULL DEFAULT 'USD', "last_sync_at" TIMESTAMP, "is_active" boolean NOT NULL DEFAULT true, "metadata" jsonb, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_2161ca995998c47ceffc44a4470" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."premium_subscriptions_plan_enum" AS ENUM('monthly', 'yearly')`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."premium_subscriptions_status_enum" AS ENUM('active', 'cancelled', 'expired', 'pending')`,
    );
    await queryRunner.query(
      `CREATE TABLE "premium_subscriptions" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "plan" "public"."premium_subscriptions_plan_enum" NOT NULL, "status" "public"."premium_subscriptions_status_enum" NOT NULL, "start_date" date NOT NULL, "end_date" date NOT NULL, "price_paid" numeric(10,2) NOT NULL, "currency" character varying(3) NOT NULL DEFAULT 'USD', "payment_method" character varying(50) NOT NULL, "stripe_subscription_id" character varying(255), "auto_renew" boolean NOT NULL DEFAULT true, "cancelled_at" TIMESTAMP, "cancellation_reason" character varying(255), "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_1f76924ce8dee722edd344d9d1b" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."referrals_status_enum" AS ENUM('pending', 'completed', 'expired')`,
    );
    await queryRunner.query(
      `CREATE TABLE "referrals" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "referrer_id" uuid NOT NULL, "referred_id" uuid, "referral_code" character varying(50) NOT NULL, "status" "public"."referrals_status_enum" NOT NULL DEFAULT 'pending', "points_awarded" integer, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "completed_at" TIMESTAMP, CONSTRAINT "UQ_c72beecc73a7cc4beb9dd9c1834" UNIQUE ("referral_code"), CONSTRAINT "PK_ea9980e34f738b6252817326c08" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "user_recommendations" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "property_id" uuid NOT NULL, "score" numeric(5,4) NOT NULL, "reason" character varying(100), "is_viewed" boolean NOT NULL DEFAULT false, "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_5f708e9f274bb15b9d271a7ea6b" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."social_shares_platform_enum" AS ENUM('facebook', 'twitter', 'whatsapp', 'email')`,
    );
    await queryRunner.query(
      `CREATE TABLE "social_shares" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "property_id" uuid NOT NULL, "platform" "public"."social_shares_platform_enum" NOT NULL, "share_link" character varying(255) NOT NULL, "points_earned" integer NOT NULL DEFAULT '0', "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_9c1f241ef146fd3ea7249a88ab3" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."price_predictions_trend_enum" AS ENUM('rising', 'falling', 'stable')`,
    );
    await queryRunner.query(
      `CREATE TABLE "price_predictions" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "property_id" uuid NOT NULL, "date" date NOT NULL, "predicted_price" numeric(10,2) NOT NULL, "confidence" numeric(5,4) NOT NULL, "trend" "public"."price_predictions_trend_enum" NOT NULL, "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_2d00ef64145c090de6ae1f9af6d" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."loyalty_transactions_type_enum" AS ENUM('earned', 'redeemed', 'expired', 'adjusted')`,
    );
    await queryRunner.query(
      `CREATE TABLE "loyalty_transactions" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "booking_id" uuid, "type" "public"."loyalty_transactions_type_enum" NOT NULL, "amount" integer NOT NULL, "description" character varying(255) NOT NULL, "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_df453f678b7575221b335673362" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "loyalty_rewards" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "name" character varying(100) NOT NULL, "description" text NOT NULL, "points_cost" integer NOT NULL, "is_active" boolean NOT NULL DEFAULT true, "valid_until" date, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_a0a01f0a250a96d6249e0af9ce3" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."itineraries_status_enum" AS ENUM('draft', 'published', 'shared', 'archived')`,
    );
    await queryRunner.query(
      `CREATE TABLE "itineraries" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "title" character varying(255) NOT NULL, "description" text, "destination" character varying(100) NOT NULL, "start_date" date NOT NULL, "end_date" date NOT NULL, "number_of_travelers" integer NOT NULL, "budget_min" numeric(10,2), "budget_max" numeric(10,2), "currency" character varying(3) NOT NULL DEFAULT 'USD', "interests" text array, "status" "public"."itineraries_status_enum" NOT NULL DEFAULT 'draft', "is_ai_generated" boolean NOT NULL DEFAULT false, "share_token" character varying(255), "metadata" jsonb, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "UQ_ca5c975df1bef0c8d829d9bb546" UNIQUE ("share_token"), CONSTRAINT "PK_9c5db87d0f85f56e4466ae09a38" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TABLE "reviews" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "property_id" uuid NOT NULL, "booking_id" uuid, "rating" integer NOT NULL, "comment" text, "is_verified" boolean NOT NULL DEFAULT false, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_231ae565c273ee700b283f15c1d" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."loyalty_points_ledger_type_enum" AS ENUM('earned', 'redeemed', 'expired', 'adjusted', 'bonus', 'referral')`,
    );
    await queryRunner.query(
      `CREATE TABLE "loyalty_points_ledger" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "type" "public"."loyalty_points_ledger_type_enum" NOT NULL, "amount" integer NOT NULL, "running_balance" integer NOT NULL, "description" character varying(255) NOT NULL, "reference_id" character varying(255), "reference_type" character varying(50), "expiry_date" date, "created_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_6eb2c9167ed8485736fda40a519" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."itinerary_items_type_enum" AS ENUM('accommodation', 'activity', 'transport', 'dining', 'other')`,
    );
    await queryRunner.query(
      `CREATE TABLE "itinerary_items" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "itinerary_id" uuid NOT NULL, "type" "public"."itinerary_items_type_enum" NOT NULL, "title" character varying(255) NOT NULL, "description" text, "day_number" integer NOT NULL, "start_time" TIME, "end_time" TIME, "estimated_cost" numeric(10,2), "currency" character varying(3) NOT NULL DEFAULT 'USD', "location" character varying(255), "latitude" numeric(10,7), "longitude" numeric(10,7), "property_id" uuid, "external_url" character varying(255), "booking_reference" character varying(100), "sort_order" integer NOT NULL DEFAULT '0', "metadata" jsonb, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "updated_at" TIMESTAMP NOT NULL DEFAULT now(), CONSTRAINT "PK_f37a39ff959ce329ccbb0d98e24" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."loyalty_redemptions_status_enum" AS ENUM('active', 'used', 'expired')`,
    );
    await queryRunner.query(
      `CREATE TABLE "loyalty_redemptions" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "user_id" uuid NOT NULL, "reward_id" uuid NOT NULL, "points_used" integer NOT NULL, "redemption_code" character varying(50) NOT NULL, "status" "public"."loyalty_redemptions_status_enum" NOT NULL DEFAULT 'active', "expiry_date" date, "created_at" TIMESTAMP NOT NULL DEFAULT now(), "used_at" TIMESTAMP, CONSTRAINT "PK_6f31b853f967275feb257789cb5" PRIMARY KEY ("id"))`,
    );
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "zipCode"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "maxGuests"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "isActive"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "createdAt"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "updatedAt"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "type"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "pricePerNight"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "rating"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "reviewCount"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "hostId"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "basePrice"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "name"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "profilePicture"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "phoneNumber"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "isPremium"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "loyaltyPoints"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "lastLoginAt"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "createdAt"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "updatedAt"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "firstName"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "lastName"`);
    await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "UQ_b7f8278f4e89249bb75c9a15899"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "referralCode"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "referredBy"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "hasCompletedBooking"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "userId"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "propertyId"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "confirmationCode"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "cancellationReason"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "isPaid"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "paymentMethod"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "isRefunded"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "loyaltyPointsEarned"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "loyaltyPointsRedeemed"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "isPremiumBooking"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "specialRequests"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "sourceType"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "createdAt"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "updatedAt"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "guest_count"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "isCancelled"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "cancellationDate"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "refundAmount"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "paymentId"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "paymentDate"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "checkInDate"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "checkOutDate"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "totalPrice"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "zip_code" character varying(20)`);
    await queryRunner.query(
      `CREATE TYPE "public"."properties_property_type_enum" AS ENUM('hotel', 'apartment', 'resort', 'villa', 'hostel', 'guesthouse')`,
    );
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "property_type" "public"."properties_property_type_enum" NOT NULL`,
    );
    await queryRunner.query(`ALTER TABLE "properties" ADD "star_rating" numeric(2,1)`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "base_price" numeric(10,2) NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "max_guests" integer NOT NULL`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "thumbnail_image" character varying(255)`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."properties_source_type_enum" AS ENUM('internal', 'booking', 'oyo')`,
    );
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "source_type" "public"."properties_source_type_enum" NOT NULL DEFAULT 'internal'`,
    );
    await queryRunner.query(`ALTER TABLE "properties" ADD "external_id" character varying(100)`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "external_url" character varying(255)`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "metadata" jsonb`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "is_active" boolean NOT NULL DEFAULT true`,
    );
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "created_at" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "updated_at" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(`ALTER TABLE "users" ADD "first_name" character varying(100) NOT NULL`);
    await queryRunner.query(`ALTER TABLE "users" ADD "last_name" character varying(100) NOT NULL`);
    await queryRunner.query(`ALTER TABLE "users" ADD "phone_number" character varying(20)`);
    await queryRunner.query(`ALTER TABLE "users" ADD "profile_picture" character varying(255)`);
    await queryRunner.query(`ALTER TABLE "users" ADD "preferences" jsonb`);
    await queryRunner.query(`ALTER TABLE "users" ADD "refresh_token" character varying(255)`);
    await queryRunner.query(
      `CREATE TYPE "public"."users_loyalty_tier_enum" AS ENUM('bronze', 'silver', 'gold', 'platinum')`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD "loyalty_tier" "public"."users_loyalty_tier_enum" NOT NULL DEFAULT 'bronze'`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD "loyalty_points" integer NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(`ALTER TABLE "users" ADD "auth_provider" character varying(50)`);
    await queryRunner.query(`ALTER TABLE "users" ADD "auth_provider_id" character varying(255)`);
    await queryRunner.query(`ALTER TABLE "users" ADD "stripe_customer_id" character varying(255)`);
    await queryRunner.query(
      `ALTER TABLE "users" ADD "email_verified" boolean NOT NULL DEFAULT false`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD "phone_verified" boolean NOT NULL DEFAULT false`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD "created_at" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD "updated_at" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ADD "user_id" uuid NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "property_id" uuid NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "check_in_date" date NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "check_out_date" date NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "total_price" numeric(10,2) NOT NULL`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "confirmation_code" character varying(50) NOT NULL`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ADD "special_requests" text`);
    await queryRunner.query(
      `CREATE TYPE "public"."bookings_payment_method_enum" AS ENUM('credit_card', 'paypal', 'points')`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "payment_method" "public"."bookings_payment_method_enum" NOT NULL`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ADD "payment_details" jsonb`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "loyalty_points_earned" integer NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."bookings_source_type_enum" AS ENUM('internal', 'booking', 'oyo')`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "source_type" "public"."bookings_source_type_enum" NOT NULL DEFAULT 'internal'`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "external_booking_id" character varying(100)`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ADD "supplier_id" character varying`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "supplier_booking_reference" character varying(100)`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "created_at" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "updated_at" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "name"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "name" character varying(255) NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "description"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "description" text NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "address"`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "address" character varying(255) NOT NULL`,
    );
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "city"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "city" character varying(100) NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "state"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "state" character varying(100)`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "country"`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "country" character varying(100) NOT NULL`,
    );
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "latitude"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "latitude" numeric(10,7) NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "longitude"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "longitude" numeric(10,7) NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "currency"`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "currency" character varying(3) NOT NULL DEFAULT 'USD'`,
    );
    await queryRunner.query(`ALTER TABLE "properties" ALTER COLUMN "bedrooms" DROP NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" ALTER COLUMN "bathrooms" DROP NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "amenities"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "amenities" text array`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "images"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "images" text array`);
    await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "UQ_users_email"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "email"`);
    await queryRunner.query(`ALTER TABLE "users" ADD "email" character varying(255) NOT NULL`);
    await queryRunner.query(
      `ALTER TABLE "users" ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE ("email")`,
    );
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "password"`);
    await queryRunner.query(`ALTER TABLE "users" ADD "password" character varying(255) NOT NULL`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "role"`);
    await queryRunner.query(`CREATE TYPE "public"."users_role_enum" AS ENUM('user', 'admin')`);
    await queryRunner.query(
      `ALTER TABLE "users" ADD "role" "public"."users_role_enum" NOT NULL DEFAULT 'user'`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ALTER COLUMN "number_of_guests" SET NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "currency"`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "currency" character varying(3) NOT NULL DEFAULT 'USD'`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "status"`);
    await queryRunner.query(
      `CREATE TYPE "public"."bookings_status_enum" AS ENUM('confirmed', 'completed', 'cancelled')`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "status" "public"."bookings_status_enum" NOT NULL DEFAULT 'confirmed'`,
    );
    await queryRunner.query(
      `ALTER TABLE "property_availability" ADD CONSTRAINT "FK_99aeda8d8fbf9d6efb929db36d2" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "supplier_properties" ADD CONSTRAINT "FK_32fff33d5dbbfeaee2838968b2a" FOREIGN KEY ("supplier_id") REFERENCES "suppliers"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "supplier_properties" ADD CONSTRAINT "FK_35aa79fcea09998c4840fd73736" FOREIGN KEY ("nestery_master_property_id") REFERENCES "nestery_master_properties"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD CONSTRAINT "FK_64cd97487c5c42806458ab5520c" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD CONSTRAINT "FK_afa260d0e51f81520a480817702" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "premium_subscriptions" ADD CONSTRAINT "FK_44be65c9f19bbb36772b6657520" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "referrals" ADD CONSTRAINT "FK_18af9fcaffac6d6d3b28130e149" FOREIGN KEY ("referrer_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "referrals" ADD CONSTRAINT "FK_507a2818bf5524662b068c2e81c" FOREIGN KEY ("referred_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_recommendations" ADD CONSTRAINT "FK_b65c00f26f1cceff8a096abdf6f" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_recommendations" ADD CONSTRAINT "FK_ed73e10cdebf9b6fede57a3277b" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "social_shares" ADD CONSTRAINT "FK_c3ef34eadf6e80f40c330292b20" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "social_shares" ADD CONSTRAINT "FK_802b3b9cd4b26c267f4b4aa80d3" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "price_predictions" ADD CONSTRAINT "FK_261ed3c3edf88dcd32b72080541" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "FK_c4d462b2bc48d9304b31bcab46b" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_transactions" ADD CONSTRAINT "FK_a51f0b10d0baf1f83b89cb8b2bc" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE SET NULL ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "itineraries" ADD CONSTRAINT "FK_2c1f9990ff4b57b054ed85a45e6" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" ADD CONSTRAINT "FK_728447781a30bc3fcfe5c2f1cdf" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" ADD CONSTRAINT "FK_2b1e1cd13649e9315b28b7f2f0c" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" ADD CONSTRAINT "FK_bbd6ac6e3e6a8f8c6e0e8692d63" FOREIGN KEY ("booking_id") REFERENCES "bookings"("id") ON DELETE SET NULL ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_points_ledger" ADD CONSTRAINT "FK_31118d1b0215166324667b678d0" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "itinerary_items" ADD CONSTRAINT "FK_6f8232dfb944b7628c7ae781ce6" FOREIGN KEY ("itinerary_id") REFERENCES "itineraries"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "itinerary_items" ADD CONSTRAINT "FK_fa41ef3d6b21c97cca2c5009b2a" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_redemptions" ADD CONSTRAINT "FK_e223a4449ae69f109776d49a60d" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_redemptions" ADD CONSTRAINT "FK_09d6bed25a55b92b2de4c913f8d" FOREIGN KEY ("reward_id") REFERENCES "loyalty_rewards"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "loyalty_redemptions" DROP CONSTRAINT "FK_09d6bed25a55b92b2de4c913f8d"`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_redemptions" DROP CONSTRAINT "FK_e223a4449ae69f109776d49a60d"`,
    );
    await queryRunner.query(
      `ALTER TABLE "itinerary_items" DROP CONSTRAINT "FK_fa41ef3d6b21c97cca2c5009b2a"`,
    );
    await queryRunner.query(
      `ALTER TABLE "itinerary_items" DROP CONSTRAINT "FK_6f8232dfb944b7628c7ae781ce6"`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_points_ledger" DROP CONSTRAINT "FK_31118d1b0215166324667b678d0"`,
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" DROP CONSTRAINT "FK_bbd6ac6e3e6a8f8c6e0e8692d63"`,
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" DROP CONSTRAINT "FK_2b1e1cd13649e9315b28b7f2f0c"`,
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" DROP CONSTRAINT "FK_728447781a30bc3fcfe5c2f1cdf"`,
    );
    await queryRunner.query(
      `ALTER TABLE "itineraries" DROP CONSTRAINT "FK_2c1f9990ff4b57b054ed85a45e6"`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_transactions" DROP CONSTRAINT "FK_a51f0b10d0baf1f83b89cb8b2bc"`,
    );
    await queryRunner.query(
      `ALTER TABLE "loyalty_transactions" DROP CONSTRAINT "FK_c4d462b2bc48d9304b31bcab46b"`,
    );
    await queryRunner.query(
      `ALTER TABLE "price_predictions" DROP CONSTRAINT "FK_261ed3c3edf88dcd32b72080541"`,
    );
    await queryRunner.query(
      `ALTER TABLE "social_shares" DROP CONSTRAINT "FK_802b3b9cd4b26c267f4b4aa80d3"`,
    );
    await queryRunner.query(
      `ALTER TABLE "social_shares" DROP CONSTRAINT "FK_c3ef34eadf6e80f40c330292b20"`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_recommendations" DROP CONSTRAINT "FK_ed73e10cdebf9b6fede57a3277b"`,
    );
    await queryRunner.query(
      `ALTER TABLE "user_recommendations" DROP CONSTRAINT "FK_b65c00f26f1cceff8a096abdf6f"`,
    );
    await queryRunner.query(
      `ALTER TABLE "referrals" DROP CONSTRAINT "FK_507a2818bf5524662b068c2e81c"`,
    );
    await queryRunner.query(
      `ALTER TABLE "referrals" DROP CONSTRAINT "FK_18af9fcaffac6d6d3b28130e149"`,
    );
    await queryRunner.query(
      `ALTER TABLE "premium_subscriptions" DROP CONSTRAINT "FK_44be65c9f19bbb36772b6657520"`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" DROP CONSTRAINT "FK_afa260d0e51f81520a480817702"`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" DROP CONSTRAINT "FK_64cd97487c5c42806458ab5520c"`,
    );
    await queryRunner.query(
      `ALTER TABLE "supplier_properties" DROP CONSTRAINT "FK_35aa79fcea09998c4840fd73736"`,
    );
    await queryRunner.query(
      `ALTER TABLE "supplier_properties" DROP CONSTRAINT "FK_32fff33d5dbbfeaee2838968b2a"`,
    );
    await queryRunner.query(
      `ALTER TABLE "property_availability" DROP CONSTRAINT "FK_99aeda8d8fbf9d6efb929db36d2"`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "status"`);
    await queryRunner.query(`DROP TYPE "public"."bookings_status_enum"`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "status" character varying NOT NULL DEFAULT 'pending'`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "currency"`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "currency" character varying NOT NULL DEFAULT 'USD'`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ALTER COLUMN "number_of_guests" DROP NOT NULL`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "role"`);
    await queryRunner.query(`DROP TYPE "public"."users_role_enum"`);
    await queryRunner.query(
      `ALTER TABLE "users" ADD "role" character varying NOT NULL DEFAULT 'user'`,
    );
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "password"`);
    await queryRunner.query(`ALTER TABLE "users" ADD "password" character varying NOT NULL`);
    await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "email"`);
    await queryRunner.query(`ALTER TABLE "users" ADD "email" character varying NOT NULL`);
    await queryRunner.query(`ALTER TABLE "users" ADD CONSTRAINT "UQ_users_email" UNIQUE ("email")`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "images"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "images" text`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "amenities"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "amenities" text`);
    await queryRunner.query(`ALTER TABLE "properties" ALTER COLUMN "bathrooms" SET NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" ALTER COLUMN "bedrooms" SET NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "currency"`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "currency" character varying NOT NULL DEFAULT 'USD'`,
    );
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "longitude"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "longitude" double precision NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "latitude"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "latitude" double precision NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "country"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "country" character varying NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "state"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "state" character varying NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "city"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "city" character varying NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "address"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "address" character varying NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "description"`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "description" character varying NOT NULL`,
    );
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "name"`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "name" character varying NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "updated_at"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "created_at"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "supplier_booking_reference"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "supplier_id"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "external_booking_id"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "source_type"`);
    await queryRunner.query(`DROP TYPE "public"."bookings_source_type_enum"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "loyalty_points_earned"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "payment_details"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "payment_method"`);
    await queryRunner.query(`DROP TYPE "public"."bookings_payment_method_enum"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "special_requests"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "confirmation_code"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "total_price"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "check_out_date"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "check_in_date"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "property_id"`);
    await queryRunner.query(`ALTER TABLE "bookings" DROP COLUMN "user_id"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "updated_at"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "created_at"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "phone_verified"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "email_verified"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "stripe_customer_id"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "auth_provider_id"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "auth_provider"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "loyalty_points"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "loyalty_tier"`);
    await queryRunner.query(`DROP TYPE "public"."users_loyalty_tier_enum"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "refresh_token"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "preferences"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "profile_picture"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "phone_number"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "last_name"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "first_name"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "updated_at"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "created_at"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "is_active"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "metadata"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "external_url"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "external_id"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "source_type"`);
    await queryRunner.query(`DROP TYPE "public"."properties_source_type_enum"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "thumbnail_image"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "max_guests"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "base_price"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "star_rating"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "property_type"`);
    await queryRunner.query(`DROP TYPE "public"."properties_property_type_enum"`);
    await queryRunner.query(`ALTER TABLE "properties" DROP COLUMN "zip_code"`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "totalPrice" double precision NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "checkOutDate" TIMESTAMP NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "checkInDate" TIMESTAMP NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "paymentDate" TIMESTAMP`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "paymentId" character varying`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "refundAmount" double precision`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "cancellationDate" TIMESTAMP`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "isCancelled" boolean NOT NULL DEFAULT false`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ADD "guest_count" integer NOT NULL`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "updatedAt" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "createdAt" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "sourceType" character varying NOT NULL DEFAULT 'direct'`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ADD "specialRequests" character varying`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "isPremiumBooking" boolean NOT NULL DEFAULT false`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "loyaltyPointsRedeemed" integer NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "loyaltyPointsEarned" integer NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD "isRefunded" boolean NOT NULL DEFAULT false`,
    );
    await queryRunner.query(`ALTER TABLE "bookings" ADD "paymentMethod" character varying`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "isPaid" boolean NOT NULL DEFAULT false`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "cancellationReason" character varying`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "confirmationCode" character varying`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "propertyId" uuid NOT NULL`);
    await queryRunner.query(`ALTER TABLE "bookings" ADD "userId" uuid NOT NULL`);
    await queryRunner.query(
      `ALTER TABLE "users" ADD "hasCompletedBooking" boolean NOT NULL DEFAULT false`,
    );
    await queryRunner.query(`ALTER TABLE "users" ADD "referredBy" uuid`);
    await queryRunner.query(`ALTER TABLE "users" ADD "referralCode" character varying`);
    await queryRunner.query(
      `ALTER TABLE "users" ADD CONSTRAINT "UQ_b7f8278f4e89249bb75c9a15899" UNIQUE ("referralCode")`,
    );
    await queryRunner.query(`ALTER TABLE "users" ADD "lastName" character varying`);
    await queryRunner.query(`ALTER TABLE "users" ADD "firstName" character varying`);
    await queryRunner.query(`ALTER TABLE "users" ADD "updatedAt" TIMESTAMP NOT NULL DEFAULT now()`);
    await queryRunner.query(`ALTER TABLE "users" ADD "createdAt" TIMESTAMP NOT NULL DEFAULT now()`);
    await queryRunner.query(`ALTER TABLE "users" ADD "lastLoginAt" TIMESTAMP`);
    await queryRunner.query(`ALTER TABLE "users" ADD "loyaltyPoints" integer NOT NULL DEFAULT '0'`);
    await queryRunner.query(`ALTER TABLE "users" ADD "isPremium" boolean NOT NULL DEFAULT false`);
    await queryRunner.query(`ALTER TABLE "users" ADD "phoneNumber" character varying`);
    await queryRunner.query(`ALTER TABLE "users" ADD "profilePicture" character varying`);
    await queryRunner.query(`ALTER TABLE "users" ADD "name" character varying NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "basePrice" double precision NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "hostId" uuid`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "reviewCount" integer NOT NULL DEFAULT '0'`,
    );
    await queryRunner.query(`ALTER TABLE "properties" ADD "rating" double precision`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "pricePerNight" double precision NOT NULL`,
    );
    await queryRunner.query(`ALTER TABLE "properties" ADD "type" character varying NOT NULL`);
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "updatedAt" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "createdAt" TIMESTAMP NOT NULL DEFAULT now()`,
    );
    await queryRunner.query(
      `ALTER TABLE "properties" ADD "isActive" boolean NOT NULL DEFAULT true`,
    );
    await queryRunner.query(`ALTER TABLE "properties" ADD "maxGuests" integer NOT NULL`);
    await queryRunner.query(`ALTER TABLE "properties" ADD "zipCode" character varying NOT NULL`);
    await queryRunner.query(`DROP TABLE "loyalty_redemptions"`);
    await queryRunner.query(`DROP TYPE "public"."loyalty_redemptions_status_enum"`);
    await queryRunner.query(`DROP TABLE "itinerary_items"`);
    await queryRunner.query(`DROP TYPE "public"."itinerary_items_type_enum"`);
    await queryRunner.query(`DROP TABLE "loyalty_points_ledger"`);
    await queryRunner.query(`DROP TYPE "public"."loyalty_points_ledger_type_enum"`);
    await queryRunner.query(`DROP TABLE "reviews"`);
    await queryRunner.query(`DROP TABLE "itineraries"`);
    await queryRunner.query(`DROP TYPE "public"."itineraries_status_enum"`);
    await queryRunner.query(`DROP TABLE "loyalty_rewards"`);
    await queryRunner.query(`DROP TABLE "loyalty_transactions"`);
    await queryRunner.query(`DROP TYPE "public"."loyalty_transactions_type_enum"`);
    await queryRunner.query(`DROP TABLE "price_predictions"`);
    await queryRunner.query(`DROP TYPE "public"."price_predictions_trend_enum"`);
    await queryRunner.query(`DROP TABLE "social_shares"`);
    await queryRunner.query(`DROP TYPE "public"."social_shares_platform_enum"`);
    await queryRunner.query(`DROP TABLE "user_recommendations"`);
    await queryRunner.query(`DROP TABLE "referrals"`);
    await queryRunner.query(`DROP TYPE "public"."referrals_status_enum"`);
    await queryRunner.query(`DROP TABLE "premium_subscriptions"`);
    await queryRunner.query(`DROP TYPE "public"."premium_subscriptions_status_enum"`);
    await queryRunner.query(`DROP TYPE "public"."premium_subscriptions_plan_enum"`);
    await queryRunner.query(`DROP TABLE "supplier_properties"`);
    await queryRunner.query(`DROP TABLE "suppliers"`);
    await queryRunner.query(`DROP TYPE "public"."suppliers_type_enum"`);
    await queryRunner.query(`DROP TABLE "nestery_master_properties"`);
    await queryRunner.query(`DROP TYPE "public"."nestery_master_properties_property_type_enum"`);
    await queryRunner.query(`DROP TABLE "property_availability"`);
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD CONSTRAINT "FK_cf064476d403971270369232d80" FOREIGN KEY ("propertyId") REFERENCES "properties"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "bookings" ADD CONSTRAINT "FK_38a69a58a323647f2e75eb994de" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD CONSTRAINT "FK_d3998945517e0cac384f573b3cb" FOREIGN KEY ("referredBy") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
    await queryRunner.query(
      `ALTER TABLE "properties" ADD CONSTRAINT "FK_97ae9ee8402b8d8d167fa7352ce" FOREIGN KEY ("hostId") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`,
    );
  }
}
