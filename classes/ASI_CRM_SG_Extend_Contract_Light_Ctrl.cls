public class ASI_CRM_SG_Extend_Contract_Light_Ctrl {
    @AuraEnabled
    public static String validateExtend(String recordId){
        ASI_TH_CRM_Contract__c contractRec = [Select Id, OwnerId,ASI_TH_CRM_Contract_Status__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
        List<ASI_FOC_Free_Goods_Request__c> focArray  = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c WHERE ASI_CRM_Sync_to_JDE__c = false AND ASI_CRM_Contract__c = :recordId];
        List<ASI_TH_CRM_PaymentRequest__c> paymentArray = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_Sync_to_JDE__c = false AND ASI_TH_CRM_Contract__c = :recordId];
        Integer focCount = focArray != null ? focArray.size() : 0;
        Integer paymentCount = paymentArray != null ? paymentArray.size() : 0;  
        if (contractRec.OwnerId != UserInfo.getUserId()) {
            return 'You cannot extend the contract because you are not the contract owner.';
        }  else if (focCount != 0 || paymentCount != 0) {
            return 'Please complete all Payment/FOC request before revise the contract.';
        }else if (contractRec.ASI_TH_CRM_Contract_Status__c != 'Contract Approved') {
            return 'You cannot extend the contract because the contract is not approved.';
        } 
        else {
            return 'Success';      
        }
    }

}