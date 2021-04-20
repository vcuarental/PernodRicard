public with sharing class ASI_TH_CRM_AccountUpdateRecordType extends ASI_HK_CRM_TriggerAbstract {
  
  public ASI_TH_CRM_AccountUpdateRecordType() {
    super('ASI_TH_CRM_AccountUpdateRecordType');
  }
  
  public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    if (tAction == TriggerAction.BEFORE_UPDATE && !isBypassByCurrentUser()) {
        List<Account> AccList = (List<Account>)sObjList;       
        List<RecordType> RTList = Global_RecordTypeCache.getRtList('Account'); 
        if (RTList != null && RTList.size() > 0) {
            ID outletRecordTypeID;
            for (RecordType recordType: RTList ) {
                if (recordType.DeveloperName == 'ASI_TH_CRM_Outlet') {
                    outletRecordTypeID = recordType.id;
                    break;
                }
            }
            System.debug('Debug outletRecordTypeID :' + outletRecordTypeID );
            
            for (Account account : AccList) {                                                
              if(Global_RecordTypeCache.getRt(account.recordTypeId).developerName.contains('ASI_TH_CRM_Potential_Outlet')){
                  if (((Account)oldMap.get(account.id)).ASI_HK_CRM_JDE_Account_Number__c == null && ((Account)newMap.get(account.id)).ASI_HK_CRM_JDE_Account_Number__c != null ){
                      account.RecordTypeid = outletRecordTypeID;
                  }
              }
                                    
        }
        
      }
    }
  }

}