@isTest
public class EUR_CRM_ZA_TestAccountValidator {

    static testMethod void testValidator(){

        Id zaOffTradeRT = Global_RecordTypeCache.getRtId('EUR_CRM_Account__cEUR_ZA_Off_Trade');
        Id zaOnTradeRT = Global_RecordTypeCache.getRtId('EUR_CRM_Account__cEUR_ZA_On_Trade_Direct');

        EUR_CRM_Account__c accOff = new EUR_CRM_Account__c(
            Name = 'accOff',
            RecordTypeId = zaOffTradeRT
        );
        insert accOff;
        Test.startTest();
        EUR_CRM_Account__c accOn = new EUR_CRM_Account__c(
            Name = 'accOn',
            RecordTypeId = zaOnTradeRT
        );
        insert accOn;

        EUR_CRM_ZA_AccountValidator validator = new EUR_CRM_ZA_AccountValidator();
            List<EUR_CRM_Account__c> accounts = validator.getValidatedAccountList((new List<EUR_CRM_Account__c>{accOn, accOff}), (new List<String>{'EUR_ZA_On_Trade_Direct'}));
            System.AssertEquals(1, accounts.size());
            System.AssertEquals('accOn', accounts[0].Name);
        Test.stopTest();
    }
}