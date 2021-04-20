/**
 * Created by osman on 4.02.2021.
 */

public with sharing class EUR_TR_DeleteProfitabilityBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    public Iterable<SObject> start(Database.BatchableContext param1) {
        System.debug('EUR_TR_DeleteProfitabilityBatch is completed');
        return Database.getQueryLocator([
                SELECT Id,Name
                FROM EUR_TR_AccountProfitability__c
                WHERE RecordType.DeveloperName = 'EUR_TR_AccountProfitability'
        ]);
    }

    public void execute(Database.BatchableContext param1, List<EUR_TR_AccountProfitability__c> listOfAccountProfitability) {
        if (!listOfAccountProfitability.isEmpty()) {
            delete listOfAccountProfitability;
        }
    }

    public void finish(Database.BatchableContext param1) {
        System.debug('EUR_TR_DeleteProfitabilityBatch is completed');
    }


}