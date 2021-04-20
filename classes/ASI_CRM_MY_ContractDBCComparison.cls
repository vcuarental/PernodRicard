/*********************************************************************************
 * Name: ASI_CRM_MY_ContractDBCComparison
 * Description: For Contract DBC
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2015-01-19       Axel                   Initial
 " 2015-01-20       Daniel                 DBCa
 *********************************************************************************/
public class ASI_CRM_MY_ContractDBCComparison {

    // Declaration
    public class DBCData{
        public Map<id, String> mapSKUTitle = new Map<id, String>();
        public Map<integer, String> mapRowTitle = new Map<integer, String>();
        public Map<integer, Map<id, decimal>> mapTblData = new Map<integer, Map<id, decimal>>{};
        public Map<integer, boolean> mapRowIsTitle = new Map<integer, boolean>{};
        public Map<integer, boolean> mapRowAddTotal = new Map<integer, boolean>{};

        public map<Id, Id> mapSKUCrossSKU = new Map<Id,Id>();
        public map<Id, String> mapCrossSKUDesc = new Map<Id, String>();
    }

    
    public map<Integer, String> mapIndexCrossSKUTitle {get; private set;}{mapIndexCrossSKUTitle = new map<Integer, String> ();}
    // Declaration - End

    /** Constructor */
    public ASI_CRM_MY_ContractDBCComparison() {
		
    }
    
	
    /** 
        for DBCa
    **/
    public class DBC_A{
        public Map<Id, Decimal> mapAO_Quantity = new Map<Id, Decimal>();
        public Map<String, Decimal> mapFOC_Quantity = new Map<String, Decimal>();
        public Map<String, Decimal> mapPayment_Amount = new Map<String, Decimal>();
        public Map<Id, Decimal> mapFOC_Btl = new Map<Id, Decimal>();
    }
    
    public DBC_A getDBCaMap(Id idContract, Id idCustomer, Date dteStart, Date dteEnd, Boolean isParent){
        Map<Id, Decimal> mapAO_Quantity = new Map<Id, Decimal>();
        Map<String, Decimal> mapFOC_Quantity = new Map<String, Decimal>();
        Map<String, Decimal> mapPayment_Amount = new Map<String, Decimal>();
        Map<Id, Decimal> mapFOC_Btl = new Map<Id, Decimal>();
        Set<Id> setCustomer = new Set<Id>();
        Set<Id> setAOHeader = new Set<Id>();
        Set<Id> setFOCHeader = new Set<Id>();
        Set<Id> setPaymentHeader = new Set<Id>();
        Set<Id> setCalcFOCHeader = new Set<Id>();
        setCustomer.add(idCustomer);
        
        // --  AccountsAdditionalField -- 
        if(isParent){
            for(ASI_CRM_AccountsAdditionalField__c i :
                [SELECT 
                 	Id 
                 FROM ASI_CRM_AccountsAdditionalField__c 
                 WHERE ASI_CRM_CN_Parent_Outlet__c = :idCustomer]){
                setCustomer.add(i.id);
            }
        }
        system.debug('ASI_CRM_MY_ContractDBC.getDBCaMap------------------setCustomer : ' + setCustomer);
        // --  AccountsAdditionalField -- 
        
        system.debug('@@@setCustomer@@@: '+setCustomer);
        system.debug('@@@idContract@@@: '+idContract);
        // -- Calculated FOC --
        for(ASI_CRM_Calculated_FOC__c calcFoc : [
                SELECT Id 
                FROM ASI_CRM_Calculated_FOC__c
                WHERE ASI_CRM_Customer__c IN :setCustomer
                AND ASI_CRM_Contract__c = :idContract
            ]){
            setCalcFOCHeader.add(calcFoc.Id);
        }
        // -- Calculated FOC --
        
        
        // -- Calculated FOC Line -- 
        if(!setCalcFOCHeader.isEmpty()){
            for(ASI_CRM_Calculated_FOC_Line__c i : [
                SELECT 
                	Id, 
                	ASI_CRM_SKU__c,
                	ASI_CRM_FOC__c, 
                	ASI_CRM_FOC_WS__c, 
                	ASI_CRM_Actual_Purchase__c,
                	ASI_CRM_Original_SKU__c,
                    ASI_CRM_Packing_Size__c
                FROM ASI_CRM_Calculated_FOC_Line__c
                WHERE ASI_CRM_Calculated_FOC__c IN :setCalcFOCHeader
                AND ASI_CRM_Packing_Size__c != null 
                AND ASI_CRM_Packing_Size__c != 0 
            ]){
                
                Decimal temp = 0;
                if(mapFOC_Btl.get(i.ASI_CRM_Original_SKU__c) != NULL)
                    temp = mapFOC_Btl.get(i.ASI_CRM_Original_SKU__c);
                temp += (i.ASI_CRM_FOC__c + i.ASI_CRM_FOC_WS__c) / i.ASI_CRM_Packing_Size__c;
                mapFOC_Btl.put(i.ASI_CRM_Original_SKU__c, temp);
                
                Decimal temp2 = 0;
                if(mapAO_Quantity.get(i.ASI_CRM_Original_SKU__c) != NULL)
                    temp2 = mapAO_Quantity.get(i.ASI_CRM_Original_SKU__c);
                temp2 += (i.ASI_CRM_Actual_Purchase__c / i.ASI_CRM_Packing_Size__c);
                mapAO_Quantity.put(i.ASI_CRM_Original_SKU__c, temp2);
                
                
            }
        }
        // -- Calculated FOC Line -- 
        
        
        /*for(ASI_CRM_ActualOfftakeHeader__c i : [
            SELECT Id 
            FROM ASI_CRM_ActualOfftakeHeader__c 
            WHERE ASI_CRM_ToOutlet__c IN :setCustomer
            AND (ASI_CRM_OfftakeDate__c >= :dteStart AND ASI_CRM_OfftakeDate__c <= :dteEnd)
            AND ASI_CRM_Status__c = 'Final'
        ]){
            setAOHeader.add(i.id);
        }
        system.debug('ASI_CRM_MY_ContractDBC.getDBCaMap------------------setAOHeader: ' + setAOHeader);
        
        if(!setAOHeader.isEmpty()){
            for(ASI_TH_CRM_Actual_Offtake__c i : [
                SELECT Id, ASI_CRM_SKU__c, ASI_TH_CRM_Quantity__c, ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE ASI_CRM_ActualOfftakeHeader__c IN :setAOHeader
                AND ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != NULL
            ]){
                Decimal temp = 0;
                if(mapAO_Quantity.get(i.ASI_CRM_SKU__c) != NULL)
                    temp = mapAO_Quantity.get(i.ASI_CRM_SKU__c);
                temp += (i.ASI_TH_CRM_Quantity__c / i.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c);
                mapAO_Quantity.put(i.ASI_CRM_SKU__c, temp);
            }
        }*/
        system.debug('ASI_CRM_MY_ContractDBC.getDBCaMap------------------mapAO_Quantity: ' + mapAO_Quantity);
        
        
        // -- Free Goods Request -- 
        for(ASI_FOC_Free_Goods_Request__c i : [
            SELECT Id 
            FROM ASI_FOC_Free_Goods_Request__c 
            //WHERE ASI_CRM_Outlet__c IN :setCustomer
            //AND (ASI_FOC_Date_of_Delivery__c >= :dteStart AND ASI_FOC_Date_of_Delivery__c <= :dteEnd)
            WHERE ASI_CRM_Contract__c = :idContract
        ]){
            setFOCHeader.add(i.id);
        }
        system.debug('ASI_CRM_MY_ContractDBC.getDBCaMap------------------setFOCHeader: ' + setFOCHeader);
        // -- Free Goods Request -- 
        
        
        // -- FOC Request Item --
        if(!setFOCHeader.isEmpty()){
            for(ASI_FOC_Request_Item__c i : [
                SELECT Id, ASI_FOC_SKU__c, ASI_FOC_Issued_Qty__c, ASI_CRM_SetupCode__c
                FROM ASI_FOC_Request_Item__c
                WHERE ASI_FOC_Request_Order__c IN :setFOCHeader 
                AND (ASI_FOC_Request_Order__r.ASI_CRM_Status__c = 'Final' OR ASI_FOC_Request_Order__r.ASI_CRM_Status__c = 'Not Converted')
            ]){
                Decimal temp = 0;
                //if(i.ASI_CRM_SetupCode__c == 'SAVR'){
                    //if(mapAO_Quantity.get(i.ASI_FOC_SKU__c) != NULL)
                        //temp = mapAO_Quantity.get(i.ASI_FOC_SKU__c);
                     
                String foc_request_key = i.ASI_CRM_SetupCode__c+'_'+i.ASI_FOC_SKU__c;
                if(mapFOC_Quantity.containsKey(foc_request_key)){
                    temp = mapFOC_Quantity.get(foc_request_key);
                }
                
                if(i.ASI_FOC_Issued_Qty__c != NULL){
                    temp += i.ASI_FOC_Issued_Qty__c;
                }
                mapFOC_Quantity.put(foc_request_key, temp);
                //}
            }
        }
        system.debug('ASI_CRM_MY_ContractDBC.getDBCaMap------------------mapFOC_Quantity: ' + mapFOC_Quantity);
        // -- FOC Request Item --
        
        
        // -- Payment Request -- 
        for(ASI_TH_CRM_PaymentRequest__c i : [
            SELECT Id 
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE ASI_TH_CRM_Contract__c = :idContract
            //AND (ASI_FOC_Date_of_Delivery__c >= :dteStart AND ASI_FOC_Date_of_Delivery__c <= :dteEnd)
        ]){
            setPaymentHeader.add(i.id);
        }
        system.debug('ASI_CRM_MY_ContractDBC.getDBCaMap------------------setPaymentHeader: ' + setPaymentHeader);
        // -- Payment Request -- 
        
        
        // -- Payment Request Line Item
        if(!setPaymentHeader.isEmpty()){
            for(ASI_TH_CRM_PaymentRequestLineItem__c i : [
                SELECT Id, ASI_CRM_SKU__c, ASI_CRM_Net_Amount__c, ASI_CRM_SetupCode__c 
                FROM ASI_TH_CRM_PaymentRequestLineItem__c
                WHERE ASI_TH_CRM_Payment_Request__c IN :setPaymentHeader
                AND (ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Approved' 
                     OR ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Status__c = 'Final') 
            ]){
                Decimal temp = 0;
                //if(i.ASI_CRM_SetupCode__c == 'SAVR'){
                	String payment_amount_key = i.ASI_CRM_SetupCode__c+'_'+i.ASI_CRM_SKU__c;
                    if(mapPayment_Amount.containsKey(payment_amount_key))
                        temp = mapPayment_Amount.get(payment_amount_key);
                    if(i.ASI_CRM_Net_Amount__c != NULL)
                        temp += i.ASI_CRM_Net_Amount__c;
                    mapPayment_Amount.put(payment_amount_key, temp);
                //}
            }
        }
        system.debug('ASI_CRM_MY_ContractDBC.getDBCaMap------------------mapPayment_Amount: ' + mapPayment_Amount);
        // -- Payment Request Line Item
        
        
        DBC_A objData = new DBC_A();
        objData.mapAO_Quantity = mapAO_Quantity;
        objData.mapFOC_Quantity = mapFOC_Quantity;
        objData.mapPayment_Amount = mapPayment_Amount;
        objData.mapFOC_Btl = mapFOC_Btl;
        return objData;
    }
    
    public DBCData genDBC_E(Id idContract, String strDBC, Boolean isCompareReport) {
        // Declaration
        list<ASI_CRM_ContractTarget__c> lstContractTarget = new list<ASI_CRM_ContractTarget__c>();
        Map<id, decimal> mapSKUData = new Map<id, decimal>();
        Map<integer, Map<id, decimal>> mapTblData = new Map<integer, Map<id, decimal>>{};
        Map<integer, String> mapRowTitle = new Map<integer, String>(); // Start from row = 0
        Map<id, String> mapSKUTitle = new Map<id, String>();
        Map<integer, boolean> mapRowIsTitle = new Map<integer, boolean>{};
        Map<integer, boolean> mapRowAddTotal = new Map<integer, boolean>{};
        Set<id> setSKU = new Set<id>();
        Map<id, id> mapSKUProdCateg = new Map<id, id>(); // <SKUID, ProdCategID>
        Set<string> setVolDesc = new Set<string>();
        Set<string> setOthDesc = new Set<string>();
        Map<String, Set<id>> mapVolDesc = new Map<String, Set<id>>(); // <VolType, SKUID> To store if the SKU id exists in the type
        Map<String, Set<id>> mapOthDesc = new Map<String, Set<id>>(); // <OthType, SKUID> To store if the SKU id exists in the type
        
        integer intLineCount = 0;
        String strMktResp = 'Duty Paid'; //TODO get from contract default value
        decimal decCommRate = 0;
        
        Map<String, integer> mapIdx = new Map<String, integer>(); // Figure and Row mapping
        map<id, map<String, map<String, decimal>>> mapDistCost = new map<id, map<String, map<String, decimal>>>(); // res[ProdCatg][MktResp][ALLOWANCE] = 123.45;
        
        Map<id, decimal> mapAC = new Map<id, decimal>();
        Map<id, decimal> mapIGC = new Map<id, decimal>();
        Map<id, decimal> mapCrossBrandIGC = new Map<id, decimal>();
        Map<id, decimal> mapVol_FOC = new Map<id, decimal>();
        Map<id, decimal> mapVol_MGTIFOC = new Map<id, decimal>();
        Map<id, decimal> mapVol_Cash = new Map<id, decimal>();
        map<id, string> mapVol_SetupCode = new Map<id, string>();
        Map<id, Map<String, decimal>> mapOth_FOC = new Map<id, Map<String, decimal>>();
        Map<id, decimal> mapOth_MGTIFOC = new Map<id, decimal>();
        Map<id, Map<String, decimal>> mapOth_Cash = new Map<id, Map<String, decimal>>();
        Map<id, Map<String, decimal>> mapOth_Total = new Map<id, Map<String, decimal>>();
        Map<id, decimal> mapWSSP = new Map<id, decimal>();
        Map<id, decimal> mapSS_FOC = new Map<id, decimal>();
        Map<id, decimal> mapSS_AchievedBtl = new Map<id, decimal>();
        Map<id, decimal> mapSS_CashInc = new Map<id, decimal>();
        Map<id, decimal> mapPacking = new Map<id, decimal>();
        Map<id, decimal> mapCrossBrandPacking = new Map<id, decimal>();
        Map<id, decimal> mapPP_Count = new Map<id, decimal>();
        Map<id, decimal> mapPP_Salary = new Map<id, decimal>();
        Map<id, decimal> mapPP_Day = new Map<id, decimal>();
        Map<id, decimal> mapPP_Month = new Map<id, decimal>();
        Map<id, string> mapSS_SetupCode = new Map<id, string>();
        
        // for DBCa
        Map<Id, Decimal> mapAO_Quantity = new Map<Id, Decimal>();
        Map<String, Decimal> mapFOC_Quantity = new Map<String, Decimal>();
        Map<String, Decimal> mapPayment_Amount = new Map<String, Decimal>();
        Map<Id, Decimal> mapFOC_Btl = new Map<Id, Decimal>();
        
        // for cross-brand
        map<Id, Id> mapSKUCrossSKU = new Map<Id,Id>();
        map<Id, String> mapCrossSKUDesc = new Map<Id, String>();

        // Record Types
        id rtIGC = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_IGC'); // IGC - IntoGodown Cost
        
        integer intIdxActualCase = 0;
        integer intIdxSP = 0;
        integer intIdxIGC = 0;
        
        Date dteStart = system.today();
        Date dteEnd = system.today();
        Id idCustomer;
        Boolean isParent = FALSE;
        // Declaration - End
        
        if (strDBC != 'DBCa')
            strDBC = 'DBCe';
        
        // get Contract detail
        List<ASI_TH_CRM_Contract__c> con = [
                SELECT 
            		ASI_CRM_Commission_Rate__c, 
            		ASI_TH_CRM_Start_Date__c, 
            		ASI_TH_CRM_End_Date__c,
                    ASI_CRM_CN_Outlet_WS__c,
            		LastModifiedDate,
            		ASI_CRM_IsParentContract__c, 
            		ASI_CRM_Market_Responsibility__c 
                FROM ASI_TH_CRM_Contract__c 
                WHERE id = :idContract
        ];
        
        if(con[0].ASI_TH_CRM_Start_Date__c != NULL){
            dteStart = con[0].ASI_TH_CRM_Start_Date__c;
            //Datetime modifiedDatetime = con[0].LastModifiedDate;
            //Date modifiedDate = Date.newInstance(modifiedDatetime.year(), modifiedDatetime.month(), modifiedDatetime.day());
            //dteStart = modifiedDate;
        }
        if(con[0].ASI_TH_CRM_End_Date__c != NULL)
            dteEnd = con[0].ASI_TH_CRM_End_Date__c;
        if(con[0].ASI_CRM_CN_Outlet_WS__c != NULL)
            idCustomer = con[0].ASI_CRM_CN_Outlet_WS__c;
        isParent = con[0].ASI_CRM_IsParentContract__c;
        if(con[0].ASI_CRM_Market_Responsibility__c != NULL)
            strMktResp = con[0].ASI_CRM_Market_Responsibility__c;
        

        // Get SKU list from contract target and all incentive and promoter placement
        // -- ContractTarget --
        for(ASI_CRM_ContractTarget__c i : 
            [SELECT 
             	ASI_CRM_SKU__c, 
             	ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, 
             	ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c,
             	ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c, 
             	ASI_CRM_TargetCase__c, 
             	ASI_CRM_WSSP__c 
             FROM ASI_CRM_ContractTarget__c 
             WHERE ASI_CRM_Contract__c = :idContract]){
                 
            mapSKUTitle.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c);
            setSKU.add(i.ASI_CRM_SKU__c); 
            mapSKUProdCateg.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c);
            
            mapAC.put(i.ASI_CRM_SKU__c, i.ASI_CRM_TargetCase__c);
            mapPacking.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c);
            
            // Wholesaler Selling Price ???
            mapWSSP.put(i.ASI_CRM_SKU__c, i.ASI_CRM_WSSP__c); 
                 
        }
        
        for(Id sku : setSKU){
            system.debug('@@@sku target@@@; '+ sku);
        }
        
        // -- ContractTarget -- 
        
        
        // -- ContractOtherIncentive -- 
        for(ASI_CRM_ContractOtherIncentive__c i : 
            [SELECT 
             	ASI_CRM_SKU__c,
             	ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, 
             	ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c,
             	ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c, 
             	ASI_CRM_Type__c, ASI_CRM_Description__c,
             	ASI_CRM_FOC__c, ASI_CRM_CashInc__c, 
             	ASI_CRM_Total__c, 
             	ASI_CRM_SetupCode__c,
             	ASI_CRM_WSSP__c
             FROM ASI_CRM_ContractOtherIncentive__c 
             WHERE ASI_CRM_Contract__c = :idContract 
             AND ASI_CRM_Exclude__c = false]){
                 
            mapSKUTitle.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c);
            setSKU.add(i.ASI_CRM_SKU__c);
            mapSKUProdCateg.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c);
            mapPacking.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c);
            mapWSSP.put(i.ASI_CRM_SKU__c, i.ASI_CRM_WSSP__c);
            String strKey = i.get('ASI_CRM_SetupCode__c') == null ? '' : (String) i.get('ASI_CRM_SetupCode__c');
            Map<String, Decimal> mapTemp = new Map<String, Decimal>();
            //FOC
            mapTemp = (mapOth_FOC.get(i.ASI_CRM_SKU__c) != null) ? mapOth_FOC.get(i.ASI_CRM_SKU__c) : new Map<String, Decimal>();
             
            if(mapOth_FOC.get(i.ASI_CRM_SKU__c) != null){
                if(mapTemp.get(strKey) != null){
                    Decimal b_value = mapTemp.get(strKey);
                    mapTemp.put(strKey, (i.ASI_CRM_FOC__c+b_value));
                }
                else{
                    mapTemp.put(strKey, i.ASI_CRM_FOC__c);
                }
            }
            else{
            	mapTemp.put(strKey, i.ASI_CRM_FOC__c);
            }
            mapOth_FOC.put(i.ASI_CRM_SKU__c, mapTemp);
            //mapTemp.put(strKey, i.ASI_CRM_FOC__c);     
            //mapOth_FOC.put(i.ASI_CRM_SKU__c, mapTemp);
                 
            //MGTI FOC
            if (i.ASI_CRM_SetupCode__c != null && i.ASI_CRM_SetupCode__c == 'MGTI') {
                Decimal d = 0;
                d = (mapOth_MGTIFOC.get(i.ASI_CRM_SKU__c) != null) ? mapOth_MGTIFOC.get(i.ASI_CRM_SKU__c) : 0;
                mapOth_MGTIFOC.put(i.ASI_CRM_SKU__c, d + (i.ASI_CRM_FOC__c == null ? 0 : i.ASI_CRM_FOC__c));
            }
            //Cash
            mapTemp = (mapOth_Cash.get(i.ASI_CRM_SKU__c) != null) ? mapOth_Cash.get(i.ASI_CRM_SKU__c) : new Map<String, Decimal>();
            if(mapOth_Cash.get(i.ASI_CRM_SKU__c) != null){
                if(mapTemp.get(strKey) != null){
                    Decimal b_value = mapTemp.get(strKey);
                    system.debug('@@@b_value: '+i.ASI_CRM_SKU__c+' || '+b_value);
                    mapTemp.put(strKey, (i.ASI_CRM_CashInc__c+b_value));
                }
                else{
                    mapTemp.put(strKey, i.ASI_CRM_CashInc__c);
                }
            }
            else{
            	mapTemp.put(strKey, i.ASI_CRM_CashInc__c);
            }
            mapOth_Cash.put(i.ASI_CRM_SKU__c, mapTemp);
            //mapTemp.put(strKey, i.ASI_CRM_CashInc__c);
            //mapOth_Cash.put(i.ASI_CRM_SKU__c, mapTemp);
            //Total
            mapTemp = (mapOth_Total.get(i.ASI_CRM_SKU__c) != null) ? mapOth_Total.get(i.ASI_CRM_SKU__c) : new Map<String, Decimal>();
            mapTemp.put(strKey, i.ASI_CRM_Total__c);
            mapOth_Total.put(i.ASI_CRM_SKU__c, mapTemp);
        }
        // -- ContractOtherIncentive --
        for(Id sku : setSKU){
            system.debug('@@@sku Other@@@; '+ sku);
        }
        
        // -- PromoterPlacement -- 
        for(ASI_CRM_PromoterPlacement__c i : 
            [SELECT 
             	ASI_CRM_SKU__c, 
             	ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, 
             	ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c, 
             	ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c, 
             	ASI_CRM_PromoterCount__c, 
             	ASI_CRM_DailySalary__c, 
             	ASI_CRM_WorkingDay__c, 
             	ASI_CRM_WorkingMonth__c, 
             	ASI_CRM_SetupCode__c,
             	ASI_CRM_WSSP__c 
             FROM ASI_CRM_PromoterPlacement__c 
             WHERE ASI_CRM_Contract__c = :idContract 
             AND ASI_CRM_Exclude__c = false]){
                 
            mapSKUTitle.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c);
            setSKU.add(i.ASI_CRM_SKU__c);
            mapSKUProdCateg.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c);
            mapPacking.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c);
            mapWSSP.put(i.ASI_CRM_SKU__c, i.ASI_CRM_WSSP__c);
            mapPP_Count.put(i.ASI_CRM_SKU__c, i.ASI_CRM_PromoterCount__c);
            mapPP_Salary.put(i.ASI_CRM_SKU__c, i.ASI_CRM_DailySalary__c);
            mapPP_Day.put(i.ASI_CRM_SKU__c, i.ASI_CRM_WorkingDay__c);
            mapPP_Month.put(i.ASI_CRM_SKU__c, i.ASI_CRM_WorkingMonth__c);
                 
        }
        // -- PromoterPlacement --
        
        
        // -- ContractSalesStaffIncentive -- 
        for(ASI_CRM_ContractSalesStaffIncentive__c i : 
            [SELECT 
             	ASI_CRM_SKU__c, 
             	ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c, 
             	ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c, 
             	ASI_CRM_FOCPRM__c, 
             	ASI_CRM_FOCWS__c, 
             	ASI_CRM_AchievedBtl__c,
             	ASI_CRM_CashInc__c, 
             	ASI_CRM_SetupCode__c,
             	ASI_CRM_CrossBrandSKU__c, 
             	ASI_CRM_CrossBrandSKU__r.ASI_HK_CRM_Packaging_Size__c,
             	ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c 
             FROM ASI_CRM_ContractSalesStaffIncentive__c 
             WHERE ASI_CRM_Contract__c = :idContract 
             AND ASI_CRM_Exclude__c = false]){
                 
            Decimal temp = 0;
            if(i.ASI_CRM_FOCPRM__c != NULL) temp += i.ASI_CRM_FOCPRM__c;
            if(i.ASI_CRM_FOCWS__c != NULL) temp += i.ASI_CRM_FOCWS__c;
            temp = temp * (i.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c / i.ASI_CRM_AchievedBtl__c); // / (i.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c);
            mapSS_FOC.put(i.ASI_CRM_SKU__c, temp); 
            mapSS_AchievedBtl.put(i.ASI_CRM_SKU__c, i.ASI_CRM_AchievedBtl__c);
            mapSS_CashInc.put(i.ASI_CRM_SKU__c,i.ASI_CRM_CashInc__c);
            mapSS_SetupCode.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SetupCode__c);
			mapVol_FOC.put(i.ASI_CRM_SKU__c, temp);

            //Updated 2018-01 to add cross-brand SKU:
            if(i.ASI_CRM_CrossBrandSKU__c!=null && i.ASI_CRM_CrossBrandSKU__c!= i.ASI_CRM_SKU__c){
                mapSKUCrossSKU.put(i.ASI_CRM_SKU__c, i.ASI_CRM_CrossBrandSKU__c);
                Decimal crossBrandPackagingSize = (i.ASI_CRM_CrossBrandSKU__r.ASI_HK_CRM_Packaging_Size__c != NULL) ? i.ASI_CRM_CrossBrandSKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
                mapCrossBrandPacking.put(i.ASI_CRM_CrossBrandSKU__c, crossBrandPackagingSize);
                mapCrossSKUDesc.put(i.ASI_CRM_CrossBrandSKU__c, i.ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c);
            }
        }
        system.debug('mapSKUCrossSKU='+mapSKUCrossSKU);
        system.debug('mapCrossSKUDesc='+mapCrossSKUDesc);
        // -- ContractSalesStaffIncentive --
        

        // -- ContractVolumeIncentive --
        for(ASI_CRM_ContractVolumeIncentive__c i : 
            [SELECT 
             	ASI_CRM_SKU__c,
             	ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c, 
             	ASI_CRM_FOC__c,
             	ASI_CRM_CashInc__c, 
             	ASI_CRM_SetupCode__c 
             FROM ASI_CRM_ContractVolumeIncentive__c 
             WHERE ASI_CRM_Contract__c = :idContract 
             AND ASI_CRM_Exclude__c = false]){
                 
            //mapVol_FOC.put(i.ASI_CRM_SKU__c, i.ASI_CRM_FOC__c);
            mapVol_Cash.put(i.ASI_CRM_SKU__c, i.ASI_CRM_CashInc__c);
            mapVol_SetupCode.put(i.ASI_CRM_SKU__c, i.ASI_CRM_SetupCode__c);
            if (i.ASI_CRM_SetupCode__c != null && i.ASI_CRM_SetupCode__c.toUpperCase() == 'MGTI') {
                mapVol_MGTIFOC.put(i.ASI_CRM_SKU__c, i.ASI_CRM_FOC__c);
            }
                 
        }
        // Get SKU list from contract target and all incentive and promoter placement - END
        // -- ContractVolumeIncentive -- 
         
        
        // Start initialize master data
        if(strDBC == 'DBCe'){
            if(con[0].ASI_CRM_Commission_Rate__c != NULL)
                decCommRate = con[0].ASI_CRM_Commission_Rate__c;
            
            Set<id> setCrossSKU = new Set<id>();
            for (id idSKU : mapSKUCrossSKU.keySet()) {
                Id cross_sku = mapSKUCrossSKU.get(idSKU);
                setCrossSKU.add(cross_sku);
            }
            if(mapSKUCrossSKU.size() > 0){
            	mapCrossBrandIGC = ASI_CRM_MY_Function.getSKUIGC(setCrossSKU, dteStart, rtIGC);    
            }
            
            mapIGC = ASI_CRM_MY_Function.getSKUIGC(setSKU, dteStart, rtIGC);
            mapDistCost = ASI_CRM_MY_Function.getDistributionCost(dteStart);
        }else if(strDBC == 'DBCa'){
            DBC_A var = getDBCaMap(idContract, idCustomer, dteStart, dteEnd, isParent);
            
            mapAO_Quantity = var.mapAO_Quantity;
            mapFOC_Quantity = var.mapFOC_Quantity;
            //mapVol_Cash = var.mapPayment_Amount;
            mapPayment_Amount = var.mapPayment_Amount;
            mapFOC_Btl = var.mapFOC_Btl;
            
            List<ASI_CRM_MY_Settings__c> LstMYSetting = [SELECT ASI_CRM_MY_Salesman_Commission__c FROM ASI_CRM_MY_Settings__c LIMIT 1];
            
            if(LstMYSetting[0].ASI_CRM_MY_Salesman_Commission__c != NULL)
                decCommRate  = LstMYSetting[0].ASI_CRM_MY_Salesman_Commission__c;
            system.debug('------setSKU ' + setSKU);
            system.debug('------date.today() ' + date.today());
            system.debug('------rtIGC ' + rtIGC);
            
            Set<id> setCrossSKU = new Set<id>();
            for (id idSKU : mapSKUCrossSKU.keySet()) {
                Id cross_sku = mapSKUCrossSKU.get(idSKU);
                setCrossSKU.add(cross_sku);
            }
            if(mapSKUCrossSKU.size() > 0){
            	mapCrossBrandIGC = ASI_CRM_MY_Function.getSKUIGC(setCrossSKU, dteStart, rtIGC);    
            }
            mapIGC = ASI_CRM_MY_Function.getSKUIGC(setSKU, date.today(), rtIGC);
            mapDistCost = ASI_CRM_MY_Function.getDistributionCost(date.today());
        }
        // Start initialize master data - End

        // Row #1
        // Reset for this row
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for (ID i : setSKU){
            Decimal temp = 0;
            if(strDBC == 'DBCe'){
                if(mapAC.get(i) != null)
                    temp = mapAC.get(i);
            }else if(strDBC == 'DBCa'){
                if(mapAO_Quantity.get(i) != null )
                    temp = mapAO_Quantity.get(i);
            }
            
            system.debug('@@@temp Row@@@: '+ i +' : '+  temp);
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Actual Case Sales Volume');
        mapIdx.put('SELL_CASE', intLineCount); 
        mapTblData.put(intLineCount, mapSKUData); 
        intLineCount++;
        // Row #1 - End
        
        // Row #2
        // """WS SP * Pack Factor"" from the Contract Sales Target Tab
        // The WS is filled on creating the target entry, transparent to users
        // The WS SP is retrieve from SKU table according to the contract start date, and stored into the contract table for snapshot"
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for (ID i : setSKU) {
            Decimal temp = 0;
            if(mapPacking.get(i) != NULL)
                temp = mapPacking.get(i);
            if(mapWSSP.get(i) != NULL)
                temp = temp * mapWSSP.get(i);
            mapSKUData.put(i, temp);
        }
        mapRowTitle.put(intLineCount, 'Selling Price Per Actual Case');
        mapIdx.put('SELL_PRICE', intLineCount); 
        mapTblData.put(intLineCount, mapSKUData); 
        intLineCount++;
        // Row #2 - End
        
        // Row #3 - IGC per case
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(id idTemp : setSKU){
            // "IGC * Pack Factor" is retrieve from SKU table when the SKU is defined in the contract target, according to the contract start date
            Decimal temp = 0;
            if(mapIGC.get(idTemp) != NULL)
                temp = mapIGC.get(idTemp);
            if(mapPacking.get(idTemp) != NULL)
                temp = temp * mapPacking.get(idTemp) * -1;
            mapSKUData.put(idTemp, temp);
        }
        mapRowTitle.put(intLineCount, 'IGC per case'); 
        mapIdx.put('IGC', intLineCount); 
        mapTblData.put(intLineCount, mapSKUData); 
        intLineCount++;
        // Row #3 - IGC per case - End
        
        // Row #4 - header - Allowances (SUB-Title)
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID idTemp : setSKU){
            mapSKUData.put(idTemp, 0); 
        }
        mapRowIsTitle.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Allowances');
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #4 - header - Allowances - End
        
        // Row #5 - Mgt Incentives - Variable Sales FOC
        // DBCe
        //      Sales & Staff TAB --> FOC(PRM) + FOC(WS)"    setup Code == SAVR
       
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = 0;
            if(strDBC == 'DBCe'){
                if(mapSS_FOC.get(i) != NULL)
                temp = mapSS_FOC.get(i);
            }else if(strDBC == 'DBCa'){
                if(mapSS_FOC.get(i) != NULL)
                temp = mapSS_FOC.get(i) / mapPacking.get(i);
            }
            mapSKUData.put(i, temp);
        }
        mapRowTitle.put(intLineCount, 'Mgt Incentives - Variable sales FOC');
        mapIdx.put('MI_VAR_SALES_FOC', intLineCount); 
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #5 - Mgt Incentives - Variable Sales FOC - End
        
        // Row #6 - Mgt Incentives - Variable sales 
        // DBCe
        //      sales target in cases * Pack Factor / SS Incentive ACHIEVED BOTTLE * foc (ws + PRM) / Pack Factor
        //      sales target in cases * packing / ACHIEVED BOTTLE * foc (ws + prm) / packing on Sales Inc and Staff Inc tab
        //      Achieved bottle entered in the sales & staff incentive
        // DBCa
        //      To summarized the FIS on the outlet. That to calculate according to the actual purchase in DBC/A in point #1. 
        //      No matter if the bottle is really issued to outlet or not. It calculates again here according to the contract specification.
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = 0;
            //if(mapVol_SetupCode.get(i) == 'MGTI'){
                if(mapAC.get(i) != NULL)
                    temp = mapAC.get(i);
                if(strDBC == 'DBCe'){
                    //if(mapPacking.get(i) != NULL){
                        //temp = temp / mapPacking.get(i); 
                        //temp = temp / mapCrossBrandPacking.get(mapSKUCrossSKU.get(i));
                        // * mapTblData.get(mapIdx.get('SELL_CASE')).get(i);
                    //}
                    if(mapSKUCrossSKU.containsKey(i)){
                        if( mapCrossBrandPacking.containsKey(mapSKUCrossSKU.get(i))){
                        	temp = temp / mapCrossBrandPacking.get(mapSKUCrossSKU.get(i));
                        }
                        else{
                            if(mapPacking.get(i) != NULL){
                            	temp = temp / mapPacking.get(i); 
                            }
                        }
                    }
                    else{
                        if(mapPacking.get(i) != NULL){
                            temp = temp / mapPacking.get(i); 
                        }
                    }
                }
                if(strDBC == 'DBCe'){
                    temp = temp * (mapSS_FOC.get(i) != null ? mapSS_FOC.get(i) : 0);
                } 
            	else if(strDBC == 'DBCa'){
                    //temp = temp * (mapSS_FOC.get(i) != NULL ? mapSS_FOC.get(i) : 0);
                    temp = mapTblData.get(mapIdx.get('MI_VAR_SALES_FOC')).get(i) * mapTblData.get(mapIdx.get('SELL_CASE')).get(i);
                }
                
            //}
            mapSKUData.put(i, temp);
        }
        mapRowTitle.put(intLineCount, 'Mgt Incentives - Variable sales');
        mapIdx.put('MGT_INCSales', intLineCount); 
        mapTblData.put(intLineCount, mapSKUData); 
        intLineCount++;
        // Row #6 - Mgt Incentives - Variable sales - End
        
        // Row #7 - Mgt Incentives - Fixed
        // Vol Incentive FOC / Pack Factor
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = 0;
            if (mapVol_SetupCode.get(i) == 'MGTI') {
                //if(mapVol_FOC.get(i) != NULL)
                if(mapVol_MGTIFOC.get(i) != NULL && mapPacking.get(i) != NULL && mapPacking.get(i) != 0) {
                    temp = mapVol_MGTIFOC.get(i) / mapPacking.get(i);
                }
            }
            if (mapOth_MGTIFOC.get(i) != null && mapPacking.get(i) != NULL && mapPacking.get(i) != 0) {
                temp += mapOth_MGTIFOC.get(i) / mapPacking.get(i);
            }
            mapSKUData.put(i, temp);
        }
        mapRowTitle.put(intLineCount, 'Mgt Incentives - Fixed'); 
        mapIdx.put('MGT_INCFixed', intLineCount); 
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #7 - Mgt Incentives - Fixed - End
        
        // Row #8 - Per Bottle Incentives - Cash
        //"S&S Incentive --> Cash Inc / Achieved (Btl)"
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = 0;
            if(mapSS_CashInc.get(i) != NULL)
                temp = mapSS_CashInc.get(i);
            if(mapSS_AchievedBtl.get(i) != NULL && mapSS_AchievedBtl.get(i) != 0)
                temp = temp / mapSS_AchievedBtl.get(i);
            mapSKUData.put(i, temp);
        }
        mapRowTitle.put(intLineCount, 'Per Bottle Incentives - Cash'); 
        mapIdx.put('PER_BOT_INC_CASH', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #8 - Per Bottle Incentives - Cash - End
        
        // Row #9 - Selling & Distribution Cost (SUB-Title)
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            mapSKUData.put(i, 0);
        }
        mapRowIsTitle.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Selling & Distribution Cost'); 
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #9 - Selling & Distribution Cost - End
        
        // Row #10 - Distribution cost per case - revenue
        // "Distribution Cost --> Product cat > Distribution Cost > Effective Date Ref#: SIF_MY1.xlsx ! Product"
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID idTemp : setSKU){
            mapSKUData.put(idTemp, 0);
            id idProdCateg;
            decimal temp = 0;
            if (mapSKUProdCateg.get(idTemp) != null) {
                idProdCateg = mapSKUProdCateg.get(idTemp);
                if (mapDistCost.get(mapSKUProdCateg.get(idTemp)) != null) {
                    if (mapDistCost.get(mapSKUProdCateg.get(idTemp)).get(strMktResp) != null) {
                        if (mapDistCost.get(mapSKUProdCateg.get(idTemp)).get(strMktResp).get('REVENUE') != null) {
                            temp = (decimal) mapDistCost.get(mapSKUProdCateg.get(idTemp)).get(strMktResp).get('REVENUE');
                            temp = temp * -1;
                            mapSKUData.put(idTemp, temp);
                        }
                    }
                }
            }
        }
        mapRowTitle.put(intLineCount, 'Distribution cost per case - revenue');
        mapIdx.put('DISTRIBUTION_COST', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #10 - Distribution cost per case - revenue - End
        
        // Row #11 - Distribution cost per case - allowances
        // "Distribution Cost --> Product cat > Distribution Cost > Effective Date Ref#: SIF_MY1.xlsx ! Product"
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID idTemp : setSKU){
            mapSKUData.put(idTemp, 0);
            id idProdCateg;
            decimal temp = 0;
            if (mapSKUProdCateg.get(idTemp) != null) {
                idProdCateg = mapSKUProdCateg.get(idTemp);
                if (mapDistCost.get(mapSKUProdCateg.get(idTemp)) != null) {
                    if (mapDistCost.get(mapSKUProdCateg.get(idTemp)).get(strMktResp) != null) {
                        if (mapDistCost.get(mapSKUProdCateg.get(idTemp)).get(strMktResp).get('ALLOWANCE') != null) {
                            temp = (decimal) mapDistCost.get(mapSKUProdCateg.get(idTemp)).get(strMktResp).get('ALLOWANCE');
                            temp = temp * -1;
                            mapSKUData.put(idTemp, temp);
                        }
                    }
                }
            }
        }
        mapRowTitle.put(intLineCount, 'Distribution cost per case - allowances');
        mapIdx.put('DISTRIBUTION_COST_ALLOWANCES', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #11 - Distribution cost per case - allowances - End
        
        // Row #12 - Salesman commission
        // "Define in SFDC Custom Setting maintain by Regional IT 
        // Rate is pulled and fixed on the creation of the contract"
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID idTemp : setSKU){
            mapSKUData.put(idTemp, decCommRate * -1);
        }
        mapRowTitle.put(intLineCount, 'Salesman commission');
        mapIdx.put('SALES_COMMISSION', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #12 - Salesman commission - allowances - End
        
        // Row #13 - Statutory P&L - allowance at IGC Cost (SUB-Title) // AXEL HELP ME, VF page will display ZERO but not blank
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            mapSKUData.put(i, 0);
        }
        mapRowIsTitle.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Statutory P&L - allowance at IGC Cost');
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #13 - Statutory P&L - allowance at IGC Cost - End
        
        // Row 14 - Gross Sales
        // = Actual Case Sales Volume * Selling Price per Actual Case <--- #1 * #2
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = 0;
            temp = mapTblData.get(mapIdx.get('SELL_CASE')).get(i) * mapTblData.get(mapIdx.get('SELL_PRICE')).get(i);
            
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Gross Sales');
        mapIdx.put('GROSS_SALES', intLineCount); 
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #14 - Gross Sales - End
        
        // Row 15 - Cost of Sales - revenue sales cases
        // = Actual Case Sales Volume * IGC per case <--- #1 * #3
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = mapTblData.get(mapIdx.get('SELL_CASE')).get(i) * mapTblData.get(mapIdx.get('IGC')).get(i);
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Cost of Sales - revenue sales cases');
        mapIdx.put('COST_SALES_REVENUE', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #15 - Cost of Sales - revenue sales cases - End
        
        // Row 16 - Cost of Sales - variable sales incentives cases
        // = IGC per Case * Mgt Inc variable slaes <--- #3 * #6
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = 0;
            if(strDBC == 'DBCe'){
                if( mapSKUCrossSKU.containsKey(i) && mapCrossBrandIGC.size() >0 ){
                    Decimal crossBrandIGC = mapCrossBrandIGC.get(mapSKUCrossSKU.get(i));
                    Decimal crossBrandPacking = mapCrossBrandPacking.get(mapSKUCrossSKU.get(i)) * -1;
                    temp = (crossBrandIGC * crossBrandPacking) * mapTblData.get(mapIdx.get('MGT_INCSales')).get(i);
                    //temp = -mapCrossBrandIGC.get(mapSKUCrossSKU.get(i)) * mapTblData.get(mapIdx.get('MGT_INCSales')).get(i);
                }
                else{
                    temp = mapTblData.get(mapIdx.get('IGC')).get(i) * mapTblData.get(mapIdx.get('MGT_INCSales')).get(i);
                }
            }
            else{
                temp = mapTblData.get(mapIdx.get('IGC')).get(i) * mapTblData.get(mapIdx.get('MGT_INCSales')).get(i);
            }
            
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Cost of Sales - variable sales incentives cases');
        mapIdx.put('COST_SALES_VARIABLE', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); 
        intLineCount++;
        // Row #16 - Cost of Sales - variable sales incentives cases - End
        
        // Row 17 - Cost of Sales - fixed incentive cases
        // = IGC per Case * Mgt Inc fixed <--- #3 * #7
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = mapTblData.get(mapIdx.get('IGC')).get(i) * mapTblData.get(mapIdx.get('MGT_INCFixed')).get(i);
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Cost of Sales - fixed incentive cases');
        mapIdx.put('COST_SALES_FIXED', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #17 - Cost of Sales - fixed incentive cases - End
        
        // Row #18 - Gross Margin
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = mapTblData.get(mapIdx.get('GROSS_SALES')).get(i) + 
                           mapTblData.get(mapIdx.get('COST_SALES_REVENUE')).get(i) +
                           mapTblData.get(mapIdx.get('COST_SALES_VARIABLE')).get(i) +
                           mapTblData.get(mapIdx.get('COST_SALES_FIXED')).get(i);
            
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Gross Margin');
        mapIdx.put('GROSS_MARGIN', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #18 - Gross Margin - End
        
        // Row #19 - Selling & Distribution Cost (SUB-Title)
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            mapSKUData.put(i, 0);
        }
        mapRowIsTitle.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Selling & Distribution Cost');
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #19 - Selling & Distribution Cost - End
        
        // Row #20 - Distribution cost per case - revenue
        // Actual Case Sales Volume * Distribution cost per case revenue <-- #1 * #10
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = mapTblData.get(mapIdx.get('SELL_CASE')).get(i) * mapTblData.get(mapIdx.get('DISTRIBUTION_COST')).get(i);
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Distribution cost per case - revenue');
        mapIdx.put('DISTRIBUTION_COST_UNDER_GM', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #20 - Distribution cost per case - revenue - End
        
        // Row #21 - Distribution cost per case - allowances
        // Mgt Incentives( Variable + Fixed) * Distribution cost per case allowances <--- (#6 + #7) * #11
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = mapTblData.get(mapIdx.get('MGT_INCSales')).get(i) + mapTblData.get(mapIdx.get('MGT_INCFixed')).get(i);
            temp = temp * mapTblData.get(mapIdx.get('DISTRIBUTION_COST_ALLOWANCES')).get(i);
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Distribution cost per case - allowances');
        mapIdx.put('DISTRIBUTION_COST_ALLOWANCES_UNDER_GM', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #21 - Distribution cost per case - allowances - End
        
        // Row #22 - Trade A&P
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            mapSKUData.put(i, 0);
        }
        mapRowIsTitle.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Trade A&P');
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #22 - Trade A&P - End
        
        // Row #23 - Salesman commission
        // Salesman commission * Gross Margin <--- #12 * #18
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = mapTblData.get(mapIdx.get('SALES_COMMISSION')).get(i) * mapTblData.get(mapIdx.get('GROSS_SALES')).get(i);
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Salesman commission');
        mapIdx.put('Trade_AP_SALES_COMMISSION', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #23 - Salesman commission - End

        // Row #24 - Bottles cash incentive - revenue, without FOC
        // Actual Case Sales Volume * Per Bottle Incentives - Cash <--- #1 * #8 * pack factor
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = mapTblData.get(mapIdx.get('SELL_CASE')).get(i) * mapTblData.get(mapIdx.get('PER_BOT_INC_CASH')).get(i);
            if(mapPacking.get(i) != NULL)
                temp = temp * mapPacking.get(i);
            temp = temp * -1;
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Bottles cash incentive - revenue, without FOC');
        mapIdx.put('Trade_AP_CASH', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #24 - Bottles cash incentive - revenue, without FOC - End
        
        // Row #25 - Bottles cash incentive on allowances
        // Mgt Incentives( Variable + Fixed) * per bottle incentives cash <--- (#6 + #7) * #8
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = mapTblData.get(mapIdx.get('MGT_INCSales')).get(i) + mapTblData.get(mapIdx.get('MGT_INCFixed')).get(i);
            temp = temp * mapTblData.get(mapIdx.get('PER_BOT_INC_CASH')).get(i);
            temp = temp * -1;
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Bottles cash incentive on allowances');
        mapIdx.put('Trade_AP_CASH_ALLOWANCES', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); 
        intLineCount++;
        // Row #25 - Bottles cash incentive on allowances - End
        
        // Row #26 - Sponsorship for festives/special occassions (SUB-Title)
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            mapSKUData.put(i, 0);
        }
        mapRowIsTitle.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Sponsorship for festives/special occassions');
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #26 - Sponsorship for festives/special occassions - End

        // Row #27 - Trade A&P - Volume Incentive
        // Group by Volume Incentive's Event Type
        // CASH inc  + FOC * Pack Factor * IGC per case
        // Show Vol Incentive - Desc as the DBC row title
        // Dynamic generate to rows according to different types
        

        map<string, set<id>> mapSetupCodeSS = new map<string, set<id>>(); 
        map<string, set<id>> mapSetupCodeVol = new map<string, set<id>>(); 
        map<string, set<id>> mapSetupCodeOther = new map<string, set<id>>(); 
        
        /*
        if(strDBC == 'DBCe' && !isCompareReport){
            for(AggregateResult i : [
                    SELECT ASI_CRM_Description__c, ASI_CRM_SKU__c
                    FROM ASI_CRM_ContractVolumeIncentive__c 
                    WHERE ASI_CRM_Contract__c = :idContract 
                    AND ASI_CRM_Exclude__c = false
                    AND ASI_CRM_AchievedBtl__c != NULL
                    //AND (ASI_CRM_SetupCode__c = 'VOLC' OR ASI_CRM_SetupCode__c = 'SAVR')
                    AND (ASI_CRM_SetupCode__c != 'MGTI')
                    GROUP BY ASI_CRM_Description__c, ASI_CRM_SKU__c
                ]){
                Set<id> setTemp = new Set<id>();
                setVolDesc.add('VOL : ' + (String) i.get('ASI_CRM_Description__c'));
                if (mapVolDesc.get((String) i.get('ASI_CRM_Description__c')) != null) {
                    setTemp = mapVolDesc.get((String) i.get('ASI_CRM_Description__c'));
                }
                setTemp.add((id) i.get('ASI_CRM_SKU__c'));
                mapVolDesc.put((String) i.get('ASI_CRM_Description__c'), setTemp);
            }
        }
        Map<id, decimal> mapSKUVolDescData = new Map<id, decimal>();
        for(String s : setVolDesc){
            s = s.removeStart('VOL : ');
            mapSKUData = new Map<id, decimal>(); // Reset for this row
            for(ID i : setSKU){
                Decimal temp = 0;
                if(mapVolDesc.get(s) != null){
                    if(mapVolDesc.get(s).contains(i)){
                        if(MapVol_Cash.get(i) != NULL){
                            if(strDBC == 'DBCe'){
                                temp += MapVol_Cash.get(i);
                            }
                        }
                    }
                }
                temp = temp * -1;
				
                mapSKUData.put(i, temp);
                system.debug('@@@temp VolDesc: '+temp);
                mapSKUVolDescData.put(i, temp);
            }
        }
        if(strDBC == 'DBCe' && !isCompareReport){
            for(AggregateResult i : [
                    SELECT ASI_CRM_Description__c, ASI_CRM_SKU__c
                    FROM ASI_CRM_ContractOtherIncentive__c 
                    WHERE ASI_CRM_Contract__c = :idContract 
                    AND ASI_CRM_Exclude__c = false
                    //AND ASI_CRM_SetupCode__c IN ('SPON', 'BANQ', 'DISP')
                    AND (ASI_CRM_SetupCode__c != 'MGTI')
                    GROUP BY ASI_CRM_Description__c, ASI_CRM_SKU__c
                ]){
                    Set<id> setTemp = new Set<id>();
                    String strKey = i.get('ASI_CRM_Description__c') == null ? '' : (String) i.get('ASI_CRM_Description__c');
        
                    if (strKey != null && strKey != '') {
                        setOthDesc.add('OTHER : ' + strKey);
                        if (mapOthDesc.get(strKey) != null) {
                            setTemp = mapOthDesc.get(strKey);
                        }
                        setTemp.add((id) i.get('ASI_CRM_SKU__c'));
                        mapOthDesc.put(strKey, setTemp);
                    }
            }
        }
        Map<id, decimal> mapSKUOthDescData = new Map<id, decimal>();
        for(String s : setOthDesc){
            s = s.removeStart('OTHER : ');
            mapSKUData = new Map<id, decimal>(); // Reset for this row
            for(ID idTemp : setSKU) {
                Decimal temp = 0;
                
                if (mapOthDesc.get(s) != null) {
                    if (mapOthDesc.get(s).contains(idTemp)){
                        if(mapOth_Cash.get(idTemp) != NULL){
                            if(mapOth_Cash.get(idTemp).get(s) != null){
                                if(strDBC == 'DBCe'){
                                    temp += mapOth_Cash.get(idTemp).get(s);
                                }
                            }
                        }
                    }
                }
                temp = temp * -1;
                mapSKUData.put(idTemp, temp);
                system.debug('@@@temp OthDesc: '+temp);
                mapSKUOthDescData.put(idTemp, temp);
            }
        }
        */
        
		set<string> setSetupCode = new set<string>();        
        
            
        	AggregateResult[] resultSS = 
                [SELECT  
                	ASI_CRM_SKU__c,
                	ASI_CRM_SetupCode__c
                FROM ASI_CRM_ContractSalesStaffIncentive__c 
                WHERE ASI_CRM_Contract__c = :idContract 
                AND ASI_CRM_Exclude__c = false
                AND ASI_CRM_AchievedBtl__c != NULL
                AND (ASI_CRM_SetupCode__c != 'MGTI')
                GROUP BY ASI_CRM_SetupCode__c, ASI_CRM_SKU__c];
        
            for(AggregateResult i : resultSS){
                Set<id> setTemp = new Set<id>();
                String strKey = (String) i.get('ASI_CRM_SetupCode__c');
    
                if (strKey != null && strKey != '') {
                    setSetupCode.add(strKey);
                    if (mapSetupCodeSS.get(strKey) != null) {
                        setTemp = mapSetupCodeSS.get(strKey);
                    }
                    setTemp.add((id) i.get('ASI_CRM_SKU__c'));
                    mapSetupCodeSS.put(strKey, setTemp);
                }
            }
            system.debug('@@@resultSS@@@: '+resultSS);
            
        	
        	AggregateResult[] resultVol = 
                [SELECT  
                	ASI_CRM_SKU__c,
                	ASI_CRM_SetupCode__c
                FROM ASI_CRM_ContractVolumeIncentive__c 
                WHERE ASI_CRM_Contract__c = :idContract 
                AND ASI_CRM_Exclude__c = false
                AND ASI_CRM_AchievedBtl__c != NULL
                AND (ASI_CRM_SetupCode__c != 'MGTI')
                GROUP BY ASI_CRM_SetupCode__c, ASI_CRM_SKU__c];
        
            for(AggregateResult i : resultVol){
                Set<id> setTemp = new Set<id>();
                String strKey = (String) i.get('ASI_CRM_SetupCode__c');
    
                if (strKey != null && strKey != '') {
                    setSetupCode.add(strKey);
                    if (mapSetupCodeVol.get(strKey) != null) {
                        setTemp = mapSetupCodeVol.get(strKey);
                    }
                    setTemp.add((id) i.get('ASI_CRM_SKU__c'));
                    mapSetupCodeVol.put(strKey, setTemp);
                }
            }
            system.debug('@@@resultVol@@@: '+resultVol);
        
        	
        	AggregateResult[] resultOther = 
                [SELECT  
                	ASI_CRM_SKU__c,
                	ASI_CRM_SetupCode__c
                FROM ASI_CRM_ContractOtherIncentive__c 
                WHERE ASI_CRM_Contract__c = :idContract 
                AND ASI_CRM_Exclude__c = false
                //AND ASI_CRM_AchievedBtl__c != NULL
                AND (ASI_CRM_SetupCode__c != 'MGTI')
                GROUP BY ASI_CRM_SetupCode__c, ASI_CRM_SKU__c];    
        
            for(AggregateResult i : resultOther){
                Set<id> setTemp = new Set<id>();
                String strKey = (String) i.get('ASI_CRM_SetupCode__c');
    
                if (strKey != null && strKey != '') {
                    setSetupCode.add(strKey);
                    if (mapSetupCodeOther.get(strKey) != null) {
                        setTemp = mapSetupCodeOther.get(strKey);
                    }
                    setTemp.add((id) i.get('ASI_CRM_SKU__c'));
                    mapSetupCodeOther.put(strKey, setTemp);
                }
            }
        	system.debug('@@@resultOther@@@: '+resultOther);
                        
        if(strDBC == 'DBCe'){
            for(String s : setSetupCode){
                mapSKUData = new Map<id, decimal>(); // Reset for this row
                for(ID idTemp : setSKU) {
                    Decimal temp = 0;
                    /*
                    if (mapSetupCodeSS != null && mapSetupCodeSS.size() > 0 && mapSetupCodeSS.get(s) != null) {
                        if (mapSetupCodeSS.get(s).contains(idTemp)){
                            if(MapVol_Cash.get(idTemp) != NULL){
                                temp += MapVol_Cash.get(idTemp);
                            }
                            if(MapVol_FOC.get(idTemp) != NULL && MapPacking.get(idTemp) != NULL && mapIGC.get(idTemp) != NULL){
                                temp += MapVol_FOC.get(idTemp) * mapIGC.get(idTemp);
                            }
                        }
                        
                        
                    }
                    */
                    
                    if (mapSetupCodeVol != null && mapSetupCodeVol.size() > 0 && mapSetupCodeVol.get(s) != null) {
                        if (mapSetupCodeVol.get(s).contains(idTemp)){
                            if(MapVol_Cash.get(idTemp) != NULL){
                                temp += MapVol_Cash.get(idTemp);
                            }
                            /*
                            if(MapVol_FOC.get(idTemp) != NULL && MapPacking.get(idTemp) != NULL && mapIGC.get(idTemp) != NULL){
                                temp += MapVol_FOC.get(idTemp) * mapIGC.get(idTemp);
                            }
							*/
                        }
                    }
                    
                    if (mapSetupCodeOther != null && mapSetupCodeOther.size() > 0 && mapSetupCodeOther.get(s) != null) {
                        if (mapSetupCodeOther.get(s).contains(idTemp)){
                            if(mapOth_Cash.get(idTemp) != NULL){
                                system.debug('@@@mapOth_Cash@@@: '+mapOth_Cash.get(idTemp).get(s));
                                if(mapOth_Cash.get(idTemp).get(s) != null){
                                    temp += mapOth_Cash.get(idTemp).get(s);
                                }
                            }
                            if(mapOth_FOC.get(idTemp) != NULL && mapIGC.get(idTemp) != NULL) {
                                if(mapOth_FOC.get(idTemp).get(s) != null){
                                    temp += mapOth_FOC.get(idTemp).get(s) * mapIGC.get(idTemp);
                                }
                            }
                        }
                    }
					
                    
                    /*
                    if(mapOth_Cash.get(idTemp) != NULL){
                        system.debug('@@@mapOth_Cash@@@: '+mapOth_Cash.get(idTemp).get(s));
                        if(mapOth_Cash.get(idTemp).get(s) != null){
                            temp += mapOth_Cash.get(idTemp).get(s);
                        }
                    }
                    
                    if(mapOth_FOC.get(idTemp) != NULL && MapIGC.get(idTemp) != NULL) {
                        if(mapOth_FOC.get(idTemp).get(s) != null){
                            if(strDBC == 'DBCe'){
                                temp += mapOth_FOC.get(idTemp).get(s) * MapIGC.get(idTemp);
                            }
                        }
                    }
                    */
                    temp = temp * -1;
                    mapSKUData.put(idTemp, temp);
                }
                
                mapRowAddTotal.put(intLineCount, true);
                mapRowTitle.put(intLineCount, s); 
                mapIdx.put(s, intLineCount);
                mapTblData.put(intLineCount, mapSKUData); 
                intLineCount++;
            }
            
        }
        // Row #28 - Additional Volume Incentive (Other Inc) - END
        
        
        // Row #28 - DBCa
        map<string, set<id>> mapSetupCodePR = new map<string, set<id>>(); 
        set<id> setPR = new set<id>();
        map<string, set<id>> mapSetupCodeFOC = new map<string, set<id>>(); 
        set<id> setFOC = new set<id>();
        //set<string> setSetupCode = new set<string>();
        
        if(strDBC == 'DBCa'){
            for(ASI_TH_CRM_PaymentRequest__c i : [
                    SELECT Id
                    FROM ASI_TH_CRM_PaymentRequest__c
                    WHERE ASI_TH_CRM_Contract__c = :idContract 
                    AND (ASI_TH_CRM_Status__c = 'Approved' 
                    OR ASI_TH_CRM_Status__c = 'Final')
                ]){
                    setPR.add(i.Id);
            }
            
            for(ASI_FOC_Free_Goods_Request__c i : [
                SELECT Id 
                FROM ASI_FOC_Free_Goods_Request__c
                WHERE ASI_CRM_Contract__c = :idContract
                AND (ASI_CRM_Status__c = 'Final' 
                OR ASI_CRM_Status__c = 'Not Converted')
            ]){
                setFOC.add(i.id);
            }
        
        
            if(setPR != null && setPR.size() > 0)
            for(AggregateResult i : [
                    SELECT ASI_CRM_SetupCode__c, ASI_CRM_SKU__c
                    FROM ASI_TH_CRM_PaymentRequestLineItem__c
                    WHERE ASI_TH_CRM_Payment_Request__c IN :setPR
                    AND (ASI_CRM_SetupCode__c != 'MGTI')
                    AND ASI_CRM_SetupCode__c != null
                	AND ASI_CRM_SetupCode__c IN :setSetupCode
                    GROUP BY ASI_CRM_SetupCode__c, ASI_CRM_SKU__c
                ]){
                    Set<id> setTemp = new Set<id>();
                    String strKey = (String) i.get('ASI_CRM_SetupCode__c');
        
                    if (strKey != null && strKey != '') {
                        setSetupCode.add(strKey);
                        if (mapSetupCodePR.get(strKey) != null) {
                            setTemp = mapSetupCodePR.get(strKey);
                        }
                        setTemp.add((id) i.get('ASI_CRM_SKU__c'));
                        mapSetupCodePR.put(strKey, setTemp);
                    }
            }
            
            if(setFOC != null && setFOC.size() > 0)
            for(AggregateResult i : [
                    SELECT ASI_CRM_SetupCode__c, ASI_FOC_SKU__c
                    FROM ASI_FOC_Request_Item__c
                    WHERE ASI_FOC_Request_Order__c IN :setFOC
                    AND (ASI_CRM_SetupCode__c != 'MGTI')
                    AND ASI_CRM_SetupCode__c != null
                	AND ASI_CRM_SetupCode__c IN :setSetupCode
                    GROUP BY ASI_CRM_SetupCode__c, ASI_FOC_SKU__c
                ]){
                    Set<id> setTemp = new Set<id>();
                    String strKey = (String) i.get('ASI_CRM_SetupCode__c');
        
                    if (strKey != null && strKey != '') {
                        setSetupCode.add(strKey);
                        if (mapSetupCodeFOC.get(strKey) != null) {
                            setTemp = mapSetupCodeFOC.get(strKey);
                        }
                        setTemp.add((id) i.get('ASI_FOC_SKU__c'));
                        mapSetupCodeFOC.put(strKey, setTemp);
                    }
            }
            
            for(String s : setSetupCode){
                mapSKUData = new Map<id, decimal>(); // Reset for this row
                for(ID idTemp : setSKU) {
                    Decimal temp = 0;
                    
                    if (mapSetupCodePR != null && mapSetupCodePR.size() > 0 && mapSetupCodePR.get(s) != null) {
                        String payment_amount_key = s+'_'+idTemp;
                        if (mapSetupCodePR.get(s).contains(idTemp)){
                            if(mapPayment_Amount.get(payment_amount_key) != NULL){
                                temp += mapPayment_Amount.get(payment_amount_key);
                            }
                        }
                    }
                    
                    if (mapSetupCodeFOC != null && mapSetupCodeFOC.size() > 0 && mapSetupCodeFOC.get(s) != null) {
                        String foc_req_key = s+'_'+idTemp;
                        if (mapSetupCodeFOC.get(s).contains(idTemp)){
                            if(mapFOC_Quantity != null && mapFOC_Quantity.size() > 0 && mapFOC_Quantity.get(foc_req_key) != NULL && MapIGC.get(idTemp) != null){
                                temp += mapFOC_Quantity.get(foc_req_key) * MapIGC.get(idTemp);
                            }
                        }
                    }
                    
                    temp = temp * -1;
                    mapSKUData.put(idTemp, temp);
                }
                
                mapRowAddTotal.put(intLineCount, true);
                mapRowTitle.put(intLineCount, s); 
                mapIdx.put(s, intLineCount);
                //mapIdx.put('SETPCODE', intLineCount);
                mapTblData.put(intLineCount, mapSKUData); intLineCount++;
            }
        }
        
        // Row #29 - Promoters Placement
        // In Promoter Placement Tab --> No of Promoter * Working Days * wage * No. of Month
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = 0;
            if(mapPP_Count.get(i) != NULL && mapPP_Salary.get(i) != NULL && mapPP_Day.get(i) != NULL && mapPP_Month.get(i) != NULL)
            temp = mapPP_Count.get(i) * mapPP_Salary.get(i) * mapPP_Day.get(i) * mapPP_Month.get(i);
            temp = temp * -1;
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Promoters Placement');
        mapIdx.put('PROMOTER', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // Row #29 - Promoters Placement - End
        
        // #30 - Contributive Margin
        // Add all A&P incentive
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        
        for(ID i : setSKU){
            Decimal temp = 0;
            temp = mapIdx.get('GROSS_MARGIN') != null ? mapTblData.get(mapIdx.get('GROSS_MARGIN')).get(i) : 0;
            /*
            for(String s : setVolDesc){
                temp += mapIdx.get('VOLC') != null ? mapTblData.get(mapIdx.get('VOLC')).get(i) : 0;
            }
            temp += mapIdx.get('SAVR') != null ? mapTblData.get(mapIdx.get('SAVR')).get(i) : 0;
            for(String s : setOthDesc){
                temp += mapIdx.get('OTHER-FOC') != null ? mapTblData.get(mapIdx.get('OTHER-FOC')).get(i) : 0;
            }
			*/
            /*
            if(strDBC == 'DBCe'){
                system.debug('@@@mapSKUVolDescData: '+mapSKUVolDescData.get(i));
                temp += mapSKUVolDescData.get(i) != null ? mapSKUVolDescData.get(i) : 0;
                system.debug('@@@mapSKUOthDescData: '+mapSKUOthDescData.get(i));
                temp += mapSKUOthDescData.get(i) != null ? mapSKUOthDescData.get(i) : 0;
            }
            */
            temp += mapIdx.get('OTHER-Cash') != null ? mapTblData.get(mapIdx.get('OTHER-Cash')).get(i) : 0;
            temp += mapTblData.get(mapIdx.get('PROMOTER')).get(i);
            temp += mapTblData.get(mapIdx.get('DISTRIBUTION_COST_UNDER_GM')).get(i);
            temp += mapTblData.get(mapIdx.get('DISTRIBUTION_COST_ALLOWANCES_UNDER_GM')).get(i);
            temp += mapTblData.get(mapIdx.get('Trade_AP_SALES_COMMISSION')).get(i);
            temp += mapTblData.get(mapIdx.get('Trade_AP_CASH')).get(i);
            temp += mapTblData.get(mapIdx.get('Trade_AP_CASH_ALLOWANCES')).get(i);
            //if(strDBC == 'DBCa'){
                for(String s : setSetupCode){
                    temp += mapIdx.get(s) != null ? mapTblData.get(mapIdx.get(s)).get(i) : 0;
                }
            //} 
            
            mapSKUData.put(i, temp);
        }
        mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'Contributive Margin');
        mapIdx.put('CONTRIBUTIVE_MARGIN', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // #30 - Contributive Margin - End
        
        // #31 - GP % vs Turnover
        // Contributive Margin / Gross Sales * 100
        mapSKUData = new Map<id, decimal>(); // Reset for this row
        for(ID i : setSKU){
            Decimal temp = 0;
            if(mapTblData.get(mapIdx.get('GROSS_SALES')).get(i) != 0)
                temp = mapTblData.get(mapIdx.get('CONTRIBUTIVE_MARGIN')).get(i) / mapTblData.get(mapIdx.get('GROSS_SALES')).get(i) * 100;
            else
                temp = 0;
            mapSKUData.put(i, temp);
        }
        //mapRowAddTotal.put(intLineCount, true);
        mapRowTitle.put(intLineCount, 'GP % vs Turnover');
        mapIdx.put('GP_TURNOVER', intLineCount);
        mapTblData.put(intLineCount, mapSKUData); intLineCount++;
        // #31 - GP % vs -End
        
        DBCData objData = new DBCData();
        objData.mapSKUTitle = mapSKUTitle;
        objData.mapRowTitle = mapRowTitle;
        objData.mapTblData = mapTblData;
        objData.mapRowIsTitle = mapRowIsTitle;
        objData.mapRowAddTotal = mapRowAddTotal;

        objData.mapSKUCrossSKU = mapSKUCrossSKU;
        objData.mapCrossSKUDesc =mapCrossSKUDesc;
        return objData;
    }
	

    
    public Map<integer, Map<integer, Map<integer, String>>> renderCompareDataTable(id idContract, integer intPageSize, String strDBC, Boolean isGroupMember,Boolean isCompareReport){
        // Declaration
        integer intTotalCol = 0; // Number of columns
        integer intTotalPage = 0; // Number of page
        integer intTotalRow = 0;
        Map<integer, id> mapSKUSeq = new Map<integer, id>();
        Map<integer, Map<integer, String>> mapRow = new  Map<integer, Map<integer, String>>();
        Map<integer, Map<integer, Map<integer, String>>> mapDataTable = new Map<integer, Map<integer, Map<integer, String>>>();
        integer i = 0;
        list<String> lstSKU = new List<String>();
        Map<String, id> mapSKUNameID = new Map<String, id>();
        
        Map<id, String> mapSKUTitle = new Map<id, String>();
        Map<integer, String> mapRowTitle = new Map<integer, String>();
        Map<integer, Map<id, decimal>> mapTblData = new Map<integer, Map<id, decimal>>();
        Map<integer, boolean> mapRowIsTitle = new Map<integer, boolean>();
        Map<integer, boolean> mapRowAddTotal = new Map<integer, boolean>();
        Map<integer, decimal> mapTotalCol = new Map<integer, decimal>(); // <rowNum, total>

        Map<Id, Id> mapSKUCrossSKU = new Map<Id,Id>();
        Map<Id, String> mapCrossSKUDesc = new Map<Id, String>();
        // Declaration - End
        
        // Get DBC Data from common function
        DBCData objDBCData = new DBCData();
        objDBCData = genDBC_E(idContract, strDBC, isCompareReport);
        mapSKUTitle = objDBCData.mapSKUTitle;
        mapRowTitle = objDBCData.mapRowTitle;
        mapTblData = objDBCData.mapTblData;
        mapRowIsTitle = objDBCData.mapRowIsTitle;
        mapRowAddTotal = objDBCData.mapRowAddTotal;
        mapSKUCrossSKU = objDBCData.mapSKUCrossSKU;
        mapCrossSKUDesc = objDBCData.mapCrossSKUDesc;

        // Initial the count, page count, columns count and row count
        intTotalCol = mapSKUTitle.size();
        intTotalPage = Integer.valueOf(Math.ceil(((decimal) intTotalCol + 1.0) / intPageSize)); // + 1 for the right most "Total" column 
        intTotalRow = mapTblData.size();
        System.debug('intTotalCol = ' + String.valueOf(intTotalCol));
        System.debug('(intTotalCol + 1) / intPageSize) = ' + String.valueOf(((decimal) intTotalCol + 1.0) / intPageSize));
        System.debug('intTotalPage = ' + String.valueOf(intTotalPage));
        System.debug('intTotalRow = ' + String.valueOf(intTotalRow));
        
        // SKU Title with Sorting
        for (id idSKU : mapSKUTitle.keySet()) {
            mapSKUNameID.put(mapSKUTitle.get(idSKU), idSKU); // Add the NAME/ID Mapping
        }
        lstSKU.addAll(mapSKUTitle.values()); lstSKU.sort(); // Sort the SKU by Name
        i = 0;
        for (String s : lstSKU) {
            mapSKUSeq.put(i, mapSKUNameID.get(s));

            //Add cross-brand sku
            Id crossBrandSKUId = mapSKUCrossSKU.get(mapSKUNameID.get(s));
            if(crossBrandSKUId!=null){
                mapIndexCrossSKUTitle.put(i,  mapCrossSKUDesc.get(crossBrandSKUId));
            }else{
                mapIndexCrossSKUTitle.put(i,  '');
            }
            i++;
        }
        mapIndexCrossSKUTitle.put(i,'');        //For total column

        // Initial Total Column
        for (integer x = 0; x < intTotalRow + 1; x++ ) {
            mapTotalCol.put(x, 0);
        }
        
        // Construct Grid Data
        for (integer p = 0; p < intTotalPage; p++) {
            mapRow = new Map<integer, Map<integer, String>>();
            for (integer x = 0; x < intTotalRow + 1; x++) {
                Map<integer, String> mapCell = new Map<integer, String>();
                
                if (x == 0) {
                    // Add table header
                    mapCell.put(0, ''); // The most top-left cell 
                    for (integer y = 0; y < intPageSize && intPageSize * p + y < mapSKUSeq.size(); y++) {
                        //system.debug('p: ' + String.valueOf(p) + ', x: ' + String.valueOf(x) + ', y: ' + String.valueOf(y) + '....' + mapSKUTitle.get(mapSKUSeq.get(i)));
                        mapCell.put(y + 1, mapSKUTitle.get(mapSKUSeq.get(intPageSize * p + y + 1 - 1))); // SKU Title
                    }
                    if (p == intTotalPage - 1) {
                        mapCell.put(mapCell.size(), 'Total');
                    }
                }else if(x == 3 /* IGC row */ && isGroupMember==FALSE){
                    mapCell.put(0, ' ');
                    for (integer y = 0; y < intPageSize && intPageSize * p + y < mapSKUSeq.size(); y++) {
                        mapCell.put(y + 1, ' '); 
                    }
                    //ADD new Total Column
                    if (p == intTotalPage - 1) {
                        System.debug('p: ' + String.valueOf(p) + ' x: ' + String.valueOf(x));
                        mapCell.put(Math.mod(mapSKUSeq.size(), intPageSize) + 1, '');
                    }
                }else{
                    mapCell.put(0, mapRowTitle.get(x - 1)); // The left column desc
                    decimal decRowTtl = 0;
                    for (integer y = 0; y < intPageSize && intPageSize * p + y < mapSKUSeq.size(); y++) {
                        id s = mapSKUSeq.get(intPageSize * p + y); // Get the SKU ID
                        Map<id, decimal> mapTemp = new Map<id, decimal>();
                        String strVal = '';
                        if (mapRowIsTitle.get(x - 1) == null || mapRowIsTitle.get(x - 1) == false) {
                            mapTemp = mapTblData.get(x - 1);
                            if (mapTemp != null) {
                                strVal = String.valueOf(mapTemp.get(s) == null ? 0 : mapTemp.get(s));
                            }
                        }
                        if (mapRowAddTotal.get(x - 1) == true) {
                            mapTemp = mapTblData.get(x - 1);
                            if (mapTemp != null) {
                                decRowTtl += mapTemp.get(s) == null ? 0 : mapTemp.get(s);
                            }
                        }
                        mapCell.put(y + 1, strVal); // The actual decimal value
                        //mapCell.put(y + 1, String.valueOf('x: ' + String.valueOf(x) + ', y: ' + String.valueOf(y)));
                    }
                    // Add Total of all columns acorss all pages
                    if (mapRowAddTotal.get(x - 1) == true) {
                        //mapTotalCol.put(x, mapTotalCol.get(x) + mapTemp.get(s) == null ? 0 : mapTemp.get(s));
                        mapTotalCol.put(x - 1, mapTotalCol.get(x - 1) + decRowTtl);
                        System.debug('True: ' + mapRowTitle.get(x - 1) + ' decRowTtl : ' + String.valueOf(decRowTtl));
                    }
                    // Add new total column
                    if (p == intTotalPage - 1) {
                        System.debug('p: ' + String.valueOf(p) + ' x: ' + String.valueOf(x));
                        //mapCell.put(y + 2, (mapRowAddTotal.get(x - 1) == true) ? String.valueOf(mapTotalCol.get(x)) : '');
                        if (mapRowAddTotal.get(x - 1) == true) {
                            mapCell.put(Math.mod(mapSKUSeq.size(), intPageSize) + 1,
                                String.valueOf(mapTotalCol.get(x - 1))
                            ) ;
                        } else {    
                            mapCell.put(Math.mod(mapSKUSeq.size(), intPageSize) + 1, '');
                        }
                        // To calculate the ROI of the entire contract
                        if(x == intTotalRow){
                            String tempstr= 'TOTAL';
                            Decimal temp = 0;
                            system.debug('IN ASI_CRM_MY_ContractDBC renderDataTable ----------------------------- String row Last2: ' + mapRow.get(intTotalRow - 1).get(Math.mod(mapSKUSeq.size(), intPageSize) + 1));
                            system.debug('IN ASI_CRM_MY_ContractDBC renderDataTable ----------------------------- String row 14: ' + mapRow.get(14).get(Math.mod(mapSKUSeq.size(), intPageSize) + 1));
                            
                            system.debug('IN ASI_CRM_MY_ContractDBC renderDataTable ----------------------------- Decimal row Last2: ' + Decimal.valueof(mapRow.get(intTotalRow - 1).get(Math.mod(mapSKUSeq.size(), intPageSize) + 1).trim()));
                            system.debug('IN ASI_CRM_MY_ContractDBC renderDataTable ----------------------------- Decimal row 14: ' + Decimal.valueof(mapRow.get(14).get(Math.mod(mapSKUSeq.size(), intPageSize) + 1).trim()));
                            
                            temp = Decimal.valueof(mapRow.get(intTotalRow - 1).get(Math.mod(mapSKUSeq.size(), intPageSize) + 1).trim());
                            if(Decimal.valueof(mapRow.get(14).get(Math.mod(mapSKUSeq.size(), intPageSize) + 1).trim()) != 0)
                                temp = temp / Decimal.valueof(mapRow.get(14).get(Math.mod(mapSKUSeq.size(), intPageSize) + 1).trim()) * 100;
                            else
                                temp = 0;
                            system.debug('IN ASI_CRM_MY_ContractDBC renderDataTable ----------------------------- ROI: ' + temp);
                            tempstr = string.valueOf(temp);
                            mapCell.put(Math.mod(mapSKUSeq.size(), intPageSize) + 1, tempstr);
                        } 
                    }
                }
                mapRow.put(x, mapCell);
            }
            mapDataTable.put(p, mapRow);
        }
        
        system.debug(mapDataTable);
        return mapDataTable;
    }


}