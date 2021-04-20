/**
2017.JAN.03
Handle account filter for DE
**/

public with sharing class EUR_CRM_DE_SurveyControllerExt {
    
    public static Map<String,String> SurveyAccountFilteringMethod= New Map<String,String>{
    	'EUR_DE_OFF_Trade_Survey_Header' => 'CUST',
    	'EUR_DE_ON_Trade_Survey_Header' => 'PROS',
    	'EUR_DE_WS_Survey_Header' => 'CUST'
    };

    public static Map<string,String> SurveyAccountRtMapping = New Map<String,String>{
    	'EUR_DE_OFF_Trade_Survey_Header' => '\'EUR_DE_OFF_STD\'',
    	'EUR_DE_ON_Trade_Survey_Header' => '\'EUR_DE_ON_Consumers\',\'EUR_DE_ON_Enquiry_Acquisition\',\'EUR_DE_ON_Gastronomy\',\'EUR_DE_ON_Service_agency\'',
    	'EUR_DE_WS_Survey_Header' => '\'EUR_DE_ON_Wholesaler\''
    };

    public static Map<String,String> SurveyHeaderCustTax_FilterMap = New Map <String, String> {
        'EUR_DE_OFF_Trade_Survey_Header' => 'EUR_DE_Customer_Taxonomy',
        'EUR_DE_WS_Survey_Header' => 'EUR_DE_WS_Customer_Taxonomy'
    };

    public with sharing class QuestionItem{
        public EUR_CRM_Question__c Question { get; set; }
        public Boolean IsSelected { get; set; }
        
        public QuestionItem(EUR_CRM_Question__c q, Boolean s){
            Question = q;
            IsSelected = s;
        }
    }

	public List<EUR_CRM_Account__c> filteredAcctList {get;set;}

    private static final Integer PAGE_SIZE = 100;
    private Integer pageNumber = 1;

    //public Integer PageAccountCount {get;set;}
    //public Boolean PROSFilter {get;set;}
    //public Boolean CustFilter {get;set;}
    //public Boolean AccountSelected {get;set;}

    //Front Eend Value
    //public String filterOpValue {get;set;} //listView / prosSeg / custTax
    //public String targetCustTax {get;set;}

    private Map<String,String> recordTypeMapping = EUR_CRM_RecordTypeHelper.SurveyControllerExt_recordTypeMapping;
    private Map<String,String> surveyHeaderRecordTypeMapping = EUR_CRM_RecordTypeHelper.SurveyControllerExt_surveyHeaderRecordTypeMapping;
    private Map<String,String> surveyQuestionRecordTypeMapping = EUR_CRM_RecordTypeHelper.SurveyControllerExt_surveyQuestionRecordTypeMapping;
    
    //public Apexpages.StandardSetController acctStandardSetCon { get; set; }
    public Apexpages.Standardsetcontroller questionStandardSetCon { get; set; }
    //public Apexpages.Standardsetcontroller accFilterSetCon {get;set;}
    
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
    
    public EUR_CRM_DE_SurveyControllerExt(Apexpages.StandardSetController stdSetCon){
    	//targetCustTax = 'EUR_DE_Customer_Taxonomy';
    	//AccountSelected = false;

    	//filterOpValue = 'listView';
        
        initSurveyHeader();

        //targetCustTax = SurveyHeaderCustTax_FilterMap.get(surveyHeader.recordtype.developername);

        queryQuestionList();
        
        /*If (SurveyAccountFilteringMethod.Get(SurveyHeader.RecordType.DeveloperName) == 'PROS')
        {    PROSFilter = True;
    		CustFilter = False;}
        Else If (SurveyAccountFilteringMethod.Get(SurveyHeader.RecordType.DeveloperName) == 'CUST')
        {    PROSFilter = False;
    		 CustFilter = True;}
        Else
        {	PROSFilter = False;
    		CustFilter = False;}

    	if(surveyHeader.EUR_CRM_Account_Filter_ID__c != null)	{
    		filterOpValue='listView';
    	} 
    	else if (surveyHeader.EUR_CRM_Account_Filter_CustTax_Chain__c != null) {
    		filterOpValue='custTax';
    		//ToDo: Fill Selection Back
    	}
    	else if (surveyHeader.EUR_CRM_Account_Filter_PROS__c != null) {
    		filterOpValue='prosSeg';
    		//ToDo: Check Selected
    	}

        acctStandardSetCon = stdSetCon;
        acctStandardSetCon.setFilterId(surveyHeader.EUR_CRM_Account_Filter_ID__c);
        acctStandardSetCon.getResultSize();

        if (SurveyHeader.EUR_CRM_Active__c)
        {
        	updateFilterOption();
        }*/
    }
    
    private void initSurveyHeader(){
        String syHeaderId = Apexpages.currentPage().getParameters().get('shid');
        List<EUR_CRM_Survey_Header__c> syHeaderList = 
        [Select Name, EUR_CRM_Active__c, recordtype.developername, EUR_CRM_Account_Filter_ID__c,
        EUR_CRM_Account_Filter_CustTax_Chain__c,EUR_CRM_Account_Filter_CustTax_Level_1__c,
        EUR_CRM_Account_Filter_CustTax_Level_2__c,EUR_CRM_Account_Filter_CustTax_Level_3__c,
        EUR_CRM_Account_Filter_CustTax_Level_4__c,EUR_CRM_Account_Filter_CustTax_Level_5__c,
        EUR_CRM_Account_Filter_CustTax_Level_6__c,EUR_CRM_Account_Filter_CustTax_Level_7__c,
        EUR_CRM_Account_Filter_CustTax_Level_8__c, 
        EUR_CRM_Account_Filter_PROS__c,
        EUR_CRM_Description__c, 
        EUR_CRM_Valid_From__c, EUR_CRM_Valid_Until__c, 
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
    
    

    public Boolean hasNextQuestionPage{
        get{
            return questionStandardSetCon.getHasNext();
        } set;
    }
    
    public Boolean hasPreviousQuestionPage{
        get{
            return questionStandardSetCon.getHasPrevious();
        } set;
    }
    
    public void nextQuestionPage(){
        questionStandardSetCon.next();
        getQuestionList();
    }
    
    public void previousQuestionPage(){
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
    
    public void getSelectedQuestions(){
        selectedQuestionIds.clear();
        for(QuestionItem item : pageQuestionItems){
            if(item.IsSelected)
                selectedQuestionIds.add(item.Question.Id);
        }
    }
    
    public void selectAllQuestions(){
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
    
    public void doSelectQuestion(){
        System.debug('@@@doSelectQuestion');
        selectedQuestionIds.add(contextItem);
        System.debug('@@@EUR_CRM_DE_SurveyControllerExt:Selected questions: ' + selectedQuestionIds);
    }
    
    public void doDeselectQuestion(){
        System.debug('@@@doDeselectionQuestion');
        selectedQuestionIds.remove(contextItem);
        System.debug('@@@EUR_CRM_DE_SurveyControllerExt:Selected questions: ' + selectedQuestionIds);
    }
    
    public void addSurveyQuestions(){
        System.Debug('@@@addSurveyQuestions:' + selectedQuestionIds);
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
            System.Debug('@@@syqlist' + syqlist);
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
    
    /*public void updateOutletFilter(){
        acctStandardSetCon.setFilterId(surveyHeader.EUR_CRM_Account_Filter_ID__c);
        system.debug('filter id: ' + surveyHeader.EUR_CRM_Account_Filter_ID__c);
        system.debug('filter id: ' + acctStandardSetCon.getFilterId());
        system.debug('standard set controller count after filter: '+acctStandardSetCon.getResultSize());
    }

    public void updateFilterOption(){
		System.Debug('@@@EUR_DE_SurveyController:updateFilterOption:' + filterOpValue + ':' + surveyHeader);

    	if(filterOpValue=='listView')	{
    		updateAccountSelectionByListView();
    	} 
    	else if (filterOpValue=='custTax') {
    		initSurveyHeader();
    		updateAccountSelectionByCustTax();
    	}
    	else if (filterOpValue=='prosSeg') {
    		initSurveyHeader();
    		updateAccountSelectionByPROS();
    	}
    	else {
    		Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Error, 'Filter Not Set.'));    	
    	}
    }

    public void updateAccountSelectionByPROS(){
    	System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByPROS:');
    	String PROSFilter = surveyHeader.EUR_CRM_Account_Filter_PROS__c; 
		String AccRt = SurveyAccountRtMapping.get(SurveyHeader.recordtype.DeveloperName);
    	String query = 'SELECT Id,Name FROM EUR_CRM_Account__c WHERE RecordType.DeveloperName In (' + AccRt + ') AND (' +  PROSFilter + ') Limit 1000';
    	System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByPROS:AccQuery:' + query);
	    filteredAcctList =  (List<EUR_CRM_Account__c>)Database.query(query);
	    System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByPROS:' + filteredAcctList);

		if (filteredAcctList.size() > 0){
        	AccountSelected = True;
	    	accFilterSetCon = new ApexPages.StandardSetController(filteredAcctList);
        }else {
        	AccountSelected = False;
        }
        System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByPROS:AccountSelected:' + AccountSelected);
    }

    public void updateAccountSelectionByCustTax(){
    	System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByCustTax:');
    	//TODO: Get Result From Component!!!
    	String rtInCause;

        List<RecordType> CtRt = [SELECT ID,DeveloperName FROM RecordType WHERE SObjectType = 'EUR_CRM_Customer_Taxonomy__c' and DeveloperName =: targetCustTax];
        String ALL = 'All *';
    	if(CtRt.Size() > 0)
    	{
	    	rtInCause = '(';
	    	for(RecordType rt : CtRt)
	    	{rtInCause = rtInCause + '\'' + rt.Id + '\',';}
	    	rtInCause = rtInCause.removeEnd(',');
	    	rtInCause = rtInCause + ') ';
    	}
    
    	String chainValue = surveyHeader.EUR_CRM_Account_Filter_CustTax_Chain__c; 
    	String level1Value= surveyHeader.EUR_CRM_Account_Filter_CustTax_Level_1__c;
    	String level2value= surveyHeader.EUR_CRM_Account_Filter_CustTax_Level_2__c;
    	String level3value= surveyHeader.EUR_CRM_Account_Filter_CustTax_Level_3__c;
    	String level4value= surveyHeader.EUR_CRM_Account_Filter_CustTax_Level_4__c;
    	String level5value= surveyHeader.EUR_CRM_Account_Filter_CustTax_Level_5__c;
    	String level6value= surveyHeader.EUR_CRM_Account_Filter_CustTax_Level_6__c;
    	String level7value= surveyHeader.EUR_CRM_Account_Filter_CustTax_Level_7__c;
    	String level8value= surveyHeader.EUR_CRM_Account_Filter_CustTax_Level_8__c;

        String query1 = 'select id,Name,recordtypeid from EUR_CRM_Customer_Taxonomy__c where recordtypeid in ' + rtInCause;
        if(chainValue !=null && chainValue != ALL){
            query1 += ' AND EUR_CRM_Chain__c = \''+ String.escapeSingleQuotes(chainValue) +'\'';}
            
        if(level1Value !=null && level1Value != ALL){
            query1 += ' AND EUR_CRM_Level_1__c = \''+ String.escapeSingleQuotes(level1Value)  +'\'';}
        
        if(level2value !=null && level2Value != ALL){
            query1 += ' AND EUR_CRM_Level_2__c = \''+ String.escapeSingleQuotes(level2Value) +'\'';}
        
        if(level3value !=null && level3Value != ALL){
            query1 += ' AND EUR_CRM_Level_3__c = \''+ String.escapeSingleQuotes(level3Value) +'\'';}
        
        if(level4value !=null && level4Value != ALL){
            query1 += ' AND EUR_CRM_Level_4__c = \''+ String.escapeSingleQuotes(level4Value) +'\'';}
        
        if(level5value !=null && level5Value != ALL){
            query1 += ' AND EUR_CRM_Level_5__c = \''+ String.escapeSingleQuotes(level5Value) +'\'';}
        
        if(level6value !=null && level6Value != ALL){
            query1 += ' AND EUR_CRM_Level_6__c = \''+ String.escapeSingleQuotes(level6Value) +'\'';}
        
        if(level7value !=null && level7Value != ALL){
            query1 += ' AND EUR_CRM_Level_7__c = \''+ String.escapeSingleQuotes(level7Value) +'\'';}
        
        if(level8value !=null && level8Value != ALL){
            query1 += ' AND EUR_CRM_Level_8__c = \''+ String.escapeSingleQuotes(level8Value) +'\'';}

        //if(managementTypeValue !=null && managementTypeValue != Label.EUR_CRM_Regie_and_Independent)
        //    query1 += ' AND EUR_CRM_Management_Type__c = \''+ managementTypeValue+'\'';        
        //query1 += ' limit 1000';
        system.debug('$$$ ' +  query1);
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList;
        customerTaxonomyList = (List<EUR_CRM_Customer_Taxonomy__c>)Database.query(query1);
        String CTListStr= '';

        for(EUR_CRM_Customer_Taxonomy__c ct : customerTaxonomyList)
        {
        	CTListStr = CTListStr + '\'' + ct.id + '\','; 
        }

        CTListStr = CTListStr.removeEnd(',');

        System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByCustTax:query1:' + query1);
        String AccRt = SurveyAccountRtMapping.get(SurveyHeader.recordtype.DeveloperName);
        
        //filteredAcctList = [SELECT id,Name FROM EUR_CRM_Account__c WHERE RecordType.DeveloperName In : AccRt AND EUR_JB_Customer_Taxonomy__c in :customerTaxonomyList Limit 1000];

        String AccQuery = 'SELECT id,Name FROM EUR_CRM_Account__c WHERE RecordType.DeveloperName In (' + AccRt + ') AND EUR_JB_Customer_Taxonomy__c in (' + CTListStr + ') Limit 1000';
        system.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByCustTax:AccQuery:' + AccQuery);
        filteredAcctList = (List<EUR_CRM_Account__c>)Database.query(AccQuery);

        System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByCustTax:AccountListSize:' + filteredAcctList.size());

        //Account Wrapper Test
        if (filteredAcctList.size() > 0){
        	AccountSelected = True;
	    	accFilterSetCon = new ApexPages.StandardSetController(filteredAcctList);
        }else {
        	AccountSelected = False;
        }
        System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByCustTax:AccountSelected:' + AccountSelected);
        //accCon = new ApexPages.StandardSetController(filteredAcctList);
    }

    public void updateAccountSelectionByListView(){
		//surveyHeader.EUR_CRM_Account_Filter_ID__c = 

        system.debug('filter id: ' + surveyHeader.EUR_CRM_Account_Filter_ID__c);
        system.debug('filter id: ' + acctStandardSetCon.getFilterId());
        system.debug('standard set controller count after filter: '+acctStandardSetCon.getResultSize());
        
        //create survey to link survey header and account
        EUR_CRM_ListViewFilter filter = new EUR_CRM_ListViewFilter(acctStandardSetCon);
        List<EUR_CRM_Account__c> filterAcctList = Test.isRunningTest() ? EUR_CRM_FilteredMassChatterCtrllerTest.acctlist : filter.getEURAccountListByFilter();

        Set<id> AccIdList = New Set<id>();
        String AccIdStr = '';
        for(EUR_CRM_Account__c Ac : filterAcctList)
        {
        	AccIdStr = AccIdStr + '\'' + Ac.id + '\','; 
        }
        AccIdStr = AccIdStr.removeEnd(',');
 
        System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByListView:filterAcctList' + AccIdStr);
        String AccRt = SurveyAccountRtMapping.get(SurveyHeader.recordtype.DeveloperName);
        system.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByListView:AccRt:' + AccRt);

    	//filteredAcctList = [select ID,Name FROM EUR_CRM_Account__c WHERE RecordType.DeveloperName =: AccRt AND  id in : AccIdList];
		String AccQuery = 'SELECT id,Name FROM EUR_CRM_Account__c WHERE RecordType.DeveloperName In (' + AccRt + ') AND Id in (' + AccIdStr + ') Limit 1000';
		system.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByListView:AccQuery:' + AccQuery);
        filteredAcctList = (List<EUR_CRM_Account__c>)Database.query(AccQuery);


        System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByListView:AccountListSize:' + filteredAcctList.size());
    	//accCon = new ApexPages.StandardSetController(filteredAcctList);

    	if (filteredAcctList.size() > 0){
        	AccountSelected = True;
	    	accFilterSetCon = new ApexPages.StandardSetController(filteredAcctList);
        }else {
        	AccountSelected = False;
        }
        System.Debug('@@@EUR_DE_SurveyController:updateAccountSelectionByListView:AccountSelected:' + AccountSelected);
    }*/

    /*public void publishSurvey(){
    	System.Debug('@@@Publish Survey:filteredAcctList:' + filteredAcctList);
        System.Savepoint sp = Database.setSavepoint();
        try{
		    String devName = surveyHeaderRecordTypeMapping.get(surveyHeader.recordtype.developername);
	        RecordType rt = [select id from recordtype where sobjecttype = 'EUR_CRM_Survey__c' and developername =:devName];
	        Id recordTypeId = null;
	        if(rt != null)  
	            recordTypeId = rt.id;
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

    public Boolean isAllAccSelected { 
        get{
            if(isAllSelected == null)
                isAllSelected = false;
            return isAllSelected;
        }set; 
    }*/

    //@TestVisible Set<Id> selectedAccounts = new Set<Id>();
    //@TestVisible Set<Id> deselectedAccounts = new Set<Id>();
/*
    public class euAccountsWrapper {
        public Boolean isSelected {get;set;}
        public EUR_CRM_Account__c euAccount {get;set;}

        public euAccountsWrapper(EUR_CRM_Account__c euAccount, Boolean isSelected){
            this.euAccount = euAccount;
            this.isSelected = isSelected;
        }
    }

    public List<euAccountsWrapper> dummyWrapperList{get;set;}

    public List<euAccountsWrapper> getWrapAccounts(){   

        List<euAccountsWrapper> wrapAccounts = new List<euAccountsWrapper>();
        dummyWrapperList = NEw List<euAccountsWrapper> ();

		try{
			for(EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>)accFilterSetCon.getRecords()){
				System.debug('@@@EUR_CRM_DE_SurveyControllerExt:1');
	            if(!deselectedAccounts.contains(acc.Id))
	            this.selectedAccounts.add(acc.Id);
	        }

	        for(sObject r : this.accFilterSetCon.getRecords()){
	        	System.debug('@@@EUR_CRM_DE_SurveyControllerExt:2');
	            EUR_CRM_Account__c  a = (EUR_CRM_Account__c)r;
	      
	            euAccountsWrapper wrapAccount = new euAccountsWrapper(a,false);
	            if(this.selectedAccounts.contains(a.Id)){
	            	System.debug('@@@EUR_CRM_DE_SurveyControllerExt:3');
	                wrapAccount.IsSelected=true;
	            } else {
	            	System.debug('@@@EUR_CRM_DE_SurveyControllerExt:4');
	              	wrapAccount.IsSelected=false;
	            }
	            wrapAccounts.add(wrapAccount);   
	            dummyWrapperList.add(wrapAccount);               
	        }
		}catch(Exception e)
		{
			System.debug('@@@EUR_CRM_DE_SurveyControllerExt:getWrapAccounts:Exception:' + e.getMessage());
		}
        
        
        System.debug('@@@EUR_CRM_DE_SurveyControllerExt:getWrapAccounts:' + wrapAccounts);
        return wrapAccounts;
    }

  */
}