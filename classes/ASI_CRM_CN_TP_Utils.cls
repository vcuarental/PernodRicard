public without sharing class ASI_CRM_CN_TP_Utils {
    /******************************************Trade Plan**********************************/
    public static final String TP_BUDGET_RTNAME = 'ASI_CRM_CN_TP_Budget_Plan';
    public static final String TP_RTNAME = 'ASI_CRM_CN_TP_Trade_Plan';
    public static final String TP_READ_RTNAME = 'ASI_CRM_CN_TP_Trade_Plan_Read_Only';
    public static final String TP_APPROVAL_RTNAME = 'ASI_CRM_CN_TP_Approval';
    public static final String TP_RD_APPROVAL_RTNAME = 'ASI_CRM_CN_TP_Approval_Read_Only';
    //CN Contract
    public static final String CN_Contract = 'ASI_CRM_CN_Contract';
    // Trade Plan Line Item
    public static final String TP_LINE_ITEM_RTNAME = 'ASI_CRM_CN_TP_Trade_Plan_Line_Item';
    //ASI MFM CN Prefix
    public static final String CN_PREFIX = 'ASI_MFM_CN_Prefix';
    //ASI_CRM_Contract_Cost__c
    public static final String CN_Contract_Cost = 'ASI_CRM_CN_Contract_Cost';
    // Trade plan status
    public static final String TPSTATUSDRAFT = 'Draft';
    public static final String TPSTATUSSUBMITTED = 'Submitted';
    public static final String TPSTATUSFINAL = 'Final';
    public static final String TPSTATUSCOMPLETE = 'Complete';
    // Promotion mechanism
    public static final String PMSCANDATA = 'scan data';
    public static final String PMSCANDATATAXAPI = 'scan data tax included';
    public static final String PMSCANDATATAXLABEL = 'scan data(含税)';
    public static final String PMINTAKEVERIFYAPI = 'intake price verification';
    public static final String PMINTAKEVERIFYLABEL = '进价核销';
    public static final String PMINTAKEVERIFYTAXAPI = 'intake price verification tax included';
    public static final String PMINTAKEVERIFYTAXLABEL = '进价核销(含税)';

    public static final Set<String> ALL_INTAKE_VERIFICATION_SET = new Set<String> {PMINTAKEVERIFYAPI, PMINTAKEVERIFYLABEL, PMINTAKEVERIFYTAXAPI, PMINTAKEVERIFYTAXLABEL};
    /******************************************Actual CM/GS**********************************/
    public static final String CM_GS_RTNAME = 'ASI_CRM_CN_Actual_CM_GS';
    public static final String BUDGET_CM = 'Budget CM';
    public static final String BUDGET_GS = 'Budget GS';
    /******************************************PO*******************************************/
    public static final String PO_BRSF_RTNAME = 'ASI_CRM_CN_Contract_TradePlan_BRSF_Line_Item';
    /******************************************Payment*******************************************/
    public static final String PAYMENT_RTNAME = 'ASI_CRM_CN_Payment_Request';
    public static final String PAYMENT_DETAIL_TP_RTNAME = 'ASI_CRM_CN_TP_Payment_Request_Detail_TradePlan';
    public static final String PAYMENT_DETAIL_OTHER_RTNAME = 'ASI_CRM_CN_Payment_Request_Detail_Other';

    public static final String PAYMENTSTATUSAPPROVED = 'Approved';

    // ASI_CRM_CN_Expense_Type__c
    public static final String PRICE_PROMOTION = '店家价格促销';
    public static final String DM_SECONDARY_DISPLAY_FEE = '海报/二次陈列费';
    public static final String SCANDATA_COST= 'PRC - Consumer Price Promotion';
    public static final String PRICE_PROMOTION_CONSUMER = '消费者价格促销';

    public static final Set<String> TRADEPLAN_CSV_TABLE_HEADER_ADD = new Set<String> {'本次付款促销金额', '本次付款海报陈列费金额'};
    public static final Map<String, Schema.SObjectType> sObjectDescribeMap = Schema.getGlobalDescribe();
    public static Decimal getCNTaxRate() {
        //query new tax
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id, ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        Decimal taxRate = 0.13;//cn default
        if (!taxRateList.isEmpty()) {
            taxRate = taxRateList[0].ASI_CRM_CN_Tax_Rate__c / 100;
        }
        return taxRate;
    }

    public static List<Map<String, String>> getPickListValuesIntoList(Schema.DescribeFieldResult fieldResult, String  type) {
        List<Map<String, String>> pickListValuesList = new List<Map<String, String>>();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for ( Schema.PicklistEntry pickListVal : ple) {
            Map<String, String> newMap = new Map<String, String>();
            if (type == 'promotionMode') {
                newMap.put('id', pickListVal.getLabel());
                newMap.put('PromotionMode', pickListVal.getLabel());
            } else {
                newMap.put('value', pickListVal.getLabel());
                newMap.put('label', pickListVal.getLabel());
            }

            pickListValuesList.add(newMap);
        }
        return pickListValuesList;
    }

    public static List<Map<String, String>> getSettingValuesIntoList(String picklistLabels) {
        List<Map<String, String>> pickListValuesList = new List<Map<String, String>>();

        List<String> picklistLabelList = picklistLabels.contains(',') ? picklistLabels.split(',') : new List<String> {picklistLabels};
        for ( String pickListLabel : picklistLabelList) {
            Map<String, String> newMap = new Map<String, String>();
            newMap.put('value', pickListLabel);
            newMap.put('label', pickListLabel);
            pickListValuesList.add(newMap);
        }
        return pickListValuesList;
    }
    /*
        get Specified picklist field's map<vlaue, label> by sobjectName and fieldname
        Map<api-label>
    */
    public static Map<String, String> getPicklistLabels(String sObjectName, String sFieldName) {
        Map<String, String> picValues = new Map<String, String>();

        // Map<String, Schema.SObjectType> sObjectDescribeMap = Schema.getGlobalDescribe();
        if (sObjectDescribeMap.containsKey(sObjectName)) {
            Map<String, Schema.SobjectField> sObjectFieldsMap =
                sObjectDescribeMap.get(sObjectName).getDescribe().fields.getMap();
            System.debug(LoggingLevel.INFO, '*** sObjectFieldsMap: ' + sObjectFieldsMap);
            if (sObjectFieldsMap.containsKey(sFieldName)) {
                Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFieldsMap.get(sFieldName).getDescribe();
                List<Schema.PicklistEntry> lPickEntryList = sObjectFieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry tPicklistEntry : lPickEntryList) {
                    picValues.put(tPicklistEntry.getValue(), tPicklistEntry.getLabel());
                }
            } else {
                //there is not exist this field
                return picValues;
            }
        } else {
            //there is not exist this sobject
            return picValues;
        }
        return picValues;
    }


    public static Map<String, String> generate999(List<Object> pLItemList) {
        Map<String, String> msgMap = new Map<String, String>();
        Set<Id> planIdSet = new Set<Id>();
        for (Object obj : pLItemList) {
            Map<String, Object> pLItemMap = (Map<String, Object>)obj;
            planIdSet.add((String)pLItemMap.get('PlanId'));
        }
        if (!planIdSet.isEmpty()) {
            List<ASI_MFM_Plan__c> tplans = [SELECT ASI_CRM_CN_TP_Outlet_Count__c,
                                            ASI_CRM_CN_TP_Region_Team__c,
                                            ASI_MFM_Remarks__c,
                                            ASI_CRM_CN_TP_Promotion_Mode__c,
                                            ASI_MFM_Approver_1__c,
                                            (SELECT ASI_MFM_Sub_brand_Code__c
                                             FROM Plan_Line_Items__r
                                             WHERE ASI_MFM_Sub_brand_Code__r.Name = '999'
                                                     AND ASI_MFM_Sub_brand_Code__r.RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand')
                                            FROM ASI_MFM_Plan__c
                                            WHERE Id IN :planIdSet];
            System.debug(LoggingLevel.INFO, '*** tplans: ' + JSON.serialize(tplans));
            List<ASI_MFM_Sub_brand__c> subBrands = [SELECT Id, ASI_CRM_CN_Standard_Bottle_Size__c
                                                    FROM ASI_MFM_Sub_brand__c
                                                    WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand'
                                                            AND Name = '999'];
            List<ASI_MFM_Plan_Line_Item__c> item999s = new List<ASI_MFM_Plan_Line_Item__c>();
            Decimal taxRate = ASI_CRM_CN_TP_Utils.getCNTaxRate() * 100;
            for (ASI_MFM_Plan__c tp : tplans) {
                if (tp.Plan_Line_Items__r.isEmpty()) {
                    ASI_MFM_Plan_Line_Item__c lineItem = new ASI_MFM_Plan_Line_Item__c();
                    lineItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_CRM_CN_TP_Trade_Plan_Line_Item');
                    lineItem.ASI_MFM_Sub_brand_Code__c = subBrands.isEmpty() ? null : subBrands[0].Id;
                    lineItem.ASI_CRM_CN_TP_Subsidies__c =  1;
                    lineItem.ASI_MFM_Remarks__c = tp.ASI_MFM_Remarks__c;
                    lineItem.ASI_MFM_Plan__c = tp.Id;
                    lineItem.ASI_CRM_CN_TP_Tax_Rate__c = taxRate;
                    lineItem.ASI_CRM_CN_TP_Promotion_Mode__c = tp.ASI_CRM_CN_TP_Promotion_Mode__c;
                    item999s.add(lineItem);
                }

            }
            System.debug(LoggingLevel.INFO, '*** item999s: ' + item999s);
            if (!item999s.isEmpty()) {
                try {
                    insert item999s;
                } catch (Exception e) {
                    msgMap.put('ERROR', 'Line: ' + e.getLineNumber() + e.getMessage());
                    return msgMap;
                }
            } else {
                msgMap.put('ERROR', '选择的Trade Plan下已存在Dummy产品，请勿重复生成！');
            }
        }
        msgMap.put('SUCCESS', 'SUCCESS');
        return msgMap;
    }

    public static Map<String, String> deletePlans(List<Object> pLItemList) {
        Map<String, String> msgMap = new Map<String, String>();
        List<ASI_MFM_Plan__c> deletempList = new List<ASI_MFM_Plan__c>();
        Set<Id> planIdSet = new Set<Id>();
        for (Object obj : pLItemList) {
            Map<String, Object> pLItemMap = (Map<String, Object>)obj;
            if (!planIdSet.contains((String)pLItemMap.get('PlanId'))) {
                planIdSet.add((String)pLItemMap.get('PlanId'));
                deletempList.add(new ASI_MFM_Plan__c(Id = (String)pLItemMap.get('PlanId')));
            }
        }
        if (!deletempList.isEmpty()) {
            try {
                delete deletempList;
            } catch (Exception e) {
                msgMap.put('ERROR', 'Line: ' + e.getLineNumber() + e.getMessage());
                return msgMap;
            }
        }
        msgMap.put('SUCCESS', 'SUCCESS');
        return msgMap;
    }
    /*
        Last payment form
        Map<String, POBRSFInfo> key:sub-brand   value:POBRSFInfo
    */
    public static Map<String, POBRSFInfo> LastpaymentForm(String paymentId) {
        Map<String, POBRSFInfo> brsfMap = new Map<String, POBRSFInfo>();

        List<ASI_TH_CRM_PaymentRequest__c> payment  = [SELECT ASI_TH_CRM_Contract__c,
                                           ASI_TH_CRM_Contract__r.ASI_CRM_Version__c,
                                           ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_No__c
                                           FROM ASI_TH_CRM_PaymentRequest__c
                                           WHERE Id = :paymentId
                                                   AND RecordType.developerName = :PAYMENT_RTNAME
                                                      ];
        if (payment.size() == 0) {
            return brsfMap;
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> POBRSFList = [SELECT ASI_CRM_CN_Sub_Brand__c,
                                                                        ASI_CRM_CN_Sub_Brand__r.Name,
                                                                        ASI_CRM_CN_Total_Volume_9L__c,
                                                                        ASI_CRM_CN_TP_Promotion_Cost__c,
                                                                        ASI_CRM_CN_TP_Fixed_Cost__c,
                                                                        ASI_CRM_CN_GS_Per_9L__c,
                                                                        ASI_CRM_CN_TP_GS_Amount__c,
                                                                        ASI_CRM_CN_TP_CM_Per_9L__c,
                                                                        ASI_CRM_CN_TP_CM_Amount__c,
                                                                        ASI_CRM_CN_TP_GS_Percent__c
                                                                        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                                                WHERE (ASI_CRM_CN_Contract__c = :payment[0].ASI_TH_CRM_Contract__c
                                                                      OR (ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_No__c = :payment[0].ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_No__c
                                                                        AND ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c = '0.0'))
                                                                 AND RecordType.DeveloperName = :PO_BRSF_RTNAME
                                                                 ORDER BY ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c DESC];
        System.debug(LoggingLevel.INFO, '*** : POBRSFList' + Json.serializePretty(POBRSFList));
        Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> POBRSFMap = new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf : POBRSFList) {
            POBRSFMap.put(brsf.ASI_CRM_CN_Sub_Brand__c, brsf);
        }

        List<AggregateResult> subbrandResults = [SELECT ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c poId,
                              ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c sudBrandId,
                              SUM(ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_ActualVolumesIn9L__c) qty,
                              SUM(ASI_CRM_CN_TP_Promotion_Fee__c) promotionCost,
                              SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fixedCost,
                              ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c regionId
                              FROM ASI_TH_CRM_PaymentRequestLineItem__c
                              WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :payment[0].ASI_TH_CRM_Contract__c
                                      AND RecordType.DeveloperName = :PAYMENT_DETAIL_TP_RTNAME
                                              GROUP BY ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c,
                              ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,
                              ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c
                                                ];
        System.debug(LoggingLevel.INFO, '*** subbrandResults: ' + JSON.serialize( subbrandResults) );
        for (AggregateResult agg : subbrandResults) {
            POBRSFInfo brsfinfo = new POBRSFInfo();
            ASI_CRM_CN_Contract_BRSF_Line_Item__c pobrsf = POBRSFMap.get(String.valueOf(agg.get('sudBrandId')));
            brsfinfo.subBrandName = pobrsf == null ? '' : pobrsf.ASI_CRM_CN_Sub_Brand__r.Name;
            brsfinfo.actualVolumeIn9L = agg.get('qty') != null ? Decimal.valueOf(String.valueOf(agg.get('qty'))) : 0;
            brsfinfo.actualAmount = agg.get('promotionCost') != null ? Decimal.valueOf(String.valueOf(agg.get('promotionCost'))) : 0;
            brsfinfo.fixedCost = agg.get('fixedCost') != null ? Decimal.valueOf(String.valueOf(agg.get('fixedCost'))) : 0;
            brsfinfo.cmAmount = pobrsf == null ? 0 : pobrsf.ASI_CRM_CN_TP_CM_Per_9L__c * brsfinfo.actualVolumeIn9L;
            // System.debug(LoggingLevel.INFO, '*** :pobrsf.ASI_CRM_CN_TP_CM_Per_9L__c ' + pobrsf.ASI_CRM_CN_TP_CM_Per_9L__c);
            brsfinfo.gsAmount = pobrsf == null ? 0 : pobrsf.ASI_CRM_CN_GS_Per_9L__c * brsfinfo.actualVolumeIn9L;
            // System.debug(LoggingLevel.INFO, '*** :pobrsf.ASI_CRM_CN_GS_Per_9L__c ' + pobrsf.ASI_CRM_CN_GS_Per_9L__c);

            // brsfinfo.gsPercent = brsfinfo.actualAmount / brsfinfo.gsAmount;
            brsfMap.put(String.valueOf(agg.get('sudBrandId')), brsfinfo);
        }

        return brsfMap;
    }

    public static List<ASI_MFM_Plan_Line_Item__c> getTradePlanListByIds(List<Id> tpItemIds) {
        return [SELECT ASI_CRM_CN_TP_Last_Payment_Fixed_Cost__c, ASI_CRM_CN_TP_Last_Promotion_Fee__c,
                        ASI_CRM_CN_TP_FixedCost_Payment_Amount__c, ASI_CRM_CN_TP_Promotion_Payment_Amount__c, ASI_CRM_CN_TP_Actual_Total_Fee_Percent__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_Customer__r.ASI_CRM_Channel__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c,
                        ASI_CRM_CN_TP_Total_Fee_Percent__c, ASI_CRM_CN_TP_Posters_Fee__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Activity_NO__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_PO_No__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_PO_Version__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_PaymentRequestNumber__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_Total_Fixed_Cost__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Estimated_Total_Amount__c, ASI_CRM_CN_TP_Fixed_Cost__c ,
                        ASI_CRM_CN_TP_Retail_Price__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_TP_Display_Fee__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_CCity__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_NewChannel__c,
                        ASI_CRM_CN_TP_LPP__r.ASI_CRM_CN_TP_Benchmark__c, ASI_MFM_Plan__c, ASI_CRM_CN_TP_LPP__c, ASI_CRM_CN_TP_LPP__r.ASI_CRM_CN_TP_LPP_Price__c, ASI_CRM_CN_TP_LPP_Price__c,
                        ASI_MFM_Plan__r.Name, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Cover_City__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Status__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_KA_Account__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_KA_Account__r.Name, ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c, ASI_MFM_Plan__r.ASI_MFM_Start_Date__c, ASI_MFM_Plan__r.ASI_MFM_End_Date__c,
                        ASI_MFM_Plan__r.ASI_MFM_Status__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Outlet_Count__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__r.Name, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Account_Type__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Channel__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_Channel__r.Name, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Budget_Plan__r.ASI_CRM_CN_TP_Customer__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Customer__r.Name,
                        Id, ASI_CRM_CN_TP_T1_Price__c, ASI_CRM_CN_TP_Tax_Rate__c, ASI_CRM_CN_TP_Bottle_Size__c, ASI_CRM_CN_TP_Plan_Fee_Percent__c, ASI_CRM_CN_TP_Actual_Fee_Percent__c, Name, ASI_MFM_Sub_brand_Code__c,
                        ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_Remarks__c, ASI_CRM_CN_TP_Promotion_Type__c, ASI_CRM_CN_TP_Promotion_Mode__c, ASI_MFM_Unit_Price__c, ASI_CRM_CN_TP_Promotion_Unit_Price__c, ASI_CRM_CN_TP_Promotion_Purchase_Price__c,
                        ASI_CRM_CN_TP_Normal_Purchase_Price__c, ASI_MFM_Distributor_Amount__c, ASI_CRM_CN_TP_Subsidies__c, ASI_CRM_CN_TP_Estimated_Qty__c, ASI_CRM_CN_TP_Estimated_Amount__c, ASI_CRM_CN_TP_Advice_Amount__c, ASI_CRM_CN_TP_Actual_Qty__c,
                        ASI_MFM_Actual_Spending_Amount__c, ASI_CRM_CN_TP_Payment_Amount__c, ASI_MFM_Plan__r.ASI_MFM_Remarks__c, ASI_CRM_CN_TP_Total_Actual_Vol__c,ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__r.ASI_CRM_Chinese_Name__c,ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region_P__c,
                        ASI_CRM_CN_TP_Promotion_Product__r.Name, ASI_CRM_CN_TP_Promotion_Product__c, ASI_MFM_Plan__r.ASI_CRM_CN_TP_Customer__c,ASI_MFM_Plan__r.ASI_CRM_CN_TP_KA_Banner__c,ASI_CRM_CN_TP_Promotion_Content__c,
                        ASI_MFM_Plan__r.ASI_CRM_CN_TP_Customer__r.OwnerId,ASI_MFM_Plan__r.ASI_CRM_CN_TP_Customer__r.Owner.Name,ASI_MFM_List_Item_Description__c,
                        (SELECT Id FROM Payment_Request_Line_Items__r
                         WHERE RecordType.DeveloperName = :PAYMENT_DETAIL_TP_RTNAME)
                FROM ASI_MFM_Plan_Line_Item__c
                WHERE Id IN:tpItemIds
                AND RecordType.DeveloperName = :TP_LINE_ITEM_RTNAME AND ASI_MFM_Plan__r.ASI_CRM_CN_TP_Customer__c != null
                ORDER BY ASI_MFM_Plan__r.ASI_CRM_CN_TP_KA_Banner__c, ASI_MFM_Plan__r.Name DESC, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c DESC
               ];
    }

    public static Map<String, String> savePLItem(List<Object> pLItemList) {
        Map<String, String> msgMap = new Map<String, String>();
        List<ASI_MFM_Plan_Line_Item__c> updatepLItemList = new List<ASI_MFM_Plan_Line_Item__c>();
        for (Object obj : pLItemList) {
            Map<String, Object> pLItemMap = (Map<String, Object>)obj;
            ASI_MFM_Plan_Line_Item__c pLItemInstance = new ASI_MFM_Plan_Line_Item__c();
            pLItemInstance.Id = (String)pLItemMap.get('PlanLineItemId');
            pLItemInstance.ASI_CRM_CN_TP_Total_Actual_Vol__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('TotalActualQty')))) + nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ActualQty'))));
            String PromotionModeStr = (String)pLItemMap.get('PromotionMode');
            pLItemInstance.ASI_CRM_CN_TP_Promotion_Mode__c = (PromotionModeStr == PMINTAKEVERIFYLABEL ? PMINTAKEVERIFYAPI : (PromotionModeStr == PMINTAKEVERIFYTAXLABEL ? PMINTAKEVERIFYTAXAPI : PromotionModeStr == PMSCANDATATAXLABEL ? PMSCANDATATAXAPI :PromotionModeStr));
            pLItemInstance.ASI_CRM_CN_TP_Subsidies__c = pLItemInstance.ASI_CRM_CN_TP_Promotion_Mode__c == PMSCANDATA || pLItemInstance.ASI_CRM_CN_TP_Promotion_Mode__c == PMSCANDATATAXAPI
                                                        ? nv(Decimal.valueof(String.valueOf(pLItemMap.get('Subsidies'))))
                                                        : Decimal.valueof(String.valueOf(pLItemMap.get('NormalPurchasePrice'))) - Decimal.valueof(String.valueOf(pLItemMap.get('PromotionPurchasePrice')));
            pLItemInstance.ASI_CRM_CN_TP_Retail_Price__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('RetailPrice'))));
            pLItemInstance.ASI_CRM_CN_TP_Promotion_Unit_Price__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('PromotionUnitPrice'))));
            pLItemInstance.ASI_CRM_CN_TP_Normal_Purchase_Price__c = nv(Decimal.valueof(String.valueOf(pLItemMap.get('NormalPurchasePrice'))));
            pLItemInstance.ASI_CRM_CN_TP_Promotion_Purchase_Price__c = nv(Decimal.valueof(String.valueOf(pLItemMap.get('PromotionPurchasePrice'))));
            pLItemInstance.ASI_CRM_CN_TP_Estimated_Qty__c = nv(Decimal.valueof(String.valueOf(pLItemMap.get('EstimatedQty'))));
            pLItemInstance.ASI_CRM_CN_TP_Posters_Fee__c = nv(Decimal.valueof(String.valueOf(pLItemMap.get('PostersFee'))));
            pLItemInstance.ASI_CRM_CN_TP_Display_Fee__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('DisplayFee'))));
            pLItemInstance.ASI_CRM_CN_TP_Actual_Qty__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ActualQty'))));
            pLItemInstance.ASI_CRM_CN_TP_Payment_Amount__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('PaymentAmount'))));
            pLItemInstance.ASI_CRM_CN_TP_Last_Promotion_Fee__c = 0;
            pLItemInstance.ASI_CRM_CN_TP_Promotion_Content__c = (String)pLItemMap.get('PromotionContent');
            updatepLItemList.add(pLItemInstance);
        }
        if (updatepLItemList.size() > 0) {
            try {
                update updatepLItemList;
            } catch (Exception e) {
                system.debug('Update updatepLItemList Fail' + e.getMessage());
                msgMap.put('ERROR', e.getLineNumber() + 'ROW ' + e.getMessage());
                return msgMap;
            }
        }
        msgMap.put('SUCCESS', 'Save Success');
        return msgMap;
    }

    public static Map<String, String> saveTPApprovalAndUpdateTp(String remarks, List<Object> pLItemList) {
        Map<String, String> msgMap = new Map<String, String>();
        ASI_MFM_Plan__c approvalTP = new ASI_MFM_Plan__c();
        Set<String> pIdSet = new Set<String>();
        for (Object obj : pLItemList) {
            Map<String, Object> pLItemMap = (Map<String, Object>)obj;
            if (pLItemMap.containsKey('PlanId') && String.isNotBlank((String)pLItemMap.get('PlanId'))) {
                pIdSet.add((String)pLItemMap.get('PlanId'));
            }
        }
        approvalTP.RecordTypeId = Schema.getGlobalDescribe().get('ASI_MFM_Plan__c').getDescribe().getRecordTypeInfosByDeveloperName().get(TP_APPROVAL_RTNAME).getRecordTypeId();
        approvalTP.ASI_MFM_Status__c = 'Draft';
        approvalTP.ASI_MFM_Remarks__c = remarks;
        Map<String, ASI_MFM_Prefix__c> prefixMap = new Map<String, ASI_MFM_Prefix__c>();
        List<ASI_MFM_Prefix__c> prefixlist= [SELECT Name, ASI_MFM_Fiscal_year__c FROM ASI_MFM_Prefix__c WHERE Name = 'CN TP Approval'];
        for (ASI_MFM_Prefix__c pre : prefixlist) {
            prefixMap.put(pre.ASI_MFM_Fiscal_year__c, pre);
        }
        for (ASI_MFM_Plan__c tpInstance : [SELECT ASI_CRM_CN_TP_Channel__c,
                                                   ASI_CRM_CN_TP_Region__c,
                                                   ASI_MFM_Fiscal_year__c,
                                                   ASI_CRM_CN_TP_KA_Banner__c,
                                                   ASI_CRM_CN_TP_Customer__c
                                           FROM ASI_MFM_Plan__c
                                           WHERE Id IN :pIdSet
                                           AND (RecordType.developerName = :TP_RTNAME
                                               OR RecordType.developerName = :TP_READ_RTNAME)
                                            LIMIT 1]) {
            approvalTP.ASI_CRM_CN_TP_Region__c = tpInstance.ASI_CRM_CN_TP_Region__c;
            approvalTP.ASI_CRM_CN_TP_Channel__c = tpInstance.ASI_CRM_CN_TP_Channel__c;
            approvalTP.ASI_MFM_Fiscal_year__c = tpInstance.ASI_MFM_Fiscal_year__c;
            approvalTP.ASI_MFM_Prefix__c = prefixMap.get(approvalTP.ASI_MFM_Fiscal_year__c) != null ? prefixMap.get(approvalTP.ASI_MFM_Fiscal_year__c).Id : null;
            approvalTP.ASI_CRM_CN_TP_KA_Banner__c = tpInstance.ASI_CRM_CN_TP_KA_Banner__c;
            approvalTP.ASI_CRM_CN_TP_Customer__c = tpInstance.ASI_CRM_CN_TP_Customer__c;
            approvalTP.RecordTypeId = Schema.getGlobalDescribe().get('ASI_MFM_Plan__c').getDescribe().getRecordTypeInfosByDeveloperName().get(TP_RD_APPROVAL_RTNAME).getRecordTypeId();
        }
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(approvalTP): ' + JSON.serialize(approvalTP));
            insert approvalTP;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(approvalTP.id);
            // Submit the approval request 
            Approval.ProcessResult result = Approval.process(req1);
            List<ASI_MFM_Plan__c> updateTPList = new List<ASI_MFM_Plan__c>();
            for (String pId : pIdSet) {
                ASI_MFM_Plan__c tpInstance = new ASI_MFM_Plan__c();
                tpInstance.Id = pId;
                tpInstance.ASI_CRM_CN_TP_Approval__c = approvalTP.Id;
                tpInstance.ASI_MFM_Status__c = 'Submitted';
                tpInstance.RecordTypeId = Schema.getGlobalDescribe().get('ASI_MFM_Plan__c').getDescribe().getRecordTypeInfosByDeveloperName().get(TP_READ_RTNAME).getRecordTypeId();
                updateTPList.add(tpInstance);
            }
            if (updateTPList.size() > 0) {
                update updateTPList;
                approvalTP.ASI_MFM_Status__c = 'Submitted';
                update approvalTP;
            }
            
        } catch (Exception e) {
            Database.rollback(sp);
            msgMap.put('ERROR', e.getLineNumber() + 'Row ' + e.getMessage());
            return msgMap;
        }
        msgMap.put('SUCCESS', approvalTP.Id);
        return msgMap;
    }

     public static Map<String, String> savePo(List<Object> pLItemList) {
        Map<String, String> msgMap = new Map<String, String>();
        Set<String> tpIdSet = new Set<String>();
        Set<String> pLItemIdSet = new Set<String>();
        String exsitPOId = '';
        for (Object obj : pLItemList) {
            Map<String, Object> pLItemMap = (Map<String, Object>)obj;
            if (pLItemMap.containsKey('PlanId') && String.isNotBlank((String)pLItemMap.get('PlanId'))) {
                tpIdSet.add((String)pLItemMap.get('PlanId'));
            }
            if (pLItemMap.containsKey('POId') && String.isNotBlank((String)pLItemMap.get('POId'))) {
                exsitPOId = (String)pLItemMap.get('POId');
            }
        }
        AggregateResult tpAResult = [SELECT MIN(ASI_MFM_Start_Date__c) minDate, MAX(ASI_MFM_End_Date__c) maxDate
                                     FROM ASI_MFM_Plan__c
                                     WHERE id in:tpIdSet
                                     AND (RecordType.developerName = :TP_RTNAME
                                         OR RecordType.developerName = :TP_READ_RTNAME)
                                     AND ASI_MFM_Start_Date__c != null
                                     AND ASI_MFM_End_Date__c != null];
        ASI_MFM_Plan__c planInstance = [SELECT ASI_CRM_CN_TP_Customer__c,
                                                ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_NewChannel__c,
                                                ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_CCity__c,
                                                ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c,
                                                ASI_MFM_Remarks__c
                                        FROM ASI_MFM_Plan__c
                                        WHERE id in:tpIdSet
                                        AND (RecordType.developerName = :TP_RTNAME
                                             OR RecordType.developerName = :TP_READ_RTNAME)
                                        LIMIT 1];
        ASI_TH_CRM_Contract__c newPO = new ASI_TH_CRM_Contract__c();
        ASI_TH_CRM_Contract__c exsitPO = new ASI_TH_CRM_Contract__c();
        if (String.isNotBlank(exsitPOId)) {
             exsitPO = [SELECT ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_PO_Version__c, Name,ASI_CRM_CN_Effective_Date__c,
                              ASI_CRM_CN_PO_No__c,ASI_CRM_CN_Bottle_Collection_Rate__c,OwnerId,ASI_CRM_Contract_Version_Checking__c, 
                              ASI_CRM_CN_Outlet_WS__c, ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_Source_of_Contract__c,
                              ASI_CRM_CN_Status__c, ASI_CRM_Investment_Type__c, ASI_CRM_CN_Contract_Upload__c,
                              ASI_CRM_CN_Description__c, ASI_CRM_Martell_BC_Rate__c, ASI_CRM_CN_Group_Contract__c,
                              ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c, ASI_CRM_PO_City__c,ASI_CRM_CN_TP_Is_Trade_Plan_CN__c,
                              ASI_CRM_CN_Vol_Budget_LE__c, ASI_CRM_CN_Budget_LE__c,ASI_TH_CRM_Outlet__c,
                              ASI_CRM_CN_Sys_Approver_1__c,ASI_CRM_CN_Sys_Approver_2__c, ASI_CRM_CN_Sys_Approver_3__c, 
                              ASI_CRM_CN_Sys_Approver_4__c, ASI_CRM_CN_Sys_Approver_5__c, ASI_CRM_CN_Sys_Approver_6__c,
                              ASI_CRM_CN_Sys_Approver_7__c, ASI_CRM_CN_Sys_Approver_8__c, ASI_CRM_CN_Sys_Approver_9__c,
                              ASI_CRM_CN_Sys_Approver_10__c, ASI_CRM_CN_Sys_Approver_11__c,ASI_CRM_CN_V0_0_PO_version__c,
                              RecordTypeId,
                              (SELECT ASI_CRM_CN_Contract__c, 
                                     ASI_CRM_CN_Estimate_Amount__c,
                                     ASI_CRM_CNY_Est__c,
                                     ASI_CRM_Other_Est__c,
                                     Name,
                                     ASI_CRM_CN_Contract_Amount__c,
                                     RecordTypeId,
                                     ASI_CRM_MAF_Est__c, 
                                     ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c,
                                     ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c,
                                     ASI_CRM_CN_Other_Cost_Payment_Request__c
                              FROM Contract_Costs__r),
                              (SELECT ASI_TH_CRM_Contract__c FROM ASI_TH_CRM_PaymentRequests_Contract__r)
                          FROM ASI_TH_CRM_Contract__c
                          WHERE Id = :exsitPOId
                          AND ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true
                          LIMIT 1];
            newPO = exsitPO.clone();
            newPO.Name = exsitPO.Name + '1';
            newPO.ASI_CRM_CN_Last_PO_version__c = exsitPO.Id;
            newPo.ASI_CRM_CN_V0_0_PO_version__c = exsitPO.ASI_CRM_CN_V0_0_PO_version__c == null && exsitPO.ASI_CRM_CN_PO_Version__c == '0.0' ? exsitPO.Id : exsitPO.ASI_CRM_CN_V0_0_PO_version__c;
            newPO.ASI_TH_CRM_Promotion_Type__c = 'Promotion';
            newPO.ASI_CRM_CN_Status__c = ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT;
            newPO.ASI_CRM_CN_PO_Version__c = String.valueOf(Decimal.valueOf(exsitPO.ASI_CRM_CN_PO_Version__c) + 0.1);
            newPO.ASI_CRM_CN_PO_Start_Date__c = (Date)tpAResult.get('minDate');
            newPO.ASI_CRM_CN_PO_End_Date__c = (Date)tpAResult.get('maxDate');
            newPO.ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true;
        } else {
            newPO.Name = 'Automated, Do not Change';
            newPO.ASI_CRM_CN_PO_Start_Date__c = (Date)tpAResult.get('minDate');
            newPO.ASI_CRM_CN_PO_End_Date__c = (Date)tpAResult.get('maxDate');
            newPO.ASI_CRM_CN_Outlet_WS__c = planInstance.ASI_CRM_CN_TP_Customer__c;
            newPO.ASI_CRM_PO_Channel__c = planInstance.ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_NewChannel__c;
            newPO.ASI_CRM_PO_City__c = planInstance.ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_CCity__c;
            newPO.ASI_CRM_PO_Province__c = planInstance.ASI_CRM_CN_TP_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__c;
            newPO.ASI_CRM_CN_PO_Version__c = '0.0';
            newPO.ASI_CRM_CN_TP_Is_Trade_Plan_CN__c = true;
            newPO.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_Contract__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_Contract').getRecordTypeId();
            newPO.ASI_TH_CRM_Promotion_Type__c = 'Promotion';
            newPO.ASI_CRM_CN_Status__c = 'Draft';
            newPO.ASI_CRM_CN_Description__c = planInstance.ASI_MFM_Remarks__c;
            newPO.ASI_CRM_CN_Bottle_Collection_Rate__c = 0;
        }
        
        
        Savepoint sp = Database.setSavepoint();
        try {
            insert newPO;
            List<ASI_CRM_Contract_Cost__c> inCostList = new List<ASI_CRM_Contract_Cost__c>();
            for (ASI_CRM_Contract_Cost__c ccost : exsitPO.Contract_Costs__r) {
                ASI_CRM_Contract_Cost__c ccost2 = ccost.clone();
                ccost2.ASI_CRM_CN_Contract__c = newPO.Id;
                inCostList.add(ccost2);
            }
            if (!inCostList.isEmpty()) {
                insert inCostList;
            }
            if (exsitPO.Id != null) {
                exsitPO.ASI_CRM_CN_Status__c = 'Archived';
                update exsitPO;
            }

            List<ASI_TH_CRM_PaymentRequest__c> upPmtList = new List<ASI_TH_CRM_PaymentRequest__c>();
            for (ASI_TH_CRM_PaymentRequest__c pmt : exsitPO.ASI_TH_CRM_PaymentRequests_Contract__r) {
                pmt.ASI_TH_CRM_Contract__c = newPO.Id;
                upPmtList.add(pmt);
            }
            if (!upPmtList.isEmpty()) {
                update upPmtList;
            }
            List<ASI_MFM_Plan__c> updateTpList = new List<ASI_MFM_Plan__c>();
            for (String planId : tpIdSet) {
                ASI_MFM_Plan__c tpInstance = new ASI_MFM_Plan__c();
                tpInstance.id = planId;
                tpInstance.ASI_CRM_CN_TP_Contract__c = newPO.id;
                updateTpList.add(tpInstance);
            }
            if (updateTpList.size() > 0) {
                update updateTpList;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            msgMap.put('ERROR', e.getLineNumber() + 'Row ' + e.getMessage());
            return msgMap;
        }
        msgMap.put('SUCCESS', newPO.id);
        return msgMap;
    }

    public static Map<String, String> savePayment(List<Object> pLItemList) {
        Map<String, String> msgMap = new Map<String, String>();
        Set<String> pLItemSet = new Set<String>();
        String po;
        for (Object obj : pLItemList) {
            Map<String, Object> pLItemMap = (Map<String, Object>)obj;
            if (pLItemMap.containsKey('PlanLineItemId') && String.isNotBlank((String)pLItemMap.get('PlanLineItemId'))) {
                pLItemSet.add((String)pLItemMap.get('PlanLineItemId'));
            }
        }

        List<ASI_MFM_Plan_Line_Item__c> planLineItems = [SELECT ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_PO_Version__c,
                                                            ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                                                            ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_PO_No__c,
                                                            ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Outlet_WS__c,
                                                            ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c
                                                        FROM ASI_MFM_Plan_Line_Item__c
                                                       WHERE id in:pLItemSet
                                                         AND RecordType.developerName = :TP_LINE_ITEM_RTNAME
                                                         AND ASI_MFM_Plan__c != null
                                                         AND ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c != null
                                                         LIMIT 1];
        if (planLineItems.size() == 0) {
            msgMap.put('ERROR', 'PO不存在');
            return msgMap;
        }
        po = planLineItems[0].ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c;


        // Added by Jack Yuan start
        Boolean hasDraftPmt = false;
        List<ASI_TH_CRM_PaymentRequest__c> draftPayment = [SELECT Id, Name FROM ASI_TH_CRM_PaymentRequest__c
                                                           WHERE ASI_TH_CRM_Status__c = 'Draft'
                                                             AND ASI_TH_CRM_Contract__c = :po
                                                             AND ASI_CRM_Total_Payee_Line__c = 0
                                                           ORDER BY CreatedDate DESC LIMIT 1];
        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> planItemIdPmtItemMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        if (!draftPayment.isEmpty()) {
            hasDraftPmt = true;
            List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineItems = [SELECT ASI_CRM_CN_TP_Plan_Line_Item__c, ASI_CRM_CN_Actual_Vol__c,
                                                                                   ASI_CRM_CN_TP_Promotion_Fee__c, ASI_CRM_CN_TP_Fixed_Cost__c
                                                                             FROM ASI_TH_CRM_PaymentRequestLineItem__c
                                                                            WHERE ASI_TH_CRM_Payment_Request__c = :draftPayment[0].Id];
            for (ASI_TH_CRM_PaymentRequestLineItem__c pmtItem : paymentLineItems) {
                if (pmtItem.ASI_CRM_CN_TP_Plan_Line_Item__c != null) {
                    planItemIdPmtItemMap.put(pmtItem.ASI_CRM_CN_TP_Plan_Line_Item__c, pmtItem);
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** planItemIdPmtItemMap: ' + planItemIdPmtItemMap);
        System.debug(LoggingLevel.INFO, '*** draftPayment: ' + draftPayment);
       
        // Added by Jack Yuan end

        ASI_TH_CRM_PaymentRequest__c payment = new ASI_TH_CRM_PaymentRequest__c();
        for (ASI_MFM_Plan_Line_Item__c pLItemVar : planLineItems) {
            payment.ASI_TH_CRM_Contract__c = pLItemVar.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c;
            //po = pLItemVar.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__c;
            payment.ASI_CRM_CN_PO_Version__c = pLItemVar.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_PO_Version__c;
            payment.ASI_CRM_CN_Bottle_Collection_Rate__c = pLItemVar.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c;
            payment.ASI_CRM_CN_Adjustment__c = 100;
            payment.Name = pLItemVar.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_PO_No__c + '-' + getPaymentName(payment.ASI_TH_CRM_Contract__c);
            payment.ASI_CRM_CN_OutletWS__c = pLItemVar.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Contract__r.ASI_CRM_CN_Outlet_WS__c;
            payment.ASI_CRM_CN_Payment_Raised_Date__c = Date.today();
            payment.ASI_TH_CRM_Status__c = 'Draft';
            payment.ASI_CRM_CN_Payment_Type__c = 'Discount';
            payment.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequest__c').getDescribe().getRecordTypeInfosByDeveloperName().get(PAYMENT_RTNAME).getRecordTypeId();
        }

        List<ASI_TH_CRM_PaymentRequestLineItem__c> pRLItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        List<ASI_MFM_Plan_Line_Item__c> updatePLItemList = new List<ASI_MFM_Plan_Line_Item__c>();
        Decimal totalPromotionCost = 0 ;
        Decimal totalPromotionCostScandata = 0 ;
        Decimal totalFixedCost = 0;
        Decimal poFixedcost = 0;
        Decimal poPromotionFee = 0;

        for (Object obj : pLItemList) {
            Map<String, Object> pLItemMap = (Map<String, Object>)obj;
            String PromotionModeStr = (String)pLItemMap.get('PromotionMode');
            ASI_TH_CRM_PaymentRequestLineItem__c paymentItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
            ASI_MFM_Plan_Line_Item__c pLItemInstance = new ASI_MFM_Plan_Line_Item__c();
            paymentItem.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByDeveloperName().get(PAYMENT_DETAIL_TP_RTNAME).getRecordTypeId();
            paymentItem.ASI_CRM_CN_TP_Plan_Line_Item__c = (String)pLItemMap.get('PlanLineItemId');
            paymentItem.ASI_CRM_CN_Actual_Vol__c = nv(Decimal.valueOf(String.valueof(pLItemMap.get('ActualQty'))));
            //paymentItem.ASI_CRM_CN_TP_Fixed_Cost__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('AdviceFixedCost'))));
            paymentItem.ASI_CRM_CN_TP_Fixed_Cost__c = nv(Decimal.valueOf(String.valueof(pLItemMap.get('ThisFixedCost'))));
            totalFixedCost += nv(Decimal.valueOf(String.valueof(pLItemMap.get('ThisFixedCost'))));
            paymentItem.ASI_CRM_CN_TP_Promotion_Fee__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisPromotionAmount'))));
            system.debug('ThisPromotionAmount** ' + nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisPromotionAmount')))));
            if (String.isNotBlank(PromotionModeStr) && PromotionModeStr.contains('scan data')) {
                totalPromotionCostScandata += nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisPromotionAmount'))));
            } else {
                totalPromotionCost += nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisPromotionAmount'))));
            }

            paymentItem.ASI_CRM_CN_Total_Payable__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisFixedCost')))) + nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisPromotionAmount'))));
            system.debug('ThisFixedCost** ' + nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisFixedCost')))));

            paymentItem.ASI_CRM_CN_TP_Amount__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisFixedCost')))) + nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisPromotionAmount'))));
            paymentItem.ASI_TH_CRM_Amount__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisFixedCost')))) + nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisPromotionAmount'))));
            pLItemInstance.Id = (String)pLItemMap.get('PlanLineItemId');
            pLItemInstance.ASI_CRM_CN_TP_FixedCost_Payment_Amount__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('FixedCostPaymentAmount'))));
            if (hasDraftPmt) {
                pLItemInstance.ASI_CRM_CN_TP_FixedCost_Payment_Amount__c = 0;
            } 
            pLItemInstance.ASI_CRM_CN_TP_FixedCost_Payment_Amount__c += nv(Decimal.valueof(String.valueOf(pLItemMap.get('ThisFixedCost'))));
            
            pLItemInstance.ASI_CRM_CN_TP_Promotion_Payment_Amount__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('PromotionPaymentAmount'))));
            if (hasDraftPmt) {
                pLItemInstance.ASI_CRM_CN_TP_Promotion_Payment_Amount__c = 0;
            } 
            pLItemInstance.ASI_CRM_CN_TP_Promotion_Payment_Amount__c += nv(Decimal.valueof(String.valueOf(pLItemMap.get('ThisPromotionAmount'))));

            pLItemInstance.ASI_CRM_CN_TP_Payment_Amount__c = nv(Decimal.valueOf(String.valueOf(pLItemMap.get('PaymentAmount'))));
            if (hasDraftPmt) {
                pLItemInstance.ASI_CRM_CN_TP_Payment_Amount__c = 0;
            }
            if (hasDraftPmt) {
                pLItemInstance.ASI_CRM_CN_TP_Total_Actual_Vol__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('ActualQty'))));
            } else {
                pLItemInstance.ASI_CRM_CN_TP_Total_Actual_Vol__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('TotalActualQty')))) + nv(Decimal.valueof(String.valueof(pLItemMap.get('ActualQty'))));
            }
            pLItemInstance.ASI_CRM_CN_TP_Payment_Amount__c += nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisFixedCost')))) + nv(Decimal.valueOf(String.valueOf(pLItemMap.get('ThisPromotionAmount'))));

            pLItemInstance.ASI_CRM_CN_TP_Promotion_Mode__c = (PromotionModeStr == PMINTAKEVERIFYLABEL ? PMINTAKEVERIFYAPI : (PromotionModeStr == PMINTAKEVERIFYTAXLABEL ? PMINTAKEVERIFYTAXAPI : PromotionModeStr == PMSCANDATATAXLABEL ? PMSCANDATATAXAPI : PromotionModeStr));
            pLItemInstance.ASI_CRM_CN_TP_Subsidies__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('Subsidies'))));
            pLItemInstance.ASI_CRM_CN_TP_Retail_Price__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('RetailPrice'))));
            pLItemInstance.ASI_CRM_CN_TP_Promotion_Unit_Price__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('PromotionUnitPrice'))));
            pLItemInstance.ASI_CRM_CN_TP_Normal_Purchase_Price__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('NormalPurchasePrice'))));
            pLItemInstance.ASI_CRM_CN_TP_Promotion_Purchase_Price__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('PromotionPurchasePrice'))));
            pLItemInstance.ASI_CRM_CN_TP_Estimated_Qty__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('EstimatedQty'))));
            pLItemInstance.ASI_CRM_CN_TP_Posters_Fee__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('PostersFee'))));
            pLItemInstance.ASI_CRM_CN_TP_Display_Fee__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('DisplayFee'))));
            pLItemInstance.ASI_CRM_CN_TP_Actual_Qty__c = nv(Decimal.valueof(String.valueof(pLItemMap.get('ActualQty'))));
            pLItemInstance.ASI_CRM_CN_TP_Last_Promotion_Fee__c = 0;

            // Added by Jack Yuan start
            // if (planItemIdPmtItemMap.containsKey(pLItemInstance.Id)) {
            //     System.debug(LoggingLevel.INFO, '*** JSON.serialize(planItemIdPmtItemMap): ' + JSON.serialize(planItemIdPmtItemMap));
            //     System.debug(LoggingLevel.INFO, '*** 1: ' + planItemIdPmtItemMap.get(pLItemInstance.Id).ASI_CRM_CN_TP_Promotion_Fee__c);
            //     System.debug(LoggingLevel.INFO, '*** 2: ' + pLItemInstance.ASI_CRM_CN_TP_Promotion_Payment_Amount__c);
            //     pLItemInstance.ASI_CRM_CN_TP_FixedCost_Payment_Amount__c -= planItemIdPmtItemMap.get(pLItemInstance.Id).ASI_CRM_CN_TP_Fixed_Cost__c;
            //     pLItemInstance.ASI_CRM_CN_TP_Total_Actual_Vol__c -= planItemIdPmtItemMap.get(pLItemInstance.Id).ASI_CRM_CN_Actual_Vol__c;
            //     pLItemInstance.ASI_CRM_CN_TP_Promotion_Payment_Amount__c -=  planItemIdPmtItemMap.get(pLItemInstance.Id).ASI_CRM_CN_TP_Promotion_Fee__c;
            //     pLItemInstance.ASI_CRM_CN_TP_Payment_Amount__c = (planItemIdPmtItemMap.get(pLItemInstance.Id).ASI_CRM_CN_TP_Fixed_Cost__c + planItemIdPmtItemMap.get(pLItemInstance.Id).ASI_CRM_CN_TP_Promotion_Fee__c);
            //     System.debug(LoggingLevel.INFO, '*** amount1: ' + promotionOPmtAmount);
            // }
            // Added by Jack Yuan end

            System.debug(LoggingLevel.INFO, '*** amount2: ' + pLItemInstance.ASI_CRM_CN_TP_Promotion_Payment_Amount__c);
            poFixedcost += pLItemInstance.ASI_CRM_CN_TP_FixedCost_Payment_Amount__c;
            poPromotionFee += pLItemInstance.ASI_CRM_CN_TP_Promotion_Payment_Amount__c;
            
            pRLItemList.add(paymentItem);
            updatePLItemList.add(pLItemInstance);
        }
        List<ASI_CRM_Contract_Cost__c> costList = [SELECT ASI_CRM_CN_Estimate_Amount__c,
                                                       ASI_CRM_CNY_Est__c,
                                                       ASI_CRM_Other_Est__c,
                                                       ASI_CRM_CN_Contract__c,
                                                       ASI_CRM_CN_Contract_Amount__c,
                                                       ASI_CRM_CN_Contract__r.ASI_CRM_CN_Description__c,
                                                       Name
                                                       FROM ASI_CRM_Contract_Cost__c
                                                       WHERE ASI_CRM_CN_Contract__c = :payment.ASI_TH_CRM_Contract__c
                                                         AND RecordType.developerName = :CN_Contract_Cost
                                                         AND (Name = :Label.ASI_CRM_CN_TP_PRC
                                                               OR Name = :SCANDATA_COST
                                                               OR Name = :Label.ASI_CRM_CN_TP_Total_fixedCost)
                                                                  ];
        Decimal poTotalEstAmount = 0;
        String msg = '';
        for (ASI_CRM_Contract_Cost__c cost : costList) {
            if (cost.Name == Label.ASI_CRM_CN_TP_Total_fixedCost && cost.ASI_CRM_CN_Contract_Amount__c != null
                    && cost.ASI_CRM_CN_Contract_Amount__c < poFixedcost) {
                msg += Label.ASI_CRM_CN_TP_Total_Fix_cost_Payment_Validation + ', 合同海报陈列总金额为: ' + cost.ASI_CRM_CN_Contract_Amount__c + ', 申请付款海报陈列金额为: ' + poFixedcost;
                msgMap.put('ERROR', msg);
                return msgMap;
            }
            if ((cost.Name == Label.ASI_CRM_CN_TP_PRC || cost.Name == SCANDATA_COST) && cost.ASI_CRM_CN_Contract_Amount__c != null) {
                poTotalEstAmount += cost.ASI_CRM_CN_Contract_Amount__c;
            }
        }
        if (poTotalEstAmount < poPromotionFee) {
            msg += Label.ASI_CRM_CN_TP_Total_Promotion_Payment_Validation  + ', 合同促销总金额为: ' + poTotalEstAmount + ', 申请付款促销金额为: ' + poPromotionFee;
            msgMap.put('ERROR', msg);
            return msgMap;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            String oldPaymentName;
            if (!draftPayment.isEmpty()) {
                oldPaymentName = draftPayment[0].Name;
                delete draftPayment;
            }
            if (String.isNotBlank(oldPaymentName)) {payment.Name = oldPaymentName;}
            insert payment;
            if (pRLItemList.size() > 0) {
                for (ASI_TH_CRM_PaymentRequestLineItem__c paymentItemVar : pRLItemList) {
                    paymentItemVar.ASI_TH_CRM_Payment_Request__c = payment.Id;
                }
                insert pRLItemList;
            }
            List<ASI_TH_CRM_PaymentRequestLineItem__c> payItemSummaryList = [SELECT ASI_CRM_CN_Total_Payable__c,
                                                       ASI_TH_CRM_Payment_Request__c,
                                                       ASI_CRM_CN_Expense_Type__c,
                                                       ASI_CRM_CN_TP_Amount__c,
                                                       ASI_TH_CRM_Amount__c,
                                                       ASI_CRM_Other_Est__c
                                                       FROM ASI_TH_CRM_PaymentRequestLineItem__c
                                                       WHERE ASI_TH_CRM_Payment_Request__c = :payment.Id
                                                               AND RecordType.DeveloperName = :PAYMENT_DETAIL_OTHER_RTNAME
                                                                       AND (ASI_CRM_CN_Expense_Type__c = :PRICE_PROMOTION
                                                                               OR ASI_CRM_CN_Expense_Type__c = :PRICE_PROMOTION_CONSUMER
                                                                               OR ASI_CRM_CN_Expense_Type__c = :DM_SECONDARY_DISPLAY_FEE
                                                                           )
                                                                            ];
            for (ASI_TH_CRM_PaymentRequestLineItem__c paymentItemSum : payItemSummaryList) {
                if (paymentItemSum.ASI_CRM_CN_Expense_Type__c == PRICE_PROMOTION && totalPromotionCost > 0) {
                    paymentItemSum.ASI_CRM_CN_Total_Payable__c = totalPromotionCost;
                    paymentItemSum.ASI_CRM_CN_TP_Amount__c = totalPromotionCost;
                    paymentItemSum.ASI_TH_CRM_Amount__c = totalPromotionCost;
                    paymentItemSum.ASI_CRM_Other_Est__c = totalPromotionCost;
                }
                if (paymentItemSum.ASI_CRM_CN_Expense_Type__c == PRICE_PROMOTION_CONSUMER && totalPromotionCostScandata > 0) {
                    paymentItemSum.ASI_CRM_CN_Total_Payable__c = totalPromotionCostScandata;
                    paymentItemSum.ASI_CRM_CN_TP_Amount__c = totalPromotionCostScandata;
                    paymentItemSum.ASI_TH_CRM_Amount__c = totalPromotionCostScandata;
                    paymentItemSum.ASI_CRM_Other_Est__c = totalPromotionCostScandata;
                }
                if (paymentItemSum.ASI_CRM_CN_Expense_Type__c == DM_SECONDARY_DISPLAY_FEE && totalFixedCost > 0) {
                    paymentItemSum.ASI_CRM_CN_Total_Payable__c = totalFixedCost;
                    paymentItemSum.ASI_CRM_CN_TP_Amount__c = totalFixedCost;
                    paymentItemSum.ASI_TH_CRM_Amount__c = totalFixedCost;
                    paymentItemSum.ASI_CRM_Other_Est__c = totalFixedCost;
                }
            }
            if (payItemSummaryList.size() > 0) {
                update payItemSummaryList;
            }
            if (updatePLItemList.size() > 0) {
                update updatePLItemList;
            }
            paymentGenerateBRSF(po, payment.Id);
            msgMap.put('SUCCESS', payment.Id);
            return msgMap;
        } catch (Exception e) {
            Database.rollback(sp);
            msgMap.put('ERROR', e.getLineNumber() + 'Row ' + e.getMessage());
            return msgMap;
        }
    }

    //sharing budget plan for sales
    // public static void processBudgetPlanShare(Map<Id, Id> insertShareMap, Map<Id, Id> deleteShareMap) {
    //     if (deleteShareMap.size() > 0) {
    //         List<ASI_MFM_Plan__Share> deleteShares = new List<ASI_MFM_Plan__Share>();
    //         List<ASI_MFM_Plan__Share> planShares = [select id, ParentId, UserOrGroupId from ASI_MFM_Plan__Share where ParentId IN :deleteShareMap.keySet() and UserOrGroupId IN:deleteShareMap.values()];
    //         for (ASI_MFM_Plan__Share planShare : planShares) {
    //             if (planShare.UserOrGroupId == deleteShareMap.get(planShare.ParentId)) {
    //                 deleteShares.add(planShare);
    //             }
    //         }
    //         if (deleteShares.size() > 0) {
    //             delete deleteShares;
    //         }
    //     }

    //     if (insertShareMap.size() > 0) {
    //         List<ASI_MFM_Plan__Share> insertShares = new List<ASI_MFM_Plan__Share>();
    //         for (String planId : insertShareMap.keySet()) {
    //             ASI_MFM_Plan__Share insertShare = new ASI_MFM_Plan__Share();
    //             insertShare.ParentId = planId;
    //             insertShare.UserOrGroupId = insertShareMap.get(planId);
    //             insertShare.AccessLevel = 'Read';
    //             insertShares.add(insertShare);
    //         }
    //         insert insertShares;
    //     }
    // }

    //payment generate BRSF
    public static void paymentGenerateBRSF(String poId, String paymentId) {
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> POBRSFList = [SELECT ASI_CRM_CN_Sub_Brand__c
                                                                    FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                                                    WHERE ASI_CRM_CN_Contract__c = :poId
                                                                     AND RecordType.DeveloperName = :PO_BRSF_RTNAME
                                                                 ];
        Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> POBRSFMap = new Map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf : POBRSFList) {
            POBRSFMap.put(brsf.ASI_CRM_CN_Sub_Brand__c, brsf);
        }

        List<ASI_TH_CRM_PaymentRequestLineItem__c> brsfList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        List<AggregateResult> subbrandResults = [SELECT ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c poId,
                              ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c sudBrandId,
                              SUM(ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_CRM_CN_TP_ActualVolumesIn9L__c) qty,
                              SUM(ASI_CRM_CN_TP_Promotion_Fee__c) promotionCost,
                              SUM(ASI_CRM_CN_TP_Fixed_Cost__c) fixedCost,
                              ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c regionId
                              FROM ASI_TH_CRM_PaymentRequestLineItem__c
                              WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :poId
                                AND ASI_TH_CRM_Payment_Request__c = :paymentId
                                AND RecordType.DeveloperName = :PAYMENT_DETAIL_TP_RTNAME
                                GROUP BY ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_CRM_CN_TP_Region__c,
                                         ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,
                                         ASI_CRM_CN_TP_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c
                                                ];
        Set<String> sudbrandIdSet = new Set<String>();
        for (AggregateResult agg : subbrandResults) {
            sudbrandIdSet.add(String.valueOf(agg.get('sudBrandId')));
        }

        List<ASI_CRM_CM_GS__c> cmgsList = [SELECT ASI_CRM_CM_GS_per_9L__c,
                                           ASI_CRM_PRODUCTCODE__c,
                                           ASI_CRM_Region__c,
                                           ASI_CRM_YEAR__c,
                                           ASI_CRM_CN_Month__c,
                                           ASI_CRM_TYPE__c,
                                           ASI_CRM_VERSION__c
                                           FROM ASI_CRM_CM_GS__c
                                           WHERE ASI_CRM_PRODUCTCODE__c IN :sudbrandIdSet
                                            AND (ASI_CRM_YEAR__c = :String.valueOf(Date.today().year()) 
                                                 OR ASI_CRM_YEAR__c = :String.valueOf(Date.today().addYears(1).year()))
                                             AND ASI_CRM_CN_Month__c = 6
                                             AND RecordType.DeveloperName = :CM_GS_RTNAME
                                             AND (ASI_CRM_TYPE__c = :BUDGET_CM
                                                  OR ASI_CRM_TYPE__c = :BUDGET_GS)
                                           ORDER BY ASI_CRM_VERSION__c desc];
        Map<String, List<ASI_CRM_CM_GS__c>> cmgsMap = new Map<String, List<ASI_CRM_CM_GS__c>>();
        for (ASI_CRM_CM_GS__c cmgs : cmgsList) {
            if ((Date.today().month() > 6 && cmgs.ASI_CRM_YEAR__c == String.valueOf(Date.today().year())) || (Date.today().month() <= 6 && cmgs.ASI_CRM_YEAR__c == String.valueOf(Date.today().addYears(1).year()))){
                continue;
            }
            String mappingKey = cmgs.ASI_CRM_PRODUCTCODE__c + '-' + cmgs.ASI_CRM_Region__c + '-' + cmgs.ASI_CRM_TYPE__c;
            List<ASI_CRM_CM_GS__c> tempList = cmgsMap.get(mappingKey);
            if (tempList != null) {
                tempList.add(cmgs);
            } else {
                tempList = new List<ASI_CRM_CM_GS__c> {cmgs};
            }
            cmgsMap.put(mappingKey, tempList);
        }

        Map<String, ASI_TH_CRM_PaymentRequestLineItem__c> subPmtBRSFMap = new Map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        for (AggregateResult agg : subbrandResults) {
            ASI_TH_CRM_PaymentRequestLineItem__c item_brsf = new ASI_TH_CRM_PaymentRequestLineItem__c();
            item_brsf.RecordTypeId = Schema.getGlobalDescribe().get('ASI_TH_CRM_PaymentRequestLineItem__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_Payment_Request_Detail_BRSF').getRecordTypeId();
            item_brsf.ASI_TH_CRM_Payment_Request__c = paymentId;
            item_brsf.ASI_CRM_CN_Sub_Brand__c = String.valueOf(agg.get('sudBrandId'));
            if (POBRSFMap.containskey(String.valueOf(agg.get('sudBrandId')))) {
                item_brsf.ASI_CRM_CN_Contract_BRSF_Line_Item__c = POBRSFMap.get(String.valueOf(agg.get('sudBrandId'))).Id;
            }
            item_brsf.ASI_CRM_Volume_9L__c = agg.get('qty') != null ? Decimal.valueOf(String.valueOf(agg.get('qty'))) : 0;
            item_brsf.ASI_CRM_CN_TP_Amount__c = agg.get('promotionCost') != null ? Decimal.valueOf(String.valueOf(agg.get('promotionCost'))) : 0;
            item_brsf.ASI_TH_CRM_Amount__c = agg.get('promotionCost') != null ? Decimal.valueOf(String.valueOf(agg.get('promotionCost'))) : 0;
            item_brsf.ASI_CRM_Other_Est__c = agg.get('promotionCost') != null ? Decimal.valueOf(String.valueOf(agg.get('promotionCost'))) : 0;
            item_brsf.ASI_CRM_CN_TP_Fixed_Cost__c = agg.get('fixedCost') != null ? Decimal.valueOf(String.valueOf(agg.get('fixedCost'))) : 0;
            String mappingKeyPrefix = agg.get('sudBrandId') + '-' + agg.get('regionId') + '-';
            item_brsf.ASI_CRM_CN_TP_CM_Per_9L__c = cmgsMap.get(mappingKeyPrefix + BUDGET_CM) != null && cmgsMap.get(mappingKeyPrefix + BUDGET_CM).size() > 0 ? cmgsMap.get(mappingKeyPrefix + BUDGET_CM)[0].ASI_CRM_CM_GS_per_9L__c : 0;
            item_brsf.ASI_CRM_CN_GS_Per_9L__c = cmgsMap.get(mappingKeyPrefix + BUDGET_GS) != null && cmgsMap.get(mappingKeyPrefix + BUDGET_GS).size() > 0 ? cmgsMap.get(mappingKeyPrefix + BUDGET_GS)[0].ASI_CRM_CM_GS_per_9L__c : 0;
            String contractId = String.valueOf(agg.get('poId'));
            String brsfKey = contractId + '-' + item_brsf.ASI_CRM_CN_Sub_Brand__c;
            if (subPmtBRSFMap.containsKey(brsfKey)) {
                ASI_TH_CRM_PaymentRequestLineItem__c exsitBRSF = subPmtBRSFMap.get(brsfKey);
                exsitBRSF.ASI_CRM_Volume_9L__c += item_brsf.ASI_CRM_Volume_9L__c;
                exsitBRSF.ASI_CRM_CN_TP_Amount__c += item_brsf.ASI_CRM_CN_TP_Amount__c;
                exsitBRSF.ASI_CRM_CN_TP_Fixed_Cost__c += item_brsf.ASI_CRM_CN_TP_Fixed_Cost__c;
                exsitBRSF.ASI_TH_CRM_Amount__c += item_brsf.ASI_TH_CRM_Amount__c;
                exsitBRSF.ASI_CRM_Other_Est__c += item_brsf.ASI_CRM_Other_Est__c;
            } else {
                subPmtBRSFMap.put(brsfKey, item_brsf);
            }
            // brsfList.add(item_brsf);
        }
        if (subPmtBRSFMap.size() > 0) {
            insert subPmtBRSFMap.values();
        }
    }
    public static String getPaymentName(String poId) {
        string tempPHName_seq = '';
        Integer tmpPHSeq = 0;
        Integer countPH = 0;
        List<ASI_TH_CRM_PaymentRequest__c> listOtherPH = [SELECT id, Name
                                                            FROM ASI_TH_CRM_PaymentRequest__c
                                                            WHERE ASI_TH_CRM_Contract__c = :poId
                                                              AND RecordType.developerName = :PAYMENT_RTNAME
                                                            ORDER BY Name Desc
                                                         ];

        if (listOtherPH != null && listOtherPH.size() > 0) {
            for (ASI_TH_CRM_PaymentRequest__c tmpPH : listOtherPH) {
                string[] strName = tmpPH.Name.split('-');
                if (strName.size() > 1) {
                    if (strName[1].isNumeric()) {
                        if (Integer.valueOf(strName[1]) > tmpPHSeq)
                            tmpPHSeq = Integer.valueOf(strName[1]);
                    }
                }

                countPH += 1;
            }
        }

        if (tmpPHSeq == 0 && countPH == 0) {
            tempPHName_seq = '001';
        } else {
            if (tmpPHSeq > countPH) {
                tempPHName_seq = digit_formatting(3, tmpPHSeq + 1);
            } else {
                tempPHName_seq = digit_formatting(3, countPH + 1);
            }
        }
        return tempPHName_seq;
    }

    public static String digit_formatting(Integer digit, Decimal numbers) {
        Decimal base = Math.pow(10, (digit - 1));
        String formate = '';
        Decimal counter = numbers / base;
        if (counter > 1)formate = String.valueOf(numbers);
        else {
            counter = 0;
            for (Integer dec = Integer.valueOf(numbers); dec > 0; dec = dec / 10) {
                counter++;
            }
            for (Integer a = 0; a < digit - counter; a++) {
                formate += '0';
            }

            formate += numbers;
        }
        return formate;
    }
    public static Set<String> getFYContainsPreNextCurrent() {
        Date fYEndDate = Date.newInstance(Date.today().year(), 7, 1);
        Set<String> fYSet = new Set<String>();
        String currentFy = '', preFy = '', nextFy = '';
        if (Date.today() < fYEndDate) {
            currentFy = 'FY' + String.valueOf(Date.today().year() - 1).substring(2, String.valueOf(Date.today().year()).length()) + String.valueOf(Date.today().year()).substring(2, String.valueOf(Date.today().year()).length());
            preFy = 'FY' + String.valueOf(Date.today().year() - 2).substring(2, String.valueOf(Date.today().year()).length()) + String.valueOf(Date.today().year() - 1).substring(2, String.valueOf(Date.today().year()).length());
            nextFy = 'FY' + String.valueOf(Date.today().year()).substring(2, String.valueOf(Date.today().year()).length()) + String.valueOf(Date.today().year() + 1).substring(2, String.valueOf(Date.today().year()).length());
        } else {
            currentFy = 'FY' + String.valueOf(Date.today().year()).substring(2, String.valueOf(Date.today().year()).length()) + String.valueOf(Date.today().year() + 1).substring(2, String.valueOf(Date.today().year()).length());
            preFy = 'FY' + String.valueOf(Date.today().year() - 1).substring(2, String.valueOf(Date.today().year()).length()) + String.valueOf(Date.today().year()).substring(2, String.valueOf(Date.today().year()).length());
            nextFy = 'FY' + String.valueOf(Date.today().year() + 1).substring(2, String.valueOf(Date.today().year()).length()) + String.valueOf(Date.today().year() + 2).substring(2, String.valueOf(Date.today().year()).length());
        }
        fYSet.add(currentFy);
        fYSet.add(preFy);
        fYSet.add(nextFy);
        return fYSet;
    }
    public static Decimal nv(Object obj) {
        return obj == null ? 0 : (Decimal)obj;
    }
    public class POBRSFInfo {
        public String subBrandName {Get; Set;}
        public Double actualVolumeIn9L {Get; Set;}
        public Decimal actualAmount {Get; Set;}
        public Decimal cmAmount {Get; Set;}
        public Decimal gsAmount {Get; Set;}
        public Decimal fixedCost {Get; Set;}
    }
}