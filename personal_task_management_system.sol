// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TaskManagement {
    enum Priority { High, Medium, Low }
    enum Status { Pending, Completed }
    
    struct Task {
        uint taskId;
        address doer;
        Priority priority;
        Status status;
        uint dueDate;
        string description;
    }

    mapping(address => Task[]) private userTasks;
    mapping(uint => address) private taskToOwner;
    mapping(uint => Task) private taskRegistry;

  
    event TaskCreated(address indexed owner, uint indexed taskId);
    event TaskUpdated(address indexed owner, uint indexed taskId);
    event TaskDeleted(address indexed owner, uint indexed taskId);
    event DueDateChanged(uint indexed taskId, uint newDueDate);

    uint private taskCounter = 1;

    function createTask(
        string calldata description,
        Priority priority,
        uint customDueDate
    ) external returns (uint) {
        uint dueDate = customDueDate == 0 ? 
            block.timestamp + 2 days : 
            customDueDate;
        
        require(dueDate > block.timestamp, "Due date must be in future");

        uint newTaskId = taskCounter++;
        Task memory newTask = Task({
            taskId: newTaskId,
            doer: msg.sender,
            priority: priority,
            status: Status.Pending,
            dueDate: dueDate,
            description: description
        });

        userTasks[msg.sender].push(newTask);
        taskToOwner[newTaskId] = msg.sender;
        taskRegistry[newTaskId] = newTask;

        emit TaskCreated(msg.sender, newTaskId);
        return newTaskId;
    }

    function updateTaskDescription(uint taskId, string calldata newDescription) external {
        require(taskToOwner[taskId] == msg.sender, "Unauthorized");
        Task storage task = taskRegistry[taskId];
        task.description = newDescription;
        _updateTaskInArray(taskId);
        emit TaskUpdated(msg.sender, taskId);
    }

    function completeTask(uint taskId) external {
        require(taskToOwner[taskId] == msg.sender, "Unauthorized");
        Task storage task = taskRegistry[taskId];
        task.status = Status.Completed;
        _updateTaskInArray(taskId);
        emit TaskUpdated(msg.sender, taskId);
    }

    function setDueDate(uint taskId, uint newDueDate) external {
        require(taskToOwner[taskId] == msg.sender, "Unauthorized");
        require(newDueDate > block.timestamp, "Invalid due date");
        
        Task storage task = taskRegistry[taskId];
        task.dueDate = newDueDate;
        _updateTaskInArray(taskId);
        
        emit DueDateChanged(taskId, newDueDate);
        emit TaskUpdated(msg.sender, taskId);
    }

    function deleteTask(uint taskId) external {
        require(taskToOwner[taskId] == msg.sender, "Unauthorized");
        
        // Remove from mappings
        delete taskToOwner[taskId];
        delete taskRegistry[taskId];
        
        // Remove from user's task array
        Task[] storage tasks = userTasks[msg.sender];
        for (uint i = 0; i < tasks.length; i++) {
            if (tasks[i].taskId == taskId) {
                if (i < tasks.length - 1) {
                    tasks[i] = tasks[tasks.length - 1];
                }
                tasks.pop();
                break;
            }
        }

        emit TaskDeleted(msg.sender, taskId);
    }

    function getTasksByStatus(Status status) external view returns (Task[] memory) {
        Task[] storage tasks = userTasks[msg.sender];
        uint count = 0;
        
        // First pass to count matches
        for (uint i = 0; i < tasks.length; i++) {
            if (tasks[i].status == status) count++;
        }

        
        Task[] memory result = new Task[](count);
        uint index = 0;
        
        for (uint i = 0; i < tasks.length; i++) {
            if (tasks[i].status == status) {
                result[index++] = tasks[i];
            }
        }

        return result;
    }

    function getUserTasks() external view returns (Task[] memory) {
        return userTasks[msg.sender];
    }

    function getTaskDetails(uint taskId) external view returns (Task memory) {
        require(taskToOwner[taskId] == msg.sender, "Unauthorized");
        return taskRegistry[taskId];
    }


    function _updateTaskInArray(uint taskId) private {
        Task[] storage tasks = userTasks[msg.sender];
        for (uint i = 0; i < tasks.length; i++) {
            if (tasks[i].taskId == taskId) {
                tasks[i] = taskRegistry[taskId];
                break;
            }
        }
    }
}