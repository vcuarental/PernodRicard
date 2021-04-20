/*********************************************************************************
 * Name: ASI_CRM_SG_ROI_Helper
 * Description: Calculate ROI of contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-04-06       Laputa: Vincent Lam     Created
 * 2016-04-11       Wilken Lee              Add A&P Payment & A&P FOC amount for ROI reporting
 * 2016-05-16       Laputa: Vincent Lam     [VL 1.0] Calculate FOC (9L) to header
 * 2016-05-23       Laputa: Vincent Lam     [VL 2.0] Calculate Duty, FOB, Handling Cost for some FOC type
 * 2016-10-24		Wilken Lee				Add checking on ContractID Set to include non-Null ID only, to avoid non-Select Query error on production
 * 2017-02-27		Laputa: Vincent Lam		[VL 3.0] Calculate bottle incentive with adjusted amount
 * 2017-11-30		Wilken Lee				[WL 4.0] Reconcile with SAS, FOC Item need to be included in Cost calculation even the SKU has no price defined 
 * 2018-04-13		Laputa: Vincent Lam		[VL 5.0] Ignore promotion incentive from ROI
 * 2019-02-25		Wilken Lee				[WL 6.0] Correct Payment Request Back Rebate Revised Amount
 */
public class ASI_CRM_SG_ROI_Helper {
    
    public Set<ID> set_contractID = new Set<ID>();
    public Map<ID, ASI_TH_CRM_Contract__c> map_contractID_ContractHeader {get;set;}
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> list_payment {get;set;}
    public List<ASI_FOC_Request_Item__c> list_FOC {get;set;}
    public List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_credit {get;set;}
    public List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_debit {get;set;}
    
    public Map<ID, Decimal> map_contractID_freeGoodsAmount_all  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsAmount_approved  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsAdhocAmount_all  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsAdhocAmount_approved  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_bottleIncentiveAmount_all  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_bottleIncentiveAmount_approved  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_contractMarginAmount_all  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_contractMarginAmount_approved  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_cashSponsorshipAmount_all  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_cashSponsorshipAmount_approved  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_tradeAnPExpensesAmount_all  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_tradeAnPExpensesAmount_approved  = new Map<ID, Decimal>();
    
    //Added by Wilken, separate A&P Payment Amount and A&P Free Goods Amount for ROI reporting
    public Map<ID, Decimal> map_contractID_PaymentAnPAmount_approved  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsAnPAmount_approved  = new Map<ID, Decimal>();
    
    public Map<ID, Decimal> map_contractID_salesSupportAmount_all  = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_salesSupportAmount_approved  = new Map<ID, Decimal>();
    
    /* [VL 1.0] BEGIN */
    public Map<ID, Decimal> map_contractID_freeGoods9L_approved = new Map<ID, Decimal>();
    /* [VL 1.0] END */
    
    /* [VL 2.0] BEGIN */
    public Map<ID, Decimal> map_contractID_freeGoodsDuty_approved = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsDuty_all = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsFOB_approved = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsFOB_all = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsHandling_approved = new Map<ID, Decimal>();
    public Map<ID, Decimal> map_contractID_freeGoodsHandling_all = new Map<ID, Decimal>();
    /* [VL 2.0] END */
    
    // constructor for contract ID input
    public ASI_CRM_SG_ROI_Helper (List<ID> header) {
        this.set_contractID = new Set<ID>(header);
        getContractHeader();
        this.list_FOC = getFOC();
        this.list_payment = getPayment();
		this.list_credit = getCredit();
		this.list_debit = getDebit();
    }
    
    // constructor for contract ID input
    public ASI_CRM_SG_ROI_Helper (Set<ID> header) {
        this.set_contractID = header;
        getContractHeader();
        this.list_FOC = getFOC();
        this.list_payment = getPayment();
		this.list_credit = getCredit();
		this.list_debit = getDebit();
    }
    
    // constructor for payment request header input
    public ASI_CRM_SG_ROI_Helper (List<ASI_TH_CRM_PaymentRequest__c> header) {
        getContractFromPayment(header);
        getContractHeader();
        this.list_FOC = getFOC();
        this.list_payment = getPayment();
		this.list_credit = getCredit();
		this.list_debit = getDebit();
    }
    
    // constructor for FOC request header input
    public ASI_CRM_SG_ROI_Helper (List<ASI_FOC_Free_Goods_Request__c> header) {
        getContractFromFOC(header);
        getContractHeader();
        this.list_FOC = getFOC();
        this.list_payment = getPayment();
		this.list_credit = getCredit();
		this.list_debit = getDebit();
    }
    
    // constructor for Credit/Debit header input
    public ASI_CRM_SG_ROI_Helper (List<ASI_CRM_Credit_Debit_Note__c> header) {
        getContractFromCreditDebit(header);
        getContractHeader();
        this.list_FOC = getFOC();
        this.list_payment = getPayment();
		this.list_credit = getCredit();
		this.list_debit = getDebit();
    }
    
    // constructor for payment request header input
    public ASI_CRM_SG_ROI_Helper (Set<ID> set_contractId, List<ASI_TH_CRM_PaymentRequest__c> header) {
        this.set_contractID = set_contractId;
		getContractFromPayment(header);
        getContractHeader();
        this.list_FOC = getFOC();
        this.list_payment = getPayment();
		this.list_credit = getCredit();
		this.list_debit = getDebit();
    }
    
    // constructor for FOC request header input
    public ASI_CRM_SG_ROI_Helper (Set<ID> set_contractId, List<ASI_FOC_Free_Goods_Request__c> header) {
        this.set_contractID = set_contractId;
        getContractFromFOC(header);
        getContractHeader();
        this.list_FOC = getFOC();
        this.list_payment = getPayment();
		this.list_credit = getCredit();
		this.list_debit = getDebit();
    }
    
    // constructor for Credit/Debit header input
    public ASI_CRM_SG_ROI_Helper (Set<ID> set_contractId, List<ASI_CRM_Credit_Debit_Note__c> header) {
        this.set_contractID = set_contractId;
        getContractFromCreditDebit(header);
        getContractHeader();
        this.list_FOC = getFOC();
        this.list_payment = getPayment();
		this.list_credit = getCredit();
		this.list_debit = getDebit();
    }
    
    public void getContractFromPayment(List<ASI_TH_CRM_PaymentRequest__c> header) {
        for (ASI_TH_CRM_PaymentRequest__c paymentHeader : [Select ASI_TH_CRM_Contract__c from ASI_TH_CRM_PaymentRequest__c where id in :header]) {
			if (paymentHeader.ASI_TH_CRM_Contract__c != null)
				this.set_contractID.add(paymentHeader.ASI_TH_CRM_Contract__c);
        }
    }
    
    public void getContractFromFOC(List<ASI_FOC_Free_Goods_Request__c> header) {
        for (ASI_FOC_Free_Goods_Request__c focHeader : [Select ASI_CRM_Contract__c from ASI_FOC_Free_Goods_Request__c where id in :header]) {
			if (focHeader.ASI_CRM_Contract__c != null)
				this.set_contractID.add(focHeader.ASI_CRM_Contract__c);
        }
    }
    
    public void getContractFromCreditDebit(List<ASI_CRM_Credit_Debit_Note__c> header) {
        for (ASI_CRM_Credit_Debit_Note__c creditHeader : [Select ASI_CRM_Contract__c from ASI_CRM_Credit_Debit_Note__c where id in :header]) {
			if (creditHeader.ASI_CRM_Contract__c != null)
				this.set_contractID.add(creditHeader.ASI_CRM_Contract__c);
        }
    }
    
    public void getContractHeader() {
        this.map_contractID_ContractHeader = new Map<ID, ASI_TH_CRM_Contract__c>();
        Set<ID> contractIDs = this.set_contractID;
        for (ASI_TH_CRM_Contract__c contractHeader : [Select id, name from ASI_TH_CRM_Contract__c where id in :contractIDs]) {
            this.map_contractID_ContractHeader.put(contractHeader.id, contractHeader);
            initiateMapWithZero(contractHeader.id);
        }
        this.set_contractID = this.map_contractID_ContractHeader.keySet();
    }
    
    public void initiateMapWithZero(ID contractID){
        this.map_contractID_freeGoodsAmount_all.put(contractID, 0);
        this.map_contractID_freeGoodsAmount_approved.put(contractID, 0);
        this.map_contractID_freeGoodsAdhocAmount_all.put(contractID, 0);
        this.map_contractID_freeGoodsAdhocAmount_approved.put(contractID, 0);
        this.map_contractID_bottleIncentiveAmount_all.put(contractID, 0);
        this.map_contractID_bottleIncentiveAmount_approved.put(contractID, 0);
		this.map_contractID_contractMarginAmount_all.put(contractID, 0);
		this.map_contractID_contractMarginAmount_approved.put(contractID, 0);
        this.map_contractID_cashSponsorshipAmount_all.put(contractID, 0);
        this.map_contractID_cashSponsorshipAmount_approved.put(contractID, 0);
        this.map_contractID_tradeAnPExpensesAmount_all.put(contractID, 0);
        this.map_contractID_tradeAnPExpensesAmount_approved.put(contractID, 0);
        this.map_contractID_PaymentAnPAmount_approved.put(contractID, 0);
        this.map_contractID_freeGoodsAnPAmount_approved.put(contractID, 0);  
        this.map_contractID_salesSupportAmount_all.put(contractID, 0);
        this.map_contractID_salesSupportAmount_approved.put(contractID, 0);
        /* [VL 1.0] BEGIN */
        this.map_contractID_freeGoods9L_approved.put(contractID, 0);
        /* [VL 1.0] END */
        /* [VL 2.0] BEGIN */
        this.map_contractID_freeGoodsDuty_approved.put(contractID, 0);
        this.map_contractID_freeGoodsDuty_all.put(contractID, 0);
        this.map_contractID_freeGoodsFOB_approved.put(contractID, 0);
        this.map_contractID_freeGoodsFOB_all.put(contractID, 0);
        this.map_contractID_freeGoodsHandling_approved.put(contractID, 0);
        this.map_contractID_freeGoodsHandling_all.put(contractID, 0);
        /* [VL 2.0] END */
    }
    
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> getPayment() {
        Set<ID> contractIDs = this.set_contractID;
        List<ASI_TH_CRM_PaymentRequestLineItem__c> list_payment_temp = [
            SELECT ID, Name, 
            ASI_TH_CRM_Amount__c, ASI_CRM_SG_Type__c, ASI_CRM_Adjusted_Amount__c,
            ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,
            ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c
            FROM ASI_TH_CRM_PaymentRequestLineItem__c
            WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c IN : contractIDs
			AND RecordTypeID = :Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail')
			AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c != null 
            AND ASI_TH_CRM_Amount__c <> 0
            AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c <> : 'Rejected'
			/* [VL 5.0] BEGIN */
			AND ASI_CRM_Promotion_Detail__c = null
			/* [VL 5.0] END */
		];
        return list_payment_temp;
    }
    
    public List<ASI_FOC_Request_Item__c> getFOC() {
        Set<ID> contractIDs = this.set_contractID;
        List<ASI_FOC_Request_Item__c> list_FOC_temp = [
            SELECT ID, Name, 
            ASI_CRM_SG_FOC_Type__c, 
            ASI_CRM_SG_Unit_Price__c, ASI_FOC_Request_Quantity_Bottle__c , ASI_FOC_Actual_Quantity_Bottle__c ,
            ASI_CRM_Duty_Per_Bottle__c,
            ASI_CRM_FOB_Per_Bottle__c,
            ASI_CRM_Handling_Cost_Per_Bottle__c,
            ASI_CRM_IGC_Cost_Per_case__c,
            ASI_CRM_Selling_Price_Btl_PRS_WS__c,
            ASI_CRM_Selling_Price_Btl_WS_On_Trade__c,
            ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c,
            ASI_FOC_Request_Order__r.ASI_CRM_Contract__c,
            ASI_FOC_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c,
            ASI_FOC_SKU__r.ASI_HK_CRM_Packaging_Size__c
            FROM ASI_FOC_Request_Item__c
            WHERE ASI_FOC_Request_Order__r.ASI_CRM_Contract__c IN : contractIDs
            /*[WL 4.0] BEGIN*/
			//AND ASI_CRM_SG_Unit_Price__c > 0
			/*[WL 4.0] END*/
            AND ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c <> 'Rejected'
			AND ASI_FOC_Request_Order__r.ASI_CRM_Contract__c != null 
			AND (ASI_FOC_Request_Order__r.RecordTypeID = :Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC') 
				OR ASI_FOC_Request_Order__r.RecordTypeID = :Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC_Read_Only'))
			/* [VL 5.0] BEGIN */
			AND ASI_CRM_Promotion_Detail__c = null
			/* [VL 5.0] END */
		];
        return list_FOC_temp;
    }
    
    public List<ASI_CRM_Credit_Debit_Note_Line_Item__c> getCredit() {
        Set<ID> contractIDs = this.set_contractID;
        List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_credit_temp = [
            SELECT ID, Name, 
            ASI_CRM_Actual_Amount__c, ASI_CRM_Type__c, ASI_CRM_Amount__c,
            ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Contract__c,
            ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Status__c
            FROM ASI_CRM_Credit_Debit_Note_Line_Item__c
            WHERE ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Contract__c IN : contractIDs
			AND RecordTypeID = :Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note_Line_Item__cASI_CRM_SG_Contract_Margin_Credit_Note_Line_Item')
			AND ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Contract__c != null 
            AND ASI_CRM_Amount__c <> 0
            AND ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Status__c <> 'Rejected'];
        return list_credit_temp;
    }
    
    public List<ASI_CRM_Credit_Debit_Note_Line_Item__c> getDebit() {
        Set<ID> contractIDs = this.set_contractID;
        List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_debit_temp = [
            SELECT ID, Name, 
            ASI_CRM_Actual_Amount__c, ASI_CRM_Type__c, ASI_CRM_Amount__c,
            ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Contract__c,
            ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Status__c
            FROM ASI_CRM_Credit_Debit_Note_Line_Item__c
            WHERE ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Contract__c IN : contractIDs
			AND RecordTypeID = :Global_RecordTypeCache.getRtId('ASI_CRM_Credit_Debit_Note_Line_Item__cASI_CRM_SG_Contract_Margin_Debit_Note_Line_Item')
			AND ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Contract__c != null 
            AND ASI_CRM_Amount__c <> 0
            AND ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Status__c <> 'Rejected'];
        return list_debit_temp;
    }
    
    public void calculateROI() {
        if (!this.list_payment.isEmpty()) calculateROI_payment();
        if (!this.list_FOC.isEmpty()) calculateROI_foc();
        if (!this.list_credit.isEmpty()) calculateROI_credit();
        if (!this.list_debit.isEmpty()) calculateROI_debit();
        adjustAll();
        updateContract();
    }
    
    public void calculateROI_payment(){
        for (ASI_TH_CRM_PaymentRequestLineItem__c paymentItem : this.list_payment){
            ID contractID = paymentItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c;
            if (paymentItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Approved' || paymentItem.ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c == 'Final') {
                if (paymentItem.ASI_CRM_SG_Type__c == 'Cash - Upfront' || paymentItem.ASI_CRM_SG_Type__c == 'Cash - Target Achieved') {
                    map_contractID_cashSponsorshipAmount_approved.put(contractID, map_contractID_cashSponsorshipAmount_approved.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                } else 
                if (paymentItem.ASI_CRM_SG_Type__c == 'Bottle Incentive' || paymentItem.ASI_CRM_SG_Type__c == 'Back Rebates') {
                    /* [VL 3.0] BEGIN */
                    /*
                    map_contractID_bottleIncentiveAmount_approved.put(contractID, map_contractID_bottleIncentiveAmount_approved.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                    */
                    decimal bottleIncentiveAmount = paymentItem.ASI_CRM_Adjusted_Amount__c == null ? paymentItem.ASI_TH_CRM_Amount__c : paymentItem.ASI_CRM_Adjusted_Amount__c;
                    map_contractID_bottleIncentiveAmount_approved.put(contractID, map_contractID_bottleIncentiveAmount_approved.get(contractID) + bottleIncentiveAmount);
                    /* [VL 3.0] BEGIN */
                } else
                if (paymentItem.ASI_CRM_SG_Type__c == 'Ad-hoc Promotions' || 
					paymentItem.ASI_CRM_SG_Type__c == 'A&P Fund' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Product Branding Display' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Signages' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Advertising Spot' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Trade Incentive Trips' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Events'
                ) {
                    map_contractID_tradeAnPExpensesAmount_approved.put(contractID, map_contractID_tradeAnPExpensesAmount_approved.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                    map_contractID_PaymentAnPAmount_approved.put(contractID, map_contractID_PaymentAnPAmount_approved.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                } else 
                if (paymentItem.ASI_CRM_SG_Type__c == 'Sales Support') {
                    map_contractID_salesSupportAmount_approved.put(contractID, map_contractID_salesSupportAmount_approved.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                }
            } else {
                if (paymentItem.ASI_CRM_SG_Type__c == 'Cash - Upfront' || paymentItem.ASI_CRM_SG_Type__c == 'Cash - Target Achieved') {
                    map_contractID_cashSponsorshipAmount_all.put(contractID, map_contractID_cashSponsorshipAmount_all.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                } else 
                if (paymentItem.ASI_CRM_SG_Type__c == 'Bottle Incentive' || paymentItem.ASI_CRM_SG_Type__c == 'Back Rebates') {
                    /* [VL 3.0] BEGIN */
                    /*
                    map_contractID_bottleIncentiveAmount_all.put(contractID, map_contractID_bottleIncentiveAmount_approved.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                    */
                    decimal bottleIncentiveAmount = paymentItem.ASI_CRM_Adjusted_Amount__c == null ? paymentItem.ASI_TH_CRM_Amount__c : paymentItem.ASI_CRM_Adjusted_Amount__c;
                    /*[WL 6.0] BEGIN*/
					//map_contractID_bottleIncentiveAmount_all.put(contractID, map_contractID_bottleIncentiveAmount_approved.get(contractID) + bottleIncentiveAmount);
					map_contractID_bottleIncentiveAmount_all.put(contractID, map_contractID_bottleIncentiveAmount_all.get(contractID) + bottleIncentiveAmount);
					/*[WL 6.0] END*/
                    /* [VL 3.0] BEGIN */
                } else
                if (paymentItem.ASI_CRM_SG_Type__c == 'Ad-hoc Promotions' || 
					paymentItem.ASI_CRM_SG_Type__c == 'A&P Fund' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Product Branding Display' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Signages' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Advertising Spot' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Trade Incentive Trips' || 
                    paymentItem.ASI_CRM_SG_Type__c == 'Events'
                ) {
                    map_contractID_tradeAnPExpensesAmount_all.put(contractID, map_contractID_tradeAnPExpensesAmount_all.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                } else 
                if (paymentItem.ASI_CRM_SG_Type__c == 'Sales Support') {
                    map_contractID_salesSupportAmount_all.put(contractID, map_contractID_salesSupportAmount_all.get(contractID) + paymentItem.ASI_TH_CRM_Amount__c);
                }
            }
        }
		
		for (ID contractID : this.set_contractID){
			system.debug('Before Adjust All: contractID: ' + contractID + ' All Back Rebate Amt: ' + map_contractID_bottleIncentiveAmount_all.get(contractID) + ' Approved Back Rebate Amt: ' + map_contractID_bottleIncentiveAmount_approved.get(contractID));
		}
    }

    public void calculateROI_foc(){
        for (ASI_FOC_Request_Item__c focItem : this.list_FOC){
            ID contractID = focItem.ASI_FOC_Request_Order__r.ASI_CRM_Contract__c;
            if (focItem.ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c == 'Approved' || focItem.ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c == 'Final') {
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Cash Sponsorship' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Management Incentive' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Contract Sponsorship/Target Incentive'
                ) {
                    map_contractID_freeGoodsAmount_approved.put(contractID, map_contractID_freeGoodsAmount_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                    /* [VL 2.0] BEGIN */
                    map_contractID_freeGoodsDuty_approved.put(contractID, map_contractID_freeGoodsDuty_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Duty_Per_Bottle__c));
                    map_contractID_freeGoodsFOB_approved.put(contractID, map_contractID_freeGoodsFOB_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_FOB_Per_Bottle__c));
                    map_contractID_freeGoodsHandling_approved.put(contractID, map_contractID_freeGoodsHandling_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Handling_Cost_Per_Bottle__c));
                    /* [VL 2.0] END */
                } else 
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Sales Incentive') {
                    if (focItem.ASI_FOC_Actual_Quantity_Bottle__c > focItem.ASI_FOC_Request_Quantity_Bottle__c) {
                        map_contractID_freeGoodsAmount_approved.put(contractID, map_contractID_freeGoodsAmount_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                        map_contractID_freeGoodsAdhocAmount_approved.put(contractID, map_contractID_freeGoodsAdhocAmount_approved.get(contractID) + ((focItem.ASI_FOC_Actual_Quantity_Bottle__c - focItem.ASI_FOC_Request_Quantity_Bottle__c) * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                    } else {
                        map_contractID_freeGoodsAmount_approved.put(contractID, map_contractID_freeGoodsAmount_approved.get(contractID) + (focItem.ASI_FOC_Actual_Quantity_Bottle__c * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                    }
                    /* [VL 2.0] BEGIN */
                    map_contractID_freeGoodsDuty_approved.put(contractID, map_contractID_freeGoodsDuty_approved.get(contractID) + (focItem.ASI_FOC_Actual_Quantity_Bottle__c * focItem.ASI_CRM_Duty_Per_Bottle__c));
                    map_contractID_freeGoodsFOB_approved.put(contractID, map_contractID_freeGoodsFOB_approved.get(contractID) + (focItem.ASI_FOC_Actual_Quantity_Bottle__c * focItem.ASI_CRM_FOB_Per_Bottle__c));
                    map_contractID_freeGoodsHandling_approved.put(contractID, map_contractID_freeGoodsHandling_approved.get(contractID) + (focItem.ASI_FOC_Actual_Quantity_Bottle__c * focItem.ASI_CRM_Handling_Cost_Per_Bottle__c));
                    /* [VL 2.0] END */
                } else 
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Adhoc Promotion/Sponsorship'
                ) {
                    map_contractID_freeGoodsAdhocAmount_approved.put(contractID, map_contractID_freeGoodsAdhocAmount_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                    /* [VL 2.0] BEGIN */
                    map_contractID_freeGoodsDuty_approved.put(contractID, map_contractID_freeGoodsDuty_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Duty_Per_Bottle__c));
                    map_contractID_freeGoodsFOB_approved.put(contractID, map_contractID_freeGoodsFOB_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_FOB_Per_Bottle__c));
                    map_contractID_freeGoodsHandling_approved.put(contractID, map_contractID_freeGoodsHandling_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Handling_Cost_Per_Bottle__c));
                    /* [VL 2.0] END */
                } else 
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Anniversary'|| 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'A&P Fund' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Signages New - TOT' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Signages New - MOT' || focItem.ASI_CRM_SG_FOC_Type__c == 'Singages New - MOT' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Advertising Spot' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Events' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'GMA Purchases' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Commando Activity' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Sampling' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Replacement Bottle') {
                    map_contractID_tradeAnPExpensesAmount_approved.put(contractID, map_contractID_tradeAnPExpensesAmount_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_IGC_Cost_Per_case__c / focItem.ASI_FOC_SKU__r.ASI_HK_CRM_Packaging_Size__c));
                    map_contractID_freeGoodsAnPAmount_approved.put(contractID, map_contractID_freeGoodsAnPAmount_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_SG_Unit_Price__c));
                }
                /* [VL 1.0] BEGIN */
                this.map_contractID_freeGoods9L_approved.put(contractID, map_contractID_freeGoods9L_approved.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_FOC_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c / 900));
                /* [VL 1.0] END */
            } else {
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Cash Sponsorship' || focItem.ASI_CRM_SG_FOC_Type__c == 'Management Incentive' || focItem.ASI_CRM_SG_FOC_Type__c == 'Contract Sponsorship/Target Incentive') {
                    map_contractID_freeGoodsAmount_all.put(contractID, map_contractID_freeGoodsAmount_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                    /* [VL 2.0] BEGIN */
                    map_contractID_freeGoodsDuty_all.put(contractID, map_contractID_freeGoodsDuty_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Duty_Per_Bottle__c));
                    map_contractID_freeGoodsFOB_all.put(contractID, map_contractID_freeGoodsFOB_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_FOB_Per_Bottle__c));
                    map_contractID_freeGoodsHandling_all.put(contractID, map_contractID_freeGoodsHandling_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Handling_Cost_Per_Bottle__c));
                    /* [VL 2.0] END */
                } else 
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Sales Incentive') {
                    if (focItem.ASI_FOC_Actual_Quantity_Bottle__c > focItem.ASI_FOC_Request_Quantity_Bottle__c) {
                        map_contractID_freeGoodsAmount_all.put(contractID, map_contractID_freeGoodsAmount_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                        map_contractID_freeGoodsAdhocAmount_all.put(contractID, map_contractID_freeGoodsAdhocAmount_all.get(contractID) + ((focItem.ASI_FOC_Actual_Quantity_Bottle__c - focItem.ASI_FOC_Request_Quantity_Bottle__c) * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                    } else {
                        map_contractID_freeGoodsAmount_all.put(contractID, map_contractID_freeGoodsAmount_all.get(contractID) + (focItem.ASI_FOC_Actual_Quantity_Bottle__c * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                    }
                    /* [VL 2.0] BEGIN */
                    map_contractID_freeGoodsDuty_all.put(contractID, map_contractID_freeGoodsDuty_all.get(contractID) + (focItem.ASI_FOC_Actual_Quantity_Bottle__c * focItem.ASI_CRM_Duty_Per_Bottle__c));
                    map_contractID_freeGoodsFOB_all.put(contractID, map_contractID_freeGoodsFOB_all.get(contractID) + (focItem.ASI_FOC_Actual_Quantity_Bottle__c * focItem.ASI_CRM_FOB_Per_Bottle__c));
                    map_contractID_freeGoodsHandling_all.put(contractID, map_contractID_freeGoodsHandling_all.get(contractID) + (focItem.ASI_FOC_Actual_Quantity_Bottle__c * focItem.ASI_CRM_Handling_Cost_Per_Bottle__c));
                    /* [VL 2.0] END */
                } else 
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Adhoc Promotion/Sponsorship'
                ) {
                    map_contractID_freeGoodsAdhocAmount_all.put(contractID, map_contractID_freeGoodsAdhocAmount_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Selling_Price_Btl_PRS_WS__c));
                    /* [VL 2.0] BEGIN */
                    map_contractID_freeGoodsDuty_all.put(contractID, map_contractID_freeGoodsDuty_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Duty_Per_Bottle__c));
                    map_contractID_freeGoodsFOB_all.put(contractID, map_contractID_freeGoodsFOB_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_FOB_Per_Bottle__c));
                    map_contractID_freeGoodsHandling_all.put(contractID, map_contractID_freeGoodsHandling_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_Handling_Cost_Per_Bottle__c));
                    /* [VL 2.0] END */
                } else 
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Anniversary'|| 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'A&P Fund' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Signages New - TOT' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Signages New - MOT' || focItem.ASI_CRM_SG_FOC_Type__c == 'Singages New - MOT' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Advertising Spot' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Events' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'GMA Purchases' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Commando Activity' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Sampling' || 
                    focItem.ASI_CRM_SG_FOC_Type__c == 'Replacement Bottle') {
                    map_contractID_tradeAnPExpensesAmount_all.put(contractID, map_contractID_tradeAnPExpensesAmount_all.get(contractID) + (focItem.ASI_FOC_Request_Quantity_Bottle__c * focItem.ASI_CRM_IGC_Cost_Per_case__c / focItem.ASI_FOC_SKU__r.ASI_HK_CRM_Packaging_Size__c));
                }
            }
        }
    }
    
    public void calculateROI_credit(){
        for (ASI_CRM_Credit_Debit_Note_Line_Item__c creditItem : this.list_credit){
            ID contractID = creditItem.ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Contract__c;
            if (creditItem.ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Status__c == 'Approved' || creditItem.ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Status__c == 'Final') {
                if (creditItem.ASI_CRM_Type__c == 'Contract Margin') {
                    decimal contractMarginAmount = creditItem.ASI_CRM_Actual_Amount__c == null ? creditItem.ASI_CRM_Amount__c : creditItem.ASI_CRM_Actual_Amount__c;
                    map_contractID_contractMarginAmount_approved.put(contractID, map_contractID_contractMarginAmount_approved.get(contractID) + contractMarginAmount);
                }
            } else {
                if (creditItem.ASI_CRM_Type__c == 'Contract Margin') {
                    decimal contractMarginAmount = creditItem.ASI_CRM_Actual_Amount__c == null ? creditItem.ASI_CRM_Amount__c : creditItem.ASI_CRM_Actual_Amount__c;
                    map_contractID_contractMarginAmount_all.put(contractID, map_contractID_contractMarginAmount_all.get(contractID) + contractMarginAmount);
                }
            }
        }
    }

    public void calculateROI_debit(){
        for (ASI_CRM_Credit_Debit_Note_Line_Item__c creditItem : this.list_debit){
            ID contractID = creditItem.ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Contract__c;
            if (creditItem.ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Status__c == 'Approved' || creditItem.ASI_CRM_Credit_Debit_Note__r.ASI_CRM_Status__c == 'Final') {
                if (creditItem.ASI_CRM_Type__c == 'Contract Margin') {
                    decimal contractMarginAmount = creditItem.ASI_CRM_Actual_Amount__c == null ? creditItem.ASI_CRM_Amount__c : creditItem.ASI_CRM_Actual_Amount__c;
                    map_contractID_contractMarginAmount_approved.put(contractID, map_contractID_contractMarginAmount_approved.get(contractID) - contractMarginAmount);
                }
            } else {
                if (creditItem.ASI_CRM_Type__c == 'Contract Margin') {
                    decimal contractMarginAmount = creditItem.ASI_CRM_Actual_Amount__c == null ? creditItem.ASI_CRM_Amount__c : creditItem.ASI_CRM_Actual_Amount__c;
                    map_contractID_contractMarginAmount_all.put(contractID, map_contractID_contractMarginAmount_all.get(contractID) - contractMarginAmount);
                }
            }
        }
    }

    public void adjustAll(){
        for (ID contractID : this.set_contractID){
            map_contractID_freeGoodsAmount_all.put(contractID, map_contractID_freeGoodsAmount_all.get(contractID) + map_contractID_freeGoodsAmount_approved.get(contractID));
            map_contractID_freeGoodsAdhocAmount_all.put(contractID, map_contractID_freeGoodsAdhocAmount_all.get(contractID) + map_contractID_freeGoodsAdhocAmount_approved.get(contractID));
            map_contractID_bottleIncentiveAmount_all.put(contractID, map_contractID_bottleIncentiveAmount_all.get(contractID) + map_contractID_bottleIncentiveAmount_approved.get(contractID));
            map_contractID_contractMarginAmount_all.put(contractID, map_contractID_contractMarginAmount_all.get(contractID) + map_contractID_contractMarginAmount_approved.get(contractID));
            map_contractID_cashSponsorshipAmount_all.put(contractID, map_contractID_cashSponsorshipAmount_all.get(contractID) + map_contractID_cashSponsorshipAmount_approved.get(contractID));
            map_contractID_tradeAnPExpensesAmount_all.put(contractID, map_contractID_tradeAnPExpensesAmount_all.get(contractID) + map_contractID_tradeAnPExpensesAmount_approved.get(contractID));
            map_contractID_salesSupportAmount_all.put(contractID, map_contractID_salesSupportAmount_all.get(contractID) + map_contractID_salesSupportAmount_approved.get(contractID));
            /* [VL 2.0] BEGIN */
            map_contractID_freeGoodsDuty_all.put(contractID, map_contractID_freeGoodsDuty_all.get(contractID) + map_contractID_freeGoodsDuty_approved.get(contractID));
            map_contractID_freeGoodsFOB_all.put(contractID, map_contractID_freeGoodsFOB_all.get(contractID) + map_contractID_freeGoodsFOB_approved.get(contractID));
            map_contractID_freeGoodsHandling_all.put(contractID, map_contractID_freeGoodsHandling_all.get(contractID) + map_contractID_freeGoodsHandling_approved.get(contractID));
            /* [VL 2.0] END */
			
			system.debug('contractID: ' + contractID + ' All Back Rebate Amt: ' + map_contractID_bottleIncentiveAmount_all.get(contractID) + ' Approved Back Rebate Amt: ' + map_contractID_bottleIncentiveAmount_approved.get(contractID));
        }
    }
    
    public void updateContract(){
        List<ASI_TH_CRM_Contract__c> list_updateContract = new List<ASI_TH_CRM_Contract__c>();
        for (ID contractID : this.map_contractID_ContractHeader.keySet()) {
            ASI_TH_CRM_Contract__c contractHeader = this.map_contractID_ContractHeader.get(contractID);
            contractHeader.ASI_CRM_Free_Goods_Actual__c = map_contractID_freeGoodsAmount_approved.get(contractID);
            contractHeader.ASI_CRM_Free_Goods_Revised__c = map_contractID_freeGoodsAmount_all.get(contractID);
            contractHeader.ASI_CRM_Free_Goods_Ad_hoc_Actual__c = map_contractID_freeGoodsAdhocAmount_approved.get(contractID);
            contractHeader.ASI_CRM_Free_Goods_Ad_hoc_Revised__c = map_contractID_freeGoodsAdhocAmount_all.get(contractID);
            contractHeader.ASI_CRM_Cash_Sponsorship_Actual__c = map_contractID_cashSponsorshipAmount_approved.get(contractID);
            contractHeader.ASI_CRM_Cash_Sponsorship_Revised__c = map_contractID_cashSponsorshipAmount_all.get(contractID);
            contractHeader.ASI_CRM_Bottle_Incentive_Actual__c = map_contractID_bottleIncentiveAmount_approved.get(contractID);
            contractHeader.ASI_CRM_Bottle_Incentive_Revised__c = map_contractID_bottleIncentiveAmount_all.get(contractID);
			/*
            contractHeader.ASI_CRM_ContractMarginPriceOverwrite_Act__c = map_contractID_contractMarginAmount_approved.get(contractID);
            contractHeader.ASI_CRM_ContractMarginPriceOverwrite_Rev__c = map_contractID_contractMarginAmount_all.get(contractID);
			*/
            contractHeader.ASI_CRM_Trade_A_P_Expenses_Actual__c = map_contractID_tradeAnPExpensesAmount_approved.get(contractID);
            
            contractHeader.ASI_CRM_A_P_Payment_Actual__c = map_contractID_PaymentAnPAmount_approved.get(contractID);
            contractHeader.ASI_CRM_A_P_Free_Goods_Actual__c = map_contractID_freeGoodsAnPAmount_approved.get(contractID);

            contractHeader.ASI_CRM_Trade_A_P_Expenses_Revised__c = map_contractID_tradeAnPExpensesAmount_all.get(contractID);
            contractHeader.ASI_CRM_Sales_Support_Actual__c = map_contractID_salesSupportAmount_approved.get(contractID);
            contractHeader.ASI_CRM_Sales_Support_Revised__c = map_contractID_salesSupportAmount_all.get(contractID);
            /* [VL 1.0] BEGIN */
            contractHeader.ASI_CRM_Free_Goods_9L_Actual__c = map_contractID_freeGoods9L_approved.get(contractID);
            /* [VL 1.0] END */
            /* [VL 2.0] BEGIN */
            contractHeader.ASI_CRM_Total_Duty_Free_Goods_Revised__c = map_contractID_freeGoodsDuty_all.get(contractID);
            contractHeader.ASI_CRM_Total_Duty_Free_Goods_Actual__c = map_contractID_freeGoodsDuty_approved.get(contractID);
            contractHeader.ASI_CRM_Total_FOB_Free_Goods_Revised__c = map_contractID_freeGoodsFOB_all.get(contractID);
            contractHeader.ASI_CRM_Total_FOB_Free_Goods_Actual__c = map_contractID_freeGoodsFOB_approved.get(contractID);
            contractHeader.ASI_CRM_Total_Handling_Cost_FOC_Revised__c = map_contractID_freeGoodsHandling_all.get(contractID);
            contractHeader.ASI_CRM_Total_Handling_Cost_FOC_Actual__c = map_contractID_freeGoodsHandling_approved.get(contractID);
            /* [VL 2.0] END */
            list_updateContract.add(contractHeader);
        }
        Database.update(list_updateContract);
    }

}