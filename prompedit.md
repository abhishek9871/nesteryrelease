Ok, we are continuing the task 4 from the @Genspark_Research_Input.md file. I want you to read the file and all of the sections that relate to the task 4 and its subtasks. We will be focusing on the task 4.3 and 4.4 for this chat thread. Please read the @NSI_3.0_PERFECT_FUSION.md file anD then follow it to complete the tasks 4.3 and 4.4. Alos, in a different chat hread you decided upon a blueprint for the task 4. Please read that file and use it to complete the tasks 4.3 and 4.4. If you need to do research about naything that you not sure about then please use Tavily mcp for completing the tasks. If you need help regading how to use the configured MCP servers for your help then please refer to the @MCP_FUNCTION_CATALOG.md file. 



URGENT: Railway NestJS Deployment Fix - Database Authentication Error

I have a NestJS backend (Nestery project) that's failing to deploy on Railway with this specific error:

ERROR: password authentication failed for user 'neondb_owner'

CURRENT STATUS:

✅ Build succeeds (webpack compiles successfully)
✅ App starts loading modules
❌ Database connection fails during startup
❌ Health check fails due to database connection error

CURRENT SETUP:

Platform: Railway deployment
Database: Neon PostgreSQL (free tier)
Cache: Upstash Redis
Framework: NestJS with TypeORM
Repository: GitHub monorepo, deploying from nestery-backend folder
CURRENT ENVIRONMENT VARIABLES IN RAILWAY:

NODE_ENV=production
PORT=3000
HOST=0.0.0.0
DATABASE_URL=postgresql://neondb_owner:npg_7Y1srBETQcjk@ep-wispy-union-a8ochsuh-pooler.eastus2.azure.neon.tech:5432/neondb?sslmode=require
CACHE_HOST=fit-crawdad-24523.upstash.io
CACHE_PORT=6379
CACHE_PASSWORD=AV_LAAIjcDE3YzZkNDAwNmM0M2Q0ZGY3OWZkNWIzMTIwM2QyNGM2NnAxMA
JWT_SECRET=39e241866207291ede33cab28b231d8ab36379aa6c8e469e492efc84799726a1c3c047e1d9b4a1f88b902f89e0e2a43e3efd9ce5aa896b20478293d2ce103530
FRONTEND_URL=http://localhost:3000

EXACT ERROR FROM LOGS present in the @deploylogs.md file. pLease read it and use tavily MCP to fix the issue with perefction.

WHAT I NEED:

Fix the Neon PostgreSQL authentication issue
Ensure successful Railway deployment
Working health check at /health endpoint
CONSTRAINTS:

Must use existing Neon database (don't create new one)
Must use Railway for deployment
Must maintain current environment variables if possible
GOAL: Get this deployment working successfully with proper database connection.

Please provide the exact steps to fix this authentication issue and ensure successful deployment.

🎯 USE THIS EXACT PROMPT IN THE NEW CHAT THREAD FOR FOCUSED DEPLOYMENT FIXING!