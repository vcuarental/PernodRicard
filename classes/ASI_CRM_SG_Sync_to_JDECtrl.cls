public class ASI_CRM_SG_Sync_to_JDECtrl {

    @AuraEnabled
    public static String updateCustomer(Id recordId){
        ASI_CRM_AccountsAdditionalField__c customer = [Select id,ASI_CRM_SG_Search_Type__c,ASI_CRM_ToJDE__c from ASI_CRM_AccountsAdditionalField__c where id = : recordId];
        system.debug('@#'+customer.ASI_CRM_SG_Search_Type__c);
        if (customer.ASI_CRM_SG_Search_Type__c == null || customer.ASI_CRM_SG_Search_Type__c == ''){
			return 'Please enter Additional Information before Sync to JDE.';
        }
        else if(customer.ASI_CRM_ToJDE__c == false) {   
        	customer.ASI_CRM_ToJDE__c = true;
            try{
            	database.update(customer);   
                return 'Success';
            }catch(exception e){
                return e.getMessage();
            }
            
        }else{
            return 'Record Waiting to Sync to JDE.';
        }
    }
}