public with sharing class EUR_CRM_AccountAssignAutoNumber extends EUR_CRM_TriggerAbstract  {
  
  public EUR_CRM_AccountAssignAutoNumber() {
    super('EUR_CRM_AccountAssignAutoNumber');
  }
  private Set<String> validRecordTypes = EUR_CRM_RecordTypeHelper.AccountAssignAutoNumber_validRecordTypes; 
  
    private final Static String MODULE = 'EUR_CRM_Account_Running_Number'; 
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
  
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : accountRecordTypes ){
           accountRecordTypesMap.put(rt.id,rt);
        }
         
        Map<String, EUR_CRM_GenerateAccountAutoNumber> autoNumGenerators = new Map<String, EUR_CRM_GenerateAccountAutoNumber>();        
         
        for (EUR_CRM_Account__c acc : (List<EUR_CRM_Account__c>) sObjList) {
            String accountTDevName = accountRecordTypesMap.get(acc.recordtypeid).developername;  

            if(validRecordTypes.contains(accountTDevName)){
                String countryCode = acc.EUR_CRM_Country_Code__c;
                String key = MODULE + countryCode;
                if(autoNumGenerators.get(key) == null){
                    autoNumGenerators.put(key, new EUR_CRM_GenerateAccountAutoNumber(MODULE, countryCode, accountTDevName));
                }
                EUR_CRM_GenerateAccountAutoNumber autoNumAssign = autoNumGenerators.get(key);
                if(autoNumAssign.isValid){
					// Update by Joel J. 8/15/15 - Change the field from EUR_CRM_Internal_Customer_Num__c to EUR_CRM_Account_Code__c
                    acc.EUR_CRM_Account_Code__c=  autoNumAssign.nextAutoNumStr();
                }
                else{
                    acc.addError('Cannot generate Auto Number. Please contact the system administrator');
                }
            }
        }
        
        for(EUR_CRM_GenerateAccountAutoNumber autoNumAssign : autoNumGenerators.values()){
            autoNumAssign.writeToDB(); 
        }
    }
}