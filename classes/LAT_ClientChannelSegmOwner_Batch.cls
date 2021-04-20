global class LAT_ClientChannelSegmOwner_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    
    String query;
    Map <Id, Id> accountNewOwner = new Map<Id, Id>();
    Set <Id> accounts = new Set <Id>();

    global LAT_ClientChannelSegmOwner_Batch(String headerId) {


        List <LAT_MasiveOwnerLine__c> lines = [Select LAT_Account__c, LAT_NewValue__c From LAT_MasiveOwnerLine__c Where LAT_Header__c = :headerId];
    

        for(LAT_MasiveOwnerLine__c line :lines){
            accounts.add(line.LAT_Account__c);
            accountNewOwner.put(line.LAT_Account__c, line.LAT_NewValue__c);
        }

        query = 'Select Id, ownerId, Account__c From LAT_BR_ClientChannelSegmentation2__c where Account__c in :accounts';

    }

    global LAT_ClientChannelSegmOwner_Batch (Map<Id, Lat_Account__c> mapLatAccount) {

        accounts = mapLatAccount.keySet();
        accountNewOwner = new Map<Id, Id>();

        for(Lat_Account__c latacc :mapLatAccount.values()){
            
            accountNewOwner.put(latacc.LAT_Accountid__c, latacc.LAT_Accountid__r.ownerid);
        }

        query = 'Select Id, ownerId, Account__c From LAT_BR_ClientChannelSegmentation2__c where Account__c in :accounts';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        System.debug('%%%% scope.size() : ' + scope.size());

        List <LAT_BR_ClientChannelSegmentation2__c> lat_channel_segm = (List<LAT_BR_ClientChannelSegmentation2__c>)scope;
        
        for (LAT_BR_ClientChannelSegmentation2__c seg : lat_channel_segm) {
            System.debug('%%%% accountNewOwner.get(seg.Account__c) : ' + accountNewOwner.get(seg.Account__c));
            seg.ownerId = accountNewOwner.get(seg.Account__c);
    
        }

        if(lat_channel_segm.size() > 0)
            update lat_channel_segm;
    
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}