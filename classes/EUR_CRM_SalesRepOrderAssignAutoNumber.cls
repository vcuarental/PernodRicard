public with sharing class EUR_CRM_SalesRepOrderAssignAutoNumber extends EUR_CRM_TriggerAbstract  {
  
  public EUR_CRM_SalesRepOrderAssignAutoNumber() {
    super('EUR_CRM_SalesRepOrderAssignAutoNumber');
  }
  private Set<String> validRecordTypes = EUR_CRM_RecordTypeHelper.SalesRepOrderAssignAutoNumber_validRecordTypes; 
  
    private final Static String MODULE = 'EUR_CRM_SRO_Running_Number'; 
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
  
        List<Recordtype> salesRepOrderRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_SalesRep_Order__c');
        Map<Id,Recordtype> salesRepOrderRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : salesRepOrderRecordTypes ){
           salesRepOrderRecordTypesMap.put(rt.id,rt);
        }
         
        Map<String, EUR_CRM_GenerateAutoNumber> autoNumGenerators = new Map<String, EUR_CRM_GenerateAutoNumber>();        
         
        for (EUR_CRM_SalesRep_Order__c sro : (List<EUR_CRM_SalesRep_Order__c>) sObjList) {
            String salesRepOrdeRTDevName = salesRepOrderRecordTypesMap.get(sro.recordtypeid).developername;            
            if(validRecordTypes.contains(salesRepOrdeRTDevName ) ){
                String countryCode = sro.EUR_CRM_Country_Code__c;
                String key = MODULE + countryCode;
                if(autoNumGenerators.get(key) == null)
                    autoNumGenerators.put(key, new EUR_CRM_GenerateAutoNumber(MODULE, countryCode));
                EUR_CRM_GenerateAutoNumber  autoNumAssign = autoNumGenerators.get(key);
                if(autoNumAssign.isValid)
                    sro.name=  autoNumAssign.nextAutoNumStr();
                else
                    sro.addError('Cannot generate Auto Number. Please contact the system administrator');
            }
        }
        
        for(EUR_CRM_GenerateAutoNumber autoNumAssign: autoNumGenerators.values())
            autoNumAssign.writeToDB(); 
    }
}