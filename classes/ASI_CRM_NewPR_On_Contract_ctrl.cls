public class ASI_CRM_NewPR_On_Contract_ctrl {
	@AuraEnabled
    public static String getRecordType(){
      String rTypeId =   ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_RT_PaymentRequests__c;
        if(rTypeId == null){
            rTypeId =   ASI_CRM_MY_Settings__c.getOrgDefaults().ASI_CRM_MY_RT_PaymentRequests__c;
        }
        return rTypeId;
    }
    
    @AuraEnabled
    public static ASI_TH_CRM_Contract__c getContract(String recordId){
        return [Select id, ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where id = :recordId limit 1];
    }
}