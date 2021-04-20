public with sharing class EUR_CRM_ProsSegmentationCleanUpHandler extends EUR_CRM_TriggerAbstract{
    
    public EUR_CRM_ProsSegmentationCleanUpHandler() {
        super('EUR_CRM_ProsSegmentationCleanUpHandler');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
	    List<EUR_CRM_Pros_Segmentation__c> segmentations = [
		    SELECT Id
		    FROM EUR_CRM_Pros_Segmentation__c
		    WHERE EUR_CRM_Account__c = :oldMap.keySet()
	    ];
	    if (segmentations.size() > 0) {
		    Database.delete(segmentations);
	    }
    }
    
}