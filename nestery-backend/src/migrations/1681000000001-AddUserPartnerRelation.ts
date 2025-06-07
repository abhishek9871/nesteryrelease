import { MigrationInterface, QueryRunner } from "typeorm";

export class AddUserPartnerRelation1681000000001 implements MigrationInterface {
    name = 'AddUserPartnerRelation1681000000001'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" ADD "partner_id" uuid`);
        await queryRunner.query(`ALTER TABLE "users" ADD CONSTRAINT "UQ_users_partner_id" UNIQUE ("partner_id")`);
        await queryRunner.query(`ALTER TABLE "users" ADD CONSTRAINT "FK_users_partner_id" FOREIGN KEY ("partner_id") REFERENCES "affiliate_partners"("id") ON DELETE SET NULL ON UPDATE NO ACTION`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "FK_users_partner_id"`);
        await queryRunner.query(`ALTER TABLE "users" DROP CONSTRAINT "UQ_users_partner_id"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "partner_id"`);
    }
}
