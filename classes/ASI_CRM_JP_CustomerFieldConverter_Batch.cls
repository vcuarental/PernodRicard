/**********************************************************************************
 * Name : ASI_CRM_JP_CustomerFieldConverter_Batch
 * Created : DC @03/16/2016 10:03 AM
 * Revision History:
 * 1. 03/16/2016 - [DC 1.0] Created
 * 1. 03/22/2016 - [DC 1.1] Changed record order to sort by CreatedDate descending
 **********************************************************************************/

global class ASI_CRM_JP_CustomerFieldConverter_Batch implements
    Database.Batchable<sObject>, Schedulable, Database.Stateful {

    // All JP CRM record types for Customer object.
    private Set<String> setRecordTypeNames = new Set<String> {
        'ASI_CRM_JP_Bar_Supplier',
        'ASI_CRM_JP_Off_Trade_Outlet',
        'ASI_CRM_JP_On_Trade_Outlet',
        'ASI_CRM_JP_Wholesaler'
    };

    // Builing query for fetching records for Customer object.
    // DC - For testing purpose, set the query limit to 10, otherwise it will pick up all records
    // from the org and will change the characters.
    private String query = '  SELECT Id'
                         + '       , Name'
                         + '       , ASI_CRM_Customer_Name_Katakana__c'
                         + '       , ASI_CRM_CN_Phone_Number__c'
                         + '       , ASI_CRM_PostalCode__c'
                         + '       , ASI_CRM_Street_Number__c'
                         + '       , ASI_CRM_Building_Floor_Number__c'
                         + '    FROM ASI_CRM_AccountsAdditionalField__c'
                         + '   WHERE RecordType.DeveloperName IN : setRecordTypeNames '
                         + 'ORDER BY CreatedDate DESC'; // [DC 1.1]

    private List<ASI_CRM_AccountsAdditionalField__c> lstCustomers_ToUpdate =
        new List<ASI_CRM_AccountsAdditionalField__c>();

    global Database.QueryLocator start(Database.BatchableContext contextInstance) {

        return Database.getQueryLocator(query);

    }
    
    global void execute(Database.BatchableContext contextInstance, list<Sobject> lstFetchedRecords) {
        List<ASI_CRM_AccountsAdditionalField__c> toUpdate = new List<ASI_CRM_AccountsAdditionalField__c>();
        List<ASI_CRM_AccountsAdditionalField__c> lstCustomers_ToProcess =
            (List<ASI_CRM_AccountsAdditionalField__c>) lstFetchedRecords;

        ASI_CRM_JP_EncodingConverter converter = new ASI_CRM_JP_EncodingConverter();

        system.debug('------ lstCustomers_ToProcess ------ : ' + lstCustomers_ToProcess);
        
        converter.performConversion(lstCustomers_ToProcess);

        toUpdate.addAll(converter.triggerNew);
        try{
            if(!toUpdate.isEmpty()){
                update toUpdate;
            }
        }catch(DmlException exceptionInstance){
        
        }
    }

    public void execute(SchedulableContext schedulableContextInstance) {
        // TODO : Nothing
    }

    global void finish(Database.BatchableContext contextInstance) {
       
    }
}