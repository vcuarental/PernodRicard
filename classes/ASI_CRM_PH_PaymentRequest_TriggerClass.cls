/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_PaymentRequest_TriggerClass
 * Description: Contains the methods for ASI_TH_CRM_PaymentRequest__c trigger
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-04       Calvin Chiu (LAPUTA)    Created
 * 2018-10-29		Calvin Chiu	(LAPUTA)	Updated method to run in before insert; logic for bottle rebate and staff incentive
 * 2018-11-14		Wilken					[WL 1.0] Update exchange rate to payment
 * 2018-11-28		Wilken					[WL 2.0] Default Payment Ref Number and Invoice Date
 * 2018-12-18		Calvin Chiu (LAPUTA)	Updated new fields used in item creation
 * 2019-01-14		Calvin Chiu (LAPUTA)	Updated afterUpdate to recalculate line item amount
 * 2019-02-25		Vincent Lam (LAPUTA)	[VL 1.0] Fix validation logic
 ****************************************************************************************************************************/
public without sharing class ASI_CRM_PH_PaymentRequest_TriggerClass{

	private static final String PAYMENT_REQUEST_STATUS_DRAFT = 'Draft';
	private static final String PAYMENT_REQUEST_STATUS_READY_FOR_APPROVAL = 'Ready for Approval';
	private static final String PAYMENT_REQUEST_STATUS_PENDING_REGIONAL_SALES_MANAGER = 'Pending Regional Sales Manager';
	private static final String PAYMENT_REQUEST_STATUS_PENDING_HEAD_OF_NATIONAL_ON_TRADE = 'Pending Head of National On Trade';
	private static final String PAYMENT_REQUEST_STATUS_PENDING_HEAD_OF_FINANCE_AND_OPERATION = 'Pending Head of Finance and Operations';
	private static final String PAYMENT_REQUEST_STATUS_PENDING_MANAGING_DIRECTOR = 'Pending Managing Director';
	private static final String PAYMENT_REQUEST_STATUS_SUBMITTED = 'Submitted';
	private static final String PAYMENT_REQUEST_STATUS_APPROVED = 'Approved';
	private static final String PAYMENT_REQUEST_STATUS_REJECTED = 'Rejected';
	private static final String PAYMENT_REQUEST_STATUS_PAID = 'Paid';

	private static final String PAYMENT_TYPE_CONTRACT_FUND = 'Contract Fund';
	private static final String PAYMENT_TYPE_ACTIVATION_FUND = 'Activation Fund';
	private static final String PAYMENT_TYPE_MERCHANDISE = 'Merchandise';
	private static final String PAYMENT_TYPE_PURCHASE_INCENTIVE = 'Purchase Incentive';
	private static final String PAYMENT_TYPE_BOTTLE_REBATE = 'Bottle Rebate';
	private static final String PAYMENT_TYPE_STAFF_INCENTIVE = 'Staff Incentive';
	
    private final static string RTID_PAYMENTREQUESTLINE = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_PH_Payment_Request_Detail');

	/*[WL 1.0] BEGIN*/
    public static void routineBeforeUpsert(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, Map<id,ASI_TH_CRM_PaymentRequest__c> oldMap){
		List<ASI_MFM_Exchange_Rate__c> exRateList = [SELECT ASI_MFM_Exchange_Rate__c FROM ASI_MFM_Exchange_Rate__c WHERE ASI_MFM_Country__c = 'SG' AND ASI_MFM_Base_Currency__c = 'SGD' AND ASI_MFM_Counter_Currency__c = 'USD' AND ASI_MFM_Application__c = 'MFM'
													ORDER BY ASI_MFM_Effective_Date__c DESC LIMIT 1];

		Set<Id> contractIdSet = new Set<Id>();

        for(ASI_TH_CRM_PaymentRequest__c payment : trigger_new) {
			contractIdSet.add(payment.ASI_TH_CRM_Contract__c);
        }

		List<ASI_TH_CRM_Contract__c> contractList = [SELECT ASI_CRM_Contract_Duty_Type__c FROM ASI_TH_CRM_Contract__c WHERE ID in :contractIdSet];
		Map<Id, String> contractDutyTypeMap = new Map<Id, String>();
		for (ASI_TH_CRM_Contract__c contract:contractList){
			contractDutyTypeMap.put(contract.Id, contract.ASI_CRM_Contract_Duty_Type__c);
		}

		for(ASI_TH_CRM_PaymentRequest__c payment : trigger_new) {
			if (payment.ASI_TH_CRM_Status__c == 'Draft'){
				if (contractDutyTypeMap.get(payment.ASI_TH_CRM_Contract__c) != null && contractDutyTypeMap.get(payment.ASI_TH_CRM_Contract__c) == 'Duty Free'){
					if (exRateList.size() == 1)
						payment.ASI_CRM_Exchange_Rate__c = exRateList.get(0).ASI_MFM_Exchange_Rate__c;
				}
				else {
					payment.ASI_CRM_Exchange_Rate__c = 1;
				}
			}
        }
    }
	/*[WL 1.0] END*/

    public static void routineBeforeInsert(List<ASI_TH_CRM_PaymentRequest__c> trigger_new){
        // check if sum of payment request item payment amount is larger than that of the parent payment request for bottle rebate and staff incentive
        Id paymentReqRtId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request');
        Id contractFundRtId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Contract_Fund');
        Id purchaseIncentiveRtId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Purchase_Incentive');

        Set<Id> bottleStaffContractSet = new Set<Id>();
        Set<Id> contractUnderValidation = new Set<Id>();

		/*[WL 2.0] BEGIN*/
		List<ASI_TH_CRM_PaymentRequest__c> latestPayment = [SELECT Name FROM ASI_TH_CRM_PaymentRequest__c WHERE RecordType.DeveloperName like 'ASI_CRM_PH%' AND Name like 'PR%' ORDER BY CreatedDate desc LIMIT 1];
		Integer refNumCounter;
		if (latestPayment.size() == 0)
			refNumCounter = 0;
		else {
			refNumCounter = Integer.ValueOf(latestPayment.get(0).Name.right(6));
		}
		/*[WL 2.0] END*/

        for(ASI_TH_CRM_PaymentRequest__c req: trigger_new){
			/*[WL 2.0] BEGIN*/
			refNumCounter++;
			String newRefNum = '000000' + String.ValueOf(refNumCounter);
			req.Name = 'PR' + newRefNum.right(6);

			if (req.ASI_CRM_SG_Invoice_No__c == null)
				req.ASI_CRM_SG_Invoice_No__c = req.Name;
			/*[WL 2.0] END*/
        }        
        validatePaymentRequest(trigger_new);
    }

    public static void routineAfterInsert(List<ASI_TH_CRM_PaymentRequest__c> trigger_new){
        Id paymentReqRtId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request');
        Set<String> paymentType1 = new Set<String>{'Contract Fund','Activation Fund','Merchandise','Purchase Incentive'};
        Set<Id> contractSet = new Set<Id>();
        for(ASI_TH_CRM_PaymentRequest__c req: trigger_new){
            if(req.recordTypeId == paymentReqRtId){
            	contractSet.add(req.ASI_TH_CRM_Contract__c);
            }
        }

        if(!contractSet.isEmpty()){
            Map<Id, List<ASI_CRM_ContractTarget__c>> contractTargetMap = new Map<Id, List<ASI_CRM_ContractTarget__c>>();
            for(ASI_CRM_ContractTarget__c target: [select ASI_CRM_Weight_by_Outlet_Sales_Revenue__c, ASI_CRM_Contract__c, ASI_CRM_SKU__c, ASI_CRM_Target_Total_Sales__c, ASI_CRM_Achieved_Amount__c, ASI_CRM_Staff_Incentive__c, ASI_CRM_Bottle_Rebate__c, ASI_CRM_Till_Date_Sales_Bottle__c from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c in: contractSet for update]){
                // 1. Calculate sum map for contract fund / activation fund / merchandise / purchase incentive
                List<ASI_CRM_ContractTarget__c> temp = contractTargetMap.get(target.ASI_CRM_Contract__c);
                if(temp == null){
                    temp = new List<ASI_CRM_ContractTarget__c>{target};
                }
                else{
                    temp.add(target);
                }
                contractTargetMap.put(target.ASI_CRM_Contract__c, temp);
            }
            
            List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentReqItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

            for(ASI_TH_CRM_PaymentRequest__c req: trigger_new){
                List<ASI_CRM_ContractTarget__c> targets = contractTargetMap.get(req.ASI_TH_CRM_Contract__c);
                if(targets != null){
                    for(ASI_CRM_ContractTarget__c target: targets){
                        ASI_TH_CRM_PaymentRequestLineItem__c item = new ASI_TH_CRM_PaymentRequestLineItem__c();
                        item.ASI_CRM_SKU__c = target.ASI_CRM_SKU__c;
                        item.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_PH_Payment_Request_Detail');
                        item.ASI_TH_CRM_Payment_Request__c = req.Id;

                        if(paymentType1.contains(req.ASI_CRM_Payment_Type__c)){
                            Decimal paymentAmt = checkNullDecimal(req.ASI_CRM_Payment_Amount__c);
                            item.ASI_TH_CRM_Amount__c = paymentAmt * target.ASI_CRM_Weight_by_Outlet_Sales_Revenue__c / 100;
                        	paymentReqItems.add(item);
                        }
                        else{
                            Decimal tillDateSalesBottle = target.ASI_CRM_Till_Date_Sales_Bottle__c != null ? target.ASI_CRM_Till_Date_Sales_Bottle__c : 0;
                            if(req.ASI_CRM_Payment_Type__c == 'Bottle Rebate'){
                                Decimal botteRebate = checkNullDecimal(target.ASI_CRM_Bottle_Rebate__c);
                                item.ASI_TH_CRM_Amount__c = tillDateSalesBottle * botteRebate;
                                paymentReqItems.add(item);
                            }
                            else if(req.ASI_CRM_Payment_Type__c == 'Staff Incentive'){
                                Decimal staffIncentive = checkNullDecimal(target.ASI_CRM_Staff_Incentive__c);
                                item.ASI_TH_CRM_Amount__c = tillDateSalesBottle * staffIncentive;
                                paymentReqItems.add(item);
                            }
                        }
                    }
                }
            }
            insert paymentReqItems;
        }
    }

	public static void routineBeforeDelete(list<ASI_TH_CRM_PaymentRequest__c> trigger_old){
        for(ASI_TH_CRM_PaymentRequest__c payment : trigger_old) {
			if (payment.ASI_TH_CRM_Status__c != 'Draft' && payment.ASI_TH_CRM_Status__c != 'Rejeced')
				payment.addError('You cannot delete submitted or approved payment');
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_TH_CRM_PaymentRequest__c> trigger_new, Map<Id, ASI_TH_CRM_PaymentRequest__c> trigger_old){
    	List<ASI_TH_CRM_PaymentRequest__c> paymentRequestToValidate = new List<ASI_TH_CRM_PaymentRequest__c>();
    	for(ASI_TH_CRM_PaymentRequest__c req: trigger_new){
    		//if(req.ASI_CRM_Payment_Amount__c != trigger_old.get(req.Id).ASI_CRM_Payment_Amount__c){
    			paymentRequestToValidate.add(req);
    		//}
    	}    	
    	validatePaymentRequest(paymentRequestToValidate);
    }

	public static void routineAfterUpdate(List<ASI_TH_CRM_PaymentRequest__c> trigger_new, Map<Id, ASI_TH_CRM_PaymentRequest__c> trigger_old) {
		Id paymentReqRtId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request');
    	Id paymentReqItemRtId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_PH_Payment_Request_Detail');
    	Set<String> paymentType1 = new Set<String>{'Contract Fund','Activation Fund','Merchandise','Purchase Incentive'};
    	
    	Map<Id, Id> paymentRequestForReCalc = new Map<Id, Id>();
    	Map<Id, Decimal> paymentRequestAmountMap = new Map<Id, Decimal>();
    	for(ASI_TH_CRM_PaymentRequest__c req: trigger_new){
    		if(req.ASI_CRM_Payment_Amount__c != trigger_old.get(req.Id).ASI_CRM_Payment_Amount__c && paymentType1.contains(req.ASI_CRM_Payment_Type__c)){
    			paymentRequestForReCalc.put(req.Id, req.ASI_TH_CRM_Contract__c);
    			paymentRequestAmountMap.put(req.Id, req.ASI_CRM_Payment_Amount__c);
    		}
    	}
    	
    	if(!paymentRequestForReCalc.isEmpty()){
            Map<Id, List<ASI_CRM_ContractTarget__c>> contractTargetMap = new Map<Id, List<ASI_CRM_ContractTarget__c>>();
            for(ASI_CRM_ContractTarget__c target: [select ASI_CRM_Weight_by_Outlet_Sales_Revenue__c, ASI_CRM_Contract__c, ASI_CRM_SKU__c from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c in: paymentRequestForReCalc.values() for update]){
                List<ASI_CRM_ContractTarget__c> temp = contractTargetMap.get(target.ASI_CRM_Contract__c);
                if(temp == null){
                    temp = new List<ASI_CRM_ContractTarget__c>{target};
                }
                else{
                    temp.add(target);
                }
                contractTargetMap.put(target.ASI_CRM_Contract__c, temp);
            }
            
            List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentReqItems = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();            
            
        	for(ASI_TH_CRM_PaymentRequestLineItem__c item: [select ASI_TH_CRM_Payment_Request__c, ASI_CRM_SKU__c from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__c in: paymentRequestForReCalc.keySet() and recordTypeId =: paymentReqItemRtId for update]){
        		Id contractId = paymentRequestForReCalc.get(item.ASI_TH_CRM_Payment_Request__c);
        		List<ASI_CRM_ContractTarget__c> targets = contractTargetMap.get(contractId);
        		if(!targets.isEmpty()){
	                for(ASI_CRM_ContractTarget__c target: targets){
	                    if(item.ASI_CRM_SKU__c == target.ASI_CRM_SKU__c){
	                        Decimal paymentAmt = checkNullDecimal(paymentRequestAmountMap.get(item.ASI_TH_CRM_Payment_Request__c));
	                        item.ASI_TH_CRM_Amount__c = paymentAmt * target.ASI_CRM_Weight_by_Outlet_Sales_Revenue__c / 100;
	                    	paymentReqItems.add(item);
	                    }
	                }
            	}
            }
            
            update paymentReqItems;
    	}		
		
		rollUpPaymentRequestAmountToContract(trigger_new);
	}

    private static Decimal checkNullDecimal(Decimal input){
        if(input == null)
        	return 0;
        return input;
    }
    
    private static void validatePaymentRequest(List<ASI_TH_CRM_PaymentRequest__c> paymentRequests){
    	// check if sum of payment request item payment amount is larger than that of the parent payment request for bottle rebate and staff incentive
        Id paymentReqRtId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request');
        Id contractFundRtId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Contract_Fund');
        Id purchaseIncentiveRtId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Purchase_Incentive');

        Set<Id> bottleStaffContractSet = new Set<Id>();
        Set<Id> contractUnderValidation = new Set<Id>();
		Set<Id> paymentRequestToBeValidate = new Set<Id>();
    	
    	for(ASI_TH_CRM_PaymentRequest__c req: paymentRequests){
            if(req.recordTypeId == paymentReqRtId && (req.ASI_CRM_Payment_Type__c == 'Staff Incentive' || req.ASI_CRM_Payment_Type__c == 'Bottle Rebate')){
            	bottleStaffContractSet.add(req.ASI_TH_CRM_Contract__c);
            }
            if(req.ASI_CRM_Payment_Type__c == 'Contract Fund' || req.ASI_CRM_Payment_Type__c == 'Purchase Incentive' || req.ASI_CRM_Payment_Type__c == 'Activation Fund' || req.ASI_CRM_Payment_Type__c == 'Merchandise'){
            	contractUnderValidation.add(req.ASI_TH_CRM_Contract__c);
            }
			if(req.Id <> null){
				paymentRequestToBeValidate.add(req.Id);
			}
        }
		system.debug('contractUnderValidation:: ' + contractUnderValidation);
        // get all payment request under the same contract
        Map<Id, String> paymentReqContractTypeMap = new Map<Id, String>();
		map<string, decimal> map_contractType_amount = new map<string, decimal>();
		for(AggregateResult ar : [
            select
                ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c contractId,
				sum(ASI_CRM_Amount_Number__c) amount,
                ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c type
            from 
                ASI_TH_CRM_PaymentRequestLineItem__c
            where
                recordtypeid = :RTID_PAYMENTREQUESTLINE
				and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c in :contractUnderValidation
				and ASI_TH_CRM_Payment_Request__c not in :paymentRequestToBeValidate
                and ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c <> 'Rejected'
            group by
				ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,
                ASI_TH_CRM_Payment_Request__r.ASI_CRM_Payment_Type__c
        ]){
            string contractId = string.valueOf(ar.get('contractId'));
            string type = string.valueOf(ar.get('type'));
			decimal amount = (decimal)ar.get('amount');
            map_contractType_amount.put(contractId + '_' + type, amount);
        }
		/*
        for(ASI_TH_CRM_PaymentRequest__c req: [select ASI_TH_CRM_Contract__c, ASI_CRM_Payment_Type__c, ASI_CRM_Payment_Amount__c from ASI_TH_CRM_PaymentRequest__c where ASI_TH_CRM_Contract__c in :contractUnderValidation and id not in: paymentRequests for update]){
        	//paymentReqContractTypeMap.put(req.ASI_TH_CRM_Contract__c, req.ASI_CRM_Payment_Type__c);
        }
		*/

        // check if contract net sales is valid against payment schedule's ASI_CRM_Target_Achievement_Amount__c value
        Map<Id, ASI_TH_CRM_Contract__c> contractMap = new Map<Id, ASI_TH_CRM_Contract__c>();
        for(ASI_TH_CRM_Contract__c contract: [select ASI_CRM_SG_Net_Sales__c, ASI_CRM_Merchandise_Amount__c, ASI_CRM_Activation_Fund_Amount__c from ASI_TH_CRM_Contract__c where id in: contractUnderValidation for update]){
            contractMap.put(contract.Id, contract);
        }

        // check if payment amount is valid against sponsorship and target achievement amount
        Map<Id, Decimal> map_contractFundScheme_entitled = new Map<Id, Decimal>(); // contractId (contract fund) : target achievement
        Map<Id, Decimal> map_purchaseIncentiveScheme_entitled = new Map<Id, Decimal>(); // contractId (purchase incentive) : sponsorship
        for(ASI_CRM_Payment_Schedule__c schd: [select ASI_CRM_Sys_Parent_Record__c, ASI_CRM_Type__c, ASI_CRM_Schedule_Date__c, ASI_CRM_Issuable__c, ASI_CRM_Sponsorship__c, ASI_CRM_Payout_Amount__c, ASI_CRM_Contract__c, ASI_CRM_Target_Achievement_Amount__c, recordTypeId, RecordType.DeveloperName from ASI_CRM_Payment_Schedule__c where ASI_CRM_Contract__c in: contractUnderValidation and (recordTypeId =: contractFundRtId or recordTypeId =: purchaseIncentiveRtId) for update]){
            if(schd.recordTypeId == contractFundRtId){
                /* [VL 1.0] BEGIN */
				/*
				if (schd.ASI_CRM_Issuable__c) {
                    if(map_contractFundScheme_entitled.get(schd.ASI_CRM_Contract__c) == null) {
                        map_contractFundScheme_entitled.put(schd.ASI_CRM_Contract__c, schd.ASI_CRM_Sponsorship__c);
                    } else {
                        map_contractFundScheme_entitled.put(schd.ASI_CRM_Contract__c, map_contractFundScheme_entitled.get(schd.ASI_CRM_Contract__c) + schd.ASI_CRM_Sponsorship__c);
                    }
                }
				*/
				if (schd.ASI_CRM_Issuable__c || (
					schd.ASI_CRM_Type__c == 'Date' && schd.ASI_CRM_Schedule_Date__c < system.now()
				)) {
                    if(map_contractFundScheme_entitled.get(schd.ASI_CRM_Contract__c) == null) {
                        map_contractFundScheme_entitled.put(schd.ASI_CRM_Contract__c, schd.ASI_CRM_Sponsorship__c);
                    } else {
                        map_contractFundScheme_entitled.put(schd.ASI_CRM_Contract__c, map_contractFundScheme_entitled.get(schd.ASI_CRM_Contract__c) + schd.ASI_CRM_Sponsorship__c);
                    }
                }
                /* [VL 1.0] END */
            }
            else if(schd.recordTypeId == purchaseIncentiveRtId){
                if(schd.ASI_CRM_Issuable__c && !schd.ASI_CRM_Sys_Parent_Record__c){
                    Decimal temp = map_purchaseIncentiveScheme_entitled.get(schd.ASI_CRM_Contract__c);
                    if(temp != null){
                        map_purchaseIncentiveScheme_entitled.put(schd.ASI_CRM_Contract__c, temp + schd.ASI_CRM_Payout_Amount__c);
                    }
                    else{
                        map_purchaseIncentiveScheme_entitled.put(schd.ASI_CRM_Contract__c, schd.ASI_CRM_Payout_Amount__c);
                    }
                }
            }
        }
        System.debug(map_purchaseIncentiveScheme_entitled);
        System.debug(map_contractFundScheme_entitled);
		// validate contract fund  and purchase incentive
		for(ASI_TH_CRM_PaymentRequest__c req: paymentRequests){
        	if(req.ASI_CRM_Payment_Type__c == 'Contract Fund' || req.ASI_CRM_Payment_Type__c == 'Purchase Incentive'){
                // purchase incentive specific validation
                if(req.ASI_CRM_Payment_Type__c == 'Purchase Incentive'){
                    Decimal entitledPurchaseIncentiveAmount = map_purchaseIncentiveScheme_entitled.get(req.ASI_TH_CRM_Contract__c);
					/* [VL 1.0] BEGIN */
                    if(entitledPurchaseIncentiveAmount == null) {
                        req.addError('There is no Purchase Incentive Scheme for this contract');
                    } else 
					/* [VL 1.0] END */
                    if(req.ASI_CRM_Payment_Amount__c > entitledPurchaseIncentiveAmount){
                        req.addError('Payment Amount must be less than Sponsorship stated in respective Payment Schedule');
                    }
					/* [VL 1.0] BEGIN */
					else 
					if(map_contractType_amount.containsKey(req.ASI_TH_CRM_Contract__c + '_Purchase Incentive')){
						if((req.ASI_CRM_Payment_Amount__c + map_contractType_amount.get(req.ASI_TH_CRM_Contract__c + '_Purchase Incentive')) > entitledPurchaseIncentiveAmount) {
							req.addError('Payment Amount must be less than Sponsorship stated in respective Payment Schedule');
						}
					}
					/* [VL 1.0] END */
                }
                // contract fund specific validation
                else if(req.ASI_CRM_Payment_Type__c == 'Contract Fund'){
                    // validate net sales and target achievement amount
                    Decimal entitledContractFundAmount = map_contractFundScheme_entitled.get(req.ASI_TH_CRM_Contract__c);
					/* [VL 1.0] BEGIN */
					/*
                    Decimal sponsorshipAmout = map_purchaseIncentiveScheme_entitled.get(req.ASI_TH_CRM_Contract__c); // Added as quick Fix 2018-11-27
					*/
					/* [VL 1.0] END */
                    system.debug('entitledContractFundAmount:: ' + entitledContractFundAmount);
					/* [VL 1.0] BEGIN */
					/*
                    system.debug('Net Sales:: ' + contractMap.get(req.ASI_TH_CRM_Contract__c).ASI_CRM_SG_Net_Sales__c);
                    if(entitledContractFundAmount > contractMap.get(req.ASI_TH_CRM_Contract__c).ASI_CRM_SG_Net_Sales__c){
                        req.addError('Contract Net Sales must be larger or equal to Contract Fund Target Achievement Amount');// Added as quick Fix 2018-11-27
                    }
					*/
					/* [VL 1.0] END */

                    // Added as quick Fix 2018-11-27
					/* [VL 1.0] BEGIN */
                    if(entitledContractFundAmount == null) {
                        req.addError('There is no Contract Fund Scheme for this contract');
                    } else 
					/* [VL 1.0] END */
                    if(req.ASI_CRM_Payment_Amount__c > entitledContractFundAmount) {
                        req.addError('Payment Amount must be less than Sponsorship amount stated in respective Contract Fund Scheme');
                    } else 
					if(map_contractType_amount.containsKey(req.ASI_TH_CRM_Contract__c + '_Contract Fund')){
						if((req.ASI_CRM_Payment_Amount__c + map_contractType_amount.get(req.ASI_TH_CRM_Contract__c + '_Contract Fund')) > entitledContractFundAmount) {
							req.addError('Payment Amount must be less than Sponsorship amount stated in respective Contract Fund Scheme');
						}
					}
                }
            }
            else if(req.ASI_CRM_Payment_Type__c == 'Merchandise'){
                if(req.ASI_CRM_Payment_Amount__c > contractMap.get(req.ASI_TH_CRM_Contract__c).ASI_CRM_Merchandise_Amount__c){
                    req.addError('Payment Amount must be less than merchandise amount stated in respective contract');
                }
            }
            else if(req.ASI_CRM_Payment_Type__c == 'Activation Fund'){
                if(req.ASI_CRM_Payment_Amount__c > contractMap.get(req.ASI_TH_CRM_Contract__c).ASI_CRM_Activation_Fund_Amount__c){
                    req.addError('Payment Amount must be less than activation fund amount stated in respective contract');
                }
            }
        }


        if(!bottleStaffContractSet.isEmpty()){
            Map<Id, List<ASI_CRM_ContractTarget__c>> contractTargetMap = new Map<Id, List<ASI_CRM_ContractTarget__c>>();
            for(ASI_CRM_ContractTarget__c target: [select ASI_CRM_Contract__c, ASI_CRM_SKU__c, ASI_CRM_Target_Total_Sales__c, ASI_CRM_Achieved_Amount__c, ASI_CRM_Staff_Incentive__c, ASI_CRM_Bottle_Rebate__c, ASI_CRM_Till_Date_Sales_Bottle__c from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c in: bottleStaffContractSet]){
                List<ASI_CRM_ContractTarget__c> temp = contractTargetMap.get(target.ASI_CRM_Contract__c);
                if(temp == null){
                    temp = new List<ASI_CRM_ContractTarget__c>{target};
                }
                else{
                    temp.add(target);
                }
                contractTargetMap.put(target.ASI_CRM_Contract__c, temp);
            }

            Map<Id, Decimal> bottleRebateSumMap = new Map<Id, Decimal>();
            Map<Id, Decimal> staffIncentiveSumMap = new Map<Id, Decimal>();

            for(ASI_TH_CRM_PaymentRequest__c req: paymentRequests){
                List<ASI_CRM_ContractTarget__c> targets = contractTargetMap.get(req.ASI_TH_CRM_Contract__c);
                if(!targets.isEmpty()){
                    for(ASI_CRM_ContractTarget__c target: targets){
                        Decimal tillDateSalesBottle = target.ASI_CRM_Till_Date_Sales_Bottle__c != null ? target.ASI_CRM_Till_Date_Sales_Bottle__c : 0;
                        if(req.ASI_CRM_Payment_Type__c == 'Bottle Rebate'){
                            Decimal botteRebate = checkNullDecimal(target.ASI_CRM_Bottle_Rebate__c);
                            Decimal total = tillDateSalesBottle * botteRebate;
                            if(bottleRebateSumMap.get(target.ASI_CRM_Contract__c) == null){
                                bottleRebateSumMap.put(target.ASI_CRM_Contract__c, total);
                            }
                            else{
                                Decimal temp = bottleRebateSumMap.get(target.ASI_CRM_Contract__c);
                                temp += total;
                                bottleRebateSumMap.put(target.ASI_CRM_Contract__c, temp);
                            }
                        }
                        else if(req.ASI_CRM_Payment_Type__c == 'Staff Incentive'){
                            Decimal staffIncentive = checkNullDecimal(target.ASI_CRM_Staff_Incentive__c);
                            Decimal total = tillDateSalesBottle * staffIncentive;
                            if(staffIncentiveSumMap.get(target.ASI_CRM_Contract__c) == null){
                                staffIncentiveSumMap.put(target.ASI_CRM_Contract__c, total);
                            }
                            else{
                                Decimal temp = staffIncentiveSumMap.get(target.ASI_CRM_Contract__c);
                                temp += total;
                                staffIncentiveSumMap.put(target.ASI_CRM_Contract__c, temp);
                            }
                        }
                    }
                }
            }

            for(ASI_TH_CRM_PaymentRequest__c req: paymentRequests){
                if(req.ASI_CRM_Payment_Type__c == 'Bottle Rebate'){
               		req.ASI_CRM_Payment_Amount__c = bottleRebateSumMap.get(req.ASI_TH_CRM_Contract__c);
                }
                else if(req.ASI_CRM_Payment_Type__c == 'Staff Incentive'){
                    req.ASI_CRM_Payment_Amount__c = staffIncentiveSumMap.get(req.ASI_TH_CRM_Contract__c);
                }
            }
        }
    }

    private static void rollUpPaymentRequestAmountToContract(List<ASI_TH_CRM_PaymentRequest__c> paymentRequests) {
        
        final Map<Id, Id> paymentRequestIdContractIdMap = new Map<Id, Id>();
		for (ASI_TH_CRM_PaymentRequest__c paymentRequest : paymentRequests) {
			paymentRequestIdContractIdMap.put(paymentRequest.Id, paymentRequest.ASI_TH_CRM_Contract__c);
		}

		final Map<Id, ASI_TH_CRM_Contract__c> contractIdContractMap = new Map<Id, ASI_TH_CRM_Contract__c>();
		for (
				ASI_TH_CRM_Contract__c contract
				:
		[
				SELECT Id, ASI_CRM_Paid_Activation_Fund_Amount__c, ASI_CRM_Paid_Bottle_Rebate_Amount__c,
				ASI_CRM_Paid_Contract_Fund_Amount__c, ASI_CRM_Paid_Merchandise_Amount__c,
				ASI_CRM_Paid_Purchase_Incentive_Amt__c, ASI_CRM_Paid_Staff_Incentive_Amount__c,
				ASI_CRM_Paid_Marketing_Support_Fund_Amt__c
				FROM ASI_TH_CRM_Contract__c
				WHERE Id IN :paymentRequestIdContractIdMap.values()
		]) {
			contractIdContractMap.put(contract.Id, contract);
		}

		final Map<Id, ASI_FOC_Free_Goods_Request__c> contractIdFocFreeGoodRequestMap = new Map<Id, ASI_FOC_Free_Goods_Request__c>();
		for(ASI_FOC_Free_Goods_Request__c focFreeGoodsRequest : [
				SELECT Id, ASI_CRM_Contract__c, ASI_CRM_SG_Total_Amount__c
				FROM ASI_FOC_Free_Goods_Request__c
				WHERE ASI_CRM_Contract__c IN :paymentRequestIdContractIdMap.values()
		]) {
			contractIdFocFreeGoodRequestMap.put(focFreeGoodsRequest.ASI_CRM_Contract__c, focFreeGoodsRequest);
		}

		final Set<Id> allowedPaymentRequestRecordTypes = getValidRecordTypeIdsForPaymentRequestRollUp();

		for (ASI_TH_CRM_PaymentRequest__c paymentRequest : paymentRequests) {

			System.debug('Payment Request Status = ' + paymentRequest.ASI_TH_CRM_Status__c);
			System.debug('Payment Request Record Type Id = ' + paymentRequest.RecordTypeId);

			if (!PAYMENT_REQUEST_STATUS_APPROVED.equals(paymentRequest.ASI_TH_CRM_Status__c) ||
					!allowedPaymentRequestRecordTypes.contains(paymentRequest.RecordTypeId)
			) {
				continue;
			}

			final Id contractId = paymentRequestIdContractIdMap.get(paymentRequest.Id);
			final String paymentRequestType = paymentRequest.ASI_CRM_Payment_Type__c;

			if (PAYMENT_TYPE_CONTRACT_FUND.equals(paymentRequestType)) {

				if (contractIdContractMap.get(contractId).ASI_CRM_Paid_Contract_Fund_Amount__c == null) {
					contractIdContractMap.get(contractId).ASI_CRM_Paid_Contract_Fund_Amount__c = 0;
				}

				contractIdContractMap.get(contractId).ASI_CRM_Paid_Contract_Fund_Amount__c +=
						paymentRequest.ASI_CRM_Payment_Amount__c;

			} else if (PAYMENT_TYPE_ACTIVATION_FUND.equals(paymentRequestType)) {

				if (contractIdContractMap.get(contractId).ASI_CRM_Paid_Activation_Fund_Amount__c == null) {
					contractIdContractMap.get(contractId).ASI_CRM_Paid_Activation_Fund_Amount__c = 0;
				}

				contractIdContractMap.get(contractId).ASI_CRM_Paid_Activation_Fund_Amount__c +=
						paymentRequest.ASI_CRM_Payment_Amount__c;

			} else if (PAYMENT_TYPE_MERCHANDISE.equals(paymentRequestType)) {

				if (contractIdContractMap.get(contractId).ASI_CRM_Paid_Merchandise_Amount__c == null) {
					contractIdContractMap.get(contractId).ASI_CRM_Paid_Merchandise_Amount__c = 0;
				}

				contractIdContractMap.get(contractId).ASI_CRM_Paid_Merchandise_Amount__c +=
						paymentRequest.ASI_CRM_Payment_Amount__c;

			} else if (PAYMENT_TYPE_PURCHASE_INCENTIVE.equals(paymentRequestType)) {

				if (contractIdContractMap.get(contractId).ASI_CRM_Paid_Purchase_Incentive_Amt__c == null) {
					contractIdContractMap.get(contractId).ASI_CRM_Paid_Purchase_Incentive_Amt__c = 0;
				}

				contractIdContractMap.get(contractId).ASI_CRM_Paid_Purchase_Incentive_Amt__c +=
						paymentRequest.ASI_CRM_Payment_Amount__c;

			} else if (PAYMENT_TYPE_BOTTLE_REBATE.equals(paymentRequestType)) {

				if (contractIdContractMap.get(contractId).ASI_CRM_Paid_Bottle_Rebate_Amount__c == null) {
					contractIdContractMap.get(contractId).ASI_CRM_Paid_Bottle_Rebate_Amount__c = 0;
				}

				contractIdContractMap.get(contractId).ASI_CRM_Paid_Bottle_Rebate_Amount__c +=
						paymentRequest.ASI_CRM_Payment_Amount__c;

			} else if (PAYMENT_TYPE_STAFF_INCENTIVE.equals(paymentRequestType)) {

				if (contractIdContractMap.get(contractId).ASI_CRM_Paid_Staff_Incentive_Amount__c == null) {
					contractIdContractMap.get(contractId).ASI_CRM_Paid_Staff_Incentive_Amount__c = 0;
				}

				contractIdContractMap.get(contractId).ASI_CRM_Paid_Staff_Incentive_Amount__c +=
						paymentRequest.ASI_CRM_Payment_Amount__c;

			}
		}

		update contractIdContractMap.values();
    }

	private static Set<Id> getValidRecordTypeIdsForPaymentRequestRollUp() {
		final Id paymentRequestRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_TH_CRM_PaymentRequest__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_TH_CRM_PaymentRequest.ASI_CRM_PH_Payment_Request.name()
		);

		final Id readOnlyPaymentRequestRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_TH_CRM_PaymentRequest__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_TH_CRM_PaymentRequest.ASI_CRM_PH_Payment_Request_Read_Only.name()
		);

		return new Set<Id> {paymentRequestRecordTypeId, readOnlyPaymentRequestRecordTypeId};
	}

}