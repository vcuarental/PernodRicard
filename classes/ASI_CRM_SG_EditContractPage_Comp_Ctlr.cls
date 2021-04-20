public class ASI_CRM_SG_EditContractPage_Comp_Ctlr {
    
    @AuraEnabled
    public static dataWrapper initializeContract(Id recordId, Id recordTypeId) {
        dataWrapper dw = new dataWrapper();
        Id recordTypeProposal = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
        Id recordTypeProposalRo = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only');
        
        if(recordTypeProposalRo == recordTypeId) {
            dw.isNewReadOnly = true;
        } else if(recordTypeProposal == recordTypeId) {
            dw.isNewReadOnly = false;
        }
        
        return dw;    
    }
    
    @AuraEnabled
    public static String save(Id outletId){
        system.debug('@#outletId'+outletId);
        list<String> lstCustomerRecType = new list<String>();
        //lstCustomerRecType.add('ASI_CRM_SG_Potential_Outlet');
        lstCustomerRecType.add('ASI_CRM_SG_Outlet');
        //lstCustomerRecType.add('ASI_CRM_SG_Converted_Outlets');
                // DC - 04/27/2016 - Added condition to select/save outlet.
                list<ASI_CRM_AccountsAdditionalField__c> lstCustomer =
                    new list<ASI_CRM_AccountsAdditionalField__c>(
                        [SELECT Id
                              , RecordType.DeveloperName
                           FROM ASI_CRM_AccountsAdditionalField__c
                          WHERE Id = :outletId
                            AND RecordType.DeveloperName IN : lstCustomerRecType]
                    );

                // TODO : 1. If list is empty, show errod, don't save.
                //        2. If list has values, go ahead and save.
                //        3. If lookup is null, go ahead and save. THIS WILL BE FIRST.

                if(!lstCustomer.isEmpty() && lstCustomer[0].Id != NULL) {
                    return 'Success';
                } else {
                    return 'Please select JDE Outlets only.';
                }
                
        }
    public class dataWrapper{
        @AuraEnabled public boolean isNewReadOnly{get;set;}
        @AuraEnabled public boolean isEdit{get;set;}
        public  dataWrapper(){
            this.isNewReadOnly = false;
            this.isEdit = false;
        }
    }
    
}