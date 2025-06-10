# MCP Servers Configuration Guide for Windows

This guide provides simple steps to configure various MCP (Model Context Protocol) servers for use with Augment AI.

## 1. Task Manager MCP Server

**Purpose:** Provides comprehensive project and task tracking capabilities with support for project organization, task tracking, and PRD parsing.

**Installation Steps:**
```powershell
# Create directory in C:\
mkdir C:\mcp-servers\task-manager-mcp

# Navigate to the directory
cd C:\mcp-servers\task-manager-mcp

# Clone the repository
git clone https://github.com/tradesdontlie/task-manager-mcp .

# Create .env file with the following content
Set-Content -Path .env -Value "TRANSPORT=stdio`nHOST=`nPORT=8050"

# Install required Python packages
pip install pyyaml mcp
```

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "task-manager": {
      "command": "python",
      "args": ["C:\\mcp-servers\\task-manager-mcp\\src\\main.py"],
      "env": {
        "TRANSPORT": "stdio",
        "PORT": "8050"
      },
      "cwd": "C:\\mcp-servers\\task-manager-mcp"
    }
  }
}
```

**Usage Examples:**
```python
# Create a new project
await mcp.create_task_file(project_name="my-project")

# Add a task with subtasks
await mcp.add_task(
    project_name="my-project",
    title="Setup Development Environment",
    description="Configure the development environment with required tools",
    subtasks=[
        "Install dependencies",
        "Configure linters",
        "Set up testing framework"
    ]
)

# Update task status
await mcp.update_task_status(
    project_name="my-project",
    task_title="Setup Development Environment",
    subtask_title="Install dependencies",
    status="done"
)

# Get the next task to work on
next_task = await mcp.get_next_task(project_name="my-project")

# Parse a PRD to create tasks automatically
await mcp.parse_prd(
    project_name="my-project",
    prd_content="# Your PRD content..."
)
```

**Troubleshooting:**
- If you encounter a "No module named 'yaml'" error, run `pip install pyyaml`
- If you encounter a "No module named 'mcp'" error, run `pip install mcp`
- Make sure to set the correct working directory (`cwd`) in the configuration
- Ensure the PORT environment variable is set to a valid integer (e.g., "8050")

## 2. Fetch MCP Server

**Purpose:** Retrieves web content in various formats (HTML, JSON, plain text, Markdown)

**Installation Steps:**
```powershell
# Create directory in C:\
mkdir C:\fetch-mcp

# Navigate to the directory
cd C:\fetch-mcp

# Clone the repository
git clone https://github.com/zcaceres/fetch-mcp .

# Install shx globally (required for the build process)
npm install -g shx

# Install dependencies
npm install

# Build the server
npm run build
```

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "github.com/zcaceres/fetch-mcp": {
      "command": "node",
      "args": [
        "C:\\fetch-mcp\\dist\\index.js"
      ]
    }
  }
}
```

## 3. Browser Tools MCP Server

**Purpose:** Provides browser interaction capabilities (console logs, screenshots, audits)

**Installation Steps:**
```powershell
# Download and install the Chrome extension
# 1. Download from: https://github.com/AgentDeskAI/browser-tools-mcp/releases/download/v1.2.0/BrowserTools-1.2.0-extension.zip
# 2. Unzip the file
# 3. Open Chrome's "Manage Extensions" page
# 4. Enable "Developer Mode"
# 5. Click "Load unpacked" and select the unzipped extension folder

# Start the Browser Tools server (keep this terminal open while using)
npx @agentdeskai/browser-tools-server@1.2.0
```

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "browser-tools": {
      "command": "npx",
      "args": [
        "@agentdeskai/browser-tools-mcp@1.2.0"
      ]
    }
  }
}
```

## 4. Filesystem MCP Server

**Purpose:** Provides access to the filesystem (read/write files, list directories)

**Installation Steps:**
No installation needed - runs directly via npx

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Users\\VASU\\Desktop",
        "C:\\Users\\VASU\\Documents",
        "C:\\Users\\VASU\\Desktop\\DESKTO~1\\EXAMPR~1",
        "C:\\Projects"
      ]
    }
  }
}

```

## 5. Sequential Thinking MCP Server

**Purpose:** Helps with structured problem-solving and complex reasoning

**Installation Steps:**
No installation needed - runs directly via npx

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    }
  }
}
```

## 6. UIFlowchartCreator MCP Server

**Purpose:** Creates UI flowcharts by analyzing React/Angular repositories to visualize user interfaces and their interactions

**Installation Steps:**
```powershell
# Create directory in C:\
mkdir C:\mcp-servers\uiflowchartcreator

# Navigate to the directory
cd C:\mcp-servers\uiflowchartcreator

# Clone the repository
git clone https://github.com/umshere/uiflowchartcreator .

# Install dependencies
npm install

# Build the server
npm run build
```

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "uiflowchartcreator": {
      "command": "node",
      "args": ["C:\\mcp-servers\\uiflowchartcreator\\build\\index.js"],
      "env": {},
      "protocol": "2024-11-05"
    }
  }
}
```

**Usage Examples:**
```javascript
// Generate a UI flow diagram from a GitHub repository
await mcp.generate_ui_flow({
  isLocal: false,
  owner: "facebook",
  repo: "react",
  fileExtensions: ["js", "jsx", "ts", "tsx"]
});

// Generate a UI flow diagram from a local repository
await mcp.generate_ui_flow({
  isLocal: true,
  repoPath: "C:\\Projects\\my-react-app",
  fileExtensions: ["js", "jsx", "ts", "tsx"]
});
```

**Troubleshooting:**
- Ensure Node.js is installed on your system
- If you encounter dependency issues, run `npm install` in the uiflowchartcreator directory
- Make sure the path to index.js is correct in your configuration
- For local repository analysis, ensure the repository path exists and is accessible

## 7. Qdrant MCP Server

**Purpose:** Provides semantic memory capabilities through Qdrant vector database, allowing storage and retrieval of information based on semantic similarity.

**Installation Steps:**
```powershell
# Create a directory for Qdrant data
mkdir C:\mcp-servers
mkdir C:\mcp-servers\qdrant-data

# Install required Python packages
pip install uvx==1.0.0 mcp-server-qdrant

# Create a Python script to run the Qdrant MCP server
$scriptContent = @"
#!/usr/bin/env python
import os
import sys

# Set environment variables
os.environ["QDRANT_LOCAL_PATH"] = "C:\\mcp-servers\\qdrant-data"
os.environ["COLLECTION_NAME"] = "augment-memories"
os.environ["EMBEDDING_MODEL"] = "sentence-transformers/all-MiniLM-L6-v2"

# Import and run the MCP server directly
from mcp_server_qdrant.server import mcp

# Run the server with stdio transport
mcp.run(transport="stdio")
"@

# Save the script
Set-Content -Path C:\mcp-servers\run_qdrant.py -Value $scriptContent
```

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "qdrant-mcp": {
      "protocol": "2024-11-05",
      "command": "python",
      "args": ["C:\\mcp-servers\\run_qdrant.py"]
    }
  }
}
```

**Usage Examples:**
```python
# Store information in the Qdrant database
await mcp.qdrant_store(
    information="Flutter uses the Dart programming language and provides a rich set of pre-designed widgets.",
    metadata={"category": "mobile_development", "framework": "flutter"}
)

# Store code snippets with metadata
await mcp.qdrant_store(
    information="How to create a basic Flutter app with a Material App and Scaffold",
    metadata={
        "code": """
        import 'package:flutter/material.dart';

        void main() {
          runApp(MyApp());
        }

        class MyApp extends StatelessWidget {
          @override
          Widget build(BuildContext context) {
            return MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: Text('My Flutter App')),
                body: Center(child: Text('Hello, World!')),
              ),
            );
          }
        }
        """
    }
)

# Retrieve information based on semantic search
results = await mcp.qdrant_find(
    query="How do I create a basic Flutter application?"
)

# Find information about Kotlin development
kotlin_info = await mcp.qdrant_find(
    query="What are the main features of Kotlin for Android development?"
)
```

**Troubleshooting:**
- If you encounter "module not found" errors, ensure you've installed all required packages with `pip install uvx==1.0.0 mcp-server-qdrant`
- If you get "storage folder already accessed" errors, ensure no other instances of the Qdrant server are running
- For embedding model errors, check your internet connection as the model needs to be downloaded on first use
- Make sure all paths in the configuration use double backslashes (\\\\)

## 8. Software Planning Tool MCP Server

**Purpose:** Facilitates software development planning through an interactive, structured approach. Helps break down complex software projects into manageable tasks, track implementation progress, and maintain detailed development plans.

**Installation Steps:**
```powershell
# Create directory in C:\
mkdir C:\mcp-servers\software-planning-mcp

# Navigate to the directory
cd C:\mcp-servers\software-planning-mcp

# Clone the repository
git clone https://github.com/NightTrek/Software-planning-mcp .

# Install dependencies and build the project
npm install
```

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "software-planning-tool": {
      "command": "node",
      "args": ["C:\\mcp-servers\\software-planning-mcp\\build\\index.js"],
      "protocol": "2024-11-05"
    }
  }
}
```

**Usage Examples:**
```javascript
// Start a new planning session
await mcp.start_planning({
  goal: "Create a React-based dashboard application"
});

// Add a todo item
const todo = await mcp.add_todo({
  title: "Set up project structure",
  description: "Initialize React project with necessary dependencies",
  complexity: 3,
  codeExample: `
npx create-react-app dashboard
cd dashboard
npm install @material-ui/core @material-ui/icons
  `
});

// Update todo status
await mcp.update_todo_status({
  todoId: todo.id,
  isComplete: true
});

// Get all todos in the current plan
const todos = await mcp.get_todos();

// Remove a todo item
await mcp.remove_todo({
  todoId: todo.id
});

// Save the implementation plan
await mcp.save_plan({
  plan: `
# Dashboard Implementation Plan

## Phase 1: Setup (Complexity: 3)
- Initialize React project
- Install dependencies
- Set up routing

## Phase 2: Core Features (Complexity: 5)
- Implement authentication
- Create dashboard layout
- Add data visualization components
  `
});
```

**Troubleshooting:**
- Ensure Node.js is installed on your system
- If you encounter dependency issues, run `npm install` in the software-planning-mcp directory
- Make sure the path to index.js is correct in your configuration
- If the server fails to start, check the build directory exists and contains index.js
- For any other issues, refer to the [GitHub repository](https://github.com/NightTrek/Software-planning-mcp)

## 9. Context7 MCP Server

**Purpose:** Provides access to up-to-date documentation for various libraries and frameworks, allowing AI to reference accurate and current information.

**Installation Steps:**
```powershell
# No installation needed - runs directly via npx
```

**Augment Settings Configuration:**
```json
{
  "mcpServers": {
    "context7": {
      "protocol": "2024-11-05",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

**Usage Examples:**
```javascript
// Resolve a library name to get the Context7-compatible library ID
const libraryInfo = await mcp.resolve_library_id({
  libraryName: "react"
});

// Fetch documentation for a specific library
const reactDocs = await mcp.get_library_docs({
  context7CompatibleLibraryID: "vercel/react",
  tokens: 5000,
  topic: "hooks"
});

// Get documentation for a specific framework
const nextjsDocs = await mcp.get_library_docs({
  context7CompatibleLibraryID: "vercel/nextjs",
  topic: "routing"
});

// Get Flutter documentation
const flutterDocs = await mcp.get_library_docs({
  context7CompatibleLibraryID: "flutter/flutter",
  topic: "widgets"
});
```

**Troubleshooting:**
- Ensure Node.js is installed on your system
- If you encounter network issues, check your internet connection as the tool fetches documentation from online sources
- For specific libraries, first use the `resolve-library-id` function to get the correct Context7-compatible ID

## Usage

To use any of these MCP servers in your Augment prompts, simply reference them by name:

- **Task Manager MCP:** "Use task-manager to create a new project and add tasks"
- **Fetch MCP:** "Use github.com/zcaceres/fetch-mcp to get content from example.com"
- **Browser Tools:** "Use browser-tools to take a screenshot of the current page"
- **Filesystem:** "Use filesystem to list files in my Documents folder"
- **Sequential Thinking:** "Use sequential-thinking to help me solve this problem step by step"
- **UIFlowchartCreator:** "Use uiflowchartcreator to generate a UI flow diagram for my React app"
- **Qdrant MCP:** "Use qdrant-mcp to store and retrieve information about Flutter and Kotlin development"
- **Software Planning Tool:** "Use software-planning-tool to create a development plan for my project"
- **Context7:** "Use context7 to get up-to-date documentation for React, Flutter, or other libraries"

## Notes

- Configure each MCP server separately in Augment settings to avoid potential errors
- The Task Manager MCP server requires Python to be installed on your system
- For the Task Manager MCP and Qdrant MCP, ensure all paths in the configuration use double backslashes (\\\\)
- The Browser Tools server requires keeping a terminal running with the server process
- Filesystem MCP only has access to directories explicitly specified in the configuration
- The Qdrant MCP server provides semantic memory capabilities, making it ideal for storing and retrieving information for Flutter and Kotlin development
- The Qdrant MCP server stores information in vector embeddings, allowing for semantic similarity searches
- For Flutter and Kotlin development, use the Qdrant MCP server to store code snippets, best practices, and documentation
- The Context7 MCP server provides up-to-date documentation for libraries and frameworks, including Flutter and React
- The Context7 MCP server requires an internet connection to fetch the latest documentation
- The Software Planning Tool MCP server helps organize software development projects by breaking them down into manageable tasks
- Use Context7 and Qdrant MCP servers together for a powerful development experience - Context7 for official documentation and Qdrant for your own code snippets and notes
- All other servers run on-demand when invoked in a prompt