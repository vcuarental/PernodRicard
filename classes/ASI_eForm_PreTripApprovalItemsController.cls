public class ASI_eForm_PreTripApprovalItemsController{
    
    public ASI_eForm_Pre_Trip_Approval__c booking {get; private set;}
    public Boolean isDepartmentAdminUser {get;set;}
    public Boolean isSGrecord {get;set;}
    
    public ASI_eForm_PreTripApprovalItemsController(ApexPages.StandardSetController controller){
        id pid = apexpages.currentPage().getParameters().get('id');
        booking = database.query(ASI_MFM_function.buildQuery('ASI_eForm_Pre_Trip_Approval__c') + ' where id = :pid');
        isDepartmentAdminUser = isDepartmentAdminUser(UserInfo.getUserId());
        Recordtype rt = Global_RecordTypeCache.getRt(booking.recordTypeId);
        isSGrecord=rt.developername.contains('SG');
    }
    
    private static Boolean isDepartmentAdminUser (Id userId){        
        
    List<GroupMember> groupMember = [Select UserOrGroupId from GroupMember Where 
    Group.DeveloperName = 'ASI_eForm_Department_Admin_Func' and UserOrGroupId = :userId];
  
    Boolean result = false;        
                      
    if (groupMember.size() > 0){
         result = true;   
    }
        
     return result;
    }

}