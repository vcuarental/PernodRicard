/*********************************************************************************
 * Name:ASI_TnE_ClaimsDetailUpdateHeader
 * Description: Update Claims Header when Detail is insert&update&delete
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/3/2015         Laputa: Hank            Created
 * 25/07/2016       Laputa: Hugo Cheung     Updated. Change ASI_TnE_Payment_Amount__c to ASI_TnE_TW_Payment_Amount__c
*********************************************************************************/

public with sharing class ASI_TnE_ClaimsDetailUpdateHeader extends ASI_TnE_TriggerAbstract {

    public ASI_TnE_ClaimsDetailUpdateHeader() {
        super('ASI_TnE_ClaimsDetailUpdateHeader');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_TnE_ClaimDetail__c> detailList = (List<ASI_TnE_ClaimDetail__c>)sObjList;
        Set<Id> headerIdSet = new Set<Id>();
        if(oldMap == null){
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                headerIdSet.add(detail.ASI_TnE_ClaimHeader__c);
            }
        }else if(sObjList != null){
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_Receipt_Date__c != detailOldMap.get(detail.Id).ASI_TnE_Receipt_Date__c || detail.ASI_TnE_Expense_Classification__c != detailOldMap.get(detail.Id).ASI_TnE_Expense_Classification__c || Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('HK') ||
                        Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('TW') || detail.ASI_TnE_Expense_Category__c != detailOldMap.get(detail.Id).ASI_TnE_Expense_Category__c || detail.ASI_TnE_Receipt_Amount__c != detailOldMap.get(detail.Id).ASI_TnE_Receipt_Amount__c){
                    headerIdSet.add(detail.ASI_TnE_ClaimHeader__c);
                }
            }
        }else if(sObjList == null){
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailOldMap.values()){
                headerIdSet.add(detail.ASI_TnE_ClaimHeader__c);
            }
        }
        Map<Id, ASI_TnE_ClaimHeader__c> headerMap = new Map<Id, ASI_TnE_ClaimHeader__c>([Select ownerId, ASI_TnE_Sys_Exceed_Budget__c, ASI_TnE_Status__c, recordTypeid, ASI_TnE_Sys_Notified__c, Id, ASI_TnE_Payee_Employee__c,
                                                                                                ASI_TnE_Start_Date__c, ASI_TnE_End_Date__c, ASI_TnE_Sys_Approver_1__c, ASI_TnE_Sys_Approver_2__c, ASI_TnE_Sys_Approver_3__c, ASI_TnE_Total_Amount__c,
                                                                                                ASI_TnE_Sys_Approver_4__c, ASI_TnE_Sys_Approver_5__c, ASI_TnE_Sys_Approver_6__c, ASI_TnE_Sys_Approver_7__c, ASI_TnE_Sys_Last_Approver__c, ASI_TnE_Total_Amount_LCY__c,
                                                                                                (Select Id, ASI_TnE_HK_Payment_Amount__c, ASI_TnE_Payment_Amount__c, ASI_TnE_TW_Payment_Amount__c, ASI_TnE_Receipt_Date__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Approver__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_3__c,
                                                                                                ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_2__c, ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_4__c, ASI_TnE_Expense_Classification__r.ASI_TnE_BU_Finance__c From ASI_TnE_ClaimDetail__r) 
                                                                                                From ASI_TnE_ClaimHeader__c Where Id In :headerIdSet ]);     
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_TnE_ClaimHeader__c header:headerMap.values()){
            if(header.ASI_TnE_Payee_Employee__c == null){
                userIdSet.add(header.ownerId);
            }else{
                userIdSet.add(header.ASI_TnE_Payee_Employee__c); 
            }
        }
        
        //Get route type info 
        routeMap = new Map<String, ASI_TnE_Route_Type__c>();
        for(ASI_TnE_Route_Type__c route:[Select ASI_TnE_Company__c, ASI_TnE_Department__c, ASI_TnE_User__r.Name, (Select ASI_TnE_Approver_Type__c, ASI_TnE_Approver_Name__c,ASI_TnE_Amount_Threshold__c From ASI_TnE_Route_Rule_Details__r Order By Name ASC) From ASI_TnE_Route_Type__c WHERE NOT recordtype.DeveloperName LIKE '%Pre_Approval_Route_Type%']){
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
        ownerMap = new Map<Id, User>([Select Id, Name, ManagerId, Manager.ManagerId, CompanyName, Department From User Where Id In :userIdSet]);
        //managerMap = new Map<Id, User>([Select Id, Name, ManagerId, CompanyName, Department From User Where Id In :managerIdSet]);
        for(ASI_TnE_ClaimHeader__c header:headerMap.values()){
            Date startDate = null;
            Date endDate = null;
            routeTypeApprovers = new Id[7];
            additionalApprovers = new Id[7];
            if((Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TH') && header.ASI_TnE_Sys_Exceed_Budget__c) ||
                    Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TW')){
                insertSecMgrMap.put(header.Id, true);  
            }
            if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_HK') ||
                    Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_TW')){
                clearApprovers(header, CLEARONLY);
            }else{
                clearApprovers(header, CLEARANDINSERT);
            }
            Double ttl = 0;
            Boolean insertBU = false;
            for(ASI_TnE_ClaimDetail__c detail:header.ASI_TnE_ClaimDetail__r){
                if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_TW')) {
                    ttl += detail.ASI_TnE_TW_Payment_Amount__c != null ? detail.ASI_TnE_TW_Payment_Amount__c : 0; 
                } else {
                    ttl += detail.ASI_TnE_Payment_Amount__c;
                }
                if(startDate == null){
                    startDate = detail.ASI_TnE_Receipt_Date__c;
                }else{
                    if(detail.ASI_TnE_Receipt_Date__c < startDate){
                        startDate = detail.ASI_TnE_Receipt_Date__c;
                    }
                }
                if(endDate == null){
                    endDate = detail.ASI_TnE_Receipt_Date__c;
                }else{
                    if(detail.ASI_TnE_Receipt_Date__c > endDate){
                        endDate = detail.ASI_TnE_Receipt_Date__c;
                    }
                }
                //Update approvers for Claim Header
                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver__c);
                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_2__c);
                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_3__c);
                insertAddApprover(header, detail.ASI_TnE_Expense_Classification__r.ASI_TnE_Approver_4__c);
                if(detail.ASI_TnE_Expense_Classification__r.ASI_TnE_BU_Finance__c){
                    insertBU = true;
                }
            }
            totalAmtMap.put(header.Id,ttl);
            header.ASI_TnE_Start_Date__c = startDate;
            header.ASI_TnE_End_Date__c = endDate;
            if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_HK') ||
                    Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('TnE_TW')){
                clearApprovers(header, INSERTONLY);
                if(insertBU == true && buApprover != null){
                    checkForInsert(header, buApprover);    
                }
            }
            insertApprovers(header);
        }
        if(oldMap == null){
           
        }else if(sObjList != null){
            Map<Id, ASI_TnE_ClaimDetail__c> detailOldMap = (Map<Id, ASI_TnE_ClaimDetail__c>)oldMap;
            for(ASI_TnE_ClaimDetail__c detail:detailList){
                if(detail.ASI_TnE_Expense_Classification__c != detailOldMap.get(detail.Id).ASI_TnE_Expense_Classification__c || Global_RecordTypeCache.getRt(detail.recordTypeid).developerName.contains('HK') ||
                        detail.ASI_TnE_Expense_Category__c != detailOldMap.get(detail.Id).ASI_TnE_Expense_Category__c || detail.ASI_TnE_Receipt_Amount__c != detailOldMap.get(detail.Id).ASI_TnE_Receipt_Amount__c){
                    if(headerMap.get(detail.ASI_TnE_ClaimHeader__c) != null && headerMap.get(detail.ASI_TnE_ClaimHeader__c).ASI_TnE_Status__c == 'Approved'){
                        headerMap.get(detail.ASI_TnE_ClaimHeader__c).ASI_TnE_Sys_Notified__c = true;
                    }    
                }
            }
        }else if(sObjList == null){
            
        }
        update headerMap.values();
    }
    
    private Map<String, ASI_TnE_Route_Type__c> routeMap;
    private Map<Id, Boolean> insertSecMgrMap = new Map<Id, Boolean>();
    private Map<Id, Double> totalAmtMap = new Map<Id,Double>();
    //private Map<Id, User> managerMap;
    private Map<Id, User> ownerMap;
    private Id buApprover = null;
    private Id[] routeTypeApprovers = new Id[7];
    private Id[] additionalApprovers = new Id[7];
    //Below functions are for approval process
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
            fillNextApprover(header, routeTypeApprovers, approverId);
            return true;
        }
    }
    
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
        }
        if(opt == INSERTONLY || opt == CLEARANDINSERT){
            Id userId = header.ASI_TnE_Payee_Employee__c == null?header.ownerId:header.ASI_TnE_Payee_Employee__c;
            String key1 = (ownerMap.get(userId).CompanyName == null?'':ownerMap.get(userId).CompanyName) +
                          (ownerMap.get(userId).Department == null?'':ownerMap.get(userId).Department);
            String key2 = userId;
            if(routeMap.get(key2) != null){
                key1 = key2;
            }
            if(routeMap.get(key1) != null){
                Boolean isSecMgr = false;
                Id lastUser = null;
                for(ASI_TnE_Route_Rule_Detail__c detail:routeMap.get(key1).ASI_TnE_Route_Rule_Details__r){
                    if(!isSecMgr && detail.ASI_TnE_Approver_Type__c == 'Line Manager'){
                        checkForInsert(header, ownerMap.get(userId).ManagerId);
                        isSecMgr = true;
                    }else if(isSecMgr && detail.ASI_TnE_Approver_Type__c == 'Line Manager'){
                        if(insertSecMgrMap.get(header.Id) != null && insertSecMgrMap.get(header.Id) == true){
                            if(lastUser == null){
                                checkForInsert(header, ownerMap.get(userId).Manager.ManagerId);
                            }else{
                                checkForInsert(header, ownerMap.get(lastUser).ManagerId);
                            } 
                        }   
                    }else if(detail.ASI_TnE_Approver_Type__c == 'User'){
                        if(isSecMgr){
                            lastUser = detail.ASI_TnE_Approver_Name__c;    
                        }
                        checkForInsert(header, detail.ASI_TnE_Approver_Name__c);
                    }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK') && detail.ASI_TnE_Approver_Type__c == 'Checker'){
                        header.ASI_TnE_Checker__c = detail.ASI_TnE_Approver_Name__c;
                    }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_TW') && detail.ASI_TnE_Approver_Type__c == 'Additional Approver'){
                        system.debug('Check Additional Approver, Total: ' + header.ASI_TnE_Total_Amount__c + ' threshold: ' + detail.ASI_TnE_Amount_Threshold__c);
                        if(totalAmtMap.get(header.Id) >= detail.ASI_TnE_Amount_Threshold__c){
                            checkForInsert(header, detail.ASI_TnE_Approver_Name__c);
                        }
                    }else if(Global_RecordTypeCache.getRt(header.recordTypeid).developerName.contains('ASI_TnE_HK') && detail.ASI_TnE_Approver_Type__c == 'BU Finance'){
                        buApprover = detail.ASI_TnE_Approver_Name__c;
                    }
                }
            }
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
                    insertNextApprover(header,approver);
                }
            }
            for(Id approver: additionalApprovers){
                if(approver!= null){
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