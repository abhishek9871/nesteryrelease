import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import compression from 'compression';
import cookieParser from 'cookie-parser';
import { AppModule } from './app.module';
import { LoggerService } from './core/logger/logger.service';
/**
 * Bootstrap the application
 */
async function bootstrap() {
  // Create NestJS application
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug', 'verbose'],
  });
  // Get configuration service
  const configService = app.get(ConfigService);
  const logger = app.get(LoggerService);
  logger.setContext('Bootstrap');
  // Set global prefix to v1, but exclude health endpoints for Railway
  app.setGlobalPrefix('v1', {
    exclude: ['/health', '/'],
  });
  // Enable CORS
  app.enableCors({
    origin: configService.get('CORS_ORIGIN', '*'),
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });
  // Use security middleware
  app.use(helmet());
  app.use(compression());
  app.use(cookieParser());
  // Use global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  // Set up Swagger documentation
  if (configService.get('NODE_ENV') !== 'production') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('Nestery API')
      .setDescription('API documentation for Nestery mobile application')
      .setVersion('1.0')
      .addBearerAuth()
      .addServer('/v1')
      .build();
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    // Swagger UI will be available at /v1/docs due to the global prefix
    SwaggerModule.setup('docs', app, document);
    logger.log('Swagger documentation is available at /v1/docs');
  }
  // Start the server
  const port = configService.get('PORT', 3000);
  const host = configService.get('HOST', '0.0.0.0');
  await app.listen(port, host);
  logger.log(`Application is running on ${host}:${port}`);

  // Developer Note:
  // API endpoints are now prefixed with /v1/.
  // Client applications and reverse proxy configurations (e.g., Nginx)
  // must be updated to reflect this change (e.g., /api/users -> /v1/users).
}
bootstrap();
