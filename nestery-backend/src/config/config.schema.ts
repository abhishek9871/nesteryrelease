import * as Joi from 'joi';

export const configValidationSchema = Joi.object({
  // Application
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  PORT: Joi.number().default(3000),
  HOST: Joi.string().default('0.0.0.0'),
  API_PREFIX: Joi.string().default('v1'),
  FRONTEND_URL: Joi.string().default('http://localhost:3000'),

  // Database
  DATABASE_URL: Joi.string().optional(), // For Neon PostgreSQL connection string
  DATABASE_HOST: Joi.string().default('localhost'),
  DATABASE_PORT: Joi.number().default(5432),
  DATABASE_USERNAME: Joi.string().default('postgres'),
  DATABASE_PASSWORD: Joi.string().default('password'),
  DATABASE_NAME: Joi.string().default('nestery'),
  DATABASE_SCHEMA: Joi.string().default('public'),
  DATABASE_SYNCHRONIZE: Joi.boolean().default(false),
  DATABASE_LOGGING: Joi.boolean().default(true),

  // JWT Authentication
  JWT_SECRET: Joi.string().default('default-secret-for-development-only'),
  JWT_ACCESS_EXPIRATION: Joi.string().default('15m'),
  JWT_REFRESH_EXPIRATION: Joi.string().default('7d'),

  // External APIs
  BOOKING_COM_API_KEY: Joi.string().required(),
  BOOKING_COM_API_SECRET: Joi.string().required(),
  BOOKING_COM_API_URL: Joi.string().required(),
  GOOGLE_MAPS_API_KEY: Joi.string().required(),
  GOOGLE_MAPS_API_URL: Joi.string().required(),

  // Rate Limiting
  THROTTLE_TTL: Joi.number().default(60),
  THROTTLE_LIMIT: Joi.number().default(10),

  // Logging
  LOG_LEVEL: Joi.string().valid('error', 'warn', 'info', 'debug').default('info'),

  // Security
  CORS_ORIGIN: Joi.string().default('*'),

  // Feature Flags
  ENABLE_SWAGGER: Joi.boolean().default(true),
  ENABLE_RATE_LIMITING: Joi.boolean().default(true),

  // Cache
  CACHE_HOST: Joi.string().default('localhost'),
  CACHE_PORT: Joi.number().default(6379),
  CACHE_TTL_DEFAULT_SECONDS: Joi.number().default(60),
});
