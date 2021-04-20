public class ASI_CRM_RedirectPRNew_lig {

    	@AuraEnabled
    public static string getRecordTypeName(String recordTypeId){
        
         if(recordTypeId  == null){
            Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c;    
            List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
            system.debug(rtInfos);
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                System.debug(rtInfo);
                System.debug(rtInfo.isDefaultRecordTypeMapping());
                // For only one record type available user
                if(rtInfo.isAvailable() && rtInfo.getName() != 'Master') {               
                    //ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
                    recordTypeId  = rtInfo.getRecordTypeId();
                    break;
                }
            }
            
        }
      String  recordTypeName = 'null';
        if(recordTypeId != '' && recordTypeId != null){
            Recordtype rt = Global_RecordTypeCache.getRt(recordTypeId);
            recordTypeName = rt.DeveloperName;
        }
        return recordTypeName;
    }
}