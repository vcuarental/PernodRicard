public class ASI_CRM_RedirectPREdit_LightningCtrl {
	@AuraEnabled
    public static ASI_TH_CRM_PaymentRequest__c getRecord(string recordId){
        return [Select Id, recordType.DeveloperName,ASI_CRM_CN_Promotion_Type__c,RecordTypeId,Name from ASI_TH_CRM_PaymentRequest__c where Id = :recordId limit 1];
    }
}