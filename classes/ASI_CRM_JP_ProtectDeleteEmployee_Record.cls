/*********************************************************************************
 * Name:ASI_CRM_JP_ProtectDeleteEmployee_Record
 * Description: Special class to protect delete Employee (2 level down record)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/01/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_ProtectDeleteEmployee_Record extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_ProtectDeleteEmployee_Record() {
        super('ASI_CRM_JP_ProtectDeleteEmployee_Record');
        
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_CRM_Employee_Attendee__c> employeeAttendeeList = (List<ASI_CRM_Employee_Attendee__c>)sObjList;
        Map<ID, ASI_CRM_Call_Detail__c> validCallDetailMap = new Map<ID, ASI_CRM_Call_Detail__c>();
        Set<ID> callDetailIdSet = new Set<ID>();
        
        for(ASI_CRM_Employee_Attendee__c employees : employeeAttendeeList) {
            callDetailIdSet.add(employees.ASI_CRM_Call_Detail__c);
        }
        
        if(callDetailIdSet.size() > 0) {
            validCallDetailMap = new Map<ID, ASI_CRM_Call_Detail__c>([SELECT ASI_CRM_Call_Plan__r.OwnerId, ID, Name, recordtypeid, ASI_CRM_Call_Plan__c, ASI_CRM_Call_Plan__r.recordtype.developername, ASI_CRM_Status__c FROM ASI_CRM_Call_Detail__c WHERE ID IN : callDetailIdSet]);
            for(ASI_CRM_Employee_Attendee__c employees : employeeAttendeeList) {
                ASI_CRM_Call_Detail__c callDetail = validCallDetailMap.get(employees.ASI_CRM_Call_Detail__c);
                if(ASI_CRM_JP_ProtectDelete_Record.recordtypeProtectKeyword.contains(callDetail.ASI_CRM_Call_Plan__r.recordtype.developername) && callDetail.ASI_CRM_Status__c != 'Planned') {
                    employees.adderror(Label.ASI_CRM_JP_Invalid_Delete );
                }
                if(employees.ASI_CRM_Attendee__c == callDetail.ASI_CRM_Call_Plan__r.OwnerId){
                    employees.adderror(Label.ASI_CRM_JP_Invalid_Delete );
                }
            }
            
        }
    }
    
}