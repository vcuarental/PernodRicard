/*
 * Coverage is done in EUR_CRM_AutomaticSharingTest
 */
public class EUR_CRM_AutomaticSharingTriggerHandler extends EUR_CRM_TriggerHandler{
    override public void beforeUpdate(){
        
        EUR_CRM_AutomaticSharing.controlStatusAS(
            (Map<Id, EUR_CRM_Automatic_Sharing__c>) Trigger.newMap, 
            (Map<Id, EUR_CRM_Automatic_Sharing__c>) Trigger.oldMap
        );
    }

}