import {
  Controller,
  Post,
  Get,
  Delete,
  Param,
  UseGuards,
} from '@nestjs/common';
import { MatchingService } from './matching.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { User } from '../users/entities/user.entity';

@Controller('matching')
@UseGuards(JwtAuthGuard)
export class MatchingController {
  constructor(private readonly matchingService: MatchingService) {}

  @Post('like/:targetId')
  async likeUser(@CurrentUser() user: User, @Param('targetId') targetId: string) {
    const result = await this.matchingService.likeUser(user.id, targetId);
    return { isMatch: result.matched, match: result.match || null };
  }

  @Get('matches')
  async getMatches(@CurrentUser() user: User) {
    const matches = await this.matchingService.getMatches(user.id);
    // Transform matches to include matchedUser
    const transformedMatches = matches.map(match => {
      const matchedUser = match.user1Id === user.id ? match.user2 : match.user1;
      return {
        id: match.id,
        userId: user.id,
        matchedUserId: matchedUser?.id,
        matchedUser: matchedUser,
        createdAt: match.createdAt,
        lastMessage: null,
        lastMessageAt: null,
        unreadCount: 0,
      };
    });
    return { matches: transformedMatches };
  }

  @Delete('unmatch/:matchId')
  async unmatch(@CurrentUser() user: User, @Param('matchId') matchId: string) {
    await this.matchingService.unmatch(matchId, user.id);
    return { message: 'Unmatched successfully' };
  }

  @Get('discovery')
  async getDiscoveryUsers(@CurrentUser() user: User) {
    const users = await this.matchingService.getDiscoveryUsers(user.id);
    return { users };
  }
}
