/*********************************************************************************
 * Name:ASI_CRM_JP_AssignAutoNumber_Customer 
 * Description: Class to Assign Custom Auto Number to CRM Code. JP Specific
 *                Each Prefecture has its own Running Number                
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/11/2014       Laputa: Conrad          Created
 * 20/11/2014       Laputa: Conrad          Added Prefecture Mapping (46 different running numbers)
 * 24/11/2014       Laputa: Conrad          Added checking where Prefecture mapping only applies on JP On-Trade recordtype
*********************************************************************************/

public with sharing class ASI_CRM_JP_AssignAutoNumber_Customer extends ASI_CRM_JP_TriggerAbstract {


    public ASI_CRM_JP_AssignAutoNumber_Customer () {
        super('ASI_CRM_JP_AssignAutoNumber_Customer ');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_CRM_AccountsAdditionalField__c> validCustomerList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;
        
        ASI_CRM_JP_AutoNumberAssignment autoNumAssign = null;
        
        // Retrieve all the related Japanese Postal Codes
        Set<String> postalJPCodeIDSet = new Set<String>();
        Map<String, ASI_CRM_Postal_Code__c> postalJPCodeMap = new Map<String, ASI_CRM_Postal_Code__c>();
        for(ASI_CRM_AccountsAdditionalField__c validCustomer : validCustomerList) {
        
            if(validCustomer.ASI_CRM_PostalCode__c != null) {
                postalJPCodeIDSet.add(validCustomer.ASI_CRM_PostalCode__c);
            }
        }
        
        if (postalJPCodeIDSet.size() > 0) {
            for(ASI_CRM_Postal_Code__c postal:[SELECT ID, Name, ASI_CRM_JP_Prefecture_EN__c, ASI_CRM_JP_Prefecture__c FROM ASI_CRM_Postal_Code__c WHERE Name IN : postalJPCodeIDSet]){
            	postalJPCodeMap.put(postal.Name, postal);
            }
        }
        
        for (ASI_CRM_AccountsAdditionalField__c validCustomer : validCustomerList)
        {
            ASI_CRM_Postal_Code__c postalCode;
            
            //Check if Postal Code exist AND the recordtype of the Customer is JP On-trade
            if (validCustomer.ASI_CRM_PostalCode__c != null && postalJPCodeMap.containsKey(validCustomer.ASI_CRM_PostalCode__c) 
                && ValidCustomer.recordtypeid == Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_On_Trade_Outlet')) {
                postalCode = postalJPCodeMap.get(validCustomer.ASI_CRM_PostalCode__c);
            }
            
            String prefecture = postalCode != null ? 
                                    (postalCode.ASI_CRM_JP_Prefecture_EN__c != null ? 
                                        '_'+postalCode.ASI_CRM_JP_Prefecture_EN__c : '') : '';
            
            if (autoNumAssign == null) 
            {
                autoNumAssign = new ASI_CRM_JP_AutoNumberAssignment('ASI_CRM_JP_Customer_Code' + prefecture);
                validCustomer.ASI_CRM_CN_CRM_Code__c = autoNumAssign.nextAutoNumStr();
            }
        }
        
        if (autoNumAssign != null)
            autoNumAssign.writeToDB();
    }
}