import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateBookingsTable1716487724000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "bookings" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "userId" uuid NOT NULL,
        "propertyId" uuid NOT NULL,
        "checkInDate" date NOT NULL,
        "checkOutDate" date NOT NULL,
        "numberOfGuests" integer NOT NULL,
        "totalPrice" decimal(10,2) NOT NULL,
        "currency" character varying NOT NULL,
        "status" character varying NOT NULL DEFAULT 'pending',
        "confirmationCode" character varying,
        "cancellationReason" character varying,
        "isPaid" boolean NOT NULL DEFAULT false,
        "paymentMethod" character varying,
        "paymentTransactionId" character varying,
        "isRefunded" boolean NOT NULL DEFAULT false,
        "loyaltyPointsEarned" integer NOT NULL DEFAULT 0,
        "loyaltyPointsRedeemed" integer NOT NULL DEFAULT 0,
        "isPremiumBooking" boolean NOT NULL DEFAULT false,
        "specialRequests" character varying,
        "sourceType" character varying,
        "externalBookingId" character varying,
        "metadata" jsonb,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_bookings_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_bookings_userId" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_bookings_propertyId" FOREIGN KEY ("propertyId") REFERENCES "properties"("id") ON DELETE CASCADE
      )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "bookings"`);
  }
}
