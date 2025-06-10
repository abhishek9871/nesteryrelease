# 🚀 NESTERY BACKEND DEPLOYMENT GUIDE

## 📋 PREREQUISITES CHECKLIST

- [ ] GitHub account
- [ ] Neon account (neon.tech)
- [ ] Upstash account (upstash.com)
- [ ] Railway account (railway.app)

## 🗄️ STEP 1: SETUP NEON POSTGRESQL (5 MINUTES)

1. **Go to [neon.tech](https://neon.tech)**
2. **Sign up** (free, no credit card required)
3. **Create new project**: "nestery-production"
4. **Copy connection details**:
   - Host: `ep-xxx-xxx.us-east-2.aws.neon.tech`
   - Database: `neondb`
   - Username: `neondb_owner`
   - Password: `xxx`

## 🔄 STEP 2: SETUP UPSTASH REDIS (3 MINUTES)

1. **Go to [upstash.com](https://upstash.com)**
2. **Sign up** (free, no credit card required)
3. **Create Redis database**:
   - Name: "nestery-cache"
   - Region: Choose closest to your users
4. **Copy connection details**:
   - Endpoint: `xxx.upstash.io`
   - Port: `6379`
   - Password: `xxx`

## 🚂 STEP 3: SETUP RAILWAY HOSTING (5 MINUTES)

1. **Go to [railway.app](https://railway.app)**
2. **Sign up with GitHub**
3. **Create new project** → **Deploy from GitHub repo**
4. **Select your nestery-backend repository**
5. **Add environment variables** (see below)

## 🔧 STEP 4: ENVIRONMENT VARIABLES

Add these in Railway dashboard → Variables:

```
NODE_ENV=production
PORT=3000
API_PREFIX=v1

DATABASE_HOST=your-neon-host.neon.tech
DATABASE_PORT=5432
DATABASE_USERNAME=your-neon-username
DATABASE_PASSWORD=your-neon-password
DATABASE_NAME=your-neon-database
DATABASE_SCHEMA=public
DATABASE_SYNCHRONIZE=true
DATABASE_LOGGING=false

CACHE_HOST=your-upstash-host.upstash.io
CACHE_PORT=6379
CACHE_PASSWORD=your-upstash-password
CACHE_TTL_DEFAULT_SECONDS=60

JWT_SECRET=your_super_secure_jwt_secret_change_this
JWT_ACCESS_EXPIRATION=15m
JWT_REFRESH_EXPIRATION=7d
JWT_ACCESS_SECRET=your_jwt_access_secret
JWT_REFRESH_SECRET=your_jwt_refresh_secret

CORS_ORIGIN=*
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX=100
LOG_LEVEL=info
LOG_FORMAT=combined
```

## ✅ STEP 5: VERIFY DEPLOYMENT

1. **Check Railway logs** for successful startup
2. **Test health endpoint**: `https://your-app.railway.app/v1/health`
3. **Test registration**: `POST https://your-app.railway.app/v1/auth/register`

## 📱 STEP 6: UPDATE FLUTTER APP

Update your Flutter app's API base URL:

```dart
const String API_BASE_URL = 'https://your-app.railway.app/v1';
```

## 🎯 SUCCESS CRITERIA

- ✅ Backend responds to health checks
- ✅ Database connection working
- ✅ Redis cache working
- ✅ Registration/login working
- ✅ All API endpoints responding

## 🔄 AUTOMATIC DEPLOYMENTS

Railway automatically deploys when you push to your main branch!

## 💰 COST BREAKDOWN

- **Neon PostgreSQL**: $0/month (500MB free forever)
- **Upstash Redis**: $0/month (256MB, 500K commands free forever)
- **Railway Hosting**: $0/month ($5 free credits monthly)
- **TOTAL**: $0/month 🎉

## 🆘 TROUBLESHOOTING

### Database Connection Issues
- Check Neon connection string
- Verify SSL settings
- Check Railway logs

### Redis Connection Issues
- Verify Upstash credentials
- Check Redis URL format
- Test connection in Railway logs

### Deployment Issues
- Check Railway build logs
- Verify package.json scripts
- Check environment variables
