/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetailTgrHdlr
 * Description: Call Detail Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_CallDetailTgrHdlr extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_CallDetailTgrHdlr() {
        super('ASI_CRM_JP_CallDetailTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Call_Detail__c> detailList = (List<ASI_CRM_Call_Detail__c>)sObjList;
        List<ASI_CRM_Employee_Attendee__c> attList = new List<ASI_CRM_Employee_Attendee__c>();
        Set<Id> eventIdSet = new Set<Id>();
        List<ASI_CRM_Call_Plan__c> newPlanList = new List<ASI_CRM_Call_Plan__c>();
        List<ASI_CRM_Call_Detail__c> newDetailList = new List<ASI_CRM_Call_Detail__c>();
        Set<Id> updateDetailSet = new Set<Id>();
        List<ASI_CRM_Call_Detail__c> updateDetailList = new List<ASI_CRM_Call_Detail__c>();
        Set<Id> repeatIdSet  = new Set<Id>();
        Set<Id> repeatUpdateIdSet = new Set<Id>();
        Set<Id> planIdSet = new Set<Id>();
        
        if (oldMap == null) {
            for (ASI_CRM_Call_Detail__c detail : detailList) {
                ASI_CRM_Employee_Attendee__c att = new ASI_CRM_Employee_Attendee__c();
                att.ASI_CRM_Call_Detail__c= detail.id;
                att.ASI_CRM_Attendee__c = detail.CreatedById;
                att.ASI_CRM_Payer__c = true; 
                att.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Employee_Attendee__cASI_CRM_JP_Employee_Attendee');
                attList.add(att);
            }
        }
        else {
            Map<ID, ASI_CRM_Call_Detail__c> oldDetailMap = (Map<ID, ASI_CRM_Call_Detail__c>) oldMap;
            for (ASI_CRM_Call_Detail__c detail: detailList) {
                if (detail.ASI_CRM_Status__c == 'Cancelled' && detail.ASI_CRM_Reminder_Id__c != null && (detail.ASI_CRM_Status__c != oldDetailMap.get(detail.Id).ASI_CRM_Status__c)) {
                    eventIdSet.add(detail.ASI_CRM_Reminder_Id__c);  
                    updateDetailSet.add(detail.Id);
                }
                //For Repeat
                if(detail.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat_Settings')
                        && oldDetailMap.get(detail.Id).RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail')){
                    repeatIdSet.add(detail.CreatedById);
                }
            }
            updateDetailList = [Select ASI_CRM_Reminder_Id__c From ASI_CRM_Call_Detail__c Where Id In :updateDetailSet];
            for(ASI_CRM_Call_Detail__c detail: updateDetailList){
                detail.ASI_CRM_Reminder_Id__c = null;
            }
            Map<Id, ASI_CRM_Call_Plan__c> planMap = new Map<Id, ASI_CRM_Call_Plan__c>();
            List<ASI_CRM_Call_Plan__c> repeatList = new List<ASI_CRM_Call_Plan__c>();
            
            repeatList = [Select Id, OwnerId, ASI_CRM_Period_From__c, ASI_CRM_Period_To__c From ASI_CRM_Call_Plan__c Where OwnerId In :repeatIdSet];
                        
            for (ASI_CRM_Call_Detail__c detail: detailList) {
                //For Repeat
                if(detail.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat_Settings')
                        && oldDetailMap.get(detail.Id).RecordTypeId == Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail')){
                    for(ASI_CRM_Call_Plan__c plan:repeatList){
                        if(plan.OwnerId == detail.CreatedById){
                            if(detail.ASI_CRM_Pattern__c == 'Weekly'){
                                Integer numOfDays = detail.ASI_CRM_Visit_Date_Formula__c.daysBetween(detail.ASI_CRM_Repeat_End_Date__c);
                                Integer i = 0;
                                for(i=(7*Integer.valueOf(detail.ASI_CRM_Frequency__c));i<=numOfDays;i+=(7*Integer.valueOf(detail.ASI_CRM_Frequency__c))){
                                    if(Date.valueOf(plan.ASI_CRM_Period_From__c) <= detail.ASI_CRM_Visit_Date_From__c.date().addDays(i) &&
                                            Date.valueOf(plan.ASI_CRM_Period_To__c) >= detail.ASI_CRM_Visit_Date_From__c.date().addDays(i)){
                                        ASI_CRM_Call_Detail__c newDetail = new ASI_CRM_Call_Detail__c();
                                        newDetail = detail.clone(true,true);
                                        newDetail.id = null;
                                        newDetail.ASI_CRM_Call_Plan__c = plan.Id;
                                        newDetail.ASI_CRM_Visit_Date_From__c = detail.ASI_CRM_Visit_Date_From__c.addDays(i);
                                        newDetail.ASI_CRM_Visit_Date_To__c = detail.ASI_CRM_Visit_Date_To__c.addDays(i);
                                        newDetail.ASI_CRM_Original_Call_Detail__c = detail.id;
                                        newDetail.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat');
                                        newDetailList.add(newDetail);
                                    }
                                }
                            }else if(detail.ASI_CRM_Pattern__c == 'Monthly'){
                                Integer numOfMonths = detail.ASI_CRM_Visit_Date_Formula__c.monthsBetween(detail.ASI_CRM_Repeat_End_Date__c);
                                Integer i = 0;
                                for(i=Integer.valueOf(detail.ASI_CRM_Frequency__c);i<=numOfMonths;i+=Integer.valueOf(detail.ASI_CRM_Frequency__c)){
                                    if(Date.valueOf(plan.ASI_CRM_Period_From__c) <= detail.ASI_CRM_Visit_Date_From__c.date().addMonths(i) &&
                                            Date.valueOf(plan.ASI_CRM_Period_To__c) >= detail.ASI_CRM_Visit_Date_From__c.date().addMonths(i) &&
                                            detail.ASI_CRM_Visit_Date_From__c.addMonths(i).day() == detail.ASI_CRM_Visit_Date_From__c.day() &&
                                            detail.ASI_CRM_Visit_Date_To__c.addMonths(i).day() == detail.ASI_CRM_Visit_Date_To__c.day()){
                                        ASI_CRM_Call_Detail__c newDetail = new ASI_CRM_Call_Detail__c();
                                        newDetail = detail.clone(true,true);
                                        newDetail.id = null;
                                        newDetail.ASI_CRM_Call_Plan__c = plan.Id;
                                        newDetail.ASI_CRM_Visit_Date_From__c = detail.ASI_CRM_Visit_Date_From__c.addMonths(i);
                                        newDetail.ASI_CRM_Visit_Date_To__c = detail.ASI_CRM_Visit_Date_To__c.addMonths(i);
                                        newDetail.ASI_CRM_Original_Call_Detail__c = detail.id;
                                        newDetail.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Detail__cASI_CRM_JP_Call_Plan_Detail_Repeat');
                                        newDetailList.add(newDetail);       
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //Insert owner as the first employee attendee
        insert attList;
        
        if(newDetailList.size() > 0){
            insert newDetailList;
        }
        
        //Delete event if detail is cancelled
        List<Event> eventList = [Select Id From Event Where Id In :eventIdSet];
        delete eventList;
        if(updateDetailList.size() > 0){
            update updateDetailList;
        }
    }
    
}