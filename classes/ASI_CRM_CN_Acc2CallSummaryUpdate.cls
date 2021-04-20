global class ASI_CRM_CN_Acc2CallSummaryUpdate implements Schedulable, Database.Batchable<SObject> {

	// START: Schedulable Interface    

    public void execute(SchedulableContext sc) {
        database.executebatch(new ASI_CRM_CN_Acc2CallSummaryUpdate());
    }

    // END: Schedulable Interface

    
    // START: Batchable Interface

    global database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator([SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE RecordType.DeveloperName='ASI_CRM_Outlet_CN' OR RecordType.DeveloperName='ASI_CRM_CN_WS']);
     }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope){
		list<Id> account2Ids = new list<Id>();
        for(SObject o: scope) {
            account2Ids.add(o.Id);
        }
        UpdateAccount2CallSummary(account2Ids);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    // END: Batchable Interface
    
    

    public static void UpdateAccount2CallSummary(list<Id> account2Ids) {
        
        Date startDate = Date.newInstance(system.today().year(), system.today().month(), 1);
        
        RecordType rtEvent = Global_RecordTypeCache.getRtRec('EventASI_CRM_CN_Call_Plan');
        
        list<ASI_CRM_AccountsAdditionalField__c> updates = new list<ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c account2 : [SELECT Id, ASI_CRM_Latest_Call_Plan_Date__c, ASI_CRM_MTD_Call_Plan__c, ASI_CRM_MTD_Call_Log__c,
                                                           (SELECT ASI_CRM_Number_Of_Call_Plan__c, ASI_CRM_Number_Of_Call_Log__c 
                                                            FROM Call_Monthly_Summaries__r 
                                                            WHERE ASI_CRM_Summary_Start_Date__c  = :startDate
                                                            LIMIT 1),
                                                           (SELECT StartDateTime FROM Events
                                                            WHERE RecordTypeId = :rtEvent.Id AND StartDateTime!=NULL
                                                            ORDER BY StartDateTime DESC
                                                            LIMIT 1)
                                                           FROM ASI_CRM_AccountsAdditionalField__c
                                                           WHERE Id IN :account2Ids]) {
                                                               
                                                               boolean updated = false;
                                                               
                                                               if((account2.Events==null || account2.Events.size()<=0)) {
                                                                   if(account2.ASI_CRM_Latest_Call_Plan_Date__c!=null) {
                                                                       account2.ASI_CRM_Latest_Call_Plan_Date__c = null;
                                                                       updated = true;
                                                                   }   
                                                               }
                                                               else if(account2.ASI_CRM_Latest_Call_Plan_Date__c==null || account2.ASI_CRM_Latest_Call_Plan_Date__c <account2.Events[0].StartDateTime) {
                                                                   account2.ASI_CRM_Latest_Call_Plan_Date__c = Date.newInstance( account2.Events[0].StartDateTime.year(), account2.Events[0].StartDateTime.month(), account2.Events[0].StartDateTime.day());
                                                                   updated = true;
                                                               }
                                                               
                                                               if(account2.Call_Monthly_Summaries__r==null || account2.Call_Monthly_Summaries__r.size()<=0) {
                                                                   if(account2.ASI_CRM_MTD_Call_Plan__c!=0 ||account2.ASI_CRM_MTD_Call_Log__c!=0 ) {
                                                                       account2.ASI_CRM_MTD_Call_Plan__c = 0;
                                                                       account2.ASI_CRM_MTD_Call_Log__c = 0;
                                                                       updated = true;
                                                                   }    
                                                               }
                                                               else if(account2.ASI_CRM_MTD_Call_Plan__c != account2.Call_Monthly_Summaries__r[0].ASI_CRM_Number_Of_Call_Plan__c ||
                                                                       account2.ASI_CRM_MTD_Call_Log__c != account2.Call_Monthly_Summaries__r[0].ASI_CRM_Number_Of_Call_Log__c) {
                                                                           account2.ASI_CRM_MTD_Call_Plan__c = account2.Call_Monthly_Summaries__r[0].ASI_CRM_Number_Of_Call_Plan__c;
                                                                           account2.ASI_CRM_MTD_Call_Log__c = account2.Call_Monthly_Summaries__r[0].ASI_CRM_Number_Of_Call_Log__c;
                                                                           updated = true;
                                                                       }
                                                               
                                                               if(updated) 
                                                                   updates.add(account2);
                                                           }
        
        if(updates.size()>0)
            update updates;
    }
    
}