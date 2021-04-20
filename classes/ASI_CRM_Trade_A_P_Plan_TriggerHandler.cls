/*********************************************************************************
 * Name: ASI_CRM_Trade_A_P_Plan_TriggerHandler
 * Description: Trigger Handler for Object Trade A&P Plan
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/01/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_Trade_A_P_Plan_TriggerHandler {
    
    private final static String SUBMITTED_STATUS = 'Submitted';
    private final static String APPROVED_STATUS = 'Approved';
    
    private final static Id PLAN_ITEM_READ_ONLY_RECORD_TYPE = Global_RecordTypeCache.getRtId('ASI_CRM_Trade_A_P_Plan_Item__c' + 'ASI_CRM_VN_Promotion_Plan_Item_Read_Only');
    
    //Error Message
    private final static String DELETE_ERROR_MESSAGE = 'Cannot delete approved/submitted Promotion Plan!';
    
    public ASI_CRM_Trade_A_P_Plan_TriggerHandler() {
    }
    
    public void beforeInsertTrigger(List<sObject> newList) {
        List<ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanList = (List<ASI_CRM_Trade_A_P_Plan__c>) newList;
        
        beforeInsertProcess(tradeAPPlanList);
    }
    
    public void afterUpdateTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanList = (List<ASI_CRM_Trade_A_P_Plan__c>) newList;
        Map<Id, ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanMap = (Map<Id, ASI_CRM_Trade_A_P_Plan__c>) oldMap;
        
        afterUpdateProcess(tradeAPPlanList, tradeAPPlanMap);
    }
    
    public void beforeDeleteTrigger(List<sObject> oldList) {
        List<ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanList = (List<ASI_CRM_Trade_A_P_Plan__c>) oldList;
        
        validateBeforeDelete(tradeAPPlanList);
    }
    
    //Validation Handler
    private void validateBeforeDelete(List<ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanList) {
        for(ASI_CRM_Trade_A_P_Plan__c tradeAPPlan : tradeAPPlanList) {
        	if(tradeAPPlan.ASI_CRM_Status__c == APPROVED_STATUS || 
               tradeAPPlan.ASI_CRM_Status__c == SUBMITTED_STATUS) {
            	tradeAPPlan.addError(DELETE_ERROR_MESSAGE);
            }
        }
    }
    
    //Logic Handler
    private void beforeInsertProcess(List<ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanList) {
        ASI_CRM_VN_Settings__c vnSetting = ASI_CRM_VN_Settings__c.getOrgDefaults();
        
        //First Approver
        Set<Id> userIdSet = new Set<Id>();
        for(ASI_CRM_Trade_A_P_Plan__c tradeAPPLan : tradeAPPlanList) {
            userIdSet.add(tradeAPPLan.OwnerId);
        }
        
        Map<Id, User> userMap = new Map<Id, User>(retrieveUserList(userIdSet));
        //Second Approver (If approver = final approver, skip it)
        userIdSet = new Set<Id>();
        for(User u : userMap.values()) {
        	if(u.Manager.Name == vnSetting.ASI_CRM_VN_Promotion_Plan_Final_Approver__c) {
            	continue;
            }
            
            userIdSet.add(u.ManagerId);
        }
        
        if(userIdSet.size() > 0) {
            userMap.putAll(new Map<Id, User>(retrieveUserList(userIdSet)));
        }
        
        //Assign Approver
        for(ASI_CRM_Trade_A_P_Plan__c tradeAPPLan : tradeAPPlanList) {
            User owner = userMap.get(tradeAPPLan.OwnerId);
            tradeAPPLan.ASI_CRM_System_Approver_1__c = owner.ManagerId;
            
            if(owner.Manager.Name != vnSetting.ASI_CRM_VN_Promotion_Plan_Final_Approver__c) {
                if(userMap.containsKey(owner.ManagerId))
                	tradeAPPLan.ASI_CRM_System_Approver_2__c = userMap.get(owner.ManagerId).ManagerId;
            }
        }
    }
    
    private void afterUpdateProcess(List<ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanList, Map<Id, ASI_CRM_Trade_A_P_Plan__c> tradeAPPlanMap) {
    	Set<Id> approvedTradeAPPlanIdSet = new Set<Id>();
        for(ASI_CRM_Trade_A_P_Plan__c tradeAPPlan : tradeAPPlanList) {
            ASI_CRM_Trade_A_P_Plan__c oldTradeAPPlan = tradeAPPlanMap.get(tradeAPPlan.Id);
            
            if(tradeAPPlan.ASI_CRM_Status__c == APPROVED_STATUS&&
               oldTradeAPPlan.ASI_CRM_Status__c != APPROVED_STATUS) {
                approvedTradeAPPlanIdSet.add(tradeAPPlan.Id);
            }
        }
        
        List<ASI_CRM_Trade_A_P_Plan_Item__c> updateItemList = updateItemReadOnly(retrieveTradeAPPlanItemList(approvedTradeAPPlanIdSet));
        
		if(updateItemList.size() > 0) update updateItemList;
        if(approvedTradeAPPlanIdSet.size() > 0) sendEmailToPublicGroup(approvedTradeAPPlanIdSet);

    }
    
    private List<ASI_CRM_Trade_A_P_Plan_Item__c> updateItemReadOnly(List<ASI_CRM_Trade_A_P_Plan_Item__c> tradeAPPlanItemList) {
        for(ASI_CRM_Trade_A_P_Plan_Item__c item : tradeAPPlanItemList) {
            item.RecordTypeId = PLAN_ITEM_READ_ONLY_RECORD_TYPE;
        }
        return tradeAPPlanItemList;
    }

    private void sendEmailToPublicGroup(Set<Id> plansIdSets){
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ASI_CRM_VN_PromotionPlanApprovedCDPTmp'].Id;
        List<ProcessInstanceStep> processInstanceSteps = [SELECT Id, Actor.Name, SystemModstamp, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId IN :plansIdSets ORDER BY SystemModstamp];
        Map<Id, List<String>> planIdToName = new Map<Id, List<String>>();
        for (ProcessInstanceStep processInstanceStep : processInstanceSteps) {
            Id planId = processInstanceStep.ProcessInstance.TargetObjectId;
            String name = processInstanceStep.Actor.Name;
            if (planIdToName.containsKey(planId)) {
                List<String> names = planIdToName.get(planId);
                names.add(name);
                planIdToName.put(planId, names);

            } else {
                planIdToName.put(planId, new List<String> { name });
            }
        }

        Set<Id> groupIds = new Set<Id>();
        for(GroupMember gm : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE Group.Name = 'ASI_CRM_VN_Sales_User']) {
            groupIds.add(gm.UserOrGroupId);
        }
        Set<Id> userRolesIds = new Set<Id>(); 
        for(Group g : [SELECT Id, Name, RelatedId FROM Group WHERE Type = 'Role' AND Id in :groupIds]) {
            userRolesIds.add(g.RelatedId);
        }

        // Because SFDC only allows send 100 email at one time, we workaround by grouping users by 100
        List<User> users = [SELECT Id, Email FROM User WHERE UserRoleId IN :userRolesIds];
        List<List<User>> usersGroupByHundred = new List<List<User>>();
        List<User> usersHundred = new List<User>();
        for (Integer i = 0; i < users.size(); i++) {
            usersHundred.add(users[i]);
            if (usersHundred.size() == 100) {
                usersGroupByHundred.add(usersHundred);
                usersHundred = new List<User>();
            }
            // if last element already and usersHundred.size not 100, add
            if (i == (users.size() - 1) && usersHundred.size() != 100) {
                usersGroupByHundred.add(usersHundred);
            }
        }

        for (List<User> users2 : usersGroupByHundred) {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for (Id planId : plansIdSets) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                if (planIdToName.get(planId) != null) {
                    mail.setSenderDisplayName(planIdToName.get(planId)[1]);
                }
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setTemplateId(templateId);
                mail.setWhatId(planId);
                mail.setToAddresses(ASI_CRM_VN_Util_Pluck.strings(users2, User.Email));
                mail.saveAsActivity = false;
                emails.add(mail);
            }

            Messaging.sendEmail(emails);
        }
    }

        /***************
        Data Retrieval Function
        ***************/
    private List<User> retrieveUserList(Set<Id> userIdSet) {
    	String query = 'SELECT Id, Name, ManagerId, Manager.Name ' + 
                       'FROM User ' + 
                       'WHERE Id in :userIdSet ';
        
    	return (List<User>) Database.query(query);
  	}
    
    private List<ASI_CRM_Trade_A_P_Plan_Item__c> retrieveTradeAPPlanItemList(Set<Id> tradeAPPlanIdSet) {
        List<ASI_CRM_Trade_A_P_Plan_Item__c> tradeAPPlanItemList = [SELECT Id, RecordTypeId
                                                                    FROM ASI_CRM_Trade_A_P_Plan_Item__c
                                                                    WHERE ASI_CRM_Trade_A_P_Plan__c IN :tradeAPPlanIdSet];
        
        return tradeAPPlanItemList;
    }
}