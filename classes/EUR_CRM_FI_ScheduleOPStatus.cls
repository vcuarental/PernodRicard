global class EUR_CRM_FI_ScheduleOPStatus implements 
    Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private Set<String> setRecordTypeNames = new Set<String> {
        'EUR_FI_Off_Trade_O_P',
        'EUR_FI_On_Trade_O_P'
    };

    // Builing query for fetching records 
    private String query = '  SELECT Id'
                         + '       , EUR_CRM_Evaluation_Period_End_Date__c'
                         + '       , EUR_CRM_Status__c'
                         + '       , (Select EUR_CRM_Actual_Number_of_Commitments__c,EUR_CRM_Is_Quota__c, EUR_CRM_Visit_Targets__c From O_P_Targets__r Limit 1)'
                         + '  FROM EUR_CRM_ObjPromo__c'
                         + '  WHERE RecordType.DeveloperName IN : setRecordTypeNames '
                         + '  AND EUR_CRM_Status__c != \'Ended\''
                         + '  ORDER BY CreatedDate DESC'; 

    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext contextInstance, list<Sobject> lstFetchedRecords) {
        List<EUR_CRM_ObjPromo__c> toUpdate = new List<EUR_CRM_ObjPromo__c>();
        List<EUR_CRM_ObjPromo__c> toProcess = (List<EUR_CRM_ObjPromo__c>) lstFetchedRecords;
        for(EUR_CRM_ObjPromo__c objpromo:toProcess){
            if(objpromo.EUR_CRM_Evaluation_Period_End_Date__c <= System.Today()){
                objpromo.EUR_CRM_Status__c = 'Ended';
                toUpdate.add(objpromo);
            }/*else{
                for(EUR_CRM_ObjPromo_Target__c target:objpromo.O_P_Targets__r){
                    if(target.EUR_CRM_Actual_Number_of_Commitments__c >= target.EUR_CRM_Visit_Targets__c && target.EUR_CRM_Is_Quota__c == true){
                        objpromo.EUR_CRM_Status__c = 'Ended';
                        toUpdate.add(objpromo);
                    }
                }
            }*/
        }
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