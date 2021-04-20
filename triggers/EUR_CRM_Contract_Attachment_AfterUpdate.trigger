trigger EUR_CRM_Contract_Attachment_AfterUpdate on Attachment (after update){
    String contractObjName = 'EUR_CRM_Contract__c';
    Set<String> validContractRecordTypes = new Set<String>{'EUR_DE_Contract','EUR_GB_Contract'};
    List<Id> contractIdList = new List<Id>();
    List<EUR_CRM_Contract__c> contractForUpdate = new List<EUR_CRM_Contract__c>();
    Set<Id> contractIdSet = new Set<Id>();
    Map<Id, EUR_CRM_Contract__c> contractMap = new Map<Id, EUR_CRM_Contract__c>();
    
    Set<Id> contractIdForValidation = new Set<Id>();

    //Iterate attachment
    for (Attachment att: Trigger.new){
        String sObjName = att.ParentId.getSObjectType().getDescribe().getName();
        if (sObjName.equalsIgnoreCase(contractObjName) && Trigger.oldMap.get(att.Id).Name != att.Name){
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
                String fileNamePrefix = String.valueOf(contract.EUR_CRM_Contract_Copy_File_Name__c);
                if (att.Name.length()>= fileNamePrefix .length() && 
                    att.Name.subString(0, fileNamePrefix.length())== fileNamePrefix){//(att.Name.contains(contract.EUR_CRM_Contract_Copy_File_Name__c)){
                    if(contract.EUR_CRM_Contract_Uploaded__c==false){
                        contract.EUR_CRM_Contract_Uploaded__c=true;
                        contractForUpdate.add(contract);
                    }
                }else{
                    contractIdForValidation.add(contract.Id);
                }
            }
        }
        
        if (contractIdForValidation.size()>0){
            Set<Id> contractIdNoContractUpload = new Set<Id>();
            contractIdNoContractUpload.addAll(contractIdForValidation);
            for (Attachment att: [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId IN: contractIdForValidation]){
                if (contractMap.containsKey(att.ParentId)){
                    String fileNamePrefix = String.valueOf(contractMap.get(att.ParentId).EUR_CRM_Contract_Copy_File_Name__c);
                    if(att.Name.length()>= fileNamePrefix .length() && 
                        att.Name.subString(0, fileNamePrefix.length())== fileNamePrefix){//(att.Name.contains(contractMap.get(att.ParentId).EUR_CRM_Contract_Copy_File_Name__c)){
                        contractIdNoContractUpload.remove(att.ParentId);
                    }
                }
            }
            
            if (contractIdNoContractUpload.size()>0){
                for (Id contractId: contractIdNoContractUpload){
                    EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(Id=contractId, EUR_CRM_Contract_Uploaded__c=false);
                    contractForUpdate.add(contract);
                }
            }
        }
        
        if (contractForUpdate.size()>0){
            update contractForUpdate;
        }
    }
}