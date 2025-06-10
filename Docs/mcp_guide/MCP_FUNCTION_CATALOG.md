# MCP Function Catalog
**Complete Reference Guide for AI Assistant Context - 7 MCP Servers**

This document provides comprehensive information about all available MCP server functions across your complete ecosystem to enable intelligent routing and zero-hallucination function calls.

**Your Complete MCP Ecosystem:**
- 🗂️ **File System MCP** - File operations and project navigation
- 🔍 **Vector Search MCP** - Semantic search and knowledge storage
- 🧠 **Serena MCP** - Advanced code analysis and development assistance
- 📚 **Context7 MCP** - Library documentation and package information
- 🧠 **Sequential Thinking MCP** - Structured problem-solving and reasoning
- 📋 **Task Master MCP** - Project management and task orchestration
- 🌐 **Tavily MCP** - Real-time web search and content extraction

---

## 🗂️ File System MCP Server (`filesystem`)

**Purpose:** File operations, project navigation, and file management  
**Best for:** Reading files, creating directories, searching for files, managing project structure

### Core Functions:

#### File Reading & Information
- **`read_file_node_exe(path)`** - Read complete file contents
  - **Use when:** Need to examine specific files, analyze code, read configuration
  - **Example:** "Read the package.json file" or "Show me the main.dart file"

- **`read_multiple_files_node_exe(paths)`** - Read multiple files simultaneously  
  - **Use when:** Need to compare or analyze multiple files at once
  - **Example:** "Read all TypeScript files in the components directory"

- **`get_file_info_node_exe(path)`** - Get file metadata (size, dates, permissions)
  - **Use when:** Need file details without reading content
  - **Example:** "Check when this file was last modified"

#### Directory Operations
- **`list_directory_node_exe(path)`** - List directory contents with file/directory indicators
  - **Use when:** Exploring project structure, finding files in directories
  - **Example:** "Show me all files in the src directory"

- **`directory_tree_node_exe(path)`** - Get recursive tree view as JSON structure
  - **Use when:** Need complete project structure overview
  - **Example:** "Show me the entire project structure"

- **`create_directory_node_exe(path)`** - Create directories (supports nested creation)
  - **Use when:** Setting up new directory structures
  - **Example:** "Create a new components/auth directory"

#### File Creation & Editing
- **`write_file_node_exe(path, content)`** - Create new file or overwrite existing
  - **Use when:** Creating new files or completely replacing file content
  - **Example:** "Create a new README.md file"

- **`edit_file_node_exe(path, edits)`** - Make line-based edits with git-style diff
  - **Use when:** Making precise edits to existing files
  - **Example:** "Update the import statement in this file"

#### File Management
- **`move_file_node_exe(source, destination)`** - Move or rename files/directories
  - **Use when:** Reorganizing project structure
  - **Example:** "Move this component to the shared directory"

- **`search_files_node_exe(path, pattern, excludePatterns)`** - Search for files by pattern
  - **Use when:** Finding files by name pattern across directories
  - **Example:** "Find all .tsx files containing 'Button'"

#### Utility
- **`list_allowed_directories_node_exe()`** - Get list of accessible directories
  - **Use when:** Understanding file system access boundaries
  - **Example:** "What directories can I access?"

---

## 🔍 Vector Search MCP Server (`vectorsearch`)

**Purpose:** Semantic search, knowledge retrieval, and information storage  
**Best for:** Finding code patterns, searching documentation, storing project knowledge

### Core Functions:

#### Information Storage
- **`qdrant-store_uvx_exe(information, metadata)`** - Store information with semantic indexing
  - **Use when:** Saving important project information, code patterns, or documentation
  - **Example:** "Store information about the authentication flow"
  - **Parameters:**
    - `information`: Text content to store
    - `metadata`: Optional additional data (JSON object)

#### Information Retrieval  
- **`qdrant-find_uvx_exe(query)`** - Search stored information using semantic similarity
  - **Use when:** Finding relevant code patterns, searching for specific functionality
  - **Example:** "Find information about user authentication" or "Search for API integration patterns"
  - **Returns:** Semantically similar stored information with relevance scores

### Usage Patterns:
- **Code Pattern Discovery:** "Find examples of error handling in the codebase"
- **Documentation Search:** "Search for information about the database schema"
- **Knowledge Retrieval:** "Find stored information about the deployment process"
- **Similar Code Finding:** "Find code similar to this authentication function"

---

## 🧠 Serena MCP Server (`serena`)

**Purpose:** Advanced code analysis, project management, and intelligent development assistance  
**Best for:** Symbol-level code operations, project onboarding, memory management, semantic code understanding

### Project Management
- **`activate_project_uv_exe(project)`** - Activate a project by name or path
  - **Use when:** Starting work on a specific project
  - **Example:** "Activate the nesteryrelease project"

- **`get_current_config_uv_exe()`** - Get current configuration and active modes
  - **Use when:** Understanding current Serena setup and capabilities
  - **Example:** "Show me the current configuration"

- **`switch_modes_uv_exe(modes)`** - Change active modes (editing, planning, interactive, etc.)
  - **Use when:** Switching between different work modes
  - **Example:** "Switch to editing and interactive modes"

### Code Analysis & Navigation
- **`get_symbols_overview_uv_exe(relative_path)`** - Get overview of top-level symbols in files/directories
  - **Use when:** Understanding code structure and available symbols
  - **Example:** "Show me all classes and functions in this directory"

- **`find_symbol_uv_exe(name_path, relative_path, depth, include_body)`** - Find symbols by name pattern
  - **Use when:** Locating specific classes, methods, or variables
  - **Example:** "Find the UserService class" or "Find all methods containing 'auth'"

- **`find_referencing_symbols_uv_exe(name_path, relative_path)`** - Find symbols that reference a given symbol
  - **Use when:** Understanding code dependencies and usage patterns
  - **Example:** "Find all places that use the authenticate method"

### File Operations
- **`read_file_uv_exe(relative_path, start_line, end_line)`** - Read files or specific line ranges
  - **Use when:** Examining code with precise line control
  - **Example:** "Read lines 50-100 of the auth service"

- **`create_text_file_uv_exe(relative_path, content)`** - Create new files
  - **Use when:** Creating new code files
  - **Example:** "Create a new service class file"

- **`list_dir_uv_exe(relative_path, recursive)`** - List directory contents
  - **Use when:** Exploring project structure
  - **Example:** "List all files in the services directory"

### Code Editing
- **`replace_symbol_body_uv_exe(name_path, relative_path, body)`** - Replace entire symbol definition
  - **Use when:** Completely rewriting methods, classes, or functions
  - **Example:** "Replace the entire authenticate method"

- **`insert_after_symbol_uv_exe(name_path, relative_path, body)`** - Insert content after symbol
  - **Use when:** Adding new methods to classes or new functions to modules
  - **Example:** "Add a new method after the constructor"

- **`insert_before_symbol_uv_exe(name_path, relative_path, body)`** - Insert content before symbol
  - **Use when:** Adding imports, comments, or new symbols before existing ones
  - **Example:** "Add an import statement before the class definition"

- **`replace_regex_uv_exe(relative_path, regex, repl)`** - Replace content using regex patterns
  - **Use when:** Making pattern-based replacements across code
  - **Example:** "Replace all occurrences of old API calls with new ones"

- **`insert_at_line_uv_exe(relative_path, line, content)`** - Insert content at specific line
  - **Use when:** Adding content at precise locations
  - **Example:** "Add a comment at line 25"

- **`replace_lines_uv_exe(relative_path, start_line, end_line, content)`** - Replace line ranges
  - **Use when:** Replacing specific sections of code
  - **Example:** "Replace lines 10-15 with new implementation"

- **`delete_lines_uv_exe(relative_path, start_line, end_line)`** - Delete line ranges
  - **Use when:** Removing specific code sections
  - **Example:** "Delete the deprecated method on lines 50-75"

### Memory Management
- **`write_memory_uv_exe(memory_name, content)`** - Create project-specific memories
  - **Use when:** Storing important project information for future reference
  - **Example:** "Create a memory about the authentication system architecture"

- **`read_memory_uv_exe(memory_file_name)`** - Read stored memories
  - **Use when:** Retrieving previously stored project information
  - **Example:** "Read the memory about database schema"

- **`list_memories_uv_exe()`** - List all available memories
  - **Use when:** Seeing what information has been stored
  - **Example:** "Show me all stored memories for this project"

- **`delete_memory_uv_exe(memory_file_name)`** - Delete specific memories
  - **Use when:** Removing outdated or incorrect information
  - **Example:** "Delete the outdated API documentation memory"

### Project Onboarding
- **`check_onboarding_performed_uv_exe()`** - Check if project onboarding is complete
  - **Use when:** Starting work on a project to understand its state
  - **Example:** "Has this project been onboarded?"

- **`onboarding_uv_exe()`** - Perform project onboarding process
  - **Use when:** First-time project setup and analysis
  - **Example:** "Perform onboarding for this new project"

### Search & Pattern Matching
- **`search_for_pattern_uv_exe(pattern, only_in_code_files, context_lines_before, context_lines_after)`** - Search for patterns in project
  - **Use when:** Finding specific code patterns, text, or implementations
  - **Example:** "Search for all TODO comments in the codebase"

- **`find_file_uv_exe(file_mask, relative_path)`** - Find files by name pattern
  - **Use when:** Locating files by name or pattern
  - **Example:** "Find all test files containing 'auth'"

### Shell Operations
- **`execute_shell_command_uv_exe(command, cwd)`** - Execute shell commands
  - **Use when:** Running tests, builds, or other command-line operations
  - **Example:** "Run the test suite" or "Build the project"

### Thinking & Reflection Tools
- **`think_about_collected_information_uv_exe()`** - Reflect on gathered information
  - **Use when:** Ensuring sufficient context before making changes
  - **Example:** "Do I have enough information to proceed?"

- **`think_about_task_adherence_uv_exe()`** - Check if still on track with the task
  - **Use when:** Ensuring work aligns with original goals
  - **Example:** "Am I still working on the right task?"

- **`think_about_whether_you_are_done_uv_exe()`** - Determine if task is complete
  - **Use when:** Checking if all requirements have been met
  - **Example:** "Have I completed all the requested changes?"

### Utility Functions
- **`restart_language_server_uv_exe()`** - Restart the language server
  - **Use when:** Language server becomes unresponsive or outdated
  - **Example:** "Restart the language server to refresh symbol information"

- **`summarize_changes_uv_exe()`** - Summarize changes made to codebase
  - **Use when:** Providing overview of completed work
  - **Example:** "Summarize all the changes I made"

- **`prepare_for_new_conversation_uv_exe()`** - Prepare context for new conversation
  - **Use when:** Continuing work in a new chat session
  - **Example:** "Prepare context for continuing this work later"

- **`initial_instructions_uv_exe()`** - Get initial project instructions
  - **Use when:** Starting work on a project
  - **Example:** "What are the initial instructions for this project?"

---

## 📚 Context7 MCP Server (`context7`)

**Purpose:** Library documentation retrieval and package information lookup
**Best for:** Getting up-to-date documentation, resolving library IDs, accessing package information

### Core Functions:

#### Library Resolution
- **`resolve-library-id_context7(libraryName)`** - Resolve package name to Context7-compatible library ID
  - **Use when:** Need to find the correct library ID before getting documentation
  - **Example:** "Find the library ID for React" or "Resolve the Next.js library identifier"
  - **Returns:** Context7-compatible library ID and selection rationale
  - **Required:** Must call this before `get-library-docs` unless user provides explicit library ID

#### Documentation Retrieval
- **`get-library-docs_context7(context7CompatibleLibraryID, tokens, topic)`** - Fetch up-to-date library documentation
  - **Use when:** Need current documentation for specific libraries or frameworks
  - **Example:** "Get React hooks documentation" or "Show me Next.js routing docs"
  - **Parameters:**
    - `context7CompatibleLibraryID`: Exact ID from resolve-library-id (required)
    - `tokens`: Max tokens to retrieve (default: 10000)
    - `topic`: Focus area like 'hooks', 'routing', 'authentication'

### Usage Patterns:
- **Library Research:** "Get documentation for the latest version of TypeScript"
- **API Reference:** "Show me the authentication methods for Firebase"
- **Framework Guidance:** "Get Next.js documentation about API routes"
- **Package Comparison:** "Compare documentation between React and Vue"

---

## 🧠 Sequential Thinking MCP Server (`sequential-thinking`)

**Purpose:** Structured problem-solving and complex reasoning through step-by-step thought processes
**Best for:** Breaking down complex problems, planning solutions, reflective analysis

### Core Functions:

#### Structured Thinking Process
- **`sequentialthinking_sequential-thinking(thought, nextThoughtNeeded, thoughtNumber, totalThoughts, ...)`** - Dynamic problem-solving through thoughts
  - **Use when:** Need to break down complex problems, plan solutions, or analyze situations step-by-step
  - **Example:** "Plan the architecture for a new feature" or "Analyze the root cause of this bug"
  - **Key Parameters:**
    - `thought`: Current thinking step or analysis
    - `nextThoughtNeeded`: Whether more thinking is required
    - `thoughtNumber`: Current step number in the sequence
    - `totalThoughts`: Estimated total steps needed (adjustable)
    - `isRevision`: Whether this thought revises previous thinking
    - `revisesThought`: Which previous thought is being reconsidered
    - `branchFromThought`: Branching point for alternative approaches
    - `needsMoreThoughts`: If more analysis is needed beyond initial estimate

### Advanced Features:
- **Adaptive Planning:** Can adjust total thoughts up or down as understanding deepens
- **Revision Capability:** Can question or revise previous thoughts
- **Branching Logic:** Can explore alternative approaches
- **Uncertainty Handling:** Can express and work through uncertainty
- **Solution Verification:** Generates and verifies solution hypotheses

### Usage Patterns:
- **Complex Problem Solving:** "Analyze why the authentication system is failing"
- **Architecture Planning:** "Design the database schema for the new feature"
- **Debugging Analysis:** "Trace through the error to find the root cause"
- **Feature Planning:** "Plan the implementation approach for user notifications"
- **Code Review:** "Analyze the potential issues with this implementation"

---

## 📋 Task Master MCP Server (`taskmaster-ai`)

**Purpose:** AI-driven project management, task planning, and development workflow orchestration
**Best for:** Project planning, task breakdown, dependency management, progress tracking

### Project Initialization & Configuration
- **`initialize_project_taskmaster-ai(projectRoot, addAliases, skipInstall, yes)`** - Initialize Task Master in project
  - **Use when:** Setting up Task Master for a new project
  - **Example:** "Initialize Task Master for this project"
  - **Parameters:** `projectRoot` (required), `addAliases`, `skipInstall`, `yes`

- **`models_taskmaster-ai(projectRoot, setMain, setResearch, setFallback, listAvailableModels)`** - Configure AI models
  - **Use when:** Setting up or changing AI models for task generation
  - **Example:** "Configure the main model for task generation"

### PRD & Task Generation
- **`parse_prd_taskmaster-ai(projectRoot, input, numTasks, output, research, append, force)`** - Generate tasks from PRD
  - **Use when:** Converting project requirements into structured tasks
  - **Example:** "Generate 15 tasks from the PRD file with research mode"
  - **Key Parameters:**
    - `projectRoot`: Absolute project path (required)
    - `input`: Path to PRD file (default: scripts/prd.txt)
    - `numTasks`: Number of top-level tasks to generate
    - `research`: Use research model for comprehensive task details

### Task Management & Retrieval
- **`get_tasks_taskmaster-ai(projectRoot, status, withSubtasks, file, complexityReport)`** - Get all tasks with filtering
  - **Use when:** Viewing project tasks and current status
  - **Example:** "Show me all pending tasks with their subtasks"

- **`get_task_taskmaster-ai(id, projectRoot, file, status, complexityReport)`** - Get specific task details
  - **Use when:** Examining a particular task and its subtasks
  - **Example:** "Show me details for task 5"

- **`next_task_taskmaster-ai(projectRoot, file, complexityReport)`** - Find next available task
  - **Use when:** Determining what to work on next based on dependencies
  - **Example:** "What task should I work on next?"

### Task Status Management
- **`set_task_status_taskmaster-ai(id, status, projectRoot, file, complexityReport)`** - Update task/subtask status
  - **Use when:** Marking tasks as in-progress, done, or other statuses
  - **Example:** "Mark task 3.2 as completed"
  - **Statuses:** pending, done, in-progress, review, deferred, cancelled

### Task Creation & Modification
- **`add_task_taskmaster-ai(projectRoot, prompt, title, description, details, priority, dependencies, research)`** - Add new tasks
  - **Use when:** Adding tasks not covered in original PRD
  - **Example:** "Add a task for implementing user authentication"

- **`update_task_taskmaster-ai(id, prompt, projectRoot, file, research)`** - Update single task
  - **Use when:** Modifying specific task based on new requirements
  - **Example:** "Update task 5 with new client requirements"

- **`update_taskmaster-ai(from, prompt, projectRoot, file, research)`** - Update multiple tasks from ID
  - **Use when:** Applying changes to multiple upcoming tasks
  - **Example:** "Update all tasks from task 10 onwards with new architecture"

### Subtask Management
- **`add_subtask_taskmaster-ai(id, projectRoot, title, description, details, status, dependencies)`** - Add subtasks
  - **Use when:** Breaking down complex tasks into smaller pieces
  - **Example:** "Add subtasks to task 7 for detailed implementation"

- **`update_subtask_taskmaster-ai(id, prompt, projectRoot, file, research)`** - Update specific subtask
  - **Use when:** Adding information to subtasks without replacing content
  - **Example:** "Update subtask 5.3 with implementation notes"

### Task Expansion & Analysis
- **`expand_task_taskmaster-ai(id, projectRoot, num, prompt, research, force, file)`** - Expand task into subtasks
  - **Use when:** Breaking down complex tasks for detailed implementation
  - **Example:** "Expand task 8 into 6 subtasks with research mode"

- **`expand_all_taskmaster-ai(projectRoot, num, prompt, research, force, file)`** - Expand all pending tasks
  - **Use when:** Creating detailed subtasks for all remaining work
  - **Example:** "Expand all pending tasks based on complexity analysis"

- **`analyze_project_complexity_taskmaster-ai(projectRoot, file, output, threshold, research, from, to, ids)`** - Analyze task complexity
  - **Use when:** Understanding which tasks need expansion or more detail
  - **Example:** "Analyze complexity of all tasks and recommend expansions"

### Dependency Management
- **`add_dependency_taskmaster-ai(id, dependsOn, projectRoot, file)`** - Add task dependencies
  - **Use when:** Establishing task order and prerequisites
  - **Example:** "Make task 5 depend on task 3"

- **`remove_dependency_taskmaster-ai(id, dependsOn, projectRoot, file)`** - Remove dependencies
  - **Use when:** Removing unnecessary task dependencies
  - **Example:** "Remove dependency between task 7 and task 4"

- **`validate_dependencies_taskmaster-ai(projectRoot, file)`** - Check dependency issues
  - **Use when:** Ensuring dependency chain is valid
  - **Example:** "Check for circular dependencies or invalid links"

- **`fix_dependencies_taskmaster-ai(projectRoot, file)`** - Fix dependency problems
  - **Use when:** Automatically resolving dependency issues
  - **Example:** "Fix any broken dependencies in the task chain"

### Task Organization
- **`move_task_taskmaster-ai(from, to, projectRoot, file)`** - Move tasks to new positions
  - **Use when:** Reorganizing task order or structure
  - **Example:** "Move task 8 to position 5"

- **`remove_task_taskmaster-ai(id, projectRoot, confirm, file)`** - Remove tasks permanently
  - **Use when:** Deleting unnecessary or obsolete tasks
  - **Example:** "Remove task 12 as it's no longer needed"

### Subtask Operations
- **`remove_subtask_taskmaster-ai(id, projectRoot, convert, skipGenerate, file)`** - Remove or convert subtasks
  - **Use when:** Cleaning up subtask structure
  - **Example:** "Remove subtask 5.4 or convert it to standalone task"

- **`clear_subtasks_taskmaster-ai(projectRoot, id, all, file)`** - Clear subtasks from tasks
  - **Use when:** Resetting task structure for re-expansion
  - **Example:** "Clear all subtasks from task 6"

### Reporting & File Generation
- **`generate_taskmaster-ai(projectRoot, file, output)`** - Generate individual task files
  - **Use when:** Creating separate markdown files for each task
  - **Example:** "Generate individual task files in the tasks directory"

- **`complexity_report_taskmaster-ai(projectRoot, file)`** - Display complexity analysis
  - **Use when:** Viewing detailed complexity analysis results
  - **Example:** "Show the complexity analysis report"

### Usage Patterns:
- **Project Setup:** Initialize → Create PRD → Parse PRD → Analyze Complexity
- **Daily Workflow:** Check next task → Update status → Add subtasks as needed
- **Progress Tracking:** Get tasks overview → Update completed work → Validate dependencies
- **Project Evolution:** Add new tasks → Update existing tasks → Expand complex tasks

---

## 🌐 Tavily MCP Server (`tavily-mcp`)

**Purpose:** Real-time web search and content extraction for current information
**Best for:** Research, fact-checking, getting current information, web content analysis

### Core Functions:

#### Web Search
- **`tavily-search_tavily-mcp(query, max_results, search_depth, topic, time_range, days, include_domains, exclude_domains, include_images, include_image_descriptions, include_raw_content)`** - Comprehensive web search
  - **Use when:** Need current information, research, or real-time data
  - **Example:** "Search for latest React 18 features" or "Find current best practices for authentication"
  - **Key Parameters:**
    - `query`: Search query (required)
    - `max_results`: Number of results (5-20, default: 10)
    - `search_depth`: "basic" or "advanced"
    - `topic`: "general" or "news"
    - `time_range`: "day", "week", "month", "year"
    - `include_domains`: Specific sites to search
    - `exclude_domains`: Sites to avoid
    - `include_raw_content`: Get cleaned HTML content

#### Content Extraction
- **`tavily-extract_tavily-mcp(urls, extract_depth, include_images)`** - Extract content from specific URLs
  - **Use when:** Need to analyze specific web pages or documentation
  - **Example:** "Extract content from this GitHub README" or "Get details from this API documentation"
  - **Parameters:**
    - `urls`: List of URLs to extract from (required)
    - `extract_depth`: "basic" or "advanced" (use advanced for LinkedIn/complex sites)
    - `include_images`: Include images from the pages

### Usage Patterns:
- **Technology Research:** "Search for latest TypeScript 5.0 features and changes"
- **Best Practices:** "Find current security best practices for Node.js applications"
- **Documentation Lookup:** "Search for official documentation on React Server Components"
- **Competitive Analysis:** "Research how other companies implement user authentication"
- **Troubleshooting:** "Search for solutions to this specific error message"
- **Market Research:** "Find current trends in mobile app development"

---

## 🎯 Intelligent Routing Guidelines

### For File Operations:
- **Simple file reading/writing** → Use `filesystem` MCP
- **Complex code analysis** → Use `serena` MCP
- **Semantic search** → Use `vectorsearch` MCP

### For Code Analysis:
- **Symbol-level operations** → Use `serena` MCP
- **Pattern searching** → Use `serena` MCP for code, `vectorsearch` for semantic similarity
- **Project structure** → Use `filesystem` for basic listing, `serena` for symbol overview

### For Information Management:
- **Storing knowledge** → Use `vectorsearch` MCP for semantic storage, `serena` for project memories
- **Retrieving information** → Use `vectorsearch` for semantic search, `serena` for project-specific memories
- **Current web information** → Use `tavily-mcp` for real-time research and facts

### For Project Management:
- **Project setup** → Use `serena` MCP for code projects, `taskmaster-ai` for task planning
- **File organization** → Use `filesystem` MCP
- **Code refactoring** → Use `serena` MCP
- **Task planning & tracking** → Use `taskmaster-ai` MCP

### For Documentation & Research:
- **Library documentation** → Use `context7` MCP for package docs
- **Web research** → Use `tavily-mcp` for current information
- **Content extraction** → Use `tavily-mcp` for specific URL analysis

### For Problem Solving:
- **Complex analysis** → Use `sequential-thinking` MCP for structured reasoning
- **Step-by-step planning** → Use `sequential-thinking` MCP for breaking down problems
- **Architecture decisions** → Use `sequential-thinking` MCP for thorough analysis

---

## 📝 Usage Examples

### Example 1: "Find authentication code"
1. **Use `vectorsearch`**: `qdrant-find_uvx_exe("authentication code patterns")`
2. **Use `serena`**: `find_symbol_uv_exe("auth", null, 1, true)`
3. **Use `serena`**: `search_for_pattern_uv_exe("authenticate|login|auth", true)`

### Example 2: "Create a new component"
1. **Use `filesystem`**: `create_directory_node_exe("src/components/NewComponent")`
2. **Use `serena`**: `create_text_file_uv_exe("src/components/NewComponent/index.tsx", content)`
3. **Use `serena`**: `write_memory_uv_exe("new_component_info", "Created NewComponent with...")`

### Example 3: "Analyze project structure"
1. **Use `serena`**: `get_symbols_overview_uv_exe("src")`
2. **Use `filesystem`**: `directory_tree_node_exe(".")`
3. **Use `serena`**: `list_memories_uv_exe()` to check existing project knowledge

### Example 4: "Research and implement a new feature"
1. **Use `tavily-mcp`**: `tavily-search_tavily-mcp("React Server Components best practices", 10, "advanced")`
2. **Use `context7`**: `resolve-library-id_context7("React")` then `get-library-docs_context7(libraryId, 15000, "server-components")`
3. **Use `sequential-thinking`**: Plan the implementation approach step-by-step
4. **Use `taskmaster-ai`**: `add_task_taskmaster-ai(projectRoot, "Implement React Server Components", research=true)`

### Example 5: "Plan a complex feature implementation"
1. **Use `sequential-thinking`**: Break down the feature requirements and architecture decisions
2. **Use `taskmaster-ai`**: `add_task_taskmaster-ai(projectRoot, "User notification system", research=true)`
3. **Use `taskmaster-ai`**: `expand_task_taskmaster-ai(taskId, projectRoot, research=true)`
4. **Use `serena`**: `write_memory_uv_exe("notification_architecture", "Planned approach for notifications...")`

### Example 6: "Debug a complex issue"
1. **Use `sequential-thinking`**: Analyze the problem step-by-step with structured reasoning
2. **Use `serena`**: `search_for_pattern_uv_exe("error_pattern", true)` to find related code
3. **Use `vectorsearch`**: `qdrant-find_uvx_exe("similar error handling patterns")`
4. **Use `tavily-mcp`**: `tavily-search_tavily-mcp("specific error message solution", 5, "advanced")`

### Example 7: "Set up a new project with comprehensive planning"
1. **Use `taskmaster-ai`**: `initialize_project_taskmaster-ai(projectRoot, yes=true)`
2. **Use `taskmaster-ai`**: `parse_prd_taskmaster-ai(projectRoot, "scripts/prd.txt", numTasks=15, research=true)`
3. **Use `taskmaster-ai`**: `analyze_project_complexity_taskmaster-ai(projectRoot, research=true)`
4. **Use `serena`**: `onboarding_uv_exe()` for code analysis and memory creation

---

## 🚀 Complete MCP Ecosystem Overview

### **Your Seven MCP Servers:**
1. **`filesystem`** - File operations and project navigation
2. **`vectorsearch`** - Semantic search and knowledge storage
3. **`serena`** - Advanced code analysis and development assistance
4. **`context7`** - Library documentation and package information
5. **`sequential-thinking`** - Structured problem-solving and reasoning
6. **`taskmaster-ai`** - Project management and task orchestration
7. **`tavily-mcp`** - Real-time web search and content extraction

### **Workflow Integration Patterns:**

#### **Research → Plan → Implement → Track:**
1. **Research**: `tavily-mcp` + `context7` for current information and documentation
2. **Plan**: `sequential-thinking` + `taskmaster-ai` for structured planning and task breakdown
3. **Implement**: `serena` + `filesystem` + `vectorsearch` for development and knowledge management
4. **Track**: `taskmaster-ai` for progress monitoring and task status updates

#### **Problem-Solving Workflow:**
1. **Analyze**: `sequential-thinking` for structured problem breakdown
2. **Research**: `tavily-mcp` for current solutions and `vectorsearch` for similar patterns
3. **Document**: `context7` for official documentation and `serena` for project memories
4. **Execute**: `serena` + `filesystem` for implementation
5. **Manage**: `taskmaster-ai` for tracking progress and dependencies

### **Best Practices for Multi-MCP Usage:**
- **Start with research** (`tavily-mcp`, `context7`) before implementation
- **Use structured thinking** (`sequential-thinking`) for complex decisions
- **Plan systematically** (`taskmaster-ai`) before coding
- **Implement intelligently** (`serena`, `filesystem`) with proper analysis
- **Store knowledge** (`vectorsearch`, `serena` memories) for future reference
- **Track progress** (`taskmaster-ai`) throughout the development cycle

---

**Remember:** Always choose the MCP server that best matches the task requirements. Use this catalog to make informed decisions and avoid function hallucination! With seven specialized MCP servers, you have comprehensive coverage for research, planning, implementation, and management of any development project.
