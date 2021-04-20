/*********************************************************************************
 * Name:        ASI_CRM_MO_Offtake_Stock_In_Trade_Common
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-04-13       Introv: Daniel WONG     Created - Set the TriggerClass as without sharing for Seapower Trading to search for Contracts.
*********************************************************************************/

public without sharing class ASI_CRM_MO_Offtake_Stock_In_Trade_Common{
    public static id MOAccountRT = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_MO_WSOfftakeDetail');
    public static id MOContractRT = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MO_Contract'); 
    
    public static void generateWSOfftakeIncentive(list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstOT_reGen, boolean blnUpdateRec){
        date queryDate;
        date queryDateS;
        date queryDateE;
        integer queryY = 0;
        integer queryM = 0;
        set<id> setOutlet = new set<id>();
        set<id> setContract = new set<id>();
        map<string, ASI_CRM_ContractVolumeIncentive__c> mapContractVolume = new map<string, ASI_CRM_ContractVolumeIncentive__c>();
        map<string, id> mapContract = new map<string, id>();
        map<String, String> mapSKUItmGrp = new map<String, String>();
        set<id> setSKUs = new set<id>();
        list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstOT = new list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        
        for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c ot : lstOT_reGen){
            if(ot.recordTypeId == MOAccountRT){
                queryDate = ot.ASI_TH_CRM_Date__c;
                queryY = queryDate.year();
                queryM = queryDate.month();
                queryDateS = Date.newInstance(queryDate.year(), queryDate.month(), 1);
                queryDateE = Date.newInstance(queryDate.addMonths(1).year(), queryDate.addMonths(1).month(), 1);
                queryDateE = queryDateE.addDays(-1);
                setOutlet.add(ot.ASI_TH_CRM_Account__c);
                setSKUs.add(ot.ASI_CRM_SKU__c);
            }
        }
        
        system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ queryDate : ' + queryDate);
        system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ setOutlet : ' + setOutlet);
        
        for(ASI_TH_CRM_Contract__c contract : [
            SELECT id
            FROM ASI_TH_CRM_Contract__c
            WHERE ASI_TH_CRM_Outlet__c IN :setOutlet
           	//AND ASI_TH_CRM_Start_Date__c <= :queryDate
            //AND ASI_TH_CRM_End_Date__c >= :queryDate
            AND (
               CALENDAR_YEAR(ASI_TH_CRM_Start_Date__c) < :queryY 
               OR (CALENDAR_YEAR(ASI_TH_CRM_Start_Date__c) = :queryY AND CALENDAR_MONTH(ASI_TH_CRM_Start_Date__c) <= :queryM)
            )
            AND (
               CALENDAR_YEAR(ASI_TH_CRM_End_Date__c) > :queryY
               OR (CALENDAR_YEAR(ASI_TH_CRM_End_Date__c) = :queryY AND CALENDAR_MONTH(ASI_TH_CRM_End_Date__c) >= :queryM)
            )
            AND ASI_CRM_Obsolete_Version__c != TRUE
            AND RecordTypeid = :MOContractRT
            AND ASI_TH_CRM_Contract_Status__c = 'Final'
        ]
        ){
            setContract.add(contract.id);
        }
        
        system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ setContract : ' + setContract);
        
        for(ASI_CRM_ContractVolumeIncentive__c cv : [SELECT id, ASI_CRM_Contract__c, ASI_CRM_Contract__r.ASI_TH_CRM_Outlet__c, ASI_CRM_SKU__c, ASI_CRM_Item_Group_ID__c, ASI_CRM_Incentive_Point_Per_Bottle__c FROM ASI_CRM_ContractVolumeIncentive__c WHERE ASI_CRM_Contract__c IN :setContract]){
            //string strTemp = string.valueOf(cv.ASI_CRM_Contract__r.ASI_TH_CRM_Outlet__c) + '_' + string.valueOf(cv.ASI_CRM_SKU__c);
            if (cv.ASI_CRM_SKU__c == null) {
                continue;
            }

            setSKUs.add(cv.ASI_CRM_SKU__c);
            
            string strTempGrp = '';
            string strTemp = '';
            system.debug('SKU: ' + cv.ASI_CRM_SKU__c + ' Group: ' + cv.ASI_CRM_Item_Group_ID__c);
            if (cv.ASI_CRM_Item_Group_ID__c != null && string.valueOf(cv.ASI_CRM_Item_Group_ID__c) != '') {
                strTempGrp = string.valueOf(cv.ASI_CRM_Contract__r.ASI_TH_CRM_Outlet__c) + '_' + string.valueOf(cv.ASI_CRM_Item_Group_ID__c).left(15);
            }
            strTemp = string.valueOf(cv.ASI_CRM_Contract__r.ASI_TH_CRM_Outlet__c) + '_' + string.valueOf(cv.ASI_CRM_SKU__c).left(15);
                    
            mapContractVolume.put(strTempGrp, cv);
            mapContractVolume.put(strTemp, cv);
            mapContract.put(strTemp, cv.ASI_CRM_Contract__c);
            if (strTempGrp != '') {
                mapContract.put(strTempGrp, cv.ASI_CRM_Contract__c);
            }
        }
        
        for (ASI_MFM_SKU_Code__c s : [SELECT id, ASI_MFM_Item_Group__c FROM ASI_MFM_SKU_Code__c WHERE id IN :setSKUs ]) {
            system.debug('SKU ID: ' + string.valueof(s.id) + ' Group: ' + string.valueof(s.ASI_MFM_Item_Group__c));
            if (s.ASI_MFM_Item_Group__c != null && string.valueOf(s.ASI_MFM_Item_Group__c) != '') {
                mapSKUItmGrp.put(String.valueOf(s.id).left(15), String.valueOf(s.ASI_MFM_Item_Group__c).left(15));
            } else {
                mapSKUItmGrp.put(String.valueOf(s.id).left(15), String.valueOf(s.id).left(15));
            }
        }
        
        system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ mapContractVolume : ' + mapContractVolume);
        
        for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c ot : lstOT_reGen){
            //string strkey = string.valueOf(ot.ASI_TH_CRM_Account__c) + '_' + string.valueOf(ot.ASI_CRM_SKU__c);
            string strkey = '';
            if (mapSKUItmGrp.get(String.valueOf(ot.ASI_CRM_SKU__c).left(15)) != null && string.valueOf(mapSKUItmGrp.get(String.valueOf(ot.ASI_CRM_SKU__c).left(15))) != '') {
                strkey = string.valueOf(ot.ASI_TH_CRM_Account__c) + '_' + string.valueOf(mapSKUItmGrp.get(String.valueOf(ot.ASI_CRM_SKU__c).left(15))).left(15);
            }
            system.debug('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c loop: ' + strkey);
            
            system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ strkey : ' + strkey);
            
            if(mapContractVolume.get(strkey) != NULL){
                if(mapContractVolume.get(strkey).ASI_CRM_Incentive_Point_Per_Bottle__c != NULL) {
                    ot.ASI_CRM_Contract__c = mapContract.get(strkey);
                    ot.ASI_CRM_Incentive_Points_Per_Bottle__c = mapContractVolume.get(strkey).ASI_CRM_Incentive_Point_Per_Bottle__c;
                    if(ot.ASI_CRM_Quantity_Bottle__c != NULL)
                    ot.ASI_CRM_Incentive_Points__c = mapContractVolume.get(strkey).ASI_CRM_Incentive_Point_Per_Bottle__c * ot.ASI_CRM_Quantity_Bottle__c;
                    
                    system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ strkey : ' + strkey);
                    system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ ASI_CRM_Incentive_Points_Per_Bottle__c : ' + ot.ASI_CRM_Incentive_Points_Per_Bottle__c);
                    system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ ASI_CRM_Quantity_Bottle__c : ' + ot.ASI_CRM_Quantity_Bottle__c);
                    system.debug('------ASI_CRM_MO_Offtake_Stock_In_Trade_Common.reGenWS------ ASI_CRM_Incentive_Points__c : ' + ot.ASI_CRM_Incentive_Points__c);
                }
            }
        }
        
        if (blnUpdateRec == true) {
        	update lstOT_reGen;
        }   
    }
}