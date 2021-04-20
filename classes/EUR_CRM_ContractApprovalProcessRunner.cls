public with sharing class EUR_CRM_ContractApprovalProcessRunner {

    private static final String CLASS_NAME = 'EUR_CRM_ContractApprovalProcessRunner';

    private final Set<String> VALID_RT = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'VALID_RT');
//    private final Set<String> VALID_RT = new Set<String> {
//        'EUR_NL_Chain_Contract'
//    ,   'EUR_NL_Independant_Contract'
//    ,   'EUR_DE_Contract'
//    ,   'EUR_FI_Chain_Contract'
//    ,   'EUR_FI_Independent_Contract'
//    };

    private final Map<String, Map<String, Boolean>> VALID_VALUE_BY_FIELD_NAME_BY_RT_DEV_NAME =
        EUR_CRM_RecordTypeHelper_v2.getBooleanByStringByString(
            EUR_CRM_RecordTypeHelper_v2.getSettingsMultilevelMap(CLASS_NAME, 'VALID_VALUE_BY_FIELD_NAME_BY_RT_DEV_NAME'));

//    private final Map<String, Map<String, Object>> VALID_VALUE_BY_FIELD_NAME_BY_RT_DEV_NAME = new Map<String, Map<String, Object>> {
//        'EUR_DE_Contract' => new Map<String, Object> { 'EUR_CRM_Has_Budget__c' => true }
//    };

    @TestVisible private static final String STATUS_WAITING_FOR_SYNC = 'Waiting for sync';
    @TestVisible private static final String STATUS_SUBMITTED = 'Submitted';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void validateToRunApprovalProcess(List<EUR_CRM_Contract__c> contractsToUpdate, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        List<EUR_CRM_Contract__c> contractsToSubmit = this.extractContractsToSubmit(contractsToUpdate, oldContractById);
        System.debug('\n\n contractsToSubmit.size() => ' + JSON.serializePretty(contractsToSubmit.size()) + '\n');
        System.debug('\n\n contractsToSubmit => ' + JSON.serializePretty(contractsToSubmit) + '\n');
        if (contractsToSubmit.isEmpty()) { return ; }

        this.setSubmittedStatus(contractsToSubmit);
    }

    public void runApprovalProcess(List<EUR_CRM_Contract__c> updatedContracts, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        List<EUR_CRM_Contract__c> contractsToApprove = this.extractContractsToApprove(updatedContracts, oldContractById);
        System.debug('\n\n contractsToApprove.size() => ' + JSON.serializePretty(contractsToApprove.size()) + '\n');
        System.debug('\n\n contractsToApprove => ' + JSON.serializePretty(contractsToApprove) + '\n');
        if (contractsToApprove.isEmpty()) { return ; }

        this.runAP(contractsToApprove);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void setSubmittedStatus(List<EUR_CRM_Contract__c> contracts) {
        for (EUR_CRM_Contract__c contract : contracts) {
            contract.EUR_CRM_Status__c = STATUS_SUBMITTED;
        }
    }

    private void runAP(List<EUR_CRM_Contract__c> contracts) {
        for (EUR_CRM_Contract__c contract : contracts) {
            Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
            submitRequest.setComments('Submitting request for approval automatically by Trigger.');
            submitRequest.setObjectId(contract.Id);
            System.debug('\n submitRequest => ' + JSON.serializePretty(submitRequest) + '\n');
            Approval.ProcessResult result = Approval.process(submitRequest);
            System.debug('\n result => ' + JSON.serializePretty(result) + '\n');
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Contract__c> extractContractsToSubmit(List<EUR_CRM_Contract__c> contracts, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        Map<Id, RecordTypeInfo> rtInfoByRTId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosById();

        List<EUR_CRM_Contract__c> contractsToSubmit = new List<EUR_CRM_Contract__c>();
        for (EUR_CRM_Contract__c contract : contracts) {
            if (this.isContractToSubmit(contract, oldContractById, rtInfoByRTId)) {
                contractsToSubmit.add(contract);
            }
        }
        return contractsToSubmit;
    }

    private List<EUR_CRM_Contract__c> extractContractsToApprove(List<EUR_CRM_Contract__c> contracts, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        Map<Id, RecordTypeInfo> rtInfoByRTId = Schema.SObjectType.EUR_CRM_Contract__c.getRecordTypeInfosById();

        List<EUR_CRM_Contract__c> contractsToApprove = new List<EUR_CRM_Contract__c>();
        for (EUR_CRM_Contract__c contract : contracts) {
            if (this.isContractToApprove(contract, oldContractById, rtInfoByRTId)) {
                contractsToApprove.add(contract);
            }
        }
        return contractsToApprove;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Boolean isContractToSubmit(EUR_CRM_Contract__c contract, Map<Id, EUR_CRM_Contract__c> oldContractById, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return this.isNeedToValidate(contract, oldContractById)
            && this.isWaitingForSyncContract(contract, rtInfoByRTId)
            && this.isExpectedNumberOfChild(contract)
        ;
    }

    private Boolean isContractToApprove(EUR_CRM_Contract__c contract, Map<Id, EUR_CRM_Contract__c> oldContractById, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return this.isStatusChanged(contract, oldContractById)
            && this.isSubmittedContract(contract, rtInfoByRTId)
            && this.isValidAdditionalRequirements(contract, rtInfoByRTId)
            && this.isExpectedNumberOfChild(contract)
            && ( ! this.isApproved(contract))
        ;
    }

    private Boolean isValidAdditionalRequirements(EUR_CRM_Contract__c contract, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        String rtDevName = rtInfoByRTId.get(contract.RecordTypeId).getDeveloperName();
        if ( ! VALID_VALUE_BY_FIELD_NAME_BY_RT_DEV_NAME.containsKey(rtDevName)) { return true; }

        Map<String, Object> validValueByFieldName = VALID_VALUE_BY_FIELD_NAME_BY_RT_DEV_NAME.get(rtDevName);
        for (String fieldName : validValueByFieldName.keySet()) {
            if (contract.get(fieldName) != validValueByFieldName.get(fieldName)) {
                return false;
            }
        }

        return true;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isNeedToValidate(EUR_CRM_Contract__c contract, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        return this.isNumberOfChildChanged(contract, oldContractById)
            || this.isStatusChanged(contract, oldContractById)
        ;
    }

    private Boolean isNumberOfChildChanged(EUR_CRM_Contract__c contract, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        return contract.EUR_CRM_N_of_child_records__c != oldContractById.get(contract.Id).EUR_CRM_N_of_child_records__c
            || contract.EUR_CRM_Total_N_of_products__c != oldContractById.get(contract.Id).EUR_CRM_Total_N_of_products__c
        ;
    }

    private Boolean isStatusChanged(EUR_CRM_Contract__c contract, Map<Id, EUR_CRM_Contract__c> oldContractById) {
        return contract.EUR_CRM_Status__c != oldContractById.get(contract.Id).EUR_CRM_Status__c;
    }

    private Boolean isWaitingForSyncContract(EUR_CRM_Contract__c contract, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return this.isValidContractMetadata(contract, rtInfoByRTId)
            && contract.EUR_CRM_Status__c == STATUS_WAITING_FOR_SYNC

        ;
    }

    private Boolean isValidContractMetadata(EUR_CRM_Contract__c contract, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return contract.RecordTypeId != null
            && rtInfoByRTId.containsKey(contract.RecordTypeId)
            && VALID_RT.contains(rtInfoByRTId.get(contract.RecordTypeId).getDeveloperName())
        ;
    }

    private Boolean isExpectedNumberOfChild(EUR_CRM_Contract__c contract) {
        return contract.EUR_CRM_N_of_child_records__c == contract.EUR_CRM_Total_N_of_products__c
            && contract.EUR_CRM_N_of_child_records__c != null
            && contract.EUR_CRM_N_of_child_records__c != 0
            && contract.EUR_CRM_Total_N_of_products__c != null
            && contract.EUR_CRM_Total_N_of_products__c != 0
            ;
    }

    private Boolean isSubmittedContract(EUR_CRM_Contract__c contract, Map<Id, RecordTypeInfo> rtInfoByRTId) {
        return this.isValidContractMetadata(contract, rtInfoByRTId)
            && contract.EUR_CRM_Status__c == STATUS_SUBMITTED
        ;
    }

    private Boolean isApproved(EUR_CRM_Contract__c contract) {
        return Approval.isLocked(contract);
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */

}