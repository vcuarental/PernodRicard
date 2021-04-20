/*********************************************************************************
 * Name:ASI_CRM_SG_CustomerTgrHdlr
 * Description: Customer Trigger Handler for CRM SG
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/11/2014       Laputa: Christina       Created
 * 13/03/2019       Wilken Lee          	[WL 1.0] Remove Account linkage to Customer
*********************************************************************************/

public with sharing class ASI_CRM_SG_CustomerTgrHdlr extends ASI_CRM_SG_TriggerAbstract {

    public ASI_CRM_SG_CustomerTgrHdlr() {
        super('ASI_CRM_SG_CustomerTgrHdlr');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        /*[WL 1.0] BEGIN*/
        /*List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;
        
        Map<String, ASI_CRM_AccountsAdditionalField__c> customerNameMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        Map<String, account> accountNameMap = new Map<String, account>();
        
        // Create unique ID in case the multiple customer names are identical in one bulk
        Integer counter = 0;
        ASI_CRM_Default_Value__c defaultValue = ASI_CRM_Default_Value__c.getValues('ASI_CRM_SG_Account_Default_Owner_ID');
        String defaultOwnerID ;
        
        if (defaultValue != null && defaultValue.ASI_CRM_Value__c != null)
            defaultOwnerID = defaultValue.ASI_CRM_Value__c;
        else 
            defaultOwnerID = UserInfo.getUserId();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            ID accRecordtypeID;
            
            // Choose what recordtypeID it will be
            if(Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_SG_Potential_Outlet')) {
                accRecordtypeID = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Potential_Outlet');
            } else if(Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_SG_Wholesaler')) {
                accRecordtypeID = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Wholesaler');
            } else if(Global_RecordTypeCache.getRt(customer.recordTypeid).developerName.contains('ASI_CRM_SG_Outlet')) {
                accRecordtypeID = Global_RecordTypeCache.getRtId('AccountASI_CRM_SG_Outlet');
            }
            
            if(!customerNameMap.containsKey(customer.name)) {
                Account acc = new account(
                                            name = customer.name,
                                            recordtypeid = accRecordtypeID,
                                            ownerID = defaultOwnerID
                                          );
                                          
                customerNameMap.put(customer.name, customer);
                accountNameMap.put(customer.name, acc);
            } else {
                Account acc = new account(
                                            name = customer.name,
                                            recordtypeid = accRecordtypeID,
                                            ownerID = defaultOwnerID
                                          );
                                          
                customerNameMap.put(customer.name+(String.valueof(counter)), customer);
                accountNameMap.put(customer.name+(String.valueof(counter)), acc);
                counter++;
            }
        }
        
        if(accountNameMap.size() > 0) {
            insert accountNameMap.values();
        }
        
        Map<String, ASI_CRM_AccountsAdditionalField__c> tempCustomerNameMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        Integer tempCounter = 0;
        
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
        
            if(!tempCustomerNameMap.containsKey(customer.name)) {
                customer.ASI_CRM_Account__c = accountNameMap.get(customer.name).id;
            } else {                     
                tempCustomerNameMap.put(customer.name+(String.valueof(tempCounter)), customer);
                customer.ASI_CRM_Account__c = accountNameMap.get(customer.name+(String.valueof(tempCounter))).id;
                tempCounter++;
            }
        }*/
		/*[WL 1.0] END*/
    }
    
}