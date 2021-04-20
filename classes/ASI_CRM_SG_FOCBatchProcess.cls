/*********************************************************************************
 * Name: ASI_CRM_SG_FOCBatchProcess
 * Test Class: ASI_CRM_SG_FOCComputeControllerTest
 * Description: Free goods generation batch apex. Rewrote the code from the existing ASI_CRM_SG_FOCBatchProcess 
 * Below will list out all the possible scenarios that this code caters:
 *
 * 1/ Contract Target SKU_WS_Outlet match offtake SKU_WS_Outlet (use SKU of Contract target as Free Goods)
 *
 * 2/ Contract Target SubBrand_WS_Outlet match with offtake SubBrand_WS_Outlet (use SKU of Contract target as Free Goods with Volume Conversion
 * Offtake SKU Volume/Contract Target SKU Volume)
 *
 * 3/ Contract Target SKU_WS_Outlet has wine category match with Wine offtake SKU_WS_Outlet (use Latest Vintage SKU of Offtake as free goods)
 * Similar to 3/: Contract Target WineCategory_WS_Outlet match with offtake WineCategory_WS_Outlet (use Latest Vintage SKU of Offtake as free goods)
 * The logic in the code will only look for winecategory instead. Also do the volume conversion between Offtake SKU vs offtake Latest Vintage (offtake sku as base)
 *
 * 4/ Contract Target SubBrand_WS_Outlet match with offtake SubBrand_WS_Outlet but offtake SKU is a wine category but the Contract Target 
 * SKU not a wine category: same as 2/ but no conversion and use Latest Vintage SKU as free goods
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/19/2015       Conrad                  Created
 * 29 Oct 2015      Kevin
 * 8 Jan 2016       Vincent                 [Vincent 3.0] Correct offtake qty x2 problem generated when offtake wine cat. = contract wine cat.
 * 8 Jan 2016       Vincent                 [Vincent 3.1] Correct request qty x2 problem generated when offtake wine cat. = contract wine cat.
 * 8 Jan 2016       Vincent                 [Vincent 3.2] Correct the FOC calculation formula from 
 *                                                        (volume of offtake / volume of latest vintage) * (sales incentive of this target ) * (Total bottle of offtake) / (Packaging size in each case of latest vintage) 
 *                                                        To
 *                                                        (volume of offtake / volume of latest vintage) * (sales incentive of this target / Packaging size of in each case of this target ) * (Total bottle of offtake)  
 * 9 Mar 2016       Vincent                 [Vincent 4.0] In the change of 3.2, I store (sales incentive of this target / Packaging size of in each case of this target ) value in a Map. 
 *                                                        The value will cause inaccurate result in further calculation. for example:
 *                                                          Decimal a = 1.0/12.0;
 *                                                          Decimal result1 = 12.0 * a;
 *                                                          Decimal result2 = 12.0 *1.0/12.0;
 *                                                        Result1 = 0.999... and Result2 = 1.0. So I have to store Sales Incentive and Packaging Size separately in two Map.
 * 23 Apr 2016      Vincent                 [VL 5.0] only allow create FOC request for contract status = "Contract Approved"
 * 09 May 2016      Hugo                    [HC 1.0] In the FOC request line item and carry over, change the SKU Id with the SKU Mapping
 * 23 May 2016      Vincent                 [VL 6.0] Besides PRS - WS, save WS - OT and IGC cost to FOC items
 *                                          [VL 7.0] Calculate ROI for contracts
 * 08 Jun 2016      Vincent                 [VL 8.0] If the Actual Offtake is an new SKU for SKU only contract target, also give FOC
 * 23 Aug 2016      Vincent                 [VL 9.0] put Contract and Owner in the constructor
 * 24 Aug 2016      Vincent                 [VL 10.0] fill-in contract's outlet to FOC, not actual offtake customers
 * 30 May 2017      Wilken                  [WL 1.0] SVR115090090 Incorrect carry over due to incorect subtraction of rounded carry over
 * 28 Jul 2017      Vincent                 [VL 11.0] Remove SG CRM P3 item 72
 * 08 Nov 2017      Wilken                  [WL 12.0] P4.1A: Block trade deal generation from RTM Contracts
 * 06 Feb 2018      Wilken                  [WL 13.0] Allow regenerate FOC to generate for previous month
 * 13 Apr 2018		Vincent					[VL 14.0] P4.2: generate promotion incentive at the end of foc generation (obsoleted)
 * 04 Dec 2018      Wilken                  [WL 15.0] Bug fix for missing FOC generation if match sub-brand but no latest vintage on offtake
*********************************************************************************/
global class ASI_CRM_SG_FOCBatchProcess implements Database.Batchable<sobject>, Database.stateful{

    // The month and the year of the offtakes to retrieve
    global String monthGlobal,yearGlobal;
    // Store the grouped offtake in a persisting map. The key is the Contract ID
    global Map<ID, offtakeWrapper> offtakeWrapperMap;
    // Map of the Contract Headers Involved in a persisting map, extracted from the actual offtake records
    global Map<ID, ASI_TH_CRM_Contract__c> contractMap;
    // Map of the SKUs Involved in a persisting map, extracted from the actual offtake records
    global Map<ID, ASI_MFM_SKU_Code__c> skuMap;
    // Map of the FOC carry over of the latest previous month and filtered by the contract header. 
    // The FOC carry overs are grouped by Contract The key is the Contract ID
    global Map<ID, List<ASI_CRM_SG_FOC_Carry_Over__c>> focCarryOverMap;
    // Map of the SKU Historic cost. ID being the sku ID
    global Map<ID, Decimal> skuPriceHistoricCostMap;
    // Map storing Carry Over with the unique key of sku_ws_contractID or wineCategory_ws_contractid
    global Map<String, ASI_CRM_SG_FOC_Carry_Over__c> latestCarryOverMap;
    /* [HC 1.0] BEGIN */
    global Map<Id, Id> skuMappingMap;
    /* [HC 1.0] END */
    
    /* [VL 9.0] BEGIN */
    global id contractOwnerid;
    global list<string> list_contractID;
    /* [VL 9.0] END */

    
    /* [VL 6.0] BEGIN */
    // map contract id to SKU Price/Cost with different type of price/cost
    global Map<id, Map<id,Map<string, ASI_CRM_MY_SKUPriceCost__c>>> map_contractID_type_SkuPrice;
    
    global static final Set<String> SET_PRICE_RECTYPE_DEVNAME = new Set<String>{
        'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',
        'ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',
        'ASI_CRM_SG_IGC',
        'ASI_CRM_SG_CRM_Duty_Per_Bottle',
        'ASI_CRM_SG_CRM_FOB_Per_Bottle',
        'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'
    };
    /* [VL 6.0] END */
    
	global static final String CONTRACTTARGET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';

    global ASI_CRM_SG_FOCBatchProcess(String months, String years){
        this.monthGlobal = months;
        this.yearGlobal = years;
        /* [VL 9.0] BEGIN */
        this.contractOwnerid = UserInfo.getUserId();
        this.list_contractID = new list<string>();
        /* [VL 9.0] END */
    }

    /* [VL 9.0] BEGIN */
    global ASI_CRM_SG_FOCBatchProcess(String months, String years, string contractOwnerid, list<string> list_contractID){
        this.monthGlobal = months;
        this.yearGlobal = years;
        this.contractOwnerid = contractOwnerid;
        this.list_contractID = list_contractID;
    }
    /* [VL 9.0] END */

    //Query all the Actual Offtakes based on the month, year and the owner of the contract as the current logged in user
    global database.querylocator start(Database.BatchableContext BC){
        if(this.offtakeWrapperMap == null) {
            this.offtakeWrapperMap = new map<ID, offtakeWrapper>();
        }
        
        if(contractMap == null ) {
            this.contractMap = new Map<ID, ASI_TH_CRM_Contract__c>();
        }
        
        if(skuMap == null ) {
            this.skuMap = new Map<ID, ASI_MFM_SKU_Code__c>();
        }
        
        if(this.focCarryOverMap == null) {
            this.focCarryOverMap = new Map<ID, List<ASI_CRM_SG_FOC_Carry_Over__c>>();
        }
        
        if(this.skuPriceHistoricCostMap == null) {
            this.skuPriceHistoricCostMap = new Map<ID, Decimal>();
        }
        
        if(this.latestCarryOverMap == null) {
            latestCarryOverMap = new Map<String, ASI_CRM_SG_FOC_Carry_Over__c>();
        }
        
        /* [VL 6.0] BEGIN */
        if(this.map_contractID_type_SkuPrice == null) {
            map_contractID_type_SkuPrice = new Map<id, Map<id,Map<string, ASI_CRM_MY_SKUPriceCost__c>>>();
        }
        /* [VL 6.0] END */
        
        /* [HC 1.0] BEGIN */
        skuMappingMap = new Map<Id, Id>();
        skuMappingMap = getSKUMapping();
        /* [HC 1.0] END */
        
        String query = '';
        query += 'SELECT ASI_CRM_Latest_Vintage__r.ASI_HK_CRM_Packaging_Size__c, ';
        query += 'ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c,ASI_CRM_Latest_Vintage__c, ';
        query += 'ASI_TH_CRM_Sub_brand__c,ASI_CRM_Contract__c,ASI_CRM_SG_Customer__c,ASI_TH_CRM_Year__c,ASI_TH_CRM_Month__c, ';
        query += 'ASI_CRM_FromWS__c, ASI_CRM_SKU__c,ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ';
        query += 'ASI_TH_CRM_Quantity__c,ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c,  ';
        query += 'ASI_CRM_SKU__r.ASI_CRM_Latest_Vintage__c,  '; //[WL 15.0]
        /* [VL 6.0] BEGIN */
        query += ' ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c ';
        /* [VL 6.0] END */
        query += 'FROM ASI_TH_CRM_Actual_Offtake__c  ';
        query += 'WHERE ASI_TH_CRM_Month__c= \'' + this.monthGlobal + '\' and ASI_TH_CRM_Year__c = \'' + this.yearGlobal  + '\' ';
        /* [VL 9.0] BEGIN */
        /*
        query += 'AND ASI_CRM_Contract__r.ownerId=:UserInfo.getUserId() ';
        */
        query += 'AND ASI_CRM_Contract__r.ownerId= \'' + this.contractOwnerid + '\' ';
        /* [VL 9.0] END */
        query += 'AND ASI_CRM_SKU__c != null ';
        query += 'AND ASI_CRM_SG_Customer__c != null ';
        query += 'AND ASI_CRM_Contract__c != null ';
        query += 'AND ASI_CRM_FromWS__c != null ';
        /* [VL 5.0] BEGIN */
        query += 'AND ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c = \'Contract Approved\' ';
        /* [VL 5.0] END */
		
		/* [WL 12.0] BEGIN */
        query += 'AND ASI_CRM_Contract__r.ASI_CRM_Contract_Exist_Before_RTM__c = true ';
        /* [WL 12.0] END */
		
        /* [VL 9.0] BEGIN */
        if (this.list_contractID.size()>0){
            query += ' AND ASI_CRM_Contract__c in (';
            for(id cid: this.list_contractID) {
                query += '\''+cid+'\','; 
            }
            query = query.subString(0,query.length()-1);
            query += ') ';
        }
        /* [VL 9.0] END */
        query += 'ORDER BY ASI_CRM_Contract__c asc ';
        
        return Database.getQueryLocator(query);
    }
    
    // Main Grouping Logic, the execute batch will be ONLY involved in the creation of the offtakeWrapper items
    // and the grouping/defining of the scenarios.
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        system.debug('---SKU Mapping---'+skuMappingMap );
        
        /* [VL 6.0] BEGIN */
        // store the latest contract start date of the contracts, in order to reduce query size
        Date recentStartDate;
        // map contract ID to start date, for SKU Price/Cost calculation
        Map<id, Date> map_contractID_contractStartDate = new Map<id, Date>();
        /* [VL 6.0] END */
        
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = (List<ASI_TH_CRM_Actual_Offtake__c>)scope;
        
        Set<ID> contractHeaderIDSet = new Set<ID>();
        Set<ID> skuIDSet = new Set<ID>();
        // clear out the erroneous actual offtake data (the ones without a contract lookup)
        List<ASI_TH_CRM_Actual_Offtake__c> validActualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        
        //Loop through the actual offtake to retrieve the unique IDs of the Contract Headers, and SKUs
        for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOfftakeList) {
            
            if(actualOfftake.ASI_CRM_SKU__c != null && actualOfftake.ASI_CRM_Contract__c != null) {
                validActualOfftakeList.add(actualOfftake);
                skuIDSet.add(actualOfftake.ASI_CRM_SKU__c);
                // Special case, also retrieve the SKU from the latest vintage, if it exists
                if(actualOfftake.ASI_CRM_Latest_Vintage__c != null) {
                    skuIDSet.add(actualOfftake.ASI_CRM_Latest_Vintage__c);
                }

                /*[WL 15.0] BEGIN*/
                if (actualOfftake.ASI_CRM_SKU__r.ASI_CRM_Latest_Vintage__c != null){
                    skuIDSet.add(actualOfftake.ASI_CRM_SKU__r.ASI_CRM_Latest_Vintage__c);
                }
                /*[WL 15.0] END*/
                contractHeaderIDSet.add(actualOfftake.ASI_CRM_Contract__c);
                
                /* [VL 6.0] BEGIN */
                map_contractID_contractStartDate.put(actualOfftake.ASI_CRM_Contract__c, actualOfftake.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c);
                if (recentStartDate == null) {
                    recentStartDate = actualOfftake.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c;
                } else
                if (recentStartDate < actualOfftake.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c) {
                    recentStartDate = actualOfftake.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c;
                }
                /* [VL 6.0] END */
            }
        }
        
        // Query the contract Header ID and put it inside the persisting map
        String contractTargetQuery = ', (SELECT ID, Name, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c, ' +
                                     ' ASI_CRM_SG_Sales_Incentive__c, ASI_CRM_Subbrand__c FROM Contract_Target__r Where recordtype.developername = :CONTRACTTARGET_RECORD_TYPE) ';
        String queryContractHeaderString = queryAll_Builder_String('ASI_TH_CRM_Contract__c', contractTargetQuery);
        queryContractHeaderString += 'WHERE ID IN:contractHeaderIDSet ';
        List<ASI_TH_CRM_Contract__c> contractHeaderList = (List<ASI_TH_CRM_Contract__c>)Database.query(queryContractHeaderString);
        this.contractMap.putAll(contractHeaderList);
        // Also add the sku from the contract target records
        for(ASI_TH_CRM_Contract__c contractHeader : contractHeaderList) {
            List<ASI_CRM_ContractTarget__c> contractTargetList = contractHeader.Contract_Target__r;
            for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
                if(contractTarget.ASI_CRM_SKU__c != null) {
                    skuIDSet.add(contractTarget.ASI_CRM_SKU__c);
                }
            }
        }
        
        for (ID oldSKUID:skuMappingMap.keySet()){
            skuIDSet.add(oldSKUID);
            skuIDSet.add(skuMappingMap.get(oldSKUID));
        }
        
        // Query the SKU records and put it inside the persisting map
        String querySKUString = queryAll_Builder_String('ASI_MFM_SKU_Code__c', '');
        querySKUString += 'WHERE ID IN:skuIDSet ';
        List<ASI_MFM_SKU_Code__c> skuList = (List<ASI_MFM_SKU_Code__c>)Database.query(querySKUString);
        this.skuMap.putAll(skuList);
        
        // Query the sku historic price records depending on the queried sku records
        String querySKUHistoricPriceString = queryAll_Builder_String('ASI_CRM_MY_SKUPriceCost__c', '');
        querySKUHistoricPriceString += 
            /* [VL 6.0] BEGIN */
            /*
            'WHERE ASI_CRM_SKU__c IN:skuIDSet AND ' + 
            'recordtypeid = \''+ Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') + '\' ' +
            ' ORDER BY ASI_CRM_SKU__c, ASI_CRM_EffectiveDate__c ';
            */
            'WHERE ASI_CRM_SKU__c IN:skuIDSet ' + 
            ' AND recordtype.developername IN :SET_PRICE_RECTYPE_DEVNAME ' +
            ' AND ASI_CRM_EffectiveDate__c <= :recentStartDate ' +
            ' ORDER BY ASI_CRM_EffectiveDate__c DESC ';
            /* [VL 6.0] END */
        List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCost = (List<ASI_CRM_MY_SKUPriceCost__c>)Database.query(querySKUHistoricPriceString);
        // Only retrieve the latest effective date price per bottle prs wholesaler
        for(ASI_CRM_MY_SKUPriceCost__c priceCost : skuPriceCost) {
            if(!skuPriceHistoricCostMap.containsKey(priceCost.ASI_CRM_SKU__c)) {
                skuPriceHistoricCostMap.put(priceCost.ASI_CRM_SKU__c, priceCost.ASI_CRM_Price__c);
            }
            
            /* [VL 6.0] BEGIN */
            for(id contractID : map_contractID_contractStartDate.keySet()){
                if (priceCost.ASI_CRM_EffectiveDate__c > map_contractID_contractStartDate.get(contractID)) continue;
                
                Map<id,Map<string, ASI_CRM_MY_SKUPriceCost__c>> map_sku_type_skuPrice = map_contractID_type_SkuPrice.containsKey(contractID) ? map_contractID_type_SkuPrice.get(contractID) : new Map<id, Map<string,ASI_CRM_MY_SKUPriceCost__c>>();
                
                Map<string, ASI_CRM_MY_SKUPriceCost__c> map_type_skuPrice = map_sku_type_skuPrice.containsKey(priceCost.ASI_CRM_SKU__c) ? map_sku_type_skuPrice.get(priceCost.ASI_CRM_SKU__c) : new Map<string,ASI_CRM_MY_SKUPriceCost__c>();
                if (map_type_skuPrice.keySet()==SET_PRICE_RECTYPE_DEVNAME) {
                    continue;
                } else
                if (!map_type_skuPrice.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') && priceCost.RecordType.DeveloperName=='ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'){
                    map_type_skuPrice.put('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',priceCost);
                    map_sku_type_skuPrice.put(priceCost.ASI_CRM_SKU__c, map_type_skuPrice);
                } else
                if (!map_type_skuPrice.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade') && priceCost.RecordType.DeveloperName=='ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade'){
                    map_type_skuPrice.put('ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',priceCost);
                    map_sku_type_skuPrice.put(priceCost.ASI_CRM_SKU__c, map_type_skuPrice);
                } else
                if (!map_type_skuPrice.containsKey('ASI_CRM_SG_IGC') && priceCost.RecordType.DeveloperName=='ASI_CRM_SG_IGC'){
                    map_type_skuPrice.put('ASI_CRM_SG_IGC',priceCost);
                    map_sku_type_skuPrice.put(priceCost.ASI_CRM_SKU__c, map_type_skuPrice);
                } else
                if (!map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_Duty_Per_Bottle') && priceCost.RecordType.DeveloperName=='ASI_CRM_SG_CRM_Duty_Per_Bottle'){
                    map_type_skuPrice.put('ASI_CRM_SG_CRM_Duty_Per_Bottle',priceCost);
                    map_sku_type_skuPrice.put(priceCost.ASI_CRM_SKU__c, map_type_skuPrice);
                } else
                if (!map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_FOB_Per_Bottle') && priceCost.RecordType.DeveloperName=='ASI_CRM_SG_CRM_FOB_Per_Bottle'){
                    map_type_skuPrice.put('ASI_CRM_SG_CRM_FOB_Per_Bottle',priceCost);
                    map_sku_type_skuPrice.put(priceCost.ASI_CRM_SKU__c, map_type_skuPrice);
                } else
                if (!map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') && priceCost.RecordType.DeveloperName=='ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'){
                    map_type_skuPrice.put('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',priceCost);
                    map_sku_type_skuPrice.put(priceCost.ASI_CRM_SKU__c, map_type_skuPrice);
                }
                
                map_contractID_type_SkuPrice.put(contractID,map_sku_type_skuPrice);
            }
            
            /* [VL 6.0] END */
        }
        
        // Query the FOC Carry Over records and put it inside the persisting map.
        // Need to group the FOC Carry over records by contract header
        String queryFOCCarryOverString = queryAll_Builder_String('ASI_CRM_SG_FOC_Carry_Over__c', '');
        /*[WL 13.0] BEGIN*/
		//queryFOCCarryOverString += 'WHERE ASI_CRM_SG_Contract__c IN:contractHeaderIDSet ';
		queryFOCCarryOverString += 'WHERE ASI_CRM_SG_Contract__c IN:contractHeaderIDSet order by ASI_CRM_SG_Year__c, ASI_CRM_SG_Month__c desc';
		/*[WL 13.0] END*/
        List<ASI_CRM_SG_FOC_Carry_Over__c> FOCcarryOverList = (List<ASI_CRM_SG_FOC_Carry_Over__c>)Database.query(queryFOCCarryOverString);
		
		/*[WL 13.0] BEGIN*/
		Date generationPeriod = Date.newInstance(Integer.valueOf(yearGlobal), Integer.valueOf(monthGlobal),1);
		Date carryOverPeriod  = Date.newInstance(2000,1,1);
		
		if (FOCcarryOverList.size() > 0)
			carryOverPeriod = Date.newInstance(Integer.valueOf(FOCcarryOverList.get(0).ASI_CRM_SG_Year__c), Integer.valueOf(FOCcarryOverList.get(0).ASI_CRM_SG_Month__c),1);
		/*[WL 13.0] END*/
		
		system.debug('queryFOCCarryOverString: ' + queryFOCCarryOverString + ' FOCcarryOverList: ' + FOCcarryOverList.size());
        
        // Only retrieve the latest created date of the FOC carry over map based on the key: sku_ws_contractID OR wineCategory_ws_ContractID
        // if carry over has wine category
        for(ASI_CRM_SG_FOC_Carry_Over__c focCarryOver : FOCcarryOverList) {
            if(focCarryOver.ASI_CRM_SG_Contract__c != null && focCarryOver.ASI_CRM_SG_SKU__c != null && focCarryOver.ASI_CRM_SG_Wholesaler__c != null) {
                String key = '';

                if(focCarryOver.ASI_CRM_SG_Wine_Category__c != null) {
                    key = (String)focCarryOver.ASI_CRM_SG_Wine_Category__c + '_' + (String)focCarryOver.ASI_CRM_SG_Wholesaler__c + '_' + (String)focCarryOver.ASI_CRM_SG_Contract__c;
                } else {
                    key = (String)focCarryOver.ASI_CRM_SG_SKU__c + '_' + (String)focCarryOver.ASI_CRM_SG_Wholesaler__c + '_' + (String)focCarryOver.ASI_CRM_SG_Contract__c;
                }
                
				/*[WL 13.0] BEGIN*/
				system.debug('generationPeriod: ' + generationPeriod + ' carryOverPeriod: ' + carryOverPeriod);
				
				if (carryOverPeriod < generationPeriod){
					if(latestCarryOverMap.containsKey(key)) {
						ASI_CRM_SG_FOC_Carry_Over__c focCarryOverTemp = latestCarryOverMap.get(key);
						if(focCarryOver.createdDate > focCarryOverTemp.createdDate) {
							latestCarryOverMap.put(key, focCarryOver);
						}
					} else {
						latestCarryOverMap.put(key, focCarryOver);
					}   
				}
				
				system.debug('latestCarryOverMap: ' + latestCarryOverMap);
				/*[WL 13.0] END*/
            }
        }
        
        // Main grouping logic loop
        for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : validActualOfftakeList) {
            
            // The map retrieve below will never be null because the a validation took place in the previous loop
            ASI_TH_CRM_Contract__c contractHeader = this.contractMap.get(actualOfftake.ASI_CRM_Contract__c);  
            ASI_MFM_SKU_Code__c sku = this.skuMap.get(actualOfftake.ASI_CRM_SKU__c);
            
            offtakeWrapper offtWrap;
            // Initialize or get the current OfftakeWrapper record
            if(!offtakeWrapperMap.containsKey(contractHeader.id)) {
                offtWrap = new offtakeWrapper(monthGlobal, yearGlobal);
                /* [VL 10.0] BEGIN */
                /*
                //20151202-Kevin: compare the contract outlet and the offtake outlet, if different the outlet should be reassigned to the the offtake outlet as it is a child outlet of the parent outlet
                offtWrap.OutletID = contractHeader.ASI_CRM_CN_Outlet_WS__c == actualOfftake.ASI_CRM_SG_Customer__c?contractHeader.ASI_CRM_CN_Outlet_WS__c:actualOfftake.ASI_CRM_SG_Customer__c;
                */
                offtWrap.OutletID = contractHeader.ASI_CRM_CN_Outlet_WS__c != null ? contractHeader.ASI_CRM_CN_Outlet_WS__c:actualOfftake.ASI_CRM_SG_Customer__c;
                /* [VL 10.0] END */
                offtWrap.contractHeader = contractHeader;
                // Map and set up the contract target by subBrand, by SKU and by Wine Category. To be used for the calculation later
                offtWrap.setContractTargetBySKU();
                offtWrap.setContractTargetBySubBrand();
                offtWrap.setContractTargetByWineCategory();
                /* [VL 8.0] BEGIN */
                offtWrap.setContractTargetBySKU_newSKU(skuMappingMap);
                /* [VL 8.0] END */
            }
            else {
                offtWrap = offtakeWrapperMap.get(contractHeader.id);
            }
            
            // Store the actual offtake record in the wrapper for the calculation later
            offtWrap.actualOfftakesMap.put(actualOfftake.id, actualOfftake);
            offtakeWrapperMap.put(contractHeader.id, offtWrap);
            
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
		system.debug('Finish latestCarryOverMap: ' + latestCarryOverMap);
        // Group the carry over by contractID
        for(ASI_CRM_SG_FOC_Carry_Over__c focCarry : this.latestCarryOverMap.values()) {
            List<ASI_CRM_SG_FOC_Carry_Over__c> focCarryOverList = new List<ASI_CRM_SG_FOC_Carry_Over__c>();
            
            if(this.focCarryOverMap.containsKey(focCarry.ASI_CRM_SG_Contract__c)) {
                focCarryOverList = this.focCarryOverMap.get(focCarry.ASI_CRM_SG_Contract__c);
            } 
            focCarryOverList.add(focCarry);
            this.focCarryOverMap.put(focCarry.ASI_CRM_SG_Contract__c, focCarryOverList);
        }
        
        // Polishing the offtakeWrapperMap to simplify the calculation code: retrieve the FOC Carry Over Map, if it has any
        // and map it with a key using SKU_WS key.
        for(ID contractID : this.offtakeWrapperMap.keyset()) {
            if(this.focCarryOverMap.containsKey(contractID)) {
                List<ASI_CRM_SG_FOC_Carry_Over__c> carryOverList = this.focCarryOverMap.get(contractID);
                offtakeWrapper offtakeWrap = offtakeWrapperMap.get(contractID);
                for(ASI_CRM_SG_FOC_Carry_Over__c carryOver : carryOverList) {
                    
					system.debug('carryOver: ' + carryOver);
					
                    String key = '';
                    
                    // Special case: if wine category exist, that means the sku belongs to a wine category.
                    // The key built will be wineCategory_ws instead of sku_ws
                    if(carryOver.ASI_CRM_SG_Wine_Category__c != null) {
                        key = buildKey(carryOver.ASI_CRM_SG_Wine_Category__c, carryOver.ASI_CRM_SG_Wholesaler__c);
                    } else {
                        key = buildKey(carryOver.ASI_CRM_SG_SKU__c, carryOver.ASI_CRM_SG_Wholesaler__c);
                    }
                    
                    
                    offtakeWrap.focCarryOverMap.put(key, carryOver);
					
					system.debug('offtakeWrap.focCarryOverMap: ' + offtakeWrap.focCarryOverMap);
                }
                // Resave the new offtakewrapper record in the persistent offtakeWrapperMap
                offtakeWrapperMap.put(contractID, offtakeWrap);
            }
        }
        
        // List where the new Free Goods Record will be created and inserted. The key is the contract ID. The key will help map the 
        // header and line records together
        Map<ID, ASI_FOC_Free_Goods_Request__c> freeGoodsHeaderToInsert = new Map<ID, ASI_FOC_Free_Goods_Request__c>();
        // List where the new Free Goods Request Items will be created and inserted. The key is the contract ID. The key will help map the 
        // header and line records together
        Map<String, ASI_FOC_Request_Item__c> requestLineItemToInsert = new Map<String, ASI_FOC_Request_Item__c>();
        // FOC Carry over to be inserted if the carry over key does not exist (which is SKU_WS_Outlet key)
        List<ASI_CRM_SG_FOC_Carry_Over__c> carryOverToInsert = new List<ASI_CRM_SG_FOC_Carry_Over__c>();
        // Previous Carry Over to be Updated, when consumed, meaning, if we add the previous FOC carry over to the new request Item
        List<ASI_CRM_SG_FOC_Carry_Over__c> carryOverToUpdate = new List<ASI_CRM_SG_FOC_Carry_Over__c>();
        
		/* [VL 11.0]
        List<ASI_CRM_FOC_Linkage__c> insertFOCLinkageList = new List<ASI_CRM_FOC_Linkage__c>();
		*/

        // Main loop block
        for(ID contractID : this.offtakeWrapperMap.keyset()) {
            
            offtakeWrapper offtakeWrap = offtakeWrapperMap.get(contractID);
            List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = offtakeWrap.actualOfftakesMap.values();
            System.debug(logginglevel.INFO,'########################## + offtakeWrap.contractHeader.id ' + contractID);
            System.debug(logginglevel.INFO,'########################## + actualOfftakeList ' + actualOfftakeList);
            System.debug(logginglevel.INFO,'########################## + actualOfftakeList.size() ' + actualOfftakeList.size());
            // First loop to group the Free Goods Request offtake Quantity together and calculate offtakeQuantityMap, volumeConversionMap and salesIncentiveMap
            // Loop through the related actual offtakes to calculate the related values
            // This loop detects the rules
            for(ASI_TH_CRM_Actual_Offtake__c offtakes : actualOfftakeList) { 
                System.debug(logginglevel.INFO,'########################## + offtakes.id ' + offtakes.id);
                String key = '';  
                
                // retrieve the current SKU for all the fields. SKU to be used as the free goods
                ASI_MFM_SKU_Code__c relatedSKU;
                
                /* 
                * Default Value is 1. The volumeConversion multiplier will change on the following scenarios:
                * - When a wine category is detected, and the latest vintage volume is not the same as the offtake SKU
                * - When the sub-brand in offtake matches the Contract target but the SKU offtake volume is not the same as the contract 
                *   target sku
                * The calculation formula: offtake sku Volume/latest vintage volume and offtake sku volume/contract target sku volume for scenario 2
                */ 
                Decimal volumeConversion = 1;
                // related Sales Incentive to be stored in the salesIncentiveMap 
                Decimal salesIncentive = 0;
                /* [Vincent 4.0] BEGIN */
                Decimal packagingSize = 0;
                /* [Vincent 4.0] END */
                Id tempContractTargetId;

                String matchBy = '';
                
                // Detect if there's a Wine Category First: overrides all other rules. This logic caters rule 3 and 4
                if(offtakes.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c != null && offtakeWrap.contractTargetWineCategoryMap.containsKey(offtakes.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c)) {
                    // use latest vintage as the SKU 
                    if(offtakes.ASI_CRM_Latest_Vintage__c != null) {
                        key = buildKey(offtakes.ASI_CRM_Latest_Vintage__c, offtakes.ASI_CRM_FromWS__c);
                        offtakeWrap.wineCategoryMap.put(key, offtakes.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c);
                        
                        relatedSKU = this.skuMap.get(offtakes.ASI_CRM_Latest_Vintage__c);
                        ASI_MFM_SKU_Code__c offtakeSKU = this.skuMap.get(offtakes.ASI_CRM_SKU__c);
                        // Do the volume conversion
                        if(relatedSKU.ASI_HK_CRM_Std_Bottle_Size__c != null && offtakeSKU.ASI_HK_CRM_Std_Bottle_Size__c != null) {
                            volumeConversion = offtakeSKU.ASI_HK_CRM_Std_Bottle_Size__c/relatedSKU.ASI_HK_CRM_Std_Bottle_Size__c;
                        }
                        
                        // Get the sales Incentive
                        ASI_CRM_ContractTarget__c contractTarget = offtakeWrap.contractTargetWineCategoryMap.get(offtakes.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c);
                        tempContractTargetId = contractTarget.Id;
                        matchBy = 'Wine Category';
                        /* [Vincent 3.2].1 BEGIN 
                        salesIncentive = contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? contractTarget.ASI_CRM_SG_Sales_Incentive__c : 0;
                        */
                        ASI_MFM_SKU_Code__c contractTargetSKU = this.skuMap.get(contractTarget.ASI_CRM_SKU__c);
                        packagingSize = contractTargetSKU.ASI_HK_CRM_Packaging_Size__c != null ? contractTargetSKU.ASI_HK_CRM_Packaging_Size__c : 0;
                        /* [Vincent 4.0] BEGIN */
                        /*
                        salesIncentive = packagingSize == 0 ? 0 : (contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? (contractTarget.ASI_CRM_SG_Sales_Incentive__c/packagingSize) : 0);
                        */
                        salesIncentive = contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? contractTarget.ASI_CRM_SG_Sales_Incentive__c : 0;
                        /* [Vincent 4.0] END */
                        /* [Vincent 3.2].1 END */
                    }
                }
                
                system.debug('---offtakeWrap.contractTargetSKUMap_newSKU---'+offtakeWrap.contractTargetSKUMap_newSKU);
                system.debug('---offtakes.ASI_CRM_SKU__c---'+offtakes.ASI_CRM_SKU__c);
                
                // If the wine category didnt match any, detect the usual rules
                if(key == '') {
                    // Detect 1: if theres an actual offtake SKU match in the contract target sku map
                    if(offtakeWrap.contractTargetSKUMap.containsKey(offtakes.ASI_CRM_SKU__c)) {
                        key = buildKey(offtakes.ASI_CRM_SKU__c, offtakes.ASI_CRM_FromWS__c);
                        relatedSKU = this.skuMap.get(offtakes.ASI_CRM_SKU__c);
                        
                        // Get the sales Incentive
                        ASI_CRM_ContractTarget__c contractTarget = offtakeWrap.contractTargetSKUMap.get(offtakes.ASI_CRM_SKU__c);
                        tempContractTargetId = contractTarget.Id;
                        matchBy = 'SKU';
                        /* [Vincent 3.2].4 BEGIN 
                        salesIncentive = contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? contractTarget.ASI_CRM_SG_Sales_Incentive__c : 0;
                        */
                        ASI_MFM_SKU_Code__c contractTargetSKU = this.skuMap.get(contractTarget.ASI_CRM_SKU__c);
                        packagingSize = contractTargetSKU.ASI_HK_CRM_Packaging_Size__c != null ? contractTargetSKU.ASI_HK_CRM_Packaging_Size__c : 0;
                        /* [Vincent 4.0] BEGIN */
                        /*
                        salesIncentive = packagingSize == 0 ? 0 : (contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? (contractTarget.ASI_CRM_SG_Sales_Incentive__c/packagingSize) : 0);
                        */
                        salesIncentive = contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? contractTarget.ASI_CRM_SG_Sales_Incentive__c : 0;
                        /* [Vincent 4.0] END */
                        /* [Vincent 3.2].4 END */
                        
                    } 
                    /* [VL 8.0] BEGIN */
                    // Detect 1.1: if theres an actual offtake SKU match in the contract target NEW sku map
                    else if(offtakeWrap.contractTargetSKUMap_newSKU.containsKey(offtakes.ASI_CRM_SKU__c)) {
                        key = buildKey(offtakes.ASI_CRM_SKU__c, offtakes.ASI_CRM_FromWS__c);
                        relatedSKU = this.skuMap.get(offtakes.ASI_CRM_SKU__c);
                        
                        // Get the sales Incentive
                        ASI_CRM_ContractTarget__c contractTarget = offtakeWrap.contractTargetSKUMap_newSKU.get(offtakes.ASI_CRM_SKU__c);
                        tempContractTargetId = contractTarget.Id;
                        matchBy = 'SKU';
                        ASI_MFM_SKU_Code__c contractTargetSKU = this.skuMap.get(contractTarget.ASI_CRM_SKU__c);
                        packagingSize = contractTargetSKU.ASI_HK_CRM_Packaging_Size__c != null ? contractTargetSKU.ASI_HK_CRM_Packaging_Size__c : 0;
                        salesIncentive = contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? contractTarget.ASI_CRM_SG_Sales_Incentive__c : 0;
                        
                    }
                    /* [VL 8.0] END */
                    // Detect 2: if theres an actual offtake Sub brand match in the contract target SKU map
                    else if (offtakeWrap.contractTargetSubBrandMap.containsKey(offtakes.ASI_TH_CRM_Sub_brand__c)) {
                        ASI_CRM_ContractTarget__c contractTarget = offtakeWrap.contractTargetSubBrandMap.get(offtakes.ASI_TH_CRM_Sub_brand__c);
                        tempContractTargetId = contractTarget.Id;
                        matchBy = 'Sub-brand';
                        ID skuID = null;
                        
                        // Extra detection, need to check if the actual offtake has an actual vintage (assuming the SKU has a wine category)
                        if(offtakes.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c != null) {
                            /*[WL 15.0] BEGIN*/
                            if (offtakes.ASI_CRM_SKU__r.ASI_CRM_Latest_Vintage__c != null)
                                skuID = offtakes.ASI_CRM_SKU__r.ASI_CRM_Latest_Vintage__c;
                            else 
                                skuID = offtakes.ASI_CRM_SKU__c;
                            /*if(offtakes.ASI_CRM_Latest_Vintage__c != null) {
                                skuID = offtakes.ASI_CRM_Latest_Vintage__c;
                            } else {
                                continue; // dont generate a free goods if the offtake sku is a a wine category and there is no latest vintage
                            }*/
                            /*[WL 15.0] END*/
                        } else {
                            skuID = contractTarget.ASI_CRM_SKU__c; // Normal scenario without any wine category
                        }
                        relatedSKU = this.skuMap.get(skuID);
                        
                        //Patched by Kevin on Oct 29, for fixing vol conversion issue
                        key = (String) skuID + '_' + buildKey(offtakes.ASI_CRM_FromWS__c, offtakes.ASI_CRM_SKU__c);
                        
                        ASI_MFM_SKU_Code__c offtakeSKU = this.skuMap.get(offtakes.ASI_CRM_SKU__c);
                        // Do the volume conversion
                        system.debug('Offtake: ' + offtakes.Id + ' relatedSKU ID: ' + skuID + ' Offtake SKU: ' + offtakes.ASI_CRM_SKU__c);
                        if(relatedSKU.ASI_HK_CRM_Std_Bottle_Size__c != null && offtakeSKU.ASI_HK_CRM_Std_Bottle_Size__c != null) {
                            volumeConversion = offtakeSKU.ASI_HK_CRM_Std_Bottle_Size__c/relatedSKU.ASI_HK_CRM_Std_Bottle_Size__c;
                        }
                        
                        // Get the sales Incentive
                        /* [Vincent 3.2].2 BEGIN 
                        salesIncentive = contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? contractTarget.ASI_CRM_SG_Sales_Incentive__c : 0;
                        */
                        ASI_MFM_SKU_Code__c contractTargetSKU = this.skuMap.get(contractTarget.ASI_CRM_SKU__c);
                        packagingSize = contractTargetSKU.ASI_HK_CRM_Packaging_Size__c != null ? contractTargetSKU.ASI_HK_CRM_Packaging_Size__c : 0;
                        /* [Vincent 4.0] BEGIN */
                        /*
                        salesIncentive = packagingSize == 0 ? 0 : (contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? (contractTarget.ASI_CRM_SG_Sales_Incentive__c/packagingSize) : 0);
                        */
                        salesIncentive = contractTarget.ASI_CRM_SG_Sales_Incentive__c != null ? contractTarget.ASI_CRM_SG_Sales_Incentive__c : 0;
                        /* [Vincent 4.0] END */
                        /* [Vincent 3.2].2 END */
                        
                    }
                }
                
                // If any rules are detected from the logic above: add up the offtake quantity together and store the volume coefficient
                if(key != '') {
                    
                    // Add up the offtake together and store it in the offtakeQuantityMap
                    // It will be used to do the calculation on the second loop pass
                    Decimal offtakeQty = 0;
                    
                    // Sub-brand or wine category case where offtake sku does not have same volume as free goods sku
                    if(volumeConversion != 1) {
                        offtakeQty = offtakeWrap.offtakeQuantityWithConversionMap.containsKey(key) ? offtakeWrap.offtakeQuantityWithConversionMap.get(key) : 0;
                        offtakeQty += offtakes.ASI_TH_CRM_Quantity__c == null ? 0 : offtakes.ASI_TH_CRM_Quantity__c;
                        offtakeWrap.skuIDConversionMap.put(key, offtakes.ASI_CRM_SKU__c);
                        offtakeWrap.salesIncentiveWithConversionMap.put(key, salesIncentive);
                        /* [Vincent 4.0] BEGIN */
                        offtakeWrap.packageSizeWithConversionMap.put(key, packagingSize);
                        /* [Vincent 4.0] END */
                        offtakeWrap.volumeConversionMap.put(key, volumeConversion);
                        offtakeWrap.offtakeQuantityWithConversionMap.put(key, offtakeQty);
						
						string tempKey = key.split('_')[0] + '_' + key.split('_')[1];
						offtakeWrap.packageSizeMap.put(tempKey, packagingSize);
                    } else {
                        //Patched by Kevin on 1 Nov, keep the key as SKUID + WSID because all offtake SKUs do not need conversion despite their SKU code may differ
                        //This is also for solving the missing royal salute issue discovered on 30 Oct
                        key = key.split('_')[0] + '_' + key.split('_')[1];
                        offtakeQty = offtakeWrap.offtakeQuantityMap.containsKey(key) ? offtakeWrap.offtakeQuantityMap.get(key) : 0;
                        offtakeQty += offtakes.ASI_TH_CRM_Quantity__c == null ? 0 : offtakes.ASI_TH_CRM_Quantity__c;
                        offtakeWrap.offtakeQuantityMap.put(key, offtakeQty);
                        offtakeWrap.salesIncentiveMap.put(key, salesIncentive);
                        /* [Vincent 4.0] BEGIN */
                        offtakeWrap.packageSizeMap.put(key, packagingSize);
                        /* [Vincent 4.0] END */
                    }

                    System.debug(logginglevel.INFO,'########################## + offtakes ' + offtakes);
                    System.debug(logginglevel.INFO,'########################## + offtakeQty ' + offtakeQty + ' key ' + key);
                    System.debug(logginglevel.INFO,'########################## + offtakes ' + offtakes);

                    //Patched by Kevin - 29 Oct
                    if(key.length() <= 37) {
                        offtakeWrap.uniqueKeys.add(key);
                    }
                    else {
                        key = key.split('_')[0] + '_' + key.split('_')[1];
                        offtakeWrap.uniqueKeys.add(key);
                    }

                    key = contractID + '_' + key;

                    Map<Id, List<String>> contractTargetOfftakeMap;
                    if(offtakeWrap.uniqueKeyContractTargetOfftakeMap.containsKey(key)) {
                        contractTargetOfftakeMap = offtakeWrap.uniqueKeyContractTargetOfftakeMap.get(key);
                    } else {
                        contractTargetOfftakeMap = new Map<Id, List<String>>();
                    }

                    List<String> actualOfftakeIdList;
                    if(contractTargetOfftakeMap.containsKey(tempContractTargetId)) {
                        actualOfftakeIdList = contractTargetOfftakeMap.get(tempContractTargetId);
                    } else {
                        actualOfftakeIdList = new List<String>();
                    }
                    actualOfftakeIdList.add(offtakes.Id + '_' + matchBy);
                    contractTargetOfftakeMap.put(tempContractTargetId, actualOfftakeIdList);
                    offtakeWrap.uniqueKeyContractTargetOfftakeMap.put(key, contractTargetOfftakeMap);
                }
                
            }
            
            // Special loop to calculate the conversion SKU together if there is any
            for(String key : offtakeWrap.offtakeQuantityWithConversionMap.keyset()) {
                
                // Special case where the conversion is needed
                Decimal offtakeQtyWithConversion = offtakeWrap.offtakeQuantityWithConversionMap.containsKey(key) ? offtakeWrap.offtakeQuantityWithConversionMap.get(key) : 0;
                Decimal requestQtyWithConversion = offtakeWrap.requestQtyWithConversionMap.containsKey(key) ? offtakeWrap.requestQtyWithConversionMap.get(key) : 0;
                Decimal volCoefficient = offtakeWrap.volumeConversionMap.containsKey(key) ? offtakeWrap.volumeConversionMap.get(key) : 1;
                Decimal salesIncentiveWithConversion = offtakeWrap.salesIncentiveWithConversionMap.containsKey(key) ? offtakeWrap.salesIncentiveWithConversionMap.get(key) : 0;
                /* [Vincent 4.0] BEGIN */
                Decimal packageSizeWithConversion = offtakeWrap.packageSizeWithConversionMap.containsKey(key) ? offtakeWrap.packageSizeWithConversionMap.get(key) : 0;
                /* [Vincent 4.0] END */
                
                ID skuID = key.split('_')[0];
                ASI_MFM_SKU_Code__c freeGoodsSKUVolConv = skuMap.get(skuID);
                Decimal skuCaseSizeVolConv = freeGoodsSKUVolConv.ASI_HK_CRM_Packaging_Size__c != null ? freeGoodsSKUVolConv.ASI_HK_CRM_Packaging_Size__c : 1;
                /* [Vincent 3.2].5 BEGIN 
                requestQtyWithConversion += volCoefficient * salesIncentiveWithConversion * (offtakeQtyWithConversion/skuCaseSizeVolConv);
                */
                /* [Vincent 4.0] BEGIN */
                /*
                requestQtyWithConversion += volCoefficient * salesIncentiveWithConversion * (offtakeQtyWithConversion);
                */
                requestQtyWithConversion += packageSizeWithConversion == 0 ? 0 : volCoefficient * salesIncentiveWithConversion * (offtakeQtyWithConversion) / packageSizeWithConversion;
                /* [Vincent 4.0] END */
                
                /* [Vincent 3.2].5 END */
                System.debug(logginglevel.INFO,'########################## + requestQtyWithConversion ' + requestQtyWithConversion);
                offtakeWrap.requestQtyWithConversionMap.put(key, requestQtyWithConversion);
                
            }
            
            //Patched by Kevin 29 Oct
            //Special loop to group the converted SKU offtake qty by SKU ID+WS ID
            
            /* [Vincent 3.0] BEGIN 
            for(String key : offtakeWrap.offtakeQuantityWithConversionMap.keyset()) {
                if(offtakeWrap.offtakeQuantityWithConversionMap.containsKey(key.split('_')[0] + '_' + key.split('_')[1])){
                    offtakeWrap.offtakeQuantityWithConversionMap.put(key.split('_')[0] + '_' + key.split('_')[1], offtakeWrap.offtakeQuantityWithConversionMap.get(key.split('_')[0] + '_' + key.split('_')[1]) + offtakeWrap.offtakeQuantityWithConversionMap.remove(key));
                } else {
                    offtakeWrap.offtakeQuantityWithConversionMap.put(key.split('_')[0] + '_' + key.split('_')[1], offtakeWrap.offtakeQuantityWithConversionMap.remove(key));
                }             
            } 
            */      
            for(String key : offtakeWrap.offtakeQuantityWithConversionMap.keyset()) {
                if(offtakeWrap.offtakeQuantityWithConversionMap.containsKey(key.split('_')[0] + '_' + key.split('_')[1]) && key!=(key.split('_')[0] + '_' + key.split('_')[1])){
                    offtakeWrap.offtakeQuantityWithConversionMap.put(key.split('_')[0] + '_' + key.split('_')[1], offtakeWrap.offtakeQuantityWithConversionMap.get(key.split('_')[0] + '_' + key.split('_')[1]) + offtakeWrap.offtakeQuantityWithConversionMap.remove(key));
                } else {
                    offtakeWrap.offtakeQuantityWithConversionMap.put(key.split('_')[0] + '_' + key.split('_')[1], offtakeWrap.offtakeQuantityWithConversionMap.remove(key));
                }             
            }    
            /* [Vincent 3.0] END */  
 
            //Patched by Kevin 29 Oct
            //Special loop to group the converted SKU request qty by SKU ID+WS ID
            /* [Vincent 3.1] BEGIN 
            for(String key : offtakeWrap.requestQtyWithConversionMap.keyset()) {
                if(offtakeWrap.requestQtyWithConversionMap.containsKey(key.split('_')[0] + '_' + key.split('_')[1])){
                    offtakeWrap.requestQtyWithConversionMap.put(key.split('_')[0] + '_' + key.split('_')[1], offtakeWrap.requestQtyWithConversionMap.get(key.split('_')[0] + '_' + key.split('_')[1]) + offtakeWrap.requestQtyWithConversionMap.remove(key));
                } else {
                    offtakeWrap.requestQtyWithConversionMap.put(key.split('_')[0] + '_' + key.split('_')[1], offtakeWrap.requestQtyWithConversionMap.remove(key));
                }             
            }   
            */
            for(String key : offtakeWrap.requestQtyWithConversionMap.keyset()) {
                if(offtakeWrap.requestQtyWithConversionMap.containsKey(key.split('_')[0] + '_' + key.split('_')[1]) && key!=(key.split('_')[0] + '_' + key.split('_')[1])){
                    offtakeWrap.requestQtyWithConversionMap.put(key.split('_')[0] + '_' + key.split('_')[1], offtakeWrap.requestQtyWithConversionMap.get(key.split('_')[0] + '_' + key.split('_')[1]) + offtakeWrap.requestQtyWithConversionMap.remove(key));
                } else {
                    offtakeWrap.requestQtyWithConversionMap.put(key.split('_')[0] + '_' + key.split('_')[1], offtakeWrap.requestQtyWithConversionMap.remove(key));
                }             
            }   
            /* [Vincent 3.1] END */
            
            // Second loop to calculate the requestQtyMap 
            // Loop through the detected sku_ws keys that matched the rules
            Set<String> uniqueKeysTemp = offtakeWrap.uniqueKeys;
            System.debug(logginglevel.INFO,'########################## + uniqueKeysTemp ' + uniqueKeysTemp);
            System.debug(logginglevel.INFO,'************************** + offtakeQuantityMap ' + offtakeWrap.offtakeQuantityMap);
            System.debug(logginglevel.INFO,'!!!!!!!!!!!!!!!!!!!!!!!!!! + requestQtyMap ' + offtakeWrap.requestQtyMap);
            
            for(String key : uniqueKeysTemp) {
                // This loop will add/calculate the offtake request quantity and carry over based on the wrapper information
                System.debug(logginglevel.INFO,'########################## + key ' + key);
                // split the key string knowing the the key structure is sku_ws
                ID skuID = key.split('_')[0];
                ASI_MFM_SKU_Code__c freeGoodsSKU = skuMap.get(skuID);
                
                // Retrieve the figures needed to calculate the request qty
                Decimal offtakeQty = offtakeWrap.offtakeQuantityMap.containsKey(key) ? offtakeWrap.offtakeQuantityMap.get(key) : 0;
                System.debug(logginglevel.INFO,'########################## + offtakeQtyTotal ' + offtakeQty);

                Decimal salesIncentive = offtakeWrap.salesIncentiveMap.containsKey(key) ? offtakeWrap.salesIncentiveMap.get(key) : 0;
                /* [Vincent 4.0] BEGIN */
                Decimal packageSize = offtakeWrap.packageSizeMap.containsKey(key) ? offtakeWrap.packageSizeMap.get(key) : 0;
                /* [Vincent 4.0] END */
                System.debug(logginglevel.INFO,'########################## + salesIncentiveMap ' + salesIncentive);
                Decimal skuCaseSize = freeGoodsSKU.ASI_HK_CRM_Packaging_Size__c != null ? freeGoodsSKU.ASI_HK_CRM_Packaging_Size__c : 1;
                System.debug(logginglevel.INFO,'########################## + skuCaseSize ' + skuCaseSize);
                // requestQty result
                Decimal requestQty = offtakeWrap.requestQtyMap.containsKey(key) ? offtakeWrap.requestQtyMap.get(key) : 0;
                /* [Vincent 3.2].3 BEGIN 
                requestQty += salesIncentive * (offtakeQty/skuCaseSize);
                */
                /* [Vincent 4.0] BEGIN */
                /*
                salesIncentive * (offtakeQty);
                */
                 requestQty += packageSize == 0 ? 0 : salesIncentive * (offtakeQty) / packageSize;
                /* [Vincent 4.0] END */
               
                /* [Vincent 3.2].3 END */
                System.debug(logginglevel.INFO,'########################## + requestQty ' + requestQty);
                // Resave the value back to the map
                offtakeWrap.requestQtyMap.put(key, requestQty);
                //if(key.split('_')[0] == 'a7HM00000008yMj'){
                    System.debug(logginglevel.INFO,'------------------------------------------------------------------------------------------------- + requestQty of ' + key.split('_')[0] + ': '+ requestQty);
                //}
            }
            
            // Third loop to calculate the carryOverMap and make the requestQtyMap a whole number
            for(String key : uniqueKeysTemp) {
                
                // Combine the requestQtyMap with the requestQtyWithConversion and the offtakeQtyWithConversion with the offtakeQuantityMap
                Decimal offtakeQtyWithConversion = offtakeWrap.offtakeQuantityWithConversionMap.containsKey(key) ? offtakeWrap.offtakeQuantityWithConversionMap.get(key) : 0;
                Decimal requestQtyWithConversion = offtakeWrap.requestQtyWithConversionMap.containsKey(key) ? offtakeWrap.requestQtyWithConversionMap.get(key) : 0;
                Decimal offtakeQty = offtakeWrap.offtakeQuantityMap.containsKey(key) ? offtakeWrap.offtakeQuantityMap.get(key) : 0;
                Decimal requestQty = offtakeWrap.requestQtyMap.containsKey(key) ? offtakeWrap.requestQtyMap.get(key) : 0;
                Decimal requestQtyTotal = requestQty + requestQtyWithConversion;
                Decimal offtakeQtyTotal = offtakeQty + offtakeQtyWithConversion;
                
                Decimal requestWholeQty = requestQtyTotal.round(System.RoundingMode.FLOOR);
                Decimal carryOver = requestQtyTotal - requestWholeQty;
                
                // Resave the value back to the map
                offtakeWrap.requestQtyMap.put(key, requestWholeQty);
                offtakeWrap.offtakeQuantityMap.put(key, offtakeQtyTotal);

                // Special case: if the SKU has a wine category, create a key with a wine category instead
                ID skuID = key.split('_')[0];
                ID wsID = key.split('_')[1];
                ASI_MFM_SKU_Code__c freeGoodsSKU = skuMap.get(skuID);
                if(freeGoodsSKU.ASI_CRM_SG_Wine_Category__c != null) {
                    String keyTemp = buildKey(freeGoodsSKU.ASI_CRM_SG_Wine_Category__c, wsID);
                    offtakeWrap.carryOverMap.put(keyTemp, carryOver);
                } else {
                    offtakeWrap.carryOverMap.put(key, carryOver);
                }
                
            }

            // Fourth loop to generate the carry overs if there is any any
            for(String key : uniqueKeysTemp) {
                system.debug('key: ' + key);
                // split the key string knowing the the key structure is sku_ws
                ID skuID = key.split('_')[0];
                ID wsID = key.split('_')[1];
                
                ASI_MFM_SKU_Code__c freeGoodsSKU = skuMap.get(skuID);
                
                // Final result of the request qty calculation and carry over
                Decimal requestQty = offtakeWrap.requestQtyMap.containsKey(key) ? offtakeWrap.requestQtyMap.get(key) : 0;
                Decimal carryOver = 0;
                ID wineCategoryID;
                String keyWineCategory = '';

                // Special case: detect if the free goods sku has a wine category, if yes, then build the carry over to be with that wine category
                if(freeGoodsSKU.ASI_CRM_SG_Wine_Category__c != null) {
                    keyWineCategory = buildKey(freeGoodsSKU.ASI_CRM_SG_Wine_Category__c, wsID);
                    carryOver = offtakeWrap.carryOverMap.containsKey(keyWineCategory) ? offtakeWrap.carryOverMap.get(keyWineCategory) : 0;
                    wineCategoryID = freeGoodsSKU.ASI_CRM_SG_Wine_Category__c;
                } else {
                    carryOver = offtakeWrap.carryOverMap.containsKey(key) ? offtakeWrap.carryOverMap.get(key) : 0;
                }
				
                // Carry over to update or insert depending if it is contained in the carryOverMap
				/*[WL 13.0] BEGIN*/
				string latestSKUkey = buildKey(skuMappingMap.containsKey(skuID) ? skuMappingMap.get(skuID) : skuId, wsID);
				
				
                ASI_CRM_SG_FOC_Carry_Over__c oldCarryOverItem = offtakeWrap.focCarryOverMap.containsKey(keyWineCategory) ? offtakeWrap.focCarryOverMap.get(keyWineCategory) 
                                                    : (
                                                        offtakeWrap.focCarryOverMap.containsKey(latestSKUkey) 
                                                        ? 
                                                        offtakeWrap.focCarryOverMap.get(latestSKUkey) 
                                                        :  
                                                        new ASI_CRM_SG_FOC_Carry_Over__c()
                                                    );
                /*[WL 13.0] END*/
				
				ASI_CRM_SG_FOC_Carry_Over__c CarryOverItem = new ASI_CRM_SG_FOC_Carry_Over__c();
                
				system.debug('oldCarryOverItem: ' + oldCarryOverItem + ' keyWineCategory: ' + keyWineCategory + ' key:' + latestSKUkey + ' offtakeWrap.focCarryOverMap: ' + offtakeWrap.focCarryOverMap);
				
                // if the carry over exist previously
                if(oldCarryOverItem.id != null) {
                    carryOver += oldCarryOverItem.ASI_CRM_SG_Carry_Over__c != null ? oldCarryOverItem.ASI_CRM_SG_Carry_Over__c : 0;
                    // Detect if the sum of the carry over reaches a whole number
                    Decimal carryOverWhole = carryOver.round(System.RoundingMode.FLOOR);
                    if(carryOverWhole > 0) {
                        requestQty += carryOverWhole;
                        /*[WL 1.0 ] BEGIN*/
                        //carryOver = carryOverWhole - carryOver;
                        carryOver = carryOver - carryOverWhole;
                        /*[WL 1.0 ] END*/
                    }
                }
                
                // Avoid negative number where the scale is beyond 2 decimal points
                carryOver = carryOver.setScale(2, RoundingMode.HALF_UP);

                // Fill the fields of the carryOverItem
                carryOverItem.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_SG_FOC_Carry_Over__cASI_CRM_SG_FOC_Carry_Over');
                /* [HC 1.0] BEGIN */
                carryOverItem.ASI_CRM_SG_SKU__c = skuMappingMap.containsKey(skuID) ? skuMappingMap.get(skuID) : skuId;
                /* [HC 1.0] END */
                carryOverItem.ASI_CRM_SG_Outlet__c = offtakeWrap.OutletID;
                carryOverItem.ASI_CRM_SG_Month__c = Integer.valueOf(offtakeWrap.Month);
                carryOverItem.ASI_CRM_SG_Year__c = offtakeWrap.Year;
                carryOverItem.ASI_CRM_SG_Carry_Over__c = carryOver;
                carryOverItem.ASI_CRM_SG_Contract__c = offtakeWrap.contractHeader.id;
                carryOverItem.ASI_CRM_SG_Wholesaler__c = wsID;
                carryOverItem.ASI_CRM_SG_Wine_Category__c = wineCategoryID;
                /* [VL 9.0] BEGIN */
                carryOverItem.ownerid = this.contractOwnerid;
                /* [VL 9.0] END */
                
                // Some Actual Offtakes quantity can be negative, ignore negative carry overs
                if(carryOverItem.id == null && carryOver >= 0) {
                    carryOverToInsert.add(carryOverItem);
                } 
                
                // Free Goods header generation depends if at least one request qty is > 0. The code below will generate the Free Goods Header
                // There is only one Free Goods Header per contract per month per year
                // The request items of this free goods will get generated on a separate loop
                if(!freeGoodsHeaderToInsert.containsKey(offtakeWrap.contractHeader.id)) {
                    if(requestQty > 0) {
                        // Generate a Free Good Header if theres a request Item to generate
                        ASI_FOC_Free_Goods_Request__c freeGoodHeader = new ASI_FOC_Free_Goods_Request__c
                        (
                            recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC'),
                            ASI_CRM_SG_System_Generated__c = true,
                            ASI_CRM_Outlet__c = offtakeWrap.OutletID,
                            ASI_CRM_Contract__c = offtakeWrap.contractHeader.id,
                            ASI_CRM_SG_Year__c = offtakeWrap.Year,
                            ASI_CRM_SG_Month__c = offtakeWrap.Month,
                            ASI_FOC_Request_Status__c = 'Draft'
                            /* [VL 9.0] BEGIN */
                            , ownerid = this.contractOwnerid
                            /* [VL 9.0] END */
                        );
                        
                        freeGoodsHeaderToInsert.put(offtakeWrap.contractHeader.id, freeGoodHeader);
                    }
                }
                
                // Resave the requestQty just in case a carry over adds up to one whole number
                offtakeWrap.requestQtyMap.put(key, requestQty);
                
            }
            
            // Resave the new offtakewrapper record in the persistent offtakeWrapperMap
            offtakeWrapperMap.put(contractID, offtakeWrap);
        }
        
        // Initial save
        if(freeGoodsHeaderToInsert.size() > 0) {
            insert freeGoodsHeaderToInsert.values();
        }
        
        if(carryOverToInsert.size() > 0) {
			/*[WL 13.0] BEGIN*/
			List<ASI_CRM_SG_FOC_Carry_Over__c> existingLatestCarryOver = [select ASI_CRM_SG_Month__c, ASI_CRM_SG_Year__c from ASI_CRM_SG_FOC_Carry_Over__c 
				where ASI_CRM_SG_Contract__c = :carryOverToInsert.get(0).ASI_CRM_SG_Contract__c order by ASI_CRM_SG_Year__c, ASI_CRM_SG_Month__c desc];
			
			system.debug('existingLatestCarryOver: ' + existingLatestCarryOver);
			system.debug('carryOverToInsert.get(0): ' + carryOverToInsert.get(0));
			
			if (existingLatestCarryOver.size() > 0){
				//If there is existing carry over, skip insert this carry over if existing one is in later month
				if (existingLatestCarryOver.get(0).ASI_CRM_SG_Year__c < carryOverToInsert.get(0).ASI_CRM_SG_Year__c 
					|| existingLatestCarryOver.get(0).ASI_CRM_SG_Year__c == carryOverToInsert.get(0).ASI_CRM_SG_Year__c && existingLatestCarryOver.get(0).ASI_CRM_SG_Month__c < carryOverToInsert.get(0).ASI_CRM_SG_Month__c){
				
					insert carryOverToInsert;
				}
			}
			else {
				//If no existing carry over, insert the current one
				insert carryOverToInsert;
			}
			/*[WL 13.0] END*/
        }
        
        if(carryOverToUpdate.size() > 0) {
            update carryOverToUpdate;
        }
        
        // Last loop: generate the request items
        for(ID contractID : freeGoodsHeaderToInsert.keyset()) {
            
            // Freshly inserted free goods header record
            ASI_FOC_Free_Goods_Request__c freeGoods = freeGoodsHeaderToInsert.get(contractID);
            
            offtakeWrapper offtakeWrap = offtakeWrapperMap.get(contractID);
            Set<String> uniqueKeysTemp = offtakeWrap.uniqueKeys;
            
            
                        
            //Loop through the unique keys again and identify which requestQty needs to get generated
            for(String key : uniqueKeysTemp) {
				Decimal packageSize = offtakeWrap.packageSizeMap.containsKey(key) ? offtakeWrap.packageSizeMap.get(key) : 1;
				
                // split the key string knowing the the key structure is sku_ws
                ID skuID = key.split('_')[0];
                ID wsID = key.split('_')[1];
                
                skuID = skuMappingMap.containsKey(skuID) ? skuMappingMap.get(skuID) : skuId;
                
                /* [VL 6.0] BEGIN */
                Decimal price_PRS_WS = 0;
                Decimal price_WS_OT = 0;
                Decimal cost_IGC = 0;
                Decimal cost_Duty = 0;
                Decimal cost_FOB = 0;
                Decimal cost_Handling = 0;
                if(this.map_contractID_type_SkuPrice.containsKey(contractID)) {                    
                    Map<id,Map<string, ASI_CRM_MY_SKUPriceCost__c>> map_sku_type_skuPrice = this.map_contractID_type_SkuPrice.get(contractID);
                    
                    if (map_sku_type_skuPrice.containsKey(skuID)){
                        Map<string, ASI_CRM_MY_SKUPriceCost__c> map_type_skuPrice = map_sku_type_skuPrice.get(skuID);
                        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWS = map_type_skuPrice.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') ? map_type_skuPrice.get('ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler') : new ASI_CRM_MY_SKUPriceCost__c();
                        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostWSOnTrade = map_type_skuPrice.containsKey('ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade') ? map_type_skuPrice.get('ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade') : new ASI_CRM_MY_SKUPriceCost__c();
                        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostIGC = map_type_skuPrice.containsKey('ASI_CRM_SG_IGC') ? map_type_skuPrice.get('ASI_CRM_SG_IGC') : new ASI_CRM_MY_SKUPriceCost__c();
                        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostDuty = map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_Duty_Per_Bottle') ? map_type_skuPrice.get('ASI_CRM_SG_CRM_Duty_Per_Bottle') : new ASI_CRM_MY_SKUPriceCost__c();
                        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostFob = map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_FOB_Per_Bottle') ? map_type_skuPrice.get('ASI_CRM_SG_CRM_FOB_Per_Bottle') : new ASI_CRM_MY_SKUPriceCost__c();
                        ASI_CRM_MY_SKUPriceCost__c skuHistoricCostHandlingCost = map_type_skuPrice.containsKey('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') ? map_type_skuPrice.get('ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle') : new ASI_CRM_MY_SKUPriceCost__c();
                        
                        price_PRS_WS = skuHistoricCostWS.ASI_CRM_Price__c != null ? skuHistoricCostWS.ASI_CRM_Price__c : 0;
                        price_WS_OT = skuHistoricCostWSOnTrade.ASI_CRM_Price__c != null ? skuHistoricCostWSOnTrade.ASI_CRM_Price__c : 0;
                        cost_IGC = skuHistoricCostIGC.ASI_CRM_Cost__c != null ? skuHistoricCostIGC.ASI_CRM_Cost__c : 0;
                        cost_Duty = skuHistoricCostDuty.ASI_CRM_Cost__c != null ? skuHistoricCostDuty.ASI_CRM_Cost__c : 0;
                        cost_FOB = skuHistoricCostFob.ASI_CRM_Cost__c != null ? skuHistoricCostFob.ASI_CRM_Cost__c : 0;
                        cost_Handling = skuHistoricCostHandlingCost.ASI_CRM_Cost__c != null ? skuHistoricCostHandlingCost.ASI_CRM_Cost__c : 0;
                    }
                }
                /* [VL 6.0] END */
            
                
                
                // Final result of the request qty calculation and carry over
                Decimal requestQty = offtakeWrap.requestQtyMap.containsKey(key) ? offtakeWrap.requestQtyMap.get(key) : 0;
                Decimal actualOfftakeQty = offtakeWrap.offtakeQuantityMap.containsKey(key) ? offtakeWrap.offtakeQuantityMap.get(key) : 0;
                
                // If request qty is over 0, then need a request item to generate
                if(requestQty > 0) {
                    ASI_FOC_Request_Item__c requestItem = new ASI_FOC_Request_Item__c 
                    (
                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_SG_CRM_Request_Items'),
                        ASI_FOC_Request_Order__c = freeGoods.id,
                        /* [HC 1.0] BEGIN */
                        ASI_FOC_SKU__c = skuId,
                        /* [HC 1.0] END */
                        ASI_FOC_Request_Quantity_Bottle__c = requestQty,
                        ASI_FOC_Actual_Quantity_Bottle__c = requestQty,
                        ASI_CRM_Offtake_Quantity__c = actualOfftakeQty,
                        ASI_CRM_SG_A_G_Code__c = '0023',
                        ASI_CRM_SG_FOC_Type__c = 'Sales Incentive',
                        /* [VL 6.0] BEGIN */
                        /*
                        ASI_CRM_SG_Unit_Price__c = skuPriceHistoricCostMap.get(skuID),
                        */
                        ASI_CRM_SG_Unit_Price__c = price_PRS_WS,
                        ASI_CRM_Duty_Per_Bottle__c = cost_Duty,
                        ASI_CRM_FOB_Per_Bottle__c = cost_FOB,
                        ASI_CRM_Handling_Cost_Per_Bottle__c = cost_Handling,
                        ASI_CRM_IGC_Cost_Per_case__c = cost_IGC,
                        ASI_CRM_Selling_Price_Btl_PRS_WS__c = price_PRS_WS,
                        ASI_CRM_Selling_Price_Btl_WS_On_Trade__c = price_WS_OT,
						ASI_FOC_Free_Good_Cost__c = cost_IGC / packageSize * requestQty,
                        /* [VL 6.0] END */
                        ASI_CRM_Wholesaler__c = wsID
                        
                        
                    );
                    
                    requestLineItemToInsert.put(contractID + '_' + key, requestItem);
                }
                
            }
            
        }
        
        // Insert the request items if any
        if(requestLineItemToInsert.size() > 0) {
            insert requestLineItemToInsert.values();
        }
        
		/* [VL 11.0]
        for(String key : requestLineItemToInsert.keySet()) {
            ASI_FOC_Request_Item__c requestItem = requestLineItemToInsert.get(key);
            String contractId = key.split('_')[0];
            offtakeWrapper offtakeWrap = offtakeWrapperMap.get(contractId);
            if(offtakeWrap.uniqueKeyContractTargetOfftakeMap.containsKey(key)) {
                Map<Id, List<String>> contractTargetOfftakeMap = offtakeWrap.uniqueKeyContractTargetOfftakeMap.get(key);
                for(Id contractTargetId : contractTargetOfftakeMap.keySet()) {
                    List<String> actualOfftakeList = contractTargetOfftakeMap.get(contractTargetId);
                    for(String actualOfftakeMatchBy : actualOfftakeList) {
                        String actualOfftake = actualOfftakeMatchBy.split('_')[0];
                        String matchBy = actualOfftakeMatchBy.split('_')[1];
                        ASI_CRM_FOC_Linkage__c focLinkage = new ASI_CRM_FOC_Linkage__c();
                        focLinkage.ASI_CRM_Actual_Offtake__c   = actualOfftake;
                        focLinkage.ASI_CRM_Contract_Target__c  = contractTargetId;
                        focLinkage.ASI_CRM_FOC_Request_Item__c = requestItem.Id;
                        focLinkage.ASI_CRM_Match_By__c         = matchBy;
                        insertFOCLinkageList.add(focLinkage);
                    }
                }
            }
        }

        System.debug(logginglevel.INFO,'########################## + insertFOCLinkageList ' + insertFOCLinkageList);

        if(insertFOCLinkageList.size() > 0) {
            insert insertFOCLinkageList;
        }
		*/

        
        /* [VL 7.0] BEGIN */
        ASI_CRM_SG_ROI_Helper roi = new ASI_CRM_SG_ROI_Helper(this.offtakeWrapperMap.keyset());
        roi.calculateROI();
        /* [VL 7.0] END */
        
		/* [VL 14.0] BEGIN */
        sendEMailNotification(BC.getJobId());
		/*
		Database.executeBatch(new ASI_CRM_SG_GenPromotionIncentive_Batch(this.yearGlobal,this.monthGlobal, freeGoodsHeaderToInsert.values()), 200);
		*/
		/* [VL 14.0] END */
    }
    
    /*********************************************************************************
     * Description: key Builder. Format: sku_ws
     *
     * Parameters:  sku ID
     *              Wholesaler ID
     *                     
     *
     * Return: key
     * Exception: Invalid ID
    *********************************************************************************/
    private String buildKey(ID sku, ID ws) {
        return (String)sku + '_' + (String)ws;
    }
    
    /*********************************************************************************
     * Description: Query string builder for retrieving all fields
     *
     * Parameters:  sObject api Name
     *              extraFieldQuery, for relationship queries; format: ', field__r.field__c, field2__r.field2__c'
     *                     
     *
     * Return: Query string without the where statement (to be added by user)
     * Exception: Invalid sObject api Name
    *********************************************************************************/
    private String queryAll_Builder_String(String sObjectName, String extraFieldQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' , recordtype.developername '+extraFieldQuery+' From '+sObjectName + ' ';
        
        return thequery;
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

        return skuMappingMap;
    }

    // Wrapper Class: create a helper wrapper class that stores the grouping of the Actual Offtakes
    // Each offtakeWrapper record represents and will generate one Free Goods Header 
    // IF any of the Free goods items have >= 1 requestQty
    public class offtakeWrapper {
        
        // Outlet ID. Unique for each free goods header on the same month-year relationship.
        public ID OutletID {get;set;}
        // Group all the offtakes together to each contract header. Use Map to enforce uniqueness
        public Map<ID, ASI_TH_CRM_Actual_Offtake__c> actualOfftakesMap {get;set;}
        // Store the contract header
        public ASI_TH_CRM_Contract__c contractHeader {get;set;}
        // Month of the taken offtakes
        public String Month {get;set;}
        // Year of the taken offtakes
        public String Year {get;set;}
        // Map the carry over value. The unique key is the ID of SKU + ID of WS from the offtake
        public Map<String, Decimal> carryOverMap {get;set;}
        // Map the offtake Quantity. The unique key is the ID of SKU + ID of WS from the offtake
        public Map<String, Decimal> offtakeQuantityMap {get;set;}
        // Map the request Quantity (number of free bottles to give). The unique key is the ID of SKU + ID of WS from the offtake
        public Map<String, Decimal> requestQtyMap {get;set;}
        // Set of all the keys for this particular record. The unique key is the ID of SKU + ID of WS from the offtake
        // The key will be used to either generate a request item or create a carry over, or both
        public Set<String> uniqueKeys {get;set;}
        // Map the FOC Carry Over records. The unique key is the ID of SKU + WS
        public Map<String, ASI_CRM_SG_FOC_Carry_Over__c> focCarryOverMap {get;set;}
        // Map the contractTarget BY SKU. The Unique key is the SKU ID
        public Map<ID, ASI_CRM_ContractTarget__c> contractTargetSKUMap {get;set;}
        // Map the contractTarget BY SubBrand. The Unique key is the SubBrand ID
        public Map<ID, ASI_CRM_ContractTarget__c> contractTargetSubBrandMap {get;set;}
        // Map the contractTarget BY Wine Category. The Unique key is the wine Category ID
        public Map<ID, ASI_CRM_ContractTarget__c> contractTargetWineCategoryMap {get;set;}
        // Map the Wine Category ID. The unique key is the ID of SKU + ID of WS from the offtake
        // The map will detect if any wine category is involved in the calculation
        public Map<String, ID> wineCategoryMap {get;set;}
        // The map will store the volume multiplier for each unique key. The unique key is the ID of SKU + ID of WS from the offtake
        // Default value of the key volume conversion is 1
        public Map<String, Decimal> volumeConversionMap {get;set;}
        // The map will store the sales incentive for each key. The unique key is the ID of SKU + ID of WS from the offtake
        public Map<String, Decimal> salesIncentiveMap {get;set;}
        // Need to separate the sku_ws key where the conversion has been made.
        public Map<String, Decimal> offtakeQuantityWithConversionMap {get;set;}
        // Need to separate the sku_ws key where the conversion has been made.
        public Map<String, Decimal> requestQtyWithConversionMap {get;set;}
        // Store the SKU id of the offtake if a sub-brand to sub-brand scenario happens
        public Map<String, ID> skuIDConversionMap {get;set;}
        // Store the sales incentive of the contract target for sub-brand to sub-brand scenarios
        public Map<String, Decimal> salesIncentiveWithConversionMap {get;set;}
        /* [Vincent 3.2] BEGIN */
        // The map will store the contract target package size for each key. The unique key is the ID of SKU + ID of WS from the offtake; Calculate buy X give Y with sales incentive
        public Map<String, Decimal> packageSizeMap {get;set;}
        // Store the package size of the contract target for sub-brand to sub-brand scenarios; Calculate buy X give Y with sales incentive
        public Map<String, Decimal> packageSizeWithConversionMap {get;set;}
        /* [Vincent 3.2] END */
        /* [VL 8.0] BEGIN */
        // Map the contractTarget BY SKU only. The Unique key is the new SKU ID
        public Map<ID, ASI_CRM_ContractTarget__c> contractTargetSKUMap_newSKU {get;set;}
        /* [VL 8.0] END*/
        //Structure : Map<key, Map<Contract Target Id, List<Actual Offtake Id>>>
        public Map<String, Map<Id, List<String>>> uniqueKeyContractTargetOfftakeMap {get; set;}
        
        // Constructor Initialize empty containers
        public offtakeWrapper (String monthGlobal, String yearGlobal) {
            this.OutletID = null;
            this.actualOfftakesMap = new Map<ID, ASI_TH_CRM_Actual_Offtake__c>();
            this.contractHeader = new ASI_TH_CRM_Contract__c();
            this.Month = monthGlobal;
            this.Year = yearGlobal;
            this.carryOverMap = new Map<String, Decimal>();
            this.offtakeQuantityMap = new Map<String, Decimal>();
            this.requestQtyMap = new Map<String, Decimal>();
            this.uniqueKeys = new Set<String>();
            this.focCarryOverMap = new Map<String, ASI_CRM_SG_FOC_Carry_Over__c>();
            this.contractTargetSKUMap = new Map<ID, ASI_CRM_ContractTarget__c>();
            this.contractTargetSubBrandMap = new Map<ID, ASI_CRM_ContractTarget__c>();
            this.contractTargetWineCategoryMap = new Map<Id, ASI_CRM_ContractTarget__c>();
            this.wineCategoryMap = new Map<String, ID>();
            this.volumeConversionMap = new Map<String, Decimal>();
            this.salesIncentiveMap = new Map<String, Decimal>();
            this.offtakeQuantityWithConversionMap = new Map<String, Decimal>();
            this.requestQtyWithConversionMap = new Map<String, Decimal>();
            this.skuIDConversionMap = new Map<String, ID>();
            this.salesIncentiveWithConversionMap = new Map<String, Decimal>();
            /* [Vincent 3.2] BEGIN */
            this.packageSizeMap = new Map<String, Decimal>();
            this.packageSizeWithConversionMap = new Map<String, Decimal>();
            /* [Vincent 3.2] END */
            /* [VL 8.0] BEGIN */
            this.contractTargetSKUMap_newSKU = new Map<ID, ASI_CRM_ContractTarget__c>();
            /* [VL 8.0] END*/
            this.uniqueKeyContractTargetOfftakeMap = new Map<String, Map<Id, List<String>>>();
        }
        
        // Fill the contractTarget and map them by SKU
        public void setContractTargetBySKU() {
            List<ASI_CRM_ContractTarget__c> contractTargetList = contractHeader.Contract_Target__r == null ? new List<ASI_CRM_ContractTarget__c>() : contractHeader.Contract_Target__r;
            for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
                if(contractTarget.ASI_CRM_SKU__c != null) {
                    contractTargetSKUMap.put(contractTarget.ASI_CRM_SKU__c, contractTarget);
                }
            }
        }
        
        // Fill the contractTarget and map them by SubBrand
        public void setContractTargetBySubBrand() {
            List<ASI_CRM_ContractTarget__c> contractTargetList = contractHeader.Contract_Target__r == null ? new List<ASI_CRM_ContractTarget__c>() : contractHeader.Contract_Target__r;
            for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
                if(contractTarget.ASI_CRM_Subbrand__c != null) {
                    contractTargetSubBrandMap.put(contractTarget.ASI_CRM_Subbrand__c, contractTarget);
                }
            }
        }
        
        // Fill the contractTarget and map them by Wine Category
        public void setContractTargetByWineCategory() {
            List<ASI_CRM_ContractTarget__c> contractTargetList = contractHeader.Contract_Target__r == null ? new List<ASI_CRM_ContractTarget__c>() : contractHeader.Contract_Target__r;
            for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
                if(contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c != null) {
                    contractTargetWineCategoryMap.put(contractTarget.ASI_CRM_SKU__r.ASI_CRM_SG_Wine_Category__c, contractTarget);
                }
            }
        }
        
        /* [VL 8.0] BEGIN */
        // Fill the contractTarget and map them by new SKU
        public void setContractTargetBySKU_newSKU(Map<id, id> map_newSKU) {
            List<ASI_CRM_ContractTarget__c> contractTargetList = contractHeader.Contract_Target__r == null ? new List<ASI_CRM_ContractTarget__c>() : contractHeader.Contract_Target__r;
            for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
        system.debug('---setContractTargetBySKU_newSKU contractTarget---'+contractTarget );
                if(contractTarget.ASI_CRM_SKU__c != null && contractTarget.ASI_CRM_Subbrand__c == null) {
                    if (map_newSKU.containsKey(contractTarget.ASI_CRM_SKU__c)) {
                        contractTargetSKUMap_newSKU.put(map_newSKU.get(contractTarget.ASI_CRM_SKU__c), contractTarget);
                    }
                }
            }
        system.debug('---setContractTargetBySKU_newSKU contractTargetSKUMap_newSKU---'+contractTargetSKUMap_newSKU);
        }
        /* [VL 8.0] END */
        
    }
    
    public void sendEMailNotification(Id BC_ID){
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
       mail.setSubject('Free Goods Request Generation Completed ' + a.Status);
       mail.setPlainTextBody
       ('The Free Goods Request generation for ' + this.yearGlobal + '-' + this.monthGlobal + 
       ' completed with '+ a.NumberOfErrors + ' errors.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}