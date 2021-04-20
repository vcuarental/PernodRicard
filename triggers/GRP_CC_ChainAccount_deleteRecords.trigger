trigger GRP_CC_ChainAccount_deleteRecords on GRP_CC_ChainAccount__c (after update) {
    List<GRP_CC_Collect__c> collects = new List<GRP_CC_Collect__c>();
    List<GRP_CC_CollectBQ__c> collectsBQ = new List<GRP_CC_CollectBQ__c>();
    List<GRP_CC_CollectBQS__c> collectsBQS = new List<GRP_CC_CollectBQS__c>();
    for(GRP_CC_ChainAccount__c ca : [Select Id from GRP_CC_ChainAccount__c where Id IN : Trigger.new and GRP_CC_Delete_related_records__c=true]){
        collects.addAll([Select id, GRP_CC_Contract__c from GRP_CC_Collect__c where GRP_CC_ChainAccount__c=:ca.Id]);
        collectsBQ.addAll([Select Id, GRP_CC_BrandQuality__c from GRP_CC_CollectBQ__c where GRP_CC_Collect__c IN : collects]);
        collectsBQS.addAll([Select Id, GRP_CC_BrandQualitySize__c from GRP_CC_CollectBQS__c where GRP_CC_Collect__c IN : collects]);
    }

    delete collectsBQS;
    delete collectsBQ;
    delete collects;
}