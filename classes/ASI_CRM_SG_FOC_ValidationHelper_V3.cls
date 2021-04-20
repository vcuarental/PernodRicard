/*********************************************************************************
 * Name: ASI_CRM_SG_FOC_ValidationHelper_V3
 * Description: Validation Helper for volume Exceed between FOC and Contract 
 * (Version 3: to validate focs against the contract target by sub-brand)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-02-23       Laputa: Vincent Lam     Created
 * 2017-06-07       Wilken Lee              [WL 1.0] Marketing FOC SKU's Sub-brand does not need to be defined in Contract Target 
 * 2017-11-23       Wilken Lee              [WL 2.0] Add validation for A&P Fund FOC volume
 * 2018-01-23       Wilken Lee              [WL 3.0] Disable FOC Sub-brand validation for adhoc promotion type
 */
 
 public class ASI_CRM_SG_FOC_ValidationHelper_V3 {
 
    private boolean isFOCObject {get;set;}
    
    private List<ASI_FOC_Request_Item__c> focItemList {get;set;}
    private List<ASI_FOC_Free_Goods_Request__c> focHeaderList {get;set;}
    
    private List<ASI_CRM_ContractTarget__c> contractTargetItemList {get;set;}
    
    private List<sObject> headerObject {get;set;}
    private List<sObject> sObjList {get;set;}
    
    private Map<ID, List<ASI_FOC_Request_Item__c>> contract_FOCItemListMap {get;set;}
    private Map<ID, List<ASI_CRM_ContractTarget__c>> contract_ContractTargetListMap {get;set;}
    private Map<ID, String> contract_Name_Map {get;set;}

    private Map<ID, String> sku_NameMap {get;set;}
    
    private Map<ID, Decimal> sku_BottleVolume_Map {get;set;}
    
    private Date currentOrderDate;
    private Boolean isSalesIncentive = false;
    
    public Map<ID, Boolean> map_header_isSampling = new Map<ID, Boolean>();
    public Map<ID, Map<ID, Decimal>> map_header_sku_samplingBottle = new Map<ID, Map<ID, Decimal>>();
    public Map<ID, ASI_FOC_Free_Goods_Request__c> map_focID_focHeader = new Map<ID, ASI_FOC_Free_Goods_Request__c>();
    public Map<ID, ID> map_focID_contractHeader = new Map<ID, ID>();
    
    private Map<ID, Map<ID, List<ASI_FOC_Request_Item__c>>> contract_subBrand_FOCListMap {get;set;}
    private Map<ID, Map<ID, List<ASI_CRM_ContractTarget__c>>> contract_subBrand_ContractTargetListMap {get;set;}
    private Map<ID, String> subBrand_NameMap {get;set;}
    private Map<String, String> map_skuID_subBrandID {get;set;}
    private Map<String, decimal> map_skuID_bottleSize {get;set;}
    
    private Set<ID> contractSubrandIDSet {get;set;}
    private Set<ID> focSubBRandIDSet {get;set;}
    
	private static final String CONTRACTTARGET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';

    // constructor to cater multiple headers
    public ASI_CRM_SG_FOC_ValidationHelper_V3 (boolean isFOC, List<sObject> header, List<sObject> sObList) {
        this.isFOCObject = isFOC;
        this.headerObject = header;
        this.sObjList = sObList;
        initiator();
    }
    
    // constructor to cater single header
    public ASI_CRM_SG_FOC_ValidationHelper_V3 (boolean isFOC, sObject header, List<sObject> sObList) {
        this.isFOCObject = isFOC;
        this.headerObject = new List<sObject>();
        this.headerObject.add(header);
        this.sObjList = sObList;
        initiator();
    }
	
    public void initiator () {
        this.contractSubrandIDSet = new Set<ID>();
        this.focSubBRandIDSet = new Set<ID>();
        this.focItemList = new List<ASI_FOC_Request_Item__c>();
        this.contractTargetItemList = new List<ASI_CRM_ContractTarget__c>();
        
		//2017-12-04 Wilken
        //if(this.isFOCObject != null && this.headerObject != null && this.sObjList != null
		if(this.isFOCObject != null && this.headerObject != null
		) {
			//2017-12-04 Wilken
            //if(this.sObjList.size() > 0 && this.isFOCObject) {
			if(this.isFOCObject) {
                initData();
                System.debug('Initialize data');
            }
        }
    }
    
    public void initData() {
    
        ID contractHeaderID = null;
        ID focRequestTempid = null;
        List<ID> contractHeaderID_List = new List<ID>();
        List<ID> focRequestTempid_List = new List<ID>();
        List<ASI_FOC_Request_Item__c> focItemListTemp = new List<ASI_FOC_Request_Item__c>();
        List<ASI_CRM_ContractTarget__c> contractTargetListTemp0 = new List<ASI_CRM_ContractTarget__c>();
        
        if(isFOCObject) {
            focItemListTemp = (List<ASI_FOC_Request_Item__c>)sObjList;
            for (ASI_FOC_Request_Item__c focItemList : focItemListTemp) {
                if (focItemList.ASI_CRM_SG_FOC_Type__c == 'Sales Incentive') this.isSalesIncentive = true;
            }
            
            List<ASI_FOC_Free_Goods_Request__c> focRequestTemp_List = (List<ASI_FOC_Free_Goods_Request__c>)headerObject;
            
            for (ASI_FOC_Free_Goods_Request__c eachHeader : focRequestTemp_List){
                Date dateTemp = date.newInstance(Integer.valueof(eachHeader.ASI_CRM_SG_Year__c), Integer.valueof(eachHeader.ASI_CRM_SG_Month__c), 1);
                this.currentOrderDate = dateTemp;
                contractHeaderID_List.add(eachHeader.ASI_CRM_Contract__c);
                focRequestTempid_List.add(eachHeader.id);
                this.map_focID_focHeader.put(eachHeader.id, eachHeader);
                this.map_focID_contractHeader.put(eachHeader.id, eachHeader.ASI_CRM_Contract__c);
            }
        } 
            
        if(contractHeaderID_List.size() > 0) {
            
            focHeaderList = [SELECT 
                             ID, Name, ASI_CRM_Contract__c, ASI_CRM_Contract__r.name 
                             FROM ASI_FOC_Free_Goods_Request__c 
                             WHERE ASI_CRM_Contract__c IN : contractHeaderID_List
                            AND recordtype.developerName IN ('ASI_CRM_SG_FOC', 'ASI_CRM_SG_FOC_Read_Only')];
                
            this.contract_Name_Map = new Map<ID, String>();
            
            Set<ID> focHeaderIds = new Set<ID>();
            Map<ID, ID> focHeader_Contract_Map = new Map<ID, ID>();
            for(ASI_FOC_Free_Goods_Request__c focReq : focHeaderList) {
                focHeaderIds.add(focReq.id);
                focHeader_Contract_Map.put(focReq.id, focReq.ASI_CRM_Contract__c);
                this.map_focID_contractHeader.put(focReq.id, focReq.ASI_CRM_Contract__c);
                if(focReq.ASI_CRM_Contract__c != NULL){
                    this.contract_Name_Map.put(focReq.ASI_CRM_Contract__c, focReq.ASI_CRM_Contract__r.name);
                }
            }
            focItemList = new List<ASI_FOC_Request_Item__c>();
            
            focItemList = [SELECT ID, Name, ASI_FOC_Request_Order__c, ASI_FOC_SKU__c, ASI_FOC_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c,
                                ASI_CRM_SG_FOC_Type__c, ASI_FOC_Request_Quantity_Bottle__c,
                                ASI_FOC_Request_Order__r.ASI_CRM_SG_Month__c, ASI_FOC_Request_Order__r.ASI_CRM_SG_Year__c,
                               ASI_FOC_Request_Order__r.ASI_CRM_Contract__c,  ASI_FOC_Request_Order__r.ASI_CRM_Contract__r.name,
                               ASI_CRM_SG_Unit_Price__c
                               FROM ASI_FOC_Request_Item__c
                               WHERE ASI_FOC_Request_Order__c IN : focHeaderIds
                               AND ASI_FOC_Request_Order__c NOT IN : focRequestTempid_List
                               AND ASI_FOC_SKU__c <> null
                                AND ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c <> 'Rejected'
                               ORDER BY ASI_FOC_SKU__c];
            
            contractTargetItemList = [SELECT ID, Name, ASI_CRM_Contract__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.name, ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c, ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,
                                      ASI_CRM_Contract__r.name,
                                      ASI_CRM_SG_Events_Free_Bottles__c, 
                                      ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c,
                                      ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c,
                                      ASI_CRM_SG_Anniversary_Free_Bottles__c,
                                      ASI_CRM_Advertising_Spot_Free_Bottles__c,
                                      ASI_CRM_SG_Management_Incentives__c,
                                      ASI_CRM_Total_Management_Incentives__c,
                                      ASI_CRM_SG_Btls_Per_Case__c, ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c,
                                      ASI_CRM_SG_Good_in_Kinds__c,
                                      ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.name, ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.name
                                      FROM ASI_CRM_ContractTarget__c
                                      WHERE ASI_CRM_Contract__c IN : contractHeaderID_List
                                      AND ASI_CRM_SKU__c != null
									  AND recordtype.developername = :CONTRACTTARGET_RECORD_TYPE
                                      ORDER BY ASI_CRM_SKU__c
                                     ];
            
            system.debug(' HELPER map_header_isSampling #########################################');
            system.debug(this.map_header_isSampling);
            
             for(ASI_FOC_Request_Item__c focItem : focItemListTemp) {
                focItemList.add(focItem);
            }
                        
            this.contract_FOCItemListMap = new Map<ID, List<ASI_FOC_Request_Item__c>>();
            Set<ID> focItemList_skuIDSet = new Set<ID>();
                
            for(ASI_FOC_Request_Item__c focItem : focItemList) {
                ID contractID = focHeader_Contract_Map.get(focItem.ASI_FOC_Request_Order__c);
                List<ASI_FOC_Request_Item__c> contract_focItemList = this.contract_FOCItemListMap.containsKey(contractID) ? this.contract_FOCItemListMap.get(contractID) : new List<ASI_FOC_Request_Item__c>();
                contract_focItemList.add(focItem);
                this.contract_FOCItemListMap.put(contractID, contract_focItemList);
                focItemList_skuIDSet.add(focItem.ASI_FOC_SKU__c);
            }
            
            this.sku_NameMap = new Map<ID, String>();
            this.subBrand_NameMap = new Map<ID, String>();
            this.map_skuID_subBrandID = new Map<string, String>();
            this.map_skuID_bottleSize = new Map<string, decimal>();
            
            
            for(ASI_MFM_SKU_Code__c sku : [SELECT ID, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.name, ASI_HK_CRM_Std_Bottle_Size__c
                               FROM ASI_MFM_SKU_Code__c
                               WHERE ID IN :focItemList_skuIDSet]) {
                this.subBrand_NameMap.put(sku.ASI_MFM_Sub_brand__c , sku.ASI_MFM_Sub_brand__r.name);
                this.map_skuID_subBrandID.put(sku.id, sku.ASI_MFM_Sub_brand__c);
                this.map_skuID_bottleSize.put(sku.id, sku.ASI_HK_CRM_Std_Bottle_Size__c);
            }
              
            this.contract_ContractTargetListMap = new Map<ID, List<ASI_CRM_ContractTarget__c>>();
                 
            for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetItemList) {
                ID contractID = contractTargetItem.ASI_CRM_Contract__c;
                List<ASI_CRM_ContractTarget__c> contract_contractTargetItemList = this.contract_ContractTargetListMap.containsKey(contractID) ? this.contract_ContractTargetListMap.get(contractID) : new List<ASI_CRM_ContractTarget__c>();
                contract_contractTargetItemList.add(contractTargetItem);
                this.contract_ContractTargetListMap.put(contractID, contract_contractTargetItemList);
            }

            system.debug('contract_Name_Map');
            system.debug(this.contract_Name_Map);
            
            this.contract_subBrand_FOCListMap = new Map<ID, Map<ID, List<ASI_FOC_Request_Item__c>>>();
            this.contract_subBrand_ContractTargetListMap = new Map<ID, Map<ID, List<ASI_CRM_ContractTarget__c>>>();
            
            
            for (ID contractID : this.contract_FOCItemListMap.keySet()) {
                List<ASI_FOC_Request_Item__c> contract_focItemList = contract_FOCItemListMap.get(contractID);
                
                Map<ID, List<ASI_FOC_Request_Item__c>> subBrand_FOCListMap = new Map<ID, List<ASI_FOC_Request_Item__c>>();
                    
                List<ASI_FOC_Request_Item__c> focReqItemList = new List<ASI_FOC_Request_Item__c>();
                
                Set<ID> subBrandIDsSet  = new Set<ID>();
                for(ASI_FOC_Request_Item__c focItem : contract_focItemList) {
                    string subBrandID = this.map_skuID_subBrandID.get(focItem.ASI_FOC_SKU__c);
                    focSubBRandIDSet.add(subBrandID);
                    if(!subBrandIDsSet.contains(subBrandID)) {
                        
                        for(ASI_FOC_Request_Item__c focItem1 : contract_focItemList) {
                            string subBrandID_1 = this.map_skuID_subBrandID.get(focItem1.ASI_FOC_SKU__c);
                            if(subBrandID == subBrandID_1) {
                                focReqItemList.add(focItem1);
                            }
                        }
                        if(focReqItemList.size() > 0) {
                            subBrand_FOCListMap.put(subBrandID, focReqItemList);
                        }
                    }
                    subBrandIDsSet.add(subBrandID);
                    focReqItemList = new List<ASI_FOC_Request_Item__c>();
                }
                
                this.contract_subBrand_FOCListMap.put(contractID, subBrand_FOCListMap);
            }
            
            for (ID contractID : this.contract_ContractTargetListMap.keySet()) {
                List<ASI_CRM_ContractTarget__c> contract_contractTargetItemList = this.contract_ContractTargetListMap.get(contractID);
                
                Map<ID, List<ASI_CRM_ContractTarget__c>> subBrand_ContractTargetListMap = new Map<ID, List<ASI_CRM_ContractTarget__c>>();
                    
                List<ASI_CRM_ContractTarget__c> contractTargetListTemp = new List<ASI_CRM_ContractTarget__c>();
                
                
                // retrieve the SKU according to contract target SKU
                Map<ID, ID> subBrandMap = new Map<ID, ID>();
                
                for(ASI_CRM_ContractTarget__c contractTargetItem : contract_contractTargetItemList) {
                    ID subBrand_id = contractTargetItem.ASI_CRM_Subbrand__c != NULL ? contractTargetItem.ASI_CRM_Subbrand__c : contractTargetItem.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                    String subBrand_name = contractTargetItem.ASI_CRM_Subbrand__c != NULL ? contractTargetItem.ASI_CRM_Subbrand__r.name : contractTargetItem.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.name;
                    subBrandMap.put(contractTargetItem.ASI_CRM_SKU__c , subBrand_id);
                    contractSubrandIDSet.add(subBrand_id);
                    this.subBrand_NameMap.put(subBrand_id, subBrand_name);
                }
                
                system.debug('subBrandMap.values() ' + subBrandMap.values() + ' subBrandMap.keySet() ' + subBrandMap.keySet());
                
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
    

	
    public String validateVolumeExceed() {
        
        String volumeExceed = '';
        
        for (ID contractID : this.contract_Name_Map.keySet()) {
            String contractNo = this.contract_Name_Map.get(contractID);
            
            //Add checking if foc sub brand exist in the related contract
            
            System.debug('Start validateVolumeExceed');
            System.debug(contractID);
            System.debug(this.contract_FOCItemListMap);
            System.debug(this.contract_ContractTargetListMap);
            
            Map<ID, List<ASI_FOC_Request_Item__c>> subBrand_FOCListMap  = this.contract_subBrand_FOCListMap.containsKey(contractID) ? this.contract_subBrand_FOCListMap.get(contractID) : new Map<ID, List<ASI_FOC_Request_Item__c>>();
            Map<ID, List<ASI_CRM_ContractTarget__c>> subBrand_ContractTargetListMap  = this.contract_subBrand_ContractTargetListMap.containsKey(contractID) ? this.contract_subBrand_ContractTargetListMap.get(contractID) : new Map<ID, List<ASI_CRM_ContractTarget__c>>();
            
            if(subBrand_FOCListMap == null  || subBrand_ContractTargetListMap == null){
                return '';
            }
            
            system.debug('subBrand_ContractTargetListMap.values() ' + subBrand_ContractTargetListMap.values() + ' subBrand_FOCListMap.values() ' + subBrand_FOCListMap.values() );
            system.debug('subBrand_ContractTargetListMap.keySet() ' + subBrand_ContractTargetListMap.keySet() + ' subBrand_FOCListMap.keySet() ' + subBrand_FOCListMap.keySet() );
            
            for (Id subBrandID : subBrand_FOCListMap.keySet()) {
                String subBrand_name = '<b>'+this.subBrand_NameMap.get(subBrandID)+'</b>';
                Boolean notSampling = false;
                if (!subBrand_ContractTargetListMap.containsKey(subBrandID)) {
                    Decimal totalSalesSupport = 0;
                    Decimal totalLineItem = 0;
                    for(ASI_FOC_Request_Item__c focListItem : subBrand_FOCListMap.get(subBrandID)) {
                        /*[WL 1.0 Begin]*/
                        //if(focListItem.ASI_CRM_SG_FOC_Type__c == 'Sampling') {
                        if(focListItem.ASI_CRM_SG_FOC_Type__c == 'Sampling' || 
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Gift for Trade/Business Associate (CNY)' ||
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Sampling to end consumer (marketing)' ||
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Brand Awareness' ||
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Training' ||
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Corporate Public Relation' ||
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Hospitality' ||
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Company functions (marketing)' ||
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Contest/Prize (marketing)' ||
                                focListItem.ASI_CRM_SG_FOC_Type__c == 'Direct marketing' ||
								/*[WL 3.0] BEGIN*/
								focListItem.ASI_CRM_SG_FOC_Type__c == 'Adhoc Promotion/Sponsorship'
								/*[WL 3.0] BEGIN*/
                        ) {
                        /*[WL 1.0 End]*/
                            
                            totalSalesSupport++;
                            
                            string skuID = focListItem.ASI_FOC_SKU__c;
                            ID contractHeader_temp = this.map_focID_contractHeader.get(focListItem.ASI_FOC_Request_Order__c);
                            Map<ID, Decimal> map_sku_samplingBottle = this.map_header_sku_samplingBottle.containsKey(contractHeader_temp) ? this.map_header_sku_samplingBottle.get(contractHeader_temp) : new Map<ID, Decimal>();
                            Decimal samplingBottle = map_sku_samplingBottle.containsKey(skuID) ? map_sku_samplingBottle.get(skuID) : 0;
                            samplingBottle += focListItem.ASI_FOC_Request_Quantity_Bottle__c == null ? 0 : focListItem.ASI_FOC_Request_Quantity_Bottle__c;
                            map_sku_samplingBottle.put(skuID, samplingBottle);
                            this.map_header_sku_samplingBottle.put(contractHeader_temp, map_sku_samplingBottle);
                            
                        }
                        totalLineItem++;
                    }
                    if (totalLineItem > totalSalesSupport) volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', it does not exist in contract. <br/>';
                }
                
            }
            
            for (Id subBrandID : subBrand_ContractTargetListMap.keySet()) {
                
                /* [VL 1.2] BEGIN */
                String subBrand_name = '<b>'+this.subBrand_NameMap.get(subBrandID)+'</b>';
                /* [VL 1.2] END */
                
                List<ASI_CRM_ContractTarget__c> contractTargetListTemp = subBrand_ContractTargetListMap.get(subBrandID);
                List<ASI_FOC_Request_Item__c> focLineListTemp = subBrand_FOCListMap.get(subBrandID) == null ? new List<ASI_FOC_Request_Item__c>() : subBrand_FOCListMap.get(subBrandID);
                System.debug('contractTargetListTemp  ' + contractTargetListTemp  + ' focLineListTemp ' + focLineListTemp);
                 
                Decimal totalCash = 0;
                Decimal totalEvents = 0;
                Decimal totalSignages = 0;
                Decimal totalContractSponsorship = 0;
                Decimal totalAnniversary = 0;
                Decimal totalAdvertisingSpot = 0;
                Decimal totalManagementIncentive = 0;
				/*[WL 2.0] BEGIN*/
				Decimal totalAnPFund = 0;
				Decimal totalAnPFundFOC = 0;
				/*[WL 2.0] END*/
                
                Decimal totalCashFOC = 0;
                Decimal totalEventsFOC = 0;
                Decimal totalSignagesFOC = 0;
                Decimal totalContractSponsorshipFOC = 0;
                Decimal totalAnniversaryFOC = 0;
                Decimal totalAdvertisingSpotFOC = 0;
                Decimal totalManagementIncentiveFOC = 0;
				
                
                for(ASI_FOC_Request_Item__c focLine : focLineListTemp) {
                    Decimal bottleQty = focLine.ASI_FOC_Request_Quantity_Bottle__c == null ? 0 : focLine.ASI_FOC_Request_Quantity_Bottle__c;
                    Decimal volumeInCL = this.map_skuID_bottleSize.get(focLine.ASI_FOC_SKU__c) == null ? 0 : this.map_skuID_bottleSize.get(focLine.ASI_FOC_SKU__c) ;
                    Decimal totalVolumeInCL = bottleQty * volumeInCL ;
                    system.debug('totalVolumeInCL : '+totalVolumeInCL );
                    
                    if(focLine.ASI_CRM_SG_FOC_Type__c == 'Events') {
                        totalEventsFOC += totalVolumeInCL ;
                    } else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Signages New - TOT' || focLine.ASI_CRM_SG_FOC_Type__c == 'Signages Recurrent - TOT / Advertising Spot' || focLine.ASI_CRM_SG_FOC_Type__c == 'Singages New - MOT' || focLine.ASI_CRM_SG_FOC_Type__c == 'Signages New - MOT') {
                        totalSignagesFOC += totalVolumeInCL ;
                    } else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Contract Sponsorship/Target Incentive') {
                        totalContractSponsorshipFOC += totalVolumeInCL ;
                    } else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Anniversary') {
                        totalAnniversaryFOC += totalVolumeInCL ;
                    } 
                    else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Cash Sponsorship') {
                        totalCashFOC += totalVolumeInCL ;
                    }
                    else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Advertising Spot') {
                        totalAdvertisingSpotFOC += totalVolumeInCL ;
                    }
                    else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Management Incentive') {
                        totalManagementIncentiveFOC += totalVolumeInCL ;
                    }
					/*[WL 2.0] BEGIN*/
                    else if(focLine.ASI_CRM_SG_FOC_Type__c == 'A&P Fund') {
                        totalAnPFundFOC += totalVolumeInCL ;
                    }                 
					/*[WL 2.0] END*/					
                    
                    system.debug('focLine.ASI_CRM_SG_FOC_Type__c: '+focLine.ASI_CRM_SG_FOC_Type__c);
                }
                    
                for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetListTemp) {
                    
                    Decimal bottleSize = contractTargetItem.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c != null ? contractTargetItem.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c : 0;
                    Decimal caseSize = contractTargetItem.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != null ? contractTargetItem.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
                    Decimal WS_OnTrade_price = contractTargetItem.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c != null ? contractTargetItem.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c : 0;
                    
                    totalEvents += contractTargetItem.ASI_CRM_SG_Events_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Events_Free_Bottles__c * bottleSize * caseSize : 0;
                    totalSignages += contractTargetItem.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c != null ? contractTargetItem.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c * bottleSize * caseSize : 0;
                    totalAnniversary += contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c * bottleSize * caseSize : 0;
                    totalAdvertisingSpot += contractTargetItem.ASI_CRM_Advertising_Spot_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_Advertising_Spot_Free_Bottles__c * bottleSize * caseSize : 0;
                    totalManagementIncentive += contractTargetItem.ASI_CRM_Total_Management_Incentives__c != null ? contractTargetItem.ASI_CRM_Total_Management_Incentives__c * bottleSize * caseSize : 0;
                    totalContractSponsorship += contractTargetItem.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c != null ? contractTargetItem.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c * bottleSize * caseSize : 0;
					/*[WL 2.0] BEGIN*/
					totalAnPFund += contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c * bottleSize * caseSize : 0;
					/*[WL 2.0] END*/
					
                    
                    totalCash += contractTargetItem.ASI_CRM_SG_Good_in_Kinds__c == null ? 0 : (WS_OnTrade_price == 0 ? 0 : contractTargetItem.ASI_CRM_SG_Good_in_Kinds__c * bottleSize / WS_OnTrade_price);
                }
                                    
                
                
                if(totalEventsFOC.setScale(2) > totalEvents.setScale(2)) {
                    volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total events FOC of ' + totalEventsFOC.setScale(2) + '(cL) exceed contracted ' + totalEvents.setScale(2) + '(cL). ';
                }
				
                if(totalSignagesFOC.setScale(2) > totalSignages.setScale(2)) {
                    volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total signage FOC of ' + totalSignagesFOC.setScale(2) + '(cL) exceed contracted ' + totalSignages.setScale(2) + '(cL). ';
                    
                }
				
                if(totalContractSponsorshipFOC.setScale(2) > totalContractSponsorship.setScale(2)) {
                    volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total Contract Sponsorship/Target Incentive FOC of ' + totalContractSponsorshipFOC.setScale(2) + '(cL) exceed contracted ' + totalContractSponsorship.setScale(2) + '(cL). ';
                    
                }
				
                if(totalAnniversaryFOC.setScale(2) > totalAnniversary.setScale(2)) {
                    volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total anniversay FOC of ' + totalAnniversaryFOC.setScale(2) + '(cL) exceed contracted ' + totalAnniversary.setScale(2) + '(cL). ';                    
                }
				
                if(totalCashFOC.setScale(2) > totalCash.setScale(2)) {
                    volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total cash FOC of ' + totalCashFOC.setScale(2) + '(cL) exceed contracted ' + totalCash.setScale(2) + '(cL). ';
                }
				
                if(totalAdvertisingSpotFOC.setScale(2) > totalAdvertisingSpot.setScale(2)) {
                    volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total advertising spot FOC of ' + totalAdvertisingSpotFOC.setScale(2) + '(cL) exceed contracted ' + totalAdvertisingSpot.setScale(2) + '(cL). ';
                }
				
                if(totalManagementIncentiveFOC.setScale(2) > totalManagementIncentive.setScale(2)) {
                    volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total management incentive FOC of ' + totalManagementIncentiveFOC.setScale(2) + '(cL) exceed contracted ' + totalManagementIncentive.setScale(2) + '(cL). ';
                }
				
				/*[WL 2.0] BEGIN*/
				if(totalAnPFundFOC.setScale(2) > totalAnPFund.setScale(2)) {
                    volumeExceed += contractNo + ': For Sub-Brand ' + subBrand_name + ', Total A&P Fund FOC of ' + totalAnPFundFOC.setScale(2) + '(cL) exceed contracted ' + totalAnPFund.setScale(2) + '(cL). ';
                }
				/*[WL 2.0] END*/
                
                system.debug('totalContractSponsorshipFOC: '+totalContractSponsorshipFOC);
                system.debug('totalContractSponsorship: '+totalContractSponsorship);
            }
            
        }
        system.debug(' HELPER map_header_sku_samplingBottle #########################################');
        system.debug(this.map_header_sku_samplingBottle);
        
        return volumeExceed;
    }
    
    public List<ASI_FOC_Free_Goods_Request__c> updateSamplingLevel() {
        List<ASI_FOC_Free_Goods_Request__c> updateFocHeaderList = new List<ASI_FOC_Free_Goods_Request__c>();
        if (!this.map_header_isSampling.isEmpty()){
            for (ID focHeaderID : this.map_header_isSampling.keySet()){
                if (this.map_header_isSampling.get(focHeaderID)) {
                    Decimal max = 0;
                    Map<ID, Decimal> map_sku_samplingBottle = this.map_header_sku_samplingBottle.containsKey(this.map_focID_contractHeader.get(focHeaderID)) ? this.map_header_sku_samplingBottle.get(this.map_focID_contractHeader.get(focHeaderID)) : new Map<ID, Decimal>();
                    for (ID skuID : map_sku_samplingBottle.keySet()){
                        if (map_sku_samplingBottle.get(skuID)>max) max = map_sku_samplingBottle.get(skuID);
                    }
                    ASI_FOC_Free_Goods_Request__c focHeader_temp = map_focID_focHeader.get(focHeaderID);
                    if (max < 1) {
                        focHeader_temp.ASI_CRM_Sampling_Approval_Level__c = 0;
                    } else 
                    if (max < 2) {
                        focHeader_temp.ASI_CRM_Sampling_Approval_Level__c = 1;
                    } else 
                    if (max < 3) {
                        focHeader_temp.ASI_CRM_Sampling_Approval_Level__c = 2;
                    } else {
                        focHeader_temp.ASI_CRM_Sampling_Approval_Level__c = 3;
                    }
                    updateFocHeaderList.add(focHeader_temp);
                }
                
            }
            //database.update(updateFocHeaderList);
        }
        system.debug(' HELPER updateFocHeaderList #########################################');
        system.debug(this.map_header_sku_samplingBottle);
        system.debug(updateFocHeaderList);
        return updateFocHeaderList;
    }

}