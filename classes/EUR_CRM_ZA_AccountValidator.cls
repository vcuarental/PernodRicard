/*
*    Description    :    This class contains methods which validates whether the Accounts
*                        belong to the List of Permissible Record Type
*
*    Version        Date                Author        Description
*    1.0            12/16/2015          Sid           Initial Draft
*/

public with sharing class EUR_CRM_ZA_AccountValidator {

    //Method accepts a list of Account(EU) records and 
    // a list of Permissible Record Types based on which Accounts should be filtered
    //Returns filtered list of Account records
    public List<EUR_CRM_Account__c> getValidatedAccountList(List<EUR_CRM_Account__c> pSelectedAccountList, 
                                                            List<String> pPermissibleRecTypeList){
        
        System.debug('============ pSelectedAccountList ' + pSelectedAccountList.size());
        
        //List of Validated Accounts
        List<EUR_CRM_Account__c> validatedAccList = new List<EUR_CRM_Account__c>();
        
        //Map of Permissible Record Type Ids 
        Map<Id, RecordType> accRecTypeMap = new Map<Id, RecordType>([Select Id, 
                                                                            DeveloperName
                                                                     from RecordType 
                                                                     Where DeveloperName IN: pPermissibleRecTypeList]);
        
        for(EUR_CRM_Account__c acc : pSelectedAccountList){
            
            if(accRecTypeMap.containsKey(acc.RecordTypeId)){
                validatedAccList.add(acc);
            }
        }
        
        return validatedAccList;
    }
}