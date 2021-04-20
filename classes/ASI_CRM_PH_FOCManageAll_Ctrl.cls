/*
 * *******************************************************************************
 * Name: ASI_CRM_PH_FOCManageAll_Ctrl
 * Version History
 * Date Developer Comments
 * --------------- -------------------- -------------------------------------
 * 09-11-2018 		LAPUTA: CALVIN            Created
 * 13-12-2018       LAPUTA: CALVIN          Replaced activation fund with marketing support FOC
 * 11-01-2019       LAPUTA: CALVIN          Retrieve all foc item by SKU from the same contract for validation
 * 2019-02-26       LAPUTA: Vincent Lam     [VL 1.0] get correct list of SKU
 * *******************************************************************************
 */
public without sharing class ASI_CRM_PH_FOCManageAll_Ctrl {
    private final static String UPSERT_FOC_ITEM_LIST_JSON     = 'upsertFocListJson';
    private final static String DELETE_FOC_ITEM_ID_LIST_JSON  = 'deleteFocItemIdListJson';
    private final static String IS_QUICK_SAVE                 = 'isQuickSave';
	private final static String RTID_SKU_DF = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_PH_DF_SKU');
	private final static String RTID_SKU_DP = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_PH_DP_SKU');
    private final static String RTID_LISTPRICE = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price');

    public Boolean isReadOnly {get; set;}
    public Boolean hasError {get; set;}

    // Exception 
    public class CustomException extends Exception {}
    public List <ExceptionWrapper> exceptionList {get; set;}
    public String exceptionListJson {
        get {
            return toJsonString(exceptionList);
        }
    }

    public ASI_FOC_Free_Goods_Request__c foc {get; set;}
    public String focItemListJson {get {return toJsonString(focItemList);}}
    public String SKUListJson {get {return toJsonString(SKUMap.keySet());}}
    public String SKUMapJson {get {return toJsonString(SKUMap);}}

    private Map<String, ASI_MFM_SKU_Code__c> SKUMap;
    private Map<String, ASI_MFM_Sub_brand__c> subBrandMap;
    private List<ASI_FOC_Request_Item__c> focItemList;

    public ASI_CRM_PH_FOCManageAll_Ctrl(ApexPages.StandardController standardController) {
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
        String recordId = pageParameters.get('id');
        foc = [
                select ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c, ASI_FOC_MFM_Consumer_AP_PO_Number__c,
                ASI_FOC_MFM_Consumer_AP_PO_Number__r.RecordType.DeveloperName,
                ASI_FOC_MFM_Consumer_AP_PO_Number__r.ASI_MFM_PO_Start_Date__c, ASI_CRM_Contract__c,
                ASI_CRM_Contract__r.ASI_CRM_Marketing_Support_Fund_Amount__c, ASI_CRM_Outlet__c, ASI_CRM_Outlet__r.ASI_CRM_Duty_Free__c,
                ASI_CRM_Contract__r.ASI_CRM_Merchandise_Amount__c, ASI_FOC_Request_Type__c, Name,
                RecordType.DeveloperName
                from ASI_FOC_Free_Goods_Request__c
                where id =: recordId
        ];
        isReadOnly = Boolean.valueOf(pageParameters.containsKey('isReadOnly') ? pageParameters.get('isReadOnly') : 'true');
        init(recordId);
    }

    public PageReference saveFocItem(){
        Savepoint sp = Database.setSavepoint();
        try{
            Map<String, String> params = ApexPages.currentPage().getParameters();
            Boolean isQuickSave = String.isBlank(params.get(IS_QUICK_SAVE)) ? false : Boolean.valueOf(params.get(IS_QUICK_SAVE));

            hasError = false;
            exceptionList = new List <ExceptionWrapper> ();

            Id focItemRtId = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item');

            String upsertFocItemListJson  = params.get(UPSERT_FOC_ITEM_LIST_JSON);
            String removeFocItemIdListJson  = params.get(DELETE_FOC_ITEM_ID_LIST_JSON);

            List<ASI_FOC_Request_Item__c> upsertFocItemList = new List<ASI_FOC_Request_Item__c>();
            List<String> removeFocItemIdList = new List<String>();

            upsertFocItemList = (List<ASI_FOC_Request_Item__c>) fromJsonString(upsertFocItemListJson, List<ASI_FOC_Request_Item__c>.class);
                        
            removeFocItemIdList = (List<String>) fromJsonString(removeFocItemIdListJson, List<String>.class);

            // Remove foc item
            if(removeFocItemIdList != null && !removeFocItemIdList.isEmpty()){
                delete [select id from ASI_FOC_Request_Item__c where id in: removeFocItemIdList];
            }

            // Validation
            // Map<Id, ASI_FOC_Request_Item__c> SKUFOCItemMap = new Map<Id, ASI_FOC_Request_Item__c>();
            // CC 2019-01-11
            Map<Id, Decimal> SKUFOCAmountMap = new Map<Id, Decimal>();
            Map<string, ASI_FOC_Request_Item__c> map_sku_requestItem = new Map<string, ASI_FOC_Request_Item__c>();
            for(ASI_FOC_Request_Item__c item: upsertFocItemList){
                if(item.Id == null){
                    item.recordTypeId = focItemRtId;
                }
                /*
                if(!SKUFOCItemMap.containsKey(item.ASI_FOC_SKU__c)){
                    SKUFOCItemMap.put(item.ASI_FOC_SKU__c, item);                    
                }*/
                // CC 2019-01-11 
                if(!SKUFOCAmountMap.containsKey(item.ASI_FOC_SKU__c)){
                    SKUFOCAmountMap.put(item.ASI_FOC_SKU__c, item.ASI_FOC_Request_Quantity_Bottle__c);
                }
                else{
                    // throw exception for duplicate SKU
                    throw new CustomException('Cannot add the same SKU');
                }
				map_sku_requestItem.put(item.ASI_FOC_SKU__c, item);
            }
            
            // CC 2019-01-11
            // include all foc items within the same contract
            List<ASI_FOC_Request_Item__c> allFocItemList = new List<ASI_FOC_Request_Item__c>();
            
            if(foc.RecordType.DeveloperName == 'ASI_CRM_PH_Contract_FOC_POSM_Request' && foc.ASI_FOC_Request_Type__c == 'FOC' && foc.ASI_CRM_Contract__c != null){
                allFocItemList = [select ASI_FOC_SKU__c, ASI_FOC_Request_Quantity_Bottle__c from ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__r.RecordType.DeveloperName like 'ASI_CRM_PH_Contract_FOC_POSM_Request' AND ASI_FOC_Request_Order__r.ASI_CRM_Contract__c =: foc.ASI_CRM_Contract__c and ASI_FOC_Request_Order__c !=: foc.Id];
            }
            else if(foc.RecordType.DeveloperName == 'ASI_MFM_PH_PO_FOC_POSM_Request' && foc.ASI_FOC_MFM_Consumer_AP_PO_Number__c != null){
                allFocItemList = [select ASI_FOC_SKU__c, ASI_FOC_Request_Quantity_Bottle__c from ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__r.RecordType.DeveloperName like 'ASI_MFM_PH_PO_FOC_POSM_Request' AND ASI_FOC_Request_Order__r.ASI_FOC_MFM_Consumer_AP_PO_Number__c =: foc.ASI_FOC_MFM_Consumer_AP_PO_Number__c and ASI_FOC_Request_Order__c !=: foc.Id];
            }
            
            for(ASI_FOC_Request_Item__c item: allFocItemList){
                // merge with SKUFOCAmountMap
                Decimal subtotal = SKUFOCAmountMap.get(item.ASI_FOC_SKU__c);
                subtotal = (subtotal == null)? item.ASI_FOC_Request_Quantity_Bottle__c: (subtotal + item.ASI_FOC_Request_Quantity_Bottle__c);
                SKUFOCAmountMap.put(item.ASI_FOC_SKU__c, subtotal);
            }            
            // END

            // FOC Contract
            if(foc.RecordType.DeveloperName == 'ASI_CRM_PH_Contract_FOC_POSM_Request' && foc.ASI_FOC_Request_Type__c == 'FOC' && foc.ASI_CRM_Contract__c != null){
                Map<Id, Decimal> skuProportionMap = new Map<Id, Decimal>();
                Map<Id, ASI_CRM_ContractTarget__c> skuContractTargetMap = new Map<Id, ASI_CRM_ContractTarget__c>();

                List<ASI_CRM_ContractTarget__c> contractTargets = [
                        select ASI_CRM_Weight_by_Outlet_Sales_Revenue__c, ASI_CRM_SKU__c, ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c,
                        ASI_CRM_Target_Total_Bottle__c, ASI_CRM_SKU__r.Name
                        from ASI_CRM_ContractTarget__c
                        where ASI_CRM_SKU__c in: SKUFOCAmountMap.keySet()
                        and ASI_CRM_Contract__c =: foc.ASI_CRM_Contract__c
                ];system.debug(contractTargets);
                for (ASI_CRM_ContractTarget__c target : contractTargets) {
                    if(!skuProportionMap.containsKey(target.ASI_CRM_SKU__c)){
                        skuProportionMap.put(target.ASI_CRM_SKU__c, target.ASI_CRM_Weight_by_Outlet_Sales_Revenue__c * foc.ASI_CRM_Contract__r.ASI_CRM_Marketing_Support_Fund_Amount__c / 100);
                        skuContractTargetMap.put(target.ASI_CRM_SKU__c, target);
                    }
                }
				
                //if(SKUFOCItemMap.size() != skuProportionMap.size()){
                if (!isValidSku(contractTargets, upsertFocItemList)) {
                    // throw exception: missing contract target
                    throw new CustomException('Free Goods Request SKU must be one of the Contract Target SKU');
                }
                else{
                    List<String> invalidSKU = new List<String>();
                    for(Id skuId: skuProportionMap.keySet()){
                        //final Decimal total = SKUFOCItemMap.get(skuId).ASI_FOC_Request_Quantity_Bottle__c * skuContractTargetMap.get(skuId).ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
                        final Decimal total = SKUFOCAmountMap.get(skuId) * skuContractTargetMap.get(skuId).ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c; 
						system.debug('map_sku_requestItem');
						system.debug(map_sku_requestItem);
						system.debug(skuContractTargetMap.get(skuId));
						system.debug(map_sku_requestItem.containsKey(skuId));
						if(map_sku_requestItem.containsKey(skuId)){
							ASI_FOC_Request_Item__c i = map_sku_requestItem.get(skuId);
							i.ASI_FOC_Unit_Cost_PC_BT__c = skuContractTargetMap.get(skuId).ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c; 
						}
                        if(skuProportionMap.get(skuId) < total){
                            // throw exception: exceed support amount
                            invalidSKU.add(skuContractTargetMap.get(skuId).ASI_CRM_SKU__r.Name + ' of ' + ASI_CRM_NumberUtil.getCurrencyFormattedValue(total, '$') + ' exceeded by ' + ASI_CRM_NumberUtil.getCurrencyFormattedValue(total - skuProportionMap.get(skuId), '$'));
                        }
                    }
                    if(!invalidSKU.isEmpty()){
                        String invalidSKUString = String.join(invalidSKU, ', ');
                        throw new CustomException('Request amount of SKU exceeds Marketing Support Fund amount : ' + invalidSKUString + '');
                    }
                }
            }
            // FOC PO
            else if(foc.RecordType.DeveloperName == 'ASI_MFM_PH_PO_FOC_POSM_Request' && foc.ASI_FOC_MFM_Consumer_AP_PO_Number__c != null){
                Map<Id, Decimal> subBrandPriceMap = new Map<Id, Decimal>(); // stores id : total price for each subbrand
                Map<Id, String> subBrandMap = new Map<Id, String>(); // stores id : name pair
				/* [VL 1.0] BEGIN */
                Map<Id, Decimal> brandPriceMap = new Map<Id, Decimal>(); // stores id : total price for each brand
                Map<Id, String> brandMap = new Map<Id, String>(); // stores id : name pair
				/* [VL 1.0] END */
                // Populate balance for each sub brand
                Set<Id> duplicateSkuSet = new Set<Id>(); // ignore duplicate price cost with older effective date being calculated
                final List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCosts = [
                        SELECT ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_Price__c
						/* [VL 1.0] BEGIN */
						, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.Name
						/* [VL 1.0] END */
                        FROM ASI_CRM_MY_SKUPriceCost__c
                        WHERE recordType.DeveloperName = 'ASI_CRM_PH_List_Price'
                        //AND ASI_CRM_SKU__c IN: SKUFOCItemMap.keySet()
                        AND ASI_CRM_SKU__c in: SKUFOCAmountMap.keySet()
                        AND ASI_CRM_EffectiveDate__c <: foc.ASI_FOC_MFM_Consumer_AP_PO_Number__r.ASI_MFM_PO_Start_Date__c
                        ORDER BY ASI_CRM_EffectiveDate__c DESC
                ];
                for (ASI_CRM_MY_SKUPriceCost__c priceCost : skuPriceCosts) {
					/* [VL 1.0] BEGIN */
					/*
                    if(!subBrandPriceMap.containsKey(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c)){
                        // subBrandPriceMap.put(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, priceCost.ASI_CRM_Price__c * SKUFOCItemMap.get(priceCost.ASI_CRM_SKU__c).ASI_FOC_Request_Quantity_Bottle__c);
                        subBrandPriceMap.put(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, priceCost.ASI_CRM_Price__c * SKUFOCAmountMap.get(priceCost.ASI_CRM_SKU__c));
						if(map_sku_requestItem.containsKey(priceCost.ASI_CRM_SKU__c)){
							ASI_FOC_Request_Item__c i = map_sku_requestItem.get(priceCost.ASI_CRM_SKU__c);
							i.ASI_FOC_Unit_Cost_PC_BT__c = priceCost.ASI_CRM_Price__c; 
						}
                        // populate id: name pair for sub brand
                        subBrandMap.put(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name);
                        duplicateSkuSet.add(priceCost.ASI_CRM_SKU__c);
                    }
                    else{
                        if(!duplicateSkuSet.contains(priceCost.ASI_CRM_SKU__c)){
                            //Decimal subtotal = subBrandPriceMap.get(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c) + priceCost.ASI_CRM_Price__c * SKUFOCItemMap.get(priceCost.ASI_CRM_SKU__c).ASI_FOC_Request_Quantity_Bottle__c;
                            Decimal subtotal = subBrandPriceMap.get(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c) + priceCost.ASI_CRM_Price__c * SKUFOCAmountMap.get(priceCost.ASI_CRM_SKU__c);
                            subBrandPriceMap.put(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, subTotal);
                        }
                    }
					*/
                    if(!brandPriceMap.containsKey(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c)){
                        brandPriceMap.put(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c, priceCost.ASI_CRM_Price__c * SKUFOCAmountMap.get(priceCost.ASI_CRM_SKU__c));
						if(map_sku_requestItem.containsKey(priceCost.ASI_CRM_SKU__c)){
							ASI_FOC_Request_Item__c i = map_sku_requestItem.get(priceCost.ASI_CRM_SKU__c);
							i.ASI_FOC_Unit_Cost_PC_BT__c = priceCost.ASI_CRM_Price__c; 
						}
                        // populate id: name pair for sub brand
                        brandMap.put(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c, priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.Name);
                        duplicateSkuSet.add(priceCost.ASI_CRM_SKU__c);
                    }
                    else{
                        if(!duplicateSkuSet.contains(priceCost.ASI_CRM_SKU__c)){
                            Decimal subtotal = brandPriceMap.get(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c) + priceCost.ASI_CRM_Price__c * SKUFOCAmountMap.get(priceCost.ASI_CRM_SKU__c);
                            brandPriceMap.put(priceCost.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c, subTotal);
                        }
                    }
					/* [VL 1.0] END */
                }

                Map<Id, Decimal> subBrandPriceFromPO = new Map<Id, Decimal>(); // stores id : total remaining balance for each sub brands
				/* [VL 1.0] BEGIN */
                Map<Id, Decimal> brandPriceFromPO = new Map<Id, Decimal>(); // stores id : total remaining balance for each brands
				/* [VL 1.0] END */
                for(AggregateResult ar:[
					select 
						ASI_MFM_Sub_brand_Code__c, 
						ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c brand, 
						SUM(ASI_MFM_Remaining_Balance__c) sum 
					from 
						ASI_MFM_PO_Line_Item__c 
					where 
						ASI_MFM_PO__c =: foc.ASI_FOC_MFM_Consumer_AP_PO_Number__c 
					GROUP BY 
						ASI_MFM_Sub_brand_Code__c,
						ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c
				]){
                    Decimal subtotal = (Decimal)ar.get('sum');
                    subBrandPriceFromPO.put((Id)ar.get('ASI_MFM_Sub_brand_Code__c'), subtotal);
					/* [VL 1.0] BEGIN */
					string brandId = (String)ar.get('brand');
					decimal amount = brandPriceFromPO.containsKey(brandId) ? brandPriceFromPO.get(brandId) : 0;
					brandPriceFromPO.put(brandId, amount + subtotal);
					/* [VL 1.0] END */
                }
                system.debug('subBrandPriceFromPO:: ' + subBrandPriceFromPO);
                system.debug('subBrandPriceMap:: ' + subBrandPriceMap);

				/* [VL 1.0] BEGIN */
				/*
                if(!subBrandPriceFromPO.keySet().containsAll(subBrandPriceMap.keySet())){
                    // throw exception for subbrand in foc item not found in po line item
                    throw new CustomException('SKU and PO line item sub-brand mismatch');
                }
				*/
                if(!brandPriceFromPO.keySet().containsAll(brandPriceMap.keySet())){
                    // throw exception for subbrand in foc item not found in po line item
                    throw new CustomException('SKU and PO line item brand mismatch');
                }
				/* [VL 1.0] END */
                // validate remaining amount
                else{
					/* [VL 1.0] BEGIN */
					/*
                    List<String> invalidSubBrand = new List<String>();
                    for(Id subBrand: subBrandPriceMap.keySet()){
                        Decimal remainingAmt = subBrandPriceFromPO.get(subBrand);
                        system.debug('Sub brand:: ' + subbrand);
                        system.debug('remainingAmt:: ' + remainingAmt);
                        system.debug('subBrandPriceMap.get(subBrand):: ' + subBrandPriceMap.get(subBrand));
                        if(subBrandPriceMap.get(subBrand) > remainingAmt){
                            // throw exception
                            invalidSubBrand.add(subBrandMap.get(subBrand));
                        }
                    }
                    if(!invalidSubBrand.isEmpty()){
                        String invalidSubBrandString = String.join(invalidSubBrand, ', ');
                        throw new CustomException('Request amount of Sub Brand: ' + invalidSubBrandString + ' exceed remaining balance');
                    }
					*/
                    List<String> invalidbrand = new List<String>();
                    for(Id brand: brandPriceMap.keySet()){
                        Decimal remainingAmt = brandPriceFromPO.get(brand);
                        if(brandPriceMap.get(brand) > remainingAmt){
                            // throw exception
                            invalidbrand.add(brandMap.get(brand));
                        }
                    }
                    if(!invalidbrand.isEmpty()){
                        String invalidbrandString = String.join(invalidbrand, ', ');
                        throw new CustomException('Request amount of Brand: ' + invalidbrandString + ' exceed remaining balance');
                    }
					/* [VL 1.0] END */
                }
                rollUpSummary(upsertFocItemList, skuPriceCosts);
            }
            upsert upsertFocItemList;

            if(isQuickSave) {
                focItemList = retrieveFocItemList(foc.Id);
                return null;
            } else {
                PageReference pageRef = new PageReference('/' + foc.Id);
                pageRef.setRedirect(true);
                return pageRef;
            }

        }catch(Exception e){
            Database.rollback(sp);
            hasError = true;
            ExceptionWrapper exceptionWrapper = new ExceptionWrapper(0, e.getMessage());
            exceptionList.add(exceptionWrapper);
            return null;
        }
    }

    private void init(Id recordId){
        if(String.isBlank(recordId)) return;

        focItemList = retrieveFocItemList(recordId);

        SKUMap  = new Map<String, ASI_MFM_SKU_Code__c>();
        for(ASI_MFM_SKU_Code__c sku : retrieveSKUList()){
            SKUMap.put(sku.Name, sku);
        }

        subBrandMap = new Map<String, ASI_MFM_Sub_brand__c>();
    }

    private List<ASI_FOC_Request_Item__c> retrieveFocItemList(Id focId){
        return [select id, ASI_CRM_Support_Type__c, ASI_FOC_SKU__c, ASI_FOC_SKU__r.Name, ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_FOC_Sub_brand__c, ASI_FOC_Request_Quantity_Bottle__c, ASI_FOC_Request_Order__c from ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__c =: focId];
    }

    private List<ASI_MFM_SKU_Code__c> retrieveSKUList() {

        if (foc.RecordType.DeveloperName.equals('ASI_CRM_PH_Contract_FOC_POSM_Request') &&
            foc.ASI_FOC_Request_Type__c.equals('FOC')) {

			/* [VL 1.0] BEGIN */
			String rtId = foc.ASI_CRM_Outlet__r.ASI_CRM_Duty_Free__c ? RTID_SKU_DF : RTID_SKU_DP;
			/* [VL 1.0] END */
			
            return [
                    SELECT Id, Name, ASI_MFM_Sub_brand__r.Name
                    FROM ASI_MFM_SKU_Code__c
                    WHERE ASI_FOC_Active__c = TRUE
					/* [VL 1.0] BEGIN */
					/*
                    AND (RecordType.DeveloperName = 'ASI_CRM_PH_DF_SKU' OR RecordType.DeveloperName = 'ASI_CRM_PH_DP_SKU')
                    AND ASI_CRM_Duty_Free__c = :foc.ASI_CRM_Outlet__r.ASI_CRM_Duty_Free__c
					*/
					AND recordtypeid = :rtId
					AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Price__c != null 
						AND recordtypeId = :RTID_LISTPRICE 
						AND ASI_CRM_EffectiveDate__c <= :foc.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c
					)
					/* [VL 1.0] END */
            ];

        } else if (foc.RecordType.DeveloperName.equals('ASI_CRM_PH_Contract_FOC_POSM_Request') &&
                foc.ASI_FOC_Request_Type__c.equals('POSM')) {

			/* [VL 1.0] BEGIN */
			String rtId = foc.ASI_CRM_Outlet__r.ASI_CRM_Duty_Free__c ? RTID_SKU_DF : RTID_SKU_DP;
			/* [VL 1.0] END */
			
            return [
                    SELECT Id, Name, ASI_MFM_Sub_brand__r.Name
                    FROM ASI_MFM_SKU_Code__c
                    WHERE ASI_FOC_Active__c = TRUE
					/* [VL 1.0] BEGIN */
					/*
                    AND RecordType.DeveloperName = 'ASI_CRM_PH_POSM'
                    AND ASI_CRM_Duty_Free__c = :foc.ASI_CRM_Outlet__r.ASI_CRM_Duty_Free__c
					*/
					AND recordtypeid = :rtId
					AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Price__c != null 
						AND recordtypeId = :RTID_LISTPRICE 
						AND ASI_CRM_EffectiveDate__c <= :foc.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c
					)
					/* [VL 1.0] END */
            ];

        } else if (foc.RecordType.DeveloperName.equals('ASI_MFM_PH_PO_FOC_POSM_Request')) {

            Boolean dutyFree = false;
            final Set<String> mfmRecordTypeName = new Set<String>{
                'ASI_MFM_PH_DF_PO',
                'ASI_MFM_PH_DF_PO_Read_Only'
                    };
//            ,
//            'ASI_MFM_PH_DP_PO',
//            'ASI_MFM_PH_DP_PO_Read_Only'
			/* [VL 1.0] BEGIN */
			/*
            if(mfmRecordTypeName.contains(
                    foc.ASI_FOC_MFM_Consumer_AP_PO_Number__r.RecordType.DeveloperName
            )) {
                dutyFree = true;
            }
			*/
			String rtId = mfmRecordTypeName.contains(foc.ASI_FOC_MFM_Consumer_AP_PO_Number__r.RecordType.DeveloperName) ? RTID_SKU_DF : RTID_SKU_DP;
			/* [VL 1.0] END */
			

            return [
                    SELECT Id, Name, ASI_MFM_Sub_brand__r.Name, ASI_MFM_SKU_Code__c
                    FROM ASI_MFM_SKU_Code__c
                    WHERE ASI_FOC_Active__c = TRUE
					/* [VL 1.0] BEGIN */
					/*
                    AND (RecordType.DeveloperName = 'ASI_CRM_PH_DF_SKU' OR RecordType.DeveloperName = 'ASI_CRM_PH_DP_SKU')
                    AND ASI_CRM_Duty_Free__c = :dutyFree
					*/
					AND recordtypeid = :rtId
					AND Id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Price__c != null 
						AND recordtypeId = :RTID_LISTPRICE 
						AND ASI_CRM_EffectiveDate__c <= :foc.ASI_FOC_MFM_Consumer_AP_PO_Number__r.ASI_MFM_PO_Start_Date__c
					)
					/* [VL 1.0] END */
            ];
        }

        return new List<ASI_MFM_SKU_Code__c>();
    }

    private Boolean isValidSku(List<ASI_CRM_ContractTarget__c> contractTargets,
                               List<ASI_FOC_Request_Item__c> focRequestItems) {

        final Set<Id> skusInContractTarget = new Set<Id>();
        for (ASI_CRM_ContractTarget__c contractTarget : contractTargets) {
            skusInContractTarget.add(contractTarget.ASI_CRM_SKU__c);
        }

        for (ASI_FOC_Request_Item__c focRequestItem : focRequestItems) {
            if (!skusInContractTarget.contains(focRequestItem.ASI_FOC_SKU__c)) return false;
        }

        return true;
    }

    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private Object fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }

    private static void rollUpSummary(List<ASI_FOC_Request_Item__c> requestItems,
                                      List<ASI_CRM_MY_SKUPriceCost__c> priceCosts) {

        Map<Id, ASI_CRM_MY_SKUPriceCost__c> skuIdPriceCostMap = new Map<Id, ASI_CRM_MY_SKUPriceCost__c>();

        for (ASI_CRM_MY_SKUPriceCost__c priceCost : priceCosts) {
            skuIdPriceCostMap.put(priceCost.ASI_CRM_SKU__c, priceCost);
        }

        for (ASI_FOC_Request_Item__c requestItem : requestItems) {
            requestItem.ASI_FOC_Unit_Cost_PC_BT__c = skuIdPriceCostMap.get(requestItem.ASI_FOC_SKU__c).ASI_CRM_Price__c;
        }
    }

    //Inner class for storing the exception
    private class ExceptionWrapper {
        private Integer lineNumber {
            get;
            set;
        }
        private String errorMessage {
            get;
            set;
        }
        private List < String > fieldAPINameList {
            get;
            set;
        }

        private ExceptionWrapper(Integer lineNumber, String errorMessage) {
            this.lineNumber = lineNumber;
            this.errorMessage = errorMessage;
        }

        private ExceptionWrapper(Integer lineNumber, String errorMessage, List < String > fieldAPINameList) {
            this(lineNumber, errorMessage);
            this.fieldAPINameList = fieldAPINameList;
        }
    }
}