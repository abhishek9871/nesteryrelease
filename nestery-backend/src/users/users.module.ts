import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { User } from './entities/user.entity';
import { CoreModule } from '../core/core.module';

/**
 * Users module handling user-related operations
 */
@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    CoreModule,
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
