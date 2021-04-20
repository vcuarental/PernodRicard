/**********************************************************************************
 * Name : ASI_CRM_SG_PopulateCustomer_Test
 * Created : DC @04/19/2016
 * Revision History:
 * 1. 04/19/2016 - [DC 1.0] Created
 * 2. 03/29/2017 - [WL 1.1] Added testSalesOrderReuestPositiveReExport for re-export SO enhancement
 * 3. 02/28/2018 - [WL 2.0] Add test for WS SO Default Approver code
 **********************************************************************************/
@isTest
private class ASI_CRM_SG_PopulateCustomer_Test {
    
    @TestSetup
    static void createTestData() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias  = 'standt', 
                          email = 'newUser@newUser.com',
                          EmailEncodingKey = 'UTF-8', 
                          LastName = 'Testing', 
                          LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', 
                          ASI_Company_Name__c = 'Testcompany',
                          ProfileId  = p.Id, 
                          ManagerId = UserInfo.getUserId(),
                          TimeZoneSidKey = 'America/Los_Angeles',
						  ASI_Default_Order_Customer__c = 'Sample Customer', 
						  ASI_Default_Order_Ship_To__c = 'Sample Customer', 
                          username = 'newUser1234@newUser1234.com');
        insert u;
        
        
        System.runAs(u) {
            /*
            Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                         .getRecordTypeInfosByName()
                                         .get('Wholesaler (SG)').getRecordTypeId();
            */
                                         
            Id customerRecTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Wholesaler');
    
            List<ASI_CRM_AccountsAdditionalField__c> lstCustomer = 
                new list<ASI_CRM_AccountsAdditionalField__c>();
    
            lstCustomer.add( new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Testcompany',
                RecordTypeId = customerRecTypeId
            ));
    
            lstCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Testcustomer',
                                                           RecordTypeId = customerRecTypeId));
            
            insert lstCustomer;  
        }
    } 

    static testMethod void testWholesalerSalesOrderPositive() {
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User testUser = [SELECT Id , ASI_Company_Name__c FROM User WHERE ProfileId =: testProfile.Id AND ASI_Company_Name__c = 'Testcompany'];

		/*[WL 2.0] BEGIN*/
		ASI_CRM_AccountsAdditionalField__c defaultCust = new ASI_CRM_AccountsAdditionalField__c(
															Name = 'Sample Customer', 
															RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
															ASI_CRM_MY_CustomerCode__c = '30005');
		insert defaultCust;
		
		ASI_CRM_SG_WS_SO_Approval__c soApproval = new ASI_CRM_SG_WS_SO_Approval__c(Name = '30005', ASI_CRM_Handler_1__c = System.UserInfo.getUserName(), ASI_CRM_Handler_2__c = System.UserInfo.getUserName(), 
																					ASI_CRM_Handler_3__c = System.UserInfo.getUserName(), ASI_CRM_Handler_4__c = System.UserInfo.getUserName());
		insert soApproval;
		/*[WL 2.0] END*/
		
        ASI_KOR_Sales_Order_Request__c salesOrderReq = new ASI_KOR_Sales_Order_Request__c(
            ASI_CRM_SG_Order_Date__c = Date.Today(),
            CurrencyIsoCode = 'SGD',
            ASI_CRM_SG_Country__c = 'Singapore Duty Paid',
            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Request__cASI_CRM_SG_Wholesaler'),
            OwnerId = testUser.Id
        );

        Test.startTest(); // Starts the scope of test
            insert salesOrderReq;
        Test.stopTest(); // Ends the scope of test
    }

    static testMethod void testSalesOrderReuestNegative() {       

        /*
        Id salesRecTypeId = Schema.SObjectType.ASI_KOR_Sales_Order_Request__c
                                  .getRecordTypeInfosByName()
                                  .get('ASI CRM SG Wholesaler').getRecordTypeId(); 
        */
        Id salesRecTypeId = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Request__cASI_CRM_SG_Wholesaler');

        ASI_KOR_Sales_Order_Request__c salesOrderReqst = 
                     new ASI_KOR_Sales_Order_Request__c( ASI_CRM_SG_Order_Date__c = Date.Today()
                                                       , CurrencyIsoCode = 'SGD'
                                                       , ASI_CRM_SG_Country__c = 'Singapore Duty Paid'
                                                       , RecordTypeId = salesRecTypeId
                                                       , OwnerId = UserInfo.getUserId() );
        Test.startTest(); // Starts the scope of test
            try {
                insert salesOrderReqst;
            }catch(Exception e) {
                String expectedExceptionThrown =  e.getMessage();
            }
        Test.stopTest(); // Ends the scope of test   
    }
	
	static testMethod void testSalesOrderReuestPositiveReExport() {
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User testUser = new User(Alias  = 'standt', 
                          email = 'newUser@newUser.com',
                          EmailEncodingKey = 'UTF-8', 
                          LastName = 'Testing', 
                          LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', 
                          ASI_Company_Name__c = 'Testcompany',
                          ProfileId  = testProfile.Id, 
                          ManagerId = UserInfo.getUserId(),
                          TimeZoneSidKey = 'America/Los_Angeles',
                          username = 'newUser1234@reexportTestUser.com',
						  ASI_Default_Order_Customer__c = 'Sample Customer',
						  ASI_Default_Order_Ship_To__c = 'Sample Customer');
        insert testUser;
		
		System.runAs(testUser) {
			Id salesRecTypeId = Global_RecordTypeCache.getRTId('ASI_KOR_Sales_Order_Request__cASI_CRM_SG_CA');

			ASI_CRM_AccountsAdditionalField__c cust = new ASI_CRM_AccountsAdditionalField__c(Name='Sample Customer', recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'), ASI_CRM_VN_Channel__c ='CA');
			insert cust;
			
			ASI_KOR_Sales_Order_Request__c salesOrderReq = new ASI_KOR_Sales_Order_Request__c(
				ASI_CRM_SG_Order_Date__c = Date.Today(),
				CurrencyIsoCode = 'SGD',
				ASI_CRM_SG_Country__c = 'Singapore Duty Paid',
				RecordTypeId = salesRecTypeId,
				OwnerId = testUser.Id
			);

			Test.startTest(); // Starts the scope of test
				insert salesOrderReq;
			Test.stopTest(); // Ends the scope of test
		}
    }
}