public class ASI_JP_TnE_ClaimHeaderTriggerClass {
    
    public static String eAPPROVAL_RECORD_TYPE = 'ASI_JP_TnE_eApproval_Claim_Header';
    public static String PAPER_APPROVAL_RECORD_TYPE = 'ASI_JP_TnE_Paper_Approval_Claim_Header';
    
    
    public static void validateClaimHeaderStatus(List<ASI_TnE_ClaimHeader__c> triggerClaims, Map<Id, 
                                                 ASI_TnE_ClaimHeader__c> triggerNewMap, Map<Id, ASI_TnE_ClaimHeader__c> triggerOldMap) 
    {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        for (ASI_TnE_ClaimHeader__c claimHeader : triggerClaims)
        {
            if ((claimHeader.ASI_TnE_Status__c == 'Final' || claimHeader.ASI_TnE_Status__c == 'Complete') && profileName != 'ASI JP Admin User' && profileName != 'System Administrator')
            {
                claimHeader.addError(Label.ASI_JP_TnE_Not_Allowed_to_delete_Claim);
                System.debug('Error cannot delete debugging Header');
            }    
        }   
    }
    
    public static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }    
    
    public static void updateClaimHeaderDueDateMapping(List<ASI_TnE_ClaimHeader__c> triggerNew, Map<Id, 
                                                       ASI_TnE_ClaimHeader__c> triggerNewMap, Map<Id, ASI_TnE_ClaimHeader__c> triggerOldMap, Map<Id,RecordType> recordTypeMap,
                                                       boolean isUpdate)
    { 
        Set<Integer> years = new Set<Integer>();
        Set<String> paymentOptions = new Set<String>(); 
        Set<String> departmentCodes = new Set<String>(); 
        Set<ASI_TnE_ClaimHeader__c> validClaimHeaders = new Set<ASI_TnE_ClaimHeader__c>();
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> currentIds = new Set<Id>();
        
        //Beta CR Feb 24: retrieve the 86506 account Customer/Supplier number
        map<string, id> rt_map  = getRecordTypeId('Account');
        List<Account> acctList = [SELECT ID, Name, ASI_MFM_Customer_Supplier_Number__c 
                                  FROM Account 
                                  WHERE ASI_MFM_Customer_Supplier_Number__c = : '86506' AND recordtypeID = : rt_map.get('ASI_JP_Supplier')];
        Account acct_86506 = null;
        if (acctList.size() > 0)
            acct_86506 = acctList.get(0);
        
        ASI_JP_TnE_AutoNumberAssignment autoNumAssign = null;
        for (ASI_TnE_ClaimHeader__c claimHeader : triggerNew)
        {
            
            // Create a running number for Document Suffix
            if (!isUpdate)
            {
                if (autoNumAssign == null) 
                {
                    autoNumAssign = new ASI_JP_TnE_AutoNumberAssignment('ASI_JP_TnE_Document_Number');
                    claimHeader.ASI_TnE_Document_No_Suffix__c = autoNumAssign.nextAutoNumStr();
                }
            }
            
            //Beta CR Feb 24: set Payee Supplier to 86506 account if Payment Options == DC Card(Mgr.)
            if (claimHeader.ASI_TnE_Payment_Option__c == 'DC Card(Mgr.)')
            {
                if (acct_86506 != null)
                    claimHeader.ASI_TnE_Payee__c = acct_86506.id;
                else
                    claimHeader.addError(Label.ASI_JP_TnE_Account_86506_Not_Exist);
            }
            
            ASI_TnE_ClaimHeader__c  oldClaimHeader = triggerOldMap!=null?triggerOldMap.get(claimHeader.Id):null;           
            
            if ((oldClaimHeader ==null) ||  (oldClaimHeader != null && 
                                             ((claimHeader.OwnerId != oldClaimHeader.OwnerId) ||
                                              (claimHeader.ASI_TnE_Payee_Employee__c != oldClaimHeader.ASI_TnE_Payee_Employee__c) ||
                                              (claimHeader.ASI_TnE_Date__c != oldClaimHeader.ASI_TnE_Date__c) || 
                                              (claimHeader.ASI_TnE_Payment_Option__c != oldClaimHeader.ASI_TnE_Payment_Option__c))  ))
            {
                years.add(claimHeader.ASI_TnE_Date__c.year());                        
                years.add(claimHeader.ASI_TnE_Date__c.year()+1);
                
                if (claimHeader.ASI_TnE_3rd_Party__c)
                {
                    paymentOptions.add('Invoice'); //make this a label
                } else {                
                    paymentOptions.add(claimHeader.ASI_TnE_Payment_Option__c);                
                }
                
                departmentCodes.add(claimHeader.ASI_TnE_Department_Category_Code__c);  
                validClaimHeaders.add(claimHeader);              
                
                
                //For Update
                if (oldClaimHeader != null)
                {                
                    //Scenario 1 - Old ASI_TnE_Payee_Employee__c is not null
                    //(oldClaimHeader.ASI_TnE_Payee_Employee__c != null && claimHeader.ASI_TnE_Payee_Employee__c == null)
                    if (claimHeader.ASI_TnE_Payee_Employee__c != null && 
                        (claimHeader.ASI_TnE_Payee_Employee__c != oldClaimHeader.ASI_TnE_Payee_Employee__c))
                    {
                        claimHeader.OwnerId = claimHeader.ASI_TnE_Payee_Employee__c;                                     
                    } else if (claimHeader.OwnerId != oldClaimHeader.OwnerId)
                    {
                        claimHeader.ASI_TnE_Payee_Employee__c = claimHeader.OwnerId;                 
                    }
                } else //New Record
                {
                    if (claimHeader.ASI_TnE_Payee_Employee__c != null)
                    {
                        claimHeader.OwnerId = claimHeader.ASI_TnE_Payee_Employee__c;
                    }
                }                
                
                ownerIds.add(claimHeader.OwnerId);               
                currentIds.add(claimHeader.Id);
            }                   
        }    
        
        if (autoNumAssign != null)
            autoNumAssign.writeToDB();
        
        Map<Id,User> currentUsers = new Map<Id,User>([Select Id, Name, ASI_JP_TnE_Department_Category_Code__c, UserRole.DeveloperName from User WHERE Id in :ownerIds]);
        
        for (User currentUser : currentUsers.values())
        {
            departmentCodes.add(currentUser.ASI_JP_TnE_Department_Category_Code__c);
        }
        
        List<ASI_JP_TnE_Due_Date_Mapping__c> dueDates = [Select Id, ASI_JP_TnE_Department_Category_Code__c, 
                                                         ASI_JP_TnE_Closing_Date__c, ASI_JP_TnE_Payment_Date__c, ASI_JP_TnE_Period_From__c, ASI_JP_TnE_Period_To__c, ASI_JP_TnE_Payment_Option__c 
                                                         from ASI_JP_TnE_Due_Date_Mapping__c where 
                                                         ASI_JP_TnE_Department_Category_Code__c in :departmentCodes and 
                                                         ASI_JP_TnE_Payment_Option__c in :paymentOptions and
                                                         CALENDAR_YEAR(ASI_JP_TnE_Closing_Date__c) in :years
                                                        ]; 
        
        //Key: departmentCode+paymentOption+Year
        Map<String,List<ASI_JP_TnE_Due_Date_Mapping__c>> dueDatesMapping = new 
            Map<String,List<ASI_JP_TnE_Due_Date_Mapping__c>>();
        
        for (ASI_JP_TnE_Due_Date_Mapping__c dueDate : dueDates)
        {
            String key = dueDate.ASI_JP_TnE_Department_Category_Code__c+dueDate.ASI_JP_TnE_Payment_Option__c
                +dueDate.ASI_JP_TnE_Closing_Date__c.year();
            
            if(!dueDatesMapping.containsKey(key))
            {
                List<ASI_JP_TnE_Due_Date_Mapping__c> dueDateList = new List<ASI_JP_TnE_Due_Date_Mapping__c>();
                dueDateList.add(dueDate);
                dueDatesMapping.put(key,dueDateList);            
            } else
            {
                dueDatesMapping.get(key).add(dueDate);         
            }        
        }
        
        List<ASI_TnE_ClaimHeader__c>  userExistingClaims =
            [SELECT OwnerId, ASI_TnE_Due_Date_Mapping__c, Name from ASI_TnE_ClaimHeader__c where 
             id not in :currentIds
             and ASI_TnE_Due_Date_Mapping__c != null
             and ownerId in :ownerIds
             and CALENDAR_YEAR(ASI_TnE_Date__c) in :years];   
        
        Map<String,String> userClaimDueDateMapping = new Map<String,String>();        
        
        
        for (ASI_TnE_ClaimHeader__c claimHeader : userExistingClaims )
        {
            String key = '' + claimHeader.ownerId + claimHeader.ASI_TnE_Due_Date_Mapping__c;
            userClaimDueDateMapping.put(key,claimHeader.Name);        
        }             
        
        List<ASI_JP_TnE_Role_eApproval_Settings__c>  eApprovalRoles =
            [Select Id, ASI_JP_TnE_Role_API__c, ASI_TnE_JP_Marketing_User__c from ASI_JP_TnE_Role_eApproval_Settings__c];
        
        Set<String> eApprovalRoleSet = new Set<String>();
        Set<String> eApprovalMarket = new Set<String>(); //20161020, Leo@Elufa
        for(ASI_JP_TnE_Role_eApproval_Settings__c eApprovalRole : eApprovalRoles )
        {
            eApprovalRoleSet.add(eApprovalRole.ASI_JP_TnE_Role_API__c);            
            //20161020, Leo@Elufa
            if(eApprovalRole.ASI_TnE_JP_Marketing_User__c)
            {
                eApprovalMarket.add(eApprovalRole.ASI_JP_TnE_Role_API__c);
            }
            //20161020, Leo@Elufa
        }         
        
        for (ASI_TnE_ClaimHeader__c  claimHeader: validClaimHeaders)
        {
            RecordType currentRecordType = recordTypeMap.get(claimHeader.RecordTypeId);
            
            User currentOwner =  currentUsers.get(claimHeader.OwnerId);
            
            if (((currentRecordType.DeveloperName == eAPPROVAL_RECORD_TYPE && !eApprovalRoleSet.contains(currentOwner.UserRole.DeveloperName)) || 
                 (currentRecordType.DeveloperName == PAPER_APPROVAL_RECORD_TYPE && eApprovalRoleSet.contains(currentOwner.UserRole.DeveloperName)))
               )
            {
                claimHeader.addError(String.format(Label.ASI_JP_TnE_Owner_Not_Eligible_for_Record_Type,
                                                   new String[]{currentOwner.Name,currentRecordType.Name}));         
                
            } else 
            {
                
                String paymentOption = claimHeader.ASI_TnE_3rd_Party__c?'Invoice':claimHeader.ASI_TnE_Payment_Option__c;
                String key = currentOwner.ASI_JP_TnE_Department_Category_Code__c+paymentOption
                    +claimHeader.ASI_TnE_Date__c.year();
                
                List<ASI_JP_TnE_Due_Date_Mapping__c> dueDateList =  dueDatesMapping.get(key);
                
                if (dueDateList != null)
                {
                    Integer currentDaysBetween = -1;
                    for(ASI_JP_TnE_Due_Date_Mapping__c dueDate : dueDateList)
                    {
                        if (dueDate.ASI_JP_TnE_Closing_Date__c >= claimHeader.ASI_TnE_Date__c)
                        {
                            Integer daysBetween =  claimHeader.ASI_TnE_Date__c.daysBetween(dueDate.ASI_JP_TnE_Closing_Date__c);
                            
                            if (currentDaysBetween == -1)
                            {
                                currentDaysBetween  = daysBetween;
                                claimHeader.ASI_TnE_Due_Date_Mapping__c = dueDate.Id;                       
                                
                            } else if (daysBetween < currentDaysBetween)
                            {
                                currentDaysBetween  = daysBetween;
                                claimHeader.ASI_TnE_Due_Date_Mapping__c = dueDate.Id;                       
                                
                            }
                        } 
                    }
                    if (currentDaysBetween == -1)
                    {
                        claimHeader.ASI_TnE_Due_Date_Mapping__c=null;
                    }
                } else {
                    claimHeader.ASI_TnE_Due_Date_Mapping__c=null;               
                }               
                
                if (claimHeader.ASI_TnE_Due_Date_Mapping__c==null)
                {
                    String nextYearPaymentOption = claimHeader.ASI_TnE_3rd_Party__c?'Invoice':claimHeader.ASI_TnE_Payment_Option__c;
                    String nextYearKey = currentOwner.ASI_JP_TnE_Department_Category_Code__c+nextYearPaymentOption 
                        +(claimHeader.ASI_TnE_Date__c.year()+1);
                    
                    List<ASI_JP_TnE_Due_Date_Mapping__c> nextYearDueDateList =  dueDatesMapping.get(nextYearKey);
                    
                    if (nextYearDueDateList != null)
                    {
                        Integer currentDaysBetween = -1;
                        for(ASI_JP_TnE_Due_Date_Mapping__c dueDate : nextYearDueDateList)
                        {
                            if (dueDate.ASI_JP_TnE_Closing_Date__c > claimHeader.ASI_TnE_Date__c)
                            {
                                Integer daysBetween =  claimHeader.ASI_TnE_Date__c.daysBetween(dueDate.ASI_JP_TnE_Closing_Date__c);
                                
                                if (currentDaysBetween == -1)
                                {
                                    currentDaysBetween  = daysBetween;
                                    claimHeader.ASI_TnE_Due_Date_Mapping__c = dueDate.Id;                       
                                    
                                } else if (daysBetween < currentDaysBetween)
                                {
                                    currentDaysBetween  = daysBetween;
                                    claimHeader.ASI_TnE_Due_Date_Mapping__c = dueDate.Id;                       
                                    
                                }
                            } 
                        }
                    }           
                }  
                
                // Beta CR Feb 24: allow to create using the same due date record when ASI_TnE_3rd_Party__c == true 
                if (claimHeader.ASI_TnE_Due_Date_Mapping__c==null)
                {
                    claimHeader.addError(String.format(Label.ASI_JP_TnE_Unable_To_Associate_Due_Date_Mapping,
                                                       new String[]{currentOwner.Name,currentOwner.ASI_JP_TnE_Department_Category_Code__c,claimHeader.ASI_TnE_Payment_Option__c, 
                                                           String.valueOf(claimHeader.ASI_TnE_Date__c.month()),String.valueOf(claimHeader.ASI_TnE_Date__c.year())}));
                } else
                {
                    String currentKey = '' + claimHeader.ownerId + claimHeader.ASI_TnE_Due_Date_Mapping__c;
                    
                    if (userClaimDueDateMapping.containsKey(currentKey) && !claimHeader.ASI_TnE_3rd_Party__c && claimHeader.ASI_TnE_Charger__c == null)    
                    {
                        claimHeader.addError(String.format(Label.ASI_JP_TnE_Due_Date_Mapping_Already_Associated, 
                                                           new String[]{currentOwner.Name, userClaimDueDateMapping.get(currentKey)}));
                    }            
                    
                }
            }
        }
        //20160602, Leo@Elufa 
        //Howard If paper no need select approver, only e-approval need
        if(isUpdate)
        {
            // Dynamic Approval Route
            Map<Id,ASI_TnE_Dynamic_Approval_Route__c> DARMap  =new Map<Id,ASI_TnE_Dynamic_Approval_Route__c>();
            List<ASI_TnE_Dynamic_Approval_Route__c> DARList   = new List<ASI_TnE_Dynamic_Approval_Route__c>([SELECT id,ASI_TnE_Type__c,  ASI_TnE_User__c, ASI_TnE_Approval_Limit__c,ASI_TnE_End_of_1st_Route__c FROM ASI_TnE_Dynamic_Approval_Route__c WHERE RecordType.DeveloperName LIKE 'ASI_TnE_JP_Dynamic_Approval_Route'  AND ASI_TnE_Type__c LIKE 'T&E']);
            for(ASI_TnE_Dynamic_Approval_Route__c DAR: DARList){
                DARMap.put(DAR.ASI_TnE_User__c, DAR);
            }
            Map<Id, User> mapUser = new Map<Id, User>();
            List<User>userList = new List<User>([SELECT ID, Name, ManagerID, UserRole.Id, UserRole.DeveloperName,ASI_MFM_Team__c,ASI_MFM_Brand_Manager__c FROM User WHERE  IsActive =true and (CompanyName LIKE '%Japan%' or ASI_MFM_Country__c ='JP' )]); //20161020, Leo@Elufa
            for(User u: userList){
                mapUser.put(u.id, u);
            }
            /*//20160714, Leo@Elufa
            Map<Id, User> mapAllUser = new Map<Id, USer>();
            List<User>userListA = new List<User>([SELECT ManagerID FROM User WHERE CompanyName LIKE '%Japan%']);
            for(User u: userListA){
                mapAllUser.put(u.id, u);
            }
            //20160714, Leo@Elufa*/
            for (ASI_TnE_ClaimHeader__c header : triggerNew)
            {
                RecordType currentRecordType = recordTypeMap.get(header.RecordTypeId);
				if(currentRecordType.DeveloperName == eAPPROVAL_RECORD_TYPE)
                {
                    setApproverToNull(header);
                    if(mapUser.containsKey(header.OwnerId)&&mapUser.get(header.OwnerId).ASI_MFM_Brand_Manager__c!=null)
                        header.ASI_TnE_Sys_Approver_1__c = mapUser.get(header.OwnerId).ASI_MFM_Brand_Manager__c;//20160714, Leo@Elufa
                    if(mapUser.containsKey(header.ownerId) && eApprovalMarket.contains(mapUser.get(header.OwnerId).UserRole.DeveloperName)) //20161028, Leo@Elufa
                    {
                        header.ASI_TnE_JP_Marketing_User__c = true;
                        dynamicRoute(header,mapUser,DARMap,mapUser.get(header.ownerId).ASI_MFM_Brand_Manager__c,1);
                    }
                    else
                    {
                        header.ASI_TnE_JP_Marketing_User__c = false;
                    }
                }
            }
        }
        //20160602, Leo@Elufa
    }
    
    //20160602, Leo@Elufa
    private Static void dynamicRoute(ASI_TnE_ClaimHeader__c header, Map<Id, USer> mapUser, Map<Id, ASI_TnE_Dynamic_Approval_Route__c> DARMap, Id approverId, Integer i){
        
        String sysApprover = 'ASI_TnE_Sys_Approver_' + i + '__c';
        
        if((approverId != NULL && !mapUser.containsKey(approverId)) || i > 7){
            //setApproverToNull(header);
        }else if(approverId != NULL && mapUser.containsKey(approverId) && (DARMap.containsKey(approverId) && !DARMap.get(approverId).ASI_TnE_End_of_1st_Route__c || !DARMap.containsKey(approverId))){
            header.put(sysApprover, approverId);
            approverId = mapUser.get(approverId).ASI_MFM_Brand_Manager__c;
            i++;
            dynamicRoute(header, mapUser, DARMap, approverId, i);
        }else if(approverId != NULL && mapUser.containsKey(approverId) && (DARMap.containsKey(approverId) && DARMap.get(approverId).ASI_TnE_End_of_1st_Route__c)){
            header.put(sysApprover, approverId);
        }
    }
    
    //clear sys approvers record
    public static void setApproverToNull(ASI_TnE_ClaimHeader__c header)
    {
        String sysApprover;
        
        for(integer i = 1 ; i <=7 ; i++)
        {
            sysApprover = 'ASI_TnE_Sys_Approver_' + i + '__c';
            header.put(sysApprover,null);
        }//end for
    }//end method: setApproverToNull
    //20160602, Leo@Elufa
}