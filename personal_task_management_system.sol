pragma solidity ^0.8.0;

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
    mapping(uint => address) public idtoowner;
    mapping(uint => Task) public idtotask;

    function createTask(
        address doer,
        string memory taskTodo,
        Priority hierarchy,
        uint dueDate
    ) public {
        require(msg.sender == doer, "CREATE FOR URSELF ONLY");
        Task memory temp = Task({
            task_id: id,
            doer: doer,
            hierarchy: hierarchy,
            status: Status.Pending,
            dueDate: dueDate,
            todo: taskTodo
        });
        
        todoList[doer].push(temp);
        idtoowner[id] = doer;
        idtotask[id] = temp;
        id++;
    }

    function edittask(uint task_id, string memory edit) public {
        require(msg.sender == idtoowner[task_id], "Invalid ownership");
        address owner = idtoowner[task_id];
        for (uint i = 0; i < todoList[owner].length; i++) {
            if (task_id == todoList[owner][i].task_id) {
                todoList[owner][i].todo = edit;
                idtotask[task_id].todo = edit;
                return;
            }
        }
    }

    function change_task_status(uint task_id) public {
        require(msg.sender == idtoowner[task_id], "CHANGE STATUS OF UR OWN TASK");
        idtotask[task_id].status = Status.Completed;
    } 

    function delete_task(uint task_id) public {
        require(msg.sender == idtoowner[task_id], "DELETE YOUR OWN TASKS");
        address owner = idtoowner[task_id];
        Task[] storage userTasks = todoList[owner];
        for (uint i = 0; i < userTasks.length; i++) {
            if (task_id == userTasks[i].task_id) {
                userTasks[i] = userTasks[userTasks.length - 1];
                userTasks.pop();
                delete idtotask[task_id];
                delete idtoowner[task_id];
                break;
            }
        }
    }

    function show_tasks(address doer) public view returns (Task[] memory) {
        require(msg.sender == doer, "SEE UR OWN TASKS");
        return todoList[doer];
    }

    function set_duedates(uint task_id, uint dues) public {
        require(msg.sender == idtoowner[task_id], "SET UR OWN DUEDATES");
        idtotask[task_id].dueDate = dues;
    }

    function show_tasks_bystatus(address doer, Status stats) public view returns (Task[] memory) {
        require(msg.sender == doer, "SEE UR OWN TASKS");
        Task[] storage tasks = todoList[doer];
        uint count = 0;
        for (uint i = 0; i < tasks.length; i++) {
            if (tasks[i].status == stats) {
                count++;
            }
        }
        Task[] memory result = new Task[](count);
        uint index = 0;
        for (uint i = 0; i < tasks.length; i++) {
            if (tasks[i].status == stats) {
                result[index] = tasks[i];
                index++;
            }
        }
        return result;
    }
}