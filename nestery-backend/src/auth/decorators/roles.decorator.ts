import { SetMetadata } from '@nestjs/common';

/**
 * Key for role-based access control metadata
 */
export const ROLES_KEY = 'roles';

/**
 * Decorator to specify required roles for a route
 * @param roles Array of roles that can access the route
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
