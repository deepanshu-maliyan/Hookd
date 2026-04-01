import { Controller, Get, UseGuards } from '@nestjs/common';
import { StreamService } from './stream.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import { User } from '../users/entities/user.entity';

@Controller('stream')
export class StreamController {
  constructor(private readonly streamService: StreamService) {}

  @Get('token')
  @UseGuards(JwtAuthGuard)
  getStreamToken(@CurrentUser() user: User) {
    const token = this.streamService.generateUserToken(user.id);
    return { token, userId: user.id };
  }
}
