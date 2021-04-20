//Edit: 11/07 - Check Contract record type; use EUR_CRM_Contract_Copy_File_Name__c, a field on Contract, for file name prefix

trigger EUR_CRM_Contract_Attachment_AfterDelete on Attachment (after delete){
    String contractObjName = 'EUR_CRM_Contract__c';
    Set<String> validContractRecordTypes = new Set<String>{'EUR_DE_Contract','EUR_GB_Contract'};
    Set<Id> attachmentParentIdSet = new Set<Id>();
    Set<Id> attachmentContractCopySet = new Set<Id>();
    List<EUR_CRM_Contract__c> contractForUpdate = new List<EUR_CRM_Contract__c>();
    Set<Id> contractIdSet = new Set<Id>();
    Map<Id, EUR_CRM_Contract__c> contractMap = new Map<Id, EUR_CRM_Contract__c>();
    
    //Iterate attachment
    for (Attachment att: Trigger.old){
        String sObjName = att.ParentId.getSObjectType().getDescribe().getName();
        if (sObjName.equalsIgnoreCase(contractObjName)){
            attachmentParentIdSet.add(att.ParentId);
        }
    }
    
    contractMap = new Map<Id, EUR_CRM_Contract__c>([SELECT Id, EUR_CRM_Contract_Uploaded__c, EUR_CRM_Contract_Copy_File_Name__c
                                                    FROM EUR_CRM_Contract__c WHERE Id IN:attachmentParentIdSet and recordtype.developername IN:validContractRecordTypes]);
    Set<Id> excludeContracts = new Set<Id>();
    
    for(Attachment att : [select id,name,ParentId from Attachment where ParentId in:contractMap.keySet() AND id not in:Trigger.oldMap.keySet()]){
        String fileNamePrefix = String.valueOf(contractMap.get(att.ParentId).EUR_CRM_Contract_Copy_File_Name__c);
            if (att.Name.length()>= fileNamePrefix .length() && 
                att.Name.subString(0, fileNamePrefix.length())== fileNamePrefix){//att.Name.contains(contractMap.get(att.ParentId).EUR_CRM_Contract_Copy_File_Name__c)){
                excludeContracts.add(att.ParentId);
            }
    }
    
    for (Attachment att : [SELECT Name, ParentId FROM Attachment 
                            WHERE ParentId IN: attachmentParentIdSet]){
                            //AND Name LIKE 'EUR_CRM_GB_Contract_Soft_Copy%']){
        //attachmentContractCopySet.add(att.ParentId);
        if (contractMap.containsKey(att.ParentId)){
            String fileNamePrefix = String.valueOf(contractMap.get(att.ParentId).EUR_CRM_Contract_Copy_File_Name__c);
            if (att.Name.length()>= fileNamePrefix .length() && 
                att.Name.subString(0, fileNamePrefix.length())== fileNamePrefix){//att.Name.contains(contractMap.get(att.ParentId).EUR_CRM_Contract_Copy_File_Name__c)){
                attachmentContractCopySet.add(att.ParentId);
            }
        }
    }
    Set<Id> tobeUpdated = new Set<Id>();
    for(EUR_CRM_Contract__c  contract : [select id from EUR_CRM_Contract__c where id in: attachmentParentIdSet and EUR_CRM_Contract_Uploaded__c = true]){
        tobeUpdated.add(contract.id);
    }
    for (Id delAttId : attachmentParentIdSet){
        if ((!attachmentContractCopySet.contains(delAttId)) && tobeUpdated.contains(delAttId) && 
            (!excludeContracts.contains(delAttId))){
            EUR_CRM_Contract__c contractRec = new EUR_CRM_Contract__c(Id=delAttId, EUR_CRM_Contract_Uploaded__c=false);
            contractForUpdate.add(contractRec);
        }
    }
    system.debug('contract for update: ' + contractForUpdate);
    if(contractForUpdate.size()>0){
        update contractForUpdate;
    }
    
}