public without sharing class ASI_CRM_VN_VisitationConfirmProcess {

    public static final Integer DEF_VISIT_HOUR = 9;
    public static final Integer DEF_VISIT_MINUTE = 0;
    public static final Integer CUTOFF_DAY = 31;
    public static final String DEF_EVENT_STATUS = 'Outstanding';
    public static final String DEF_EVENT_VISIT_TYPE = 'Planned';
    public static final String VISITATION_DETAIL_STATUS = 'Planned';
    private static Boolean alreadyInitRT = false;
   
    private static ID eventRTId {
        get {
            if (eventRTId == null && !alreadyInitRT) {
                List<RecordType> rtList = [SELECT Id FROM RecordType WHERE DeveloperName = 'ASI_CRM_VN_Event' AND SobjectType = 'Event'];
                //system.debug('************Record type'+rtList.get(0).Id);
                if (rtList.size() > 0) eventRTId = rtList.get(0).Id;
                alreadyInitRT = true;
            }
            
            system.debug('@eventRTId'+eventRTId);
            return eventRTId;
        }
        set;
    }
    private static List<String> visitPlanMonthList;
    
    private ID visitId;
    private List<ASI_HK_CRM_Visitation_Plan__c> visits;
    
 
    
    public ASI_CRM_VN_VisitationConfirmProcess(ID visitId) {
        this.visitId = visitId;
        visits = getVisitationsForConfirm(visitId);
        system.debug('@visits'+visits);
    }
    
    public Boolean processConfirmation() {
        List<Event> visitEventList = new List<Event>();
        List<ASI_HK_CRM_Visitation_Plan__c> updateVisitList = new List<ASI_HK_CRM_Visitation_Plan__c>();
        List<ASI_HK_CRM_Visitation_Plan_Detail__c > updateVisitPlanDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c >();
        
        for (ASI_HK_CRM_Visitation_Plan__c visit : visits) {
            if (!visit.ASI_HK_CRM_Confirmed__c) {
                visit.ASI_HK_CRM_Confirmed__c = true;
                for (ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail : visit.ASI_HK_CRM_Visitation_Plan_Details__r) {
                    Event visitEvent = convertVisitPlanDetailToEvent(visit, visitDetail);
                    visitEventList.add(visitEvent);                
                    visitDetail.ASI_HK_CRM_Status__c = 'Planned';
                    updateVisitPlanDetailList.add(visitDetail);
                }
                updateVisitList.add(visit);
            }
            List<User> manager= [SELECT manager.email , ASI_HK_CRM_Sales_Director_Approver__r.email from user WHERE id= :visit.ownerid];
            if (manager.size() > 0){
                visit.ASI_HK_CRM_Manager_Email__c=manager.get(0).manager.email;
                visit.ASI_HK_CRM_Sales_Director_Email__c=manager.get(0).ASI_HK_CRM_Sales_Director_Approver__r.email;
            }
        }
        System.Savepoint sp = database.setSavepoint();
     
        try {
            insert visitEventList;
            update updateVisitList;
            update updateVisitPlanDetailList;
            
        } catch (Exception e) {
            // TODO: Log the errors
            database.rollback(sp);
            return false;
        }
        return true;
    }
    
    public static List<ASI_HK_CRM_Visitation_Plan__c> getVisitationsForConfirm(ID visitId) {
        List<ASI_HK_CRM_Visitation_Plan__c> result = null;
        if (visitId != null) {
            result = [
                SELECT Id, OwnerId, ASI_HK_CRM_Confirmed__c
                    , (SELECT Id, ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Account__c, ASI_HK_CRM_Subject__c,ASI_CRM_MY_Customer__c
                            , ASI_HK_CRM_Achievement_Detail__c, ASI_HK_CRM_Achievement_Required__c, ASI_HK_CRM_Activity_Type__c
                            , ASI_HK_CRM_Memo__c, ASI_HK_CRM_Objective_Required__c, ASI_HK_CRM_Visit_Objective__c,ASI_HK_CRM_Status__c
                            , ASI_HK_CRM_Account__r.Name, ASI_HK_CRM_Account__r.ASI_HK_CRM_Address__c
                        FROM ASI_HK_CRM_Visitation_Plan_Details__r
                    )
                FROM ASI_HK_CRM_Visitation_Plan__c
                WHERE Id = :visitId
                ]; //ASI_HK_CRM_Account__r.ASI_HK_CRM_Main_Contact__c, Removed by William Yang 03-04-2014
        }// else { // Get all visitation needed to be confirmed
          
        return result;
    }
     
    private Event convertVisitPlanDetailToEvent(ASI_HK_CRM_Visitation_Plan__c visitHeader, ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail) {
        Date visitDate = visitDetail.ASI_HK_CRM_Visit_Date__c;
        visitDetail.ASI_HK_CRM_Status__c = VISITATION_DETAIL_STATUS;
        Datetime eventDatetime = Datetime.newInstance(visitDate.year(), visitDate.month(), visitDate.day(), DEF_VISIT_HOUR, DEF_VISIT_MINUTE, 0);
        return new Event(
            Subject = visitDetail.ASI_HK_CRM_Subject__c
            , WhatId = visitDetail.ASI_CRM_MY_Customer__c
            , RecordTypeId = eventRTId
            , StartDateTime = eventDatetime
            , EndDateTime = eventDatetime
            , IsAllDayEvent = false
            , OwnerId = visitHeader.OwnerId
            , Location = locationFromVisitDetail(visitDetail)
            //Removed by William Yang 03-04-2014
            //, WhoId = visitDetail.ASI_HK_CRM_Account__r.ASI_HK_CRM_Main_Contact__c  
            , PR_Achievement_Detail__c = visitDetail.ASI_HK_CRM_Achievement_Detail__c
            , PR_Achievement_Required__c = visitDetail.ASI_HK_CRM_Achievement_Required__c
            , PR_Activity_Type__c = visitDetail.ASI_HK_CRM_Activity_Type__c
            , PR_Memo__c = visitDetail.ASI_HK_CRM_Memo__c
            , PR_Objective_Required__c = visitDetail.ASI_HK_CRM_Objective_Required__c
            , PR_Activity_Status__c = DEF_EVENT_STATUS
            , PR_Visit_Objective__c = visitDetail.ASI_HK_CRM_Visit_Objective__c
            , PR_Report_Visit_Type__c = DEF_EVENT_VISIT_TYPE
            , PR_Report_IsPlanned__c = true
           
            //, ASI_HK_CRM_VSE_Cancellation_Reason__c = visitDetail.ASI_HK_CRM_Cancellation_Reason__c
            //, ASI_HK_CRM_VSE_Meeting_Notes__c = visitDetail.ASI_HK_CRM_Meeting_Notes__c
        );    
    }
    
    private String locationFromVisitDetail(ASI_HK_CRM_Visitation_Plan_Detail__c visitDetail) {
        return visitDetail.ASI_HK_CRM_Account__r.ASI_HK_CRM_Address__c;
    }
}