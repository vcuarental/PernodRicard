/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | Project                                                                                 |
|     - Description     | Controller of Gantt planning displayed on Project page.                                                                                                                 |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 05/07/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ESN_VFC26_ProjectGanttChart {

    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public ESNProject__c currProject {get;set;}
    
    /* List of child elements */
    public List<ESNStream__c> currProjectStreams_list {get;set;}
    public List<Task> currProjectTasks_list {get;set;}
    public List<Task> currProjectRecurrTasks_list {get;set;}
    public List<Event> currProjectEvents_list {get;set;}
    public List<Event> currProjectRecurrEvents_list {get;set;}
    
    /* Color associated with stream situation */
    public Map<String,String> situation2color_map {get;set;}
    public Map<String,String> situation2ActColor_map {get;set;}
    
    /* Display Parameters */
    public String paramGanttZoom {get;set;}

    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public ESN_VFC26_ProjectGanttChart(ApexPages.StandardController controller) {
        // Get the current Project //
        currProject = (ESNProject__c)controller.getRecord();
        
        // Define zoom by default = Day (value in {D,W} ) //
        paramGanttZoom = 'D';
        
        // Get all child elements (Streams, Tasks, Events) of the current Project //
        currProjectStreams_list = [SELECT Id, Name, StartDate__c, ESN_ActualDeadline__c, ESN_ActualStartDate__c, ESN_ActualEndDate__c, ESN_SituationText__c, RecordType.Name, ESN_PlannedDeadline__c, EndDate__c, Status__c FROM ESNStream__c WHERE Project__c = :currProject.Id AND ParentStream__c = null ORDER BY RecordType.Name,ESN_PlannedDeadline__c,StartDate__c, Name Asc];
        currProjectTasks_list = [SELECT Id, Owner.Name, Subject, Type, ActivityDate, Priority, Status, RecurrenceActivityId FROM Task WHERE WhatId = :currProject.Id AND IsRecurrence = false ORDER BY Subject Asc];
        currProjectRecurrTasks_list = [SELECT RecurrenceActivityId FROM Task WHERE WhatId = :currProject.Id AND IsRecurrence = true];
        currProjectEvents_list = [SELECT RecurrenceActivityId, StartDateTime, EndDateTime, Owner.Name, Id, Subject, Type, Location FROM Event WHERE WhatId = :currProject.Id AND IsChild = false AND IsRecurrence = false ORDER BY Subject Asc];
        currProjectRecurrEvents_list = [SELECT RecurrenceActivityId FROM Event WHERE WhatId = :currProject.Id AND IsRecurrence = true];
                
        situation2color_map = new Map<String,String>{      
            'Closed'=>'rgb(155,155,155)',
            'In Progress'=>'rgb(75, 204, 75)', 
            'Planned'=>'rgb(250, 88, 208)',
            'Not Started'=>'rgb(250, 88, 208)',
            'Late Start'=>'rgb(255,150,0)',  
            'At Risk'=>'rgb(255,0,0)',  
            'Late'=>'rgb(255,0,0)'
        };
        
        situation2ActColor_map = new Map<String,String>{
            'Closed'=>'rgb(155,155,155)',
            'In Progress'=>'rgb(75, 204, 75)', 
            'Planned'=>'rgb(250, 88, 208)',
            'Not Started'=>'rgb(250, 88, 208)',
            'Late Start'=>'rgb(255,150,0)',  
            'At Risk'=>'rgb(255,0,0)',  
            'Late'=>'rgb(255,0,0)'
        };
    }

}