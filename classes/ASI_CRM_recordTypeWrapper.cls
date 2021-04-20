public class ASI_CRM_recordTypeWrapper {
 /*******************************************/
    /* Wrapper class to display Record Types      */
    /*****************************************/
        
        @AuraEnabled public boolean isDefault; 
        @AuraEnabled public string recordTypeLabel;
        @AuraEnabled public string recordTypeId;
        @AuraEnabled public string recordTypeDevName;
        
        public ASI_CRM_recordTypeWrapper(){
            isDefault = false;
            recordTypeLabel = '';
            recordTypeId = '';
            recordTypeDevName='';
        }
}