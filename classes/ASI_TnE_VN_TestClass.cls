@isTest
/**********************************************************************************
 * Name : ASI_TnE_VN_TestClass
 * Created : 
 * Revision History:
 * 1. 25/10/2017 - [WL 1.0] Correct test class from Elufa Leo's modification, in order to test ASI_TnE_VN_ClaimHeaderPDFController
 **********************************************************************************/
public class ASI_TnE_VN_TestClass
{
    static testMethod void testPDFController(){
        
        /*List<User> tempUsers = ASI_TnE_KR_TestClassHelper.createTestUser(); //user list
        List<ASI_eForm_HR_MDM__c> tempMDMs = ASI_TnE_KR_TestClassHelper.createMDMRecords(); //MDM list
        List<ASI_TnE_Account_Mapping__c> tempACMaps = ASI_TnE_KR_TestClassHelper.createAcMapRecords(); //accounting mapping list
        List<ASI_JP_TnE_Expense_Category__c> tempCats = ASI_TnE_KR_TestClassHelper.createExCatRecords(); //expense category list
        List<ASI_JP_TnE_Expense_Classification__c> tempClasses = ASI_TnE_KR_TestClassHelper.createExClassRecords(tempCats,tempACMaps); //expense classficiation list
        List<ASI_KOR_Brand__c> tempBrands = ASI_TnE_KR_TestClassHelper.createBrandRecords(); //brand list
        List<ASI_KOR_Sub_Brand__c> tempSubBrands = ASI_TnE_KR_TestClassHelper.createSubBrandRecords(tempBrands); //sub-brand list
        String fiscalYear1  = ASI_TnE_KR_TestClassHelper.createFY();
        List<ASI_TnE_Employee_Budget__c> tempBudgets = ASI_TnE_KR_TestClassHelper.createBudgetRecords(tempUsers,fiscalYear1); //budget list
        List<ASI_MFM_Exchange_Rate__c> tempExRates = ASI_TnE_KR_TestClassHelper.createExRateRecords(fiscalYear1); //exchange rate list
        List<ASI_TnE_Branch_Channel__c> tempBraChas = ASI_TnE_KR_TestClassHelper.createBraChannelRecords(); //branch channel list
        List<ASI_CRM_AccountsAdditionalField__c> tempCustomers = ASI_TnE_KR_TestClassHelper.createCustomerRecords(tempUsers); //customer list
        List<ASI_TnE_ClaimHeader__c> tempHeaders = ASI_TnE_KR_TestClassHelper.createGeneralHeaderRecord(tempUsers); //claim header list
        List<ASI_TnE_ClaimDetail__c> tempDetails = ASI_TnE_KR_TestClassHelper.createGeneralDetailRecord(tempHeaders,tempSubBrands,tempCats,tempClasses,tempCustomers,tempUsers); //claim detail list
        
        List<ASI_KR_Schd_Setting__c> schdSettings = new List<ASI_KR_Schd_Setting__c>();
    	schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For AnP Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_TnE_KR_AnPSchd'));
        schdSettings.add(new ASI_KR_Schd_Setting__c(Name ='For TnE Reminder',ASI_KR_isActivate__c=True,ASI_KR_numOfDays1__c=0,ASI_KR_numOfDays2__c=0,ASI_KR_schdClass__c='ASI_TnE_KR_TnESchd'));
        insert schdSettings;*/
        
        Test.startTest();        
		
		ASI_TnE_ClaimHeader__c header = new ASI_TnE_ClaimHeader__c(recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_VN_ClaimHeader'));
		insert header;
                
		ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(ASI_TnE_ClaimHeader__c = header.id, 
		recordTypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_VN_Claim_Detail'), ASI_TnE_VAT__c = false, ASI_TnE_Amount__c = 1000, ASI_TnE_Expense_Type__c = 'Hotel');
		insert detail;          
		
		ASI_TnE_VN_ClaimHeaderPDFController extension = new ASI_TnE_VN_ClaimHeaderPDFController();
		extension.currentHeaderId = header.Id;
		ASI_TnE_ClaimHeader__c testControllerGetHeader = extension.getHeader();
		List<ASI_TnE_ClaimDetail__c> testControllerGetClaimDetails = extension.getClaimDetails();
		
        //Test.setCurrentPage(Page.ASI_TnE_VN_ClaimHeaderPDFPage);
        //Apexpages.currentPage().getParameters().put('id', tempHeaders[2].id);
        //Apexpages.standardController sc2 = new apexpages.standardController(tempHeaders[2]);
        /*ASI_TnE_VN_ClaimHeaderPDFController cx2 = new ASI_TnE_VN_ClaimHeaderPDFController();
        cx2.currentHeaderId = tempHeaders[2].id;
        cx2.getHeader();
        cx2.getClaimDetails();*/
        Test.stopTest();
    }
}