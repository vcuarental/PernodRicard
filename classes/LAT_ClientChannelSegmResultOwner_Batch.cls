global class LAT_ClientChannelSegmResultOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    
    String query;
    Map <Id, Id> accountNewOwner = new Map<Id, Id>();
    Set <Id> accounts = new Set <Id>();

    global LAT_ClientChannelSegmResultOwner_Batch(String headerId) {


        List <LAT_MasiveOwnerLine__c> lines = [Select LAT_Account__c, LAT_NewValue__c From LAT_MasiveOwnerLine__c Where LAT_Header__c = :headerId];
    

        for(LAT_MasiveOwnerLine__c line :lines){
            accounts.add(line.LAT_Account__c);
            accountNewOwner.put(line.LAT_Account__c, line.LAT_NewValue__c);
        }

        query = 'Select Id, ownerId, Account__c From LAT_BR_ClientChannelSegmentation2Result__c where Account__c in :accounts';

    }

    global LAT_ClientChannelSegmResultOwner_Batch(Map<Id, Lat_Account__c> mapLatAccount) {

        accounts = mapLatAccount.keySet();
        accountNewOwner = new Map<Id, Id>();

        for(Lat_Account__c latacc :mapLatAccount.values()){
            
            accountNewOwner.put(latacc.LAT_Accountid__c, latacc.LAT_Accountid__r.ownerid);
        }

        query = 'Select Id, ownerId, Account__c From LAT_BR_ClientChannelSegmentation2Result__c where Account__c in :accounts';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        System.debug('%%%% scope.size() : ' + scope.size());
        List <LAT_BR_ClientChannelSegmentation2Result__c> lat_seg_result = (List<LAT_BR_ClientChannelSegmentation2Result__c>)scope;
        
        for (LAT_BR_ClientChannelSegmentation2Result__c result : lat_seg_result) {
            
            result.ownerId = accountNewOwner.get(result.Account__c);
            result.LAT_BR_Dont_Update_After_Owner__c = true;
    
        }

        if(lat_seg_result.size() > 0)
            update lat_seg_result;
    
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}