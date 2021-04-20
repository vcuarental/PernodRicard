/*********************************************************************************
 * Name: ASI_CRM_JP_DeleteAccCusDirAfterCus
 * Description: Delete Account and Customer Directory after Customer is deleted (JP CRM)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 20/11/2014       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_CRM_JP_DeleteAccCusDirAfterCus extends ASI_CRM_JP_TriggerAbstract {

    public ASI_CRM_JP_DeleteAccCusDirAfterCus() {
        super('ASI_CRM_JP_DeleteAccCusDirAfterCus');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_CRM_AccountsAdditionalField__c> cList = (List<ASI_CRM_AccountsAdditionalField__c>)oldMap.Values();
        Set<Id> accSet = new Set<Id>();
        Set<Id> cusSet = new Set<Id>();
        for (ASI_CRM_AccountsAdditionalField__c c:cList) {
            accSet.add(c.ASI_CRM_Account__c);
            cusSet.add(c.Id);
        }
        List<Account> accList = [Select Id From Account Where Id In :accSet];
        List<ASI_CRM_Customer_Directory__c> cusDirList = [Select Id, Name From ASI_CRM_Customer_Directory__c Where ASI_CRM_Customer__c In :cusSet];
        //system.debug('Check 1: ' + cusDirList);
        delete accList;
        delete cusDirList;
        //system.debug('Check 2: ' + cusDirList);
    }
    
}