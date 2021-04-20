/*************************************************************
*   EUR_CRM_MassUpdateVisitFrequencyBatch
*   Mass updates all accounts' visit frequencies 
*   According to the new values of visit frequencies in the customer taxonomies
*
*   Called by EUR_CRM_MassUpdateVisitFrequency component from the Admin Consoles
****************************************************************/
global class EUR_CRM_MassUpdateVisitFrequencyBatch implements Database.Batchable<sObject>, Database.Stateful{

    // Valid recordtypes
    private List<String> validCustomerTaxonomyRecordTypes_BG = new List<String>{
        'EUR_BG_Wholesalers_Customer_Taxonomy',
        'EUR_BG_Modern_Off_Trade_Customer_Taxonomy'
    };
    private Set<String> acctDeliveryType_validRT = new Set<String>{'EUR_BG_Wholesaler'};
    private Set<String> acctStatus_validRT = new Set<String>{'EUR_BG_Modern_Off_Trade'};
    // Map of Customer Taxonomies
    public Map<Id, EUR_CRM_Customer_Taxonomy__c> customerTaxonomyMap;
    public Set<Id> customerTaxonomyIds {get;set;}
    // Accounts Recordtype map
    private Map<Id,Recordtype> accountRTMap = new Map<Id,Recordtype>();
    
    // country code to specify which recordtypes to use
    private String countryCode; 
    

    /*
    * generateQuery
    * return the Accounts with the retrieved customer taxonomies
    */
    private String generateQuery(){
        return  'SELECT Id, EUR_CRM_Visit_Frequency__c, EUR_JB_Customer_Taxonomy__c, RecordTypeId, ' +
                'EUR_CRM_Delivery_Type__c, EUR_CRM_Status__c ' +
                'FROM EUR_CRM_Account__c ' +
                'WHERE EUR_JB_Customer_Taxonomy__c =: customerTaxonomyIds';
    }

    global EUR_CRM_MassUpdateVisitFrequencyBatch(String countryCode){
        this.countryCode = countryCode;
    }

    /*
    * start
    * Retrieves all customer taxonomies with recordtypes in the validCustomerTaxonomyRecordTypes
    * Then calls the generateQuery and returns the Accounts to be processed
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        // Valid recordTypes of customer Taxonomies
        List<String> validCustomerTaxonomyRecordTypes;
        if(countryCode == 'BG'){
            validCustomerTaxonomyRecordTypes = validCustomerTaxonomyRecordTypes_BG;
        }
        customerTaxonomyMap = new Map<Id, EUR_CRM_Customer_Taxonomy__c>([SELECT Id, Recordtype.DeveloperName, EUR_CRM_VF_When_Cust_Active__c,
                                                                                EUR_CRM_VF_When_Cust_Prospect__c, EUR_CRM_VF_When_Delivery_Is_Direct__c,
                                                                                EUR_CRM_VF_When_Delivery_is_Indirect__c
                                                                         FROM EUR_CRM_Customer_Taxonomy__c
                                                                         WHERE Recordtype.DeveloperName IN : validCustomerTaxonomyRecordTypes
                                                                        ]);
        // Assign the Ids to the Set for use in the SOQL query
        customerTaxonomyIds = customerTaxonomyMap.KeySet();

        // Construct Account record types map
        for(Recordtype rt : Global_RecordTypeCache.getRtList('EUR_CRM_Account__c')){
            accountRTMap.put(rt.Id, rt);
        }

        // Call the main SOQL 
        return Database.getQueryLocator(generateQuery());
    }

    /*
    * Execute
    * Assigns the new values of visit frequencies from the customer taxonomies 
    */
    global void execute (Database.Batchablecontext BC, List<sObject> scope){
        System.debug('Scope: ' + scope);
        
        // Cast the scope to accounts object
        List<EUR_CRM_Account__c> accountsList = (List<EUR_CRM_Account__c>) scope;
        // Account Recordtype DeveloperName
        String acctRecordType;
        // Update the accounts depending on their recordtypes
        for(EUR_CRM_Account__c acct : accountsList){
            acctRecordType = accountRTMap.get(acct.RecordTypeId).DeveloperName;
            // Based on Delivery Type
            if(acctDeliveryType_validRT.contains(acctRecordType)){
                if(acct.EUR_CRM_Delivery_Type__c == 'Direct'){
                    acct.EUR_CRM_Visit_Frequency__c = customerTaxonomyMap.get(acct.EUR_JB_Customer_Taxonomy__c).EUR_CRM_VF_When_Delivery_Is_Direct__c;                        
                } 
                else if(acct.EUR_CRM_Delivery_Type__c == 'Indirect'){
                    acct.EUR_CRM_Visit_Frequency__c = customerTaxonomyMap.get(acct.EUR_JB_Customer_Taxonomy__c).EUR_CRM_VF_When_Delivery_is_Indirect__c;                        
                }
            }
            // Based on Status
            else if(acctStatus_validRT.contains(acctRecordType)){
                if(acct.EUR_CRM_Status__c == 'Active'){
                    acct.EUR_CRM_Visit_Frequency__c = customerTaxonomyMap.get(acct.EUR_JB_Customer_Taxonomy__c).EUR_CRM_VF_When_Cust_Active__c;                        
                } 
                else if(acct.EUR_CRM_Status__c == 'Prospect'){
                    acct.EUR_CRM_Visit_Frequency__c = customerTaxonomyMap.get(acct.EUR_JB_Customer_Taxonomy__c).EUR_CRM_VF_When_Cust_Prospect__c;                        
                }
            }
        }
        // Update all accounts
        update accountsList;
    }

    
    /*
    * Finish
    */
    global void finish(Database.BatchableContext BC){}
}