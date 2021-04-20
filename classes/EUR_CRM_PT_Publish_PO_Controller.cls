public class EUR_CRM_PT_Publish_PO_Controller {
	
    private final static String ACCOUNT_MAPPING_PT_RT_DEVNAME = 'EUR_PT_Account_Mapping';
    
    public PageReference publishOP() {
        PageReference pageRef = null;
        String opId = ApexPages.currentPage().getParameters().get('id'); 
        
        if(String.isNotBlank(opId)){
            Savepoint sp = Database.setSavepoint();

            try{
                
                EUR_CRM_ObjPromo__c op = new EUR_CRM_ObjPromo__c();
                op.id = opId;
                op.EUR_CRM_Status__c = 'Active';
                op.EUR_CRM_Active_Start_Date__c = System.today();
                
                update op;
                
                List<EUR_CRM_ObjPromo_Target__c> opTargetList = [SELECT Id, EUR_CRM_Account__c 
                                                                 FROM EUR_CRM_ObjPromo_Target__c
                                                                 WHERE EUR_CRM_ObjPromo__c = :opId];
                
                Set<Id> accountIdSet = new Set<Id>();
                for(EUR_CRM_ObjPromo_Target__c opTarget : opTargetList) {
                    if(String.isNotBlank(opTarget.EUR_CRM_Account__c)) {
                    	accountIdSet.add(opTarget.EUR_CRM_Account__c);
                    }
                }
                
                RecordType accountMappingRT = [SELECT Id 
                                               FROM RecordType 
                                               WHERE SObjectType = 'EUR_CRM_ObjPromo_Account_Mapping__c' and DeveloperName = :ACCOUNT_MAPPING_PT_RT_DEVNAME];
                
                List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappingList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
                for(Id accountId : accountIdSet) {
                    EUR_CRM_ObjPromo_Account_Mapping__c opAccountMapping = new EUR_CRM_ObjPromo_Account_Mapping__c();
                    opAccountMapping.EUR_CRM_ObjPromo__c = opId;
                    opAccountMapping.EUR_CRM_Account__c = accountId;
                    opAccountMapping.EUR_CRM_Is_Active__c = true;
                    opAccountMapping.RecordTypeId = accountMappingRT.Id;
                    opAccountMappingList.add(opAccountMapping);
                }
                
                System.debug(opAccountMappingList);
                
                insert opAccountMappingList;
            }catch(Exception e){
                Database.rollback(sp);
                system.debug('Error : ' + e);
            }
            pageRef = new PageReference('/'+ opId);
        } else {
            pageRef = new PageReference('/');
        }
        
        return pageRef;
    }
    
}