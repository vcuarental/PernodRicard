/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_PlanLineItem_TriggerClass
 * Object: ASI_MFM_Plan_Line_Item__c
 * Purpose: 
 * Author:  (jack yuan)
 * Create Date: 2020-3-18
 * Modify History:
 * 2020-3-18        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_PlanLineItem_TriggerClass {

    public static Boolean EXECUTEFLAG = false;
    public static void routineBeforeUpsert(List<ASI_MFM_Plan_Line_Item__c> trigger_new, Map<Id,ASI_MFM_Plan_Line_Item__c> trigger_oldMap) {

        Set<Id> subIdSet = new Set<Id>();
        List<Decimal> bottleSizeList = new List<Decimal>();
        
        for (ASI_MFM_Plan_Line_Item__c planItem : trigger_new) {
            subIdSet.add(planItem.ASI_MFM_Sub_brand_Code__c);
            if (planItem.ASI_CRM_CN_TP_Bottle_Size__c != null) {
                bottleSizeList.add(Decimal.valueOf( planItem.ASI_CRM_CN_TP_Bottle_Size__c));
            }
        }

        // Item group Map
        Map<String, ASI_MFM_Item_Group__c> keyItemGroupMap = new Map<String, ASI_MFM_Item_Group__c>();
        // Set<Id> itemGroupIdSet = new Set<Id>();
        List<ASI_MFM_Item_Group__c> itemGroups = [SELECT ASI_MFM_Sub_brand__c, ASI_CRM_CN_TP_Bottle_Size__c, ASI_CRM_CN_Converion9L_C__c
                                                  FROM ASI_MFM_Item_Group__c
                                                  WHERE ASI_MFM_Sub_brand__c IN :subIdSet
                                                  AND ASI_CRM_CN_TP_Bottle_Size__c IN :bottleSizeList
                                                  AND RecordType.DeveloperName = 'ASI_CRM_CN_CRM_Item_Group'
                                                  ORDER BY CreatedDate DESC];
        for (ASI_MFM_Item_Group__c itemGroup : itemGroups) {
            String subKey = itemGroup.ASI_MFM_Sub_brand__c + '-' + itemGroup.ASI_CRM_CN_TP_Bottle_Size__c;
            if (!keyItemGroupMap.containsKey(subKey)) {
                keyItemGroupMap.put(subKey, itemGroup);
                // itemGroupIdSet.add(itemGroup.Id);
            }
        }
        // System.debug(LoggingLevel.INFO, '*** itemGroupIdSet: ' + itemGroupIdSet);
        // Key t1 price map
        Map<String, Decimal> keyPriceMap = new Map<String, Decimal>();
        List<ASI_CRM_CN_T1_Price__c> t1PriceList = [SELECT ASI_CRM_CN_Item_Group__r.ASI_MFM_Sub_brand__c,
                                                           ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_TP_Bottle_Size__c,
                                                           ASI_CRM_CN_T1_Price__c
                                                    FROM ASI_CRM_CN_T1_Price__c
                                                    WHERE ASI_CRM_CN_Item_Group__r.ASI_MFM_Sub_brand__c IN : subIdSet
                                                    AND ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_TP_Bottle_Size__c IN :bottleSizeList
                                                    AND ASI_CRM_CN_Item_Group__r.RecordType.DeveloperName = 'ASI_CRM_CN_CRM_Item_Group'
                                                    ORDER BY ASI_CRM_CN_Effective_Date__c DESC];
        for (ASI_CRM_CN_T1_Price__c t1Price : t1PriceList) {
            String subKey = t1Price.ASI_CRM_CN_Item_Group__r.ASI_MFM_Sub_brand__c 
                            + '-' + t1Price.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_TP_Bottle_Size__c;
            if (!keyPriceMap.containsKey(subKey)) {
                keyPriceMap.put(subKey, t1Price.ASI_CRM_CN_T1_Price__c);
            }
        }
        System.debug(LoggingLevel.INFO, '*** keyPriceMap: ' + keyPriceMap);

        // Fill t1 price and related LPP
        for (ASI_MFM_Plan_Line_Item__c planItem : trigger_new) {
            String subKey = '';
            if (planItem.ASI_CRM_CN_TP_Bottle_Size__c != null) {
                subKey = planItem.ASI_MFM_Sub_brand_Code__c + '-' + Decimal.valueOf(planItem.ASI_CRM_CN_TP_Bottle_Size__c).setScale(2);
            }
            System.debug(LoggingLevel.INFO, '*** subKey: ' + subKey);
            if (keyPriceMap.containsKey(subKey) && planItem.ASI_CRM_CN_TP_T1_Price__c == null) {
                planItem.ASI_CRM_CN_TP_T1_Price__c = keyPriceMap.get(subKey);
            }
            if (keyItemGroupMap.containsKey(subKey)) {
                planItem.ASI_CRM_CN_TP_Converion9L__c = keyItemGroupMap.get(subKey) == null ? 0 : keyItemGroupMap.get(subKey).ASI_CRM_CN_Converion9L_C__c;
            }
        }
    }

    public static void routineAfterUpsert(List<ASI_MFM_Plan_Line_Item__c> trigger_new, Map<Id,ASI_MFM_Plan_Line_Item__c> trigger_oldMap) {
        // if (EXECUTEFLAG) return;
        // EXECUTEFLAG = true;
        
         Set<Id> subIdSet = new Set<Id>();
        List<String> bottleSizeList = new List<String>();
        Set<Id> lineItemIdSet = new Set<Id>();
        Set<Id> itemGroupIdSet = new Set<Id>();

        Set<String> upTPIds = new Set<String>();
        Set<Id> tpIds = new Set<Id>();

        for (ASI_MFM_Plan_Line_Item__c planItem : trigger_new) {
            if (trigger_oldMap == null) {
                subIdSet.add(planItem.ASI_MFM_Sub_brand_Code__c);
                bottleSizeList.add(planItem.ASI_CRM_CN_TP_Bottle_Size__c);
                lineItemIdSet.add(planItem.Id);
            } else if (trigger_oldMap != null 
                       && (planItem.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(planItem.Id).ASI_MFM_Sub_brand_Code__c
                       || planItem.ASI_CRM_CN_TP_Bottle_Size__c != trigger_oldMap.get(planItem.Id).ASI_CRM_CN_TP_Bottle_Size__c)) {
                subIdSet.add(planItem.ASI_MFM_Sub_brand_Code__c);
                bottleSizeList.add(planItem.ASI_CRM_CN_TP_Bottle_Size__c);
                lineItemIdSet.add(planItem.Id);
            }
            
            if (planItem.ASI_CRM_CN_TP_Promotion_Product__c != null) {
                itemGroupIdSet.add(planItem.ASI_CRM_CN_TP_Promotion_Product__c);
            }
            
            if ((trigger_oldMap != null && (planItem.ASI_CRM_CN_TP_Approval_Step2_Rule1__c != trigger_oldMap.get(planItem.Id).ASI_CRM_CN_TP_Approval_Step2_Rule1__c
                     || planItem.ASI_CRM_CN_TP_Approval_Step2_Rule2__c != trigger_oldMap.get(planItem.Id).ASI_CRM_CN_TP_Approval_Step2_Rule2__c
                     || planItem.ASI_CRM_CN_TP_Approval_Step2_Rule3__c != trigger_oldMap.get(planItem.Id).ASI_CRM_CN_TP_Approval_Step2_Rule3__c))
                    || trigger_oldMap == null) {
                upTPIds.add(planItem.ASI_MFM_Plan__c);
            }
            // Set plan status to draft when plan line item changed
            if (trigger_oldMap != null) {
                List<Schema.FieldSetMember> fieldList = SObjectType.ASI_MFM_Plan_Line_Item__c.FieldSets.ASI_CRM_CN_TP_PlanLineItem_Change.getFields();
                Boolean flag = false;
                for (Schema.FieldSetMember f : fieldList) {
                    if (planItem.get(f.getFieldPath()) != trigger_oldMap.get(planItem.Id).get(f.getFieldPath())) {
                        flag = true;
                        break;
                    }
                }
                if (flag) {
                    tpIds.add(planItem.ASI_MFM_Plan__c);
                }
            }
        }

        // Set plan status to draft when plan line item changed
        List<ASI_MFM_Plan__c> tpList = [SELECT ASI_MFM_Status__c FROM ASI_MFM_Plan__c WHERE Id IN :tpIds];
        for (ASI_MFM_Plan__c tp : tpList) {

            tp.ASI_MFM_Status__c = ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT;
        }
        if (!tpList.isEmpty()) {
            update tpList;
        }
        
        Approval.unlock(tpList, false);

        if (trigger_new[0].ASI_MFM_Sub_brand_Name__c == '999') return;
        
        Set<Id> headIds = new Set<Id>();
        if (!upTPIds.isEmpty()) {
            for (ASI_MFM_Plan__c tp : [SELECT ASI_CRM_CN_TP_Approval__c FROM ASI_MFM_Plan__c WHERE Id IN :upTPIds]) {
                headIds.add(tp.ASI_CRM_CN_TP_Approval__c);
            }
        }
        
        if (!headIds.isEmpty()) {
            // Summary the child tp step2  number
            List<AggregateResult> tplanList = [SELECT ASI_MFM_Plan__r.ASI_CRM_CN_TP_Approval__c headId, 
                                                       sum(ASI_CRM_CN_TP_Approval_Step2_Rule1__c) sumRule1,
                                                       sum(ASI_CRM_CN_TP_Approval_Step2_Rule2__c) sumRule2,
                                                       sum(ASI_CRM_CN_TP_Approval_Step2_Rule3__c) sumRule3 
                                                FROM ASI_MFM_Plan_Line_Item__c
                                                WHERE ASI_MFM_Plan__r.ASI_CRM_CN_TP_Approval__c IN :headIds
                                                AND ASI_MFM_Plan__r.ASI_CRM_CN_TP_Approval__c != null
                                                GROUP BY ASI_MFM_Plan__r.ASI_CRM_CN_TP_Approval__c];
            List<ASI_MFM_Plan__c> headTPList = new List<ASI_MFM_Plan__c>();
            for (AggregateResult tplan : tplanList) {
                ASI_MFM_Plan__c newTPHead = new ASI_MFM_Plan__c(Id = (String)tplan.get('headId'));
                newTPHead.ASI_CRM_CN_TP_Head_Approval_Step2__c = (Decimal)tplan.get('sumRule1') + 
                                                                 (Decimal)tplan.get('sumRule2') + 
                                                                 (Decimal)tplan.get('sumRule3');
                newTPHead.ASI_CRM_CN_TP_Head_Approval_Step3__c = (Decimal)tplan.get('sumRule1');
                headTPList.add(newTPHead);
            }
            System.debug(LoggingLevel.INFO, '*** headTPList: ' + headTPList.size());
            if (!headTPList.isEmpty()) {
                update headTPList;
            }
            
        }
        if (lineItemIdSet.isEmpty()) return;
        List<ASI_MFM_Plan_Line_Item__c> planItemList = [SELECT ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_TP_Bottle_Size__c,
                                                               ASI_MFM_Plan__r.ASI_CRM_CN_TP_Channel__c,
                                                               ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c,
                                                               ASI_CRM_CN_TP_Promotion_Product__c
                                                        FROM ASI_MFM_Plan_Line_Item__c
                                                        WHERE Id IN :lineItemIdSet];

        // LPP Map
        Map<String, ASI_CRM_T2_Selling_Price__c> keyLPPIdMap = new Map<String, ASI_CRM_T2_Selling_Price__c>();
        System.debug(LoggingLevel.INFO, '*** subIdSet: ' + subIdSet.size());
        System.debug(LoggingLevel.INFO, '*** bottleSizeList: ' + bottleSizeList.size());
        List<ASI_CRM_T2_Selling_Price__c> lppList = [SELECT ASI_CRM_CN_TP_Sub_Brand__c,
                                                            ASI_CRM_CN_TP_Bottle_Size__c,
                                                            ASI_CRM_CN_TP_LPP_Price__c,
                                                            ASI_CRM_CN_TP_Region__c,
                                                            ASI_CRM_CN_TP_Channel__c,
                                                            ASI_CRM_CN_TP_Benchmark__c,
                                                            ASI_CRM_CN_TP_T1_Price__c,
                                                            ASI_CRM_Item_Group__c
                                                    FROM ASI_CRM_T2_Selling_Price__c
                                                    WHERE ((ASI_CRM_CN_TP_Sub_Brand__c IN :subIdSet AND ASI_CRM_CN_TP_Bottle_Size__c IN :bottleSizeList)
                                                            OR ASI_CRM_Item_Group__c IN :itemGroupIdSet)
                                                    AND RecordType.DeveloperName = 'ASI_CRM_CN_TP_LPP'];
        System.debug(LoggingLevel.INFO, '*** lppList: ' + lppList.size());
        for (ASI_CRM_T2_Selling_Price__c lpp : lppList) {
            // String subKey = lpp.ASI_CRM_CN_TP_Sub_Brand__c + '-' + lpp.ASI_CRM_CN_TP_Bottle_Size__c + '-' + lpp.ASI_CRM_CN_TP_Region__c + '-' + lpp.ASI_CRM_CN_TP_Channel__c;
            String subKey = lpp.ASI_CRM_CN_TP_Sub_Brand__c + '-' + lpp.ASI_CRM_CN_TP_Bottle_Size__c;
            if (lpp.ASI_CRM_Item_Group__c != null) {
                subKey = lpp.ASI_CRM_Item_Group__c;
            }
            if (!keyLPPIdMap.containsKey(subKey)) {
                keyLPPIdMap.put(subKey, lpp);
            }
        }
        System.debug(LoggingLevel.INFO, '*** keyLPPIdMap: ' + keyLPPIdMap.size());

        for (ASI_MFM_Plan_Line_Item__c planItem : planItemList) {
            // String subKey = planItem.ASI_MFM_Sub_brand_Code__c + '-' + 
            //                 planItem.ASI_CRM_CN_TP_Bottle_Size__c + '-' + 
            //                 planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c + '-' + 
            //                 planItem.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Channel__c;
            String subKey = planItem.ASI_MFM_Sub_brand_Code__c + '-' + 
                            planItem.ASI_CRM_CN_TP_Bottle_Size__c;
            if (planItem.ASI_CRM_CN_TP_Promotion_Product__c != null) {
                subKey = planItem.ASI_CRM_CN_TP_Promotion_Product__c;
            }
            System.debug(LoggingLevel.INFO, '*** subKey: ' + subKey);
            if (keyLPPIdMap.containsKey(subKey)) {
                planItem.ASI_CRM_CN_TP_LPP__c = keyLPPIdMap.get(subKey).Id;
                planItem.ASI_CRM_CN_TP_LPP_Price_App__c = keyLPPIdMap.get(subKey).ASI_CRM_CN_TP_LPP_Price__c;
                planItem.ASI_CRM_CN_TP_Benchmark__c = keyLPPIdMap.get(subKey).ASI_CRM_CN_TP_Benchmark__c;
                if (keyLPPIdMap.get(subKey).ASI_CRM_CN_TP_T1_Price__c != null) {
                    planItem.ASI_CRM_CN_TP_T1_Price__c = keyLPPIdMap.get(subKey).ASI_CRM_CN_TP_T1_Price__c;
                }
                
            }
        }
        if (!planItemList.isEmpty()) {
            update planItemList;
        }
        
    }

}