@isTest
private class EUR_CRM_PT_ContractCreateVolumeTest {
    static testMethod void EUR_CRM_PT_ContractCreateVolumeTest(){
    	EUR_CRM_Account__c account = new EUR_CRM_Account__c(
    		Name = 'Test Class',
    		RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Account__cEUR_PT_On_Trade')
    	);
    	insert account;
    	EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract__cEUR_PT_Outlet_Contract'),
   			EUR_CRM_Account__c = account.Id,
   			EUR_CRM_Status__c = 'Draft'
   		);
   		insert contract;
   		EUR_CRM_Mechanic_Type__c type = new EUR_CRM_Mechanic_Type__c(
   			Name = 'Volume Targets and Rebates',
   			Recordtypeid = Global_RecordTypeCache.getRtId('EUR_CRM_Mechanic_Type__cEUR_PT_Volume_Targets_and_Rebates_Mechanic_Type')
   		);
   		insert type;
   		EUR_CRM_Contract_Activity_Item__c activityItem = new EUR_CRM_Contract_Activity_Item__c(
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract_Activity_Item__cEUR_PT_Contract_Activity_Item'),
   			EUR_CRM_Contract__c = contract.Id,
   			EUR_CRM_Mechanic_Type__c = type.Id
   		);
   		insert activityItem;
   		EUR_CRM_Contract_Product_Item__c item = new EUR_CRM_Contract_Product_Item__c(
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract_Product_Item__cEUR_PT_Contract_Product_Item'),
   			EUR_CRM_Contract_Activity_Item__c = activityItem.Id
   		);
   		insert item;
   		
   		test.startTest();
   		contract.EUR_CRM_Status__c = 'Activated';
   		update contract;
   		test.stopTest();
    }
}