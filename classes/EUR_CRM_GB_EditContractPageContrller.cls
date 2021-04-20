public class EUR_CRM_GB_EditContractPageContrller{ 
        private Boolean isOverrideContractEditPage = false;
        private final String PROPOSAL_APPROVED = 'Proposal Approved';
        private final String GB_CONTRACT_RECORDTYPE = 'EUR_GB_Contract';
        private EUR_CRM_Contract__c objContract;
        private Id contractId;
    public EUR_CRM_GB_EditContractPageContrller(ApexPages.StandardController stdController) {
        contractId =  stdController.getId();
        EUR_CRM_Contract__c objContract = new EUR_CRM_Contract__c(); 
          
        String objectRT = null;
        if(objContract  != null){
            objContract = [select id, recordtype.developername, name,EUR_CRM_Status__c from EUR_CRM_Contract__c where id =:contractId];
            objectRT = objContract.recordtype.developername;
            String status = objContract.EUR_CRM_Status__c;
            if(status==PROPOSAL_APPROVED && objectRT == GB_CONTRACT_RECORDTYPE){
                isOverrideContractEditPage = true;
            }   
        }
      
    }   

    public PageReference redirect(){ 
        if(!isOverrideContractEditPage){
            String url = '/' + contractId + '/e?retURL=%2F' + contractId + '&nooverride=1';
            return new ApexPages.PageReference(url).SetRedirect(true); 
        }
        return null;
    }
       
}