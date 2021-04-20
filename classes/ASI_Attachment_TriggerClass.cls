public class ASI_Attachment_TriggerClass{
    public static void routineBeforeDelete(map<id, attachment> trigger_oldMap){
        set<id> PAIdSet = new set<id>();
        map<id, attachment> attachMap = new map<id, attachment>();
        for (attachment att : trigger_oldMap.values()){
            //Pricing Approval - avoid deletion of attachment on approved/completed record.
            if ((att.ParentId).getSObjectType().getDescribe().getName() == 'ASI_Pricing_Approval__c'){
                PAIdSet.add(att.ParentId);
                attachMap.put(att.ParentId, att);
            }
        }
        list<attachment> attList = new list<attachment>();
        if (PAIdSet.size() > 0){
            for (ASI_Pricing_Approval__c pa : [SELECT ASI_Status__c, id FROM ASI_Pricing_Approval__c WHERE id IN :PAIdSet AND (ASI_Status__c  != 'Rejected' AND ASI_Status__c  != 'Open' AND ASI_Status__c  != 'Void')]){
                if (attachMap.containskey(pa.id))
                    attList.add(attachMap.get(pa.id));
            }
        }
        if (attList.size() > 0){
            for (attachment att : attList){
                att.Name.addError('No Attachment can be deleted on submitted / approved record.');
            }    
        }
    }
}