public class ASI_eForm_ITProcHardAndSoftReqController{
    
    public ASI_eForm_IT_Procurement_Service_Request__c itProcAndServiceReq {get; private set;}
      public Boolean isITGroupUser {get;set;}
      public Boolean isBypassGroupUser {get;set;} //Issue #5: Detect the Bypass Group users
    
    public ASI_eForm_ITProcHardAndSoftReqController(ApexPages.StandardSetController controller){
        id pid = apexpages.currentPage().getParameters().get('id');
        itProcAndServiceReq = database.query(ASI_MFM_function.buildQuery('ASI_eForm_IT_Procurement_Service_Request__c') + ' where id = :pid');
        isITGroupUser = isITGroupUser(UserInfo.getUserId());
        isBypassGroupUser = isHKBypassGroupUser(UserInfo.getUserId()); //Issue #5: Detect the Bypass Group users
    }
    
     private static Boolean isITGroupUser(Id userId) {         
        
        List<GroupMember> groupMember = [Select UserOrGroupId from GroupMember Where 
        (Group.DeveloperName = 'ASI_eForm_Infra_Group' OR Group.DeveloperName = 'ASI_eForm_General_Admin') and UserOrGroupId = :userId];
      
        Boolean result = false;        
                          
        if (groupMember.size() > 0){
             result = true;    
        }
        
     return result;
    }
    
    //Issue #5: Detect the Bypass Group users
    private static Boolean isHKBypassGroupUser(Id userId) {         
        
        List<GroupMember> groupMember = [Select UserOrGroupId from GroupMember Where 
        Group.DeveloperName = 'ASI_eForm_HK_Bypass_Group' and UserOrGroupId = :userId];
      
        Boolean result = false;        
                          
        if (groupMember.size() > 0){
             result = true;   
        }
        
     return result;
    }
}