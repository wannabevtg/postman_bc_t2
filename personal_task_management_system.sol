pragma solidity ^0.8.20;

contract TaskManagement {
    enum Priority { High, Medium, Low }
    enum Status { Pending, Completed }
    
    struct Task {
        uint task_id;
        address doer;
        Priority hierarchy;
        Status status;
        uint dueDate;
        string todo;
    }
    
    Task[] public taskList;
    uint public id = 1;

    mapping(address => Task[]) public todoList;
    mapping(uint => address) public idToOwner;
    mapping(uint => Task) public idToTask;
    
    event TaskCreated(address indexed doer, uint indexed taskId);
    event TaskEdited(address indexed doer, uint indexed taskId);
    event TaskDeleted(address indexed doer, uint indexed taskId);

    function createTask(
        string memory taskTodo,
        Priority hierarchy
    ) public returns (uint) {
        uint taskId = id;
        Task memory newTask = Task({
            task_id: taskId,
            doer: msg.sender,
            hierarchy: hierarchy,
            status: Status.Pending,
            dueDate: block.timestamp + 2 days,
            todo: taskTodo
        });

        todoList[msg.sender].push(newTask);
        idToOwner[taskId] = msg.sender;
        idToTask[taskId] = newTask;
        id++;
        
        emit TaskCreated(msg.sender, taskId);
        return taskId;
    }

    function editTask(uint taskId, string memory newTodo) public {
        require(msg.sender == idToOwner[taskId], "Unauthorized");
        Task storage task = idToTask[taskId];
        task.todo = newTodo;
        
        // Update the task in the user's todoList
        Task[] storage userTasks = todoList[msg.sender];
        for (uint i = 0; i < userTasks.length; i++) {
            if (userTasks[i].task_id == taskId) {
                userTasks[i].todo = newTodo;
                break;
            }
        }
        
        emit TaskEdited(msg.sender, taskId);
    }

    function changeTaskStatus(uint taskId) public {
        require(msg.sender == idToOwner[taskId], "Unauthorized");
        Task storage task = idToTask[taskId];
        task.status = Status.Completed;
        
        // Update the task in the user's todoList
        Task[] storage userTasks = todoList[msg.sender];
        for (uint i = 0; i < userTasks.length; i++) {
            if (userTasks[i].task_id == taskId) {
                userTasks[i].status = Status.Completed;
                break;
            }
        }
    }

    function deleteTask(uint taskId) public {
        require(msg.sender == idToOwner[taskId], "Unauthorized");
        
        // Remove from mappings
        delete idToOwner[taskId];
        delete idToTask[taskId];
        
        // Remove from todoList
        Task[] storage userTasks = todoList[msg.sender];
        for (uint i = 0; i < userTasks.length; i++) {
            if (userTasks[i].task_id == taskId) {
                if (i < userTasks.length - 1) {
                    userTasks[i] = userTasks[userTasks.length - 1];
                }
                userTasks.pop();
                break;
            }
        }
        
        emit TaskDeleted(msg.sender, taskId);
    }

    function getTasksByStatus(Status status) public view returns (Task[] memory) {
        Task[] storage userTasks = todoList[msg.sender];
        Task[] memory filteredTasks = new Task[](userTasks.length);
        uint count = 0;
        
        for (uint i = 0; i < userTasks.length; i++) {
            if (userTasks[i].status == status) {
                filteredTasks[count] = userTasks[i];
                count++;
            }
        }
        
    }
    function setDueDate(uint taskId, uint newDueDate) public {
    require(msg.sender == idToOwner[taskId], "Unauthorized");
    Task storage task = idToTask[taskId];
    task.dueDate = newDueDate;
    
    // Update the task in the user's todoList array
    Task[] storage userTasks = todoList[msg.sender];
    for (uint i = 0; i < userTasks.length; i++) {
        if (userTasks[i].task_id == taskId) {
            userTasks[i].dueDate = newDueDate;
            break;
        }
    }
}
}
       