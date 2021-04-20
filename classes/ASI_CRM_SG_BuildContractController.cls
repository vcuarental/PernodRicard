/*********************************************************************************
 * Name: ASI_CRM_SG_BuildContractController
 * Description: Controller class for buildContractPage 
 * Related Test Class: ASI_CRM_SG_Contract_Test

 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2014-11-17       Laputa                  Copy contract builder from EUR
 * 2014-12-01       Laputa: Conrad          Implement SKU historical cost mapping
 * 2014-12-02       Laputa: Conrad          Implement New Object insertion with Payment Schedule. Started Testing and debugging. Development completed 
 * 2014-12-22       Laputa: Conrad          Implement Contract Outlet Selection if Contract Outlet is a parent account
 * 2015-02-13       Laputa: Conrad          Beta Comments Implemented
 * 2015-04-21       Laputa: Conrad          Change Request: Sub-Brand Selection
 * 2016-02-05       Laputa: Vincent         [VL 7.0] Retrieve the latest SKU Price/Cost before contract start date 
 *                                          [VL 7.1] Retrieve Duty Per Bottle from SKU Price/Cost
 *                                          [VL 7.2] Activate the usage of Duty Per Bottle 
 * 2016-02-05       IPC: DC                 [DC 8.0] Retrieve "FOB" and "Handling Cost" Per Bottle from SKU Price/Cost
 *                                          [DC 8.1] Activate the usage of "FOB" and "Handling Cost" Per Bottle 
 * 2016-02-12       IPC: DC                 [DC 8.2] Retrieve "Sequence No." from Contract Target.
 * 2016-02-15       IPC: DC                 [DC 8.3] Sort using "Sequence No." of contract target before saving.
 * 2016-02-17       Laputa: Vincent         [VL 9.0] Display any error when saving the contract
 *                                          [VL 9.1] Sort contract target by Sequence No. by adjusting the index of allContractTargetMap
 * 2016-02-18       IPC: DC                 [DC 10.0] Implemented "Request Payment" logic for creating Payment Request and Line Item records.
 * 2016-02-23       Laputa: Vincent         [VL 11.0] For "Request Payment" button, add contract ID to payment request header.
 * 2016-02-24       IPC: DC                 [DC 11.0] Get generated Payment Request Id in order to redirect the whole page to new Payment Request.
 * 2016-02-24       IPC: DC                 [DC 11.1] Updated logic for generating Payment Requests and related Line Items.
 * 2016-03-01       IPC: DC                 [DC 11.1] Updated logic for generating Payment Requests and related Line Items.
 * 2016-03-11       Laputa: Vincent         [VL 12.0] For generating Payment Requests: Build final sub-brand - Cash sponsorship MAP: fix error for DC (forgot to calculate final sub-brand and sum the cash)
 *                                          [VL 12.1] For generating Payment Requests: Build final sub-brand - Cash sponsorship Weighted % MAP: fix error for DC (forget to sum the %)
 *                                          [VL 12.2] For generating Payment Requests: Calculate amount for payment request line item: fix error for DC (forget to convert number to % by dividing it by 100)
 * 2016-03-11       Laputa: Vincent         [VL 13.0] For generating Payment Requests: Invoice No. = Contract No.
 *                                          [VL 13.1] For generating Payment Requests: Cater description for Schedule Date achieved
 * 2016-05-16       Laputa: Vincent         [VL 14.0] For generating Payment Requests: Cater 0% achieved
 * 2016-05-16       Laputa: Hugo            [HC 1.0] For generating Payment Requests: Cater 0% achieved
 * 2016-06-10       Laputa: Hugo            [HC 2.0] Quick save remove refresh command
 * 2016-08-02       Laputa: Vincent         [VL 15.0] For "Request Payment" button, PR request using the input amount as total, but not Total Cash Sponsorship * achieved %
 * 2016-12-14       Laputa: Vincent         [VL 16.0] Change Sub-brand field from select-option to auto-complete
 * 2017-02-07		Wilken Lee				[WL 17.0] Check split of payment amount against payment schedule and adjust for rounding issue
 * 2017-04-19		Laputa: Vincent			[VL 18.0] Auto-populate Wholesaler Margin = WS-OT - PRS-WS on add contract target
 * 2017-06-26		Laputa: Vincent			[VL 19.0] Issue time bound bonus
 * 2017-07-03		Laputa: Vincent			[VL 20.0] Calculate WS Margin on save
 * 2017-07-21		Laputa: Vincent			[VL 21.0] Remove default Invoice Date for auto-generated payment request
 * 2018-02-23		Wilken Lee				[WL 22.0] Clone Contract attachment when creating cash sponsorship payment
 * 2018-03-27		Laputa: Vincent			[VL 23.0] Fix: payment schedule can input decimal as achieved %
 * 2018-03-28		Laputa: Vincent			[VL 24.0] Fix: put RTM WS price on search SKU
 */


global with sharing class ASI_CRM_SG_BuildContractController extends ASI_CRM_SG_PageControllerBase {
            
    private final static String REQUEST_PAYMENT_ERROR = 
        'Payment request cannot be created because the accumulated request for cash is larger than the Total Cash Sponsorship of this contract';
    private final static String NO_DATA = 'There isn\'t enough data to request payment.';
    private final static String REQUEST_LINE_TYPE = 'Cash - Target Achieved';
    private final static String REQUEST_Line_TYPE_UPFRONT = 'Cash - Upfront';
    private final static String CONTRACTTARGET_RT = 'ASI_CRM_SG_Contract_Target';
    private final static String PAYMENTSCHEDULE_RT = 'ASI_CRM_SG_Payment_Schedule';

    /* [DC 11.0] BEGIN */
    public String paymentScheduleId {get; set;}
    public String prevPaymentScheduleId {get; set;}
    public ASI_TH_CRM_PaymentRequest__c paymentRequestInstance {get; set;}
    /* [DC 11.0] END */

    /* [DC 11.1] BEGIN */
    Map<Id, Decimal> mapSubBrandId_CotractTargetCash;
    Map<Id, Decimal> mapSubBrandId_WeightPercent;
    Decimal sponsorshipWithScheduleDate = 0.0;
    /* [HC 1.0] BEGIN */ 
    Decimal sponsorshipWithZeroAchieved = 0.0;
    /* [HC 1.0] END */ 

    Map<Id, Decimal> mapSubBrandId_AmountWithDate;
    /* [DC 11.1] END */    

    public ApexPages.StandardController standardController {get;set;}
    public Id contractId {
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }
    
    public ASI_TH_CRM_Contract__c contractObj {get;set;}
    public static String CONTRACT_LINE_ITEM_TABLE_PREFIX {get{ return 'ContractLineItemTable_';}}
    
    public Map<String, contractTargetWrapper> allContractTargetMap {get;set;}{allContractTargetMap = new Map<String, contractTargetWrapper>();}
    
    public Map<String, ASI_MFM_SKU_Code__c> allSKUMap {get;set;}{allSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();}
    
    //List out all child account of parent outlet
    public Map<String, ASI_CRM_AccountsAdditionalField__c> allContractOutletMap {get;set;}{allContractOutletMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();}
    public Map<String, ASI_CRM_AccountsAdditionalField__c> addedContractOutletMap {get;set;}{addedContractOutletMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();}
    
    // Store all the Contract Outlet Objects
    public Map<String,ASI_CRM_Contract_Outlets__c> allContractOutletSelectedMap {get;set;}{allContractOutletSelectedMap = new Map<String,ASI_CRM_Contract_Outlets__c>();}
    public List<ASI_CRM_Contract_Outlets__c> ContractOutletToDelete {get;set;}{ContractOutletToDelete = new List<ASI_CRM_Contract_Outlets__c>();}
    
    // Retrieve and map all SKU Historic cost
    public Map<ID, Map<String, ASI_CRM_MY_SKUPriceCost__c>> allSKUHistoricMap {get;set;}{allSKUHistoricMap = new Map<ID, Map<String, ASI_CRM_MY_SKUPriceCost__c>>();}

    // Initialize existing SKU query
    public Set<ID> existingSKU {get;set;}{existingSKU = new Set<ID>();}
    
    // Store all the payment schedule objects
    public Map<String, ASI_CRM_Payment_Schedule__c> allPaymentScheduleCashMap {get;set;}{allPaymentScheduleCashMap = new Map<String, ASI_CRM_Payment_Schedule__c>();}
    public Map<String, ASI_CRM_Payment_Schedule__c> allPaymentScheduleContractMap {get;set;}{allPaymentScheduleContractMap = new Map<String, ASI_CRM_Payment_Schedule__c>();}
    public List<ASI_CRM_Payment_Schedule__c> paymentScheduleToDelete {get;set;}{paymentScheduleToDelete = new List<ASI_CRM_Payment_Schedule__c>();}
    
    // Attributes for boolean expressions
    public Boolean isEdit {get;set;}{isEdit = false;}
    public Boolean isParentOutlet {get;set;}{isParentOutlet = false;}
    
    //Attributes used for filtering SKU
    public String subBrandSelected {get;set;}{subBrandSelected = '';}
    public String skuNameFilter {get;set;}
    public String categorySelected {get;set;}{categorySelected = '';}
    public List<SelectOption> SubBrandSelectOptions {get;set;}
    public Map<String, ASI_MFM_Sub_Brand__c> subBrandMap {get;set;}
    public Map<String, String> subBrandNameMap {get;set;}
    public List<String> subBrandNameList {get;set;}
    
    public Map<String, Schema.SObjectField> contractTargetFieldMap {get;set;}
    public List<ASI_CRM_ContractTarget__c> deleteContractTargetList {get;set;}{deleteContractTargetList = new List<ASI_CRM_ContractTarget__c>();}
    public Map<String, ASI_MFM_SKU_Code__c> addedSKUMap {get;set;}{addedSKUMap = new Map<String, ASI_MFM_SKU_Code__c>();}
    
    // Attributes to keep track of newly added Payment Schedule record
    public static String PAYMENTSCHEDULE_ITEM_NEWRECORD_PREFIX {get{ return 'zzzzzzPAYMENTSCHEDULENEWZ';}}
    public Integer PAYMENTSCHEDULE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    public static String CONTRACT_LINE_ITEM_NEWRECORD_PREFIX {get{ return 'zzzzzCONTRACTNEWZ';}}
    public Integer CONTRACT_LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    private string REQUESTEDPAYMENTID = '';
    public String REQUESTEDPAYMENTID_VF          {get {return REQUESTEDPAYMENTID;}}
    
    public ASI_CRM_SG_BuildContractController(ApexPages.StandardController standardController){
        this.standardController = standardController;

        mapSubBrandId_WeightPercent = new Map<Id, Decimal>();
        mapSubBrandId_CotractTargetCash = new Map<Id, Decimal>();
        /*Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType contractTargetSchema = schemaMap.get('ASI_CRM_ContractTarget__c');
        contractTargetFieldMap = contractTargetSchema.getDescribe().fields.getMap();
        */
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isEditStr = params.get('IS_EDIT');
        isEdit = (isEditStr ==null)?false:true;
        
        //Set Contract
        contractObj = retrieveContractHeader(((ASI_TH_CRM_Contract__c)standardController.getRecord()).id);
        
        if(contractObj.ASI_TH_CRM_Contract_Status__c != 'Draft' && !contractObj.ASI_TH_CRM_Contract_Status__c.contains('Rejected')) {
            //isEdit = false;
        }
        
        if (contractObj.ASI_CRM_CN_Outlet_WS__c != null) {
            List<ASI_CRM_AccountsAdditionalField__c> customerList = [SELECT ID, Name FROM ASI_CRM_AccountsAdditionalField__c
                                                                        WHERE ASI_CRM_CN_Parent_Outlet__c = : contractObj.ASI_CRM_CN_Outlet_WS__c];
            if(customerList.size() > 0) {
                isParentOutlet = true;
            }
        }
        
        //Retrieve all existing Contract Target
        allContractTargetMap = retrieveContractTarget(contractObj);
        
        //Retrieve all SG SKU
        //allSKUMap = retrieveSKU(allContractTargetMap, subBrandSelected);
        
        // Retrieve related Payment Schedule objects
        setPaymentScheduleMaps(contractObj);
        
        setSubBrandSelectOptions();
        
        // Retrieve all related contract outlets if contract outlet is a parent outlet
        if(isParentOutlet) {
            allContractOutletMap = retrieveContractOutlets(contractObj);
            allContractOutletSelectedMap = retrieveSelectedContractOutlets(contractObj);
            
        }
    }

    public ASI_TH_CRM_Contract__c retrieveContractHeader(ID headerID) {
         ASI_TH_CRM_Contract__c header =  new ASI_TH_CRM_Contract__c();
         Map<String, Schema.SObjectField> contractFieldMap = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
         String theQuery = 'Select ';
        
         for(String fields  : contractFieldMap.keySet()){
            theQuery += fields + ' ,';
         }
         
         thequery = theQuery.subString(0,theQuery.length()-1);
         thequery += ', recordtype.developername, owner.name, createdby.name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c ' +
         ' From ASI_TH_CRM_Contract__c where  ID = ' + '\'' + headerID + '\' ';
     
         List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>)Database.query(theQuery); 
         if (contractList.size() > 0) {
             header = contractList.get(0);
         }
         return header;
    }

    public Map<String, contractTargetWrapper> retrieveContractTarget(ASI_TH_CRM_Contract__c contractObj){
        Map<String, contractTargetWrapper> contractTargetMap = new Map <String, contractTargetWrapper>();
        
        Map<String, Schema.SObjectField> contractDetailsFieldMap = Schema.SObjectType.ASI_CRM_ContractTarget__c.fields.getMap();
        String theQuery = 'Select ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.name, ASI_CRM_Subbrand__r.ASI_CRM_Representative_SKU__c, ASI_CRM_Subbrand__r.name, ';
    
        
        for(String fields  : contractDetailsFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        /*
        theQuery += ' ASI_CRM_SG_Ad_hoc_Promotions__c,';
        theQuery += ' ASI_CRM_Advertising_Spot__c,';
        theQuery += ' ASI_CRM_Advertising_Spot_Free_Bottles__c,';
        theQuery += ' ASI_CRM_SG_Anniversary__c,';
        theQuery += ' ASI_CRM_SG_Anniversary_Free_Bottles__c,';
        theQuery += ' ASI_CRM_Bottle_Incentive__c,';
        theQuery += ' ASI_CRM_SG_Btls_Per_Case__c,';
        theQuery += ' ASI_CRM_SG_Cash__c,';
        theQuery += ' ASI_CRM_SG_Consumer_Price_Offer__c,';
        theQuery += ' ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c,';
        theQuery += ' ASI_CRM_Duty_Per_Bottle__c,';
        theQuery += ' ASI_CRM_SG_Events__c,';
        theQuery += ' ASI_CRM_SG_Events_Free_Bottles__c,';
        theQuery += ' ASI_CRM_FOB_Per_Bottle__c,';
        theQuery += ' ASI_CRM_SG_Good_in_Kinds__c,';
        theQuery += ' ASI_CRM_Handling_Cost_Per_Bottle__c,';
        theQuery += ' ASI_CRM_IGC__c,';
        theQuery += ' ASI_CRM_SG_Management_Incentives__c,';
        theQuery += ' ASI_CRM_SG_Product_Branding_Display__c,';
        theQuery += ' ASI_CRM_SG_Sales_Incentive__c,';
        theQuery += ' ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c,';
        theQuery += ' ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c,';
        theQuery += ' ASI_CRM_Sequence_No__c,';
        theQuery += ' ASI_CRM_SG_Signages_Advertising_Spot__c,';
        theQuery += ' ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c,';
        theQuery += ' ASI_CRM_SG_Size_cl__c,';
        theQuery += ' ASI_CRM_SKU__c,';
        theQuery += ' ASI_CRM_Subbrand__c,';
        theQuery += ' ASI_CRM_TargetCase__c,';
        theQuery += ' ASI_CRM_SG_Trade_Incentive_Trips__c,';
        theQuery += ' ASI_CRM_SG_Wholesaler_Margin__c,';
        theQuery += ' ASI_CRM_Weighted_percentof_Cash_Sponsor__c,';
        theQuery += ' ASI_CRM_SG_Others__c,';
        theQuery += ' ASI_CRM_SG_Target_Sales_Cases_FOC__c,';
        theQuery += ' ASI_CRM_SG_Target_Sales_9L_Cases__c,';
        theQuery += ' ASI_CRM_Total_Duty__c,';
        theQuery += ' ASI_CRM_Total_FOB__c,';
        theQuery += ' ASI_CRM_Total_Handling_Cost__c,';
        theQuery += ' ASI_CRM_SG_Total_Free_Goods_Cases__c,';
        theQuery += ' ASI_CRM_SG_Total_Free_Goods_9L_Cases__c,';
        theQuery += ' ASI_CRM_SG_Wholesaler_Margin_Total__c,';
        theQuery += ' ASI_CRM_SG_Contract_Margin_per_9Lc__c,';
        theQuery += ' ASI_CRM_SG_Contract_Margin_Total__c,';
        theQuery += ' ASI_CRM_Bottle_Incentive_Total__c,';
        theQuery += ' ASI_CRM_SG_Cash_Sponsorship_Total__c,';
        theQuery += ' ASI_CRM_SG_IGC_Cost_Per_case__c,';
        theQuery += ' ASI_CRM_SG_Trd_Adv_Promo_Total__c,';
        theQuery += ' ASI_CRM_SG_Trd_Adv_Promo_TotalPRS__c,';
        theQuery += ' ASI_CRM_SG_Compensation_for_WS_Price_Dif__c,';
        */
        
        thequery = theQuery.subString(0,theQuery.length()-1);
        /* [DC 8.2] BEGIN */
        thequery += ' FROM ASI_CRM_ContractTarget__c WHERE ASI_CRM_Contract__c = ' + '\'' + contractObj.id + '\' ';
        thequery += ' and recordtype.developername = :CONTRACTTARGET_RT ';
        thequery += ' ORDER BY ASI_CRM_Sequence_No__c ASC LIMIT 1000';
        /* [DC 8.2] END */     
        List<ASI_CRM_ContractTarget__c> purchaseContractLineItems = (List<ASI_CRM_ContractTarget__c>)Database.query(theQuery); 
        
        if (contractObj != null){
            Decimal ctCash = 0.0, weightedPercent = 0.0;
            for(ASI_CRM_ContractTarget__c c : purchaseContractLineItems){ 
                contractTargetWrapper contracttargetWrap = new contractTargetWrapper(c, null);
                /*if(c.ASI_CRM_SKU__c == null) {
                    contractTargetMap.put(c.ASI_CRM_Subbrand__r.ASI_CRM_Representative_SKU__c, contracttargetWrap);
                } else {
                    contractTargetMap.put(c.ASI_CRM_SKU__c, contracttargetWrap);
                }*/
                /* [VL 9.1] BEGIN */
                /*
                contractTargetMap.put(c.id, contracttargetWrap);
                */
                String sequenceNo = '0000' + c.ASI_CRM_Sequence_No__c;
                contractTargetMap.put(sequenceNo.right(5)+'_'+c.id, contracttargetWrap);
                /* [VL 9.1] END */
                if(c.ASI_CRM_SKU__c == null) {
                    existingSKU.add(c.ASI_CRM_Subbrand__r.ASI_CRM_Representative_SKU__c);
                } else {
                    existingSKU.add(c.ASI_CRM_SKU__c);
                }

                
                /* [VL 12.0][VL 12.1] BEGIN */
                ID finalSubBrandID = c.ASI_CRM_Subbrand__c != NULL ? c.ASI_CRM_Subbrand__c : c.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                /* [VL 12.0][VL 12.1] END */
                
                /* [DC 11.1] BEGIN */
                /* [VL 12.0] BEGIN */
                /*
                if(!mapSubBrandId_CotractTargetCash.containsKey(c.ASI_CRM_Subbrand__c)) {
                    ctCash = c.ASI_CRM_SG_Cash__c == NULL ? 0.0 : c.ASI_CRM_SG_Cash__c;
                    mapSubBrandId_CotractTargetCash.put(c.ASI_CRM_Subbrand__c, ctCash);
                } else {
                    mapSubBrandId_CotractTargetCash.put(
                        c.ASI_CRM_Subbrand__c,
                        mapSubBrandId_CotractTargetCash.get(c.ASI_CRM_Subbrand__c) + ctCash);
                }
                */
                ctCash = c.ASI_CRM_SG_Cash__c == NULL ? 0.0 : c.ASI_CRM_SG_Cash__c;
                mapSubBrandId_CotractTargetCash.put(finalSubBrandID, (mapSubBrandId_CotractTargetCash.containsKey(finalSubBrandID) ? (mapSubBrandId_CotractTargetCash.get(finalSubBrandID) + ctCash) : ctCash)); 
                /* [VL 12.0] END */
                System.debug('------ mapSubBrandId_CotractTargetCash ------ : ' + mapSubBrandId_CotractTargetCash);

                /* [VL 12.1] BEGIN */
                /*
                if(!mapSubBrandId_WeightPercent.containsKey(c.ASI_CRM_Subbrand__c)) {
                    weightedPercent = c.ASI_CRM_Weighted_percentof_Cash_Sponsor__c == NULL ? 0.0 : c.ASI_CRM_Weighted_percentof_Cash_Sponsor__c;
                    mapSubBrandId_WeightPercent.put(c.ASI_CRM_Subbrand__c, weightedPercent);
                } else {
                    mapSubBrandId_WeightPercent.put(
                        c.ASI_CRM_Subbrand__c,
                        mapSubBrandId_WeightPercent.get(c.ASI_CRM_Subbrand__c) + weightedPercent);
                }
                */
                weightedPercent = c.ASI_CRM_Weighted_percentof_Cash_Sponsor__c == NULL ? 0.0 : c.ASI_CRM_Weighted_percentof_Cash_Sponsor__c;
                mapSubBrandId_WeightPercent.put(finalSubBrandID, (mapSubBrandId_WeightPercent.containsKey(finalSubBrandID) ? (mapSubBrandId_WeightPercent.get(finalSubBrandID) + weightedPercent) : weightedPercent)); 
                /* [VL 12.1] END */
                System.debug('------ mapSubBrandId_WeightPercent ------ : ' + mapSubBrandId_WeightPercent);
                /* [DC 11.1] END */
                
            }
        } 
        System.debug('FLAG - retrieveContractTarget'+ '--' +contractTargetMap);
        // contractTargetMap.values().sort();
        return contractTargetMap;
    }
    
    public void retrieveSKUbySubBrand(){
        allSKUMap = retrieveSKU(allContractTargetMap, subBrandSelected);
    }
    
    public Map<String, ASI_MFM_SKU_Code__c> retrieveSKU(Map<String, contractTargetWrapper> contractTargetMap, String subBrandSelected){
        Map<String, ASI_MFM_SKU_Code__c> contractSKUMap = new Map <String, ASI_MFM_SKU_Code__c>();
        if (contractObj != null){
        
            Map<String, Schema.SObjectField> skuFieldsMap = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
            String theQuery = 'Select ';
    
            for(String fields  : skuFieldsMap.keySet()){
                theQuery += fields + ' ,';
            }
            thequery = theQuery.subString(0,theQuery.length()-1);
            thequery +=' From ASI_MFM_SKU_Code__c where recordtype.developername = \'ASI_CRM_SG_SKU\' AND ASI_HK_CRM_IsPOSProduct__c = false ';
            //thequery +=' AND ASI_HK_CRM_Packaging_Size__c != NULL AND ASI_HK_CRM_Std_Bottle_Size__c != NULL ';
            
            /*if (subBrandSelected != null && subBrandSelected.trim() != '') {
               thequery += ' and ASI_MFM_Sub_Brand__c = \'' + String.escapeSingleQuotes(subBrandSelected.trim()) + '\'';
            }*/
            
            if (skuNameFilter != null && skuNameFilter.trim() != '') {
               thequery += ' and name like \'%' + String.escapeSingleQuotes(skuNameFilter.trim()) + '%\'';
            }
            
            thequery += ' ORDER BY Name ';   
            
            List<ASI_MFM_SKU_Code__c> skuList = (List<ASI_MFM_SKU_Code__c>)Database.query(theQuery);   
            Set<ID> skuCodeID = new Set<ID>();
            
            for(ASI_MFM_SKU_Code__c sku : skuList){
                if(!existingSKU.contains(sku.id)) {
                    //contractSKUMap.put(sku.id, sku);
                    skuCodeID.add(sku.id); 
                }    
            }
            
            System.debug('FLAG - skuCodeID'+ '--' +skuCodeID);
            
			/*
            Map<String, Schema.SObjectField> skuHistoricFieldsMap = Schema.SObjectType.ASI_CRM_MY_SKUPriceCost__c.fields.getMap();
            String theQueryHistoric = 'Select recordtype.developername, ';
    
            for(String fields  : skuHistoricFieldsMap.keySet()){
                theQueryHistoric += fields + ' ,';
            }
			*/
            List<String> skuHistoricFieldsList = new List<String>{
				'ASI_CRM_SKU__c',
				'ASI_CRM_EffectiveDate__c',
				'ASI_CRM_Price__c',
				'ASI_CRM_Cost__c',
				'ASI_CRM_SG_IGC_Cost_Per_9Lc__c'
			};
            String theQueryHistoric = 'Select recordtype.developername, ';
    
            for(String fields  : skuHistoricFieldsList){
                theQueryHistoric += fields + ' ,';
            }
            theQueryHistoric = theQueryHistoric.subString(0,theQueryHistoric.length()-1);
            theQueryHistoric +=' From ASI_CRM_MY_SKUPriceCost__c where ';
            
            theQueryHistoric +=' (recordtype.developername = \'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler\' OR ';
            theQueryHistoric +=' recordtype.developername = \'ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade\' OR ';
            theQueryHistoric +=' recordtype.developername = \'ASI_CRM_SG_IGC\' OR ';
            /* [VL 7.1] BEGIN */
            theQueryHistoric +=' recordtype.developername = \'ASI_CRM_SG_CRM_Duty_Per_Bottle\' OR ';
            /* [VL 7.1] END */
			/* [VL 24.0] BEGIN */
            theQueryHistoric +=' recordtype.developername = \'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle\' OR ';
            theQueryHistoric +=' recordtype.developername = \'ASI_CRM_SG_Open_Outlet_Price_Per_Bottle\' OR ';
			/* [VL 24.0] END */
            /* [DC 8.0] BEGIN */
            theQueryHistoric +=' recordtype.developername = \'ASI_CRM_SG_CRM_FOB_Per_Bottle\' OR ';
            theQueryHistoric +=' recordtype.developername = \'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle\' ) ';
            /* [DC 8.0] END */
            theQueryHistoric +=' AND ASI_CRM_SKU__c IN : skuCodeID AND ASI_CRM_EffectiveDate__c != NULL';
            /* [VL 7.0] BEGIN */

            Date contractStartDate = contractObj.ASI_TH_CRM_Start_Date__c;
            if (contractStartDate != NULL) {
                theQueryHistoric +=' AND ASI_CRM_EffectiveDate__c <= :contractStartDate';
            }
            /* [VL 7.0] END */
            theQueryHistoric += ' ORDER BY ASI_CRM_EffectiveDate__c DESC NULLS LAST ';
            
            System.debug('FLAG - theQueryHistoric '+ '--' +theQueryHistoric );
            
            List<ASI_CRM_MY_SKUPriceCost__c> skuHistoricCosts = (List<ASI_CRM_MY_SKUPriceCost__c>)Database.query(theQueryHistoric);
            Map<ID, Map<String,ASI_CRM_MY_SKUPriceCost__c>> skuHistoricCostMap = new Map<ID, Map<String,ASI_CRM_MY_SKUPriceCost__c>> ();

            // Query all related SKU Historic Map data by retrieving the latest historical data and mapping them according to the SKU ID.
            for(ASI_CRM_MY_SKUPriceCost__c skuHistoric : skuHistoricCosts) {
            
                System.debug('FLAG - skuHistoric.recordtype.developername'+ '--' +skuHistoric.recordtype.developername);
                
                if(!skuHistoricCostMap.containsKey(skuHistoric.ASI_CRM_SKU__c)) {
                
                    Map<String, ASI_CRM_MY_SKUPriceCost__c> skuMapRecordtype = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();
                    skuMapRecordtype.put(skuHistoric.recordtype.developername, skuHistoric);
                    skuHistoricCostMap.put(skuHistoric.ASI_CRM_SKU__c, skuMapRecordtype);
                }
                
                if(skuHistoricCostMap.containsKey(skuHistoric.ASI_CRM_SKU__c)) {
                
                    Map<String, ASI_CRM_MY_SKUPriceCost__c> skuPriceCostRecordTypeMap = skuHistoricCostMap.get(skuHistoric.ASI_CRM_SKU__c);
                    String recordTypeDeveloperName = skuHistoric.recordtype.developername;
                    
                    if(skuPriceCostRecordTypeMap.containsKey(recordTypeDeveloperName)) {
                        ASI_CRM_MY_SKUPriceCost__c skuHistTemp = skuPriceCostRecordTypeMap.get(recordTypeDeveloperName);
                        if(skuHistTemp.ASI_CRM_EffectiveDate__c < skuHistoric.ASI_CRM_EffectiveDate__c) {
                            
                            skuPriceCostRecordTypeMap.put(recordtypeDevelopername, skuHistoric);
                            skuHistoricCostMap.put(skuHistoric.ASI_CRM_SKU__c, skuPriceCostRecordTypeMap);
                        }
                    } else {
                        skuPriceCostRecordTypeMap.put(recordtypeDevelopername, skuHistoric);
                        skuHistoricCostMap.put(skuHistoric.ASI_CRM_SKU__c, skuPriceCostRecordTypeMap);
                    }
                    
                }
            }
            
            System.debug('FLAG - skuHistoricCosts'+ '--' +skuHistoricCosts );
            System.debug('FLAG - skuHistoricCosts.size() '+ '--' +skuHistoricCosts.size() );
            
            allSKUHistoricMap = skuHistoricCostMap;
            
            // Only retrieve SKU with historic cost
            for(ASI_MFM_SKU_Code__c sku : skuList){
                if(!existingSKU.contains(sku.id) && allSKUHistoricMap.containsKey(sku.id)) {
                    Map<String,ASI_CRM_MY_SKUPriceCost__c> skuHistoricCostTemp = allSKUHistoricMap.get(sku.id);
                    /* [DC 8.0] BEGIN
                    COMMENTED OUT FOLLOWING PORTION FOR EASIER DOCUMENTATION
                    
                        // [VL 7.1] BEGIN
                        // There is one more record type Duty Per Bottle now
                        //if(skuHistoricCostTemp.size() == 3) {
                        
                        if(skuHistoricCostTemp.size() == 4) {
                        // [VL 7.1] BEGIN 

                    DC - 02/09/2016 - There are two more record types in addition to Duty Per Bottle,
                    which are "FOB Per Bottle" & "Handling Cost Per Bottle". Hence changing size check from 4 to 6.
                    */
					/* [VL 24.0] BEGIN */
					/*
                    if(skuHistoricCostTemp.size() == 6) {
					*/
                    if(skuHistoricCostTemp.size() == 8) {
					/* [VL 24.0] END */
                    /* [DC 8.0] END */
                        contractSKUMap.put(sku.id, sku);
                    }
                }    
            }
            
        }
        System.debug('FLAG - retrieveContractSKU'+ '--' +contractSKUMap );
        System.debug('FLAG - allSKUHistoricMap '+ '--' +allSKUHistoricMap);
        System.debug('FLAG - allSKUHistoricMap.size() '+ '--' +allSKUHistoricMap.size());
        return contractSKUMap ;
    }
    
    public Map<String, ASI_CRM_AccountsAdditionalField__c> retrieveContractOutlets (ASI_TH_CRM_Contract__c contract){
        
        Map<String, ASI_CRM_AccountsAdditionalField__c> contractOutletsMap = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.fields.getMap();
        String theQuery = 'Select ';
    
        for(String fields  : fieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        
        thequery = theQuery.subString(0,theQuery.length()-1);
        
        thequery +=' From ASI_CRM_AccountsAdditionalField__c where ASI_CRM_CN_Parent_Outlet__c = \''+contract.ASI_CRM_CN_Outlet_WS__c+'\' ';
        
        List<ASI_CRM_AccountsAdditionalField__c> objList = (List<ASI_CRM_AccountsAdditionalField__c>)Database.query(theQuery);   
        
        for(ASI_CRM_AccountsAdditionalField__c contractOutlets : objList) {
            contractOutletsMap.put((String)(contractOutlets.id), contractOutlets);
        }
        
        
        
        return contractOutletsMap;
    }
    
    public Map<String, ASI_CRM_Contract_Outlets__c> retrieveSelectedContractOutlets(ASI_TH_CRM_Contract__c contract) {
        Map<String, ASI_CRM_Contract_Outlets__c> contractOutletsMap = new Map<String, ASI_CRM_Contract_Outlets__c>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.ASI_CRM_Contract_Outlets__c.fields.getMap();
        String theQuery = 'Select ';
    
        for(String fields  : fieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        
        thequery = theQuery.subString(0,theQuery.length()-1);
        
        thequery +=' From ASI_CRM_Contract_Outlets__c where ASI_CRM_SG_Contract__c = \''+contract.ID+'\' ';
        
        List<ASI_CRM_Contract_Outlets__c> objList = (List<ASI_CRM_Contract_Outlets__c>)Database.query(theQuery);   
        
        for(ASI_CRM_Contract_Outlets__c contractOutlets : objList) {
            contractOutletsMap.put((String)(contractOutlets.ASI_CRM_SG_Customer__c), contractOutlets);
            addedContractOutletMap.put((String)(contractOutlets.ASI_CRM_SG_Customer__c), allContractOutletMap.get((String)(contractOutlets.ASI_CRM_SG_Customer__c)));
            allContractOutletMap.remove((String)(contractOutlets.ASI_CRM_SG_Customer__c));
        }

        return contractOutletsMap;
    }
    
    public void setPaymentScheduleMaps(ASI_TH_CRM_Contract__c contractObj) {
    
        Map<String, ASI_CRM_Payment_Schedule__c> paymentScheduleCashMap = new Map <String, ASI_CRM_Payment_Schedule__c>();
        Map<String, ASI_CRM_Payment_Schedule__c> paymentScheduleContractMap = new Map <String, ASI_CRM_Payment_Schedule__c>();

        Map<String, Schema.SObjectField> paymentScheduleFieldMap = Schema.SObjectType.ASI_CRM_Payment_Schedule__c.fields.getMap();
        String theQuery = 'Select ';
    
        for(String fields  : paymentScheduleFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += ' From ASI_CRM_Payment_Schedule__c where ASI_CRM_Contract__c = ' + '\'' + contractObj.id + '\' ';
        thequery += ' and recordtype.developername = :PAYMENTSCHEDULE_RT ';
     
        List<ASI_CRM_Payment_Schedule__c> paymentScheduleItems = (List<ASI_CRM_Payment_Schedule__c>)Database.query(theQuery); 
        
        for(ASI_CRM_Payment_Schedule__c c : paymentScheduleItems ){
            if(c.ASI_CRM_Type__c == 'Cash Sponsorship') {
                paymentScheduleCashMap.put(c.id, c);
                /* [DC 11.1] BEGIN */
                if(c.ASI_CRM_Schedule_Date__c != NULL) {
                   sponsorshipWithScheduleDate += c.ASI_CRM_Sponsorship__c == NULL ? 0.0 : c.ASI_CRM_Sponsorship__c;
                }
                /* [DC 11.1] END */

                /* [HC 1.0] BEGIN */ 
                if(String.isNotBlank(c.ASI_CRM_Percentof_achieved_Sales_Target__c) && c.ASI_CRM_Percentof_achieved_Sales_Target__c.equals('0')) {
                    sponsorshipWithZeroAchieved += c.ASI_CRM_Sponsorship__c == NULL ? 0.0 : c.ASI_CRM_Sponsorship__c;
                }
                /* [HC 1.0] END */ 

            }
            if(c.ASI_CRM_Type__c == 'Contract Sponsorship') { 
                paymentScheduleContractMap.put(c.id, c);
            }
        }
        System.debug('------ sponsorshipWithScheduleDate ------ : ' + sponsorshipWithScheduleDate);
        
        allPaymentScheduleCashMap = paymentScheduleCashMap;
        allPaymentScheduleContractMap = paymentScheduleContractMap;
        
    }

    public PageReference saveContract(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        System.debug('Flag - Save Contract - isQuickSave:' + isQuickSaveStr);
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
        
        System.debug('Flag - Save Contract - Mode:' + isQuickSave);
        
        Database.upsertResult[] upsertContractTarget;
        Database.deleteResult[] deleteContractTarget;
        
        System.Savepoint pSavepoint = Database.setSavepoint();
        try{
            if(deleteContractTargetList.size()>0){
                deleteContractTarget = Database.delete(deleteContractTargetList);
                deleteContractTargetList.clear();
            }
            System.debug('Flag - Save Contract - Deleted Contract Target:' + deleteContractTarget);
            
            List<ASI_CRM_ContractTarget__c> upsertContractTargetList = new List<ASI_CRM_ContractTarget__c>();

            
            /* [DC 8.3] BEGIN */
            /*List<String> sortMapKey = new List<String>();

            for(String key : allContractTargetMap.keySet()){
                sortMapKey.add(key);
            }

            sortMapKey.sort();

            for(String key : sortMapKey) {
                allContractTargetMap.get(key).contractTarget.ASI_CRM_Subbrand__c = (Id)allContractTargetMap.get(key).targetSubBrandSelected;
                upsertContractTargetList.add(allContractTargetMap.get(key).contractTarget);
            }*/

			// check manual sort for contract target
			boolean manualSorted = false;
			
            for (contractTargetWrapper a : allContractTargetMap.values()){
                system.debug(a.contractTarget.ASI_CRM_SKU__c + ' ' + a.contractTarget.ASI_CRM_TargetCase__c + ' ' + a.contractTarget.ASI_CRM_SG_Management_Incentives__c);
				if (a.contractTarget.ASI_CRM_Sequence_No__c != null) manualSorted = true;
            }
            
			List<contractTargetWrapper> temp_lstTargetWrappers = new List<contractTargetWrapper>();
			if (manualSorted) {
				// Calling sorting method to sort the items using Sequence No. and/or SKU.Name
				// and iterating over sorted list to set Sequence No. and selected Sub-brand.
				temp_lstTargetWrappers = sortContractTargets(allContractTargetMap.values());
			} else {
				temp_lstTargetWrappers = allContractTargetMap.values();
			}
            Map<String,integer> map_subbrand_count = new Map<String,integer>();
            Map<String,integer> map_sku_count = new Map<String,integer>();
            system.debug('Flag - check contract target sort');
            for (Integer index = 0; index < temp_lstTargetWrappers.size(); index++) {
                system.debug('index: ' + index + ' SKU: ' + temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SKU__c + ' Sub-brand : ' + temp_lstTargetWrappers[index].contractTarget.ASI_CRM_Subbrand__c);
                /* [VL 16.0] BEGIN */
                /*
                // check duplicate sub-brand
                String temp_subbrandid = temp_lstTargetWrappers[index].targetSubBrandSelected;
                if (temp_subbrandid ==null || temp_subbrandid =='') {
                    temp_lstTargetWrappers[index].contractTarget.ASI_CRM_Subbrand__c = null;
                } else 
                if (map_subbrand_count.containsKey(temp_subbrandid)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Duplicated Sub-brand '+subBrandMap.get((id)temp_lstTargetWrappers[index].targetSubBrandSelected).name.toUpperCase()));
                    Database.rollback(pSavepoint); 
                    return null;
                } else {
                    temp_lstTargetWrappers[index].contractTarget.ASI_CRM_Subbrand__c = (Id)temp_subbrandid;
                    map_subbrand_count.put(temp_subbrandid,1);
                }
                */
                
                // use sub-brand name instead of sub-brand id
                String temp_subbrandname = temp_lstTargetWrappers[index].targetSubBrandNameSelected;
				String temp_sku = temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SKU__c;
				system.debug('temp_sku');
				system.debug(temp_sku);
                if (temp_subbrandname ==null || temp_subbrandname =='') {
                    temp_lstTargetWrappers[index].contractTarget.ASI_CRM_Subbrand__c = null;
                } else 
                if (!subBrandNameMap.containsKey(temp_subbrandname.toUpperCase())){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Sub-brand '+temp_subbrandname.toUpperCase() + ' does not exist'));
                    Database.rollback(pSavepoint); 
                    return null;
                } else 
                if (map_subbrand_count.containsKey(temp_subbrandname.toUpperCase())){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Duplicated Sub-brand '+temp_subbrandname.toUpperCase()));
                    Database.rollback(pSavepoint); 
                    return null;
                } else {
                    temp_lstTargetWrappers[index].contractTarget.ASI_CRM_Subbrand__c = (Id)subBrandNameMap.get(temp_subbrandname.toUpperCase());
                    map_subbrand_count.put(temp_subbrandname.toUpperCase(),1);
                }
                /* [VL 16.0] END */
				
                if (map_sku_count.containsKey(temp_sku)){
					ASI_MFM_SKU_Code__c skuDuplicated = [SELECT Name FROM ASI_MFM_SKU_Code__c WHERE ID = : temp_sku limit 1];
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Duplicated SKU '+skuDuplicated.name));
                    Database.rollback(pSavepoint); 
                    return null;
                } else {
					map_sku_count.put(temp_sku, 1);
				}
                               
                temp_lstTargetWrappers[index].contractTarget.ASI_CRM_Sequence_No__c = index + 1;
				
				/* [VL 20.0] BEGIN */
				if (temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c != null && 
                    temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Wholesaler_Margin__c == null
                ){
					decimal price_consumerOffer = temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c;
					decimal price_PRSWS = temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
					decimal price_WSOT = temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c;
					if (price_consumerOffer < price_WSOT && price_PRSWS <= price_WSOT){
						if (price_consumerOffer <= price_PRSWS){
							temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Wholesaler_Margin__c = price_WSOT - price_PRSWS;
						} else
						if (price_consumerOffer > price_PRSWS && price_consumerOffer < price_WSOT){
							temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Wholesaler_Margin__c = price_WSOT - price_consumerOffer;
						}
					}
					/*
					if (price_consumerOffer == price_PRSWS){
						temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Wholesaler_Margin__c = price_WSOT - price_consumerOffer;
					} else 
                    if (price_consumerOffer < price_PRSWS) {
						temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SG_Wholesaler_Margin__c = price_WSOT - price_PRSWS;
					}
					*/
				}
				/* [VL 20.0] END */
				
                upsertContractTargetList.add(temp_lstTargetWrappers[index].contractTarget);
                system.debug('upsertCT');
                system.debug(temp_lstTargetWrappers[index].contractTarget);
                system.debug('index: ' + index + ' SKU: ' + temp_lstTargetWrappers[index].contractTarget.ASI_CRM_SKU__c + ' Sub-brand : ' + temp_lstTargetWrappers[index].contractTarget.ASI_CRM_Subbrand__c);
            }

            // Insert Payment Schedule objects
            List<ASI_CRM_Payment_Schedule__c> PaymentScheduleToUpsert = new List<ASI_CRM_Payment_Schedule__c>();
            
            for(ASI_CRM_Payment_Schedule__c payment: allPaymentScheduleContractMap.values()) {
                PaymentScheduleToUpsert.add(payment);
            }

            for(ASI_CRM_Payment_Schedule__c payment: allPaymentScheduleCashMap.values()) {
                PaymentScheduleToUpsert.add(payment);
            }
            
            // Aggregate all Good in Kinds and Cash from the Cash Sponsorship Tab
            Decimal contractSponsorship_Incentive = 0;
            Decimal cash = 0;
            
            for(ASI_CRM_ContractTarget__c contractTarget : upsertContractTargetList) {
                /*Decimal btlsPerCase = contractTarget.ASI_CRM_SG_Btls_Per_Case__c != null ? contractTarget.ASI_CRM_SG_Btls_Per_Case__c : 0;
                Decimal priceWsOnTrade = contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c != null ? contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c : 0;
                Decimal goodKind = contractTarget.ASI_CRM_SG_Good_in_Kinds__c != null ? contractTarget.ASI_CRM_SG_Good_in_Kinds__c : 0;*/
                Decimal incentive = contractTarget.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c != null ? contractTarget.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c : 0;
                
                //goodsInKinds += btlsPerCase*priceWsOnTrade == 0 ? 0 : goodKind/(btlsPerCase*priceWsOnTrade);
                contractSponsorship_Incentive  += incentive;
                cash += contractTarget.ASI_CRM_SG_Cash__c != null ? contractTarget.ASI_CRM_SG_Cash__c : 0;
            }
            
            //Aggregate all Free Goods Payment and Cash Sponsorship Payment Schedules
            Decimal cashSponsorTotal = 0;
            Decimal freeGoodsCaseTotal = 0;
            
            for(ASI_CRM_Payment_Schedule__c paymentSched : PaymentScheduleToUpsert) {
        
                if(paymentSched.ASI_CRM_Type__c == 'Cash Sponsorship') {
                    cashSponsorTotal += paymentSched.ASI_CRM_Sponsorship__c != null ? paymentSched.ASI_CRM_Sponsorship__c : 0;
                }
                if(paymentSched.ASI_CRM_Type__c == 'Contract Sponsorship') {
                
                    freeGoodsCaseTotal += paymentSched.ASI_CRM_Sponsorship__c != null ? paymentSched.ASI_CRM_Sponsorship__c : 0;
                }
            }
            
            if(cashSponsorTotal > cash) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Total Cash Sponsorship (S$) in Payment Schedule cannot exceed the Total Cash Sponsorship(S$) in Contract Target'));
                Database.rollback(pSavepoint); 
                return null;
            }
            
            if(freeGoodsCaseTotal > contractSponsorship_Incentive) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Total Free Goods (Act Case) in Payment Schedule cannot exceed the total Contract Sponsorship Target Incentive in Contract Target'));
                Database.rollback(pSavepoint); 
                return null;
            }
            
            if(upsertContractTargetList.size()>0)
                upsertContractTarget = Database.upsert(upsertContractTargetList);
                             
            if (PaymentScheduleToUpsert.size() > 0) {
                upsert PaymentScheduleToUpsert;
            }
            if (paymentScheduleToDelete.size() > 0) {
                delete paymentScheduleToDelete;
                paymentScheduleToDelete.clear();
            }
            
            if(allContractOutletSelectedMap.size() > 0) {
                upsert allContractOutletSelectedMap.values();
            }
            
            if (ContractOutletToDelete.size() > 0) {
                delete ContractOutletToDelete;
                ContractOutletToDelete.clear();
            }
            
            } catch (DMLException ex){
                Database.rollback(pSavepoint);
                String errorMessage = ex.getMessage();
                Integer occurence;
                if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    /* [VL 9.0] BEGIN */
                    /*
                    occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
                    errorMessage = errorMessage.mid(occurence, errorMessage.length());
                    occurence = errorMessage.indexOf(': []');
                    errorMessage = errorMessage.mid(0, occurence);
                    */
                    errorMessage = ex.getdmlMessage(0);
                    /* [VL 9.0] END */
                }
                else {
                    errorMessage = ex.getMessage();
                }

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                /* [VL 9.0] BEGIN */
                return null;
                /* [VL 9.0] END */
            }
        
        if (!isQuickSave){
            pageRef = new PageReference('/'+contractObj.Id);
            pageRef.setRedirect(true);
        } 
        //allContractTargetMap = retrieveContractTarget(contractObj);
        /* [HC 2.0] BEGIN */
        setSubBrandSelectOptions();
        /* [HC 2.0] END */

        return pageRef;
    } 
    
    public void addContractProductItem(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID');

        System.debug('param_contractSourceItemId ' + param_contractSourceItemId + ' subBrandSelected:' + subBrandSelected + ' subBrandMap size: ' + subBrandMap.size());

        String targetSubBrand = '';
        boolean isSubBrand = false;
        String param_contractSourceItemType = params.get('PARAM_CONTRACT_SOURCE_ITEM_TYPE');
        if(param_contractSourceItemType != null) {
            if(param_contractSourceItemType.equals('isSubBrand')) {
                isSubBrand = true;
                targetSubBrand = subBrandSelected;
                param_contractSourceItemId = (String)(subBrandMap.get(targetSubBrand).ASI_CRM_Representative_SKU__c);
            }
        }

        System.debug('param_contractSourceItemId ' + param_contractSourceItemId + ' isSubBrand: ' + isSubBrand);
        System.debug('targetSubBrand ' + targetSubBrand);
        System.debug('contractID ' + contractObj.id);
        
        Map<string, ASI_CRM_MY_SKUPriceCost__c> skuTempHistoricCost = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();
        
        if(allSKUMap.containsKey(param_contractSourceItemId) || (isSubBrand && targetSubBrand != null && param_contractSourceItemId != null)){
            System.debug('Inside allSKUMap************** ');
            // Check if theres any valid SKU historic cost
            if(allSKUHistoricMap.containsKey((ID)param_contractSourceItemId)) {
                skuTempHistoricCost = allSKUHistoricMap.get((ID)param_contractSourceItemId);
            }
            
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWS = skuTempHistoricCost.get('ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'); //ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler 
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWSOnTrade = skuTempHistoricCost.get('ASI_CRM_SG_Open_Outlet_Price_Per_Bottle');// ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostIGC = skuTempHistoricCost.get('ASI_CRM_SG_IGC');
            /* [VL 7.2] BEGIN */
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostDuty = skuTempHistoricCost.get('ASI_CRM_SG_CRM_Duty_Per_Bottle');
            /* [VL 7.2] END */
            /* [DC 8.1] BEGIN */
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostFob = skuTempHistoricCost.get('ASI_CRM_SG_CRM_FOB_Per_Bottle');
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostHandlingCost = skuTempHistoricCost.get('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle');
            /* [DC 8.1] END */
			/* [VL 24.0] BEGIN */
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWSRTM = skuTempHistoricCost.get('ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle');
            ASI_CRM_MY_SKUPriceCost__c skuHistoricCostOTRTM = skuTempHistoricCost.get('ASI_CRM_SG_Open_Outlet_Price_Per_Bottle');
			/* [VL 24.0] END */
            
            if(skuHistoricCostWS != null) {
                if(contractObj.ASI_CRM_CN_Effective_Date__c > skuHistoricCostWS.ASI_CRM_EffectiveDate__c) {
                    skuHistoricCostWS = null;
                }
            }
            
            if(skuHistoricCostWSOnTrade != null) {
                if(contractObj.ASI_CRM_CN_Effective_Date__c > skuHistoricCostWSOnTrade.ASI_CRM_EffectiveDate__c) {
                    skuHistoricCostWSOnTrade = null;
                }
            }
            
            if(skuHistoricCostIGC != null) {
                if(contractObj.ASI_CRM_CN_Effective_Date__c > skuHistoricCostIGC.ASI_CRM_EffectiveDate__c) {
                    skuHistoricCostIGC = null;
                }
            }
            
            /* [VL 7.2] BEGIN */
            if(skuHistoricCostDuty != null) {
                if(contractObj.ASI_CRM_CN_Effective_Date__c > skuHistoricCostDuty.ASI_CRM_EffectiveDate__c) {
                    skuHistoricCostDuty = null;
                }
            }
            /* [VL 7.2] END */

            /* [DC 8.1] BEGIN */
            if(skuHistoricCostFob != null) {
                if(contractObj.ASI_CRM_CN_Effective_Date__c > skuHistoricCostFob.ASI_CRM_EffectiveDate__c) {
                    skuHistoricCostFob = null;
                }
            }

            if(skuHistoricCostHandlingCost != null) {
                if(contractObj.ASI_CRM_CN_Effective_Date__c > skuHistoricCostHandlingCost.ASI_CRM_EffectiveDate__c) {
                    skuHistoricCostHandlingCost = null;
                }
            }
            /* [DC 8.1] END */
            
            ASI_MFM_SKU_Code__c skuTemp = isSubBrand ? [SELECT ID, Name, ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c,
                                                        ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c, ASI_CRM_SG_IGC_Cost_Per_case__c,
                                                        ASI_CRM_SG_IGC_Cost_Per_9Lc__c, ASI_HK_CRM_Packaging_Size__c, ASI_HK_CRM_Std_Bottle_Size__c 
                                                        FROM ASI_MFM_SKU_Code__c
                                                        WHERE ID = : ((ID)param_contractSourceItemId)].get(0) :
                                                        allSKUMap.get(param_contractSourceItemId);
            
            // Fix the ordering in the VF Page
            string newIDCounter = newCounterCreatorContractLine();

            contractTargetWrapper contTargWrap = new contractTargetWrapper(new ASI_CRM_ContractTarget__c(
                    ASI_CRM_Contract__c = contractObj.id,
                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target'),
                    ASI_CRM_SKU__c = (!isSubBrand ? param_contractSourceItemId : null),
                    //ASI_CRM_SG_FOC_Calculation__c = '--None--',
                    ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c = (skuHistoricCostWS != null ? skuHistoricCostWS.ASI_CRM_Price__c : skuTemp.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c),
                    ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c = (skuHistoricCostWSOnTrade != null ? skuHistoricCostWSOnTrade.ASI_CRM_Price__c : skuTemp.ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c) ,
                    ASI_CRM_SG_IGC_Cost_Per_case__c = (skuHistoricCostIGC != null ? skuHistoricCostIGC.ASI_CRM_Cost__c : skuTemp.ASI_CRM_SG_IGC_Cost_Per_case__c),
                    /* [VL 7.2] BEGIN */
                    ASI_CRM_Duty_Per_Bottle__c = (skuHistoricCostDuty != null ? skuHistoricCostDuty.ASI_CRM_Cost__c : 0),
                    /* [VL 7.2] END */
                    /* [DC 8.1] BEGIN */
                    ASI_CRM_FOB_Per_Bottle__c = (skuHistoricCostFob != null ? skuHistoricCostFob.ASI_CRM_Cost__c : 0),
                    ASI_CRM_Handling_Cost_Per_Bottle__c = (skuHistoricCostHandlingCost != null ? skuHistoricCostHandlingCost.ASI_CRM_Cost__c : 0),
                    /* [DC 8.1] END */
					/* [VL 24.0] BEGIN */
                    ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c = (skuHistoricCostWSRTM != null ? skuHistoricCostWSRTM.ASI_CRM_Price__c : null),
                    ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c = (skuHistoricCostOTRTM != null ? skuHistoricCostOTRTM.ASI_CRM_Price__c : null),
					/* [VL 24.0] END */
                    ASI_CRM_SG_IGC_Cost_Per_9Lc__c = (skuHistoricCostIGC != null ? skuHistoricCostIGC.ASI_CRM_SG_IGC_Cost_Per_9Lc__c : skuTemp.ASI_CRM_SG_IGC_Cost_Per_9Lc__c),
                    ASI_CRM_SG_Btls_Per_Case__c = skutemp.ASI_HK_CRM_Packaging_Size__c,
                    ASI_CRM_SG_Size_cl__c = skutemp.ASI_HK_CRM_Std_Bottle_Size__c 
					/* [VL 18.0] BEGIN */
					//, ASI_CRM_SG_Wholesaler_Margin__c = (skuHistoricCostWSOnTrade != null ? skuHistoricCostWSOnTrade.ASI_CRM_Price__c : skuTemp.ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c) - (skuHistoricCostWS != null ? skuHistoricCostWS.ASI_CRM_Price__c : skuTemp.ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c)
					/* [VL 18.0] END */
                ), SubBrandSelectOptions);

            if(isSubBrand) {
                contTargWrap.targetSubBrandSelected = targetSubBrand;
                contTargWrap.contractTarget.ASI_CRM_Subbrand__c = (ID)targetSubBrand;
            }

            allContractTargetMap.put(CONTRACT_LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, contTargWrap);
			
			existingSKU.add((ID)param_contractSourceItemId);

            addedSKUMap.put(param_contractSourceItemId, allSKUMap.get(param_contractSourceItemId));
            allSKUMap.remove(param_contractSourceItemId);
        }
        
        
       
        //return pageRef;
    }
    
    public void removeContractSKU(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractId = params.get('PARAM_CONTRACT_ID');
        String param_contractSKUId = params.get('PARAM_CONTRACT_SKU_ID');
        boolean isSKURep = false;
        String param_contractSubBrandId = params.get('PARAM_CONTRACT_SUBBRAND_ID');
        try{

            if(param_contractSKUId == null || param_contractSKUId == '') {
                param_contractSKUId = (String)(subBrandMap.get(param_contractSubBrandId).ASI_CRM_Representative_SKU__c);
            }
            
            if(allContractTargetMap.containsKey(param_contractId)){
                ASI_CRM_ContractTarget__c delContractTarget = allContractTargetMap.get(param_contractId).contractTarget;
                if(delContractTarget.ASI_CRM_SKU__c == null) {
                    isSKURep = true;
                }
                if(delContractTarget.id != null){
                    deleteContractTargetList.add(delContractTarget);
                }
                else if(!isSKURep){
                    allSKUMap.put(param_contractSKUId, addedSKUMap.get(param_contractSKUId));
                    addedSKUMap.remove(param_contractSKUId);
                }
                allContractTargetMap.remove(param_contractId);
				
				existingSKU.remove((ID)param_contractSKUId);

            }
        } catch (exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'param_contractSubBrandId ' + param_contractSubBrandId));
            //system.debug('param_contractSubBrandId ' + param_contractSubBrandId);
        }
        
        
        //return pageRef;
    }

    public void updateSubBrandPick() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String subBrandChoice = params.get('subBrandChoice');
        String cpiKey = params.get('cpiKey');

        if(allContractTargetMap.containsKey(cpiKey)){
            contractTargetWrapper contractTargetWrap = allContractTargetMap.get(cpiKey);
            contractTargetWrap.targetSubBrandSelected = subBrandChoice;
        }
    }
    
    public void addCashSponsorship() {
        string newIDCounter = newCounterCreator();
        ASI_CRM_Payment_Schedule__c newCashSponsorship = new ASI_CRM_Payment_Schedule__c
                                (
                                     name=contractObj.name+'_Cash_'+newIDCounter,
                                     ASI_CRM_Contract__c = contractObj.id,
                                     recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'),
                                     ASI_CRM_Type__c = 'Cash Sponsorship'
                                     
                                );
        allPaymentScheduleCashMap.put(PAYMENTSCHEDULE_ITEM_NEWRECORD_PREFIX+newIDCounter, newCashSponsorship);
    }
    
    public void removeCashSponsorship() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_paymentScheduleID = params.get('PARAM_PAYMENT_ID');
    
        if (allPaymentScheduleCashMap.containsKey(param_paymentScheduleID)) {
            ASI_CRM_Payment_Schedule__c paymentSchedule = allPaymentScheduleCashMap.get(param_paymentScheduleID);
            allPaymentScheduleCashMap.remove(param_paymentScheduleID);
            if(!param_paymentScheduleID.contains(PAYMENTSCHEDULE_ITEM_NEWRECORD_PREFIX)) {
                paymentScheduleToDelete.add(paymentSchedule);
            }
        }
    }
    
    public void addContractSponsorship() {
        string newIDCounter = newCounterCreator();
        ASI_CRM_Payment_Schedule__c newContractSponsorship = new ASI_CRM_Payment_Schedule__c
                                (
                                     name=contractObj.name+'_Contract_'+newIDCounter,
                                     ASI_CRM_Contract__c = contractObj.id,
                                     recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'),
                                     ASI_CRM_Type__c = 'Contract Sponsorship'
                                     
                                );
        allPaymentScheduleContractMap.put(PAYMENTSCHEDULE_ITEM_NEWRECORD_PREFIX+newIDCounter, newContractSponsorship);
    }
    
    public void addContractOutlet() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID');
        
        if(allContractOutletMap.containsKey(param_contractSourceItemId)){
            ASI_CRM_AccountsAdditionalField__c customerTemp = allContractOutletMap.get(param_contractSourceItemId);
            
            allContractOutletSelectedMap.put(param_contractSourceItemId, new ASI_CRM_Contract_Outlets__c(
                                                                            ASI_CRM_SG_Contract__c = contractObj.id,
                                                                            ASI_CRM_SG_Customer__c = customerTemp.id,
                                                                            recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__cASI_CRM_SG_Contract_Outlet')));
                                                                            
            addedContractOutletMap.put(param_contractSourceItemId, allContractOutletMap.get(param_contractSourceItemId));
            allContractOutletMap.remove(param_contractSourceItemId);
            
                                                                            
        }
        
    }
    
    public void removeContractOutlet() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_contractCUSTOMERId = params.get('PARAM_CONTRACT_CUSTOMER_ID');
        
        if(allContractOutletSelectedMap.containsKey(param_contractCUSTOMERId)){
            ASI_CRM_Contract_Outlets__c delcontractOutlet = allContractOutletSelectedMap.get(param_contractCUSTOMERId);
            if(delcontractOutlet.id != null){
                ContractOutletToDelete.add(delcontractOutlet);
                allContractOutletMap.put(param_contractCUSTOMERId, addedContractOutletMap.get(param_contractCUSTOMERId));
                addedContractOutletMap.remove(param_contractCUSTOMERId);
            }
            else{
                allContractOutletMap.put(param_contractCUSTOMERId, addedContractOutletMap.get(param_contractCUSTOMERId));
                addedContractOutletMap.remove(param_contractCUSTOMERId);
            }
            allContractOutletSelectedMap.remove(param_contractCUSTOMERId);
        }
    }
            
    public void removeContractSponsorship() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_paymentScheduleID = params.get('PARAM_PAYMENT_ID');
    
        if (allPaymentScheduleContractMap.containsKey(param_paymentScheduleID)) {
            ASI_CRM_Payment_Schedule__c paymentSchedule = allPaymentScheduleContractMap.get(param_paymentScheduleID);
            allPaymentScheduleContractMap.remove(param_paymentScheduleID);
            if(!param_paymentScheduleID.contains(PAYMENTSCHEDULE_ITEM_NEWRECORD_PREFIX)) {
                paymentScheduleToDelete.add(paymentSchedule);
            }
        }
    }
    
    public List<SelectOption> getCategorySelectOptions(){
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('',''));
        
        for(ASI_HK_CRM_Product_Category__c sb : [SELECT Id, Name FROM ASI_HK_CRM_Product_Category__c WHERE recordtype.developername = 'ASI_SG_CRM_Product_Category' ORDER BY name]){
            result.add(new SelectOption(sb.id, sb.name));
        }
        return result;
    }
            
    public String newCounterCreator() {
    
        String idNew;
        IF(PAYMENTSCHEDULE_ITEM_NEWRECORD_COUNTER == null) {
            PAYMENTSCHEDULE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            PAYMENTSCHEDULE_ITEM_NEWRECORD_COUNTER+=1;
        }
        
        String zParser = '';
        Integer oneDigitCounter = PAYMENTSCHEDULE_ITEM_NEWRECORD_COUNTER;
        
        if(PAYMENTSCHEDULE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = PAYMENTSCHEDULE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(PAYMENTSCHEDULE_ITEM_NEWRECORD_COUNTER, 10);
        }
        
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
        
    }
    
    public void setSubBrandSelectOptions() 
    {
        subBrandMap = new Map<String, ASI_MFM_Sub_Brand__c>();
        subBrandNameMap = new Map<String, String>();
        subBrandNameList = new List<String>();

        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('',''));
            
        String query = 'SELECT Id, Name, ASI_CRM_Representative_SKU__c FROM ASI_MFM_Sub_Brand__c WHERE recordtype.developername = \'ASI_CRM_SG_Sub_brand\' ';
            
        query += ' ORDER BY name ';
            
        List<ASI_MFM_Sub_Brand__c> subBrandQuery = (List<ASI_MFM_Sub_Brand__c>)Database.query(query); 
        
        for(ASI_MFM_Sub_Brand__c sb : subBrandQuery){
            result.add(new SelectOption(sb.id, sb.name));
            subBrandMap.put((String)sb.id, sb);
            subBrandNameMap.put(sb.name.toUpperCase(), (String)sb.id);
            subBrandNameList.add(sb.name);
            System.debug('*******subBrand Map ' + (String)sb.id);
        }
        SubBrandSelectOptions = result;
        setContractTargetWrapper_SubBrand();
    }

    public void setContractTargetWrapper_SubBrand() {
        for(contractTargetWrapper contractLine : allContractTargetMap.values()) {
            contractLine.subBrandSelectOption = SubBrandSelectOptions;
        }
    }
        
    public PageReference cancel() {
        Pagereference ref;
        ref = new PageReference('/'+contractObj.Id);
        ref.setRedirect(true);
        return ref;
    }

    /*********************************
    Contract Target Wrapper
    *********************************/
    global class contractTargetWrapper /*implements Comparable*/ {
        public ASI_CRM_ContractTarget__c contractTarget {get;set;}
        public List<SelectOption> subBrandSelectOption {get;set;}
        public String targetSubBrandSelected {get;set;}
        public String targetSubBrandNameSelected {get;set;}
        public Id finalSubBrand;

        public contractTargetWrapper (ASI_CRM_ContractTarget__c contractLine, List<SelectOption> subBrandSelectOptionP) {
            this.subBrandSelectOption = subBrandSelectOptionP;
            this.contractTarget = contractLine;
            this.targetSubBrandSelected = (String)contractLine.ASI_CRM_Subbrand__c;
            this.targetSubBrandNameSelected = (String)contractLine.ASI_CRM_Subbrand__r.name;
            this.finalSubBrand = String.isNotBlank(this.targetSubBrandSelected) ? this.targetSubBrandSelected : contractLine.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
        }

        /*global Integer compareTo(Object compareTo) {
            contractTargetWrapper compareToContractTarget = (contractTargetWrapper)compareTo;
            if(this.contractTarget.ASI_CRM_Sequence_No__c > compareToContractTarget.contractTarget.ASI_CRM_Sequence_No__c) {
                return 1;
            } else if(this.contractTarget.ASI_CRM_Sequence_No__c > compareToContractTarget.contractTarget.ASI_CRM_Sequence_No__c) {
                return -1;
            } else if(this.contractTarget.ASI_CRM_Sequence_No__c == compareToContractTarget.contractTarget.ASI_CRM_Sequence_No__c) {
                if(String.isNotBlank(this.contractTarget.ASI_CRM_SKU__r.name) 
                && String.isNotBlank(compareToContractTarget.contractTarget.ASI_CRM_SKU__r.name)) {
                    if(this.contractTarget.ASI_CRM_SKU__r.name.toLowerCase()
                       .compareTo(compareToContractTarget.contractTarget.ASI_CRM_SKU__r.name.toLowerCase()) > 0) {
                        return 1;
                    } else if(this.contractTarget.ASI_CRM_SKU__r.name.toLowerCase()
                              .compareTo(compareToContractTarget.contractTarget.ASI_CRM_SKU__r.name.toLowerCase()) < 0) {
                        return -1;
                    }
                }
            }
            return 0;
        }*/
    }
    
    public String newCounterCreatorContractLine() {

        String idNew;
        IF(CONTRACT_LINE_ITEM_NEWRECORD_COUNTER == null) {
            CONTRACT_LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            CONTRACT_LINE_ITEM_NEWRECORD_COUNTER+=1;
        }
    
        String zParser = '';
        Integer oneDigitCounter = CONTRACT_LINE_ITEM_NEWRECORD_COUNTER;
    
        if(CONTRACT_LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = CONTRACT_LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(CONTRACT_LINE_ITEM_NEWRECORD_COUNTER, 10);
        }
    
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
    
    }

    /* [DC 8.3] BEGIN */
    private List<contractTargetWrapper> sortContractTargets(List<contractTargetWrapper> pLstContractTargets) {
        
        if(pLstContractTargets != NULL && !pLstContractTargets.isEmpty()) {
        
            contractTargetWrapper swapVar;
            // iterating over list for finding smallest next element.
            for (Integer outerIndex = 0; outerIndex < pLstContractTargets.size(); outerIndex++) {

                // initializing swap variable to avoid possible bugs.
                swapVar = new contractTargetWrapper(new ASI_CRM_ContractTarget__c(), NULL);

                // iterating over list and comparing current element to each next element.
                for (Integer innerIndex = 0; innerIndex < pLstContractTargets.size() - outerIndex - 1; innerIndex++) {

                    // comparing sequence number of current element with the next elements in the list.
                    // if found greater than next elements, swap the places.

                    // Setting sequence number to 0 if it is blank.
                    if(pLstContractTargets[innerIndex].contractTarget.ASI_CRM_Sequence_No__c == NULL) {
                        pLstContractTargets[innerIndex].contractTarget.ASI_CRM_Sequence_No__c = 0;
                    }

                    if(pLstContractTargets[innerIndex + 1].contractTarget.ASI_CRM_Sequence_No__c == NULL) {
                        pLstContractTargets[innerIndex + 1].contractTarget.ASI_CRM_Sequence_No__c = 0;
                    }

                    if (pLstContractTargets[innerIndex].contractTarget.ASI_CRM_Sequence_No__c >     /* For descending order use < */
                        pLstContractTargets[innerIndex + 1].contractTarget.ASI_CRM_Sequence_No__c) {

                        // Swapping the element positions if found smaller.
                        swapVar = pLstContractTargets[innerIndex];
                        pLstContractTargets[innerIndex] = pLstContractTargets[innerIndex + 1];
                        pLstContractTargets[innerIndex + 1] = swapVar;
                    
                    }

                    // if sequence numbers are equal, compare SKU.Name of current element with the next elements in the list.
                    // if found greater than next elements, swap the places.
                    else if(pLstContractTargets[innerIndex].contractTarget.ASI_CRM_Sequence_No__c ==
                        pLstContractTargets[innerIndex + 1].contractTarget.ASI_CRM_Sequence_No__c) {
                        
                        // DC - 02/18/2016 - Added null check for the SKU lookup & SKU Name to avoid null-pointer exception.
                        if(String.isNotBlank(pLstContractTargets[innerIndex].contractTarget.ASI_CRM_SKU__c)
                        && String.isNotBlank(pLstContractTargets[innerIndex + 1].contractTarget.ASI_CRM_SKU__c)
                        && String.isNotBlank(pLstContractTargets[innerIndex].contractTarget.ASI_CRM_SKU__r.Name)
                        && String.isNotBlank(pLstContractTargets[innerIndex + 1].contractTarget.ASI_CRM_SKU__r.Name)) {

                            if(pLstContractTargets[innerIndex].contractTarget.ASI_CRM_SKU__r.Name.toLowerCase()
                                .compareTo(pLstContractTargets[innerIndex + 1].contractTarget.ASI_CRM_SKU__r.Name.toLowerCase()) > 0) {
                                
                                // Swapping the element positions if found smaller.
                                swapVar = pLstContractTargets[innerIndex];
                                pLstContractTargets[innerIndex] = pLstContractTargets[innerIndex + 1];
                                pLstContractTargets[innerIndex + 1] = swapVar;

                            }
                        }
                    }
                }
            }        
        }
        return pLstContractTargets;
    }


    /* [DC 10.0] */
    public void requestPayment() {

        REQUESTEDPAYMENTID = '';
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> lstPaymentRequestLines =
            new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

        paymentScheduleId = ApexPages.currentPage().getParameters().get('scheduleId');
        prevPaymentScheduleId = ApexPages.currentPage().getParameters().get('prevScheduleId');
        System.debug('------ paymentScheduleId ------ : ' + paymentScheduleId);
        System.debug('------ prevPaymentScheduleId ------ : ' + prevPaymentScheduleId);

        ASI_CRM_Payment_Schedule__c currentPaymentSchedule, prevPaymentSchedule;
        Decimal currentAchieved = 0.0, previousAchieved = 0.0, finalAchieved = 0.0;
        
        if(String.isNotBlank(paymentScheduleId)) {
            currentPaymentSchedule = allPaymentScheduleCashMap.get((Id)paymentScheduleId);
            currentAchieved = (currentPaymentSchedule == NULL || currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c == NULL) ? 0.0 : Decimal.valueOf(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c);
        }
        
        if(String.isNotBlank(prevPaymentScheduleId) && !prevPaymentScheduleId.equalsIgnoreCase('NULL')) {
            prevPaymentSchedule = allPaymentScheduleCashMap.get((Id)prevPaymentScheduleId);
            previousAchieved = (prevPaymentSchedule == NULL || prevPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c == NULL) ? 0.0 : Decimal.valueOf(prevPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c);
        }

        finalAchieved = currentAchieved - previousAchieved;

        Map<Id, Decimal> mapSubBrandId_CalculatedAmount;
        Boolean isZeroAchieved = false;
        Decimal paymentScheduleAmount = currentPaymentSchedule.ASI_CRM_Sponsorship__c != null ? currentPaymentSchedule.ASI_CRM_Sponsorship__c : 0;

        if(currentPaymentSchedule.ASI_CRM_Schedule_Date__c != NULL) {

            mapSubBrandId_CalculatedAmount = calculateAmountWithDate(paymentScheduleAmount);

        } 
        /* [HC 1.0] BEGIN */ 
        else if(String.isNotBlank(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c) && currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c.equals('0')) {

            mapSubBrandId_CalculatedAmount = calculateAmountsForZeroAchieved(paymentScheduleAmount);
            isZeroAchieved = true;

        } 
        /* [HC 1.0] END */ 
        else if(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c != NULL) {

            /* [VL 15.0] BEGIN */
            /*
            mapSubBrandId_CalculatedAmount = calculateAmountsForLines(finalAchieved);
            */
            mapSubBrandId_CalculatedAmount = calculateAmountsForLines(paymentScheduleAmount);
            /* [VL 15.0] END */

        }

        System.debug('------ mapSubBrandId_CalculatedAmount ------ : ' + mapSubBrandId_CalculatedAmount);

        System.Savepoint preRecordCreationState = Database.setSavepoint();
        try {
            // Formatting date
            Datetime dateInstance = Datetime.newInstance(
                Date.today().year(),
                Date.today().month(),
                Date.today().day());

            String formattedDate = dateInstance.format('YYYYMMdd', UserInfo.getTimeZone().getID());

            // Payment Request Record Creation
            paymentRequestInstance = new ASI_TH_CRM_PaymentRequest__c(
                RecordTypeId = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c.getRecordTypeInfosByName()
                                                 .get('ASI CRM SG Payment Request').getRecordTypeId(),
                OwnerId = UserInfo.getUserId(),
                /* [VL 11.0] BEGIN */
                ASI_TH_CRM_Contract__c = contractObj.id,
                /* [VL 11.0] END */
                ASI_CRM_CN_OutletWS__c = contractObj.ASI_CRM_CN_Outlet_WS__c,
                ASI_TH_CRM_Status__c = 'Draft',
                ASI_TH_CRM_GL_Date__c = Date.today(),
				/* [VL 21.0] BEGIN */
				/*
                ASI_CRM_SG_Invoice_Date__c = Date.today(),
				*/
				/* [VL 21.0] END */
                /* [VL 13.0] BEGIN */
                /*
                ASI_CRM_SG_Invoice_No__c = contractObj.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c
                                         + formattedDate,
                */
                ASI_CRM_SG_Invoice_No__c = contractObj.name + '-' + formattedDate,
                /* [VL 13.0] END */
                /* [VL 13.1] BEGIN */
                /*
                ASI_CRM_CN_Description__c = 'Pymt upon '
                                          + allPaymentScheduleCashMap.get(paymentScheduleId).ASI_CRM_Percentof_achieved_Sales_Target__c
                                          + '% sales achieved'
                */
                ASI_CRM_CN_Description__c = currentPaymentSchedule.ASI_CRM_Schedule_Date__c != NULL ? 
                                        (
                                            'Pymt upon '
                                          + currentPaymentSchedule.ASI_CRM_Schedule_Date__c.format()
                                        ) : ( 
                                            currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c == '0' ? 
                                            'Upfront Payment Upon Signing' : 
											/* [VL 19.0] BEGIN */
											/*
                                            (
                                                'Pymt upon '
                                              + currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c
                                              + '% sales achieved'
                                            )
											*/
                                            (
												/* [VL 23.0] BEGIN */
												/*
                                                Integer.valueOf(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c) == 101 ? 
												*/
                                                Decimal.valueOf(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c) == 101 ? 
												/* [VL 23.0] END */
												'Pymt upon timely completion' :
												(
													'Pymt upon '
												  + currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c
												  + '% sales achieved'
												)
                                            )
											/* [VL 19.0] END */
                                        ),
				ASI_CRM_Achievement__c = currentPaymentSchedule.ASI_CRM_Schedule_Date__c != NULL ? 
                                        (
                                            null
                                        ) : ( 
                                            decimal.valueOf(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c)
                                        ),
                ASI_CRM_System_Generated__c = true
                /* [VL 13.1] END */
            );

            /*
            // Inserted the payment request
            insert paymentRequestInstance;
            System.debug('------ paymentRequestInstance.Id ------ : ' + paymentRequestInstance.Id);
            [DC 11.0] BEGIN 
            ApexPages.currentPage().getParameters().put('pymtReqId', paymentRequestInstance.Id);
            [DC 11.0] END */ 

            //insert paymentRequestInstance;

            Integer counter = 0;
			Decimal lineItemAmountTotal = 0;
            
            Map<ASI_TH_CRM_PaymentRequestLineItem__c, ID> map_line_contractID = new Map<ASI_TH_CRM_PaymentRequestLineItem__c, ID>();

            for(Id subBrandId : mapSubBrandId_CalculatedAmount.keySet()) {
                if(mapSubBrandId_CalculatedAmount.get(subBrandId) > 0.0) {
                    counter++;
                    ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                            RecordTypeId = Schema.SObjectType.ASI_TH_CRM_PaymentRequestLineItem__c.getRecordTypeInfosByName()
                                                 .get('ASI CRM SG Payment Request Detail').getRecordTypeId(),
                            ASI_CRM_SG_Sub_brand__c = subBrandId,
                            /* [HC 1.0] BEGIN */ 
                            ASI_CRM_SG_Type__c = isZeroAchieved ? REQUEST_Line_TYPE_UPFRONT : REQUEST_LINE_TYPE,
                            /* [HC 1.0] END */ 
							/* [WL 17.0] BEGIN */
                            ASI_TH_CRM_Amount__c = mapSubBrandId_CalculatedAmount.get(subBrandId).setScale(2),
							/* [WL 17.0] END */
                            ASI_TH_CRM_Payment_Request__c = paymentRequestInstance.id
                        );
					lineItemAmountTotal += mapSubBrandId_CalculatedAmount.get(subBrandId).setScale(2);
                    lstPaymentRequestLines.add(paymentLine);
                    map_line_contractID.put(paymentLine, contractObj.id);
                }
            }

			/* [WL 17.0] BEGIN */
			system.debug('Payment Schedule Amount: ' + paymentScheduleAmount + ' Payment Request Amount: ' + lineItemAmountTotal);
			if (paymentScheduleAmount <> lineItemAmountTotal && lstPaymentRequestLines.size() > 0){
				lstPaymentRequestLines.get(0).ASI_TH_CRM_Amount__c += paymentScheduleAmount - lineItemAmountTotal;
			}
			/* [WL 17.0] END */
			
            system.debug('paymentRequestInstance: '+paymentRequestInstance);
            system.debug('lstPaymentRequestLines: '+lstPaymentRequestLines);

            ASI_CRM_SG_Payment_ValidationHelper_V2 validator = 
                new ASI_CRM_SG_Payment_ValidationHelper_V2(true, paymentRequestInstance, lstPaymentRequestLines, map_line_contractID);

            String validateAmount = validator.validateAmountExceed();

            if(String.isNotBlank(validateAmount)) {
                //delete paymentRequestInstance;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, validateAmount));
                REQUESTEDPAYMENTID = '';
                return;
            }

            insert paymentRequestInstance;
            ApexPages.currentPage().getParameters().put('pymtReqId', paymentRequestInstance.Id);

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineIterator : lstPaymentRequestLines) {
                lineIterator.ASI_TH_CRM_Payment_Request__c = paymentRequestInstance.Id;
            }

            insert lstPaymentRequestLines;

            ASI_CRM_Payment_Schedule__c scheduleInstance = new ASI_CRM_Payment_Schedule__c(
                Id = paymentScheduleId,
                ASI_CRM_Payment_Issued__c = true
            );

            update scheduleInstance;

			/*[WL 22.0] BEGIN*/
			Attachment[] attList = [select id, name, body from Attachment where ParentId = :contractObj.id];
			Attachment[] insertAttList = new Attachment[]{}; 

			for(Attachment a: attList){
               Attachment att = new Attachment(name = a.name, body = a.body, parentid = paymentRequestInstance.id);
               insertAttList.add(att);
			}
			
			if(insertAttList.size() > 0){
				insert insertAttList;
			}					
			/*[WL 22.0] BEGIN*/
			
            /* [DC 11.0] BEGIN */
            /*pageRef = new PageReference('/' + paymentRequestInstance.Id);
            pageRef.setRedirect(true);*/
            /* [DC 11.0] END */

            REQUESTEDPAYMENTID = paymentRequestInstance.Id;

        } catch(Exception exceptionInstance) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, exceptionInstance.getMessage()));

            if(preRecordCreationState != NULL) {
                Database.rollback(preRecordCreationState);
            }
        }

    }

    Map<Id, Decimal> calculateAmountsForLines(Decimal pFinalAchieved) {

        system.debug('--- calculateAmountsForLines ---');
        system.debug('--- pFinalAchieved ---' + pFinalAchieved);
        system.debug('--- mapSubBrandId_CotractTargetCash ---' + mapSubBrandId_CotractTargetCash);
        system.debug('--- sponsorshipWithScheduleDate ---' + sponsorshipWithScheduleDate);
        system.debug('--- sponsorshipWithZeroAchieved ---' + sponsorshipWithZeroAchieved); 
        system.debug('--- mapSubBrandId_WeightPercent ---' + mapSubBrandId_WeightPercent);
        
        Map<Id, Decimal> mapSubBrandId_CalculatedAmount = new Map<Id, Decimal>();

        for(Id subBrandId : mapSubBrandId_CotractTargetCash.keySet()) {
            mapSubBrandId_CalculatedAmount.put(
                subBrandId,
                (
                    /* [VL 15.0] BEGIN */
                    /* Original logic: total amount in this payment = (Total Cash Sponsorship * achieved %) - (sum of 0% and target date payment)
                    (
                        mapSubBrandId_CotractTargetCash.get(subBrandId) - 
                        (
                            sponsorshipWithScheduleDate *
                            mapSubBrandId_WeightPercent.get(subBrandId)
                            // [VL 12.2] BEGIN 
                            / 100
                            // [VL 12.2] END 
                            
                        )
                        // [HC 1.0] BEGIN  
                        - (
                            sponsorshipWithZeroAchieved * 
                            mapSubBrandId_WeightPercent.get(subBrandId)
                            / 100
                        )
                        // [HC 1.0] END  
                    ) * (
                            pFinalAchieved
                            // [VL 12.2] BEGIN 
                            / 100
                            // [VL 12.2] END 
                    )
                    */
                    // new logic, directly use the amount input in the payment schedule line
                    pFinalAchieved * mapSubBrandId_WeightPercent.get(subBrandId) / 100
                    /* [VL 15.0] END */
                ) 
            );
        }
        return mapSubBrandId_CalculatedAmount;
    }

    /* [HC 1.0] BEGIN */ 
    private Map<Id, Decimal> calculateAmountsForZeroAchieved(Decimal pSponsorship) {

        Map<Id, Decimal> mapSubBrandId_CalculatedAmount = new Map<Id, Decimal>();

        for(Id subBrandId : mapSubBrandId_WeightPercent.keySet()) {
            mapSubBrandId_CalculatedAmount.put(
                subBrandId,
                pSponsorship * mapSubBrandId_WeightPercent.get(subBrandId)
                /* [VL 12.2] BEGIN */
                / 100
                /* [VL 12.2] END */
            );
        }

        return mapSubBrandId_CalculatedAmount;

    }
    /* [HC 1.0] END */ 

    private Map<Id, Decimal> calculateAmountWithDate(Decimal pSponsorship) {
        
        mapSubBrandId_AmountWithDate = new Map<Id, Decimal>();

        for(Id subBrandId : mapSubBrandId_WeightPercent.keySet()) {
            mapSubBrandId_AmountWithDate.put(
                subBrandId,
                pSponsorship * mapSubBrandId_WeightPercent.get(subBrandId)
                /* [VL 12.2] BEGIN */
                / 100
                /* [VL 12.2] END */
            );
        }

        return mapSubBrandId_AmountWithDate;
    }
}