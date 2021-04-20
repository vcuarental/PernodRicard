global class EUR_CRM_BE_PRS_SetReperformFlag implements Database.Batchable<sObject> {
    
    String query;


    public static Set<String> validRecordType = New Set<String>{'EUR_BE_On_Trade','EUR_BE_Off_Trade'}; 

    global EUR_CRM_BE_PRS_SetReperformFlag() {

        /*Datetime now = Datetime.now();
        Date dateNow = now.date(); 

        System.Debug('Date Check:' + dateNow);
        System.Debug('Date Check:' + targetDate);
        System.Debug('Query Check:' + query);
        return query;*/
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT id,EUR_CRM_Perform_Yearly_Segmentation__c,EUR_CRM_Account__c FROM EUR_CRM_PRS_Segmentation__c ' + 
        'WHERE EUR_CRM_Account__c in (SELECT id FROM EUR_CRM_Account__c WHERE RecordType.DeveloperName in : validRecordType) and (EUR_CRM_Perform_Yearly_Segmentation__c = false or EUR_CRM_Perform_Yearly_Segmentation__c = null)';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.Debug('EUR_CRM_BE_PRS_SetReperformFlag:execute');
        SetFlag((List<EUR_CRM_PRS_Segmentation__c>) scope);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

    global static void SetFlag(List<EUR_CRM_PRS_Segmentation__c> PRSList){
        System.Debug('EUR_CRM_BE_PRS_SetReperformFlag:SetFlag:' + PRSList);
        
        
        for(EUR_CRM_PRS_Segmentation__c PRS : PRSList){
            PRS.EUR_CRM_Perform_Yearly_Segmentation__c = True;
        }
        
        update PRSList;
    }
}