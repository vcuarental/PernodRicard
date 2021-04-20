public with sharing class ASI_CRM_TW_AutoNumberAssignment {
    private String key;
    private ASI_CRM_TW_Running_Number__c autoNumObj;
    private Boolean hasUpdate; 
    
    public ASI_CRM_TW_AutoNumberAssignment(String key) {
        this.key = key;
        List<ASI_CRM_TW_Running_Number__c> autoNumObjs = null;
        try {
            autoNumObjs = [
                SELECT Id, ASI_CRM_TW_Running_Number__c
                FROM ASI_CRM_TW_Running_Number__c
                WHERE ASI_CRM_TW_Prefix__c = :key
                FOR UPDATE
            ];
        } catch (QueryException qe) {
            throw new ASI_HK_CRM_CustomException('Race condition occurs. Please try saving again.');
        }                
        
        if (autoNumObjs != null && autoNumObjs.size() > 0) {
            this.autoNumObj = autoNumObjs[0];            
        }else{
            ASI_CRM_TW_Running_Number__c newRunningNumberRecord = new ASI_CRM_TW_Running_Number__c();
            newRunningNumberRecord.recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_TW_Running_Number__cASI_CRM_TW_RunningNumber');
            newRunningNumberRecord.ASI_CRM_TW_Prefix__c = key;
            newRunningNumberRecord.ASI_CRM_TW_Running_Number__c = 0;
            
            insert newRunningNumberRecord;
            
            autoNumObj = [
                SELECT Id, ASI_CRM_TW_Running_Number__c
                FROM ASI_CRM_TW_Running_Number__c
                WHERE ASI_CRM_TW_Prefix__c = :key LIMIT 1           
                FOR UPDATE 
            ];
        }     
    }
/*
    public String nextAutoNumStr() {
        Integer autoNum = nextAutoNum();
        
        String autoNumStr = String.valueOf(autoNum); 
        autoNumStr = autoNumStr.leftPad(4).replace(' ', '0');       
        
        return key + autoNumStr;
    }
 */   
    public String nextAutoNumStr(Integer length) {
        Integer autoNum = nextAutoNum();
        
        String autoNumStr = String.valueOf(autoNum); 
        autoNumStr = autoNumStr.leftPad(length).replace(' ', '0');       
        
        return key + autoNumStr;
    }
    
    public Integer nextAutoNum() {        
        this.autoNumObj.ASI_CRM_TW_Running_Number__c = this.autoNumObj.ASI_CRM_TW_Running_Number__c + 1;
        this.hasUpdate = true;
        return this.autoNumObj.ASI_CRM_TW_Running_Number__c.intValue();
    }
    
    public void writeToDB() {
        if (this.autoNumObj != null && this.hasUpdate)
            update this.autoNumObj;
    }
}