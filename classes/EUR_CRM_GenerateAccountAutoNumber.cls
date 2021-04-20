/*********************************************************************************
 * Name:EUR_CRM_GenerateAccountAutoNumber
 * Description: Generic Helper Class to generate Custom AutoNumber for Accoutn names based on Running Number Object
*********************************************************************************/
public without sharing class EUR_CRM_GenerateAccountAutoNumber {

    private String autoPrefix;
    private Decimal numOfDigit;
    private boolean hasUpdate;    
    private EUR_CRM_Apex_Configuration__c runningNumberConfig;
    private static final decimal DEFAULT_LENGTH = 6;
    public Boolean isValid {get; set;} 

    public EUR_CRM_GenerateAccountAutoNumber(String module, String countryCode, String recordTypeDevName){
        Map<Id, EUR_CRM_Apex_Configuration__c> runningNumbers;
        hasUpdate = false;
        isValid = false; 
        runningNumbers = new  Map<Id, EUR_CRM_Apex_Configuration__c>([
                                                                        SELECT Id, EUR_CRM_Prefix__c, EUR_CRM_Running_Number_Length__c, EUR_CRM_Running_Number__c,
                                                                               EUR_CRM_Account_RecordType_DevName__c, EUR_CRM_Master_Running_Number__c
                                                                        FROM EUR_CRM_Apex_Configuration__c
                                                                        WHERE EUR_CRM_Module__c =: module
                                                                        AND EUR_CRM_Country_Code__c =: countryCode
                                                                        FOR UPDATE
                                                                    ]);

        if(runningNumbers != null && runningNumbers.KeySet().size() > 0){
            for(EUR_CRM_Apex_Configuration__c config : runningNumbers.values()){
                if(config.EUR_CRM_Account_RecordType_DevName__c == recordTypeDevName){
                    if(config.EUR_CRM_Master_Running_Number__c == null){
                        runningNumberConfig = config;
                    }
                    else {
                        runningNumberConfig = runningNumbers.get(config.EUR_CRM_Master_Running_Number__c);
                    }

                    autoPrefix = runningNumberConfig.EUR_CRM_Prefix__c == null ? '' : runningNumberConfig.EUR_CRM_Prefix__c;
                    numOfDigit = runningNumberConfig.EUR_CRM_Running_Number_Length__c == null ? DEFAULT_LENGTH : runningNumberConfig.EUR_CRM_Running_Number_Length__c;
                    isValid = true;
                    break;
                }
            }
        }
    }

    public String nextAutoNumStr(){
        Integer autoNum = nextAutoNum();
        return genRunningNumber(autoNum);
    }
    
    public Integer nextAutoNum(){
        if(this.runningNumberConfig.EUR_CRM_Running_Number__c == NULL){
            this.runningNumberConfig.EUR_CRM_Running_Number__c = 0;
        }

        this.runningNumberConfig.EUR_CRM_Running_Number__c = this.runningNumberConfig.EUR_CRM_Running_Number__c + 1;
        this.hasUpdate = true;
        return this.runningNumberConfig.EUR_CRM_Running_Number__c.intValue();
    }
    
    private String genRunningNumber(Integer autoNum){
        Decimal autoNumLength = numOfDigit - (String.valueof(autoNum)).length(); 
        String runningNum = String.isBlank(autoPrefix) ? '' : autoPrefix;
        
        if(autoNumLength > 0){
            String tempDigit = '';
            for(Integer i=0; i<autoNumLength; i++){
                tempDigit = tempDigit + '0';
            }
            
            runningNum = runningNum + tempDigit + autoNum;
        }else{
            runningNum = runningNum + autoNum;
        }
        
        return runningNum;
    }

    public void writeToDB(){
        if(runningNumberConfig != null && this.hasUpdate){
            update runningNumberConfig;
        }
    }
}