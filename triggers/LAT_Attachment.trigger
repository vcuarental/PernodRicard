trigger LAT_Attachment on Attachment (after insert, after delete, after update) {
    Set<String> latamSObjects = new Set<String>{'Visitas__c', 'LAT_Contract2__c'};
    List<Attachment> latamAttchs = new List<Attachment>();

    if(trigger.isUpdate || trigger.isInsert){
        for(Attachment a : trigger.new){
            if(latamSObjects.contains(a.ParentId.getSobjectType().getDescribe().getName())){
                latamAttchs.add(a);
            }
        }
        if(latamAttchs.size() > 0){
            System.debug('%%% LAtam Attachments: ' + latamAttchs);
            LAT_CTR_Attachment.runTriggers();
            if(trigger.IsAfter && trigger.isUpdate) {
                LAT_CTR_Attachment.processContractAttachment(latamAttchs);
            }
        }
    } else if(trigger.isDelete){
        for(Attachment a : trigger.old){
            if(latamSObjects.contains(a.ParentId.getSobjectType().getDescribe().getName())){
                latamAttchs.add(a);
            }
        }
        if(latamAttchs.size() > 0){
            System.debug('%%% LAtam Attachments on delete: ' + latamAttchs);
            LAT_CTR_Attachment.runTriggers();
        }
    }

    
}