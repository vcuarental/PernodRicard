/**
"PR FI - Surveys
1) Implement Batch Apex to set Active Flag of Survey Header and Survey (EU) records to False when the Survey Header is Expired
 
*/

global class EUR_CRM_DeactivateSurveys implements Database.Batchable<sObject>{

  global static Set<String> validSurveryHeaderRecordType = new Set<String>{
             'EUR_FI_OFF_Trade_Survey_Header',
             'EUR_FI_ON_Trade_Survey_Header',
             'EUR_BG_OFF_Trade_Survey_Header',
             'EUR_BG_ON_Trade_Survey_Header',
             'EUR_BE_OFF_Trade_Survey_Header',
             'EUR_BE_ON_Trade_Survey_Header',
             'EUR_SE_ON_Trade_Survey_Header',
             'EUR_DK_OFF_Trade_Survey_Header',
             'EUR_DK_ON_Trade_Survey_Header',
             'EUR_NL_Off_Trade_Survey_Header',
             'EUR_NL_On_Trade_Survey_Header'
        };

  global static String generateQuery(){
        String validSHRTs = '(\''+String.join(new List<String>(validSurveryHeaderRecordType), '\',\'')+'\')';

        String q ='SELECT ID, NAME, EUR_CRM_Survey_Header__c, EUR_CRM_Active__c '; 
        q +=' FROM EUR_CRM_Survey__c';
        q +=' WHERE EUR_CRM_Survey_Header__r.RECORDTYPE.DEVELOPERNAME IN '+validSHRTs ;
        q +=' AND EUR_CRM_Active__c = true';
        q +=' AND EUR_CRM_Survey_Header__r.EUR_CRM_Valid_Until__c < TODAY';
        system.debug('### query: ' + q);
        return q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(generateQuery());
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
      deactivateSurveys((List<EUR_CRM_Survey__c>) scope);
    }
    global static void deactivateSurveys(List<EUR_CRM_Survey__c> s){
         Set<String> validRecordType = new Set<String>{
             'EUR_FI_OFF_Trade_Survey_Header',
             'EUR_FI_ON_Trade_Survey_Header',
             'EUR_BG_OFF_Trade_Survey_Header',
             'EUR_BG_ON_Trade_Survey_Header',
             'EUR_BE_OFF_Trade_Survey_Header',
             'EUR_BE_ON_Trade_Survey_Header',
             'EUR_SE_ON_Trade_Survey_Header',
             'EUR_DK_OFF_Trade_Survey_Header',
             'EUR_DK_ON_Trade_Survey_Header',
             'EUR_NL_Off_Trade_Survey_Header',
             'EUR_NL_On_Trade_Survey_Header'
        };
            
        Set<ID> surveyHeaderIds = new Set<ID>();
        List<EUR_CRM_Survey__c> surveys = new List<EUR_CRM_Survey__c>();
        
        for(EUR_CRM_Survey__c survey :  s){
            if(survey.EUR_CRM_Active__c){
               surveyHeaderIds.add(survey.EUR_CRM_Survey_Header__c);
               survey.EUR_CRM_Active__c  = false;
               surveys.add(survey);
            }
        }
        
        update surveys;
        
        List<EUR_CRM_Survey_Header__c> surveyHeaders = new List<EUR_CRM_Survey_Header__c>();
        
        for(Id svId : surveyHeaderIds){
            surveyHeaders.add(new EUR_CRM_Survey_Header__c(id = svId, EUR_CRM_Active__c = false));
        }
         
        update surveyHeaders;
        List<EUR_CRM_Survey_Header__c> otherSurveyHeaders = new List<EUR_CRM_Survey_Header__c>();
        
         for(EUR_CRM_Survey_Header__c surveyHeader:  [select id from EUR_CRM_Survey_Header__c 
             where recordtype.developername in : validRecordType 
             and EUR_CRM_Active__c = true and EUR_CRM_Valid_Until__c < today
             and id not in: surveyHeaderIds]){
             surveyHeader.EUR_CRM_Active__c = false;
             otherSurveyHeaders.add(surveyHeader );
         }
          update otherSurveyHeaders ;
    }
    global void finish(Database.BatchableContext BC){
    
    }

}