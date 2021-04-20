public with sharing class ASI_CRM_JP_InputPaymentItemsControllerV2 {

	public Id paymentInvoiceId{
		get; set;
	}

	public ASI_CRM_Payment_Invoice__c paymentInvoice{
		get; set;
	}

	public Boolean isCashRebate{
        get; set;
	}

	public String recordType{
		get; set;
	}

	public String contractLineItemCustomCriteria{
		get; set;
	}

	public String paymentLineItemCustomCriteria{
		get; set;
	}

	public String addedInvoiceLineItemsJsonString{
		get {
			return JSON.serialize(addedInvoiceLineItems);
		} set;
	}

	public final String apEntPicklistSelectOptionString{
		get {
			return JSON.serialize(apEntPicklistSelectOption);
		} set;
	}

	public static String RECORD_TYPE_OPT_REBATE{
		get; set;
	}
	public static String RECORD_TYPE_OPT_AP{
		get; set;
	}

	public final Map<String, String> apEntPicklistSelectOption = new Map<String, String>();
	public final List<ASI_CRM_Payment_Invoice_Line_Item__c> addedInvoiceLineItems = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();


	{
		RECORD_TYPE_OPT_REBATE = 'Rebate';
		RECORD_TYPE_OPT_AP = 'AP';
	}

	public ASI_CRM_JP_InputPaymentItemsControllerV2() {

		//		addedInvoiceLineItems = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
		paymentInvoiceId = ApexPages.currentPage().getParameters().get('id');
		recordType = ApexPages.currentPage().getParameters().get('recordtypeOpt');
        system.debug('recordType:' + recordType);
		paymentInvoice = ASI_CRM_JP_DataService.getPaymentInvoiceById(paymentInvoiceId);
        system.debug('paymentInvoice:' + paymentInvoice);
        system.debug('paymentInvoice.RecordType.DeveloperName:' + paymentInvoice.RecordType.DeveloperName);
        
        isCashRebate = false;//@todo
        if(recordType == 'AP') {
            isCashRebate = true;
        }

		contractLineItemCustomCriteria = getContractLineItemCustomCriteriaString(paymentInvoice, isCashRebate);
        system.debug('contractLineItemCustomCriteria:' + contractLineItemCustomCriteria);
      //  if(!test.isRunningTest()){
		paymentLineItemCustomCriteria = getPaymentLineItemCustomCriteriaString(paymentInvoiceId, recordType);
        system.debug('paymentLineItemCustomCriteria:' + paymentLineItemCustomCriteria);
       // }else{
	//	paymentLineItemCustomCriteria='test';
      //  }
		initializePickList(apEntPicklistSelectOption);
	}

	public static String getPaymentLineItemCustomCriteriaString(Id paymentInvoiceId, String recordType) {

		final Id paymentLineItemRecordTypeId = getPaymentLineItemRecordTypeId(recordType);
		String paymentLineItemCustomCriteria = '';
		paymentLineItemCustomCriteria +=
				' ASI_CRM_Payment_Invoice__c = ' + ASI_CRM_QueryUtil.encloseWithQuotes(paymentInvoiceId);
		paymentLineItemCustomCriteria +=
				' AND RecordTypeId = ' + ASI_CRM_QueryUtil.encloseWithQuotes(paymentLineItemRecordTypeId);

		return paymentLineItemCustomCriteria;
	}

	public static String getContractLineItemCustomCriteriaString(ASI_CRM_Payment_Invoice__c paymentInvoice, boolean isCashRebate) {

		final DateTime startDate = paymentInvoice.ASI_CRM_From_Month__c;
		final DateTime endDate =
				paymentInvoice.ASI_CRM_To_Month__c == null ? startDate : paymentInvoice.ASI_CRM_To_Month__c;
		final String startDateSting = ASI_CRM_QueryUtil.getDateForQuery(startDate);
		final String endDateSting = ASI_CRM_QueryUtil.getDateForQuery(endDate);
        
        final String indirectRebateInvoice = 'ASI_CRM_JP_Indirect_Rebate_Invoice';
        final String jpCashInvoice = 'ASI_CRM_JP_Cash_Invoice';
        final String sptdCashInvoice = 'ASI_CRM_JP_SPTD_Cash_Invoice';
        final String sptdFocInvoice = 'ASI_CRM_JP_SPTD_FOC_Invoice';
        
		Id recordTypeId = null;
        if(isCashRebate && paymentInvoice.RecordType.DeveloperName == jpCashInvoice) {
            recordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_Purchase_Contract_Line_Item__c.sObjectType,
				ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_SPTD_Contract_Line_Item.name()
            );
        }
        else {
            recordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_Purchase_Contract_Line_Item__c.sObjectType,
				ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_Indirect_Rebate_Contract_Line_Item.name()
            );
        }

		String contractLineItemCustomCriteria = '';
		contractLineItemCustomCriteria += ' RecordTypeId = ' + ASI_CRM_QueryUtil.encloseWithQuotes(recordTypeId + '');
		contractLineItemCustomCriteria += ' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Status__c = ' +
				ASI_CRM_QueryUtil.encloseWithQuotes('Activated');
		contractLineItemCustomCriteria += ' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Remaining_Balance__c > 0';
        
        //Filter FOC payment methods only
        if(paymentInvoice.RecordType.DeveloperName == sptdFocInvoice) {
            contractLineItemCustomCriteria += ' AND (ASI_CRM_Payment_Method__c like \'FOC%\' OR ASI_CRM_Payment_Method__c like \'商品現品%\') ';
        }
        
        //Filter NOT FOC payment methods only
        if(paymentInvoice.RecordType.DeveloperName == sptdCashInvoice 
           || (paymentInvoice.RecordType.DeveloperName == jpCashInvoice && isCashRebate) ) {
            contractLineItemCustomCriteria += ' AND ((NOT ASI_CRM_Payment_Method__c like \'FOC%\') AND (NOT ASI_CRM_Payment_Method__c like \'商品現品%\') ) ';
        }
        
        system.debug('contractLineItemCustomCriteria:' + contractLineItemCustomCriteria);
        
        if(paymentInvoice.RecordType.DeveloperName == indirectRebateInvoice 
           || (paymentInvoice.RecordType.DeveloperName == jpCashInvoice && !isCashRebate)) {
            contractLineItemCustomCriteria +=
                    ' AND ((ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= ' + startDateSting;
            contractLineItemCustomCriteria +=
                    ' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c >= ' + startDateSting + ')';
            contractLineItemCustomCriteria +=
                    ' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c >= ' + endDateSting + '';
            contractLineItemCustomCriteria +=
                    ' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= ' + endDateSting + ')';
            contractLineItemCustomCriteria +=
                    ' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c > ' + startDateSting + '';
            contractLineItemCustomCriteria +=
                    ' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c < ' + endDateSting + ')';
            contractLineItemCustomCriteria +=
                    ' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= ' + startDateSting + '';
            contractLineItemCustomCriteria += ' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c = NULL) )';
        }

        String payTo_Filter = '';
        if(paymentInvoice.RecordType.DeveloperName == indirectRebateInvoice 
           || (paymentInvoice.RecordType.DeveloperName == jpCashInvoice && !isCashRebate)) {
            payTo_Filter = paymentInvoice.ASI_CRM_Pay_To__r.Name == null ? '' : paymentInvoice.ASI_CRM_Pay_To__r.Name;
        }
        system.debug('payTo_Filter:' + payTo_Filter);
        //no usage here, copy from old version ASI_CRM_JP_InputPaymentItemsController
        /*
        if(paymentInvoice.RecordType.DeveloperName == indirectRebateInvoice 
           || (paymentInvoice.RecordType.DeveloperName == jpCashInvoice && !isCashRebate)) {
            contractLineItemCustomCriteria += ' AND ASI_CRM_Pay_To__r.name like \'' + String.escapeSingleQuotes(payTo_Filter.trim()) + '%\' ';
        }
        
        contractLineItemCustomCriteria += ' and ASI_CRM_Purchase_Contract__r.owner.firstName = \'' + UserInfo.getFirstName() + '\' and ASI_CRM_Purchase_Contract__r.owner.lastname = \'' + UserInfo.getLastName() + '\' ';   
		*/        

		return contractLineItemCustomCriteria;
	}


	public void addPaymentInvoiceLineItem() {

		final Map <String, String> parameters = ApexPages.currentPage().getParameters();
		final Id purchaseContractLineItemId = parameters.get('purchaseContractLineItemId');
		final ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem =
				ASI_CRM_JP_DataService.getPurchaseContractLineItemById(purchaseContractLineItemId);
		final ASI_CRM_Payment_Invoice_Line_Item__c paymentInvoiceItem = createPaymentInvoiceLineItem(
				paymentInvoice, purchaseContractLineItem
		);

		if (!recordType.contains('Rebate')) {
			paymentInvoiceItem.ASI_CRM_Actual_Quantity__c = purchaseContractLineItem.ASI_CRM_Quantity__c;
			paymentInvoiceItem.ASI_CRM_Sales_Result__c = purchaseContractLineItem.ASI_CRM_Target_Volume__c;
		}

		System.debug('recordType');
		System.debug(recordType);
		System.debug('paymentInvoice');
		System.debug(paymentInvoice);
		paymentInvoiceItem.RecordTypeId = getPaymentLineItemDefaultRecordTypeId(paymentInvoice, recordType);

		addedInvoiceLineItems.clear();
		addedInvoiceLineItems.add(paymentInvoiceItem);
	}

	public void addAllPaymentInvoiceLineItem() {

		final Map <String, String> parameters = ApexPages.currentPage().getParameters();
		final List<Id> purchaseContractLineItemIds = (List<Id>) JSON.deserialize(
				parameters.get('purchaseContractLineItemIds'), List<Id>.class
		);
		final Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c> idPurchaseContractLineItemMap =
				ASI_CRM_JP_DataService.getIdPurchaseContractLIneItemMap(purchaseContractLineItemIds);

		final List<ASI_CRM_Payment_Invoice_Line_Item__c> paymentInvoiceLineItems =
				new List<ASI_CRM_Payment_Invoice_Line_Item__c>();

		for (Id i : idPurchaseContractLineItemMap.keySet()) {
			final ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem = idPurchaseContractLineItemMap.get(
					i
			);

			final ASI_CRM_Payment_Invoice_Line_Item__c paymentInvoiceItem = createPaymentInvoiceLineItem(
					paymentInvoice, purchaseContractLineItem
			);

			if (!recordType.contains('Rebate')) {
				paymentInvoiceItem.ASI_CRM_Actual_Quantity__c = purchaseContractLineItem.ASI_CRM_Quantity__c;
				paymentInvoiceItem.ASI_CRM_Sales_Result__c = purchaseContractLineItem.ASI_CRM_Target_Volume__c;
			}
			paymentInvoiceItem.RecordTypeId = getPaymentLineItemDefaultRecordTypeId(paymentInvoice, recordType);

			paymentInvoiceLineItems.add(paymentInvoiceItem);
		}

		addedInvoiceLineItems.clear();
		addedInvoiceLineItems.addAll(paymentInvoiceLineItems);
	}

	public static ASI_CRM_Payment_Invoice_Line_Item__c createPaymentInvoiceLineItem(
			ASI_CRM_Payment_Invoice__c paymentInvoice,
			ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem) {

		final ASI_CRM_Payment_Invoice_Line_Item__c paymentInvoiceItem = new ASI_CRM_Payment_Invoice_Line_Item__c();

		paymentInvoiceItem.ASI_CRM_Payment_Invoice__c = paymentInvoice.Id;
		paymentInvoiceItem.ASI_CRM_Purchase_Contract_Line_Item__c = purchaseContractLineItem.Id;
		paymentInvoiceItem.ASI_CRM_Purchase_Contract_Line_Item__r = purchaseContractLineItem;
		paymentInvoiceItem.ASI_CRM_Contract_No__c = purchaseContractLineItem.ASI_CRM_Purchase_Contract__c;
		paymentInvoiceItem.ASI_CRM_Actual_Unit_Cost__c = purchaseContractLineItem.ASI_CRM_Unit_Price__c;
		paymentInvoiceItem.ASI_CRM_Sys_BS_Retailer_Ship_To__c = purchaseContractLineItem.ASI_CRM_BS_Retailer_Ship_To__c;
		paymentInvoiceItem.ASI_CRM_SYS_Outlet__c = purchaseContractLineItem.ASI_CRM_Outlet__c;
		paymentInvoiceItem.ASI_CRM_Item_Group__c = purchaseContractLineItem.ASI_CRM_Item_Group__r.Name;
		paymentInvoiceItem.ASI_CRM_Sys_Representative_SKU_Id__c =
				purchaseContractLineItem.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c;
		paymentInvoiceItem.ASI_CRM_Sys_Alternative_SKU_Id__c =
				purchaseContractLineItem.ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c;
		paymentInvoiceItem.ASI_CRM_SKU__c =
				purchaseContractLineItem.ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c;
		paymentInvoiceItem.ASI_CRM_Rebate_Type__c = purchaseContractLineItem.ASI_CRM_Rebate_Type__c;

		paymentInvoiceItem.ASI_CRM_A_P_Entertainment_F_D_Code__c = 'A&P';
		paymentInvoiceItem.ASI_CRM_BC_Code__c = 'B';
		paymentInvoiceItem.ASI_CRM_SKU_Selection__c = 'Representative SKU';

		if (paymentInvoice.RecordType.DeveloperName.equals(
				ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_SPTD_FOC_Invoice.name())) {

			paymentInvoiceItem.ASI_CRM_AP_Code__c = purchaseContractLineItem.ASI_CRM_Sys_AP_Code__c;
		}

		return paymentInvoiceItem;
	}

	public static Id getPaymentLineItemDefaultRecordTypeId(ASI_CRM_Payment_Invoice__c paymentInvoice,
														   String recordType) {

		final String RECORD_TYPE_OPT_REBATE = 'Rebate';
		final String RECORD_TYPE_OPT_AP = 'AP';
		final Map<Id, String> recordTypeIdApiNameMap =  ASI_CRM_RecordTypeUtil.getRecordTypeIdApiNameMap(
				paymentInvoice.getSObjectType()
		);

		String paymentInvoiceRecordTypeDeveloperName = '';
		if (paymentInvoice.RecordType != null && String.isNotBlank(paymentInvoice.RecordType.DeveloperName)) {
			paymentInvoiceRecordTypeDeveloperName = paymentInvoice.RecordType.DeveloperName;
		} else {
			paymentInvoiceRecordTypeDeveloperName = recordTypeIdApiNameMap.get(paymentInvoice.RecordTypeId);
		}
		System.debug('paymentInvoiceRecordTypeDeveloperName');
		System.debug(paymentInvoiceRecordTypeDeveloperName);
		System.debug(recordType);
		System.debug(RECORD_TYPE_OPT_AP);
		String paymentLineItemDefaultRecordType = '';
		if (ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_Indirect_Rebate_Invoice.name().equals(
				paymentInvoiceRecordTypeDeveloperName)) {

			paymentLineItemDefaultRecordType =
					ASI_CRM_RecordType.ASI_CRM_Payment_Invoice_Line_Item.ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item.name();

		} else if (ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_SPTD_Cash_Invoice.name().equals(
				paymentInvoiceRecordTypeDeveloperName)) {

			paymentLineItemDefaultRecordType =
					ASI_CRM_RecordType.ASI_CRM_Payment_Invoice_Line_Item.ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item.name();

		} else if (ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_SPTD_FOC_Invoice.name().equals(
				paymentInvoiceRecordTypeDeveloperName)) {

			paymentLineItemDefaultRecordType =
					ASI_CRM_RecordType.ASI_CRM_Payment_Invoice_Line_Item.ASI_CRM_JP_SPTD_FOC_Invoice_Line_Item.name();

		} else if (ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_Cash_Invoice.name().equals(
				paymentInvoiceRecordTypeDeveloperName) && recordType.equals(RECORD_TYPE_OPT_AP)) {

			paymentLineItemDefaultRecordType =
					ASI_CRM_RecordType.ASI_CRM_Payment_Invoice_Line_Item.ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item.name();

		} else if (
				ASI_CRM_RecordType.ASI_CRM_Payment_Invoice.ASI_CRM_JP_Cash_Invoice.name().equals(
						paymentInvoiceRecordTypeDeveloperName) && recordType.equals(RECORD_TYPE_OPT_REBATE)) {

			paymentLineItemDefaultRecordType =
					ASI_CRM_RecordType.ASI_CRM_Payment_Invoice_Line_Item.ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item.name();

		}

		System.debug('ASI_CRM_Payment_Invoice_Line_Item__c.sObjectType');
		System.debug(ASI_CRM_Payment_Invoice_Line_Item__c.sObjectType);
		System.debug(paymentLineItemDefaultRecordType);
		return ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(ASI_CRM_Payment_Invoice_Line_Item__c.sObjectType,
				paymentLineItemDefaultRecordType);
	}

	public static String getPaymentLineItemCustomCriteria() {

		//		String invoiceStartDate;
		//		String invoiceEndDate;
		//dtValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')

		String customCriteria = '';
		customCriteria += ' RecordType.DeveloperName = ' +
				ASI_CRM_RecordType.ASI_CRM_Purchase_Contract_Line_Item.ASI_CRM_JP_Indirect_Rebate_Contract_Line_Item.name();
		customCriteria += ' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Status__c = ' + 'Activated';
		customCriteria += ' AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Remaining_Balance__c > 0';
		customCriteria += ' AND (';
		customCriteria += ' (';
		customCriteria +=
				'	ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c >= : invoiceStartDate)';
		customCriteria +=
				' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c >= : invoiceEndDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceEndDate)';
		customCriteria +=
				' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c > : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c < : invoiceEndDate)';
		customCriteria +=
				' OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c = NULL)';
		customCriteria += ' ) ';

		//		WHERE recordtypeID = '012M00000000dEjIAI'
		//		AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Status__c = 'Activated'
		//		AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Remaining_Balance__c > 0
		//		AND (
		//				(
		//				ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c >= : invoiceStartDate)
		//		OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c >= : invoiceEndDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceEndDate)
		//		OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c > : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c < : invoiceEndDate)
		//		OR (ASI_CRM_Purchase_Contract__r.ASI_CRM_Start_Date__c <= : invoiceStartDate AND ASI_CRM_Purchase_Contract__r.ASI_CRM_End_Date__c = NULL)
		//		)

		return null;
	}

	private static Id getPaymentLineItemRecordTypeId(String type) {

		if (type.equals(RECORD_TYPE_OPT_REBATE)) {
			return ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
					ASI_CRM_Payment_Invoice_Line_Item__c.sObjectType,
					ASI_CRM_RecordType.ASI_CRM_Payment_Invoice_Line_Item.ASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item.name()
			);
		}

		if (type.equals(RECORD_TYPE_OPT_AP)) {
			return ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
					ASI_CRM_Payment_Invoice_Line_Item__c.sObjectType,
					ASI_CRM_RecordType.ASI_CRM_Payment_Invoice_Line_Item.ASI_CRM_JP_SPTD_Cash_Invoice_Line_Item.name()
			);
		}

		return null;
	}

	private static void initializePickList(Map<String, String> apEntPicklistSelectOption) {
		for (
				PicklistEntry entry
				:
		ASI_CRM_Payment_Invoice_Line_Item__c.ASI_CRM_A_P_Entertainment_F_D_Code__c.getDescribe().getPicklistValues()
		) {
			apEntPicklistSelectOption.put(entry.getValue(), entry.getLabel());
		}
	}
}