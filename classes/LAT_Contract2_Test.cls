@istest
public with sharing class LAT_Contract2_Test {

  static testMethod void unitTest() {
    
    Account acc = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
    acc.Rating_segmentation_targert_market__c = 'Leading';
    acc.Client_code_AN8__c = '557799';
    acc.Client_country_AN8__c = '1-557799';
    insert acc;
    Test.startTest();
    LAT_Contract2__c con = new LAT_Contract2__c();
		con.TotalMoneyPerceivedValue__c = 1000.00;
		con.TotalMoneyPRBCost__c = 100.00;
		con.TotalProductsPerceivedValue__c = 10.00;
		con.TotalProductsPRBCost__c = 10.00;
		con.StartDate__c = Date.today().addDays(-105);
		con.EndDate__c = Date.today().addDays(105);
		con.Value__c = 100000.00;
        con.Account__c  = acc.id;
      	con.Account__r  = acc;
       
    con.recordtypeid = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_OnTrade_CommercialConditionContract');
    
    insert con;

    LAT_Contract2__c contract = new LAT_Contract2__c();
    List<LAT_Contract2__c> contractResults = [Select OriginalContractNumber__c From LAT_Contract2__c Limit 1];
    if(contractResults.size() > 0){
      contract = contractResults[0];
    }
    con.OriginalContractNumber__c = contract.OriginalContractNumber__c;
    con.Status__c = 'Ativo';
    con.ProcessStatus__c = 'Contrato Prorrogado';
    update con;

    con.Status__c = 'Em Aprovação';
    update con;
    Test.stopTest();
  }
  
}