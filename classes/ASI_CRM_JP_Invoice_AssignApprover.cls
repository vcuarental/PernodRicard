/*********************************************************************************
 * Name:ASI_CRM_JP_Invoice_AssignApprover
 * Description: Assign Approvers for Invoice
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/12/2014       Laputa: Hank          Created
*********************************************************************************/
public without sharing class ASI_CRM_JP_Invoice_AssignApprover extends ASI_CRM_JP_TriggerAbstract {
    public ASI_CRM_JP_Invoice_AssignApprover() {
        super('ASI_CRM_JP_Invoice_AssignApprover');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_Payment_Invoice__c> detailList = (List<ASI_CRM_Payment_Invoice__c>)sObjList;
        String module = 'Payment Invoice';
        List<ASI_CRM_Route_Type__c> routeTypeList = [SELECT ID, Name, ASI_CRM_Module__c, ASI_CRM_Module_Record_Type__c, (SELECT ID, Name, ASI_CRM_Approver__c,ASI_CRM_Threshold__c FROM ASI_CRM_Route_Rule_Details__r order by name ASC),
                                                     (Select Name From ASI_CRM_Role_Route_Type_Relationships__r) FROM ASI_CRM_Route_Type__c WHERE ASI_CRM_Module__c = : module ];
        Set<Id> ownerIdSet = new Set<Id>();                                             
        Set<Id> invoiceIdSet = new Set<Id>();                                            
        Map<ID,RecordType> rtMap = New Map<ID,RecordType>([Select ID, Name From RecordType Where sObjectType = 'ASI_CRM_Payment_Invoice__c']);
        Id profileId = userinfo.getProfileId();
        Profile p = [Select Name From Profile Where Id = :profileId];    
        if (oldMap == null) {
            for (ASI_CRM_Payment_Invoice__c detail : detailList) {
                if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice')){
                    ownerIdSet.add(detail.OwnerId);
                    invoiceIdSet.add(detail.Id);
                }
            }
        }
        else {
            Map<ID, ASI_CRM_Payment_Invoice__c> oldDetailMap = (Map<ID, ASI_CRM_Payment_Invoice__c>) oldMap;
            for (ASI_CRM_Payment_Invoice__c detail: detailList) {
                if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice') &&
                    detail.ASI_CRM_Approver_2__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_2__c &&
                    detail.ASI_CRM_Approver_3__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_3__c &&
                    detail.ASI_CRM_Approver_4__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_4__c &&
                    detail.ASI_CRM_Approver_5__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_5__c &&
                    detail.ASI_CRM_Approver_6__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_6__c &&
                    detail.ASI_CRM_Approver_7__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_7__c &&
                    detail.ASI_CRM_Approver_7__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_8__c &&
                    detail.ASI_CRM_Approver_8__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_9__c &&
                    detail.ASI_CRM_Approver_10__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_10__c &&
                    detail.ASI_CRM_Sys_Allow_Submit_Approval__c == false &&
                    detail.ASI_CRM_Status__c == oldDetailMap.get(detail.Id).ASI_CRM_Status__c &&
                    detail.ASI_CRM_Status__c == 'Draft'){
                     ownerIdSet.add(detail.OwnerId);  
                     invoiceIdSet.add(detail.Id);  
                }
            }
        }
        
        Map<Id, User> ownerMap = new Map<Id, User>([Select Id, UserRole.Name, UserRole.DeveloperName From User Where Id In :ownerIdSet]);
        invoiceItemsMap = new Map<Id, ASI_CRM_Payment_Invoice__c>([Select Id, (Select Id, ASI_CRM_Actual_Amount__c From Payment_Invoice_Lines__r) From ASI_CRM_Payment_Invoice__c Where Id In :invoiceIdSet]);
        integer approver_count = 0;
        if (oldMap == null) {
            for (ASI_CRM_Payment_Invoice__c detail : detailList) {
                if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice')){
                    for (ASI_CRM_Route_Type__c type:routeTypeList) {
                        System.debug('JP ' + type.ASI_CRM_Module_Record_Type__c + '  ' + rtMap.get(detail.recordtypeId).Name);
                        if (('JP ' + type.ASI_CRM_Module_Record_Type__c) == rtMap.get(detail.recordtypeId).Name) {
                            System.debug('Loop-1 Successed');
                            for (ASI_CRM_Role_Route_Type_Relationship__c relation:type.ASI_CRM_Role_Route_Type_Relationships__r) {
                                system.debug(ownerMap.get(detail.ownerId).UserRole.DeveloperName + '   ' + relation.name);
                                if (ownerMap.get(detail.ownerId).UserRole.DeveloperName == relation.name) {
                                    System.debug('Loop-2 Successed');
                                    clearApprovers(detail);
                                    approver_count = 0;
                                    Id[] strArray;
                                    strArray = new Id[10];
                                    strArray[0] = detail.ASI_CRM_Approver_1__c;
                                    for (ASI_CRM_Route_Rule_Detail__c rule:type.ASI_CRM_Route_Rule_Details__r) {
                                        System.debug('Loop-3 Successed');
                                        System.debug(rule.ASI_CRM_Threshold__c + '  ' + detail.ASI_CRM_Total_Invoice_Amount__c);
                                        if (rule.ASI_CRM_Threshold__c <= calcHighest(detail.Id)) {
                                            System.debug('Loop-4 Successed');
                                            if (approver_count == 0) {
                                                //detail.ASI_CRM_Approver_2__c = rule.ASI_CRM_Approver__c;
                                                strArray[1] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 1) {                                 
                                                //detail.ASI_CRM_Approver_3__c = rule.ASI_CRM_Approver__c;
                                                strArray[2] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 2) {                                 
                                                //detail.ASI_CRM_Approver_4__c = rule.ASI_CRM_Approver__c;
                                                strArray[3] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 3) {                                 
                                                //detail.ASI_CRM_Approver_5__c = rule.ASI_CRM_Approver__c;
                                                strArray[4] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 4) {                                 
                                                //detail.ASI_CRM_Approver_6__c = rule.ASI_CRM_Approver__c;
                                                strArray[5] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 5) {                                 
                                                //detail.ASI_CRM_Approver_7__c = rule.ASI_CRM_Approver__c;
                                                strArray[6] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 6) {                                 
                                                //detail.ASI_CRM_Approver_8__c = rule.ASI_CRM_Approver__c;
                                                strArray[7] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 7) {                                 
                                                //detail.ASI_CRM_Approver_9__c = rule.ASI_CRM_Approver__c;
                                                strArray[8] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 8) {                                 
                                                //detail.ASI_CRM_Approver_10__c = rule.ASI_CRM_Approver__c;
                                                strArray[9] = rule.ASI_CRM_Approver__c;
                                            } 
                                            approver_count++;
                                        }
                                    }
                                    Integer idx = 0;
                                    Integer cnt = 1;
                                    for(Integer num =0;num<10;num++){
                                        if(strArray[num] == detail.ASI_CRM_Approver_1__c){
                                            idx = num;
                                        }
                                    }
                                    for(Integer ind = idx;ind<10;ind++){
                                        if(cnt == 1 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_1__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 2 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_2__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 3 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_3__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 4 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_4__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 5 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_5__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 6 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_6__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 7 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_7__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 8 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_8__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 9 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_9__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 10 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_10__c = strArray[ind];
                                            cnt ++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }else {
            Map<ID, ASI_CRM_Payment_Invoice__c> oldDetailMap = (Map<ID, ASI_CRM_Payment_Invoice__c>) oldMap;
            for (ASI_CRM_Payment_Invoice__c detail: detailList) {
                if (Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('ASI_CRM_JP_SPTD_FOC_Invoice') &&
                    detail.ASI_CRM_Approver_2__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_2__c &&
                    detail.ASI_CRM_Approver_3__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_3__c &&
                    detail.ASI_CRM_Approver_4__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_4__c &&
                    detail.ASI_CRM_Approver_5__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_5__c &&
                    detail.ASI_CRM_Approver_6__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_6__c &&
                    detail.ASI_CRM_Approver_7__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_7__c &&
                    detail.ASI_CRM_Approver_7__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_8__c &&
                    detail.ASI_CRM_Approver_8__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_9__c &&
                    detail.ASI_CRM_Approver_10__c == oldDetailMap.get(detail.Id).ASI_CRM_Approver_10__c &&
                    detail.ASI_CRM_Sys_Allow_Submit_Approval__c == false &&
                    detail.ASI_CRM_Status__c == oldDetailMap.get(detail.Id).ASI_CRM_Status__c &&
                    detail.ASI_CRM_Status__c == 'Draft'){
                    for (ASI_CRM_Route_Type__c type:routeTypeList) {
                        if (('JP ' + type.ASI_CRM_Module_Record_Type__c) == rtMap.get(detail.recordtypeId).Name) {
                            for (ASI_CRM_Role_Route_Type_Relationship__c relation:type.ASI_CRM_Role_Route_Type_Relationships__r) {
                                if (ownerMap.get(detail.ownerId).UserRole.DeveloperName == relation.name) {
                                    clearApprovers(detail);
                                    approver_count = 0;
                                    Id[] strArray;
                                    strArray = new Id[10];
                                    strArray[0] = detail.ASI_CRM_Approver_1__c;
                                    for (ASI_CRM_Route_Rule_Detail__c rule:type.ASI_CRM_Route_Rule_Details__r) {
                                        if (rule.ASI_CRM_Threshold__c <= calcHighest(detail.Id)) {
                                            if (approver_count == 0) {
                                                //detail.ASI_CRM_Approver_2__c = rule.ASI_CRM_Approver__c;
                                                strArray[1] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 1) {                                 
                                                //detail.ASI_CRM_Approver_3__c = rule.ASI_CRM_Approver__c;
                                                strArray[2] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 2) {                                 
                                                //detail.ASI_CRM_Approver_4__c = rule.ASI_CRM_Approver__c;
                                                strArray[3] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 3) {                                 
                                                //detail.ASI_CRM_Approver_5__c = rule.ASI_CRM_Approver__c;
                                                strArray[4] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 4) {                                 
                                                //detail.ASI_CRM_Approver_6__c = rule.ASI_CRM_Approver__c;
                                                strArray[5] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 5) {                                 
                                                //detail.ASI_CRM_Approver_7__c = rule.ASI_CRM_Approver__c;
                                                strArray[6] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 6) {                                 
                                                //detail.ASI_CRM_Approver_8__c = rule.ASI_CRM_Approver__c;
                                                strArray[7] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 7) {                                 
                                                //detail.ASI_CRM_Approver_9__c = rule.ASI_CRM_Approver__c;
                                                strArray[8] = rule.ASI_CRM_Approver__c;
                                            }
                                            else if (approver_count == 8) {                                 
                                                //detail.ASI_CRM_Approver_10__c = rule.ASI_CRM_Approver__c;
                                                strArray[9] = rule.ASI_CRM_Approver__c;
                                            }                                                                                                  
                                            approver_count++;
                                        }
                                    }
                                    Integer idx = 0;
                                    Integer cnt = 1;
                                    for(Integer num =0;num<10;num++){
                                        if(strArray[num] == detail.ASI_CRM_Approver_1__c){
                                            idx = num;
                                        }
                                    }
                                    for(Integer ind = idx;ind<10;ind++){
                                        if(cnt == 1 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_1__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 2 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_2__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 3 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_3__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 4 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_4__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 5 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_5__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 6 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_6__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 7 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_7__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 8 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_8__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 9 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_9__c = strArray[ind];
                                            cnt ++;
                                        }else if(cnt == 10 && strArray[ind] != null){
                                            detail.ASI_CRM_Approver_10__c = strArray[ind];
                                            cnt ++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
    }
    
     private void clearApprovers(ASI_CRM_Payment_Invoice__c detail){
        detail.ASI_CRM_Approver_2__c = null;
        detail.ASI_CRM_Approver_3__c = null;
        detail.ASI_CRM_Approver_4__c = null;
        detail.ASI_CRM_Approver_5__c = null;
        detail.ASI_CRM_Approver_6__c = null;
        detail.ASI_CRM_Approver_7__c = null;
        detail.ASI_CRM_Approver_8__c = null;
        detail.ASI_CRM_Approver_9__c = null;
        detail.ASI_CRM_Approver_10__c = null;
    }
    
    private Decimal calcHighest(Id i){
        Decimal rst = 0;
        if (invoiceItemsMap.get(i) == null) {
            return rst;
        }
        for (ASI_CRM_Payment_Invoice_Line_Item__c item:invoiceItemsMap.get(i).Payment_Invoice_Lines__r) {
            if (item.ASI_CRM_Actual_Amount__c > rst){
                rst = item.ASI_CRM_Actual_Amount__c;
            }
        }
        return rst;
    }
    
    private Map<Id, ASI_CRM_Payment_Invoice__c> invoiceItemsMap;
}