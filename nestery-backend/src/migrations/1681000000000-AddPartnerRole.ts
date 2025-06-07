import { MigrationInterface, QueryRunner } from "typeorm";

export class AddPartnerRole1681000000000 implements MigrationInterface {
    name = 'AddPartnerRole1681000000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // The role column is VARCHAR(20) and can already store 'partner' value
        // No database schema changes needed - this migration is a no-op
        console.log('Role column supports partner role - no migration needed');
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        throw new Error("Downward migration for adding an enum value is not supported for safety.");
    }
}
