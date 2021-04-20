/*
 * Created by Alan Lau 2 on 14/1/2019.
 */

public without sharing class ASI_CRM_Purchase_Contract_ReportPageCtrl {

	public static final String SALES_STAFF_NO {
		get;set;
	}
	public Boolean isSalesAdmin {
		get; set;
	}
	public String batchId {
		get; set;
	}
	public ASI_CRM_Purchase_Contract_Line_Item__c reportSearchForm {
		get; set;
	}
	public ASI_CRM_JP_PurchaseContractService.ReportParameters reportParameters {
		get; set;
	}
	public Id userId {
		get;set;
	}
	public String purchaseContractReportId {
		get; set;
	}
	public String purchaseContractLineItemReportId {
		get; set;
	}
	public List<ASI_CRM_Purchase_Contract__c> newPurchaseContracts {
		get; set;
	}
	public List<ASI_CRM_Purchase_Contract_Line_Item__c> newPurchaseContractLineItems {
		get; set;
	}
	public Integer userActionStep {
		get;set;
	}
	public Boolean isStepOneFinished {
		get; set;
	}
	public Boolean isStepTwoFinished {
		get; set;
	}

	public final Map<Id, String> recordTypeIdNameMap = new Map<Id, String>();
	public List<SelectOption> purchaseContractRecordTypesPickListOptions{
		get; set;
	}

	private final Set<Id> contractLineItemIds = new Set<Id>();

	{
		SALES_STAFF_NO = '0000';
		userActionStep = 1;
		reportParameters = new ASI_CRM_JP_PurchaseContractService.ReportParameters();
	}

	public ASI_CRM_Purchase_Contract_ReportPageCtrl() {
		userId = UserInfo.getUserId();
		batchId = ASI_CRM_JP_PurchaseContractService.createBatchId();

		reportParameters.isEffective = true;

		final User currentUser = ASI_CRM_JP_DataService.getUserById(userId);
		isSalesAdmin = isUserSalesAdmin(currentUser);

		initializePurchaseLineItem(userId, isSalesAdmin);
		initializeRecordTypeIdNameMap();
		initializeRecordTypeIds();
		initializeRecordTypePickList();
	}

	public void initializeRecordTypePickList() {

		purchaseContractRecordTypesPickListOptions = new List<SelectOption>();
		final List<String> availableRecordTypes = new List<String> {
				'JP Direct Rebate Contract',
				'JP Indirect Rebate Contract'
				};

		purchaseContractRecordTypesPickListOptions.add(new SelectOption('', '--', false));
		for (String rt : availableRecordTypes) {
			purchaseContractRecordTypesPickListOptions.add(new SelectOption(rt, rt));
		}
	}

	private void initializePurchaseLineItem(Id userId, Boolean isSalesAdmin) {
		reportSearchForm = new ASI_CRM_Purchase_Contract_Line_Item__c();
		reportSearchForm.ASI_CRM_Purchase_Contract__r = new ASI_CRM_Purchase_Contract__c();
		if (!isSalesAdmin) {
			reportSearchForm.ASI_CRM_Purchase_Contract__r.OwnerId = userId;
		}
	}

	private void initializeRecordTypeIdNameMap() {
		for (
				Schema.RecordTypeInfo recordTypeInfo
				:
		ASI_CRM_Purchase_Contract__c.SObjectType.getDescribe().getRecordTypeInfos()
		) {
			if (
					!'Master'.equals(recordTypeInfo.getName()) &&
					recordTypeInfo.getName().containsIgnoreCase('rebate') &&
					!recordTypeInfo.getName().containsIgnoreCase('read-only')
			) {
				recordTypeIdNameMap.put(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName());
			}
		}
	}

	private void initializeRecordTypeIds() {
        system.debug('ASI_CRM_JP_PurchaseContractService.SEARCH_REPORT_NAME====='+ASI_CRM_JP_PurchaseContractService.SEARCH_REPORT_NAME);
		purchaseContractReportId =
				ASI_CRM_JP_DataService.getReportIdByApiName(ASI_CRM_JP_PurchaseContractService.SEARCH_REPORT_NAME);
		purchaseContractLineItemReportId =
				ASI_CRM_JP_DataService.getReportIdByApiName(ASI_CRM_JP_PurchaseContractService.EXPORT_REPORT_NAME);
	}

	private Boolean isUserSalesAdmin(User userObject) {
		if (userObject == null) return false;

		return SALES_STAFF_NO.equals(userObject.ASI_MFM_CN_Staff_No__c);
	}

	public void searchPurchaseContractReport() {
		batchId = ASI_CRM_JP_PurchaseContractService.createBatchId();
		isStepOneFinished = true;
		isStepTwoFinished = false;
		userActionStep = 2;
	}

	public void clonePurchaseContracts() {

		if (reportSearchForm == null) {}
		if (reportParameters == null) {}

		try {
			ASI_CRM_JP_PurchaseContractService.cloneAll(reportSearchForm, reportParameters, batchId);
		} catch (ASI_CRM_JP_PurchaseContractService.PurchaseContractImportException e) {
			System.debug(e.getMessage());
            ASI_CRM_PageUtil.showError(e.getMessage());
		}

		isStepTwoFinished = true;
		userActionStep = 3;
	}

}