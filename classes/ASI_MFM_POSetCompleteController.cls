/**********************************************************
Introv DW - PO Clone for Complete 

**********************************************************/

public with sharing class ASI_MFM_POSetCompleteController {

    public ASI_MFM_PO__c po {get;set;}
    public List<ASI_MFM_PO_Line_Item__c> lstPOLine {get;set;}
    public List<ASI_MFM_PO_Line_Item__c> updatePOLine {get;set;}
    public List<ASI_MFM_PO_Line_Item__c> newPOLine {get;set;}
    public List<ASI_MFM_PO_Line_Item__c> newPOLineAdj {get;set;}
    public Decimal invoiceAmount {get;set;}
    //public Decimal orginialPOAmount {get;set;}
    //public Decimal orginialPOBalance {get;set;}
    public Decimal historyAmount {get;set;}
    public Decimal futureAmount {get;set;}
    
    public ASI_MFM_POSetCompleteController(ApexPages.StandardController controller) {
        //po = new ASI_MFM_PO__c();
        this.po = (ASI_MFM_PO__c)controller.getRecord();
        newPOLine = new List<ASI_MFM_PO_Line_Item__c>();
        newPOLineAdj = new List<ASI_MFM_PO_Line_Item__c>();
        updatePOLine = new List<ASI_MFM_PO_Line_Item__c>();
        historyAmount = 0.00;
        futureAmount = 0.00;
        invoiceAmount = (po.ASI_MFM_Inv_Amount_from_JDE_less_TnE__c != Null ? po.ASI_MFM_Inv_Amount_from_JDE_less_TnE__c : 0) + (po.ASI_MFM_T_E_Amount__c != Null ? po.ASI_MFM_T_E_Amount__c : 0);//20170919 Introv
    }
    
    public pageReference doComplete(){
        //return null;
        init();
        
        //check PO status
        if(!(po.ASI_MFM_Status__c.equalsignorecase('Final') || po.ASI_MFM_Status__c.equalsignorecase('Partial Paid'))){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Only Final / Partial Paid PO can be complete.'));
            return null;
        }
        
        if(po.ASI_MFM_FOC_PO_Remaining_Amount__c < 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'FOC PO Remaining Amount cannot be negative.'));
            return null;
        }
        
        if(po.ASI_MFM_Invoice_Amount_from_JDE__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Invoice Amount From JDE cannot be NULL.'));
            return null;
        }
        
        if(po.ASI_MFM_PO_Amount__c == po.ASI_MFM_PO_Balance__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Clone for Complete function should not be allowed if \'PO Amount\' = \'PO Balance\''));
            return null;
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            lstPOLine = getLineItem(po.Id);
            historyAmount = getHistoryItem(lstPOLine);
            futureAmount = getFutureItem(lstPOLine);
            //cloneHistoryItem(groupHistLine);
            cloneHistoryItem(lstPOLine);
            
            if(newPOLine != null && newPOLine.size() > 0){
                insert newPOLine;
                update updatePOLine;
            }
            
            if(newPOLineAdj != null && newPOLineAdj.size() > 0){
                insert newPOLineAdj;
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            Database.rollback(sp);
            return null;
        }
        
        //return null;
        
        PageReference redirectPage = new PageReference('/' + po.Id); //Page.force_OrderDetail;
        redirectPage.setRedirect(true);
        return redirectPage;
        
    }
    
    public void init(){
        //orginialPOAmount = 0.00;
        //orginialPOBalance = 0.00;
    }
    
    public List<ASI_MFM_PO_Line_Item__c> getLineItem(Id poId){
        List<ASI_MFM_PO_Line_Item__c> lstPOLine = new List<ASI_MFM_PO_Line_Item__c>();
        String query_string = ASI_MFM_Function.buildQuery('ASI_MFM_PO_line_item__c') + ' WHERE ASI_MFM_PO__c = :poId';
        lstPOLine = database.query(query_string);
        return lstPOLine;
    }
        
    public Date getNextMonth1stDay() {
		//Return 1st day of next month
        Date nextMonth1stDay = Date.newInstance(Date.today().addMonths(1).year(), Date.today().addMonths(1).month(), 1);
        return nextMonth1stDay;
    }
    
    //clone Future Item * -1
    public Decimal getFutureItem(List<ASI_MFM_PO_Line_Item__c> lstPOLine){
        Decimal futureAmount = 0.00;
        //Return 1st day of next month
        Date nextMonth = getNextMonth1stDay();
        for(ASI_MFM_PO_Line_Item__c pl : lstPOLine){
            //if(!pl.ASI_MFM_Synced__c) {
            if(pl.ASI_MFM_G_L_Date__c >= nextMonth){
                ASI_MFM_PO_Line_Item__c pl2 = pl.clone(false, true);
                //set A/P = C
                pl2.ASI_MFM_Base_Currency_Amount__c = pl2.ASI_MFM_Base_Currency_Amount__c * -1;
                pl2.ASI_MFM_Amount__c = pl2.ASI_MFM_Amount__c * -1 * (pl2.ASI_MFM_Exchange_Rate__c != null ? pl2.ASI_MFM_Exchange_Rate__c : 1); //ASI_MFM_Exchange_Rate__c
                pl2.ASI_MFM_Synced__c = false;
                if (pl2.ASI_MFM_List_Item_Description__c.length() >= 220) {
                    pl2.ASI_MFM_List_Item_Description__c = pl2.ASI_MFM_List_Item_Description__c.substring(0,220);
                }
                pl2.ASI_MFM_List_Item_Description__c += ' (Reversal due to PO Completion)'; //' - (Cloned for negative amount)';
                pl2.ASI_MFM_PO_Line_Item_External_ID__c  = '';
                pl2.Id = null;
                //pl2.ASI_MFM_Pay_Acc__c = 'C';
                newPOLine.add(pl2);
                
                //pl.ASI_MFM_Pay_Acc__c = 'C';
                updatePOLine.add(pl);
                futureAmount += pl.ASI_MFM_Amount__c;
                //futureAmount += pl2.ASI_MFM_Amount__c;
            }
        }
        
        return futureAmount;
    }
    
    //get History Item * -1
    public Decimal getHistoryItem(List<ASI_MFM_PO_Line_Item__c> lstPOLine){
        Decimal syncedAmount = 0.00;
        //Return 1st day of next month
        Date nextMonth = getNextMonth1stDay();
        for(ASI_MFM_PO_Line_Item__c pl : lstPOLine){
            //if(pl.ASI_MFM_Synced__c){
            if(pl.ASI_MFM_G_L_Date__c < nextMonth){
                syncedAmount += pl.ASI_MFM_Amount__c;
            }
        }
        return syncedAmount;
    }
    
    // Line Amount / (Total Synced Amount) * (JDE INV - Total Synced Amount)
    public Void cloneHistoryItem(List<ASI_MFM_PO_Line_Item__c> lstPOLine){
        Map<Id, Integer> mapPOSubBrand = new Map<Id, Integer>();
        Decimal clonedAmount = 0.00;
        Integer iCnt = 0;
        //Return 1st day of next month
        Date nextMonth = getNextMonth1stDay();
        Date thisMonth1stDay = Date.newInstance(system.today().year(), system.today().month(), 1);
        //Map <Id, Decimal> map_SubBrandTotal = new Map <Id, Decimal>();
        if((invoiceAmount - historyAmount + futureAmount) != 0){
            for(ASI_MFM_PO_Line_Item__c pl : lstPOLine){
                //if(pl.ASI_MFM_Synced__c){
                if(pl.ASI_MFM_G_L_Date__c < nextMonth){
                    ASI_MFM_PO_Line_Item__c pl2 = pl.clone(false, true);
                    //System.debug('pl.ASI_MFM_G_L_Date__c := ' + pl.ASI_MFM_G_L_Date__c);
                    //System.debug('historyAmount := ' + historyAmount);
                    //System.debug('futureAmount := ' + futureAmount);
                    //System.debug('invoiceAmount := ' + invoiceAmount);
                    //System.debug('pl2.ASI_MFM_Base_Currency_Amount__c := ' + pl2.ASI_MFM_Base_Currency_Amount__c);
                    //pl2.ASI_MFM_Base_Currency_Amount__c = (pl2.ASI_MFM_Base_Currency_Amount__c / historyAmount) * (invoiceAmount + futureAmount - historyAmount);
                    pl2.ASI_MFM_Base_Currency_Amount__c = (pl2.ASI_MFM_Base_Currency_Amount__c / historyAmount) * (historyAmount - invoiceAmount) * -1;
                    //pl2.ASI_MFM_Amount__c = (pl2.ASI_MFM_Amount__c / historyAmount) * (invoiceAmount + futureAmount - historyAmount) * (pl2.ASI_MFM_Exchange_Rate__c != null ? pl2.ASI_MFM_Exchange_Rate__c : 1);
                    pl2.ASI_MFM_Amount__c = (pl2.ASI_MFM_Amount__c / historyAmount) * (historyAmount - invoiceAmount) * (pl2.ASI_MFM_Exchange_Rate__c != null ? pl2.ASI_MFM_Exchange_Rate__c : 1) * -1;
                    //pl2.ASI_MFM_Amount__c = pl2.ASI_MFM_Amount__c * -1; //ASI_MFM_Exchange_Rate__c
                    //System.debug('ASI_MFM_Base_Currency_Amount__c := ' + pl2.ASI_MFM_Base_Currency_Amount__c);
                    //System.debug('ASI_MFM_Amount__c := ' + pl2.ASI_MFM_Amount__c);
                    pl2.ASI_MFM_Synced__c = false;
                    if (pl2.ASI_MFM_List_Item_Description__c.length() >= 220) {
                    	pl2.ASI_MFM_List_Item_Description__c = pl2.ASI_MFM_List_Item_Description__c.substring(0,220);                        
                    }
                    pl2.ASI_MFM_List_Item_Description__c += ' (Reversal due to PO Completion)'; //' - Cloned for adjustment amount';
                    pl2.ASI_MFM_PO_Line_Item_External_ID__c  = '';
                    pl2.Id = null;
                    
                    pl2.ASI_MFM_Base_Currency_Amount__c = pl2.ASI_MFM_Base_Currency_Amount__c.setScale(0);
                    pl2.ASI_MFM_Amount__c = pl2.ASI_MFM_Amount__c.setScale(0);
                    
                    if (mapPOSubBrand.containsKey(pl2.ASI_MFM_Sub_brand_Code__c)) {
                    	iCnt = mapPOSubBrand.get(pl2.ASI_MFM_Sub_brand_Code__c);                        
                    }
                   
                    pl2.ASI_MFM_G_L_Date__c = thisMonth1stDay + iCnt;
                    mapPOSubBrand.put(pl2.ASI_MFM_Sub_brand_Code__c, iCnt + 1);
                    
                    clonedAmount += pl2.ASI_MFM_Amount__c;
                    
                    newPOLineAdj.add(pl2);
                }
            }
            
            
            if(newPOLine != null && newPOLine.size() > 0 && newPOLineAdj != null && newPOLineAdj.size() > 0){
                Decimal netDiff = 0.00;
                netDiff = invoiceAmount - historyAmount - clonedAmount;
                if(newPOLineAdj[newPOLineAdj.size() - 1].ASI_MFM_Synced__c == false){ //Vincent@20180131
                    newPOLineAdj[newPOLineAdj.size() - 1].ASI_MFM_Base_Currency_Amount__c += netDiff;
                    newPOLineAdj[newPOLineAdj.size() - 1].ASI_MFM_Amount__c += netDiff;
                }
            }
        }
        
    }
}