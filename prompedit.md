Ok, we are continuing the task 4 from the @Genspark_Research_Input.md file. I want you to read the file and all of the sections that relate to the task 4 and its subtasks. We will be focusing on the task 4.3 and 4.4 for this chat thread. Please read the @NSI_3.0_PERFECT_FUSION.md file anD then follow it to complete the tasks 4.3 and 4.4. Alos, in a different chat hread you decided upon a blueprint for the task 4. Please read that file and use it to complete the tasks 4.3 and 4.4. If you need to do research about naything that you not sure about then please use Tavily mcp for completing the tasks. If you need help regading how to use the configured MCP servers for your help then please refer to the @MCP_FUNCTION_CATALOG.md file. 



I need to fix a PostgreSQL database connection issue in my NestJS backend. Here's the current status:

## CURRENT SITUATION
- NestJS backend is 95% working and compiling successfully
- PostgreSQL container is running with user `nestery_user` and database `nestery_dev`
- Redis connection is working perfectly
- All NestJS modules are loading correctly
- Authentication implementation is complete and ready for testing

## THE PROBLEM
The backend cannot connect to PostgreSQL due to password authentication failure:
error: password authentication failed for user "nestery_user"


## WHAT'S BEEN TRIED
1. PostgreSQL container is running via Docker Compose
2. User `nestery_user` exists with superuser privileges
3. Password has been set to `nestery_password` using: `ALTER USER nestery_user PASSWORD 'nestery_password';`
4. Environment variables in `.env` file are set correctly
5. Backend retries connection but fails after 9 attempts

## PROJECT STRUCTURE
- Backend: `C:\Users\VASU\Desktop\nesteryrelease\nestery-backend`
- Docker Compose running PostgreSQL on port 5432
- Environment file: `nestery-backend/.env`
- Database config uses environment variables from `.env`

## CURRENT DOCKER STATUS
- Container `nestery-postgres` is running
- Can connect to PostgreSQL from inside container successfully
- Issue is external connection from host machine to container

## IMMEDIATE GOAL
Fix the PostgreSQL authentication so the NestJS backend can connect to the database, then test the authentication endpoints:
- `POST /v1/auth/register`
- `POST /v1/auth/login`

## ENVIRONMENT DETAILS
- Windows PowerShell
- Docker Desktop running
- NestJS backend on Node.js
- PostgreSQL 14 in Docker container

Please help me resolve this database connection issue and get the authentication system fully operational.