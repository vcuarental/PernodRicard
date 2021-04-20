/**********************************************************
Introv Alvin - PO for Complete 

**********************************************************/

public with sharing class ASI_MFM_MKTEXP_POCompleteController {

    public ASI_MFM_PO__c po { get; set; }
    public Boolean err { get; set; }
    
    public ASI_MFM_MKTEXP_POCompleteController(ApexPages.StandardController controller) {
        this.po = (ASI_MFM_PO__c)controller.getRecord();
        err = false;

        if (this.po != null)
        {
            this.po = [
                select Id, Name, ASI_MFM_Reference_2__c, ASI_MFM_Status__c, ASI_MFM_FOC_PO_Remaining_Amount__c,
                ASI_MFM_PO_Amount__c, ASI_MFM_MKTEXP_PO_Balance__c, ASI_MFM_Accrual_Prepayment_Amount__c,
                ASI_MFM_Invoice_Amount_from_JDE__c, ASI_MFM_Inv_Amount_from_JDE_less_TnE__c, ASI_MFM_T_E_Amount__c,
                ASI_MFM_HK_T_E_Amount__c, ASI_MFM_HK_T_E_Paid_Amount__c, ASI_MFM_HK_FOC_Amount__c, ASI_MFM_HK_FOC_Paid_Amount__c
                from ASI_MFM_PO__c where Id = :this.po.Id
            ];

            for (ASI_MFM_Payment__c payment: [
                select ID, ASI_MFM_Status__c, ASI_MFM_Payment_Line_Generation__c, ASI_MFM_PO_Receipt_Generation__c
                from ASI_MFM_Payment__c
                where (
                    ASI_MFM_PO_1__c = :this.po.ID
                    or ASI_MFM_PO_2__c = :this.po.ID
                    or ASI_MFM_PO_3__c = :this.po.ID
                    or ASI_MFM_PO_4__c = :this.po.ID
                    or ASI_MFM_PO_5__c = :this.po.ID
                )
            ])
            {
                if ((payment.ASI_MFM_Status__c == 'Pending Goods/Service Receipt'
                    || payment.ASI_MFM_Status__c == 'Submitted')
                    && payment.ASI_MFM_Payment_Line_Generation__c == false
                    && payment.ASI_MFM_PO_Receipt_Generation__c == true)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'There are pending PO Receipt. This PO cannot be in "Completed" status at the moment.'));
                    err = true;
                }
            }

            // Only for non-CAPEX PO ************Added by 2018-05-07 Linus@introv
            /*if (po.ASI_MFM_Reference_2__c == 'CAPEX')
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'CAPEX PO can only be completed with Depreciation'));
                err = true;
            }
            */
            //check PO status
            if (!(po.ASI_MFM_Status__c.equalsignorecase('Final') || po.ASI_MFM_Status__c.equalsignorecase('Partial Paid')))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Only Final / Partial Paid PO can be complete.'));
                err = true;
            }
            
            if (po.ASI_MFM_FOC_PO_Remaining_Amount__c < 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'FOC PO Remaining Amount cannot be negative.'));
                err = true;
            }
            
            // if (po.ASI_MFM_Invoice_Amount_from_JDE__c == null)
            // {
            //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Invoice Amount From JDE cannot be NULL.'));
            //     return null;
            // }
            
            //System.debug('poamount: ' + po.ASI_MFM_PO_Amount__c);
            //        System.debug('pobalance: ' + po.ASI_MFM_MKTEXP_PO_Balance__c);
            //if (po.ASI_MFM_PO_Amount__c == po.ASI_MFM_MKTEXP_PO_Balance__c)
            //{
            //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Clone for Complete function should not be allowed if \'PO Amount\' = \'PO Balance (MKTEXP)\''));
            //    return null;
            //}

            if (po.ASI_MFM_Accrual_Prepayment_Amount__c != 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Prepayment is made from this PO and accrual is in-progress based on future G/L date. I.e. This PO cannot be in "Completed" status at the moment. Please use "Clone for Adjust" if necessary.'));
                err = true;
            }
            
            //20191205:AM@introv - SSC CR start
            if ((po.ASI_MFM_HK_T_E_Amount__c > 0 && po.ASI_MFM_HK_T_E_Amount__c != po.ASI_MFM_HK_T_E_Paid_Amount__c) || (po.ASI_MFM_HK_FOC_Amount__c > 0 && po.ASI_MFM_HK_FOC_Amount__c != po.ASI_MFM_HK_FOC_Paid_Amount__c))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'There are pending FOC/T&E Amount. This PO cannot be in "Completed" status at the moment.'));
                err = true;
            }
            //20191205:AM@introv - SSC CR end
        }
    }
    
    public pageReference doComplete()
    {   
        List<ASI_MFM_PO_Line_Item__c> poItems = getPoItems(po.Id);
        List<ASI_MFM_PO_Line_Item__c> newPoItems = completeItems(poItems);
        Savepoint sp = Database.setSavepoint();
        try {
            if (newPoItems != null && newPoItems.size() > 0){
                upsert newPoItems;
            }

            //update poItems;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }
        
        PageReference redirectPage = new PageReference('/' + po.Id);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    public List<ASI_MFM_PO_Line_Item__c> getPoItems(Id poId)
    {
        List<ASI_MFM_PO_Line_Item__c> lstPOLine = new List<ASI_MFM_PO_Line_Item__c>();
        String query_string = ASI_MFM_Function.buildQuery('ASI_MFM_PO_line_item__c') + ' WHERE ASI_MFM_PO__c = :poId';
        lstPOLine = database.query(query_string);
        return lstPOLine;
    }

    public List<ASI_MFM_PO_Line_Item__c> completeItems(List<ASI_MFM_PO_Line_Item__c> poItems)
    {
        List<ASI_MFM_PO_Line_Item__c> newPoItems = new List<ASI_MFM_PO_Line_Item__c>();

        for (ASI_MFM_PO_Line_Item__c item : poItems)
        {
            if (item.ASI_MFM_Base_Currency_Remaining_Balance__c != 0)
            {
                ASI_MFM_PO_Line_Item__c newItem = item.clone(false, true);
                newItem.ASI_MFM_G_L_Date__c = system.today();
                newItem.ASI_MFM_Base_Currency_Amount__c = item.ASI_MFM_Base_Currency_Remaining_Balance__c * -1;
                newItem.ASI_MFM_Amount__c = newItem.ASI_MFM_Base_Currency_Amount__c / newItem.ASI_MFM_Exchange_Rate__c;
                newItem.ASI_MFM_List_Item_Description__c += ' (Reversal due to PO Completion)';
                newItem.ASI_MFM_MKTEXP_Complete_Reverse__c = true;
                newItem.ASI_MFM_PO_Line_Item_External_ID__c  = '';
                newItem.ASI_MFM_Synced__c = false;
                newPoItems.add(newItem);
            }

            Date lastDate = system.today();
            lastDate = lastDate.addMonths(1).toStartofMonth().addDays(-1);
            if (item.ASI_MFM_G_L_Date__c > lastDate)
            {
                item.ASI_MFM_G_L_Date__c = system.today();
                newPoItems.add(item);
            }
        }
        
        return newPoItems;
    }
}