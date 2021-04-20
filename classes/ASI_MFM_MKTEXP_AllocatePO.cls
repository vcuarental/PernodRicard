public without sharing class ASI_MFM_MKTEXP_AllocatePO
{
    public static ID paymentHKRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_HK_Payment');
    public static ID paymentRMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_RM_Payment');
    public static ID paymentTRRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment');
    public static ID paymentROHKRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_HK_Payment_Read_Only');
    public static ID paymentRORMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_RM_Payment_Read_Only');
    public static ID paymentROTRRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment_Read_Only');
    public static ID paymentItemHKRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MKTEXP_HK_Payment_Line_Item');
    public static ID paymentItemRMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MKTEXP_RM_Payment_Line_Item');
    public static ID paymentItemTRRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MKTEXP_TR_Payment_Line_Item');
    public static ID receiptHKRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_MKTEXP_HK_PO_Receipt');
    public static ID receiptRMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_MKTEXP_RM_PO_Receipt');
    public static ID receiptTRRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_MKTEXP_TR_PO_Receipt');
    public static ID receiptItemHKRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_MKTEXP_HK_PO_Receipt_Item');
    public static ID receiptItemRMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_MKTEXP_RM_PO_Receipt_Item');
    public static ID receiptItemTRRTID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_MKTEXP_TR_PO_Receipt_Item');
    public static ID accrualItemRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Accrual_Request_Item__cASI_MFM_MKTEXP_Accural_Request_Item');
    public static Set<ID> tnedHKRTID = new Set<ID> {
        Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail')
    };
    public static Set<ID> focHKRTID = new Set<ID> {
        Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Approval'),
        Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales_Admin'),
        Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales')
    };

    public static String allocatePO(List<ASI_MFM_Payment__c> paymentList, Boolean prePayment)
    {
        Map<String, String> logMap = new Map<String, String>();
        Set<String> tnedSet = new Set<String>();
        Set<String> focrSet = new Set<String>();
        Boolean hasProcess = false;
        Set<ID> poIDs = new Set<ID>();
        Date lastDate;
        Date minDate;

        for (ASI_MFM_Payment__c payment : paymentList)
        {
            for (Integer i = 1; i <= 5; i++)
            {
                if (payment.get('ASI_MFM_PO_' + i + '__c') != null)
                {
                    poIDs.add((ID)(payment.get('ASI_MFM_PO_' + i + '__c')));
                }
            }

            if (lastDate == null || payment.ASI_MFM_Invoice_Date__c > lastDate)
            {
                lastDate = payment.ASI_MFM_Invoice_Date__c;
            }

            if (minDate == null || payment.ASI_MFM_Invoice_Date__c < minDate)
            {
                minDate = payment.ASI_MFM_Invoice_Date__c;
            }
            
            //20191205:AM@introv - SSC CR start
            if (payment.ASI_MFM_T_E_Detail_External_ID__c != null)
            {
                tnedSet.add(payment.ASI_MFM_T_E_Detail_External_ID__c);
            }
            
            if (payment.ASI_MFM_FOC_Detail_External_ID__c != null)
            {
                focrSet.add(payment.ASI_MFM_FOC_Detail_External_ID__c);
            }
            //20191205:AM@introv - SSC CR end
        }

        if (minDate != null)
        {
            minDate = minDate.addMonths(-1).toStartofMonth();
        }

        List<ASI_MFM_Setting__c> custSetting = [select ASI_MFM_MKTEXP_Cutover__c, ASI_MFM_TR_A_P_PO_Approver__c, ASI_MFM_MKTEXP_PaymentTolerance__c from ASI_MFM_Setting__c];
        List<ASI_MFM_PO_Line_Item__c> poLineItemlist;
        List<ASI_MFM_PO__c> poList;
        ID assignUser;

        if (custSetting != null && custSetting.size() > 0 && custSetting[0].ASI_MFM_MKTEXP_Cutover__c == true)
        {
            poList = [select id, Name, ASI_MFM_HK_T_E_Amount__c, ASI_MFM_HK_T_E_Paid_Amount__c, ASI_MFM_HK_FOC_Amount__c, ASI_MFM_HK_FOC_Paid_Amount__c, ASI_MFM_AP_AD__c, ASI_MFM_Supplier_Name__r.ParentId, ASI_MFM_Object_Key__c,ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c, ASI_MFM_PO_Balance__c, ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_Remaining_Balance__c, ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO__c where id in :poIDs and ASI_MFM_MKTEXP_PO_Balance__c >= 0 and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Partial Paid' or ASI_MFM_Status__c = 'Complete') for update];
            poLineItemlist = [select ASI_MFM_PO__c, ASI_MFM_G_L_Date__c, ID, RecordTypeId, ASI_MFM_List_Item_Description__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_Accrual_Amount_PO_Currency__c, ASI_MFM_Plan_Line_Item__c, ASI_MFM_PO__r.Ownerid, ASI_MFM_PO__r.ASI_MFM_Responsible_By__c, Name, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_BU_Code__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c, ASI_MFM_PO__r.ASI_MFM_Currency__c, ASI_MFM_Amount__c, ASI_MFM_Base_Currency_Amount__c, ASI_MFM_Remaining_Balance__c, ASI_MFM_Base_Currency_Remaining_Balance__c,  ASI_MFM_PO__r.ASI_MFM_PO_Amount__c, ASI_MFM_Accrual_Balance_Base_Currency__c, ASI_MFM_Accrual_Balance_PO_Currency__c, ASI_MFM_PO__r.Name, ASI_MFM_PO__r.ASI_MFM_PO_Balance__c, ASI_MFM_PO__r.ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_PO__r.ASI_MFM_GL_Date__c, ASI_MFM_Customer_Name__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c, ASI_MFM_Receipt_Amount_in_Base_Currency__c, ASI_MFM_PaidAmount_in_BaseCurrency__c, ASI_MFM_Exceed__c, ASI_MFM_PO__r.ASI_MFM_AP_AD__c, ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in :poIDs and ASI_MFM_PO__r.ASI_MFM_MKTEXP_PO_Balance__c >= 0 and (ASI_MFM_PO__r.ASI_MFM_Status__c = 'Final' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Partial Paid' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Complete') for update];
        }
        else
        {
            poList = [
                select id, Name, ASI_MFM_HK_T_E_Amount__c, ASI_MFM_HK_T_E_Paid_Amount__c, ASI_MFM_HK_FOC_Amount__c, ASI_MFM_HK_FOC_Paid_Amount__c, ASI_MFM_AP_AD__c, ASI_MFM_Supplier_Name__r.ParentId, ASI_MFM_Object_Key__c,
                ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c, ASI_MFM_PO_Balance__c,
                ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_Remaining_Balance__c, ASI_MFM_Base_Currency_Amount__c
                from ASI_MFM_PO__c 
                where id in :poIDs 
                and ASI_MFM_MKTEXP_PO_Balance__c >= 0 
                and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Partial Paid')
                for update
                ];
            poLineItemlist = [
                select
                ASI_MFM_PO__c, ASI_MFM_G_L_Date__c, ID, RecordTypeId, ASI_MFM_List_Item_Description__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_Accrual_Amount_PO_Currency__c,
                ASI_MFM_Plan_Line_Item__c, ASI_MFM_PO__r.Ownerid, ASI_MFM_PO__r.ASI_MFM_Responsible_By__c, Name,
                ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_BU_Code__c,
                ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c, ASI_MFM_PO__r.ASI_MFM_Currency__c,
                ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c,
                ASI_MFM_Amount__c, ASI_MFM_Base_Currency_Amount__c,
                ASI_MFM_Remaining_Balance__c, ASI_MFM_Base_Currency_Remaining_Balance__c, 
                ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,
                ASI_MFM_Accrual_Balance_Base_Currency__c, ASI_MFM_Accrual_Balance_PO_Currency__c,
                ASI_MFM_PO__r.Name,
                ASI_MFM_PO__r.ASI_MFM_PO_Balance__c,
                ASI_MFM_PO__r.ASI_MFM_MKTEXP_PO_Balance__c,
                ASI_MFM_PO__r.ASI_MFM_GL_Date__c,
                ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c,
                ASI_MFM_Customer_Name__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,
                ASI_MFM_Receipt_Amount_in_Base_Currency__c, ASI_MFM_PaidAmount_in_BaseCurrency__c,
                ASI_MFM_Exceed__c, ASI_MFM_PO__r.ASI_MFM_AP_AD__c
                from ASI_MFM_PO_Line_Item__c
                where ASI_MFM_PO__c in :poIDs
                and ASI_MFM_PO__r.ASI_MFM_MKTEXP_PO_Balance__c >= 0
                and (ASI_MFM_PO__r.ASI_MFM_Status__c = 'Final' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Partial Paid')
                // and ASI_MFM_PO__r.ASI_MFM_AP_AD__c = 'A&P'
                // order by ASI_MFM_G_L_Date__c, ASI_MFM_Sub_brand_Code__c, ID
                for update
            ];
        }

        //20191205:AM@introv - SSC CR start
        Map<String, ASI_TnE_ClaimDetail__c> tnedMap = new Map<String, ASI_TnE_ClaimDetail__c>();
        for (ASI_TnE_ClaimDetail__c tned : [
            select ID, ASI_TnE_Payment_Amount__c, ASI_TnE_HK_Paid_Amount__c, ASI_TnE_HK_Paid_Amount_Raw__c, 
                    ASI_TnE_ClaimHeader__r.ASI_TnE_Total_Amount__c, ASI_TnE_ClaimHeader__r.ASI_TnE_HK_Paid_Amount__c,
                    ASI_TnE_KR_Detail_External_ID__c
            from ASI_TnE_ClaimDetail__c
            where RecordTypeId in :tnedHKRTID
            and ASI_TnE_KR_Detail_External_ID__c in :tnedSet
        ])
        {
            tnedMap.put(tned.ASI_TnE_KR_Detail_External_ID__c, tned);
        }

        Map<String, ASI_FOC_Free_Goods_Request__c> focrMap = new Map<String, ASI_FOC_Free_Goods_Request__c>();
        for (ASI_FOC_Free_Goods_Request__c focr : [
            select ID, Name, ASI_FOC_Budget_Amount__c, ASI_FOC_HK_Paid_Amount__c, ASI_FOC_HK_Paid_Amount_Raw__c
            from ASI_FOC_Free_Goods_Request__c
            where RecordTypeId in :focHKRTID
            and Name in :focrSet
        ])
        {
            focrMap.put(focr.Name, focr);
        }
        //20191205:AM@introv - SSC CR end

        if (custSetting != null && custSetting.size() > 0 && custSetting[0].ASI_MFM_TR_A_P_PO_Approver__c != null)
        {
            assignUser = ID.valueOf(custSetting[0].ASI_MFM_TR_A_P_PO_Approver__c);
        }

        Map<ID, ID> acMap = new Map<ID, ID>();
        Set<String> objKeys = new Set<String>();

        for (ASI_MFM_PO__c po : poList)
        {
            if (po.ASI_MFM_AP_AD__c == 'A&D' && po.ASI_MFM_Object_Key__c != null)
            {
                objKeys.add(po.ASI_MFM_Object_Key__c.substring(0, 11));
            }
        }

        System.debug('objKeys: ' + objKeys);

        if (objKeys.size() > 0)
        {
            for (ASI_MFM_A_C_Code__c ac : [
                    select id, ASI_MFM_A_C_Code__c 
                    from ASI_MFM_A_C_Code__c 
                    where RecordType.DeveloperName = 'ASI_MFM_HK_A_C_Code' and ASI_MFM_A_C_Code__c in :objKeys
                ])
            {
                System.debug('acCode1: ' + ac.ASI_MFM_A_C_Code__c);
                for (ASI_MFM_PO__c po : poList)
                {
                    
                    if (po.ASI_MFM_AP_AD__c == 'A&D' && po.ASI_MFM_Object_Key__c != null && po.ASI_MFM_Object_Key__c.substring(0, 11) == ac.ASI_MFM_A_C_Code__c)
                    {
                        System.debug('acCode2: ' + po.ASI_MFM_Object_Key__c.substring(0, 11));
                        acMap.put(po.id, ac.id);
                        break;
                    }
                }
            }
        }

        System.debug('acMap: ' + acMap);

        Map<String, ASI_MFM_Payment_Line_Item__c> insertPaymentItem = new Map<String, ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_Accrual_Request_Item__c> insertAccrualItem = new List<ASI_MFM_Accrual_Request_Item__c>();
        Map<String, ASI_MFM_PO_Line_Item__c> insertPOItem = new Map<String, ASI_MFM_PO_Line_Item__c>();
        Map<String, ASI_MFM_PO_Receipt__c> insertReceipt = new Map<String, ASI_MFM_PO_Receipt__c>();
        Map<String, ASI_MFM_PO_Receipt_Item__c> insertReceiptItem = new Map<String, ASI_MFM_PO_Receipt_Item__c>();
        Map<String, Map<String, Decimal>> relatedMap = new Map<String, Map<String, Decimal>>();
        List<ASI_MFM_Payment__Share> insertShareList = new List<ASI_MFM_Payment__Share>();
        Set<ID> trPOOwnerIDs = new Set<ID>();

        Set<String> ccySet = new Set<String>();
        Map<String, ASI_MFM_MKTEXP_POToleranceLimit__mdt> setting = new Map<String, ASI_MFM_MKTEXP_POToleranceLimit__mdt>();
        for (ASI_MFM_MKTEXP_POToleranceLimit__mdt tSet : [
            select
            ASI_MFM_MKTEXP_Record_Type__c,
            ASI_MFM_AP_AD__c,
            ASI_MFM_MKTEXP_Amount__c,
            ASI_MFM_MKTEXP_Percentage__c,
            ASI_MFM_MKTEXP_Currency__c
            from ASI_MFM_MKTEXP_POToleranceLimit__mdt
        ]) {
            String exCur = tSet.ASI_MFM_MKTEXP_Currency__c == null ? 'HKD' : tSet.ASI_MFM_MKTEXP_Currency__c;
            ID rtID = Global_RecordTypeCache.getRtId(tSet.ASI_MFM_MKTEXP_Record_Type__c);

            if (tSet.ASI_MFM_AP_AD__c == null)
            {
                setting.put('A&P' + rtID + exCur, tSet);
            }
            else
            {
                setting.put(tSet.ASI_MFM_AP_AD__c + rtID + exCur, tSet);
            }

            if (tSet.ASI_MFM_MKTEXP_Currency__c != null && tSet.ASI_MFM_MKTEXP_Currency__c != '')
            {
                ccySet.add(tSet.ASI_MFM_MKTEXP_Currency__c);
            }
        }

        List<ASI_MFM_Exchange_Rate__c> exchangeList = [
            select id, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
            where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c in ('HK','RM','TR')
            and ASI_MFM_Base_Currency__c = 'HKD' and ASI_MFM_Counter_Currency__c in :ccySet
            and ASI_MFM_Effective_Date__c <= :lastDate and ASI_MFM_Effective_Date__c >= :minDate
            order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc
        ];

        // Integer startMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;

        Integer receiptHeaderCount = 0;
        Integer receiptItemCount = 0;
        Integer paymentItemCount = 0;

        for (ASI_MFM_Payment__c payment : paymentList)
        {
            Boolean hasAP = false;
            Boolean hasAD = false;
            for (Integer i = 1; i <= 5; i++)
            {
                if (payment.get('ASI_MFM_PO_' + i + '__c') != null)
                {
                    ASI_MFM_PO__c po = getPO(poList, (ID)(payment.get('ASI_MFM_PO_' + i + '__c')));

                    if (po != null)
                    {
                        if (po.ASI_MFM_AP_AD__c == 'A&D')
                        {
                            hasAD = true;
                        }
                        else if (po.ASI_MFM_AP_AD__c == 'A&P')
                        {
                            hasAP = true;
                        }
                    }
                }
            }
            Map<ID, User> userMap;

            if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && hasAP)
            {
                userMap = new Map<ID, User>([
                    select ID, UserRole.DeveloperName
                    from User
                    where UserRole.DeveloperName in ('ASI_ATR_KD_Agent', 'ASI_ATR_KR_Agent')
                ]);
            }

            Map<String, ASI_MFM_PO_Receipt__c> ownerGroup = new Map<String, ASI_MFM_PO_Receipt__c>();
            Map<String, String> headerKeys = new Map<String, String>();
            Map<ID, Decimal> remainMap = new Map<ID, Decimal>();

            for (ASI_MFM_PO_Line_Item__c item : poLineItemlist)
            {
                if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && payment.ASI_MFM_Prepayment__c == true)
                {
                    remainMap.put(item.ID, item.ASI_MFM_Accrual_Balance_PO_Currency__c);
                }
                else
                {
                    remainMap.put(item.ID, item.ASI_MFM_Remaining_Balance__c);
                }
            }

            if (payment.ASI_MFM_Prepayment__c == prePayment && payment.ASI_MFM_Payment_Line_Generation__c == false)
            {
                hasProcess = true;

                for (Integer i = 1; i <= 5; i++)
                {
                    if (payment.get('ASI_MFM_PO_' + i + '__c') != null)
                    {
                        ID poID = (ID)(payment.get('ASI_MFM_PO_' + i + '__c'));
                        ASI_MFM_PO__c po = getPO(poList, poID);
                        Decimal totalPaymentAmount = (Decimal)payment.get('ASI_MFM_PO_' + i + '_Amount__c');
                        Decimal paymentAmount = totalPaymentAmount;
                        List<ASI_MFM_PO_Line_Item__c> poliList = getPOLineItem(poLineItemlist, poID);

                        if (hasAP && po.ASI_MFM_AP_AD__c == 'A&D')
                        {
                            continue;
                        }

                        if (poliList.size() > 0)
                        {
                            Decimal adjust = 0;
                            if (custSetting != null && custSetting.size() > 0 && custSetting[0].ASI_MFM_MKTEXP_PaymentTolerance__c != null)
                            {
                                adjust = (Decimal)custSetting[0].ASI_MFM_MKTEXP_PaymentTolerance__c;
                            }

                            //20191205:AM@introv - SSC CR start
                            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true
                                 && (payment.ASI_MFM_T_E_Detail_External_ID__c != null || payment.ASI_MFM_FOC_Detail_External_ID__c != null))
                            {
                                if (payment.ASI_MFM_T_E_Detail_External_ID__c != null)
                                {
                                    ASI_TnE_ClaimDetail__c tned = tnedMap.get(payment.ASI_MFM_T_E_Detail_External_ID__c);

                                    if (tned == null)
                                    {
                                        String logID = 'PO,' + po.ID;
                                        String msg = 'T&E Detail not found\n';
                                        appendLog(logMap, logID, msg);
                                    }
                                    else if (po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2) + (tned.ASI_TnE_Payment_Amount__c != null ? tned.ASI_TnE_Payment_Amount__c : 0) < (paymentAmount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2) - adjust)
                                    {
                                        String logID = 'PO,' + po.ID;
                                        String msg = 'PO#: ' + po.Name + ' - payment amount should not be greater than po balance\n';
                                        appendLog(logMap, logID, msg);
                                    }
                                    
                                    if (tned != null)
                                    {
                                        tned.ASI_TnE_HK_Paid_Amount__c = tned.ASI_TnE_Payment_Amount__c;
                                    	tned.ASI_TnE_HK_Paid_Amount_Raw__c = payment.ASI_MFM_MKTEXP_Invoice_Amount__c;
                                    }
                                }
                                else if (payment.ASI_MFM_FOC_Detail_External_ID__c != null)
                                {
                                    ASI_FOC_Free_Goods_Request__c focr = focrMap.get(payment.ASI_MFM_FOC_Detail_External_ID__c);

                                    if (focr == null)
                                    {
                                        String logID = 'PO,' + po.ID;
                                        String msg = 'Free Good Request not found\n';
                                        appendLog(logMap, logID, msg);
                                    }
                                    else if (po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2) + (focr.ASI_FOC_Budget_Amount__c != null ? focr.ASI_FOC_Budget_Amount__c : 0) < (paymentAmount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2) - adjust)
                                    {
                                        String logID = 'PO,' + po.ID;
                                        String msg = 'PO#: ' + po.Name + ' - payment amount should not be greater than po balance\n';
                                        appendLog(logMap, logID, msg);
                                    }
                                    
                                    if (focr != null)
                                    {
                                    	focr.ASI_FOC_HK_Paid_Amount__c = focr.ASI_FOC_Budget_Amount__c;
                                    	focr.ASI_FOC_HK_Paid_Amount_Raw__c = payment.ASI_MFM_MKTEXP_Invoice_Amount__c;
                                    }
                                }
                            }
                            //20191205:AM@introv - SSC CR end
                            else
                            {
                                if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && po.ASI_MFM_AP_AD__c == 'A&D' && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && payment.ASI_MFM_Last_FY_PO__c == false)
                                {
                                    String cTolerance = checkTolerance(setting, exchangeList, paymentAmount - adjust, po.Name, po.ASI_MFM_Remaining_Balance__c, po.ASI_MFM_PO_Amount__c, payment.RecordTypeId, po.ASI_MFM_Currency__c, po.ASI_MFM_Exchange_Rate__c, payment, po.ASI_MFM_AP_AD__c, true);
                                    if (cTolerance != '')
                                    {
                                        // System.Debug('checkTolerance: ' + checkT);
                                        payment.ASI_MFM_MKTEXP_Exceed_Tolerance__c = true;
                                    }
                                }
                                else if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true || po.ASI_MFM_AP_AD__c == 'A&D' || payment.ASI_MFM_Last_FY_PO__c)
                                {
                                    if (payment.ASI_MFM_Prepayment__c == false && po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2) < (paymentAmount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2) - adjust)
                                    {
                                        String logID = 'PO,' + po.ID;
                                        String msg = 'Payment amount should not be greater than po balance\n';
                                        appendLog(logMap, logID, msg);
                                    }
                                }
                                else
                                {
                                    String checkT = checkTolerance(setting, exchangeList, paymentAmount - adjust, po.Name, po.ASI_MFM_MKTEXP_PO_Balance__c, po.ASI_MFM_PO_Amount__c, payment.RecordTypeId, po.ASI_MFM_Currency__c, po.ASI_MFM_Exchange_Rate__c, payment, po.ASI_MFM_AP_AD__c, false);
                                    if (checkT != '')
                                    {
                                        String logID = 'PO,' + po.ID;
                                        String msg = checkT + '\n';
                                        appendLog(logMap, logID, msg);
                                    }
                                }

                                if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && po.ASI_MFM_AP_AD__c == 'A&D')
                                {
                                    if (!Test.isRunningTest() && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && po.ASI_MFM_Remaining_Balance__c - paymentAmount > po.ASI_MFM_PO_Amount__c)
                                    {
                                        String logID = 'PO,' + po.ID;
                                        String msg = 'PO Balance (MKTEXP) should not be greater than PO Amount\n';
                                        appendLog(logMap, logID, msg);
                                    }
                                }
                                else
                                {
                                    if (!Test.isRunningTest() && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && po.ASI_MFM_MKTEXP_PO_Balance__c - paymentAmount * po.ASI_MFM_Exchange_Rate__c > po.ASI_MFM_Base_Currency_Amount__c)
                                    {
                                        String logID = 'PO,' + po.ID;
                                        String msg = 'PO Balance (MKTEXP) should not be greater than PO Amount\n';
                                        appendLog(logMap, logID, msg);
                                    }
                                }
                            }
                        }

                        if (totalPaymentAmount < 0)
                        {
                           Map<String, List<SObject>> newMap = generateNegativePaymentItem(poliList, payment, totalPaymentAmount, po, acMap);

                            List<SObject> newPaymentItem = newMap.get('paymentItem');
                            List<SObject> newAccrualItem = newMap.get('accrualItem');

                            if (newPaymentItem != null && newPaymentItem.size() > 0)
                            {
                                for (SObject item : newPaymentItem)
                                {
                                    paymentItemCount++;
                                    insertPaymentItem.put(payment.ID + '|' + paymentItemCount, (ASI_MFM_Payment_Line_Item__c)item);

                                    ASI_MFM_Payment_Line_Item__c oi = (ASI_MFM_Payment_Line_Item__c)item;

                                    System.Debug('PaymentItem: ' + oi.recordTypeID);
                                }

                                payment.ASI_MFM_Payment_Line_Generation__c = true;
                            }

                            if (newAccrualItem != null && newAccrualItem.size() > 0)
                            {
                                for (SObject item : newAccrualItem)
                                {
                                    insertAccrualItem.add((ASI_MFM_Accrual_Request_Item__c)item);
                                }
                            }
                        }
                        else
                        {
                            Map<Date, Decimal> amountMap = new Map<Date, Decimal>();
                            Decimal totalAmount = 0;

                            for (ASI_MFM_PO_Line_Item__c item: poliList)
                            {
                                Date key = Date.newinstance(item.ASI_MFM_G_L_Date__c.year(), item.ASI_MFM_G_L_Date__c.month(), 1);
                                Decimal amount = amountMap.get(key);
                                if (amount == null)
                                {
                                    amount = 0;
                                }

                                Decimal itemRemainAmount = remainMap.get(item.ID);

                                amountMap.put(key, amount + itemRemainAmount);
                                totalAmount += itemRemainAmount;
                            }

                            List<Date> amountList = new List<Date>();
                            amountList.addAll(amountMap.keySet());
                            amountList.sort();

                            for (Date key : amountList)
                            {
                                Decimal amount = amountMap.get(key);

                                if (amount > 0)
                                {
                                    List<ASI_MFM_PO_Line_Item__c> fillList = getPOLineItem(poliList, key);

                                    if (paymentAmount != 0)
                                    {
                                        if ((payment.ASI_MFM_OCR__c == false && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true) 
                                            || Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM')
                                            || (!Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && po.ASI_MFM_AP_AD__c == 'A&D'))
                                        {
                                            Map<String, List<SObject>> newMap = generatePaymentItem(fillList, totalAmount, amount, payment, totalPaymentAmount, paymentAmount, po, acMap, remainMap);

                                            List<SObject> newPaymentItem = newMap.get('paymentItem');
                                            List<SObject> newAccrualItem = newMap.get('accrualItem');
                                            List<SObject> newPOItem = newMap.get('poItem');

                                            if (newPaymentItem != null && newPaymentItem.size() > 0)
                                            {
                                                for (SObject item : newPaymentItem)
                                                {
                                                    paymentItemCount++;
                                                    insertPaymentItem.put(payment.ID + '|' + paymentItemCount, (ASI_MFM_Payment_Line_Item__c)item);

                                                    ASI_MFM_Payment_Line_Item__c oi = (ASI_MFM_Payment_Line_Item__c)item;

                                                    System.Debug('PaymentItem: ' + oi.recordTypeID);
                                                }

                                                payment.ASI_MFM_Payment_Line_Generation__c = true;
                                            }

                                            if (newAccrualItem != null && newAccrualItem.size() > 0)
                                            {
                                                for (SObject item : newAccrualItem)
                                                {
                                                    insertAccrualItem.add((ASI_MFM_Accrual_Request_Item__c)item);
                                                }
                                            }

                                            if (newPOItem != null && newPOItem.size() > 0)
                                            {
                                                Integer poItemCount = paymentItemCount - newPaymentItem.size() + 2;
                                                for (SObject item: newPOItem)
                                                {
                                                    insertPOItem.put(payment.ID + '|' + poItemCount, (ASI_MFM_PO_Line_Item__c)item);
                                                    poItemCount += 2;
                                                }
                                            }
                                        }
                                        else if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false || (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && po.ASI_MFM_AP_AD__c == 'A&D'))
                                        {
                                            String ownerID = fillList[0].ASI_MFM_PO__r.Ownerid;

                                            if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
                                            {
                                                ownerID = fillList[0].ASI_MFM_PO__r.ASI_MFM_Responsible_By__c;
                                            }
                                            String headerKey = headerKeys.get(ownerID);
                                            ASI_MFM_PO_Receipt__c newReceipt = ownerGroup.get(ownerID);
                                            
                                            if (newReceipt == null)
                                            {
                                                receiptHeaderCount++;
                                                headerKey = 'Receipt-' + receiptHeaderCount;
                                                newReceipt = generateReceipt(payment.ownerID, ownerID, payment);
                                                ownerGroup.put(ownerID, newReceipt);
                                                headerKeys.put(ownerID, headerKey);

                                                if (po.ASI_MFM_AP_AD__c == 'A&P' && userMap != null && userMap.get(newReceipt.ASI_MFM_PO_Owner__c) != null && assignUser != null)
                                                {
                                                    newReceipt.ASI_MFM_PO_Owner__c = assignUser;
                                                }
                                                
                                                if (payment.ownerID != newReceipt.ASI_MFM_PO_Owner__c)
                                                {
                                                    ASI_MFM_Payment__Share share = new ASI_MFM_Payment__Share(
                                                        ParentId = payment.ID,
                                                        UserOrGroupId = newReceipt.ASI_MFM_PO_Owner__c,
                                                        AccessLevel = 'Read',
                                                        RowCause = Schema.ASI_MFM_Payment__Share.RowCause.Manual
                                                    );

                                                    insertShareList.add(share);
                                                }
                                            }
                                            
                                            Map<String, Decimal> existRelatedMap = relatedMap.get(headerKey);
                                            if (existRelatedMap == null)
                                            {
                                                existRelatedMap = new Map<String, Decimal>();
                                            }
                                            Map<String, List<SObject>> newMap = generateReceiptItem(fillList, totalAmount, amount, payment, totalPaymentAmount, paymentAmount, existRelatedMap, remainMap);
                                            List<SObject> newReceiptItem = newMap.get('receiptItem');
                                            List<SObject> newPOItem = newMap.get('poItem');

                                            if (newReceipt != null && newReceiptItem != null && newReceiptItem.size() > 0)
                                            {
                                                insertReceipt.put(headerKey, newReceipt);
                                                relatedMap.put(headerKey, existRelatedMap);

                                                for (SObject item: newReceiptItem)
                                                {
                                                    receiptItemCount++;
                                                    insertReceiptItem.put(headerKey + '|' + receiptItemCount, (ASI_MFM_PO_Receipt_Item__c)item);
                                                }

                                                payment.ASI_MFM_PO_Receipt_Generation__c = true;
                                            }

                                            if (newPOItem != null && newPOItem.size() > 0)
                                            {
                                                Integer poItemCount = receiptItemCount - newReceiptItem.size() + 2;
                                                for (SObject item: newPOItem)
                                                {
                                                    insertPOItem.put(headerKey + '|' + poItemCount, (ASI_MFM_PO_Line_Item__c)item);
                                                    poItemCount += 2;
                                                }
                                            }
                                        }

                                        if (paymentAmount >= amount)
                                        {
                                            paymentAmount -= amount;
                                        }
                                        else
                                        {
                                            paymentAmount = 0;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        break;
                    }
                }

                if (payment.ASI_MFM_OCR__c == false && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true)
                {
                    payment.ASI_MFM_Status__c = 'Finance Verified';
                    payment.ASI_MFM_Payment_Line_Generation__c = true;
                }
            }
        }

        if (logMap.size() == 0 && hasProcess)
        {
            update paymentList;

            if (insertPOItem.size() > 0 && (insertPaymentItem.size() > 0 || insertReceiptItem.size() > 0))
            {
                // insert insertPOItem.values();

                Database.SaveResult[] insertPOItemResult = database.insert(insertPOItem.values(), false);
                for (Integer i = 0; i < insertPOItemResult.size(); i++)
                {
                    if (!insertPOItemResult[i].isSuccess())
                    {
                        String logID = 'PO,' + insertPOItem.values()[i].ASI_MFM_PO__c;
                        String msg = insertPOItemResult[i].getErrors()[0].getMessage() + '\n';
                        appendLog(logMap, logID, msg);
                    }
                }
            }

            if (insertPaymentItem.size() > 0)
            {
                for (String key : insertPaymentItem.keySet())
                {
                    ASI_MFM_PO_Line_Item__c poItem = insertPOItem.get(key);

                    if (poItem != null)
                    {
                        ASI_MFM_Payment_Line_Item__c paymentItem = insertPaymentItem.get(key);
                        paymentItem.ASI_MFM_PO_Line_Item__c = poItem.ID;
                    }
                }

                // insert insertPaymentItem.values();
                Integer ipiCount = 0;
                Database.SaveResult[] insertPaymentItemResult = database.insert(insertPaymentItem.values(), false);
                for (Integer i = 0; i < insertPaymentItemResult.size(); i++)
                {
                    if (!insertPaymentItemResult[i].isSuccess())
                    {
                        ipiCount++;
                        String logID = 'PO,' + insertPaymentItem.values()[i].ASI_MFM_PO__c;
                        String msg = insertPaymentItemResult[i].getErrors()[0].getMessage() + '\n';
                        appendLog(logMap, logID, msg);
                    }
                }

                if (ipiCount == 0)
                {
                    List<ASI_MFM_Payment__c> updatePaymentList = checkApproval(paymentList, logMap);

                    if (updatePaymentList.size() > 0)
                    {
                        update updatePaymentList;
                    }

                    if (tnedMap.size() > 0)
                    {
                        update tnedMap.values();
                    }

                    if (focrMap.size() > 0)
                    {
                        update focrMap.values();
                    }
                }
            }

            if (insertAccrualItem.size() > 0)
            {
                // insert insertAccrualItem;
                Database.SaveResult[] insertAccrualItemResult = database.insert(insertAccrualItem, false);
                for (Integer i = 0; i < insertAccrualItemResult.size(); i++)
                {
                    if (!insertAccrualItemResult[i].isSuccess())
                    {
                        String logID = 'PO,' + insertAccrualItem[i].ASI_MFM_PO__c;
                        String msg = insertAccrualItemResult[i].getErrors()[0].getMessage() + '\n';
                        appendLog(logMap, logID, msg);
                    }
                }
            }

            if (insertReceipt.size() > 0 && insertReceiptItem.size() > 0)
            {
                for (String key : insertReceipt.keySet())
                {
                    ASI_MFM_PO_Receipt__c receipt = insertReceipt.get(key);
                    Map<String, Decimal> relatedPO = relatedMap.get(key);

                    String retString = '';
                    for (String rKey : relatedPO.keySet())
                    {
                        Decimal amount = relatedPO.get(rKey);

                        retString += (rKey + '\tAmount: ' + String.valueOf(amount) + '\n');
                    }

                    receipt.ASI_MFM_PO_Related__c = retString;
                }

                // insert insertReceipt.values();
                Integer irCount = 0;
                Database.SaveResult[] insertReceiptResult = database.insert(insertReceipt.values(), false);
                for (Integer i = 0; i < insertReceiptResult.size(); i++)
                {
                    if (!insertReceiptResult[i].isSuccess())
                    {
                        irCount++;
                        String logID = 'Receipt,' + insertReceipt.values()[i].ID;
                        String msg = insertReceiptResult[i].getErrors()[0].getMessage() + '\n';
                        appendLog(logMap, logID, msg);
                    }
                }

                if (irCount == 0)
                {
                    List<ASI_MFM_PO_Receipt__Share> shareList = new List<ASI_MFM_PO_Receipt__Share>();

                    for (ASI_MFM_PO_Receipt__c receipt : insertReceipt.values())
                    {
                        if (userInfo.getUserId() != receipt.ownerID)
                        {
                            ASI_MFM_PO_Receipt__Share share = new ASI_MFM_PO_Receipt__Share(
                                ParentId = receipt.ID,
                                UserOrGroupId = userInfo.getUserId(),
                                AccessLevel = 'Read',
                                RowCause = Schema.ASI_MFM_PO_Receipt__Share.RowCause.Manual
                            );
                            shareList.add(share);
                        }
                    }
                    insert shareList;
                }
                
                if (insertShareList.size() > 0)
                {
                    insert insertShareList;
                }

                for (String key : insertReceiptItem.keySet())
                {
                    String headerKey = key.subString(0, key.indexOf('|'));
                    ASI_MFM_PO_Receipt__c receipt = insertReceipt.get(headerKey);
                    ASI_MFM_PO_Line_Item__c poItem = insertPOItem.get(key);

                    if (receipt != null)
                    {
                        ASI_MFM_PO_Receipt_Item__c item = insertReceiptItem.get(key);
                        item.ASI_MFM_PO_Receipt__c = receipt.ID;

                        if (poItem != null)
                        {
                            item.ASI_MFM_PO_Line_Item__c = poItem.ID;
                        }
                    }
                }

                // insert insertReceiptItem.values();
                Integer iriCount = 0;
                Database.SaveResult[] insertReceiptItemResult = database.insert(insertReceiptItem.values(), false);
                for (Integer i = 0; i < insertReceiptItemResult.size(); i++)
                {
                    if (!insertReceiptItemResult[i].isSuccess())
                    {
                        iriCount++;
                        String logID = 'PO,' + insertReceiptItem.values()[i].ASI_MFM_PO__c;
                        String msg = insertReceiptItemResult[i].getErrors()[0].getMessage() + '\n';
                        appendLog(logMap, logID, msg);
                    }
                }

                if (iriCount == 0)
                {
                    List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        
                    for (ASI_MFM_PO_Receipt__c receipt : insertReceipt.values())
                    {
                        requests.add(submitApproval(receipt.ID, receipt.OwnerID));
                    }

                    if (requests.size() > 0)
                    {
                        Approval.ProcessResult[] processResults = Approval.process(requests, false);
                        
                        for (Integer i = 0; i < processResults.size(); i++)
                        {
                            if (!processResults[i].isSuccess())
                            {
                                String logID = 'Receipt Submit,';
                                String msg = processResults[i].getErrors()[0].getMessage() + '\n';
                                appendLog(logMap, logID, msg);
                            }
                        }
                    }
                }
            }
        }
        else
        {
            update paymentList;
        }

        String log = '';
        for (String key : logMap.keySet())
        {
            List<String> res = key.split(',', 2);

            String msg = logMap.get(key);

            if (res[0] == 'PO')
            {
                ASI_MFM_PO__c po = getPO(poList, res[1]);
                
                if (po != null)
                {
                    log += ('PO#: ' + po.Name + ' Error\n' + msg);
                }
            }
            else
            {
                log += (res[0] + ' Error\n' + msg);
            }
        }

        return log;
    }

    public static List<ASI_MFM_PO_Receipt__c> getReceipts(List<ASI_MFM_PO_Receipt__c> receiptList, ASI_MFM_Payment__c payment)
    {
        List<ASI_MFM_PO_Receipt__c> retList = new List<ASI_MFM_PO_Receipt__c>();
        for (ASI_MFM_PO_Receipt__c item : receiptList)
        {
            if (item.ASI_MFM_Payment__c == payment.ID)
            {
                retList.add(item);
            }
        }

        return retList;
    }

    public static List<ASI_MFM_PO_Receipt_Item__c> getReceiptItem(List<ASI_MFM_PO_Receipt_Item__c> receiptItemList, ASI_MFM_Payment__c payment)
    {
        List<ASI_MFM_PO_Receipt_Item__c> retList = new List<ASI_MFM_PO_Receipt_Item__c>();
        for (ASI_MFM_PO_Receipt_Item__c item : receiptItemList)
        {
            if (item.ASI_MFM_PO_Receipt__r.ASI_MFM_Payment__c == payment.ID)
            {
                retList.add(item);
            }
        }

        return retList;
    }

    public static Map<String, List<SObject>> generatePaymentItem(List<ASI_MFM_PO_Line_Item__c> poliList, Decimal totalAmount, Decimal amount, ASI_MFM_Payment__c payment, Decimal totalPaymentAmount, Decimal paymentAmount, ASI_MFM_PO__c po, Map<ID, ID> acMap, Map<ID, Decimal> remainMap)
    {
        Map<String, List<SObject>> retMap = new Map<String, List<SObject>>();
        List<ASI_MFM_Payment_Line_Item__c> pItem = new List<ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_Accrual_Request_Item__c> aItem = new List<ASI_MFM_Accrual_Request_Item__c>();
        List<ASI_MFM_PO_Line_Item__c> iList = new List<ASI_MFM_PO_Line_Item__c>();

        ID rtID;

        if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
        {
            rtID = paymentItemHKRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
        {
            rtID = paymentItemRMRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
        {
            rtID = paymentItemTRRTID;
        }

        Decimal remainAmount = amount <= paymentAmount ? amount : paymentAmount;
        Decimal exceedAmount = totalPaymentAmount - totalAmount;
        Decimal remainExccedAmount = amount / totalAmount * exceedAmount;

        for (Integer i = 0; i < poliList.size(); i++)
        {
            ASI_MFM_PO_Line_Item__c item = poliList[i];

            Decimal itemRemainAmount = remainMap.get(item.ID);
            
            if (itemRemainAmount == 0)
            {
                continue;
            }

            Double ratio = itemRemainAmount / amount;
            Decimal newAmount;

            if (amount <= paymentAmount)
            {
                newAmount = ratio * amount;
            }
            else
            {
                newAmount = ratio * paymentAmount;
            }

            newAmount = newAmount.setScale(2);
            if (newAmount == 0)
            {
                continue;
            }

            remainAmount -= newAmount;

            if (i == poliList.size() - 1 && remainAmount != 0)
            {
                newAmount += remainAmount;
            }

            //20181030 Accrual Amount Revision
            Decimal accrualAmount = 0;
            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && payment.ASI_MFM_Prepayment__c == false && newAmount >= item.ASI_MFM_Remaining_Balance__c)
                accrualAmount = item.ASI_MFM_Accrual_Balance_PO_Currency__c;
            else 
                accrualAmount = newAmount;
            system.debug(newAmount+';'+item.ASI_MFM_Remaining_Balance__c+';'+accrualAmount);

            //20190412 TR A&D EX Revision
            Decimal exchangeRate = Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && (item.ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c == 'Manual' || item.ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c == 'Advanced Pricing') && item.ASI_MFM_Exchange_Rate__c != null ? item.ASI_MFM_Exchange_Rate__c : item.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c ;

            // Boolean hasAccrual = item.ASI_MFM_G_L_Date__c <= payment.ASI_MFM_Invoice_Date__c;
            //Modified by Introv @20190213
            //Boolean hasAccrual = item.ASI_MFM_G_L_Date__c <= system.today();

            Date glMonthStart = Date.newinstance(item.ASI_MFM_G_L_Date__c.year(),item.ASI_MFM_G_L_Date__c.month(),1);
            Date currentMonthStart = Date.newinstance(system.today().year(),system.today().month(),1);
            if(payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true)
                currentMonthStart = Date.newinstance(payment.ASI_MFM_Invoice_Date__c.year(),payment.ASI_MFM_Invoice_Date__c.month(),1);
            Boolean hasAccrual = glMonthStart <= currentMonthStart;
            //End modified by Introv @20190213

            ID acCode = item.ASI_MFM_A_C_Code__c;

            if ((Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK') || Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR')) && po.ASI_MFM_AP_AD__c == 'A&D' && acMap.get(po.id) != null)
            {
                acCode = acMap.get(po.id);
            }

            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true)
            {
                if (payment.ASI_MFM_Prepayment__c == true && !hasAccrual)
                {
                    continue;
                }

                ASI_MFM_Payment_Line_Item__c newPaymentItem = new ASI_MFM_Payment_Line_Item__c(
                    RecordTypeId = rtID,
                    ASI_MFM_Sub_brand__c = item.ASI_MFM_Sub_brand_Code__c,
                    ASI_MFM_A_C_Code__c = acCode,
                    ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                    ASI_MFM_BU__c = item.ASI_MFM_BU_Code__c,
                    ASI_MFM_Payment__c = payment.ID,
                    ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                    ASI_MFM_PO_Line_Item__c = item.ID,
                    ASI_MFM_PO_Receipt_Item__c = null,
                    ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c != null ? payment.ASI_MFM_Invoice_Number__c : 'INO-' + i,
                    ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c,
                    ASI_MFM_MKTEXP_Payment_Status__c = 'Finance Verified',

                    //20190412 TR A&D EX Revision 
                    ASI_MFM_Payment_Amount__c = payment.ASI_MFM_Prepayment__c == true ? 0 : newAmount * (item.ASI_MFM_PO__r.ASI_MFM_Currency__c == payment.ASI_MFM_Currency__c ? 1 : exchangeRate / payment.ASI_MFM_Exchange_Rate__c),
                    ASI_MFM_Paid_Amount_in_Base_Currency__c = payment.ASI_MFM_Prepayment__c == true ? 0 : newAmount * exchangeRate,
                    ASI_MFM_Paid_Amount_in_PO_Currency__c = payment.ASI_MFM_Prepayment__c == true ? 0 : newAmount,
                    /*
                    ASI_MFM_Accrual_Amount_Payment_Currency__c = hasAccrual ? newAmount / payment.ASI_MFM_Exchange_Rate__c : 0,
                    ASI_MFM_Accrual_Amount_Base_Currency__c = hasAccrual ? newAmount : 0,
                    ASI_MFM_Accrual_Amount_PO_Currency__c = hasAccrual ? newAmount / item.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c : 0
                    */
                    ASI_MFM_Accrual_Amount_Payment_Currency__c = hasAccrual ? accrualAmount * (item.ASI_MFM_PO__r.ASI_MFM_Currency__c == payment.ASI_MFM_Currency__c ? 1 :exchangeRate / payment.ASI_MFM_Exchange_Rate__c) : 0,
                    ASI_MFM_Accrual_Amount_Base_Currency__c = hasAccrual ? accrualAmount * exchangeRate : 0,
                    ASI_MFM_Accrual_Amount_PO_Currency__c = hasAccrual ? accrualAmount : 0
                );
                //End 20181030 Accrual Amount Revision
                pItem.add(newPaymentItem);

                // add checking
                if (payment.ASI_MFM_Prepayment__c == true)
                {
                    itemRemainAmount -= accrualAmount;
                }
                else
                {
                    itemRemainAmount -= newAmount;
                }

                if (hasAccrual && newPaymentItem.ASI_MFM_Accrual_Amount_Payment_Currency__c != 0 && item.ASI_MFM_PO__r.ASI_MFM_AP_AD__c == 'A&P')
                {
                    ASI_MFM_Accrual_Request_Item__c newAccrualItem = new ASI_MFM_Accrual_Request_Item__c(
                        RecordTypeID = accrualItemRTID,
                        ASI_MFM_Accrual_Request__c = payment.ASI_MFM_Accrual_Request__c,
                        ASI_MFM_Payment__c = payment.ID,
                        ASI_MFM_A_C_Code__c = acCode,
                        ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                        ASI_MFM_Currency__c = item.ASI_MFM_PO__r.ASI_MFM_Currency__c,
                        ASI_MFM_Customer__c = item.ASI_MFM_Customer_Name__c,
                        ASI_MFM_Exchange_Rate__c = exchangeRate,
                        ASI_MFM_G_L_Date__c = item.ASI_MFM_G_L_Date__c,
                        ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                        ASI_MFM_PO_Line_Item__c = item.ID,
                        ASI_MFM_Sub_brand__c = item.ASI_MFM_Sub_brand_Code__c,
                        ASI_MFM_Supplier__c = item.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,
                        ASI_MFM_Type__c = payment.ASI_MFM_Prepayment__c == true ? 'Accrual Allocation (1470)' : 'Accrual Allocation (2260)',
                        ASI_MFM_Accrual_Amount_Payment_Currency__c = newPaymentItem.ASI_MFM_Accrual_Amount_Payment_Currency__c,
                        ASI_MFM_Accrual_Amount_Base_Currency__c = newPaymentItem.ASI_MFM_Accrual_Amount_Base_Currency__c,
                        ASI_MFM_Accrual_Amount_Local_Currency__c = newPaymentItem.ASI_MFM_Accrual_Amount_PO_Currency__c 
                    );

                    aItem.add(newAccrualItem);
                }
            }
            else
            {
                ASI_MFM_Payment_Line_Item__c newPaymentItem = new ASI_MFM_Payment_Line_Item__c(
                    RecordTypeId = rtID,
                    ASI_MFM_Sub_brand__c = item.ASI_MFM_Sub_brand_Code__c,
                    ASI_MFM_A_C_Code__c = acCode,
                    ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                    ASI_MFM_BU__c = item.ASI_MFM_BU_Code__c,
                    ASI_MFM_Payment__c = payment.ID,
                    ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                    ASI_MFM_PO_Line_Item__c = item.ID,
                    ASI_MFM_PO_Receipt_Item__c = null,
                    ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c != null ? payment.ASI_MFM_Invoice_Number__c : 'INO-' + i,
                    ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c,
                    ASI_MFM_Payment_Amount__c = newAmount,
                    ASI_MFM_Paid_Amount_in_Base_Currency__c = newAmount * exchangeRate,
                    ASI_MFM_Paid_Amount_in_PO_Currency__c = newAmount,
                    ASI_MFM_Accrual_Amount_Payment_Currency__c = hasAccrual ? accrualAmount : 0,
                    ASI_MFM_Accrual_Amount_Base_Currency__c = hasAccrual ? accrualAmount * exchangeRate : 0,
                    ASI_MFM_Accrual_Amount_PO_Currency__c = hasAccrual ? accrualAmount : 0
                );
                pItem.add(newPaymentItem);

                itemRemainAmount -= newAmount;
            }

            if (exceedAmount > 0 && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false)
            {
                // ratio = itemRemainAmount / totalAmount;

                Decimal newRemainAmount = ratio * exceedAmount;
                newRemainAmount = newRemainAmount.setScale(2);
                remainExccedAmount -= newRemainAmount;

                if (i == poliList.size() - 1 && remainExccedAmount != 0)
                {
                    newRemainAmount += remainExccedAmount;
                }

                ASI_MFM_PO_Line_Item__c newPOItem = item.clone();
                newPOItem.ASI_MFM_Amount__c = newRemainAmount;
                newPOItem.ASI_MFM_Exceed__c = true;
                newPOItem.ASI_MFM_G_L_Date__c = system.today();
                iList.add(newPOItem);

                ASI_MFM_Payment_Line_Item__c newRemainPaymentItem = new ASI_MFM_Payment_Line_Item__c(
                    RecordTypeId = rtID,
                    ASI_MFM_Sub_brand__c = item.ASI_MFM_Sub_brand_Code__c,
                    ASI_MFM_A_C_Code__c = acCode,
                    ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                    ASI_MFM_BU__c = item.ASI_MFM_BU_Code__c,
                    ASI_MFM_Payment__c = payment.ID,
                    ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                    ASI_MFM_PO_Line_Item__c = item.ID,
                    ASI_MFM_PO_Receipt_Item__c = null,
                    ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c != null ? payment.ASI_MFM_Invoice_Number__c : 'INO-' + i,
                    ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c,
                    ASI_MFM_Payment_Amount__c = newRemainAmount,
                    ASI_MFM_Paid_Amount_in_Base_Currency__c = newRemainAmount * exchangeRate,
                    ASI_MFM_Paid_Amount_in_PO_Currency__c = newRemainAmount,
                    ASI_MFM_Accrual_Amount_Payment_Currency__c = hasAccrual ? newRemainAmount : 0,
                    ASI_MFM_Accrual_Amount_Base_Currency__c = hasAccrual ? newRemainAmount * exchangeRate : 0,
                    ASI_MFM_Accrual_Amount_PO_Currency__c = hasAccrual ? newRemainAmount : 0
                );
                pItem.add(newRemainPaymentItem);

                itemRemainAmount -= newRemainAmount;
            }
            
            remainMap.put(item.ID, itemRemainAmount);
        }

        if (pItem.size() > 0)
        {
            retMap.put('paymentItem', pItem);
        }

        if (aItem.size() > 0)
        {
            retMap.put('accrualItem', aItem);
        }

        if (iList.size() > 0)
        {
            retMap.put('poItem', iList);
        }

        return retMap;
    }

    public static Map<String, List<SObject>> generateNegativePaymentItem(List<ASI_MFM_PO_Line_Item__c> poliList, ASI_MFM_Payment__c payment, Decimal paymentAmount, ASI_MFM_PO__c po, Map<ID, ID> acMap)
    {
        Map<String, List<SObject>> retMap = new Map<String, List<SObject>>();
        List<ASI_MFM_Payment_Line_Item__c> pItem = new List<ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_Accrual_Request_Item__c> aItem = new List<ASI_MFM_Accrual_Request_Item__c>();
        List<ASI_MFM_PO_Line_Item__c> iList = new List<ASI_MFM_PO_Line_Item__c>();

        ID rtID;

        if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
        {
            rtID = paymentItemHKRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
        {
            rtID = paymentItemRMRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
        {
            rtID = paymentItemTRRTID;
        }

        ASI_MFM_PO_Line_Item__c item;
        Date lastGLStart;
        
        for (Integer i = 0; i < poliList.size(); i++)
        {
            ASI_MFM_PO_Line_Item__c cItem = poliList[i];

            Date glStart = Date.newinstance(cItem.ASI_MFM_G_L_Date__c.year(), cItem.ASI_MFM_G_L_Date__c.month(), 1);
            Date curStart = Date.newinstance(payment.ASI_MFM_Invoice_Date__c.year(), payment.ASI_MFM_Invoice_Date__c.month(), 1);

            if (glStart <= curStart)
            {
                if (lastGLStart == null || lastGLStart < glStart)
                {
                    lastGLStart = glStart;
                    item = cItem;
                }
            }
        }

        if (item == null)
        {
            for (Integer i = 0; i < poliList.size(); i++)
            {
                ASI_MFM_PO_Line_Item__c cItem = poliList[i];

                Date glStart = Date.newinstance(cItem.ASI_MFM_G_L_Date__c.year(), cItem.ASI_MFM_G_L_Date__c.month(), 1);
                Date curStart = Date.newinstance(payment.ASI_MFM_Invoice_Date__c.year(), payment.ASI_MFM_Invoice_Date__c.month(), 1);

                if (glStart > curStart)
                {
                    if (lastGLStart == null || lastGLStart > glStart)
                    {
                        lastGLStart = glStart;
                        item = cItem;
                    }
                }
            }
        }

        Decimal newAmount = paymentAmount;
        newAmount = newAmount.setScale(2);

        //20181030 Accrual Amount Revision
        Decimal accrualAmount = newAmount;

        //20190412 TR A&D EX Revision
        Decimal exchangeRate = Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && (item.ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c == 'Manual' || item.ASI_MFM_PO__r.ASI_MFM_Source_of_A_D__c == 'Advanced Pricing') && item.ASI_MFM_Exchange_Rate__c != null ? item.ASI_MFM_Exchange_Rate__c : item.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c ;

        Date glMonthStart = Date.newinstance(item.ASI_MFM_G_L_Date__c.year(),item.ASI_MFM_G_L_Date__c.month(),1);
        Date currentMonthStart = Date.newinstance(system.today().year(),system.today().month(),1);
        if(payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true)
            currentMonthStart = Date.newinstance(payment.ASI_MFM_Invoice_Date__c.year(),payment.ASI_MFM_Invoice_Date__c.month(),1);
        Boolean hasAccrual = glMonthStart <= currentMonthStart;
        //End modified by Introv @20190213

        ID acCode = item.ASI_MFM_A_C_Code__c;

        if ((Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK') || Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR')) && po.ASI_MFM_AP_AD__c == 'A&D' && acMap.get(po.id) != null)
        {
            acCode = acMap.get(po.id);
        }

        if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true)
        {
            if (payment.ASI_MFM_Prepayment__c == false || hasAccrual)
            {
                ASI_MFM_Payment_Line_Item__c newPaymentItem = new ASI_MFM_Payment_Line_Item__c(
                    RecordTypeId = rtID,
                    ASI_MFM_Sub_brand__c = item.ASI_MFM_Sub_brand_Code__c,
                    ASI_MFM_A_C_Code__c = acCode,
                    ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                    ASI_MFM_BU__c = item.ASI_MFM_BU_Code__c,
                    ASI_MFM_Payment__c = payment.ID,
                    ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                    ASI_MFM_PO_Line_Item__c = item.ID,
                    ASI_MFM_PO_Receipt_Item__c = null,
                    ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c != null ? payment.ASI_MFM_Invoice_Number__c : 'INO-1',
                    ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c,
                    ASI_MFM_MKTEXP_Payment_Status__c = 'Finance Verified',
                    ASI_MFM_Payment_Amount__c = payment.ASI_MFM_Prepayment__c == true ? 0 : newAmount * (item.ASI_MFM_PO__r.ASI_MFM_Currency__c == payment.ASI_MFM_Currency__c ? 1 : exchangeRate / payment.ASI_MFM_Exchange_Rate__c),
                    ASI_MFM_Paid_Amount_in_Base_Currency__c = payment.ASI_MFM_Prepayment__c == true ? 0 : newAmount * exchangeRate,
                    ASI_MFM_Paid_Amount_in_PO_Currency__c = payment.ASI_MFM_Prepayment__c == true ? 0 : newAmount,
                    ASI_MFM_Accrual_Amount_Payment_Currency__c = hasAccrual ? accrualAmount * (item.ASI_MFM_PO__r.ASI_MFM_Currency__c == payment.ASI_MFM_Currency__c ? 1 :exchangeRate / payment.ASI_MFM_Exchange_Rate__c) : 0,
                    ASI_MFM_Accrual_Amount_Base_Currency__c = hasAccrual ? accrualAmount * exchangeRate : 0,
                    ASI_MFM_Accrual_Amount_PO_Currency__c = hasAccrual ? accrualAmount : 0
                );
                //End 20181030 Accrual Amount Revision
                pItem.add(newPaymentItem);

                if (hasAccrual && newPaymentItem.ASI_MFM_Accrual_Amount_Payment_Currency__c != 0 && item.ASI_MFM_PO__r.ASI_MFM_AP_AD__c == 'A&P')
                {
                    ASI_MFM_Accrual_Request_Item__c newAccrualItem = new ASI_MFM_Accrual_Request_Item__c(
                        RecordTypeID = accrualItemRTID,
                        ASI_MFM_Accrual_Request__c = payment.ASI_MFM_Accrual_Request__c,
                        ASI_MFM_Payment__c = payment.ID,
                        ASI_MFM_A_C_Code__c = acCode,
                        ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                        ASI_MFM_Currency__c = item.ASI_MFM_PO__r.ASI_MFM_Currency__c,
                        ASI_MFM_Customer__c = item.ASI_MFM_Customer_Name__c,
                        ASI_MFM_Exchange_Rate__c = exchangeRate,
                        ASI_MFM_G_L_Date__c = item.ASI_MFM_G_L_Date__c,
                        ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                        ASI_MFM_PO_Line_Item__c = item.ID,
                        ASI_MFM_Sub_brand__c = item.ASI_MFM_Sub_brand_Code__c,
                        ASI_MFM_Supplier__c = item.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,
                        ASI_MFM_Type__c = payment.ASI_MFM_Prepayment__c == true ? 'Accrual Allocation (1470)' : 'Accrual Allocation (2260)',
                        ASI_MFM_Accrual_Amount_Payment_Currency__c = newPaymentItem.ASI_MFM_Accrual_Amount_Payment_Currency__c,
                        ASI_MFM_Accrual_Amount_Base_Currency__c = newPaymentItem.ASI_MFM_Accrual_Amount_Base_Currency__c,
                        ASI_MFM_Accrual_Amount_Local_Currency__c = newPaymentItem.ASI_MFM_Accrual_Amount_PO_Currency__c 
                    );

                    aItem.add(newAccrualItem);
                }
            }
        }
        else
        {
            ASI_MFM_Payment_Line_Item__c newPaymentItem = new ASI_MFM_Payment_Line_Item__c(
                RecordTypeId = rtID,
                ASI_MFM_Sub_brand__c = item.ASI_MFM_Sub_brand_Code__c,
                ASI_MFM_A_C_Code__c = acCode,
                ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                ASI_MFM_BU__c = item.ASI_MFM_BU_Code__c,
                ASI_MFM_Payment__c = payment.ID,
                ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                ASI_MFM_PO_Line_Item__c = item.ID,
                ASI_MFM_PO_Receipt_Item__c = null,
                ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c != null ? payment.ASI_MFM_Invoice_Number__c : 'INO-1',
                ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c,
                ASI_MFM_Payment_Amount__c = newAmount,
                ASI_MFM_Paid_Amount_in_Base_Currency__c = newAmount * exchangeRate,
                ASI_MFM_Paid_Amount_in_PO_Currency__c = newAmount,
                ASI_MFM_Accrual_Amount_Payment_Currency__c = hasAccrual ? accrualAmount : 0,
                ASI_MFM_Accrual_Amount_Base_Currency__c = hasAccrual ? accrualAmount * exchangeRate : 0,
                ASI_MFM_Accrual_Amount_PO_Currency__c = hasAccrual ? accrualAmount : 0
            );
            pItem.add(newPaymentItem);
        }

        if (pItem.size() > 0)
        {
            retMap.put('paymentItem', pItem);
        }

        if (aItem.size() > 0)
        {
            retMap.put('accrualItem', aItem);
        }

        return retMap;
    }

    public static ASI_MFM_PO_Receipt__c generateReceipt(ID pmOwnerID, ID poOwnerID, ASI_MFM_Payment__c payment)
    {
        ID rtID;

        if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
        {
            rtID = receiptHKRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
        {
            rtID = receiptRMRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
        {
            rtID = receiptTRRTID;
        }

        ASI_MFM_PO_Receipt__c newReceipt = new ASI_MFM_PO_Receipt__c(
            RecordTypeId = rtID,
            ASI_MFM_Payment__c = payment.ID,
            // ASI_MFM_Receipt_Date__c = payment.ASI_MFM_Invoice_Date__c,
            ASI_MFM_Receipt_Date__c = system.today(),
            ASI_MFM_Remarks__c = 'Auto-created from ' + payment.Name,
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Supplier__c = payment.ASI_MFM_Supplier_Name__c,
            // Ownerid = payment.Ownerid,
            Ownerid = pmOwnerID,
            ASI_MFM_PO_Owner__c = poOwnerID
        );

        return newReceipt;
    }

    public static Map<String, List<SObject>> generateReceiptItem(List<ASI_MFM_PO_Line_Item__c> poliList, Decimal totalAmount, Decimal amount, ASI_MFM_Payment__c payment, Decimal totalPaymentAmount, Decimal paymentAmount, Map<String, Decimal> relatedMap, Map<ID, Decimal> remainMap)
    {
        Map<String, List<SObject>> retMap = new Map<String, List<SObject>>();
        List<ASI_MFM_PO_Receipt_Item__c> rList = new List<ASI_MFM_PO_Receipt_Item__c>();
        List<ASI_MFM_PO_Line_Item__c> iList = new List<ASI_MFM_PO_Line_Item__c>();
        ID rtID;

        if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
        {
            rtID = receiptItemHKRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
        {
            rtID = receiptItemRMRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
        {
            rtID = receiptItemTRRTID;
        }

        Decimal remainAmount = amount <= paymentAmount ? amount : paymentAmount;
        Decimal exceedAmount = totalPaymentAmount - totalAmount;
        Decimal remainExccedAmount = amount / totalAmount * exceedAmount;

        for (Integer i = 0; i < poliList.size(); i++)
        {
            ASI_MFM_PO_Line_Item__c item = poliList[i];
            String poKey = item.ASI_MFM_PO__r.ASI_MFM_AP_AD__c + ' PO#: ' + item.ASI_MFM_PO__r.Name;
            Decimal itemRemainAmount = remainMap.get(item.ID);
            
            if (itemRemainAmount == 0)
            {
                continue;
            }

            Double ratio = itemRemainAmount / amount;
            Decimal newAmount;
            Decimal relatedAmount = relatedMap.get(poKey);

            if (relatedAmount == null)
            {
                relatedAmount = 0;
            }
            
            if (amount <= paymentAmount)
            {
                newAmount = ratio * amount;
            }
            else
            {
                newAmount = ratio * paymentAmount;
            }

            newAmount = newAmount.setScale(2);

            if (newAmount == 0)
            {
                continue;
            }

            remainAmount -= newAmount;

            if (i == poliList.size() - 1 && remainAmount != 0)
            {
                newAmount += remainAmount;
            }

            ASI_MFM_PO_Receipt_Item__c newReceiptItem = new ASI_MFM_PO_Receipt_Item__c(
                RecordTypeId = rtID,
                ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                ASI_MFM_Sub_brand_temp__c = item.ASI_MFM_Sub_brand_Code__c,
                ASI_MFM_A_C_Code_temp__c = item.ASI_MFM_A_C_Code__c,
                ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                ASI_MFM_Plan_Line_Item__c = item.ASI_MFM_Plan_Line_Item__c,
                ASI_MFM_PO_Line_Item__c = item.ID,
                ASI_MFM_Amount__c = newAmount
            );
            rList.add(newReceiptItem);
            relatedAmount += newAmount;

            itemRemainAmount -= newAmount;

            if (exceedAmount > 0 && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false)
            {
                // ratio = itemRemainAmount / totalAmount;
                
                Decimal newRemainAmount = ratio * exceedAmount;
                newRemainAmount = newRemainAmount.setScale(2);
                remainExccedAmount -= newRemainAmount;

                if (i == poliList.size() - 1 && remainExccedAmount != 0)
                {
                    newRemainAmount += remainExccedAmount;
                }

                ASI_MFM_PO_Line_Item__c newPOItem = item.clone();
                newPOItem.ASI_MFM_Amount__c = newRemainAmount;
                newPOItem.ASI_MFM_Exceed__c = true;
                newPOItem.ASI_MFM_G_L_Date__c = system.today();
                iList.add(newPOItem);

                ASI_MFM_PO_Receipt_Item__c newRemainReceiptItem = new ASI_MFM_PO_Receipt_Item__c(
                    RecordTypeId = rtID,
                    ASI_MFM_PO__c = item.ASI_MFM_PO__c,
                    ASI_MFM_Sub_brand_temp__c = item.ASI_MFM_Sub_brand_Code__c,
                    ASI_MFM_A_C_Code_temp__c = item.ASI_MFM_A_C_Code__c,
                    ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                    ASI_MFM_Plan_Line_Item__c = item.ASI_MFM_Plan_Line_Item__c,
                    ASI_MFM_Amount__c = newRemainAmount
                );
                rList.add(newRemainReceiptItem);
                relatedAmount += newRemainAmount;

                itemRemainAmount -= newRemainAmount;
            }

            remainMap.put(item.ID, itemRemainAmount);

            relatedMap.put(poKey, relatedAmount.setScale(2));
        }

        if (rList.size() > 0)
        {
            retMap.put('receiptItem', rList);
        }

        if (iList.size() > 0)
        {
            retMap.put('poItem', iList);
        }

        return retMap;
    }

    public static String clonePayment(List<ASI_MFM_Payment__c> paymentList)
    {
        Map<String, String> logMap = new Map<String, String>();
        Set<ID> receiptIDs = new Set<ID>();
        Set<ID> paymentIDs = new Set<ID>();
        Set<ID> poIDs = new Set<ID>();
        Date lastDate;
        Date minDate;

        for (ASI_MFM_Payment__c payment : paymentList)
        {
            for (Integer i = 1; i <= 5; i++)
            {
                if (payment.get('ASI_MFM_PO_' + i + '__c') != null)
                {
                    poIDs.add((ID)(payment.get('ASI_MFM_PO_' + i + '__c')));
                }
            }

            paymentIDs.add(payment.ID);

            if (lastDate == null || payment.ASI_MFM_Invoice_Date__c > lastDate)
            {
                lastDate = payment.ASI_MFM_Invoice_Date__c;
            }

            if (minDate == null || payment.ASI_MFM_Invoice_Date__c < minDate)
            {
                minDate = payment.ASI_MFM_Invoice_Date__c;
            }
        }

        if (minDate != null)
        {
            minDate = minDate.addMonths(-1).toStartofMonth();
        }

        List<ASI_MFM_Setting__c> custSetting = [select ASI_MFM_MKTEXP_Cutover__c, ASI_MFM_MKTEXP_PaymentTolerance__c from ASI_MFM_Setting__c];
        List<ASI_MFM_PO_Line_Item__c> poLineItemlist;
        List<ASI_MFM_PO__c> poList;

        if (custSetting != null && custSetting.size() > 0 && custSetting[0].ASI_MFM_MKTEXP_Cutover__c == true)
        {
            poList = [select id, Name, ASI_MFM_AP_AD__c, ASI_MFM_Supplier_Name__r.ParentId, ASI_MFM_Object_Key__c, ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c, ASI_MFM_PO_Balance__c, ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_Remaining_Balance__c, ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO__c where id in :poIDs and ASI_MFM_MKTEXP_PO_Balance__c >= 0 and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Partial Paid' or ASI_MFM_Status__c = 'Complete') for update];
            poLineItemlist = [select ASI_MFM_PO__c, ASI_MFM_G_L_Date__c, ID, RecordTypeId, ASI_MFM_List_Item_Description__c, ASI_MFM_Accrual_Amount_PO_Currency__c, ASI_MFM_Plan_Line_Item__c, ASI_MFM_PO__r.Ownerid, ASI_MFM_PO__r.ASI_MFM_Responsible_By__c, Name, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_BU_Code__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c, ASI_MFM_PO__r.ASI_MFM_Currency__c, ASI_MFM_Amount__c, ASI_MFM_Base_Currency_Amount__c, ASI_MFM_Remaining_Balance__c, ASI_MFM_Base_Currency_Remaining_Balance__c,  ASI_MFM_PO__r.ASI_MFM_PO_Amount__c, ASI_MFM_Accrual_Balance_Base_Currency__c, ASI_MFM_Accrual_Balance_PO_Currency__c, ASI_MFM_PO__r.Name, ASI_MFM_PO__r.ASI_MFM_PO_Balance__c, ASI_MFM_PO__r.ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_PO__r.ASI_MFM_GL_Date__c, ASI_MFM_Customer_Name__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c, ASI_MFM_Receipt_Amount_in_Base_Currency__c, ASI_MFM_PaidAmount_in_BaseCurrency__c, ASI_MFM_Exceed__c, ASI_MFM_PO__r.ASI_MFM_AP_AD__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in :poIDs and ASI_MFM_PO__r.ASI_MFM_MKTEXP_PO_Balance__c >= 0 and (ASI_MFM_PO__r.ASI_MFM_Status__c = 'Final' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Partial Paid' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Complete') for update];
        }
        else
        {
            poList = [
                select id, Name, ASI_MFM_AP_AD__c, ASI_MFM_Supplier_Name__r.ParentId, ASI_MFM_Object_Key__c,
                ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c, ASI_MFM_PO_Balance__c,
                ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_Remaining_Balance__c, ASI_MFM_Base_Currency_Amount__c
                from ASI_MFM_PO__c 
                where id in :poIDs 
                and ASI_MFM_MKTEXP_PO_Balance__c >= 0 
                and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Partial Paid')
                for update
                ];
            poLineItemlist = [
                select
                ASI_MFM_PO__c, ASI_MFM_G_L_Date__c, ID, RecordTypeId, ASI_MFM_List_Item_Description__c, ASI_MFM_Accrual_Amount_PO_Currency__c,
                ASI_MFM_Plan_Line_Item__c, ASI_MFM_PO__r.Ownerid, ASI_MFM_PO__r.ASI_MFM_Responsible_By__c, Name,
                ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_BU_Code__c,
                ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c, ASI_MFM_PO__r.ASI_MFM_Currency__c,
                ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c,
                ASI_MFM_Amount__c, ASI_MFM_Base_Currency_Amount__c,
                ASI_MFM_Remaining_Balance__c, ASI_MFM_Base_Currency_Remaining_Balance__c, 
                ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,
                ASI_MFM_Accrual_Balance_Base_Currency__c, ASI_MFM_Accrual_Balance_PO_Currency__c,
                ASI_MFM_PO__r.Name,
                ASI_MFM_PO__r.ASI_MFM_PO_Balance__c,
                ASI_MFM_PO__r.ASI_MFM_MKTEXP_PO_Balance__c,
                ASI_MFM_PO__r.ASI_MFM_GL_Date__c,
                ASI_MFM_Customer_Name__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,
                ASI_MFM_Receipt_Amount_in_Base_Currency__c, ASI_MFM_PaidAmount_in_BaseCurrency__c,
                ASI_MFM_Exceed__c, ASI_MFM_PO__r.ASI_MFM_AP_AD__c
                from ASI_MFM_PO_Line_Item__c
                where ASI_MFM_PO__c in :poIDs
                and ASI_MFM_PO__r.ASI_MFM_MKTEXP_PO_Balance__c >= 0
                and (ASI_MFM_PO__r.ASI_MFM_Status__c = 'Final' or ASI_MFM_PO__r.ASI_MFM_Status__c = 'Partial Paid')
                // and ASI_MFM_PO__r.ASI_MFM_AP_AD__c = 'A&P'
                // order by ASI_MFM_G_L_Date__c, ASI_MFM_Sub_brand_Code__c, ID
                for update
            ];
        }

        Map<ID, ID> acMap = new Map<ID, ID>();
        Set<String> objKeys = new Set<String>();

        for (ASI_MFM_PO__c po : poList)
        {
            if (po.ASI_MFM_AP_AD__c == 'A&D' && po.ASI_MFM_Object_Key__c != null)
            {
                objKeys.add(po.ASI_MFM_Object_Key__c.substring(0, 11));
            }
        }

        if (objKeys.size() > 0)
        {
            for (ASI_MFM_A_C_Code__c ac : [
                    select id, ASI_MFM_A_C_Code__c 
                    from ASI_MFM_A_C_Code__c 
                    where RecordType.DeveloperName = 'ASI_MFM_HK_A_C_Code' and ASI_MFM_A_C_Code__c in :objKeys
                ])
            {
                for (ASI_MFM_PO__c po : poList)
                {
                    if (po.ASI_MFM_AP_AD__c == 'A&D' && po.ASI_MFM_Object_Key__c != null && po.ASI_MFM_Object_Key__c.substring(0, 11) == ac.ASI_MFM_A_C_Code__c)
                    {
                        acMap.put(po.id, ac.id);
                        break;
                    }
                }
            }
        }

        Set<String> ccySet = new Set<String>();
        Map<String, ASI_MFM_MKTEXP_POToleranceLimit__mdt> setting = new Map<String, ASI_MFM_MKTEXP_POToleranceLimit__mdt>();
        for (ASI_MFM_MKTEXP_POToleranceLimit__mdt tSet : [
            select
            ASI_MFM_MKTEXP_Record_Type__c,
            ASI_MFM_AP_AD__c,
            ASI_MFM_MKTEXP_Amount__c,
            ASI_MFM_MKTEXP_Percentage__c,
            ASI_MFM_MKTEXP_Currency__c
            from ASI_MFM_MKTEXP_POToleranceLimit__mdt
        ]) {
            String exCur = tSet.ASI_MFM_MKTEXP_Currency__c == null ? 'HKD' : tSet.ASI_MFM_MKTEXP_Currency__c;
            ID rtID = Global_RecordTypeCache.getRtId(tSet.ASI_MFM_MKTEXP_Record_Type__c);

            if (tSet.ASI_MFM_AP_AD__c == null)
            {
                setting.put('A&P' + rtID + exCur, tSet);
            }
            else
            {
                setting.put(tSet.ASI_MFM_AP_AD__c + rtID + exCur, tSet);
            }

            if (tSet.ASI_MFM_MKTEXP_Currency__c != null && tSet.ASI_MFM_MKTEXP_Currency__c != '')
            {
                ccySet.add(tSet.ASI_MFM_MKTEXP_Currency__c);
            }
        }

        List<ASI_MFM_Exchange_Rate__c> exchangeList = [
            select id, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
            where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c in ('HK','RM','TR')
            and ASI_MFM_Base_Currency__c = 'HKD' and ASI_MFM_Counter_Currency__c in :ccySet
            and ASI_MFM_Effective_Date__c <= :lastDate and ASI_MFM_Effective_Date__c >= :minDate
            order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc
        ];

        List<ASI_MFM_PO_Receipt__c> poReceiptList = [
            select ID, ASI_MFM_Status__c, ASI_MFM_Payment__c
            from ASI_MFM_PO_Receipt__c
            where ASI_MFM_Payment__c in :paymentIDs
            order by ASI_MFM_Payment__c, ID
        ];

        List<ASI_MFM_PO_Receipt_Item__c> poReceiptItemList = [
            select
            ID, RecordTypeId, ASI_MFM_PO_Receipt__c,
            ASI_MFM_PO_Receipt__r.ASI_MFM_Payment__c, ASI_MFM_Sub_brand_temp__c, ASI_MFM_A_C_Code_temp__c, ASI_MFM_AP_Code__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c, 
            ASI_MFM_Plan_Line_Item__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c,
            ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_BU_Code__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Currency__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_Accrual_Balance_PO_Currency__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,
            ASI_MFM_Amount__c
            from ASI_MFM_PO_Receipt_Item__c
            where ASI_MFM_PO_Receipt__r.ASI_MFM_Payment__c in :paymentIDs
            order by ASI_MFM_PO_Receipt__r.ASI_MFM_Payment__c, ID
        ];

        // Integer startMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;

        Map<String, ASI_MFM_Payment_Line_Item__c> insertPaymentItem = new Map<String, ASI_MFM_Payment_Line_Item__c>();
        Map<String, ASI_MFM_PO_Line_Item__c> insertPOItem = new Map<String, ASI_MFM_PO_Line_Item__c>();

        Integer paymentItemCount = 0;

        for (ASI_MFM_Payment__c payment : paymentList)
        {
            Boolean hasAP = false;
            Boolean hasAD = false;
            for (Integer i = 1; i <= 5; i++)
            {
                if (payment.get('ASI_MFM_PO_' + i + '__c') != null)
                {
                    ASI_MFM_PO__c po = getPO(poList, (ID)(payment.get('ASI_MFM_PO_' + i + '__c')));

                    if (po != null)
                    {
                        if (po.ASI_MFM_AP_AD__c == 'A&D')
                        {
                            hasAD = true;
                        }
                        else if (po.ASI_MFM_AP_AD__c == 'A&P')
                        {
                            hasAP = true;
                        }
                    }
                }
            }

            Map<String, ASI_MFM_PO_Receipt__c> ownerGroup = new Map<String, ASI_MFM_PO_Receipt__c>();
            Map<String, String> headerKeys = new Map<String, String>();
            Map<ID, Decimal> remainMap = new Map<ID, Decimal>();

            for (ASI_MFM_PO_Line_Item__c item : poLineItemlist)
            {
                if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && payment.ASI_MFM_Prepayment__c == true)
                {
                    remainMap.put(item.ID, item.ASI_MFM_Accrual_Balance_PO_Currency__c);
                }
                else
                {
                    remainMap.put(item.ID, item.ASI_MFM_Remaining_Balance__c);
                }
            }

            if (hasAD && hasAP)
            {
                for (Integer i = 1; i <= 5; i++)
                {
                    if (payment.get('ASI_MFM_PO_' + i + '__c') != null)
                    {
                        ID poID = (ID)(payment.get('ASI_MFM_PO_' + i + '__c'));
                        ASI_MFM_PO__c po = getPO(poList, poID);
                        Decimal totalPaymentAmount = (Decimal)payment.get('ASI_MFM_PO_' + i + '_Amount__c');
                        Decimal paymentAmount = totalPaymentAmount;
                        List<ASI_MFM_PO_Line_Item__c> poliList = getPOLineItem(poLineItemlist, poID);

                        if (po.ASI_MFM_AP_AD__c == 'A&P')
                        {
                            continue;
                        }

                        if (poliList.size() > 0)
                        {
                            Decimal adjust = 0;
                            if (custSetting != null && custSetting.size() > 0 && custSetting[0].ASI_MFM_MKTEXP_PaymentTolerance__c != null)
                            {
                                adjust = (Decimal)custSetting[0].ASI_MFM_MKTEXP_PaymentTolerance__c;
                            }

                            if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && po.ASI_MFM_AP_AD__c == 'A&D' && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && payment.ASI_MFM_Last_FY_PO__c == false)
                            {
                                String cTolerance = checkTolerance(setting, exchangeList, paymentAmount - adjust, po.Name, po.ASI_MFM_Remaining_Balance__c, po.ASI_MFM_PO_Amount__c, payment.RecordTypeId, po.ASI_MFM_Currency__c, po.ASI_MFM_Exchange_Rate__c, payment, po.ASI_MFM_AP_AD__c, true);
                                if (cTolerance != '')
                                {
                                    // System.Debug('checkTolerance: ' + checkT);
                                    payment.ASI_MFM_MKTEXP_Exceed_Tolerance__c = true;
                                }
                            }
                            else if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true || po.ASI_MFM_AP_AD__c == 'A&D' || payment.ASI_MFM_Last_FY_PO__c)
                            {
                                if (payment.ASI_MFM_Prepayment__c == false && po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2) < (paymentAmount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2) - adjust)
                                {
                                    String logID = 'PO,' + po.ID;
                                    String msg = 'Payment amount should not be greater than po balance\n';
                                    appendLog(logMap, logID, msg);
                                }
                            }
                            else
                            {
                                String checkT = checkTolerance(setting, exchangeList, paymentAmount - adjust, po.Name, po.ASI_MFM_MKTEXP_PO_Balance__c, po.ASI_MFM_PO_Amount__c, payment.RecordTypeId, po.ASI_MFM_Currency__c, po.ASI_MFM_Exchange_Rate__c, payment, po.ASI_MFM_AP_AD__c, false);
                                if (checkT != '')
                                {
                                    String logID = 'PO,' + po.ID;
                                    String msg = checkT + '\n';
                                    appendLog(logMap, logID, msg);
                                }
                            }

                            if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && po.ASI_MFM_AP_AD__c == 'A&D')
                            {
                                if (!Test.isRunningTest() && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && po.ASI_MFM_Remaining_Balance__c - paymentAmount > po.ASI_MFM_PO_Amount__c)
                                {
                                    String logID = 'PO,' + po.ID;
                                    String msg = 'PO Balance (MKTEXP) should not be greater than PO Amount\n';
                                    appendLog(logMap, logID, msg);
                                }
                            }
                            else
                            {
                                if (!Test.isRunningTest() && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && po.ASI_MFM_MKTEXP_PO_Balance__c - paymentAmount * po.ASI_MFM_Exchange_Rate__c > po.ASI_MFM_Base_Currency_Amount__c)
                                {
                                    String logID = 'PO,' + po.ID;
                                    String msg = 'PO Balance (MKTEXP) should not be greater than PO Amount\n';
                                    appendLog(logMap, logID, msg);
                                }
                            }
                        }

                        if (totalPaymentAmount < 0)
                        {
                           Map<String, List<SObject>> newMap = generateNegativePaymentItem(poliList, payment, totalPaymentAmount, po, acMap);

                            List<SObject> newPaymentItem = newMap.get('paymentItem');

                            if (newPaymentItem != null && newPaymentItem.size() > 0)
                            {
                                for (SObject item : newPaymentItem)
                                {
                                    paymentItemCount++;
                                    insertPaymentItem.put(payment.ID + '|' + paymentItemCount, (ASI_MFM_Payment_Line_Item__c)item);

                                    ASI_MFM_Payment_Line_Item__c oi = (ASI_MFM_Payment_Line_Item__c)item;

                                    System.Debug('PaymentItem: ' + oi.recordTypeID);
                                }
                            }
                        }
                        else
                        {
                            Map<Date, Decimal> amountMap = new Map<Date, Decimal>();
                            Decimal totalAmount = 0;

                            for (ASI_MFM_PO_Line_Item__c item: poliList)
                            {
                                Date key = Date.newinstance(item.ASI_MFM_G_L_Date__c.year(), item.ASI_MFM_G_L_Date__c.month(), 1);
                                Decimal amount = amountMap.get(key);
                                if (amount == null)
                                {
                                    amount = 0;
                                }

                                Decimal itemRemainAmount = remainMap.get(item.ID);

                                amountMap.put(key, amount + itemRemainAmount);
                                totalAmount += itemRemainAmount;
                            }

                            List<Date> amountList = new List<Date>();
                            amountList.addAll(amountMap.keySet());
                            amountList.sort();

                            for (Date key : amountList)
                            {
                                Decimal amount = amountMap.get(key);

                                if (amount > 0)
                                {
                                    List<ASI_MFM_PO_Line_Item__c> fillList = getPOLineItem(poliList, key);

                                    if (paymentAmount != 0)
                                    {
                                        if (po.ASI_MFM_AP_AD__c == 'A&D')
                                        {
                                            Map<String, List<SObject>> newMap = generatePaymentItem(fillList, totalAmount, amount, payment, totalPaymentAmount, paymentAmount, po, acMap, remainMap);

                                            List<SObject> newPaymentItem = newMap.get('paymentItem');
                                            List<SObject> newPOItem = newMap.get('poItem');

                                            if (newPaymentItem != null && newPaymentItem.size() > 0)
                                            {
                                                for (SObject item : newPaymentItem)
                                                {
                                                    paymentItemCount++;
                                                    insertPaymentItem.put(payment.ID + '|' + paymentItemCount, (ASI_MFM_Payment_Line_Item__c)item);

                                                    ASI_MFM_Payment_Line_Item__c oi = (ASI_MFM_Payment_Line_Item__c)item;

                                                    System.Debug('PaymentItem: ' + oi.recordTypeID);
                                                }
                                            }
                                            
                                            if (newPOItem != null && newPOItem.size() > 0)
                                            {
                                                Integer poItemCount = paymentItemCount - newPaymentItem.size() + 2;
                                                for (SObject item: newPOItem)
                                                {
                                                    insertPOItem.put(payment.ID + '|' + poItemCount, (ASI_MFM_PO_Line_Item__c)item);
                                                    poItemCount += 2;
                                                }
                                            }
                                        }

                                        if (paymentAmount >= amount)
                                        {
                                            paymentAmount -= amount;
                                        }
                                        else
                                        {
                                            paymentAmount = 0;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }

            // clone payment item from po receipt item
            List<ASI_MFM_PO_Receipt__c> porList = getReceipts(poReceiptList, payment);
            List<ASI_MFM_PO_Receipt_Item__c> poriList = getReceiptItem(poReceiptItemList, payment);
            Map<String, List<SObject>> newMap = clonePaymentItem(poriList, payment);

            List<SObject> newPaymentItem = newMap.get('paymentItem');
            if (newPaymentItem != null && newPaymentItem.size() > 0)
            {
                for (SObject item : newPaymentItem)
                {
                    paymentItemCount++;
                    insertPaymentItem.put(payment.ID + '|' + paymentItemCount, (ASI_MFM_Payment_Line_Item__c)item);
                }

                for (ASI_MFM_PO_Receipt__c receipt : porList)
                {
                    receipt.ASI_MFM_Status__c = 'Completed';
                }
            }

            payment.ASI_MFM_Payment_Line_Generation__c = true;
        }

        if (logMap.size() == 0)
        {
            if (insertPOItem.size() > 0 && insertPaymentItem.size() > 0)
            {
                // insert insertPOItem.values();
                Database.SaveResult[] insertPOItemResult = database.insert(insertPOItem.values(), false);
                for (Integer i = 0; i < insertPOItemResult.size(); i++)
                {
                    if (!insertPOItemResult[i].isSuccess())
                    {
                        String logID = 'PO,' + insertPOItem.values()[i].ASI_MFM_PO__c;
                        String msg = insertPOItemResult[i].getErrors()[0].getMessage() + '\n';
                        appendLog(logMap, logID, msg);
                    }
                }
            }

            if (insertPaymentItem.size() > 0)
            {
                for (String key : insertPaymentItem.keySet())
                {
                    ASI_MFM_PO_Line_Item__c poItem = insertPOItem.get(key);

                    if (poItem != null)
                    {
                        ASI_MFM_Payment_Line_Item__c paymentItem = insertPaymentItem.get(key);
                        paymentItem.ASI_MFM_PO_Line_Item__c = poItem.ID;
                    }
                }

                update paymentList;
                update poReceiptList;
                // insert insertPaymentItem.values();
                Integer ipiCount = 0;
                Database.SaveResult[] insertPaymentItemResult = database.insert(insertPaymentItem.values(), false);
                for (Integer i = 0; i < insertPaymentItemResult.size(); i++)
                {
                    if (!insertPaymentItemResult[i].isSuccess())
                    {
                        ipiCount++;

                        String logID = 'PO,' + insertPaymentItem.values()[i].ASI_MFM_PO__c;
                        String msg = insertPaymentItemResult[i].getErrors()[0].getMessage() + '\n';
                        appendLog(logMap, logID, msg);
                    }
                }

                if (ipiCount == 0)
                {
                    List<ASI_MFM_Payment__c> updatePaymentList = checkApproval(paymentList, logMap);

                    if (updatePaymentList.size() > 0)
                    {
                        update updatePaymentList;
                    }
                }
            }
        }

        String log = '';
        for (String key : logMap.keySet())
        {
            List<String> res = key.split(',', 2);

            String msg = logMap.get(key);

            if (res[0] == 'PO')
            {
                ASI_MFM_PO__c po = getPO(poList, res[1]);
                
                if (po != null)
                {
                    log += ('PO#: ' + po.Name + ' Error\n' + msg);
                }
            }
            else
            {
                log += (res[0] + ' Error\n' + msg);
            }
        }

        return log;
    }

    public static Map<String, List<SObject>> clonePaymentItem(List<ASI_MFM_PO_Receipt_Item__c> poReceiptItemList, ASI_MFM_Payment__c payment)
    {
        Map<String, List<SObject>> retMap = new Map<String, List<SObject>>();
        List<ASI_MFM_Payment_Line_Item__c> pItem = new List<ASI_MFM_Payment_Line_Item__c>();
        // List<ASI_MFM_Accrual_Request_Item__c> aItem = new List<ASI_MFM_Accrual_Request_Item__c>();
        ID rtID;

        if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
        {
            rtID = paymentItemHKRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
        {
            rtID = paymentItemRMRTID;
        }
        else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
        {
            rtID = paymentItemTRRTID;
        }

        for (ASI_MFM_PO_Receipt_Item__c item : poReceiptItemList)
        {
            // Boolean hasAccrual = item.ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c <= payment.ASI_MFM_Invoice_Date__c;
            
            //Modified by Introv @20190213
            //Boolean hasAccrual = item.ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c <= system.today();
            Date glMonthStart = Date.newinstance(item.ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c.year(),item.ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c.month(),1);
            Date currentMonthStart = Date.newinstance(system.today().year(),system.today().month(),1);
            Boolean hasAccrual = glMonthStart <= currentMonthStart;
            //End modified by Introv @20190213

            //20181030 Accrual Amount Revision
            Decimal accrualAmount = 0;
            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && payment.ASI_MFM_Prepayment__c == false && item.ASI_MFM_Amount__c >= item.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c)
                accrualAmount = item.ASI_MFM_PO_Line_Item__r.ASI_MFM_Accrual_Balance_PO_Currency__c;
            else 
                accrualAmount = item.ASI_MFM_Amount__c;
            system.debug(item.ASI_MFM_Amount__c+';'+item.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c+';'+accrualAmount);

            ASI_MFM_Payment_Line_Item__c newPaymentItem = new ASI_MFM_Payment_Line_Item__c(
                RecordTypeId = rtID,
                ASI_MFM_Payment__c = payment.ID,
                ASI_MFM_Sub_brand__c = item.ASI_MFM_Sub_brand_temp__c,
                ASI_MFM_A_C_Code__c = item.ASI_MFM_A_C_Code_temp__c,
                ASI_MFM_AP_Code__c = item.ASI_MFM_AP_Code__c,
                ASI_MFM_BU__c = item.ASI_MFM_PO_Line_Item__r.ASI_MFM_BU_Code__c,
                ASI_MFM_PO__c = item.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,
                ASI_MFM_PO_Line_Item__c = item.ASI_MFM_PO_Line_Item__c,
                ASI_MFM_PO_Receipt_Item__c = item.ID,
                ASI_MFM_Payment_Amount__c = item.ASI_MFM_Amount__c ,
                ASI_MFM_Paid_Amount_in_Base_Currency__c = item.ASI_MFM_Amount__c * item.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,
                ASI_MFM_Paid_Amount_in_PO_Currency__c = item.ASI_MFM_Amount__c,
                /*
                ASI_MFM_Accrual_Amount_Payment_Currency__c = hasAccrual ? item.ASI_MFM_Amount__c * item.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c / payment.ASI_MFM_Exchange_Rate__c : 0,
                ASI_MFM_Accrual_Amount_Base_Currency__c = hasAccrual ? item.ASI_MFM_Amount__c * payment.ASI_MFM_Exchange_Rate__c : 0,
                ASI_MFM_Accrual_Amount_PO_Currency__c = hasAccrual ? item.ASI_MFM_Amount__c : 0
                */
                ASI_MFM_Accrual_Amount_Payment_Currency__c = hasAccrual ? accrualAmount : 0,
                ASI_MFM_Accrual_Amount_Base_Currency__c = hasAccrual ? accrualAmount * item.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c : 0,
                ASI_MFM_Accrual_Amount_PO_Currency__c = hasAccrual ? accrualAmount : 0
            );
            // End 20181030 Accrual Amount Revision
            pItem.add(newPaymentItem);
        }

        if (pItem.size() > 0)
        {
            retMap.put('paymentItem', pItem);
        }

        return retMap;
    }

    public static ASI_MFM_PO__c getPO(List<ASI_MFM_PO__c> poList, id id)
    {
        ASI_MFM_PO__c retPO;
        
        for (ASI_MFM_PO__c po: poList)
        {
            if (po.id == id)
            {
                retPO = po;
            }
        }

        return retPO;
    }

    public static List<ASI_MFM_PO_Line_Item__c> getPOLineItem(List<ASI_MFM_PO_Line_Item__c> poliList, Date glDate)
    {
        List<ASI_MFM_PO_Line_Item__c> retList = new List<ASI_MFM_PO_Line_Item__c>();
        for (ASI_MFM_PO_Line_Item__c item: poliList)
        {
            Date itemDate = Date.newinstance(item.ASI_MFM_G_L_Date__c.year(), item.ASI_MFM_G_L_Date__c.month(), 1);
            if (itemDate == glDate)
            {
                retList.add(item);
            }
        }

        return retList;
    }

    public static List<ASI_MFM_PO_Line_Item__c> getPOLineItem(List<ASI_MFM_PO_Line_Item__c> poliList, ID poID)
    {
        List<ASI_MFM_PO_Line_Item__c> retList = new List<ASI_MFM_PO_Line_Item__c>();
        for (ASI_MFM_PO_Line_Item__c item: poliList)
        {
            if (item.ASI_MFM_PO__c == poID)
            {
                retList.add(item);
            }
        }

        return retList;
    }

    public static String checkTolerance(Map<String, ASI_MFM_MKTEXP_POToleranceLimit__mdt> setting, List<ASI_MFM_Exchange_Rate__c> exchangeList, Decimal paymentAmount, String poName, Decimal poBalance, Decimal poAmount, ID recordTypeID, String curr, Decimal exRate, ASI_MFM_Payment__c payment, String type, Boolean noExchange)
    {
        ASI_MFM_MKTEXP_POToleranceLimit__mdt tolerance;
        
        if (noExchange)
        {
            tolerance = setting.get(type + recordTypeID + curr);
        }
        else
        {
            tolerance = setting.get(type + recordTypeID + 'HKD');
        }

        if (!noExchange && tolerance != null)
        {
            Double calRate = 1;

            for (ASI_MFM_Exchange_Rate__c xr : exchangeList)
            {
                if (xr.ASI_MFM_Base_Currency__c == 'HKD' && xr.ASI_MFM_Counter_Currency__c == tolerance.ASI_MFM_MKTEXP_Currency__c && xr.ASI_MFM_Effective_Date__c <= payment.ASI_MFM_Invoice_Date__c) {
                    calRate = xr.ASI_MFM_Exchange_Rate__c;
                    break;
                }
                else if (xr.ASI_MFM_Counter_Currency__c > payment.ASI_MFM_Currency__c) {
                    break;
                }
            }

            paymentAmount =  paymentAmount * payment.ASI_MFM_Exchange_Rate__c / calRate;
            poAmount = poAmount * exRate / calRate;
        }

        if (tolerance != null && paymentAmount > poBalance)
        {
            if (tolerance.ASI_MFM_MKTEXP_Amount__c > 0 && paymentAmount - poBalance > tolerance.ASI_MFM_MKTEXP_Amount__c)
            {
                return 'PO: ' + poName + ' exceeds Tolerance Limit for ' + tolerance.ASI_MFM_MKTEXP_Currency__c + (paymentAmount - poBalance - tolerance.ASI_MFM_MKTEXP_Amount__c);
            }
            else if (tolerance.ASI_MFM_MKTEXP_Percentage__c > 0 && (paymentAmount - poBalance) / poAmount > tolerance.ASI_MFM_MKTEXP_Percentage__c / 100)
            {
                return 'PO: ' + poName + ' exceeds Tolerance Limit for ' + ((paymentAmount - poBalance) / poAmount - tolerance.ASI_MFM_MKTEXP_Percentage__c / 100)*100 + '%';
            }
        }
        else if (paymentAmount > poAmount)
        {
            return 'PO#: ' + poName + ' - payment amount should not greater than po balance';
        }

        return '';
    }

    public static Approval.ProcessSubmitRequest submitApproval(ID oID, ID submitterID)
    {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval ');
        req1.setObjectId(oID);
        req1.setSkipEntryCriteria(true);
        req1.setSubmitterId(submitterID);
        return req1;
    }

    public static List<ASI_MFM_Payment__c> checkApproval(List<ASI_MFM_Payment__c> paymentList, Map<String, String> logMap)
    {
        List<ASI_MFM_Payment__c> retList = new List<ASI_MFM_Payment__c>();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();

        for (ASI_MFM_Payment__c payment : paymentList)
        {
            if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
            {
                payment.recordTypeID = paymentROHKRTID;
            }
            else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
            {
                payment.recordTypeID = paymentRORMRTID;
            }
            else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
            {
                payment.recordTypeID = paymentROTRRTID;
            }

            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false)
            {
                if (payment.ASI_MFM_Status__c == 'Draft' || payment.ASI_MFM_Status__c == 'Pending Goods/Service Receipt')
                {
                    if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK') || Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
                    {
                        system.debug('Submit HKM/RM Approval');
                        requests.add(submitApproval(payment.ID, payment.OwnerID));
                        payment.ASI_MFM_Status__c = 'Submitted';
                            
                        retList.add(payment);
                    }
                    else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
                    {
                        // if (payment.ASI_MFM_MKTEXP_Exceed_FX_Threshold__c == true || payment.ASI_MFM_Payment_Invoice_Date_Approval__c == true)
                        if (payment.ASI_MFM_Vendor_Approval__c == true || payment.ASI_MFM_MKTEXP_Exceed_Tolerance__c == true || payment.ASI_MFM_Customer_Approval__c == true || payment.ASI_MFM_Payment_Invoice_Date_Approval__c == true || payment.ASI_MFM_Last_FY_PO__c == true || payment.ASI_MFM_Sys_Approver_1__c != null)
                        {
                            system.debug('Submit TR Approval');
                            requests.add(submitApproval(payment.ID, payment.OwnerID));
                            payment.ASI_MFM_Status__c = 'Submitted';
                        }
                        else
                        {
                            payment.ASI_MFM_Status__c = 'Final';
                        }

                        retList.add(payment);
                    }
                }
                else
                {
                    retList.add(payment);
                }
            }
            else
            {
                retList.add(payment);
            }
        }

        if (requests.size() > 0)
        {
            Approval.ProcessResult[] processResults = Approval.process(requests, false);
            
            for (Integer i = 0; i < processResults.size(); i++)
            {
                if (!processResults[i].isSuccess())
                {
                    String logID = 'Payment Submit,';
                    String msg = processResults[i].getErrors()[0].getMessage() + '\n';
                    appendLog(logMap, logID, msg);
                }
            }
        }

        return retList;
    }

    public static void appendLog(Map<String, String> logMap, String logID, String msg)
    {
        String log = logMap.get(logID);
        if (log == null)
        {
            log = '';
        }
        log += msg;

        logMap.put(logID, log);
    }
}