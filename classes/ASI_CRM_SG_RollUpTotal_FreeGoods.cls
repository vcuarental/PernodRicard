/*********************************************************************************
 * Name:ASI_CRM_SG_RollUpTotal_FreeGoods 
 * Description: Roll up total value of free goods from line items. No roll up fields to not waste the limit           
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/01/2015       Laputa: Conrad          Created
 * 2016-04-01       Laputa: Vincent         [VL 1.0] Cater Actual Request Bottle for type = Sales Incentive
 * 2017-01-06		Laputa: Vincent			[VL 2.0] Rollup Total Cost
 * 2018-05-06		Laputa: Vincent			[VL 3.0] Rollup 9L volume
*********************************************************************************/

public without sharing class ASI_CRM_SG_RollUpTotal_FreeGoods extends ASI_CRM_SG_TriggerAbstract {
    
    public ASI_CRM_SG_RollUpTotal_FreeGoods() {
        super('ASI_CRM_SG_RollUpTotal_FreeGoods');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<ASI_FOC_Request_Item__c> requestItems = (List<ASI_FOC_Request_Item__c>)sObjList;
        List<ASI_FOC_Request_Item__c> validRequestItems = (List<ASI_FOC_Request_Item__c>)sObjList;
        
        validRequestItems = requestItems;
        
        if(validRequestItems.size() > 0) {
            
            /*Set<ID> freeGoodsHeaderIDs = new Set<ID>();
            List<ASI_FOC_Free_Goods_Request__c> freeGoodHeadersToUpdate = new List<ASI_FOC_Free_Goods_Request__c>();
            
            for(ASI_FOC_Request_Item__c requestItem : validRequestItems) {
                
                freeGoodsHeaderIDs.add(requestItem.ASI_FOC_Request_Order__c);
            }
            
            Set<ID> tempfreeGoodsHeaderIDs = freeGoodsHeaderIDs.clone();
            
            List<AggregateResult> resultAggregateList = [SELECT ASI_FOC_Request_Order__c,
                SUM(ASI_CRM_SG_Amount__c)totalAmount
                FROM ASI_FOC_Request_Item__c
                WHERE ASI_FOC_Request_Order__c IN: freeGoodsHeaderIDs
                AND ASI_FOC_Request_Order__r.recordtype.developername LIKE : '%ASI_CRM_SG_FOC%'
                GROUP BY ASI_FOC_Request_Order__c];
                
            for(AggregateResult result : resultAggregateList){
                ASI_FOC_Free_Goods_Request__c tempFreeGood = new ASI_FOC_Free_Goods_Request__c(id = (ID)result.get('ASI_FOC_Request_Order__c'));
                tempFreeGood.ASI_CRM_SG_Total_Amount__c = (Decimal)result.get('totalAmount');
                
                freeGoodHeadersToUpdate.add(tempFreeGood);   
                tempfreeGoodsHeaderIDs.remove(tempFreeGood.id);
            }
            
            if(freeGoodHeadersToUpdate.size()>0){
                update freeGoodHeadersToUpdate;
            }
            
            //Base case Scenario
            if(tempfreeGoodsHeaderIDs.size() > 0) {
                for(ID freeGoodsID : tempfreeGoodsHeaderIDs) {
                    ASI_FOC_Free_Goods_Request__c tempFreeGood = new ASI_FOC_Free_Goods_Request__c(id = freeGoodsID);
                    tempFreeGood.ASI_CRM_SG_Total_Amount__c = null;
            
                    freeGoodHeadersToUpdate.add(tempFreeGood); 
                }
            }
        
            if(freeGoodHeadersToUpdate.size()>0){
                update freeGoodHeadersToUpdate;
            }*/
            
            Set<ID> headerIds = new Set<ID>();
            
            for(ASI_FOC_Request_Item__c focItem : validRequestItems) {
                headerIds.add(focItem.ASI_FOC_Request_Order__c);
            }
            
            List<ASI_FOC_Free_Goods_Request__c> freeGoodsHeader = [SELECT ID, Name, ASI_CRM_SG_Total_Amount__c,
                                                                        (SELECT ID, Name, 
                                                                         ASI_FOC_Request_Quantity_Bottle__c, 
                                                                         ASI_CRM_SG_Unit_Price__c, 
                                                                         ASI_CRM_SG_FOC_Type__c, 
                                                                         ASI_FOC_Actual_Quantity_Bottle__c
                                                                         /* [VL 2.0] BEGIN */
                                                                         , ASI_FOC_Free_Good_Cost__c
                                                                         /* [VL 2.0] END */
                                                                         /* [VL 3.0] BEGIN */
                                                                         , ASI_CRM_Actual_Quantity_9L__c
                                                                         /* [VL 3.0] END */
                                                                         FROM ASI_FOC_Request_Items__r)
                                                                   FROM ASI_FOC_Free_Goods_Request__c
                                                                   WHERE ID IN : headerIds
                                                                  ];
            
            system.debug('Header ID Set: ' + headerIds + ' Header size: ' + freeGoodsHeader.size());
            
            List<ASI_FOC_Free_Goods_Request__c> freeGoodsHeaderToUpdate = new List<ASI_FOC_Free_Goods_Request__c>();
            
            for(ASI_FOC_Free_Goods_Request__c focHeader : freeGoodsHeader) {
                if(focHeader.ASI_FOC_Request_Items__r.size() > 0) {
                    Decimal totalAmount = 0;
                    /* [VL 2.0] BEGIN */
                    Decimal totalCost = 0;
                    /* [VL 2.0] END */
                    /* [VL 3.0] BEGIN */
                    Decimal totalActualQuantity9L = 0;
                    /* [VL 3.0] END */
                    List<ASI_FOC_Request_Item__c> focItemList = focHeader.ASI_FOC_Request_Items__r;
                    for(ASI_FOC_Request_Item__c focItem : focItemList) {
                        /* [VL 1.0] BEGIN */
                        /*
                        Decimal amount = (focItem.ASI_FOC_Request_Quantity_Bottle__c != null ? focItem.ASI_FOC_Request_Quantity_Bottle__c : 0) *
                                            (focItem.ASI_CRM_SG_Unit_Price__c != null ? focItem.ASI_CRM_SG_Unit_Price__c : 0);
                        */
                        Decimal amount = focItem.ASI_CRM_SG_FOC_Type__c == 'Sales Incentive' ? 
                            ( (focItem.ASI_FOC_Actual_Quantity_Bottle__c != null ? focItem.ASI_FOC_Actual_Quantity_Bottle__c : (focItem.ASI_FOC_Request_Quantity_Bottle__c != null ? focItem.ASI_FOC_Request_Quantity_Bottle__c : 0))
                             * (focItem.ASI_CRM_SG_Unit_Price__c != null ? focItem.ASI_CRM_SG_Unit_Price__c : 0)
                            ) :
                            (focItem.ASI_FOC_Request_Quantity_Bottle__c != null ? focItem.ASI_FOC_Request_Quantity_Bottle__c : 0) *
                                            (focItem.ASI_CRM_SG_Unit_Price__c != null ? focItem.ASI_CRM_SG_Unit_Price__c : 0);
                        system.debug(focItem);
                        system.debug(amount);
                        system.debug(focItem.ASI_FOC_Free_Good_Cost__c);
                        /* [VL 1.0] END */
                        totalAmount += amount;
                        /* [VL 2.0] BEGIN */
                        totalCost += focItem.ASI_FOC_Free_Good_Cost__c == null ? 0 : focItem.ASI_FOC_Free_Good_Cost__c; 
                        /* [VL 2.0] END */
                        /* [VL 3.0] BEGIN */
                        totalActualQuantity9L += focItem.ASI_CRM_Actual_Quantity_9L__c == null ? 0 : focItem.ASI_CRM_Actual_Quantity_9L__c; 
                        /* [VL 3.0] END */
                        system.debug(totalCost);
                    }
                    focHeader.ASI_CRM_SG_Total_Amount__c = totalAmount;
                    /* [VL 2.0] BEGIN */
                    focHeader.ASI_CRM_Total_Cost__c = totalCost;
                    /* [VL 2.0] END */
                    /* [VL 3.0] BEGIN */
                    focHeader.ASI_CRM_Total_Actual_Quantity_9L__c = totalActualQuantity9L;
                    /* [VL 3.0] END */
                    freeGoodsHeaderToUpdate.add(focHeader);
                } else {
                    focHeader.ASI_CRM_SG_Total_Amount__c = 0;
                    /* [VL 2.0] BEGIN */
                    focHeader.ASI_CRM_Total_Cost__c = 0;
                    /* [VL 2.0] END */
                    /* [VL 3.0] BEGIN */
                    focHeader.ASI_CRM_Total_Actual_Quantity_9L__c = 0;
                    /* [VL 3.0] END */
                    freeGoodsHeaderToUpdate.add(focHeader);
                }
                
            }
            
            if(freeGoodsHeaderToUpdate.size() > 0) {
                update freeGoodsHeaderToUpdate;
                system.debug('total cost = '+freeGoodsHeaderToUpdate);
            }
        }
        
    }
}