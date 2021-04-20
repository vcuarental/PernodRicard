public with sharing class EUR_CRM_PRSQuestionsExt {

    private final String ACTION_EDIT = 'EDIT';
    private final String ACTION_NEW = 'NEW';
    private final String ACTION;

    private ApexPages.StandardController standardController;
    private EUR_CRM_AnswerManager answerMgr;

    public  EUR_CRM_PRS_Question__c prsQuestion                             {get;set;}

    public Id possibleAnswerRecordTypeId                                    {get;set;}
    public Id answerTypeId                                                  {get;set;}

    public String parentURL                                                 {get;set;}
    public Integer rowIndex                                                 {get;set;}
    public String state                                                     {get;set;}

    public List<String> visibleFieldSet                                     {get;set;}
    public List<SelectOption> answerRecordTypes                             {get;set;}
    public List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswerDisplay  {get;set;}
    public List<EUR_CRM_PRS_Question_Criteria__c> deletePRSPossibleAnswer   {get;set;}

    public Map<String, String> visibleFieldLabelSet                         {get;set;}
    public Map<Id,EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswer       {get;set;}

    public Boolean isAnswerBoolean                                          {get;set;} {isAnswerBoolean=false;}
    public Boolean isBrandBuilding                                          {get;set;}
    public Boolean isNumber                                                 {get;set;}
    public Boolean hasAnswers                                               {get;set;}
    public Boolean isUKVol                                                  {get;set;}
    public Boolean isDisplayPRSPossibleAnswer                               {get;set;}

    public EUR_CRM_PRSQuestionsExt(ApexPages.StandardController standardController)
    {
        isBrandBuilding = false;
        isNumber = true;
        this.standardController = standardController;

        if (this.standardController.getId() != null){
            this.ACTION = ACTION_EDIT;
            this.prsQuestion = (EUR_CRM_PRS_Question__c) returnPRSQuestion();
        }

        System.debug('FLAG_Question:' + prsQuestion);
        System.debug('FLAG_RECORDTYPE: ' + this.prsQuestion.RecordTypeId);

        this.answerMgr = new EUR_CRM_AnswerManager(this.prsQuestion.EUR_CRM_PRS_Question_Set__r.EUR_CRM_Country_Code__c);
        this.isDisplayPRSPossibleAnswer = false;
        System.debug('Parent URL: ' + parentURL);

        //SET FIELD LABELS
        visibleFieldLabelSet = new Map<String, String> {
                'EUR_CRM_Criteria_Picklist_Value__c'=>'Answer Value',
                'EUR_CRM_Criteria_Picklist_Label__c'=>'Answer Label',
                'EUR_CRM_Criteria_Weight__c'=>'Weight',
                'EUR_CRM_Answer_Condition__c'=>'Condition',
                'EUR_CRM_Criteria_Threshold_Number__c'=>'Base Number',
                'EUR_CRM_Criteria_Threshold_Currency__c'=>'Base Currency'
        };

        //SET Possible Answer
        answerRecordTypes = this.answerMgr.getQuestionsRecordTypes();
        initPRSPossibleAnswers();
        System.debug('Record Type:' + this.prsQuestion.RecordTypeId);

        EUR_CRM_PRS_Question_Set__c questionGOTypeMapping = [SELECT Id, RecordType.Name, RecordType.Developername
        FROM EUR_CRM_PRS_Question_Set__c
        WHERE Id =: prsQuestion.EUR_CRM_PRS_Question_Set__c];

        if(questionGOTypeMapping != null && (questionGOTypeMapping.RecordType.Name).contains('BrandBuilding')){
            isBrandBuilding = true;
        }
        isNumber = getIsNumber();

        // TODO: Buggy Developer Name 
        isUKVol = (questionGOTypeMapping != null && (questionGOTypeMapping.RecordType.Developername == 'EUR_GB_Volume_Potential_Answer'));
    }

    private EUR_CRM_PRS_Question__c returnPRSQuestion(){
        EUR_CRM_PRS_Question__c tempQuestion =
        [SELECT Id, RecordTypeId,
                EUR_CRM_PRS_Question_Set__c, EUR_CRM_PRS_Question_Set__r.RecordTypeId,
                EUR_CRM_PRS_Question_Set__r.EUR_CRM_Country_Code__c,
                EUR_CRM_Question_Statement__c, EUR_CRM_Question_Weight__c, EUR_CRM_ActionPROS__c
        FROM EUR_CRM_PRS_Question__c
        WHERE Id =: this.standardController.getId()];

        return tempQuestion;
    }

    private void initPRSPossibleAnswers(){
        System.debug('Init Possible Answers');
        prsPossibleAnswer = null;
        prsPossibleAnswerDisplay = new List<EUR_CRM_PRS_Question_Criteria__c>();
        deletePRSPossibleAnswer = new List<EUR_CRM_PRS_Question_Criteria__c>();
        visibleFieldSet = new List<String>();
        isNumber = getIsNumber();
        System.debug('INIT Possible Answer: FLAG_RECORD TYPE:' + this.prsQuestion.RecordTypeId);
        isAnswerBoolean = (this.prsQuestion.RecordTypeId == answerMgr.returnBooleanRecordTypeId()) ? true : false;

        visibleFieldSet = answerMgr.newClassInstance(this.prsQuestion.RecordTypeId).getFieldSet();
        possibleAnswerRecordTypeId = answerMgr.getAnswerRecordType(this.prsQuestion.RecordTypeId);

        hasAnswers = answerMgr.hasQuestionAnswer(this.prsQuestion.RecordTypeId);

        System.debug('Possible Answers:' + possibleAnswerRecordTypeId + '|' + hasAnswers);
        System.debug('INIT Possible Answer: FLAG_VISIBLE FIELDS' + visibleFieldSet);

        if (this.ACTION.equalsIgnoreCase(this.ACTION_EDIT)) {
            prsPossibleAnswer = new Map<Id, EUR_CRM_PRS_Question_Criteria__c>([SELECT Id,
                    RecordTypeId,
                    EUR_CRM_Criteria_Threshold_Currency__c,
                    EUR_CRM_Criteria_Threshold_Number__c,
                    EUR_CRM_Criteria_Picklist_Value__c,
                    EUR_CRM_Answer_Condition__c, EUR_CRM_PRS_Question__r.Id,
                    EUR_CRM_Criteria_Picklist_Label__c, EUR_CRM_Criteria_Weight__c
            FROM EUR_CRM_PRS_Question_Criteria__c
            WHERE EUR_CRM_PRS_Question__r.Id =: this.standardController.getId()]);
        }

        if (prsPossibleAnswer!=null && prsPossibleAnswer.size()>0) {
            this.isDisplayPRSPossibleAnswer = true;
            prsPossibleAnswerDisplay.addAll(prsPossibleAnswer.values());
        } else{
            if (isAnswerBoolean) {
                isAnswerBoolean = true;
                addPossibleAnswer('true', 'Yes');
                addPossibleAnswer('false', 'No');
            } else {
                addPossibleAnswer();
            }
        }
        isNumber = getIsNumber();
    }


    public void addPossibleAnswer(){
        // TODO: possibleAnswerRecordTypeId deprecated?
        System.debug('Before - Possible Answer Display: ' + prsPossibleAnswerDisplay);
        EUR_CRM_PRS_Question_Criteria__c newPossibleAnswer = new EUR_CRM_PRS_Question_Criteria__c();
        newPossibleAnswer.EUR_CRM_PRS_Question__c = this.prsQuestion.Id;

        prsPossibleAnswerDisplay.add(newPossibleAnswer);
        System.debug('After - Possible Answer Display: ' + prsPossibleAnswerDisplay);
    }

    public void addPossibleAnswer(String value, String label){
        System.debug('Before - Possible Answer Display: ' + prsPossibleAnswerDisplay);
        EUR_CRM_PRS_Question_Criteria__c newPossibleAnswer = new EUR_CRM_PRS_Question_Criteria__c();
        newPossibleAnswer.EUR_CRM_PRS_Question__c = this.prsQuestion.Id;
        newPossibleAnswer.EUR_CRM_Criteria_Picklist_Value__c = value;
        newPossibleAnswer.EUR_CRM_Criteria_Picklist_Label__c = label;

        prsPossibleAnswerDisplay.add(newPossibleAnswer);
        System.debug('After - Possible Answer Display: ' + prsPossibleAnswerDisplay);
    }

    public void deletePossibleAnswer(){
        String answerIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        Integer index = Integer.valueOf(answerIndex);

        System.debug('deletePossibleAnswer if exists:' + prsPossibleAnswerDisplay[index].Id);
        if(prsPossibleAnswer.containsKey(prsPossibleAnswerDisplay[index].Id))
        {
            deletePRSPossibleAnswer.add(prsPossibleAnswerDisplay[index]);
        }

        prsPossibleAnswerDisplay.remove(index);
    }

    public void changeAnswerType(){
        System.debug('changeAnswerType - record type:' + this.prsQuestion.RecordTypeId);

        initPRSPossibleAnswers();
    }

    public PageReference saveAnswer(){
        PageReference pageRef = null;
        Database.Deleteresult[] deleteResultAnswers;
        Database.Upsertresult[] upsertResultAnswers;
        Database.Upsertresult upsertResultAnswer;
        System.Savepoint pSavepoint = Database.setSavepoint();

        try{
            //Save Question
            upsertResultAnswer = Database.upsert(this.prsQuestion);
            //Save Possible Answer
            if(deletePRSPossibleAnswer.size()>0){
                deleteResultAnswers = Database.delete(deletePRSPossibleAnswer);
            }
            if (this.ACTION.equalsIgnoreCase(this.ACTION_NEW)){
                for(EUR_CRM_PRS_Question_Criteria__c answer: prsPossibleAnswerDisplay){
                    answer.EUR_CRM_PRS_Question__c = this.prsQuestion.Id;
                }
            }
            upsertResultAnswers = Database.upsert(prsPossibleAnswerDisplay);

            if(upsertResultAnswer.isSuccess()){
                pageRef = new PageReference('/' + this.prsQuestion.EUR_CRM_PRS_Question_Set__c);
            }
        } catch(Exception ex){
            Apexpages.addMessages(ex);
            pageRef = null;
            Database.rollback(pSavepoint);
//            String strError = '';
//            if(ex.getTypeName() == 'DMLException' && ex.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
//                String s = ex.getDmlMessage(0);
//                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());
//                addPageMessage(strError, ApexPages.Severity.INFO);
//            }
//            addPageMessage(strError, ApexPages.Severity.ERROR);
        }

        return pageRef;
    }

    public PageReference cancel() {
        parentURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+prsQuestion.EUR_CRM_PRS_Question_Set__c;
        Pagereference p = new PageReference(parentURL);
        return p;
    }

    public void addPageMessage(String strMessage, ApexPages.Severity severity) {
        ApexPages.Message infoMessage = new ApexPages.Message(severity, strMessage);
        ApexPages.addMessage(infoMessage);
    }

    public void updateCheckbox(){
    }

    private Boolean getIsNumber(){
        Boolean flag = false;
        for(SelectOption selOption: answerRecordTypes){
            system.debug('++' +  selOption.getValue() + ' ' +selOption.getLabel());
            if(selOption.getValue() == answerTypeId && (selOption.getLabel().contains('Number') || selOption.getLabel().contains('Integer'))){
                flag = true;
                break;
            }
            if(prsQuestion != null &&  selOption.getValue() == prsQuestion.RecordTypeId && (selOption.getLabel().contains('Number') || selOption.getLabel().contains('Integer'))){
                flag = true;
                break;
            }
        }
        system.debug('+++' + flag);

        return flag;
    }
}