public class ASI_CRM_RedirectContractNew_lig {
	@AuraEnabled
    public static RecordType getRecordTypeName(String recordTypeId){
        system.debug('@#debugg'+recordTypeId);
        if(recordTypeId == null){
			Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.ASI_TH_CRM_Contract__c;    
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
    public static String getExchangeRet(){
        List<ASI_CRM_MO_Settings__c> lstMOSetting = [SELECT ASI_CRM_MO_Field_ID_Exchange_Rate__c FROM ASI_CRM_MO_Settings__c WHERE ASI_CRM_MO_Field_ID_Exchange_Rate__c != NULL LIMIT 1];
            string strFieldExchangeRate;
            
        if(lstMOSetting != NULL && lstMOSetting.size() > 0){
            strFieldExchangeRate = lstMOSetting[0].ASI_CRM_MO_Field_ID_Exchange_Rate__c;
        }
            return strFieldExchangeRate;
    }
}