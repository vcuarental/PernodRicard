@isTest
public with sharing class LAT_BR_VFC27_OnTradeExecution_Test {
	static testMethod void LAT_BR_VFC27_OnTradeExecution_Test() {
		
		
		String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
         User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','MX'); 
        insert usuario;  
	

	    LAT_CRP_Custom_Report__c crp = new LAT_CRP_Custom_Report__c();
	    crp.LAT_VisualForceName__c = 'LAT_BR_VFP27_OnTradeExecution';
	    crp.LAT_ReportName__c = 'Test';
	    insert crp;

	    ApexPages.currentPage().getParameters().put('IdRep', crp.id);	
	    LAT_BR_VFC27_OnTradeExecution controller = new LAT_BR_VFC27_OnTradeExecution();
	}
}