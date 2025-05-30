import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { User } from './entities/user.entity';
import { CoreModule } from '../core/core.module';
import { ConfigModule } from '@nestjs/config'; // Import ConfigModule

/**
 * Users module handling user-related operations
 */
@Module({
  imports: [TypeOrmModule.forFeature([User]), CoreModule, ConfigModule], // Add ConfigModule
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
