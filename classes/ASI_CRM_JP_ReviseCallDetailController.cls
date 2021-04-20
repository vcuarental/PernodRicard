/************************
 * Create Date: 2018-03-27
 * Create By: Linus@Introv
 * Function: Update the Customer and Amount (For super user only)
 * 
*************************/ 
public class ASI_CRM_JP_ReviseCallDetailController {
    
    public Boolean access {get;set;}    
    public ASI_CRM_Call_Detail__c call {get;set;}                    
    
    public ASI_CRM_JP_ReviseCallDetailController(apexpages.standardController sc){
        call = [Select id, ASI_CRM_Customer__c, ASI_CRM_Planned_Amount__c, ASI_CRM_Actual_Amount__c, ASI_CRM_Tax_Rate__c from ASI_CRM_Call_Detail__c where id = :sc.getId()];
    }        
    
    public Boolean HasAccess (id user_id){
        boolean access = false;
        
        for(PermissionSetAssignment permissionSet : [Select PermissionSet.id from PermissionSetAssignment where Assigneeid = :user_id and (PermissionSet.Name = 'ASI_CRM_JP_Accounting_Add_On' or PermissionSet.Name = 'ASI_CRM_JP_Sales_Planning_Add_On')]){
            access = true;
        }
        system.debug('Debug - access: ' + access);
        return access; 
    }
    
    public pageReference init(){
        
        Id user_id;
        
                
        user_id = apexpages.currentPage().getParameters().get('userid');    
        access = HasAccess(user_id);
                
        if(!access){            
            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Only Super User allow to edit call detail when record is locked'));
            return null;
        }
        
        return null;
    }

    public pageReference save(){
                
        if(!Test.isRunningtest()){
            update call;
        }
        return new pageReference('/' + call.id);
    }
}