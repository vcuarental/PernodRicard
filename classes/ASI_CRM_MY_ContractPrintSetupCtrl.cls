public class ASI_CRM_MY_ContractPrintSetupCtrl {
    
    public Id contractId {get; private set;}
    public ASI_TH_CRM_Contract__c contract {get; private set;}
    public Decimal totalUpfrontAmt;
    
    public ASI_CRM_MY_ContractPrintSetupCtrl(ApexPages.StandardController controller) {
        contractId = controller.getId();
        contract = (ASI_TH_CRM_Contract__c) controller.getRecord();
    }
    
    public Decimal getUpfrontAmt (){
        if(totalUpfrontAmt == null){
            AggregateResult[] groupedResults = [SELECT SUM(ASI_CRM_CashInc__c) SumCashAmount, ASI_CRM_Contract__c 
                                                FROM ASI_CRM_ContractOtherIncentive__c 
                                                WHERE ASI_CRM_Contract__c = :contractId 
                                                AND ASI_CRM_Type__c = 'Up Front' GROUP BY ASI_CRM_Contract__c ];
            if(groupedResults.size()>0){
                for(AggregateResult ag : groupedResults ){
                    totalUpfrontAmt = (Decimal) ag.get('SumCashAmount');
                }
            } else {
                totalUpfrontAmt = 0;
            }
        }
        return totalUpfrontAmt;
    }
    
    public PageReference downloadContract(){
        PageReference downloadPage = Page.ASI_CRM_MY_ContractWordPage;
        downloadPage.setRedirect(true);
        return downloadPage;
    }
    
    public PageReference returnToContract(){
        //PageReference pr = new PageReference(contract) ;
        PageReference pr = new PageReference('/'+contractId) ;
        return pr;
    }
    
    public PageReference saveUpdates(){
        if(!contract.ASI_CRM_MY_Show_StaffIncentiveSection__c && contract.ASI_CRM_MY_Show_StaffInc_CustObligation__c){
            contract.ASI_CRM_MY_Show_StaffInc_CustObligation__c = false;
        }
        Savepoint sp = Database.setSavepoint();
        
        try{
            update contract;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Updates have been saved. You may procced to download the contract.'));
        } catch (exception e){
            Database.rollback(sp);
            String err= e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Update failed. Error:'+err));
        }
        return null;
    }
}