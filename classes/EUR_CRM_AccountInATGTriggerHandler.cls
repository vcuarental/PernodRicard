/*
 * Coverage is done in EUR_CRM_AutomaticSharingTest
 */
public class EUR_CRM_AccountInATGTriggerHandler extends EUR_CRM_TriggerHandler{
    
    override public void afterInsert() {
        EUR_CRM_AutomaticSharing.moreOrLessAccountsDetected(Trigger.newMap.keySet());
    }
    
    override public void beforeDelete(){
        
        EUR_CRM_AutomaticSharing.moreOrLessAccountsDetected(Trigger.oldMap.keySet());
    }
    override public void afterUndelete(){
        EUR_CRM_AutomaticSharing.moreOrLessAccountsDetected(Trigger.newMap.keySet());
    }
}