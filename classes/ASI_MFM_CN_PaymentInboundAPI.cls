/***************************************************************************************************************************
* Name:        ASI_MFM_CN_PaymentInboundAPI
* Description: Restful API for returning ASI_MFM_Payment__c and their detail records
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-10-10		Kevin Choi				Created
* 2018-10-11        Alan Lau                Add methods to get/verify payment, VAT Invoice, payment request and payee line item data
* 2018-10-12        Alan Lau                Separate payee line item list into 3 lists by different types
* 2018-10-18		Vincent Lam				Add some new fields in the retrieved data
* 2018-10-31        Alan Lau                Add null handling for paymentId
* 2018-11-30        Vincent Lam             Get the prefix from ASI MFM Prefix table
****************************************************************************************************************************/
@RestResource(urlMapping='/ASI_MFM_CN_Payment_API/*')
global without sharing class ASI_MFM_CN_PaymentInboundAPI {

    global class PaymentresponseWrapper {
        public ASI_MFM_Payment__c payment;
        public List<ASI_MFM_VAT_Invoice__c> vatInvoiceList;
        public List<ASI_MFM_Payment_Line_Item__c> paymentLineItemList;
        public List<ASI_TH_CRM_PaymentRequest__c> paymentrequestList;
        public List<ASI_CRM_CN_PH_Payee_Line_Item__c> payeeLineItemCashList;
        public List<ASI_CRM_CN_PH_Payee_Line_Item__c> payeeLineItemDiscountList;
        public List<ASI_CRM_CN_PH_Payee_Line_Item__c> payeeLineItemOtherList;
        public String verificationResult;
        public String errorMessage;
    }
    //initialise get the payment id and analyse the pattern
	
	private static final list<string> LIST_PREFIX_PAYMENT = new list<string>{
		'Payment'
	};
	private static final list<string> LIST_PREFIX_STRUCTURECOST = new list<string>{
		'Structure Cost Accrual',
		'Structure Cost Rental Payment',
		'Structure Cost Payment'
	};
	private static final string PAYMENTTYPE_CONSUMER = 'Consumer A&P Payment';
	private static final string PAYMENTTYPE_STRUCTURECOST = 'Structure Cost';
	private static final string PAYMENTTYPE_TRADE = 'Trade A&P Payment';

    @HttpGet
    global static PaymentresponseWrapper retrievePaymentIdAndConfirmation() {
        String paymentId = RestContext.request.params.get('paymentId');
        String isPaymentConfirmed = RestContext.request.params.get('confirmed');
        PaymentresponseWrapper response = new PaymentresponseWrapper();

        if(paymentId == null) {
            response.errorMessage = 'paymentId is null';
            return response;
        }
		
		String paymentType = retrievePaymentType(paymentId);

		/*
        if (paymentId.startsWith('CT') || paymentId.startsWith('CB')) {
            response = retrievePaymentAndInvoice(paymentId);
        } else if (paymentId.startsWith('SCPayment') || paymentId.startsWith('SCCAPXPayment') || paymentId.startsWith('SCRentalPayment')) {
            response = retrievePayment(paymentId);
        } else {
            response = retrievePaymentRequestAndPayeeLineItem(paymentId);
        }

        if (isPaymentConfirmed != null) {
            if (paymentId.startsWith('CT') || paymentId.startsWith('CB') || paymentId.startsWith('SCPayment') || paymentId.startsWith('SCCAPXPayment') || paymentId.startsWith('SCRentalPayment')) {
                response.verificationResult = verifyPayment(isPaymentConfirmed, paymentId);
            } else {
                response.verificationResult = verifyPaymentRequest(isPaymentConfirmed, paymentId);
            }
        }
		*/
        if (paymentType == PAYMENTTYPE_CONSUMER) {
            response = retrievePaymentAndInvoice(paymentId);
        } else if (paymentType == PAYMENTTYPE_STRUCTURECOST) {
            response = retrievePayment(paymentId);
        } else {
            response = retrievePaymentRequestAndPayeeLineItem(paymentId);
        }

        if (isPaymentConfirmed != null) {
            if (paymentType == PAYMENTTYPE_CONSUMER || paymentType == PAYMENTTYPE_STRUCTURECOST) {
                response.verificationResult = verifyPayment(isPaymentConfirmed, paymentId);
            } else {
                response.verificationResult = verifyPaymentRequest(isPaymentConfirmed, paymentId);
            }
        }

        return response;
    }

    private static String verifyPayment(String isPaymentConfirmed, String paymentId) {
        String verificationResult = paymentId + ' Verification FAILED';

        if (isPaymentConfirmed.trim() == 'true') {
            ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c();

            payment = [
                    SELECT Id,
                            ASI_MFM_Pass_Verification__c
                    FROM ASI_MFM_Payment__c
                    WHERE Name = :paymentId
                    LIMIT 1
            ];

            if (payment != null) {
                payment.ASI_MFM_Pass_Verification__c = true;

                update payment;
                verificationResult = paymentId + 'Verification SUCCEED';
            }
        }

        return verificationResult;
    }

    private static String verifyPaymentRequest(String isPaymentConfirmed, String paymentId) {
        String verificationResult = paymentId + ' Verification FAILED';

        if (isPaymentConfirmed.trim() == 'true') {
            ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();

            paymentRequest = [
                    SELECT Id,
                            ASI_CRM_Pass_Verification__c
                    FROM ASI_TH_CRM_PaymentRequest__c
                    WHERE Name = :paymentId
                    LIMIT 1
            ];

            if (paymentRequest != null) {
                paymentRequest.ASI_CRM_Pass_Verification__c = true;

                update paymentRequest;
                verificationResult = paymentId + 'Verification SUCCEED';
            }
        }

        return verificationResult;
    }

	private static string retrievePaymentType(String paymentId){
		// get all consumer a&p prefix
		for(ASI_MFM_Prefix__c prefix : retrievePrefix(LIST_PREFIX_PAYMENT)){
			if(paymentId.startsWith(prefix.name)){
				return PAYMENTTYPE_CONSUMER;
			}
		}
		// get all structure cost prefix
		for(ASI_MFM_Prefix__c prefix : retrievePrefix(LIST_PREFIX_STRUCTURECOST)){
			if(paymentId.startsWith(prefix.name)){
				return PAYMENTTYPE_STRUCTURECOST;
			}
		}
		// else
		return PAYMENTTYPE_TRADE;
	}
	
	private static list<ASI_MFM_Prefix__c> retrievePrefix(list<string> list_type){
		string RTID = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_CN_Prefix');
		
		return [
			select name 
			from ASI_MFM_Prefix__c
			where 
			recordtypeid = :RTID
			and ASI_MFM_Module__c in :list_type
		];
	}
	
    private static PaymentresponseWrapper retrievePaymentAndInvoice(String paymentId) {
        PaymentresponseWrapper result = new PaymentresponseWrapper();

        result.payment = retrieveCPaymentHeader(paymentId);
        result.paymentLineItemList = retrieveCPaymentLineItemList(result.payment.id);
        result.vatInvoiceList = retrieveVatInvoiceList(result.payment.id);

        result = clearAllEmptyList(result);

        return result;
    }

    private static PaymentresponseWrapper retrievePayment(String paymentId) {
        PaymentresponseWrapper result = new PaymentresponseWrapper();

        result.payment = retrievePaymentHeader(paymentId);

        result = clearAllEmptyList(result);

        return result;
    }

    private static PaymentresponseWrapper retrievePaymentRequestAndPayeeLineItem(String paymentId) {
        PaymentresponseWrapper result = new PaymentresponseWrapper();
        List<String> paymentRequestHeaderIdList = new List<String>();
        List<String> cashTypeList = new List<String>{
                'Cash'
        };
        List<String> discountTypeList = new List<String>{
                'Discount'
        };
        List<String> otherTypeList = new List<String>{
                'Others', 'CD'
        };

        result.paymentrequestList = retrievePaymentRequestHeaderList(paymentId);
        for (ASI_TH_CRM_PaymentRequest__c paymentRequestHeader : result.paymentrequestList) {
            paymentRequestHeaderIdList.add(paymentRequestHeader.id);
        }
        result.payeeLineItemCashList = retrievePayeeLineItemList(paymentRequestHeaderIdList, cashTypeList);
        result.payeeLineItemDiscountList = retrievePayeeLineItemList(paymentRequestHeaderIdList, discountTypeList);
        result.payeeLineItemOtherList = retrievePayeeLineItemList(paymentRequestHeaderIdList, otherTypeList);

        result = clearAllEmptyList(result);

        return result;
    }

    private static ASI_MFM_Payment__c retrievePaymentHeader(String paymentId) {
        List<String> recordTypeDeveloperNameList = new List<String>{
                'ASI_MFM_CAP_CN_StructureCost_Payment'
        };
        ASI_MFM_Payment__c paymentHeader = new ASI_MFM_Payment__c();

        paymentHeader = [
                SELECT Id,
                        ASI_MFM_Supplier_Name__r.Name,
                        ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c,
                        ASI_MFM_Department_Text__c,
                        ASI_MFM_Expense_Type__r.Name,
                        ASI_MFM_BU__r.Name,
                        ASI_MFM_CN_Fiscal_Year__c,
                        ASI_MFM_Currency__c,
                        ASI_MFM_Payment_Amount__c,
                        ASI_MFM_Invoice_Amount__c,
                        ASI_MFM_Normal_Invoice_Amount__c,
                        ASI_MFM_No_Invoice_Amount__c,
                        ASI_MFM_VAT_Amount__c,
                        ASI_MFM_Payment_Amount_RMB__c,
                        ASI_MFM_Tax_Code__r.Name,
                        ASI_MFM_Remarks__c,
                        ASI_MFM_Invoice_Afterwards__c,
                        ASI_MFM_G_L_Date__c,
                        ASI_MFM_Invoice_Number__c
            			,LastModifiedBy.Name,LastModifiedBy.Alias,LastModifiedBy.Email,LastModifiedBy.Username
            			,ASI_MFM_Submitter__r.Name,ASI_MFM_Submitter__r.Alias,ASI_MFM_Submitter__r.Email,ASI_MFM_Submitter__r.Username
                FROM ASI_MFM_Payment__c
                WHERE Name = :paymentId AND RecordType.DeveloperName IN :recordTypeDeveloperNameList
                LIMIT 1
        ];

        return paymentHeader;
    }

    private static ASI_MFM_Payment__c retrieveCPaymentHeader(String paymentId) {
        List<String> recordTypeDeveloperNameList = new List<String>{
                'ASI_MFM_CN_Payment', 'ASI_MFM_CN_Payment_Read_Only'
        };
        ASI_MFM_Payment__c paymentHeader = new ASI_MFM_Payment__c();

        paymentHeader = [
                SELECT Id,
                        ASI_MFM_BU__r.Name,
                        ASI_MFM_Supplier_Name__r.Name,
                        ASI_MFM_CN_Tax_Code_Picklist__c,
                        ASI_MFM_VAT_Rate__c,
                        ASI_MFM_Payment_Amount__c,
                        ASI_MFM_G_L_Date__c,
                        ASI_MFM_CN_Payment_Amount_Net_of_Tax__c,
                        ASI_MFM_Budget_Owner__r.Name,
                        Owner.Name,
                        ASI_MFM_PaymentDate__c,
                        ASI_MFM_Currency__c,
                        ASI_MFM_Pre_payment__c,
                        ASI_MFM_One_Off_Payee__c,
                        ASI_MFM_AlternatePayee__r.Name,
                        ASI_MFM_Invoice_Afterwards__c,
                        ASI_MFM_Entertainment__c,
                        ASI_MFM_No_Invoice_Amount__c,
                        ASI_MFM_Entertainment_Amount__c,
                        ASI_MFM_Invoice_Number__c
            			,LastModifiedBy.Name,LastModifiedBy.Alias,LastModifiedBy.Email,LastModifiedBy.Username
            			,ASI_MFM_Submitter__r.Name,ASI_MFM_Submitter__r.Alias,ASI_MFM_Submitter__r.Email,ASI_MFM_Submitter__r.Username
                FROM ASI_MFM_Payment__c
                WHERE Name = :paymentId AND RecordType.DeveloperName IN :recordTypeDeveloperNameList
                LIMIT 1
        ];

        return paymentHeader;
    }

    private static List<ASI_MFM_Payment_Line_Item__c> retrieveCPaymentLineItemList(String paymentHeaderId) {
        List<ASI_MFM_Payment_Line_Item__c> paymentLineItemList = new List<ASI_MFM_Payment_Line_Item__c>();

        paymentLineItemList = [
                SELECT Id,
                        ASI_MFM_PO__r.Name,
                        ASI_MFM_CN_Invoice_Amount__c,
                        ASI_MFM_Tax_Amount__c,
                        ASI_MFM_Payment_Amount_Net_of_Tax__c,
                        ASI_MFM_Payment_Date__c,
                        Name
            			,LastModifiedBy.Name,LastModifiedBy.Alias,LastModifiedBy.Email,LastModifiedBy.Username
                FROM ASI_MFM_Payment_Line_Item__c
                WHERE ASI_MFM_Payment__c = :paymentHeaderId
        ];

        return paymentLineItemList;
    }

    private static List<ASI_MFM_VAT_Invoice__c> retrieveVatInvoiceList(String paymentHeaderId) {
        List<ASI_MFM_VAT_Invoice__c> vatInvoiceList = new List<ASI_MFM_VAT_Invoice__c>();

        vatInvoiceList = [
                SELECT Id,
                        Name,
                        ASI_MFM_Invoice_Type__c,
                        ASI_MFM_Invoice_Date__c,
                        ASI_MFM_Invoice_Code__c,
                        ASI_MFM_Invoice_Amount__c,
                        AS_MFM_Invoice_Amount_Before_Tax__c,
                        ASI_MFM_Currency__c,
                        ASI_MFM_BU__r.Name,
                        ASI_MFM_Supplier__r.Name,
                        ASI_MFM_Tax_Code__r.Name,
                        ASI_MFM_Remarks__c,
                        ASI_MFM_Attachment_Link__c,
                        ASI_MFM_Index_Number__c,
                        ASI_MFM_PO_No__r.Name,
                        ASI_MFM_External_ID__c,
						ASI_MFM_PO_Type__c,
						ASI_MFM_Payment_Date__c,
						ASI_MFM_Payment_No__r.ASI_MFM_G_L_Date__c
            			,LastModifiedBy.Name,LastModifiedBy.Alias,LastModifiedBy.Email,LastModifiedBy.Username
            			,ASI_MFM_Payment_No__r.ASI_MFM_Submitter__r.Name,ASI_MFM_Payment_No__r.ASI_MFM_Submitter__r.Alias,ASI_MFM_Payment_No__r.ASI_MFM_Submitter__r.Email,ASI_MFM_Payment_No__r.ASI_MFM_Submitter__r.Username
                FROM ASI_MFM_VAT_Invoice__c
                WHERE ASI_MFM_Payment_No__c = :paymentHeaderId
        ];

        return vatInvoiceList;
    }

    private static List<ASI_TH_CRM_PaymentRequest__c> retrievePaymentRequestHeaderList(String paymentId) {
        List<String> recordTypeDeveloperNameList = new List<String>{
                'ASI_CRM_CN_Payment_Request'
        };
        List<ASI_TH_CRM_PaymentRequest__c> paymentRequestHeaderList = new List<ASI_TH_CRM_PaymentRequest__c>();

        paymentRequestHeaderList = [
                SELECT Id,
                        Name, ASI_TH_CRM_GL_Date__c
            			,LastModifiedBy.Name,LastModifiedBy.Alias,LastModifiedBy.Email,LastModifiedBy.Username
            			,ASI_CRM_Finance_Last_Updated_By__r.Name,ASI_CRM_Finance_Last_Updated_By__r.Alias,ASI_CRM_Finance_Last_Updated_By__r.Email,ASI_CRM_Finance_Last_Updated_By__r.Username
                FROM ASI_TH_CRM_PaymentRequest__c
                WHERE Name = :paymentId AND RecordType.DeveloperName IN :recordTypeDeveloperNameList
        ];

        return paymentRequestHeaderList;
    }

    private static List<ASI_CRM_CN_PH_Payee_Line_Item__c> retrievePayeeLineItemList(List<String> paymentRequestHeaderIdList, List<String> type) {
        List<ASI_CRM_CN_PH_Payee_Line_Item__c> payeeLineItemList = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();

        payeeLineItemList = [
                SELECT ASI_CRM_CN_Payee_T2__r.Name,
                        ASI_CRM_CN_Payee_T1__r.Name,
						ASI_CRM_CN_Cash_Payee_Name_T1__r.Name,
                        ASI_CRM_CN_Amount__c,
                        ASI_CRM_CN_Reason__c,
                        ASI_CRM_CN_Instruction_Sent_Time__c,
                        ASI_CRM_CN_Comfirm_Receipt__c,
                        ASI_CRM_CN_Type__c,
						ASI_CRM_CN_Payment_Request__r.ASI_TH_CRM_GL_Date__c, ASI_CRM_CN_Invoice_Number__c
            			,LastModifiedBy.Name,LastModifiedBy.Alias,LastModifiedBy.Email,LastModifiedBy.Username
            			,ASI_CRM_Finance_Last_Updated_By__r.Name,ASI_CRM_Finance_Last_Updated_By__r.Alias,ASI_CRM_Finance_Last_Updated_By__r.Email,ASI_CRM_Finance_Last_Updated_By__r.Username
                FROM ASI_CRM_CN_PH_Payee_Line_Item__c
                WHERE ASI_CRM_CN_Payment_Request__c IN :paymentRequestHeaderIdList AND ASI_CRM_CN_Type__c IN :type
        ];

        return payeeLineItemList;
    }

    private static PaymentresponseWrapper clearAllEmptyList(PaymentresponseWrapper result) {
        result.payeeLineItemCashList = clearEmptyList(result.payeeLineItemCashList);

        result.payeeLineItemDiscountList = clearEmptyList(result.payeeLineItemDiscountList);

        result.payeeLineItemOtherList = clearEmptyList(result.payeeLineItemOtherList);

        result.paymentrequestList = clearEmptyList(result.paymentrequestList);

        result.paymentLineItemList = clearEmptyList(result.paymentLineItemList);

        result.vatInvoiceList = clearEmptyList(result.vatInvoiceList);

        return result;
    }

    private static List<sObject> clearEmptyList(List<sObject> itemList) {
        if (itemList != null && itemList.isEmpty()) {
            itemList = null;
        }

        return itemList;
    }

}