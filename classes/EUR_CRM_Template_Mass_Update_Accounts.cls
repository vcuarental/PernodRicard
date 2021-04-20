/**
SEPT.22.2014
    - added a new constructor where parameter is String that represents country code.
    - Select all listing template where record type represents the country code.
    - if country code is 'DE' nullify EUR_CRM_Listing_Template__c account field instead of EUR_JB_Default_Template__c 
        
*/
global class EUR_CRM_Template_Mass_Update_Accounts implements Database.Batchable<sObject>  {
    
    private final String subject = 'Template Batch Update for EU Accounts - Done';
    private final String emailTemplateName = 'EUR_CRM_Template_Batch_Email_Result';
    private final static Map<String,Set<String>> countryCodeRecordTypeMap = new Map<String,Set<String>>{
    'DE'=>new Set<String>{'EUR_DE_OFF_Trade_Template', 'EUR_DE_ON_TRADE_Template'}};
    private Set<String> validRecordTypes; 
    private String countryCode; 
    private final String query;
    global EUR_CRM_Template_Mass_Update_Accounts(Id templateRecordType){
        // Batch Constructor
        //Get User's default record type on Template object
        //Get all inactive Template Criteria
        System.debug('Flag Template Record Type:' + templateRecordType);
        
        query = 'SELECT Id, EUR_JB_Template__c, EUR_JB_Active__c, EUR_JB_Template__r.RecordTypeId, EUR_JB_Template__r.ID FROM EUR_CRM_JB_Template_Criteria__c WHERE EUR_JB_Active__c=false AND EUR_JB_Template__r.RecordTypeId = \''+String.valueOf(templateRecordType)+'\'';
        System.debug('Flag - Mass Update query:' + query);
    }
    
    global EUR_CRM_Template_Mass_Update_Accounts(String countryCode){
        // Batch Constructor
        //Get User's default record type on Template object
        //Get all inactive Template Criteria
        System.debug('Flag Template countryCode :' + countryCode);
        this.countryCode = countryCode;
        validRecordTypes = countryCodeRecordTypeMap.get(countryCode);
        query = 'SELECT Id, EUR_JB_Template__c, EUR_JB_Active__c, EUR_JB_Template__r.RecordTypeId, EUR_JB_Template__r.ID FROM EUR_CRM_JB_Template_Criteria__c WHERE EUR_JB_Active__c=false AND EUR_JB_Template__r.RecordType.developername in:validRecordTypes';
        System.debug('Flag - Mass Update query:' + query);
    }
     
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
   // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        // Logic to be Executed batch wise      
        //Records to be updated
        List<EUR_CRM_Account__c> updatedEUAccount = new List<EUR_CRM_Account__c>();
        //Reference records
        List<EUR_CRM_JB_Template_Criteria__c> templateList= (List<EUR_CRM_JB_Template_Criteria__c>) scope;
        Set<Id> templateIdList = new Set<Id>();
        
        String strError = '';
        String s = '';
        
        try{
            for (EUR_CRM_JB_Template_Criteria__c templateCriteria: templateList){
                templateIdList.add(templateCriteria.EUR_JB_Template__c);
            }
            
            System.debug('Flag - Templates:' + templateIdList);
            
            //Find accounts to be updated
            if(countryCode != null && countryCode == 'DE'){ 
                for (EUR_CRM_Account__c euAcct: [SELECT Id, EUR_JB_Default_Template__c,EUR_CRM_Listing_Template__c FROM EUR_CRM_Account__c 
                                                    WHERE EUR_CRM_Listing_Template__c IN: templateIdList]){
                    euAcct.EUR_CRM_Listing_Template__c = null;                
                    updatedEUAccount.add(euAcct);
                }
            }else{
                 for (EUR_CRM_Account__c euAcct: [SELECT Id, EUR_JB_Default_Template__c FROM EUR_CRM_Account__c 
                                                    WHERE EUR_JB_Default_Template__c IN: templateIdList]){
                    euAcct.EUR_JB_Default_Template__c = null;                
                    updatedEUAccount.add(euAcct);
                }
            
            }
            
            System.debug('Flag - EU Accounts for Update:' + updatedEUAccount);
            //update DB
            Database.update(updatedEUAccount);
            
        }catch(Exception e){ 
            strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                s = e.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
            }else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));}
        }
    }
   
    global void finish(Database.BatchableContext BC){
         // Logic to be Executed at finish
         EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), null);
    }
}