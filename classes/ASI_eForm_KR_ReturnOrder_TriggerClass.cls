public class ASI_eForm_KR_ReturnOrder_TriggerClass {
        
    private final static String SHARINGREASON     = 'ASI_eForm_KR_Manual_Share__c';
    
    public static void routineBeforeUpsert(List<ASI_eForm_Return_Order_Request__c> triggerNew, Map<Id, ASI_eForm_Return_Order_Request__c> triggerOldMap) {
        Set<Id> OwnerIdSet = New Set<Id>();
        Map<String,ASI_eForm_HR_MDM__c> MDMMap= new Map<String,ASI_eForm_HR_MDM__c> ();
        Map<String,ASI_MFM_Fix_Approval_Route__c>  FixApprovalRouteMap = new Map<String,ASI_MFM_Fix_Approval_Route__c>();  
        Map<Id,User> UserMap = new Map<Id,User>();
        
        for(ASI_eForm_Return_Order_Request__c obj : triggerNew){
            OwnerIdSet.add(obj.OwnerId);
        }
        if(OwnerIdSet.size()>0 ){
            Set<String> UserSalesTeamSet = new Set<String>();
            Set<String> UserEmailSet = new Set<String>();
            List<User> UserList= [select Id,Email,username,ASI_MFM_Team__c from User where Id in : OwnerIdSet and ASI_MFM_Team__c!=null ];
            for(User u : UserList){
                UserMap.put(u.Id,u);
                UserEmailSet.add(u.username);
                UserSalesTeamSet.add(u.ASI_MFM_Team__c); 
            }
            
            List<ASI_eForm_HR_MDM__c> ListOfMDM = [select id,ASI_eForm_Employee_Work_Email__c,ASI_eForm_Employee_Job_Title__c,ASI_eForm_Employee_Branch_Code__c 
                                                   from ASI_eForm_HR_MDM__c 
                                                   where ASI_eForm_Employee_Work_Email__c in : UserEmailSet and ASI_eForm_Employee_Work_Email__c!=null ];
            
            
            for(ASI_eForm_HR_MDM__c mdm :ListOfMDM ){
                MDMMap.put(mdm.ASI_eForm_Employee_Work_Email__c, mdm);
            }
            List<ASI_MFM_Fix_Approval_Route__c> FARList = new List<ASI_MFM_Fix_Approval_Route__c>([SELECT Id,ASI_MFM_Team__c, ASI_MFM_Corporate_Approver_1__c, ASI_MFM_Corporate_Approver_2__c
                                                                                                   FROM ASI_MFM_Fix_Approval_Route__c 
                                                                                                   WHERE ASI_MFM_Team__c in :UserSalesTeamSet  and RecordType.DeveloperName LIKE 'ASI_MFM_KR_Fix_Approval_Route' 
                                                                                                   AND ASI_MFM_Module__c = 'eForm' and ASI_MFM_KR_Grand_Category__c ='Return Order' AND ASI_MFM_Inactive__c = false ]);
            
            for(ASI_MFM_Fix_Approval_Route__c FixApprovalRoute : FARList){
                FixApprovalRouteMap.put(FixApprovalRoute.ASI_MFM_Team__c,FixApprovalRoute);
            }
        }
        
        
        for(ASI_eForm_Return_Order_Request__c obj : triggerNew){
            if(UserMap.containsKey(obj.OwnerId) ){
                string userEmail = UserMap.get(obj.OwnerId).username;
                if(MDMMap.containsKey(userEmail)){
                    obj.ASI_eForm_Branch_Code__c = MDMMap.get(userEmail).ASI_eForm_Employee_Branch_Code__c;
                }
            }
            if(FixApprovalRouteMap.containsKey(UserMap.get(obj.OwnerId).ASI_MFM_Team__c) ){
                obj.ASI_eForm_Sys_Approver_1__c = FixApprovalRouteMap.get(UserMap.get(obj.OwnerId).ASI_MFM_Team__c).ASI_MFM_Corporate_Approver_1__c; 
                obj.ASI_eForm_Sys_Approver_2__c = FixApprovalRouteMap.get(UserMap.get(obj.OwnerId).ASI_MFM_Team__c).ASI_MFM_Corporate_Approver_2__c;
            }
        }
        
    }
    
    public static void routineAfterUpsert(List<ASI_eForm_Return_Order_Request__c> triggerNew, Map<Id, ASI_eForm_Return_Order_Request__c> triggerOldMap){
        Map<string, set<string>> map_recordId_userId = new Map<string, set<string>>();
        
        for(ASI_eForm_Return_Order_Request__c obj : triggerNew){
            if(triggerOldMap == null || 
               (obj.ASI_eForm_Sales_Admin__c != triggerOldMap.get(obj.Id).ASI_eForm_Sales_Admin__c ||
                obj.ASI_eForm_Sys_Approver_2__c != triggerOldMap.get(obj.Id).ASI_eForm_Sys_Approver_2__c
               )
            ){
                set<string> set_userId = map_recordId_userId.containsKey(obj.Id) ? map_recordId_userId.get(obj.Id) : new set<string>();
                if(obj.ASI_eForm_Sales_Admin__c != null) set_userId.add(obj.ASI_eForm_Sales_Admin__c);
                if(obj.ASI_eForm_Sys_Approver_2__c != null) set_userId.add(obj.ASI_eForm_Sys_Approver_2__c);
                map_recordId_userId.put(obj.Id, set_userId);
            }
        }
        if(map_recordId_userId != null) manualShareToSalesAdmin(map_recordId_userId);
        
    }
    
    public static void manualShareToSalesAdmin(Map<string, set<string>> map_recordId_userId){
        List<ASI_eForm_Return_Order_Request__Share> newShareList = new List<ASI_eForm_Return_Order_Request__Share>();
        
        List<ASI_eForm_Return_Order_Request__Share> shareListToDelete = [
            select id from ASI_eForm_Return_Order_Request__Share 
            where parentId In: map_recordId_userId.keySet() 
            and RowCause = :SHARINGREASON
        ];
        if(shareListToDelete.size()>0) delete shareListToDelete;
        
        for(string rid : map_recordId_userId.keySet()){
            set<string> set_userId = map_recordId_userId.get(rid);
            for(string uid : set_userId){
                newShareList.add(
                	(ASI_eForm_Return_Order_Request__Share)createCustomShare(
                        rid, uid, 'ASI_eForm_Return_Order_Request', 'Edit', SHARINGREASON
                    )
                );
            }
        }
        if(newShareList.size()>0) insert newShareList;
    }
    
	public static SObject createCustomShare(String p, String userOrGroupId, String objectName, String accessLevel, String reason){
		Schema.SObjectType customShareType = Schema.getGlobalDescribe().get(objectName + '__Share');
		SObject customShare = customShareType.newSObject();		
		customShare.put('ParentId', p);
		customShare.put('AccessLevel', accessLevel);	
		customShare.put('UserOrGroupId', userOrGroupId);
		customShare.put('RowCause', reason);
		return customShare;
    } 

}