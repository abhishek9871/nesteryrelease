import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateAffiliateSchema1717171717171 implements MigrationInterface {
  name = 'CreateAffiliateSchema1717171717171';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create Enums
    await queryRunner.query(
      `CREATE TYPE "public"."affiliate_partner_category_enum" AS ENUM('TOUR_OPERATOR', 'ACTIVITY_PROVIDER', 'RESTAURANT', 'TRANSPORTATION', 'ECOMMERCE')`,
    );
    await queryRunner.query(
      `CREATE TYPE "public"."affiliate_earning_status_enum" AS ENUM('PENDING', 'CONFIRMED', 'PAID', 'CANCELLED')`,
    );

    // Create affiliate_partners table
    await queryRunner.query(`
      CREATE TABLE "affiliate_partners" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "name" character varying(255) NOT NULL,
        "category" "public"."affiliate_partner_category_enum" NOT NULL,
        "contactInfo" jsonb NOT NULL,
        "commissionRateOverride" numeric(5,4),
        "isActive" boolean NOT NULL DEFAULT true,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "PK_affiliate_partners_id" PRIMARY KEY ("id")
      )
    `);

    // Create affiliate_offers table
    await queryRunner.query(`
      CREATE TABLE "affiliate_offers" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "partnerId" uuid NOT NULL,
        "title" character varying(255) NOT NULL,
        "description" text NOT NULL,
        "commissionStructure" jsonb NOT NULL,
        "validFrom" TIMESTAMP WITH TIME ZONE NOT NULL,
        "validTo" TIMESTAMP WITH TIME ZONE NOT NULL,
        "termsConditions" text NOT NULL,
        "isActive" boolean NOT NULL DEFAULT true,
        "originalUrl" character varying(2048),
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "PK_affiliate_offers_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_affiliate_offers_partnerId" FOREIGN KEY ("partnerId") REFERENCES "affiliate_partners"("id") ON DELETE CASCADE
      )
    `);

    // Create affiliate_links table
    await queryRunner.query(`
      CREATE TABLE "affiliate_links" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "offerId" uuid NOT NULL,
        "userId" uuid,
        "uniqueCode" character varying(50) NOT NULL,
        "qrCodeDataUrl" text,
        "clicks" integer NOT NULL DEFAULT 0,
        "conversions" integer NOT NULL DEFAULT 0,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "PK_affiliate_links_id" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_affiliate_links_uniqueCode" UNIQUE ("uniqueCode"),
        CONSTRAINT "FK_affiliate_links_offerId" FOREIGN KEY ("offerId") REFERENCES "affiliate_offers"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_affiliate_links_userId" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_affiliate_links_unique_code" ON "affiliate_links" ("uniqueCode")`,
    );

    // Create affiliate_earnings table
    await queryRunner.query(`
      CREATE TABLE "affiliate_earnings" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "partnerId" uuid NOT NULL,
        "offerId" uuid NOT NULL,
        "linkId" uuid,
        "userId" uuid,
        "bookingId" uuid,
        "conversionReferenceId" character varying(255),
        "amountEarned" numeric(12,2) NOT NULL,
        "currency" character varying(3) NOT NULL,
        "transactionDate" TIMESTAMP WITH TIME ZONE NOT NULL,
        "status" "public"."affiliate_earning_status_enum" NOT NULL DEFAULT 'PENDING',
        "notes" text,
        "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "PK_affiliate_earnings_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_affiliate_earnings_partnerId" FOREIGN KEY ("partnerId") REFERENCES "affiliate_partners"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_affiliate_earnings_offerId" FOREIGN KEY ("offerId") REFERENCES "affiliate_offers"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_affiliate_earnings_linkId" FOREIGN KEY ("linkId") REFERENCES "affiliate_links"("id") ON DELETE SET NULL,
        CONSTRAINT "FK_affiliate_earnings_userId" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL,
        CONSTRAINT "FK_affiliate_earnings_bookingId" FOREIGN KEY ("bookingId") REFERENCES "bookings"("id") ON DELETE SET NULL
      )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop tables in reverse order
    await queryRunner.query(`DROP TABLE "affiliate_earnings"`);
    await queryRunner.query(`DROP INDEX "IDX_affiliate_links_unique_code"`);
    await queryRunner.query(`DROP TABLE "affiliate_links"`);
    await queryRunner.query(`DROP TABLE "affiliate_offers"`);
    await queryRunner.query(`DROP TABLE "affiliate_partners"`);

    // Drop enums
    await queryRunner.query(`DROP TYPE "public"."affiliate_earning_status_enum"`);
    await queryRunner.query(`DROP TYPE "public"."affiliate_partner_category_enum"`);
  }
}
