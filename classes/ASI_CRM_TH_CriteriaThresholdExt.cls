/*********************************************************************************
 * Name: ASI_CRM_TH_CriteriaThresholdExt
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_CriteriaThresholdExt
*********************************************************************************/

public without sharing class ASI_CRM_TH_CriteriaThresholdExt {     
        private ApexPages.StandardController standardController;
        public  ASI_CRM_Criteria_Threshold__c  criteriaThreshold{get;set;}
        private ASI_CRM_TH_CriteriaManager criteriaMgr;
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
        public Map<Id,ASI_CRM_Criteria_Answer__c> criteriaAnswers {get;set;}
        public List<ASI_CRM_Criteria_Answer__c> criteriaAnswersDisplay {get;set;}
        public List<ASI_CRM_Criteria_Answer__c> deleteCriteriaAnswers{get;set;}
        public Integer rowIndex{get;set;}
        public List<String> visibleFieldSet{get;set;}
        public Map<String, String> visibleFieldLabelSet{get;set;}
        public Boolean isImage{get; set;}
        public Boolean isNumber {get;set;}
        public ASI_CRM_TH_CriteriaThresholdExt(ApexPages.StandardController standardController){       
            isImage = false;
            isNumber = true;
            this.standardController = standardController;
            this.criteriaMgr = new ASI_CRM_TH_CriteriaManager();
            String criSetId = ApexPages.currentPage().getParameters().get('setId');
                    
            if (this.standardController.getId() == null){
                this.ACTION = ACTION_NEW;
                Id criteriaSetId = ApexPages.currentPage().getParameters().get('setId');
                
                if (criteriaSetId != null){
                    this.criteriaThreshold = new ASI_CRM_Criteria_Threshold__c();
                    this.criteriaThreshold.ASI_CRM_SG_Criteria_Set__c = criteriaSetId;
                    this.criteriaThreshold.RecordTypeId = this.criteriaMgr.getDefaultRecordType();
                }
                else{
                    //TODO error page
                }
            }
            else if (this.standardController.getId() != null){
                this.ACTION = ACTION_EDIT;
                this.criteriaThreshold = (ASI_CRM_Criteria_Threshold__c)returnCriteriaThreshold();
            }
            
            System.debug('FLAG_CRITERIA THRESHOLD:' + criteriaThreshold);
            System.debug('FLAG_RECORDTYPE: ' + this.criteriaThreshold.RecordTypeId);
            
            this.isDisplayCriteriaAnswers = false;
            System.debug('Parent URL: ' + parentURL);
            //SET FIELD LABELS
            visibleFieldLabelSet = new Map<String, String>{'ASI_CRM_SG_Value__c'=>'Answer Value',
            'ASI_CRM_SG_Label__c'=>'Answer Label',
            'ASI_CRM_SG_Weight__c'=>'Weight',
            'ASI_CRM_SG_Condition__c'=>'Condition',
            'ASI_CRM_SG_Base_Integer__c'=>'Base Number',
            'ASI_CRM_SG_Base_Currency__c'=>'Base Currency'}; 
            
            //SET CRITERIA ANSWERS
            criteriaRecordTypes = this.criteriaMgr.getCriteriaRecordTypes();
            initCriteriaAnswers(); 
            System.debug('Flag - Record Type:' + this.criteriaThreshold.RecordTypeId);
                               
            ASI_CRM_Criteria_Set__c critSet = [select id, RecordType.Name, RecordType.Developername from ASI_CRM_Criteria_Set__c where id=:criteriaThreshold.ASI_CRM_SG_Criteria_Set__c];
            
            if(critSet != null && (critSet.RecordType.Name).contains('Image')){
                isImage = true;
            }
            isNumber = getIsNumber();                        
        }
        
    private ASI_CRM_Criteria_Threshold__c returnCriteriaThreshold(){
        ASI_CRM_Criteria_Threshold__c tempCriteriaThreshold = 
                                [SELECT Id, RecordTypeId,
                                ASI_CRM_SG_Criteria_Set__c, ASI_CRM_SG_Criteria_Set__r.RecordTypeId,
                                ASI_CRM_SG_Criteria_Type__c,
                                ASI_CRM_SG_Question__c, ASI_CRM_SG_Weight__c
                                FROM ASI_CRM_Criteria_Threshold__c 
                                WHERE Id=:this.standardController.getId()]; 
    
        return tempCriteriaThreshold;
    }
    private void initCriteriaThreshold(Id criteriaSetId, String criteriaSetType){
    }
    
    private void initCriteriaAnswers(){
        System.debug('Init Criteria Answers');
        criteriaAnswers = null;
        criteriaAnswersDisplay = new List<ASI_CRM_Criteria_Answer__c>();
        deleteCriteriaAnswers = new List<ASI_CRM_Criteria_Answer__c>();
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
            criteriaAnswers = new Map<Id, ASI_CRM_Criteria_Answer__c>([SELECT Id, 
                                                            RecordTypeId,
                                                            ASI_CRM_SG_Value__c, 
                                                            ASI_CRM_SG_Base_Currency__c, ASI_CRM_SG_Base_Integer__c,
                                                            ASI_CRM_SG_Condition__c, ASI_CRM_SG_Criteria_Threshold__r.Id,
                                                            ASI_CRM_SG_Label__c, ASI_CRM_SG_Weight__c
                                                            FROM ASI_CRM_Criteria_Answer__c 
                                                            WHERE ASI_CRM_SG_Criteria_Threshold__r.Id =: this.standardController.getId()]);
        system.debug('###criteriaAnswers:'+criteriaAnswers);
                        
        if (criteriaAnswers!=null && criteriaAnswers.size()>0){
            this.isDisplayCriteriaAnswers = true;
            criteriaAnswersDisplay.addAll(criteriaAnswers.values());
            system.debug('###1');
        }else{
            if (isCriteriaBoolean){
                isCriteriaBoolean = true;
                addCriteriaAnswer('true', 'Yes');
                addCriteriaAnswer('false', 'No');
                system.debug('###2');
            }
            else{
                addCriteriaAnswer();
                system.debug('###3');
            }
        }
        isNumber = getIsNumber();
    }   
    
    public void addCriteriaAnswer(){
        System.debug('Criteria Answer Record Type Id: ' + criteriaAnswerRecordTypeId);
        if (this.criteriaAnswerRecordTypeId != null){
            System.debug('Flag Before - Criteria Answer Display: ' + criteriaAnswersDisplay);
            ASI_CRM_Criteria_Answer__c newCriteriaAnswer = new ASI_CRM_Criteria_Answer__c();
            newCriteriaAnswer.RecordTypeId = this.criteriaAnswerRecordTypeId;
            newCriteriaAnswer.ASI_CRM_SG_Criteria_Threshold__c = this.criteriaThreshold.Id;
            
            criteriaAnswersDisplay.add(newCriteriaAnswer);
            System.debug('Flag After - Criteria Answer Display: ' + criteriaAnswersDisplay);
        }
    }
    
    public void addCriteriaAnswer(String value, String label){
        if (this.criteriaAnswerRecordTypeId != null){
            System.debug('Flag Before - Criteria Answer Display: ' + criteriaAnswersDisplay);
            ASI_CRM_Criteria_Answer__c newCriteriaAnswer = new ASI_CRM_Criteria_Answer__c();
            newCriteriaAnswer.RecordTypeId = this.criteriaAnswerRecordTypeId;
            newCriteriaAnswer.ASI_CRM_SG_Criteria_Threshold__c = this.criteriaThreshold.Id;
            newCriteriaAnswer.ASI_CRM_SG_Value__c = value;
            newCriteriaAnswer.ASI_CRM_SG_Label__c = label;
            
            criteriaAnswersDisplay.add(newCriteriaAnswer);
            System.debug('Flag After - Criteria Answer Display: ' + criteriaAnswersDisplay);
        }
    }
    
    public void deleteCriteriaAnswer(){
        String answerIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        Integer index = Integer.valueOf(answerIndex);
        
        System.debug('Flag - deleteCriteriaAnswer if exists:' + criteriaAnswersDisplay[index].Id);
        if(criteriaAnswers.containsKey(criteriaAnswersDisplay[index].Id)){
                deleteCriteriaAnswers.add(criteriaAnswersDisplay[index]);
        }
        
        criteriaAnswersDisplay.remove(index);
    }
    
    public void changeCriteriaType(){
        System.debug('changeCriteriaType - Flag record type:' + this.criteriaThreshold.RecordTypeId);       
        initCriteriaAnswers();                
    }
               
    public PageReference saveCriteria(){
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
                for(ASI_CRM_Criteria_Answer__c answer: criteriaAnswersDisplay){
                        answer.ASI_CRM_SG_Criteria_Threshold__c = this.criteriaThreshold.Id;
                }
            }
            upsertResultAnswers = Database.upsert(criteriaAnswersDisplay);

            if(upsertResultCriteria.isSuccess()){
                    pageRef = new PageReference('/' + this.criteriaThreshold.ASI_CRM_SG_Criteria_Set__c);
            }
        }
        catch(Exception ex){
            pageRef = null;
            Database.rollback(pSavepoint);      
            String strError = '';
            // Debug
            if(ex.getTypeName() == 'DMLException' && ex.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
            {
                String s = ex.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                addPageMessage(strError, ApexPages.Severity.INFO);
            }                   
            addPageMessage(strError, ApexPages.Severity.ERROR); 
        }
        return pageRef;
    }
    
    public PageReference cancel() {
        parentURL = URL.getSalesforceBaseUrl().toExternalForm()+'/'+criteriaThreshold.ASI_CRM_SG_Criteria_Set__c;
        Pagereference p = new PageReference(parentURL);
        return p;
    }    
    public void addPageMessage(String strMessage, ApexPages.Severity severity){
        ApexPages.Message infoMessage = new ApexPages.Message(severity, strMessage);
        ApexPages.addMessage(infoMessage);      
    }  
    
    public String state {get; set;}
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