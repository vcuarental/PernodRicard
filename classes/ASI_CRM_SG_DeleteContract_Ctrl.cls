public class ASI_CRM_SG_DeleteContract_Ctrl {
    @AuraEnabled
    public Static String validateDelete(String recordId){
        Boolean isEligible = true;
        List<ASI_TH_CRM_Contract__c> contractList = [Select Id,(select Id from Free_Goods_Requests__r where 
                                RecordType.DeveloperName IN ('ASI_CRM_SG_FOC','ASI_CRM_SG_FOC_Read_Only','ASI_CRM_SG_POSM','ASI_CRM_SG_POSM_Read_Only')),
                                (SELECT Id FROM ASI_TH_CRM_PaymentRequests_Contract__r WHERE 
                                RecordType.DeveloperName IN ('ASI_CRM_SG_Payment_Request','ASI_CRM_SG_Payment_Request_Read_Only')) FROM ASI_TH_CRM_Contract__c WHERE Id = :recordId];
         system.debug('@#'+contractList[0].ASI_TH_CRM_PaymentRequests_Contract__r); 
        if(contractList != null && contractList.size()>0){
            if(contractList[0].ASI_TH_CRM_PaymentRequests_Contract__r != null && contractList[0].ASI_TH_CRM_PaymentRequests_Contract__r.size() > 0){
                isEligible = false;
            }else if(contractList[0].Free_Goods_Requests__r != null && contractList[0].Free_Goods_Requests__r.size() > 0){
                isEligible = false;
            }
        }
        if(isEligible){
            return 'Success';
        }else{
            return System.Label.ASI_CRM_SG_ContractDeleteError;
        }
        
    }
    
    @AuraEnabled
    public static String deleteAction(String recordId){
        try{
            ASI_TH_CRM_Contract__c contractRec = [Select id,Name,RecordType.Name from ASI_TH_CRM_Contract__c where Id  = : recordId limit 1];
            if (contractRec.RecordType.Name == 'ASI CRM SG 1. Proposal' || contractRec.RecordType.Name == 'ASI CRM SG 2. Contract') {
                String recordtype = contractRec.RecordType.Name == 'ASI CRM SG 1. Proposal' ? 'ASI_CRM_SG_Proposal_Read_Only' : 'ASI_CRM_SG_Contract_Read_Only';
                String originalContractName1 = contractRec.Name;
                String originalContractName = contractRec.RecordType.Name == 'ASI CRM SG 1. Proposal' ? originalContractName1.substring(0,17) : originalContractName1.substring(0,15);
                String contractStatus = contractRec.RecordType.Name == 'ASI CRM SG 1. Proposal' ? 'Proposal Approved' : 'Contract Approved';
                String queryRevisingContract = 'SELECT Id, Name from ASI_TH_CRM_Contract__c where recordtype.developername = \'' + recordtype + '\' and name like \'' + originalContractName + '%\' and ASI_TH_CRM_Contract_Status__c = \'' + contractStatus + '\' Limit 1';
                List<ASI_TH_CRM_Contract__c> revisingContractArray = Database.query(queryRevisingContract);
                
                if (revisingContractArray!= null && revisingContractArray.size()>0){
                    return 'redirect';
                } else {
                    delete contractRec;
                    return 'Success';
                }
            } else {
                delete contractRec;
                return 'Success';
            }
        }catch(Exception e){
            return e.getMessage();
        }
    }
}