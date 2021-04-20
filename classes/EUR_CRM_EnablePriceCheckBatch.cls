/*****************************************
* Sets the pricecheck checkbox to true in the account card
* According to the proce check frequency
* 2017-03-10 JAY: Add EUR_BE_Off_Trade
******************************************/
global class EUR_CRM_EnablePriceCheckBatch implements Database.Batchable<sObject>{

    private static Set<String> validRecordTypes = New Set<String>{  'EUR_DK_Off_Trade',
                                                                    'EUR_RU_Direct_Off_Trade',
                                                                    'EUR_RU_Direct_Type_2_Off_Trade',
                                                                    'EUR_RU_Indirect_Off_Trade',
                                                                    'EUR_BE_Off_Trade','EUR_IDL_Off_Trade_Account','EUR_DB_Off_Trade_Account'};



    global static String generateQuery(){ 
        String q ='SELECT Id, EUR_CRM_Price_Check__c, EUR_CRM_Price_Check_Frequency__c, ';
        q += 'EUR_CRM_Price_Check_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c, EUR_CRM_Price_Check_Frequency__r.EUR_CRM_Frequency_Span_Days__c ';
        q += 'FROM EUR_CRM_Account__c ';
        q += 'WHERE EUR_CRM_Price_Check__c = FALSE ';
        q += 'AND EUR_CRM_Price_Check_Frequency__c != null ';
        // set of valid recordtypes
        q += 'AND RecordType.DeveloperName IN : validRecordTypes';
        System.debug(q);
        return q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(generateQuery());
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        System.debug(scope);
        process((List<EUR_CRM_Account__c>) scope);
    }
   
    global void finish(Database.BatchableContext BC){
    
    }

    global static void process(List<EUR_CRM_Account__c> accountList){
        Map<Id, EUR_CRM_Account__c> accMap = new Map<Id, EUR_CRM_Account__c>();
        List<AggregateResult> priceCheckHistoryList = new List<AggregateResult>();
        List<EUR_CRM_Account__c> accsToUpdate = new List<EUR_CRM_Account__c>();
        for(EUR_CRM_Account__c acc : accountList){
            accMap.put(acc.Id, acc);
        }
        System.debug(accMap);
        priceCheckHistoryList = [SELECT ParentId, MAX(CreatedDate) FROM EUR_CRM_Account__History WHERE ParentId IN :accMap.KeySet() AND Field='EUR_CRM_Price_Check__c' GROUP BY ParentId];
        Date today = Date.Today();
        System.debug(priceCheckHistoryList);
        for(AggregateResult result : priceCheckHistoryList){
            EUR_CRM_Account__c acc = accMap.get((ID)result.get('ParentId'));
            Date dateOfLastChange = ((DateTime) result.get('expr0')).date();
            system.debug(dateOfLastChange);
            System.debug(acc);
            if(acc.EUR_CRM_Price_Check_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c != 0){
                Integer frequency = (Integer) ((acc.EUR_CRM_Price_Check_Frequency__r.EUR_CRM_Frequency_Span_Days__c) / (acc.EUR_CRM_Price_Check_Frequency__r.EUR_CRM_No_of_Visits_Within_Interval__c));
                System.debug(frequency);
                if(dateOfLastChange.addDays(frequency).isSameDay(today)){
                    System.debug('success');
                    acc.EUR_CRM_Price_Check__c = TRUE;
                    accsToUpdate.add(acc);
                }                
            }
        }
        // Update
        if(accsToUpdate.size() > 0){
            system.debug(accsToUpdate);
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', accsToUpdate);
        }
    }
}