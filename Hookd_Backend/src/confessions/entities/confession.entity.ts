import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('confessions')
export class Confession {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ nullable: true, name: 'author_id' })
  authorId: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'author_id' })
  author: User;

  @Column({ default: false, name: 'is_anonymous' })
  isAnonymous: boolean;

  @Column({ type: 'text' })
  body: string;

  @Column({ type: 'text', nullable: true, name: 'image_url' })
  imageUrl: string;

  @Column({ nullable: true, name: 'stream_activity_id' })
  streamActivityId: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
