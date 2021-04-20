@isTest
public class ASI_KOR_KeymanAllocationBatchTest
{
    
    @isTest
    public static void ASI_KOR_KeymanAllocationBatchTest()
    {    
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
		 
         Account newAccount = new Account();
         newAccount.Name = 'TestName';
         newAccount.ASI_KOR_Customer_Code__c = '123456';
         newAccount.ownerid = srUser.id;
         insert newAccount;
         
		 ASI_KOR_Venue_Supplier__c newWholesaler = new ASI_KOR_Venue_Supplier__c(
			ASI_KOR_Venue_Supplier_To_Venue_Lookup__c = newAccount.id,
			ASI_KOR_Representative_WS__c = true,
			ASI_KOR_Wholesaler_Code__c = '123456'
		 );
		 insert newWholesaler;
		 
		 Contact newContact = new Contact(
			firstName = 'Test',
			LastName = 'Keyman'
		 );
		 insert newContact;
		 
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
         
         ASI_KOR_SR_Payment_Settlement_Header__c srPaymentSettlementHeader = new
         ASI_KOR_SR_Payment_Settlement_Header__c();
         srPaymentSettlementHeader.ASI_KOR_Month__c = '1';
         srPaymentSettlementHeader.ASI_KOR_Year__c = '2014';
         srPaymentSettlementHeader.ASI_KOR_Status__c = 'Approved by BM';
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
         srPaymentSettlementDetail.ASI_KOR_Actual_Volume__c = 100;
         srPaymentSettlementDetail.ASI_KOR_Settlement_Unit_Cost__c = 10000;
         
         insert srPaymentSettlementDetail;
         
        
        Map<String,Id> productItemMap = ASI_KOR_TestHelper.insertProductItem(brandMap);
        Map<String,Id> itemGroupMap = ASI_KOR_TestHelper.insertItemGroup(productItemMap);
        
        list<ASI_KOR_VMS_Interface_File__c> list_vdd = new list<ASI_KOR_VMS_Interface_File__c>();
		for (string itemGroupID : itemGroupMap.values()){
			ASI_KOR_VMS_Interface_File__c vdd1 = new ASI_KOR_VMS_Interface_File__c(
				ASI_KOR_Venue__c = newAccount.id,
				ASI_KOR_Item_Group__c = itemGroupID,
				ASI_KOR_UOM__c = 'C',
				ASI_KOR_Quantity_Bottle__c = 10,
				ASI_KOR_Quantity_Case__c = 10,
				ASI_KOR_Keyman__c = newContact.id,
				ASI_KOR_Promotion_Year__c = '2014',
				ASI_KOR_Promotion_Month__c = '1'
			);
			list_vdd.add(vdd1);
		}
        insert list_vdd;
        
        Test.StartTest();
        
        Database.executeBatch(new  ASI_KOR_KeymanAllocationBatch('2014','1','test', rsdPaymentSettlementHeader, new Map<Id, Set<String>>(), new List<String>()));
		
        Test.StopTest();
        
        
    }
    
    
}