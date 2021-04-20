/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Deep Clone the Survey and Question Line Items
  @Author:      IPC
  @History:     OCT.08.2014 - Created
*/
public class EUR_CRM_SurveyHeaderQuestionsClone{
    private ApexPages.StandardController controller {get; set;}
    private EUR_CRM_Survey_Header__c surveyHeader {get;set;}
    public ID newRecordId {get;set;}
    
    public EUR_CRM_SurveyHeaderQuestionsClone(ApexPages.StandardController controller) {
        this.controller = controller;
        surveyHeader = (EUR_CRM_Survey_Header__c)controller.getRecord();
    }
    
    public PageReference cloneSurveyWithQuestions() {
        //setup the save point for rollback
        Savepoint sp = Database.setSavepoint();
        EUR_CRM_Survey_Header__c newSH;

        try{
            surveyHeader = (EUR_CRM_Survey_Header__c)Database.query(getSOQL('EUR_CRM_Survey_Header__c','Id = \'' + surveyHeader.Id + '\''));

            surveyHeader.EUR_CRM_Active__c = false;
            surveyHeader.OwnerId = userInfo.getUserId();
            newSH = surveyHeader.clone(false);
            insert newSH;
            
            //for testing
            newRecordId = newSH.id;

            //Survey Questions - Line Item
            List<EUR_CRM_Survey_Question__c> surveyQuestionsSOQL = new List<EUR_CRM_Survey_Question__c>();
            surveyQuestionsSOQL = (List<EUR_CRM_Survey_Question__c>)Database.query(getSOQL('EUR_CRM_Survey_Question__c','EUR_CRM_Survey_Header__c = \'' + surveyHeader.Id + '\''));
            
            List<EUR_CRM_Survey_Question__c> surveyQuestions = new List<EUR_CRM_Survey_Question__c>();
            for (EUR_CRM_Survey_Question__c sq : surveyQuestionsSOQL) {
                EUR_CRM_Survey_Question__c newSQ = sq.clone(false);
                newSQ.EUR_CRM_Survey_Header__c = newSH.Id;
                surveyQuestions.add(newSQ);
            }
            if(surveyQuestions.size() > 0){
                insert surveyQuestions;
            }
        }catch(Exception e){
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
 
        return new PageReference('/'+newSH.id+'/e?retURL=%2F'+newSH.id);
    }
    
    public static String getSOQL(String objName, String whereClause){
        String selects = '';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if(fieldMap != null){
            for (Schema.SObjectField ft : fieldMap.values()){
                Schema.DescribeFieldResult fd = ft.getDescribe();
                if (fd.isCreateable()){
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
        }
        
        system.debug('***SELECT: ' + 'Select ' + selects + ' From ' + objName + ' Where ' + whereClause);
        return 'Select ' + selects + ' From ' + objName + ' Where ' + whereClause;
    }
}