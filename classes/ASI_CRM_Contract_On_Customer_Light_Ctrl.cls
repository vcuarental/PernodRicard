public class ASI_CRM_Contract_On_Customer_Light_Ctrl {
    
    @AuraEnabled
    public static List<ASI_CRM_recordTypeWrapper> getRecordTypes() {
        List<ASI_CRM_recordTypeWrapper> lstRecordTypes = new List<ASI_CRM_recordTypeWrapper>();
        List<Schema.RecordTypeInfo> recordtypes = ASI_TH_CRM_Contract__c.SObjectType.getDescribe().getRecordTypeInfos();
        System.debug ('Find record type size: '+recordtypes.size());
        for(RecordTypeInfo rt : recordtypes){
            System.debug ('RecordTypeInfo: '+rt);
        	if (rt.getName() != 'Master') {
                String devName = rt.getDeveloperName();
               	System.debug (devName + ' - ' + devName.containsIgnoreCase('Read'));
                if (rt.isAvailable() == True && !devName.containsIgnoreCase('Read')) {
                    ASI_CRM_recordTypeWrapper recordType = new ASI_CRM_recordTypeWrapper();
                    recordType.recordTypeId =rt.getRecordTypeId();
                    recordType.recordTypeLabel = rt.getName();
                    recordType.recordTypeDevName = rt.getDeveloperName();
                    recordType.isDefault =rt.isDefaultRecordTypeMapping();
                    lstRecordTypes.add(recordType);
                }
            }    
        }
        system.debug('lstRecordTypes' +lstRecordTypes);
        return lstRecordTypes;
    }
}