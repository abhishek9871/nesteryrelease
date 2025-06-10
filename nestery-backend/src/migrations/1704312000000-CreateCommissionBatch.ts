import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreateCommissionBatch1704312000000 implements MigrationInterface {
  name = 'CreateCommissionBatch1704312000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create enum type for batch status
    await queryRunner.query(`
      CREATE TYPE "batch_status_enum" AS ENUM('processing', 'completed', 'failed')
    `);

    // Create commission_batches table
    await queryRunner.createTable(
      new Table({
        name: 'commission_batches',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'batchDate',
            type: 'date',
            isNullable: false,
          },
          {
            name: 'totalCommissions',
            type: 'decimal',
            precision: 12,
            scale: 2,
            default: 0,
          },
          {
            name: 'processedEarnings',
            type: 'integer',
            default: 0,
          },
          {
            name: 'status',
            type: 'enum',
            enum: ['processing', 'completed', 'failed'],
            default: "'processing'",
          },
          {
            name: 'errorMessage',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'createdAt',
            type: 'timestamp with time zone',
            default: 'CURRENT_TIMESTAMP',
          },
          {
            name: 'updatedAt',
            type: 'timestamp with time zone',
            default: 'CURRENT_TIMESTAMP',
          },
        ],
      }),
      true,
    );

    // Create indexes for performance
    await queryRunner.query(`
      CREATE INDEX "IDX_commission_batches_batch_date" ON "commission_batches" ("batchDate")
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_commission_batches_status" ON "commission_batches" ("status")
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_commission_batches_created_at" ON "commission_batches" ("createdAt")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop indexes
    await queryRunner.query(`DROP INDEX "IDX_commission_batches_created_at"`);
    await queryRunner.query(`DROP INDEX "IDX_commission_batches_status"`);
    await queryRunner.query(`DROP INDEX "IDX_commission_batches_batch_date"`);

    // Drop table
    await queryRunner.dropTable('commission_batches');

    // Drop enum type
    await queryRunner.query(`DROP TYPE "batch_status_enum"`);
  }
}
