import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfessionsController } from './confessions.controller';
import { ConfessionsService } from './confessions.service';
import { Confession } from './entities/confession.entity';
import { StreamModule } from '../stream/stream.module';

@Module({
  imports: [TypeOrmModule.forFeature([Confession]), StreamModule],
  controllers: [ConfessionsController],
  providers: [ConfessionsService],
  exports: [ConfessionsService],
})
export class ConfessionsModule {}
