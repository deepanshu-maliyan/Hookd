import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { StreamChat } from 'stream-chat';

@Injectable()
export class StreamService {
  private client: StreamChat;

  constructor(private readonly configService: ConfigService) {
    const apiKey = this.configService.get<string>('STREAM_API_KEY');
    const apiSecret = this.configService.get<string>('STREAM_API_SECRET');
    this.client = StreamChat.getInstance(apiKey, apiSecret);
  }

  async syncUser(
    userId: string,
    userData: { id: string; name: string; image?: string },
  ): Promise<void> {
    await this.client.upsertUser({
      id: userData.id,
      name: userData.name,
      image: userData.image,
    });
  }

  generateUserToken(userId: string): string {
    return this.client.createToken(userId);
  }

  async createChannel(
    channelId: string,
    user1Id: string,
    user2Id: string,
  ): Promise<string> {
    const channel = this.client.channel('messaging', channelId, {
      members: [user1Id, user2Id],
      created_by_id: user1Id,
    });

    await channel.create();
    return channelId;
  }

  getClient(): StreamChat {
    return this.client;
  }
}
