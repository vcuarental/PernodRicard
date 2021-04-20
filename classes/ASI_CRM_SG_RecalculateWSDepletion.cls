/*********************************************************************************
 * Name:ASI_CRM_SG_RecalculateWSDepletion
 * Description: Update closing / beginning stock of wholesaler depletion records after it is updated
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-07-12       Laputa: Vincent Lam     Created
*********************************************************************************/
public with sharing class ASI_CRM_SG_RecalculateWSDepletion extends ASI_CRM_SG_TriggerAbstract{

      public ASI_CRM_SG_RecalculateWSDepletion() {
        super('ASI_CRM_SG_RecalculateWSDepletion');
      }
    
      public override void executeTriggerAction (
        TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
            
        Set<String> OFFTAKE_STOCK_IN_TRADE_DETAIL_RECORD_TYPE = new Set<String> {
            'ASI_CRM_SG_WS_Depletion'
        };
    
        Set<String> WHOLESALER_RECORD_TYPE = new Set<String> {
            'ASI_CRM_SG_Wholesaler'
        };
    
        Set<String> ACTUAL_OFFTAKE_RECORD_TYPE = new Set<String> {
            'ASI_CRM_SG_Actual_Offtake'
        };
            
        List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> list_depletion_new = (List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>) sObjList;
        Map<Id, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> map_delpletion_old = (Map<Id, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>) oldMap;
    
        Set<Id> set_depletion_needToUpdate = new Set<Id>();
        Set<Id> set_depletionSKU = new Set<Id>();
        Set<Id> set_depletionWholesaler = new Set<Id>();
        Map<id, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> map_depletion_update = new Map<id, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
            
        Date startDepletionMonth = list_depletion_new[0].ASI_TH_CRM_Date__c;
            
        Map<String, date> map_wholesalerSKU_earliestDate = new Map<String, date>();
    
        // only recalculate closing / beginning stock if Offtake / FOC / Sell-in / Adjusted Quantity is changed
        for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c depletion_new : list_depletion_new) {
    
            if (map_delpletion_old.containsKey(depletion_new.id)){
                ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c depletion_old = map_delpletion_old.get(depletion_new.id);
                if (
                    depletion_new.ASI_TH_CRM_Total_Offtake_Final__c != depletion_old.ASI_TH_CRM_Total_Offtake_Final__c ||
                    depletion_new.ASI_TH_CRM_Sell_In__c != depletion_old.ASI_TH_CRM_Sell_In__c ||
                    depletion_new.ASI_TH_CRM_FOC__c != depletion_old.ASI_TH_CRM_FOC__c ||
                    depletion_new.ASI_CRM_Adjusted_Quantity__c != depletion_old.ASI_CRM_Adjusted_Quantity__c
                ) {                    
                    set_depletion_needToUpdate.add(depletion_new.id);
                    map_depletion_update.put(depletion_new.id, depletion_new);
                    if (depletion_new.ASI_CRM_SKU__c != null) set_depletionSKU.add(depletion_new.ASI_CRM_SKU__c);
                    if (depletion_new.ASI_CRM_Customer__c != null) set_depletionWholesaler.add(depletion_new.ASI_CRM_Customer__c);
                    
                    if (depletion_new.ASI_TH_CRM_Date__c < startDepletionMonth) startDepletionMonth = depletion_new.ASI_TH_CRM_Date__c;
                    
                    String key = depletion_new.ASI_CRM_Customer__c + '_' + depletion_new.ASI_CRM_SKU__c ;
                    if (map_wholesalerSKU_earliestDate.containsKey(key)) {
                        map_wholesalerSKU_earliestDate.put(key, (depletion_new.ASI_TH_CRM_Date__c < map_wholesalerSKU_earliestDate.get(key) ? depletion_new.ASI_TH_CRM_Date__c : map_wholesalerSKU_earliestDate.get(key)));
                    } else {
                        map_wholesalerSKU_earliestDate.put(key, depletion_new.ASI_TH_CRM_Date__c);
                    }
                }
            }
        
        }
        
        // only recalculate depletion record if required
        if (set_depletion_needToUpdate.size()>0){
            List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> depletionList = [SELECT Id, 
                                                                           ASI_CRM_SKU__c, ASI_CRM_Customer__c, 
                                                                           ASI_TH_CRM_Total_Offtake_Final__c, 
                                                                           ASI_TH_CRM_Beginning_Stock__c, 
                                                                           ASI_TH_CRM_Sell_In__c,
                                                                           ASI_TH_CRM_FOC__c,
                                                                           ASI_CRM_Adjusted_Quantity__c,
                                                                               ASI_TH_CRM_Date__c
                                                                              FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c
                                                                                 WHERE RecordType.DeveloperName in :OFFTAKE_STOCK_IN_TRADE_DETAIL_RECORD_TYPE 
                                                                                    AND ASI_CRM_SKU__c in :set_depletionSKU
                                                                                    AND ASI_CRM_Customer__c in :set_depletionWholesaler
                                                                                    AND ASI_TH_CRM_Date__c >= :startDepletionMonth
                                                                              Order by ASI_CRM_Customer__c, ASI_CRM_SKU__c, ASI_TH_CRM_Date__c];
            
            List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> updateDepletionStockList = updateDepletionStock(depletionList, map_depletion_update, map_wholesalerSKU_earliestDate);
    
            update updateDepletionStockList; 
        }

    

    }
    
    private List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> updateDepletionStock(
        List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> allDepletionList, 
        Map<id, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> map_depletion_update, 
        Map<String, date> map_wholesalerSKU_earliestDate) {

        List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> list_depletion_final = new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        Map<String, decimal> map_wholesalerSKU_beginningStock = new Map<String, decimal>();

        for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c depletion : allDepletionList) {

            String key = depletion.ASI_CRM_Customer__c + '_' + depletion.ASI_CRM_SKU__c ;
            
            if (map_wholesalerSKU_earliestDate.containsKey(key)) {
                if (depletion.ASI_TH_CRM_Date__c >= map_wholesalerSKU_earliestDate.get(key)){
                    Decimal beginningStock = map_wholesalerSKU_beginningStock.containsKey(key) ? map_wholesalerSKU_beginningStock.get(key) : (depletion.ASI_TH_CRM_Beginning_Stock__c != null ? depletion.ASI_TH_CRM_Beginning_Stock__c : 0);
                    ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c latestDepletion = depletion;
                    
                    latestDepletion.ASI_TH_CRM_Beginning_Stock__c = beginningStock;
                    latestDepletion.ASI_TH_CRM_Ending_Stock_Final__c = (latestDepletion.ASI_TH_CRM_Beginning_Stock__c != null ? latestDepletion.ASI_TH_CRM_Beginning_Stock__c : 0)
                           + (latestDepletion.ASI_TH_CRM_Sell_In__c != null ? latestDepletion.ASI_TH_CRM_Sell_In__c : 0)
                           + (latestDepletion.ASI_TH_CRM_FOC__c != null ? latestDepletion.ASI_TH_CRM_FOC__c : 0)
                           - (latestDepletion.ASI_TH_CRM_Total_Offtake_Final__c != null ? latestDepletion.ASI_TH_CRM_Total_Offtake_Final__c : 0)
                           + (latestDepletion.ASI_CRM_Adjusted_Quantity__c != null ? latestDepletion.ASI_CRM_Adjusted_Quantity__c : 0);
                    map_wholesalerSKU_beginningStock.put(key, latestDepletion.ASI_TH_CRM_Ending_Stock_Final__c);
                    
                    list_depletion_final.add(latestDepletion);
                }
            }
            
        }

        return list_depletion_final;
    }


}