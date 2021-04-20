public without sharing class EUR_CRM_EUAccountLinkHandler extends EUR_CRM_TriggerAbstract {

    @TestVisible private static Boolean doRunOnce = false;
    private static Boolean runOnce = false;

    public EUR_CRM_EUAccountLinkHandler(){
        super('EUR_CRM_EUAccountLinkHandler');
    }
    
    // trigger to auto link Account and EU Account in a 1:1 manner
    // when insert eu account, create Account and create a junction to link Account and EU Account
    // when update eu account (owner or name), update the owner or name values on Account object
    // when delete eu account, delete the linked Account record
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if (runOnce == true && doRunOnce == true) {
            return ;
        }
        List<EUR_CRM_Account__c> acctlist = (List<EUR_CRM_Account__c>) sObjList;
        Map<Id, Account> euAcctId2AccountMap = new Map<Id, Account>();
        Set<Id> euAcctIdSet = new Set<Id>();
        List<EUR_CRM_Account_Link__c> acctlinklist = new List<EUR_CRM_Account_Link__c>();
        if(tAction == TriggerAction.AFTER_INSERT){
            for(EUR_CRM_Account__c acct : acctlist){
                system.debug('Flag 1: ' + acct.id);
                euAcctId2AccountMap.put(acct.Id, createStdAccount(acct));
            }
            if(euAcctId2AccountMap.size()>0){
                system.debug('Flag 2: ' + euAcctId2AccountMap.values().size());
                upsert euAcctId2AccountMap.values();
                for(EUR_CRM_Account__c acct : acctlist){
                    system.debug('Flag 3' + euAcctId2AccountMap.get(acct.Id));
                    if(euAcctId2AccountMap.get(acct.Id) != null)
                        system.debug('Flag 3' + euAcctId2AccountMap.get(acct.Id).id);
                    acctlinklist.add(createEuAccountLink(acct, euAcctId2AccountMap.get(acct.Id)));
                }
                if(acctlinklist.size()>0)
                    insert acctlinklist;
            }
            runOnce = true;
        }
        if(tAction == TriggerAction.AFTER_UPDATE){
            Map<Id, EUR_CRM_Account__c> oldAcctMap = (Map<Id, EUR_CRM_Account__c>) oldMap;
            Map<Id, EUR_CRM_Account__c> newAcctMap = (Map<Id, EUR_CRM_Account__c>) newMap;
            for(EUR_CRM_Account__c acct : acctlist){
                if(oldAcctMap.get(acct.Id).Name <> newAcctMap.get(acct.Id).Name 
                    || oldAcctMap.get(acct.Id).OwnerId <> newAcctMap.get(acct.Id).OwnerId 
                    || oldAcctMap.get(acct.Id).EUR_CRM_Group_Outlet_Type__c <> newAcctMap.get(acct.Id).EUR_CRM_Group_Outlet_Type__c 
                    || oldAcctMap.get(acct.Id).EUR_CRM_Volume_Potential__c <> newAcctMap.get(acct.Id).EUR_CRM_Volume_Potential__c 
                    || oldAcctMap.get(acct.Id).EUR_CRM_Image_Level__c <> newAcctMap.get(acct.Id).EUR_CRM_Image_Level__c
                    || oldAcctMap.get(acct.Id).EUR_CRM_Street__c <> newAcctMap.get(acct.Id).EUR_CRM_Street__c 
                    || oldAcctMap.get(acct.Id).EUR_CRM_Postal_Code__c <> newAcctMap.get(acct.Id).EUR_CRM_Postal_Code__c 
                    || oldAcctMap.get(acct.Id).EUR_CRM_City__c <> newAcctMap.get(acct.Id).EUR_CRM_City__c 
                    || oldAcctMap.get(acct.Id).EUR_CRM_Country__c <> newAcctMap.get(acct.Id).EUR_CRM_Country__c){
                    euAcctIdSet.add(acct.Id);           
                }   
            }
            if(euAcctIdSet.size()>0){
                for(EUR_CRM_Account_Link__c acctlink : [Select EUR_CRM_Standard_Account__c, EUR_CRM_EU_Account__c  
                    From EUR_CRM_Account_Link__c Where EUR_CRM_EU_Account__c in: euAcctIdSet]){
                    euAcctId2AccountMap.put(acctlink.EUR_CRM_EU_Account__c, new Account(id=acctlink.EUR_CRM_Standard_Account__c));      
                }
                for(EUR_CRM_Account__c acct : acctlist){
                    Account a = euAcctId2AccountMap.get(acct.Id);
                    if(a != null){
                        a.OwnerId = acct.OwnerId;
                        a.Name = acct.Name;
                        a.EUR_CRM_Group_Outlet_Type__c = acct.EUR_CRM_Group_Outlet_Type_Name__c;
                        a.EUR_CRM_Volume_Potential__c = acct.EUR_CRM_Volume_Potential_Name__c;
                        a.EUR_CRM_Image_Level__c = acct.EUR_CRM_Image_Level_Name__c;
                        a.BillingStreet = acct.EUR_CRM_Street__c;
                        a.BillingPostalCode = acct.EUR_CRM_Postal_Code__c;
                        a.BillingCity = acct.EUR_CRM_City__c;
                        a.BillingCountry = acct.EUR_CRM_Country__c;
                        euAcctId2AccountMap.put(acct.Id, a);
                    }
                }
                update euAcctId2AccountMap.values();
            }
            runOnce = true;
        }
        if(tAction == TriggerAction.BEFORE_DELETE){
            for(EUR_CRM_Account__c acct : acctlist){
                euAcctIdSet.add(acct.Id);
            }
            if(euAcctIdSet.size()>0){
                Map<Id, Account> acctMap = new Map<Id, Account>();
                for(EUR_CRM_Account_Link__c acctlink : [Select EUR_CRM_Standard_Account__c   
                    From EUR_CRM_Account_Link__c Where EUR_CRM_EU_Account__c in: euAcctIdSet]){
                    acctMap.put(acctlink.EUR_CRM_Standard_Account__c, new Account(id=acctlink.EUR_CRM_Standard_Account__c));        
                }
                if(acctMap.size()>0)
                    delete acctMap.values();
            }
            runOnce = true;
        }
        
    }
    
    private Account createStdAccount(EUR_CRM_Account__c euAcct){
        Account a = new Account(name=euAcct.Name, ownerId = euAcct.OwnerId);
        a.RecordTypeId = EUR_CRM_AccountUtils.EUR_CRM_GENERAL_RECORDTYPE.RecordTypeId;
        return a;
    }
    
    private EUR_CRM_Account_Link__c createEuAccountLink(EUR_CRM_Account__c euAcct, Account acct){
        EUR_CRM_Account_Link__c acctlink = new EUR_CRM_Account_Link__c();
        acctlink.EUR_CRM_EU_Account__c = euAcct.Id;
        acctlink.EUR_CRM_Standard_Account__c = acct.Id;
        return acctlink;
    }
}