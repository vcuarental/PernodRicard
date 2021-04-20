public without sharing class EUR_CRM_NG_ShareEUAccountHandler extends EUR_CRM_TriggerAbstract {
    private static final String ON_TRADE = 'ON TRADE';
    private static final String OFF_TRADE = 'OFF TRADE';
    private static final String TERRITORY_NG_DEV_NAME = 'EUR_CRM_NG_Territory';
    private static final String EUACCOUNT_NG_ON_TRADE = 'EUR_NG_On_Trade';
    private static final String IMAGELEVELMAINSTREAM = 'Mainstream';
    private static Set<String> allEUAccountRecordTypeSet = new Set<String>{
          'EUR_NG_On_Trade'
    };
        
    public static Set<String> TargetRecordSet {
        get{ return new Set<String>(allEUAccountRecordTypeSet);}
        private set;
    }

    public EUR_CRM_NG_ShareEUAccountHandler(){
        super('EUR_CRM_NG_ShareEUAccountHandler');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){ 
        /*System.Debug('EUR_CRM_NG_ShareEUAccountHandler');
        List<EUR_CRM_Account__c> euAccounts = new List<EUR_CRM_Account__c>();
        Set<Id> unShareUserIds = new Set<Id>();

        if(tAction == TriggerAction.AFTER_INSERT){
            euAccounts.addAll(filterAccountOnInsert((List<EUR_CRM_Account__c>)sObjList));
        }else if(tAction == TriggerAction.AFTER_UPDATE){
            euAccounts.addAll(filterAccountOnUpdate((List<EUR_CRM_Account__c>)sObjList, (Map<Id, EUR_CRM_Account__c>)oldMap));
            Map<Id, EUR_CRM_Account__c> oldMapAcc = (Map<Id, EUR_CRM_Account__c>)oldMap;
            for(EUR_CRM_Account__c euAccount: euAccounts){
                if(String.isNotBlank(oldMapAcc.get(euAccount.Id).EUR_CRM_Territory_KD_Owner__c)) {
                    unShareUserIds.add(oldMapAcc.get(euAccount.Id).EUR_CRM_Territory_KD_Owner__c);
                }
            }
        }
        
        if(!euAccounts.isEmpty()){
            populateAccountEUShare(euAccounts, unShareUserIds, false);
        }
        */
    }
/*
    private static List<EUR_CRM_Account__c> filterAccountOnInsert(List<EUR_CRM_Account__c> euAccounts){
       List<EUR_CRM_Account__c> euAccts = new List<EUR_CRM_Account__c>();
        for(EUR_CRM_Account__c euAccount: euAccounts){
            if(euAccount.EUR_CRM_RTDevName__c == EUACCOUNT_NG_ON_TRADE && 
                        String.isNotBlank(euAccount.EUR_CRM_Image_Level_Name__c) &&
                        euAccount.EUR_CRM_Image_Level_Name__c != IMAGELEVELMAINSTREAM && 
                        euAccount.EUR_CRM_Channel__c == ON_TRADE &&
                        euAccount.EUR_CRM_Territory__c != null &&
                        euAccount.EUR_CRM_RTTerritoryDevName__c == TERRITORY_NG_DEV_NAME){
                euAccts.add(euAccount);
            }
        }
        return euAccts;
    }

    private static List<EUR_CRM_Account__c> filterAccountOnUpdate(List<EUR_CRM_Account__c> euAccounts, Map<Id, EUR_CRM_Account__c> oldMap){
        List<EUR_CRM_Account__c> euAccts = new List<EUR_CRM_Account__c>();
        /*for(EUR_CRM_Account__c euAccount: euAccounts){
            EUR_CRM_Account__c oldEuAccount = (EUR_CRM_Account__c) oldMap.get(euAccount.Id);
            if(euAccount.EUR_CRM_RTDevName__c == EUACCOUNT_NG_ON_TRADE && 
                        String.isNotBlank(euAccount.EUR_CRM_Image_Level_Name__c) &&
                        euAccount.EUR_CRM_Image_Level_Name__c != IMAGELEVELMAINSTREAM && 
                        euAccount.EUR_CRM_Territory__c != null &&
                        (String.isBlank(oldEuAccount.EUR_CRM_Image_Level_Name__c) ||
                        euAccount.EUR_CRM_Territory__c != oldEuAccount.EUR_CRM_Territory__c) ){
                euAccts.add(euAccount);
            }
        }
        return euAccts;
    }*/

    public static void populateAccountEUShare(List<EUR_CRM_Account__c> euAccounts, Set<Id> unShareUserIds, Boolean forceCreate){
        /*List<EUR_CRM_Account__Share> euAcctSharelistDelete = new List<EUR_CRM_Account__Share>();
        List<AccountShare> stdAcctSharelistDelete = new List<AccountShare>();
        List<EUR_CRM_Account__Share> euAcctSharelist = new List<EUR_CRM_Account__Share>();
        List<AccountShare> stdAcctSharelist = new List<AccountShare>();

        unShareUserIds.remove(null);
        System.debug('@@@ unShareUserIds: ' + unShareUserIds);

        Map<Id,Id> euAccountToAccountMap = new Map<Id,Id>();
        Map<Id,Id> accountToEUAccountMap = new Map<Id,Id>();
        if(euAccounts.size() > 0){
            for(EUR_CRM_Account_Link__c link: [select EUR_CRM_Standard_Account__c,EUR_CRM_EU_Account__c from EUR_CRM_Account_Link__c where EUR_CRM_EU_Account__c in :euAccounts]){
                euAccountToAccountMap.put(link.EUR_CRM_EU_Account__c, link.EUR_CRM_Standard_Account__c);
                accountToEUAccountMap.put(link.EUR_CRM_Standard_Account__c, link.EUR_CRM_EU_Account__c);
            }
        }

        if(!euAccountToAccountMap.isEmpty() && !unShareUserIds.isEmpty()){
            for(EUR_CRM_Account__Share aShare : [select RowCause, id,ParentId,UserOrGroupId from EUR_CRM_Account__Share where parentid in: euAccountToAccountMap.keyset() and UserOrGroupId in:unShareUserIds and rowCause = 'Manual']){
                euAcctSharelistDelete.add(aShare);
            }
            for(AccountShare aShare : [select RowCause, id,AccountId,UserOrGroupId from AccountShare where AccountId in: accountToEUAccountMap.keyset() and UserOrGroupId in:unShareUserIds and rowCause = 'Manual']){
                stdAcctSharelistDelete.add(aShare);
            }            
        }
        System.debug('@@@ EUSHARE: '+euAcctSharelistDelete);
        System.debug('@@@ STD ACTSHARE: '+euAcctSharelistDelete);

        if(euAcctSharelistDelete.size() > 0){
            delete euAcctSharelistDelete;
        }
        if(stdAcctSharelistDelete.size() > 0){
            delete stdAcctSharelistDelete;
        }

        for(EUR_CRM_Account__c euAccount: euAccounts){
            // Only grant access to account which doesn't already belong to the KD owner
            if(forceCreate==true || (String.isNotBlank(euAccount.EUR_CRM_Territory_KD_Owner__c) && euAccount.EUR_CRM_Territory_KD_Owner__c!=euAccount.OwnerId)){
                euAcctSharelist.add(createEUAcctShare(euAccount.Id, euAccount.EUR_CRM_Territory_KD_Owner__c));
                stdAcctSharelist.add(createAcctShare(euAccountToAccountMap.get(euAccount.Id), euAccount.EUR_CRM_Territory_KD_Owner__c));
            }
        }
 
        if(euAcctSharelist.size() > 0){
            Database.insert(euAcctSharelist, false);
        }
        if(stdAcctSharelist.size() > 0){
            Database.insert(stdAcctSharelist, false);
        }
*/
    }
/*
    @testVisible private static EUR_CRM_Account__Share createEUAcctShare(Id euAccountId, Id userOrGroupId){
      EUR_CRM_Account__Share teamMember = new EUR_CRM_Account__Share();
      teamMember.AccessLevel = 'Edit';
      teamMember.ParentId = euAccountId;
      teamMember.UserOrGroupId = userOrGroupId;
      return teamMember;
    }

    @testVisible private  static AccountShare createAcctShare(Id accountId, Id userOrGroupId){
      AccountShare teamMember = new AccountShare();
      teamMember.AccountAccessLevel = 'Edit';
      teamMember.AccountId = accountId;
      teamMember.OpportunityAccessLevel = 'None';
      teamMember.UserOrGroupId = userOrGroupId;
      return teamMember;
    }*/

}