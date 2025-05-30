import { Request } from 'express';

export interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    email: string;
    // Add other properties from JwtPayload if needed, e.g., role
    role: string;
  };
}
