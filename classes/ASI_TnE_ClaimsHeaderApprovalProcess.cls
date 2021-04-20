/*********************************************************************************
 * Name:ASI_TnE_ClaimsHeaderApprovalProcess
 * Description: Assign approvers for Claim Header
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 17/3/2015        Laputa: Hank            Created
 * 25/07/2016       Laputa: Hugo Cheung     Updated. Change ASI_TnE_Total_Amount__c field to ASI_TnE_TW_Total_Amount__c
 * 12/03/2019       SH                      Updated. Check ASI Department instead of standard Department when retrieving Route Type
*********************************************************************************/

public with sharing class ASI_TnE_ClaimsHeaderApprovalProcess extends ASI_TnE_TriggerAbstract {

    private Map<String, String> claimHeaderRouteTypeRecordTypeMap = new Map<String, String> 
                                                                    {'ASI_TnE_HK_Claim_Header'         => 'ASI_TnE_HK_Route_Type',
                                                                     'ASI_TnE_HK_Claim_Header_Finance' => 'ASI_TnE_HK_Route_Type',
                                                                     'ASI_TnE_ID_Cash_Advance_Header'  => 'ASI_TnE_ID_Route_Type',
                                                                     'ASI_TnE_ID_Claim_Header'         => 'ASI_TnE_ID_Route_Type',
                                                                     'ASI_TnE_ID_Claim_Header_Finance' => 'ASI_TnE_ID_Route_Type',
                                                                     'ASI_TnE_KH_Cash_Advance_Header'  => 'ASI_TnE_SG_Route_Type',     // Added by 2018-02-11 Linus@introv
                                                                     'ASI_TnE_KH_Claim_Header'         => 'ASI_TnE_SG_Route_Type',
                                                                     'ASI_TnE_KH_Claim_Header_Finance' => 'ASI_TnE_SG_Route_Type',
                                                                     'ASI_TnE_MY_Cash_Advance_Header'  => 'ASI_TnE_MY_Route_Type',
                                                                     'ASI_TnE_MY_Claim_Header'         => 'ASI_TnE_MY_Route_Type',
                                                                     'ASI_TnE_MY_Claim_Header_Finance' => 'ASI_TnE_MY_Route_Type',
                                                                     'ASI_TnE_PH_Cash_Advance_Header'  => 'ASI_TnE_PH_Route_Type',
                                                                     'ASI_TnE_PH_Claim_Header'         => 'ASI_TnE_PH_Route_Type',
                                                                     'ASI_TnE_PH_Claim_Header_Finance' => 'ASI_TnE_PH_Route_Type',
                                                                     'ASI_TnE_SG_Cash_Advance_Header'  => 'ASI_TnE_SG_Route_Type',
                                                                     'ASI_TnE_SG_Claim_Header'         => 'ASI_TnE_SG_Route_Type',
                                                                     'ASI_TnE_SG_Claim_Header_Finance' => 'ASI_TnE_SG_Route_Type',
                                                                     'ASI_TnE_TH_Cash_Advance_Header'  => 'ASI_TnE_TH_Route_Type',
                                                                     'ASI_TnE_TH_Claim_Header'         => 'ASI_TnE_TH_Route_Type',
                                                                     'ASI_TnE_TH_Claim_Header_Finance' => 'ASI_TnE_TH_Route_Type',
                                                                     'ASI_TnE_TW_Cash_Advance_Header'  => 'ASI_TnE_TW_Route_Type',
                                                                     'ASI_TnE_TW_Claim_Header'         => 'ASI_TnE_TW_Route_Type',
                                                                     'ASI_TnE_TW_Claim_Header_Finance' => 'ASI_TnE_TW_Route_Type'};

    public ASI_TnE_ClaimsHeaderApprovalProcess() {
        super('ASI_TnE_ClaimsHeaderApprovalProcess');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
System.debug('line41');
        List<ASI_TnE_ClaimHeader__c> headerList = (List<ASI_TnE_ClaimHeader__c>)sObjList;
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> headerIdSet = new Set<Id>();
        if(oldMap == null){
            //Get user id depends on payee is empty or not
            for(ASI_TnE_ClaimHeader__c header:headerList){
                if(header.ASI_TnE_Payee_Employee__c == null){
                    userIdSet.add(header.ownerId);
                }else{
                    userIdSet.add(header.ASI_TnE_Payee_Employee__c); 
                }
            }
            System.debug('line54');
        }else{
            Map<Id, ASI_TnE_ClaimHeader__c> oldClaimMap = (Map<Id, ASI_TnE_ClaimHeader__c>) oldMap;
            for(ASI_TnE_ClaimHeader__c header:headerList){
                if(header.ownerId != oldClaimMap.get(header.Id).ownerId || header.ASI_TnE_Payee_Employee__c != oldClaimMap.get(header.Id).ASI_TnE_Payee_Employee__c || header.ASI_TnE_Sys_Exceed_Budget__c || header.ASI_TnE_Sys_Exceed_Budget__c != oldClaimMap.get(header.Id).ASI_TnE_Sys_Exceed_Budget__c ||
                   (header.ASI_TnE_Sys_Approver_1__c == null && header.ASI_TnE_Sys_Approver_1__c != oldClaimMap.get(header.Id).ASI_TnE_Sys_Approver_1__c) ||
                   (Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK'))){
                    headerIdSet.add(header.Id);
                    if(header.ASI_TnE_Payee_Employee__c == null){
                        userIdSet.add(header.ownerId);
                    }else{
                        userIdSet.add(header.ASI_TnE_Payee_Employee__c); 
                    }
                }
            }
            System.debug('line69');
        }
        
        //Get route type info 
        routeMap = new Map<String, ASI_TnE_Route_Type__c>();
        for(ASI_TnE_Route_Type__c route:[Select ASI_TnE_Company__c, ASI_TnE_Department__c, ASI_TnE_User__r.Id, RecordType.DeveloperName, (Select ASI_TnE_Approver_Type__c, ASI_TnE_Approver_Name__c,ASI_TnE_Amount_Threshold__c From ASI_TnE_Route_Rule_Details__r Order By Name ASC) From ASI_TnE_Route_Type__c where NOT recordtype.DeveloperName LIKE '%Pre_Approval_Route_Type%']){
            if(route.ASI_TnE_User__r.Id == null){
                routeMap.put((route.ASI_TnE_Company__c == null?'':route.ASI_TnE_Company__c) + 
                             (route.ASI_TnE_Department__c == null?'':route.ASI_TnE_Department__c) + 
                             route.RecordType.DeveloperName, route);
                             System.debug('line79');
            }else{
                routeMap.put((route.ASI_TnE_User__r.Id == null?'':route.ASI_TnE_User__r.Id) + 
                             route.RecordType.DeveloperName, route);
                             System.debug('line83');
            }
            for(ASI_TnE_Route_Rule_Detail__c detail:route.ASI_TnE_Route_Rule_Details__r){
                if(detail.ASI_TnE_Approver_Name__c != null){
                    userIdSet.add(detail.ASI_TnE_Approver_Name__c);
                    System.debug('line88');
                }
            }
        }
        
        //Get info from user
        ownerMap = new Map<Id, User>([Select Id, Name, ManagerId, Manager.ManagerId, CompanyName, Department, ASI_Company_Name__c, ASI_Department__c From User Where Id In :userIdSet]);
        //managerMap = new Map<Id, User>([Select Id, Name, ManagerId, CompanyName, Department From User Where Id In :managerIdSet]);
        Map<Id, ASI_TnE_ClaimHeader__c> headerMap = new Map<Id, ASI_TnE_ClaimHeader__c>([Select ownerId, Id, ASI_TnE_Payee_Employee__c, (Select Id, ASI_TnE_Expense_Classification__r.ASI_TnE_Approver__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_4__c,
                                                                                         ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_2__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_3__c, ASI_TnE_Expense_Classification__r.ASI_TnE_BU_Finance__c From ASI_TnE_ClaimDetail__r) 
                                                                                         From ASI_TnE_ClaimHeader__c Where Id In :headerIdSet ]);  
        
        if(oldMap == null){
            //Assign approvers
            for(ASI_TnE_ClaimHeader__c header:headerList){
                routeTypeApprovers = new Id[7];
                additionalApprovers = new Id[7];
                clearApprovers(header, CLEARANDINSERT);
                insertApprovers(header);
            }
            System.debug('line108');
        }else{
            Map<Id, ASI_TnE_ClaimHeader__c> oldClaimMap = (Map<Id, ASI_TnE_ClaimHeader__c>) oldMap;
            for(ASI_TnE_ClaimHeader__c header:headerList){
                routeTypeApprovers = new Id[7];
                additionalApprovers = new Id[7];
                if(header.ownerId != oldClaimMap.get(header.Id).ownerId || header.ASI_TnE_Payee_Employee__c != oldClaimMap.get(header.Id).ASI_TnE_Payee_Employee__c || header.ASI_TnE_Sys_Exceed_Budget__c || header.ASI_TnE_Sys_Exceed_Budget__c != oldClaimMap.get(header.Id).ASI_TnE_Sys_Exceed_Budget__c || 
                   (header.ASI_TnE_Sys_Approver_1__c == null && header.ASI_TnE_Sys_Approver_1__c != oldClaimMap.get(header.Id).ASI_TnE_Sys_Approver_1__c) || 
                   (Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK'))){
                    if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK') ||
                            Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TW')){
                        if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TW')){
                            insertSecMgrMap.put(header.Id, true);    
                        }
                        clearApprovers(header, CLEARONLY);
                        Boolean insertBU = false;
                        if(headerMap.get(header.Id) != null && headerMap.get(header.Id).ASI_TnE_ClaimDetail__r != null){
                            for(ASI_TnE_ClaimDetail__c detail:headerMap.get(header.Id).ASI_TnE_ClaimDetail__r){
                                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver__c);
                                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_2__c);
                                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_3__c);
                                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_4__c);
                                if(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_BU_Finance__c){
                                    insertBU = true;
                                }
                            }
                        }
                        clearApprovers(header, INSERTONLY);
                        if(insertBU == true && buApprover != null){
                            checkForInsert(header, buApprover);    
                        }
                        insertApprovers(header);
                    }else{
                        if((Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TH') && header.ASI_TnE_Sys_Exceed_Budget__c) ||
                                Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TW')){
                                System.debug('line143');
                            insertSecMgrMap.put(header.Id, true);    
                        }
                        clearApprovers(header, CLEARANDINSERT);
                        if(headerMap.get(header.Id).ASI_TnE_ClaimDetail__r != null){
                            for(ASI_TnE_ClaimDetail__c detail:headerMap.get(header.Id).ASI_TnE_ClaimDetail__r){
                            System.debug('line149');
                                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver__c);
                                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_2__c);
                                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_3__c);
                                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_4__c);
                            }
                        }
                        insertApprovers(header);
                    }
                }   
            }
        }
        
        //20161130 Wilken, update Company Code into unused Company field for sharing rule
        for(ASI_TnE_ClaimHeader__c header:headerList){
            if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK'))
                header.ASI_TnE_KR_Company__c = header.ASI_TnE_Company_Code__c;
        }
        
    }
    private void fillNextApprover(ASI_TnE_ClaimHeader__c header, Id[] approvers, Id ApproverId){
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
        header.ASI_TnE_Sys_Last_Approver__c = ApproverId;
    }
    
    private Map<String, ASI_TnE_Route_Type__c> routeMap;
    private Map<Id, User> ownerMap;
    //private Map<Id, User> managerMap;
    private Map<Id, Boolean> insertSecMgrMap = new Map<Id, Boolean>();
    private Id[] routeTypeApprovers = new Id[7];
    private Id[] additionalApprovers = new Id[7];
    private Id buApprover = null;
    static final Integer CLEARONLY = 1;
    static final Integer INSERTONLY = 2;
    static final Integer CLEARANDINSERT = 3;
    private void clearApprovers(ASI_TnE_ClaimHeader__c header, Integer opt){
        if(opt == CLEARONLY || opt == CLEARANDINSERT){
            header.ASI_TnE_Sys_Approver_1__c = null;
            header.ASI_TnE_Sys_Approver_2__c = null;
            header.ASI_TnE_Sys_Approver_3__c = null;
            header.ASI_TnE_Sys_Approver_4__c = null;
            header.ASI_TnE_Sys_Approver_5__c = null;
            header.ASI_TnE_Sys_Approver_6__c = null;
            header.ASI_TnE_Sys_Approver_7__c = null;
            header.ASI_TnE_Sys_Last_Approver__c = null;
            if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK')) {
                header.ASI_TnE_Checker__c = null;
            }
        }
        if(opt == INSERTONLY || opt == CLEARANDINSERT){
            Id userId = header.ASI_TnE_Payee_Employee__c == null?header.ownerId:header.ASI_TnE_Payee_Employee__c;
            String key1 = '';
            String key2 = userId + claimHeaderRouteTypeRecordTypeMap.get(Global_RecordTypeCache.getRt(header.RecordTypeId).DeveloperName);
            // [SH] 2019-03-11 Check 'ASI Department' instead 
            /*if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK')) {
                key1 = (ownerMap.get(userId).ASI_Company_Name__c == null?'':ownerMap.get(userId).ASI_Company_Name__c) +
                       (ownerMap.get(userId).ASI_Department__c == null?'':ownerMap.get(userId).ASI_Department__c) + 
                       claimHeaderRouteTypeRecordTypeMap.get(Global_RecordTypeCache.getRt(header.RecordTypeId).DeveloperName);
            } else { 
                key1 = (ownerMap.get(userId).CompanyName == null?'':ownerMap.get(userId).CompanyName) +
                       (ownerMap.get(userId).Department == null?'':ownerMap.get(userId).Department) + 
                       claimHeaderRouteTypeRecordTypeMap.get(Global_RecordTypeCache.getRt(header.RecordTypeId).DeveloperName);
            }
			*/
            key1 = (ownerMap.get(userId).CompanyName == null?'':ownerMap.get(userId).CompanyName) +
                       (ownerMap.get(userId).ASI_Department__c == null?'':ownerMap.get(userId).ASI_Department__c) + 
                       claimHeaderRouteTypeRecordTypeMap.get(Global_RecordTypeCache.getRt(header.RecordTypeId).DeveloperName);
            
            System.debug('Debug Log : ' + key1);
            System.debug('Debug Log : ' + key2);
            if(routeMap.get(key2) != null){
                key1 = key2;
                System.debug('line229');
            }
            if(routeMap.get(key1) != null){
                Boolean isSecMgr = false;
                Id lastUser = null;
                for(ASI_TnE_Route_Rule_Detail__c detail:routeMap.get(key1).ASI_TnE_Route_Rule_Details__r){
                    if(!isSecMgr && detail.ASI_TnE_Approver_Type__c == 'Line Manager'){
                        checkForInsert(header, ownerMap.get(userId).ManagerId);
                        isSecMgr = true;
                        System.debug('line238');
                    }else if(isSecMgr && detail.ASI_TnE_Approver_Type__c == 'Line Manager'){
                        if(insertSecMgrMap.get(header.Id) != null && insertSecMgrMap.get(header.Id) == true){
                            if(lastUser == null){
                                checkForInsert(header, ownerMap.get(userId).Manager.ManagerId);
                                System.debug('line243');
                            }else{
                                checkForInsert(header, ownerMap.get(lastUser).ManagerId);
                                System.debug('line246');
                            } 
                        }   
                    }else if(detail.ASI_TnE_Approver_Type__c == 'User'){
                        if(isSecMgr){
                            lastUser = detail.ASI_TnE_Approver_Name__c;    
                            System.debug('line252');
                        }
                        checkForInsert(header, detail.ASI_TnE_Approver_Name__c);
                        System.debug('line255');
                    }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK') && detail.ASI_TnE_Approver_Type__c == 'Checker'){
                        header.ASI_TnE_Checker__c = detail.ASI_TnE_Approver_Name__c;
                    }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TW') && detail.ASI_TnE_Approver_Type__c == 'Additional Approver'){
                        system.debug('Check Additional Approver, Total: ' + header.ASI_TnE_TW_Total_Amount__c + ' threshold: ' + detail.ASI_TnE_Amount_Threshold__c);
                        if(header.ASI_TnE_TW_Total_Amount__c >= detail.ASI_TnE_Amount_Threshold__c){
                            checkForInsert(header, detail.ASI_TnE_Approver_Name__c);
                        }
                    }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK') && detail.ASI_TnE_Approver_Type__c == 'BU Finance'){
                        buApprover = detail.ASI_TnE_Approver_Name__c;
                    }
                }
            }
        }
    }
    
    private Boolean checkForInsert(ASI_TnE_ClaimHeader__c header, Id approverId){
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
        System.debug('line312');
            fillNextApprover(header, routeTypeApprovers, approverId);
            return true;
        }
    }
    
    private Boolean insertAddApprover(ASI_TnE_ClaimHeader__c header, Id approverId){
        if(approverId == null){
            return false;
        }else if(additionalApprovers[0] == approverId){
            return false;
        }else if(additionalApprovers[1] == approverId){
            return false;
        }else if(additionalApprovers[2] == approverId){
            return false;
        }else if(additionalApprovers[3] == approverId){
            return false;
        }else if(additionalApprovers[4] == approverId){
            return false;
        }else if(additionalApprovers[5] == approverId){
            return false;
        }else if(additionalApprovers[6] == approverId){
            return false;
        }else if(header.OwnerId == approverId){
            return false;
        }else{
        System.debug('line338');
            fillNextApprover(header, additionalApprovers, approverId);
            return true;
        }
    }
    
    private void insertApprovers(ASI_TnE_ClaimHeader__c header){
        if(routeTypeApprovers[0] == null && additionalApprovers[0] == null){
            return;
        }
        if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK') ||
                Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TW')){
            for(Id approver: additionalApprovers){
                if(approver!= null){
                    insertNextApprover(header,approver);
                }
            }
            for(Id approver: routeTypeApprovers){
                if(approver!= null){
                    insertNextApprover(header,approver);
                }
            }   
        }else{
            for(Id approver: routeTypeApprovers){
                if(approver!= null){
                System.debug('line363');
                    insertNextApprover(header,approver);
                }
            }
            for(Id approver: additionalApprovers){
                if(approver!= null){
                System.debug('line369');
                    insertNextApprover(header,approver);
                }
            }
        }  
    }
    
    private void insertNextApprover(ASI_TnE_ClaimHeader__c header, Id ApproverId){
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