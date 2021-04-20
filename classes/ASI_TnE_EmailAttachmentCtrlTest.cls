/*********************************************************************************
 * Name: ASI_TnE_EmailAttachmentCtrlTest
 * Description: Test class for ASI_TnE_EmailAttachmentController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/7/2017        Hugo Cheung           Created          
*/

@isTest
public class ASI_TnE_EmailAttachmentCtrlTest {
    
    @testSetup
	public static void setupTestData() {
		//Create running number for T&E claim header
        ASI_TnE_TestClassHelper.createRunningNumbers();
		
        //Create exchange rate
        ASI_MFM_Exchange_Rate__c exchangeRate1 = new ASI_MFM_Exchange_Rate__c();
        exchangeRate1.ASI_MFM_Application__c = 'T&E';
        exchangeRate1.ASI_MFM_Base_Currency__c = 'HKD';
        exchangeRate1.ASI_MFM_Counter_Currency__c = 'USD';
        exchangeRate1.ASI_MFM_Country__c = 'HK';
        exchangeRate1.ASI_MFM_Effective_Date__c = Date.Today().addMonths(-4);
        exchangeRate1.ASI_MFM_Exchange_Rate__c = 8.1;
        
        ASI_MFM_Exchange_Rate__c exchangeRate2 = new ASI_MFM_Exchange_Rate__c();
        exchangeRate2.ASI_MFM_Application__c = 'T&E';
        exchangeRate2.ASI_MFM_Base_Currency__c = 'HKD';
        exchangeRate2.ASI_MFM_Counter_Currency__c = 'USD';
        exchangeRate2.ASI_MFM_Country__c = 'HK';
        exchangeRate2.ASI_MFM_Effective_Date__c = Date.Today().addMonths(-5);
        exchangeRate2.ASI_MFM_Exchange_Rate__c = 8.0;
        
        ASI_MFM_Exchange_Rate__c exchangeRate3 = new ASI_MFM_Exchange_Rate__c();
        exchangeRate3.ASI_MFM_Application__c = 'T&E';
        exchangeRate3.ASI_MFM_Base_Currency__c = 'HKD';
        exchangeRate3.ASI_MFM_Counter_Currency__c = 'AUD';
        exchangeRate3.ASI_MFM_Country__c = 'HK';
        exchangeRate3.ASI_MFM_Effective_Date__c = Date.Today().addMonths(-1);
        exchangeRate3.ASI_MFM_Exchange_Rate__c = 5.636907;
        
        ASI_MFM_Exchange_Rate__c exchangeRate4 = new ASI_MFM_Exchange_Rate__c();
        exchangeRate4.ASI_MFM_Application__c = 'T&E';
        exchangeRate4.ASI_MFM_Base_Currency__c = 'HKD';
        exchangeRate4.ASI_MFM_Counter_Currency__c = 'AUD';
        exchangeRate4.ASI_MFM_Country__c = 'HK';
        exchangeRate4.ASI_MFM_Effective_Date__c = Date.Today().addMonths(-2);
        exchangeRate4.ASI_MFM_Exchange_Rate__c = 5.436907;
        
		List<ASI_MFM_Exchange_Rate__c> exchangeRateList = new List<ASI_MFM_Exchange_Rate__c>();
		exchangeRateList.add(exchangeRate1);
		exchangeRateList.add(exchangeRate2);
		exchangeRateList.add(exchangeRate3);
		exchangeRateList.add(exchangeRate4);
        insert exchangeRateList;
        
        //Create claim header
        ASI_TnE_ClaimHeader__c claimHeader = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header');
        ASI_TnE_ClaimHeader__c financeClaimHeader = ASI_TnE_TestClassHelper.createTestClaimHeader('1234567','ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header_Finance');
        
        //Create expense category and classification
        ASI_JP_TnE_Expense_Category__c expenseCategory = ASI_TnE_TestClassHelper.createExpenseCategory('ASI_JP_TnE_Expense_Category__cASI_TnE_HK_Expense_Category');
        ASI_JP_TnE_Expense_Classification__c expenseClassification = ASI_TnE_TestClassHelper.createExpenseCls('ASI_JP_TnE_Expense_Classification__cASI_TnE_HK_Expense_Classification',
                                                                                                              expenseCategory,
                                                                                                              ASI_TnE_TestClassHelper.createAccMap('ASI_TnE_Account_Mapping__cASI_TnE_HK_Account_Mapping')
                                                                                                              );
        
        //Create A/C Code
        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c();
        acCode.Name = 'Test A/C Code';
        acCode.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_TnE_HK_A_C_Code');
        insert acCode;
	}
    
    public static testMethod void testCtrl() {
        ASI_TnE_ClaimHeader__c claimHeader = [SELECT Id 
                                              FROM ASI_TnE_ClaimHeader__c 
                                              WHERE RecordTypeId =: Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header')
                                              LIMIT 1];
        
        Attachment att = new Attachment();
        att.Name     = 'Testing';
        att.Parentid = claimHeader.Id;
        att.Body     = Blob.valueof('Testing');
        insert att;
        
        ASI_TnE_EmailAttachmentController emailAttachmentCtrl = new ASI_TnE_EmailAttachmentController();
        emailAttachmentCtrl.currentHeaderId = claimHeader.Id;
        Map<String, String> urlMap = emailAttachmentCtrl.getUrlMap();
    }
}