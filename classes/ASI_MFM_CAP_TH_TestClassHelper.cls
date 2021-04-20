/*********************************************************************************
 * Name:ASI_MFM_CAP_TH_TestClassHelper
 * Description: For generating test data for OPEX TH
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 17/05/2016       Laputa: Hugo            Created
*********************************************************************************/

@isTest
public class ASI_MFM_CAP_TH_TestClassHelper {

	public static Account createAccountSupplier() {

		Account acc = new Account(
			Name = 'Testing Supplier',
			ASI_MFM_Customer_Supplier_Number__c = '1234',
			recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CAP_TH_Supplier')
		);

		insert acc;
		return acc;

	}

	public static ASI_MFM_A_C_Code__c createAcCode() {

		ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
			Name = '2281.1234 Testing AC Code',
			ASI_MFM_A_C_Code__c = '2281.1234',
			recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_CAP_TH_A_C_Code')
		);

		insert acCode;
		return acCode;
	}

	public static ASI_MFM_AP_Code__c createApCode(ASI_MFM_A_C_Code__c acCode) {

		ASI_MFM_AP_Code__c apCode = new ASI_MFM_AP_Code__c(
			Name = '2281.1234 Test AP Code',
			ASI_MFM_AP_Code__c = '2281.1234',
			ASI_MFM_A_C_Code__c = acCode.Id,
			recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_CAP_TH_AP_Code')
		);

		insert apCode;
		return apCode;

	}

	public static User createUser(Id userRoleId) {

		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		userRole r = [SELECT Id, Name, DeveloperName FROM userRole WHERE Id = :userRoleId];
		
		User newUser = new User(
			Alias = 'tuser1',
			Email = 'testinguser@testorg.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = p.Id,
			UserName = 'testinguser1@testorg.com',
			UserRoleId = r.id,
			ASI_MFM_Country__c = 'TH',
			TimeZoneSidKey='America/Los_Angeles'
		);

		insert newUser;
		return newUser;
	}

	public static ASI_MFM_Prefix__c createPrefixPO(user u) {

		ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c(
			Name = 'Testing PO Prefix',
			ASI_MFM_Module__c = 'PO',
			ASI_MFM_Fiscal_year__c = 'FY1516',
			RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_TH_Prefix')
		);         

		System.runAs(u) {
			insert prefixCap;
		}

		UserRole r = [SELECT Id, Name, DeveloperName FROM UserRole WHERE Id = :u.UserRoleId];
		ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c(
			ASI_MFM_Prefix__c = prefixCap.Id,
			ASI_MFM_Role_Name__c = r.DeveloperName
		);

		System.runAs(u) {
			insert rel;
		}

		return prefixCap;
	}
	

	public static ASI_MFM_Prefix__c createPrefixPayment(user u) {

		ASI_MFM_Prefix__c prefixCap = new ASI_MFM_Prefix__c(
			Name = 'Testing Payment Prefix',
			ASI_MFM_Module__c = 'Payment',
			ASI_MFM_Fiscal_year__c = 'FY1516',
			RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CAP_TH_Prefix')
		);         

		System.runAs(u) {
			insert prefixCap;
		}

		UserRole r = [SELECT Id, Name, DeveloperName FROM UserRole WHERE Id = :u.UserRoleId];
		ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c(
			ASI_MFM_Prefix__c = prefixCap.Id,
			ASI_MFM_Role_Name__c = r.DeveloperName
		);

		System.runAs(u) {
			insert rel;
		}

		return prefixCap;

	}

	public static ASI_MFM_Payment__c createPayment(Account acc, ASI_MFM_Prefix__c prefix) {

		ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c(
			ASI_MFM_Currency__c = 'THB',
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Invoice_Number__c = '1234',
            ASI_MFM_Invoice_Date__c = date.today(),
            ASI_MFM_Prefix__c= prefix.Id,
            ASI_MFM_Supplier_Name__c = acc.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_TH_Payment')
		);

		insert payment;
		return payment;
	}

	public static ASI_MFM_Payment_Line_Item__c createPaymentLines(ASI_MFM_Payment__c payment, ASI_MFM_PO_Line_Item__c poi, ASI_MFM_AP_Code__c apCode, ASI_MFM_A_C_Code__c acCode)
    {
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c
        (
        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_TH_Payment_Line_Item'),
	        ASI_MFM_Payment__c=payment.id, 
	        ASI_MFM_Payment_Amount__c=10, 
	        ASI_MFM_PO_Line_Item__c=poi.id, 
	        ASI_MFM_Invoice_Date__c = date.today(), 
	        ASI_MFM_Invoice_Number__c = '123456',
	        ASI_MFM_AP_Code__c = apCode.id,
	        ASI_MFM_A_C_Code__c = acCode.id
	        );                       
        insert pyi;
        return pyi;
    }

	public static ASI_MFM_PO__c createPO(ASI_MFM_Prefix__c prefix) {

		ASI_MFM_PO__c po = new ASI_MFM_PO__c(
			Name = 'Testing PO',
			ASI_MFM_PO_End_Date__c = date.today().addmonths(1),
            ASI_MFM_Prefix__c = prefix.Id,
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_TH_PO')
		);

		insert po;
		return po;

	}

	public static ASI_MFM_PO_Line_Item__c createPOLine(ASI_MFM_PO__c po) {

		ASI_MFM_PO_Line_Item__c poLineItem = new ASI_MFM_PO_Line_Item__c(
			ASI_MFM_G_L_Date__c = date.today(),
            ASI_MFM_PO__c = po.Id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_TH_PO_Line_Item')
		);

		insert poLineItem;
		return poLineItem;
	}
}