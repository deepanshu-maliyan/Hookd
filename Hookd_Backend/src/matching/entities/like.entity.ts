import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Unique,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('likes')
@Unique(['likerId', 'likedId'])
export class Like {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'liker_id' })
  likerId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'liker_id' })
  liker: User;

  @Column({ name: 'liked_id' })
  likedId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'liked_id' })
  liked: User;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
