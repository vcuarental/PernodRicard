public with sharing class PRH_Delete_Iconic_Account_Controller {
    private ApexPages.StandardSetController standardController;
    public List<PRH_Luxury_Accounts__c> selectedAccounts {get;set;}
    
    public PRH_Delete_Iconic_Account_Controller(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference loadAccount()
    {       
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        selectedAccounts = (List<PRH_Luxury_Accounts__c>) standardController.getSelected();
          
        return null;        
    }

    public PageReference updateAccounts()
    {       
        // Check if user have access to delete records
        if(verifyAccess()){
        
            // Check if the records selected have PRH_Suppress_and_archive__c selected
            if(verifySelectedDeleted()){
                
                // Get privilege to suppress
                if(getPrivilege()){
                    // Launch batch
                    Set<Id> resultIds = (new Map<Id,SObject>(selectedAccounts)).keySet();
                    launchBatchDeleteIconicAccount(convertSetToString(resultIds));
                    // Message
                    printMessage('success');
                }else{
                    printMessage('no_privilege');
                }

            }else{
                printMessage('no_suppress');   
            }
        }else{
            printMessage('no_access');              
        }
        return null;   
    }
    // Check if user have access to delete records
    private boolean verifyAccess(){
        String retour='';
                 
        // Get Permission Set of user
        Set<Id> setAssigneeIds = new Set<Id>();
        for(PermissionSetAssignment psa:[SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: userInfo.getUserId()]){
          setAssigneeIds.add(psa.PermissionSetId);
        }
        
        // Get Permission Name of user
        Set<String> setNames = new Set<String>();
        for(PermissionSet ps:[Select Name From PermissionSet Where ID IN:(setAssigneeIds)]){
          setNames.add(ps.Name);
        }
        return setNames.contains('PRH_Iconic_Platform_PR_Holding_Admin');
    }
    
    // Check if the records selected have PRH_Suppress_and_archive__c selected
    private boolean verifySelectedDeleted(){
        Boolean validated_Suppress= true;
        for(PRH_Luxury_Accounts__c la:selectedAccounts){
            if(la.get('PRH_Suppress_and_archive__c') == false){
                validated_Suppress = false;
            }
        }
        
        return validated_Suppress;
    }
    
    // Convert set<id> to String
    private String convertSetToString(Set<Id> setString){
        
        String idStr = '';
        for(String s:setString) {
           idStr += (idStr == ''?'':',')+s;
        }
        return idStr;
    }
    
    // Add privilege
    private Boolean getPrivilege(){
        Boolean result = false;
        
        // Get id Permission of PRH_Iconic_Platform_Support_LeCercle
        String psId = [select id from PermissionSet where name = 'PRH_Iconic_Platform_Support_LeCercle'].Id;
        AggregateResult[] arList = [SELECT count(Id) FROM PermissionSetAssignment WHERE AssigneeId =: userInfo.getUserId() AND PermissionSetId =: psId];
        
        if(arList.size() == 0){
            PermissionSetAssignment psa = new PermissionSetAssignment(); 
            psa.assigneeId = userInfo.getUserId();
            psa.PermissionSetId = psId;
            
            PermissionSetAssignment[] psas = new List<PermissionSetAssignment>{psa};
            Database.SaveResult[] srList = Database.insert(psas, false);
            if(srList[0].isSuccess()){ result = true;}
        }else{
            result = true;
        }
       
        return result;
    }
    
    // Add a tempo for second batch execution
    public static void sleep(Integer secs ) {
        datetime myStartDateTime = datetime.now();
        DateTime newDateTime = myStartDateTime.addSeconds(secs);
        while (datetime.now() < newDateTime );
    }
    
    // Launch batch to delete
    private String launchBatchDeleteIconicAccount(String Ids){
        PRH_Iconic_Account_Deletion c = new PRH_Iconic_Account_Deletion(Ids);
        Id batchJobId = Database.executeBatch(c, 200);
        sleep(50);
        PRH_Iconic_Account_Deletion_End c2 = new PRH_Iconic_Account_Deletion_End();
        Id batchJobId2 = Database.executeBatch(c2, 200);
        return null;
    }
    
    // Print a message
    public void printMessage(String msg){ 
        switch on (msg){          
            when 'success'{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,Label.PRH_IA_Msg_Confirm_Delete));
            }
            when 'no_suppress'{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.PRH_IA_Msg_No_Suppress));
            }
            when 'no_access'{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.PRH_IA_Msg_No_Access));
            }
            when 'no_privilege'{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.PRH_IA_Msg_Error_Permission));
            }
        }
    }
    
}