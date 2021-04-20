trigger ASI_CRM_CN_FeedItem_AfterInsert_Trigger on FeedItem (after insert) {
/* Old Name: ASI_CRM_CN_MentionShare 
    2014-02-11         Stella Sing        Created
   Goal: Sharing IssueZone Record with @Mention
   ********************************************************
   2014-03-28         Stella Sing        Updated
   Goal: Change IssueZone Record Status if post made with attachment
*/
  set<Id> RecordId = new set<Id>();
  Map<Id, FeedItem> FeedItemMap = new Map<Id, FeedItem>();
  List<FeedItem> FeedItemList = new List<FeedItem>();
  for (FeedItem a : trigger.new){
    RecordId.add(a.parentId);
    FeedItemMap.put(a.parentId, a);
  }
  if (RecordId.size() > 0){
    for (Id b : RecordId){
      String sObjName = b.getSObjectType().getDescribe().getName();
      if (sObjName == 'ASI_CRM_Issue_Zone__c'){
          if (FeedItemMap.containskey(b))
          FeedItemList.add(FeedItemMap.get(b));
      }
    }
  }
  if (FeedItemList.size() > 0){
    ASI_CRM_CN_ChatterSharing cs = new ASI_CRM_CN_ChatterSharing();
    cs.ASI_CRM_CN_ChatterShareMentioned(FeedItemList);
      cs.ASI_CRM_CN_ChatterChangeStatus(FeedItemList);
      cs.ASI_CRM_CN_ChatterAdminChangeStatus(FeedItemList);
  }
}