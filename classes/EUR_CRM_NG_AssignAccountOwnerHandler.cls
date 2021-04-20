/*********************************************************************************
 * Name:EUR_CRM_NG_AssignAccountOwnerHandler 
 * Description: Trigger Class to update the owner and sharing access of the account related to the territories
 * Field to Update:
 * On trade Owner = Owner change to All related Account On Trade Recordtypes
 * Off Trade owner = Owner change to All related Account On Trade Recordtypes
 * KD Owner = Share edit rights to all the related Account (any recordtypes)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/30/2015        Laputa: Conrad          Added Comment Header
**********************************************************************************/
public without sharing class EUR_CRM_NG_AssignAccountOwnerHandler extends EUR_CRM_TriggerAbstract {

    public EUR_CRM_NG_AssignAccountOwnerHandler(){
        super('EUR_CRM_NG_AssignAccountOwnerHandler');
    } 

    private static String ACCOUNT_NG_ON_TRADE = 'EUR_NG_On_Trade';
    private static String ACCOUNT_NG_OFF_TRADE_TRADITIONAL = 'EUR_NG_Off_Trade_Traditional';
    private static String ACCOUNT_NG_OFF_TRADE_BULK_BREAKER = 'EUR_NG_Off_Trade_Bulk_Breaker';
	
    /*
    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.add(ACCOUNT_NG_ON_TRADE);
            TRt.add(ACCOUNT_NG_OFF_TRADE_TRADITIONAL);
            TRt.add(ACCOUNT_NG_OFF_TRADE_BULK_BREAKER);
            return TRt;
        }private set;
    }*/



    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){ 
        /*
        List<EUR_CRM_Account__c> acctList = (List<EUR_CRM_Account__c>)sObjList;
        Set<ID> territoryIDsSet = new Set<ID>();
        
        for(EUR_CRM_Account__c acc : acctList) {
        	if(acc.EUR_CRM_Territory__c != null) {
        		territoryIDsSet.add(acc.EUR_CRM_Territory__c);
        	}
        	
        }
        
        Map<ID, EUR_CRM_Territory__c> territoryMap = new Map<ID, EUR_CRM_Territory__c>([SELECT ID, Name, EUR_CRM_Off_Trade_Owner__c, EUR_CRM_On_Trade_Owner__c, EUR_CRM_KD_Owner__c
        																					FROM EUR_CRM_Territory__c
        																					WHERE ID IN : territoryIDsSet]);
        
        Set<String> sharingAccountEUKeys;
        Set<String> sharingAccountStdKeys;
        //List<EUR_CRM_Account__c> acctToUpdateList = new List<EUR_CRM_Account__c>();
        
        //Set<ID> territoryIDSet = new Set<ID>();
        Map<Id,Id> accountTerritoryShare = new Map<Id,Id>();

        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();

        List<EUR_CRM_Account__Share> euAcctSharelist = new List<EUR_CRM_Account__Share>();
        List<AccountShare> stdAcctSharelist = new List<AccountShare>();

        for(Recordtype rt : accountRecordTypes){ 
           accountRecordTypesMap.put(rt.id,rt);
        }
		
		// Code to retrieve image level
		Set<ID> imageLevelIDs = new Set<ID>();
		Map<ID, EUR_CRM_Image_Level__c> imageLevelMap = new Map<ID, EUR_CRM_Image_Level__c>();
		for (EUR_CRM_Account__c acct : acctList){    
			if(acct.EUR_CRM_Image_Level__c != null) {
				imageLevelIDs.add(acct.EUR_CRM_Image_Level__c);
			}
		}
		
		if(imageLevelIDs.size() > 0) {
			imageLevelMap = new Map<ID, EUR_CRM_Image_Level__c>([SELECT ID, Name, EUR_CRM_Affiliate_Country__c, EUR_CRM_Name__c, EUR_CRM_External_ID__c
																	FROM EUR_CRM_Image_Level__c
																	WHERE ID IN : imageLevelIDs]);
		}
		
        for (EUR_CRM_Account__c acct : acctList){   
            if (acct.EUR_CRM_Territory__c != null){
            	// Make on trade owner of Territory, the account owner for NG ON TRADE recordtypes
                if(accountRecordTypesMap.get(acct.RecordTypeId).DeveloperName == ACCOUNT_NG_ON_TRADE){
                	
                	if(imageLevelMap.containsKey(acct.EUR_CRM_Image_Level__c)) {
                		EUR_CRM_Image_Level__c imgLevel = imageLevelMap.get(acct.EUR_CRM_Image_Level__c);
                		if(imgLevel.EUR_CRM_Name__c == 'Mainstream') {
                			if(territoryMap.get(acct.EUR_CRM_Territory__c).EUR_CRM_KD_Owner__c != null) {
                				acct.OwnerID = territoryMap.get(acct.EUR_CRM_Territory__c).EUR_CRM_KD_Owner__c;
                			}
                			continue;
                		}
                	}
                
                    if (territoryMap.get(acct.EUR_CRM_Territory__c).EUR_CRM_On_Trade_Owner__c != null){
                        acct.OwnerID = territoryMap.get(acct.EUR_CRM_Territory__c).EUR_CRM_On_Trade_Owner__c;
                    }
                    
                // Make off trade owner of Territory, the account owner for NG off TRADE recordtypes
                }
                else if(accountRecordTypesMap.get(acct.RecordTypeId).DeveloperName ==  ACCOUNT_NG_OFF_TRADE_TRADITIONAL
                        || accountRecordTypesMap.get(acct.RecordTypeId).DeveloperName == ACCOUNT_NG_OFF_TRADE_BULK_BREAKER)
                    {
                	if (territoryMap.get(acct.EUR_CRM_Territory__c).EUR_CRM_KD_Owner__c != null){
                        acct.OwnerID = territoryMap.get(acct.EUR_CRM_Territory__c).EUR_CRM_KD_Owner__c;
                    }
                }
            }            
        }*/  
    }
}