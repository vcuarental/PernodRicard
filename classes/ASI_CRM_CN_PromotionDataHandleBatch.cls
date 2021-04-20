/*******************************************************************************
 *  Summary         : 促销付款申请对于大数据量,批量处理并生成付款申请行明细数据
 *  Refer Object    : 
 *  Author          : Zhonghui Li
 *  CreatedDate     : 2020-09-22
 *  Change Log      : 
 ******************************************************************************/
global without sharing class ASI_CRM_CN_PromotionDataHandleBatch implements Database.batchable<ASI_CRM_CN_PromotionPaymentCtrl.interimData> {
    public List<ASI_CRM_CN_PromotionPaymentCtrl.interimData> irerabelListData;
    public ASI_TH_CRM_PaymentRequest__c PH;
    public ASI_TH_CRM_Contract__c ContractSelected;
    public Date endDate;
    public ASI_CRM_CN_PromotionDataHandleBatch(List<ASI_CRM_CN_PromotionPaymentCtrl.interimData> irerabelListData,
                                                ASI_TH_CRM_PaymentRequest__c PH,
                                                ASI_TH_CRM_Contract__c ContractSelected,
                                                Date endDate){
        this.irerabelListData = irerabelListData;
        this.PH = PH;
        this.ContractSelected = ContractSelected;
        this.endDate = endDate;
    }

    global Iterable<ASI_CRM_CN_PromotionPaymentCtrl.interimData> start(Database.BatchableContext bc) {
        return new ASI_CRM_CN_PromotionPaymentCtrl(irerabelListData);
    }
    // 分批处理逻辑
    global void execute(Database.BatchableContext BC, List<object> scope)
    {
        List<ASI_CRM_CN_PromotionPaymentCtrl.interimData> lstWrap = (List<ASI_CRM_CN_PromotionPaymentCtrl.interimData>)scope;
        ASI_CRM_CN_PromotionPaymentCtrl paymentCtrl = new ASI_CRM_CN_PromotionPaymentCtrl();
        paymentCtrl.PH = PH;
        system.debug('======exetcute method-scope--'+ lstWrap);
        System.debug(LoggingLevel.INFO, '*** PH: ' + PH);
        System.debug(LoggingLevel.INFO, '*** ContractSelected: ' + ContractSelected);
        //Get Historical Module and Amount
        Set<Id> parentModuleIdSet = new Set<Id>();
        for(ASI_CRM_Module__c module :[ SELECT Id
                                        FROM ASI_CRM_Module__c
                                        WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                                        AND ASI_CRM_Line_Type__c = :ASI_CRM_CN_PromotionPaymentCtrl.PRICE_PROMOTION_MODULE_TYPE
                                        AND ASI_CRM_Parent_Module__c = null]){
            parentModuleIdSet.add(module.Id);
        }
        Map<String, Decimal> HistoricalAmountMap = new Map<String, Decimal>();
        if(parentModuleIdSet.size()>0){
            List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();
            moduleList = ASI_CRM_CN_PromotionPaymentUtilClass.HistoricalModuleQuerying(parentModuleIdSet, PH.Id);
            HistoricalAmountMap = ASI_CRM_CN_PromotionPaymentUtilClass.GetHistoricalAmountMap(moduleList);
        }
        List<ASI_CRM_Module__c> contractModules = [
                SELECT Id, ASI_CRM_Methodology__c, ASI_CRM_Methodology__r.Name, ASI_CRM_Volume_Base__c, ASI_CRM_Line_Type__c, ASI_CRM_CN_Only_for_Strategy_WS__c,(
                        SELECT
                                ASI_CRM_CN_Activity_Code__c,
                                ASI_CRM_CN_Contract__c,
                                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
                                ASI_CRM_CN_Contract_Monthly_Qty__c,
                                ASI_CRM_CN_Date__c,
                                ASI_CRM_CN_Max_Purchase_Target__c,
                                ASI_CRM_CN_Min_Purchase_Target__c,
                                ASI_CRM_CN_Rebate_Percent__c,
                                ASI_CRM_CN_Sub_Brand__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_Sub_Brand_Grade_Sequence__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,
                                ASI_CRM_CN_Sub_Brand__r.Name,
                                ASI_CRM_CN_Volume_Value_Base__c,
                                ASI_CRM_Line_Long_Name__c,
                                ASI_CRM_Module__r.ASI_CRM_Created_PO_Version__c,
                                Id
                        FROM Contract_BRSF_Line_Item__r
                )
                FROM ASI_CRM_Module__c
                WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c 
                AND ASI_CRM_Line_Type__c = :ASI_CRM_CN_PromotionPaymentCtrl.PRICE_PROMOTION_MODULE_TYPE 
                AND ASI_CRM_Payment_Request__c = NULL
        ];

        List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletList = [select Id, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.RecordType.DeveloperName, ASI_CRM_CN_Strategy_WS__c FROM ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c =:PH.ASI_TH_CRM_Contract__c];
        // Set wholesalerIds and outletIds
        Set<Id> onlyForStrategyIdSet = new Set<Id>();
        for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutletList) {
            // if (coveredOutlet.ASI_CRM_CN_Outlet__r.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN') {
            //     outletIds.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
            // }
            if (coveredOutlet.ASI_CRM_CN_Outlet__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS') {
                // wholesalerIds.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
                if(coveredOutlet.ASI_CRM_CN_Strategy_WS__c){
                    onlyForStrategyIdSet.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
                }
            }
        }
        String dataSource = ContractSelected.ASI_CRM_CN_Data_Source__c;
        List<ASI_CRM_Module__c> contractPromotionList = [
                    SELECT
                            ASI_CRM_CN_Total_Markup__c,
                            Id
                    FROM ASI_CRM_Module__c
                    WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                    AND ASI_CRM_Line_Type__c = :ASI_CRM_CN_PromotionPaymentCtrl.PROMOTION_TARGET_MODULE_TYPE
                    LIMIT 1
            ];
        paymentCtrl.markupPercent = contractPromotionList.isEmpty()? 1 : (contractPromotionList[0].ASI_CRM_CN_Total_Markup__c / 100 + 1);
        List<ASI_CRM_Module__c> modules = new List<ASI_CRM_Module__c>();
        Set<ASI_TH_CRM_PaymentRequestLineItem__c> lineItems = new Set<ASI_TH_CRM_PaymentRequestLineItem__c>();

        for (ASI_CRM_CN_PromotionPaymentCtrl.interimData interimData : lstWrap) {
            // interimData interimData = interimDataMapAll.get(key);
            // subBrandVolumes = subBrandVolumesByCustomers.get(key);
            interimData.paymentRequestLineOutletWS = ASI_CRM_CN_PromotionPaymentCtrl.calculateDataSource(interimData.paymentRequestLineOutletWS, dataSource);

            for (ASI_CRM_Module__c module : contractModules) {
                // Skip this module if it has no BRSF line
                if (module.Contract_BRSF_Line_Item__r.isEmpty()) {
                    continue;
                }

                ASI_CRM_CN_PromotionPaymentCtrl.interimData moduleWrapper = new ASI_CRM_CN_PromotionPaymentCtrl.interimData();
                moduleWrapper.module = new ASI_CRM_Module__c(
                                                ASI_CRM_Volume_Base__c = module.ASI_CRM_Volume_Base__c,
                                                ASI_CRM_Created_PO_Version__c = ContractSelected.ASI_CRM_CN_PO_Version__c,
                                                ASI_CRM_Line_Type__c = module.ASI_CRM_Line_Type__c,
                                                ASI_CRM_Methodology__c = module.ASI_CRM_Methodology__c,
                                                ASI_CRM_Payment_Request__c = PH.Id
                                        );

                moduleWrapper.paymentRequestLines = paymentCtrl.createPaymentRequestLineFromContractLines(module.Contract_BRSF_Line_Item__r);
                // Set Wholesaler/Outlet
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : moduleWrapper.paymentRequestLines) {
                    lineItem.ASI_CRM_CN_Wholesaler__c = interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c;
                    lineItem.ASI_CRM_Customer__c = interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c;
                }

                if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && ContractSelected.ASI_CRM_CN_Region__c == 'South Region'){
                    moduleWrapper.paymentRequestLines = paymentCtrl.calculateSubBrandVolumesByBreakdowns(
                                                            interimData.subBrandVolumeBreakdowns,
                                                             moduleWrapper.paymentRequestLines, 
                                                             PH.ASI_CRM_CN_Promotion_Type__c, 
                                                             dataSource, 
                                                             module.ASI_CRM_Volume_Base__c, 
                                                             module.ASI_CRM_Methodology__r.Name, 
                                                             true);
                } else {
                    moduleWrapper.paymentRequestLines = paymentCtrl.calculateSubBrandVolumes(interimData.subBrandVolumes, moduleWrapper.paymentRequestLines, PH.ASI_CRM_CN_Promotion_Type__c, dataSource, module.ASI_CRM_Volume_Base__c, module.ASI_CRM_Methodology__r.Name);
                }
                moduleWrapper.paymentRequestLines = ASI_CRM_CN_PromotionPaymentCtrl.calculateDataSource(moduleWrapper.paymentRequestLines, dataSource);
                switch on module.ASI_CRM_Methodology__r.Name {
                    when 'Per Incentive Btl' {
                        moduleWrapper.paymentRequestLines = ASI_CRM_CN_PromotionPaymentCtrl.calculatePerIncentiveBottle(moduleWrapper.paymentRequestLines);
                    }
                    when 'Rebate%(By Package)' {
                        moduleWrapper.paymentRequestLines = ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercentByPackage(moduleWrapper.paymentRequestLines, module.ASI_CRM_Volume_Base__c);
                    }
                    when 'Rebate%(By Ladder)' {
                        moduleWrapper.paymentRequestLines = ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercentByLadder(moduleWrapper.paymentRequestLines);
                    }
                    when else {
                        moduleWrapper.paymentRequestLines = ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercent(moduleWrapper.paymentRequestLines);
                    }
                }

                Decimal totalPaymentAmount = 0;
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : moduleWrapper.paymentRequestLines) {
                    if(module.ASI_CRM_CN_Only_for_Strategy_WS__c && !onlyForStrategyIdSet.contains(lineItem.ASI_CRM_CN_Wholesaler__c)){
                        lineItem.ASI_CRM_CN_Total_Payable__c = 0;
                    }
                    totalPaymentAmount += lineItem.ASI_CRM_CN_Total_Payable__c;
                }
                moduleWrapper.module.ASI_CRM_CN_Customer__c = interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c != null? interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c : interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c;
                moduleWrapper.module.ASI_CRM_Application_Payment_Amount__c = totalPaymentAmount;
                moduleWrapper.module.ASI_CRM_Historical_Paid_Amount__c = 0;
                moduleWrapper.module.ASI_CRM_Actual_Payment__c = totalPaymentAmount;
                moduleWrapper.module.ASI_CRM_Parent_Module__c = module.Id;

                if(HistoricalAmountMap.size()>0){
                    String WholesalerId = interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c != null ? String.valueOf(interimData.paymentRequestLineOutletWS.ASI_CRM_CN_Wholesaler__c) : '';
                    String OutletId = interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c != null ? String.valueOf(interimData.paymentRequestLineOutletWS.ASI_CRM_Customer__c) : '';
                    String TemKey =  String.valueOf(moduleWrapper.module.ASI_CRM_Parent_Module__c)+';'+WholesalerId+';'+OutletId;
                    if(HistoricalAmountMap.containsKey(TemKey)){
                        moduleWrapper.module.ASI_CRM_Historical_Paid_Amount__c = HistoricalAmountMap.get(TemKey);
                        moduleWrapper.module.ASI_CRM_Actual_Payment__c = totalPaymentAmount - moduleWrapper.module.ASI_CRM_Historical_Paid_Amount__c;
                    }
                }
                moduleWrapper.module.ASI_CRM_End_Date__c = endDate;
                modules.add(moduleWrapper.module);
                interimData.moduleWrappers.add(moduleWrapper);
            }

            interimData.module.ASI_CRM_End_Date__c = endDate;
            if (interimData.paymentRequestLineOutletWS != null) {
                lineItems.add(interimData.paymentRequestLineOutletWS);
            }
        }

        upsert modules;
        // Put module Id to paymentRequestLines
        for (ASI_CRM_CN_PromotionPaymentCtrl.interimData interimData : lstWrap) {
            for (ASI_CRM_CN_PromotionPaymentCtrl.interimData moduleWrapper : interimData.moduleWrappers) {
                for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : moduleWrapper.paymentRequestLines) {
                    lineItem.ASI_CRM_Module__c = moduleWrapper.module.Id;
                }
                lineItems.addAll(moduleWrapper.paymentRequestLines);
            }
        }

        List<ASI_TH_CRM_PaymentRequestLineItem__c> newPaymentLineItem 
            = new List<ASI_TH_CRM_PaymentRequestLineItem__c>(lineItems);
        System.debug(LoggingLevel.INFO, '*** newPaymentLineItem.size(): ' + newPaymentLineItem.size());
        upsert newPaymentLineItem;
    }    
    global void finish(Database.BatchableContext BC) {

    }
}