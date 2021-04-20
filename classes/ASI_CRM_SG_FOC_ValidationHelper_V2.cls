/*********************************************************************************
 * Name: ASI_CRM_SG_FOC_ValidationHelper_V2
 * Description: Validation Helper for volume Exceed between FOC and Contract (Version 2: to validate focs against the whole contract in $ => can be any SKU)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-05-18       Laputa: Vincent Lam     Created
 */
public class ASI_CRM_SG_FOC_ValidationHelper_V2 {
    
    private boolean isFOCObject {get;set;}
    
    private List<ASI_FOC_Request_Item__c> focItemList {get;set;}
    private List<ASI_FOC_Free_Goods_Request__c> focHeaderList {get;set;}
    
    private List<ASI_CRM_ContractTarget__c> contractTargetItemList {get;set;}
    
    private List<sObject> headerObject {get;set;}
    private List<sObject> sObjList {get;set;}
    
    private Map<ID, Map<ID, List<ASI_FOC_Request_Item__c>>> contract_sku_FOCListMap {get;set;}
    private Map<ID, Map<ID, List<ASI_CRM_ContractTarget__c>>> contract_sku_ContractTargetListMap {get;set;}
    private Map<ID, List<ASI_FOC_Request_Item__c>> contract_FOCItemListMap {get;set;}
    private Map<ID, List<ASI_CRM_ContractTarget__c>> contract_ContractTargetListMap {get;set;}
    private Map<ID, String> contract_Name_Map {get;set;}

    private Map<ID, String> sku_NameMap {get;set;}
    
    private Set<ID> contractSKUIDSet {get;set;}
    private Set<ID> focSKUIDSet {get;set;}
    
    private Map<ID, Decimal> sku_BottleVolume_Map {get;set;}
    
    private Date currentOrderDate;
    private Boolean isSalesIncentive = false;
    
    public Map<ID, Boolean> map_header_isSampling = new Map<ID, Boolean>();
    public Map<ID, Map<ID, Decimal>> map_header_sku_samplingBottle = new Map<ID, Map<ID, Decimal>>();
    public Map<ID, ASI_FOC_Free_Goods_Request__c> map_focID_focHeader = new Map<ID, ASI_FOC_Free_Goods_Request__c>();
    public Map<ID, ID> map_focID_contractHeader = new Map<ID, ID>();
    
    // constructor to cater multiple headers
    public ASI_CRM_SG_FOC_ValidationHelper_V2 (boolean isFOC, List<sObject> header, List<sObject> sObList) {
        this.isFOCObject = isFOC;
        this.headerObject = header;
        this.sObjList = sObList;
        initiator();
    }
    
    // constructor to cater single header
    public ASI_CRM_SG_FOC_ValidationHelper_V2 (boolean isFOC, sObject header, List<sObject> sObList) {
        this.isFOCObject = isFOC;
        this.headerObject = new List<sObject>();
        this.headerObject.add(header);
        this.sObjList = sObList;
        initiator();
    }
    
    public void initiator () {
        this.contractSKUIDSet = new Set<ID>();
        this.focSKUIDSet = new Set<ID>();
        this.focItemList = new List<ASI_FOC_Request_Item__c>();
        this.contractTargetItemList = new List<ASI_CRM_ContractTarget__c>();
        
        if(this.isFOCObject != null && this.headerObject != null && this.sObjList != null) {
            if(this.sObjList.size() > 0 && this.isFOCObject) {
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
                                      ASI_CRM_SG_Good_in_Kinds__c
                                      FROM ASI_CRM_ContractTarget__c
                                      WHERE ASI_CRM_Contract__c IN : contractHeaderID_List
                                      AND ASI_CRM_SKU__c != null
                                      ORDER BY ASI_CRM_SKU__c
                                     ];
            
            for(ASI_FOC_Request_Item__c focItem : focItemListTemp) {
                focItemList.add(focItem);
                if (focItem.ASI_CRM_SG_FOC_Type__c == 'Sampling') this.map_header_isSampling.put(focItem.ASI_FOC_Request_Order__c, true);
            }
        system.debug(' HELPER map_header_isSampling #########################################');
        system.debug(this.map_header_isSampling);
                        
            this.contract_FOCItemListMap = new Map<ID, List<ASI_FOC_Request_Item__c>>();
            Set<ID> focItemList_SKUIDSet = new Set<ID>();
                
            for(ASI_FOC_Request_Item__c focItem : focItemList) {
                ID contractID = focHeader_Contract_Map.get(focItem.ASI_FOC_Request_Order__c);
                List<ASI_FOC_Request_Item__c> contract_focItemList = this.contract_FOCItemListMap.containsKey(contractID) ? this.contract_FOCItemListMap.get(contractID) : new List<ASI_FOC_Request_Item__c>();
                contract_focItemList.add(focItem);
                this.contract_FOCItemListMap.put(contractID, contract_focItemList);
                focItemList_SKUIDSet.add(focItem.ASI_FOC_SKU__c);
            }
            
            this.sku_NameMap = new Map<ID, String>();
            
            List<ASI_MFM_SKU_Code__c> sku_BottleVolume_List = new List<ASI_MFM_SKU_Code__c>();
            
            sku_BottleVolume_List = [SELECT ID, ASI_HK_CRM_Std_Bottle_Size__c, name
                               FROM ASI_MFM_SKU_Code__c
                               WHERE ID IN :focItemList_SKUIDSet];
            
            this.sku_BottleVolume_Map = new Map<ID, Decimal>();
            for(ASI_MFM_SKU_Code__c sku_BottleVolume : sku_BottleVolume_List) {
                this.sku_BottleVolume_Map.put(sku_BottleVolume.id, sku_BottleVolume.ASI_HK_CRM_Std_Bottle_Size__c);
                this.sku_NameMap.put(sku_BottleVolume.id , sku_BottleVolume.name);
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
            
            this.contract_sku_FOCListMap = new Map<ID, Map<ID, List<ASI_FOC_Request_Item__c>>>();
            this.contract_sku_ContractTargetListMap = new Map<ID, Map<ID, List<ASI_CRM_ContractTarget__c>>>();
            
            for (ID contractID : this.contract_FOCItemListMap.keySet()) {
                List<ASI_FOC_Request_Item__c> contract_focItemList = contract_FOCItemListMap.get(contractID);
                
                Map<ID, List<ASI_FOC_Request_Item__c>> sku_FOCListMap = new Map<ID, List<ASI_FOC_Request_Item__c>>();
                    
                List<ASI_FOC_Request_Item__c> focReqItemList = new List<ASI_FOC_Request_Item__c>();
                
                Set<ID> skuIDsSet = new Set<ID>();
                for(ASI_FOC_Request_Item__c focItem : contract_focItemList) {
                    focSKUIDSet.add(focItem.ASI_FOC_SKU__c);
                    if(!skuIDsSet.contains(focItem.ASI_FOC_SKU__c)) {
                        
                        for(ASI_FOC_Request_Item__c focItem1 : contract_focItemList) {
                            if(focItem.ASI_FOC_SKU__c == focItem1.ASI_FOC_SKU__c) {
                                focReqItemList.add(focItem1);
                            }
                        }
                        if(focReqItemList.size() > 0) {
                            sku_FOCListMap.put(focItem.ASI_FOC_SKU__c, focReqItemList);
                        }
                    }
                    skuIDsSet.add(focItem.ASI_FOC_SKU__c);
                    focReqItemList = new List<ASI_FOC_Request_Item__c>();
                }
                
                this.contract_sku_FOCListMap.put(contractID, sku_FOCListMap);
            }
            
            for (ID contractID : this.contract_ContractTargetListMap.keySet()) {
                List<ASI_CRM_ContractTarget__c> contract_contractTargetItemList = this.contract_ContractTargetListMap.get(contractID);
                
                Map<ID, List<ASI_CRM_ContractTarget__c>> sku_ContractTargetListMap = new Map<ID, List<ASI_CRM_ContractTarget__c>>();
                    
                List<ASI_CRM_ContractTarget__c> contractTargetListTemp = new List<ASI_CRM_ContractTarget__c>();
                
                
                // retrieve the SKU according to contract target SKU
                Map<ID, ID> skuMap = new Map<ID, ID>();
                
                for(ASI_CRM_ContractTarget__c contractTargetItem : contract_contractTargetItemList) {
                    ID sku_id = contractTargetItem.ASI_CRM_SKU__c;
                    String sku_name = contractTargetItem.ASI_CRM_SKU__r.name;
                    skuMap.put(contractTargetItem.ASI_CRM_SKU__c , sku_id);
                    contractSKUIDSet.add(sku_id);
                    this.sku_NameMap.put(sku_id, sku_name);
                }
                
                system.debug('skuMap.values() ' + skuMap.values() + ' skuMap.keySet() ' + skuMap.keySet());
                
                Set<ID> skuIDsSet = new Set<ID>();
                for(ASI_CRM_ContractTarget__c contractTargetItem : contract_contractTargetItemList) {
                    
                    if(!skuIDsSet.contains(skuMap.get(contractTargetItem.ASI_CRM_SKU__c))) {
                        
                        for(ASI_CRM_ContractTarget__c contractTargetItem1 : contract_contractTargetItemList) {
                            if(skuMap.get(contractTargetItem.ASI_CRM_SKU__c) == skuMap.get(contractTargetItem1.ASI_CRM_SKU__c)) {
                                contractTargetListTemp.add(contractTargetItem1);
                            }
                        }
                        if(contractTargetListTemp.size() > 0) {
                            sku_ContractTargetListMap.put(skuMap.get(contractTargetItem.ASI_CRM_SKU__c), contractTargetListTemp);
                        }
                    }
                    skuIDsSet.add(skuMap.get(contractTargetItem.ASI_CRM_SKU__c));
                    contractTargetListTemp = new List<ASI_CRM_ContractTarget__c>();
                }
                
                this.contract_sku_ContractTargetListMap.put(contractID, sku_ContractTargetListMap);
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
            
            Map<ID, List<ASI_FOC_Request_Item__c>> sku_FOCListMap = this.contract_sku_FOCListMap.containsKey(contractID) ? this.contract_sku_FOCListMap.get(contractID) : new Map<ID, List<ASI_FOC_Request_Item__c>>();
            Map<ID, List<ASI_CRM_ContractTarget__c>> sku_ContractTargetListMap = this.contract_sku_ContractTargetListMap.containsKey(contractID) ? this.contract_sku_ContractTargetListMap.get(contractID) : new Map<ID, List<ASI_CRM_ContractTarget__c>>();
            
            if(sku_FOCListMap == null  || sku_ContractTargetListMap == null){
                return '';
            }
            
            system.debug('sku_ContractTargetListMap.values() ' + sku_ContractTargetListMap.values() + ' sku_FOCListMap.values() ' + sku_FOCListMap.values() );
            system.debug('sku_ContractTargetListMap.keySet() ' + sku_ContractTargetListMap.keySet() + ' sku_FOCListMap.keySet() ' + sku_FOCListMap.keySet() );
            
            for (Id skuID : sku_FOCListMap.keySet()) {
                String sku_name = this.sku_NameMap.get(skuID);
                Boolean notSampling = false;
                Boolean inContractAndSampling = false;
                for (ASI_FOC_Request_Item__c focListItem : sku_FOCListMap.get(skuID)) {
                    if(focListItem.ASI_CRM_SG_FOC_Type__c == 'Sampling') {
                        // check if the SKU is in contract target and it is sampling
                        if (sku_ContractTargetListMap.containsKey(skuID) && focListItem.ASI_CRM_SG_FOC_Type__c == 'Sampling') {
                            inContractAndSampling = true;
                        }
                        
                        ID contractHeader_temp = this.map_focID_contractHeader.get(focListItem.ASI_FOC_Request_Order__c);
                        Map<ID, Decimal> map_sku_samplingBottle = this.map_header_sku_samplingBottle.containsKey(contractHeader_temp) ? this.map_header_sku_samplingBottle.get(contractHeader_temp) : new Map<ID, Decimal>();
                        Decimal samplingBottle = map_sku_samplingBottle.containsKey(skuID) ? map_sku_samplingBottle.get(skuID) : 0;
                        samplingBottle += focListItem.ASI_FOC_Request_Quantity_Bottle__c == null ? 0 : focListItem.ASI_FOC_Request_Quantity_Bottle__c;
                        map_sku_samplingBottle.put(skuID, samplingBottle);
                        this.map_header_sku_samplingBottle.put(contractHeader_temp, map_sku_samplingBottle);
                        
                    }
                }
            }
            
            Decimal totalCash = 0;
            Decimal totalEvents = 0;
            Decimal totalSignages = 0;
            Decimal totalContractSponsorship = 0;
            Decimal totalAnniversary = 0;
            Decimal totalAdvertisingSpot = 0;
            Decimal totalManagementIncentive = 0;
            
            Decimal totalCashFOC = 0;
            Decimal totalEventsFOC = 0;
            Decimal totalSignagesFOC = 0;
            Decimal totalContractSponsorshipFOC = 0;
            Decimal totalAnniversaryFOC = 0;
            Decimal totalAdvertisingSpotFOC = 0;
            Decimal totalManagementIncentiveFOC = 0;
            
            for (Id skuID : sku_ContractTargetListMap.keySet()) {
                
                List<ASI_CRM_ContractTarget__c> contractTargetListTemp = sku_ContractTargetListMap.get(skuID);
                System.debug('contractTargetListTemp  ' + contractTargetListTemp);
                
                for(ASI_CRM_ContractTarget__c contractTargetItem : contractTargetListTemp) {
                    
                    Decimal bottleSize = contractTargetItem.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c != null ? contractTargetItem.ASI_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c : 0;
                    Decimal caseSize = contractTargetItem.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != null ? contractTargetItem.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
                    Decimal WS_OnTrade_price = contractTargetItem.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c != null ? contractTargetItem.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c : 0;
                    
                    totalEvents += contractTargetItem.ASI_CRM_SG_Events_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Events_Free_Bottles__c * WS_OnTrade_price * caseSize : 0;
                    totalSignages += contractTargetItem.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c != null ? contractTargetItem.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c * WS_OnTrade_price * caseSize : 0;
                    totalAnniversary += contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_SG_Anniversary_Free_Bottles__c * WS_OnTrade_price * caseSize : 0;
                    totalAdvertisingSpot += contractTargetItem.ASI_CRM_Advertising_Spot_Free_Bottles__c != null ? contractTargetItem.ASI_CRM_Advertising_Spot_Free_Bottles__c * WS_OnTrade_price * caseSize : 0;
                    totalManagementIncentive += contractTargetItem.ASI_CRM_Total_Management_Incentives__c != null ? contractTargetItem.ASI_CRM_Total_Management_Incentives__c * WS_OnTrade_price * caseSize : 0;
                    totalContractSponsorship += contractTargetItem.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c != null ? contractTargetItem.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c * WS_OnTrade_price * caseSize : 0;
                    
                    totalCash += contractTargetItem.ASI_CRM_SG_Good_in_Kinds__c == null ? 0 : contractTargetItem.ASI_CRM_SG_Good_in_Kinds__c;
                }
                
            }
            
            for (Id skuID : sku_FOCListMap.keySet()) {
                
                List<ASI_FOC_Request_Item__c> focLineListTemp = sku_FOCListMap.get(skuID) == null ? new List<ASI_FOC_Request_Item__c>() : sku_FOCListMap.get(skuID);
                System.debug(' focLineListTemp ' + focLineListTemp);
                
                for(ASI_FOC_Request_Item__c focLine : focLineListTemp) {
                    Decimal bottleQty = focLine.ASI_FOC_Request_Quantity_Bottle__c == null ? 0 : focLine.ASI_FOC_Request_Quantity_Bottle__c;
                    Decimal WS_OnTrade_price = focLine.ASI_CRM_SG_Unit_Price__c == null ? 0 : focLine.ASI_CRM_SG_Unit_Price__c ;
                    Decimal totalSpend = bottleQty * WS_OnTrade_price ;
                    system.debug('totalSpend : '+totalSpend );
                    
                    if(focLine.ASI_CRM_SG_FOC_Type__c == 'Events') {
                        totalEventsFOC += totalSpend ;
                    } else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Signages New - TOT' || focLine.ASI_CRM_SG_FOC_Type__c == 'Signages Recurrent - TOT / Advertising Spot' || focLine.ASI_CRM_SG_FOC_Type__c == 'Singages New - MOT' || focLine.ASI_CRM_SG_FOC_Type__c == 'Signages New - MOT') {
                        totalSignagesFOC += totalSpend ;
                    } else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Contract Sponsorship/Target Incentive') {
                        totalContractSponsorshipFOC += totalSpend ;
                    } else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Anniversary') {
                        totalAnniversaryFOC += totalSpend ;
                    } 
                    else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Cash Sponsorship') {
                        totalCashFOC += totalSpend ;
                    }
                    else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Advertising Spot') {
                        totalAdvertisingSpotFOC += totalSpend ;
                    }
                    else if(focLine.ASI_CRM_SG_FOC_Type__c == 'Management Incentive') {
                        totalManagementIncentiveFOC += totalSpend ;
                    }
                     
                    
                    system.debug('focLine.ASI_CRM_SG_FOC_Type__c: '+focLine.ASI_CRM_SG_FOC_Type__c);
                }
                
            }
            
            if(totalEventsFOC.setScale(2) > totalEvents.setScale(2)) {
                volumeExceed += contractNo + ': Total events FOC of S$' + totalEventsFOC.setScale(2) + ' is over than the total events of S$' + totalEvents.setScale(2) + '. ';
            }
            if(totalSignagesFOC.setScale(2) > totalSignages.setScale(2)) {
                volumeExceed += contractNo + ': Total signage FOC of S$' + totalSignagesFOC.setScale(2) + ' is over than the total signage of S$' + totalSignages.setScale(2) + '. ';
                
            }
            if(totalContractSponsorshipFOC.setScale(2) > totalContractSponsorship.setScale(2)) {
                volumeExceed += contractNo + ': Total Contract Sponsorship/Target Incentive FOC of S$' + totalContractSponsorshipFOC.setScale(2) + ' is over than the total Contract Sponsorship/Target Incentive of S$' + totalContractSponsorship.setScale(2) + '. ';
                
            }
            if(totalAnniversaryFOC.setScale(2) > totalAnniversary.setScale(2)) {
                volumeExceed += contractNo + ': Total anniversay FOC of S$' + totalAnniversaryFOC.setScale(2) + ' is over than the total anniversay of S$' + totalAnniversary.setScale(2) + '. ';
                
            }
            if(totalCashFOC.setScale(2) > totalCash.setScale(2)) {
                volumeExceed += contractNo + ': Total cash FOC of S$' + totalCashFOC.setScale(2) + ' is over than the total cash sponsorship of S$' + totalCash.setScale(2) + '. ';
            }
            if(totalAdvertisingSpotFOC.setScale(2) > totalAdvertisingSpot.setScale(2)) {
                volumeExceed += contractNo + ': Total advertising spot FOC of S$' + totalAdvertisingSpotFOC.setScale(2) + ' is over than the total advertising spot of S$' + totalAdvertisingSpot.setScale(2) + '. ';
            }
            if(totalManagementIncentiveFOC.setScale(2) > totalManagementIncentive.setScale(2)) {
                volumeExceed += contractNo + ': Total management incentive FOC of S$' + totalManagementIncentiveFOC.setScale(2) + ' is over than the total management incentive of S$' + totalManagementIncentive.setScale(2) + '. ';
            }
            
            
            system.debug('totalContractSponsorshipFOC: '+totalContractSponsorshipFOC);
            system.debug('totalContractSponsorship: '+totalContractSponsorship);
            
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