/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class InvokeProjectPhaseClone {
    global InvokeProjectPhaseClone() {

    }
    @InvocableMethod(label='Clone project phase' description='Clones a project phase onto a project')
    global static List<project_cloud__Project_Phase__c> clonePhase(List<project_cloud.InvokeProjectPhaseClone.ClonePhaseActionRequest> args) {
        return null;
    }
global class ClonePhaseActionRequest {
    @InvocableVariable(label='New Phase Name' description='Name to give to the cloned phase' required=false)
    global String name;
    @InvocableVariable(label='Template Phase Id' description='Phase Id of Phase to clone' required=true)
    global Id phaseId;
    @InvocableVariable(label='Phase Start Date' description='Start date of earliest task in the phase.  If non-working day is provided the next available working day will be used.' required=false)
    global Date startDate;
    @InvocableVariable(label='Target Project Id' description='Id of project to relate phase to, if not provided the phase will be cloned onto the same project' required=false)
    global Id targetProjectId;
    global ClonePhaseActionRequest() {

    }
}
}
