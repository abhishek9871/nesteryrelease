import { MigrationInterface, QueryRunner } from "typeorm";

export class AddAffiliateAuditLogPayoutInvoiceEntities1748863159774 implements MigrationInterface {
    name = 'AddAffiliateAuditLogPayoutInvoiceEntities1748863159774'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_affiliate_earnings_bookingId"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_affiliate_earnings_userId"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_affiliate_earnings_linkId"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_affiliate_earnings_offerId"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_affiliate_earnings_partnerId"`);
        await queryRunner.query(`ALTER TABLE "affiliate_offers" DROP CONSTRAINT "FK_affiliate_offers_partnerId"`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" DROP CONSTRAINT "FK_affiliate_links_userId"`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" DROP CONSTRAINT "FK_affiliate_links_offerId"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_affiliate_links_unique_code"`);
        await queryRunner.query(`CREATE TYPE "public"."affiliate_invoices_status_enum" AS ENUM('DRAFT', 'SENT', 'PAID', 'VOID', 'OVERDUE')`);
        await queryRunner.query(`CREATE TABLE "affiliate_invoices" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "partnerId" uuid NOT NULL, "invoiceNumber" character varying(100) NOT NULL, "issueDate" TIMESTAMP WITH TIME ZONE NOT NULL, "dueDate" TIMESTAMP WITH TIME ZONE NOT NULL, "amountDue" numeric(12,2) NOT NULL, "currency" character varying(3) NOT NULL, "status" "public"."affiliate_invoices_status_enum" NOT NULL DEFAULT 'DRAFT', "lineItems" jsonb NOT NULL, "notes" text, "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), CONSTRAINT "UQ_140260ef4216b276165ecd5c386" UNIQUE ("invoiceNumber"), CONSTRAINT "PK_325ecfc0854f0162c04cee40a65" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_invoices_partnerId" ON "affiliate_invoices" ("partnerId") `);
        await queryRunner.query(`CREATE TYPE "public"."affiliate_payouts_status_enum" AS ENUM('PENDING', 'PROCESSING', 'PAID', 'FAILED', 'CANCELLED')`);
        await queryRunner.query(`CREATE TABLE "affiliate_payouts" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "partnerId" uuid NOT NULL, "amount" numeric(12,2) NOT NULL, "currency" character varying(3) NOT NULL, "status" "public"."affiliate_payouts_status_enum" NOT NULL DEFAULT 'PENDING', "paymentMethod" character varying(100) NOT NULL, "transactionId" character varying(255), "invoiceId" uuid, "payoutDate" TIMESTAMP WITH TIME ZONE, "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), CONSTRAINT "PK_bb16ad268019be269f02c660016" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_payouts_partnerId" ON "affiliate_payouts" ("partnerId") `);
        await queryRunner.query(`CREATE TABLE "affiliate_audit_logs" ("id" uuid NOT NULL DEFAULT uuid_generate_v4(), "timestamp" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(), "userId" uuid, "partnerId" uuid, "entityId" uuid, "entityType" character varying(100), "actionType" character varying(255) NOT NULL, "details" jsonb, "ipAddress" character varying(255), "userAgent" text, CONSTRAINT "PK_5e3b74f29ee66f21e63ddad7013" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_actionType" ON "affiliate_audit_logs" ("actionType") `);
        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_entityId_entityType" ON "affiliate_audit_logs" ("entityId", "entityType") `);
        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_partnerId" ON "affiliate_audit_logs" ("partnerId") `);
        await queryRunner.query(`CREATE INDEX "IDX_audit_logs_userId" ON "affiliate_audit_logs" ("userId") `);
        await queryRunner.query(`ALTER TYPE "public"."affiliate_earning_status_enum" RENAME TO "affiliate_earning_status_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."affiliate_earnings_status_enum" AS ENUM('PENDING', 'CONFIRMED', 'PAID', 'CANCELLED')`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "status" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "status" TYPE "public"."affiliate_earnings_status_enum" USING "status"::"text"::"public"."affiliate_earnings_status_enum"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "status" SET DEFAULT 'PENDING'`);
        await queryRunner.query(`DROP TYPE "public"."affiliate_earning_status_enum_old"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "createdAt" SET DEFAULT now()`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "updatedAt" SET DEFAULT now()`);
        await queryRunner.query(`ALTER TYPE "public"."affiliate_partner_category_enum" RENAME TO "affiliate_partner_category_enum_old"`);
        await queryRunner.query(`CREATE TYPE "public"."affiliate_partners_category_enum" AS ENUM('TOUR_OPERATOR', 'ACTIVITY_PROVIDER', 'RESTAURANT', 'TRANSPORTATION', 'ECOMMERCE')`);
        await queryRunner.query(`ALTER TABLE "affiliate_partners" ALTER COLUMN "category" TYPE "public"."affiliate_partners_category_enum" USING "category"::"text"::"public"."affiliate_partners_category_enum"`);
        await queryRunner.query(`DROP TYPE "public"."affiliate_partner_category_enum_old"`);
        await queryRunner.query(`ALTER TABLE "affiliate_partners" ALTER COLUMN "createdAt" SET DEFAULT now()`);
        await queryRunner.query(`ALTER TABLE "affiliate_partners" ALTER COLUMN "updatedAt" SET DEFAULT now()`);
        await queryRunner.query(`ALTER TABLE "affiliate_offers" ALTER COLUMN "createdAt" SET DEFAULT now()`);
        await queryRunner.query(`ALTER TABLE "affiliate_offers" ALTER COLUMN "updatedAt" SET DEFAULT now()`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" ALTER COLUMN "createdAt" SET DEFAULT now()`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" ALTER COLUMN "updatedAt" SET DEFAULT now()`);
        await queryRunner.query(`CREATE UNIQUE INDEX "idx_affiliate_link_unique_code" ON "affiliate_links" ("uniqueCode") `);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_172c716617d74bf324763cd033c" FOREIGN KEY ("partnerId") REFERENCES "affiliate_partners"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_19452f529e17bb85935e55df39d" FOREIGN KEY ("offerId") REFERENCES "affiliate_offers"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_9404475399b3b08237a8490d256" FOREIGN KEY ("linkId") REFERENCES "affiliate_links"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_ac5709961be944696d7c9812829" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_772e2f1ddf3b198ad01d1632768" FOREIGN KEY ("bookingId") REFERENCES "bookings"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_offers" ADD CONSTRAINT "FK_94d53af8b994fdc60ede2c86be2" FOREIGN KEY ("partnerId") REFERENCES "affiliate_partners"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" ADD CONSTRAINT "FK_cb9442616fdf8ad0cbdb0cd5f0c" FOREIGN KEY ("offerId") REFERENCES "affiliate_offers"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" ADD CONSTRAINT "FK_cb319c4abc38acc1fc6e9da9420" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_invoices" ADD CONSTRAINT "FK_756797a91a74701ad44c1a9632a" FOREIGN KEY ("partnerId") REFERENCES "affiliate_partners"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_payouts" ADD CONSTRAINT "FK_3afcc6fd6dc793246b29c8e42a7" FOREIGN KEY ("partnerId") REFERENCES "affiliate_partners"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_payouts" ADD CONSTRAINT "FK_8837ff5ccaa577a26fd438d7b45" FOREIGN KEY ("invoiceId") REFERENCES "affiliate_invoices"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "affiliate_payouts" DROP CONSTRAINT "FK_8837ff5ccaa577a26fd438d7b45"`);
        await queryRunner.query(`ALTER TABLE "affiliate_payouts" DROP CONSTRAINT "FK_3afcc6fd6dc793246b29c8e42a7"`);
        await queryRunner.query(`ALTER TABLE "affiliate_invoices" DROP CONSTRAINT "FK_756797a91a74701ad44c1a9632a"`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" DROP CONSTRAINT "FK_cb319c4abc38acc1fc6e9da9420"`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" DROP CONSTRAINT "FK_cb9442616fdf8ad0cbdb0cd5f0c"`);
        await queryRunner.query(`ALTER TABLE "affiliate_offers" DROP CONSTRAINT "FK_94d53af8b994fdc60ede2c86be2"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_772e2f1ddf3b198ad01d1632768"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_ac5709961be944696d7c9812829"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_9404475399b3b08237a8490d256"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_19452f529e17bb85935e55df39d"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" DROP CONSTRAINT "FK_172c716617d74bf324763cd033c"`);
        await queryRunner.query(`DROP INDEX "public"."idx_affiliate_link_unique_code"`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" ALTER COLUMN "updatedAt" SET DEFAULT CURRENT_TIMESTAMP`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" ALTER COLUMN "createdAt" SET DEFAULT CURRENT_TIMESTAMP`);
        await queryRunner.query(`ALTER TABLE "affiliate_offers" ALTER COLUMN "updatedAt" SET DEFAULT CURRENT_TIMESTAMP`);
        await queryRunner.query(`ALTER TABLE "affiliate_offers" ALTER COLUMN "createdAt" SET DEFAULT CURRENT_TIMESTAMP`);
        await queryRunner.query(`ALTER TABLE "affiliate_partners" ALTER COLUMN "updatedAt" SET DEFAULT CURRENT_TIMESTAMP`);
        await queryRunner.query(`ALTER TABLE "affiliate_partners" ALTER COLUMN "createdAt" SET DEFAULT CURRENT_TIMESTAMP`);
        await queryRunner.query(`CREATE TYPE "public"."affiliate_partner_category_enum_old" AS ENUM('TOUR_OPERATOR', 'ACTIVITY_PROVIDER', 'RESTAURANT', 'TRANSPORTATION', 'ECOMMERCE')`);
        await queryRunner.query(`ALTER TABLE "affiliate_partners" ALTER COLUMN "category" TYPE "public"."affiliate_partner_category_enum_old" USING "category"::"text"::"public"."affiliate_partner_category_enum_old"`);
        await queryRunner.query(`DROP TYPE "public"."affiliate_partners_category_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."affiliate_partner_category_enum_old" RENAME TO "affiliate_partner_category_enum"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "updatedAt" SET DEFAULT CURRENT_TIMESTAMP`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "createdAt" SET DEFAULT CURRENT_TIMESTAMP`);
        await queryRunner.query(`CREATE TYPE "public"."affiliate_earning_status_enum_old" AS ENUM('PENDING', 'CONFIRMED', 'PAID', 'CANCELLED')`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "status" DROP DEFAULT`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "status" TYPE "public"."affiliate_earning_status_enum_old" USING "status"::"text"::"public"."affiliate_earning_status_enum_old"`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ALTER COLUMN "status" SET DEFAULT 'PENDING'`);
        await queryRunner.query(`DROP TYPE "public"."affiliate_earnings_status_enum"`);
        await queryRunner.query(`ALTER TYPE "public"."affiliate_earning_status_enum_old" RENAME TO "affiliate_earning_status_enum"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_audit_logs_userId"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_audit_logs_partnerId"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_audit_logs_entityId_entityType"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_audit_logs_actionType"`);
        await queryRunner.query(`DROP TABLE "affiliate_audit_logs"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_payouts_partnerId"`);
        await queryRunner.query(`DROP TABLE "affiliate_payouts"`);
        await queryRunner.query(`DROP TYPE "public"."affiliate_payouts_status_enum"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_invoices_partnerId"`);
        await queryRunner.query(`DROP TABLE "affiliate_invoices"`);
        await queryRunner.query(`DROP TYPE "public"."affiliate_invoices_status_enum"`);
        await queryRunner.query(`CREATE INDEX "IDX_affiliate_links_unique_code" ON "affiliate_links" ("uniqueCode") `);
        await queryRunner.query(`ALTER TABLE "affiliate_links" ADD CONSTRAINT "FK_affiliate_links_offerId" FOREIGN KEY ("offerId") REFERENCES "affiliate_offers"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_links" ADD CONSTRAINT "FK_affiliate_links_userId" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_offers" ADD CONSTRAINT "FK_affiliate_offers_partnerId" FOREIGN KEY ("partnerId") REFERENCES "affiliate_partners"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_affiliate_earnings_partnerId" FOREIGN KEY ("partnerId") REFERENCES "affiliate_partners"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_affiliate_earnings_offerId" FOREIGN KEY ("offerId") REFERENCES "affiliate_offers"("id") ON DELETE CASCADE ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_affiliate_earnings_linkId" FOREIGN KEY ("linkId") REFERENCES "affiliate_links"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_affiliate_earnings_userId" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
        await queryRunner.query(`ALTER TABLE "affiliate_earnings" ADD CONSTRAINT "FK_affiliate_earnings_bookingId" FOREIGN KEY ("bookingId") REFERENCES "bookings"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
    }

}
