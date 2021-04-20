@isTest
/********************************
Created By: Linus@introv

Tested Classes:
1. ASI_TnE_KR_UpdateCustomSubmitController
*********************************/

public class ASI_TnE_KR_UpdateCustomSubmitCtrl_Test{

    static testMethod void ASI_TnE_KR_UpdateCustomSubmitController(){
        
        List<User> tempUsers = ASI_TnE_KR_TestClassHelper.createTestUser(); //user list
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
        List<ASI_TnE_ClaimHeader__c> tempHeaders = ASI_TnE_KR_TestClassHelper.createHeaderTriggerTestRecord(tempUsers); //claim header list
        List<ASI_TnE_ClaimDetail__c> tempDetails = ASI_TnE_KR_TestClassHelper.createDetailTriggerTestRecord(tempHeaders,tempSubBrands,tempCats,tempClasses,tempCustomers,tempUsers); //claim detail list
                
        ASI_TnE_ClaimHeader__c tempHeader1 = 
            new ASI_TnE_ClaimHeader__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE'),
                                       OwnerID = tempUsers[3].id, ASI_TnE_KR_Payee__c = tempUsers[1].id,
                                       ASI_TnE_Status__c = 'Draft', ASI_TnE_Date__c = date.today(),
                                       ASI_TnE_KR_Year__c = String.valueOf(date.today().year()),
                                       ASI_TnE_KR_Month__c = String.valueOf(date.today().month()-1),
                                       ASI_TnE_KR_Credit_Card_No__c = '1111-1111-1111-1111',
                                       ASI_TnE_KR_LookupTnE__c = tempHeaders[3].Id);        
        insert tempHeader1;
        
        ASI_TnE_ClaimDetail__c tempDetail1 = 
            new ASI_TnE_ClaimDetail__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_KR_Claim_Detail'),
                                       ASI_TnE_ClaimHeader__c = tempHeader1.id,
                                       ASI_TnE_Receipt_Date__c = date.today()-60,
                                       ASI_TnE_Receipt_Amount__c = 25
                                      );
        
        insert tempDetail1;
        
        
        Test.startTest();        
        PageReference pageRef = Page.ASI_TnE_KR_UpdateCustomSubmitPage;
        test.setCurrentPageReference(pageRef);        
        pageRef.getParameters().put('id',tempHeader1.id);
        
        ASI_TnE_KR_UpdateCustomSubmitController s = new ASI_TnE_KR_UpdateCustomSubmitController();
        s.refresh();
        
        Test.stopTest();
    }
}