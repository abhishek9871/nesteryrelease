# **Task Master MCP Setup Guide - Perfect Configuration for Any Project**

**A complete step-by-step guide to set up and use Task Master MCP with 100% success, based on proven implementation with the Nestery project.**

## **I. Prerequisites & System Requirements:**

### **Required Software:**
- ✅ **Augment Code** (or compatible MCP client)
- ✅ **OpenRouter Account** with API key
- ✅ **Project with existing codebase** (any language/framework)

### **Recommended Models:**
- ✅ **Primary**: `openai/gpt-4o-mini` (OpenRouter) - **PROVEN TO WORK**
- ✅ **Alternative**: `openai/gpt-4o` (OpenRouter)
- ✅ **Fallback**: `openai/gpt-4o-mini` (OpenRouter)
- ❌ **AVOID**: `google/gemini-2.0-flash-exp:free` - **FAILED IN OUR TESTING**

## **II. Step-by-Step Task Master MCP Configuration:**

### **Step 1: Configure OpenRouter API Key in Augment**
1. **Open Augment Code Settings**
2. **Navigate to MCP Servers section**
3. **Add OpenRouter API Key** to environment variables
4. **Verify API key** is properly configured

### **Step 2: Install Task Master MCP Server**
1. **Add Task Master MCP Server** in Augment settings
2. **Configure Server Settings:**
   ```json
   {
     "command": "taskmaster-mcp-server",
     "args": [],
     "env": {
       "OPENROUTER_API_KEY": "your-openrouter-api-key-here"
     }
   }
   ```

### **Step 3: Configure Task Master Models**
**Use these exact model configurations for optimal performance:**

#### **Main Model Configuration:**
- **Model**: `openai/gpt-4o-mini`
- **Provider**: OpenRouter
- **Purpose**: Primary task generation and updates
- **Status**: ✅ **PROVEN TO WORK PERFECTLY**

#### **Research Model Configuration:**
- **Model**: `openai/gpt-4o-mini`
- **Provider**: OpenRouter
- **Purpose**: Research-backed task analysis
- **Status**: ✅ **PROVEN TO WORK PERFECTLY**

#### **Fallback Model Configuration:**
- **Model**: `openai/gpt-4o-mini`
- **Provider**: OpenRouter
- **Purpose**: Backup when primary fails
- **Status**: ✅ **PROVEN TO WORK PERFECTLY**

### **Step 4: Verify Task Master Installation**
1. **Test MCP Connection** in Augment
2. **Run**: `models_taskmaster-ai` (without parameters)
3. **Verify**: All three models are properly configured
4. **Confirm**: API key status shows as valid

## **III. Project Initialization Process:**

### **Step 1: Initialize Task Master in Your Project**
```bash
# Navigate to your project root directory
cd /path/to/your/project

# Initialize Task Master (replace with your actual project path)
initialize_project_taskmaster-ai --projectRoot "/absolute/path/to/your/project" --yes true
```

### **Step 2: Create Project PRD File**
1. **Create**: `scripts/prd.txt` in your project root
2. **Use Template**: Follow the format from `scripts/example_prd.txt`
3. **Include**:
   - Project overview and current status
   - Core features and requirements
   - User personas and key flows
   - Technical architecture details
   - Development roadmap and phases

### **Step 3: Generate Tasks from PRD**
```bash
# Generate tasks from your PRD file
parse_prd_taskmaster-ai --projectRoot "/absolute/path/to/your/project" --input "scripts/prd.txt" --numTasks "15" --research true
```

**Key Parameters:**
- `--numTasks`: Adjust based on project complexity (10-20 recommended)
- `--research true`: Use research model for comprehensive task generation
- `--input`: Path to your PRD file

## **IV. Task Master Usage Workflow:**

### **Step 1: Check Current Status**
```bash
# Get all tasks and current status
get_tasks_taskmaster-ai --projectRoot "/absolute/path/to/your/project" --withSubtasks true
```

### **Step 2: Find Next Available Task**
```bash
# Find next task to work on (respects dependencies)
next_task_taskmaster-ai --projectRoot "/absolute/path/to/your/project"
```

### **Step 3: Work on Subtasks**
```bash
# Get specific task details
get_task_taskmaster-ai --id "1" --projectRoot "/absolute/path/to/your/project"

# Update subtask status as you work
set_task_status_taskmaster-ai --id "1.1" --status "in-progress" --projectRoot "/absolute/path/to/your/project"

# Mark subtask as complete
set_task_status_taskmaster-ai --id "1.1" --status "done" --projectRoot "/absolute/path/to/your/project"
```

### **Step 4: Track Progress**
```bash
# View overall progress
get_tasks_taskmaster-ai --projectRoot "/absolute/path/to/your/project"

# Generate complexity analysis
analyze_project_complexity_taskmaster-ai --projectRoot "/absolute/path/to/your/project" --research true
```

## **V. Advanced Features & Best Practices:**

### **Task Expansion:**
```bash
# Expand complex tasks into subtasks
expand_task_taskmaster-ai --id "5" --projectRoot "/absolute/path/to/your/project" --research true

# Expand all pending tasks
expand_all_taskmaster-ai --projectRoot "/absolute/path/to/your/project" --research true
```

### **Task Management:**
```bash
# Add new tasks
add_task_taskmaster-ai --prompt "Implement user authentication system" --projectRoot "/absolute/path/to/your/project" --research true

# Update existing tasks
update_task_taskmaster-ai --id "3" --prompt "Updated requirements based on client feedback" --projectRoot "/absolute/path/to/your/project"

# Remove tasks if needed
remove_task_taskmaster-ai --id "10" --projectRoot "/absolute/path/to/your/project" --confirm true
```

### **Dependency Management:**
```bash
# Add dependencies
add_dependency_taskmaster-ai --id "5" --dependsOn "3" --projectRoot "/absolute/path/to/your/project"

# Validate dependency chain
validate_dependencies_taskmaster-ai --projectRoot "/absolute/path/to/your/project"

# Fix dependency issues
fix_dependencies_taskmaster-ai --projectRoot "/absolute/path/to/your/project"
```

## **VI. Integration with NSI 1.7 Workflow:**

### **Perfect Combination:**
1. **Use Task Master** for strategic task planning and dependency management
2. **Use NSI 1.7 Workflow** for systematic, research-backed implementation
3. **Update Task Master status** as you complete NSI 1.7 phases

### **Workflow Integration:**
- **Phase 1**: Task Master analysis and grouping
- **Phase 2-9**: NSI 1.7 systematic implementation
- **Final**: Update Task Master status and progress

## **VII. Troubleshooting Common Issues:**

### **CRITICAL: Gemini Model Failure (AVOID!):**
- **Problem**: `google/gemini-2.0-flash-exp:free` does NOT work with Task Master MCP
- **Symptoms**: Models appear configured but don't respond or generate tasks
- **Solution**: Use `openai/gpt-4o-mini` instead - this is what actually works
- **Lesson**: Always test model functionality, don't assume free models work

### **Model Configuration Issues:**
- **Problem**: Models not responding
- **Solution**: Verify OpenRouter API key and model availability
- **Command**: `models_taskmaster-ai --listAvailableModels true`
- **Recommendation**: Stick with proven `openai/gpt-4o-mini` configuration

### **Project Initialization Issues:**
- **Problem**: Task Master not initializing
- **Solution**: Ensure absolute project path and proper permissions
- **Check**: Project root directory exists and is writable

### **Task Generation Issues:**
- **Problem**: PRD parsing fails
- **Solution**: Verify PRD file format and content structure
- **Check**: Use `scripts/example_prd.txt` as template

## **VIII. Success Metrics:**

### **Indicators of Proper Setup:**
- ✅ **Task Master commands** execute without errors
- ✅ **Models respond** with appropriate task generation
- ✅ **Dependencies** are properly tracked and respected
- ✅ **Progress tracking** shows accurate completion percentages
- ✅ **Research mode** provides enhanced task details

### **Project Success Indicators:**
- ✅ **Clear task breakdown** with logical dependencies
- ✅ **Manageable subtasks** that can be completed individually
- ✅ **Progress visibility** with accurate status tracking
- ✅ **Quality assurance** through systematic workflow integration

## **IX. Pro Tips for Maximum Effectiveness:**

### **PRD Writing Best Practices:**
- **Be Specific**: Include exact technical requirements and constraints
- **Include Context**: Current project status and completed work
- **Define Personas**: Clear user types and their needs
- **Technical Details**: Architecture, frameworks, and dependencies
- **Phases**: Break work into logical implementation phases

### **Task Management Strategy:**
- **Start Small**: Begin with foundational tasks that others depend on
- **Respect Dependencies**: Never work on tasks with unmet dependencies
- **Regular Updates**: Keep Task Master status current as you progress
- **Use Research Mode**: Enable research for complex or unfamiliar tasks
- **Quality Gates**: Maintain high standards with systematic workflows

### **Integration with Development Workflow:**
- **Branch Strategy**: Use dedicated branches for Task Master work
- **Commit Messages**: Reference Task Master task/subtask IDs
- **Testing**: Ensure 100% test coverage before marking tasks complete
- **Documentation**: Update project docs as tasks are completed

## **X. Example Project Structure:**

```
your-project/
├── scripts/
│   ├── prd.txt                    # Your project requirements
│   └── task-complexity-report.json # Generated complexity analysis
├── tasks/
│   ├── tasks.json                 # Main Task Master file
│   ├── task-1.md                  # Individual task files
│   ├── task-2.md
│   └── ...
├── NSI_1.7.md                     # Workflow automation (optional)
└── TaskMaster_MCP_Setup_Guide.md  # This guide (for reference)
```

## **XI. Final Success Checklist:**

### **Before Starting Your Project:**
- ✅ **OpenRouter API key** configured in Augment
- ✅ **Task Master MCP** installed and responding
- ✅ **All three models** configured with `openai/gpt-4o-mini` (NOT Gemini!)
- ✅ **Model functionality tested** - verify tasks actually generate
- ✅ **Project initialized** with Task Master
- ✅ **PRD file created** with comprehensive requirements
- ✅ **Tasks generated** from PRD with research mode

### **During Development:**
- ✅ **Follow dependency chain** - never skip prerequisites
- ✅ **Update status regularly** - keep Task Master current
- ✅ **Use research mode** for complex implementations
- ✅ **Maintain quality gates** - 100% test coverage
- ✅ **Document progress** - clear commit messages

### **Project Completion:**
- ✅ **All tasks marked done** - 100% completion
- ✅ **Dependencies satisfied** - clean dependency chain
- ✅ **Quality verified** - all tests passing
- ✅ **Documentation complete** - project fully documented

---

**Remember: Task Master MCP + NSI 1.7 Workflow = Perfect Project Management and Implementation Excellence!**

**This guide has been battle-tested with the Nestery project and guarantees success when followed precisely.**
