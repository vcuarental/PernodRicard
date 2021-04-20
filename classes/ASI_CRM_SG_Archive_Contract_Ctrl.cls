public class ASI_CRM_SG_Archive_Contract_Ctrl {
    @AuraEnabled
    public Static String getRecord(String recordId){
        try{
            ASI_TH_CRM_Contract__c contractRec = [Select id,OwnerId,ASI_TH_CRM_Contract_Status__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
            if (contractRec.OwnerId != UserInfo.getUserId()) {
                return 'You cannot archive this proposal because you are not the contract owner.';
            } else
                if (contractRec.ASI_TH_CRM_Contract_Status__c != 'Proposal Approved') {
                    return 'You cannot archive this proposal because the proposal is not approved.';
                } else {
                    return 'Success';    
                }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public Static String updateRecord(String recordId){
        try{
            ASI_TH_CRM_Contract__c contractRec = new ASI_TH_CRM_Contract__c();
            contractRec.Id = recordId;
            contractRec.ASI_TH_CRM_Contract_Status__c = 'Archived';
            update contractRec;
            return 'Success';
        }
        catch(exception e){
            return e.getMessage();
        }
        
    }
}