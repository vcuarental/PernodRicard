/*********************************************************************************
 * Name: ASI_CRM_SG_GenBottleIncentiveBatch
 * Description: Generation the bottle incentive payment request and line item
 *
 * Version History
 * Date 			Developer 			Comments
 * --------------- 	-------------		--------------------------------------------------------------------------------
 * 25/01/2017 		Hugo Cheung 		Created
 * 08/11/2017 		Wilken Lee			[WL 1.0] P4.1A Block Bottle Incentive Generation from RTM Contracts
*/
global class ASI_CRM_SG_GenBottleIncentiveBatch implements Database.Batchable<sobject>, Database.stateful {

	public static final Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
	public static final Map<String, Schema.SObjectField> SKU_FIELD_MAP = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
	public static final Map<String, Schema.SObjectField> SKU_PRICE_FIELD_MAP = Schema.SObjectType.ASI_CRM_MY_SKUPriceCost__c.fields.getMap();

	public static final Id PAYMENT_REQUEST_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request');
	public static final Id PAYMENT_REQUEST_LINEITEM_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail');

	public static final Integer NINE_L_CONVERSION = 900;

	public static final Set<String> SKU_PRICE_RECORD_TYPE_ID_SET = new Set<String>{
		'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'
	};

	private static final String CONTRACTTARGET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';

	//Variable for init query
	global Date fromDate, toDate;
    global Integer fromYearInt, fromMonthInt, toYearInt, toMonthInt;
	global Id contractOwnerId;
	global Set<Id> filterContractIdSet;
    global Map<Id, Id> skuMappingMap;

	//Global Variable using when all batch completed
	Map<Id, ASI_TH_CRM_Contract__c> contractMap;
	Map<Id, ASI_MFM_SKU_Code__c> skuMap;
	Map<Id, ASI_CRM_MY_SKUPriceCost__c> skuPriceMap;
        

	Map<string, OfftakeWrapper> offtakeWrapperMap;

	global ASI_CRM_SG_GenBottleIncentiveBatch(String fromMonth, String fromYear, String toMonth, String toYear) {
		fromYearInt = Integer.valueOf(fromYear);
		fromMonthInt = Integer.valueOf(fromMonth);
		toYearInt = Integer.valueOf(toYear);
		toMonthInt = Integer.valueOf(toMonth);

		Integer toDayInt = Date.daysInMonth(toYearInt, toMonthInt);

		fromDate = Date.newInstance(fromYearInt, fromMonthInt, 1);
		toDate = Date.newInstance(toYearInt, toMonthInt, toDayInt);
		contractOwnerId = UserInfo.getUserId();

		contractMap       = new Map<Id, ASI_TH_CRM_Contract__c>();
		skuMap            = new Map<Id, ASI_MFM_SKU_Code__c>();
		offtakeWrapperMap = new Map<string, OfftakeWrapper>();
	}

	global ASI_CRM_SG_GenBottleIncentiveBatch(String fromMonth, String fromYear, String toMonth, String toYear, Set<Id> filterContractIdSet) {
		this(fromMonth, fromYear, toMonth, toYear);
		this.filterContractIdSet = filterContractIdSet;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
  		
        skuMappingMap = new Map<Id, Id>();
        skuMappingMap = getSKUMapping();
        
        String query = '';
		query += 'SELECT ASI_CRM_Latest_Vintage__r.ASI_HK_CRM_Packaging_Size__c, ';
		query += 'ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c,ASI_CRM_Latest_Vintage__c, ';
		query += 'ASI_TH_CRM_Sub_brand__c,ASI_CRM_Contract__c,ASI_CRM_SG_Customer__c,ASI_TH_CRM_Year__c,ASI_TH_CRM_Month__c, ';
		query += 'ASI_CRM_FromWS__c, ASI_CRM_SKU__c,ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ';
		query += 'ASI_TH_CRM_Quantity__c,ASI_CRM_Converted_Qty_9L__c,ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c ';
		query += ', ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c ';
		query += 'FROM ASI_TH_CRM_Actual_Offtake__c ';
		query += 'WHERE ASI_TH_CRM_Offtake_G_L_Date__c >= :fromDate AND ASI_TH_CRM_Offtake_G_L_Date__c <= :toDate ';
		
		query += 'AND ASI_CRM_SKU__c != null ';
		query += 'AND ASI_CRM_SG_Customer__c != null ';
		query += 'AND ASI_CRM_Contract__c != null ';
		query += 'AND ASI_CRM_FromWS__c != null ';
		query += 'AND ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c = \'Contract Approved\' ';
		
		/*[WL 1.0 BEGIN]*/
		query += 'AND ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c = true ';
		/*[WL 1.0 END]*/
			
		if(filterContractIdSet != null && filterContractIdSet.size() > 0) {
			String contractIdStr = '';
			for(Id contractId : filterContractIdSet) {
				contractIdStr += '\'' + contractId + '\',';
  			}
  			contractIdStr = contractIdStr.subString(0, contractIdStr.length() - 1);
  			query += 'AND ASI_CRM_Contract__c in (' + contractIdStr + ') ';
        } else {
            query += 'AND ASI_CRM_Contract__r.ownerId= \'' + this.contractOwnerid + '\' ';
        }

		query += 'ORDER BY ASI_CRM_Contract__c asc ';

  		return Database.getQueryLocator(query);
  	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = (List<ASI_TH_CRM_Actual_Offtake__c>) scope;

		List<ASI_TH_CRM_Actual_Offtake__c> validActualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>();

		Set<Id> contractIdSet = new Set<Id>();
		Set<Id> skuIdSet = new Set<Id>();

		Map<Id, Date> contractIdStartDateMap = new Map<Id, Date>();

		Date recentStartDate;

		//Find out the valid actual offtake record(s)
		for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOfftakeList) {

			if(String.isNotBlank(actualOfftake.ASI_CRM_SKU__c) && String.isNotBlank(actualOfftake.ASI_CRM_Contract__c)) {

				validActualOfftakeList.add(actualOfftake);
				skuIdSet.add(actualOfftake.ASI_CRM_SKU__c);
	  			// Special case, also retrieve the SKU from the latest vintage, if it exists
	  			if(actualOfftake.ASI_CRM_Latest_Vintage__c != null) {
	  				skuIdSet.add(actualOfftake.ASI_CRM_Latest_Vintage__c);
	  			}
	  			contractIdSet.add(actualOfftake.ASI_CRM_Contract__c);

	  			contractIdStartDateMap.put(actualOfftake.ASI_CRM_Contract__c, actualOfftake.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c);
	  			if(recentStartDate == null ||
	  			   recentStartDate < actualOfftake.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c) {
	  				recentStartDate = actualOfftake.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c;
	  			}
	  		}

	  	}

		//Execute if valid actual offtake record(s) were found
		if(validActualOfftakeList.size() > 0) {
			List<ASI_TH_CRM_Contract__c> contractList = getContractList(contractIdSet);
			contractMap.putAll(contractList);

			//Find out the sku related to contract target
	  		for(ASI_TH_CRM_Contract__c contract : contractList) {
	  			List<ASI_CRM_ContractTarget__c> contractTargetList = contract.Contract_Target__r;
	  			for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
	  				if(String.isNotBlank(contractTarget.ASI_CRM_SKU__c)) {
	  					skuIdSet.add(contractTarget.ASI_CRM_SKU__c);
	  				}
	  			}
	  		}

	  		skuMap.putAll(getSKUList(skuIdSet));

	  		for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : validActualOfftakeList) {
	  			ASI_TH_CRM_Contract__c contract = contractMap.get(actualOfftake.ASI_CRM_Contract__c);

	  			OfftakeWrapper offtakeWrapper; 
                string outletId = actualOfftake.ASI_CRM_SG_Customer__c != null ? actualOfftake.ASI_CRM_SG_Customer__c : contract.ASI_CRM_CN_Outlet_WS__c;
                string wrapper_key = contract.Id+'_'+outletId;
	  			if(!offtakeWrapperMap.containsKey(wrapper_key)) {
	  				offtakeWrapper = new OfftakeWrapper(contract, outletId, skuMappingMap);
	  			} else {
	  				offtakeWrapper = offtakeWrapperMap.get(wrapper_key);
	  			}

	  			offtakeWrapper.actualOfftakeMap.put(actualOfftake.Id, actualOfftake);
	  			offtakeWrapperMap.put(wrapper_key, offtakeWrapper);
	  		}

	  	}

  	}

  	global void finish(Database.BatchableContext BC) {

  		Datetime dateInstance = Datetime.newInstance(Date.today().year(), Date.today().month(), Date.today().day());

  		Map<string, ASI_TH_CRM_PaymentRequest__c> contractPaymentRequestMap = new Map<string, ASI_TH_CRM_PaymentRequest__c>();
  		Map<string, List<ASI_TH_CRM_PaymentRequestLineItem__c>> contractPaymentReuqestLineItemMap = new Map<string, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();

  		for(string wrapper_key : offtakeWrapperMap.keySet()) {
  			Map<Id, Decimal> totalBottleIncentiveMap     = new Map<Id, Decimal>();
  			Map<Id, Decimal> totalVolumeMap              = new Map<Id, Decimal>();
  			Map<Id, Decimal> bottleIncentiveRateMap      = new Map<Id, Decimal>();

  			OfftakeWrapper offtakeWrapper = offtakeWrapperMap.get(wrapper_key);

  			List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = offtakeWrapper.actualOfftakeMap.values();
  			for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOfftakeList) {

                ASI_CRM_ContractTarget__c contractTarget;
                                
                /* // 20170406: Aaron request only check contract target SKU's / new SKU
                // check if map by wine category
  				if(offtakeWrapper.contractTargetWineCategoryMap.containsKey(actualOfftake.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c)) {
  					contractTarget = offtakeWrapper.contractTargetWineCategoryMap.get(actualOfftake.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c);
                } else                
                // check if map by sub-brand
  				if(offtakeWrapper.contractTargetSubBrandMap.containsKey(actualOfftake.ASI_TH_CRM_Sub_brand__c)) {
  					contractTarget = offtakeWrapper.contractTargetSubBrandMap.get(actualOfftake.ASI_TH_CRM_Sub_brand__c);
                } else                
                */
                // check if map by SKU
  				if(offtakeWrapper.contractTargetSKUMap.containsKey(actualOfftake.ASI_CRM_SKU__c)) {
  					contractTarget = offtakeWrapper.contractTargetSKUMap.get(actualOfftake.ASI_CRM_SKU__c);
                } else                
                // check if map by new SKU
                if (skuMappingMap.containsKey(actualOfftake.ASI_CRM_SKU__c)){
                    if(offtakeWrapper.contractTargetSKUMap_newSKU.containsKey(skuMappingMap.get(actualOfftake.ASI_CRM_SKU__c))) {
                        contractTarget = offtakeWrapper.contractTargetSKUMap_newSKU.get(skuMappingMap.get(actualOfftake.ASI_CRM_SKU__c));
                    }
                }
                
                if (contractTarget != null){

  					ASI_MFM_SKU_Code__c contractTargetSKU = skuMap.get(contractTarget.ASI_CRM_SKU__c);
  					ASI_MFM_SKU_Code__c offtakeSKU = skuMap.get(actualOfftake.ASI_CRM_SKU__c);

  					Decimal bottleIncentive = contractTarget.ASI_CRM_Bottle_Incentive__c == null ? 0 : contractTarget.ASI_CRM_Bottle_Incentive__c;
  					Decimal bottleSize = contractTargetSKU.ASI_HK_CRM_Std_Bottle_Size__c == null ? 0 : contractTargetSKU.ASI_HK_CRM_Std_Bottle_Size__c;
  					Decimal bottleIncentiveRate = bottleIncentive / (bottleSize / NINE_L_CONVERSION);

  					bottleIncentiveRateMap.put(actualOfftake.ASI_TH_CRM_Sub_brand__c, bottleIncentiveRate);

  					Decimal offtakeSKUBottleSize = offtakeSKU.ASI_HK_CRM_Std_Bottle_Size__c == null ? 0 : offtakeSKU.ASI_HK_CRM_Std_Bottle_Size__c;

  					Decimal totalBottleIncentive = 0;
  					if(totalBottleIncentiveMap.containsKey(actualOfftake.ASI_TH_CRM_Sub_brand__c)) {
  						totalBottleIncentive = totalBottleIncentiveMap.get(actualOfftake.ASI_TH_CRM_Sub_brand__c);
  					}
                    
                    decimal volume9L = actualOfftake.ASI_TH_CRM_Quantity__c * actualOfftake.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c / NINE_L_CONVERSION;
                    
  					totalBottleIncentive += volume9L * bottleIncentiveRate;
  					totalBottleIncentiveMap.put(actualOfftake.ASI_TH_CRM_Sub_brand__c, totalBottleIncentive);

  					Decimal totalVolume = 0;
  					if(totalVolumeMap.containsKey(actualOfftake.ASI_TH_CRM_Sub_brand__c)) {
  						totalVolume = totalVolumeMap.get(actualOfftake.ASI_TH_CRM_Sub_brand__c);
  					}
  					totalVolume += volume9L;
  					totalVolumeMap.put(actualOfftake.ASI_TH_CRM_Sub_brand__c, totalVolume);
  				}

  			}

  			ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
  			paymentRequest.ASI_CRM_CN_OutletWS__c = offtakeWrapper.outletId;
  			paymentRequest.ASI_TH_CRM_Contract__c = offtakeWrapper.contract.Id;
  			paymentRequest.ASI_CRM_SG_Invoice_No__c = offtakeWrapper.contract.Name + '-' + dateInstance.format('YYYYMMdd', UserInfo.getTimeZone().getId());
  			paymentRequest.ASI_TH_CRM_Status__c = 'Draft';
  			//paymentRequest.ASI_CRM_SG_Invoice_Date__c = Date.today();
  			paymentRequest.ASI_CRM_System_Generated__c = true;
  			paymentRequest.RecordTypeId = PAYMENT_REQUEST_RECORD_TYPE_ID;
  			paymentRequest.ASI_CRM_Generation_From_Date__c = fromDate;
  			paymentRequest.ASI_CRM_Generation_To_Date__c = toDate;
            paymentRequest.ownerid = offtakeWrapper.contract.ownerid;

  			List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLineItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
  			for(Id subBrandId : totalBottleIncentiveMap.keySet()) {
  				decimal amount = totalBottleIncentiveMap.containsKey(subBrandId) ? totalBottleIncentiveMap.get(subBrandId) : 0;
                if (amount.setScale(2)>0) {
                    ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c();
                    paymentRequestLineItem.ASI_CRM_SG_Sub_brand__c = subBrandId;
                    paymentRequestLineItem.ASI_CRM_Volume_9L__c = totalVolumeMap.containsKey(subBrandId) ? totalVolumeMap.get(subBrandId) : 0;
                    paymentRequestLineItem.ASI_CRM_Contracted_Rate_9L__c = bottleIncentiveRateMap.containsKey(subBrandId) ? bottleIncentiveRateMap.get(subBrandId) : 0;
                    paymentRequestLineItem.ASI_TH_CRM_Amount__c = amount.setScale(2);
                    paymentRequestLineItem.ASI_CRM_Adjusted_Amount__c = amount.setScale(2);
                    paymentRequestLineItem.ASI_CRM_SG_Type__c = 'Bottle Incentive';
                    paymentRequestLineItem.RecordTypeId = PAYMENT_REQUEST_LINEITEM_RECORD_TYPE_ID;
                    paymentRequestLineItemList.add(paymentRequestLineItem);
                }
                
  			}
			
            if (paymentRequestLineItemList.size()>0){
                string payment_key = offtakeWrapper.contract.Id+'_'+offtakeWrapper.outletId;
                contractPaymentRequestMap.put(payment_key, paymentRequest);
  				contractPaymentReuqestLineItemMap.put(payment_key, paymentRequestLineItemList);
            }
  			
  		}

        set<string> set_paymentID = new set<string>();
        List<string> set_contractID = new List<string>();
        
        if (contractPaymentRequestMap!=null){
            insert contractPaymentRequestMap.values();

            List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLineItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
    
            for(string wrapper_key : contractPaymentRequestMap.keySet()) {
                Id paymentRequestId = contractPaymentRequestMap.get(wrapper_key).Id;
                set_paymentID.add(paymentRequestId);
                set_contractID.add(contractPaymentRequestMap.get(wrapper_key).ASI_TH_CRM_Contract__c);
                for(ASI_TH_CRM_PaymentRequestLineItem__c paymentRequestLineItem : contractPaymentReuqestLineItemMap.get(wrapper_key)) {
                    paymentRequestLineItem.ASI_TH_CRM_Payment_Request__c = paymentRequestId;
                    paymentRequestLineItemList.add(paymentRequestLineItem);
                }
            }
    
            insert paymentRequestLineItemList;
            
            ASI_CRM_SG_ROI_Helper roi = new ASI_CRM_SG_ROI_Helper(set_contractID);
        	roi.calculateROI();
        }
        
        sendEMailNotification(BC.getJobId(), set_paymentID);
  		
  	}

	private List<ASI_TH_CRM_Contract__c> getContractList(Set<Id> contractIdSet) {
		String queryStr = 'SELECT ';
		queryStr += genQueryField(CONTRACT_FIELD_MAP);
		queryStr += ', (SELECT ID, Name, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c, ' +
		' ASI_CRM_Bottle_Incentive__c, ASI_CRM_Subbrand__c FROM Contract_Target__r WHERE recordtype.developername = :CONTRACTTARGET_RECORD_TYPE)';
		queryStr += ' FROM ASI_TH_CRM_Contract__c';
		queryStr += ' WHERE Id in :contractIdSet';
		return (List<ASI_TH_CRM_Contract__c>) Database.query(queryStr);
	}

	private List<ASI_MFM_SKU_Code__c> getSKUList(Set<Id> skuIdSet) {
		String queryStr = 'SELECT ';
		queryStr += genQueryField(SKU_FIELD_MAP);
		queryStr += ' FROM ASI_MFM_SKU_Code__c';
		queryStr += ' WHERE Id in :skuIdSet';
		return (List<ASI_MFM_SKU_Code__c>) Database.query(queryStr);
	}

	private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
		String queryField = '';
		for(String field : fieldMap.keySet()) {
		queryField += field + ',';
		}
		return queryField.subString(0, queryField.length() - 1);
	}

	//Wrapper Class
	public class OfftakeWrapper {

		public ASI_TH_CRM_Contract__c contract {get; set;}
		public Id outletId {get; set;}

		public Map<Id, ASI_TH_CRM_Actual_Offtake__c> actualOfftakeMap {get; set;}
		public Map<Id, ASI_CRM_ContractTarget__c> contractTargetSubBrandMap {get; set;}
		public Map<Id, ASI_CRM_ContractTarget__c> contractTargetSKUMap {get; set;}
		public Map<Id, ASI_CRM_ContractTarget__c> contractTargetWineCategoryMap {get; set;}
		public Map<Id, ASI_CRM_ContractTarget__c> contractTargetSKUMap_newSKU {get; set;}


		public offtakeWrapper(ASI_TH_CRM_Contract__c contract, Id outletId, Map<id, id> map_newSKU) {
			actualOfftakeMap = new Map<Id, ASI_TH_CRM_Actual_Offtake__c>();
			contractTargetSubBrandMap = new Map<Id, ASI_CRM_ContractTarget__c>();
			contractTargetSKUMap = new Map<Id, ASI_CRM_ContractTarget__c>();
			contractTargetWineCategoryMap = new Map<Id, ASI_CRM_ContractTarget__c>();
			contractTargetSKUMap_newSKU = new Map<Id, ASI_CRM_ContractTarget__c>();

			this.contract = contract;
			this.outletId = outletId;
			setContractTargetBySubBrand();
			setContractTargetBySKU();
			setContractTargetByWineCategory();
			setContractTargetBySKU_newSKU(map_newSKU);
		}

		private void setContractTargetBySubBrand() {
			for(ASI_CRM_ContractTarget__c contractTarget : contract.Contract_Target__r) {
                if (contractTarget.ASI_CRM_Bottle_Incentive__c != null) {
                    if(String.isNotBlank(contractTarget.ASI_CRM_Subbrand__c)) {
                        contractTargetSubBrandMap.put(contractTarget.ASI_CRM_Subbrand__c, contractTarget);
                    } 
                    /*
                    // able to group sub-brand even contract target has no sub-brand input
                    else {
                        contractTargetSubBrandMap.put(contractTarget.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, contractTarget);
                    }
					*/
                }
                
			}
		}
        
         // Fill the contractTarget and map them by SKU
        private void setContractTargetBySKU() {
            for(ASI_CRM_ContractTarget__c contractTarget : contract.Contract_Target__r) {
                if (contractTarget.ASI_CRM_Bottle_Incentive__c != null) {
                    if(contractTarget.ASI_CRM_SKU__c != null/* && contractTarget.ASI_CRM_Subbrand__c == null*/) {
                        contractTargetSKUMap.put(contractTarget.ASI_CRM_SKU__c, contractTarget);
                    }
                }
            }
        }
           
         // Fill the contractTarget and map them by Wine Category
        private void setContractTargetByWineCategory() {
            for(ASI_CRM_ContractTarget__c contractTarget : contract.Contract_Target__r) {
                if (contractTarget.ASI_CRM_Bottle_Incentive__c != null) {
                    if(contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c != null) {
                        contractTargetWineCategoryMap.put(contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c, contractTarget);
                    }
                }
            }
        }
           
         // Fill the contractTarget and map them by New SKU
        private void setContractTargetBySKU_newSKU(Map<id, id> map_newSKU) {
            for(ASI_CRM_ContractTarget__c contractTarget : contract.Contract_Target__r) {
                if (contractTarget.ASI_CRM_Bottle_Incentive__c != null) {
                    if (contractTarget.ASI_CRM_SKU__c != null/* && contractTarget.ASI_CRM_Subbrand__c == null*/ && map_newSKU.containsKey(contractTarget.ASI_CRM_SKU__c)) {
                        contractTargetSKUMap_newSKU.put(map_newSKU.get(contractTarget.ASI_CRM_SKU__c), contractTarget);
                    }
                }
            }
        }
           


	}

    public void sendEMailNotification(Id BC_ID, set<string> set_paymentID){
         AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC_ID];
                          
       // Send an email to the Apex job's submitter 
       //   notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {a.CreatedBy.Email};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Bottle Incentive Payment Request Generation ' + a.Status);
        if (set_paymentID.size()>0){
            string ebody = '<p>The Bottle Incentive Payment Request generation for ' + this.fromMonthInt + '/' + this.fromYearInt + ' to ' + 
                this.toMonthInt + '/' + this.toYearInt + ' completed with '+ a.NumberOfErrors + ' errors.</p>';
            ebody += '<table width="100%">';
            ebody += '<tr><th>Payment Request</th><th>Outlet</th><th>Contract</th>';
            for (ASI_TH_CRM_PaymentRequest__c p : [
                select id, name, ASI_CRM_CN_OutletWS__r.name, ASI_TH_CRM_Contract__r.name from ASI_TH_CRM_PaymentRequest__c
                where id in :set_paymentID
            ]){
                ebody += '<tr><td>'+p.name+'</td><td>'+p.ASI_CRM_CN_OutletWS__r.name+'</td><td>'+p.ASI_TH_CRM_Contract__r.name+'</td></tr>';
            }
            ebody += '</table>';
            mail.setHtmlBody(ebody);
        } else {
            mail.setPlainTextBody
           ('The Bottle Incentive Payment Request generation for ' + this.fromMonthInt + '/' + this.fromYearInt + ' to ' + this.toMonthInt + '/' + this.toYearInt + 
           ' completed with '+ a.NumberOfErrors + ' errors. No payment is generated.');
        }
       
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    /*********************************************************************************
     * Description: Get the mapping of sku
     *
     * Return: SKU Mapping contain the SKU Id and the newest SKU Id
    *********************************************************************************/
    private Map<Id, Id> getSKUMapping() {
        Map<Id, Id> skuMappingMap = new Map<Id, Id>();

        Id sgSKUMappingRecordType = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cSG_SKU_Mapping');

        for(ASI_CRM_SKU_Mapping__c skuMapping : [SELECT ASI_CRM_SKU__c, ASI_CRM_New_SKU__c 
                                                 FROM ASI_CRM_SKU_Mapping__c
                                                 WHERE RecordTypeId = :sgSKUMappingRecordType]) {
            skuMappingMap.put(skuMapping.ASI_CRM_SKU__c, skuMapping.ASI_CRM_New_SKU__c);
        }

        for(Id skuId : skuMappingMap.keySet()) {
            Id tempSKUId = skuMappingMap.get(skuId);
            while(skuMappingMap.containsKey(tempSKUId)) {
                tempSKUId = skuMappingMap.get(tempSKUId);
            }
            skuMappingMap.put(skuId, tempSKUId);
        }
        
        for(Id skuId : skuMappingMap.values()) {
            skuMappingMap.put(skuId, skuId);
        }

        return skuMappingMap;
    }
    
}