/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class InvokeProjectClone {
    global InvokeProjectClone() {

    }
    @InvocableMethod(label='Clone a project' description='Clones a project')
    global static List<project_cloud__Project__c> cloneProjects(List<project_cloud.InvokeProjectClone.InvocableProjectClone> invocables) {
        return null;
    }
global class InvocableProjectClone {
    @InvocableVariable(label='Clone allocations' description='Clone allocations related to the project' required=false)
    global Boolean cloneAllocations;
    @InvocableVariable(label='Clone cases' description='Clone cases related to the project' required=false)
    global Boolean cloneCases;
    @InvocableVariable(label='Clone expenses' description='Clone expenses related to the project' required=false)
    global Boolean cloneExpenses;
    @InvocableVariable(label='Clone skills' description='Clone skills related to the project' required=false)
    global Boolean cloneSkills;
    @InvocableVariable(label='Clone tickets' description='Clone tickets related to the project' required=false)
    global Boolean cloneTickets;
    @InvocableVariable(label='Template Project Id' description='Required. The id of the project to clone.' required=true)
    global Id projectId;
    @InvocableVariable(label='New Project Name' description='Required. The project name' required=true)
    global String projectName;
    @InvocableVariable(label='Related Record Id' description='Not Required.  Related record to associate with the project' required=false)
    global Id relatedRecordId;
    @InvocableVariable(label='Project Start Date' description='Required. Start date for the project' required=true)
    global Date startDate;
    global InvocableProjectClone() {

    }
}
}
