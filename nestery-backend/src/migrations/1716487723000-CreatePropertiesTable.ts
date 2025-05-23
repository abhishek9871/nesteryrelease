import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreatePropertiesTable1716487723000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "properties" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "name" character varying NOT NULL,
        "description" character varying NOT NULL,
        "address" character varying NOT NULL,
        "city" character varying NOT NULL,
        "state" character varying NOT NULL,
        "country" character varying NOT NULL,
        "zipCode" character varying NOT NULL,
        "latitude" decimal(10,6) NOT NULL,
        "longitude" decimal(10,6) NOT NULL,
        "propertyType" character varying NOT NULL,
        "starRating" integer NOT NULL,
        "basePrice" decimal(10,2) NOT NULL,
        "currency" character varying NOT NULL,
        "maxGuests" integer NOT NULL,
        "bedrooms" integer NOT NULL,
        "bathrooms" integer NOT NULL,
        "amenities" text,
        "images" text,
        "thumbnailImage" character varying,
        "isActive" boolean NOT NULL DEFAULT true,
        "sourceType" character varying NOT NULL,
        "externalId" character varying NOT NULL,
        "externalUrl" character varying,
        "metadata" jsonb,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_properties_id" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_properties_sourceType_externalId" UNIQUE ("sourceType", "externalId")
      )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "properties"`);
  }
}
