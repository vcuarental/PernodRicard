trigger ASI_CRM_CN_FeedComment_AfterInsert_Trigger on FeedComment (after insert) {
  set<Id> FeedId = new set<Id>();
  Map<Id, FeedComment> FeedIdMap = new map<Id, FeedComment>();
  List<FeedComment> objList = new List<FeedComment>();
  for (FeedComment a : trigger.new){
    FeedId.add(a.parentId);
    FeedIdMap.put(a.parentId, a);
  }
  system.debug('FeedId: ' +FeedId);
  if (FeedId.size() > 0){
    for (id c : FeedId){
      String sObjName = c.getSObjectType().getDescribe().getName();
      if (sObjName == 'ASI_CRM_Issue_Zone__c'){
        if (FeedIdMap.containskey(c)){
          objList.add(FeedIdMap.get(c));
        }
      }
    }
  }
  if (objList.size() > 0){
      ASI_CRM_CN_ChatterSharing cs = new ASI_CRM_CN_ChatterSharing();
      cs.ASI_CRM_CN_ChatterAdminChangeStatusComment(objList);
  }  
}