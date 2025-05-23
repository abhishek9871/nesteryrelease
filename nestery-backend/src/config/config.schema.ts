import * as Joi from 'joi';

export const configValidationSchema = Joi.object({
  // Application
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  PORT: Joi.number().default(3000),
  API_PREFIX: Joi.string().default('v1'),
  FRONTEND_URL: Joi.string().required(),

  // Database
  DATABASE_HOST: Joi.string().required(),
  DATABASE_PORT: Joi.number().default(5432),
  DATABASE_USERNAME: Joi.string().required(),
  DATABASE_PASSWORD: Joi.string().required(),
  DATABASE_NAME: Joi.string().required(),
  DATABASE_SCHEMA: Joi.string().default('public'),
  DATABASE_SYNCHRONIZE: Joi.boolean().default(false),
  DATABASE_LOGGING: Joi.boolean().default(true),

  // JWT Authentication
  JWT_SECRET: Joi.string().required(),
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
});
