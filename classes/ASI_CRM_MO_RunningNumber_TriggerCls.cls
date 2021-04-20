/*Filename:    ASI_CRM_MO_RunningNumber_TriggerCls.cls
* Author:      Daniel WONG (Introv Limited)
* Purpose:     Generic Helper Class to generate Custom RunningNumber
*
* ref: ASI_CRM_JP_AutoNumberAssignment
*      https://pernod-ricard--asisb5conf.cs7.my.salesforce.com/01pM00000007gVl
*      ASI_CRM_JP_AssignAutoNumber_Contract
*      https://pernod-ricard--asisb5conf.cs7.my.salesforce.com/01pM00000007gWo
*
* History
* -----------------------------------------------------------------------------
* 2015-03-31        daniel.wong@introv.com        Created
*/

public with sharing class ASI_CRM_MO_RunningNumber_TriggerCls{
    private string key;
    private ASI_CRM_Running_Number__c autoNumObj;
    private string autoPrefix;
    private decimal autoNumDigit;
    private boolean hasUpdate;
    private ID MORunningNumberRT = Global_RecordTypeCache.getRtId('ASI_CRM_Running_Number__cASI_CRM_MO_Running_Number');
    
    public ASI_CRM_MO_RunningNumber_TriggerCls(String key){
        this.hasUpdate = false;
        this.key = key;
        list<ASI_CRM_Running_Number__c> autoNumObjs = NULL;
        
        try{
            autoNumObjs = [
                SELECT Id, ASI_CRM_Module__c,
                       ASI_CRM_Prefix__c, ASI_CRM_Number_of_Digit__c, ASI_CRM_Running_Number__c
                FROM ASI_CRM_Running_Number__c
                WHERE ASI_CRM_Module__c = :key
                AND RecordTypeId = :MORunningNumberRT
                FOR UPDATE
            ];
        }catch(QueryException qe){
            throw new ASI_HK_CRM_CustomException('Race condition occurs. Please try saving again.');
        }
        
        if(autoNumObjs != NULL && autoNumObjs.size() > 0){
            this.autoNumObj = autoNumObjs[0];
            this.autoPrefix = String.isBlank(autoNumObj.ASI_CRM_Prefix__c)? '' : autoNumObj.ASI_CRM_Prefix__c;
            this.autoNumDigit = autoNumObj.ASI_CRM_Number_of_Digit__c == NULL? 0 : autoNumObj.ASI_CRM_Number_of_Digit__c;
        }
    }
    
    public String nextAutoNumStr(){
        Integer autoNum = nextAutoNum();
        return genRunningNumber(this.autoPrefix ,this.autoNumDigit, autoNum);
    }
    
    public Integer nextAutoNum(){
        if(this.autoNumObj.ASI_CRM_Running_Number__c == NULL)
            this.autoNumObj.ASI_CRM_Running_Number__c = -1;
        this.autoNumObj.ASI_CRM_Running_Number__c = this.autoNumObj.ASI_CRM_Running_Number__c + 1;
        this.hasUpdate = true;
        return this.autoNumObj.ASI_CRM_Running_Number__c.intValue();
    }
    
    private String genRunningNumber(string prefix, decimal numOfDigit, integer autoNum){
        decimal autoNumLength = numOfDigit - (String.valueof(autoNum)).length(); 
        string runningNum = String.isBlank(prefix)? '': prefix;
        
        if(autoNumLength > 0){
            string tempDigit = '';
            integer i = 0;
            for(i=0; i<autoNumLength; i++){
                tempDigit = tempDigit + '0';
            }
            
            runningNum = runningNum + tempDigit + autoNum;
        }else{
            runningNum = runningNum + autoNum;
        }
        
        return runningNum;
    }
    
    public void writeToDB(){
        if(this.autoNumObj != null && this.hasUpdate)
            update this.autoNumObj;
    }
}