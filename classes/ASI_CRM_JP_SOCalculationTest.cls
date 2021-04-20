@isTest
public class ASI_CRM_JP_SOCalculationTest {

	@testSetup
	static void setup() {
		//		ASI_CRM_JP_TestHelper.createRunningNumber();
		//		ASI_CRM_JP_TestHelper.createApprovalRoute();
		//		ASI_CRM_JP_TestHelper.createBusinessDay();
		//
		//		insert getRouteTypes();
		//		insert getTestUsers(8);
		//		insert getRouteDetails();

		final Date startDate = Date.newInstance(2019, 4, 1);
		final List<ASI_JP_CRM_Business_Day_Calendar__c> businessDayCalendar = getBusinessDayCalendar(
				startDate, 31
		);

		insert businessDayCalendar;

		ASI_CRM_JP_TestHelper.createRunningNumber();
		Map<String, Object> directSalesCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_CUSTOMER_DEFAULT_VALUE_MAP;
		directSalesCustomerFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.CUSTOMER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales_Customer'));
		ASI_CRM_AccountsAdditionalField__c directSalesCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesCustomerFieldValueMap);
		insert directSalesCustomer;

		Map<String, Object> directSalesShipToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.DIRECT_SALES_SHIP_TO_DEFAULT_VALUE_MAP;
		directSalesShipToCustomerFieldValueMap.put('ASI_CRM_Customer__c', directSalesCustomer.Id);
		directSalesShipToCustomerFieldValueMap.remove('ASI_CRM_KR_Salesman__c');
		ASI_CRM_AccountsAdditionalField__c directSalesShipToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesShipToCustomerFieldValueMap);
		insert directSalesShipToCustomer;

		Map<String, Object> directSalesBillToCustomerFieldValueMap = ASI_CRM_JP_TestHelper.BILL_TO_CUSTOMER_DEFAULT_VALUE_MAP;
		ASI_CRM_AccountsAdditionalField__c directSalesBillToCustomer = ASI_CRM_JP_TestHelper.createCustomer(directSalesBillToCustomerFieldValueMap);
		insert directSalesBillToCustomer;

		insert ASI_CRM_JP_TestHelper.createBillTo(directSalesCustomer.Id, directSalesBillToCustomer.Id);
	}

	@isTest
	static void testDateCalculation() {
		final Integer shippingLeadTime = 2;

		final ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
		salesOrder.ASI_CRM_Route_Code__c = shippingLeadTime;
		salesOrder.ASI_CRM_Requested_Date__c = Date.newInstance(2019, 4, 5);

		//final Date minimalRequestDate = ASI_CRM_JP_SOAssignApprover.getMinimalRequestedDate(salesOrder);

		if(Datetime.now().hour() > 11) {
			//System.assertEquals(Date.newInstance(2019, 4, 4), minimalRequestDate);
		} else {
			//System.assertEquals(Date.newInstance(2019, 4, 3), minimalRequestDate);
		}

		//final Date latestApprovalDate = ASI_CRM_JP_SOAssignApprover.getLatestApprovalDate(salesOrder);
		//System.assertEquals(Date.newInstance(2019, 4, 3), latestApprovalDate);
	
	}


	@isTest
	static void testDateCalculation2() {
		final Integer shippingLeadTime = 2;
		final ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
		salesOrder.ASI_CRM_Route_Code__c = shippingLeadTime;
		salesOrder.ASI_CRM_Requested_Date__c = Date.newInstance(2019, 4, 12);

		//final Date minimalRequestDate = ASI_CRM_JP_SOAssignApprover.getMinimalRequestedDate(salesOrder);
		

		if (Datetime.now().hour() > 11) {
			//System.assert(Date.today().addDays(shippingLeadTime) <= minimalRequestDate);
		} else {
			//System.assert(Date.today().addDays(shippingLeadTime - 1) <= minimalRequestDate);
		}

		//final Date latestApprovalDate = ASI_CRM_JP_SOAssignApprover.getLatestApprovalDate(salesOrder);
		
		//System.assertEquals(Date.newInstance(2019, 4, 10), latestApprovalDate);
	}
	@isTest
    static void testcalculateSO(){
        list<ASI_CRM_JP_Sales_Order__c> so = new List<ASI_CRM_JP_Sales_Order__c>();

		Map<String, ASI_CRM_AccountsAdditionalField__c> customerMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();

		for(ASI_CRM_AccountsAdditionalField__c customer : [SELECT Id, RecordType.DeveloperName FROM ASI_CRM_AccountsAdditionalField__c]) {
			customerMap.put(customer.RecordType.DeveloperName, customer);
		}

		ASI_CRM_Bill_To__c billTo = [SELECT Id FROM ASI_CRM_Bill_To__c LIMIT 1];

		Map<String, Object> directSOFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_DEFAULT_VALUE_MAP;
		directSOFieldValueMap.put('ASI_CRM_Sold_To__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
		directSOFieldValueMap.put('ASI_CRM_JP_Bill_To__c', billTo.Id);
		directSOFieldValueMap.put('RecordTypeId', ASI_CRM_JP_TestHelper.SALES_ORDER_RECORD_TYPE_MAP.get('ASI_CRM_JP_Direct_Sales'));

		directSOFieldValueMap.put('ASI_CRM_Payment_Option__c', 'COD');
		directSOFieldValueMap.put('ASI_CRM_JP_Taxable_Service_Charge__c', '1000');
		directSOFieldValueMap.put('ASI_CRM_Invoice_Date__c', Date.today());
		directSOFieldValueMap.put('ASI_CRM_Payment_Request_Date__c', Date.today().addMonths(2));

		ASI_CRM_JP_Sales_Order__c directSO = ASI_CRM_JP_TestHelper.createSalesOrder(directSOFieldValueMap);
		insert directSO;

		Map<String, Object> itemGroupFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_GROUP_DEFAUL_VALUE_MAP;
		ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_TestHelper.createItemGroup(itemGroupFieldValueMap);
		insert itemGroup;

		List<ASI_MFM_SKU_Code__c> skuCodeList = new List<ASI_MFM_SKU_Code__c>();
		for(Integer index = 0 ; index < 2 ; index++) {
			Map<String, Object> skuCodeFieldValueMap = ASI_CRM_JP_TestHelper.SKU_DEFAULT_VALUE_MAP;
			skuCodeFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
			skuCodeFieldValueMap.put('ASI_HK_CRM_Active__c', true);
			ASI_MFM_SKU_Code__c skuCode = ASI_CRM_JP_TestHelper.createSKU(skuCodeFieldValueMap);
			skuCodeList.add(skuCode);
		}
		insert skuCodeList;

		List<ASI_CRM_JP_Item_Availability__c> itemAvailabilityList = new List<ASI_CRM_JP_Item_Availability__c>();
		for(ASI_MFM_SKU_Code__c skuCode : skuCodeList) {
			Map<String, Object> itemAvailabilityFieldValueMap1 = ASI_CRM_JP_TestHelper.ITEM_AVAILABILITY_DEFAULT_VALUE_MAP;
			itemAvailabilityFieldValueMap1.put('ASI_SKU__c', skuCode.Id);
			itemAvailabilityFieldValueMap1.put('ASI_Warehouse_Location__c', '111');
			ASI_CRM_JP_Item_Availability__c itemAvailability1 = ASI_CRM_JP_TestHelper.createItemAvailability(itemAvailabilityFieldValueMap1);
			itemAvailabilityList.add(itemAvailability1);

			Map<String, Object> itemAvailabilityFieldValueMap2 = ASI_CRM_JP_TestHelper.ITEM_AVAILABILITY_DEFAULT_VALUE_MAP;
			itemAvailabilityFieldValueMap2.put('ASI_SKU__c', skuCode.Id);
			itemAvailabilityFieldValueMap2.put('ASI_Warehouse_Location__c', '131');
			ASI_CRM_JP_Item_Availability__c itemAvailability2 = ASI_CRM_JP_TestHelper.createItemAvailability(itemAvailabilityFieldValueMap2);
			itemAvailabilityList.add(itemAvailability2);
		}
		insert itemAvailabilityList;

		Map<String, Object> priceListFieldValueMap = ASI_CRM_JP_TestHelper.PRICE_LIST_DEFAULT_VALUE_MAP;
		ASI_CRM_Price_List__c priceList = ASI_CRM_JP_TestHelper.createPriceList(priceListFieldValueMap);
		priceList.ASI_CRM_JP_Effective_Date__c = Date.today().addDays(10);
		insert priceList;

		List<ASI_CRM_JP_Customer_Product_Price__c> itemBasePriceList = new List<ASI_CRM_JP_Customer_Product_Price__c>();
		for(String itemBasePriceRecordTypeId : ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_RECORD_TYPE.values()) {
			Map<String, Object> itemBasePriceFieldValueMap = ASI_CRM_JP_TestHelper.ITEM_BASE_PRICE_DEFAULT_VALUE_MAP;
			itemBasePriceFieldValueMap.put('ASI_MFM_Item_Group__c', itemGroup.Id);
			itemBasePriceFieldValueMap.put('RecordTypeId', itemBasePriceRecordTypeId);
			itemBasePriceFieldValueMap.put('ASI_Customer_Name__c', customerMap.get('ASI_CRM_JP_Direct_Sales_Customer').Id);
			ASI_CRM_JP_Customer_Product_Price__c itemBasePrice = ASI_CRM_JP_TestHelper.createItemBasePrice(itemBasePriceFieldValueMap);
			itemBasePriceList.add(itemBasePrice);
		}
		insert itemBasePriceList;

		Map<String, Object> salesOrderItemFieldValueMap = ASI_CRM_JP_TestHelper.SALES_ORDER_ITEM_DEFAULT_VALUE_MAP;
		salesOrderItemFieldValueMap.put('ASI_CRM_Sales_Order__c', directSO.Id);
		salesOrderItemFieldValueMap.put('ASI_CRM_SKU__c', skuCodeList.get(0).Id);
		salesOrderItemFieldValueMap.put('ASI_CRM_Sys_Item_Availability_Filter__c', directSO.ASI_CRM_Branch_Plant__c);
		salesOrderItemFieldValueMap.put('ASI_CRM_JP_Sys_Lookup_Filter__c', 'ASI_CRM_JP_Manual_JDE_SO');
		ASI_CRM_JP_Sales_Order_Item__c salesOrderItem = ASI_CRM_JP_TestHelper.createSalesOrderLine(salesOrderItemFieldValueMap);
		insert salesOrderItem;


		so.add(directSO);

		/*
        ASI_CRM_JP_Sales_Order__c Sorder = new ASI_CRM_JP_Sales_Order__c();
        
        insert Sorder;
        
        update Sorder;
		*/
       
        ASI_CRM_JP_SOCalculation acj = new ASI_CRM_JP_SOCalculation();
        acj.calculateSO(so);
        
    }

	@isTest
	static void testDateCalculation3() {
		final Integer shippingLeadTime = 2;
		final ASI_CRM_JP_Sales_Order__c salesOrder = new ASI_CRM_JP_Sales_Order__c();
		salesOrder.ASI_CRM_Route_Code__c = shippingLeadTime;
		salesOrder.ASI_CRM_Requested_Date__c = Date.newInstance(2019, 4, 15);

		//final Date latestApprovalDate = ASI_CRM_JP_SOAssignApprover.getLatestApprovalDate(salesOrder);
		//System.assertEquals(Date.newInstance(2019, 4, 11), latestApprovalDate);
	}

	private static List<ASI_JP_CRM_Business_Day_Calendar__c> getBusinessDayCalendar(Date startDate, Integer length) {
		final List<ASI_JP_CRM_Business_Day_Calendar__c> businessDayCalendars =
				new List<ASI_JP_CRM_Business_Day_Calendar__c>();
		final Id recordTypeId = Global_RecordTypeCache.getRtId('ASI_JP_CRM_Business_Day_Calendar__cASI_JP_CRM_Business_Day_Calendar');

		final Set<Integer> holidays = new Set<Integer> {
				6, 7, 13, 14, 20, 21, 27, 28
				};

		Date dateCounter = startDate;
		Integer counter = 0;
		while (counter < length) {
			final ASI_JP_CRM_Business_Day_Calendar__c businessDayCalendar = new ASI_JP_CRM_Business_Day_Calendar__c(
					Name = dateCounter.format(),
					ASI_Business_Day__c = dateCounter,
					ASI_PR_Working__c = !holidays.contains(dateCounter.day()),
					ASI_WS_Working__c = true,
					RecordTypeId = recordTypeId
			);
			businessDayCalendars.add(businessDayCalendar);
			dateCounter = dateCounter.addDays(1);
			counter++;
		}

		return businessDayCalendars;
	}

	private static List<ASI_CRM_Route_Type__c> getRouteTypes() {
		final List<ASI_CRM_Route_Type__c> routeTypes = new List<ASI_CRM_Route_Type__c> {
				new ASI_CRM_Route_Type__c(
						Name = 'Marketing FOC Route Type - 9024',
						ASI_CRM_Route_Type_Description__c = null,
						ASI_CRM_Module__c = 'Sales Order',
						ASI_CRM_A_P_Code__c = '9024 Tasting Sample',
						ASI_CRM_Module_Record_Type__c = 'Marketing FOC'
				),
				new ASI_CRM_Route_Type__c(
						Name = 'Marketing FOC Route Type - 9025',
						ASI_CRM_Route_Type_Description__c = null,
						ASI_CRM_Module__c = 'Sales Order',
						ASI_CRM_A_P_Code__c = '9025 Ambassador',
						ASI_CRM_Module_Record_Type__c = 'Marketing FOC'
				),
				new ASI_CRM_Route_Type__c(
						Name = 'Marketing FOC Route Type - 9026',
						ASI_CRM_Route_Type_Description__c = null,
						ASI_CRM_Module__c = 'Sales Order',
						ASI_CRM_A_P_Code__c = '9026 Event etc.',
						ASI_CRM_Module_Record_Type__c = 'Marketing FOC'
				)
				};
		return routeTypes;
	}

	private static List<ASI_CRM_Route_Rule_Detail__c> getRouteDetails() {
		final List<ASI_CRM_Route_Type__c> routeTypes = [SELECT Id from ASI_CRM_Route_Type__c ORDER BY Name ASC ];
		final List<User> users = [SELECT Id FROM User ORDER BY Id];
		final List<ASI_CRM_Route_Rule_Detail__c> routeRules = new List<ASI_CRM_Route_Rule_Detail__c>();

		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = 'null',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(0).Id,
				ASI_CRM_Approver__c = users.get(0).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '113,400,410,411,414,416,531',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(0).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '200,504',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(1).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '503,530,532,537,541,591',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(2).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '112,315,323,333,350',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(3).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '112,315,323,333,350',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(4).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '120,122,123,130,140',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(7).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '120,122,123,130,140',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(4).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '312',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(0).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '312',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(4).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '419',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(3).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '419',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(2).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '510',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(5).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '510',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(4).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = 'others',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(1).Id,
				ASI_CRM_Approver__c = users.get(6).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '113,400,410,411,414,416,531',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(0).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '200,504',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(1).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '503,530,532,537,541,591',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(2).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '112,315,323,333,350',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(3).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '112,315,323,333,350',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(4).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '120,122,123,130,140',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(7).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '120,122,123,130,140',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(4).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '312',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(0).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '312',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(4).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '419',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(3).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '419',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(2).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '510',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(5).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = '510',
				ASI_CRM_Threshold__c = 1000000,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(4).Id
		));
		routeRules.add(new ASI_CRM_Route_Rule_Detail__c(
				ASI_CRM_Brand_Code__c = 'others',
				ASI_CRM_Threshold__c = 0,
				ASI_CRM_JP_Approval_Sequence__c = null,
				ASI_CRM_Route_Type__c = routeTypes.get(2).Id,
				ASI_CRM_Approver__c = users.get(6).Id
		));
		
		return routeRules;
	}

	private static List<User> getTestUsers(Integer count) {
		final Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		final List<User> users = new List<User>();
		for (Integer counter = 0; counter < count; counter++) {
			users.add(getUser(counter + '', p.Id));
		}
		return users;
	}

	private static User getUser(String identifier, Id profileId) {
		return new User(
				Alias = 'al' + identifier,
				Email = identifier + 'estandarduser@testorg.com',
				EmailEncodingKey = 'UTF-8',
				LastName = 'Testing' + identifier,
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				ProfileId = profileId,
				TimeZoneSidKey = 'America/Los_Angeles',
				UserName = identifier + 'unstandarduser@testorg.com'
		);
	}

}