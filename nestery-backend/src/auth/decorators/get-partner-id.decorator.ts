import { createParamDecorator, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtPayload } from '../interfaces/jwt-payload.interface';

export const GetPartnerId = createParamDecorator((data: unknown, ctx: ExecutionContext): string => {
  const request = ctx.switchToHttp().getRequest();
  const user = request.user as JwtPayload;
  if (!user || user.role !== 'partner' || !user.partnerId) {
    throw new UnauthorizedException('User is not an authorized partner.');
  }
  return user.partnerId;
});
