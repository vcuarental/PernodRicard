public with sharing class EUR_CRM_AnswerManager {
	private List<RecordType> questionsRecordTypes{get;set;}
	private Map<Id, String> questionsTypeMap{get;set;}
	private Map<Id, RecordType> questionsRecordTypeMap{get;set;}
	private Map<String, RecordType> possibleAnswerRecordTypeMap{get;set;}
	
	private RecordType booleanRecordType{get;set;}
	
	private final String BOOLEAN_QUESTIONS = 'EUR_CRM_AnswerFactory.BooleanQuestions';
	private final String INTEGERINPUT_QUESTIONS = 'EUR_CRM_AnswerFactory.IntegerInputQuestions';
	private final String CURRENCYINPUT_QUESTIONS = 'EUR_CRM_AnswerFactory.CurrencyInputQuestions';
	private final String PICKLIST_QUESTIONS = 'EUR_CRM_AnswerFactory.PicklistQuestions';
	private final String TEXTINPUT_QUESTIONS = 'EUR_CRM_AnswerFactory.TextInputQuestions';
	
	//List of Questions thresholds without weight calculation
	private Set<Id> noAnswerQuestions{get;set;}
	
	public EUR_CRM_AnswerManager(String countryCode){
		String BOOLEAN_QUESTIONS_DEVNAME = 'EUR_' + countryCode + '_PRS_Question_Boolean_Input';
		String INTEGERINPUT_QUESTIONS_DEVNAME = 'EUR_' + countryCode + '_PRS_Question_Number_Input';
		String CURRENCYINPUT_QUESTIONS_DEVNAME = 'EUR_' + countryCode + '_PRS_Question_Currency_Input';
		String PICKLIST_QUESTIONS_DEVNAME = 'EUR_' + countryCode + '_PRS_Question_Picklist_Input';
		String TEXTINPUT_QUESTIONS_DEVNAME = 'EUR_' + countryCode + '_PRS_Question_Text_Input';

	    //Instantiate Questions record type maps and no answer set
	    noAnswerQuestions = new Set<Id>();
	    questionsTypeMap = new Map<Id, String> ();
	    questionsRecordTypeMap = new Map<Id, RecordType>();
	    
	    questionsRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_PRS_Question__c');

	    for(RecordType recordType : questionsRecordTypes){
	        //Questions Type Map: Key-Record Type ID, Value:Factory class name
	        if (recordType.DeveloperName.equalsIgnoreCase(BOOLEAN_QUESTIONS_DEVNAME)){
	            questionsTypeMap.put(recordType.Id,BOOLEAN_QUESTIONS);
	            booleanRecordType = recordType;
	        }
	        else if (recordType.DeveloperName.equalsIgnoreCase(INTEGERINPUT_QUESTIONS_DEVNAME)) questionsTypeMap.put(recordType.Id,INTEGERINPUT_QUESTIONS);
	        else if (recordType.DeveloperName.equalsIgnoreCase(CURRENCYINPUT_QUESTIONS_DEVNAME)) questionsTypeMap.put(recordType.Id,CURRENCYINPUT_QUESTIONS);
	        else if (recordType.DeveloperName.equalsIgnoreCase(PICKLIST_QUESTIONS_DEVNAME)) questionsTypeMap.put(recordType.Id,PICKLIST_QUESTIONS);
	        else if (recordType.DeveloperName.equalsIgnoreCase(TEXTINPUT_QUESTIONS_DEVNAME)) {
	            questionsTypeMap.put(recordType.Id,TEXTINPUT_QUESTIONS);
	            noAnswerQuestions.add(recordType.Id);
	        }
	        
	        //Questions Record Type Map: Key-Record Type ID, Value:Record Type Instance
	        questionsRecordTypeMap.put(recordType.Id, recordType);
	    }
	    //Instantiate answer record type map
	    //Questions Answer Record Type: Key-Developer Name, Value: Record type
	    possibleAnswerRecordTypeMap = new Map<String, RecordType>();
	    List<RecordType> possibleAnswerRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_PRS_Question_Criteria__c');
	    for (RecordType recordType : possibleAnswerRecordTypes){
	        possibleAnswerRecordTypeMap.put(recordType.DeveloperName, recordType);
	    }
	}
	
	public EUR_CRM_AnswerFactory.IQuestionsInterface newClassInstance(Id recordTypeId){
	    String className = null;

	    if(questionsTypeMap.containsKey(recordTypeId)){
	        className = questionsTypeMap.get(recordTypeId);
	        System.debug('ClassName: ' + className);
	        
	        Type t = Type.forName(className);
	        System.debug('TypeName: ' + t);
	        
	        return (EUR_CRM_AnswerFactory.IQuestionsInterface) t.newInstance();
	    }
	    return null;
	}
	
	public Id getDefaultRecordType(){
	    return booleanRecordType.Id;
	}
	
	public Id getAnswerRecordType (Id QuestionsRecordTypeId){
	    String developerName = null;
	    Id possibleAnswerRecordTypeId = null;
	    
	    if (questionsRecordTypeMap.containsKey(QuestionsRecordTypeId)){
	        developerName = questionsRecordTypeMap.get(QuestionsRecordTypeId).DeveloperName;
	        if (possibleAnswerRecordTypeMap.containsKey(developerName)){
	            possibleAnswerRecordTypeId = possibleAnswerRecordTypeMap.get(developerName).Id;
            }
	    }
	    
	    return possibleAnswerRecordTypeId;
	}
	
	public List<SelectOption> getQuestionsRecordTypes()
	{
	    List<SelectOption> options = new List<SelectOption>();
	    for (List<RecordType> rts : [SELECT ID, name FROM RecordType WHERE SObjectType = 'EUR_CRM_PRS_Question__c' ORDER BY name]) {
	        for (RecordType rt : rts) {
	            options.add(new SelectOption(rt.ID, rt.Name));
	        } 
	    }
	    return options;
	}
	
	public Boolean hasQuestionAnswer(Id recordTypeId)
	{
	    if (noAnswerQuestions.contains(recordTypeId)){
	        return false;
	    }
	    return true;
	}

    public Id returnBooleanRecordTypeId()
    {
        return booleanRecordType.Id;
    }
}