@isTest
private class ASI_KOR_RSDPaymentSettlementControlTest
{
    @isTest(seeAllData=false)
    public static void testRSDPaymentSettlementCreation(){
    
         testDataCreation();         
   

    }
    
    public static void testDataCreation(){
    
         Map<String,Id> brandMap = ASI_KOR_TestHelper.insertBrands();

		 Profile p = [SELECT Id FROM Profile WHERE Name='ASI KOR Standard Platform User'];    
		 
        User rsdUser = new User(Alias = 'testRSD', Email='testRSD@laputa-pernod-ricard.com.test', 
            EmailEncodingKey='UTF-8', LastName='testRSD', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= 'testRSD@laputa-pernod-ricard.com.test',
			ASI_KOR_User_Region_Name__c = 'test');
        insert rsdUser;
		 		 
        User srUser = new User(Alias = 'testSR', Email='testSR@laputa-pernod-ricard.com.test', 
            EmailEncodingKey='UTF-8', LastName='testSR', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName= 'testSR@laputa-pernod-ricard.com.test',
			ASI_KOR_User_Region_Name__c = 'test');
        insert srUser;
		 
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
		 rsdPaymentSettlementHeader.ownerid = rsdUser.id;
		 rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = 0;
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
         bmPaymentSettlementHeader.ASI_KOR_Status__c = 'Submitted';
         bmPaymentSettlementHeader.ASI_KOR_RSD_Payment_Settlement__c = rsdPaymentSettlementHeader.id;
		 bmPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = 0;
         insert bmPaymentSettlementHeader;
         
         ASI_KOR_BM_Payment_Settlement_By_Brand__c bmPaymentSettlementByBrand1 
         = new ASI_KOR_BM_Payment_Settlement_By_Brand__c();         
         bmPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         bmPaymentSettlementByBrand1.ASI_KOR_BM_Payment_Settlement__c = bmPaymentSettlementHeader.Id;
         bmPaymentSettlementByBrand1.ASI_KOR_RSD_Payment_Settlement_By_Brand__c = rsdPaymentSettlementByBrand1.Id;
         bmPaymentSettlementByBrand1 .ASI_KOR_UOM__c = 'Bottle';
         insert bmPaymentSettlementByBrand1;         
         
         Account newAccount = new Account();
         newAccount.Name = 'TestName';
         newAccount.ASI_KOR_Customer_Code__c = '123456';
         insert newAccount;
         
         ASI_KOR_SR_Payment_Settlement_Header__c srPaymentSettlementHeader = new
         ASI_KOR_SR_Payment_Settlement_Header__c();
         srPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         srPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         srPaymentSettlementHeader.ASI_KOR_Status__c = 'Submitted';
         srPaymentSettlementHeader.ASI_KOR_BM_Payment_Settlement_Header__c = bmPaymentSettlementHeader.Id;
		 srPaymentSettlementHeader.ownerid = srUser.id;
         insert srPaymentSettlementHeader;
         
         ASI_KOR_SR_Payment_Settlement_By_Brand__c srPaymentSettlementByBrand1 
         = new ASI_KOR_SR_Payment_Settlement_By_Brand__c();         
         srPaymentSettlementByBrand1.ASI_KOR_Brand__c = brandMap.get('Absolut');
         srPaymentSettlementByBrand1.ASI_KOR_SR_Payment_Settlement__c = srPaymentSettlementHeader.Id;
         srPaymentSettlementByBrand1.ASI_KOR_BM_Payment_Settlement_By_Brand__c = bmPaymentSettlementByBrand1.Id;
         srPaymentSettlementByBrand1.ASI_KOR_UOM__c = 'Bottle';
         insert srPaymentSettlementByBrand1;  
         
         ASI_KOR_SR_Payment_Settlement_Detail__c srPaymentSettlementDetail = 
         new ASI_KOR_SR_Payment_Settlement_Detail__c();
         srPaymentSettlementDetail.ASI_KOR_Brand__c = brandMap.get('Absolut');
         srPaymentSettlementDetail.ASI_KOR_Venue_Name__c = newAccount.Id;
         srPaymentSettlementDetail.ASI_KOR_SR_Payment_Settlement_By_Brand__c = srPaymentSettlementByBrand1.Id;
         srPaymentSettlementDetail.ASI_KOR_SR_Payment_Settlement__c = srPaymentSettlementHeader.Id;
         
         insert srPaymentSettlementDetail;
         
               
         List<ASI_KOR_SR_Payment_Settlement_Detail__c> paymentSettlementDetails = [SELECT Id from ASI_KOR_SR_Payment_Settlement_Detail__c
         WHERE ASI_KOR_SR_Payment_Settlement__c = :srPaymentSettlementHeader.Id];       
         
         System.debug('Flag XX: paymentSettlementDetails ' + paymentSettlementDetails );
         
         ApexPages.StandardController standardController = new ApexPages.StandardController(rsdPaymentSettlementHeader);
         
         ASI_KOR_RSDPaymentSettlementController rsdPaymentSettlementController = new ASI_KOR_RSDPaymentSettlementController(standardController);
        
         for(ASI_KOR_RSDPaymentSettlementController.RSDByBranchCategory rsdByBranchCategory : rsdPaymentSettlementController.rsdByBranchCategoryList )
         {
             rsdByBranchCategory.bmHeader.ASI_KOR_Status__c = 'Rejected';
         }
        
         rsdPaymentSettlementController.handleSave();             
         
         for(ASI_KOR_RSDPaymentSettlementController.RSDByBranchCategory rsdByBranchCategory : rsdPaymentSettlementController.rsdByBranchCategoryList )
         {
             rsdByBranchCategory.bmHeader.ASI_KOR_Status__c = 'Approved by RSD';
         }
		 
		 ASI_KOR_RSDPaymentSettlementController.RSDByBranchCategory a = rsdPaymentSettlementController.rsdByBranchCategoryList.get(0);
		 a.getTargetVolume();
		 a.getTargetVIPlanned();
		 a.getActualVolume();
		 a.getTotalVI();
		 a.getTotalPrepayment();
		 a.getTotalFinal();
		 a.getTotalBudgetVolume();
		 a.getTotalBudgetVI();
		 a.getPrepaymentVolume();
		 a.getPlannedUC();
		 a.getSettlementUC();
		 a.getBudgetUC();
		 a.getBudgetStatus();
		 a.getPrepaymentVolume();
         
         rsdPaymentSettlementController.getGrandBudgetStatus(); 
         rsdPaymentSettlementController.getGrandTotal_UC(); 
         rsdPaymentSettlementController.getGrandTotal_UC_planned(); 
         rsdPaymentSettlementController.getGrandTotal_UC_budget(); 
         rsdPaymentSettlementController.handleSave();             
         rsdPaymentSettlementController.handleSubmit();
         rsdPaymentSettlementController.handleRecall();
         rsdPaymentSettlementController.rollUp(rsdPaymentSettlementHeader.Id, false);
    }

}