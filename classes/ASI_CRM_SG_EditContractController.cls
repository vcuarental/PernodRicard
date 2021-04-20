/**********************************************************************************
 * Name : ASI_CRM_SG_EditContractController
 * Created : DC @04/11/2016 2:38 PM
 * Revision History:
 * 1. 04/11/2016 - [DC 1.0] Created
 * 2. 2016-05-16 - [VL 1.0] Use PR's Global_RecordTypeCache to get the record type ID
 **********************************************************************************/

public with sharing class ASI_CRM_SG_EditContractController {

    public ASI_TH_CRM_Contract__c contractInstance {get; set;}
    public Boolean isNewReadOnly {get; set;}
    public Boolean isEdit {get; set;}
    public Id proposalId {get; set;}

    // DC- 04/25/16 -Added set of Record Type to select outlet.
    list<String> lstCustomerRecType = new list<String>();
    

    public String pageBlockTitle {
        get {
            return 'Proposal Edit';
        }
        set;
    }

    public String titleInformation {
        get {
            return 'Information';
        }
        set;
    }

    public String titleMarketing {
        get {
            return 'Marketing A&P support';
        }
        set;
    }

    public String titleIndicator {
        get {
            return 'Contract Indicator';
        }
        set;
    }

    public String titleSummary {
        get {
            return 'Summary';
        }
        set;
    }

    public String titleSysInformation {
        get {
            return 'System Information';
        }
        set;
    }

    public ASI_CRM_SG_EditContractController(ApexPages.StandardController con) {
        
        //lstCustomerRecType.add('ASI_CRM_SG_Potential_Outlet');
        lstCustomerRecType.add('ASI_CRM_SG_Outlet');
        //lstCustomerRecType.add('ASI_CRM_SG_Converted_Outlets');

        contractInstance = (ASI_TH_CRM_Contract__c) con.getRecord();
        if(contractInstance.RecordTypeId == null){
            contractInstance.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        }
        if(ApexPages.currentPage().getParameters().get('outletId') != null){
            contractInstance.ASI_CRM_CN_Outlet_WS__c = ApexPages.currentPage().getParameters().get('outletId') ;
        }
        proposalId = (Id) con.getId();
        if(proposalId == NULL) {
            isEdit = false;
            contractInstance.OwnerId = UserInfo.getUserId();
            contractInstance.Name = '[Auto-generated]';
        } else {
            
            isEdit = true;

            Map<String, Schema.SObjectField> contractFieldsMap =
                Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
            
            String theQuery = 'SELECT ';
            
            for(String fields  : contractFieldsMap.keySet()){
                theQuery += fields + ' ,';
            }
            
            theQuery = theQuery.subString(0,theQuery.length()-1);

            theQuery += 'FROM ASI_TH_CRM_Contract__c' 
                      +  ' WHERE Id = \'' + proposalId + '\'' ;
                      //+  ' AND ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName  IN : lstCustomerRecType';

            try {
                contractInstance = (ASI_TH_CRM_Contract__c) Database.query(theQuery);
            } catch(QueryException exceptionInstance) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,exceptionInstance.getMessage()));
                // DC - TODO : Nothing
            }
        }

        /* [VL 1.0] BEGIN */
        /*
        Id recordTypeProposal =
            Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName()
                              .get('ASI CRM SG Proposal').getRecordTypeId();
    
        Id recordTypeProposalRo =
            Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName()
                              .get('ASI CRM SG Proposal (Read-Only)').getRecordTypeId();
        */
        Id recordTypeProposal = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');
    
        Id recordTypeProposalRo = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only');
        /* [VL 1.0] END */

        if(recordTypeProposalRo == ApexPages.currentPage().getParameters().get('RecordType')) {
            isNewReadOnly = true;
        } else if(recordTypeProposal == ApexPages.currentPage().getParameters().get('RecordType')) {
            isNewReadOnly = false;
        }
    }

    public PageReference save() {
        PageReference pageRef;
        try {
                // DC - 04/27/2016 - Added condition to select/save outlet.
                list<ASI_CRM_AccountsAdditionalField__c> lstCustomer =
                    new list<ASI_CRM_AccountsAdditionalField__c>(
                        [SELECT Id
                              , RecordType.DeveloperName
                           FROM ASI_CRM_AccountsAdditionalField__c
                          WHERE Id = :contractInstance.ASI_CRM_CN_Outlet_WS__c
                            AND RecordType.DeveloperName IN : lstCustomerRecType]
                    );

                // TODO : 1. If list is empty, show errod, don't save.
                //        2. If list has values, go ahead and save.
                //        3. If lookup is null, go ahead and save. THIS WILL BE FIRST.

                if(!lstCustomer.isEmpty() && lstCustomer[0].Id != NULL) {
                    upsert contractInstance;
                    pageRef = new PageReference('/' + contractInstance.Id);
                    pageRef.setRedirect(true);
                } else {
                    //contractInstance.addError('Please select Potential or JDE Outlets only.');
                    contractInstance.addError('Please select JDE Outlets only.');
                }
                
        } catch(DmlException exceptionInstance) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exceptionInstance.getMessage()));
            // DC - TODO : Nothing
            return null;
        }
        return pageRef;
    }
}