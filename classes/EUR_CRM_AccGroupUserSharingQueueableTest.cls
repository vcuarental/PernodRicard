/**
 * Created by YuriyRudenko on 9/21/2020.
 */
@isTest
public class EUR_CRM_AccGroupUserSharingQueueableTest {
    @TestSetup
    static void setup() {
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> childAccounts = new List<EUR_CRM_Account__c>();

        EUR_CRM_Account__c acc = new EUR_CRM_Account__c(Name = 'TestAccount');
        accounts.add(acc);
        insert accounts;

        EUR_CRM_Account__c parentAccount = [SELECT Id FROM EUR_CRM_Account__c WHERE Name = 'TestAccount'];
        for (Integer i = 0; i < 10; i++) {
            EUR_CRM_Account__c childAcc = new EUR_CRM_Account__c(Name = 'TestChildAccount ' + i, EUR_CRM_Parent_Account__r = parentAccount);
            childAccounts.add(childAcc);
        }
        insert childAccounts;

    }

    @isTest static void testExecuteMethod() {
        List<EUR_CRM_AccountGroupUser__c> listAgus = new List<EUR_CRM_AccountGroupUser__c>();
        Set<Id> aguIds = new Set<Id>();
        List<EUR_CRM_AccountGroup__c> ags = new List<EUR_CRM_AccountGroup__c>();
        List<EUR_CRM_Account__c> childAccounts = [SELECT Id FROM EUR_CRM_Account__c WHERE Name = 'TestChildAccount'];
        for (EUR_CRM_Account__c chAcc : childAccounts){
            ags.add(chAcc.EUR_CRM_AccountGroups__r);
        }

        for (EUR_CRM_AccountGroup__c ag : ags){
            listAgus.add(ag.EUR_CRM_AccountGroupUsers__r);
        }

        for (EUR_CRM_AccountGroupUser__c agu : listAgus){
            aguIds.add(agu.Id);
        }

        Test.startTest();
        EUR_CRM_AccGroupUserSharingQueueable agusq = new EUR_CRM_AccGroupUserSharingQueueable(aguIds);
        System.enqueueJob(agusq);
        Test.stopTest();
    }

}