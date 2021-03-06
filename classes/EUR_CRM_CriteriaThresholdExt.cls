public with sharing class EUR_CRM_CriteriaThresholdExt {
      
        private ApexPages.StandardController standardController;
        public  EUR_CRM_Criteria_Threshold__c  criteriaThreshold{get;set;}
        private EUR_CRM_CriteriaManager criteriaMgr;
        private final String ACTION_EDIT = 'EDIT';
        private final String ACTION_NEW = 'NEW';
        private final String ACTION;
        
        public Id criteriaAnswerRecordTypeId{get; set;}
        
        //CriteriaThreshold
        public boolean isCriteriaBoolean{get;set;}{isCriteriaBoolean=false;}
        public String parentURL {get; set;}
        //Criteria Answer
        public Id criteriaTypeId {get; set;}
        public Boolean hasAnswers{get; set;}
        public List<SelectOption> criteriaRecordTypes{get;set;} 
        public Boolean isDisplayCriteriaAnswers{get; set;}
        public Map<Id,EUR_CRM_Criteria_Answer__c> criteriaAnswers {get;set;}
        public List<EUR_CRM_Criteria_Answer__c> criteriaAnswersDisplay {get;set;}
        public List<EUR_CRM_Criteria_Answer__c> deleteCriteriaAnswers{get;set;}
        public Integer rowIndex{get;set;}
        public List<String> visibleFieldSet{get;set;}
        public Map<String, String> visibleFieldLabelSet{get;set;}
        public Boolean isImage{get; set;}
        public Boolean isNumber {get;set;}
        public Boolean isUKVol {get;set;}
        public EUR_CRM_CriteriaThresholdExt(ApexPages.StandardController standardController)
        {       isImage = false;
                isNumber = true;
                this.standardController = standardController;
                this.criteriaMgr = new EUR_CRM_CriteriaManager();
                //String action = ApexPages.currentPage().getParameters().get('action');
                String criSetId = ApexPages.currentPage().getParameters().get('setId');
                        
                        if (this.standardController.getId() == null){
                                this.ACTION = ACTION_NEW;
                                Id criteriaSetId = ApexPages.currentPage().getParameters().get('setId');
                                //String criteriaSetType = ApexPages.currentPage().getParameters().get('setType');
                                
                                if (criteriaSetId != null){
                                        this.criteriaThreshold = new EUR_CRM_Criteria_Threshold__c();
                                        this.criteriaThreshold.EUR_CRM_Criteria_Set__c = criteriaSetId;
                                        this.criteriaThreshold.RecordTypeId = this.criteriaMgr.getDefaultRecordType();
                                }
                                else{
                                        //TODO error page
                                }
                        }
                        else if (this.standardController.getId() != null){
                                this.ACTION = ACTION_EDIT;
                                this.criteriaThreshold = (EUR_CRM_Criteria_Threshold__c)returnCriteriaThreshold();
                        }
                        
                        System.debug('FLAG_CRITERIA THRESHOLD:' + criteriaThreshold);
                        System.debug('FLAG_RECORDTYPE: ' + this.criteriaThreshold.RecordTypeId);
                        
                        this.isDisplayCriteriaAnswers = false;
                        //parentURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+criSetId; 
                        //parentURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+this.standardController.getId(); 
                        System.debug('Parent URL: ' + parentURL);
                        //SET FIELD LABELS
                        visibleFieldLabelSet = new Map<String, String>{'EUR_CRM_Value__c'=>'Answer Value',
                        'EUR_CRM_Label__c'=>'Answer Label',
                        'EUR_CRM_Weight__c'=>'Weight',
                        'EUR_CRM_Condition__c'=>'Condition',
                        'EUR_CRM_Base_Integer__c'=>'Base Number',
                        'EUR_CRM_Base_Currency__c'=>'Base Currency'}; 
                        
                        //SET CRITERIA ANSWERS
                        criteriaRecordTypes = this.criteriaMgr.getCriteriaRecordTypes();
                        initCriteriaAnswers(); 
                        System.debug('Flag - Record Type:' + this.criteriaThreshold.RecordTypeId);
                                           
                        EUR_CRM_Criteria_Set__c critSet = [select id, RecordType.Name, RecordType.Developername from EUR_CRM_Criteria_Set__c where id=:criteriaThreshold.EUR_CRM_Criteria_Set__c];
                        
                        if(critSet != null && (critSet.RecordType.Name).contains('Image')){
                            isImage = true;
                        }
                        isNumber = getIsNumber();
                         
                        isUKVol= (critSet != null && (critSet.RecordType.Developername == 'EUR_GB_Volume_Potential_Criteria'));
        }
        
        private EUR_CRM_Criteria_Threshold__c returnCriteriaThreshold(){
                EUR_CRM_Criteria_Threshold__c tempCriteriaThreshold = 
                                    [SELECT Id, RecordTypeId,
                                    EUR_CRM_Criteria_Set__c, EUR_CRM_Criteria_Set__r.RecordTypeId,
                                    EUR_CRM_Criteria_Type__c,
                                    EUR_CRM_Question__c, EUR_CRM_Weight__c,
                                    EUR_CRM_Total_Spirits_Volume__c ,
                                    EUR_CRM_Total_Champagne_Volume__c,
                                    EUR_CRM_ActionPROS__c
                                    FROM EUR_CRM_Criteria_Threshold__c 
                                    WHERE Id=:this.standardController.getId()]; 
        
        return tempCriteriaThreshold;
        }
       private void initCriteriaThreshold(Id criteriaSetId, String criteriaSetType){
                //this.criteriaThreshold = new EUR_CRM_Criteria_Threshold__c();
                //this.criteriaThreshold.EUR_CRM_Criteria_Set__c = criteriaSetId;
                //this.criteriaThreshold
        }
        private void initCriteriaAnswers(){
                System.debug('Init Criteria Answers');
                criteriaAnswers = null;
                criteriaAnswersDisplay = new List<EUR_CRM_Criteria_Answer__c>();
                deleteCriteriaAnswers = new List<EUR_CRM_Criteria_Answer__c>();
                visibleFieldSet = new List<String>();
                isNumber = getIsNumber();
                System.debug('INIT CRITERIA ANSWERS: FLAG_RECORD TYPE:' + this.criteriaThreshold.RecordTypeId);
            isCriteriaBoolean = (this.criteriaThreshold.RecordTypeId == criteriaMgr.returnBooleanRecordTypeId())?true:false;
                
            visibleFieldSet = criteriaMgr.newClassInstance(this.criteriaThreshold.RecordTypeId).getFieldSet();
                criteriaAnswerRecordTypeId = criteriaMgr.getAnswerRecordType(this.criteriaThreshold.RecordTypeId);
                
                hasAnswers = criteriaMgr.hasCriteriaAnswer(this.criteriaThreshold.RecordTypeId);

                        System.debug('FLag - Criteria Answers:' + criteriaAnswerRecordTypeId + '|' + hasAnswers);
                System.debug('INIT CRITERIA ANSWERS: FLAG_VISIBLE FIELDS' + visibleFieldSet);
                
                if (this.ACTION.equalsIgnoreCase(this.ACTION_EDIT))
                    criteriaAnswers = new Map<Id, EUR_CRM_Criteria_Answer__c>([SELECT Id, 
                                                                    RecordTypeId,
                                                                    EUR_CRM_Value__c, 
                                                                    EUR_CRM_Base_Currency__c, EUR_CRM_Base_Integer__c,
                                                                    EUR_CRM_Condition__c, EUR_CRM_Criteria_Threshold__r.Id,
                                                                    EUR_CRM_Label__c, EUR_CRM_Weight__c
                                                                    FROM EUR_CRM_Criteria_Answer__c 
                                                                    WHERE EUR_CRM_Criteria_Threshold__r.Id =: this.standardController.getId()]);
                                
                if (criteriaAnswers!=null && criteriaAnswers.size()>0)
                {
                        this.isDisplayCriteriaAnswers = true;
                        criteriaAnswersDisplay.addAll(criteriaAnswers.values());
                }else{
                        if (isCriteriaBoolean){//(this.criteriaThreshold.RecordTypeId == criteriaMgr.returnBooleanRecordTypeId()){
                                isCriteriaBoolean = true;
                                addCriteriaAnswer('true', 'Yes');
                                addCriteriaAnswer('false', 'No');
                        }
                        else{
                                addCriteriaAnswer();
                        }
                }
                isNumber = getIsNumber();
        }
        
        
        public void addCriteriaAnswer(){
                if (this.criteriaAnswerRecordTypeId != null){
                    System.debug('Flag Before - Criteria Answer Display: ' + criteriaAnswersDisplay);
                    EUR_CRM_Criteria_Answer__c newCriteriaAnswer = new EUR_CRM_Criteria_Answer__c();
                    newCriteriaAnswer.RecordTypeId = this.criteriaAnswerRecordTypeId;
                    newCriteriaAnswer.EUR_CRM_Criteria_Threshold__c = this.criteriaThreshold.Id;
                    
                    criteriaAnswersDisplay.add(newCriteriaAnswer);
                    System.debug('Flag After - Criteria Answer Display: ' + criteriaAnswersDisplay);
                }//return null;
        }
        
        public void addCriteriaAnswer(String value, String label){
                if (this.criteriaAnswerRecordTypeId != null){
                    System.debug('Flag Before - Criteria Answer Display: ' + criteriaAnswersDisplay);
                    EUR_CRM_Criteria_Answer__c newCriteriaAnswer = new EUR_CRM_Criteria_Answer__c();
                    newCriteriaAnswer.RecordTypeId = this.criteriaAnswerRecordTypeId;
                    newCriteriaAnswer.EUR_CRM_Criteria_Threshold__c = this.criteriaThreshold.Id;
                    newCriteriaAnswer.EUR_CRM_Value__c = value;
                    newCriteriaAnswer.EUR_CRM_Label__c = label;
                    
                    criteriaAnswersDisplay.add(newCriteriaAnswer);
                    System.debug('Flag After - Criteria Answer Display: ' + criteriaAnswersDisplay);
                }//return null;
        }
        
        public void deleteCriteriaAnswer(){
                String answerIndex = ApexPages.currentPage().getParameters().get('rowIndex');
                Integer index = Integer.valueOf(answerIndex);
                
                System.debug('Flag - deleteCriteriaAnswer if exists:' + criteriaAnswersDisplay[index].Id);
                if(criteriaAnswers.containsKey(criteriaAnswersDisplay[index].Id))
                {
                        deleteCriteriaAnswers.add(criteriaAnswersDisplay[index]);
                }
                
                criteriaAnswersDisplay.remove(index);
                
                //return null;
        }
        
        public void changeCriteriaType(){
                System.debug('changeCriteriaType - Flag record type:' + this.criteriaThreshold.RecordTypeId);
                
                initCriteriaAnswers();
                
                //TODO set fieldset
        }
               
        public PageReference saveCriteria(){
            //Id criteriaID = ApexPages.currentPage().getParameters().get('criteriaID');
            PageReference pageRef = null;
            Database.Deleteresult[] deleteResultAnswers;
                Database.Upsertresult[] upsertResultAnswers;
                Database.Upsertresult upsertResultCriteria;
            System.Savepoint pSavepoint = Database.setSavepoint();
                
            try{
                    //Save Criteria Threshold
                    upsertResultCriteria = Database.upsert(this.criteriaThreshold);
                    //Save Criteria answers
                    if(deleteCriteriaAnswers.size()>0){
                        deleteResultAnswers = Database.delete(deleteCriteriaAnswers);
                    }
                    if (this.ACTION.equalsIgnoreCase(this.ACTION_NEW)){
                        for(EUR_CRM_Criteria_Answer__c answer: criteriaAnswersDisplay){
                                answer.EUR_CRM_Criteria_Threshold__c = this.criteriaThreshold.Id;
                        }
                    }
                    upsertResultAnswers = Database.upsert(criteriaAnswersDisplay);

                    if(upsertResultCriteria.isSuccess()){
                            pageRef = new PageReference('/' + this.criteriaThreshold.EUR_CRM_Criteria_Set__c);
                    }
            }
                catch(Exception ex){
                        pageRef = null;
            Database.rollback(pSavepoint);      
            String strError = '';
            // Debug
            // strError = ex.getMessage() + LINE_NUMBER + String.valueOf(ex.getLineNumber());
            if(ex.getTypeName().containsIgnoreCase('DMLException') && ex.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION)// || Test.isRunningTest())
            {
//                String s = ex.getDmlMessage(0);
//                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());
                addPageMessage(ex.getDmlMessage(0), ApexPages.Severity.INFO);
            }                   
            addPageMessage(ex.getDmlMessage(0), ApexPages.Severity.ERROR);
                }
                
                return pageRef;
    }
    
    public PageReference cancel() {
        parentURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+criteriaThreshold.EUR_CRM_Criteria_Set__c;
        Pagereference p = new PageReference(parentURL);
        return p;
    }    
    public void addPageMessage(String strMessage, ApexPages.Severity severity)
    {
        ApexPages.Message infoMessage = new ApexPages.Message(severity, strMessage);
        ApexPages.addMessage(infoMessage);      
    }  
    
    public String state {get; set;}
    public void updateCheckbox(){
        if(state == '1')
            criteriaThreshold.EUR_CRM_Total_Champagne_Volume__c = false;
        if(state == '2')
            criteriaThreshold.EUR_CRM_Total_Spirits_Volume__c = false;
    }
    private Boolean getIsNumber(){    
        Boolean flag = false;
        for(SelectOption selOption: criteriaRecordTypes){
            system.debug('++' +  selOption.getValue() + ' ' +selOption.getLabel());
            if(selOption.getValue() == criteriaTypeId && (selOption.getLabel().contains('Number') || selOption.getLabel().contains('Integer'))){
                flag = true;
                break;
            }  
            if(criteriaThreshold != null &&  selOption.getValue() == criteriaThreshold.RecordTypeId && (selOption.getLabel().contains('Number') || selOption.getLabel().contains('Integer'))){
                flag = true;
                break;
            }  
        }
            system.debug('+++' + flag);
        return flag;
    }
}