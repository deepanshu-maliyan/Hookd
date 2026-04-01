import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Like } from './entities/like.entity';
import { Match } from './entities/match.entity';
import { StreamService } from '../stream/stream.service';
import { UsersService } from '../users/users.service';

@Injectable()
export class MatchingService {
  constructor(
    @InjectRepository(Like)
    private readonly likesRepository: Repository<Like>,
    @InjectRepository(Match)
    private readonly matchesRepository: Repository<Match>,
    private readonly streamService: StreamService,
    private readonly usersService: UsersService,
  ) {}

  async likeUser(likerId: string, likedId: string): Promise<{ matched: boolean; match?: Match }> {
    const existingLike = await this.likesRepository.findOne({
      where: { likerId, likedId },
    });

    if (existingLike) {
      return { matched: false };
    }

    const like = this.likesRepository.create({ likerId, likedId });
    await this.likesRepository.save(like);

    const reciprocalLike = await this.likesRepository.findOne({
      where: { likerId: likedId, likedId: likerId },
    });

    if (reciprocalLike) {
      const channelId = `match-${[likerId, likedId].sort().join('-')}`;
      await this.streamService.createChannel(channelId, likerId, likedId);

      const match = this.matchesRepository.create({
        user1Id: likerId < likedId ? likerId : likedId,
        user2Id: likerId < likedId ? likedId : likerId,
        streamChannelId: channelId,
      });

      const savedMatch = await this.matchesRepository.save(match);
      return { matched: true, match: savedMatch };
    }

    return { matched: false };
  }

  async getMatches(userId: string): Promise<Match[]> {
    return this.matchesRepository
      .createQueryBuilder('match')
      .leftJoinAndSelect('match.user1', 'user1')
      .leftJoinAndSelect('match.user2', 'user2')
      .where('match.user1_id = :userId OR match.user2_id = :userId', { userId })
      .orderBy('match.created_at', 'DESC')
      .getMany();
  }

  async unmatch(matchId: string, userId: string): Promise<void> {
    const match = await this.matchesRepository.findOne({
      where: { id: matchId },
    });

    if (!match) {
      throw new NotFoundException('Match not found');
    }

    if (match.user1Id !== userId && match.user2Id !== userId) {
      throw new NotFoundException('Match not found');
    }

    await this.matchesRepository.remove(match);
  }

  async getDiscoveryUsers(userId: string): Promise<any[]> {
    const likedUserIds = await this.likesRepository
      .createQueryBuilder('like')
      .select('like.liked_id')
      .where('like.liker_id = :userId', { userId })
      .getRawMany();

    const likedIds = likedUserIds.map((row) => row.like_liked_id);

    const users = await this.usersService.findDiscoveryUsers(userId, 20);

    return users.filter((user) => !likedIds.includes(user.id));
  }
}
