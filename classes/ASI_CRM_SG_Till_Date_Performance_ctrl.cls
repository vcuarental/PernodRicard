public class ASI_CRM_SG_Till_Date_Performance_ctrl {

    @AuraEnabled
    public static ASI_TH_CRM_Contract__c getContract(String recordId){
        return [Select Id,ASI_CRM_Contract_Exist_Before_RTM__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
    }
}