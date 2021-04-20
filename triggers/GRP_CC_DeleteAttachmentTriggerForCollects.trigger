/*
* Created Date: November 08,2016
*
* Description: CC-429 Config - Collect : display an icon on collects when a file is attached
*
*/
trigger GRP_CC_DeleteAttachmentTriggerForCollects on Attachment (after delete) {
	List<GRP_CC_Collect__c> collectList = new List<GRP_CC_Collect__c> ();
    Set<Id>  collectIds = new Set<Id> ();
    
    for(Attachment att : trigger.old){
         // Check if added attachment is related to Collect custom object or not
         if(att.ParentId.getSobjectType() == GRP_CC_Collect__c.SobjectType){
              collectIds.add(att.ParentId);
         }
    }
    collectList = [select id from GRP_CC_Collect__c where id in : collectIds];
    if(collectList!=null && collectList.size()>0){
        for(GRP_CC_Collect__c col : collectList){
			Integer numAtts=[select count() from attachment where parentid=:col.Id];
			if (numAtts <= 0)
				col.GRP_CC_File_attached__c = false;
        }
        update collectList;
    }
}