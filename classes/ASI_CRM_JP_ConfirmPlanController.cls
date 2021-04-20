public with sharing class ASI_CRM_JP_ConfirmPlanController{
    private ASI_CRM_Call_Plan__c plan;
    private List<ASI_CRM_Call_Detail__c> detailList = new List<ASI_CRM_Call_Detail__c>();
    
    private static Boolean alreadyInitRT = false;
    private static ID eventRTId {
        get {
            if (eventRTId == null && !alreadyInitRT) {
                List<RecordType> rtList = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_CRM_JP_Visitation_Schedule_Event' AND SobjectType = 'Event'];
                if (rtList.size() > 0) eventRTId = rtList.get(0).Id;
                alreadyInitRT = true;
            }
            return eventRTId;
        }
        set;
    }

    public ASI_CRM_JP_ConfirmPlanController(ApexPages.StandardController controller){
        plan = (ASI_CRM_Call_Plan__c)controller.getRecord();
        plan = [Select OwnerId, recordTypeid From ASI_CRM_Call_Plan__c Where Id = :plan.Id];
        detailList = [Select recordTypeid, ASI_CRM_Status__c, ASI_CRM_Call_Plan__c, ASI_CRM_Activity_Sub_brand_1__r.Name, ASI_CRM_Customer__c, ASI_CRM_Customer__r.ASI_CRM_CN_Address__c, ASI_CRM_Customer__r.ASI_CRM_CN_Phone_Number__c, ASI_CRM_Customer__r.ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Customer__r.Name, ASI_CRM_Visit_Date_From__c, ASI_CRM_Visit_Date_To__c, (Select ASI_CRM_Attendee__c From Employee_Attendees__r) From ASI_CRM_Call_Detail__c Where ASI_CRM_Status__c = 'Draft' And ASI_CRM_Call_Plan__c = :plan.Id];
    }
    
     public PageReference save(){
        Map<Id, Event> visitEventMap = new Map<Id, Event>();
        Map<Id, EventRelation> evtRltMap = new Map<Id, EventRelation>(); 
        for (ASI_CRM_Call_Detail__c  detail:detailList){
            Event visitEvent = convertVisitPlanDetailToEvent(plan, detail);
            visitEventMap.put(detail.id, visitEvent);
        }
        insert visitEventMap.values();
        for (ASI_CRM_Call_Detail__c  detail:detailList){
            detail.ASI_CRM_Status__c = 'Planned';
            detail.ASI_CRM_Reminder__c = true;
            detail.ASI_CRM_Reminder_Id__c = visitEventMap.get(detail.Id).Id;
            for (ASI_CRM_Employee_Attendee__c att:detail.Employee_Attendees__r) {
                if (att.ASI_CRM_Attendee__c != visitEventMap.get(detail.Id).OwnerId ) {
                    EventRelation er = new EventRelation(EventId = detail.ASI_CRM_Reminder_Id__c, RelationId = att.ASI_CRM_Attendee__c );
                    if (evtRltMap.get(att.ASI_CRM_Attendee__c) == null) {
                        evtRltMap.put(att.ASI_CRM_Attendee__c, er);
                    }
                }
            }
        }
        update detailList;
        insert evtRltMap.values();
        for (RecordType rc : Global_RecordTypeCache.getRtList('ASI_CRM_Call_Plan__c')){
            if (rc.developerName.contains('ASI_CRM_JP_Call_Plan_Locked')){
                plan.recordTypeid = rc.id;
            }
        }
        update plan;
        PageReference planPage = new ApexPages.StandardController(plan).view();
        planPage.setRedirect(true);
        return planPage;
    }
    
     private Event convertVisitPlanDetailToEvent(ASI_CRM_Call_Plan__c visitHeader, ASI_CRM_Call_Detail__c visitDetail) {
       return new Event(
            Subject = visitDetail.ASI_CRM_Customer__r.Name
            , Description = visitDetail.ASI_CRM_Customer__r.ASI_CRM_CN_Phone_Number__c
            , WhatId = visitDetail.ASI_CRM_Customer__c
            , RecordTypeId = eventRTId
            , StartDateTime = visitDetail.ASI_CRM_Visit_Date_From__c
            , EndDateTime = visitDetail.ASI_CRM_Visit_Date_To__c
            , IsAllDayEvent = false
            , OwnerId = visitHeader.OwnerId
            , Location = visitDetail.ASI_CRM_Customer__r.ASI_CRM_CN_Address__c
        );
    }
}