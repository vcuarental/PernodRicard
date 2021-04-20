public class ASI_CRM_SG_Convert_to_Contract {
    @AuraEnabled
    public Static String validateContract(String recordId){
        
        try {
            ASI_TH_CRM_Contract__c  contractRec = [Select Id,ASI_CRM_CN_Outlet_WS__c,ASI_TH_CRM_Contract_Status__c,OwnerId from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
            Boolean hasAttachment = false;
            Boolean isOutletReady = false;
            List<Attachment> relatedCharts = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :recordId AND (NOT name like 'SFDC - %')];
            if (relatedCharts!= null && relatedCharts.size() > 0){
                hasAttachment = true;
            }
            List<ContentDocumentLink> relatedFiles = [SELECT ContentDocumentId, LinkedEntityId, contentDocument.title FROM ContentDocumentLink where LinkedEntityId = :recordId and LinkedEntity.Type='ASI_TH_CRM_Contract__c' and (NOT contentDocument.title like 'SFDC - %')] ;   
            if (relatedFiles != null && relatedFiles.size() > 0){
                hasAttachment = true;
            }
            
            List<ASI_CRM_AccountsAdditionalField__c> relatedCharts1 = [SELECT Id, recordtype.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c WHERE id = :contractRec.ASI_CRM_CN_Outlet_WS__c];
            
            if (relatedCharts1 != null && relatedCharts1.size() > 0){
                if (relatedCharts1[0].RecordType.DeveloperName == 'ASI_CRM_SG_Outlet'){
                    isOutletReady = true;   
                }
            }
            
            if (contractRec.OwnerId != UserInfo.getUserId()) {
                return 'You cannot convert this proposal to contract because you are not the contract owner.';
            } else
                if (contractRec.ASI_TH_CRM_Contract_Status__c == 'Proposal Converted') {
                    return 'You cannot convert this proposal to contract because it has been converted.';
                } else
                    if (contractRec.ASI_TH_CRM_Contract_Status__c != 'Proposal Approved' && contractRec.ASI_TH_CRM_Contract_Status__c != 'Archived') {
                        return 'You cannot convert this proposal to contract because the proposal is not approved.';
                    } else
                        if (!isOutletReady ) {
                            return 'You cannot convert this proposal to contract because the outlet is not converted.';
                        } else
                            if (!hasAttachment ) {
                                return 'You cannot convert this proposal to contract because no printed contract is attached.';
                            } else {
                                return 'Success';
                            }
        } catch(Exception e) {
            return e.getMessage();
        }
    }
}