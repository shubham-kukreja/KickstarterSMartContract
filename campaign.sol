pragma solidity ^0.4.17;

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address recipent;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approval;
    }
    address public manager;
    mapping(address => bool) public approvers;
    uint256 public minimumContribution;
    uint256 public approversCount;
    Request[] public requests;

    constructor(uint256 minimum) public {
        manager = msg.sender;
        minimumContribution = minimum;
        approversCount = 0;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function createRequest(
        string _description,
        uint256 _value,
        address _recipent
    ) public restricted {
        Request memory newRequest = Request({
            description: _description,
            value: _value,
            recipent: _recipent,
            complete: false,
            approvalCount: 0
        });
        requests.push(newRequest);
    }

    function approveRequest(uint256 index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender]);
        require(!request.approval[msg.sender]);
        request.approval[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];
        require(!request.complete);
        require(request.approvalCount > (approversCount / 2));
        request.complete = true;
        request.recipent.transfer(request.value);
    }
}
