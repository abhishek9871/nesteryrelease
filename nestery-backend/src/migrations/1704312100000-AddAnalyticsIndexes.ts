import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddAnalyticsIndexes1704312100000 implements MigrationInterface {
  name = 'AddAnalyticsIndexes1704312100000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add composite index for affiliate earnings analytics queries
    await queryRunner.query(`
      CREATE INDEX "IDX_affiliate_earnings_partner_status_created" 
      ON "affiliate_earnings" ("partnerId", "status", "createdAt")
    `);

    // Add index for date-based analytics queries
    await queryRunner.query(`
      CREATE INDEX "IDX_affiliate_earnings_created_status" 
      ON "affiliate_earnings" ("createdAt", "status")
    `);

    // Add index for amount earned queries
    await queryRunner.query(`
      CREATE INDEX "IDX_affiliate_earnings_amount_status" 
      ON "affiliate_earnings" ("amountEarned", "status")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop indexes in reverse order
    await queryRunner.query(`DROP INDEX "IDX_affiliate_earnings_amount_status"`);
    await queryRunner.query(`DROP INDEX "IDX_affiliate_earnings_created_status"`);
    await queryRunner.query(`DROP INDEX "IDX_affiliate_earnings_partner_status_created"`);
  }
}
