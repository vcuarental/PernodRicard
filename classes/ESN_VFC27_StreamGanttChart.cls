/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | Stream                                                                                 |
|     - Description     | Controller of Gantt planning displayed on Stream page.                                                                                                                 |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 05/07/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ESN_VFC27_StreamGanttChart {

    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public ESNStream__c currStream {get;set;}
    
    /* List of child elements */
    public List<ESNStream__c> currChildStreams_list {get;set;}
    public List<Task> currStreamTasks_list {get;set;}
    public List<Event> currStreamEvents_list {get;set;}
    public List<Task> currStreamRecurrTasks_list {get;set;}
    public List<Event> currStreamRecurrEvents_list {get;set;}
    
    /* Color associated with stream situation */
    public Map<String,String> situation2color_map {get;set;}
    public Map<String,String> situation2ActColor_map {get;set;}
    
    /* Display Parameters */
    public String paramGanttZoom {get;set;}
    public Boolean hasChild {get;set;}
           
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public ESN_VFC27_StreamGanttChart(ApexPages.StandardController controller) {
        // Get the current Stream //
        currStream = (ESNStream__c)controller.getRecord();
        
        // Define zoom by default = Day (value in {D,W} ) //
        paramGanttZoom = 'D';
        
        // Get all child elements (Streams, Tasks, Events) of the current stream //
        currChildStreams_list = [SELECT Id, Name, ESN_ActualDeadline__c, ESN_ActualStartDate__c, ESN_ActualEndDate__c, ESN_SituationText__c, RecordType.Name, ESN_PlannedDeadline__c, StartDate__c, EndDate__c, Status__c FROM ESNStream__c WHERE ParentStream__c = :currStream.Id ORDER BY RecordType.Name,ESN_PlannedDeadline__c,StartDate__c,Name Asc];
        currStreamTasks_list = [SELECT Id, Owner.Name, Subject, Type, ActivityDate, Priority, Status, RecurrenceActivityId FROM Task WHERE WhatId = :currStream.Id AND IsRecurrence = false ORDER BY Subject Asc];
        currStreamRecurrTasks_list = [SELECT RecurrenceActivityId FROM Task WHERE WhatId = :currStream.Id AND IsRecurrence = true];
        currStreamEvents_list = [SELECT RecurrenceActivityId, StartDateTime, EndDateTime, Owner.Name, Id, Subject, Type, Location FROM Event WHERE WhatId = :currStream.Id AND IsChild = false AND IsRecurrence = false ORDER BY Subject Asc];
        currStreamRecurrEvents_list = [SELECT RecurrenceActivityId FROM Event WHERE WhatId = :currStream.Id AND IsRecurrence = true];
            
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