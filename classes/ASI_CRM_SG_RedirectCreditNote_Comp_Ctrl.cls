public class ASI_CRM_SG_RedirectCreditNote_Comp_Ctrl {
	@AuraEnabled
    public static RecordType getRecordTypeName(String recordTypeId){
        system.debug('@#debugg'+recordTypeId);
        if(recordTypeId == null){
			Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c;    
            List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
            system.debug(rtInfos);
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                System.debug(rtInfo);
                System.debug(rtInfo.isDefaultRecordTypeMapping());
                // For only one record type available user
                if(rtInfo.isAvailable() && rtInfo.getName() != 'Master') {  
                    system.debug('@#debugg'+rtInfo.getRecordTypeId());
                    //ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
                    recordTypeId  = rtInfo.getRecordTypeId();
                    break;
                }
            }            
        }
        if(recordTypeId  != null && recordTypeId !=''){
            return [Select Id, developername, Name from recordType where id = :recordTypeId limit 1];
        }else{
            return null;
        }    
        
    }
    
    @AuraEnabled
    public static List<ASI_CRM_recordTypeWrapper> getRecordTypes() {
        system.debug('@#here');
        List<ASI_CRM_recordTypeWrapper> lstRecordTypes =
        new List<ASI_CRM_recordTypeWrapper>();
        List<Schema.RecordTypeInfo> recordtypes = ASI_CRM_Credit_Debit_Note__c.SObjectType.getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master')
                if(rt.isAvailable()==True){
               ASI_CRM_recordTypeWrapper recordType =
                new ASI_CRM_recordTypeWrapper();
                recordType.recordTypeId =rt.getRecordTypeId();
                recordType.recordTypeLabel = rt.getName();
                 recordType.recordTypeDevName = rt.getDeveloperName();
                recordType.isDefault =rt.isDefaultRecordTypeMapping();
                lstRecordTypes.add(recordType);
            }
       }
        system.debug('lstRecordTypes' +lstRecordTypes);
        return lstRecordTypes;

}
}