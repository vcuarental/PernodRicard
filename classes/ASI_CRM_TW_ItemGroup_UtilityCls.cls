/*Filename:        ASI_CRM_TW_ItemGroup_UtilityCls.cls
* Author:          Twinkle LI (Introv Limited)
* Purpose:         Utility Class for Item Group & SKU Price/Costs
* Created Date:    2016/11/01
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_ItemGroup_UtilityCls{
    public List<ASI_MFM_Item_Group__c> getItemGroup(String Channel){
        List<ASI_MFM_Item_Group__c> listItemGp = [SELECT id, Name 
                                                FROM ASI_MFM_Item_Group__c 
                                                WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group') 
                                                AND ASI_CRM_Active__c = TRUE AND ASI_CRM_Applied_To__c includes (:Channel)
                                                ORDER BY Name];
        return listItemGp;
    }
    
    public List<ASI_CRM_MY_SKUPriceCost__c> getAllEffectiveSKUpc(List<String> Channels, Set<Id> setItmGroupId, List<String> Type, Date effDate){

        String soql = 'SELECT id, ASI_CRM_Item_Group__c, ASI_CRM_Cost__c, ASI_CRM_Price__c, ASI_CRM_Applied_To__c, ASI_CRM_Type__c '
                                                    + 'FROM ASI_CRM_MY_SKUPriceCost__c '
                                                    + 'WHERE ASI_CRM_Item_Group__c IN: setItmGroupId '
                                                    + 'AND ASI_CRM_Applied_To__c includes (' + String.join(Channels, ',') +') '
                                                    + 'AND ASI_CRM_Type__c IN: Type ' 
                                                    + 'AND ASI_CRM_EffectiveDate__c <=: effDate '
                                                    + 'Order By ASI_CRM_EffectiveDate__c ASC';

        List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = database.query(soql);
        
        /*
        List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = [SELECT id, ASI_CRM_Item_Group__c, ASI_CRM_Cost__c, ASI_CRM_Price__c, ASI_CRM_Applied_To__c, ASI_CRM_Type__c
                                                    FROM ASI_CRM_MY_SKUPriceCost__c 
                                                    WHERE ASI_CRM_Item_Group__c IN: setItmGroupId 
                                                    AND ASI_CRM_Applied_To__c includes (:Channel)
                                                    AND ASI_CRM_Type__c IN: Type
                                                    AND ASI_CRM_EffectiveDate__c <=: effDate 
                                                    Order By ASI_CRM_EffectiveDate__c ASC];
        */
        return listSKUpc;
    }
    
    public List<ASI_CRM_MY_SKUPriceCost__c> getAllChannelSKUpc(Set<Id> setItmGroupId, List<String> Type){
        List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = [SELECT id, ASI_CRM_Item_Group__c, ASI_CRM_Cost__c, ASI_CRM_Price__c, ASI_CRM_Applied_To__c, ASI_CRM_Type__c, ASI_CRM_EffectiveDate__c
                                                    FROM ASI_CRM_MY_SKUPriceCost__c 
                                                    WHERE ASI_CRM_Item_Group__c IN: setItmGroupId 
                                                    AND ASI_CRM_Type__c IN: Type
                                                    Order By ASI_CRM_EffectiveDate__c DESC];
        return listSKUpc;
    }
    
    
    public List<ASI_CRM_MY_SKUPriceCost__c> getAllSKUpc(String Channel, Set<Id> setItmGroupId, List<String> Type){
        List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = [SELECT id, ASI_CRM_Item_Group__c, ASI_CRM_Cost__c, ASI_CRM_Price__c, ASI_CRM_Applied_To__c, 
                                                        ASI_CRM_Type__c, ASI_CRM_EffectiveDate__c
                                                    FROM ASI_CRM_MY_SKUPriceCost__c 
                                                    WHERE ASI_CRM_Item_Group__c IN: setItmGroupId 
                                                    AND ASI_CRM_Applied_To__c includes (:Channel)
                                                    AND ASI_CRM_Type__c IN: Type 
                                                    Order By ASI_CRM_EffectiveDate__c DESC];
        return listSKUpc;
    }
}