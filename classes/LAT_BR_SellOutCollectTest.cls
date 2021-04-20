/******************************************************************************
*                           Company: Zimmic
*------------------------------------------------------------------------------
*  Test class para LAT_BR_SelloutCollect
*******************************************************************************/

@isTest
private class LAT_BR_SellOutCollectTest {
	//Test Constructor sin variables
	@isTest static void testConstructor() {
			LAT_BR_SellOutCollect c2 = new LAT_BR_SellOutCollect();
			system.assertEquals(c2.month, String.valueOf(Date.today().month()));
			system.assertEquals(c2.year, String.valueOf(Date.today().year()));
			system.assert(c2.client != null);
			system.assert(c2.headerList != null);
			
	}
	//Testea que el metodo agregue elementos a la lista
	@isTest static void testGetMonthsList() {
		 LAT_BR_SellOutCollect c2 = new LAT_BR_SellOutCollect();
		 c2.getMonthsList();
		 system.assertEquals(12,c2.getMonthsList().size());			 
	}
	 
	 @isTest static void testGetYearList() {
		 LAT_BR_SellOutCollect c2 = new LAT_BR_SellOutCollect();
		 c2.getYearList();
		 system.assertEquals(22,c2.getYearList().size());			 
	}

	@isTest static void testDoSearch() {
		LAT_SellOutCollect__c r = logs();
		LAT_BR_SellOutCollect c2 = new LAT_BR_SellOutCollect();
		c2.client = r; 
		c2.month=String.valueOf(Date.today().month());
		c2.year=String.valueOf(Date.today().year());
		c2.doSearch();		
		system.assertEquals(1,c2.headerList.size());
	}

	@isTest static void testDoColeta(){
		LAT_SellOutCollect__c r = logs();
		LAT_BR_SellOutCollect c2 = new LAT_BR_SellOutCollect();
		c2.client = r; 
		c2.month=String.valueOf(Date.today().month());
		c2.year=String.valueOf(Date.today().year());
		c2.doColeta();
			
	}
	@isTest static void testDoDelete(){
		LAT_SellOutCollect__c r = logs();
		LAT_BR_SellOutCollect c2 = new LAT_BR_SellOutCollect();
		PageReference p = Page.LAT_BR_VFP28_SellOutCollect;
		p.getParameters().put('obid',r.id);
		Test.setCurrentPage(p);
		c2.client = r; 
		c2.month=String.valueOf(Date.today().month());
		c2.year=String.valueOf(Date.today().year());
		c2.doSearch();		
		Integer size = c2.headerList.size();
		c2.doDelete();
		c2.doSearch();
		Integer size2 = c2.headerList.size();
		system.assertEquals(size2,size-1);
	}

		// Implement test codes

	public static LAT_SellOutCollect__c logs(){
		 Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
     insert Acc;
     LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
     rf.Account__c = Acc.id;
     rf.isActive__c = true;
     insert rf;
     LAT_SellOutCollect__c soc = new LAT_SellOutCollect__c();
     soc.CollectDate__c = Date.today();
     soc.ReferencedMonth__c = Date.newInstance(Integer.valueOf(Date.today().year()), Integer.valueOf(Date.today().month()), 1);
     soc.Status__c = 'Filling';
		 soc.ReferenceAccount__c = rf.id;

		
		 insert soc;
		 return soc;
	}
}