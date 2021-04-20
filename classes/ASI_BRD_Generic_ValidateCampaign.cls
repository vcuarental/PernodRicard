/*********************************************************************************
 * Name:ASI_BRD_Generic_ValidateCampaign
 * Description: Valiadte ASI_BRD_Salesforce_Campaign_Reference__pc for person account
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * March 16, 2016       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_BRD_Generic_ValidateCampaign extends ASI_BRD_Generic_TriggerAbstract {

    public ASI_BRD_Generic_ValidateCampaign() {
        super('ASI_BRD_Generic_ValidateCampaign');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<Account> accList = (List<Account>)sObjList;
        List<String> camStrList = new list<String>();
        if(oldMap == null){
            for(Account acc:accList){
                if(acc.ASI_BRD_Salesforce_Campaign_Reference__pc != null){
                    camStrList.add(acc.ASI_BRD_Salesforce_Campaign_Reference__pc);
                }
            }
        }else{
            Map<Id, Account> oldAccMap = (Map<Id, Account>) oldMap;
            for(Account acc:accList){
                if(acc.ASI_BRD_Salesforce_Campaign_Reference__pc != null && acc.ASI_BRD_Salesforce_Campaign_Reference__pc != oldAccMap.get(acc.Id).ASI_BRD_Salesforce_Campaign_Reference__pc){
                    camStrList.add(acc.ASI_BRD_Salesforce_Campaign_Reference__pc);
                }    
            }
        }
        Map<String, Campaign> camMap = new Map<String, Campaign>();
        for(Campaign cam:[Select Id, Name from Campaign Where Name In :camStrList And (Recordtype.DeveloperName Like '%ASI_LUX_%' OR Recordtype.DeveloperName Like '%ASI_BRD_%')]){
            camMap.put(cam.Name, cam);
        }
        if(oldMap == null){
            for(Account acc:accList){
                if(acc.ASI_BRD_Salesforce_Campaign_Reference__pc != null && camMap.get(acc.ASI_BRD_Salesforce_Campaign_Reference__pc) == null){
                    acc.addError('Please input a valid Campaign Name in Acquisition Campaign.');  
                }
            }
        }else{
            Map<Id, Account> oldAccMap = (Map<Id, Account>) oldMap;
            for(Account acc:accList){
                if(acc.ASI_BRD_Salesforce_Campaign_Reference__pc != null && acc.ASI_BRD_Salesforce_Campaign_Reference__pc != oldAccMap.get(acc.Id).ASI_BRD_Salesforce_Campaign_Reference__pc &&
                        camMap.get(acc.ASI_BRD_Salesforce_Campaign_Reference__pc) == null){
                    acc.addError('Please input a valid Campaign Name in Acquisition Campaign.');  
                }    
            }
        }
    }
}