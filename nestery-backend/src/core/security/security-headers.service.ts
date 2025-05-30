import { Injectable, Logger } from '@nestjs/common';
import helmet from 'helmet';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class SecurityHeadersService {
  private readonly logger = new Logger(SecurityHeadersService.name);

  /**
   * Apply security headers to the response
   * @param req Express request object
   * @param res Express response object
   * @param next Express next function
   */
  applySecurityHeaders(req: Request, res: Response, next: NextFunction): void {
    // Apply default helmet protections
    // Use helmet as a function directly
    const helmetMiddleware = helmet();
    helmetMiddleware(req, res, () => {
      // Additional custom security headers

      // Content Security Policy
      res.setHeader(
        'Content-Security-Policy',
        "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https:; frame-ancestors 'none'; form-action 'self'; base-uri 'self'; object-src 'none'",
      );

      // Strict Transport Security (HSTS)
      res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');

      // X-Content-Type-Options
      res.setHeader('X-Content-Type-Options', 'nosniff');

      // X-Frame-Options
      res.setHeader('X-Frame-Options', 'DENY');

      // X-XSS-Protection
      res.setHeader('X-XSS-Protection', '1; mode=block');

      // Referrer-Policy
      res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');

      // Permissions-Policy
      res.setHeader(
        'Permissions-Policy',
        'camera=(), microphone=(), geolocation=(self), payment=(self)',
      );

      // Cache-Control for API responses
      if (req.path.startsWith('/v1/')) {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        res.setHeader('Surrogate-Control', 'no-store');
      }

      next();
    });
  }
}
