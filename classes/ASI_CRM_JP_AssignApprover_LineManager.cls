/*********************************************************************************
 * Name:ASI_CRM_JP_AssignApprover_LineManager
 * Description: Assign Approvers based on the line Manager. Generic Class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 24/11/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_AssignApprover_LineManager extends ASI_CRM_JP_TriggerAbstract {


    public ASI_CRM_JP_AssignApprover_LineManager() {
        super('ASI_CRM_JP_AssignApprover_LineManager');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Set<ID> ownerIDSet = new Set<ID>();
        List<sObject> validsObjectList = new List<sObject>();
        
        if (oldMap == null) {
            validsObjectList = sObjList;
        } else {
            for(sObject objectRecord : sObjList) {
                if((ID)(oldMap.get((ID)(objectRecord.get('id'))).get('ownerid')) != (ID)(objectRecord.get('ownerid'))) {
                    validsObjectList.add(objectRecord);
                }
            }
        }
        
        
        for(sObject objectRecord : validsObjectList){
            ownerIDSet.add((ID)objectRecord.get('ownerid'));
        }
        
        if (ownerIDSet.size() > 0) {
            Map<ID, User> userMap = new Map<ID, User>([SELECT ID, Name, ManagerID FROM User WHERE ID IN : ownerIDSet]);
            
            for(sObject objectRecord : validsObjectList){
                User userItem = userMap.get((ID)objectRecord.get('ownerid'));
                objectRecord.put('ASI_CRM_Approver_1__c', userItem.managerID);
            }
        }
    }

}