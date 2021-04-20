/*********************************************************************************
 * Name:ASI_CRM_SG_CustomerTgrHdlrDel
 * Description: Customer Trigger Handler for CRM SG Delete Account
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/01/2015       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_CRM_SG_CustomerTgrHdlrDel extends ASI_CRM_SG_TriggerAbstract {

    public ASI_CRM_SG_CustomerTgrHdlrDel() {
        super('ASI_CRM_SG_CustomerTgrHdlrDelDel');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_CRM_AccountsAdditionalField__c> customerList = (List<ASI_CRM_AccountsAdditionalField__c>)sObjList;
        
        Set<ID> accoutnIDSet = new Set<ID>();
        
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            accoutnIDSet.add(customer.ASI_CRM_Account__c);
        }
        
        List<Account> accList = [SELECT ID, Name FROM Account WHERE ID IN : accoutnIDSet];
        
        if(accList.size() > 0) {
            delete accList;
        }
        
    }
}