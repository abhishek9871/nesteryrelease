import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHealth(): { status: string; version: string } {
    return {
      status: 'ok',
      version: '0.0.1',
    };
  }
}
