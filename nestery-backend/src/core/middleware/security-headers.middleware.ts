import { Injectable } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { SecurityHeadersService } from '../security/security-headers.service';

@Injectable()
export class SecurityHeadersMiddleware {
  constructor(private readonly securityHeadersService: SecurityHeadersService) {}

  use(req: Request, res: Response, next: NextFunction) {
    this.securityHeadersService.applySecurityHeaders(req, res, next);
  }
}
