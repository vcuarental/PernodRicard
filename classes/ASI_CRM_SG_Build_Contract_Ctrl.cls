public class ASI_CRM_SG_Build_Contract_Ctrl {
    @AuraEnabled
    public Static String validateContract(String recordId){
        try{
            ASI_TH_CRM_Contract__c contractRec = [Select Id,ASI_TH_CRM_Contract_Status__c,ASI_CRM_Contract_Exist_Before_RTM__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
            if(contractRec.ASI_TH_CRM_Contract_Status__c == 'Draft' ||
               contractRec.ASI_TH_CRM_Contract_Status__c == 'Contract Rejected' ||
               contractRec.ASI_TH_CRM_Contract_Status__c == 'Proposal Rejected'
              ) {
                  if(!contractRec.ASI_CRM_Contract_Exist_Before_RTM__c){
                      return 'Success1';
                  }else{
                  	return 'Success';    
                  }
                  
              } else {
                  return 'Cannot modify Proposal / Contract during approval or when approved';
              }
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
}