/*********************************************************************************
 * Name: ASI_CRM_SG_Payment_ValidationHelper_V2
 * Description: Validation Helper for Amount Exceed between Payment and Contract (Version 2: to validate payments in  multiple contracts)
 * Test Class: ASI_CRM_SG_Payment_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-02-16       Laputa: Conrad          Created
 * 2016-02-23       Laputa: Vincent Lam     [VL 1.0] Add validation of type = "Cash - Upfront" and "Cash - Target Achieved" with Cash Sponsorship in contract target
 *                                          [VL 1.1] Map the contract target by correct sub-brand: 
 *                                                   currently it maps contract target SKU's sub-brand to contract target ->
 *                                                   should be:
 *                                                   if there is sub-brand input in contract target, map it to contract target;
 *                                                   if there is no sub-brand input in contract target, map the SKU's sub-brand to contract target
 *                                          [VL 1.2] Show alert message with sub-brand indication
 * 2016-02-26       Laputa: Vincent Lam     [VL 2.0] Structural change, in order to cater multiple contracts validation
 *                                          [VL 2.1] Add validation of type = "Bottle Incentive" with Bottle Incentive - Total in contract target
 * 2016-03-01       Laputa: Vincent Lam     [VL 3.0] Add validation of type = "Signages" with Signages (total case + cash) in contract target
 *                                          [VL 3.1] Add validation of type = "Advertising Spot" with Advertising Spot (total case + cash) in contract target
 * 2016-03-21       Laputa: Vincent Lam     [VL 4.0] Remove all "Case" column from validation, only consider "Value / Cash"
 *                                          [VL 4.1] Remove "Anniversary" from payment request
 * 2016-03-31       Laputa: Vincent Lam     [VL 5.0] Check if payment's sub-brand does not exist in contract, except the one with type = Sales Support
 * 2016-12-08       Laputa: Vincent Lam     [VL 6.0] Allow additional Bottle Incentive if the contract is over achieved
 * 2017-02-27		Laputa: Vincent Lam		[VL 7.0] Remove Bottle Incentive validation for P3
 * 2017-11-23		Wilken Lee				[WL 8.0] Add validation for A&P Fund payment type
 * 2017-11-29		Wilken Lee				[WL 9.0] Modify validateAmountExceed to allow validation when submit contract for approval
 * 2017-12-07		Laputa: Vincent Lam		[VL 8.0] Add a condition on Wilken's code to validate simulated targets
 * 2018-01-23		Laputa: Vincent Lam		[VL 9.0] Since auto-payment schedule has rounding issue when split the amount into sub-brand, so allow $0.5 buffer per sub-brand
 */
global class ASI_CRM_SG_Payment_ValidationHelper_V2 {
    
    private boolean isPaymentObject {get;set;}
	
    private List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentItemList {get;set;}
    private List<ASI_TH_CRM_PaymentRequest__c> paymentHeaderList {get;set;}
    
    private List<ASI_CRM_ContractTarget__c> contractTargetItemList {get;set;}
    
    private List<sObject> headerObject {get;set;}
    private List<sObject> sObjList {get;set;}
    /*
    private Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>> subBrand_PaymentListMap {get;set;}
    private Map<ID, List<ASI_CRM_ContractTarget__c>> subBrand_ContractTargetListMap {get;set;}
    */
    private Map<ID, Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>>> contract_subBrand_PaymentListMap {get;set;}
    private Map<ID, Map<ID, List<ASI_CRM_ContractTarget__c>>> contract_subBrand_ContractTargetListMap {get;set;}
    private Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>> contract_PaymentItemListMap {get;set;}
    private Map<ID, List<ASI_CRM_ContractTarget__c>> contract_ContractTargetListMap {get;set;}
    private Map<ID, String> contract_Name_Map {get;set;}

    /* [VL 1.2] BEGIN */
    private Map<ID, String> subBrand_NameMap {get;set;}
    /* [VL 1.2] END */
    
    private Map<ASI_TH_CRM_PaymentRequestLineItem__c, ID> map_line_contractID {get;set;}
    
    private Set<ID> contractSubrandIDSet {get;set;}
    private Set<ID> paymentSubBRandIDSet {get;set;}
    
    private Map<ID, boolean> paymentRequest_isGST_Map{get;set;}

	private static final String CONTRACTTARGET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';
	private static final String CONTRACTTARGET_RECORD_TYPE_SIMULATION = 'ASI_CRM_SG_Contract_Target_Simulation';

    // constructor to cater multiple headers
    public ASI_CRM_SG_Payment_ValidationHelper_V2 (boolean isPayment, List<sObject> header, List<sObject> sObList) {
        this.isPaymentObject = isPayment;
        this.headerObject = header;
        this.sObjList = sObList;
        initiator();
    }
    
    // constructor to cater single header
    public ASI_CRM_SG_Payment_ValidationHelper_V2 (boolean isPayment, sObject header, List<sObject> sObList) {
        this.isPaymentObject = isPayment;
        this.headerObject = new List<sObject>();
        this.headerObject.add(header);
        this.sObjList = sObList;
        initiator();
    }
    
    // constructor to cater single header and map of line item and contract id
    public ASI_CRM_SG_Payment_ValidationHelper_V2 (boolean isPayment, sObject header, List<sObject> sObList, Map<ASI_TH_CRM_PaymentRequestLineItem__c, ID> mapObject) {
        this.isPaymentObject = isPayment;
        this.headerObject = new List<sObject>();
        this.headerObject.add(header);
        this.sObjList = sObList;
        this.map_line_contractID = mapObject;
        initiator();
    }
	
	/*[WL 9.0] BEGIN*/
	// constructor for Button Page controller extension
    public ASI_CRM_SG_Payment_ValidationHelper_V2(ApexPages.StandardController stdController) {        
	
    }
    /*[WL 9.0] END*/
    
    public void initiator () {
        this.contractSubrandIDSet = new Set<ID>();
        this.paymentSubBRandIDSet = new Set<ID>();
        this.paymentItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        this.contractTargetItemList = new List<ASI_CRM_ContractTarget__c>();
        //this.isGST = false;
        
        this.paymentRequest_isGST_Map = new Map<ID, boolean>();
        
        if(this.isPaymentObject) {
            for (ASI_TH_CRM_PaymentRequest__c eachHeader : (List<ASI_TH_CRM_PaymentRequest__c>)this.headerObject){
                paymentRequest_isGST_Map.put(eachHeader.id, eachHeader.ASI_CRM_SG_GST_Inclusive__c);
            }
            
        }
        
        if(this.isPaymentObject != null && this.headerObject != null && this.sObjList != null) {
            if(this.sObjList.size() > 0 && this.isPaymentObject) {
                initData();
                System.debug('Initialize data');
            }
        }
    }
	
	/*[WL 9.0] BEGIN*/
	@RemoteAction
    global static String validateAmountExceedRTMContract(Id headerId /*[VL 8.0] BEGIN */, boolean isSimulation/*[VL 8.0] END */) {
		ASI_TH_CRM_Contract__c contractHeader = [select Id, Name from ASI_TH_CRM_Contract__c where Id = :headerId];
		
		//Substring first 15 characters of Contract Name in order to look for actual payment
		String contractName = contractHeader.Name.left(15);
		contractName = contractName + '%';
		
		String amountExceed = '';
		/* [VL 8.0] BEGIN */
		/*
		List<ASI_CRM_ContractTarget__c> contractTargetList = [select Id, ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SG_Ad_hoc_Promotions__c ,ASI_CRM_SG_Anniversary_Free_Bottles__c 
																from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c = :contractHeader.Id and recordType.DeveloperName = :CONTRACTTARGET_RECORD_TYPE];
		*/
		String contract_rt = isSimulation ? CONTRACTTARGET_RECORD_TYPE_SIMULATION : CONTRACTTARGET_RECORD_TYPE;
		List<ASI_CRM_ContractTarget__c> contractTargetList = [select Id, ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SG_Ad_hoc_Promotions__c ,ASI_CRM_SG_Anniversary_Free_Bottles__c 
																from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c = :contractHeader.Id and recordType.DeveloperName = :contract_rt];
		/* [VL 8.0] END */
		Map<String,Decimal> targetSubBrandAmountMap = new Map<String,Decimal>();		
		Map<String,Decimal> actualSubBrandAmountMap = new Map<String,Decimal>();		
		Map<String,String> subBrandCodeToNameMap = new Map<String,String>();
		
		//Prepare Map of Contract Target Sub-brand A&P Fund value and cases for validation
		for (ASI_CRM_ContractTarget__c target:contractTargetList){
			if (target.ASI_CRM_SG_Ad_hoc_Promotions__c != null){
				if (targetSubBrandAmountMap.get(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c) == null){
					targetSubBrandAmountMap.put(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, target.ASI_CRM_SG_Ad_hoc_Promotions__c);
				}
				else {
					Decimal totalAmt = targetSubBrandAmountMap.get(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c);
					totalAmt+= target.ASI_CRM_SG_Ad_hoc_Promotions__c;
					targetSubBrandAmountMap.put(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, totalAmt);
				}				
				
				subBrandCodeToNameMap.put(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name);
			}
		}
		system.debug('targetSubBrandAmountMap: ' + targetSubBrandAmountMap);
		
		//Retrieve Actual Payment Request to prepare total A&P fund amount by sub-brand
		List<ASI_TH_CRM_PaymentRequestLineItem__c> payLineList = [select Id, ASI_CRM_SG_Sub_brand__r.ASI_MFM_Sub_brand_Code__c ,ASI_TH_CRM_Amount__c, ASI_CRM_SG_Type__c 
																from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.Name like :contractName and ASI_CRM_SG_Type__c = 'A&P Fund'];
		
		for (ASI_TH_CRM_PaymentRequestLineItem__c payLine:payLineList){
			if (actualSubBrandAmountMap.get(payLine.ASI_CRM_SG_Sub_brand__r.ASI_MFM_Sub_brand_Code__c) == null){
					actualSubBrandAmountMap.put(payLine.ASI_CRM_SG_Sub_brand__r.ASI_MFM_Sub_brand_Code__c, payLine.ASI_TH_CRM_Amount__c);
			}
			else {
				Decimal totalAmt = actualSubBrandAmountMap.get(payLine.ASI_CRM_SG_Sub_brand__r.ASI_MFM_Sub_brand_Code__c);
				totalAmt+= payLine.ASI_TH_CRM_Amount__c;
				actualSubBrandAmountMap.put(payLine.ASI_CRM_SG_Sub_brand__r.ASI_MFM_Sub_brand_Code__c, totalAmt);
			}						
		}
		system.debug('actualSubBrandAmountMap: ' + actualSubBrandAmountMap);
		
		for (String sb:targetSubBrandAmountMap.keySet()){
			if (actualSubBrandAmountMap.get(sb) != null){
				if (actualSubBrandAmountMap.get(sb) > targetSubBrandAmountMap.get(sb))
					amountExceed += 'For Sub-Brand ' + subBrandCodeToNameMap.get(sb) + ', Total A and P Fund payment of $' + actualSubBrandAmountMap.get(sb) + ' is more than Contract total A and P Fund sponsorship of $' + targetSubBrandAmountMap.get(sb) + '. ';
			}
		}
		
		if (amountExceed == ''){
			amountExceed = validateVolumeExceedRTMContract(contractHeader.Id /*[VL 8.0] BEGIN */, isSimulation/*[VL 8.0] END */);
		}		
		
		if (amountExceed == '')
			amountExceed = 'OK';
		
		system.debug('validateAmountExceedRTMContract result: ' + amountExceed);
		return amountExceed;
	}
	/*[WL 9.0] END*/
    
	/*[WL 9.0] BEGIN*/	
    private static String validateVolumeExceedRTMContract(Id headerId /*[VL 8.0] BEGIN */, boolean isSimulation/*[VL 8.0] END */) {
		ASI_TH_CRM_Contract__c contractHeader = [select Id, Name from ASI_TH_CRM_Contract__c where Id = :headerId];
		
		//Substring first 15 characters of Contract Name in order to look for actual payment
		String contractName = contractHeader.Name.left(15);
		contractName = contractName + '%';
		
		String volumeExceed = '';
		/* [VL 8.0] BEGIN */
		/*
		List<ASI_CRM_ContractTarget__c> contractTargetList = [select Id, ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SG_Anniversary_Free_Bottles__c , ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c, ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c 
																from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c = :contractHeader.Id and recordType.DeveloperName = :CONTRACTTARGET_RECORD_TYPE];
		*/
		String contract_rt = isSimulation ? CONTRACTTARGET_RECORD_TYPE_SIMULATION : CONTRACTTARGET_RECORD_TYPE;
		List<ASI_CRM_ContractTarget__c> contractTargetList = [select Id, ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_SG_Anniversary_Free_Bottles__c , ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c, ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c 
																from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c = :contractHeader.Id and recordType.DeveloperName = :contract_rt];
		/* [VL 8.0] END */
		Map<String,Decimal> targetSubBrandVolMap = new Map<String,Decimal>();
		Map<String,Decimal> actualSubBrandVolMap = new Map<String,Decimal>();		
		Map<String,String> subBrandCodeToNameMap = new Map<String,String>();
		
		//Prepare Map of Contract Target Sub-brand A&P Fund vol for validation
		for (ASI_CRM_ContractTarget__c target:contractTargetList){
			if (target.ASI_CRM_SG_Anniversary_Free_Bottles__c != null){
				Decimal targetVol = target.ASI_CRM_SG_Anniversary_Free_Bottles__c * target.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c * target.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c;
				
				if (targetSubBrandVolMap.get(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c) == null){
					targetSubBrandVolMap.put(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, targetVol);
				}
				else {
					Decimal totalVol = targetSubBrandVolMap.get(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c);
					totalVol+= targetVol;
					targetSubBrandVolMap.put(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, totalVol);
				}				
				
				subBrandCodeToNameMap.put(target.ASI_CRM_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, target.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name);
			}
		}
		system.debug('targetSubBrandVolMap: ' + targetSubBrandVolMap);
		
		//Retrieve Actual Free Goods Request to prepare total A&P fund vol by sub-brand
		List<ASI_FOC_Request_Item__c> focItemList = [select Id, ASI_FOC_SKU__r.ASI_TH_CRM_Sub_brand_Code__c ,ASI_FOC_Request_Quantity_Bottle__c, ASI_FOC_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c
																from ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__r.ASI_CRM_Contract__r.Name like :contractName and ASI_CRM_SG_FOC_Type__c = 'A&P Fund'];
		
		for (ASI_FOC_Request_Item__c focLine:focItemList){
			Decimal focLineVol = focLine.ASI_FOC_Request_Quantity_Bottle__c * focLine.ASI_FOC_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c;
			
			if (actualSubBrandVolMap.get(focLine.ASI_FOC_SKU__r.ASI_TH_CRM_Sub_brand_Code__c) == null){
					actualSubBrandVolMap.put(focLine.ASI_FOC_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, focLineVol);
			}
			else {
				Decimal totalVol = actualSubBrandVolMap.get(focLine.ASI_FOC_SKU__r.ASI_TH_CRM_Sub_brand_Code__c);
				totalVol+= focLineVol;
				actualSubBrandVolMap.put(focLine.ASI_FOC_SKU__r.ASI_TH_CRM_Sub_brand_Code__c, totalVol);
			}						
		}
		system.debug('actualSubBrandVolMap: ' + actualSubBrandVolMap);
		
		for (String sb:targetSubBrandVolMap.keySet()){
			if (actualSubBrandVolMap.get(sb) != null){
				if (actualSubBrandVolMap.get(sb) > targetSubBrandVolMap.get(sb))
					volumeExceed += 'For Sub-Brand ' + subBrandCodeToNameMap.get(sb) + ', Total A and P Fund volume of ' + actualSubBrandVolMap.get(sb) + '(cL) exceed contracted ' + targetSubBrandVolMap.get(sb) + '(cL). ';                    
			}
		}
		
		system.debug('volumeExceed: ' + volumeExceed);
		
		return volumeExceed;
	}
	/*[WL 9.0] END*/
	
    public void initData() {
    
        ID contractHeaderID = null;
        ID paymentRequestTempid = null;
        List<ID> contractHeaderID_List = new List<ID>();
        List<ID> paymentRequestTempid_List = new List<ID>();
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentItemListTemp = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        List<ASI_CRM_ContractTarget__c> contractTargetListTemp0 = new List<ASI_CRM_ContractTarget__c>();
        
        if(isPaymentObject) {
            paymentItemListTemp = (List<ASI_TH_CRM_PaymentRequestLineItem__c>)sObjList;
            //ASI_TH_CRM_PaymentRequest__c paymentRequestTemp = (ASI_TH_CRM_PaymentRequest__c)headerObject;
            List<ASI_TH_CRM_PaymentRequest__c> paymentRequestTemp_List = (List<ASI_TH_CRM_PaymentRequest__c>)headerObject;
            /*
            paymentRequestTempid = paymentRequestTemp.id;
            contractHeaderID = paymentRequestTemp.ASI_TH_CRM_Contract__c;
            */
            for (ASI_TH_CRM_PaymentRequest__c eachHeader : paymentRequestTemp_List){
                contractHeaderID_List.add(eachHeader.ASI_TH_CRM_Contract__c);
                paymentRequestTempid_List.add(eachHeader.id);
            }
        } 
        /*
        else {
            ASI_CRM_ContractTarget__c contractHeaderTemp = (ASI_CRM_ContractTarget__c)headerObject;
            contractTargetListTemp0 = (List<ASI_CRM_ContractTarget__c>)sObjList;
            contractHeaderID = contractHeaderTemp.id;
        }
        */
		
        if(contractHeaderID_List.size() > 0) {
                
            /*
            paymentHeaderList = paymentRequestTempid_List.size() > 0 ? 
            [SELECT ID, Name FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c IN : contractHeaderID_List AND ID <> : paymentRequestTempid_List]
            :
            [SELECT ID, Name FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c IN : contractHeaderID_List];
                */
            paymentHeaderList = [SELECT ID, Name, ASI_TH_CRM_Contract__c, ASI_TH_CRM_Contract__r.name FROM ASI_TH_CRM_PaymentRequest__c WHERE ASI_TH_CRM_Contract__c IN : contractHeaderID_List];
                
            this.contract_Name_Map = new Map<ID, String>();
            
            Set<ID> paymentHeaderIds = new Set<ID>();
            Map<ID, ID> paymentHeader_Contract_Map = new Map<ID, ID>();
            for(ASI_TH_CRM_PaymentRequest__c paymentReq : paymentHeaderList) {
                paymentHeaderIds.add(paymentReq.id);
                paymentHeader_Contract_Map.put(paymentReq.id, paymentReq.ASI_TH_CRM_Contract__c);
                // DC - 03/11/2016 - Added null check for Contract lookup
                if(paymentReq.ASI_TH_CRM_Contract__c != NULL){
                    System.debug('Debug Message : ' + paymentReq.ASI_TH_CRM_Contract__c);
                    this.contract_Name_Map.put(paymentReq.ASI_TH_CRM_Contract__c, paymentReq.ASI_TH_CRM_Contract__r.name);
                }
            }
            paymentItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
            
            paymentItemList = [SELECT ID, Name, ASI_TH_CRM_Payment_Request__c, ASI_CRM_SG_Sub_brand__c, ASI_TH_CRM_Amount__c, ASI_CRM_SG_Type__c
                               , ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c,  ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__r.name
                               FROM ASI_TH_CRM_PaymentRequestLineItem__c
                               WHERE ASI_TH_CRM_Payment_Request__c IN : paymentHeaderIds
                               AND ASI_TH_CRM_Payment_Request__c NOT IN : paymentRequestTempid_List
                               AND ASI_CRM_SG_Sub_brand__c <> null
                               /* [VL 1.0] BEGIN */
                               // Check all existing payment request in this contract, regardless the status
                               /*
                                AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = : 'Approved'
                                */  
                                AND ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c <> : 'Rejected'
                               /* [VL 1.0] END */
                               ORDER BY ASI_CRM_SG_Sub_brand__c];
            
            contractTargetItemList = [SELECT ID, Name, ASI_CRM_Contract__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c,
                                      ASI_CRM_Contract__r.name,
                                      /* [VL 1.1] BEGIN */
                                      ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.name, ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.name,
                                      /* [VL 1.1] END */
                                      ASI_CRM_SG_Events_Free_Bottles__c, ASI_CRM_SG_Events__c, 
                                      ASI_CRM_SG_Signages_Advertising_Spot__c, ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c,
                                      ASI_CRM_SG_Anniversary__c, ASI_CRM_SG_Anniversary_Free_Bottles__c,
                                      // DC - 03/11/2016 - Added field "ASI_CRM_Advertising_Spot_Free_Bottles__c"
                                      ASI_CRM_Advertising_Spot_Free_Bottles__c,
                                      ASI_CRM_Advertising_Spot__c, 
                                      ASI_CRM_SG_Trade_Incentive_Trips__c, ASI_CRM_SG_Product_Branding_Display__c,
                                      ASI_CRM_SG_Ad_hoc_Promotions__c, ASI_CRM_SG_Btls_Per_Case__c,ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c
                                      /* [VL 1.0] BEGIN */
                                      , ASI_CRM_SG_Cash__c
                                      /* [VL 1.0] END */
                                      /* [VL 2.1] BEGIN */
                                      , ASI_CRM_Bottle_Incentive_Total__c
                                      /* [VL 2.1] END */
                                      /* [VL 6.0] BEGIN */
                                      , ASI_CRM_Contract__r.ASI_CRM_Till_Date_Sales_Volume_9L__c, ASI_CRM_Contract__r.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c 
                                      /* [VL 6.0] END */
                                      FROM ASI_CRM_ContractTarget__c
                                      WHERE ASI_CRM_Contract__c IN : contractHeaderID_List
                                      /* [VL 1.1] BEGIN */
                                      /*
                                        AND ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c != null
                                        */
                                      /* [VL 1.1] END */
                                      AND ASI_CRM_SKU__c != null
                                      /* [VL 1.1] BEGIN */
                                      /*
                                        ORDER BY ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c
                                        */
										AND recordtype.developername = :CONTRACTTARGET_RECORD_TYPE
                                      ORDER BY ASI_CRM_Subbrand__c
                                      /* [VL 1.1] END */
                                     ];
            
            for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem : paymentItemListTemp) {
                paymentItemList.add(paymentItem);
            }
            
            this.contract_PaymentItemListMap = new Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();
            
            Set<ID> paymentItemList_subBrandIDSet = new Set<ID>();
            for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem : paymentItemList) {
                ID contractID = paymentHeader_Contract_Map.get(paymentItem.ASI_TH_CRM_Payment_Request__c) != null ? paymentHeader_Contract_Map.get(paymentItem.ASI_TH_CRM_Payment_Request__c) : map_line_contractID.get(paymentItem) ;
                List<ASI_TH_CRM_PaymentRequestLineItem__c> contract_paymentItemList = this.contract_PaymentItemListMap.containsKey(contractID) ? this.contract_PaymentItemListMap.get(contractID) : new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
                contract_paymentItemList.add(paymentItem);
                this.contract_PaymentItemListMap.put(contractID, contract_paymentItemList);
                paymentItemList_subBrandIDSet.add(paymentItem.ASI_CRM_SG_Sub_brand__c);
            }
            
            System.debug('------ contract_PaymentItemListMap ------ : ' + contract_PaymentItemListMap);
              
            this.subBrand_NameMap = new Map<ID, String>();
            
            /* [VL 5.0] BEGIN */
            List<ASI_MFM_Sub_brand__c> subBrand_name_List = new List<ASI_MFM_Sub_brand__c>();
            
            subBrand_name_List = [SELECT ID, name
                               FROM ASI_MFM_Sub_brand__c
                               WHERE ID IN :paymentItemList_subBrandIDSet];
            
            for(ASI_MFM_Sub_brand__c subBrand_name : subBrand_name_List) {
                this.subBrand_NameMap.put(subBrand_name.id , subBrand_name.name);
            }
            /* [VL 5.0] END */
            
            this.contract_ContractTargetListMap = new Map<ID, List<ASI_CRM_ContractTarget__c>>();
                 
            for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetItemList) {
                ID contractID = contractTargetItem.ASI_CRM_Contract__c;
                List<ASI_CRM_ContractTarget__c> contract_contractTargetItemList = this.contract_ContractTargetListMap.containsKey(contractID) ? this.contract_ContractTargetListMap.get(contractID) : new List<ASI_CRM_ContractTarget__c>();
                contract_contractTargetItemList.add(contractTargetItem);
                this.contract_ContractTargetListMap.put(contractID, contract_contractTargetItemList);
            }

            system.debug('contract_Name_Map');
            system.debug(this.contract_Name_Map);
            
            this.contract_subBrand_PaymentListMap = new Map<ID, Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>>>();
            this.contract_subBrand_ContractTargetListMap = new Map<ID, Map<ID, List<ASI_CRM_ContractTarget__c>>>();
            
            for (ID contractID : this.contract_PaymentItemListMap.keySet()) {
                List<ASI_TH_CRM_PaymentRequestLineItem__c> contract_paymentItemList = contract_PaymentItemListMap.get(contractID);
                
                Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>> subBrand_PaymentListMap = new Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();
                    
                //ID subBrandID = null;
                List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentReqItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
                
                Set<ID> subBrandIDsSet = new Set<ID>();
                for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem : contract_paymentItemList) {
                    paymentSubBRandIDSet.add(paymentItem.ASI_CRM_SG_Sub_brand__c);
                    if(!subBrandIDsSet.contains(paymentItem.ASI_CRM_SG_Sub_brand__c)) {
                        
                        for(ASI_TH_CRM_PaymentRequestLineItem__c paymentItem1 : contract_paymentItemList) {
                            if(paymentItem.ASI_CRM_SG_Sub_brand__c == paymentItem1.ASI_CRM_SG_Sub_brand__c) {
                                paymentReqItemList.add(paymentItem1);
                            }
                        }
                            
                        if(paymentReqItemList.size() > 0) {
                            subBrand_PaymentListMap.put(paymentItem.ASI_CRM_SG_Sub_brand__c, paymentReqItemList);
                        }
                    }
                    subBrandIDsSet.add(paymentItem.ASI_CRM_SG_Sub_brand__c);
                    paymentReqItemList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
                }
                //subBrandID = null;
                System.debug('Debug Message : Contact Id (' + contractID + ') ' + subBrand_PaymentListMap);
                this.contract_subBrand_PaymentListMap.put(contractID, subBrand_PaymentListMap);
            }
            
            /*
            System.debug('this.subBrand_PaymentListMap ' + this.subBrand_PaymentListMap);
            System.debug('this.subBrand_PaymentListMap.size() ' + this.subBrand_PaymentListMap.size());
            System.debug('contractTargetListTemp0.size() ' + contractTargetListTemp0.size());             
            */
            
            for (ID contractID : this.contract_ContractTargetListMap.keySet()) {
                List<ASI_CRM_ContractTarget__c> contract_contractTargetItemList = this.contract_ContractTargetListMap.get(contractID);
                
                Map<ID, List<ASI_CRM_ContractTarget__c>> subBrand_ContractTargetListMap = new Map<ID, List<ASI_CRM_ContractTarget__c>>();
                    
                List<ASI_CRM_ContractTarget__c> contractTargetListTemp = new List<ASI_CRM_ContractTarget__c>();
                
                /* [VL 1.1] BEGIN */
                /*
                // retrieve the subbrand according to SKU
                Map<ID, ID> subBrandMap = new Map<ID, ID>();
                
                
                Set<ID> skuIDSet = new Set<ID>();
                for(ASI_CRM_ContractTarget__c contractTarget : contractTargetItemList) {
                    if(contractTarget.ASI_CRM_SKU__c != null) {
                        skuIDSet.add(contractTarget.ASI_CRM_SKU__c);
                    }
                }
                    
                if(skuIDSet.size() > 0) {
                    List<ASI_MFM_SKU_Code__c> skuListTemp = [SELECT ID, Name, ASI_MFM_Sub_brand__c FROM ASI_MFM_SKU_Code__c
                                                                WHERE ID IN : skuIDSet];
                    
                    system.debug('skuListTemp ' + skuListTemp);
                        
                    for(ASI_MFM_SKU_Code__c sku : skuListTemp) {
                        subBrandMap.put(sku.id, sku.ASI_MFM_Sub_brand__c);
                        contractSubrandIDSet.add(sku.ASI_MFM_Sub_brand__c);
                    }
                }
                */
                /* [VL 1.1] END */
                
                /* [VL 1.1][VL 1.2] BEGIN */
                // retrieve the subbrand according to contract target sub-brand, if null, SKU's sub-brand
                Map<ID, ID> subBrandMap = new Map<ID, ID>();
                
                for(ASI_CRM_ContractTarget__c contractTargetItem : contract_contractTargetItemList) {
                    ID subBrand_id = contractTargetItem.ASI_CRM_Subbrand__c != NULL ? contractTargetItem.ASI_CRM_Subbrand__c : contractTargetItem.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                    String subBrand_name = contractTargetItem.ASI_CRM_Subbrand__c != NULL ? contractTargetItem.ASI_CRM_Subbrand__r.name : contractTargetItem.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.name;
                    subBrandMap.put(contractTargetItem.ASI_CRM_SKU__c , subBrand_id);
                    contractSubrandIDSet.add(subBrand_id);
                    this.subBrand_NameMap.put(subBrand_id, subBrand_name);
                }
                /* [VL 1.1][VL 1.2] END */
                
                system.debug('subBrandMap.values() ' + subBrandMap.values() + ' subBrandMap.keySet() ' + subBrandMap.keySet());
                
                /*for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetItemList) {
                        
                    if(subBrandID == null) {
                        subBrandID = subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c);
                        contractTargetListTemp.add(contractTargetItem);
                    } else if(subBrandID != subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c)) {
                        
                        this.subBrand_ContractTargetListMap.put(subBrandID, contractTargetListTemp);
                        subBrandID = subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c);
                        contractTargetListTemp= new List<ASI_CRM_ContractTarget__c>();
                        contractTargetListTemp.add(contractTargetItem);
                    } else {
                        contractTargetListTemp.add(contractTargetItem);
                    }
                        
                }*/
                
                Set<ID> subBrandIDsSet = new Set<ID>();
                for(ASI_CRM_ContractTarget__c contractTargetItem : contract_contractTargetItemList) {
                    
                    if(!subBrandIDsSet.contains(subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c))) {
                        
                        for(ASI_CRM_ContractTarget__c contractTargetItem1 : contract_contractTargetItemList) {
                            if(subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c) == subBrandMap.get(contractTargetItem1.ASI_CRM_SKU__c)) {
                                contractTargetListTemp.add(contractTargetItem1);
                            }
                        }
                        if(contractTargetListTemp.size() > 0) {
                            subBrand_ContractTargetListMap.put(subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c), contractTargetListTemp);
                        }
                    }
                    subBrandIDsSet.add(subBrandMap.get(contractTargetItem.ASI_CRM_SKU__c));
                    contractTargetListTemp = new List<ASI_CRM_ContractTarget__c>();
                }
            
                this.contract_subBrand_ContractTargetListMap.put(contractID, subBrand_ContractTargetListMap);
            }
                
        }
        
    }
    
    public String validateAmountExceed() {
        
        String amountExceed = '';
        for (ID contractID : this.contract_Name_Map.keySet()) {
            String contractNo = this.contract_Name_Map.get(contractID);
            
            //Add checking if payment sub brand exist in the related contract
            
            System.debug('Start validateAmountExceed');
            System.debug(contractID);
            System.debug(this.contract_PaymentItemListMap);
            System.debug(this.contract_ContractTargetListMap);
            
            // DC - 03/11/2016 - Removed following debug to avoid null reference error.
            // System.debug('Payment Size ' + this.contract_PaymentItemListMap.get(contractID).size() + ' contract Size ' + this.contract_ContractTargetListMap.get(contractID).size());
            
            Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>> subBrand_PaymentListMap = this.contract_subBrand_PaymentListMap.containsKey(contractID) ? this.contract_subBrand_PaymentListMap.get(contractID) : new Map<ID, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();
            Map<ID, List<ASI_CRM_ContractTarget__c>> subBrand_ContractTargetListMap = this.contract_subBrand_ContractTargetListMap.containsKey(contractID) ? this.contract_subBrand_ContractTargetListMap.get(contractID) : new Map<ID, List<ASI_CRM_ContractTarget__c>>();
            
            if(subBrand_PaymentListMap == null  || subBrand_ContractTargetListMap == null){
                return '';
            }
            
            /*
            for(ID subbrandID : paymentSubBRandIDSet) {
                system.debug('Compare Payment SB vs Contract SB: ' + subbrandID + ' ' + contractSubrandIDSet);
                if(!contractSubrandIDSet.contains(subbrandID)) {
                    //amountExceed += 'Payment sub-brand does not exist in the related Contract. ';
                }
            }
            */
            
            system.debug('subBrand_ContractTargetListMap.values() ' + subBrand_ContractTargetListMap.values() + ' subBrand_PaymentListMap.values() ' + subBrand_PaymentListMap.values() );
            system.debug('subBrand_ContractTargetListMap.keySet() ' + subBrand_ContractTargetListMap.keySet() + ' subBrand_PaymentListMap.keySet() ' + subBrand_PaymentListMap.keySet() );
            
            /* [VL 5.0] BEGIN */
            for (Id subBrandID : subBrand_PaymentListMap.keySet()) {
                String subBrand_name = this.subBrand_NameMap.get(subBrandID);
                if (!subBrand_ContractTargetListMap.containsKey(subBrandID)) {
                    Decimal totalSalesSupport = 0;
                    Decimal totalLineItem = 0;
                    for(ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : subBrand_PaymentListMap.get(subBrandID)) {
                        if (paymentLine.ASI_CRM_SG_Type__c=='Sales Support') totalSalesSupport++;
                        totalLineItem++;
                    }
                    if (totalLineItem > totalSalesSupport) amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', it does not exist in contract. ';
                }
            }
            /* [VL 5.0] END */
            
            for (Id subBrandID : subBrand_ContractTargetListMap.keySet()) {
                
                /* [VL 1.2] BEGIN */
                String subBrand_name = this.subBrand_NameMap.get(subBrandID);
                /* [VL 1.2] END */
                
                List<ASI_CRM_ContractTarget__c> contractTargetListTemp = subBrand_ContractTargetListMap.get(subBrandID);
                List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineListTemp = subBrand_PaymentListMap.get(subBrandID) == null ? new List<ASI_TH_CRM_PaymentRequestLineItem__c>() : subBrand_PaymentListMap.get(subBrandID);
                System.debug('contractTargetListTemp  ' + contractTargetListTemp  + ' paymentLineListTemp ' + paymentLineListTemp);
                /* [VL 9.0] BEGIN */
				//Decimal totalCash = 0;
				Decimal totalCash = 0.5;
                /* [VL 9.0] BEGIN */
                Decimal totalEvents = 0;
                Decimal totalSignages = 0;
                Decimal totalTradeIncentives = 0;
                Decimal totalProductBranding = 0;
                Decimal totalAdhoc = 0;
				
				/*[WL 8.0] BEGIN*/
				Decimal totalAnPFund = 0;
				Decimal totalAnPFundPayment = 0;
				/*[WL 8.0] END*/
				
                /* [VL 4.1] BEGIN */
                /*
                Decimal totalAnniversary = 0;
                */
                /* [VL 4.1] END */
                /* [VL 2.1] BEGIN */
                Decimal totalBottleIncentive = 0;
                /* [VL 2.1] END */
                /* [VL 3.1] BEGIN */
                Decimal totalAdvertisingSpot = 0;
                /* [VL 3.1] END */
                
                Decimal totalCashPayment = 0;
                Decimal totalEventsPayment = 0;
                Decimal totalSignagesPayment = 0;
                Decimal totalTradeIncentivesPayment = 0;
                Decimal totalProductBrandingPayment = 0;
                Decimal totalAdhocPayment = 0;
                /* [VL 4.1] BEGIN */
                /*
                Decimal totalAnniversaryPayment = 0;
                */
                /* [VL 4.1] END */
                /* [VL 2.1] BEGIN */
                Decimal totalBottleIncentivePayment = 0;
                /* [VL 2.1] END */
                /* [VL 3.1] BEGIN */
                Decimal totalAdvertisingSpotPayment = 0;
                /* [VL 3.1] END */
                
                Decimal percentage = 0.07;
                
                for(ASI_TH_CRM_PaymentRequestLineItem__c paymentLine : paymentLineListTemp) {
                    Decimal amount = paymentLine.ASI_TH_CRM_Amount__c != null ? paymentLine.ASI_TH_CRM_Amount__c : 0;
                    Boolean isGST = this.paymentRequest_isGST_Map.containsKey(paymentLine.ASI_TH_CRM_Payment_Request__c) ? this.paymentRequest_isGST_Map.get(paymentLine.ASI_TH_CRM_Payment_Request__c) : false;
                    if(isGST) {
                        amount = amount - amount*percentage;  
                    }
                    
                    if(paymentLine.ASI_CRM_SG_Type__c == 'Events') {
                        totalEventsPayment += amount;
                    } 
					else if(paymentLine.ASI_CRM_SG_Type__c == 'Signages / Advertising Spot'
                             /* [VL 3.0] BEGIN */
                              || paymentLine.ASI_CRM_SG_Type__c == 'Signages'
                             /* [VL 3.0] END */
                             ) {
                        totalSignagesPayment += amount;
                    } 
					else if(paymentLine.ASI_CRM_SG_Type__c == 'Trade Incentive Trips') {
                        totalTradeIncentivesPayment += amount;
                    } 
					else if(paymentLine.ASI_CRM_SG_Type__c == 'Product Branding Display') {
                        totalProductBrandingPayment += amount;
                    } 
					else if(paymentLine.ASI_CRM_SG_Type__c == 'Ad-hoc Promotions') {
                        totalAdhocPayment += amount;
                    } 
                    /* [VL 4.1] BEGIN */
                    /*
                    else if(paymentLine.ASI_CRM_SG_Type__c == 'Anniversary') {
                        totalAnniversaryPayment += amount;
                    }
                    */
                    /* [VL 4.1] END */
                    /* [VL 1.0] BEGIN */
                    else if(paymentLine.ASI_CRM_SG_Type__c == 'Cash - Target Achieved' || paymentLine.ASI_CRM_SG_Type__c == 'Cash - Upfront') {
                        totalCashPayment += amount;
                    }
                    /* [VL 1.0] END */
                    /* [VL 2.1] BEGIN */
                    else if(paymentLine.ASI_CRM_SG_Type__c == 'Bottle Incentive') {
                        totalBottleIncentivePayment += amount;
                    }
                    /* [VL 2.1] END */
                    /* [VL 3.1] BEGIN */
                    else if(paymentLine.ASI_CRM_SG_Type__c == 'Advertising Spot') {
                        totalAdvertisingSpotPayment += amount;
                    }
                    /* [VL 3.1] END */
                    /* [WL 8.0] BEGIN */
                    else if(paymentLine.ASI_CRM_SG_Type__c == 'A&P Fund') {
                        totalAnPFundPayment += amount;
                    }
                    /* [WL 8.0] END */
                    
                    system.debug('paymentLine.ASI_CRM_SG_Type__c: '+paymentLine.ASI_CRM_SG_Type__c);
                }
                
                for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetListTemp) {
                    
                    /* [VL 4.0] BEGIN */
                    /*
                    Decimal btlsPerCase = contractTargetItem.ASI_CRM_SG_Btls_Per_Case__c != null ? contractTargetItem.ASI_CRM_SG_Btls_Per_Case__c : 0;
                    Decimal priceWsOnTrade = contractTargetItem.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c != null ? contractTargetItem.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c : 0;
                    Decimal eventsCase = contractTargetItem.ASI_CRM_SG_Events_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Events_Free_Bottles__c : 0;
                    Decimal signageCase = contractTargetItem.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c != null ? contractTargetItem.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c : 0;
                    Decimal anniversaryCase = contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c : 0;
                    */
                    /* [VL 4.0] END */
                    
                    /* [VL 3.1] BEGIN */
                    /* [VL 4.0] BEGIN */
                    /*
                    Decimal advertisingSpotCase = contractTargetItem.ASI_CRM_Advertising_Spot_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_Advertising_Spot_Free_Bottles__c : 0;*/
                    /* [VL 4.0] END */
                    /* [VL 3.1] END */
                    
                    /* [VL 4.0] BEGIN */
                    /*
                    Decimal eventsCaseConvert = eventsCase * btlsPerCase * priceWsOnTrade;
                    Decimal signageCaseConvert = signageCase * btlsPerCase * priceWsOnTrade;
                    Decimal anniversaryCaseConvert = anniversaryCase * btlsPerCase * priceWsOnTrade;*/
                    /* [VL 4.0] END */
                    /* [VL 3.1] BEGIN */
                    /* [VL 4.0] BEGIN */
                    /*
                    Decimal advertisingSpotCaseConvert = advertisingSpotCase * btlsPerCase * priceWsOnTrade;
                    */
                    /* [VL 4.0] END */
                    /* [VL 3.1] END */
                    
                    /* [VL 4.0] BEGIN */
                    /*
                    totalEvents += eventsCaseConvert + (contractTargetItem.ASI_CRM_SG_Events__c != null ? contractTargetItem.ASI_CRM_SG_Events__c : 0);
                    totalSignages += signageCaseConvert + (contractTargetItem.ASI_CRM_SG_Signages_Advertising_Spot__c != null ? contractTargetItem.ASI_CRM_SG_Signages_Advertising_Spot__c : 0);
                    */
                    totalEvents += contractTargetItem.ASI_CRM_SG_Events__c != null ? contractTargetItem.ASI_CRM_SG_Events__c : 0;
                    totalSignages += contractTargetItem.ASI_CRM_SG_Signages_Advertising_Spot__c != null ? contractTargetItem.ASI_CRM_SG_Signages_Advertising_Spot__c : 0;
                    /* [VL 4.0] END */
                    totalTradeIncentives += contractTargetItem.ASI_CRM_SG_Trade_Incentive_Trips__c != null ? contractTargetItem.ASI_CRM_SG_Trade_Incentive_Trips__c : 0;
                    totalProductBranding += contractTargetItem.ASI_CRM_SG_Product_Branding_Display__c != null ? contractTargetItem.ASI_CRM_SG_Product_Branding_Display__c : 0;
                    totalAdhoc += contractTargetItem.ASI_CRM_SG_Ad_hoc_Promotions__c != null ? contractTargetItem.ASI_CRM_SG_Ad_hoc_Promotions__c : 0;
                    /* [VL 4.1] BEGIN */
                    /*
                    totalAnniversary += anniversaryCaseConvert;
                    */
                    /* [VL 4.1] END */
                    /* [VL 1.0] BEGIN */
                    totalCash += contractTargetItem.ASI_CRM_SG_Cash__c != null ? contractTargetItem.ASI_CRM_SG_Cash__c : 0;
                    /* [VL 1.0] END */
                    /* [VL 2.1] BEGIN */
                      /* [VL 6.0] BEGIN */
                      /*
                      totalBottleIncentive += contractTargetItem.ASI_CRM_Bottle_Incentive_Total__c != null ? contractTargetItem.ASI_CRM_Bottle_Incentive_Total__c : 0;
                      */
                      decimal achievedPercent = contractTargetItem.ASI_CRM_Contract__r.ASI_CRM_Till_Date_Sales_Volume_9L__c != null ? contractTargetItem.ASI_CRM_Contract__r.ASI_CRM_Till_Date_Sales_Volume_9L__c / contractTargetItem.ASI_CRM_Contract__r.ASI_CRM_SG_Total_Target_Sales_9L_Cases__c : 0;
                      totalBottleIncentive += contractTargetItem.ASI_CRM_Bottle_Incentive_Total__c != null ?
                                              (achievedPercent > 1 ? (contractTargetItem.ASI_CRM_Bottle_Incentive_Total__c * achievedPercent) : contractTargetItem.ASI_CRM_Bottle_Incentive_Total__c ) : 0;
                      
                      /* [VL 6.0] END */
                    
                    /* [VL 2.1] END */
                    /* [VL 3.1] BEGIN */
                    totalAdvertisingSpot += contractTargetItem.ASI_CRM_Advertising_Spot__c != null ? contractTargetItem.ASI_CRM_Advertising_Spot__c : 0;
                    /* [VL 3.1] END */
					
					/* [WL 8.0] BEGIN*/
                    totalAnPFund += contractTargetItem.ASI_CRM_SG_Ad_hoc_Promotions__c != null ? contractTargetItem.ASI_CRM_SG_Ad_hoc_Promotions__c : 0;
                    /* [WL 8.0] END*/
                }
                
                System.debug('totalEventsPayment ' + totalEventsPayment + ' totalEvents ' + totalEvents);
                
                if(totalEventsPayment.setScale(2) > totalEvents.setScale(2)) {
                    /* [VL 1.2] BEGIN */
                    /*
                    amountExceed += 'Total events payment of ' + totalEventsPayment + ' is over than the total events of ' + totalEvents + '. ';
                    */
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total events payment of $' + totalEventsPayment.setScale(2) + ' is over than the total events of $' + totalEvents.setScale(2) + '. ';
                    /* [VL 1.2] END */
                }
                if(totalSignagesPayment.setScale(2) > totalSignages.setScale(2)) {
                    /* [VL 1.2] BEGIN */
                    /*
                    amountExceed += 'Total signage payment of ' + totalSignagesPayment + ' is over than the total signage of ' + totalSignages + '. ';
                    */
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total signage payment of $' + totalSignagesPayment.setScale(2) + ' is over than the total signage of $' + totalSignages.setScale(2) + '. ';
                    /* [VL 1.2] END */
                }
                if(totalTradeIncentivesPayment.setScale(2) > totalTradeIncentives.setScale(2)) {
                    /* [VL 1.2] BEGIN */
                    /*
                    amountExceed += 'Total trade incentives payment of ' + totalTradeIncentivesPayment + ' is over than the total trade incentives of ' + totalTradeIncentives + '. ';
                    */
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total trade incentives payment of $' + totalTradeIncentivesPayment.setScale(2) + ' is over than the total trade incentives of $' + totalTradeIncentives.setScale(2) + '. ';
                    /* [VL 1.2] END */
                }
                if(totalProductBrandingPayment.setScale(2) > totalProductBranding.setScale(2)) {
                    /* [VL 1.2] BEGIN */
                    /*
                    amountExceed += 'Total product branding payment of ' + totalProductBrandingPayment + ' is over than the total product branding of ' + totalProductBranding + '. ';
                    */
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total product branding payment of $' + totalProductBrandingPayment.setScale(2) + ' is over than the total product branding of $' + totalProductBranding.setScale(2) + '. ';
                    /* [VL 1.2] END */
                }
                if(totalAdhocPayment.setScale(2) > totalAdhoc.setScale(2)) {
                    /* [VL 1.2] BEGIN */
                    /*
                    amountExceed += 'Total ad hoc payment of ' + totalAdhocPayment + ' is over than the total ad hoc of ' + totalAdhoc + '. ';
                    */
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total ad hoc payment of $' + totalAdhocPayment.setScale(2) + ' is over than the total ad hoc of $' + totalAdhoc.setScale(2) + '. ';
                    /* [VL 1.2] END */
                }
                /* [VL 4.1] BEGIN */
                /*
                if(totalAnniversaryPayment > totalAnniversary) {
                    // [VL 1.2] BEGIN 
                    //amountExceed += 'Total anniversary payment of ' + totalAnniversaryPayment + ' is over than the total anniversary of ' + totalAnniversary + '. ';
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total anniversary payment of ' + totalAnniversaryPayment + ' is over than the total anniversary of ' + totalAnniversary + '. ';
                    // [VL 1.2] END 
                }
                */
                /* [VL 4.1] END */
                /* [VL 1.0][VL 1.2] BEGIN */
                system.debug('totalCashPayment: '+totalCashPayment);
                system.debug('totalCash: '+totalCash);
                if(totalCashPayment.setScale(2) > totalCash.setScale(2)) {
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total cash payment of $' + totalCashPayment.setScale(2) + ' is over than the total cash sponsorship of $' + totalCash.setScale(2) + '. ';
                }
                /* [VL 1.0][VL 1.2] END */
                
                /* [VL 2.1] BEGIN */
                /* [VL 7.0] BEGIN */
                /*
                if(totalBottleIncentivePayment.setScale(2) > totalBottleIncentive.setScale(2)) {
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total bottle incentive payment of $' + totalBottleIncentivePayment.setScale(2) + ' is over than the total bottle incentive of $' + totalBottleIncentive.setScale(2) + '. ';
                }
				*/
                /* [VL 7.0] END */
                /* [VL 2.1] END */
                
                /* [VL 3.1] BEGIN */
                if(totalAdvertisingSpotPayment.setScale(2) > totalAdvertisingSpot.setScale(2)) {
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total advertising spot payment of $' + totalAdvertisingSpotPayment.setScale(2) + ' is over than the total advertising spot of $' + totalAdvertisingSpot.setScale(2) + '. ';
                }
                /* [VL 3.1] END */
                
                 /* [WL 8.0] BEGIN */
                if(totalAnPFundPayment.setScale(2) > totalAnPFund.setScale(2)) {
                    amountExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total A&P Fund payment of $' + totalAnPFundPayment.setScale(2) + ' is over than the total A&P Fund of $' + totalAnPFund.setScale(2) + '. ';
                }
                /* [WL 8.0] END */
            }
        }
        
        return amountExceed;
    }

}