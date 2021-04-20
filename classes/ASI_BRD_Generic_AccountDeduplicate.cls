/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountDeduplicate
 * Description: checking duplicated records for account insert/update
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/09/2015       Laputa: Hank          Created
*********************************************************************************/

public with sharing class ASI_BRD_Generic_AccountDeduplicate extends ASI_BRD_Generic_TriggerAbstract {

    public ASI_BRD_Generic_AccountDeduplicate() {
        super('ASI_BRD_Generic_AccountDeduplicate');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<Account> accList = (List<Account>)sObjList;
        Set<String> emailSet = new Set<String>();
        Set<String> busEmailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> mobileSet = new Set<String>();
        Set<Id> rtIdSet = new Set<Id>();
        Id profileId = userinfo.getProfileId();
        Profile p = [Select Name From Profile Where Id = :profileId]; 
        Map<String, ASI_BRD_Generic_CRM_Default_Values__c> valuesMap = ASI_BRD_Generic_CRM_Default_Values__c.getAll();
        if(oldMap == null && !p.Name.contains('Marketo Sync')){
            for(Account acc:accList){
                if(!acc.ASI_BRD_Ignore_Matching_Records__pc){
                    emailSet.add(acc.PersonEmail);
                    busEmailSet.add(acc.ASI_LUX_Email_Business__c);
                    phoneSet.add(acc.ASI_BRD_Phone_Business__pc);
                    mobileSet.add(acc.PersonMobilePhone);
                    rtIdSet.add(acc.recordtypeid);
                }   
            }
        }else if(!p.Name.contains('Marketo Sync')){
            Map<Id, Account> oldAccMap = (Map<Id, Account>) oldMap;
            for(Account acc:accList){
                System.debug('Acc: ' + acc); 
                System.debug('Ignore: ' + acc.ASI_BRD_Ignore_Matching_Records__pc);
                if(!acc.ASI_BRD_Ignore_Matching_Records__pc){
                    if(acc.ASI_LUX_Email_Business__c != oldAccMap.get(acc.Id).ASI_LUX_Email_Business__c){
                        busEmailSet.add(acc.ASI_LUX_Email_Business__c);
                    }
                    if(acc.ASI_BRD_Phone_Business__pc != oldAccMap.get(acc.Id).ASI_BRD_Phone_Business__pc){
                        phoneSet.add(acc.ASI_BRD_Phone_Business__pc);
                    }
                    if(acc.PersonMobilePhone != oldAccMap.get(acc.Id).PersonMobilePhone){
                        mobileSet.add(acc.PersonMobilePhone);
                        system.debug('Old: ' + oldAccMap.get(acc.Id).PersonMobilePhone + ' New: ' + acc.PersonMobilePhone);
                    }
                    if(acc.PersonEmail != oldAccMap.get(acc.Id).PersonEmail){
                        emailSet.add(acc.PersonEmail);
                    }
                    rtIdSet.add(acc.recordtypeid);  
                }  
            }
        }
        List<Account> existAccList = [Select Id, Name, owner.Name, recordtypeid, PersonEmail, ASI_LUX_Email_Business__c, ASI_BRD_Phone_Business__pc, PersonMobilePhone From Account where (PersonEmail in :emailSet OR ASI_LUX_Email_Business__c in :busEmailSet OR ASI_BRD_Phone_Business__pc In :phoneSet OR PersonMobilePhone In :mobileSet) AND recordtypeid In :rtIdSet];
        system.debug('existAccList : ' + existAccList + ' size: ' + existAccList.size());
        if(existAccList.size() > 0 && !p.Name.contains('Marketo Sync')){
            for(Account acc:accList){
                if(!acc.ASI_BRD_Ignore_Matching_Records__pc){
                    String errMsg = '&nbsp;Matching records found </br>';
                    for(Account existAcc:existAccList){
                        if(existAcc.Id != acc.Id && existAcc.recordtypeid == acc.recordtypeid && ((existAcc.ASI_LUX_Email_Business__c == acc.ASI_LUX_Email_Business__c && existAcc.ASI_LUX_Email_Business__c != null) ||
                                (existAcc.ASI_BRD_Phone_Business__pc == acc.ASI_BRD_Phone_Business__pc && existAcc.ASI_BRD_Phone_Business__pc != null) || (existAcc.PersonMobilePhone == acc.PersonMobilePhone && existAcc.PersonMobilePhone != null) || (existAcc.PersonEmail == acc.PersonEmail && existAcc.PersonEmail != null))){
                            errMsg += 'Account Name: ' + '<a href=\'/' + existAcc.Id +'\'>' + existAcc.Name + '</a>' + '&nbsp;&nbsp;&nbsp;Email: ' + (existAcc.PersonEmail == null?'':existAcc.PersonEmail) + '&nbsp;&nbsp;&nbsp;Email (Business): ' + (existAcc.ASI_LUX_Email_Business__c == null?'':existAcc.ASI_LUX_Email_Business__c) + '&nbsp;&nbsp;&nbsp;Phone (Business): ' + (existAcc.ASI_BRD_Phone_Business__pc == null?'':existAcc.ASI_BRD_Phone_Business__pc) + '&nbsp;&nbsp;&nbsp;Mobile: ' + (existAcc.PersonMobilePhone == null?'':existAcc.PersonMobilePhone) + '&nbsp;&nbsp;&nbsp;Owner: ' + existAcc.owner.Name + '</br>';   
                        }
                    }
                    errMsg += '</br>If you want to go ahead to save the record, please tick \'Ignore Matching Records\' checkbox and click \'Save\' again.';
                    if(errMsg.contains('Account Name:')){
                        acc.addError(errMsg, false);
                    }
                }
            }
        }
    }
}