@isTest
public class ASI_KOR_ReminderTest{

    @isTest
    public static void testPlanning(){
    
        Map<String,SObject> propObjects = ASI_KOR_TestClassHelper.generateProposalObjects();

        ASI_KOR_BM_Proposal_Header__c bmHeader = (ASI_KOR_BM_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.BM_PROP_HEADER);
		PageReference pageRefBM = Page.ASI_KOR_BMPlanningReminder;
        Test.setCurrentPage(pageRefBM);
        ApexPages.currentPage().getParameters().put('id', bmHeader.id);
        ApexPages.StandardController scBM = new ApexPages.standardController(bmHeader);
        ASI_KOR_BMPlanningReminder bmController = new ASI_KOR_BMPlanningReminder(scBM);
		bmController.remind();

        ASI_KOR_RSD_Proposal_Header__c rsdHeader = (ASI_KOR_RSD_Proposal_Header__c) propObjects.get(ASI_KOR_TestClassHelper.RSD_PROP_HEADER);
		PageReference pageRefRSD = Page.ASI_KOR_RSDPlanningReminder;
        Test.setCurrentPage(pageRefRSD);
        ApexPages.currentPage().getParameters().put('id', rsdHeader.id);
        ApexPages.StandardController scRSD = new ApexPages.standardController(rsdHeader);
        ASI_KOR_RSDPlanningReminder rsdController = new ASI_KOR_RSDPlanningReminder(scRSD);
		rsdController.remind();
    }
	
	@isTest
    public static void testPayment(){
    
         Map<String,Id> brandMap = ASI_KOR_TestHelper.insertBrands();

        ASI_KOR_NSD_Payment_Settlement_Header__c nsdPaymentSettlementHeader = new
         ASI_KOR_NSD_Payment_Settlement_Header__c();
         nsdPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         nsdPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         nsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
         nsdPaymentSettlementHeader.ASI_KOR_SYS_Cut_off_Date__c =Date.today();
         insert nsdPaymentSettlementHeader;
         
         ASI_KOR_NSD_Payment_Settlement_By_Brand__c nsdPaymentSettlementByBrand1 
         = new ASI_KOR_NSD_Payment_Settlement_By_Brand__c();         
         nsdPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         nsdPaymentSettlementByBrand1.ASI_KOR_NSD_Payment_Settlement_Header__c = nsdPaymentSettlementHeader.Id;
         nsdPaymentSettlementByBrand1.ASI_KOR_UOM__c = 'Bottle';
         insert nsdPaymentSettlementByBrand1;
         
         ASI_KOR_RSD_Payment_Settlement_Header__c rsdPaymentSettlementHeader = new
         ASI_KOR_RSD_Payment_Settlement_Header__c();
         rsdPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         rsdPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         rsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
         rsdPaymentSettlementHeader.ASI_KOR_NSD_Payment_Settlement__c = nsdPaymentSettlementHeader.Id;
         rsdPaymentSettlementHeader.ASI_KOR_SYS_Cut_off_Date__c =Date.today();
         insert rsdPaymentSettlementHeader;
         
         ASI_KOR_RSD_Payment_Settlement_By_Brand__c rsdPaymentSettlementByBrand1 
         = new ASI_KOR_RSD_Payment_Settlement_By_Brand__c();         
         rsdPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         rsdPaymentSettlementByBrand1.ASI_KOR_RSD_Payment_Settlement__c = rsdPaymentSettlementHeader.Id;
         rsdPaymentSettlementByBrand1.ASI_KOR_NSD_Payment_Settlement_By_Brand__c = nsdPaymentSettlementByBrand1.Id;
         rsdPaymentSettlementByBrand1.ASI_KOR_UOM__c = 'Bottle';
         insert rsdPaymentSettlementByBrand1;         
         
         ASI_KOR_BM_Payment_Settlement_Header__c bmPaymentSettlementHeader = new
         ASI_KOR_BM_Payment_Settlement_Header__c();
         bmPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         bmPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         bmPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
         bmPaymentSettlementHeader.ASI_KOR_RSD_Payment_Settlement__c = rsdPaymentSettlementHeader.id;
         insert bmPaymentSettlementHeader;
         
         ASI_KOR_BM_Payment_Settlement_By_Brand__c bmPaymentSettlementByBrand1 
         = new ASI_KOR_BM_Payment_Settlement_By_Brand__c();         
         bmPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         bmPaymentSettlementByBrand1.ASI_KOR_BM_Payment_Settlement__c = bmPaymentSettlementHeader.Id;
         bmPaymentSettlementByBrand1.ASI_KOR_RSD_Payment_Settlement_By_Brand__c = rsdPaymentSettlementByBrand1.Id;
         bmPaymentSettlementByBrand1 .ASI_KOR_UOM__c = 'Bottle';
         insert bmPaymentSettlementByBrand1;  

		PageReference pageRefBM = Page.ASI_KOR_BMPaymentReminder;
        Test.setCurrentPage(pageRefBM);
        ApexPages.currentPage().getParameters().put('id', bmPaymentSettlementHeader.id);
        ApexPages.StandardController scBM = new ApexPages.standardController(bmPaymentSettlementHeader);
        ASI_KOR_BMPaymentReminder bmController = new ASI_KOR_BMPaymentReminder(scBM);
		bmController.remind();

		PageReference pageRefRSD = Page.ASI_KOR_RSDPaymentReminder;
        Test.setCurrentPage(pageRefRSD);
        ApexPages.currentPage().getParameters().put('id', rsdPaymentSettlementHeader.id);
        ApexPages.StandardController scRSD = new ApexPages.standardController(rsdPaymentSettlementHeader);
        ASI_KOR_RSDPaymentReminder rsdController = new ASI_KOR_RSDPaymentReminder(scRSD);
		rsdController.remind();
    }
    
}