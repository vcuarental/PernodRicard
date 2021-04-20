public with sharing class ASI_TH_CRM_AssignAccountCustomerCode extends ASI_HK_CRM_TriggerAbstract {
  
  public ASI_TH_CRM_AssignAccountCustomerCode() {
    super('ASI_TH_CRM_AssignAccountCustomerCode');
  }
  
  public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    if (tAction == TriggerAction.BEFORE_INSERT && !isBypassByCurrentUser()) {
        List<Account> AccList = (List<Account>)sObjList;       
        List<RecordType> RTList = Global_RecordTypeCache.getRtList('Account');   
        if (RTList != null && RTList.size() > 0) {
            ASI_HK_CRM_AutoNumberAssignment autoNumAssign = null;
            ASI_HK_CRM_AutoNumberAssignment autoNumAssignCustomer = null;
            for (Account Acc : AccList) {                                                
              if(Global_RecordTypeCache.getRt(acc.recordTypeId).developerName.contains('ASI_TH_CRM_Potential_Outlet')){
                  System.Debug('Debug Start Generate TH CRM Customer Code:');
                  if (Acc.ASI_KOR_Customer_Code__c == null || Acc.ASI_KOR_Customer_Code__c == ''){
                      autoNumAssignCustomer = new ASI_HK_CRM_AutoNumberAssignment('ASI_TH_CRM_Customer_Code');
                      Acc.ASI_KOR_Customer_Code__c = autoNumAssignCustomer.nextAutoNumStr();
                  }
                  System.Debug('Debug End Generate TH CRM Customer Code:');
              }
                                    
        }
        if (autoNumAssign != null)
            autoNumAssign.writeToDB();
            
        if (autoNumAssignCustomer != null)
            autoNumAssignCustomer.writeToDB();
      }
    }
  }

}