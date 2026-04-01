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
    return this.matchingService.likeUser(user.id, targetId);
  }

  @Get('matches')
  async getMatches(@CurrentUser() user: User) {
    return this.matchingService.getMatches(user.id);
  }

  @Delete('unmatch/:matchId')
  async unmatch(@CurrentUser() user: User, @Param('matchId') matchId: string) {
    await this.matchingService.unmatch(matchId, user.id);
    return { message: 'Unmatched successfully' };
  }

  @Get('discovery')
  async getDiscoveryUsers(@CurrentUser() user: User) {
    return this.matchingService.getDiscoveryUsers(user.id);
  }
}
