# Nestery Deployment Guide

This comprehensive guide provides step-by-step instructions for deploying the Nestery application, including both the NestJS backend and Flutter client, to production environments.

## Backend Deployment

### Prerequisites
- Docker and Docker Compose installed
- Access to a PostgreSQL database server
- Domain name with DNS configured (for production deployment)
- SSL certificate (for production deployment)

### Option 1: Docker Deployment

#### 1. Clone the Repository
```bash
git clone https://github.com/abhishek9871/nesteryrelease.git
cd nesteryrelease/nestery-backend
```

#### 2. Configure Environment Variables
```bash
cp .env.example .env
```

Edit the `.env` file with your production settings:
```
# Application
NODE_ENV=production
PORT=3000
API_PREFIX=api
FRONTEND_URL=https://your-frontend-domain.com

# Database
DB_HOST=your-db-host
DB_PORT=5432
DB_USERNAME=your-db-username
DB_PASSWORD=your-db-password
DB_DATABASE=nestery
DB_SYNCHRONIZE=false

# JWT Authentication
JWT_SECRET=your_secure_jwt_secret_key_here
JWT_EXPIRATION=3600
JWT_REFRESH_EXPIRATION=604800

# External APIs
BOOKING_API_URL=https://distribution-xml.booking.com/3.1
BOOKING_API_KEY=your_booking_api_key_here
BOOKING_API_SECRET=your_booking_api_secret_here

OYO_API_URL=https://api.oyorooms.com
OYO_API_KEY=your_oyo_api_key_here
OYO_API_SECRET=your_oyo_api_secret_here
OYO_FALLBACK_ENABLED=true
OYO_CACHE_TTL=3600

GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
GOOGLE_MAPS_GEOCODING_URL=https://maps.googleapis.com/maps/api/geocode/json
GOOGLE_MAPS_PLACES_URL=https://maps.googleapis.com/maps/api/place

STRIPE_SECRET_KEY=your_stripe_secret_key_here
STRIPE_WEBHOOK_SECRET=your_stripe_webhook_secret_here

# Logging
LOG_LEVEL=info
LOG_FORMAT=combined

# Security
CORS_ORIGIN=https://your-frontend-domain.com
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX=100
```

#### 3. Build and Start Docker Containers
```bash
docker-compose build
docker-compose up -d
```

This will start the following containers:
- PostgreSQL database (if using the included database container)
- NestJS application
- Nginx web server (for SSL termination and reverse proxy)

#### 4. Run Database Migrations
```bash
docker-compose exec app npm run migration:run
```

#### 5. Verify Deployment
Access your API at `https://your-domain.com/api` or `http://localhost:3000/api` if testing locally.

The Swagger documentation should be available at `https://your-domain.com/api/docs` or `http://localhost:3000/api/docs`.

### Option 2: AWS Elastic Beanstalk Deployment

#### 1. Prepare the Application
```bash
git clone https://github.com/abhishek9871/nesteryrelease.git
cd nesteryrelease/nestery-backend
```

#### 2. Install the EB CLI
```bash
pip install awsebcli
```

#### 3. Initialize EB Application
```bash
eb init
```

Follow the prompts to configure your application:
- Select a region
- Create a new application or use an existing one
- Select Node.js as the platform
- Set up SSH for instance access (optional)

#### 4. Configure Environment Variables
Create a `.ebextensions` directory and add a configuration file:

```bash
mkdir .ebextensions
```

Create a file `.ebextensions/env.config`:
```yaml
option_settings:
  aws:elasticbeanstalk:application:environment:
    NODE_ENV: production
    PORT: 3000
    API_PREFIX: api
    FRONTEND_URL: https://your-frontend-domain.com
    DB_HOST: your-rds-endpoint
    DB_PORT: 5432
    DB_USERNAME: your-db-username
    DB_PASSWORD: your-db-password
    DB_DATABASE: nestery
    DB_SYNCHRONIZE: false
    JWT_SECRET: your_secure_jwt_secret_key_here
    JWT_EXPIRATION: 3600
    JWT_REFRESH_EXPIRATION: 604800
    BOOKING_API_URL: https://distribution-xml.booking.com/3.1
    BOOKING_API_KEY: your_booking_api_key_here
    BOOKING_API_SECRET: your_booking_api_secret_here
    OYO_API_URL: https://api.oyorooms.com
    OYO_API_KEY: your_oyo_api_key_here
    OYO_API_SECRET: your_oyo_api_secret_here
    OYO_FALLBACK_ENABLED: true
    OYO_CACHE_TTL: 3600
    GOOGLE_MAPS_API_KEY: your_google_maps_api_key_here
    STRIPE_SECRET_KEY: your_stripe_secret_key_here
    STRIPE_WEBHOOK_SECRET: your_stripe_webhook_secret_here
    LOG_LEVEL: info
    LOG_FORMAT: combined
    CORS_ORIGIN: https://your-frontend-domain.com
    RATE_LIMIT_WINDOW_MS: 900000
    RATE_LIMIT_MAX: 100
```

#### 5. Create an RDS Database (if needed)
Create an RDS PostgreSQL instance through the AWS console or using the AWS CLI.

#### 6. Deploy the Application
```bash
eb create nestery-production
```

#### 7. Run Database Migrations
SSH into the EB instance or use the EB CLI to run commands:

```bash
eb ssh
cd /var/app/current
npm run migration:run
```

#### 8. Configure HTTPS
Use the AWS Certificate Manager to create an SSL certificate and configure it in the EB environment load balancer settings.

### Option 3: Google Cloud Run Deployment

#### 1. Install Google Cloud SDK
Follow the instructions at https://cloud.google.com/sdk/docs/install

#### 2. Authenticate with Google Cloud
```bash
gcloud auth login
gcloud config set project your-project-id
```

#### 3. Build and Push Docker Image
```bash
git clone https://github.com/abhishek9871/nesteryrelease.git
cd nesteryrelease/nestery-backend

# Build the Docker image
gcloud builds submit --tag gcr.io/your-project-id/nestery-backend

# Deploy to Cloud Run
gcloud run deploy nestery-backend \
  --image gcr.io/your-project-id/nestery-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="NODE_ENV=production,PORT=8080,API_PREFIX=api,FRONTEND_URL=https://your-frontend-domain.com,DB_HOST=your-db-host,DB_PORT=5432,DB_USERNAME=your-db-username,DB_PASSWORD=your-db-password,DB_DATABASE=nestery,DB_SYNCHRONIZE=false,JWT_SECRET=your_secure_jwt_secret_key_here,JWT_EXPIRATION=3600,JWT_REFRESH_EXPIRATION=604800"
```

#### 4. Set Up Cloud SQL (if needed)
Create a PostgreSQL instance in Cloud SQL and connect it to your Cloud Run service.

#### 5. Run Database Migrations
You can run migrations using Cloud Build or by connecting to the database directly:

```bash
gcloud builds submit --config cloudbuild.yaml .
```

Create a `cloudbuild.yaml` file:
```yaml
steps:
  - name: 'gcr.io/cloud-builders/npm'
    args: ['install']
  - name: 'gcr.io/cloud-builders/npm'
    args: ['run', 'migration:run']
    env:
      - 'DB_HOST=your-db-host'
      - 'DB_PORT=5432'
      - 'DB_USERNAME=your-db-username'
      - 'DB_PASSWORD=your-db-password'
      - 'DB_DATABASE=nestery'
```

## Flutter Client Deployment

### Android Deployment

#### 1. Update API Configuration
```bash
cd nesteryrelease/nestery-flutter
```

Create a `.env` file based on `.env.example` and update the API base URL:
```
API_BASE_URL=https://your-backend-domain.com
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
ANALYTICS_ENABLED=true
ENVIRONMENT=production
```

#### 2. Update App Version (Optional)
Edit `pubspec.yaml` to update the version number:
```yaml
version: 1.0.0+1  # Format: version_name+version_code
```

#### 3. Build the APK
```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

#### 4. Build App Bundle for Google Play
```bash
flutter build appbundle
```

The AAB will be generated at `build/app/outputs/bundle/release/app-release.aab`.

#### 5. Sign the APK/AAB
For Google Play Store distribution, you need to sign your app:

```bash
# Generate a keystore if you don't have one
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure signing in key.properties
echo "storePassword=your-keystore-password" > android/key.properties
echo "keyPassword=your-key-password" >> android/key.properties
echo "keyAlias=upload" >> android/key.properties
echo "storeFile=../upload-keystore.jks" >> android/key.properties
```

Update `android/app/build.gradle` to use the signing configuration.

#### 6. Upload to Google Play Store
Use the Google Play Console to upload your AAB file and publish your app.

### iOS Deployment

#### 1. Update API Configuration
Same as for Android, create and configure the `.env` file.

#### 2. Update iOS Bundle Identifier and Version
Edit `ios/Runner/Info.plist` if needed.

#### 3. Build the iOS Release
```bash
flutter build ios --release
```

#### 4. Open the Xcode Project
```bash
open ios/Runner.xcworkspace
```

#### 5. Configure Signing and Capabilities
In Xcode:
- Select the Runner project
- Go to the Signing & Capabilities tab
- Select your team and configure signing

#### 6. Archive and Upload to App Store
In Xcode:
- Select Product > Archive
- Once archiving is complete, click "Distribute App"
- Follow the prompts to upload to the App Store

### Web Deployment

#### 1. Update API Configuration
Same as for Android, create and configure the `.env` file.

#### 2. Build the Web Release
```bash
flutter build web --release
```

The web build will be generated in the `build/web` directory.

#### 3. Deploy to Firebase Hosting (Example)
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init hosting

# Deploy to Firebase
firebase deploy --only hosting
```

#### 4. Alternative: Deploy to Netlify
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login to Netlify
netlify login

# Initialize Netlify in your project
netlify init

# Deploy to Netlify
netlify deploy --prod
```

## Database Migration in Production

### Running Migrations
```bash
# For Docker deployment
docker-compose exec app npm run migration:run

# For direct server deployment
npm run migration:run

# For AWS EB deployment
eb ssh
cd /var/app/current
npm run migration:run
```

### Creating a New Migration
```bash
# Generate a migration
npm run migration:generate -- -n MigrationName

# Create an empty migration
npm run migration:create -- -n MigrationName
```

### Rolling Back Migrations
```bash
# Revert the last migration
npm run migration:revert
```

## Monitoring and Maintenance

### Health Checks
The API provides a health check endpoint at `/api/health` that returns the status of the application and its dependencies.

### Logging
Logs are output to the console and can be viewed:
- In Docker: `docker-compose logs -f app`
- In AWS EB: Through the EB console or `eb logs`
- In Google Cloud Run: Through Cloud Logging

### Backup Strategy
Regularly backup your PostgreSQL database:
```bash
# For local PostgreSQL
pg_dump -U postgres -d nestery > backup_$(date +%Y%m%d).sql

# For Docker PostgreSQL
docker-compose exec db pg_dump -U postgres -d nestery > backup_$(date +%Y%m%d).sql

# For AWS RDS
pg_dump -h your-rds-endpoint -U postgres -d nestery > backup_$(date +%Y%m%d).sql
```

## Troubleshooting

### Common Issues and Solutions

#### Backend Issues
1. **Database Connection Errors**
   - Check database credentials in `.env`
   - Ensure database server is running
   - Verify network connectivity and security groups/firewall rules

2. **API Key Errors**
   - Verify all external API keys are correctly set in `.env`
   - Check for API key expiration or usage limits

3. **JWT Authentication Issues**
   - Ensure JWT_SECRET is set and consistent
   - Check token expiration times

#### Flutter Client Issues
1. **API Connection Errors**
   - Verify API_BASE_URL in `.env`
   - Check network connectivity
   - Ensure backend is accessible from client devices

2. **Google Maps Issues**
   - Verify GOOGLE_MAPS_API_KEY is correct
   - Ensure API key has the necessary permissions

3. **Build Errors**
   - Run `flutter clean` and try building again
   - Update Flutter SDK if needed
   - Check for dependency conflicts in `pubspec.yaml`

## Security Considerations

### Production Security Checklist
- [ ] Use strong, unique passwords for all services
- [ ] Enable HTTPS for all endpoints
- [ ] Properly configure CORS to restrict access
- [ ] Set appropriate rate limits
- [ ] Regularly update dependencies for security patches
- [ ] Implement proper logging (without sensitive data)
- [ ] Use environment variables for all secrets
- [ ] Configure database with minimal required permissions
- [ ] Regularly backup data
- [ ] Implement monitoring and alerting

## Scaling Considerations

As your user base grows, consider:
1. Horizontal scaling of the backend (multiple instances)
2. Database read replicas for scaling read operations
3. Caching layer (Redis) for frequently accessed data
4. CDN for static assets
5. Load balancing for distributing traffic

## Conclusion

This deployment guide covers the essential steps for deploying the Nestery application to production environments. For specific issues or advanced configurations, refer to the official documentation for the respective technologies or contact the development team.
