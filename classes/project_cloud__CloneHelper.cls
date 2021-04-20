/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CloneHelper {
    global CloneHelper() {

    }
    global static void cloneCapabilities(Map<Id,Id> taskLinks) {

    }
    global static void cloneCapabilities(Map<Object,Map<Id,Id>> taskLinks) {

    }
    global static void cloneCases(List<Case> existingCases, Id clonedProjectId, Map<Id,Id> phaseLinks, Map<Id,Id> taskLinks) {

    }
    global static void cloneCases(List<Case> existingCases, Id clonedProjectId, Map<Id,Map<Object,Id>> phaseLinks, Map<Object,Map<Id,Id>> taskLinks) {

    }
    global static void cloneDependencies(Map<Id,Id> taskLinks) {

    }
    global static void cloneDependencies(Map<Object,Map<Id,Id>> taskLinks) {

    }
    global static Map<Id,Id> clonePhases(List<project_cloud__Project_Phase__c> existingPhases, Id clonedProjectId) {
        return null;
    }
    global static Map<Id,Map<Object,Id>> clonePhases(Map<Object,project_cloud__Project_Phase__c> existingPhases, Id clonedProjectId) {
        return null;
    }
    global static project_cloud__Project__c cloneProject(project_cloud__Project__c project, Date selectedStart) {
        return null;
    }
    global static project_cloud__Project__c cloneProject(project_cloud__Project__c project, Date selectedStart, Set<project_cloud.CloneHelper.Option> options) {
        return null;
    }
    global static void cloneSubscriptions(Id existingProjectId, Id clonedProjectId, Map<Id,Id> phaseLinks, Map<Id,Id> taskLinks) {

    }
    global static void cloneSubscriptions(Id existingProjectId, Id clonedProjectId, Map<Id,Map<Object,Id>> phaseLinks, Map<Object,Map<Id,Id>> taskLinks) {

    }
    global static Map<Id,Id> cloneTasks(List<project_cloud__Project_Task__c> existingTasks, Map<Id,Id> phaseLinks, Integer daysDiff) {
        return null;
    }
    global static Map<Object,Map<Id,Id>> cloneTasks(List<project_cloud__Project_Task__c> existingTasks, Map<Id,Map<Object,Id>> phaseLinks, Integer daysDiff) {
        return null;
    }
    global static void cloneTickets(List<project_cloud__Ticket__c> existingTickets, Id clonedProjectId, Map<Id,Id> phaseLinks, Map<Id,Id> taskLinks) {

    }
    global static void cloneTickets(List<project_cloud__Ticket__c> existingTickets, Id clonedProjectId, Map<Id,Map<Object,Id>> phaseLinks, Map<Object,Map<Id,Id>> taskLinks) {

    }
    global static project_cloud__Project_Task__c getClonedTask(project_cloud__Project_Task__c existingTask, Id phaseId, Integer daysDiff, Boolean isInsert) {
        return null;
    }
global class CloneException extends Exception {
}
global enum Option {CloneCases, CloneExpenses, CloneSkills, CloneSubscriptions, CloneTickets, IsBatch}
}
