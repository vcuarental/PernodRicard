public class ASI_CRM_SO_On_Customer_Light_Ctrl {

    @AuraEnabled
    public static List<ASI_CRM_recordTypeWrapper> getRecordTypes() {
        List<ASI_CRM_recordTypeWrapper> lstRecordTypes = new List<ASI_CRM_recordTypeWrapper>();
        List<Schema.RecordTypeInfo> recordtypes = ASI_KOR_Sales_Order_Request__c.SObjectType.getDescribe().getRecordTypeInfos();
        System.debug ('Find record type size: '+recordtypes.size());
        boolean hasfirstDefault = false;
        for(RecordTypeInfo rt : recordtypes){
            System.debug ('RecordTypeInfo: '+rt);
        	if (rt.getName() != 'Master') {
                String devName = rt.getDeveloperName();
               	System.debug (devName + ' - ' + devName.containsIgnoreCase('Lock'));
                if (rt.isAvailable() == True && !devName.containsIgnoreCase('Lock')) {
                    ASI_CRM_recordTypeWrapper recordType = new ASI_CRM_recordTypeWrapper();
                    recordType.recordTypeId =rt.getRecordTypeId();
                    recordType.recordTypeLabel = rt.getName();
                    recordType.recordTypeDevName = rt.getDeveloperName();
                    if (hasfirstDefault == false) {
                        recordType.isDefault = true;
                        hasfirstDefault = true;
                    } else {
                        recordType.isDefault = false;
                    }
                    //recordType.isDefault =rt.isDefaultRecordTypeMapping();
                    lstRecordTypes.add(recordType);
                }
            }    
        }
        system.debug('lstRecordTypes' +lstRecordTypes);
        return lstRecordTypes;
    }
}