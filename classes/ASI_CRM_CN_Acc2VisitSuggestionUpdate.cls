global class ASI_CRM_CN_Acc2VisitSuggestionUpdate implements Schedulable, Database.Batchable<SObject> {

    // START: Schedulable Interface    

    public void execute(SchedulableContext sc) {
        database.executebatch(new ASI_CRM_CN_Acc2VisitSuggestionUpdate());
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
        UpdateAccount2VisitSuggestion(account2Ids);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    // END: Batchable Interface
    
    

    public static void UpdateAccount2VisitSuggestion(list<Id> account2Ids) {
        
        list<string> keys = new list<string>();
        map<id, string> mapA2Keys = new map<id, string>();
        map<id, ASI_CRM_AccountsAdditionalField__c> mapIdA2 = new map<id, ASI_CRM_AccountsAdditionalField__c>();
        for(ASI_CRM_AccountsAdditionalField__c a2 : [SELECT Id, RecordType.DeveloperName, ASI_CRM_CN_Suggested_No_of_Visit__c,ASI_CRM_CN_Competitor_Outlet__c,
                                                     ASI_CRM_CN_WS_Tier__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c, ASI_CRM_CN_Grade__c, ASI_CRM_CN_Image__c,
                                                     ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.Name
                                                     ,ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c,ASI_CRM_CN_New_Image__c //20160909, edited by Leo
                                                     FROM ASI_CRM_AccountsAdditionalField__c
                                                     WHERE Id IN :account2Ids]) {
                                                         mapIdA2.put(a2.Id, a2);
                                                         If(a2.RecordType.DeveloperName=='ASI_CRM_CN_WS') {
                                                             string key = 'WS|' + a2.ASI_CRM_CN_WS_Tier__c;
                                                             keys.add(key);
                                                             mapA2Keys.put(a2.Id, key);
                                                         }
                                                         else if(a2.RecordType.DeveloperName=='ASI_CRM_Outlet_CN') {
                                                             //20160909, edited by Leo
                                                             if(a2.ASI_CRM_CN_NewChannel__c != null)
                                                             {
                                                                 string key = 'Outlet|' + ((string)a2.ASI_CRM_CN_NewChannel__c).substring(0,15) + '|';
                                                                 if(a2.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c=='On') {
                                                                     key += a2.ASI_CRM_CN_Grade__c;
                                                                 }else if(a2.ASI_CRM_CN_NewChannel__r.ASI_CRM_CN_On_Off__c=='Off') {
                                                                     key += a2.ASI_CRM_CN_New_Image__c;
                                                                 }
                                                                 keys.add(key);
                                                                 mapA2Keys.put(a2.Id, key);
                                                                 system.debug(key);
                                                             }
                                                             else if(a2.ASI_CRM_CN_Sub_Channel__c != null)
                                                             {
                                                             //20160909, edited by Leo
                                                                 string key = 'Outlet|' + ((string)a2.ASI_CRM_CN_Sub_Channel__c).substring(0,15) + '|';
                                                                 if(a2.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c=='On') {
                                                                     key += a2.ASI_CRM_CN_Grade__c;
                                                                 } else if(a2.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c=='Off') {
                                                                     key += a2.ASI_CRM_CN_Image__c;
                                                                 }
                                                                 keys.add(key);
                                                                 mapA2Keys.put(a2.Id, key);
                                                                 system.debug(key);
                                                             }//20160909, edited by Leo
                                                             else
                                                             {
                                                                 string key = 'Outlet|' + '|';
                                                                 keys.add(key);
                                                                 mapA2Keys.put(a2.Id, key);
                                                                 system.debug(key);
                                                                 
                                                             }//20160909, edited by Leo
                                                         }
                                                     }
        
        map<string, decimal> mapKeySuggestions = new map<string, decimal>();
        map<string, decimal> mapKeySuggestionsCompetitor = new map<string, decimal>();
        for(ASI_CRM_Call_Log_Suggestion_Setting__c i : [SELECT ASI_CRM_CN_Key__c, ASI_CRM_Suggested_No_of_Visit__c,ASI_CRM_SuggestedNoofVisitCompetitor__c
                                                        FROM ASI_CRM_Call_Log_Suggestion_Setting__c
                                                        WHERE ASI_CRM_CN_Key__c in :keys]) {
                                                         if(i.ASI_CRM_SuggestedNoofVisitCompetitor__c!=null)
                                                                mapKeySuggestionsCompetitor.put(i.ASI_CRM_CN_Key__c, i.ASI_CRM_SuggestedNoofVisitCompetitor__c);
                                                            if(i.ASI_CRM_Suggested_No_of_Visit__c!=null)
                                                                mapKeySuggestions.put(i.ASI_CRM_CN_Key__c, i.ASI_CRM_Suggested_No_of_Visit__c);
                                                        }
                                                        
        list<ASI_CRM_AccountsAdditionalField__c> updates = new list<ASI_CRM_AccountsAdditionalField__c>();
    
        for(Id i: account2Ids) {
            if(mapIdA2.containsKey(i) && mapA2Keys.containsKey(i)) {
                ASI_CRM_AccountsAdditionalField__c a2 = mapIdA2.get(i);
                string key = mapA2Keys.get(i);
                if(mapKeySuggestions.containsKey(key) || mapKeySuggestionsCompetitor.containsKey(key)) {
                    decimal suggestion;
                    
                    if(a2.ASI_CRM_CN_Competitor_Outlet__c == true)
                       suggestion = mapKeySuggestionsCompetitor.get(key);
                    else 
                        suggestion = mapKeySuggestions.get(key);
                    
                    if(a2.ASI_CRM_CN_Suggested_No_of_Visit__c!=suggestion)
                        updates.add(new ASI_CRM_AccountsAdditionalField__c(Id=i, ASI_CRM_CN_Suggested_No_of_Visit__c=suggestion ));
                }
                else {
                    if(a2.ASI_CRM_CN_Suggested_No_of_Visit__c!=null)
                        updates.add(new ASI_CRM_AccountsAdditionalField__c(Id=i, ASI_CRM_CN_Suggested_No_of_Visit__c=null ));
                }
            }
        }
        
        if(updates.size()>0)
            database.update(updates, false);

  
    }
    
}