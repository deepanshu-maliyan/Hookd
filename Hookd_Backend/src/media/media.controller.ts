import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { MediaService } from './media.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { IsString } from 'class-validator';

class PresignedUrlDto {
  @IsString()
  fileName: string;

  @IsString()
  contentType: string;
}

@Controller('media')
@UseGuards(JwtAuthGuard)
export class MediaController {
  constructor(private readonly mediaService: MediaService) {}

  @Post('presigned-url')
  async getPresignedUrl(@Body() dto: PresignedUrlDto) {
    const presignedUrl = await this.mediaService.generatePresignedUploadUrl(
      dto.fileName,
      dto.contentType,
    );
    return { presignedUrl };
  }
}
