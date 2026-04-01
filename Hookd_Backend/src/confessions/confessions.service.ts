import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Confession } from './entities/confession.entity';
import { CreateConfessionDto } from './dto/create-confession.dto';

@Injectable()
export class ConfessionsService {
  constructor(
    @InjectRepository(Confession)
    private readonly confessionsRepository: Repository<Confession>,
  ) {}

  async create(
    userId: string,
    createConfessionDto: CreateConfessionDto,
  ): Promise<Confession> {
    const confession = this.confessionsRepository.create({
      authorId: createConfessionDto.isAnonymous ? null : userId,
      isAnonymous: createConfessionDto.isAnonymous,
      body: createConfessionDto.body,
      imageUrl: createConfessionDto.imageUrl,
    });

    const savedConfession = await this.confessionsRepository.save(confession);
    
    return savedConfession;
  }

  async findAll(limit = 50, offset = 0): Promise<Confession[]> {
    return this.confessionsRepository.find({
      relations: ['author'],
      order: { createdAt: 'DESC' },
      take: limit,
      skip: offset,
    });
  }

  async findOne(id: string): Promise<Confession> {
    const confession = await this.confessionsRepository.findOne({
      where: { id },
      relations: ['author'],
    });

    if (!confession) {
      throw new NotFoundException('Confession not found');
    }

    return confession;
  }
}
