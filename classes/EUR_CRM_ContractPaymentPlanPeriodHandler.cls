/**
* Name: EUR_CRM_ContractPaymentPlanPeriodHandler
* Description: Creates a number of Payment Plan Period records for each Contract Product Item inserted (Pouring Refund)
*			   For other mechanic types, create one Payment Plan Period record for each Contract Activity Item 
*
* Countries: DE, iSpend
*/
public with sharing class EUR_CRM_ContractPaymentPlanPeriodHandler{

	// TODO: Refactor with RecordTypeHandler in case iSpend is expanded
	private final Set<String> VALID_COUNTRY_CODES = new Set<String>{'DE'};

	private final Set<String> VALID_CPI_RT_TO_UPDATE_CPPP = new Set<String>{
		'EUR_DE_Contract_Product_Item'
	};

	@TestVisible
	private static final String BEGINNING_CONTRACT = 'Nach Vertragsabschluss (einmalig)';
	@TestVisible
	private static final String BEGINNING_CONTRACT_PERIOD = 'Zu Beginn der Vertragsposition';
	@TestVisible
	private static final String AFTER_IMPLEMENTATION = 'Nach Umsetzung';
	@TestVisible
	private static final String HALF_YEARLY = 'Halbjährlich nach Leistungserfüllung';
	@TestVisible
	private static final String THIRD_PARTY_VENDOR = 'Abrechnung durch Dritte';
	@TestVisible
	private static final String NO_INVOICING = 'Keine Abrechnung';

	private static final Map<String, String> PAYMENT_TERM_LOCALISATION = new Map<String, String> {
		BEGINNING_CONTRACT => 'Beginning of contract'
	,	BEGINNING_CONTRACT_PERIOD => 'Beginning of contract activity'
	,	AFTER_IMPLEMENTATION => 'After implementation'
	,	HALF_YEARLY => 'Half-yearly after implementation'
	,	THIRD_PARTY_VENDOR => 'Invoiced by 3rd party'
	,	NO_INVOICING => 'No Invoicing'
	};

	private static final Set<String> MECH_TYPES_NO_NEED_TO_CREATE_CPPP = new Set<String> {
		'EUR_DE_Listing'
	,	'EUR_DE_House_Pouring'
	};

	private static final String POURING_REFUND_MECH_TYPE_EXT_ID = 'EUR_DE_Pouring_Refund';
	private static final String DE_PAYMENT_PLAN_PERIOD = 'EUR_DE_Contract_Payment_Plan_Period';

//	private final Id pouringRefundRtId 				= Global_RecordTypeCache.getRtId('EUR_CRM_Mechanic_Type__c' + POURING_REFUND);
	private final Id paymentPlanPeriodRt 			= Global_RecordTypeCache.getRtId('EUR_CRM_Contract_Payment_Plan_Period__c' + DE_PAYMENT_PLAN_PERIOD);

	public void onAfterInsert(List<EUR_CRM_Contract_Product_Item__c> sObjList) {
		List<RecordType> contractProductItemRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Contract_Product_Item__c');
		// Special case for pouring refund, as they need to be split according to year

		Map<Id,Recordtype> contractProductRecordTypesMap = new Map<Id,Recordtype>();
		List<EUR_CRM_Contract_Product_Item__c> validContractProductItems = new List<EUR_CRM_Contract_Product_Item__c>();
		Set<Id> contractActivityItemIds = new Set<Id>();
		Set<Id> contractIds = new Set<Id>();
		Map<Id, EUR_CRM_Contract_Activity_Item__c> relatedContractActivityItems;
		Map<Id, EUR_CRM_Contract_Activity_Item__c> nonPouringRefundContractActivityItems = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();
		// Maps ContractId to EUR_CRM_Contract_Payment_Plan__c
		Map<Id, EUR_CRM_Contract_Payment_Plan__c> relatedContractPaymentPlans = new Map<Id, EUR_CRM_Contract_Payment_Plan__c>();
		List<EUR_CRM_Contract_Payment_Plan_Period__c> newContractPaymentPlanPeriods = new List<EUR_CRM_Contract_Payment_Plan_Period__c>();
		List<EUR_CRM_Contract_Payment_Plan_Period__c> existingContractPaymentPlanPeriods = new List<EUR_CRM_Contract_Payment_Plan_Period__c>();
		Set<Id> existingContractActivityIds = new Set<Id>();

		// Maps all Contract Product Item record types to its ID. Used to retrieve the developername
		for(RecordType rt: contractProductItemRecordTypes) {
			contractProductRecordTypesMap.put(rt.id, rt);
		}

		for(EUR_CRM_Contract_Product_Item__c cpItem: (List<EUR_CRM_Contract_Product_Item__c>) sObjList) {
			System.debug(cpItem.EUR_CRM_Contract_Activity_Item__c);
			System.debug(cpItem.EUR_CRM_Country_Code__c);

			if(VALID_COUNTRY_CODES.contains(cpItem.EUR_CRM_Country_Code__c)) {
				validContractProductItems.add(cpItem);
				contractActivityItemIds.add(cpItem.EUR_CRM_Contract_Activity_Item__c);
			}
		}

		if(validContractProductItems.size() > 0) {

			// Retrieve Contract Activity Items and Contract
			relatedContractActivityItems = new Map<Id, EUR_CRM_Contract_Activity_Item__c>([SELECT Id,
												EUR_CRM_Amount__c, EUR_CRM_Contract__c,
												EUR_CRM_Contract__r.EUR_CRM_Start_Date__c,
												EUR_CRM_Contract__r.EUR_CRM_End_Date__c,
												EUR_CRM_Payment_Term_By_SR__c,
												EUR_CRM_Payment_Term__c,
												EUR_CRM_Mechanic_Type__r.recordTypeId,
												EUR_CRM_Mechanic_Type__r.RecordType.DeveloperName,
												EUR_CRM_Mechanic_Type__r.Name,
												EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c,
												EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c,
												(SELECT EUR_CRM_Brand__c, EUR_CRM_Brand__r.Name,
													EUR_CRM_Description__c
												FROM Contract_Product_Items__r)
												FROM EUR_CRM_Contract_Activity_Item__c
												WHERE Id IN :contractActivityItemIds]);
			existingContractPaymentPlanPeriods = [SELECT Id, EUR_CRM_Description__c,
												EUR_CRM_Contract_Payment_Plan__c,
												EUR_CRM_Contract_Activity_Item__c,
												EUR_CRM_Payment_Period_Start_Date__c,
												EUR_CRM_Payment_Period_End_Date__c,
												EUR_CRM_CPPP_Amount__c, EUR_CRM_CPPP_Payment_Term__c,
												EUR_CRM_CPPP_Earliest_Date_of_Invoice__c,
												EUR_CRM_Contract_Product_Item__c, EUR_CRM_Brand__c
												FROM EUR_CRM_Contract_Payment_Plan_Period__c
												WHERE EUR_CRM_Contract_Activity_Item__c IN :contractActivityItemIds];


			for(EUR_CRM_Contract_Activity_Item__c caItem: relatedContractActivityItems.values()) {
				// Retrieve a set of Contract Ids and use it to retrieve all related Contract Payment Plan
				caItem.EUR_CRM_Payment_Term_By_SR__c = caItem.EUR_CRM_Payment_Term__c == null ? '' : caItem.EUR_CRM_Payment_Term__c;
				contractIds.add(caItem.EUR_CRM_Contract__c);
			}
			for(EUR_CRM_Contract_Payment_Plan_Period__c existingContractPaymentPlanPeriod: existingContractPaymentPlanPeriods) {
				existingContractActivityIds.add(existingContractPaymentPlanPeriod.EUR_CRM_Contract_Activity_Item__c);
			}
			for(EUR_CRM_Contract_Payment_Plan__c cpPlan: [SELECT Id, EUR_CRM_Contract__c
														  FROM EUR_CRM_Contract_Payment_Plan__c
														  WHERE EUR_CRM_Contract__c IN :contractIds]) {
				relatedContractPaymentPlans.put(cpPlan.EUR_CRM_Contract__c, cpPlan);
			}

			System.debug('\n validContractProductItems.size() => ' + validContractProductItems.size() + '\n');
			System.debug('\n validContractProductItems => ' + JSON.serializePretty(validContractProductItems) + '\n');
			System.debug('\n relatedContractActivityItems.size() => ' + relatedContractActivityItems.size() + '\n');
			System.debug('\n relatedContractActivityItems => ' + JSON.serializePretty(relatedContractActivityItems) + '\n');
			System.debug('\n relatedContractPaymentPlans.size() => ' + relatedContractPaymentPlans.size() + '\n');
			System.debug('\n relatedContractPaymentPlans => ' + JSON.serializePretty(relatedContractPaymentPlans) + '\n');
			System.debug('\n contractIds => ' + contractIds + '\n');
			System.debug('\n existingContractPaymentPlanPeriods.size() => ' + existingContractPaymentPlanPeriods.size() + '\n');
			System.debug('\n existingContractPaymentPlanPeriods => ' + JSON.serializePretty(existingContractPaymentPlanPeriods) + '\n');
			System.debug('\n existingContractActivityIds.size() => ' + existingContractActivityIds.size() + '\n');
			System.debug('\n existingContractActivityIds => ' + JSON.serializePretty(existingContractActivityIds) + '\n');

			for(EUR_CRM_Contract_Product_Item__c cpItem: validContractProductItems) {
				EUR_CRM_Contract_Activity_Item__c caItem = relatedContractActivityItems.get(cpItem.EUR_CRM_Contract_Activity_Item__c);
				System.debug('\n caItem => ' + JSON.serializePretty(caItem) + '\n');

				// Barrier. Ignore contracts without a contract payment plan record (old contracts)
				if(relatedContractPaymentPlans.get(caItem.EUR_CRM_Contract__c) == null) {
					continue;
				}

				// Barrier. Per Contract Product Item creation for CPPP is only applicable to Pouring Refund
//    			if(caItem.EUR_CRM_Mechanic_Type__r.recordTypeId != pouringRefundRtId) {
				if(caItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c != POURING_REFUND_MECH_TYPE_EXT_ID) {
					if ( ! MECH_TYPES_NO_NEED_TO_CREATE_CPPP.contains(caItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c)) {
						nonPouringRefundContractActivityItems.put(caItem.Id, caItem);
					}
					continue;
				}

				if(this.isPaymentTermBySRequals(caItem, AFTER_IMPLEMENTATION)){
					createContractPaymentPlanPeriodYearly(
						caItem.EUR_CRM_Start_Date__c,
						caItem.EUR_CRM_End_Date__c,
						newContractPaymentPlanPeriods,
						cpItem,
						caItem,
						relatedContractPaymentPlans,
						0, 0, 0
					);
				} else if(this.isPaymentTermBySRequals(caItem, HALF_YEARLY)) {
					createContractPaymentPlanPeriodHalfYearly(
						caItem.EUR_CRM_Start_Date__c,
						caItem.EUR_CRM_End_Date__c,
						newContractPaymentPlanPeriods,
						cpItem,
						caItem,
						relatedContractPaymentPlans,
						0, 0, 0
					);
				} else if(this.isPaymentTermBySRequals(caItem, THIRD_PARTY_VENDOR)) {
					newContractPaymentPlanPeriods.add(new EUR_CRM_Contract_Payment_Plan_Period__c(
						EUR_CRM_Contract_Activity_Item__c 		= caItem.Id,
						EUR_CRM_Contract_Payment_Plan__c  		= relatedContractPaymentPlans.get(caItem.EUR_CRM_Contract__c).Id,
						EUR_CRM_Payment_Period_Start_Date__c 	= caItem.EUR_CRM_Start_Date__c,
						EUR_CRM_Payment_Period_End_Date__c 		= caItem.EUR_CRM_End_Date__c,
						recordTypeId 							= paymentPlanPeriodRt,
						EUR_CRM_CPPP_Payment_Term__c			= caItem.EUR_CRM_Payment_Term_By_SR__c,
						EUR_CRM_Contract_Product_Item__c		= cpItem.Id,
						EUR_CRM_CPPP_Unit__c					= cpItem.EUR_CRM_Unit__c,
						EUR_CRM_CPPP_Rate__c 					= cpItem.EUR_CRM_Amount__c,
						EUR_CRM_CPPP_Volume__c					= cpItem.EUR_CRM_Quantity__c,
						EUR_CRM_CPPP_Amount__c					= cpItem.EUR_CRM_Amount__c * cpItem.EUR_CRM_Quantity__c,
						EUR_CRM_Description__c					= cpItem.EUR_CRM_Description__c
					));
				}
			}

			for(EUR_CRM_Contract_Activity_Item__c caItem: nonPouringRefundContractActivityItems.values()) {
				System.debug('\n existingContractActivityIds.contains(caItem.Id) => ' + existingContractActivityIds.contains(caItem.Id) + '\n');
    			if(caItem.Contract_Product_Items__r != null && !existingContractActivityIds.contains(caItem.Id)) {
					String brandNames = '';
					String description = '';
					for(EUR_CRM_Contract_Product_Item__c cpItem: caItem.Contract_Product_Items__r) {
						System.debug(cpItem);

						// Concatenate Names
						brandNames += cpItem.EUR_CRM_Brand__r.Name + '\n';
						if(cpItem.EUR_CRM_Description__c != null) {
							description += cpItem.EUR_CRM_Description__c + '\n\n';
						}
					}

					System.debug(brandNames);

					EUR_CRM_Contract_Payment_Plan_Period__c newContractPaymentPlanPeriod = new EUR_CRM_Contract_Payment_Plan_Period__c(
						EUR_CRM_Contract_Activity_Item__c 		= caItem.Id,
						EUR_CRM_Contract_Payment_Plan__c  		= relatedContractPaymentPlans.get(caItem.EUR_CRM_Contract__c).Id,
						EUR_CRM_Payment_Period_Start_Date__c 	= caItem.EUR_CRM_Start_Date__c,
						EUR_CRM_Payment_Period_End_Date__c 		= caItem.EUR_CRM_End_Date__c,
						recordTypeId 							= paymentPlanPeriodRt,
						EUR_CRM_CPPP_Payment_Term__c			= caItem.EUR_CRM_Payment_Term_By_SR__c,
						EUR_CRM_List_of_Brand__c				= brandNames,
						EUR_CRM_CPPP_Amount__c					= caItem.EUR_CRM_Amount__c,
						EUR_CRM_Description__c					= description
					);

					if(this.isPaymentTermBySRequals(caItem, NO_INVOICING)) {
						newContractPaymentPlanPeriod.EUR_CRM_CPPP_Earliest_Date_of_Invoice__c 	= null;
						//newContractPaymentPlanPeriod.EUR_CRM_CPPP_Amount__c 					= null;
					} else if(this.isPaymentTermBySRequals(caItem, BEGINNING_CONTRACT)) {
						newContractPaymentPlanPeriod.EUR_CRM_CPPP_Earliest_Date_of_Invoice__c 	= caItem.EUR_CRM_Contract__r.EUR_CRM_Start_Date__c;
					} else if(this.isPaymentTermBySRequals(caItem, BEGINNING_CONTRACT_PERIOD)) {
						newContractPaymentPlanPeriod.EUR_CRM_CPPP_Earliest_Date_of_Invoice__c 	= caItem.EUR_CRM_Start_Date__c;
					} else if(this.isPaymentTermBySRequals(caItem, AFTER_IMPLEMENTATION) && caItem.EUR_CRM_End_Date__c != null) {
						newContractPaymentPlanPeriod.EUR_CRM_CPPP_Earliest_Date_of_Invoice__c 	= caItem.EUR_CRM_End_Date__c.addDays(1);
					}

					newContractPaymentPlanPeriods.add(newContractPaymentPlanPeriod);
				}
			}

			System.debug('\n newContractPaymentPlanPeriods.size() => ' + newContractPaymentPlanPeriods.size() + '\n');
			System.debug('\n newContractPaymentPlanPeriods => ' + JSON.serializePretty(newContractPaymentPlanPeriods) + '\n');
			if(newContractPaymentPlanPeriods.size() > 0) {
				insert newContractPaymentPlanPeriods;
			}
		}
	}

	public void onAfterUpdate(List<EUR_CRM_Contract_Product_Item__c> cpis, Map<Id, EUR_CRM_Contract_Product_Item__c> oldMapCPIbyId) {
		Set<Id> validCPIrtIds = this.getValidCPIrtIds();
		System.debug('\n validCAIrtIds.size() => ' + validCPIrtIds.size() + '\n');
		System.debug('\n validCAIrtIds => ' + JSON.serializePretty(validCPIrtIds) + '\n');

		List<EUR_CRM_Contract_Product_Item__c> validCPIsToUpdateCPPP = this.getValidCPItoUpdateCPPP(cpis, oldMapCPIbyId, validCPIrtIds);
		System.debug('\n validCPIsToUpdateCPPP.size() => ' + validCPIsToUpdateCPPP.size() + '\n');
		System.debug('\n validCPIsToUpdateCPPP => ' + JSON.serializePretty(validCPIsToUpdateCPPP) + '\n');
		if (validCPIsToUpdateCPPP.isEmpty()) { return; }

		List<EUR_CRM_Contract_Product_Item__c> cpisToUpdateCPPP = this.selectCPIsWhereIds(validCPIsToUpdateCPPP);
		System.debug('\n cpisToUpdateCPPP.size() => ' + cpisToUpdateCPPP.size() + '\n');
		System.debug('\n cpisToUpdateCPPP => ' + JSON.serializePretty(cpisToUpdateCPPP) + '\n');
		if (cpisToUpdateCPPP.isEmpty()) { return; }

		List<EUR_CRM_Contract_Payment_Plan_Period__c> cpppsToUpdate = this.updateCPPPs(cpisToUpdateCPPP);
		System.debug('\n cpppsToUpdate.size() => ' + cpppsToUpdate.size() + '\n');
		System.debug('\n cpppsToUpdate => ' + JSON.serializePretty(cpppsToUpdate) + '\n');
		if (cpppsToUpdate.isEmpty()) { return; }

		update cpppsToUpdate;
	}

	private Set<Id> getValidCPIrtIds() {
		Map<String, RecordTypeInfo> rtInfoByDevName = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName();
		Set<Id> validCAIrtIds = new Set<Id>();
		for (String rt : this.VALID_CPI_RT_TO_UPDATE_CPPP) {
			if ( ! rtInfoByDevName.containsKey(rt)) { continue; }
			validCAIrtIds.add(rtInfoByDevName.get(rt).getRecordTypeId());
		}
		return validCAIrtIds;
	}

	private List<EUR_CRM_Contract_Product_Item__c> getValidCPItoUpdateCPPP(List<EUR_CRM_Contract_Product_Item__c> newCPIs,
		Map<Id, EUR_CRM_Contract_Product_Item__c> oldCPIbyId, Set<Id> validCPIrtIds) {
		List<EUR_CRM_Contract_Product_Item__c> caisToUpdateCPPP = new List<EUR_CRM_Contract_Product_Item__c>();
		for (EUR_CRM_Contract_Product_Item__c cai : newCPIs) {
			if ( ! this.isCPIvalid(cai, oldCPIbyId.get(cai.Id), validCPIrtIds)) { continue; }
			caisToUpdateCPPP.add(cai);
		}
		return caisToUpdateCPPP;
	}

	private List<EUR_CRM_Contract_Payment_Plan_Period__c> updateCPPPs(List<EUR_CRM_Contract_Product_Item__c> cpis) {
		List<EUR_CRM_Contract_Payment_Plan_Period__c> cpppsToUpdate = new List<EUR_CRM_Contract_Payment_Plan_Period__c>();
		Date caiStart;
		Date caiEnd;
		Integer caiDuration;
		for (EUR_CRM_Contract_Product_Item__c cpi : cpis) {
			caiStart = cpi.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Start_Date__c;
			caiEnd = cpi.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_End_Date__c;
			caiDuration = this.calculateDuration(caiStart, caiEnd);

			if (this.isPouringRefund(cpi) && (!cpi.Contract_Payment_Plan_Periods_EU__r.isEmpty())) {
				List<EUR_CRM_Contract_Payment_Plan_Period__c> cppps = cpi.Contract_Payment_Plan_Periods_EU__r;
				EUR_CRM_Contract_Payment_Plan_Period__c cppp;
				Decimal totalCPPPvolume = 0.0;
				for (Integer i = 0; i < cppps.size(); i++) {
					cppp = cppps.get(i);
					if (i < cppps.size() - 1) {
						cppp.EUR_CRM_CPPP_Volume__c = this.calculateVolumePerCPPP(cppp, caiDuration, cpi.EUR_CRM_Volume_lt__c);
						totalCPPPvolume += cppp.EUR_CRM_CPPP_Volume__c;
					} else {
						cppp.EUR_CRM_CPPP_Volume__c = cpi.EUR_CRM_Volume_lt__c - totalCPPPvolume;
					}
					cppp.EUR_CRM_CPPP_Amount__c = cppp.EUR_CRM_CPPP_Volume__c * cpi.EUR_CRM_Amount__c;
					cppp.EUR_CRM_CPPP_Unit__c = cpi.EUR_CRM_Unit__c;
					cppp.EUR_CRM_CPPP_Rate__c = cpi.EUR_CRM_Amount__c;
					cppp.EUR_CRM_CPPP_Description__c = cpi.EUR_CRM_Description__c;
					cpppsToUpdate.add(cppp);
				}
			}
		}
		return cpppsToUpdate;
	}

	private Integer calculateVolumePerCPPP(EUR_CRM_Contract_Payment_Plan_Period__c cppp, Integer caiDuration, Decimal cpiVolume) {
		Date cpppStart = cppp.EUR_CRM_Payment_Period_Start_Date__c;
		Date cpppEnd = cppp.EUR_CRM_Payment_Period_End_Date__c;
		Integer cpppDuration = this.calculateDuration(cpppStart, cpppEnd);
		System.debug('\n caiDuration => ' + caiDuration + '\n');
		System.debug('\n cpppDuration => ' + cpppDuration + '\n');

		return this.calculateVolumePerCPPP(cpiVolume, caiDuration, cpppDuration);
	}

	private Integer calculateVolumePerCPPP(Decimal cpiVolume, Integer caiDuration, Integer cpppDuration) {
		Integer cpppVolume = Math.round((Decimal) cpiVolume /caiDuration * cpppDuration);
		System.debug('\n cpppVolume => ' + cpppVolume + '\n');
		return cpppVolume;
	}

	private Integer calculateDuration(Date startDate, Date endDate) {
		Integer monthsBetween = startDate.monthsBetween(endDate);
		if(startDate.addMonths(monthsBetween).daysBetween(endDate) > 0) {
			monthsBetween++;
		}
		return monthsBetween;
	}

	private Boolean isPouringRefund(EUR_CRM_Contract_Product_Item__c cpi) {
		return cpi.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c.equalsIgnoreCase('EUR_DE_Pouring_Refund');
	}

	private Boolean isCPIvalid(EUR_CRM_Contract_Product_Item__c newCPI, EUR_CRM_Contract_Product_Item__c oldCPI, Set<Id> validCPIrtIds) {
		return validCPIrtIds.contains(newCPI.RecordTypeId)
			&& (newCPI.EUR_CRM_Amount__c != oldCPI.EUR_CRM_Amount__c
			|| newCPI.EUR_CRM_Volume_lt__c != oldCPI.EUR_CRM_Volume_lt__c)
			;
	}

	private Boolean isPaymentTermBySRequals(EUR_CRM_Contract_Activity_Item__c caItem, String paymentTerm) {
		return caItem.EUR_CRM_Payment_Term_By_SR__c == paymentTerm ||
			caItem.EUR_CRM_Payment_Term_By_SR__c == PAYMENT_TERM_LOCALISATION.get(paymentTerm);
	}

	public void createContractPaymentPlanPeriodYearly(Date startDate, Date endDate,
			List<EUR_CRM_Contract_Payment_Plan_Period__c> newContractPaymentPlanPeriods,
			EUR_CRM_Contract_Product_Item__c cpItem, EUR_CRM_Contract_Activity_Item__c caItem,
			Map<Id, EUR_CRM_Contract_Payment_Plan__c> relatedContractPaymentPlans, Integer totalNumOfMonths,
			Decimal accumulatedVolume, Decimal accumulatedRemainder) {

		if(totalNumOfMonths == 0) {
			totalNumOfMonths = startDate.monthsBetween(endDate);

			// Round up remaining days to one month
			if(startDate.addMonths(totalNumOfMonths).daysBetween(endDate) > 0) {
				totalNumOfMonths = totalNumOfMonths + 1;
			} else if(totalNumofMonths == 0) {
				// Special case: start Date and End Date are the same date
				totalNumOfMonths = 1;
			}

			System.debug('\n totalNumOfMonths => ' + totalNumOfMonths + '\n');
		}

		if(startDate.daysBetween(endDate) <= 365 ||
			(startDate.addYears(1).daysBetween(endDate) < 1)) {
			// Determine how many months between start date and end date (less than one year)
			// Special case when start date and end date are on the same month
			Integer numOfMonths = startDate.monthsBetween(endDate);
			// Round up remaining days to one month
			if(startDate.addMonths(numOfMonths).daysBetween(endDate) > 0) {
				numOfMonths = numOfMonths + 1;
			} else if(numOfMonths == 0) {
				// Special case: start Date and End Date are the same date
				numOfMonths = 1;
			}

			System.debug('\n numOfMonths => ' + numOfMonths + '\n');

			Decimal annualQuantity = cpItem.EUR_CRM_Quantity__c * numOfMonths / totalNumOfMonths;
			// accumulates the remainders and add one to yearly quantity if the remainder is a round number (e.g more than 1)
			accumulatedRemainder = accumulatedRemainder + annualQuantity - annualQuantity.intValue();
			if(accumulatedRemainder >= 1) {
				annualQuantity += 1;
			}

			accumulatedVolume += annualQuantity;
			// if accumulatedVolume is not the same as the actual volume, add one to annualQuantity
			if(accumulatedVolume < cpItem.EUR_CRM_Quantity__c) {
				annualQuantity += 1;
			}

			System.debug('\n annualQuantity => ' + annualQuantity + '\n');
			System.debug('\n accumulatedVolume => ' + accumulatedVolume + '\n');
			System.debug('\n relatedContractPaymentPlans => ' + relatedContractPaymentPlans + '\n');

			newContractPaymentPlanPeriods.add(new EUR_CRM_Contract_Payment_Plan_Period__c(
				EUR_CRM_Contract_Activity_Item__c 	 	= caItem.Id,
				EUR_CRM_Contract_Product_Item__c		= cpItem.Id,
				EUR_CRM_CPPP_Unit__c					= cpItem.EUR_CRM_Unit__c,
				EUR_CRM_CPPP_Rate__c 					= cpItem.EUR_CRM_Amount__c,
				EUR_CRM_CPPP_Volume__c					= annualQuantity.intValue(),
				EUR_CRM_CPPP_Amount__c					= cpItem.EUR_CRM_Amount__c * annualQuantity.intValue(),
				EUR_CRM_Contract_Payment_Plan__c  	 	= relatedContractPaymentPlans.get(caItem.EUR_CRM_Contract__c).Id,
				EUR_CRM_Description__c					= cpItem.EUR_CRM_Description__c,
				recordTypeId 						 	= paymentPlanPeriodRt,
				EUR_CRM_CPPP_Earliest_Date_of_Invoice__c= endDate.addDays(1),
				EUR_CRM_Payment_Period_Start_Date__c 	= startDate,
				EUR_CRM_Payment_Period_End_Date__c   	= endDate,
				EUR_CRM_CPPP_Payment_Term__c			= 'Nach Umsetzung'
			));
		} else {
			Decimal annualQuantity = cpItem.EUR_CRM_Quantity__c * 12 / totalNumOfMonths;

			// accumulates the remainders and add one to yearly quantity if the remainder is a round number (e.g more than 1)
			accumulatedRemainder = accumulatedRemainder + annualQuantity - annualQuantity.intValue();
			if(accumulatedRemainder >= 1) {
				annualQuantity += 1;
				accumulatedRemainder -= 1;
			}

			accumulatedVolume += annualQuantity;

			System.debug('\n annualQuantity => ' + annualQuantity + '\n');
			System.debug('\n accumulatedRemainder => ' + accumulatedRemainder + '\n');
			System.debug('\n accumulatedVolume => ' + accumulatedVolume + '\n');

			newContractPaymentPlanPeriods.add(new EUR_CRM_Contract_Payment_Plan_Period__c(
				EUR_CRM_Contract_Activity_Item__c 	 	= caItem.Id,
				EUR_CRM_Contract_Product_Item__c		= cpItem.Id,
				EUR_CRM_CPPP_Unit__c					= cpItem.EUR_CRM_Unit__c,
				EUR_CRM_CPPP_Rate__c 					= cpItem.EUR_CRM_Amount__c,
				EUR_CRM_CPPP_Volume__c					= annualQuantity.intValue(),
				EUR_CRM_CPPP_Amount__c					= cpItem.EUR_CRM_Amount__c * annualQuantity.intValue(),
				EUR_CRM_Contract_Payment_Plan__c  	 	= relatedContractPaymentPlans.get(caItem.EUR_CRM_Contract__c).Id,
				EUR_CRM_Description__c					= cpItem.EUR_CRM_Description__c,
				recordTypeId 						 	= paymentPlanPeriodRt,
				EUR_CRM_CPPP_Earliest_Date_of_Invoice__c= startDate.addYears(1),
				EUR_CRM_Payment_Period_Start_Date__c 	= startDate,
				EUR_CRM_Payment_Period_End_Date__c   	= startDate.addYears(1).addDays(-1),
				EUR_CRM_CPPP_Payment_Term__c			= 'Jährlich nach Leistungserfüllung'
			));

			createContractPaymentPlanPeriodYearly(
				startDate.addYears(1),
				endDate,
				newContractPaymentPlanPeriods,
				cpItem,
				caItem,
				relatedContractPaymentPlans,
				totalNumOfMonths, accumulatedVolume, accumulatedRemainder);
		}
	}

	public void createContractPaymentPlanPeriodHalfYearly(Date startDate, Date endDate,
			List<EUR_CRM_Contract_Payment_Plan_Period__c> newContractPaymentPlanPeriods, 
			EUR_CRM_Contract_Product_Item__c cpItem ,EUR_CRM_Contract_Activity_Item__c caItem,
			Map<Id, EUR_CRM_Contract_Payment_Plan__c> relatedContractPaymentPlans, Integer totalNumOfMonths,
			Decimal accumulatedVolume, Decimal accumulatedRemainder) {

		if(totalNumOfMonths == 0) {
			totalNumOfMonths = startDate.monthsBetween(endDate);

			// Round up remaining days to one month
			if(startDate.addMonths(totalNumOfMonths).daysBetween(endDate) > 0) {
				totalNumOfMonths = totalNumOfMonths + 1;
			} else if(totalNumofMonths == 0) {
				// Special case: start Date and End Date are the same date
				totalNumOfMonths = 1;
			}
			System.debug('\n totalNumOfMonths => ' + totalNumOfMonths + '\n');
		}

		System.debug('\n startDate.monthsBetween(endDate) => ' + startDate.monthsBetween(endDate) + '\n');

		if(startDate.monthsBetween(endDate) < 6 || (startDate.monthsBetween(endDate) == 6 && startDate.addMonths(6).daysBetween(endDate) <= 0)) {
			// Special case when start date and end date are on the same month
			Integer numOfMonths = startDate.monthsBetween(endDate);
			// Round up remaining days to one month
			if(startDate.addMonths(numOfMonths).daysBetween(endDate) > 0) {
				numOfMonths = numOfMonths + 1;
			} else if(numOfMonths == 0) {
				// Special case: start Date and End Date are the same date
				numOfMonths = 1;
			}

			System.debug('\n numOfMonths => ' + numOfMonths + '\n');

			Decimal annualQuantity = cpItem.EUR_CRM_Quantity__c * numOfMonths / totalNumOfMonths;
			// accumulates the remainders and add one to yearly quantity if the remainder is a round number (e.g more than 1)
			accumulatedRemainder = accumulatedRemainder + annualQuantity - annualQuantity.intValue();
			if(accumulatedRemainder >= 1) {
				annualQuantity += 1;
			}

			accumulatedVolume += annualQuantity;
			// if accumulatedVolume is not the same as the actual volume, add one to annualQuantity
			if(accumulatedVolume < cpItem.EUR_CRM_Quantity__c) {
				annualQuantity += 1;
			}

			System.debug('\n annualQuantity => ' + annualQuantity + '\n');
			System.debug('\n accumulatedRemainder => ' + accumulatedRemainder + '\n');
			System.debug('\n accumulatedVolume => ' + accumulatedVolume + '\n');

			newContractPaymentPlanPeriods.add(new EUR_CRM_Contract_Payment_Plan_Period__c(
				EUR_CRM_Contract_Activity_Item__c 	 	= caItem.Id,
				EUR_CRM_Contract_Product_Item__c		= cpItem.Id,
				EUR_CRM_CPPP_Unit__c					= cpItem.EUR_CRM_Unit__c,
				EUR_CRM_CPPP_Rate__c 					= cpItem.EUR_CRM_Amount__c,
				EUR_CRM_CPPP_Volume__c					= annualQuantity.intValue(),
				EUR_CRM_CPPP_Amount__c					= cpItem.EUR_CRM_Amount__c * annualQuantity.intValue(),
				EUR_CRM_Contract_Payment_Plan__c  	 	= relatedContractPaymentPlans.get(caItem.EUR_CRM_Contract__c).Id,
				EUR_CRM_Description__c				= cpItem.EUR_CRM_Description__c,
				recordTypeId 						 	= paymentPlanPeriodRt,
				EUR_CRM_Payment_Period_Start_Date__c 	= startDate,
				EUR_CRM_Payment_Period_End_Date__c   	= endDate,
				EUR_CRM_CPPP_Earliest_Date_of_Invoice__c= endDate.addDays(1),
				EUR_CRM_CPPP_Payment_Term__c			= 'Nach Umsetzung'
			));
		} else {
			Decimal annualQuantity = cpItem.EUR_CRM_Quantity__c * 6 / totalNumOfMonths;

			// accumulates the remainders and add one to yearly quantity if the remainder is a round number (e.g more than 1)
			accumulatedRemainder = accumulatedRemainder + annualQuantity - annualQuantity.intValue();
			if(accumulatedRemainder >= 1) {
				annualQuantity += 1;
				accumulatedRemainder -= 1;
			}

			accumulatedVolume += annualQuantity;

			System.debug(accumulatedRemainder);
			System.debug(accumulatedVolume);

			newContractPaymentPlanPeriods.add(new EUR_CRM_Contract_Payment_Plan_Period__c(
				EUR_CRM_Contract_Activity_Item__c 	 	= caItem.Id,
				EUR_CRM_Contract_Product_Item__c		= cpItem.Id,
				EUR_CRM_CPPP_Unit__c					= cpItem.EUR_CRM_Unit__c,
				EUR_CRM_CPPP_Rate__c 					= cpItem.EUR_CRM_Amount__c,
				EUR_CRM_CPPP_Volume__c					= annualQuantity.intValue(),
				EUR_CRM_CPPP_Amount__c					= cpItem.EUR_CRM_Amount__c * annualQuantity.intValue(),
				EUR_CRM_Contract_Payment_Plan__c  	 	= relatedContractPaymentPlans.get(caItem.EUR_CRM_Contract__c).Id,
				EUR_CRM_Description__c				= cpItem.EUR_CRM_Description__c,
				recordTypeId 						 	= paymentPlanPeriodRt,
				EUR_CRM_Payment_Period_Start_Date__c 	= startDate,
				EUR_CRM_Payment_Period_End_Date__c   	= startDate.addMonths(6).addDays(-1),
				EUR_CRM_CPPP_Earliest_Date_of_Invoice__c= startDate.addMonths(6),
				EUR_CRM_CPPP_Payment_Term__c			= 'Halbjährlich nach Leistungserfüllung'
			));

			createContractPaymentPlanPeriodHalfYearly(
				startDate.addMonths(6),
				endDate,
				newContractPaymentPlanPeriods,
				cpItem,
				caItem,
				relatedContractPaymentPlans,
				totalNumOfMonths, accumulatedVolume, accumulatedRemainder);
		}
	}

	private List<EUR_CRM_Contract_Product_Item__c> selectCPIsWhereIds(List<EUR_CRM_Contract_Product_Item__c> cpis) {
		return [
			SELECT Id
			,	EUR_CRM_Amount__c
			,	EUR_CRM_Volume_lt__c
			,	EUR_CRM_Total_Spent__c
			,	EUR_CRM_Unit__c
			,	EUR_CRM_Description__c
			,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c
			,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Start_Date__c
			,	EUR_CRM_Contract_Activity_Item__r.EUR_CRM_End_Date__c
			,	(SELECT Id
				,	EUR_CRM_CPPP_Amount__c
				,	EUR_CRM_Payment_Period_Start_Date__c
				,	EUR_CRM_Payment_Period_End_Date__c
				FROM Contract_Payment_Plan_Periods_EU__r)
			FROM EUR_CRM_Contract_Product_Item__c
			WHERE Id IN: cpis
		];
	}
}