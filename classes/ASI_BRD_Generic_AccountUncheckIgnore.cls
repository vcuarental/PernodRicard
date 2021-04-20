/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountUncheckIgnore
 * Description: Uncheck Ingore checkbox after save
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/09/2015       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_BRD_Generic_AccountUncheckIgnore extends ASI_BRD_Generic_TriggerAbstract {

    public ASI_BRD_Generic_AccountUncheckIgnore() {
        super('ASI_BRD_Generic_AccountUncheckIgnore');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<Account> accList = (List<Account>)sObjList;
        Set<Id> accToBeUdId = new Set<Id>();
        if(oldMap == null){
            for(Account acc:accList){
                if(acc.ASI_BRD_Ignore_Matching_Records__pc){
                    accToBeUdId.add(acc.Id);
                }   
            }
        }else{
            Map<Id, Account> oldAccMap = (Map<Id, Account>) oldMap;
            for(Account acc:accList){
                if(acc.ASI_BRD_Ignore_Matching_Records__pc){
                    if(acc.ASI_LUX_Email_Business__c != oldAccMap.get(acc.Id).ASI_LUX_Email_Business__c || acc.Phone != oldAccMap.get(acc.Id).Phone
                            || acc.PersonMobilePhone != oldAccMap.get(acc.Id).PersonMobilePhone || acc.PersonEmail != oldAccMap.get(acc.Id).PersonEmail){
                        accToBeUdId.add(acc.Id);
                    }
                }
            } 
        }
        List<Account> accToBeUdList = [Select Id, ASI_BRD_Ignore_Matching_Records__pc From Account Where Id In :accToBeUdId];
        for(Account acc:accToBeUdList){
            acc.ASI_BRD_Ignore_Matching_Records__pc = false;  
        }
        if(accToBeUdList.size() > 0){
            update accToBeUdList;
        }
    }
}