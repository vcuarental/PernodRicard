public with sharing class EUR_CRM_CriteriaManager {
    private List<RecordType> criteriaRecordTypes{get;set;}
    private Map<Id, String> criteriaTypeMap{get;set;}
    private Map<Id, RecordType> criteriaRecordTypeMap{get;set;}
    private Map<String, RecordType> answerRecordTypeMap{get;set;}
    
    private RecordType booleanRecordType{get;set;}
    
    private final String BOOLEAN_CRITERIA = 'EUR_CRM_CriteriaFactory.BooleanCriteria';
    private final String INTEGERINPUT_CRITERIA = 'EUR_CRM_CriteriaFactory.IntegerInputCriteria';
    private final String CURRENCYINPUT_CRITERIA = 'EUR_CRM_CriteriaFactory.CurrencyInputCriteria';
    private final String PICKLIST_CRITERIA = 'EUR_CRM_CriteriaFactory.PicklistCriteria';
    private final String TEXTINPUT_CRITERIA = 'EUR_CRM_CriteriaFactory.TextInputCriteria';
    
    private final String BOOLEAN_CRITERIA_DEVNAME = 'EUR_CRM_Boolean';
    private final String INTEGERINPUT_CRITERIA_DEVNAME = 'EUR_CRM_Integer_Input';
    private final String CURRENCYINPUT_CRITERIA_DEVNAME = 'EUR_CRM_Currency_Input';
    private final String PICKLIST_CRITERIA_DEVNAME = 'EUR_CRM_Picklist';
    private final String TEXTINPUT_CRITERIA_DEVNAME = 'EUR_CRM_Text_Input';
    
    //List of criteria thresholds without weight calculation
    private Set<Id> noAnswerCriteria{get;set;}
    
    public EUR_CRM_CriteriaManager(){
        //Instantiate criteria record type maps and no answer set
        noAnswerCriteria = new Set<Id>();
        criteriaTypeMap = new Map<Id, String> ();
        criteriaRecordTypeMap = new Map<Id, RecordType>();
        
        criteriaRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='EUR_CRM_Criteria_Threshold__c'];

        for(RecordType recordType: criteriaRecordTypes){
            //Criteria Type Map: Key-Record Type ID, Value:Factory class name
            if (recordType.DeveloperName.equalsIgnoreCase(BOOLEAN_CRITERIA_DEVNAME)){
                criteriaTypeMap.put(recordType.Id,BOOLEAN_CRITERIA);
                booleanRecordType = recordType;
            }
            else if (recordType.DeveloperName.equalsIgnoreCase(INTEGERINPUT_CRITERIA_DEVNAME)) criteriaTypeMap.put(recordType.Id,INTEGERINPUT_CRITERIA);
            else if (recordType.DeveloperName.equalsIgnoreCase(CURRENCYINPUT_CRITERIA_DEVNAME)) criteriaTypeMap.put(recordType.Id,CURRENCYINPUT_CRITERIA);
            else if (recordType.DeveloperName.equalsIgnoreCase(PICKLIST_CRITERIA_DEVNAME)) criteriaTypeMap.put(recordType.Id,PICKLIST_CRITERIA);
            else if (recordType.DeveloperName.equalsIgnoreCase(TEXTINPUT_CRITERIA_DEVNAME)) {
                criteriaTypeMap.put(recordType.Id,TEXTINPUT_CRITERIA);
                noAnswerCriteria.add(recordType.Id);
            }
            
            //Criteria Record Type Map: Key-Record Type ID, Value:Record Type Instance
            criteriaRecordTypeMap.put(recordType.Id, recordType);
        }
        //Instantiate answer record type map
        //Criteria Answer Record Type: Key-Developer Name, Value: Record type
        answerRecordTypeMap = new Map<String, RecordType>();
        List<RecordType> answerRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType 
                                                WHERE SobjectType='EUR_CRM_Criteria_Answer__c'];
        for (RecordType recordType: answerRecordTypes){
            answerRecordTypeMap.put(recordType.DeveloperName, recordType);
        }
    }
    
    public EUR_CRM_CriteriaFactory.ICriteriaInterface newClassInstance(Id recordTypeId){
        String className = null;

        if(criteriaTypeMap.containsKey(recordTypeId)){
            className = criteriaTypeMap.get(recordTypeId);
            System.debug('Flag- ClassName:' + className);
            
            Type t = Type.forName(className);
            System.debug('Flag- TypeName:' + t);
            
            return (EUR_CRM_CriteriaFactory.ICriteriaInterface) t.newInstance();
        }
        return null;
    }
    
    public Id getDefaultRecordType(){
        return booleanRecordType.Id;
    }
    
    public Id getAnswerRecordType (Id criteriaRecordTypeId){
        String developerName = null;
        Id answerRecordTypeId = null;
        
        if (criteriaRecordTypeMap.containsKey(criteriaRecordTypeId)){
            developerName = criteriaRecordTypeMap.get(criteriaRecordTypeId).DeveloperName;
            if (answerRecordTypeMap.containsKey(developerName)) 
                answerRecordTypeId = answerRecordTypeMap.get(developerName).Id;
        }
        
        return answerRecordTypeId;
    }
    
    public List<SelectOption> getCriteriaRecordTypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        for (List<RecordType> rts : [SELECT ID, name FROM RecordType WHERE SObjectType = 'EUR_CRM_Criteria_Threshold__c' ORDER BY name]) {
            for (RecordType rt : rts) {
                options.add(new SelectOption(rt.ID, rt.Name));
            } 
        }
        return options;
    }
    
    public Boolean hasCriteriaAnswer(Id recordTypeId)
    {
        if (noAnswerCriteria.contains(recordTypeId)){
            return false;
        }
        return true;
    }
    
    public Id returnBooleanRecordTypeId()
    {
        return booleanRecordType.Id;
    }

}