@isTest
public class ASI_HK_CRM_EDISORegenHelperCtrlTest 
{
    static testMethod void testSORegen()
    {
        ASI_CRM_EDI_SO_Header__c ediso = new ASI_CRM_EDI_SO_Header__c();
        ediso.ASI_CRM_ETL_Complete__c = TRUE;
        ediso.ASI_CRM_Trigger_Processed__c = TRUE;
        ediso.ASI_CRM_Order_Date__c = '2019-08-01';
        ediso.ASI_CRM_Buyer_ID__c = 'ABC';
        
        insert ediso;
        
        Test.startTest();
        PageReference testPage = Page.ASI_HK_CRM_EDISORegenHelperPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id',ediso.Id);
        System.debug('Id : ' + ediso.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_HK_CRM_EDISORegenHelperController controller = new ASI_HK_CRM_EDISORegenHelperController();
        controller.submitHelper();
        
        /*[WL 1.0] BEGIN*/
        ASI_CRM_EDI_Invoice_Header__c inv = new ASI_CRM_EDI_Invoice_Header__c();
        insert inv;
        ediso.ASI_HK_CRM_EDI_Invoice__c = inv.id;
        update ediso;
        
        controller.submitHelper();        
        controller.retrieveSKUPriceHelper();
        /*[WL 1.0] END*/
		
        ediso.ASI_CRM_ETL_Complete__c = FALSE;
        update ediso;
        controller.submitHelper();
        
        /*[WL 1.0] BEGIN*/
        controller.retrieveSKUPriceHelper();	  
        //Wilken 20190315 END
        Test.stopTest();
    }//end method
	
	static testMethod void testSORegenSKU()
    {
        ASI_CRM_EDI_SO_Header__c ediso = new ASI_CRM_EDI_SO_Header__c();
        ediso.ASI_CRM_ETL_Complete__c = TRUE;
        ediso.ASI_CRM_Trigger_Processed__c = TRUE;
        ediso.ASI_CRM_Order_Date__c = '2019-08-01';
        ediso.ASI_CRM_Buyer_ID__c = 'ABC';
        
        insert ediso;
        
        Test.startTest();
        PageReference testPage = Page.ASI_HK_CRM_EDISORegenHelperPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id',ediso.Id);
        System.debug('Id : ' + ediso.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_HK_CRM_EDISORegenHelperController controller = new ASI_HK_CRM_EDISORegenHelperController();
        controller.submitHelper();
        
        /*[WL 1.0] BEGIN*/
        ASI_CRM_EDI_Invoice_Header__c inv = new ASI_CRM_EDI_Invoice_Header__c();
        insert inv;
        ediso.ASI_HK_CRM_EDI_Invoice__c = inv.id;
        update ediso;
        
        pageParams.put('type','retrieveSKUPrice');
        Test.setCurrentPageReference(testPage);
        controller.submitHelper();        
        controller.retrieveSKUPriceHelper();
        /*[WL 1.0] END*/

        Test.stopTest();
    }//end method
}