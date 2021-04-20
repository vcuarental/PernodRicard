/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RollupHelper {
    global RollupHelper(Schema.SObjectField incrementField) {

    }
    global RollupHelper(Set<Schema.SObjectField> allIncrementFields) {

    }
    global void increment(project_cloud__Work__c work, Decimal increment, Schema.SObjectField incrementField) {

    }
    global void increment(project_cloud__Work__c work, Decimal increment, Set<Schema.SObjectField> incrementFields) {

    }
    global static void populateMaps(Map<Id,project_cloud__Project__c> projects, Map<Id,project_cloud__Project_Phase__c> phases, Map<Id,project_cloud__Project_Task__c> tasks, Map<Id,project_cloud__Ticket__c> tickets, Map<Id,Case> cases) {

    }
    global void put(project_cloud__Work__c work) {

    }
    global void save() {

    }
global class RollupException extends Exception {
}
global virtual class WorkLookup {
    global Id phaseId {
        get;
    }
    global Id projectId {
        get;
    }
    global Id taskId {
        get;
    }
    global WorkLookup(project_cloud__Work__c work, Map<Id,Case> cases, Map<Id,project_cloud__Ticket__c> tickets, Map<Id,project_cloud__Project_Phase__c> phases, Map<Id,project_cloud__Project_Task__c> tasks) {

    }
    global virtual Boolean isProjectRelated() {
        return null;
    }
}
}
