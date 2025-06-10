# MCP CONFIGURATION MASTER GUIDE
## Complete Setup Guide for File System, Vector Search (Qdrant), and Serena MCP Servers on Windows

### 🎯 PURPOSE
This file provides step-by-step instructions for configuring three essential MCP servers with Augment Code on any Windows system. When provided as context to an AI assistant, it enables perfect MCP setup and usage.

### 📋 PREREQUISITES CHECK & INSTALLATION SEQUENCE

#### STEP 1: System Requirements Verification
**AI TASK**: Check if the following are installed, install if missing:

1. **Node.js (v18+)**
   - Check: `node --version` and `npm --version`
   - Install: Download from nodejs.org if missing
   - Verify: Both commands should return version numbers

2. **Git**
   - Check: `git --version`
   - Install: Download from git-scm.com if missing
   - Verify: Should return Git version

3. **Python (v3.11+)**
   - Check: `python --version`
   - Install: Download from python.org if missing
   - Verify: Should return Python version

4. **UV Package Manager**
   - Check: `uv --version`
   - Install: `pip install uv` if missing
   - Verify: Should return UV version

5. **UVX Package Manager**
   - Check: `uvx --version`
   - Install: `pip install uvx` if missing
   - Verify: Should return UVX version

#### STEP 2: Docker Installation for Qdrant
**AI TASK**: Install Docker Desktop for Windows
- Check: `docker --version`
- Install: Download Docker Desktop from docker.com if missing
- Verify: Docker should be running

#### STEP 3: Qdrant Vector Database Setup
**AI TASK**: Start local Qdrant instance
```bash
# Pull Qdrant image
docker pull qdrant/qdrant

# Start Qdrant server
docker run -p 6333:6333 -p 6334:6334 qdrant/qdrant
```
- Verify: http://localhost:6333 should show Qdrant info
- Keep this terminal running throughout development

#### STEP 4: Serena MCP Server Setup
**AI TASK**: Clone and prepare Serena
```bash
# Clone Serena repository
git clone https://github.com/oraios/serena
cd serena

# Test Serena installation
uv run serena-mcp-server --help
```
- Verify: Should show Serena help options
- Note: Keep the serena directory path for configuration

### 🔧 MCP SERVERS CONFIGURATION

#### STEP 5: Get System Paths
**AI TASK**: Execute these commands to get exact paths:
```powershell
# Get Node.js paths
Get-Command node | Select-Object -ExpandProperty Source
Get-Command npm | Select-Object -ExpandProperty Source

# Get UV path
Get-Command uv | Select-Object -ExpandProperty Source

# Get UVX path  
Get-Command uvx | Select-Object -ExpandProperty Source

# Get current user path
echo $env:USERPROFILE

# Get current project path
Get-Location
```

#### STEP 6: Create Augment Code Settings Configuration
**AI TASK**: Create the following settings.json configuration using the paths from Step 5:

```json
{
    "workbench.editor.empty.hint": "hidden",
    "github.copilot.enable": {
        "*": false
    },
    "augment.chat.userGuidelines": "**Always use commands for windows powershell when working in the terminal for any command**\n\n**Use web search for package information mentioned in a task and make sure they are compatible with our project. Use Tavily MCP as of June 2, 2025 to be absolutely sure about everything. There must be no build failure on things like these after your comprehensive web research about the task that you are given in any chat thread. You will use comprehensive web searches for absolute surety on things you are not 100% confident about. Do not depend on you AI training data for doing things. Always find things using tavily MCP server that are as of 3rd June, 2025 and also things which will be perefct from a future perspective. You can use context 7 mcp as well in synchronisation with the web searches and then cross verify that information before implementing to be 1000% sure.**",
    "editor.inlineSuggest.syntaxHighlightingEnabled": true,
    "redhat.telemetry.enabled": true,
    "augment.advanced": {
        "mcpServers": [
            {
                "name": "filesystem",
                "command": "[NODE_EXE_PATH]",
                "args": ["[NPX_CLI_PATH]", "-y", "@modelcontextprotocol/server-filesystem", "[PROJECT_PATH]"]
            },
            {
                "name": "vectorsearch",
                "command": "[UVX_EXE_PATH]",
                "args": ["mcp-server-qdrant"],
                "env": {
                    "QDRANT_URL": "http://localhost:6333",
                    "COLLECTION_NAME": "[PROJECT_NAME]-collection",
                    "EMBEDDING_MODEL": "sentence-transformers/all-MiniLM-L6-v2",
                    "PATH": "[SYSTEM_PATH_WITH_GIT_NODE_UV]"
                }
            },
            {
                "name": "serena",
                "command": "[UV_EXE_PATH]",
                "args": ["run", "--directory", "[SERENA_DIRECTORY_PATH]", "serena-mcp-server"],
                "env": {
                    "PATH": "[SYSTEM_PATH_WITH_GIT_NODE_UV]"
                }
            }
        ]
    }
}
```

**PLACEHOLDER REPLACEMENTS**:
- `[NODE_EXE_PATH]`: Full path to node.exe (e.g., "C:/Program Files/nodejs/node.exe")
- `[NPX_CLI_PATH]`: Full path to npx-cli.js (e.g., "C:/Program Files/nodejs/node_modules/npm/bin/npx-cli.js")
- `[PROJECT_PATH]`: Current project directory path
- `[UVX_EXE_PATH]`: Full path to uvx.exe
- `[UV_EXE_PATH]`: Full path to uv.exe  
- `[PROJECT_NAME]`: Name of the current project
- `[SERENA_DIRECTORY_PATH]`: Full path to cloned serena directory
- `[SYSTEM_PATH_WITH_GIT_NODE_UV]`: Combined PATH with Git, Node.js, and UV directories

#### STEP 7: Apply Configuration
**AI TASK**: 
1. Open VS Code user settings.json (Ctrl+Shift+P → "Open Settings (JSON)")
2. Replace entire content with the configuration from Step 6
3. Save the file
4. Restart VS Code
5. Verify no error notifications appear

### 🧪 MCP SERVERS TESTING & USAGE

#### STEP 8: Test File System MCP
**AI TASK**: Execute these tests:
```
Test 1: "List all files in my project directory"
Test 2: "Show me the package.json file contents"
Test 3: "Find all TypeScript files in the project"
```
Expected: Should successfully access and display project files

#### STEP 9: Test Vector Search MCP  
**AI TASK**: Execute these operations:
```
# Index sample content
Test 1: Store project information in vector database
Test 2: "Search for authentication-related functions"
Test 3: "Find similar code patterns to user management"
```
Expected: Should store and retrieve semantic information

#### STEP 10: Test Serena MCP
**AI TASK**: Execute these operations:
```
Test 1: "Activate the current project in Serena"
Test 2: "Show me the project structure using Serena"
Test 3: "Find all authentication-related symbols"
Test 4: "Create a memory about the project architecture"
```
Expected: Should provide symbolic code analysis and memory creation

### 📚 MCP COMMANDS REFERENCE

#### File System MCP Commands
- `list_directory_node_exe(path)` - List directory contents
- `read_file_node_exe(path)` - Read file contents
- `search_files_node_exe(path, pattern)` - Search for files
- `create_directory_node_exe(path)` - Create directories
- `write_file_node_exe(path, content)` - Write files

#### Vector Search MCP Commands  
- `qdrant-store_uvx_exe(information, metadata)` - Store information
- `qdrant-find_uvx_exe(query)` - Search stored information
- Collection management via Qdrant REST API at http://localhost:6333

#### Serena MCP Commands
- `activate_project_uv_exe(project)` - Activate project
- `get_symbols_overview_uv_exe(relative_path)` - Get code overview
- `find_symbol_uv_exe(name_path, include_body)` - Find symbols
- `find_referencing_symbols_uv_exe(name_path, relative_path)` - Find references
- `write_memory_uv_exe(memory_name, content)` - Create memories
- `read_memory_uv_exe(memory_file_name)` - Read memories
- `list_memories_uv_exe()` - List all memories

### 🎯 SUCCESS CRITERIA
**AI VERIFICATION CHECKLIST**:
- [ ] All three MCP servers start without errors
- [ ] File System MCP can access project files
- [ ] Vector Search MCP can store and retrieve information
- [ ] Serena MCP can analyze code and create memories
- [ ] Qdrant dashboard accessible at http://localhost:6333
- [ ] Serena dashboard accessible (auto-opens in browser)

### 🚨 TROUBLESHOOTING GUIDE
**Common Issues & Solutions**:
1. **spawn EINVAL**: Use full absolute paths, avoid spaces in paths
2. **Git executable not found**: Add Git to PATH environment variable
3. **Qdrant connection failed**: Ensure Docker is running and Qdrant container is active
4. **Serena startup failed**: Verify UV installation and serena directory exists

### 📝 USAGE INSTRUCTIONS FOR AI
When this file is provided as context:
1. Follow steps 1-10 in exact sequence
2. Use web search to verify latest installation methods
3. Replace all placeholders with actual system paths
4. Test each MCP server before proceeding to next
5. Create comprehensive project memories using Serena
6. Provide user with final working configuration

### 🔥 ADVANCED USAGE PATTERNS

#### Project Memory Creation Strategy
**AI TASK**: After successful setup, create these essential memories:
```
Memory 1: "authentication_system_overview" - Document auth patterns
Memory 2: "project_architecture" - Overall structure and modules
Memory 3: "business_domain_model" - Core business logic and entities
Memory 4: "development_guidelines" - Coding standards and practices
Memory 5: "technology_stack_deployment" - Tech stack and infrastructure
```

#### Vector Search Indexing Strategy
**AI TASK**: Index codebase systematically:
```
1. Index authentication modules first
2. Index core business logic
3. Index API endpoints and controllers
4. Index database models and entities
5. Index configuration and utility files
```

#### File System Operations Workflow
**AI TASK**: Use for development tasks:
```
1. Project exploration: List directories and files
2. Code analysis: Read and analyze source files
3. File creation: Generate new components following patterns
4. Batch operations: Search and modify multiple files
5. Documentation: Generate and update project docs
```

### 🎯 INTEGRATION WORKFLOW

#### Daily Development Routine
1. **Start Session**: Activate project in Serena
2. **Context Loading**: Read relevant memories for current task
3. **Code Exploration**: Use File System MCP to navigate
4. **Pattern Analysis**: Use Vector Search for similar implementations
5. **Implementation**: Use Serena for intelligent code generation
6. **Knowledge Update**: Update memories with new patterns

#### Feature Development Process
1. **Requirements Analysis**: Use memories to understand existing patterns
2. **Architecture Planning**: Leverage Serena's symbolic understanding
3. **Implementation**: Use all three MCPs for comprehensive development
4. **Testing**: Use File System MCP for test file management
5. **Documentation**: Update project memories and documentation

### 🛠️ MAINTENANCE & UPDATES

#### Regular Maintenance Tasks
- **Weekly**: Update project memories with new patterns
- **Monthly**: Rebuild vector search index for better performance
- **As needed**: Update MCP server configurations for new features

#### Version Updates
- Monitor MCP server repositories for updates
- Test new versions in isolated environment first
- Update configuration placeholders as needed

### 📊 PERFORMANCE OPTIMIZATION

#### Qdrant Optimization
- Use appropriate embedding models for your domain
- Configure collection parameters for optimal performance
- Regular index maintenance and cleanup

#### Serena Optimization
- Keep memories focused and well-organized
- Regular cleanup of outdated memories
- Use appropriate context modes for different tasks

#### File System Optimization
- Use specific paths to reduce search scope
- Implement file filtering for large projects
- Cache frequently accessed file information

### 🔒 SECURITY CONSIDERATIONS

#### Environment Security
- Keep Qdrant instance local for sensitive projects
- Use environment variables for sensitive configuration
- Regular backup of Serena memories and Qdrant collections

#### Access Control
- Limit MCP server access to project directories only
- Use appropriate file permissions
- Monitor MCP server logs for unusual activity

### 📈 SUCCESS METRICS

#### Productivity Indicators
- Reduced time for code exploration and understanding
- Faster implementation of new features following existing patterns
- Improved code consistency across the project
- Enhanced debugging and troubleshooting capabilities

#### Quality Indicators
- Better adherence to established patterns
- Reduced code duplication
- Improved documentation and knowledge retention
- Enhanced cross-module understanding

### 🎓 LEARNING RESOURCES

#### Understanding MCP Architecture
- Model Context Protocol specification
- Augment Code MCP integration documentation
- Individual MCP server documentation

#### Advanced Techniques
- Custom MCP server development
- Advanced Qdrant configuration
- Serena memory optimization strategies
- Integration with other development tools

### 🚀 FUTURE ENHANCEMENTS

#### Potential Improvements
- Custom MCP servers for project-specific needs
- Advanced vector search with domain-specific embeddings
- Integration with CI/CD pipelines
- Automated code quality analysis

#### Scaling Considerations
- Multi-project MCP configurations
- Team-shared Qdrant instances
- Collaborative Serena memory management
- Enterprise deployment strategies

### 📞 SUPPORT & TROUBLESHOOTING

#### Getting Help
- Check MCP server logs for detailed error information
- Consult individual MCP server documentation
- Use web search for latest troubleshooting guides
- Community forums and GitHub issues

#### Emergency Recovery
- Backup and restore procedures for Qdrant collections
- Serena memory export/import procedures
- Configuration rollback strategies
- Clean installation procedures

**END OF COMPREHENSIVE MASTER GUIDE**

---

## 🎯 QUICK START COMMAND FOR AI

**When this file is provided as context, execute:**
```
"Follow the MCP Configuration Master Guide step by step. Start with prerequisites check, install missing components, configure all three MCP servers (File System, Vector Search, Serena), test each one, and create comprehensive project memories. Use web search for latest installation methods as of June 10th, 2025."
```

**This guide ensures perfect MCP setup on any Windows system with comprehensive functionality for advanced AI-powered development.**
