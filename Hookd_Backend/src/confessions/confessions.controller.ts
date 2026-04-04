import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ConfessionsService } from './confessions.service';
import { CreateConfessionDto } from './dto/create-confession.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { User } from '../users/entities/user.entity';

@Controller('confessions')
export class ConfessionsController {
  constructor(private readonly confessionsService: ConfessionsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async create(
    @CurrentUser() user: User,
    @Body() createConfessionDto: CreateConfessionDto,
  ) {
    return this.confessionsService.create(user.id, createConfessionDto);
  }

  @Get()
  async findAll(
    @Query('limit') limit?: number,
    @Query('offset') offset?: number,
  ) {
    const confessions = await this.confessionsService.findAll(limit, offset);
    // Transform to match iOS expected format
    const transformedConfessions = confessions.map(c => ({
      id: c.id,
      body: c.body,
      imageUrl: c.imageUrl,
      upvotes: 0,
      commentCount: 0,
      createdAt: c.createdAt,
      isAnonymous: c.isAnonymous,
      hasUpvoted: false,
    }));
    return { 
      confessions: transformedConfessions, 
      hasMore: confessions.length >= (limit || 20) 
    };
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.confessionsService.findOne(id);
  }
}
