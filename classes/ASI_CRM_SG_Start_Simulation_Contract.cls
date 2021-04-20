public class ASI_CRM_SG_Start_Simulation_Contract {
    @AuraEnabled
    public static String validateContract(String recordId){
        try{
            ASI_TH_CRM_Contract__c  contractRec = [Select Id,Name, ASI_CRM_Contract_Exist_Before_RTM__c, ASI_TH_CRM_Contract_Status__c,RecordType.Name from ASI_TH_CRM_Contract__c  where Id = :recordId limit 1];
            List<ASI_FOC_Free_Goods_Request__c> focArray = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c WHERE ASI_CRM_Sync_to_JDE__c = false AND ASI_CRM_Contract__c = :recordId];
            List<ASI_TH_CRM_PaymentRequest__c> paymentArray = [SELECT Id FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_CRM_Sync_to_JDE__c = false AND ASI_TH_CRM_Contract__c = :recordId ];
            Integer focCount = focArray != null ? focArray.size() : 0;
            Integer paymentCount = paymentArray != null ? paymentArray.size() : 0;
            
            
            // P3 check if there is an draft / submit / rejected contract
            String recordtype = contractRec.RecordType.Name == 'ASI CRM SG Proposal (Read-Only)' ? 'ASI_CRM_SG_Proposal' : 'ASI_CRM_SG_Contract';
            String originalContractName1 = contractRec.Name ;
            String originalContractName = originalContractName1.substring(0,15);
            String revisingContractArrayString = 'SELECT Id, Name from ASI_TH_CRM_Contract__c where recordtype.developername = \'' + recordtype + '\' and name like \'' + originalContractName + '%\' and ASI_TH_CRM_Contract_Status__c in (\'Draft\',\'Submitted\',\'Contract Rejected\') Limit 1';
            List<ASI_TH_CRM_Contract__c> revisingContractArray = Database.query(revisingContractArrayString);
            
            if (revisingContractArray != null && revisingContractArray.size() > 0){
                return 'Please continue your revision on ' + revisingContractArray[0].Name;
            } else
                if (contractRec.ASI_TH_CRM_Contract_Status__c != 'Contract Approved' && contractRec.ASI_TH_CRM_Contract_Status__c != 'Proposal Approved' && contractRec.ASI_TH_CRM_Contract_Status__c != 'Archived') {
                    return 'This contract cannot start simulation.';
                } else
                    if (focCount != 0 || paymentCount != 0) {
                        return 'Please complete all Payment/FOC request before simulate the contract.';
                    } else {
                         if(contractRec.ASI_CRM_Contract_Exist_Before_RTM__c){
                      return 'Success1';
                  }else{
                    return 'Success';    
                  }
                    }
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
}