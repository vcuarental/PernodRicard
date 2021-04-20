/**
*   Class: EUR_CRM_ListingTemplateHandler
*   Assigns a Listing template to an account dynamically regardless of affiliates
*   Using PROS and Customer Taxonomy
*   Update 2017-04-11 Remove BE On Trade
**/
public with sharing class EUR_CRM_ListingTemplateHandler extends EUR_CRM_TriggerAbstract{
    
    public EUR_CRM_ListingTemplateHandler() {
        super('EUR_CRM_ListingTemplateHandler');
    }
    
    // Stores all record types of accounts that need listing template calculations based on their customer taxonomy
    private static Set<String> customerTaxonomyAccountRecordTypeSet = EUR_CRM_RecordTypeHelper.ListingTemplateHandler_customerTaxonomyAccountRecordTypeSet;
    
    // Stores all record types of accounts that need listing template calucations based on their template criteria
    private static Set<String> templateCriteriaAccountRecordTypeSet = EUR_CRM_RecordTypeHelper.ListingTemplateHandler_templateCriteriaAccountRecordTypeSet;
    
    // Stores all record types of accounts that need listing template calucations based on their template recordtype
    private static Set<String> templateAccountRecordTypeSet = new Set<String>{'EUR_BE_Wholesaler'}; //EUR_BE_On_Trade
    private static Set<String> templateRTName = new Set<String>{'EUR_BE_Wholesaler_Template','EUR_BE_On_Trade_Template'};
    private static Map<String,String> templateAccountLTMapping = new Map<string,string>{'EUR_BE_Wholesaler'=>'EUR_BE_Wholesaler_Template'
                                                                                        }; //'EUR_BE_On_Trade'=>'EUR_BE_On_Trade_Template'

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(customerTaxonomyAccountRecordTypeSet);
            TRt.addAll(templateCriteriaAccountRecordTypeSet);
            TRt.addAll(templateAccountRecordTypeSet);
            
            return TRt;
        }private set;
    }


    private Map<Id, RecordType> accountRecordTypesMap = new Map<Id, RecordType>();
    // Stores all valid account record types for this operation
    private static Set<String> accountRecordTypeSet;    
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        System.Debug('EUR_CRM_ListingTemplateHandler');
        // Assign record types to a map for easy access
        List<RecordType> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        
        
        for(RecordType rt: accountRecordTypes) {
            accountRecordTypesMap.put(rt.Id, rt);
        }
        
        // Initialize accountRecordTypeSet to be a set that includes all valid record types
        accountRecordTypeSet = new Set<String>(customerTaxonomyAccountRecordTypeSet);
        accountRecordTypeSet.addAll(templateCriteriaAccountRecordTypeSet);
        accountRecordTypeSet.addAll(templateAccountRecordTypeSet);

        // Initialize containers
        Set<Id> custTaxonomy = new Set<Id>();
        Set<String> chainSet = new Set<String>();
        Set<String> level1Set = new Set<String>();
        Set<String> level2Set = new Set<String>();
        Map<String, List<EUR_CRM_Account__c>> taxLevelToAccountMap = new Map<String, List<EUR_CRM_Account__c>>();
        List<EUR_CRM_Account__c> customerTaxonomyAccounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> templateCriteriaAccounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__c> templateAccounts = new List<EUR_CRM_Account__c>();
        Set<String> groupOutletTypeSet = new Set<String>();
        Set<String> outletTypeSet = new Set<String>();
        Set<String> imageLevelSet = new Set<String>();
        Set<String> volumePotentialSet = new Set<String>();
        
        for(EUR_CRM_Account__c acc: (List<EUR_CRM_Account__c>) sObjList) {
            String accountRecordTypeName = accountRecordTypesMap.get(acc.RecordTypeId).DeveloperName;
            
            // Barrier to continue the loop if the account's record type is of invalid type
            if(!accountRecordTypeSet.contains(accountRecordTypeName)) {
                System.debug('####### INVALID AFFILIATE');
                System.debug(acc);
                continue;
            }
            
            EUR_CRM_Account__c oldAccount = Trigger.IsUpdate ? ((EUR_CRM_Account__c) oldMap.get(acc.Id)) : null;
            if(customerTaxonomyAccountRecordTypeSet.contains(accountRecordTypeName) &&
                (Trigger.IsInsert || (Trigger.IsUpdate && isChanged(acc, oldAccount, false)))) {
                // Auto populate the customer taxonomy according to levels and chain info (Off-trade)
                if(acc.EUR_CRM_Chain__c != null && acc.EUR_CRM_Taxonomy_Level_1__c != null && acc.EUR_CRM_Taxonomy_Level_2__c != null) {
	                // Fill up sets to populate each account's Customer Taxonomy later on
                    chainSet.add(acc.EUR_CRM_Chain__c);
                    level1Set.add(acc.EUR_CRM_Taxonomy_Level_1__c);
                    level2Set.add(acc.EUR_CRM_Taxonomy_Level_2__c); 
	                customerTaxonomyAccounts.add(acc);
                    
                    // Add to TaxToAccount Map to assign the account a customer taxonomy
                    String key = createKey(acc.EUR_CRM_Chain__c, acc.EUR_CRM_Taxonomy_Level_1__c, acc.EUR_CRM_Taxonomy_Level_2__c);
                    if(taxLevelToAccountMap.get(key) == null) {
                        taxLevelToAccountMap.put(key, new List<EUR_CRM_Account__c>{acc});
                    } else {
                        taxLevelToAccountMap.get(key).add(acc);
                    }

                } // update listing template (on-trade)
                else if (acc.EUR_JB_Customer_Taxonomy__c != null){
                    customerTaxonomyAccounts.add(acc);
	                custTaxonomy.add(acc.EUR_JB_Customer_Taxonomy__c);
                }
            }
            else if(templateCriteriaAccountRecordTypeSet.contains(accountRecordTypeName) &&
                (Trigger.IsInsert || (Trigger.IsUpdate && isChanged(acc, oldAccount , true)))) {
                
                // Only assigns listing template to accounts with complete information.
                // This prevents newly created accounts to be assigned an arbitrary Listing Template
                if(acc.EUR_CRM_Group_Outlet_Type__c != null && acc.EUR_CRM_Outlet_Type__c != null &&
                    acc.EUR_CRM_Image_Level__c != null && acc.EUR_CRM_Volume_Potential__c != null) {
                    System.debug(acc);

	                templateCriteriaAccounts.add(acc);
	                groupOutletTypeSet.add(acc.EUR_CRM_Group_Outlet_Type__c);
	                outletTypeSet.add(acc.EUR_CRM_Outlet_Type__c);
	                imageLevelSet.add(acc.EUR_CRM_Image_Level__c);
	                volumePotentialSet.add(acc.EUR_CRM_Volume_Potential__c);                          
                }
            }
            else if(templateAccountRecordTypeSet.contains(accountRecordTypeName)){
                templateAccounts.add(acc);
            }           
        }
        
        if(templateCriteriaAccounts.size() > 0) {
            assignListingTemplate_TemplateCriteriaAccounts(templateCriteriaAccounts, groupOutletTypeSet, outletTypeSet, imageLevelSet, volumePotentialSet);
        }
        if(customerTaxonomyAccounts.size() > 0) {
            assignCustomerTaxonomy_CustomerTaxonomyAccounts(taxLevelToAccountMap, chainSet, level1Set, level2Set, custTaxonomy);
            assignListingTemplate_CustomerTaxonomyAccounts(customerTaxonomyAccounts, custTaxonomy);
        }
        if(templateAccounts.size() > 0){
            assignListingTemplate_TemplateAccounts(templateAccounts);
            System.Debug('Assign By Mapping:' + templateAccounts);
        }
    }
    
    /**
    *   Function: assignListingTemplate_TemplateCriteriaAccounts
    *   Assign template criteria to a list of on trade accounts obtained from the trigger action
    *   It will link each account with a template criteria with matching outlet type and image level
    *   Input: Accounts to update, Set of group outlet types, Set of image level, Set of outlet types, and a set of volume potentials for all Accounts in the list
    *   Return: null
    **/
    public static void assignListingTemplate_TemplateCriteriaAccounts(List<EUR_CRM_Account__c> acctSegmentationUpdate, Set<String> groupOutletTypeSet, Set<String> outletTypeSet, Set<String> imageLevelSet, Set<String> volumePotentialSet){ 
        //Key:Concat of segmentation details
        Map<String, EUR_CRM_JB_Template_Criteria__c> templateCriteriaMap = new Map<String, EUR_CRM_JB_Template_Criteria__c>();
        
        for(EUR_CRM_JB_Template_Criteria__c tCriteria: [SELECT Id, EUR_JB_Active__c, EUR_JB_Template__r.EUR_CRM_Record_Type_Name__c,
                                                            EUR_JB_External_ID__c, EUR_JB_Group_Outlet_Type__c, EUR_JB_Image_Level__c, 
                                                            EUR_JB_Outlet_Type__c, EUR_JB_Template__c, EUR_JB_Volume_Potential__c,
                                                            RecordType.DeveloperName
                                                            FROM EUR_CRM_JB_Template_Criteria__c
                                                            WHERE EUR_JB_Group_Outlet_Type__c IN: groupOutletTypeSet
                                                            AND EUR_JB_Outlet_Type__c IN:outletTypeSet
                                                            AND EUR_JB_Image_Level__c IN:imageLevelSet
                                                            AND EUR_JB_Volume_Potential__c IN:volumePotentialSet
                                                            AND EUR_JB_Active__c=true
                                                            //AND Recordtype.developername = :ON_TRADE_TEMPLATE_CRITERIA
                                                           
                                                            ORDER by lastmodifieddate asc
                                                            LIMIT 49999]){
            
            String key = createKey(tCriteria.EUR_JB_Group_Outlet_Type__c,tCriteria.EUR_JB_Outlet_Type__c,
                            tCriteria.EUR_JB_Image_Level__c,tCriteria.EUR_JB_Volume_Potential__c);
            templateCriteriaMap.put(key, tCriteria);
        }
        
        System.debug(templateCriteriaMap);
        
        //Iterate Account List to set value
        for(EUR_CRM_Account__c acct: acctSegmentationUpdate){ 
            String acctKey = createKey(acct.EUR_CRM_Group_Outlet_Type__c,acct.EUR_CRM_Outlet_Type__c,
                                acct.EUR_CRM_Image_Level__c,acct.EUR_CRM_Volume_Potential__c);
            if (templateCriteriaMap.containsKey(acctKey)){
                acct.EUR_CRM_Listing_Template__c = templateCriteriaMap.get(acctKey).EUR_JB_Template__c;
            }
        }
    }
    

    /**
    *   Function: assignCustomerTaxonomy_CustomerTaxonomyAccounts
    *   Assigns each off trade account to a customer taxonomy accordig to chain, level1, and level2 values
    *   Input: List of Accounts, chain, level1, level2 values, and a set of Customer Taxonomy Ids for the list of Accounts
    */    
    private void assignCustomerTaxonomy_CustomerTaxonomyAccounts(Map<String, List<EUR_CRM_Account__c>> taxLevelToAccountMap, Set<String> chainSet, Set<String> level1Set, Set<String> level2Set, Set<Id> custTaxonomy) {
        for(EUR_CRM_Customer_Taxonomy__c custTax: [SELECT Id, EUR_CRM_Chain__c, EUR_CRM_Level_1__c, EUR_CRM_Level_2__c
                                                   FROM EUR_CRM_Customer_Taxonomy__c
                                                   WHERE EUR_CRM_Chain__c IN :chainSet AND
                                                         EUR_CRM_Level_1__c IN :level1Set AND
                                                         EUR_CRM_Level_2__c IN :level2Set AND
                                                         EUR_CRM_Chain__c != NULL AND EUR_CRM_Level_1__c != NULL AND EUR_CRM_Level_2__c != NULL]) {
            
            String key = createKey(custTax.EUR_CRM_Chain__c, custTax.EUR_CRM_Level_1__c, custTax.EUR_CRM_Level_2__c);
            for(EUR_CRM_Account__c acc: taxLevelToAccountMap.get(key)) {
                acc.EUR_JB_Customer_Taxonomy__c = custTax.Id;
                custTaxonomy.add(acc.EUR_JB_Customer_Taxonomy__c);
            }
        }    
    }


    /**
    *   Function: assignListingTemplate_CustomerTaxonomyAccounts
    *   Assigns each off trade accounts to a template based on the customer taxonomy
    *   Input: List of Accounts, Set of Customer Taxonomy Ids for the list of Accounts
    */
    private void assignListingTemplate_CustomerTaxonomyAccounts(List<EUR_CRM_Account__c> euAccounts, Set<Id> custTaxonomy) {
        Map<Id, EUR_CRM_JB_Template__c> templateMap = new Map<Id, EUR_CRM_JB_Template__c>();
        if(custTaxonomy.size() > 0) {
            for(EUR_CRM_JB_Template__c template :[SELECT Id, EUR_CRM_Module__c, EUR_CRM_Default__c, EUR_CRM_Customer_Taxonomy__c
                                                  FROM EUR_CRM_JB_Template__c
                                                  WHERE EUR_CRM_Customer_Taxonomy__c IN :custTaxonomy
                                                  //AND RecordType.DeveloperName = :OFF_TRADE_TEMPLATE
                                                  ]) {
                                                      
                templateMap.put(template.EUR_CRM_Customer_Taxonomy__c, template);
            }
            
            System.debug(templateMap);
            
            for(EUR_CRM_Account__c euAccount: euAccounts) {
                if(templateMap.get(euAccount.EUR_JB_Customer_Taxonomy__c) != null) {
                    euAccount.EUR_CRM_Listing_Template__c = templateMap.get(euAccount.EUR_JB_Customer_Taxonomy__c).Id;
                } else {
                    euAccount.EUR_CRM_Listing_Template__c = null;
                }
            }
        }
    }
    
    /**
    *   Function: assignListingTemplate_TemplateAccounts
    *   Assigns each BE (so far) wholesaler accounts to a template based on master data
    *   Input: List of Accounts
    */
    private void assignListingTemplate_TemplateAccounts(List<EUR_CRM_Account__c> euAccounts) {
        List<EUR_CRM_JB_Template__c> templateList = new List<EUR_CRM_JB_Template__c>();
        templateList = [SELECT Id,RecordType.DeveloperName,EUR_JB_External_ID__c FROM EUR_CRM_JB_Template__c WHERE RecordType.DeveloperName in : templateRTName];  

        Map<String,Id> AccRtLTIdMap = New Map<String,Id>();

        For(EUR_CRM_JB_Template__c LT : templateList){
            if(LT.RecordType.DeveloperName == 'EUR_BE_Wholesaler_Template'){
                AccRtLTIdMap.put('EUR_BE_Wholesaler',LT.id);
            }else if (LT.RecordType.DeveloperName == 'EUR_BE_On_Trade_Template') {
                AccRtLTIdMap.put('EUR_BE_On_Trade',LT.id);
            }
        }

        System.Debug('assignListingTemplate_TemplateAccounts:' + AccRtLTIdMap);

        System.debug(templateList);
        if(templateList.size() > 0){
            for(EUR_CRM_Account__c euAccount: euAccounts){
                System.Debug('RT:' + accountRecordTypesMap.get(euAccount.RecordTypeId).DeveloperName);
                System.Debug('LT:' + AccRtLTIdMap.Get(euAccount.RecordType.DeveloperName));
                euAccount.EUR_CRM_Listing_Template__c = AccRtLTIdMap.Get(accountRecordTypesMap.get(euAccount.RecordTypeId).DeveloperName);
            }
        }
    }

    /**
    *   function: createKey
    *   Creates a unique map key to map accounts
    *   OFF Trade: Takes 3 parameters, maps customer taxonomies to accounts
    *   ON Trade: Takes 4 parameters, maps PROS to accounts
    */
    public static String createKey(String g, String o, String i, String v){
        return g+'-'+o+'-'+i+'-'+v;
    }

    public static String createKey(String chain, String level1, String level2) {
        if(level1 == null) {
            level1 = '_';
        }
        if(level2 == null) {
            level2 = '_';
        }
        return chain + '-' + level1 + '-' + level2;
    }

    /**
    *   function: isChanged
    *   Checks whether an account's values were updated  
    *   OFF Trade: Checks PROS related fields
    *   ON Trade: Checks customer taxonomy related fields
    *   Returns: boolean, if changed or not
    */
    private Boolean isChanged(EUR_CRM_Account__c euAccount, EUR_CRM_Account__c oldEuAccount, Boolean isOntrade){
        if(isOntrade){
            return  (oldEuAccount.EUR_CRM_Group_Outlet_Type__c != euAccount.EUR_CRM_Group_Outlet_Type__c) || 
                    (oldEuAccount.EUR_CRM_Image_Level__c != euAccount.EUR_CRM_Image_Level__c)  ||
                    (oldEuAccount.EUR_CRM_Outlet_Type__c  != euAccount.EUR_CRM_Group_Outlet_Type__c) ||
                    (oldEuAccount.EUR_CRM_Volume_Potential__c != euAccount.EUR_CRM_Volume_Potential__c) ||                    
                    (oldEuAccount.EUR_CRM_Listing_Template__c  != euAccount.EUR_CRM_Listing_Template__c);
        }else{
            return (oldEuAccount.EUR_JB_Customer_Taxonomy__c  != euAccount.EUR_JB_Customer_Taxonomy__c) || 
            (oldEuAccount.EUR_CRM_Chain__c  != euAccount.EUR_CRM_Chain__c) ||
            (oldEuAccount.EUR_CRM_Taxonomy_Level_1__c != euAccount.EUR_CRM_Taxonomy_Level_1__c) ||
            (oldEuAccount.EUR_CRM_Taxonomy_Level_2__c != euAccount.EUR_CRM_Taxonomy_Level_2__c);
        }
    }      
}