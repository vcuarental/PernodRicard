//Edit: 11/07 - Check Contract record type; use EUR_CRM_Contract_Copy_File_Name__c, a field on Contract, for file name prefix

trigger EUR_CRM_Contract_Attachment_AfterInsert on Attachment (after insert){
    String contractObjName = 'EUR_CRM_Contract__c';
    Set<String> validContractRecordTypes = new Set<String>{'EUR_DE_Contract','EUR_GB_Contract','EUR_FI_Chain_Contract', 'EUR_FI_Independent_Contract'};
    List<Id> contractIdList = new List<Id>();
    List<EUR_CRM_Contract__c> contractForUpdate = new List<EUR_CRM_Contract__c>();
    Set<Id> contractIdSet = new Set<Id>();
    Map<Id, EUR_CRM_Contract__c> contractMap = new Map<Id, EUR_CRM_Contract__c>();

    //Iterate attachment
    for (Attachment att: Trigger.new){
        String sObjName = att.ParentId.getSObjectType().getDescribe().getName();
        if (sObjName.equalsIgnoreCase(contractObjName)){
            contractIdSet.add(att.ParentId);
        }
    }
  
    if(contractIdSet.size()>0){
        contractMap = new Map<Id, EUR_CRM_Contract__c>([SELECT Id, EUR_CRM_Contract_Uploaded__c, EUR_CRM_Contract_Copy_File_Name__c
                                                        FROM EUR_CRM_Contract__c WHERE Id IN:contractIdSet and recordtype.developername IN:validContractRecordTypes]);
        
        for (Attachment att: Trigger.new){
            String sObjName = att.ParentId.getSObjectType().getDescribe().getName();
            if (sObjName.equalsIgnoreCase(contractObjName) && contractMap.containsKey(att.ParentId)){
                EUR_CRM_Contract__c contract = contractMap.get(att.ParentId);
                if (att.Name.length()>= String.valueOf(contract.EUR_CRM_Contract_Copy_File_Name__c).length() && 
                    att.Name.substring(0,String.valueOf(contract.EUR_CRM_Contract_Copy_File_Name__c).length())==String.valueOf(contract.EUR_CRM_Contract_Copy_File_Name__c)){//att.Name.subtring(contract.EUR_CRM_Contract_Copy_File_Name__c)){
                    if(contract.EUR_CRM_Contract_Uploaded__c==false){
                        contract.EUR_CRM_Contract_Uploaded__c=true;
                        contractForUpdate.add(contract);   
                    }
                    
                }
            }
        }
        
        if (contractForUpdate.size()>0){
            update contractForUpdate;
        }
    }
}