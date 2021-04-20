public without sharing class ASI_MFM_MKTEXP_Payment_TriggerClass {
    public static ID paymentHKRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_HK_Payment');
    public static ID paymentRMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_RM_Payment');
    public static ID paymentTRRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MKTEXP_TR_Payment');
    public static Set<ID> tnedHKRTID = new Set<ID> {
        Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_TnE_HK_Claim_Detail')
    };
    public static Set<ID> focHKRTID = new Set<ID> {
        Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Approval'),
        Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales_Admin'),
        Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales')
    };
    public static Set<ID> batchIDs = new Set<ID>();

    public static void routineBeforeDelete(list<ASI_MFM_Payment__c> trigger_old) {
        Set<ID> ids = new Set<ID>();
        Set<String> tnedSet = new Set<String>();
        Set<String> focrSet = new Set<String>();
        for (ASI_MFM_Payment__c pa : trigger_old){
            if (pa.ASI_MFM_Status__c == 'Final' || pa.ASI_MFM_Status__c == 'Complete'){
                 pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
            }

            ids.add(pa.ID);

            if (pa.ASI_MFM_T_E_Detail_External_ID__c != null)
            {
                tnedSet.add(pa.ASI_MFM_T_E_Detail_External_ID__c);
            }

            if (pa.ASI_MFM_FOC_Detail_External_ID__c != null)
            {
                focrSet.add(pa.ASI_MFM_FOC_Detail_External_ID__c);
            }
        }

        if (ids.size() > 0)
        {
            List<ASI_MFM_PO_Receipt__c> deleteReceipts = [
                select ID
                from ASI_MFM_PO_Receipt__c
                where ASI_MFM_Payment__c in :ids
            ];

            if (deleteReceipts.size() > 0)
            {
                delete deleteReceipts;
            }
        }

        if (tnedSet.size() > 0)
        {
            List<ASI_TnE_ClaimDetail__c> tnedList = [
                select ID, ASI_TnE_HK_Paid_Amount__c, ASI_TnE_HK_Paid_Amount_Raw__c
                from ASI_TnE_ClaimDetail__c
                where RecordTypeId in :tnedHKRTID
                and ASI_TnE_KR_Detail_External_ID__c in :tnedSet
            ];
            for (ASI_TnE_ClaimDetail__c tned : tnedList)
            {
                tned.ASI_TnE_HK_Paid_Amount__c = 0;
                tned.ASI_TnE_HK_Paid_Amount_Raw__c = 0;
            }

            update tnedList;
        }

        if (focrSet.size() > 0)
        {
            List<ASI_FOC_Free_Goods_Request__c> focrList = [
                select ID, ASI_FOC_HK_Paid_Amount__c, ASI_FOC_HK_Paid_Amount_Raw__c
                from ASI_FOC_Free_Goods_Request__c
                where RecordTypeId in :focHKRTID
                and Name in :focrSet
            ];
            for (ASI_FOC_Free_Goods_Request__c focr : focrList)
            {
                focr.ASI_FOC_HK_Paid_Amount__c = 0;
                focr.ASI_FOC_HK_Paid_Amount_Raw__c = 0;
            }

            update focrList;
        }
    }

    public static void routineAfterDelete(list<ASI_MFM_Payment__c> trigger_old) {
        
    }

    public static void routineBeforeInsert(list<ASI_MFM_Payment__c> trigger_new) {
        System.debug('Start Payment routineBeforeInsert');
        set<id> px_set = new set<id>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
        }
        
        // Set the Payment ID for new Payment               
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c,ASI_MFM_Company__c from asi_mfm_prefix__c 
            where asi_mfm_module__c = 'Payment' and id in :px_set for update]);
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                if (px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c >= 10000)
                {
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c);
                }
                else
                {
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                }
                
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }

            /*mark ng 2020-04-09
            if (p.ASI_MFM_Status__c == 'Draft' && p.ASI_MFM_OCR__c == true)
            {
                p.ASI_MFM_Status__c = 'Pending Goods/Service Receipt';
            }
            */
        }
        ASI_MFM_Function.updatePrefix(px_map.values());  
    }

    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {   
        System.debug('Start Payment routineAfterUpdate');        
        Set<Id> setChangeStatusPaymentID = new Set<Id>();
        Map<Id, ASI_MFM_Payment__c> newPaymentMap = new Map<Id, ASI_MFM_Payment__c> ();
        List<ASI_MFM_Payment_Line_Item__c> listPaymentLine;
        List<ASI_MFM_PO__c> listPo= new List<ASI_MFM_PO__c>();
        
        for (ASI_MFM_Payment__c pa : trigger_new) {
            if (pa.ASI_MFM_Status__c != 'Rejected' && 
                (pa.ASI_MFM_Status__c != trigger_oldMap.get(pa.id).ASI_MFM_Status__c
                || pa.ASI_MFM_Invoice_Date__c != trigger_oldMap.get(pa.id).ASI_MFM_Invoice_Date__c
                || pa.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(pa.id).ASI_MFM_Invoice_Number__c))
            {
                setChangeStatusPaymentID.add(pa.id);
                newPaymentMap.put(pa.id, pa);
            }
            
            if (pa.ASI_MFM_Status__c == 'Rejected'){
                
                for (Integer i = 1; i <= 5; i++){
                    ID poID = (ID)(pa.get('ASI_MFM_PO_' + i + '__c'));
                    if (poID != null)
                    {
                        ASI_MFM_PO__c po=new ASI_MFM_PO__c();
                        po.id=poID;
                        po.asi_mfm_status__c='Final';
                        listPo.add(po);
                    }
                }
            }
        }
        
        if (System.IsBatch() == false && System.isFuture() == false)
        {
            Set<ID> qIDs = new Set<ID>();
            Set<ID> accrualIDs = new Set<ID>();

            for (ASI_MFM_Payment__c p : trigger_new)
            {
                ASI_MFM_Payment__c o = trigger_oldMap != null ? trigger_oldMap.get(p.ID) : null;
                if (p.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && p.ASI_MFM_PO_Receipt_Generation__c == false
                    && o != null && o.ASI_MFM_Status__c != 'Pending Goods/Service Receipt' && p.ASI_MFM_Status__c == 'Pending Goods/Service Receipt'
                    && !batchIDs.contains(p.ID))
                {
                    qIDs.add(p.ID);
                    batchIDs.add(p.ID);
                }

                if (p.ASI_MFM_Payment_Line_Generation__c == true && o != null && o.ASI_MFM_Payment_Line_Generation__c == false)
                {
                    accrualIDs.add(p.ASI_MFM_Accrual_Request__c);
                }
            }

            if (qIDs.size() > 0)
            {
                ASI_MFM_MKTEXP_Payment_Queue.add(qIDs);
            }

            // trigger to process snapshot
            if (accrualIDs.size() > 0)
            {
                List<ASI_MFM_Payment__c> checkPaymentList = [
                    select
                    ID, ASI_MFM_Accrual_Request__c, ASI_MFM_Payment_Line_Generation__c
                    from ASI_MFM_Payment__c
                    where ASI_MFM_Accrual_Request__c in :accrualIDs
                    order by ASI_MFM_Accrual_Request__c, ID
                ];

                Map<ID, Integer> totalMap = new Map<ID, Integer>();
                Map<ID, Integer> finishMap = new Map<ID, Integer>();

                for (ASI_MFM_Payment__c p : checkPaymentList)
                {
                    Integer total = totalMap.get(p.ASI_MFM_Accrual_Request__c);
                    Integer finished = finishMap.get(p.ASI_MFM_Accrual_Request__c);

                    if (total == null)
                    {
                        total = 0;
                    }

                    if (finished == null)
                    {
                        finished = 0;
                    }

                    totalMap.put(p.ASI_MFM_Accrual_Request__c, total + 1);

                    if (p.ASI_MFM_Payment_Line_Generation__c == true)
                    {
                        finishMap.put(p.ASI_MFM_Accrual_Request__c, finished + 1);
                    }
                }

                Set<ID> updateAccrualIDs = new Set<ID>();
                for (ID id : accrualIDs)
                {
                    Integer total = totalMap.get(id);
                    Integer finished = finishMap.get(id);

                    if (total == finished)
                    {
                        updateAccrualIDs.add(id);
                    }
                }

                if (updateAccrualIDs.size() > 0)
                {
                    List<ASI_MFM_Accrual_Request__c> accrualList = [
                        select 
                        ID, ASI_MFM_Status__c
                        from ASI_MFM_Accrual_Request__c
                        where 
                        ID in :updateAccrualIDs
                        and ASI_MFM_Status__c = 'ETL Create Payment Completed'
                        order by ID
                    ];

                    if (accrualList.size() > 0)
                    {
                        Set<ID> ssIDs = new Set<ID>();
                        for (ASI_MFM_Accrual_Request__c ar: accrualList)
                        {
                            ar.ASI_MFM_Status__c = 'Snapshot Work In Progress';
                            ssIDs.add(ar.ID);
                        }

                        update accrualList;

                        ASI_MFM_MKTEXP_AccrualRequest_Batch obj = new ASI_MFM_MKTEXP_AccrualRequest_Batch(ssIDs);
                DataBase.executeBatch(obj, 20);
                    }
                }
            }
        }
        
        if(setChangeStatusPaymentID != null && setChangeStatusPaymentID.size() > 0) {
            listPaymentLine = [SELECT id, ASI_MFM_Payment__c, ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c, ASI_MFM_MKTEXP_Payment_Status__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c IN :setChangeStatusPaymentID];
            for (ASI_MFM_Payment_Line_Item__c pl : listPaymentLine) 
            {
                ASI_MFM_Payment__c payment = newPaymentMap.get(pl.ASI_MFM_Payment__c);

                if (payment != null)
                {
                    pl.ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c;
                    pl.ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c;
                    pl.ASI_MFM_MKTEXP_Payment_Status__c = payment.ASI_MFM_Status__c;
                    pl.ASI_MFM_G_L_Date__c = payment.ASI_MFM_G_L_Date__c;
                }
            }
        }
        
        if(listPaymentLine != null && listPaymentLine.size() > 0)
            upsert listPaymentLine;

        List<ASI_MFM_Payment_Line_Item__c> deletePaymentItems = new List<ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_PO_Receipt__c> deleteReceipts = new List<ASI_MFM_PO_Receipt__c>();
        List<ASI_MFM_PO_Line_Item__c> deletePOItems = new List<ASI_MFM_PO_Line_Item__c>();

        Set<ID> pIDs = new Set<ID>();
        Set<ID> poiIDs = new Set<ID>();
        Set<String> tnedSet = new Set<String>();
        Set<String> focrSet = new Set<String>();

        for (ASI_MFM_Payment__c p : trigger_new)
        {
            if (p.ASI_MFM_Status__c == 'Rejected')
            {
                ASI_MFM_Payment__c op = trigger_oldMap.get(p.ID);

                if (op.ASI_MFM_Status__c != 'Rejected')
                {
                    pIDs.add(p.ID);
                }

                if (p.ASI_MFM_T_E_Detail_External_ID__c != null)
                {
                    tnedSet.add(p.ASI_MFM_T_E_Detail_External_ID__c);
                }

                if (p.ASI_MFM_FOC_Detail_External_ID__c != null)
                {
                    focrSet.add(p.ASI_MFM_FOC_Detail_External_ID__c);
                }
            }
        }

        if (pIDs.size() > 0)
        {
            for (ASI_MFM_Payment_Line_Item__c item : [
                select ID, ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__c
                from ASI_MFM_Payment_Line_Item__c
                where ASI_MFM_Payment__c in :pIDs
            ])
            {
                deletePaymentItems.add(item);
                if (!poiIDs.contains(item.ASI_MFM_PO_Line_Item__c))
                {
                    poiIDs.add(item.ASI_MFM_PO_Line_Item__c);
                }
            }

            for (ASI_MFM_PO_Receipt__c receipt : [
                select ID, ASI_MFM_Payment__c
                from ASI_MFM_PO_Receipt__c
                where ASI_MFM_Payment__c in :pIDs
            ])
            {
                deleteReceipts.add(receipt);
            }

            for (ASI_MFM_PO_Line_Item__c item : [
                select ID, ASI_MFM_PO__c
                from ASI_MFM_PO_Line_Item__c
                where ID in :poiIDs
                and ASI_MFM_Exceed__c = true
            ])
            {
                deletePOItems.add(item);
            }
        }

        if (deletePaymentItems.size() > 0)
        {
            delete deletePaymentItems;
        }

        if (deleteReceipts.size() > 0)
        {
            delete deleteReceipts;
        }

        if (deletePOItems.size() > 0)
        {
            delete deletePOItems;
        }

        if (tnedSet.size() > 0)
        {
            List<ASI_TnE_ClaimDetail__c> tnedList = [
                select ID, ASI_TnE_HK_Paid_Amount__c, ASI_TnE_HK_Paid_Amount_Raw__c
                from ASI_TnE_ClaimDetail__c
                where RecordTypeId in :tnedHKRTID
                and ASI_TnE_KR_Detail_External_ID__c in :tnedSet
            ];
            for (ASI_TnE_ClaimDetail__c tned : tnedList)
            {
                tned.ASI_TnE_HK_Paid_Amount__c = 0;
                tned.ASI_TnE_HK_Paid_Amount_Raw__c = 0;
            }

            update tnedList;
        }

        if (focrSet.size() > 0)
        {
            List<ASI_FOC_Free_Goods_Request__c> focrList = [
                select ID, ASI_FOC_HK_Paid_Amount__c, ASI_FOC_HK_Paid_Amount_Raw__c
                from ASI_FOC_Free_Goods_Request__c
                where RecordTypeId in :focHKRTID
                and Name in :focrSet
            ];
            for (ASI_FOC_Free_Goods_Request__c focr : focrList)
            {
                focr.ASI_FOC_HK_Paid_Amount__c = 0;
                focr.ASI_FOC_HK_Paid_Amount_Raw__c = 0;
            }

            update focrList;
        }
        
        if(listPo.size()>0)
            update listPo;
    }

    public static void routineAfterUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {   
        System.debug('Start Payment routineAfterUpsert');        
        
        if (System.IsBatch() == false && System.isFuture() == false)
        {
            Set<ID> qIDs = new Set<ID>();
            
            for (ASI_MFM_Payment__c p : trigger_new)
            {
                ASI_MFM_Payment__c o = trigger_oldMap != null ? trigger_oldMap.get(p.ID) : null;
                if (p.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && p.ASI_MFM_PO_Receipt_Generation__c == false
                    && ((o != null && o.ASI_MFM_Status__c != 'Pending Goods/Service Receipt' && p.ASI_MFM_Status__c == 'Pending Goods/Service Receipt') || (o == null && p.ASI_MFM_Status__c == 'Pending Goods/Service Receipt'))
                    && !batchIDs.contains(p.ID))
                {
                    qIDs.add(p.ID);
                    batchIDs.add(p.ID);
                }
            }

            if (qIDs.size() > 0)
            {
                ASI_MFM_MKTEXP_Payment_Queue.add(qIDs);
            }
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        System.debug('Start Payment routineBeforeUpdate');
        
        // Stop Any users from setting status Complete to final
        User prof = [select id, Name, Profile.name, Profile.id, UserRole.developername from User where Id = :UserInfo.getUserId() ];
        boolean isuserAdmin = prof.profile.name.contains('Administrator') ;     
// Get rejection comment when rejected
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_Payment__c> reject_map = new map<id, ASI_MFM_Payment__c>();
                
        
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Status__c != trigger_oldMap.get(p.id).ASI_MFM_Status__c && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Complete' && !isuserAdmin)
                p.addError('Cannot change a Complete Payment status to Final or Draft. Please contact the System Administrator.');  
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                reject_map.put(p.id, p);
            }

            //if (p.ASI_MFM_Status__c == 'Draft')
            //{
            //    p.ASI_MFM_OCR__c = false;
            //    p.ASI_MFM_Payment_Line_Generation__c = false;
            //    p.ASI_MFM_PO_Receipt_Generation__c = false;
            //    p.ASI_MFM_Customer_Approval__c = false;
            //    p.ASI_MFM_Vendor_Approval__c = false;
            //}

            if (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Finance Verified' && p.ASI_MFM_G_L_Date__c != trigger_oldMap.get(p.id).ASI_MFM_G_L_Date__c && !isuserAdmin) {
                 p.addError('Cannot change G/L Date after Finance Verify.');  
            }

            if (p.ASI_MFM_Status__c == 'Finance Verified' && trigger_oldMap.get(p.id).ASI_MFM_Status__c != 'Finance Verified')
            {
                p.ASI_MFM_FinanceVerifiedBy__c = UserInfo.getName();

                if (p.ASI_MFM_G_L_Date__c == null)
                {
                    p.ASI_MFM_G_L_Date__c = Date.today();
                }
            }

            if (p.ASI_MFM_Status__c == 'Draft' && p.ASI_MFM_OCR__c == true)
      {
        p.ASI_MFM_Status__c = 'Pending Goods/Service Receipt';
      }
        }                
        
        if (reject_map.size() > 0) {
            list<ASI_MFM_Payment__c> reject_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_MFM_Payment__c where id in :reject_map.keySet()];
            for (ASI_MFM_Payment__c r:reject_list) {
                if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                    System.debug('Rejected Payment ProcessSteps: ' + r.processSteps + ' ProcessStep0: ' + r.processSteps[0]);
                    reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                    reject_map.get(r.id).ASI_MFM_Sys_Reject_Comments__c = r.processSteps[0].comments;
                }
            }
        }
    }
        
    public static void routineBeforeUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        System.debug('Start Payment routineBeforeUpsert');

        // Retrieve exchange rate for new payment or when the currency or payment date is changed
        set<id> pay_set = new set<id>();
        set<string> ccy_set = new set<string>(); 
        List<id> supplierID= new List<Id>();
        List<ASI_MFM_Payment__c> usPaymentList = new List<ASI_MFM_Payment__c>();
        List<ASI_MFM_Payment__c> hkDDPaymentList = new List<ASI_MFM_Payment__c>();
        List<ASI_MFM_Payment__c> fvPaymentList = new List<ASI_MFM_Payment__c>();
        Boolean hasPerm = false;
        String paymentRT;
        Set<String> tnedSet = new Set<String>();
        Set<String> focrSet = new Set<String>();

        date last_effective_date;
        Set<ID> paymentSet = new Set<ID>();
        Set<ID> payeeSet = new Set<ID>();
        Set<String> dbNoteSet = new Set<String>();
        for (ASI_MFM_Payment__c pay:trigger_new) {
            supplierID.add(pay.ASI_MFM_Supplier_Name__c);

            if ((trigger_oldMap != null && trigger_oldMap.get(pay.id).ASI_MFM_Status__c != pay.ASI_MFM_Status__c) && (pay.ASI_MFM_Status__c == 'Submitted' || pay.ASI_MFM_Status__c == 'Final' || pay.ASI_MFM_Status__c == 'Finance Verified' || pay.ASI_MFM_Status__c == 'Pending Goods/Service Receipt'))
                    pay.ASI_MFM_MKTEXP_Error__c = '';
            
            if (pay.ASI_MFM_Exchange_Rate__c == null || (trigger_oldMap != null && (pay.ASI_MFM_Currency__c != trigger_oldMap.get(pay.id).ASI_MFM_Currency__c || pay.ASI_MFM_Payment_Date__c != trigger_oldMap.get(pay.id).ASI_MFM_Payment_Date__c))) {
                pay_set.add(pay.id);
                ccy_set.add(pay.ASI_MFM_Currency__c);
                if (last_effective_date == null || pay.ASI_MFM_Payment_Date__c > last_effective_date) {
                    last_effective_date = pay.ASI_MFM_Payment_Date__c;
                }
            }

            if (pay.ASI_MFM_Status__c != 'Rejected')
            {
                usPaymentList.add(pay);

                if (pay.ASI_MFM_T_E_Detail_External_ID__c != null)
                {
                    tnedSet.add(pay.ASI_MFM_T_E_Detail_External_ID__c);
                }

                if (pay.ASI_MFM_FOC_Detail_External_ID__c != null)
                {
                    focrSet.add(pay.ASI_MFM_FOC_Detail_External_ID__c);
                }
            }
            
            if (trigger_oldMap != null && pay.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(pay.id).ASI_MFM_Status__c != pay.ASI_MFM_Status__c)
            {
                pay.ASI_MFM_OCR__c = false;
                pay.ASI_MFM_Payment_Line_Generation__c = false;
                pay.ASI_MFM_PO_Receipt_Generation__c = false;
                pay.ASI_MFM_Customer_Approval__c = false;
                pay.ASI_MFM_Vendor_Approval__c = false;
            }

            if (trigger_oldMap != null && pay.ASI_MFM_Status__c == 'Finance Verified' && (pay.ASI_MFM_Invoice_Date__c != trigger_oldMap.get(pay.ID).ASI_MFM_Invoice_Date__c
                || pay.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(pay.id).ASI_MFM_Invoice_Number__c))
            {
                fvPaymentList.add(pay);   
            }

            if (pay.ASI_MFM_Status__c == 'Draft' && !Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM') && pay.ASI_MFM_Credit_Note__c == true)
            {
                paymentSet.add(pay.ID);
                payeeSet.add(pay.ASI_MFM_AlternatePayee__c);

                if (pay.ASI_MFM_PO_1__c != null && pay.ASI_MFM_PO_1_Remark__c != null)
                {
                    dbNoteSet.add(pay.ASI_MFM_PO_1_Remark__c);
                }
                
                if (pay.ASI_MFM_PO_2__c != null && pay.ASI_MFM_PO_2_Remark__c != null)
                {
                  dbNoteSet.add(pay.ASI_MFM_PO_2_Remark__c);
                }

                if (pay.ASI_MFM_PO_3__c != null && pay.ASI_MFM_PO_3_Remark__c != null)
                {
                  dbNoteSet.add(pay.ASI_MFM_PO_3_Remark__c);
                }

                if (pay.ASI_MFM_PO_4__c != null && pay.ASI_MFM_PO_4_Remark__c != null)
                {
                    dbNoteSet.add(pay.ASI_MFM_PO_4_Remark__c);
                }

                if (pay.ASI_MFM_PO_5__c != null && pay.ASI_MFM_PO_5_Remark__c != null)
                {
                    dbNoteSet.add(pay.ASI_MFM_PO_5_Remark__c);
                }

                hkDDPaymentList.add(pay);
            }

            paymentRT = Global_RecordTypeCache.getRt(pay.recordTypeId).developerName + '%';
        }

        if (fvPaymentList.size() > 0)
        {
            List<PermissionSetAssignment> psList = [
                SELECT ID 
                FROM PermissionSetAssignment 
                where PermissionSet.Name = 'ASI_MFM_NWW_SSC_Finance_Add_on'
                and AssigneeId = :Userinfo.getUserId()
            ];

            if (psList.size() > 0)
            {
                hasPerm = true;
            }

            for (ASI_MFM_Payment__c payment : fvPaymentList)
            {
                if (!hasPerm)
                {
                    payment.addError('Finance Verified payment are not allow to change invoice date or number');
                }
            }
        }

        //Deduplicate Invoice Number + Supplier  
        List<ASI_MFM_Payment__c> paymentSameSupplier = [SELECT ID, Name, ASI_MFM_Invoice_Number__c
                                                            FROM ASI_MFM_Payment__c 
                                                            WHERE ASI_MFM_Supplier_Name__c IN: supplierID 
                                                            AND recordtype.developername LIKE 'ASI_MFM_MKTEXP%'
                                                            and ASI_MFM_Invoice_Number__c != ''
                                                            and ASI_MFM_Status__c != 'Cancelled'];
        if(paymentSameSupplier != null && paymentSameSupplier.size() > 0)  {
            for (ASI_MFM_Payment__c pay:trigger_new) {
                for(ASI_MFM_Payment__c payment : paymentSameSupplier){
                    system.debug('Deduplicate Invoice Number + Supplier:' + pay.ASI_MFM_Invoice_Number__c +';'+payment.ASI_MFM_Invoice_Number__c);

                    if(pay.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && payment.ASI_MFM_Invoice_Number__c == pay.ASI_MFM_Invoice_Number__c && payment.id != pay.id)
                        pay.adderror('Cannot have duplicate Invoice Number under the same Supplier:' + payment.Name);
                }
            }
        }

        if (payeeSet.size() > 0 && dbNoteSet.size() > 0)
        {
            List<ASI_MFM_Payment__c> ddPaymentList = [
                SELECT ID, Name, ASI_MFM_Invoice_Number__c, ASI_MFM_Supplier_Name__c,
                ASI_MFM_AlternatePayee__c, ASI_MFM_AlternatePayee__r.Name, ASI_MFM_PO_1_Remark__c, ASI_MFM_PO_2_Remark__c, 
                ASI_MFM_PO_3_Remark__c, ASI_MFM_PO_4_Remark__c, ASI_MFM_PO_5_Remark__c
                FROM ASI_MFM_Payment__c 
                WHERE ID not in :paymentSet
                AND ASI_MFM_AlternatePayee__c in :payeeSet
                AND (
                    ASI_MFM_PO_1_Remark__c in :dbNoteSet
                    or ASI_MFM_PO_2_Remark__c in :dbNoteSet
                    or ASI_MFM_PO_3_Remark__c in :dbNoteSet
                    or ASI_MFM_PO_4_Remark__c in :dbNoteSet
                    or ASI_MFM_PO_5_Remark__c in :dbNoteSet
                )
                AND recordType.DeveloperName like :paymentRT
                AND ASI_MFM_Status__c != 'Cancelled'];

            for (ASI_MFM_Payment__c payment : hkDDPaymentList)
            {
                for (ASI_MFM_Payment__c cPayment : ddPaymentList)
                {
                    if (payment.ID != cPayment.ID && payment.ASI_MFM_AlternatePayee__c == cPayment.ASI_MFM_AlternatePayee__c)
                    {
                        for (Integer i = 1; i <= 5; i++)
                        {
                            String dbNote = String.valueOf(payment.get('ASI_MFM_PO_' + i + '_Remark__c'));
                            if (dbNote != null)
                            {
                                for (Integer j = 1; j <= 5; j++)
                                {
                                    String cDBNote = String.valueOf(cPayment.get('ASI_MFM_PO_' + j + '_Remark__c'));
                                    if (cDBNote != null && dbNote == cDBNote)
                                    {
                                        payment.addError('Duplicate Debit Note number with payment#: ' + cPayment.Name
                                                         + ', Alternate Payee: ' + cPayment.ASI_MFM_AlternatePayee__r.Name
                                                         + ', Debit Note: ' + cDBNote);
                                    }
                                    else if (cDBNote == null)
                                    {
                                        break;
                                    }
                                }   
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                }
            }
        }

        string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(15, 17);
        SYSTEM.DEBUG(country);
        string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;
        list<ASI_MFM_Exchange_Rate__c> xr_list;
        
        // Conrad Pantua 20140704 Handle Capex Country (Laputa)
        if (country == 'HK')
        {
            country = 'HK';
            base_ccy = 'HKD';
        }
        
        if(country == 'RM'){
            country = 'RM';
        }
        
        if(country == 'TR'){
            country = 'TR';
        }

        if (pay_set.size() > 0) {
            xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            system.debug('a1:'+country +'/'+base_ccy + '/'+ last_effective_date+'/'+xr_list);
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay_set.contains(pay.id)) {
                    if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                        pay.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                        if(xr_list != null && xr_list.size() > 0){
                            pay.ASI_MFM_Exchange_Rate__c = null;    
                            if (pay.ASI_MFM_Currency__c != null && pay.ASI_MFM_Payment_Date__c != null ) {                                                                           
                                for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                                    system.debug(xr.ASI_MFM_Counter_Currency__c +';'+ pay.ASI_MFM_Currency__c);

                                    if (xr.ASI_MFM_Counter_Currency__c == pay.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= pay.ASI_MFM_Payment_Date__c) {
                                        pay.ASI_MFM_Exchange_Rate__c = xr.ASI_MFM_Exchange_Rate__c;
                                        break;
                                    }
                                    else if (xr.ASI_MFM_Counter_Currency__c > pay.ASI_MFM_Currency__c) {
                                        break;
                                    }
                                }
                            }
                        }
                        else {
                            pay.addError('Cannot Retrieve '+pay.ASI_MFM_Currency__c+' Exchange Rate');
                        }
                    }               
                }
            }                       
        }
            
        // The prefix must be for Payment
        // The prefix must be valid for the owner
        set<id> owner_set = new set<id>();
        set<id> prefix_set = new set<id>();
        list<ASI_MFM_Payment__c> Payment_list = new list<ASI_MFM_Payment__c>();
        
        for (ASI_MFM_Payment__c p:trigger_new) {
            owner_set.add(p.ownerId);
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                prefix_set.add(p.ASI_MFM_Prefix__c);
                Payment_list.add(p);
            }
        }
        
        Map<ID, User> owner_map = new map<id, user>([select userRole.DeveloperName, ASI_Department__c from user where id in :owner_set]);
        if (Payment_list.size() > 0) {
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'Payment']);
            
            for (ASI_MFM_Payment__c p:Payment_list) {
                system.debug('prefix_map: ' + prefix_map + ' payment prefix: ' + p.ASI_MFM_Prefix__c);
                
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c)) {
                    p.ASI_MFM_Prefix__c.addError('The prefix is not valid for Payment');
                }
                else {
                    string owner_role = owner_map.get(p.ownerId).userRole.DeveloperName;
                    boolean valid_prefix = false;               
                    for (ASI_MFM_Role_Prefix_Relationship__c pr:prefix_map.get(p.ASI_MFM_Prefix__c).ASI_MFM_Role_Prefix_Relationships__r) {
                        if (pr.ASI_MFM_Role_Name__c == owner_role) {
                            valid_prefix = true;
                            break;
                        }
                    }
                    if (!valid_prefix) {
                        p.ASI_MFM_Prefix__c.addError('The prefix is not valid for the owner');                  
                    }
                }
            }
        }


        // validation
        Set<ID> poIDs = new Set<ID>();
        Date lastDate;
        Date minDate;

        for (ASI_MFM_Payment__c payment : usPaymentList)
        {
            Integer nullCount = 0;
            Integer poCount = 0;
            Decimal totalAmount = 0;
            Set<ID> uniqueSet = new Set<ID>();
            for (Integer i = 1; i <= 5; i++)
            {
                ID poID = (ID)(payment.get('ASI_MFM_PO_' + i + '__c'));
                Decimal amount = (Decimal)payment.get('ASI_MFM_PO_' + i + '_Amount__c');

                if (poID != null)
                {
                    poCount++;
                    poIDs.add(poID);
                    
                    if (uniqueSet.contains(poID))
                    {
                        payment.addError('Not allow to input duplicate PO');
                    }

                    uniqueSet.add(poID);

                    if (amount == null || amount == 0)
                    {
                        nullCount++;
                    }
                    else
                    {
                        totalAmount += amount;
                    }
                }
            }

            if (poCount > 1 && nullCount != 0)
            {
                payment.addError('All PO must have PO amount or no PO amound');
            }
            else if (poCount == 0)
            {
                payment.addError('No PO is entered');
            }

            if (poCount == 1 && nullCount == 1)
            {
                payment.ASI_MFM_PO_1_Amount__c = payment.ASI_MFM_MKTEXP_Invoice_Amount__c;
                totalAmount += payment.ASI_MFM_MKTEXP_Invoice_Amount__c;
            }
            
            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && totalAmount.setScale(2) != payment.ASI_MFM_MKTEXP_Invoice_Amount__c.setScale(2))
            {
                payment.addError('Invoice amount not equal to allocate amount');
            }

            if (lastDate == null || payment.ASI_MFM_Invoice_Date__c > lastDate)
            {
                lastDate = payment.ASI_MFM_Invoice_Date__c;
            }

            if (minDate == null || payment.ASI_MFM_Invoice_Date__c < minDate)
            {
                minDate = payment.ASI_MFM_Invoice_Date__c;
            }
        }

        if (poIDs.size() > 0)
        {
            if (minDate != null)
            {
                minDate = minDate.addMonths(-1).toStartofMonth();
            }

            List<ASI_MFM_PO__c> poList = [
                select
                ID, Name, RecordTypeId,
                ASI_MFM_Currency__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c, ASI_MFM_PO_Balance__c,
                ASI_MFM_Supplier_Name__c, ASI_MFM_Status__c, ASI_MFM_Dummy_Vendor__c, ASI_MFM_Prefix__c,
                ASI_MFM_PO_Raised_Date__c, ASI_MFM_AP_AD__c, ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_Remaining_Balance__c, 
                ASI_MFM_Sys_Approver_1__c, ASI_MFM_Sys_Approver_2__c, ASI_MFM_Sys_Approver_3__c,
                ASI_MFM_Prefix__r.ASI_MFM_Location__c, ASI_MFM_PO_End_Date__c,
                ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, ASI_MFM_SG_Customer__c, ASI_MFM_Base_Currency_Amount__c,
                ASI_MFM_Is_FOC_PO__c,
                ASI_MFM_HK_T_E_Amount__c, ASI_MFM_HK_T_E_Paid_Amount__c, ASI_MFM_HK_FOC_Amount__c, ASI_MFM_HK_FOC_Paid_Amount__c,
                ASI_MFM_Reference_2__c                   // [SH] 2019-03-29
                from ASI_MFM_PO__c
                where ID in :poIDs
                order by ID
            ];

            List<ASI_MFM_PO_Line_Item__c> poItemList = [
                select
                ID, ASI_MFM_PO__c, ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c
                from ASI_MFM_PO_Line_Item__c
                where ASI_MFM_PO__c in :poIDs
                and ASI_MFM_PO__r.ASI_MFM_AP_AD__c = 'A&D'
                order by ID
            ];

            List<ASI_MFM_Setting__c> custSetting = [select ASI_MFM_MKTEXP_Cutover__c, ASI_MFM_MKTEXP_PaymentTolerance__c from ASI_MFM_Setting__c];
            
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

            List<ASI_MFM_HK_Department_Head__mdt> headSetting = [
                select
                ASI_MFM_HK_Department__c,
                ASI_MFM_HK_Department_Head_ID__c
                from ASI_MFM_HK_Department_Head__mdt
            ];
            Map<String, ID> headMap = new Map<String, ID>();
            for (ASI_MFM_HK_Department_Head__mdt h : headSetting)
            {
                headMap.put(h.ASI_MFM_HK_Department__c, (ID)h.ASI_MFM_HK_Department_Head_ID__c);
            }

            List<ASI_MFM_Exchange_Rate__c> exchangeList = [
                select id, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c in ('HK','RM','TR')
                and ASI_MFM_Base_Currency__c = 'HKD' and ASI_MFM_Counter_Currency__c in :ccySet
                and ASI_MFM_Effective_Date__c <= :lastDate and ASI_MFM_Effective_Date__c >= :minDate
                order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc
            ];

            //20191205:AM@introv - SSC CR start
            Map<String, ASI_TnE_ClaimDetail__c> tnedMap = new Map<String, ASI_TnE_ClaimDetail__c>();
            if (tnedSet.size() > 0)
            {
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
            }

            Map<String, ASI_FOC_Free_Goods_Request__c> focrMap = new Map<String, ASI_FOC_Free_Goods_Request__c>();
            if (focrSet.size() > 0)
            {
                for (ASI_FOC_Free_Goods_Request__c focr : [
                    select ID, Name, ASI_FOC_Budget_Amount__c, ASI_FOC_HK_Paid_Amount__c, ASI_FOC_HK_Paid_Amount_Raw__c
                    from ASI_FOC_Free_Goods_Request__c
                    where RecordTypeId in :focHKRTID
                    and Name in :focrSet
                ])
                {
                    focrMap.put(focr.Name, focr);
                }
            }
            //20191205:AM@introv - SSC CR end

            Integer startMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;

            Integer poCount = 0;
            Boolean hasMKTEXP = false;
            Boolean hasAP = false;
            Boolean hasAD = false;
            for (ASI_MFM_Payment__c payment : usPaymentList)
            {
                // [SH] 2019-03-29
                // Not allow to mix non-CAPEX PO and CAPEX PO in same payment
                integer capexPO = 0;
                for(ASI_MFM_PO__c po: poList){
                    if(po.ASI_MFM_Reference_2__c == 'CAPEX'){
                        capexPO++;
                    }
                }system.debug('SH capex: ' + capexPO); system.debug('SH polist: '+ poList.size());
                if(capexPO > 0 && capexPO != poList.size()){
                    payment.addError('Payment to settle both CAPEX PO and A&P/A&D PO is not allowed');
                }
                // END - [SH]

                if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false
                    && (payment.ASI_MFM_T_E_Detail_External_ID__c != null || payment.ASI_MFM_FOC_Detail_External_ID__c != null))
                {
                    payment.addError('Only Allocation is allowed to settle T&E or FOC');
                }
                
                String poCurrency = '';
                for (Integer i = 1; i <= 5; i++)
                {
                    ID poID = (ID)(payment.get('ASI_MFM_PO_' + i + '__c'));
                    Decimal amount = (Decimal)payment.get('ASI_MFM_PO_' + i + '_Amount__c');

                    if (poID != null)
                    {
                        poCount++;
                    }
                    
                    if (poID != null && payment.ASI_MFM_Status__c == 'Draft')
                    {
                        if (trigger_oldMap != null && (trigger_oldMap.get(payment.id).ASI_MFM_Status__c =='Final' ||trigger_oldMap.get(payment.id).ASI_MFM_Status__c =='Finance Verified' ||trigger_oldMap.get(payment.id).ASI_MFM_Status__c =='Pending Goods/Service Receipt')){
                            continue;
                        }
                        
                        ASI_MFM_PO__c po = getPO(poList, poID);

                        if (po != null)
                        {
                            // adding validation to limit foc po
                            if (po.ASI_MFM_Is_FOC_PO__c == true && (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false || payment.ASI_MFM_OCR__c == true))
                            {
                                payment.addError('OCR or Manual MFM Payment should not contain FOC PO');
                            }

                            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && payment.ASI_MFM_Currency__c != po.ASI_MFM_Currency__c)
                            {
                                payment.addError('Payment and PO should have same currency');
                            }

                            if (poCurrency != '' && poCurrency != po.ASI_MFM_Currency__c)
                            {
                                payment.addError('All PO should have same currency');
                            }

                            poCurrency = po.ASI_MFM_Currency__c;
                                                       
                            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true)
                            {
                                if (custSetting != null && custSetting.size() > 0 && custSetting[0].ASI_MFM_MKTEXP_Cutover__c == true)
                                {
                                    if (po.ASI_MFM_Status__c != 'Final' && po.ASI_MFM_Status__c != 'Partial Paid' && po.ASI_MFM_Status__c != 'Complete')
                                    {
                                        payment.addError('PO#: ' + po.Name + ' - PO status must be Final or Partial Paid or Complete');
                                    }
                                }
                                else if (po.ASI_MFM_Status__c != 'Final' && po.ASI_MFM_Status__c != 'Partial Paid')
                                {
                                    payment.addError('PO#: ' + po.Name + ' - PO status must be Final or Partial Paid2');
                                }                                
                            }
                            else if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && po.ASI_MFM_Status__c != 'Final' && po.ASI_MFM_Status__c != 'Partial Paid')
                            {
                                payment.addError('PO#: ' + po.Name + ' - PO status must be Final or Partial Paid');
                            }
                            
                            if (amount > 0 && po.ASI_MFM_MKTEXP_PO_Balance__c <= 0 && payment.ASI_MFM_Prepayment__c == false && payment.ASI_MFM_FOC_Detail_External_ID__c==null && payment.ASI_MFM_T_E_Detail_External_ID__c==null)
                            {
                                payment.addError('PO#: ' + po.Name + ' - PO Balance is ' + po.ASI_MFM_MKTEXP_PO_Balance__c);
                            }

                            if (po.ASI_MFM_AP_AD__c == 'A&P')
                            {
                                hasAP = true;
                                if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
                                {
                                    if (po.ASI_MFM_Dummy_Vendor__c == false && payment.ASI_MFM_Supplier_Name__c != po.ASI_MFM_Supplier_Name__c)
                                    {
                                        payment.addError('PO#: ' + po.Name + ' - Supplier name is not matched');
                                    }
                                    // else if (po.ASI_MFM_Dummy_Vendor__c == true && po.ASI_MFM_Supplier_Name__c != payment.ASI_MFM_Supplier_Name__c)
                                    else if (po.ASI_MFM_Dummy_Vendor__c == true)
                                    {
                                        payment.ASI_MFM_Vendor_Approval__c = true;
                                    }
                                }
                                else
                                {
                                    if (payment.ASI_MFM_Supplier_Name__c != po.ASI_MFM_Supplier_Name__c)
                                    {
                                        payment.addError('PO#: ' + po.Name + ' - Supplier name is not matched');
                                    }
                                }

                                if (payment.ASI_MFM_Invoice_Number__c == null || payment.ASI_MFM_Invoice_Date__c == null)
                                {
                                    payment.addError('Invoice number & invoice date must not be blank');
                                }
                            }
                            else if (po.ASI_MFM_AP_AD__c == 'A&D')
                            {
                                hasAD = true;
                                if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
                                {
                                    if (po.ASI_MFM_Dummy_Vendor__c == false && payment.ASI_MFM_Supplier_Name__c != po.ASI_MFM_Supplier_Name__c)
                                    {
                                        payment.addError('PO#: ' + po.Name + ' - Supplier name is not matched');
                                    }
                                    // else if (po.ASI_MFM_Dummy_Vendor__c == true && po.ASI_MFM_Supplier_Name__c != payment.ASI_MFM_Supplier_Name__c)
                                    else if (po.ASI_MFM_Dummy_Vendor__c == true)
                                    {
                                        payment.ASI_MFM_Vendor_Approval__c = true;
                                    }

                                    if (payment.ASI_MFM_Credit_Note__c == false)
                                    {
                                        if (payment.ASI_MFM_Invoice_Number__c == null || payment.ASI_MFM_Invoice_Date__c == null)
                                        {
                                            payment.addError('Invoice number & invoice date must not be blank');
                                        }
                                    }
                                    else
                                    {
                                        if (payment.ASI_MFM_Invoice_Number__c == null)
                                        {
                                            payment.ASI_MFM_Invoice_Number__c = payment.Name;
                                        }
                                    }
                                }
                                else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
                                {
                                    if (payment.ASI_MFM_Credit_Note__c == false)
                                    {
                                        if (payment.ASI_MFM_Invoice_Number__c == null || payment.ASI_MFM_Invoice_Date__c == null)
                                        {
                                            payment.addError('Invoice number & invoice date must not be blank');
                                        }
                                    }
                                    else
                                    {
                                        if (payment.ASI_MFM_Invoice_Number__c == null)
                                        {
                                            payment.ASI_MFM_Invoice_Number__c = payment.Name;
                                        }
                                    }
                                }
                                else
                                {
                                    if (payment.ASI_MFM_Supplier_Name__c != po.ASI_MFM_Supplier_Name__c)
                                    {
                                        payment.addError('PO#: ' + po.Name + ' - Supplier name is not matched');
                                    }
                                }
                            }

                            if (payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true)
                            {
                                hasMKTEXP = true;
                            }

                            if (hasMKTEXP && hasAP && hasAD)
                            {
                                payment.addError('A&P and A&D PO must not mixed while Marketing Expense process');
                            }

                            //Temp remark for A&D Walkthrough
                            //if (!Test.isRunningTest() && (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM') || Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR')) && po.ASI_MFM_AP_AD__c == 'A&D')
                            if (!Test.isRunningTest() && Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM') && po.ASI_MFM_AP_AD__c == 'A&D')
                            {
                                payment.addError('PO#: ' + po.Name + ' is not A&P PO');
                            }
                            //End Temp remark for A&D Walkthrough

                            Boolean lastFYPO = false;
                            // check fiscal year
                            Date today = System.Today();
                            Date fyStart = Date.newinstance(today.year(), startMonth, 1);
                            Integer thisYear = today.year();
                            Integer nextYear = today.year() + 1;
                            String thisYearString = String.valueOf(thisYear);
                            String nextYearString = String.valueOf(nextYear);
                            String fyString = thisYearString.substring(2) + '' + nextYearString.substring(2);
                            
                            Integer fy = Integer.valueOf(fyString);

                            if (today < fyStart)
                            {
                                thisYear = today.year() - 1;
                                nextYear = today.year();
                                thisYearString = String.valueOf(thisYear);
                                nextYearString = String.valueOf(nextYear);
                                fyString = thisYearString.substring(2) + '' + nextYearString.substring(2);
                                fy = Integer.valueOf(fyString);
                            }

                            Integer poFy = Integer.valueOf(po.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(2));
                            if (poFy < fy)
                            {
                                lastFYPO = true;
                            }

                            if (!payment.ASI_MFM_Last_FY_PO__c && lastFYPO)
                            {
                                payment.ASI_MFM_Last_FY_PO__c = true;
                            }

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
                                        payment.addError('T&E Detail not found');
                                    }
                                    else if (po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2) + (tned.ASI_TnE_Payment_Amount__c != null ? tned.ASI_TnE_Payment_Amount__c : 0) < (amount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2) - adjust)
                                    {
                                        System.Debug('amount error:  po mkt balance: ' + po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2)+',tne: '+(tned.ASI_TnE_Payment_Amount__c != null ? tned.ASI_TnE_Payment_Amount__c : 0)+', payment: '+(amount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2)+', adjust= '+adjust);
                                        payment.addError('PO#: ' + po.Name + ' - payment amount should not be greater than po balance');
                                    }
                                }
                                else if (payment.ASI_MFM_FOC_Detail_External_ID__c != null)
                                {
                                    ASI_FOC_Free_Goods_Request__c focr = focrMap.get(payment.ASI_MFM_FOC_Detail_External_ID__c);

                                    if (focr == null)
                                    {
                                        payment.addError('Free Good Request not found');
                                    }
                                    else if (po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2) + (focr.ASI_FOC_Budget_Amount__c != null ? focr.ASI_FOC_Budget_Amount__c : 0) < (amount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2) - adjust)
                                    {
                                        System.Debug('amount error:  po mkt balance: ' + po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2)+',foc: '+(focr.ASI_FOC_Budget_Amount__c != null ? focr.ASI_FOC_Budget_Amount__c : 0)+', payment: '+(amount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2)+', adjust= '+adjust);
                                        payment.addError('PO#: ' + po.Name + ' - payment amount should not be greater than po balance');
                                    }
                                }
                            }
                            //20191205:AM@introv - SSC CR end
                            else
                            {
                                if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && po.ASI_MFM_AP_AD__c == 'A&D' && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == false && payment.ASI_MFM_Last_FY_PO__c == false)
                                {
                                    // System.debug('debug: ' + (amount - adjust) + ', ' + po.Name + ', ' + po.ASI_MFM_Remaining_Balance__c + ', ' + po.ASI_MFM_PO_Amount__c + ', ' + payment.RecordTypeId + ', ' + po.ASI_MFM_Currency__c + ', ' + po.ASI_MFM_Exchange_Rate__c + ', ' + payment + ', ' + po.ASI_MFM_AP_AD__c);
                                    String checkT = checkTolerance(setting, exchangeList, amount - adjust, po.Name, po.ASI_MFM_Remaining_Balance__c, po.ASI_MFM_PO_Amount__c, payment.RecordTypeId, po.ASI_MFM_Currency__c, po.ASI_MFM_Exchange_Rate__c, payment, po.ASI_MFM_AP_AD__c, true);
                                    if (checkT != '')
                                    {
                                        System.Debug('checkTolerance: ' + checkT);
                                        payment.ASI_MFM_MKTEXP_Exceed_Tolerance__c = true;
                                    }
                                }
                                else if ((payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true || po.ASI_MFM_AP_AD__c == 'A&D' || payment.ASI_MFM_Last_FY_PO__c) && po.ASI_MFM_Reference_2__c != 'CAPEX')       // [SH] 2019-03-29 Exclude CAPEX PO Payment
                                {
                                    if (payment.ASI_MFM_Prepayment__c == false && po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2) < (amount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2) - adjust)
                                    {
                                        System.Debug('amount error:  po mkt balance: ' + po.ASI_MFM_MKTEXP_PO_Balance__c.setScale(2)+', payment: '+(amount * (payment.ASI_MFM_Currency__c == 'HKD' ? 1 : po.ASI_MFM_Exchange_Rate__c)).setScale(2)+', adjust= '+adjust);
                                        payment.addError('PO#: ' + po.Name + ' - payment amount should not be greater than po balance');
                                    }
                                }
                                else
                                {
                                    String checkT = checkTolerance(setting, exchangeList, amount - adjust, po.Name, po.ASI_MFM_MKTEXP_PO_Balance__c, po.ASI_MFM_PO_Amount__c, payment.RecordTypeId, po.ASI_MFM_Currency__c, po.ASI_MFM_Exchange_Rate__c, payment, po.ASI_MFM_AP_AD__c, false);
                                    if (checkT != '')
                                    {
                                        payment.addError(checkT);
                                    }
                                }

                                if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && po.ASI_MFM_AP_AD__c == 'A&D')
                                {
                                    if (!Test.isRunningTest() && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && po.ASI_MFM_Remaining_Balance__c - amount > po.ASI_MFM_PO_Amount__c)
                                    {
                                        System.Debug('amount error:  po.ASI_MFM_Remaining_Balance__c: ' + po.ASI_MFM_Remaining_Balance__c+', payment: '+amount +', po.ASI_MFM_PO_Amount__c= '+po.ASI_MFM_PO_Amount__c);
                                        payment.addError('PO#: ' + po.Name + ' - PO Balance (MKTEXP) should not be greater than PO Amount');
                                    }
                                }
                                else
                                {
                                    System.debug('new: ' + (po.ASI_MFM_MKTEXP_PO_Balance__c - amount * po.ASI_MFM_Exchange_Rate__c) + ', ' + po.ASI_MFM_Base_Currency_Amount__c);
                                    if (!Test.isRunningTest() && payment.ASI_MFM_Actual_MKT_Expense_Allocation__c == true && po.ASI_MFM_MKTEXP_PO_Balance__c - amount * po.ASI_MFM_Exchange_Rate__c > po.ASI_MFM_Base_Currency_Amount__c)
                                    {
                                        System.Debug('amount error:  po.ASI_MFM_MKTEXP_PO_Balance__c: ' + po.ASI_MFM_MKTEXP_PO_Balance__c+', payment: '+amount +' ,po.ASI_MFM_Exchange_Rate__c: '+po.ASI_MFM_Exchange_Rate__c+',  po.ASI_MFM_Base_Currency_Amount__c= '+ po.ASI_MFM_Base_Currency_Amount__c);          
                                        payment.addError('PO#: ' + po.Name + ' - PO Balance (MKTEXP) should not be greater than PO Amount');
                                    }
                                }   
                            }

                            payment.put('ASI_MFM_PO_Raise_Date_' + i + '__c', po.ASI_MFM_PO_Raised_Date__c);

                            if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
                            {
                                List<ASI_MFM_PO_Line_Item__c> poiList = getPOItems(poItemList, po.ID);
                                if (payment.ASI_MFM_Credit_Note__c == true)
                                {
                                    String dbNote = String.valueOf(payment.get('ASI_MFM_PO_' + i + '_Remark__c'));
                                    String jdeInvoice = String.valueOf(payment.get('ASI_MFM_PO_' + i + '_Offset_JDE_Sales_Invoice__c'));

                                    if (dbNote != null && jdeInvoice == null)
                                    {
                                        payment.addError('PO#: ' + po.Name + ' - Offset JDE Sales Invoice is required');
                                    }

                                    if (payment.ASI_MFM_AlternatePayee__c == null)
                                    {
                                        if (po.ASI_MFM_SG_Customer__c != null)
                                        {
                                            payment.ASI_MFM_AlternatePayee__c = po.ASI_MFM_SG_Customer__c;
                                        }
                                        else if (poItemList.size() > 0 && poItemList[0].ASI_MFM_Customer_Name__c != null)
                                        {
                                            payment.ASI_MFM_AlternatePayee__c = poItemList[0].ASI_MFM_Customer_Name__c;
                                        }
                                        else
                                        {
                                            payment.addError('PO#: ' + po.Name + ' - No Alternate Payee can be find in PO Header & Line');
                                        }
                                    }

                                    if (poiList.size() > 0)
                                    {
                                        payment.put('ASI_MFM_PO_' + i + '_A_C_Description__c', poiList[0].ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c);
                                    }

                                    Boolean match = false;

                                    if (payment.ASI_MFM_AlternatePayee__c == po.ASI_MFM_SG_Customer__c)
                                    {
                                        match = true;
                                    }

                                    if (!match)
                                    {
                                        for (ASI_MFM_PO_Line_Item__c item: poiList)
                                        {
                                            if (payment.ASI_MFM_AlternatePayee__c == item.ASI_MFM_Customer_Name__c)
                                            {
                                                match =true;
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if (!match)
                                    {
                                        payment.ASI_MFM_Customer_Approval__c = true;
                                    }
                                }
                            }
                            else if (Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
                            {
                                List<ASI_MFM_PO_Line_Item__c> poiList = getPOItems(poItemList, po.ID);

                                if (po.ASI_MFM_AP_AD__c == 'A&D' && payment.ASI_MFM_Credit_Note__c == true)
                                {
                                    if (poiList.size() > 0)
                                    {
                                        payment.put('ASI_MFM_PO_' + i + '_A_C_Description__c', poiList[0].ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Description__c);
                                    }

                                    Boolean match = false;

                                    if (payment.ASI_MFM_AlternatePayee__c == po.ASI_MFM_SG_Customer__c)
                                    {
                                        match = true;
                                    }

                                    if (!match)
                                    {
                                        for (ASI_MFM_PO_Line_Item__c item: poiList)
                                        {
                                            if (payment.ASI_MFM_AlternatePayee__c == item.ASI_MFM_Customer_Name__c)
                                            {
                                                match = true;
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if (!match)
                                    {
                                        payment.ASI_MFM_Customer_Approval__c = true;
                                    }
                                }
                                else if (payment.ASI_MFM_Credit_Note__c == false)
                                {
                                    if (payment.ASI_MFM_AlternatePayee__c == null)
                                    {
                                        payment.ASI_MFM_AlternatePayee__c = payment.ASI_MFM_Supplier_Name__c;
                                    }

                                    Boolean match = false;

                                    if (payment.ASI_MFM_AlternatePayee__c == po.ASI_MFM_Supplier_Name__c)
                                    {
                                        match = true;
                                    }
                                    
                                    if (!match)
                                    {
                                        payment.ASI_MFM_Customer_Approval__c = true;
                                    }
                                }
                            }
                        }
                    }
                }
                
                //mark ng 2020-04-09
                if (payment.ASI_MFM_Status__c == 'Draft' && payment.ASI_MFM_OCR__c == true)
                {
                    payment.ASI_MFM_Status__c = 'Pending Goods/Service Receipt';
                }
            }

            // start approver assign
            set<id> pid_set = new set<id>();
            set<id> pmID_set = new set<id>();
            set<id> px_set = new set<id>();
            set<id> pr_set = new set<id>();
        
            for (ASI_MFM_Payment__c p:usPaymentList) {
                if (p.ASI_MFM_Payment_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0)
                {
                    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
                    {
                        pid_set.add(p.ASI_MFM_PO_1__c);
                        
                        ASI_MFM_PO__c po = getPO(poList, p.ASI_MFM_PO_1__c);

                        if (po != null)
                        {
                            px_set.add(po.ASI_MFM_Prefix__c);
                        }
                    }
                    else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
                    {
                        pid_set.add(p.id);                    
                        ASI_MFM_PO__c po = getPO(poList, p.ASI_MFM_PO_1__c);

                        if (po != null && po.ASI_MFM_Prefix__r.ASI_MFM_Location__c == 'India')
                        {
                            px_set.add(p.ASI_MFM_Prefix__c);
                        }
                    }
                    else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
                    {
                        pid_set.add(p.id);
                        px_set.add(p.ASI_MFM_Prefix__c);
                    }
                    
                    setApproverToNull(p);
                }
            }
            system.debug('pid_set: '+ pid_set);
            system.debug('px_set: '+ px_set);
            if (pid_set.size() > 0) {
                map<id, id> sb_map = new map<id, id>();

                for (ASI_MFM_PO_Line_Item__c pi:[select ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c from ASI_MFM_PO_Line_Item__c 
                    where ASI_MFM_PO__c in :pid_set order by name desc]) {
                    sb_map.put(pi.ASI_MFM_PO__c, pi.ASI_MFM_Sub_brand_Code__c);
                }
                list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
            
                brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c from ASI_MFM_Brand_Route_Type_Map__c 
                where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Sub_brand__c = null or ASI_MFM_Sub_brand__c in :sb_map.values()) 
                order by ASI_MFM_Prefix__c, ASI_MFM_Sub_brand__c desc];

                System.debug('brm_list: ' + brm_list);
                set<id> rt_set = new set<id>();    
                
                for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                    rt_set.add(brm.ASI_MFM_Route_Type__c);
                }

                list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c, ASI_MFM_Sequence__c from ASI_MFM_Route_Rule_Detail__c 
                    where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Sequence__c ];
                System.debug('rule_list: ' + rule_list);
                for (ASI_MFM_Payment__c p : trigger_new)
                {
                    integer approver_count = 0;
                    id rtid;

                    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
                    {
                        ASI_MFM_PO__c po = getPO(poList, p.ASI_MFM_PO_1__c);

                        if (po != null && pid_set.contains(po.ID))
                        {
                            id sbid = sb_map.get(po.ID);

                            for (ASI_MFM_Brand_Route_Type_Map__c brm : brm_list)
                            {
                                System.debug('px: ' + brm.ASI_MFM_Prefix__c + ', ' + brm.ASI_MFM_Prefix__c);
                                if (brm.ASI_MFM_Prefix__c == po.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null))
                                {
                                    rtid = brm.ASI_MFM_Route_Type__c;
                                    System.debug('rtid_in: ' + rtid);
                                    break;
                                }
                                else if (brm.ASI_MFM_Prefix__c > po.ASI_MFM_Prefix__c)
                                {
                                    System.debug('rtid_break: ' + rtid);
                                    break;
                                }                       
                            }
                        }
                    }
                    else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR'))
                    {
                        if (pid_set.contains(p.id)) {
                            id sbid = sb_map.get(p.id);

                            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                                if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null)) {
                                    rtid = brm.ASI_MFM_Route_Type__c;
                                    break;
                                }
                                else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                                    break;
                                }                       
                            }
                        }
                    }
                    else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
                    {

                    }

                    if (rtid != null)
                    {
                        decimal local_amount = p.ASI_MFM_Payment_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                        System.debug('Local Amount: ' + local_amount);
                        System.debug('Route Type ID: ' + rtid + ' pocount: ' + poCount);

                        if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
                        {
                            for (ASI_MFM_Route_Rule_Detail__c rd : rule_list)
                            {
                                if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount) {
                                    if (approver_count == 0) {
                                        p.ASI_MFM_Sys_Approver_1__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 1) {                                 
                                        p.ASI_MFM_Sys_Approver_2__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 2) {                                 
                                        p.ASI_MFM_Sys_Approver_3__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 3) {                                 
                                        p.ASI_MFM_Sys_Approver_4__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 4) {                                 
                                        p.ASI_MFM_Sys_Approver_5__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 5) {                                 
                                        p.ASI_MFM_Sys_Approver_6__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 6) {                                 
                                        p.ASI_MFM_Sys_Approver_7__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 7) {                                 
                                        p.ASI_MFM_Sys_Approver_8__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 8) {                                 
                                        p.ASI_MFM_Sys_Approver_9__c = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (approver_count == 9) {                                 
                                        p.ASI_MFM_Sys_Approver_10__c = rd.ASI_MFM_Approver__c;
                                    }
                                    approver_count++;                                                                                                                               
                                }
                                else if (rd.ASI_MFM_Route_Type__c > rtid)
                                {
                                    break;
                                }
                            }
                        }
                        else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_TR') && rule_list.size() > 0)
                        {
                            Decimal limitAmount;
                            ID seq1Approver;
                            ID seq2Approver;
                            ID seq3Approver;
                            ID seq9Approver;

                            for (ASI_MFM_Route_Rule_Detail__c rd : rule_list)
                            {
                                if (rd.ASI_MFM_Route_Type__c == rtid)
                                {
                                    if (rd.ASI_MFM_Sequence__c == 1)
                                    {
                                        seq1Approver = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (rd.ASI_MFM_Sequence__c == 2)
                                    {
                                        seq2Approver = rd.ASI_MFM_Approver__c;
                                    }
                                    else if (rd.ASI_MFM_Sequence__c == 3)
                                    {
                                        seq3Approver = rd.ASI_MFM_Approver__c;
                                        limitAmount = rd.ASI_MFM_Minimum_Amount__c;
                                    }
                                    else if (rd.ASI_MFM_Sequence__c == 9)
                                    {
                                        seq9Approver = rd.ASI_MFM_Approver__c;
                                    }
                                }
                            }

                            if (seq1Approver == null || seq2Approver == null || seq3Approver == null || seq9Approver == null || limitAmount == null || limitAmount == 0)
                            {
                                p.addError('payment route is not setup correctly');
                                return;
                            }

                            if (local_amount < limitAmount)
                            {
                                if (poCount == 1)
                                {
                                    ASI_MFM_PO__c po = getPO(poList, p.ASI_MFM_PO_1__c);

                                    if (po != null)
                                    {
                                        if (po.ASI_MFM_Sys_Approver_1__c == seq1Approver)
                                        {
                                            p.ASI_MFM_Sys_Approver_1__c = seq2Approver;
                                        }
                                        else if (po.ASI_MFM_Sys_Approver_1__c == seq2Approver)
                                        {
                                            p.ASI_MFM_Sys_Approver_1__c = seq1Approver;
                                        }
                                    }
                                }
                                else if (poCount > 1)
                                {
                                    Integer seq1Count = 0;
                                    Integer seq2Count = 0;
                                    for (Integer i = 1; i <= 5; i++)
                                    {
                                        ID poID = (ID)(p.get('ASI_MFM_PO_' + i + '__c'));
                                        
                                        if (poID != null)
                                        {
                                            ASI_MFM_PO__c po = getPO(poList, poID);

                                            if (po.ASI_MFM_Sys_Approver_1__c == seq1Approver)
                                            {
                                                seq1Count++;
                                            }
                                            else if (po.ASI_MFM_Sys_Approver_1__c == seq2Approver)
                                            {
                                                seq2Count++;
                                            }
                                        }
                                    }
                                    
                                    if (seq1Count > 0)
                                    {
                                        p.ASI_MFM_Sys_Approver_1__c = seq2Approver;
                                    }
                                    else if (seq1Count == 0)
                                    {
                                        p.ASI_MFM_Sys_Approver_1__c = seq1Approver;
                                    }
                                }
                            }
                            else
                            {
                                p.ASI_MFM_Sys_Approver_1__c = seq3Approver;
                            }

                            if (p.ASI_MFM_Sys_Approver_1__c == null)
                            {
                                p.ASI_MFM_Sys_Approver_1__c = seq9Approver;
                            }
                            else
                            {
                                p.ASI_MFM_Sys_Approver_2__c = seq9Approver;
                            }
                        }
                    } 
                    //else
                    //{
                    //    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_RM'))
                    //    {
                    //        System.debug('No rt id' );
                    //        p.adderror('The po has no route type set up');
                    //    }
                    //}

                    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_MKTEXP_HK'))
                    {
                        if (p.ASI_MFM_Vendor_Approval__c == true)
                        {
                            User owner = owner_map.get(p.OwnerID);

                            if (owner != null)
                            {
                                String department = owner.ASI_Department__c;

                                if (department != null)
                                {
                                    ID headID = headMap.get(department);

                                    if (headID != null)
                                    {
                                        p.ASI_MFM_Sys_Approver_1__c = headID;
                                    }
                                }
                            }
                        }
                    } 
                }
            }
        }
    } 
    
    public static void setApproverToNull(ASI_MFM_Payment__c p){   
        p.ASI_MFM_Sys_Approver_1__c = null;
        p.ASI_MFM_Sys_Approver_2__c = null;
        p.ASI_MFM_Sys_Approver_3__c = null;
        p.ASI_MFM_Sys_Approver_4__c = null;
        p.ASI_MFM_Sys_Approver_5__c = null;
        p.ASI_MFM_Sys_Approver_6__c = null;
        p.ASI_MFM_Sys_Approver_7__c = null;
        p.ASI_MFM_Sys_Approver_8__c = null;
        p.ASI_MFM_Sys_Approver_9__c = null;
        p.ASI_MFM_CN_Finance__c = null;    
        p.ASI_MFM_CN_Return_Approver_1__c = null;
        p.ASI_MFM_CN_Return_Approver_2__c = null;
        p.ASI_MFM_CN_Return_Approver_3__c = null; 
    }

    public static ASI_MFM_PO__c getPO(List<ASI_MFM_PO__c> poList, ID poID)
    {
        for (ASI_MFM_PO__c po: poList)
        {
            if (po.ID == poID)
            {
                return po;
            }
        }

        return null;
    }

    public static List<ASI_MFM_PO_Line_Item__c> getPOItems(List<ASI_MFM_PO_Line_Item__c> poItemList, ID poID)
    {
        List<ASI_MFM_PO_Line_Item__c> itemList = new List<ASI_MFM_PO_Line_Item__c>();
        for (ASI_MFM_PO_Line_Item__c item: poItemList)
        {
            if (item.ASI_MFM_PO__c == poID)
            {
                itemList.add(item);
            }
        }

        return itemList;
    }

    public static String checkTolerance(Map<String, ASI_MFM_MKTEXP_POToleranceLimit__mdt> setting, List<ASI_MFM_Exchange_Rate__c> exchangeList, Decimal paymentAmount, String poName, Decimal poBalance, Decimal poAmount, ID recordTypeID, String curr, Decimal exRate, ASI_MFM_Payment__c payment, String type, Boolean noExchange)
    {
        System.debug(setting.size()+', '+exchangeList.size()+', '+paymentAmount+', '+poName+', '+poBalance+', '+poAmount+', '+recordTypeID+', '+curr+', '+exRate+', '+type+', '+noExchange);

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
            
            System.debug(exRate+', '+calRate+', '+paymentAmount+', '+poAmount);
        }

        if (tolerance != null && paymentAmount > poBalance)
        {
            System.debug(tolerance.ASI_MFM_MKTEXP_Amount__c+', '+poBalance);
            
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
            System.Debug('amount error:  paymentAmount: ' + paymentAmount+' ,poAmount: '+poAmount);                                    
            return 'PO#: ' + poName + ' - payment amount should not be greater than po balance';
        }

        return '';
    }
}