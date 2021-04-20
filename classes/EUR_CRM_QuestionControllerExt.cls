public with sharing class EUR_CRM_QuestionControllerExt {

    private final Apexpages.StandardController standardController;
    private static final Set<String> typeNeedValuesSet = new Set<String>{'Yes/No', 'Picklist', 'Multipicklist'};

    public EUR_CRM_Question__c myQuestion { get; set; }
    public Boolean needQuestionValue {
        get{
            if(String.IsNotBlank(myQuestion.EUR_CRM_Question_Value_Type__c))
                needQuestionValue = typeNeedValuesSet.contains(myQuestion.EUR_CRM_Question_Value_Type__c);
            return needQuestionValue;
        }set;
    }

    public List<EUR_CRM_Answer_Value__c> questionValuesDisplay{
        get{
            if(questionValuesDisplay == null){
                questionValuesDisplay = new List<EUR_CRM_Answer_Value__c>();
            }
            return questionValuesDisplay;
        }set;
    }

    public List<EUR_CRM_Answer_Value__c> questionValuesDelete{
        get{
            if(questionValuesDelete == null){
                questionValuesDelete = new List<EUR_CRM_Answer_Value__c>();
            }
            return questionValuesDelete;
        }set;
    }

    public EUR_CRM_QuestionControllerExt(Apexpages.StandardController stdController){
        standardController = stdController;
        getQuestionDetail();
    }

    private void getQuestionDetail(){
        myQuestion = [
            SELECT RecordTypeId, EUR_CRM_Question_Value_Type__c, EUR_CRM_Question_Statement__c, EUR_CRM_Description__c, EUR_CRM_Number_of_Survey_Answers__c,
            (
                SELECT EUR_CRM_Sequence__c, EUR_CRM_Value__c, RecordTypeId
                FROM Question_Values__r
                ORDER BY EUR_CRM_Sequence__c
                LIMIT 1000
            )
            FROM EUR_CRM_Question__c
            WHERE Id =: standardController.getId()
            LIMIT 1000
        ];

        if (myQuestion.Question_Values__r.size() > 0) {
            questionValuesDisplay = myQuestion.Question_Values__r;
        }
    }

    public void addQuestionValueItem(){
        EUR_CRM_Answer_Value__c newValue = new EUR_CRM_Answer_Value__c(EUR_CRM_Question__c = myQuestion.Id);
        questionValuesDisplay.add(newValue);
    }

    public void removeQuestionValueItem(){
        String rowIndex = Apexpages.currentPage().getParameters().get('rowIndex');
        Integer index = Integer.valueOf(rowIndex);
        if(questionValuesDisplay[index].Id != null)
            questionValuesDelete.add(questionValuesDisplay[index]);
        questionValuesDisplay.remove(index);
    }

    public PageReference saveQuestion(){

        String url = '/' + EUR_CRM_Question__c.SObjectType.GetDescribe().GetKeyPrefix();
        PageReference ref = new ApexPages.PageReference(url).SetRedirect(true);
        for(Integer i=0; i<questionValuesDisplay.size(); i++){
            questionValuesDisplay[i].EUR_CRM_Sequence__c = i+1;
        }

        System.Savepoint pSavepoint = Database.setSavepoint();
        try{
            Database.upsert(myQuestion);
            if(needQuestionValue){
                if(!questionValuesDelete.isEmpty())
                    Database.delete(questionValuesDelete);
                if(!questionValuesDisplay.isEmpty())
                    Database.upsert(questionValuesDisplay);
            }else{
                Database.delete([Select Id From EUR_CRM_Answer_Value__c Where EUR_CRM_Question__c =: myQuestion.Id]);
            }

        }catch(Exception ex){
            if(ex.getTypeName() == 'DMLException' || Test.isRunningTest()){
                Database.rollback(pSavepoint);
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, ex.getDMLMessage(0)));
            }
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
        return ref;
    }

}