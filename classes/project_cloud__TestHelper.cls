/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class TestHelper {
    global static Date friday;
    global static Date monday;
    global Date safeToday;
    global static Date saturday;
    global static Date sunday;
    global static Date thursday;
    global static Date tuesday;
    global static Date wednesday;
    global TestHelper() {

    }
    global TestHelper(Boolean populateConfigOptions, Boolean populateTimeEntryVisibilities) {

    }
    global static Date getSafeDate(Long increment) {
        return null;
    }
    global static Long getSafeIncrement(Long increment, Date start) {
        return null;
    }
    global project_cloud__Work__c newAllocation(Id taskId, Date activityDate, Decimal hours, Boolean isInsert) {
        return null;
    }
    global project_cloud__Work__c newAllocation(Id ownerId, Id taskId, Date activityDate, Decimal hours, Boolean isInsert) {
        return null;
    }
    global project_cloud__Capability__c newCapability(Id workTypeId, Schema.SObjectField parentField, Id parentId, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project__c newProject(String name, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project__c newProject(String name, project_cloud__Project__c applyTo, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project_Phase__c newProjectPhase(String name, Id projectId, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project_Phase__c newProjectPhase(String name, Id projectId, project_cloud__Project_Phase__c applyTo, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project_Task__c newProjectTask(Boolean isInsert) {
        return null;
    }
    global project_cloud__Project_Task__c newProjectTask(project_cloud__Project_Task__c applyTo, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project_Task__c newProjectTask(Decimal estimatedHours, Date autonStart, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project_Task__c newProjectTask(project_cloud.TestHelper.PUnit units, Decimal hoursOrDuration, Date autonStart, Id phaseId, project_cloud__Project_Task__c applyTo, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project_Task_Dependency__c newProjectTaskDependency(project_cloud__Project_Task__c parent, project_cloud__Project_Task__c child, Boolean isInsert) {
        return null;
    }
    global List<project_cloud__Project_Task__c> newProjectTasks(Integer size, Boolean incrementingEstimatedHours, Boolean isInsert) {
        return null;
    }
    global List<project_cloud__Project_Task__c> newProjectTasks(List<project_cloud__Project_Task__c> applyTos, Boolean isInsert) {
        return null;
    }
    global project_cloud__Work__c newSubscription(Id taskId, Boolean isInsert) {
        return null;
    }
    global project_cloud__Work__c newSubscription(Id ownerId, Schema.SObjectField parentField, Id parentId, Boolean isInsert) {
        return null;
    }
    global project_cloud__Ticket__c newTicket(String name, Schema.SObjectField parentField, Id parentId, Boolean isInsert) {
        return null;
    }
    global project_cloud__Ticket__c newTicket(String name, String ticketType, String ticketStatus, Schema.SObjectField parentField, Id parentId, Boolean isInsert) {
        return null;
    }
    global project_cloud__Work__c newTimeEntry(Date workDate, Decimal hours, Schema.SObjectField parentField, Id parentId, Boolean isInsert) {
        return null;
    }
    global project_cloud__Timesheet__c newTimesheet(Date start, Boolean isInsert) {
        return null;
    }
    global project_cloud__Timesheet__c newTimesheet(Date start, Id ownerId, Boolean isInsert) {
        return null;
    }
    global project_cloud__Work_Type__c newWorkType(String name, Boolean isInsert) {
        return null;
    }
    global List<project_cloud__Work_Type__c> newWorkTypes(List<String> names, Boolean isInsert) {
        return null;
    }
    global project_cloud__Project__c refreshProject(Id projectId) {
        return null;
    }
global enum PUnit {CalA, Dur, EstH}
global class ProjectPhaseTask {
    global List<project_cloud__Project_Phase__c> phases {
        get;
    }
    global project_cloud__Project__c project {
        get;
    }
    global List<project_cloud__Project_Task__c> tasks {
        get;
    }
    global ProjectPhaseTask(String prefix, List<List<project_cloud__Project_Task__c>> phaseApplyTos, Boolean insertTasks) {

    }
    global ProjectPhaseTask(String prefix, List<Integer> counts, Boolean insertTasks) {

    }
    global void refresh(Set<Schema.SObjectField> projectTokens, Set<Schema.SObjectField> phaseTokens, Set<Schema.SObjectField> taskTokens, Boolean opt_SortByNameOrHash) {

    }
    global void refresh(Set<String> projectFields, Set<String> phaseFields, Set<String> taskFields, Boolean opt_SortByNameOrHash) {

    }
}
}
