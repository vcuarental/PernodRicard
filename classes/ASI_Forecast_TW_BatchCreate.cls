global class ASI_Forecast_TW_BatchCreate implements Database.Batchable<sObject> {
    global final String forecastType; // Forecast | Budget
    global final String dateString;
    global final Set<Id> headerIdSet;
    
    
    global ASI_Forecast_TW_BatchCreate(String fType, Set<Id> hIdSet, String dateStr) {
        forecastType = fType;
        dateString   = dateStr;
        headerIdSet  = hIdSet;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT id, (SELECT id FROM ASI_Forecast_Item__r) FROM ASI_Forecast__c WHERE ASI_Forecast_Status__c = \'Processing\' AND RecordType.DeveloperName Like \'ASI_Forecast_TW\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_Forecast__c> scope)
    {
        Set<Id> currHeaderIdSet = new Set<Id>();
        for(ASI_Forecast__c header : scope) {
            if(header.ASI_Forecast_Item__r.size() == 0) {
                currHeaderIdSet.add(header.Id);
            }
        }
        ASI_CRM_TW_Forecast_Create.insertForecastItem(currHeaderIdSet);
    }  
    global void finish(Database.BatchableContext BC)
    {
        ASI_CRM_TW_Forecast_Util.updateForecastStatus(headerIdSet,'Draft');
        system.debug('forecastType : '+ forecastType);
        Set<String> channelCodeSet = ASI_CRM_TW_Forecast_Create.searchChannelCodeByHeaderIdSet(headerIdSet);
        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchForecastInputerByChannelCode(channelCodeSet);
        if(forecastType == 'Forecast') {
            ASI_CRM_TW_Forecast_Util.sendForecastEmail(new List<String>(emailList),dateString, '', '', 'ASI_Forecast_TW_Create_HTML', 'ASI_Forecast_TW_InputForecastPage');
            system.debug('send forecast mail');
        } else if(forecastType == 'Budget') {
            ASI_CRM_TW_Forecast_Util.sendBudgetEmail(new List<String>(emailList), dateString, '', '', 'ASI_Forecast_TW_Create_HTML', 'ASI_Forecast_TW_InputBudgetPage');
            system.debug('send Budget mail');
        }
        
/*
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'dev.pra@introv.com'});
        mail.setReplyTo('dev.pra@introv.com');
        mail.setSenderDisplayName('Batch Process');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('Batch Process has completed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
*/
    }
}