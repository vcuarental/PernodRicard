public  class EUR_CRM_ZA_Validate_RT_Start_Date extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ZA_Validate_RT_Start_Date(){
        super('EUR_CRM_ZA_Validate_RT_Start_Date');
    }

    private final Set<String> validRecordTypes = new Set<String>{
      'EUR_ZA_Route_Template'
    };
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> rtRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Route_Template__c');
        Map<Id,Recordtype> rtRecordTypesMap = new Map<Id,Recordtype>();

    
        for(Recordtype rect : rtRecordTypes){
           rtRecordTypesMap.put(rect.id,rect);
        }
        
        for(EUR_CRM_Route_Template__c rt : (List<EUR_CRM_Route_Template__c>) sObjList){ 

            String devName = rtRecordTypesMap.get(rt.recordTypeId).developername;
            

            if(validRecordTypes.contains(devname)){
                if(tAction == TriggerAction.BEFORE_UPDATE){
                    EUR_CRM_Route_Template__c oldRecord = (EUR_CRM_Route_Template__c) oldMap.get(rt.id);
                    if(rt.EUR_CRM_Start_Date__c != oldrecord.EUR_CRM_Start_Date__c){
                        if(rt.EUR_CRM_Start_Date__c == null){
                            rt.addError('Start Date is required.');
                        } else {
                            DateTime dt = Datetime.newInstance(rt.EUR_CRM_Start_Date__c.year(), rt.EUR_CRM_Start_Date__c.month(),rt.EUR_CRM_Start_Date__c.day());
                            String weekDay = dt.format('EEEE');
                            if(weekDay != 'Monday'){
                                rt.addError('Please select a date which is a Monday.');
                            } else {
                                if(rt.EUR_CRM_Start_Date__c < Date.Today()){
                                    rt.addError('You cannot select a previous Monday.');
                                }
                            }
                        }
                    }
                    
                }
                if(tAction == TriggerAction.BEFORE_INSERT){
                    if(rt.EUR_CRM_Start_Date__c == null){
                        rt.addError('Start Date is required.');
                    } else {
                        DateTime dt = Datetime.newInstance(rt.EUR_CRM_Start_Date__c.year(), rt.EUR_CRM_Start_Date__c.month(),rt.EUR_CRM_Start_Date__c.day());
                        String weekDay = dt.format('EEEE');
                        if(weekDay != 'Monday'){
                            rt.addError('Please select a date which is a Monday.');
                        } else {
                            if(rt.EUR_CRM_Start_Date__c < Date.Today()){
                                rt.addError('You cannot select a previous Monday.');
                            }
                        }
                    }
                }
            }
            
        }

        
    }
}