/*
* Created Date: November 08,2016
*
* Description: CC-429 Config - Collect : display an icon on collects when a file is attached
*
*/
trigger GRP_CC_AttachmentTriggerForCollects on Attachment (after insert) {
    // When an attach file is proceeded on Collect object, a flag GRP_CC_File_attached__c is set to true
    // This flag is viewable on Chain Account page
    List<GRP_CC_Collect__c> collectList = new List<GRP_CC_Collect__c> ();
    Set<Id>  collectIds = new Set<Id> ();
    
    for(Attachment att : trigger.New){
         // Check if added attachment is related to Collect custom object or not
         if(att.ParentId.getSobjectType() == GRP_CC_Collect__c.SobjectType){
              collectIds.add(att.ParentId);
         }
    }
    collectList = [select id from GRP_CC_Collect__c where id in : collectIds];
    if(collectList!=null && collectList.size()>0){
        for(GRP_CC_Collect__c col : collectList){
            col.GRP_CC_File_attached__c = true;
        }
        update collectList;
    }
}