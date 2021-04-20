@isTest
private class LAT_BR_VFC33_OppFreightIndicatorTest {
	
	@isTest static void test_method_one() {
 		Account acc = new Account(Client_code_AN8__c = '100', Name = 'TEST', AccountNumber = '1000', Status__c = 'Novo cadastro', Type = 'Payer', Phone = '11 1111-1111', Notes__c = 'TEST', AddressLine1_AR__c = 'TEST', CNPJ__c = '51987528000137', Corporate_Name__c = 'TEST', Channel__c = 'WS', RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'));
        insert acc;
              
        LAT_Opportunity__c opp = new LAT_Opportunity__c(LAT_Account__c = acc.Id, LAT_NROrderJDE__c='143123', Name = 'test', LAT_NRCustomerOrder__c = '100', LAT_CloseDate__c = date.today(), LAT_Type__c = 'Replenish', LAT_DSMessage1__c = 'test', LAT_DSMessage2__c = 'test', LAT_StageName__c = 'Novo pedido', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade'));
        opp.LAT_FreightFormulaDisplay__c = 12.00;
        insert opp;
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        LAT_BR_VFC33_OppFreightIndicatorCont cont = new LAT_BR_VFC33_OppFreightIndicatorCont(controller);

	}
	
	
}