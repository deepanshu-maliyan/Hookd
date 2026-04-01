import { IsString, IsBoolean, IsOptional } from 'class-validator';

export class CreateConfessionDto {
  @IsBoolean()
  isAnonymous: boolean;

  @IsString()
  body: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;
}
