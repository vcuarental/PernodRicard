global class EUR_CRM_PT_ScheduleContractStatus implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private Set<String> setRecordTypeNames = new Set<String> {
    	'EUR_PT_Outlet_Contract'
    };

    // Builing query for fetching records 
    private String query = '  SELECT Id'
                         + '       , EUR_CRM_Start_Date__c'
                         + '       , EUR_CRM_Status__c'
                         + '       , EUR_CRM_End_Date__c'
                         + '  FROM EUR_CRM_Contract__c'
                         + '  WHERE RecordType.DeveloperName IN : setRecordTypeNames '
                         + '  AND (EUR_CRM_Start_Date__c = Today'
                         + '  OR EUR_CRM_End_Date__c  = Today)'
                         + '  ORDER BY CreatedDate DESC'; 

    global Database.QueryLocator start(Database.BatchableContext contextInstance) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext contextInstance, list<Sobject> lstFetchedRecords) {
        List<EUR_CRM_Contract__c> toUpdate = new List<EUR_CRM_Contract__c>();
        List<EUR_CRM_Contract__c> toProcess = (List<EUR_CRM_Contract__c>) lstFetchedRecords;
        for(EUR_CRM_Contract__c contract:toProcess){
        	if(contract.EUR_CRM_Start_Date__c == System.today()){
        		contract.EUR_CRM_Status__c = 'Activated';
        		toUpdate.add(contract);
        	}else if(contract.EUR_CRM_End_Date__c == System.today()){
        		contract.EUR_CRM_Status__c = 'Deactivated';
        		toUpdate.add(contract);
        	}
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