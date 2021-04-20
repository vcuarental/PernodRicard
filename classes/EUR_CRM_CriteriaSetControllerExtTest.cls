/**
 * Test Class for EUR_CRM_CriteriaSetControllerExt
 * 
 */
@isTest
private class EUR_CRM_CriteriaSetControllerExtTest {
	public static EUR_CRM_Criteria_Set__c csImg;
    public static EUR_CRM_Criteria_Set__c csVol; 
    
    private static testMethod void testData() {
    	
    	Id ltImg = [Select Id from Recordtype where DeveloperName =: 'EUR_LT_Image_Level_Criteria'].Id;
     	Id ltVol = [Select Id from Recordtype where DeveloperName =: 'EUR_LT_Volume_Potential_Criteria'].Id;
     	
    	//Criteria Set Image
     	csImg = new EUR_CRM_Criteria_Set__c();
     	csImg.EUR_CRM_Name__c = 'LT Image Restaurant';
		csImg.RecordTypeId = ltImg;
		insert csImg;
    }
    
    static testMethod void runtestData(){
    	testData();
    	
    	test.startTest();
    	Pagereference pr = page.EUR_CRM_ConfigCriteriaPage;
    	pr.getParameters().put('cSetId', csImg.Id);
    	Test.setCurrentPage(pr);
     	
     	ApexPages.StandardController sc = new ApexPages.StandardController(csImg);
    	ApexPages.currentPage().getParameters().put('Id', csImg.Id);
    	EUR_CRM_CriteriaSetControllerExt cs = new EUR_CRM_CriteriaSetControllerExt(sc);  
    	cs.parentURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+csImg.Id; 
    	cs.saveCriteria();
    	test.stopTest();
    }
}