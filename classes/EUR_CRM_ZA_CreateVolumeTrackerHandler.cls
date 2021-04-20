public class EUR_CRM_ZA_CreateVolumeTrackerHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_ZA_CreateVolumeTrackerHandler(){
        super('EUR_CRM_ZA_CreateVolumeTrackerHandler');
    } 

    private static Set<String> validEUAccountRecordTypeSet = new Set<String>{
          'EUR_ZA_Off_Trade'
    };

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(validEUAccountRecordTypeSet);

            return TRt;
        }private set;
    }
    

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){ 

        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();
        List<EUR_CRM_Account_Volume_Tracker__c> acctVolumeTrackerToInsert = new List<EUR_CRM_Account_Volume_Tracker__c>();

        for(Recordtype rt : accountRecordTypes){
           accountRecordTypesMap.put(rt.id,rt);
        }

        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){

            if(tAction == TriggerAction.AFTER_INSERT){
                if(validEUAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.RecordTypeId).DeveloperName)){
                    EUR_CRM_Account_Volume_Tracker__c acctVolTracker = new EUR_CRM_Account_Volume_Tracker__c();
                    acctVolTracker.EUR_CRM_Account__c = euAccount.Id;

                    acctVolumeTrackerToInsert.add(acctVolTracker);
                }
            }
        }

        if(acctVolumeTrackerToInsert.size() > 0){
            insert acctVolumeTrackerToInsert;
        }
    }
}