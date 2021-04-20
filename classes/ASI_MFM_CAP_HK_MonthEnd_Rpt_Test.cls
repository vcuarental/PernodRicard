@isTest(SeeAllData=false)
public class ASI_MFM_CAP_HK_MonthEnd_Rpt_Test {
    
    @testSetup static void setup() {
        //Setup OV Log
        List<ASI_MFM_CAP_OV_Creation_Log__c> testLogs = new List<ASI_MFM_CAP_OV_Creation_Log__c>();
        testLogs.add(
       		new ASI_MFM_CAP_OV_Creation_Log__c(
            	ASI_Brand_Owner_SKU__c = '123456',
                ASI_Country__c = 'HK',  ASI_ETL_Process_Date__c = System.now(),
                ASI_PO_Line_Found__c = true, ASI_PO_Number__c = '12345678',
                ASI_PO_Type__c = 'OP', ASI_PR_SKU_Found__c = true
            )
        );
        testLogs.add(
       		new ASI_MFM_CAP_OV_Creation_Log__c(
            	ASI_Brand_Owner_SKU__c = '123457',
                ASI_Country__c = 'HK', ASI_ETL_Process_Date__c = System.now(),
                ASI_PO_Line_Found__c = false, ASI_PO_Number__c = '12345679',
                ASI_PO_Type__c = '2P', ASI_PR_SKU_Found__c = false
            )
        );
        insert testLogs;
        
        //Retrofit from ASI_MFM_CAP_HK_TestClassHelper.apxc Start
        //Set Up MFM Prefix
		ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c(
			Name = 'Testing Payment Prefix',
			ASI_MFM_Module__c = 'Payment',
			ASI_MFM_Fiscal_year__c = 'FY1516',
			RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_HK_Prefix')
		);         

		insert prefixCap;

        User u = [SELECT id, UserRoleId FROM user WHERE Id = :UserInfo.getUserId()];
		UserRole r = [SELECT Id, Name, DeveloperName FROM UserRole WHERE Id = :u.UserRoleId];
		ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c(
			ASI_MFM_Prefix__c = prefixCap.Id,
			ASI_MFM_Role_Name__c = r.DeveloperName
		);

		insert rel;
        
		Account acc = new Account(
			Name = 'Testing Supplier',
			recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CAP_HK_Supplier')
		);

		insert acc;
        
        //Setup BOI Payment
        List<ASI_MFM_Payment__c> testPayment = new List<ASI_MFM_Payment__c>();
        String recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_HK_Payment');
        testPayment.add(
       		new ASI_MFM_Payment__c(
				ASI_MFM_Currency__c = 'HKD',
                ASI_MFM_PO_Number__c = '12345679',
                ASI_MFM_Invoice_Number__c = '1234',
                ASI_MFM_Company_Code__c = '00000',
                ASI_MFM_Invoice_Date__c = date.today(),
                ASI_MFM_Payment_Date__c = date.today(),
                ASI_MFM_PO_Type__c = '2P',
                RecordTypeId = recordTypeId,
                ASI_MFM_Status__c = 'Draft',
                ASI_MFM_Supplier_Name__c = acc.Id,
                ASI_MFM_Prefix__c = prefixCap.Id
            )
        );
        insert testPayment;
        
        //Retrofit from ASI_MFM_CAP_HK_TestClassHelper.apxc End
    }
    
    @isTest static void testMonthEndRpt() {
        Test.startTest();        
        Id JobId= Database.executeBatch(new ASI_MFM_CAP_HK_MonthEnd_Report(), 100);
        Test.stopTest();            
    }
}