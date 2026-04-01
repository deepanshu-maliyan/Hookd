import {
  IsEmail,
  IsString,
  MinLength,
  IsInt,
  Min,
  Max,
} from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  @MinLength(2)
  name: string;

  @IsInt()
  @Min(18)
  @Max(100)
  age: number;

  @IsString()
  gender: string;
}
