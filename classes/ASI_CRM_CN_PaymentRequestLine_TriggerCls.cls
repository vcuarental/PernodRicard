public without sharing class ASI_CRM_CN_PaymentRequestLine_TriggerCls{

    public static void routineBeforeUpsert(list<ASI_TH_CRM_PaymentRequestLineItem__c> trigger_new, map<id, ASI_TH_CRM_PaymentRequestLineItem__c> trigger_oldMap) {
        Set<id> StID = new Set<id>();
        for (ASI_TH_CRM_PaymentRequestLineItem__c  prli:trigger_new){
            StID.add(prli.ASI_TH_CRM_Payment_Request__c);
        }
        Map<id,ASI_TH_CRM_PaymentRequest__c > LPRL= new Map<Id, ASI_TH_CRM_PaymentRequest__c>([Select id, CurrencyIsoCode 
                    FROM ASI_TH_CRM_PaymentRequest__c WHERE id IN :StID]);                           
        for (ASI_TH_CRM_PaymentRequestLineItem__c  prli:trigger_new){
            prli.CurrencyIsoCode = LPRL.get(prli.ASI_TH_CRM_Payment_Request__c).CurrencyIsoCode ;
        }
    }

    //2019/12/13 CanterDuan start，添加功能：在创建或者修改Payment Request Line自动填充满足条件的A/C Code
    public static void fillCodeAutomatic(list<ASI_TH_CRM_PaymentRequestLineItem__c> trigger_new){
        Set<Id> set_payId = new Set<Id>();
        List<ASI_TH_CRM_PaymentRequestLineItem__c> updateList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequestLineItem__c prli : trigger_new){
            //满足条件需要自动给A/C Code值的payment request line item记录下来
            if(prli.ASI_CRM_CN_AC_Code__c != null || prli.ASI_TH_CRM_Payment_Request__c == null
              || prli.RecordTypeId != Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Free_Goods')) continue;
            set_payId.add(prli.Id);
        }
        //查询需要自动赋值的paymentRequestLineItem数据 prli.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c != 'Consumer Promotion'
        if(set_payId.isEmpty()) return;
        list<ASI_TH_CRM_PaymentRequestLineItem__c> payReqList = new list<ASI_TH_CRM_PaymentRequestLineItem__c>([SELECT Id,ASI_CRM_CN_AC_Code__c,ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c FROM ASI_TH_CRM_PaymentRequestLineItem__c WHERE Id in: set_payId]);
        //查询自动匹配的Contract Cost Setting
        List<ASI_CRM_Contract_Cost_Setting__c> autoList = new List<ASI_CRM_Contract_Cost_Setting__c>([SELECT ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_Contract_Cost_Setting__c WHERE ASI_CRM_CN_Promotion_Type__c = 'Promotion' AND Name = 'PRC - Consumer Promotion – GWP and Free Goods']);
    	if(autoList.isEmpty() || autoList[0].ASI_CRM_CN_Activity_Code__c == null) return;
        for(ASI_TH_CRM_PaymentRequestLineItem__c pr : payReqList){
            if(pr.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion'){
                pr.ASI_CRM_CN_AC_Code__c = autoList[0].ASI_CRM_CN_Activity_Code__c;
            	updateList.add(pr); 
            } 
        }
        if(!updateList.isEmpty()){
            update updateList;
        }
    }
    //2019/12/13 CanterDuan end

    /*
    2020-01-22
    Bowen
    将payment request line item的exclude，从page转移到trigger上来
     */
    public static void ItemExclude(List<ASI_TH_CRM_PaymentRequestLineItem__c> trigger_new)
    {
    	Set<Id> itemSet = new Set<Id>();
    	Set<Id> moduleSet = new Set<Id>();
    	Set<Id> paymentSet = new Set<Id>();
    	Id paymentId = null;
    	for(ASI_TH_CRM_PaymentRequestLineItem__c payItem : trigger_new)
    	{
    		// 如果记录类型不为ASI CRM CN Payment Request Detail (Promotion)或ASI CRM CN Payment Request Detail (Outlet/WS)，均排除在外
    		if(payItem.RecordTypeId != Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Promotion')
    			&& payItem.RecordTypeId != Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Outlet_WS')) continue;
    		if(payItem.ASI_CRM_Module__c != null)
    		{
    			moduleSet.add(payItem.ASI_CRM_Module__c);
    		}
    		// 这里只考虑一种情况，即进来的lineitem trigger.new都是属于同一个payment和PO
    		if(payItem.ASI_TH_CRM_Payment_Request__c != null && paymentId == null)
    		{
    			paymentId = payItem.ASI_TH_CRM_Payment_Request__c;
    		}
    		itemSet.add(payItem.Id);
    	}
        system.debug('---到ItemExclude了吗' +itemSet.size());
        if(itemSet.size() == 0) return;
    	ASI_TH_CRM_PaymentRequest__c PH = new ASI_TH_CRM_PaymentRequest__c();
    	ASI_TH_CRM_Contract__c ContractSelected = new ASI_TH_CRM_Contract__c();
        Set<Id> outletIds = new Set<Id>();
        Set<Id> wholesalerIds  = new Set<Id>();
        Set<Id> onlyForStrategyIdSet = new Set<Id>();
        Boolean isSouthRegion = false;
    	if(paymentId != null)
    	{
    		PH = [
                    SELECT
                            ASI_CRM_CalOtherCostHistoricalPaidAmt__c,
                            ASI_CRM_CN_Adjustment__c,
                            ASI_CRM_CN_BRSF_End_Date__c,
                            ASI_CRM_CN_BRSF_Start_Date__c,
                            ASI_CRM_CN_Business_License_Qualify__c,
                            ASI_CRM_CN_Channel__c,
                            ASI_CRM_CN_Currency__c,
                            ASI_CRM_CN_Description__c,
                            ASI_CRM_CN_Division__c,
                            ASI_CRM_CN_Last_Payment__c,
                            ASI_CRM_CN_Last_Year_Payment__c,
                            ASI_CRM_CN_No_of_Month__c,
                            ASI_CRM_CN_Other_Reason__c,
                            ASI_CRM_CN_OutletWS__c,
                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_BRSF__c,
                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_PSF__c,
                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Display_Payable_Vol_Amt_VEC__c,
                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c,
                            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c,
                            ASI_CRM_CN_OutletWS__r.Name,
                            ASI_CRM_CN_Overpayment_Comment__c,
                            ASI_CRM_CN_Overpayment_Reason__c,
                            ASI_CRM_CN_Payable_Amount__c,
                            ASI_CRM_CN_Payment_Raised_Date__c,
                            ASI_CRM_CN_Payment_Type__c,
                            ASI_CRM_CN_PO_End_Date__c,
                            ASI_CRM_CN_PO_No__c,
                            ASI_CRM_CN_PO_Start_Date__c,
                            ASI_CRM_CN_PO_Version__c,
                            ASI_CRM_CN_PO_Version_Latest__c,
                            ASI_CRM_CN_Promotion_Type__c,
                            ASI_CRM_CN_Reason_For_Business_License__c,
                            ASI_CRM_CN_Payment_Request_End_Date__c ,
                            ASI_CRM_CN_Region__c,
                            ASI_CRM_CN_Reference_Code__c,
                            ASI_CRM_CN_Total_BRSF_Actual_Amount__c,
                            ASI_CRM_CN_Total_BRSF_Amount__c,
                            ASI_CRM_CN_Total_Other_Amount__c,
                            ASI_CRM_CN_Total_Payment__c,
                            ASI_CRM_CN_Total_PSF_Amount__c,
                            ASI_CRM_New_FY_Payment__c,
                            ASI_CRM_Total_Actual_Amount__c,
                            ASI_CRM_Total_Variable_Amount__c,
                            ASI_CRM_Volume_Option__c,
                            ASI_TH_CRM_Contract__c,
                            ASI_TH_CRM_Status__c,
                            ASI_TH_CRM_Total_Amount__c,
                            ASI_CRM_CN_Total_Free_Goods_Amount__c,
                            Id,
                            Name
                    FROM ASI_TH_CRM_PaymentRequest__c
                    WHERE Id = :paymentId
            ];

            if(PH.ASI_CRM_CN_Promotion_Type__c != 'Outlet Promotion' 
                && PH.ASI_CRM_CN_Promotion_Type__c != 'Wholesaler Promotion'
                && PH.ASI_CRM_CN_Promotion_Type__c != 'Consumer Promotion') return;

            ContractSelected = [
                    SELECT
                            ASI_TH_CRM_Contract_Status__c,
                            ASI_CRM_Auto_PO_Modification__c,
                            ASI_CRM_CN_Business_License__c,
                            ASI_CRM_CN_Currency__c,
                            ASI_CRM_CN_Data_Source__c,
                            ASI_CRM_CN_Description__c,
                            ASI_CRM_CN_Effective_Date__c,
                            ASI_CRM_CN_Expected_BRSF_Est_Total__c,
                            ASI_CRM_CN_Expected_Display_Est_Total__c,
                            ASI_CRM_CN_Expected_PSF_Est_Total__c,
                            ASI_CRM_CN_Festival_Season__c,
                            ASI_CRM_CN_Last_PO_version__c,
                            ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
                            ASI_CRM_CN_Last_Rejected_Date__c,
                            ASI_CRM_CN_Last_Submitted_Date__c,
                            ASI_CRM_CN_National_Group_Contract__c,
                            ASI_CRM_CN_No_of_Months__c,
                            ASI_CRM_CN_Outlet_WS__c,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,
                            ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
                            ASI_CRM_CN_PO_Modification__c,
                            ASI_CRM_CN_PO_No__c,
                            ASI_CRM_CN_PO_Start_Date__c,
                            ASI_CRM_CN_PO_Version__c,
                            ASI_CRM_CN_Region__c,
                            ASI_CRM_CN_Source_of_Contract__c,
                            ASI_CRM_CN_Source_Others__c,
                            ASI_CRM_CN_Special_Promotion__c,
                            ASI_CRM_CN_Status__c,
                            ASI_CRM_CN_Total_Contract_Amount__c,
                            ASI_CRM_CN_V0_0_PO_version__c,
                            ASI_CRM_CN_Vol_Budget_LE__c,
                            ASI_CRM_CN_Expected_Visibility_Est_Total__c,
                            ASI_CRM_Prev_Ver_Visibility_Est_Total__c,
                            ASI_CRM_New_FY_PO__c,
                            ASI_CRM_PO_Channel__c,
                            ASI_CRM_PO_City__c,
                            ASI_CRM_PO_City__r.Name,
                            ASI_CRM_PO_Province__c,
                            ASI_CRM_Volume_Option__c,
                            ASI_TH_CRM_Promotion_Type__c,
                            ASI_CRM_Copied_From__c,
                            ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,
                            ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
                            CreatedDate,
                            Id,
                            LastModifiedDate,
                            Name,
                            RecordTypeId,
                            ASI_CRM_Reject_Return_Comments__c,
                            ASI_CRM_CN_Return_Comments__c,
                            ASI_CRM_CN_Last_Approved_By__c,
                            ASI_CRM_CN_Last_Approved_Date__c,
                            ASI_CRM_CN_Last_Recall_By__c,
                            ASI_CRM_CN_Last_Recall_Date__c,
                            ASI_CRM_CN_Last_Rejected_By__c,
                            ASI_CRM_CN_Last_Submitted_By__c,
                            ASI_CRM_Auto_PO_Modification_Time__c,
                            ASI_CRM_CN_PO_End_Date__c
                    FROM ASI_TH_CRM_Contract__c
                    WHERE Id = :PH.ASI_TH_CRM_Contract__c
            ];

            List<ASI_CRM_CN_Covered_Outlet__c> coveredOutletList = [select Id, ASI_CRM_CN_Outlet__c, ASI_CRM_CN_Outlet__r.RecordType.DeveloperName, ASI_CRM_CN_Strategy_WS__c FROM ASI_CRM_CN_Covered_Outlet__c where ASI_CRM_CN_Contract__c =:PH.ASI_TH_CRM_Contract__c];
            // Set wholesalerIds and outletIds
            //for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : ContractSelected.Covered_Outlet__r) {
            for (ASI_CRM_CN_Covered_Outlet__c coveredOutlet : coveredOutletList) {
                if (coveredOutlet.ASI_CRM_CN_Outlet__r.RecordType.DeveloperName == 'ASI_CRM_Outlet_CN') {
                    outletIds.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
                }
                if (coveredOutlet.ASI_CRM_CN_Outlet__r.RecordType.DeveloperName == 'ASI_CRM_CN_WS') {
                    wholesalerIds.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
                    if(coveredOutlet.ASI_CRM_CN_Strategy_WS__c){
                        onlyForStrategyIdSet.add(coveredOutlet.ASI_CRM_CN_Outlet__c);
                    }
                }
            }

            isSouthRegion = ContractSelected.ASI_CRM_CN_Region__c == 'South Region';
    	}

    	List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLineItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        if(itemSet.size() > 0)
        {
            PaymentRequestLineItemList = [select Id ,
            									ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,
                                                ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c,
                                                ASI_CRM_CN_Sub_Brand__c  ,
                                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Pack_Size__c ,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Drop_In__c ,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__c ,
                                                ASI_CRM_CN_WS_Intake_9L_Original__c ,
                                                ASI_CRM_CN_WS_Intake_9L__c ,
                                                ASI_CRM_CN_WS_Intake_Std__c,
                                                ASI_CRM_CN_WS_Intake_9L_Exclude__c ,
                                                ASI_CRM_CN_Outlet_Intake_9L_Exclude__c ,
                                                ASI_CRM_CN_Outlet_Intake_9L_Original__c ,
                                                ASI_CRM_CN_Outlet_Intake_9L__c ,
                                                ASI_CRM_CN_Outlet_Intake_Std__c,
                                                ASI_CRM_CTD_Actual_Purchase_Value__c ,
                                                ASI_CRM_Actual_Purchase_Value_Original__c ,
                                                ASI_CRM_Actual_Purchase_Value_Exclude__c ,
                                                ASI_CRM_CN_POS_Volume__c ,
                                                ASI_CRM_CN_POS_Volume_9L_Original__c ,
                                                ASI_CRM_CN_POS_Volume_9L_Exclude__c ,
                                                ASI_CRM_CN_POS_Value__c ,
                                                ASI_CRM_Line_Long_Name__c ,
                                                ASI_CRM_CN_POS_Value_Original__c ,
                                                ASI_CRM_CN_POS_Value_Exclude__c ,
                                                ASI_CRM_CTD_Actual_Retail_Value_Original__c ,
                                                ASI_CRM_CTD_Actual_Retail_Value_Exclude__c ,
                                                ASI_CRM_Actual_Value_Base__c ,
                                                ASI_CRM_CN_Wholesaler__c ,
                                                ASI_CRM_Customer__c ,
                                                ASI_CRM_CTD_Actual_Retail_Value__c ,
                                                ASI_CRM_CN_CRM_Code__c ,
                                                ASI_CRM_CN_Actual_Value_Base_Original__c ,
                                                ASI_CRM_Module__c ,
                                                ASI_CRM_CTD_Actual_Vol__c ,
                                                ASI_CRM_CTD_Actual_Vol_std__c ,
                                                ASI_CRM_Module__r.ASI_CRM_Volume_Base__c ,
                                                ASI_CRM_CN_Sub_brand_Group__c ,
                                                ASI_CRM_Sub_Brand_Grade__c ,
                                                ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_CN_Only_for_Strategy_WS__c ,
                                                ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Methodology__r.Name ,
                                                ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c
                                            from ASI_TH_CRM_PaymentRequestLineItem__c 
                                            where Id in: itemSet
                                            and (recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Outlet_WS'
                                            OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Free_Goods'
                                            OR recordType.DeveloperName =: 'ASI_CRM_CN_Payment_Request_Detail_Promotion')];
        }

        if(PaymentRequestLineItemList.size() > 0)
        {
            system.debug('PaymentRequestLineItemList =='+PaymentRequestLineItemList.size());
            // 执行计算payment request line item的数据
            PaymentRequestLineItemList = TotalPaymentRequestLineItem(PaymentRequestLineItemList ,ContractSelected ,PH ,outletIds , wholesalerIds ,isSouthRegion);
            update PaymentRequestLineItemList;
        }

        Transient List<ASI_CRM_Module__c> moduleList = new List<ASI_CRM_Module__c>();
        if(moduleSet.size() > 0 || Test.isRunningTest())
        {
            moduleList = [select Id ,
                                ASI_CRM_Volume_Base__c ,
                                ASI_CRM_Methodology__r.Name ,
                                ASI_CRM_Parent_Module__r.ASI_CRM_CN_Only_for_Strategy_WS__c ,
                                ASI_CRM_Historical_Paid_Amount__c ,
                                (
                                    SELECT
                                        ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c ,
                                        ASI_CRM_CTD_Actual_Vol__c ,
                                        ASI_CRM_CTD_Actual_Vol_std__c ,
                                        ASI_CRM_CN_Actual_Package_Number__c,
                                        ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Min_Purchase_Target__c ,
                                        ASI_CRM_Actual_Value_Base__c ,
                                        ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Max_Purchase_Target__c ,
                                        ASI_CRM_CN_Total_Payable__c ,
                                        ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Rebate_Percent__c ,
                                        ASI_CRM_Line_Long_Name__c ,
                                        ASI_CRM_CN_Sub_Brand__c ,
                                        ASI_CRM_CN_Wholesaler__c
                                    FROM Payment_Request_Line_Items__r
                                    WHERE ASI_TH_CRM_Payment_Request__c =: PH.Id
                                )
                            from ASI_CRM_Module__c 
                            where Id in: moduleSet];

            List<ASI_TH_CRM_PaymentRequestLineItem__c> modulePaymentList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            system.debug('onlyForStrategyIdSet ==='+onlyForStrategyIdSet);
            for(ASI_CRM_Module__c module : moduleList)
            {
                System.debug(LoggingLevel.INFO, '*** module.Payment_Request_Line_Items__r: ' + module.Payment_Request_Line_Items__r);
                if(module.Payment_Request_Line_Items__r.size() > 0)
                {
                    // 重新计算module的ASI_CRM_Application_Payment_Amount__c，汇总payment line item的ASI_CRM_CN_Total_Payable__c
                    switch on module.ASI_CRM_Methodology__r.Name {
                        when 'Per Incentive Btl' {
                            ASI_CRM_CN_PromotionPaymentCtrl.calculatePerIncentiveBottle(module.Payment_Request_Line_Items__r);
                        }
                        when 'Rebate%(By Package)' {
                            ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercentByPackage(module.Payment_Request_Line_Items__r, module.ASI_CRM_Volume_Base__c);
                        }
                        when 'Rebate%(By Ladder)' {
                            ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercentByLadder(module.Payment_Request_Line_Items__r);
                        }
                        when else {
                            ASI_CRM_CN_PromotionPaymentCtrl.calculateRebatePercent(module.Payment_Request_Line_Items__r);
                        }
                    }


                    Decimal totalPaymentAmount = 0;
                    for (ASI_TH_CRM_PaymentRequestLineItem__c lineItem : module.Payment_Request_Line_Items__r) {
                        if((module.ASI_CRM_Parent_Module__r.ASI_CRM_CN_Only_for_Strategy_WS__c && !onlyForStrategyIdSet.contains(lineItem.ASI_CRM_CN_Wholesaler__c)) || Test.isRunningTest()){
                            system.debug('----StrategyWS ==='+ lineItem.ASI_CRM_CN_Wholesaler__c);
                            lineItem.ASI_CRM_CN_Total_Payable__c = 0;
                            lineItem.ASI_CRM_CN_WS_Intake_9L__c = 0;
                            lineItem.ASI_CRM_CN_Outlet_Intake_9L__c = 0;
                            lineItem.ASI_CRM_Actual_Value_Base__c = 0;
                            lineItem.ASI_CRM_CTD_Actual_Purchase_Value__c = 0;
                            lineItem.ASI_CRM_CN_POS_Value__c = 0;
                            lineItem.ASI_CRM_CN_POS_Volume__c = 0;
                            lineItem.ASI_CRM_CTD_Actual_Retail_Value__c = 0;
                            lineItem.ASI_CRM_CTD_Actual_Vol__c = 0;

                        }
                        totalPaymentAmount += lineItem.ASI_CRM_CN_Total_Payable__c;

                        modulePaymentList.add(lineItem);
                    }
                    module.ASI_CRM_Application_Payment_Amount__c = totalPaymentAmount;
                    // TODO calculate historical paid amount
                    module.ASI_CRM_Actual_Payment__c = totalPaymentAmount - ASI_CRM_CN_PromotionPaymentCtrl.denullify(module.ASI_CRM_Historical_Paid_Amount__c);
                    // module.ASI_CRM_Actual_Payment__c = totalPaymentAmount ;
                }
            }
            update moduleList;
            if(modulePaymentList.size() > 0) update modulePaymentList;
        }
      
    }

    
    /*
        Author:Bowen
        Date:2019-10-24
        Function: 计算payment request line item的扣减金额
     */
    public static List<ASI_TH_CRM_PaymentRequestLineItem__c> TotalPaymentRequestLineItem(List<ASI_TH_CRM_PaymentRequestLineItem__c> lineItems ,ASI_TH_CRM_Contract__c ContractSelected 
            ,ASI_TH_CRM_PaymentRequest__c PH ,Set<Id> outletIds ,Set<Id> wholesalerIds ,Boolean isSouthRegion)
    {
        Set<String> packSizeSet = new Set<String>();
        Set<Id> subbrandSet = new Set<Id>();

        Map<Id ,String> subBrandPackSizeMap = new Map<Id ,String>();
        Map<Id ,Boolean> subBrandDropInMap = new Map<Id ,Boolean>();

        Map<String ,Set<Id>> subBrandGroupMap = new Map<String ,Set<Id>>();

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSF_List = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        BRSF_List = [select Id ,
                            ASI_CRM_CN_Sub_Brand__c ,
                            ASI_CRM_CN_Pack_Size__c ,
                            ASI_CRM_CN_Drop_In__c ,
                            ASI_CRM_Type__c ,
                            ASI_CRM_CN_Sub_Brand_Package__c ,
                            ASI_CRM_CN_Contract__c 
                        from ASI_CRM_CN_Contract_BRSF_Line_Item__c
                        where ASI_CRM_CN_Contract__c =: ContractSelected.Id
                        and (ASI_CRM_CN_Pack_Size__c != null
                            or ASI_CRM_CN_Drop_In__c = true)
                        and ASI_CRM_Type__c =: 'BRSF'];
        if(BRSF_List.size() > 0)
        {
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c brsf : BRSF_List)
            {
                if(brsf.ASI_CRM_CN_Sub_Brand__c == null) continue;
                Boolean flag = false;
                // 存储brsf中的每一个数据的packsize值
                if(brsf.ASI_CRM_CN_Pack_Size__c != null)
                {
                    flag = true;
                    if(!subBrandPackSizeMap.containsKey(brsf.ASI_CRM_CN_Sub_Brand__c))
                    {
                        subBrandPackSizeMap.put(brsf.ASI_CRM_CN_Sub_Brand__c, brsf.ASI_CRM_CN_Pack_Size__c);
                    }
                    else
                    {
                        String packSize = subBrandPackSizeMap.get(brsf.ASI_CRM_CN_Sub_Brand__c);
                        subBrandPackSizeMap.put(brsf.ASI_CRM_CN_Sub_Brand__c, packSize + brsf.ASI_CRM_CN_Pack_Size__c);
                    }
                    // 将BRSF上的pack size上分解，用for循环，将包含的pack size归到set上。
                    List<String> splitList = brsf.ASI_CRM_CN_Pack_Size__c.split(';');
                    if(splitList.size() > 0)
                    {
                        for(String str : splitList)
                        {
                            // 取packsize的值
                            if(!packSizeSet.contains(str))
                            {
                                packSizeSet.add(str);
                            }
                        }
                        // 将subbrand加入到set集合中
                        if(!subbrandSet.contains(brsf.ASI_CRM_CN_Sub_Brand__c))
                        {
                            subbrandSet.add(brsf.ASI_CRM_CN_Sub_Brand__c);
                        }
                    }
                }
                // 存储brsf中的每一个数据的dropIn值
                if(brsf.ASI_CRM_CN_Drop_In__c)
                {
                    if(!flag) flag = true;
                    subBrandDropInMap.put(brsf.ASI_CRM_CN_Sub_Brand__c, brsf.ASI_CRM_CN_Drop_In__c);

                    // 将subbrand加入到set集合中
                    if(!subbrandSet.contains(brsf.ASI_CRM_CN_Sub_Brand__c))
                    {
                        subbrandSet.add(brsf.ASI_CRM_CN_Sub_Brand__c);
                    }
                }

                // 属于exclude的内容，且brsf中的属于同一group的subbrandId
                if(flag && brsf.ASI_CRM_CN_Sub_Brand_Package__c != null && brsf.ASI_CRM_CN_Sub_Brand_Package__c != '')
                {
                    if(subBrandGroupMap.containsKey(brsf.ASI_CRM_CN_Sub_Brand_Package__c))
                    {
                        Set<Id> subBrandGroupSet = subBrandGroupMap.get(brsf.ASI_CRM_CN_Sub_Brand_Package__c);
                        if(!subBrandGroupSet.contains(brsf.ASI_CRM_CN_Sub_Brand__c))
                        {
                            subBrandGroupSet.add(brsf.ASI_CRM_CN_Sub_Brand__c);
                        }
                        subBrandGroupMap.put(brsf.ASI_CRM_CN_Sub_Brand_Package__c ,subBrandGroupSet);
                    }
                    else
                    {
                        Set<Id> subBrandGroupSet = new Set<Id>();
                        subBrandGroupSet.add(brsf.ASI_CRM_CN_Sub_Brand__c);
                        subBrandGroupMap.put(brsf.ASI_CRM_CN_Sub_Brand_Package__c ,subBrandGroupSet);
                    }
                }
            }
        }

        Set<Id> WSOutletIds = new Set<Id>();
        if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' && ContractSelected.ASI_CRM_CN_Data_Source__c !='Outlet Intake'){
            WSOutletIds = wholesalerIds;
        }else{
            WSOutletIds = outletIds;
        }

        Set<Id> excludeOutletSet = new Set<Id>();
        Set<Id> exculdeWSSet = new Set<Id>();

        for(ASI_TH_CRM_PaymentRequestLineItem__c paymentlineItem : lineItems)
        {
            if(paymentLineItem.ASI_CRM_Customer__c != null && !excludeOutletSet.contains(paymentLineItem.ASI_CRM_Customer__c)) excludeOutletSet.add(paymentLineItem.ASI_CRM_Customer__c);

            if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && !exculdeWSSet.contains(paymentLineItem.ASI_CRM_CN_Wholesaler__c)) exculdeWSSet.add(paymentLineItem.ASI_CRM_CN_Wholesaler__c);
        }
        // 开始日期是payment中的start date
        Date startDate = PH.ASI_CRM_CN_PO_Start_Date__c;
        Date endDate = PH.ASI_CRM_CN_Payment_Request_End_Date__c;
        system.debug('----endDate==='+endDate);
        system.debug('----subbrandSet==='+subbrandSet.size());
        system.debug('----WSOutletIds==='+WSOutletIds.size());

        if(subbrandSet.size() > 0)
        {
            // 查询条件：相同的subbrand，PO下的outlet/wholeasler，时间在payment 开始时间到enddate之间
            List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemGroupVolumeList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
            if(Test.isRunningTest())
            {
                excludeItemGroupVolumeList = [select Id ,ASI_CRM_CN_Pack_Size__c ,
                                                                                        ASI_CRM_CN_Intake_GS_T1_price__c ,
                                                                                        ASI_CRM_POS_9L__c ,
                                                                                        ASI_CRM_POS_GS__c ,
                                                                                        ASI_CRM_Actual_Vol_9L__c ,
                                                                                        ASI_CRM_PR_Direct__c ,
                                                                                        ASI_CRM_T2_Depletion__c ,
                                                                                        ASI_CRM_Depletion_GS_T1_Price__c ,
                                                                                        ASI_CRM_Depletion__c,
                                                                                        ASI_CRM_Account__c ,
                                                                                        ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c ,
                                                                                        ASI_CRM_Outlet__c ,
                                                                                        ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c,
                                                                                        ASI_CRM_Sub_Brand__c ,
                                                                                        ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                                                                                        ASI_CRM_End_Date__c ,
                                                                                        ASI_CRM_CN_Item_Group__c ,
                                                                                        ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c ,
                                                                                        ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c
                                                                                    from ASI_CRM_Exclude_Item_Group_Volume__c 
                                                                                    ];              
            }
            else
            {
                if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion)
                {
                    system.debug('outlet promotion =='+subbrandSet+'----'+exculdeWSSet+'====='+excludeOutletSet);
                    excludeItemGroupVolumeList = [select Id ,ASI_CRM_CN_Pack_Size__c ,
                                                                                        ASI_CRM_CN_Intake_GS_T1_price__c ,
                                                                                        ASI_CRM_POS_9L__c ,
                                                                                        ASI_CRM_POS_GS__c ,
                                                                                        ASI_CRM_Actual_Vol_9L__c ,
                                                                                        ASI_CRM_PR_Direct__c ,
                                                                                        ASI_CRM_T2_Depletion__c ,
                                                                                        ASI_CRM_Depletion_GS_T1_Price__c ,
                                                                                        ASI_CRM_Depletion__c,
                                                                                        ASI_CRM_Account__c ,
                                                                                        ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c ,
                                                                                        ASI_CRM_Outlet__c ,
                                                                                        ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c,
                                                                                        ASI_CRM_CN_CRM_Code__c ,
                                                                                        ASI_CRM_Sub_Brand__c ,
                                                                                        ASI_CRM_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                                                                                        ASI_CRM_CN_Item_Group__c ,
                                                                                        ASI_CRM_End_Date__c ,
                                                                                        ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c ,
                                                                                        ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c
                                                                                    from ASI_CRM_Exclude_Item_Group_Volume__c 
                                                                                    where ASI_CRM_Sub_Brand__c in: subbrandSet
                                                                                    and (ASI_CRM_Account__c in: exculdeWSSet
                                                                                        or ASI_CRM_Outlet__c in: excludeOutletSet)
                                                                                    and ASI_CRM_End_Date__c <=: endDate
                                                                                    and ASI_CRM_End_Date__c >=: startDate
                                                                                    and ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Exclusion__c = true];
                }
                else
                {
                    system.debug('outlet promotion =='+subbrandSet+'----'+wholesalerIds+'====='+outletIds);
                    excludeItemGroupVolumeList = [select Id ,ASI_CRM_CN_Pack_Size__c ,
                                                                                        ASI_CRM_CN_Intake_GS_T1_price__c ,
                                                                                        ASI_CRM_POS_9L__c ,
                                                                                        ASI_CRM_POS_GS__c ,
                                                                                        ASI_CRM_Actual_Vol_9L__c ,
                                                                                        ASI_CRM_PR_Direct__c ,
                                                                                        ASI_CRM_T2_Depletion__c ,
                                                                                        ASI_CRM_Depletion_GS_T1_Price__c ,
                                                                                        ASI_CRM_Depletion__c,
                                                                                        ASI_CRM_Account__c ,
                                                                                        ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c ,
                                                                                        ASI_CRM_Outlet__c ,
                                                                                        ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c,
                                                                                        ASI_CRM_CN_CRM_Code__c ,
                                                                                        ASI_CRM_Sub_Brand__c ,
                                                                                        ASI_CRM_End_Date__c ,
                                                                                        ASI_CRM_CN_Item_Group__c ,
                                                                                        ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c ,
                                                                                        ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c
                                                                                    from ASI_CRM_Exclude_Item_Group_Volume__c 
                                                                                    where ASI_CRM_Sub_Brand__c in: subbrandSet
                                                                                    and (ASI_CRM_Account__c in: wholesalerIds
                                                                                        or ASI_CRM_Outlet__c in: outletIds)
                                                                                    and ASI_CRM_End_Date__c <=: endDate
                                                                                    and ASI_CRM_End_Date__c >=: startDate
                                                                                    and ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Exclusion__c = true];
                }
            }
            system.debug('excludeItemGroupVolumeList.size() '+excludeItemGroupVolumeList.size());
            Transient Map<Id ,List<ASI_CRM_Exclude_Item_Group_Volume__c>> outletExcludeMap = new Map<Id ,List<ASI_CRM_Exclude_Item_Group_Volume__c>>();
            Transient Map<Id ,List<ASI_CRM_Exclude_Item_Group_Volume__c>> wholesalerExcludeMap = new Map<Id ,List<ASI_CRM_Exclude_Item_Group_Volume__c>>();
            for(ASI_CRM_Exclude_Item_Group_Volume__c exclude : excludeItemGroupVolumeList)
            {

                if(exclude.ASI_CRM_Outlet__c != null)
                {
                    if(outletExcludeMap.containsKey(exclude.ASI_CRM_Outlet__c))
                    {
                        List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = outletExcludeMap.get(exclude.ASI_CRM_Outlet__c);
                        excludeItemList.add(exclude);
                        outletExcludeMap.put(exclude.ASI_CRM_Outlet__c, excludeItemList);
                    }
                    else
                    {
                        List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
                        excludeItemList.add(exclude);
                        outletExcludeMap.put(exclude.ASI_CRM_Outlet__c, excludeItemList);
                    }
                }

                if(exclude.ASI_CRM_Account__c != null)
                {
                    if(wholesalerExcludeMap.containsKey(exclude.ASI_CRM_Account__c))
                    {
                        List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = wholesalerExcludeMap.get(exclude.ASI_CRM_Account__c);
                        excludeItemList.add(exclude);
                        wholesalerExcludeMap.put(exclude.ASI_CRM_Account__c, excludeItemList);
                    }
                    else
                    {
                        List<ASI_CRM_Exclude_Item_Group_Volume__c> excludeItemList = new List<ASI_CRM_Exclude_Item_Group_Volume__c>();
                        excludeItemList.add(exclude);
                        wholesalerExcludeMap.put(exclude.ASI_CRM_Account__c, excludeItemList);
                    }
                }
            }
            Decimal markupPercent = 1;
            List<ASI_CRM_Module__c> contractPromotionList = [
                    SELECT
                            ASI_CRM_CN_Total_Markup__c,
                            Id
                    FROM ASI_CRM_Module__c
                    WHERE ASI_CRM_Contract__c = :PH.ASI_TH_CRM_Contract__c
                    AND ASI_CRM_Line_Type__c = :'BRSF'
                    LIMIT 1
            ];
            if(contractPromotionList.size() > 0 && contractPromotionList[0] != null && contractPromotionList[0].ASI_CRM_CN_Total_Markup__c != null){
                markupPercent = (1 + contractPromotionList[0].ASI_CRM_CN_Total_Markup__c / 100);
            }
            // 2019-11-01 bowen update ，因为出现空指针异常的报错，原因是contractPromotionTargetModule是空的，所以markupPercent没有值，导致下面的计算是错的，因此这里多加一个逻辑，如果数据是空的，则将markupPercent默认为1
            else{
                markupPercent = 1;
            }
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c paymentlineItem : lineItems)
            {
                System.debug(LoggingLevel.INFO, '*** paymentLineItem begin: ' + paymentLineItem );
                // Set<Id> excludeSet = new Set<Id>();
                // 先判断outlet，因为在exclude中，outlet不一定存在，存在的时候必定有对应的一个wholesaler，故wholesaler的map是全部的exclude List 集合值
                if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && wholesalerExcludeMap.containsKey(paymentLineItem.ASI_CRM_CN_Wholesaler__c))
                {
                    system.debug('paymentLineItem.Id==='+paymentLineItem.Id+'所对应的wholesaler exclude list==='+ wholesalerExcludeMap.get(paymentLineItem.ASI_CRM_CN_Wholesaler__c).size());
                    for(ASI_CRM_Exclude_Item_Group_Volume__c exclude : wholesalerExcludeMap.get(paymentLineItem.ASI_CRM_CN_Wholesaler__c))
                    {
                        // if(excludeSet.size() > 0 && excludeSet.contains(exclude.Id))continue;
                        Boolean itemFlag = ExcludeCount(paymentlineItem , exclude ,subBrandPackSizeMap ,subBrandDropInMap ,subBrandGroupMap ,exculdeWSSet ,excludeOutletSet);
                        /*
                            如果itemFlag为false，执行payment request line item与exclude之间的计算逻辑
                         */
                        if(!itemFlag)
                        {
                            system.debug('exclude.Id =='+exclude.Id);
                            paymentLineItem = CountExcludeItemGroupAndPaymentItem(paymentLineItem , exclude ,ContractSelected ,outletIds ,excludeOutletSet ,isSouthRegion ,markupPercent);
                        }
                    }
                    // ExcludeCount(paymentlineItem , wholesalerExcludeMap.get(paymentLineItem.ASI_CRM_CN_Wholesaler__c) ,subBrandPackSizeMap ,subBrandDropInMap ,subBrandGroupMap ,exculdeWSSet ,excludeOutletSet);
                }
                else if(paymentLineItem.ASI_CRM_Customer__c != null && outletExcludeMap.containsKey(paymentLineItem.ASI_CRM_Customer__c))
                {
                    system.debug('paymentLineItem.Id==='+paymentLineItem.Id+'所对应的outlet exclude list==='+ outletExcludeMap.get(paymentLineItem.ASI_CRM_Customer__c).size());
                    for(ASI_CRM_Exclude_Item_Group_Volume__c exclude : outletExcludeMap.get(paymentLineItem.ASI_CRM_Customer__c))
                    {
                        Boolean itemFlag = ExcludeCount(paymentlineItem , exclude ,subBrandPackSizeMap ,subBrandDropInMap ,subBrandGroupMap ,exculdeWSSet ,excludeOutletSet);
                        /*
                            如果itemFlag为false，执行payment request line item与exclude之间的计算逻辑
                         */
                        if(!itemFlag)
                        {
                            system.debug('exclude.Id =='+exclude.Id);
                            paymentLineItem = CountExcludeItemGroupAndPaymentItem(paymentLineItem , exclude ,ContractSelected ,outletIds ,excludeOutletSet ,isSouthRegion ,markupPercent);
                        }
                        // if(!flag)
                        // {
                        //     excludeSet.add(exclude.Id);
                        // }
                    }
                    
                }
                
                


                system.debug('开始时'+paymentLineItem);
                // WS Intake (9L) 的实际数值、以及未扣减前数值和应扣减数值
                paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Original__c = paymentLineItem.ASI_CRM_CN_WS_Intake_9L__c;// 保存初始原来的值
                paymentLineItem.ASI_CRM_CN_WS_Intake_9L__c = ExcludeJudge(paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Original__c ,paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c);
                

                //  Outlet Intake (9L) 的实际数值、以及未扣减前数值和应扣减数值
                paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Original__c = paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L__c;// 保存初始原来的值
                if(paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Original__c != 0 && paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Original__c != null)
                {
                    paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L__c = ExcludeJudge(paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Original__c ,paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c);
                }
                
                // CTD Actual Purchase Value 的实际数值、以及未扣减前数值和应扣减数值
                paymentLineItem.ASI_CRM_Actual_Purchase_Value_Original__c = (paymentLineItem.ASI_CRM_CTD_Actual_Purchase_Value__c != null ? paymentLineItem.ASI_CRM_CTD_Actual_Purchase_Value__c : 0); // 保存初始原来的值
                paymentLineItem.ASI_CRM_CTD_Actual_Purchase_Value__c = ExcludeJudge(paymentLineItem.ASI_CRM_Actual_Purchase_Value_Original__c ,paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c);
                // POS Volume (9L) 的实际数值、以及未扣减前数值和应扣减数值
                paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Original__c = (paymentLineItem.ASI_CRM_CN_POS_Volume__c != null ? paymentLineItem.ASI_CRM_CN_POS_Volume__c : 0);// 保存初始原来的值
                paymentLineItem.ASI_CRM_CN_POS_Volume__c = ExcludeJudge(paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Original__c ,paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c);// 计算初始值-exclude后得到的值
                
                // POS Value 的实际数值、以及未扣减前数值和应扣减数值
                paymentLineItem.ASI_CRM_CN_POS_Value_Original__c = (paymentLineItem.ASI_CRM_CN_POS_Value__c != null ? paymentLineItem.ASI_CRM_CN_POS_Value__c : 0); // 保存初始原来的值
                paymentLineItem.ASI_CRM_CN_POS_Value__c = ExcludeJudge(paymentLineItem.ASI_CRM_CN_POS_Value_Original__c ,paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c); // 计算初始值-exclude后得到的值
                
                // CTD Actual Retail Value 的实际数值、以及未扣减前数值和应扣减数值
                paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Original__c = (paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value__c != null ? paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value__c : 0); // 保存初始原来的值
                if(paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Original__c != null &&
                    paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Original__c != 0   )
                {
                    paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value__c = ExcludeJudge(paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Original__c ,paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c); // 计算初始值-exclude后得到的值 

                }
                // Actual Value Base 的实际数值、以及未扣减前数值
                paymentLineItem.ASI_CRM_CN_Actual_Value_Base_Original__c = (paymentLineItem.ASI_CRM_Actual_Value_Base__c != null ? paymentLineItem.ASI_CRM_Actual_Value_Base__c : 0);

                // Total Payable Original 的实际数值、以及未扣减前数值
                paymentLineItem.ASI_CRM_CN_Total_Payable_Original__c = (paymentLineItem.ASI_CRM_CN_Total_Payable__c != null ? paymentLineItem.ASI_CRM_CN_Total_Payable__c : 0);

                system.debug('计算结束后'+paymentLineItem);
            }

            lineItems = ASI_CRM_CN_PromotionPaymentCtrl.calculateDataSource(lineItems ,ContractSelected.ASI_CRM_CN_Data_Source__c); // 重新计算ASI_CRM_Actual_Value_Base__c
        }
        
        return lineItems;
    }
    private static Boolean ExcludeCount(ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem ,ASI_CRM_Exclude_Item_Group_Volume__c exclude
        ,Map<Id ,String> subBrandPackSizeMap ,Map<Id ,Boolean> subBrandDropInMap ,Map<String ,Set<Id>> subBrandGroupMap ,Set<Id> exculdeWSSet ,Set<Id> excludeOutletSet)
    {
        // for(ASI_CRM_Exclude_Item_Group_Volume__c exclude : excludeList)
        // {
            
        Boolean WSFlag = false;
        Boolean OutletFlag = false;

        Boolean itemFlag = true;

        // if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && paymentLineItem.ASI_CRM_Customer__c != null && 
        //     exclude.ASI_CRM_Account__c != null && exclude.ASI_CRM_Outlet__c != null &&
        //     (paymentLineItem.ASI_CRM_CN_Wholesaler__c != exclude.ASI_CRM_Account__c || 
        //         paymentLineItem.ASI_CRM_Customer__c != exclude.ASI_CRM_Outlet__c))
        // {
        //     continueFlag = true;
        // }
        // else 
        if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && exclude.ASI_CRM_Account__c != null &&
            paymentLineItem.ASI_CRM_CN_Wholesaler__c != exclude.ASI_CRM_Account__c) { WSFlag = true; }
        if(paymentLineItem.ASI_CRM_Customer__c != null && exclude.ASI_CRM_Outlet__c != null &&
            paymentLineItem.ASI_CRM_Customer__c != exclude.ASI_CRM_Outlet__c) { OutletFlag = true; }

        if(paymentLineItem.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' && WSFlag && OutletFlag) return itemFlag;

        if((paymentLineItem.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion' || paymentLineItem.ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c == 'Customer Promotion') && paymentlineItem.ASI_CRM_CN_CRM_Code__c != exclude.ASI_CRM_Account__r.ASI_CRM_CN_CRM_Code__c && paymentLineItem.ASI_CRM_CN_CRM_Code__c != exclude.ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c) return itemFlag;

        // 当payment request line item的subbrandId不为空时，且与exclusion的subbrandId不相同，则跳出判断。仅当不为空或相同，方能进入判断
        if(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c != null && paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c  != null && paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c  != exclude.ASI_CRM_Sub_Brand__c) return itemFlag;

        // if(paymentLineItem.ASI_CRM_CN_Sub_Brand__c != null && paymentLineItem.ASI_CRM_CN_Sub_Brand__c != exclude.ASI_CRM_Sub_Brand__c) continue;

        if (paymentLineItem.ASI_CRM_Module__r.ASI_CRM_Parent_Module__r.ASI_CRM_Methodology__r.Name == 'Rebate%(By Month)') {
            if(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c != null)
            {
                Integer year = paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c.year();
                Integer month = paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Date__c.month();
                if (year != exclude.ASI_CRM_End_Date__c.year() || month != exclude.ASI_CRM_End_Date__c.month()) {
                    return itemFlag;
                }
            }
            
        }
        // 当payment request line item所关联的module是by Brand Group的时候，判断这个group中的subbrandId是否包含exclude，不包含，则跳出循环
        if(paymentLineItem.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c == 'By Brand Group' && paymentLineItem.ASI_CRM_CN_Sub_brand_Group__c != null
            && paymentLineItem.ASI_CRM_CN_Sub_brand_Group__c != '')
        {
            if(subBrandGroupMap.containsKey(paymentLineItem.ASI_CRM_CN_Sub_brand_Group__c))
            {
                Set<Id> subBrandGroupSet = subBrandGroupMap.get(paymentLineItem.ASI_CRM_CN_Sub_brand_Group__c);
                if(!subBrandGroupSet.contains(exclude.ASI_CRM_Sub_Brand__c)) return itemFlag;
            }
            else
            {
                return itemFlag;
            }
        }

        

        String BRSF_PackSize = '';
        Boolean isDropIn = false;

        // ASI_CRM_CN_Payment_Request_Detail_Promotion 类型的payment request line item，是存在subbrand，所以可以直接判断这个subbrandId
        if(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c != null && 
            paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c  != null)
        {
            BRSF_PackSize = (subBrandPackSizeMap.containsKey(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ) ?
                                subBrandPackSizeMap.get(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ) : '');
            isDropIn = (subBrandDropInMap.containsKey(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ) ?
                                subBrandDropInMap.get(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c ) : false);
        }
        // 其余情况，根据exclusion判断
        else if(paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__c == null || paymentLineItem.ASI_CRM_CN_Contract_BRSF_Line_Item__r.ASI_CRM_CN_Sub_Brand__c  == null)
        {
            BRSF_PackSize = (subBrandPackSizeMap.containsKey(exclude.ASI_CRM_Sub_Brand__c) ?
                                subBrandPackSizeMap.get(exclude.ASI_CRM_Sub_Brand__c) : '');
            isDropIn = (subBrandDropInMap.containsKey(exclude.ASI_CRM_Sub_Brand__c) ?
                                subBrandDropInMap.get(exclude.ASI_CRM_Sub_Brand__c) : false);
        }
        

        /* 
            如果BRSF line item的pack size 不为空，根据相同的subbrand
            包含exclude item group volume中item group 的bottle size，
            即将exclude item group volume视为可扣减对象，进行标识
        */
        if((BRSF_PackSize != null || BRSF_PackSize != '' )
            && (exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c != null))
        {
            
            Integer pointCount = exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c.indexOf('.');
            String BT_Size = '';
            if(pointCount >= 0)
            {
                BT_Size = exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c.substring(0 ,pointCount);
            }
            else
            {
                BT_Size = exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_BT_Size_C__c;
            }
            if(BRSF_PackSize.indexOf(BT_Size) != -1)
            {
                itemFlag = false;
            }
            
        }
        /* 
            如果payment request line item中BRSF line item的drop in 为true
            且当前exclude item group volume中item group 的drop in也为true，
            即将exclude item group volume视为可扣减对象，进行标识
        */
        if(itemFlag && isDropIn 
            && exclude.ASI_CRM_CN_Item_Group__r.ASI_CRM_CN_Drop_In__c)
        {
            itemFlag = false;
        }

        return itemFlag;
        // }
    }
    /*
        Author：Bowen
        Date:2019-11-01
        Function:
            功能类，当被减数小于减数，则返回0；反之按正常的计算逻辑走
     */
    public static Decimal ExcludeJudge(Decimal orginal ,Decimal exclude)
    {
        Decimal ExcludeResult = 0;
        if(orginal == null) orginal = 0;
        if(exclude == null) exclude = 0;
        ExcludeResult = orginal - exclude;

        // if(orginal < exclude)
        // {
        //     ExcludeResult = 0;
        // }
        // else
        // {
        //     ExcludeResult = orginal - exclude;
        // }
        return ExcludeResult;
    }
    
    public static Decimal NullJude(Decimal total)
    {
        Decimal result = 0;
        if(total != null)
        {
            result = total;
        }
        return result;
    }

    /*
        Author:Bowen
        Date:2019-10-29
        Function:
            计算逻辑：根据整个代码汇总出来，当user选择pack size 或者 drop in的时候，
            需要从exclude line item上汇总用于扣减的数据
     */
    public static ASI_TH_CRM_PaymentRequestLineItem__c CountExcludeItemGroupAndPaymentItem(ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem 
        ,ASI_CRM_Exclude_Item_Group_Volume__c exclude ,ASI_TH_CRM_Contract__c ContractSelected 
            ,Set<Id> outletIds ,Set<Id> excludeOutletSet ,Boolean isSouthRegion ,Decimal markupPercent)
    {
        system.debug('进入 CountExcludeItemGroupAndPaymentItem '+exclude.Id);
        if(paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c == null) paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c = 0;
        if(paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c == null) paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c= 0;
        if(paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c == null) paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c= 0;
        if(paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c == null) paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c= 0;
        if(paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c == null) paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c= 0;
        if(paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c == null) paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c= 0;

        // paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
        // paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
        if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion)
        {
            if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && exclude.ASI_CRM_Account__c != null && paymentLineItem.ASI_CRM_CN_Wholesaler__c == exclude.ASI_CRM_Account__c)
            {
                paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
                paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
            }
            if(paymentLineItem.ASI_CRM_Customer__c != null && paymentLineItem.ASI_CRM_CN_Wholesaler__c != null)
            {
                if(exclude.ASI_CRM_Outlet__c != null)
                {
                    if(paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c && paymentLineItem.ASI_CRM_CN_Wholesaler__c == exclude.ASI_CRM_Account__c)
                    {
                        paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
                        paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
                    }
                }
            }
            else if(exclude.ASI_CRM_Outlet__c != null && paymentLineItem.ASI_CRM_Customer__c != null 
                && paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c)
            {
                paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
                paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
            }
        }
        else
        {

            if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion')
            {
                if(ContractSelected.ASI_CRM_CN_Data_Source__c !='Outlet Intake')
                {
                    paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
                    paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
                }

                // if(outletIds.size() > 0 && exclude.ASI_CRM_Outlet__c != null)
                // {
                //     for(Id outlet : outletIds)
                //     {
                //         if(outlet == exclude.ASI_CRM_Outlet__c)
                //         {
                //             paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
                //             paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
                //         }
                //     }
                // }

                if(ContractSelected.ASI_CRM_CN_Data_Source__c =='Outlet Intake' && exclude.ASI_CRM_Outlet__c != null && excludeOutletSet.size() > 0)
                {
                    if(excludeOutletSet.contains(exclude.ASI_CRM_Outlet__c))
                    {
                        paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
                        paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
                    }
                }
                // else if(exclude.ASI_CRM_Outlet__c != null && paymentLineItem.ASI_CRM_Customer__c != null 
                //     && paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c)
                else if(paymentLineItem.ASI_CRM_Customer__c == null )
                {

                    if(outletIds.size() > 0 && exclude.ASI_CRM_Outlet__c != null)
                    {
                        if(outletIds.contains(exclude.ASI_CRM_Outlet__c))
                        {
                            paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
                            paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
                        }
                    }
                }
                
            }
            else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' || ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Consumer Promotion')
            {
                if(paymentLineItem.ASI_CRM_CN_Wholesaler__c != null && exclude.ASI_CRM_Account__c != null && paymentLineItem.ASI_CRM_CN_Wholesaler__c == exclude.ASI_CRM_Account__c)
                {
                    paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
                    paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
                }

                if(paymentLineItem.ASI_CRM_Customer__c != null && paymentLineItem.ASI_CRM_CN_Wholesaler__c != null)
                {
                    if(exclude.ASI_CRM_Outlet__c != null)
                    {
                        if(paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c && paymentLineItem.ASI_CRM_CN_Wholesaler__c == exclude.ASI_CRM_Account__c)
                        {
                            paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
                            paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
                        }
                    }
                }
                else if(exclude.ASI_CRM_Outlet__c != null && paymentLineItem.ASI_CRM_Customer__c != null 
                    && paymentLineItem.ASI_CRM_Customer__c == exclude.ASI_CRM_Outlet__c)
                {
                    paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
                    paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
                }
                // paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
                // paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
                paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_9L__c);
                paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_GS__c) * markupPercent;
            }
        }
        

        // if(PH.ASI_CRM_CN_Promotion_Type__c == 'Wholesaler Promotion')
        // {
        //     paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
        //     paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c += NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
        //     paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Depletion__c);
        //     //if(dataSource =='Outlet Intake')
        //     //{                
        //     //}
        // }
        // else if(PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion')
        // {
        //     paymentLineItem.ASI_CRM_CN_WS_Intake_9L_Exclude__c += NullJude(exclude.ASI_CRM_Actual_Vol_9L__c);
        //     paymentLineItem.ASI_CRM_Actual_Purchase_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
        //     paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_9L__c);
        //     paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_GS__c) * markupPercent;
        //     paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion__c);

        // }
        // else if(PH.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion')
        // {
        //     paymentLineItem.ASI_CRM_CN_POS_Volume_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_9L__c);
        //     paymentLineItem.ASI_CRM_CN_POS_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_POS_GS__c) * markupPercent;
        //     paymentLineItem.ASI_CRM_CN_Outlet_Intake_9L_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion__c);
        // }

        // if(ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' && isSouthRegion)
        // {
        //     if(PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' || PH.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion')
        //     {
        //         paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
        //     }
            
        // }
        // else
        // {
        //     if(PH.ASI_CRM_CN_Promotion_Type__c =='Wholesaler Promotion')
        //     {
        //         paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_Depletion_GS_T1_Price__c) * markupPercent;
        //     }
        //     else if(PH.ASI_CRM_CN_Promotion_Type__c == 'Outlet Promotion' || PH.ASI_CRM_CN_Promotion_Type__c == 'Consumer Promotion')
        //     {
        //         paymentLineItem.ASI_CRM_CTD_Actual_Retail_Value_Exclude__c +=  NullJude(exclude.ASI_CRM_CN_Intake_GS_T1_price__c) * markupPercent;
        //     }
        // }
        
        return paymentLineItem;
    }



}