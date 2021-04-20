/*************************************************************************************
* Name:         EUR_CRM_FI_ContractActivationBatch
* Descriptopn:  Global class that activates FI Contracts which have a status of Approved-Pending Activation 
*               and a start date of TODAY().
*               Run nightly by the scheduler EUR_CRM_FI_ScheduleContractActivation
*
**************************************************************************************/
global class EUR_CRM_FI_ContractActivationBatch implements Database.Batchable<sObject>{

    /*
    *  Queries that FI contracts that matches the criteria of activation
    *  where status is = Approved-Pending Activation
    *  AND start date is TODAY()
    *
    *  Returns: The string query 
    */
    global static String generateQuery(){ 
        String q ='SELECT Id, EUR_CRM_Status__c, EUR_CRM_Start_Date__c, EUR_CRM_Active__c, RecordType.DeveloperName ';
        q += 'FROM EUR_CRM_Contract__c ';
        q += 'WHERE EUR_CRM_Status__c = \'Approved-Pending Activation\' ';
        q += 'AND EUR_CRM_Start_Date__c <= TODAY ';
        // set of valid FI contract recordtypes
        q += 'AND RecordType.DeveloperName IN (\'EUR_FI_Chain_Contract\', \'EUR_FI_Independent_Contract\')';
        return q;
    }

    /*
    *   The batch class start function
    *   calls the generateQuery() and SOQLs it
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(generateQuery());
    }
    
    /*
    *   the execute function calls the activate() function on the retrieved entries by the SOQL
    */
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        activate((List<EUR_CRM_Contract__c>)scope);
    }
   
    /*
    * Implementation is required by the interface
    */
    global void finish(Database.BatchableContext BC){}

    /*
    *   Activates the retrieved contacts by setting their EUR_CRM_Status__c to Actived
    *   Params: A list of Contract (EU) retrieved by the SOQL
    */
    global static void activate(List<EUR_CRM_Contract__c> contracts){
        system.debug('Retrieved Contracts: ' + contracts);
        // Set the status to activated for all retrieved contracts
        if(contracts.size() > 0){
            for(EUR_CRM_Contract__c contract : contracts){
                contract.EUR_CRM_Status__c = 'Activated';
                contract.EUR_CRM_Active__c = true;
            } 
            // Use common routines DML with partial success to handle exceptions        
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('Upsert', contracts);
        }
    }   
}