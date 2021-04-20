/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_OutletValidateTrigHandlerTest
 * Description: Test class for ASI_CRM_VN_OutletValidateTriggerHandler
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-31       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_OutletValidateTrigHandlerTest {
    @TestSetup static void setup(){
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();
        ASI_CRM_VN_TestClassHelper.createCustomSettings();

        String profileId = [SELECT Id FROM Profile WHERE Name = 'ASI VN Standard User'].Id;

        User user = ASI_CRM_VN_TestClassHelper.createUser(profileId);
        insert user;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        customer.OwnerId = user.Id;
        customer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert customer;

        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;

        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(customer.Id, subBrand.Id);
        contract.ASI_CRM_End_Date__c = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        insert contract;
    }

    @IsTest static void testBehavior() {
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id, ASI_CRM_Special_Outlet__c FROM ASI_CRM_AccountsAdditionalField__c];

        try {
            customer.ASI_CRM_Special_Outlet__c = true;
            update customer;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Please upload the attachment'));
        }
    }

    @IsTest static void testUpdateOutletToInactive(){
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id, ASI_CRM_Active__c FROM ASI_CRM_AccountsAdditionalField__c];

        try {
            customer.ASI_CRM_Active__c = false;
            update customer;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assert(e.getMessage().contains('not able to update'));
        }
    }
}