/*********************************************************************************
 * Name:ASI_TnE_CashAdvApprovalProcess
 * Description: Assign approvers for Cash Advance Pre-Approval
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/01/2016        Laputa: Hank            Created
*********************************************************************************/

public with sharing class ASI_TnE_CashAdvApprovalProcess extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_CashAdvApprovalProcess() {
        super('ASI_TnE_CashAdvApprovalProcess');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_TnE_Cash_Advance_Pre_Approval__c> headerList = (List<ASI_TnE_Cash_Advance_Pre_Approval__c>)sObjList;
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> headerIdSet = new Set<Id>();
        if(oldMap == null){
            //Get user id depends on payee is empty or not
            for(ASI_TnE_Cash_Advance_Pre_Approval__c header:headerList){
                if(header.ASI_TnE_Requested_Employee__c == null){
                    userIdSet.add(header.ownerId);
                }else{
                    userIdSet.add(header.ASI_TnE_Requested_Employee__c); 
                }
            }
        }else{
            Map<Id, ASI_TnE_Cash_Advance_Pre_Approval__c> oldCashAdvMap = (Map<Id, ASI_TnE_Cash_Advance_Pre_Approval__c>) oldMap;
            for(ASI_TnE_Cash_Advance_Pre_Approval__c header:headerList){
                if(header.ownerId != oldCashAdvMap.get(header.Id).ownerId || header.ASI_TnE_Requested_Employee__c != oldCashAdvMap.get(header.Id).ASI_TnE_Requested_Employee__c || header.ASI_TnE_Company__c != oldCashAdvMap.get(header.Id).ASI_TnE_Company__c ||
                        header.ASI_TnE_Department_Division__c != oldCashAdvMap.get(header.Id).ASI_TnE_Department_Division__c || (header.ASI_TnE_Sys_Approver_1__c == null && header.ASI_TnE_Sys_Approver_1__c != oldCashAdvMap.get(header.Id).ASI_TnE_Sys_Approver_1__c)){
                    if(header.ASI_TnE_Requested_Employee__c == null){
                        userIdSet.add(header.ownerId);
                    }else{
                        userIdSet.add(header.ASI_TnE_Requested_Employee__c); 
                    }
                }
            }
        }
        
        //Get route type info 
        routeMap = new Map<String, ASI_TnE_Route_Type__c>();
        for(ASI_TnE_Route_Type__c route:[Select ASI_TnE_Company__c, ASI_TnE_Department__c, ASI_TnE_User__r.Id, (Select ASI_TnE_Approver_Type__c, ASI_TnE_Approver_Name__c,ASI_TnE_Amount_Threshold__c From ASI_TnE_Route_Rule_Details__r Order By Name ASC) From ASI_TnE_Route_Type__c Where Recordtype.DeveloperName = 'ASI_TnE_SG_Cash_Advance_Pre_Approval_Route_Type']){
            if(route.ASI_TnE_User__r.Id == null){
                routeMap.put((route.ASI_TnE_Company__c == null?'':route.ASI_TnE_Company__c) + 
                             (route.ASI_TnE_Department__c == null?'':route.ASI_TnE_Department__c), route);
            }else{
                routeMap.put((route.ASI_TnE_User__r.Id == null?'':route.ASI_TnE_User__r.Id), route);
            }
            for(ASI_TnE_Route_Rule_Detail__c detail:route.ASI_TnE_Route_Rule_Details__r){
                if(detail.ASI_TnE_Approver_Name__c != null){
                    userIdSet.add(detail.ASI_TnE_Approver_Name__c);
                }
            }
        }
        
        //Get info from user
        ownerMap = new Map<Id, User>([Select Id, Name, ManagerId, Manager.ManagerId, CompanyName, ASI_Department__c  From User Where Id In :userIdSet]);
        
        if(oldMap == null){
            //Assign approvers
            for(ASI_TnE_Cash_Advance_Pre_Approval__c header:headerList){
                routeTypeApprovers = new Id[7];
                clearApprovers(header, CLEARANDINSERT);
                insertApprovers(header);
            }
        }else{
            Map<Id, ASI_TnE_Cash_Advance_Pre_Approval__c> oldCashAdvMap = (Map<Id, ASI_TnE_Cash_Advance_Pre_Approval__c>) oldMap;
            for(ASI_TnE_Cash_Advance_Pre_Approval__c header:headerList){
                routeTypeApprovers = new Id[7];
                if(header.ownerId != oldCashAdvMap.get(header.Id).ownerId || header.ASI_TnE_Requested_Employee__c != oldCashAdvMap.get(header.Id).ASI_TnE_Requested_Employee__c || header.ASI_TnE_Company__c != oldCashAdvMap.get(header.Id).ASI_TnE_Company__c ||
                    header.ASI_TnE_Department_Division__c != oldCashAdvMap.get(header.Id).ASI_TnE_Department_Division__c || (header.ASI_TnE_Sys_Approver_1__c == null && header.ASI_TnE_Sys_Approver_1__c != oldCashAdvMap.get(header.Id).ASI_TnE_Sys_Approver_1__c)){
                    clearApprovers(header, CLEARANDINSERT);
                    insertApprovers(header);
                }
            }
        }
    }
    private void fillNextApprover(ASI_TnE_Cash_Advance_Pre_Approval__c header, Id[] approvers, Id ApproverId){
        if(approvers[0] == null){
            approvers[0] = ApproverId;
        }else if(approvers[1] == null){
            approvers[1] = ApproverId;
        }else if(approvers[2] == null){
            approvers[2] = ApproverId;
        }else if(approvers[3] == null){
            approvers[3] = ApproverId;
        }else if(approvers[4] == null){
            approvers[4] = ApproverId;
        }else if(approvers[5] == null){
            approvers[5] = ApproverId;
        }else if(approvers[6] == null){
            approvers[6] = ApproverId;
        }
    }
    
    private Map<String, ASI_TnE_Route_Type__c> routeMap;
    private Map<Id, User> ownerMap;
    private Id[] routeTypeApprovers = new Id[7];    static final Integer CLEARONLY = 1;
    static final Integer INSERTONLY = 2;
    static final Integer CLEARANDINSERT = 3;
    private void clearApprovers(ASI_TnE_Cash_Advance_Pre_Approval__c header, Integer opt){
        if(opt == CLEARONLY || opt == CLEARANDINSERT){
            header.ASI_TnE_Sys_Approver_1__c = null;
            header.ASI_TnE_Sys_Approver_2__c = null;
            header.ASI_TnE_Sys_Approver_3__c = null;
            header.ASI_TnE_Sys_Approver_4__c = null;
            header.ASI_TnE_Sys_Approver_5__c = null;
            header.ASI_TnE_Sys_Approver_6__c = null;
            header.ASI_TnE_Sys_Approver_7__c = null;
        }
        if(opt == INSERTONLY || opt == CLEARANDINSERT){
            Id userId = header.ASI_TnE_Requested_Employee__c == null?header.ownerId:header.ASI_TnE_Requested_Employee__c;
            String key1 = (ownerMap.get(userId).CompanyName == null?'':ownerMap.get(userId).CompanyName) +
                          (ownerMap.get(userId).ASI_Department__c  == null?'':ownerMap.get(userId).ASI_Department__c );
            String key2 = userId;
            if(routeMap.get(key2) != null){
                key1 = key2;
            }
            if(routeMap.get(key1) != null){
                for(ASI_TnE_Route_Rule_Detail__c detail:routeMap.get(key1).ASI_TnE_Route_Rule_Details__r){
                    if(detail.ASI_TnE_Approver_Type__c == 'Line Manager'){
                        checkForInsert(header, ownerMap.get(userId).ManagerId);
                    }else if(detail.ASI_TnE_Approver_Type__c == 'User'){
                        checkForInsert(header, detail.ASI_TnE_Approver_Name__c);
                    }
                }
            }
        }
    }
    
    private Boolean checkForInsert(ASI_TnE_Cash_Advance_Pre_Approval__c header, Id approverId){
        System.debug('------ approverId ------ : ' + approverId);
        System.debug('------ routeTypeApprovers ------ : ' + routeTypeApprovers);
        if(approverId == null){
            return false;
        }else if(routeTypeApprovers[0] == approverId){
            routeTypeApprovers[1] = null;
            routeTypeApprovers[2] = null;
            routeTypeApprovers[3] = null;
            routeTypeApprovers[4] = null;
            routeTypeApprovers[5] = null;
            routeTypeApprovers[6] = null;
            return false;
        }else if(routeTypeApprovers[1] == approverId){
            routeTypeApprovers[2] = null;
            routeTypeApprovers[3] = null;
            routeTypeApprovers[4] = null;
            routeTypeApprovers[5] = null;
            routeTypeApprovers[6] = null;
            return false;
        }else if(routeTypeApprovers[2] == approverId){
            routeTypeApprovers[3] = null;
            routeTypeApprovers[4] = null;
            routeTypeApprovers[5] = null;
            routeTypeApprovers[6] = null;
            return false;
        }else if(routeTypeApprovers[3] == approverId){
            routeTypeApprovers[4] = null;
            routeTypeApprovers[5] = null;
            routeTypeApprovers[6] = null;
            return false;
        }else if(routeTypeApprovers[4] == approverId){
            routeTypeApprovers[5] = null;
            routeTypeApprovers[6] = null;
            return false;
        }else if(routeTypeApprovers[5] == approverId){
            routeTypeApprovers[6] = null;
            return false;
        }else if(routeTypeApprovers[6] == approverId){
            return false;
        }else if(header.OwnerId == approverId){
            return false;
        }else{
            fillNextApprover(header, routeTypeApprovers, approverId);
            return true;
        }
    }
    
    private void insertApprovers(ASI_TnE_Cash_Advance_Pre_Approval__c header){
        if(routeTypeApprovers[0] == null){
            return;
        }
        
        for(Id approver: routeTypeApprovers){
            if(approver!= null){
                insertNextApprover(header,approver);
            }
        }    
    }
    
    private void insertNextApprover(ASI_TnE_Cash_Advance_Pre_Approval__c header, Id ApproverId){
        if(header.ASI_TnE_Sys_Approver_1__c == null){
            header.ASI_TnE_Sys_Approver_1__c = ApproverId;
        }else if(header.ASI_TnE_Sys_Approver_2__c == null){
            header.ASI_TnE_Sys_Approver_2__c = ApproverId;
        }else if(header.ASI_TnE_Sys_Approver_3__c == null){
            header.ASI_TnE_Sys_Approver_3__c = ApproverId;
        }else if(header.ASI_TnE_Sys_Approver_4__c == null){
            header.ASI_TnE_Sys_Approver_4__c = ApproverId;
        }else if(header.ASI_TnE_Sys_Approver_5__c == null){
            header.ASI_TnE_Sys_Approver_5__c = ApproverId;
        }else if(header.ASI_TnE_Sys_Approver_6__c == null){
            header.ASI_TnE_Sys_Approver_6__c = ApproverId;
        }else if(header.ASI_TnE_Sys_Approver_7__c == null){
            header.ASI_TnE_Sys_Approver_7__c = ApproverId;
        }  
    }
}