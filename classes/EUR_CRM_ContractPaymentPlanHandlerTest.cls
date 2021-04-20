/**
 * Created by larsz on 10/1/2020.
 */
@IsTest
public with sharing class EUR_CRM_ContractPaymentPlanHandlerTest {
    @IsTest
    static void testInsert_DE_Contract() {
        EUR_CRM_Account__c acc = makeAccount('EUR_DE_On_Trade_B2B');
        insert acc;
        EUR_CRM_Contract__c contr = makeContract('EUR_DE_Contract');
        contr.EUR_CRM_Account__c = acc.Id;
        insert contr;
    }

    private static EUR_CRM_Account__c makeAccount(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Account__c(
                RecordTypeId = rtId
                ,   EUR_CRM_Postal_Code__c = '112233'
        );
    }

    private static EUR_CRM_Contract__c makeContract(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_Contract__c(
                RecordTypeId = rtId,
                EUR_CRM_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()),
                EUR_CRM_End_Date__c = Date.newInstance(Date.today().addYears(1).year(), 1, 1)
        );
    }
}