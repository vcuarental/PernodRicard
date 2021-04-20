public class EUR_CRM_OP_AccrueAchievementsController{

    public EUR_CRM_OP_AccrueAchievementsController(){ 
    }
    
    public List<EUR_CRM_Visit_Action__c> getVisitActions(){
        List<EUR_CRM_Visit_Action__c> visitActions = [
            select id,name, 
                EUR_CRM_End_Datetime__c,
                EUR_CRM_Account__c,
                EUR_CRM_Status__c,
                recordtype.developername, 
                EUR_CRM_IS_successful__c, 
                EUR_CRM_Sell_In_Volume_Bottles__c ,
                EUR_CRM_ObjPromo__c,
                recordtypeid,
                EUR_CRM_ObjPromo_Target__c,
                EUR_CRM_Visit_ID__c
                
            from EUR_CRM_Visit_Action__c 
            where EUR_CRM_Entitle_Achievement__c = true AND
        EUR_CRM_Is_Accrued__c = false
        ]; 
        
        return visitActions;
    }
    
    public PageReference accrue(){
         EUR_CRM_DE_AccrueAchievements.accrue(getVisitActions());
        return null;
    }
     public PageReference refresh(){ 
        return null;
    }
    
}