@isTest
private class EUR_CRM_PT_ScheduleContractStatusTest {
    static testMethod void EUR_CRM_PT_ScheduleContractStatusTest(){
    	EUR_CRM_Account__c account = new EUR_CRM_Account__c(
    		Name = 'Test Class',
    		RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Account__cEUR_PT_On_Trade')
    	);
    	insert account;
    	
   		List<EUR_CRM_Contract__c> contractList = new List<EUR_CRM_Contract__c>();
   		EUR_CRM_Contract__c contract1 = new EUR_CRM_Contract__c(
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract__cEUR_PT_Outlet_Contract'),
   			EUR_CRM_Account__c = account.Id,
   			EUR_CRM_Start_Date__c = system.today()
   		);
   		contractList.add(contract1);
   		EUR_CRM_Contract__c contract2 = new EUR_CRM_Contract__c(
   			RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract__cEUR_PT_Outlet_Contract'),
   			EUR_CRM_Account__c = account.Id,
   			EUR_CRM_End_Date__c = system.today()
   		);
   		contractList.add(contract2);
   		insert contractList;
   		
   		Database.executeBatch(new EUR_CRM_PT_ScheduleContractStatus());
    }
}