/**
"If Is Prestige Account = TRUE, trigger executes to enable Read/Write Apex sharing of the Account with the Prestige SR

If Is Prestige Account = FALSE, trigger executes to remove Apex Sharing of the Account with Prestige SR"
*/
public class EUR_CRM_DE_PrestigeAccountHandler  extends EUR_CRM_TriggerAbstract {
     
    private static Set<String> allGermnayAccountRecordTypeSet = new Set<String>{
      'EUR_DE_ON_Consumers',
      'EUR_DE_ON_Enquiry_Acquisition',
      'EUR_DE_ON_Gastronomy', 
      'EUR_DE_ON_Service_agency',
      'EUR_DE_ON_Wholesaler'
    };
    private static Set<String> onTradePrestigeSalesRep = new Set<String>{
        'EUR_DE_GSL_Prestige'
    }; 

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(allGermnayAccountRecordTypeSet);

            return TRt;
        }private set;
    }

    /*
        insert new op - account mappings if
            new account and taxonomy has active op-
    */
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();
        Set<Id> recordOwner = new Set<Id>(); 

        for(Recordtype rt : accountRecordTypes){
           accountRecordTypesMap.put(rt.id,rt);
        }
        List<EUR_CRM_Account__c> validAccounts = new List<EUR_CRM_Account__c>();
        List<EUR_CRM_Account__Share> euAcctSharelist = new List<EUR_CRM_Account__Share>();
        List<EUR_CRM_Account__Share> euAcctSharelistDelete = new List<EUR_CRM_Account__Share>();
        List<AccountShare> stdAcctSharelist = new List<AccountShare>();
        List<AccountShare> stdAcctSharelistDelete = new List<AccountShare>();

        Set<Id> euAccountToShare = new Set<Id>();
        Set<Id> euAccountToUnShare = new Set<Id>();
        Set<Id> euAccounts = new Set<Id>();
        Set<String> euAccountPostalCodes = new Set<String>();
        
        Map<Id,Id> previousPrestigeUnShare = new Map<Id,Id>();

        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){
            recordOwner.add(euAccount.OwnerId);
            if(allGermnayAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.recordtypeid).developername)){
                euAccounts.add(euAccount.id);
                if(Trigger.IsInsert && euAccount.EUR_CRM_Is_Prestige_Account__c){
                    euAccountToShare.add(euAccount.id);
                    euAccountPostalCodes.add(euAccount.eur_crm_postal_code__c);
                }
                if(Trigger.IsUpdate){
                    EUR_CRM_Account__c oldEuAccount = (EUR_CRM_Account__c ) oldMap.get(euAccount.id);                     
                    if(euAccount.EUR_CRM_Is_Prestige_Account__c != oldEuAccount.EUR_CRM_Is_Prestige_Account__c ||
                        euAccount.eur_crm_postal_code__c != oldEuAccount.eur_crm_postal_code__c
                        || euAccount.ownerid != oldEuAccount.ownerid
                        || euAccount.EUR_CRM_Prestige_Sales_Rep_ID__c != oldEuAccount.EUR_CRM_Prestige_Sales_Rep_ID__c
                        ){                   
                        
                        if(euAccount.EUR_CRM_Is_Prestige_Account__c){ 
                            euAccountToShare.add(euAccount.id);
                            if(euAccount.EUR_CRM_Prestige_Sales_Rep_ID__c != oldEuAccount.EUR_CRM_Prestige_Sales_Rep_ID__c){
                                previousPrestigeUnShare.put(euAccount.id,oldEuAccount.EUR_CRM_Prestige_Sales_Rep_ID__c);
                            }           
                        }
                        else{
                            euAccountToUnShare.add(euAccount.id);        
                        }
                        euAccountPostalCodes.add(euAccount.eur_crm_postal_code__c); 
                    }
                }
            }
        }

        // A map of the User Roles of record owners
        Map<Id, String> userRole = new Map<Id, String>();
        for(User usr :[Select Id, UserRole.DeveloperName From User Where Id IN :recordOwner]){
            system.debug('user Role ' + usr.UserRole.DeveloperName);
            userRole.put(usr.Id, usr.UserRole.DeveloperName);
        }
        system.debug('@@ euAccountToUnShare: ' + euAccountToUnShare);
        system.debug('@@ euAccountToShare: ' + euAccountToShare);
        system.debug('@@ euAccountPostalCodes: ' + euAccountPostalCodes);
        system.debug('@@ previousPrestigeUnShare: ' + previousPrestigeUnShare);
        
        Map<String,Id> prestigePostalOwnerMap = new Map<String,Id>();
        
        if(euAccountPostalCodes.size() >0){
            system.debug('@@@# Flag 1');
            for(EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeMapping: [select EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c,EUR_CRM_Postal_Code__c from EUR_CRM_Postal_Code_Territory_Mapping__c
            where EUR_CRM_Postal_Code__c in:euAccountPostalCodes and recordtype.developername = 'EUR_DE_On_Trade_Prestige_Postal_Code_Territory_Mapping']){
                prestigePostalOwnerMap.put(postalCodeMapping.EUR_CRM_Postal_Code__c,postalCodeMapping.EUR_CRM_Territory__r.EUR_CRM_Territory_Owner__c);
            }
        }

        Map<Id,Id> euAccountToAccountMap = new Map<Id,Id>();
        Map<Id,Id> accountToEUAccountMap = new Map<Id,Id>();

        if(euAccounts.size() > 0){
            for(EUR_CRM_Account_Link__c link: [select EUR_CRM_Standard_Account__c,EUR_CRM_EU_Account__c from EUR_CRM_Account_Link__c where EUR_CRM_EU_Account__c in:euAccounts ]){
                euAccountToAccountMap.put(link.EUR_CRM_EU_Account__c, link.EUR_CRM_Standard_Account__c);
                accountToEUAccountMap.put(link.EUR_CRM_Standard_Account__c, link.EUR_CRM_EU_Account__c);
            }
        }
        if(prestigePostalOwnerMap.size() > 0){
            for(Id euAccountId : euAccountToShare){  
                EUR_CRM_Account__c euAccount = (EUR_CRM_Account__c) newMap.get(euAccountId);
                Id userShare = prestigePostalOwnerMap.get(euAccount.eur_crm_postal_code__c);
                system.debug('!! prestige user: ' + userShare + '!!' + euAccount.ownerId);
                
                if(userShare != null && euAccount.ownerID != userShare){
                    //eu account
                    euAcctSharelist.add(createEUAcctShare(euAccountId,userShare));
                    //std account
                    Id stdAcctId = euAccountToAccountMap.get(euAccount.id);
                    // create a sharing rule between the pres sales rep and the std account
                    // IF the account is prestige but the  sales rep is not
                    if(stdAcctId != null && euAccount.EUR_CRM_Is_Prestige_Account__c && !onTradePrestigeSalesRep.contains(UserRole.get(euAccount.OwnerId))) {
                        stdAcctSharelist.add(createAcctShare(stdAcctId, userShare));
                    }
                }
            }
            /*system.debug('@@ euAcctSharelist: ' + euAcctSharelist);
            if(euAcctSharelist.size() >0 ) 
                insert euAcctSharelist;
            if(stdAcctSharelist.size() >0 )
                insert stdAcctSharelist;*/
			// Delete old sharing rules             
            Set<Id> pIds = new Set<Id>(); // eu account ids
            Set<Id> aIds = new Set<Id>(); //std account ids
            Set<Id> uIds = new Set<Id>(); // user ids
            
            for(Id euAccountId : euAccountToUnShare){
                EUR_CRM_Account__c euAccount = (EUR_CRM_Account__c) newMap.get(euAccountId);
                Id userShare =  ((EUR_CRM_Account__c) oldMap.get(euAccountId)).EUR_CRM_Prestige_Sales_Rep_ID__c ;// prestigePostalOwnerMap.get(euAccount.eur_crm_postal_code__c);
                pIds.add(euAccountId);
                aIds.add(euAccountToAccountMap.get(euAccountId));      
                if(userShare != null && euAccount.ownerID != userShare)
                    uIds.add(userShare);
            }

            for(Id euAccountId: previousPrestigeUnShare.keySet()){
                pIds.add(euAccountId);
                aIds.add(euAccountToAccountMap.get(euAccountId));  
                uIds.add(previousPrestigeUnShare.get(euAccountId));
            }

            if(pIds.size() >0 && uIds.size() >0){
                for(EUR_CRM_Account__Share aShare : [select RowCause, id,ParentId,UserOrGroupId from EUR_CRM_Account__Share where parentid in: pIds and UserOrGroupId in:uIds]){
                    EUR_CRM_Account__c euAccount = (EUR_CRM_Account__c) newMap.get(aShare.parentid);
                    if(prestigePostalOwnerMap.get(euAccount.eur_crm_postal_code__c) == aShare.UserOrGroupId){
                        euAcctSharelistDelete.add(aShare);
                    }else if(previousPrestigeUnShare.get(aShare.parentid) == aShare.UserOrGroupId){
                        euAcctSharelistDelete.add(aShare);
                    }
                }
            }
            if(aIds.size() >0 && uIds.size() >0){
                for(AccountShare aShare : [select RowCause, id,AccountId,UserOrGroupId from AccountShare where AccountId in: aIds and UserOrGroupId in:uIds and rowCause = 'Manual']){
                    EUR_CRM_Account__c euAccount = (EUR_CRM_Account__c) newMap.get(accountToEUAccountMap.get(aShare.AccountId));
                    if(euAccount != null){
                        if(prestigePostalOwnerMap.get(euAccount.eur_crm_postal_code__c) == aShare.UserOrGroupId && aShare.UserOrGroupId != euAccount.ownerId){
                            stdAcctSharelistDelete.add(aShare);
                        } else   if(previousPrestigeUnShare.get(euAccount.id) == aShare.UserOrGroupId && aShare.UserOrGroupId != euAccount.ownerId){
                            stdAcctSharelistDelete.add(aShare);
                        }                      
                    }
                }
            }
            
            system.debug('@@ pIds: ' + pIds );
            system.debug('@@ aIds : ' + aIds );
            system.debug('@@ uIds : ' + uIds );
            
            if(euAcctSharelistDelete.size() >0){ 
                system.debug('@@ euAcctSharelistDelete: ' + euAcctSharelistDelete);
                delete euAcctSharelistDelete;
                
            }
            if(stdAcctSharelistDelete.size() >0){ 
                system.debug('@@ stdAcctSharelistDelete size: ' + stdAcctSharelistDelete.size());
                system.debug('@@ stdAcctSharelistDelete: ' + stdAcctSharelistDelete);
                delete stdAcctSharelistDelete;
                
            }

            // Create new sharing rules
            system.debug('@@ euAcctSharelist: ' + euAcctSharelist);
            system.debug('@@ stdAcctSharelist: ' + stdAcctSharelist);
            if(euAcctSharelist.size() >0 ) 
                insert euAcctSharelist;
            if(stdAcctSharelist.size() >0 )
                insert stdAcctSharelist;
        }
    }
    
    public EUR_CRM_DE_PrestigeAccountHandler(){
        super('EUR_CRM_DE_PrestigeAccountHandler');
    }
    
    private EUR_CRM_Account__Share createEUAcctShare(Id euAccountId, Id userOrGroupId){
      EUR_CRM_Account__Share teamMember = new EUR_CRM_Account__Share();
      teamMember.AccessLevel = 'Edit';
      teamMember.ParentId = euAccountId;
      teamMember.UserOrGroupId = userOrGroupId;
      return teamMember;
    }
    private  AccountShare createAcctShare(Id accountId, Id userOrGroupId){
      AccountShare teamMember = new AccountShare();
      teamMember.AccountAccessLevel = 'Edit';
      teamMember.AccountId = accountId;
      teamMember.OpportunityAccessLevel = 'None';
      teamMember.UserOrGroupId = userOrGroupId;
      return teamMember;
    }
    
    
}