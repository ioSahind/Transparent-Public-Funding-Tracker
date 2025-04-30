// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title PublicFundingTracker
 * @dev A simple smart contract to track public funds allocation and spending
 */
contract PublicFundingTracker {
    address public administrator;
    
    struct FundingProject {
        string projectName;
        string description;
        uint256 allocatedAmount;
        uint256 spentAmount;
        mapping(uint256 => Expenditure) expenditures;
        uint256 expenditureCount;
        bool isActive;
    }
    
    struct Expenditure {
        string description;
        uint256 amount;
        uint256 timestamp;
        string documentHash; // IPFS hash of supporting documents
    }
    
    mapping(uint256 => FundingProject) public projects;
    uint256 public projectCount;
    
    event ProjectCreated(uint256 indexed projectId, string projectName, uint256 allocatedAmount);
    event ExpenditureRecorded(uint256 indexed projectId, uint256 expenditureId, uint256 amount);
    event ProjectStatusChanged(uint256 indexed projectId, bool isActive);
    
    modifier onlyAdministrator() {
        require(msg.sender == administrator, "Only administrator can call this function");
        _;
    }
    
    constructor() {
        administrator = msg.sender;
        projectCount = 0;
    }
    
    /**
     * @dev Creates a new funding project with allocated budget
     * @param _projectName Name of the project
     * @param _description Brief description of the project
     * @param _allocatedAmount Total funds allocated to the project
     * @return projectId The ID of the newly created project
     */
    function createProject(
        string memory _projectName, 
        string memory _description, 
        uint256 _allocatedAmount
    ) public onlyAdministrator returns (uint256) {
        uint256 projectId = projectCount;
        
        FundingProject storage newProject = projects[projectId];
        newProject.projectName = _projectName;
        newProject.description = _description;
        newProject.allocatedAmount = _allocatedAmount;
        newProject.spentAmount = 0;
        newProject.expenditureCount = 0;
        newProject.isActive = true;
        
        projectCount++;
        
        emit ProjectCreated(projectId, _projectName, _allocatedAmount);
        return projectId;
    }
    
    /**
     * @dev Records a new expenditure for a specific project
     * @param _projectId ID of the project
     * @param _description Description of the expenditure
     * @param _amount Amount spent
     * @param _documentHash IPFS hash to supporting documents
     * @return expenditureId The ID of the newly recorded expenditure
     */
    function recordExpenditure(
        uint256 _projectId,
        string memory _description,
        uint256 _amount,
        string memory _documentHash
    ) public onlyAdministrator returns (uint256) {
        FundingProject storage project = projects[_projectId];
        
        require(project.isActive, "Project is not active");
        require(_amount > 0, "Amount must be greater than 0");
        require(project.spentAmount + _amount <= project.allocatedAmount, "Expenditure exceeds allocated amount");
        
        uint256 expenditureId = project.expenditureCount;
        
        Expenditure storage newExpenditure = project.expenditures[expenditureId];
        newExpenditure.description = _description;
        newExpenditure.amount = _amount;
        newExpenditure.timestamp = block.timestamp;
        newExpenditure.documentHash = _documentHash;
        
        project.spentAmount += _amount;
        project.expenditureCount++;
        
        emit ExpenditureRecorded(_projectId, expenditureId, _amount);
        return expenditureId;
    }
    
    /**
     * @dev Gets project details (except expenditures which need to be queried separately)
     * @param _projectId ID of the project
     * @return projectName Name of the project
     * @return description Project description
     * @return allocatedAmount Total allocated budget
     * @return spentAmount Amount spent so far
     * @return expenditureCount Number of expenditures
     * @return isActive Project status
     */
    function getProjectDetails(uint256 _projectId) public view returns (
        string memory projectName,
        string memory description,
        uint256 allocatedAmount,
        uint256 spentAmount,
        uint256 expenditureCount,
        bool isActive
    ) {
        FundingProject storage project = projects[_projectId];
        return (
            project.projectName,
            project.description,
            project.allocatedAmount,
            project.spentAmount,
            project.expenditureCount,
            project.isActive
        );
    }
}
