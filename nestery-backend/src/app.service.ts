import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

@Injectable()
export class AppService {
  constructor(
    @InjectDataSource()
    private readonly dataSource: DataSource,
  ) {}

  async getHealth(): Promise<{ status: string; version: string; database?: string; timestamp: string }> {
    const result = {
      status: 'ok',
      version: '0.0.1',
      timestamp: new Date().toISOString(),
    };

    try {
      // Test database connection
      await this.dataSource.query('SELECT 1');
      return {
        ...result,
        database: 'connected',
      };
    } catch (error) {
      return {
        ...result,
        status: 'error',
        database: `disconnected: ${error.message}`,
      };
    }
  }
}
