public class ASI_CRM_RedirectContract_Edit_LightCtrl {
	@AuraEnabled
    public static ASI_TH_CRM_Contract__c getRecord(String recordId){
        return [Select Id, Name, RecordType.DeveloperName,RecordTypeId, ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_Status__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
    }
}