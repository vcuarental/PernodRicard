/*********************************************************************************
 * Name:ASI_CRM_JP_CallDetailTransfer
 * Description: Transfer Call Detail When Payer changes
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 17/12/2014       Laputa: Hank          Created
*********************************************************************************/

public without sharing class ASI_CRM_JP_CallDetailTransfer extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_CallDetailTransfer() {
        super('ASI_CRM_JP_CallDetailTransfer');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Employee_Attendee__c> attList = (List<ASI_CRM_Employee_Attendee__c>)sObjList;
        Set<Id> ownerIdSet = new Set<Id>();
        Set<Id> detailIdSet = new Set<Id>();
        
        if (oldMap == null) {
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                if(att.ASI_CRM_Payer__c == true && att.ASI_CRM_Attendee__c != att.CreatedById){
                    ownerIdSet.add(att.ASI_CRM_Attendee__c);
                    detailIdSet.add(att.ASI_CRM_Call_Detail__c); 
                }
            }
        }
        else {
            Map<ID, ASI_CRM_Employee_Attendee__c> oldAttMap = (Map<ID, ASI_CRM_Employee_Attendee__c>) oldMap;
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                if(att.ASI_CRM_Payer__c == true && oldAttMap.get(att.Id).ASI_CRM_Payer__c == false){
                    ownerIdSet.add(att.ASI_CRM_Attendee__c);
                    detailIdSet.add(att.ASI_CRM_Call_Detail__c);
                }
            }
        }
         
        Map<Id, ASI_CRM_Call_Detail__c> detailMap = new Map<Id, ASI_CRM_Call_Detail__c>([Select Id, Name, ASI_CRM_Visit_Date_From__c, ASI_CRM_Visit_Date_To__c, ASI_CRM_Visit_Date_Formula__c, ASI_CRM_Call_Plan__c, ASI_CRM_Call_Plan__r.Name From ASI_CRM_Call_Detail__c Where Id In :detailIdSet]);
        Map<Id, User> userMap = new Map<Id, User>([Select Id, Name From User Where Id In :ownerIdSet]);
        List<ASI_CRM_Call_Detail__c> detailUpdateList = new List<ASI_CRM_Call_Detail__c>();
        List<ASI_CRM_Call_Plan__c> planInsertList = new List<ASI_CRM_Call_Plan__c>();
        List<ASI_CRM_Call_Plan__c> planList = [Select Id, OwnerId, ASI_CRM_Period_From__c, ASI_CRM_Period_To__c From ASI_CRM_Call_Plan__c Where OwnerId In :ownerIdSet];
        List<ASI_CRM_Employee_Attendee__c> attUpdateList = [Select ASI_CRM_Payer__c From ASI_CRM_Employee_Attendee__c Where ASI_CRM_Call_Detail__c In :detailIdSet And ASI_CRM_Payer__c = true And ASI_CRM_Attendee__c Not In :ownerIdSet];
        
        if (oldMap == null) {
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                if(att.ASI_CRM_Payer__c == true && att.ASI_CRM_Attendee__c != att.CreatedById){
                    Boolean isCallPlanExist = false;
                    for(ASI_CRM_Call_Plan__c plan:planList){
                        if(!isCallPlanExist && plan.OwnerId == att.ASI_CRM_Attendee__c){
                            for(ASI_CRM_Call_Detail__c detail:detailMap.Values()){
                                if(!isCallPlanExist && detail.ASI_CRM_Visit_Date_From__c.date() >= plan.ASI_CRM_Period_From__c && detail.ASI_CRM_Visit_Date_From__c.date() <= plan.ASI_CRM_Period_To__c){
                                    isCallPlanExist = true;
                                }
                            }
                        }
                    }
                    if(!isCallPlanExist){
                        ASI_CRM_Call_Plan__c newPlan = new ASI_CRM_Call_Plan__c();
                        newPlan.Name = detailMap.get(att.ASI_CRM_Call_Detail__c).ASI_CRM_Call_Plan__r.Name + ' (' + userMap.get(att.ASI_CRM_Attendee__c).Name + ')';
                        newPlan.OwnerId = att.ASI_CRM_Attendee__c;
                        newPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan');
                        newPlan.ASI_CRM_Period_From__c = detailMap.get(att.ASI_CRM_Call_Detail__c).ASI_CRM_Visit_Date_From__c.date();
                        newPlan.ASI_CRM_Period_To__c = detailMap.get(att.ASI_CRM_Call_Detail__c).ASI_CRM_Visit_Date_From__c.date();
                        planInsertList.add(newPlan);
                    }   
                }
            }
        }
        else {
            Map<ID, ASI_CRM_Employee_Attendee__c> oldAttMap = (Map<ID, ASI_CRM_Employee_Attendee__c>) oldMap;
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                if(att.ASI_CRM_Payer__c == true && oldAttMap.get(att.Id).ASI_CRM_Payer__c == false){
                    Boolean isCallPlanExist = false;
                    for(ASI_CRM_Call_Plan__c plan:planList){
                        if(!isCallPlanExist && plan.OwnerId == att.ASI_CRM_Attendee__c){
                            for(ASI_CRM_Call_Detail__c detail:detailMap.Values()){
                                if(!isCallPlanExist && detail.ASI_CRM_Visit_Date_From__c.date() >= plan.ASI_CRM_Period_From__c && detail.ASI_CRM_Visit_Date_From__c.date() <= plan.ASI_CRM_Period_To__c){                               
                                    isCallPlanExist = true;
                                }
                            }
                        }
                    }
                    if(!isCallPlanExist){
                        ASI_CRM_Call_Plan__c newPlan = new ASI_CRM_Call_Plan__c();
                        newPlan.Name = detailMap.get(att.ASI_CRM_Call_Detail__c).ASI_CRM_Call_Plan__r.Name + ' (' + userMap.get(att.ASI_CRM_Attendee__c).Name + ')';
                        newPlan.OwnerId = att.ASI_CRM_Attendee__c;
                        newPlan.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan');
                        newPlan.ASI_CRM_Period_From__c = detailMap.get(att.ASI_CRM_Call_Detail__c).ASI_CRM_Visit_Date_From__c.date();
                        newPlan.ASI_CRM_Period_To__c = detailMap.get(att.ASI_CRM_Call_Detail__c).ASI_CRM_Visit_Date_From__c.date();
                        planInsertList.add(newPlan);
                    }   
                }
            }
        }
        
        if(planInsertList.size() > 0){
            insert planInsertList;
        }
        
        planList = [Select Id, OwnerId, ASI_CRM_Period_From__c, ASI_CRM_Period_To__c From ASI_CRM_Call_Plan__c Where OwnerId In :ownerIdSet];
        
        if (oldMap == null) {
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                if(att.ASI_CRM_Payer__c == true && att.ASI_CRM_Attendee__c != att.CreatedById){
                    Boolean isCallPlanExist = false;
                    for(ASI_CRM_Call_Plan__c plan:planList){
                        if(!isCallPlanExist && plan.OwnerId == att.ASI_CRM_Attendee__c){
                            for(ASI_CRM_Call_Detail__c detail:detailMap.Values()){
                                if(!isCallPlanExist && detail.ASI_CRM_Visit_Date_From__c.date() >= plan.ASI_CRM_Period_From__c && detail.ASI_CRM_Visit_Date_From__c.date() <= plan.ASI_CRM_Period_To__c){
                                    detail.ASI_CRM_Call_Plan__c = plan.Id;
                                    detailUpdateList.add(detail);
                                    isCallPlanExist = true;
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            Map<ID, ASI_CRM_Employee_Attendee__c> oldAttMap = (Map<ID, ASI_CRM_Employee_Attendee__c>) oldMap;
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                if(att.ASI_CRM_Payer__c == true && oldAttMap.get(att.Id).ASI_CRM_Payer__c == false){
                    Boolean isCallPlanExist = false;
                    for(ASI_CRM_Call_Plan__c plan:planList){
                        if(!isCallPlanExist && plan.OwnerId == att.ASI_CRM_Attendee__c){
                            for(ASI_CRM_Call_Detail__c detail:detailMap.Values()){
                                if(!isCallPlanExist && detail.ASI_CRM_Visit_Date_From__c.date() >= plan.ASI_CRM_Period_From__c && detail.ASI_CRM_Visit_Date_From__c.date() <= plan.ASI_CRM_Period_To__c){
                                    detail.ASI_CRM_Call_Plan__c = plan.Id;
                                    detailUpdateList.add(detail);
                                    isCallPlanExist = true;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if(attUpdateList.size() > 0){
            for(ASI_CRM_Employee_Attendee__c att:attUpdateList){
                att.ASI_CRM_Payer__c = false;
            }
            update attUpdateList;
        }
        if(detailUpdateList.size() > 0){
            Map<Id, ASI_CRM_Call_Detail__c> detailUpdateMap = new Map<Id, ASI_CRM_Call_Detail__c>();
            detailUpdateMap.putAll(detailUpdateList);
            update detailUpdateMap.values();
        }
    }
    
}