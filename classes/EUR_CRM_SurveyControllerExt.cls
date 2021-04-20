/**
SEPT.30.2014
 - Added filter for Germany Record Type
JUNE 29. 2015
-Added filter for Finland Record Type
 
*/
public with sharing class EUR_CRM_SurveyControllerExt {
    
    private static final Integer PAGE_SIZE = 100;
    private Integer pageNumber = 1;
    
    private Map<String,String> recordTypeMapping = EUR_CRM_RecordTypeHelper.SurveyControllerExt_recordTypeMapping;
    private Map<String,String> surveyHeaderRecordTypeMapping = EUR_CRM_RecordTypeHelper.SurveyControllerExt_surveyHeaderRecordTypeMapping;
    private Map<String,String> surveyQuestionRecordTypeMapping = EUR_CRM_RecordTypeHelper.SurveyControllerExt_surveyQuestionRecordTypeMapping;

    public with sharing class QuestionItem{
        public EUR_CRM_Question__c Question { get; set; }
        public Boolean IsSelected { get; set; }
        
        public QuestionItem(EUR_CRM_Question__c q, Boolean s){
            Question = q;
            IsSelected = s;
        }
    }
    
    public Apexpages.StandardSetController acctStandardSetCon { get; set; }
    public Apexpages.Standardsetcontroller questionStandardSetCon { get; set; }
    
    public EUR_CRM_Survey_Header__c surveyHeader { get; set; }
    
    public List<EUR_CRM_Survey_Question__c> surveyQuestions{
        get{
            if(surveyQuestions == null){
                surveyQuestions = new List<EUR_CRM_Survey_Question__c>();
            }
            return surveyQuestions;
        }set;
    }
    
    public Boolean isAllSelected { 
        get{
            if(isAllSelected == null)
                isAllSelected = false;
            return isAllSelected;
        }set; 
    }
    
    public List<QuestionItem> pageQuestionItems{
        get{
            if(pageQuestionItems == null)
                pageQuestionItems = new List<QuestionItem>();
            return pageQuestionItems;
        } set;
    }
    
    public EUR_CRM_SurveyControllerExt(Apexpages.StandardSetController stdSetCon){
        acctStandardSetCon = stdSetCon;
        initSurveyHeader();
        queryQuestionList();
        
        acctStandardSetCon.setFilterId(surveyHeader.EUR_CRM_Account_Filter_ID__c);
        acctStandardSetCon.getResultSize();
    }
    
    private void initSurveyHeader(){
        String syHeaderId = Apexpages.currentPage().getParameters().get('shid');
        List<EUR_CRM_Survey_Header__c> syHeaderList = [Select Name, EUR_CRM_Active__c, recordtype.developername, EUR_CRM_Account_Filter_ID__c, EUR_CRM_Description__c, EUR_CRM_Valid_From__c, EUR_CRM_Valid_Until__c, 
            (Select EUR_CRM_Question__c, EUR_CRM_Question__r.EUR_CRM_Question_Statement__c, EUR_CRM_Question__r.EUR_CRM_Question_Value_Type__c, EUR_CRM_Sequence__c From Survey_Questions__r ORDER BY EUR_CRM_Sequence__c LIMIT 1000)  
            From EUR_CRM_Survey_Header__c Where Id =: syHeaderId];
        if(syHeaderList.size() == 0){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, 'You have accessed the page from a wrong URL. Please contact your system admin.'));
        }else{
            surveyHeader = syHeaderList[0];
            if(syHeaderList[0].Survey_Questions__r.size() > 0)
                surveyQuestions = syHeaderList[0].Survey_Questions__r;
        }
    }
    
    private void initQuestionStdSetCon(){
        questionStandardSetCon.setPageNumber(pageNumber);
        questionStandardSetCon.setPageSize(PAGE_SIZE);
    }
    
    private void queryQuestionList(){
        String recordTypeFilter = recordTypeMapping.get(surveyHeader.recordtype.developername); 
        String q = 'Select Name, EUR_CRM_Question_Value_Type__c, EUR_CRM_Question_Statement__c, EUR_CRM_Number_of_Survey_Answers__c, EUR_CRM_Description__c From EUR_CRM_Question__c ';
        if(recordTypeFilter !=null){
           q += ' where recordtype.developername = \''+recordTypeFilter +'\' '; 
        }
         q += ' Order BY EUR_CRM_Question_Statement__c LIMIT 9000';
         system.debug('Query: '+q);
        /*
        questionStandardSetCon = new Apexpages.Standardsetcontroller(Database.getQueryLocator([Select Name, EUR_CRM_Question_Value_Type__c, 
            EUR_CRM_Question_Statement__c, EUR_CRM_Number_of_Survey_Answers__c, EUR_CRM_Description__c From EUR_CRM_Question__c Order BY EUR_CRM_Question_Statement__c  
            LIMIT 9000]));
        */ 
        questionStandardSetCon = new Apexpages.Standardsetcontroller(Database.getQueryLocator(q));
        initQuestionStdSetCon();
        getQuestionList();
    }
    
    private void getQuestionList(){
        pageQuestionItems.clear();
        for(Sobject s : questionStandardSetCon.getRecords()){
            EUR_CRM_Question__c q = (EUR_CRM_Question__c)s;
            QuestionItem item = new QuestionItem(q, false);
            pageQuestionItems.add(item);
        }
    }
    
    public Boolean hasNext{
        get{
            return questionStandardSetCon.getHasNext();
        } set;
    }
    
    public Boolean hasPrevious{
        get{
            return questionStandardSetCon.getHasPrevious();
        } set;
    }
    
    public void nextPage(){
        questionStandardSetCon.next();
        getQuestionList();
    }
    
    public void previousPage(){
        questionStandardSetCon.previous();
        getQuestionList();
    }
    
    public Set<Id> selectedQuestionIds { 
        get{
            if(selectedQuestionIds == null)
                selectedQuestionIds = new Set<Id>();
            return selectedQuestionIds;
        }set; 
    }
    
    public String contextItem { get; set; }
    
    public void getSelectedItems(){
        selectedQuestionIds.clear();
        for(QuestionItem item : pageQuestionItems){
            if(item.IsSelected)
                selectedQuestionIds.add(item.Question.Id);
        }
    }
    
    public void selectAllItems(){
        for(QuestionItem item : pageQuestionItems){
            if(isAllSelected){
                item.IsSelected = true;
                selectedQuestionIds.add(item.Question.Id);
            }else{
                item.IsSelected = false;
                selectedQuestionIds.remove(item.Question.id);
            }
        }
    }
    
    public void doSelectItem(){
        selectedQuestionIds.add(contextItem);
        System.debug('Selected questions: ' + selectedQuestionIds);
    }
    
    public void doDeselectItem(){
        selectedQuestionIds.remove(contextItem);
        System.debug('Selected questions: ' + selectedQuestionIds);
    }
    
    public void addSurveyQuestions(){
        try{
            List<EUR_CRM_Survey_Question__c> syqlist = new List<EUR_CRM_Survey_Question__c>();
            Integer ctrSeq = 0;

            String devName = surveyQuestionRecordTypeMapping.get(surveyHeader.recordtype.developername);
            List<RecordType> rt = [select id from recordtype where sobjecttype = 'EUR_CRM_Survey_Question__c' and developername =:devName];
            Id recordTypeId = null;
            if(rt != null && rt.size() >0 )  
                recordTypeId = rt.get(0).id;
            for(EUR_CRM_Question__c q : [Select Id From EUR_CRM_Question__c Where Id in: selectedQuestionIds]){
                EUR_CRM_Survey_Question__c syq = new EUR_CRM_Survey_Question__c(EUR_CRM_Question__c = q.Id, 
                                                                                EUR_CRM_Survey_Header__c = surveyHeader.Id,
                                                                                EUR_CRM_Sequence__c = ctrSeq);
                
                if(recordTypeId != null)
                    syq.recordTypeId = recordTypeId;

                syqlist.add(syq);
                ctrSeq++;
            }
            
            if(syqlist.size() > 0){
                Integer ctrSeqOld = syqlist.size();
                List<EUR_CRM_Survey_Question__c> questionToUpdateSeq = new List<EUR_CRM_Survey_Question__c>();
                for(EUR_CRM_Survey_Question__c sq :[Select EUR_CRM_Question__c, EUR_CRM_Question__r.EUR_CRM_Question_Statement__c,
                                                    EUR_CRM_Question__r.EUR_CRM_Question_Value_Type__c, EUR_CRM_Sequence__c 
                                                    From EUR_CRM_Survey_Question__c 
                                                    Where EUR_CRM_Survey_Header__c =: surveyHeader.Id 
                                                    ORDER BY EUR_CRM_Sequence__c LIMIT 1000]){
                    
                    sq.EUR_CRM_Sequence__c = ctrSeqOld;
                    questionToUpdateSeq.add(sq);
                    ctrSeqOld++;
                }
                insert syqlist;
                update questionToUpdateSeq;
                querySurveyQuestions();
            }
            resetCheckboxes();
        }catch(Exception ex){
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
        
    }
    
    private void resetCheckboxes(){
        isAllSelected = false;
        for(QuestionItem item : pageQuestionItems){
            item.IsSelected = false;
        }
        selectedQuestionIds.clear();
    }

    public void removeSurveyQuestion(){
        System.Savepoint sp = Database.setSavepoint();
        try{
            String rowIndex = Apexpages.currentPage().getParameters().get('rowIndex');
            Integer index = Integer.valueOf(rowIndex);
            EUR_CRM_Question__c q = [Select Name, EUR_CRM_Question_Value_Type__c, 
                EUR_CRM_Question_Statement__c, EUR_CRM_Number_of_Survey_Answers__c, EUR_CRM_Description__c From EUR_CRM_Question__c Where Id =: surveyQuestions[index].EUR_CRM_Question__c];
            QuestionItem item = new QuestionItem(q, false);
            delete surveyQuestions[index];
            surveyQuestions.remove(index);
            
            Integer ctrSeqOld = 0;
            List<EUR_CRM_Survey_Question__c> questionToUpdateSeq = new List<EUR_CRM_Survey_Question__c>();
            for(EUR_CRM_Survey_Question__c sq :[Select EUR_CRM_Question__c, EUR_CRM_Question__r.EUR_CRM_Question_Statement__c,
                                                EUR_CRM_Question__r.EUR_CRM_Question_Value_Type__c, EUR_CRM_Sequence__c 
                                                From EUR_CRM_Survey_Question__c 
                                                Where EUR_CRM_Survey_Header__c =: surveyHeader.Id 
                                                ORDER BY EUR_CRM_Sequence__c LIMIT 1000]){
                
                sq.EUR_CRM_Sequence__c = ctrSeqOld;
                questionToUpdateSeq.add(sq);
                ctrSeqOld++;
            }
            if(questionToUpdateSeq.size() > 0){
                update questionToUpdateSeq;
            }
        }catch(Exception ex){
            if(ex.getTypeName() == 'DMLException' || Test.isRunningTest()){
                Database.rollback(sp);
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, ex.getDMLMessage(0)));
            }
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
    }
    
    private void querySurveyQuestions(){
        surveyQuestions = [Select EUR_CRM_Question__c, EUR_CRM_Question__r.EUR_CRM_Question_Statement__c,
             EUR_CRM_Question__r.EUR_CRM_Question_Value_Type__c, EUR_CRM_Sequence__c 
             From EUR_CRM_Survey_Question__c Where EUR_CRM_Survey_Header__c =: surveyHeader.Id ORDER BY EUR_CRM_Sequence__c LIMIT 1000];
    }
    
    public void updateOutletFilter(){
        acctStandardSetCon.setFilterId(surveyHeader.EUR_CRM_Account_Filter_ID__c);
        system.debug('filter id: ' + surveyHeader.EUR_CRM_Account_Filter_ID__c);
        system.debug('filter id: ' + acctStandardSetCon.getFilterId());
        system.debug('standard set controller count after filter: '+acctStandardSetCon.getResultSize());
    }

    public void publishSurvey(){
        System.Savepoint sp = Database.setSavepoint();
        try{
            String devName = surveyHeaderRecordTypeMapping.get(surveyHeader.recordtype.developername);
            RecordType rt = [select id from recordtype where sobjecttype = 'EUR_CRM_Survey__c' and developername =:devName];
            Id recordTypeId = null;
            if(rt != null)  
                recordTypeId = rt.id;

            system.debug('filter id: ' + surveyHeader.EUR_CRM_Account_Filter_ID__c);
            system.debug('filter id: ' + acctStandardSetCon.getFilterId());
            system.debug('standard set controller count after filter: '+acctStandardSetCon.getResultSize());
            
            //create survey to link survey header and account
            EUR_CRM_ListViewFilter filter = new EUR_CRM_ListViewFilter(acctStandardSetCon);
            List<EUR_CRM_Account__c> filteredAcctList = Test.isRunningTest() ? EUR_CRM_FilteredMassChatterCtrllerTest.acctlist : filter.getEURAccountListByFilter();
            
            List<EUR_CRM_Survey__c> surveylist = new List<EUR_CRM_Survey__c>();
            for(EUR_CRM_Account__c a : filteredAcctList){
                EUR_CRM_Survey__c sy = new EUR_CRM_Survey__c(EUR_CRM_Account__c = a.Id, EUR_CRM_Survey_Header__c = surveyHeader.Id);
                if(recordTypeId != null)
                    sy.recordTypeId = recordTypeId;
                surveylist.add(sy);
            }

            if(surveylist.size() > 0)
                insert surveylist;
                
            //update active
            surveyHeader.EUR_CRM_Active__c = true;
            update surveyHeader;
            
        }catch(Exception ex){
            if(ex.getTypeName() == 'DMLException'){
                Database.rollback(sp);
                Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, ex.getDMLMessage(0)));
            }
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
    }
}