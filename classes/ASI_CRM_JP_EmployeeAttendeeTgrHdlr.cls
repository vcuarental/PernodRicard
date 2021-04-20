/*********************************************************************************
 * Name:ASI_CRM_JP_EmployeeAttendeeTgrHdlr
 * Description: Employee Attendee Trigger Handler for CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_EmployeeAttendeeTgrHdlr extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_EmployeeAttendeeTgrHdlr() {
        super('ASI_CRM_JP_EmployeeAttendeeTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Employee_Attendee__c> attList = (List<ASI_CRM_Employee_Attendee__c>)sObjList;
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> callDetailIdSet = new Set<Id>();
        
        if (oldMap == null) {
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                userIdSet.add(att.ASI_CRM_Attendee__c);
                callDetailIdSet.add(att.ASI_CRM_Call_Detail__c);
            }
        }
        else {
            Map<ID, ASI_CRM_Employee_Attendee__c> oldPlanMap = (Map<ID, ASI_CRM_Employee_Attendee__c>) oldMap;
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                if (att.ASI_CRM_Attendee__c != null && (att.ASI_CRM_Attendee__c != oldPlanMap.get(att.Id).ASI_CRM_Attendee__c )) {
                    userIdSet.add(att.ASI_CRM_Attendee__c); 
                    callDetailIdSet.add(att.ASI_CRM_Call_Detail__c);
                }
            }
        }
        
        Map<Id, User> userMap = new Map<Id, User>([Select Id, ASI_JP_TnE_Department_Category_Code__c From User Where Id In :userIdSet]);
        List<ASI_CRM_Employee_Attendee__c> existAttList = [Select Id, ASI_CRM_Attendee__c, ASI_CRM_Call_Detail__c From ASI_CRM_Employee_Attendee__c Where ASI_CRM_Call_Detail__c In :callDetailIdSet];
        
        if (oldMap == null) {
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                for(ASI_CRM_Employee_Attendee__c existAtt:existAttList){
                    if (att.ASI_CRM_Call_Detail__c == existAtt.ASI_CRM_Call_Detail__c && att.Id != existAtt.Id && att.ASI_CRM_Attendee__c == existAtt.ASI_CRM_Attendee__c){
                        att.addError(System.Label.ASI_CRM_JP_Duplicated_Attendee);
                    }
                }
                att.ASI_CRM_Department_Code__c = userMap.get(att.ASI_CRM_Attendee__c).ASI_JP_TnE_Department_Category_Code__c;
            }
        }
        else {
            Map<ID, ASI_CRM_Employee_Attendee__c> oldPlanMap = (Map<ID, ASI_CRM_Employee_Attendee__c>) oldMap;
            for (ASI_CRM_Employee_Attendee__c att: attList) {
                if (att.ASI_CRM_Attendee__c != null && (att.ASI_CRM_Attendee__c != oldPlanMap.get(att.Id).ASI_CRM_Attendee__c )) {
                    for(ASI_CRM_Employee_Attendee__c existAtt:existAttList){
                        if (att.ASI_CRM_Call_Detail__c == existAtt.ASI_CRM_Call_Detail__c && att.Id != existAtt.Id && att.ASI_CRM_Attendee__c == existAtt.ASI_CRM_Attendee__c){
                            att.addError(System.Label.ASI_CRM_JP_Duplicated_Attendee);
                        }
                    }
                    att.ASI_CRM_Department_Code__c = userMap.get(att.ASI_CRM_Attendee__c).ASI_JP_TnE_Department_Category_Code__c; 
                }
            }
        }        
    }
    
}