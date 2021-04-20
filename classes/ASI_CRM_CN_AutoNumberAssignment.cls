public with sharing class ASI_CRM_CN_AutoNumberAssignment {
    private String key;
    private ASI_CRM_CN_RunningNumber__c autoNumObj;
    private Boolean hasUpdate;
    
    public ASI_CRM_CN_AutoNumberAssignment(String key) {
        this.key = key;
        List<ASI_CRM_CN_RunningNumber__c> autoNumObjs = null;
        try {
            autoNumObjs = [
                SELECT Id, ASI_CRM_CN_Running_Number__c
                FROM ASI_CRM_CN_RunningNumber__c
                WHERE ASI_CRM_CN_Prefix__c = :key
                FOR UPDATE
            ];
        } catch (QueryException qe) {
            throw new ASI_HK_CRM_CustomException('Race condition occurs. Please try saving again.');
        }                
        
        if (autoNumObjs != null && autoNumObjs.size() > 0) {
            this.autoNumObj = autoNumObjs[0];
            /*if (autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c != null)
                this.curFiscalYear = fiscalYearByStartMonth(DateTime.now().dateGMT(), autoNumObj.ASI_HK_CRM_First_Month_of_Fiscal_Year__c.intValue());
            this.autoNumFormat = String.isBlank(autoNumObj.ASI_HK_CRM_Format__c) ? '{0}' : autoNumObj.ASI_HK_CRM_Format__c;*/
        }else{
            ASI_CRM_CN_RunningNumber__c newRunningNumberRecord = new ASI_CRM_CN_RunningNumber__c();
            newRunningNumberRecord.ASI_CRM_CN_Prefix__c = key;
            newRunningNumberRecord.ASI_CRM_CN_Running_Number__c = 0;
            
            insert newRunningNumberRecord;
            
            autoNumObj = [
                SELECT Id, ASI_CRM_CN_Running_Number__c
                FROM ASI_CRM_CN_RunningNumber__c
                WHERE ASI_CRM_CN_Prefix__c = :key LIMIT 1           
                FOR UPDATE 
            ];
        }
       /* 
        this.hasUpdate = false;
        this.alreadyChecked = false;*/
    }

    public String nextAutoNumStr() {
        Integer autoNum = nextAutoNum();
        
        String autoNumStr = String.valueOf(autoNum); 
    	if(key.startswith('WS'))
            autoNumStr = autoNumStr.leftPad(3).replace(' ', '0');       
        else
	        autoNumStr = autoNumStr.leftPad(4).replace(' ', '0');       
        
        return key + autoNumStr;
    }
    
    public Integer nextAutoNum() {
        //checkIfNeedReset();
        this.autoNumObj.ASI_CRM_CN_Running_Number__c = this.autoNumObj.ASI_CRM_CN_Running_Number__c + 1;
        this.hasUpdate = true;
        return this.autoNumObj.ASI_CRM_CN_Running_Number__c.intValue();
    }
    
    public void writeToDB() {
        if (this.autoNumObj != null && this.hasUpdate)
            update this.autoNumObj;
    }
}