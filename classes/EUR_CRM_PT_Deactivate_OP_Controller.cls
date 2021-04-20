public class EUR_CRM_PT_Deactivate_OP_Controller {
	
    public PageReference deactivateOP() {
        PageReference pageRef = null;
        String opId = ApexPages.currentPage().getParameters().get('id'); 
        
        if(String.isNotBlank(opId)){
            Savepoint sp = Database.setSavepoint();

            try{
                
                EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c();
                op.id = opId;
                op.EUR_CRM_Status__c = 'Ended';
                op.EUR_CRM_Active_End_Date__c = System.today();
                
                update op;
                
                List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappingList = [SELECT Id, EUR_CRM_Is_Active__c 
                                                                                  FROM EUR_CRM_ObjPromo_Account_Mapping__c
                                                                                  WHERE EUR_CRM_ObjPromo__c = :opId];
                for(EUR_CRM_ObjPromo_Account_Mapping__c opAccountMapping : opAccountMappingList) {
                    opAccountMapping.EUR_CRM_Is_Active__c = false;
                }
                
                update opAccountMappingList;
            }catch(Exception e){
                Database.rollback(sp);
                system.debug('Error : ' + e);
            }
            pageRef = new PageReference('/'+ opId);
        } else {
            pageRef = new PageReference('/');
        }
        
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}