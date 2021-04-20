/*********************************************************************************
 * Name:EUR_CRM_GenerateAutoNumber
 * Description: Generic Helper Class to generate Custom AutoNumber based on Running Number Object
 * ref: ASI_CRM_JP_AutoNumberAssignment
 *      https://pernod-ricard--asisb5conf.cs7.my.salesforce.com/01pM00000007gVl
 *      ASI_CRM_JP_AssignAutoNumber_Contract
 *      https://pernod-ricard--asisb5conf.cs7.my.salesforce.com/01pM00000007gWo
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * MAR.16.2015       IPC: Rey          Created
 * 
*********************************************************************************/
public without sharing class EUR_CRM_GenerateAutoNumber{  

    private string autoPrefix;
    private decimal numOfDigit;
    private boolean hasUpdate;    
    private EUR_CRM_Apex_Configuration__c runningNumberConfig;
    private static final decimal DEFAULT_LENGTH = 10;
    public Boolean isValid {get; set;} 
    public EUR_CRM_GenerateAutoNumber(String module, String countryCode){
        List<EUR_CRM_Apex_Configuration__c> runningNumbers;
        hasUpdate = false;
        isValid = false; 
            runningNumbers = [
                SELECT Id, 
                       EUR_CRM_Prefix__c, EUR_CRM_Running_Number_Length__c, EUR_CRM_Running_Number__c
                FROM EUR_CRM_Apex_Configuration__c
                WHERE EUR_CRM_Module__c = :module AND
                EUR_CRM_Country_Code__c = :countryCode
                FOR UPDATE
            ]; 
        if(runningNumbers != null && runningNumbers.size() >0){
            runningNumberConfig = runningNumbers.get(0);
            autoPrefix = runningNumberConfig.EUR_CRM_Prefix__c == null? '' : runningNumberConfig.EUR_CRM_Prefix__c;
            numOfDigit = runningNumberConfig.EUR_CRM_Running_Number_Length__c == null? DEFAULT_LENGTH : runningNumberConfig.EUR_CRM_Running_Number_Length__c;
            isValid = true;
        }

    }
    public String nextAutoNumStr(){
        Integer autoNum = nextAutoNum();
        return genRunningNumber(autoNum);
    }
    
    public Integer nextAutoNum(){
        if(this.runningNumberConfig.EUR_CRM_Running_Number__c == NULL)
            this.runningNumberConfig.EUR_CRM_Running_Number__c = 0;
        this.runningNumberConfig.EUR_CRM_Running_Number__c = this.runningNumberConfig.EUR_CRM_Running_Number__c+ 1;
        this.hasUpdate = true;
        return this.runningNumberConfig.EUR_CRM_Running_Number__c.intValue();
    }
    
    private String genRunningNumber(integer autoNum){
        decimal autoNumLength = numOfDigit - (String.valueof(autoNum)).length(); 
        string runningNum = String.isBlank(autoPrefix)? '': autoPrefix;
        
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
        if(runningNumberConfig != null && this.hasUpdate)
            update runningNumberConfig;
    }

}