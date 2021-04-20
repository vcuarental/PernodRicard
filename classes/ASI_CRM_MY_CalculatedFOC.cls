/*********************************************************************************
 * Name: ASI_CRM_MY_CalculatedFOC
 * Description: For generating suggested FOC report
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2015-01-25       Axel                    Initial
 * 2015-04-17       Axel                    Bug Fix
 *********************************************************************************/
public with sharing class ASI_CRM_MY_CalculatedFOC {
    
    // Declaration
    /*public class CALFOC_f { // Flat Information
        String PeriodKey;
        
        String CustomerNo;
        String CustomerName;
        String SalesName;
        String ContractNo;
        String SKUName;
        
        decimal AchievedBtl;
        decimal PRMFOCFactor;
        decimal PRMFOCBtl;
        decimal PRMRemain;
        decimal WSFOCFactor;
        decimal WSFOCBtl;
    }*/
    public class CALFOC {
        public Id CustomerId;
        public Id ContractId;
        //public Id ParentId;
        public boolean isParent;
        public String CustomerNo;
        public String CustomerName;
        public String SalesName;
        public String ContractNo;
        public date SDate;
        public date EDate;
        public map<string, CALFOC_SKU> skuFOCs; // <SKUID, CALFOC_SKU>
        public String voloumeType;
    }
    public class CALFOC_SKU {
        public Id SKUId;
        public Id OriginalSKUId;
        public String SKUName;
        public decimal ActualBtl;
        public decimal PackSize;
        public decimal ActualCase;   
        public decimal AchievedBtl;
        public decimal PRMBroughtForward;
        public decimal PRMFOCFactor;
        public decimal PRMFOCBtl;
        public decimal PRMRemain;
        public decimal WSBroughtForward;
        public decimal WSFOCFactor;
        public decimal WSFOCBtl;
        public decimal WSRemain;
        public decimal CashInc;
        public String SetupCode; 
        public String JDECOA;
        public decimal contract_target_achieved_bottle;
    }
    public class OFFTAKE_INV_DATE {
        public date InvDate; // Invoice Date of the Offtake
        public decimal Bottle; // Actual Offtake of the SKU
    }
    //public date runningDate;
    public date dteStart;
    public date dteEnd;
    public Map<String, Decimal> mapOfFOCActualPurchase {get; private set;}
    {mapOfFOCActualPurchase = new Map<String, Decimal>();}
    public Map<String, Decimal> mapOfPaymentActualPurchase {get; private set;}
    {mapOfPaymentActualPurchase = new Map<String, Decimal>();}
    public map<id, ASI_TH_CRM_Contract__c> mapContracts {get; private set;}
    {mapContracts = new map<id, ASI_TH_CRM_Contract__c>();}
    private ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
    public Date today{get; private set;}{today =my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();}
    public Integer intCutOffDay {get; private set;}{intCutOffDay = my_cs!=null && my_cs.ASI_CRM_MY_Offtake_Cutoff_Day__c!=null ? Integer.valueOf(ASI_CRM_MY_Settings__c.getInstance().ASI_CRM_MY_Offtake_Cutoff_Day__c) : null;}
    public Decimal GST {get; private set;}
    {
        GST = my_cs!=null && my_cs.ASI_CRM_MY_GST_Rate__c!=null ? (my_cs.ASI_CRM_MY_GST_Rate__c/100) : 0;
    }
    private Integer min_offtake = 12;
    public map<string, ASI_CRM_Calculated_FOC_Line__c> mapRemain {get; private set;}
    {mapRemain = new map<string, ASI_CRM_Calculated_FOC_Line__c>();}
    public String PAYMENT_STATUS {get; private set;}{PAYMENT_STATUS='PAYMENT';}
    public String FOC_STATUS {get; private set;}{PAYMENT_STATUS='FOC';}
    private boolean blnTodayCutoff = false;
    // Declaration - End
    
    public ASI_CRM_MY_CalculatedFOC() {
        if(Test.isRunningTest()){
            intCutOffDay = 26;
            blnTodayCutoff = true;
        }
    }
    
    public map<String, date> getOfftakeMaxMinDate(set<id> setOutletGrp, date dteRunDate) {
        map<String, date> mapRes = new map<String, date>();
        id idRT_AO = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake');
        
        if(dteRunDate.Day() >= intCutOffDay){
            dteStart = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay - 1);    
        }else{
            dteStart = date.newinstance(dteRunDate.addMonths(-1).Year(), dteRunDate.addMonths(-1).Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay - 1);
        }
        
        // Get all offtake of the outlet group
        for (AggregateResult ar : [
            SELECT Max(ASI_CRM_InvoiceDate__c) max, Min(ASI_CRM_InvoiceDate__c) min
            FROM ASI_TH_CRM_Actual_Offtake__c
            WHERE (ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
                   AND
                   ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd
            )
            AND (ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c = 'Draft')
            AND RecordTypeID = :idRT_AO
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c IN :setOutletGrp
            GROUP BY RecordTypeID
        ]) {
            mapRes.put('max', (date) ar.get('max'));
            mapRes.put('min', (date) ar.get('min'));
        }
        return mapRes;
    }
    
    
    public map<String, date> getPaymentOfftakeMaxMinDate(set<id> setOutletGrp, date dteRunDate) {
        map<String, date> mapRes = new map<String, date>();
        id idRT_AO = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake');
        
        if(dteRunDate.Day() >= intCutOffDay){
            dteStart = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay - 1);    
        }else{
            dteStart = date.newinstance(dteRunDate.addMonths(-1).Year(), dteRunDate.addMonths(-1).Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay - 1);
        }
        
        // Get all offtake of the outlet group
        for (AggregateResult ar : [
            SELECT Max(ASI_CRM_InvoiceDate__c) max, Min(ASI_CRM_InvoiceDate__c) min
            FROM ASI_TH_CRM_Actual_Offtake__c
            WHERE (ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
                   AND
                   ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd
            )
            AND (ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Calculated_Payment_Status__c = 'Draft')
            AND RecordTypeID = :idRT_AO
            AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c IN :setOutletGrp
            GROUP BY RecordTypeID
        ]) {
            mapRes.put('max', (date) ar.get('max'));
            mapRes.put('min', (date) ar.get('min'));
        }
        return mapRes;
    }
    
    
    /***
     * To real time generate current month offtake summary
        Output: <OutletID, <SKUID, Count>>
     */
    public map<id, map<id, list<OFFTAKE_INV_DATE>>> getOfftakeSummary(set<id> setOutletGrp, date dteRunDate, String statusType) {
        // Declaration
        id idRT_AO = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake');
        map<id, list<OFFTAKE_INV_DATE>> mapSKUCount = new map<id, list<OFFTAKE_INV_DATE>>(); // <skuID, list<InvDate, Bottle>>
        map<id, map<id, list<OFFTAKE_INV_DATE>>> mapAOCount = new map<id, map<id, list<OFFTAKE_INV_DATE>>>(); // <outletID, <skuID, list<InvDate, Bottle>>>>
        // Declaration - End
        
        
        //check today if meet the cutoff Day
        //runningDate = dteRunDate;
        if(dteRunDate.Day() >= intCutOffDay){
            dteStart = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay - 1);    
        }
        else{
            dteStart = date.newinstance(dteRunDate.addMonths(-1).Year(), dteRunDate.addMonths(-1).Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay - 1);
        }
        
        system.debug('@@@getOfftakeSummary dteStart'+dteStart);
        system.debug('@@@getOfftakeSummary dteEnd'+dteEnd);
        
        // Get all offtake of the outlet group
        AggregateResult[] results;
        if(statusType == PAYMENT_STATUS){
           results = 
               [SELECT 
                    ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c outlet, 
                    ASI_CRM_SKU__c, 
                    ASI_CRM_InvoiceDate__c InvDate, 
                    SUM(ASI_TH_CRM_Quantity__c) s
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE 
                (ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
                AND
                ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd) //LAST_MONTH //change to this_month 
                AND (ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Calculated_Payment_Status__c = 'Draft')
                AND RecordTypeID = :idRT_AO
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c IN :setOutletGrp
                GROUP BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_SKU__c, ASI_CRM_InvoiceDate__c
                ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_SKU__c, ASI_CRM_InvoiceDate__c];
        }
        else{
            results = 
               [SELECT 
                    ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c outlet, 
                    ASI_CRM_SKU__c, 
                    ASI_CRM_InvoiceDate__c InvDate, 
                    SUM(ASI_TH_CRM_Quantity__c) s
                FROM ASI_TH_CRM_Actual_Offtake__c
                WHERE 
                (ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c >= :dteStart 
                AND
                ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_OfftakeDate__c <= :dteEnd) //LAST_MONTH //change to this_month 
                AND (ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_Status__c = 'Draft')
                AND RecordTypeID = :idRT_AO
                AND ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c IN :setOutletGrp
                GROUP BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_SKU__c, ASI_CRM_InvoiceDate__c
                ORDER BY ASI_CRM_ActualOfftakeHeader__r.ASI_CRM_ToOutlet__c, ASI_CRM_SKU__c, ASI_CRM_InvoiceDate__c];
        }
        
        set<Id> skuIdSet = new set<Id>();
        
        for (AggregateResult ar : results) {
            OFFTAKE_INV_DATE clsOTCount = new OFFTAKE_INV_DATE();
            list<OFFTAKE_INV_DATE> lstOTCount = new list<OFFTAKE_INV_DATE>();
            mapSKUCount = new map<id, list<OFFTAKE_INV_DATE>>(); // Reset for temp purpose
            if (mapAOCount.get((id) ar.get('outlet')) != null)
                mapSKUCount = mapAOCount.get((id) ar.get('outlet'));
            clsOTCount.InvDate = (date) ar.get('InvDate');
            clsOTCount.Bottle = (decimal) (ar.get('s') == null ? 0 : ar.get('s'));
            if (mapSKUCount.get((id) ar.get('ASI_CRM_SKU__c')) != null) {
                lstOTCount = mapSKUCount.get((id) ar.get('ASI_CRM_SKU__c'));
            }
            lstOTCount.add(clsOTCount);
            
            // new skuId
            /*
            Set<Id> oldSkuSet = new Set<Id>();
            Id oldSkuId = (Id)ar.get('ASI_CRM_SKU__c');
            oldSkuSet.add(oldSkuId);
            Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(oldSkuSet);  
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
			mapSKUCount.put(newSkuId, lstOTCount);
			*/
            // new skuId
             
			// old skuId
            Id oldSkuId = (Id)ar.get('ASI_CRM_SKU__c');
            skuIdSet.add(oldSkuId);
            mapSKUCount.put(oldSkuId, lstOTCount);
            // old skuId
           
            mapAOCount.put((id) ar.get('outlet'), mapSKUCount);
            
            //System.debug('OUTLET: ' + String.valueOf(ar.get('outlet')) + ', SKU: ' + String.valueOf(ar.get('ASI_CRM_SKU__c')) + ', Count: ' + String.valueOf(newSkuId));
        }
        
        // map Latest SKU
        Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(skuIdSet);  
        for (String strKey : mapAOCount.keySet()) {
            map<id, list<OFFTAKE_INV_DATE>> mapNewSKUCount = new map<id, list<OFFTAKE_INV_DATE>>();
            map<id, list<OFFTAKE_INV_DATE>> mapSKUCount2 = mapAOCount.get(strKey);
            for (String strKey2 : mapSKUCount2.keySet()) {
                Id oldSkuId = (Id) strKey2;
                Id newSkuId = mapOfNewSKU.get(oldSkuId);
                mapNewSKUCount.put(newSkuId, mapSKUCount2.get(strKey2));
            }
            mapAOCount.put(strKey, mapNewSKUCount);
        }
        // map Latest SKU 
        
        
        System.debug('getOfftakeSummary Result');
        System.debug(mapAOCount);
        return mapAOCount;
    }
    

    public Map<String, Decimal> getFOCActualPurchaseSummary(set<id> setContracts, date runningDate){
        
        String strPY = String.valueOf(runningDate.year());
        String strPM = String.valueOf(runningDate.month());
        strPM = strPM.length() == 1 ? '0' + strPM : strPM;
        String year_month = strPY+''+strPM;
        Decimal year_month_num = Decimal.valueOf(year_month);
        
        system.debug('@@@year_month_num: '+year_month_num);
        
        AggregateResult[] results = [
            SELECT 
            	ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__c customerId, 
            	ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c contractId, 
            	ASI_CRM_Original_SKU__c skuId, 
            	SUM(ASI_CRM_Actual_Purchase__c) sum_purchase
            FROM ASI_CRM_Calculated_FOC_Line__c
            WHERE ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c IN :setContracts
            AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Date_Number__c < :year_month_num 
            GROUP BY ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__c, ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__c, ASI_CRM_Original_SKU__c
        ];
            
        Map<String, Decimal> mapOfFOCActualPurchase = new Map<String, Decimal>();
        set<Id> skuIdSet = new set<Id>();
        for (AggregateResult ar : results){
            String customerId = (String)ar.get('customerId');
            String contractId = (String)ar.get('contractId');
            String skuId = (String)ar.get('skuId');
            
			// new skuId
			/*
            Set<Id> oldSkuSet = new Set<Id>();
            Id oldSkuId = (Id)skuId;
            oldSkuSet.add(oldSkuId);
            Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(oldSkuSet);  
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            String key = customerId + '_' + contractId + '_' + newSkuId;
			*/
            // new skuId              
            
            // old skuId 
            Id oldSkuId = (Id)skuId;
            skuIdSet.add(oldSkuId);
            String key = customerId + '_' + contractId + '_' + oldSkuId;
            // old skuId 
            
            Decimal sum_purchase = (decimal)ar.get('sum_purchase');
            mapOfFOCActualPurchase.put(key, sum_purchase);
        }
        
        
        // map Latest SKU
        Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(skuIdSet);  
        Map<String, Decimal> mapOfNewFOCActualPurchase = new Map<String, Decimal>();
        for(String strKey : mapOfFOCActualPurchase.keySet()) {
            system.debug('@@@strKey: '+strKey);
            String[] strKey2 = strKey.split('_', 3);
            String customerId = strKey2[0];
            String contractId = strKey2[1]; 
            system.debug('@@@contractId: '+contractId);
            Id oldSkuId = (Id) strKey2[2]; 
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            String key = customerId + '_' + contractId + '_' + string.valueOf(newSkuId);
            mapOfNewFOCActualPurchase.put(key, mapOfFOCActualPurchase.get(strKey));
        }
        mapOfFOCActualPurchase = mapOfNewFOCActualPurchase;
        // map Latest SKU
        
        system.debug('@@@mapOfFOCActualPurchase@@@: '+mapOfFOCActualPurchase);
        
        return mapOfFOCActualPurchase;
    }
    
    public Map<String, Decimal> getPaymentActualPurchaseSummary(set<id> setContracts, date runningDate){
        
        String strPY = String.valueOf(runningDate.year());
        String strPM = String.valueOf(runningDate.month());
        strPM = strPM.length() == 1 ? '0' + strPM : strPM;
        String year_month = strPY+''+strPM;
        Decimal year_month_num = Decimal.valueOf(year_month);
        
        AggregateResult[] results = [
            SELECT ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__c customerId, 
            ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c contractId, 
            ASI_CRM_SKU__c skuId, 
            ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c incentive_type,
            SUM(ASI_CRM_Actual_Volume__c) sum_purchase
            FROM ASI_CRM_Calculated_Payment_Item__c 
            WHERE ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c IN :setContracts
            AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Date_Number__c < :year_month_num 
            GROUP BY ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__c, ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__c, ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c, ASI_CRM_SKU__c
        ];
            
        Map<String, Decimal> mapOfPaymentActualPurchase = new Map<String, Decimal>();
        for (AggregateResult ar : results){
            String customerId = (String)ar.get('customerId');
            String contractId = (String)ar.get('contractId');
            String incentive_type = (String)ar.get('incentive_type');
            String skuId = (String)ar.get('skuId');
            
            String key = customerId + '_' + contractId + '_' + incentive_type + '_' + skuId;
            Decimal sum_purchase = (decimal)ar.get('sum_purchase');
            mapOfPaymentActualPurchase.put(key, sum_purchase);
        }
        
        system.debug('@@@mapOfPaymentActualPurchase@@@: '+mapOfPaymentActualPurchase);
        
        return mapOfPaymentActualPurchase;
    }
    
	
    /***
     * To get previous month calculated
     */
    public map<String, ASI_CRM_Calculated_FOC_Line__c> genPreviousMthCalculatedFOC(set<id> setOutletGrp, set<id> setContracts, date runningDate) {
        // Declaration
        id idRT_AO = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake');
        date dteDate = runningDate.addMonths(-1); //system.today().addMonths(-1);
        string strY = String.valueOf(dteDate.year());
        string strM = String.valueOf(dteDate.month());
        strM = strM.length() == 1 ? '0' + strM : strM;
        
        system.debug('---------------------------genPreviousMthCalculatedFOC strY : ' + strY + ' strM : ' + strM);
        
        //map<String, FOCdata> mapRes = new map<String, FOCData>();
        map<String, ASI_CRM_Calculated_FOC_Line__c> mapRes = new map<String, ASI_CRM_Calculated_FOC_Line__c>();
        
        set<id> setCalFOC_Header = new set<id>();
        
        list<ASI_CRM_Calculated_FOC_Line__c> lstCalFOC_Item = new list<ASI_CRM_Calculated_FOC_Line__c>();
        // Declaration - End
        
        for(ASI_CRM_Calculated_FOC__c i : [
            SELECT id
            FROM ASI_CRM_Calculated_FOC__c
            WHERE ASI_CRM_Year__c = :strY
            AND ASI_CRM_Month__c = :strM
            AND ASI_CRM_Customer__c IN :setOutletGrp
            AND ASI_CRM_Contract__c IN :setContracts
        ]){
            setCalFOC_Header.add(i.id);
        }
        
        if(setCalFOC_Header != NULL && setCalFOC_Header.size() > 0){
            lstCalFOC_Item = [
                SELECT 
                	ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id,
                	ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id,
                    ASI_CRM_Original_SKU__c,
                    ASI_CRM_Remain__c,
                    ASI_CRM_Remain_WS__c
                FROM ASI_CRM_Calculated_FOC_Line__c
                WHERE ASI_CRM_Calculated_FOC__c IN :setCalFOC_Header
                AND ASI_CRM_Remain__c > 0
            ];
        }
        
        System.debug('GetOfftake of previous month ******');
        set<Id> skuIdSet = new set<Id>();
        for (ASI_CRM_Calculated_FOC_Line__c obj : lstCalFOC_Item) {
            
            // new skuId
            /*
            Set<Id> oldSkuSet = new Set<Id>();
            Id oldSkuId = (Id)obj.ASI_CRM_Original_SKU__c;
            oldSkuSet.add(oldSkuId);
            Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(oldSkuSet);  
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            String strTemp = String.valueOf(obj.ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id) + '_' + String.valueOf(obj.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id) + '_' + String.valueOf(newSkuId);
			mapRes.put(strTemp, obj);
			*/
            // new skuId
            
            
            // old skuId
            Id oldSkuId = (Id)obj.ASI_CRM_Original_SKU__c;
            skuIdSet.add(oldSkuId);
            String strTemp = String.valueOf(obj.ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id) + '_' + String.valueOf(obj.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id) + '_' + String.valueOf(oldSkuId);
            mapRes.put(strTemp, obj);
            // old skuId
            
            
            
        }
	
        // map Latest SKU
        Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(skuIdSet);  
        map<String, ASI_CRM_Calculated_FOC_Line__c> mapNewRes = new map<String, ASI_CRM_Calculated_FOC_Line__c>();
        for (String strKey : mapRes.keySet()) {
            String[] strKey2 = strKey.split('_', 3);
            String custId = strKey2[0];
            String conId = strKey2[1];
            Id oldSkuId = (Id) strKey2[2];
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            String strTemp = custId + '_' + conId + '_' + String.valueOf(newSkuId);
            mapNewRes.put(strTemp, mapRes.get(strKey));
        }
        mapRes = mapNewRes;
        // map Latest SKU 
		
        
        return mapRes;
    }
    
    
    public map<String, ASI_CRM_Calculated_Payment_Item__c> genPreviousMthCalculatedFOCPayment(set<id> setOutletGrp, set<id> setContracts, date runningDate) {
        // Declaration
        id idRT_AO = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_MY_Actual_Offtake');
        date dteDate = runningDate.addMonths(-1); //system.today().addMonths(-1);
        string strY = String.valueOf(dteDate.year());
        string strM = String.valueOf(dteDate.month());
        strM = strM.length() == 1 ? '0' + strM : strM;
        
        system.debug('---------------------------genPreviousMthCalculatedFOCPayment strY : ' + strY + ' strM : ' + strM);
        
        //map<String, FOCdata> mapRes = new map<String, FOCData>();
        map<String, ASI_CRM_Calculated_Payment_Item__c> mapRes = new map<String, ASI_CRM_Calculated_Payment_Item__c>();
        
        set<id> setCalFOC_Header = new set<id>();
        
        list<ASI_CRM_Calculated_Payment_Item__c> lstCalFOC_Item = new list<ASI_CRM_Calculated_Payment_Item__c>();
        // Declaration - End
        
        for(ASI_CRM_Calculated_Payment__c  i : [
            SELECT id
            FROM ASI_CRM_Calculated_Payment__c 
            WHERE ASI_CRM_Year__c = :strY
            AND ASI_CRM_Month__c = :strM
            AND ASI_CRM_Customer__c IN :setOutletGrp
            AND ASI_CRM_Contract__c IN :setContracts
        ]){
            setCalFOC_Header.add(i.id);
        }
        
        if(setCalFOC_Header != NULL && setCalFOC_Header.size() > 0){
            lstCalFOC_Item = [
                SELECT 
                	ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id,
                	ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id,
                	ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c,
                    ASI_CRM_SKU__c,
                    ASI_CRM_Carried_Forward__c
                FROM ASI_CRM_Calculated_Payment_Item__c
                WHERE ASI_CRM_Calculated_Payment__c IN :setCalFOC_Header
                AND ASI_CRM_Carried_Forward__c > 0
            ];
        }
		       
        System.debug('GetOfftake of previous month ******');
        set<Id> skuIdSet = new set<Id>();
        for (ASI_CRM_Calculated_Payment_Item__c obj : lstCalFOC_Item) {
            
            // new skuId
            /*
            Set<Id> oldSkuSet = new Set<Id>();
            Id oldSkuId = (Id)obj.ASI_CRM_SKU__c;
            oldSkuSet.add(oldSkuId);
            Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(oldSkuSet);  
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            String strTemp = String.valueOf(obj.ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id) + '_' + String.valueOf(obj.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id) + '_' + obj.ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c + '_' + String.valueOf(newSkuId);
			*/
            // new skuId 
            
            
            // old skuId
            Id oldSkuId = (Id)obj.ASI_CRM_SKU__c;
            skuIdSet.add(oldSkuId);
            String strTemp = String.valueOf(obj.ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id) + '_' + String.valueOf(obj.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id) + '_' + obj.ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c + '_' + String.valueOf(oldSkuId);
            // old skuId
            
            String strKey = strTemp;
            mapRes.put(strKey, obj);
        }
        
        // map Latest SKU
        Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(skuIdSet);  
        map<String, ASI_CRM_Calculated_Payment_Item__c> mapNewRes = new map<String, ASI_CRM_Calculated_Payment_Item__c>();
        for (String strKey : mapRes.keySet()) {
            String[] strKey2 = strKey.split('_', 4);
            String custId = strKey2[0];
            String conId = strKey2[1];
            Id oldSkuId = (Id) strKey2[3];
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            String strTemp = custId + '_' + conId + '_' + String.valueOf(newSkuId);
            mapNewRes.put(strTemp, mapRes.get(strKey));
        }
        mapRes = mapNewRes;
        // map Latest SKU
        
        
        return mapRes;
    }
    
    /***
     */
    public map<String, CALFOC> getContractSummary(set<id> idOutlet, set<id> setOutletGrp, set<id> setContracts) {
        // Declaration
        list<CALFOC> lstFOC = new list<CALFOC>();
        map<String, CALFOC> mapAllFOC = new map<String, CALFOC>();
        set<id> setParent = new set<id>();
        set<id> setChild = new set<id>();
        set<id> setIDContractSet = new set<id>();
        map<id, set<id>> mapParentContract = new map<id, set<id>>(); // Contract(s) IDs under the parent  
        map<id, set<ASI_CRM_AccountsAdditionalField__c>> mapParentChild = new map<id, set<ASI_CRM_AccountsAdditionalField__c>>();
        boolean isChild = true; // If the FOC is enquire from child
        // Declaration - End
        
        
       	// get contract target
        List<ASI_CRM_ContractTarget__c> contractTargetList = getContractTarget(setContracts);
        Map<String, Map<String, Decimal>> customer_contract_map = getMapOfContractTarget(contractTargetList);
        // get contract target
        
		      
        System.debug('ASI_CRM_MY_CalclatedFOC:getContractSummary() ');
        // Get Contract Incentive Summary
        List<ASI_CRM_ContractSalesStaffIncentive__c> objSSList = [
            SELECT 
            	id, 
            	ASI_CRM_Contract__r.Name, 
            	ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, 
            	ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id,
                ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c,
                ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name, 
            	ASI_CRM_Contract__r.id,
                ASI_CRM_Contract__r.Owner.FirstName, 
            	ASI_CRM_Contract__r.Owner.LastName, 
            	ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c, 
            	ASI_CRM_SKU__r.id,
                ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, 
            	ASI_CRM_SKU__c,
            	ASI_CRM_Packaging_Size__c, 
            	ASI_CRM_AchievedBtl__c, 
            	ASI_CRM_FOCPRM__c,
            	ASI_CRM_FOCWS__c,
                ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c, 
            	ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c,
            	ASI_CRM_SetupCode__c,
            	ASI_CRM_CrossBrandSKU__c,
            	ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__c,
            	ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id,
            	ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c,
            	ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c,
            	ASI_CRM_JDECOA__c 
            FROM ASI_CRM_ContractSalesStaffIncentive__c
            WHERE ASI_CRM_Contract__c IN :setContracts
            AND ASI_CRM_AchievedBtl__c > 0
            AND (ASI_CRM_FOCPRM__c > 0 OR ASI_CRM_FOCWS__c > 0)
            ORDER BY ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_Contract__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c
        ];
        
        set<Id> skuIdSet = new set<Id>();
        for (ASI_CRM_ContractSalesStaffIncentive__c objSS : objSSList) {
            String strCustID = String.valueOf(objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
            String strContractID = String.valueOf(objSS.ASI_CRM_Contract__c);
            CALFOC_SKU objSKUFOC = new CALFOC_SKU();
            CALFOC objFOC = new CALFOC();
            map<string, CALFOC_SKU> mapSKUFOCs = new map<string, CALFOC_SKU>(); 
            
            if(mapAllFOC.get(strCustID + '_' + strContractID) != null)
                objFOC = mapAllFOC.get(strCustID + '_' + strContractID);
            
            if(objSS.ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c == TRUE) {
                setParent.add(objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id);
                
                if (mapParentContract.get(objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c) == null) {
                    setIDContractSet = new set<id>();
                } 
                else {
                    setIDContractSet = mapParentContract.get(objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
                } 
                setIDContractSet.add(objSS.ASI_CRM_Contract__r.id);
                
                mapParentContract.put(objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, setIDContractSet);
            }
                
            objFOC.isParent = objSS.ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c;
            objFOC.CustomerId = objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id;
            objFOC.CustomerNo = objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c;
            objFOC.CustomerName = objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name;
            objFOC.SalesName = objSS.ASI_CRM_Contract__r.Owner.FirstName + ' ' + objSS.ASI_CRM_Contract__r.Owner.LastName;
            objFOC.ContractNo = objSS.ASI_CRM_Contract__r.Name;
            objFOC.ContractId = objSS.ASI_CRM_Contract__r.id;
            objFOC.SDate = objSS.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c;
            objFOC.EDate = objSS.ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c;
            
            
            
             
            if(objFOC.skuFOCs != null)
                mapSKUFOCs = objFOC.skuFOCs;
            //ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c 
            
            Map<String, Decimal> customer_sku_map = customer_contract_map.get(strCustID + '_' + strContractID);
            String skuId = String.valueOf(objSS.ASI_CRM_SKU__r.id);
            String key_customer_sku = strCustID + '_' + skuId;
            Decimal contract_target_achieved_bottle = customer_sku_map.get(key_customer_sku);
            
            objSKUFOC.contract_target_achieved_bottle = contract_target_achieved_bottle;
            if(objSS.ASI_CRM_CrossBrandSKU__c != null){
              	objSKUFOC.SKUId = objSS.ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__c != null ? objSS.ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id : objSS.ASI_CRM_CrossBrandSKU__r.id;
                objSKUFOC.SKUName = objSS.ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__c != null ? objSS.ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c : objSS.ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c;
            }
            else{
                objSKUFOC.SKUId = objSS.ASI_CRM_SKU__r.id;
                objSKUFOC.SKUName = objSS.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c;
            }
            
            objSKUFOC.OriginalSKUId = objSS.ASI_CRM_SKU__r.id;
            
            objSKUFOC.PackSize = objSS.ASI_CRM_Packaging_Size__c;
            objSKUFOC.ActualCase = (objSKUFOC.ActualBtl == null || objSKUFOC.PackSize == null || objSKUFOC.PackSize == 0) ? 0 : objSKUFOC.ActualBtl / objSKUFOC.PackSize;
            
            objSKUFOC.AchievedBtl = objSS.ASI_CRM_AchievedBtl__c;
            objSKUFOC.PRMFOCFactor = objSS.ASI_CRM_FOCPRM__c;
            objSKUFOC.WSFOCFactor = objSS.ASI_CRM_FOCWS__c;
           	objSKUFOC.SetupCode = objSS.ASI_CRM_SetupCode__c;
            objSKUFOC.JDECOA = objSS.ASI_CRM_JDECOA__c;
            
			            
            // new skuId
            /*
            Set<Id> oldSkuSet = new Set<Id>();
            Id oldSkuId = (Id)objSS.ASI_CRM_SKU__c;
            oldSkuSet.add(oldSkuId);
            Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(oldSkuSet);  
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            mapSKUFOCs.put(strCustID + '_' + string.valueOf(newSkuId), objSKUFOC);
            objFOC.skuFOCs = mapSKUFOCs;
			*/
            // new skuId  
            
            // old skuId
            Id oldSkuId = (Id)objSS.ASI_CRM_SKU__c;
            skuIdSet.add(oldSkuId);
            mapSKUFOCs.put(strCustID + '_' + string.valueOf(oldSkuId), objSKUFOC);
            objFOC.skuFOCs = mapSKUFOCs;
            // old skuId
            
            System.debug(objSKUFOC);
			
            mapAllFOC.put(strCustID + '_' + strContractID, objFOC);
        }
        
        
        // map Latest SKU
        Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(skuIdSet);  
        for (String strKey : mapAllFOC.keySet()) {
            CALFOC objFOC = mapAllFOC.get(strKey);
            map<string, CALFOC_SKU> mapNewSKUFOCs = new map<string, CALFOC_SKU>();
            map<string, CALFOC_SKU> mapSKUFOCs = objFOC.skuFOCs;
            for (String skuStrKey : mapSKUFOCs.keySet()) {
				String[] strKey2 = skuStrKey.split('_', 2);
                String custId = strKey2[0];
                Id oldSkuId = (Id) strKey2[1]; 
                Id newSkuId = mapOfNewSKU.get(oldSkuId);
                mapNewSKUFOCs.put(custId+'_'+string.valueOf(newSkuId), mapSKUFOCs.get(skuStrKey));
                objFOC.skuFOCs = mapNewSKUFOCs;
            }
            mapAllFOC.put(strKey, objFOC);
        }
        // map Latest SKU 
        
        // See if the enquiry view is from child outlet or parent outlet
        for (ASI_CRM_AccountsAdditionalField__c i : [
            SELECT id, Name, ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_Parent_Outlet__c
            FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE ASI_CRM_CN_Inactive_Flag__c = FALSE
            AND id IN :setOutletGrp
        ]) {
            if (i.ASI_CRM_CN_Parent_Outlet__c != NULL && (idOutlet.size() == 1 && idOutlet.contains(i.ASI_CRM_CN_Parent_Outlet__c)))
                isChild = false;
        }
        
        // set the Parent-Child Mapping
        system.debug('------------------- ASI_CRM_MY_CalculatedFOC.getContractSummary setParent : ' + setParent);
        if(setParent != NULL && setParent.size() > 0){
            // To Get all child's Offtake by the parent outlet id
            if(isChild == FALSE) {
                for(ASI_CRM_ActualOfftakeHeader__c i : [
                    SELECT id, ASI_CRM_ToOutlet__c
                    FROM ASI_CRM_ActualOfftakeHeader__c
                    WHERE ASI_CRM_ToOutlet__r.ASI_CRM_CN_Inactive_Flag__c = FALSE
                    AND ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c IN :setParent
                    AND ASI_CRM_OfftakeDate__c >= :dteStart
                    AND ASI_CRM_OfftakeDate__c <= :dteEnd
                ]){
                    setChild.add(i.ASI_CRM_ToOutlet__c); // Set Child Outlet IDs
                }
            }/*else if(isChild == TRUE){
                setChild.add(setOutletGrp);
            }*/
            
            for(id i : setOutletGrp){
                setChild.add(i);
            }
            
            for(id i : setParent){
                setChild.remove(i);
            }
            
            system.debug('---------------------------ASI_CRM_MY_CalculatedFOC.getContractSummary setChild : ' + setChild);
        
            for(ASI_CRM_AccountsAdditionalField__c i : [
                SELECT id, Name, ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_Parent_Outlet__c, Owner.FirstName, Owner.LastName
                FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE ASI_CRM_CN_Parent_Outlet__c IN :setParent
                AND ASI_CRM_CN_Inactive_Flag__c = FALSE
                AND id IN :setChild
            ]){     
                set<ASI_CRM_AccountsAdditionalField__c> setTemp = new set<ASI_CRM_AccountsAdditionalField__c>();
                if(mapParentChild.get(i.ASI_CRM_CN_Parent_Outlet__c) != NULL)
                    setTemp = mapParentChild.get(i.ASI_CRM_CN_Parent_Outlet__c);
                setTemp.add(i);
                mapParentChild.put(i.ASI_CRM_CN_Parent_Outlet__c, setTemp);
            }
            
            system.debug('---------------------------ASI_CRM_MY_CalculatedFOC.getContractSummary mapParentChild: ' + mapParentChild);
            
            if (mapParentChild <> NULL && mapParentChild.size() > 0) {
                for (id i : mapParentChild.keyset()) {
                    
                    String strPPID = String.valueOf(i); // Parent Outlet ID
                    setIDContractSet = mapParentContract.get(i);
             
                    for (id idC : setIDContractSet) {
                        String strPCID = String.valueOf(idC); //String.valueOf(mapParentContract.get(i)); // Parent contract(s) IDs
                        String strKeyT = strPPID + '_' + strPCID;
                        system.debug('--------------------------strPPID_strPCID: ' + strKeyT);
                        for (ASI_CRM_AccountsAdditionalField__c objAccAddt : mapParentChild.get(i)) {
                            CALFOC objFOC = new CALFOC();
                            map<string, CALFOC_SKU> mapSKUFOCs = new map<string, CALFOC_SKU>();
                            //set<string> setRemove = new set<string>();
                            if (mapAllFOC.get(strKeyT) == null) { continue; }
                            objFOC = mapAllFOC.get(strKeyT).clone();
                        	
                            objFOC.isParent = FALSE;
                            objFOC.CustomerId = objAccAddt.id; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id;
                            objFOC.CustomerNo = objAccAddt.ASI_CRM_MY_CustomerCode__c; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c;
                            objFOC.CustomerName = objAccAddt.Name; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name;
                            objFOC.SalesName = objAccAddt.Owner.FirstName + ' ' + objAccAddt.Owner.LastName; //objSS.ASI_CRM_Contract__r.Owner.FirstName + ' ' + objSS.ASI_CRM_Contract__r.Owner.LastName;
                        
                            // to change the Key value inside the cloned map
                            system.debug('START changing objFOCSKU');
                            //mapSKUFOCs = objFOC.skuFOCs;
                            system.debug('-------------------------------------BEFORE mapSKUFOCs : ' + mapSKUFOCs);
                            for(string idString : objFOC.skuFOCs.keySet()){
                                String[] strKey = idString.split('_', 2);
                                ID idSKU = (ID) strKey[1];
                                String strSKU = strKey[1];
                            
                                String strNewKey = string.valueOf(objFOC.CustomerId) + '_' + strSKU;
                                system.debug('------------strKey: ' + strKey + ', strNewKey: ' + strNewKey);
                                mapSKUFOCs.put(strNewKey, objFOC.skuFOCs.get(idString));
                                //mapSKUFOCs.put(strNewKey, objFOC.skuFOCs.get(idString).clone());
                                //setRemove.add(idString);
                            }
                        
                            /*for(string strR : setRemove){
                                mapSKUFOCs.remove(strR);
                            }*/
                        
                            objFOC.skuFOCs = mapSKUFOCs;
                            system.debug('-------------------------------------AFTER mapSKUFOCs : ' + mapSKUFOCs);
                            system.debug('END changing objFOCSKU');
                            mapAllFOC.put(String.valueOf(objAccAddt.id) + '_' + strPCID, objFOC);
                        
                            System.debug('-------' + mapAllFOC);
                            System.debug('Spawn child contract Summary: ' + objFOC.CustomerName);
                        }
                    }
                }
            }
        }
        
        /*
        system.debug('---------------------- mapParentChild : ' + mapParentChild);
        for(string strKey : mapAllFOC.keyset()){
            //continue; //Daniel
            //if isParent
            //    map.put(Child customer ID +  parent Con ID, FOC) 
            if(mapAllFOC.get(strKey).isParent == TRUE){
                for(ASI_CRM_AccountsAdditionalField__c i : mapParentChild.get(mapAllFOC.get(strKey).CustomerId)){
                    CALFOC objFOC = new CALFOC();
                    objFOC = mapAllFOC.get(strKey); //.Clone(FALSE, TRUE, FALSE, FALSE);
                    //objFOC.skuFOCs = mapAllFOC.get(strKey).skuFOCs.deepClone();
                    
                    system.debug('-----------------------' + objFOC);
                    
                    objFOC.isParent = FALSE;
                    objFOC.CustomerId = i.id; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id;
                    objFOC.CustomerNo = i.ASI_CRM_MY_CustomerCode__c; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c;
                    objFOC.CustomerName = i.Name; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name;
                    objFOC.SalesName = i.Owner.FirstName  + ' ' + i.Owner.LastName; //objSS.ASI_CRM_Contract__r.Owner.FirstName + ' ' + objSS.ASI_CRM_Contract__r.Owner.LastName;
                    
                    string strCustID = string.valueOf(objFOC.CustomerId);
                    string strContractID = string.valueOf(objFOC.ContractNo);
                    mapAllFOC.put(strCustID + '_' + strContractID , objFOC);
                }
            }
        }*/
        
        System.debug('Finish getting contract summary AGAIN');
        System.debug(mapAllFOC);
        return mapAllFOC;
    }
    

    public map<String, CALFOC> getContractPaymentSummary(set<id> idOutlet, set<id> setOutletGrp, set<id> setContracts) {
        // Declaration
        list<CALFOC> lstFOC = new list<CALFOC>();
        map<String, CALFOC> mapAllFOC = new map<String, CALFOC>();
        set<id> setParent = new set<id>();
        set<id> setChild = new set<id>();
        set<id> setIDContractSet = new set<id>();
        map<id, set<id>> mapParentContract = new map<id, set<id>>(); // Contract(s) IDs under the parent  
        map<id, set<ASI_CRM_AccountsAdditionalField__c>> mapParentChild = new map<id, set<ASI_CRM_AccountsAdditionalField__c>>();
        boolean isChild = true; // If the FOC is enquire from child
        // Declaration - End
         
        
        // get contract target
        List<ASI_CRM_ContractTarget__c> contractTargetList = getContractTarget(setContracts);
        Map<String, Map<String, Decimal>> customer_contract_map = getMapOfContractTarget(contractTargetList);
        // get contract target
       	
        
        List<ASI_CRM_ContractVolumeIncentive__c> contractVolumeList = 
           [SELECT Id, 
            Name, 
            ASI_CRM_Description__c, 
            ASI_CRM_SKU__c, 
            ASI_CRM_SKU__r.id,
            ASI_CRM_PackFactor__c, 
            ASI_CRM_MinSPBtl__c,
            ASI_CRM_CashInc__c,
            ASI_CRM_SetupCode__c, 
            ASI_CRM_Total__c,
            ASI_CRM_FOC__c, 
            ASI_CRM_AchievedBtl__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c,
            ASI_CRM_Contract__r.Name, 
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name,
            ASI_CRM_SKU__r.ASI_CRM_SKU_Group__c,
            ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id,
            ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c,
			ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,
            ASI_CRM_Contract__c,
            ASI_CRM_Contract__r.Owner.FirstName, 
            ASI_CRM_Contract__r.Owner.LastName,
            ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id,
            ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c,
            ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c,
            ASI_CRM_Packaging_Size__c
            FROM  ASI_CRM_ContractVolumeIncentive__c
            WHERE ASI_CRM_Contract__c IN :setContracts
            AND ASI_CRM_AchievedBtl__c > 0
            AND ASI_CRM_CashInc__c > 0
            ORDER BY ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_Contract__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c];
        
        set<Id> skuIdSet = new set<Id>();
        for(ASI_CRM_ContractVolumeIncentive__c contractVolume : contractVolumeList){
            String strCustID = String.valueOf(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
            String strContractID = String.valueOf(contractVolume.ASI_CRM_Contract__c);
            CALFOC_SKU objSKUFOC = new CALFOC_SKU();
            CALFOC objFOC = new CALFOC();
            map<string, CALFOC_SKU> mapSKUFOCs = new map<string, CALFOC_SKU>(); 
            
            if(mapAllFOC.get(strCustID + '_' + strContractID) != null)
                objFOC = mapAllFOC.get(strCustID + '_' + strContractID);
            
            if(contractVolume.ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c == TRUE) {
                setParent.add(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id);
                
                if (mapParentContract.get(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c) == null) {
                    setIDContractSet = new set<id>();
                } else {
                    setIDContractSet = mapParentContract.get(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
                }
                setIDContractSet.add(contractVolume.ASI_CRM_Contract__r.id);
                
                mapParentContract.put(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, setIDContractSet);
            } 
                
            objFOC.isParent = contractVolume.ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c;
            objFOC.CustomerId = contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id;
            objFOC.CustomerNo = contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c;
            objFOC.CustomerName = contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name;
            objFOC.SalesName = contractVolume.ASI_CRM_Contract__r.Owner.FirstName + ' ' + contractVolume.ASI_CRM_Contract__r.Owner.LastName;
            objFOC.ContractNo = contractVolume.ASI_CRM_Contract__r.Name;
            objFOC.ContractId = contractVolume.ASI_CRM_Contract__r.id;
            objFOC.SDate = contractVolume.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c;
            objFOC.EDate = contractVolume.ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c;
            objFOC.voloumeType = 'Volume Incentive';
             
            if(objFOC.skuFOCs != null)
                mapSKUFOCs = objFOC.skuFOCs;
            
             
            Map<String, Decimal> customer_sku_map = customer_contract_map.get(strCustID + '_' + strContractID);
            String skuId = String.valueOf(contractVolume.ASI_CRM_SKU__r.id);
            String key_customer_sku = strCustID + '_' + skuId;
            Decimal contract_target_achieved_bottle = customer_sku_map.get(key_customer_sku);
             
            objSKUFOC.contract_target_achieved_bottle = contract_target_achieved_bottle;
            objSKUFOC.SKUId = contractVolume.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__c != null ? contractVolume.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id : contractVolume.ASI_CRM_SKU__r.id;
            objSKUFOC.SKUName = contractVolume.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c;
            
            objSKUFOC.OriginalSKUId = contractVolume.ASI_CRM_SKU__r.id;
            
            objSKUFOC.PackSize = contractVolume.ASI_CRM_Packaging_Size__c;
            objSKUFOC.ActualCase = (objSKUFOC.ActualBtl == null || objSKUFOC.PackSize == null || objSKUFOC.PackSize == 0) ? 0 : objSKUFOC.ActualBtl / objSKUFOC.PackSize;
            
            objSKUFOC.AchievedBtl = contractVolume.ASI_CRM_AchievedBtl__c;
            objSKUFOC.CashInc = contractVolume.ASI_CRM_CashInc__c;
            objSKUFOC.SetupCode = contractVolume.ASI_CRM_SetupCode__c;
             
           	// new skuId
           	/*
            Set<Id> oldSkuSet = new Set<Id>();
            Id oldSkuId = (Id)contractVolume.ASI_CRM_SKU__c;
            oldSkuSet.add(oldSkuId);
            Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(oldSkuSet);  
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            mapSKUFOCs.put(strCustID + '_' + string.valueOf(newSkuId), objSKUFOC);
			*/
            // new skuId  
            
            
            // old skuId
            Id oldSkuId = (Id)contractVolume.ASI_CRM_SKU__c;
            skuIdSet.add(oldSkuId);
			mapSKUFOCs.put(strCustID + '_' + string.valueOf(oldSkuId), objSKUFOC);
			// old skuId            
            
            
            objFOC.skuFOCs = mapSKUFOCs;
            
            System.debug(objSKUFOC);

            mapAllFOC.put(strCustID + '_' + strContractID, objFOC);
        }
        
        
        // map Latest SKU
        Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(skuIdSet);  
        for (String strKey : mapAllFOC.keySet()) {
            CALFOC objFOC = mapAllFOC.get(strKey);
            map<string, CALFOC_SKU> mapNewSKUFOCs = new map<string, CALFOC_SKU>();
            map<string, CALFOC_SKU> mapSKUFOCs = objFOC.skuFOCs;
            for (String skuStrKey : mapSKUFOCs.keySet()) {
				String[] strKey2 = skuStrKey.split('_', 2);
                String custId = strKey2[0];
                Id oldSkuId = (Id) strKey2[1]; 
                Id newSkuId = mapOfNewSKU.get(oldSkuId);
                mapNewSKUFOCs.put(custId+'_'+string.valueOf(newSkuId), mapSKUFOCs.get(skuStrKey));
                objFOC.skuFOCs = mapNewSKUFOCs;
            }
            mapAllFOC.put(strKey, objFOC);
        }
        // map Latest SKU
        
        
        // See if the enquiry view is from child outlet or parent outlet
        for (ASI_CRM_AccountsAdditionalField__c i : [
            SELECT id, Name, ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_Parent_Outlet__c
            FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE ASI_CRM_CN_Inactive_Flag__c = FALSE
            AND id IN :setOutletGrp
        ]) {
            if (i.ASI_CRM_CN_Parent_Outlet__c != NULL && (idOutlet.size() == 1 && idOutlet.contains(i.ASI_CRM_CN_Parent_Outlet__c)))
                isChild = false;
        }
        
        // set the Parent-Child Mapping
        system.debug('------------------- ASI_CRM_MY_CalculatedFOC.getContractSummary setParent : ' + setParent);
        if(setParent != NULL && setParent.size() > 0){
            // To Get all child's Offtake by the parent outlet id
            if(isChild == FALSE) {
                for(ASI_CRM_ActualOfftakeHeader__c i : [
                    SELECT id, ASI_CRM_ToOutlet__c
                    FROM ASI_CRM_ActualOfftakeHeader__c
                    WHERE ASI_CRM_ToOutlet__r.ASI_CRM_CN_Inactive_Flag__c = FALSE
                    AND ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c IN :setParent
                    AND ASI_CRM_OfftakeDate__c >= :dteStart
                    AND ASI_CRM_OfftakeDate__c <= :dteEnd
                ]){
                    setChild.add(i.ASI_CRM_ToOutlet__c); // Set Child Outlet IDs
                }
            }/*else if(isChild == TRUE){
                setChild.add(setOutletGrp);
            }*/
            
            for(id i : setOutletGrp){
                setChild.add(i);
            }
            
            for(id i : setParent){
                setChild.remove(i);
            }
            
            system.debug('---------------------------ASI_CRM_MY_CalculatedFOC.getContractSummary setChild : ' + setChild);
        
            for(ASI_CRM_AccountsAdditionalField__c i : [
                SELECT id, Name, ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_Parent_Outlet__c, Owner.FirstName, Owner.LastName
                FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE ASI_CRM_CN_Parent_Outlet__c IN :setParent
                AND ASI_CRM_CN_Inactive_Flag__c = FALSE
                AND id IN :setChild
            ]){
                set<ASI_CRM_AccountsAdditionalField__c> setTemp = new set<ASI_CRM_AccountsAdditionalField__c>();
                if(mapParentChild.get(i.ASI_CRM_CN_Parent_Outlet__c) != NULL)
                    setTemp = mapParentChild.get(i.ASI_CRM_CN_Parent_Outlet__c);
                setTemp.add(i);
                mapParentChild.put(i.ASI_CRM_CN_Parent_Outlet__c, setTemp);
            }
            
            system.debug('---------------------------ASI_CRM_MY_CalculatedFOC.getContractSummary mapParentChild: ' + mapParentChild);
            
            if (mapParentChild <> NULL && mapParentChild.size() > 0) {
                for (id i : mapParentChild.keyset()) {
                    
                    String strPPID = String.valueOf(i); // Parent Outlet ID
                    setIDContractSet = mapParentContract.get(i);
             
                    for (id idC : setIDContractSet) {
                        String strPCID = String.valueOf(idC); //String.valueOf(mapParentContract.get(i)); // Parent contract(s) IDs
                        String strKeyT = strPPID + '_' + strPCID;
                        system.debug('--------------------------strPPID_strPCID: ' + strKeyT);
                        for (ASI_CRM_AccountsAdditionalField__c objAccAddt : mapParentChild.get(i)) {
                            CALFOC objFOC = new CALFOC();
                            map<string, CALFOC_SKU> mapSKUFOCs = new map<string, CALFOC_SKU>();
                            //set<string> setRemove = new set<string>();
                            if (mapAllFOC.get(strKeyT) == null) { continue; }
                            objFOC = mapAllFOC.get(strKeyT).clone();
                        
                            objFOC.isParent = FALSE;
                            objFOC.CustomerId = objAccAddt.id; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id;
                            objFOC.CustomerNo = objAccAddt.ASI_CRM_MY_CustomerCode__c; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c;
                            objFOC.CustomerName = objAccAddt.Name; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name;
                            objFOC.SalesName = objAccAddt.Owner.FirstName + ' ' + objAccAddt.Owner.LastName; //objSS.ASI_CRM_Contract__r.Owner.FirstName + ' ' + objSS.ASI_CRM_Contract__r.Owner.LastName;
                        
                            // to change the Key value inside the cloned map
                            system.debug('START changing objFOCSKU');
                            //mapSKUFOCs = objFOC.skuFOCs;
                            system.debug('-------------------------------------BEFORE mapSKUFOCs : ' + mapSKUFOCs);
                            for(string idString : objFOC.skuFOCs.keySet()){
                                String[] strKey = idString.split('_', 2);
                                ID idSKU = (ID) strKey[1];
                                String strSKU = strKey[1];
                            
                                String strNewKey = string.valueOf(objFOC.CustomerId) + '_' + strSKU;
                                system.debug('------------strKey: ' + strKey + ', strNewKey: ' + strNewKey);
                                mapSKUFOCs.put(strNewKey, objFOC.skuFOCs.get(idString));
                                //mapSKUFOCs.put(strNewKey, objFOC.skuFOCs.get(idString).clone());
                                //setRemove.add(idString);
                            }
                        
                            /*for(string strR : setRemove){
                                mapSKUFOCs.remove(strR);
                            }*/
                        
                            objFOC.skuFOCs = mapSKUFOCs;
                            system.debug('-------------------------------------AFTER mapSKUFOCs : ' + mapSKUFOCs);
                            system.debug('END changing objFOCSKU');
                            mapAllFOC.put(String.valueOf(objAccAddt.id) + '_' + strPCID, objFOC);
                        
                            System.debug('-------' + mapAllFOC);
                            System.debug('Spawn child contract Summary: ' + objFOC.CustomerName);
                        }
                    }
                }
            }
        }
        
        System.debug(mapAllFOC);
        return mapAllFOC;
         
    }
    
    
    public List<ASI_CRM_ContractTarget__c> getContractTarget(set<id> setContracts){
        List<ASI_CRM_ContractTarget__c> contractTargetList = new List<ASI_CRM_ContractTarget__c>();
        contractTargetList = 
            [SELECT 
             	Id,
             	ASI_CRM_SKU__c,                            
             	ASI_CRM_TargetCase__c, 
             	ASI_CRM_Contract__c,
             	ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, 
             	ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c            
             FROM  ASI_CRM_ContractTarget__c                        
             WHERE ASI_CRM_Contract__c IN :setContracts];
        
        return contractTargetList;
    }
    
    
    public Map<String, Map<String, Decimal>> getMapOfContractTarget(List<ASI_CRM_ContractTarget__c> contractTargetList){
        Map<String, Map<String, Decimal>> customer_contract_map = new Map<String, Map<String, Decimal>>();
        for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList){
            String skuId = String.valueOf(contractTarget.ASI_CRM_SKU__c);
            String contractId = String.valueOf(contractTarget.ASI_CRM_Contract__c);
            String customerId = String.valueOf(contractTarget.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
            Decimal targetCase = contractTarget.ASI_CRM_TargetCase__c != null ? contractTarget.ASI_CRM_TargetCase__c : 0;
            Decimal packFactor = contractTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != null ? contractTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
            Decimal contract_target_achieved_bottle = targetCase * packFactor;
            
            String key_customer_sku = customerId + '_' + skuId;
            String key_customer_contract = customerId + '_' + contractId;
            Map<String, Decimal> customer_sku_map = customer_contract_map.containsKey(key_customer_contract) ? customer_contract_map.get(key_customer_contract) : new Map<String, Decimal>();
            customer_sku_map.put(key_customer_sku, contract_target_achieved_bottle);
            customer_contract_map.put(key_customer_contract, customer_sku_map);
        }
        return customer_contract_map;
    }
    
    
    public map<String, CALFOC> getContractOtherPaymentSummary(set<id> idOutlet, set<id> setOutletGrp, set<id> setContracts) {
        // Declaration
        list<CALFOC> lstFOC = new list<CALFOC>();
        map<String, CALFOC> mapAllFOC = new map<String, CALFOC>();
        set<id> setParent = new set<id>();
        set<id> setChild = new set<id>();
        set<id> setIDContractSet = new set<id>();
        map<id, set<id>> mapParentContract = new map<id, set<id>>(); // Contract(s) IDs under the parent  
        map<id, set<ASI_CRM_AccountsAdditionalField__c>> mapParentChild = new map<id, set<ASI_CRM_AccountsAdditionalField__c>>();
        boolean isChild = true; // If the FOC is enquire from child
        // Declaration - End
        
        List<ASI_CRM_ContractOtherIncentive__c > contractVolumeList = 
           [SELECT Id, 
            Name, 
            ASI_CRM_Description__c, 
            ASI_CRM_SKU__c, 
            ASI_CRM_SKU__r.id,
            ASI_CRM_PackFactor__c, 
            ASI_CRM_MinSPBtl__c,
            ASI_CRM_CashInc__c,
            ASI_CRM_SetupCode__c, 
            ASI_CRM_Total__c,
            ASI_CRM_FOC__c, 
            ASI_CRM_AchievedBtl__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c,
            ASI_CRM_Contract__r.Name, 
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name,
            ASI_CRM_SKU__r.ASI_CRM_SKU_Group__c,
            ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id,
            ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c,
			ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,
            ASI_CRM_Contract__c,
            ASI_CRM_Contract__r.Owner.FirstName, 
            ASI_CRM_Contract__r.Owner.LastName,
            ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id,
            ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c,
            ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c,
           	ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c 
            FROM  ASI_CRM_ContractOtherIncentive__c 
            WHERE ASI_CRM_Contract__c IN :setContracts
            AND ASI_CRM_CashInc__c > 0
            AND ASI_CRM_AchievedBtl__c > 0
            AND (ASI_CRM_SetupCode__c = 'SSEC' 
            OR ASI_CRM_SetupCode__c = 'VOLC')
            ORDER BY ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_Contract__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c];
        
         set<Id> skuIdSet = new set<Id>();
         for(ASI_CRM_ContractOtherIncentive__c contractVolume : contractVolumeList){
            String strCustID = String.valueOf(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
            String strContractID = String.valueOf(contractVolume.ASI_CRM_Contract__c);
            CALFOC_SKU objSKUFOC = new CALFOC_SKU();
            CALFOC objFOC = new CALFOC();
            map<string, CALFOC_SKU> mapSKUFOCs = new map<string, CALFOC_SKU>(); 
            
            if(mapAllFOC.get(strCustID + '_' + strContractID) != null)
                objFOC = mapAllFOC.get(strCustID + '_' + strContractID);
            
            if(contractVolume.ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c == TRUE) {
                setParent.add(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id);
                
                if (mapParentContract.get(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c) == null) {
                    setIDContractSet = new set<id>();
                } else {
                    setIDContractSet = mapParentContract.get(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c);
                }
                setIDContractSet.add(contractVolume.ASI_CRM_Contract__r.id);
                
                mapParentContract.put(contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, setIDContractSet);
            } 
                
            objFOC.isParent = contractVolume.ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c;
            objFOC.CustomerId = contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id;
            objFOC.CustomerNo = contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c;
            objFOC.CustomerName = contractVolume.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name;
            objFOC.SalesName = contractVolume.ASI_CRM_Contract__r.Owner.FirstName + ' ' + contractVolume.ASI_CRM_Contract__r.Owner.LastName;
            objFOC.ContractNo = contractVolume.ASI_CRM_Contract__r.Name;
            objFOC.ContractId = contractVolume.ASI_CRM_Contract__r.id;
            objFOC.SDate = contractVolume.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c;
            objFOC.EDate = contractVolume.ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c;
            objFOC.voloumeType = 'Other Incentive';
             
            if(objFOC.skuFOCs != null)
                mapSKUFOCs = objFOC.skuFOCs;
            
            objSKUFOC.contract_target_achieved_bottle = contractVolume.ASI_CRM_AchievedBtl__c != null ? contractVolume.ASI_CRM_AchievedBtl__c : 0;
            objSKUFOC.SKUId = contractVolume.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__c != null ? contractVolume.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id : contractVolume.ASI_CRM_SKU__r.id;
            objSKUFOC.SKUName = contractVolume.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c;
            
            objSKUFOC.OriginalSKUId = contractVolume.ASI_CRM_SKU__r.id;
            
            //objSKUFOC.ActualBtl;
            objSKUFOC.PackSize = contractVolume.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c;
            objSKUFOC.ActualCase = (objSKUFOC.ActualBtl == null || objSKUFOC.PackSize == null || objSKUFOC.PackSize == 0) ? 0 : objSKUFOC.ActualBtl / objSKUFOC.PackSize;
            
            objSKUFOC.AchievedBtl = contractVolume.ASI_CRM_AchievedBtl__c;
            objSKUFOC.CashInc = contractVolume.ASI_CRM_CashInc__c;
            objSKUFOC.SetupCode = contractVolume.ASI_CRM_SetupCode__c;
             
            
           	// new skuId
           	/*
            Set<Id> oldSkuSet = new Set<Id>();
            Id oldSkuId = (Id)contractVolume.ASI_CRM_SKU__c;
            oldSkuSet.add(oldSkuId);
            Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(oldSkuSet);  
            Id newSkuId = mapOfNewSKU.get(oldSkuId);
            mapSKUFOCs.put(strCustID + '_' + string.valueOf(newSkuId), objSKUFOC);
			*/
            // new skuId  
           		  
             
            // old skuId
            Id oldSkuId = (Id)contractVolume.ASI_CRM_SKU__c;
            skuIdSet.add(oldSkuId);
            mapSKUFOCs.put(strCustID + '_' + string.valueOf(oldSkuId), objSKUFOC);
            // old skuId 
             
            objFOC.skuFOCs = mapSKUFOCs;
            
           	

            mapAllFOC.put(strCustID + '_' + strContractID, objFOC);
        }
        
        
        // map Latest SKU
        Map<Id,Id> mapOfNewSKU = ASI_CRM_MY_Function.getLatestSKUByOld(skuIdSet);  
        for (String strKey : mapAllFOC.keySet()) {
            CALFOC objFOC = mapAllFOC.get(strKey);
            map<string, CALFOC_SKU> mapNewSKUFOCs = new map<string, CALFOC_SKU>();
            map<string, CALFOC_SKU> mapSKUFOCs = objFOC.skuFOCs;
            for (String skuStrKey : mapSKUFOCs.keySet()) {
				String[] strKey2 = skuStrKey.split('_', 2);
                String custId = strKey2[0];
                Id oldSkuId = (Id) strKey2[1]; 
                Id newSkuId = mapOfNewSKU.get(oldSkuId);
                mapNewSKUFOCs.put(custId+'_'+string.valueOf(newSkuId), mapSKUFOCs.get(skuStrKey));
                objFOC.skuFOCs = mapNewSKUFOCs;
            }
            mapAllFOC.put(strKey, objFOC);
        }
        // map Latest SKU
        
        
        System.debug('--------------------- mapAllFOC : ' + mapAllFOC);
        System.debug('--------------------- mapParentContract : ' + mapParentContract);
        System.debug('Finish getting contract summary');
        
        // See if the enquiry view is from child outlet or parent outlet
        for (ASI_CRM_AccountsAdditionalField__c i : [
            SELECT id, Name, ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_Parent_Outlet__c
            FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE ASI_CRM_CN_Inactive_Flag__c = FALSE
            AND id IN :setOutletGrp
        ]) {
            if (i.ASI_CRM_CN_Parent_Outlet__c != NULL && (idOutlet.size() == 1 && idOutlet.contains(i.ASI_CRM_CN_Parent_Outlet__c)))
                isChild = false;
        }
        
        // set the Parent-Child Mapping
        system.debug('------------------- ASI_CRM_MY_CalculatedFOC.getContractSummary setParent : ' + setParent);
        if(setParent != NULL && setParent.size() > 0){
            // To Get all child's Offtake by the parent outlet id
            if(isChild == FALSE) {
                for(ASI_CRM_ActualOfftakeHeader__c i : [
                    SELECT id, ASI_CRM_ToOutlet__c
                    FROM ASI_CRM_ActualOfftakeHeader__c
                    WHERE ASI_CRM_ToOutlet__r.ASI_CRM_CN_Inactive_Flag__c = FALSE
                    AND ASI_CRM_ToOutlet__r.ASI_CRM_CN_Parent_Outlet__c IN :setParent
                    AND ASI_CRM_OfftakeDate__c >= :dteStart
                    AND ASI_CRM_OfftakeDate__c <= :dteEnd
                ]){
                    setChild.add(i.ASI_CRM_ToOutlet__c); // Set Child Outlet IDs
                }
            }/*else if(isChild == TRUE){
                setChild.add(setOutletGrp);
            }*/
            
            for(id i : setOutletGrp){
                setChild.add(i);
            }
            
            for(id i : setParent){
                setChild.remove(i);
            }
            
            system.debug('---------------------------ASI_CRM_MY_CalculatedFOC.getContractSummary setChild : ' + setChild);
        
            for(ASI_CRM_AccountsAdditionalField__c i : [
                SELECT id, Name, ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_Parent_Outlet__c, Owner.FirstName, Owner.LastName
                FROM ASI_CRM_AccountsAdditionalField__c 
                WHERE ASI_CRM_CN_Parent_Outlet__c IN :setParent
                AND ASI_CRM_CN_Inactive_Flag__c = FALSE
                AND id IN :setChild
            ]){
                set<ASI_CRM_AccountsAdditionalField__c> setTemp = new set<ASI_CRM_AccountsAdditionalField__c>();
                if(mapParentChild.get(i.ASI_CRM_CN_Parent_Outlet__c) != NULL)
                    setTemp = mapParentChild.get(i.ASI_CRM_CN_Parent_Outlet__c);
                setTemp.add(i);
                mapParentChild.put(i.ASI_CRM_CN_Parent_Outlet__c, setTemp);
            }
            
            system.debug('---------------------------ASI_CRM_MY_CalculatedFOC.getContractSummary mapParentChild: ' + mapParentChild);
            
            if (mapParentChild <> NULL && mapParentChild.size() > 0) {
                for (id i : mapParentChild.keyset()) {
                    
                    String strPPID = String.valueOf(i); // Parent Outlet ID
                    setIDContractSet = mapParentContract.get(i);
             
                    for (id idC : setIDContractSet) {
                        String strPCID = String.valueOf(idC); //String.valueOf(mapParentContract.get(i)); // Parent contract(s) IDs
                        String strKeyT = strPPID + '_' + strPCID;
                        system.debug('--------------------------strPPID_strPCID: ' + strKeyT);
                        for (ASI_CRM_AccountsAdditionalField__c objAccAddt : mapParentChild.get(i)) {
                            CALFOC objFOC = new CALFOC();
                            map<string, CALFOC_SKU> mapSKUFOCs = new map<string, CALFOC_SKU>();
                            //set<string> setRemove = new set<string>();
                            if (mapAllFOC.get(strKeyT) == null) { continue; }
                            objFOC = mapAllFOC.get(strKeyT).clone();
                        
                            objFOC.isParent = FALSE;
                            objFOC.CustomerId = objAccAddt.id; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id;
                            objFOC.CustomerNo = objAccAddt.ASI_CRM_MY_CustomerCode__c; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c;
                            objFOC.CustomerName = objAccAddt.Name; //objSS.ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name;
                            objFOC.SalesName = objAccAddt.Owner.FirstName + ' ' + objAccAddt.Owner.LastName; //objSS.ASI_CRM_Contract__r.Owner.FirstName + ' ' + objSS.ASI_CRM_Contract__r.Owner.LastName;
                        
                            // to change the Key value inside the cloned map
                            system.debug('START changing objFOCSKU');
                            //mapSKUFOCs = objFOC.skuFOCs;
                            system.debug('-------------------------------------BEFORE mapSKUFOCs : ' + mapSKUFOCs);
                            for(string idString : objFOC.skuFOCs.keySet()){
                                String[] strKey = idString.split('_', 2);
                                ID idSKU = (ID) strKey[1];
                                String strSKU = strKey[1];
                            
                                String strNewKey = string.valueOf(objFOC.CustomerId) + '_' + strSKU;
                                system.debug('------------strKey: ' + strKey + ', strNewKey: ' + strNewKey);
                                mapSKUFOCs.put(strNewKey, objFOC.skuFOCs.get(idString));
                                //mapSKUFOCs.put(strNewKey, objFOC.skuFOCs.get(idString).clone());
                                //setRemove.add(idString);
                            }
                        
                            /*for(string strR : setRemove){
                                mapSKUFOCs.remove(strR);
                            }*/
                        
                            objFOC.skuFOCs = mapSKUFOCs;
                            system.debug('-------------------------------------AFTER mapSKUFOCs : ' + mapSKUFOCs);
                            system.debug('END changing objFOCSKU');
                            mapAllFOC.put(String.valueOf(objAccAddt.id) + '_' + strPCID, objFOC);
                        
                            System.debug('-------' + mapAllFOC);
                            System.debug('Spawn child contract Summary: ' + objFOC.CustomerName);
                        }
                    }
                }
            }
        }
        
        System.debug(mapAllFOC);
        return mapAllFOC;
         
    }
    
    
    
    public Class FOCdata{
        public String PeriodKey {get;set;}
        public Id CustomerId {get; set;}
        //public Id ParentId {get; set;}
        public String CustomerNo {get;set;}
        public String CustomerName {get;set;}
        public String SalesName {get;set;}
        public String ContractNo {get;set;}
        public Id ContractId {get; set;}
        public Id SKUId {get; set;}
        public Id OriginalSKUId {get; set;}
        public String SKUName {get;set;}
        public Decimal AP_Btl {get;set;}
        public Decimal AP_Case {get;set;}
        public Decimal AchievedBtl {get;set;}
        public Decimal PRMBroughtForward {get;set;}
        public Decimal PRMFOCFactor {get;set;}
        public Decimal PRMFOCBtl {get;set;}
        public Decimal PRMRemain {get;set;}
        public Decimal WSBroughtForward {get;set;}
        public Decimal WSFOCFactor {get;set;}
        public Decimal WSFOCBtl {get;set;}
        public Decimal WSRemain {get;set;}
        public Decimal CashInc {get;set;}
        public Decimal contract_target_achieved_bottle {get;set;}
        public String SetupCode {get;set;}
        public String JDECOA {get;set;}
        public String voloumeType {get;set;}
         
        FOCdata(String strPeriodKey, Id IdCustomerId, String strCustomerNo, String strCustomerName, String strSalesName, String strContractNo, Id IdContractId,
                String strSKUName, Id IdSKUId, Decimal dblAP_Btl, Decimal dblAP_Case, Decimal dblAchievedBtl, Decimal dblPRMBroughtForward,
                Decimal dblPRMFOCFactor, Decimal dblPRMFOCBtl, Decimal dblPRMRemain, Decimal dblWSBroughtForward,
                Decimal dblWSFOCFactor, Decimal dblWSFOCBtl, Decimal dblWSRemain, Decimal dblCashInc, String SetupCode, String JDECOA, Id OriginalSKUId, String voloumeType, Decimal contract_target_achieved_bottle
        ){
            this.PeriodKey = strPeriodKey;
            this.CustomerId = idCustomerId;
            //this.ParentId = idParentId;
            this.CustomerNo = strCustomerNo;
            this.CustomerName = strCustomerName;
            this.SalesName = strSalesName;
            this.ContractNo = strContractNo;
            this.ContractId = IdContractId;
            this.SKUName = strSKUName;
            this.SKUId = IdSKUID;
            this.OriginalSKUId = OriginalSKUId;
            this.AP_Btl = dblAP_Btl;
            this.AP_Case = dblAP_Case;
            
            this.AchievedBtl = dblAchievedBtl;
            this.PRMBroughtForward = dblPRMBroughtForward;
            this.PRMFOCFactor = dblPRMFOCFactor;
            this.PRMFOCBtl = dblPRMFOCBtl;
            this.PRMRemain = dblPRMRemain;
            this.WSBroughtForward = dblWSBroughtForward;
            this.WSFOCFactor = dblWSFOCFactor;
            this.WSFOCBtl = dblWSFOCBtl;
            this.WSRemain = dblWSRemain;
            this.CashInc = dblCashInc;
            this.SetupCode = SetupCode;
            this.JDECOA = JDECOA;
            this.voloumeType = voloumeType;
            this.contract_target_achieved_bottle = contract_target_achieved_bottle;
        }
    }
    
    public list<FOCdata> genFOC_List(set<id> setCustomer, date dteGenDate /*id idOutlet*/) {
        list<FOCdata> lstCalculatedFOC = new list<FOCdata>();
        //ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        map<String, CALFOC> mapCalFOC = new map<String, CALFOC>();
        
        system.debug('----------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC_List BEFORE generate the mapCalFOC');
        /*
        List<ASI_CRM_MY_Settings__c> lstMYSetting = [SELECT ASI_CRM_MY_Offtake_Cutoff_Day__c FROM ASI_CRM_MY_Settings__c WHERE ASI_CRM_MY_Offtake_Cutoff_Day__c != NULL LIMIT 1];
        if(lstMYSetting != NULL && lstMYSetting.size() > 0){
            intCutOffDay = integer.valueOf(lstMYSetting[0].ASI_CRM_MY_Offtake_Cutoff_Day__c);
        }
        */
        mapCalFOC = genFOC(setCustomer, dteGenDate);
        system.debug('-------------------------mapCalFOC' + mapCalFOC);
        system.debug('----------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC_List AFTER generate the mapCalFOC : ' + mapCalFOC);
        String strY = String.valueOf(dteGenDate.year()); //String.valueOf(Date.today().year());
        String strM = String.valueOf(dteGenDate.month()); //String.valueOf(Date.today().month());
        String strPeriod = strY + (strM.length() == 1 ? '0' + strM : strM);
		
        for(String strkey : mapCalFOC.keySet()){
            String[] strTemp = strKey.split('_', 2);
            String strOutletID = strTemp[0];
            String strContractID = strTemp[1];
            
            ASI_CRM_MY_CalculatedFOC.CALFOC objCALFOC = mapCalFOC.get(strKey);
            system.debug('------------------------------------------objCALFOC : ' + objCALFOC);
            
            Id IdCustomerId = objCALFOC.CustomerId;
            String strCustomerNo = objCALFOC.CustomerNo;
            String strCustomerName = objCALFOC.CustomerName;
            String strContractNo = objCALFOC.ContractNo;
            Id IdContractId = objCALFOC.ContractId;
            String strSales = objCALFOC.SalesName;
            String voloumeType = objCALFOC.voloumeType != null ? objCALFOC.voloumeType : '';
            
            if (objCALFOC.skuFOCs != null && !objCALFOC.skuFOCs.isEmpty()) {
                for (string idString : objCALFOC.skuFOCs.keySet()) {
                    ASI_CRM_MY_CalculatedFOC.CALFOC_SKU objFOCSKU = objCALFOC.skuFOCs.get(idString);
                    objFOCSKU = objFOCSKU.clone();
                    if (objFOCSKU.ActualBtl == null) objFOCSKU.ActualBtl = 0;
                    if (objFOCSKU.PackSize == null) objFOCSKU.PackSize = 0;
                    if (objFOCSKU.PRMBroughtForward == null) objFOCSKU.PRMBroughtForward = 0;
                    if (objFOCSKU.PRMFOCFactor == null) objFOCSKU.PRMFOCFactor = 0;
                    if (objFOCSKU.PRMFOCBtl == null) objFOCSKU.PRMFOCBtl = 0;
                    if (objFOCSKU.PRMRemain == null) objFOCSKU.PRMRemain = 0;
                    if (objFOCSKU.WSBroughtForward == null) objFOCSKU.WSBroughtForward = 0;
                    if (objFOCSKU.WSFOCFactor == null) objFOCSKU.WSFOCFactor = 0;
                    if (objFOCSKU.WSFOCBtl == null) objFOCSKU.WSFOCBtl = 0;
                    if (objFOCSKU.WSRemain == null) objFOCSKU.WSRemain = 0;
                    if (objFOCSKU.CashInc == null) objFOCSKU.CashInc = 0;
                    if (objFOCSKU.contract_target_achieved_bottle == null) objFOCSKU.contract_target_achieved_bottle = 0;
                    
                    system.debug('------------------------------------------objFOCSKU : ' + objFOCSKU);
                    map<id, decimal> mapSKUCount = new map<id, decimal>();
                    
                    String SKUName = '';
                    Id SKUID;
                    Id OriginalSKUId;
                    decimal ActualBtl = 0;
                    decimal PackSize = 0;
                    decimal ActualCase = 0;
                    
                    decimal AchievedBtl = 0;
                    decimal PRMBroughtForward = 0;
                    decimal PRMFOCFactor = 0;
                    decimal PRMFOCBtl = 0;
                    decimal PRMRemain = 0;
                    decimal WSBroughtForward = 0;
                    decimal WSFOCFactor = 0;
                    decimal WSFOCBtl = 0;
                    decimal WSRemain = 0;
                    decimal CashInc = 0;
                    decimal contract_target_achieved_bottle = 0;
                    String SetupCode = '';
                    String JDECOA = '';
                    
                    if (objFOCSKU != null) {
                        SKUName = objFOCSKU.SKUName;
                        SKUID = objFOCSKU.SKUId;
                        OriginalSKUId = objFOCSKU.OriginalSKUId;
                        ActualBtl = objFOCSKU.ActualBtl;
                        PackSize = objFOCSKU.PackSize;
                        ActualCase = (objFOCSKU.ActualBtl / objFOCSKU.PackSize).setScale(2);
                        
                        AchievedBtl = objFOCSKU.AchievedBtl;
                        PRMBroughtForward = objFOCSKU.PRMBroughtForward;
                        PRMFOCFactor = objFOCSKU.PRMFOCFactor;
                        PRMFOCBtl = objFOCSKU.PRMFOCBtl;
                        PRMRemain = objFOCSKU.PRMRemain;
                        WSBroughtForward = objFOCSKU.WSBroughtForward;
                        WSFOCFactor = objFOCSKU.WSFOCFactor;
                        WSFOCBtl = objFOCSKU.WSFOCBtl;
                        WSRemain = objFOCSKU.WSRemain;
                        CashInc = objFOCSKU.CashInc;
                        SetupCode = objFOCSKU.SetupCode;
                        JDECOA = objFOCSKU.JDECOA;
                        contract_target_achieved_bottle = objFOCSKU.contract_target_achieved_bottle;
                    }
                    
                    // Only show the item having actual purchase OR brought fw <> 0  
                    if (ActualBtl <> 0 || WSBroughtForward <> 0 || PRMBroughtForward <> 0 /*|| TRUE*/) {
                        lstCalculatedFOC.add(new FOCdata(strPeriod, IdCustomerId, strCustomerNo, strCustomerName, strSales, 
                                                             strContractNo, IdContractId, SKUName, SKUid, ActualBtl.setScale(2), 
                                                             ActualCase.setScale(2), AchievedBtl.setScale(2), PRMBroughtForward.setScale(2),
                                                             PRMFOCFactor.setScale(2), PRMFOCBtl.setScale(2), PRMRemain.setScale(2), WSBroughtForward.setScale(2), 
                                                             WSFOCFactor.setScale(2), WSFOCBtl.setScale(2), WSRemain.setScale(2), CashInc.setScale(2), SetupCode, JDECOA, OriginalSKUId, voloumeType, contract_target_achieved_bottle));
                    }
                }
            }
        }
        //lstStaticDummaryList.add(new FOCdata('201403', '503997', 'RED BOX KARAOKE (503997)', 'Stanley', '00009001.3', 'ABA100_ABSOLUT APEACH 1L 40%', 3, 0.25, 12, 2.5, 0, 3, 0, 0, 0));
        //system.debug('---------------------------------------------------lstCalculatedFOC: ' + lstCalculatedFOC);
        return lstCalculatedFOC;
    }
    
   	public list<FOCdata> genFOCPayment_List(set<id> setCustomer, date dteGenDate /*id idOutlet*/) {
        list<FOCdata> lstCalculatedFOC = new list<FOCdata>();
        //ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        map<String, CALFOC> mapCalFOC = new map<String, CALFOC>();
        
        system.debug('----------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC_List BEFORE generate the mapCalFOC');
        /*
        List<ASI_CRM_MY_Settings__c> lstMYSetting = [SELECT ASI_CRM_MY_Offtake_Cutoff_Day__c FROM ASI_CRM_MY_Settings__c WHERE ASI_CRM_MY_Offtake_Cutoff_Day__c != NULL LIMIT 1];
        if(lstMYSetting != NULL && lstMYSetting.size() > 0){
            intCutOffDay = integer.valueOf(lstMYSetting[0].ASI_CRM_MY_Offtake_Cutoff_Day__c);
        }
        */
        mapCalFOC = genFOCPayment(setCustomer, dteGenDate);
        system.debug('-------------------------mapCalFOC' + mapCalFOC);
        system.debug('----------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC_List AFTER generate the mapCalFOC : ' + mapCalFOC);
        String strY = String.valueOf(dteGenDate.year()); //String.valueOf(Date.today().year());
        String strM = String.valueOf(dteGenDate.month()); //String.valueOf(Date.today().month());
        String strPeriod = strY + (strM.length() == 1 ? '0' + strM : strM);

        for(String strkey : mapCalFOC.keySet()){
            String[] strTemp = strKey.split('_', 3);
            String strOutletID = strTemp[0];
            String strContractID = strTemp[1];
            
            ASI_CRM_MY_CalculatedFOC.CALFOC objCALFOC = mapCalFOC.get(strKey);
            system.debug('------------------------------------------objCALFOC : ' + objCALFOC);
            
            Id IdCustomerId = objCALFOC.CustomerId;
            String strCustomerNo = objCALFOC.CustomerNo;
            String strCustomerName = objCALFOC.CustomerName;
            String strContractNo = objCALFOC.ContractNo;
            Id IdContractId = objCALFOC.ContractId;
            String strSales = objCALFOC.SalesName;
            String voloumeType = objCALFOC.voloumeType != null ? objCALFOC.voloumeType : '';
            
            if (objCALFOC.skuFOCs != null && !objCALFOC.skuFOCs.isEmpty()) {
                for (string idString : objCALFOC.skuFOCs.keySet()) {
                    ASI_CRM_MY_CalculatedFOC.CALFOC_SKU objFOCSKU = objCALFOC.skuFOCs.get(idString);
                    objFOCSKU = objFOCSKU.clone();
                    if (objFOCSKU.ActualBtl == null) objFOCSKU.ActualBtl = 0;
                    if (objFOCSKU.PackSize == null) objFOCSKU.PackSize = 0;
                    if (objFOCSKU.PRMBroughtForward == null) objFOCSKU.PRMBroughtForward = 0;
                    if (objFOCSKU.PRMFOCFactor == null) objFOCSKU.PRMFOCFactor = 0;
                    if (objFOCSKU.PRMFOCBtl == null) objFOCSKU.PRMFOCBtl = 0;
                    if (objFOCSKU.PRMRemain == null) objFOCSKU.PRMRemain = 0;
                    if (objFOCSKU.WSBroughtForward == null) objFOCSKU.WSBroughtForward = 0;
                    if (objFOCSKU.WSFOCFactor == null) objFOCSKU.WSFOCFactor = 0;
                    if (objFOCSKU.WSFOCBtl == null) objFOCSKU.WSFOCBtl = 0;
                    if (objFOCSKU.WSRemain == null) objFOCSKU.WSRemain = 0;
                    if (objFOCSKU.CashInc == null) objFOCSKU.CashInc = 0;
                    if (objFOCSKU.contract_target_achieved_bottle == null) objFOCSKU.contract_target_achieved_bottle = 0;
                    
                    system.debug('------------------------------------------objFOCSKU : ' + objFOCSKU);
                    map<id, decimal> mapSKUCount = new map<id, decimal>();
                    
                    String SKUName = '';
                    Id SKUID;
                    Id OriginalSKUId;
                    decimal ActualBtl = 0;
                    decimal PackSize = 0;
                    decimal ActualCase = 0;
                  	
                    decimal AchievedBtl = 0;
                    decimal PRMBroughtForward = 0;
                    decimal PRMFOCFactor = 0;
                    decimal PRMFOCBtl = 0;
                    decimal PRMRemain = 0;
                    decimal WSBroughtForward = 0;
                    decimal WSFOCFactor = 0;
                    decimal WSFOCBtl = 0;
                    decimal WSRemain = 0;
                    decimal CashInc = 0;
                    String SetupCode = '';
                    String JDECOA = '';
                    decimal contract_target_achieved_bottle = 0;
                    
                    if (objFOCSKU != null) {
                        SKUName = objFOCSKU.SKUName;
                        SKUID = objFOCSKU.SKUId;
                        OriginalSKUId = objFOCSKU.OriginalSKUId;
                        ActualBtl = objFOCSKU.ActualBtl;
                        PackSize = objFOCSKU.PackSize;
                        ActualCase = PackSize <= 0 ? 0 : (objFOCSKU.ActualBtl / objFOCSKU.PackSize).setScale(2);
                        
                        AchievedBtl = objFOCSKU.AchievedBtl;
                        PRMBroughtForward = objFOCSKU.PRMBroughtForward;
                        PRMFOCFactor = objFOCSKU.PRMFOCFactor;
                        PRMFOCBtl = objFOCSKU.PRMFOCBtl;
                        PRMRemain = objFOCSKU.PRMRemain;
                        WSBroughtForward = objFOCSKU.WSBroughtForward;
                        WSFOCFactor = objFOCSKU.WSFOCFactor;
                        WSFOCBtl = objFOCSKU.WSFOCBtl;
                        WSRemain = objFOCSKU.WSRemain;
                        CashInc = objFOCSKU.CashInc;
                        SetupCode = objFOCSKU.SetupCode;
                        JDECOA = objFOCSKU.JDECOA;
                        contract_target_achieved_bottle = objFOCSKU.contract_target_achieved_bottle;
                    }
                    
                    // Only show the item having actual purchase OR brought fw <> 0  
                    if (ActualBtl <> 0 || WSBroughtForward <> 0 || PRMBroughtForward <> 0 /*|| TRUE*/) {
                        lstCalculatedFOC.add(new FOCdata(strPeriod, IdCustomerId, strCustomerNo, strCustomerName, strSales, 
                                                             strContractNo, IdContractId, SKUName, SKUid, ActualBtl.setScale(2), 
                                                             ActualCase.setScale(2), AchievedBtl.setScale(2), PRMBroughtForward.setScale(2),
                                                             PRMFOCFactor.setScale(2), PRMFOCBtl.setScale(2), PRMRemain.setScale(2), WSBroughtForward.setScale(2), 
                                                             WSFOCFactor.setScale(2), WSFOCBtl.setScale(2), WSRemain.setScale(2), CashInc.setScale(2), SetupCode, JDECOA, OriginalSKUId, voloumeType, contract_target_achieved_bottle));
                    }
                }
            }
        }
        //lstStaticDummaryList.add(new FOCdata('201403', '503997', 'RED BOX KARAOKE (503997)', 'Stanley', '00009001.3', 'ABA100_ABSOLUT APEACH 1L 40%', 3, 0.25, 12, 2.5, 0, 3, 0, 0, 0));
        //system.debug('---------------------------------------------------lstCalculatedFOC: ' + lstCalculatedFOC);
        return lstCalculatedFOC;
    }
    
    
    public map<String, CALFOC> genFOC(set<id> idOutlet, date dteGenDate /*id idOutlet*/) {
        // Declaration
        id idRT_Outlet = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        id idRT_POutlet = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
        set<id> setRTOutlet = new set<id>();
        set<id> setRTContract = new set<id>();
        set<id> setOutletGrp = new set<id>();
        set<id> setContracts = new set<id>();
        mapContracts = new map<id, ASI_TH_CRM_Contract__c>();
        map<id, map<id, list<OFFTAKE_INV_DATE>>> mapResOfftakeSummary = new map<id, map<id, list<OFFTAKE_INV_DATE>>>(); // <OutletID, <SKUID, count>>
        map<string, CALFOC> mapRes = new map<string, CALFOC>(); // <OutletID_ContractID, <SKUID, CALFOC_SKU>>
        map<string, ASI_CRM_Calculated_FOC_Line__c> mapRemain = new map<string, ASI_CRM_Calculated_FOC_Line__c>();
        map<string, CALFOC> mapReturn = new map<string, CALFOC>(); // <OutletID_ContractID, <SKUID, CALFOC_SKU>>
        boolean isRecord = FALSE;
        date conDateStart;
        date conDateEnd;
        // Declaration - End
        
        system.debug('--------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC dteGenDate : '+ dteGenDate + ' intCutOffDay : ' + intCutOffDay);
        
        
        setRTOutlet.add(idRT_Outlet); 
        setRTOutlet.add(idRT_POutlet);
        setRTContract.add(idRT_ContractFinal);
        
        
        // Set the outlet involve
        for (ASI_CRM_AccountsAdditionalField__c objOutlet : [
            SELECT id, ASI_CRM_CN_Parent_Outlet__c
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE (id IN :idOutlet 
            OR ASI_CRM_CN_Parent_Outlet__c IN :idOutlet)
            AND ASI_CRM_CN_Inactive_Flag__c = false
            AND RecordTypeId IN :setRTOutlet
        ]) {
            setOutletGrp.add(objOutlet.id);
            system.debug('@@@setOutletGrp@@@: '+objOutlet.id);
            if(objOutlet.ASI_CRM_CN_Parent_Outlet__c != NULL)
                setOutletGrp.add(objOutlet.ASI_CRM_CN_Parent_Outlet__c);
        }

        
        
        map<String, date> mapOfftakeDate = getOfftakeMaxMinDate(setOutletGrp, dteGenDate);
        conDateStart = mapOfftakeDate.get('min');
        conDateEnd = mapOfftakeDate.get('max');
        system.debug('@@@conDateStart@@@: '+conDateStart);
        system.debug('@@@conDateEnd@@@: '+conDateEnd);
        
        // Get all contract under the outlet group
        for (ASI_TH_CRM_Contract__c objContract : [
            SELECT 
            	id, 
            	name, 
            	ASI_TH_CRM_Start_Date__c, 
            	ASI_TH_CRM_End_Date__c, 
            	ASI_CRM_IsParentContract__c,
                OwnerId 
            FROM ASI_TH_CRM_Contract__c
            WHERE RecordTypeID IN :setRTContract
            AND ASI_TH_CRM_Contract_Status__c = 'Final'
            AND ASI_CRM_Terminate__c = false
            AND ASI_CRM_Obsolete_Version__c = false
            AND (
                (ASI_TH_CRM_Start_Date__c <= :conDateStart AND ASI_TH_CRM_End_Date__c >= :conDateStart)
                OR (ASI_TH_CRM_Start_Date__c <= :conDateEnd AND ASI_TH_CRM_End_Date__c >= :conDateEnd)
                //(ASI_TH_CRM_Start_Date__c <= TODAY AND ASI_TH_CRM_End_Date__c >= TODAY)
                //OR (ASI_TH_CRM_End_Date__c >= LAST_90_DAYS AND ASI_TH_CRM_End_Date__c <= TODAY)
                
                //(ASI_TH_CRM_Start_Date__c >= :conDateStart OR ASI_TH_CRM_End_Date__c >= :conDateEnd)
            )
            AND ASI_CRM_CN_Outlet_WS__c IN :setOutletGrp
        ]) {
            //System.debug('Contract ID/Name: ' + objContract.ID + '/' + objContract.Name + ', Period: ' + objContract.ASI_TH_CRM_Start_Date__c + ' to ' + objContract.ASI_TH_CRM_End_Date__c);
            setContracts.add(objContract.id);
            mapContracts.put(objContract.id, objContract);
            system.debug('@@@setContracts@@@: '+objContract.id);
        }
        
       	
        
        if(Test.isRunningTest()){
            for(ASI_TH_CRM_Contract__c objContract : [SELECT id FROM ASI_TH_CRM_Contract__c LIMIT 1]){
                setContracts.add(objContract.id);
            }     
        }
        
        system.debug('--------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC setOutletGrp : ' + setOutletGrp);
        system.debug('--------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC setContracts : ' + setContracts);
        
        // Get the figures before merge
        mapResOfftakeSummary = getOfftakeSummary(setOutletGrp, dteGenDate, FOC_STATUS); // Offtake of current month, Date
        mapRemain = genPreviousMthCalculatedFOC(setOutletGrp, setContracts, dteGenDate); // Previous Month Carry Forward //TODO
        mapRes = getContractSummary(idOutlet, setOutletGrp, setContracts); // Contract and FOC factor of the outlet
        this.mapOfFOCActualPurchase = getFOCActualPurchaseSummary(setContracts, dteGenDate);
        System.debug('Start Merging calcualted FOC & contract summary ');
        
        // Merging calcualted FOC & contract summary
        if (mapRes != null && !mapRes.isEmpty()) {
            for (String strKey : mapRes.keySet()) {
                String[] strTemp = strKey.split('_', 2);
                String strOutletID = strTemp[0];
                String strContractID = strTemp[1];
                System.debug('Key: Outlet: ' + strOutletID + ', Contract: ' + strContractID + ' strKey: ' + strKey);
                CALFOC objCALFOC = mapRes.get(strKey);
                System.debug(objCALFOC);
                //isRecord = FALSE;
				system.debug('@@@objCALFOC.skuFOCs:'+objCALFOC.skuFOCs);
                system.debug('@@@mapResOfftakeSummary:'+mapResOfftakeSummary.get((id) strOutletID));
                if (objCALFOC.skuFOCs != null && !objCALFOC.skuFOCs.isEmpty() && mapResOfftakeSummary.get((id) strOutletID) != NULL) {
                    //System.debug('!objCALFOC.skuFOCs.isEmpty');
                    for (string idString : objCALFOC.skuFOCs.keySet()) {
                        System.debug('id idString : objCALFOC.skuFOCs.keySet : >>>>>> ' + idString);
                        String[] strKey2 = idString.split('_', 2);
                        ID idSKU = (ID) strKey2[1];
                        String strSKU = strKey2[1];
                        
                        CALFOC_SKU objFOCSKU = objCALFOC.skuFOCs.get(idString);
                        objFOCSKU = objFOCSKU.clone();
                        isRecord = FALSE;
                        map<id, list<OFFTAKE_INV_DATE>> mapSKUCount = new map<id, list<OFFTAKE_INV_DATE>>();
                        string strKey_BF = strOutletID + '_' + strContractID  + '_' + string.valueOf(idSKU);
                        
                        if (objFOCSKU.AchievedBtl == null) objFOCSKU.AchievedBtl = 0;
                        objFOCSKU.ActualBtl = 0;
                        //objFOCSKU.ActualCase = 0;
                        ASI_CRM_Calculated_FOC_Line__c focLine = mapRemain.containsKey(strKey_BF) ? mapRemain.get(strKey_BF) : new ASI_CRM_Calculated_FOC_Line__c();
                        objFOCSKU.PRMBroughtForward = focLine.ASI_CRM_Remain__c != null  ? focLine.ASI_CRM_Remain__c : 0;
                        objFOCSKU.WSBroughtForward = focLine.ASI_CRM_Remain_WS__c != null ? focLine.ASI_CRM_Remain_WS__c : 0;
                        objFOCSKU.PRMFOCBtl = 0;
                        objFOCSKU.WSFOCBtl = 0;
                        if (objFOCSKU.PRMFOCFactor == null) objFOCSKU.PRMFOCFactor = 0;
                        if (objFOCSKU.WSFOCFactor == null) objFOCSKU.WSFOCFactor = 0;
                        if (objFOCSKU.PRMRemain == null) objFOCSKU.PRMRemain = 0;
                        if (objFOCSKU.WSRemain == null) objFOCSKU.WSRemain = 0;
                        
                        System.debug('ASI_CRM_MY_CalculatedFOC.genFOC mapResOfftakeSummary: >>>>>> ' + mapResOfftakeSummary);
                        system.debug('ASI_CRM_MY_CalculatedFOC.genFOC mapResOfftakeSummary: strOutletID >>>>>> ' + strOutletID + ' on ' + idString);
                        
                        mapSKUCount = mapResOfftakeSummary.get((id) strOutletID);
                        System.debug('ASI_CRM_MY_CalculatedFOC.genFOC mapSKUCount : >>>>>> ' + mapSKUCount + ' on ' + idString);
                        
                        if (mapSKUCount != null) {
                            isRecord = TRUE;
                            System.debug('Doing SKUID: ' + String.valueOf(idSKU) + ' on ' + idString);
                            if (mapSKUCount.get(idSKU) != null) {
                                Map<String, decimal> mapFOCTemp = new Map<String, decimal>();
                                OFFTAKE_INV_DATE objOfftakeInvDate = new OFFTAKE_INV_DATE();
                                
                                //System.debug('mapSKUCount.get(idSKU) : ' + String.valueOf(mapSKUCount.get(idSKU)));
                                //System.debug('objFOCSKU.ActualBtl : ' + (decimal) mapSKUCount.get(idSKU));
                                objFOCSKU.ActualBtl = 0;
                                for (OFFTAKE_INV_DATE obj : mapSKUCount.get(idSKU)) {
                                    if (obj.InvDate >= objCALFOC.SDate && obj.InvDate <= objCALFOC.EDate) {
                                        objFOCSKU.ActualBtl += (decimal) obj.Bottle;
                                    }
                                }
                                
                                if (objFOCSKU.PRMFOCFactor != null && objFOCSKU.PRMFOCFactor > 0) {
                                    System.debug('objFOCSKU.PRMFOCFactor : ' + objFOCSKU.PRMFOCFactor);
                                    //objFOCSKU.PRMFOCBtl = Math.floor((objFOCSKU.ActualBtl + objFOCSKU.PRMBroughtForward) / objFOCSKU.AchievedBtl * objFOCSKU.PRMFOCFactor);
                                    //objFOCSKU.PRMRemain = ((objFOCSKU.ActualBtl + objFOCSKU.PRMBroughtForward) - (objFOCSKU.PRMFOCBtl / objFOCSKU.PRMFOCFactor * objFOCSKU.AchievedBtl)).setScale(2);
                                    mapFOCTemp = FOCRemain(objFOCSKU.ActualBtl + objFOCSKU.PRMBroughtForward, objFOCSKU.AchievedBtl, objFOCSKU.PRMFOCFactor);
                                    objFOCSKU.PRMFOCBtl = mapFOCTemp.get('FOC');
                                    objFOCSKU.PRMRemain = mapFOCTemp.get('Remain');
                                    System.debug('objFOCSKU.PRMFOCBtl : ' + objFOCSKU.PRMFOCBtl);
                                    System.debug('objFOCSKU.PRMRemain : ' + objFOCSKU.PRMRemain);
                                }
                                if (objFOCSKU.WSFOCFactor != null && objFOCSKU.WSFOCFactor > 0) {
                                    System.debug('objFOCSKU.WSFOCFactor : ' + objFOCSKU.WSFOCFactor);
                                    //objFOCSKU.WSFOCBtl = Math.floor((objFOCSKU.ActualBtl + objFOCSKU.WSBroughtForward) / objFOCSKU.AchievedBtl * objFOCSKU.WSFOCFactor);
                                    //objFOCSKU.WSRemain = ((objFOCSKU.ActualBtl + objFOCSKU.WSBroughtForward) - (objFOCSKU.WSFOCBtl / objFOCSKU.WSFOCFactor * objFOCSKU.AchievedBtl)).setScale(2);
                                    mapFOCTemp = FOCRemain(objFOCSKU.ActualBtl + objFOCSKU.WSBroughtForward, objFOCSKU.AchievedBtl, objFOCSKU.WSFOCFactor);
                                    objFOCSKU.WSFOCBtl = mapFOCTemp.get('FOC');
                                    objFOCSKU.WSRemain = mapFOCTemp.get('Remain');
                                    System.debug('objFOCSKU.WSFOCBtl : ' + objFOCSKU.WSFOCBtl);
                                    System.debug('objFOCSKU.WSRemain : ' + objFOCSKU.WSRemain);
                                }
                            } else {
                                // Bring remaining from previous month to current month
                                if ((objFOCSKU.PRMBroughtForward != null && objFOCSKU.PRMBroughtForward != 0)
                                    || (objFOCSKU.WSBroughtForward != null && objFOCSKU.WSBroughtForward != 0)
                                ) {
                                    objFOCSKU.PRMRemain = objFOCSKU.PRMBroughtForward;
                                    objFOCSKU.WSBroughtForward = objFOCSKU.WSBroughtForward;
                                }
                            }
                        } else {
                            objFOCSKU.ActualBtl = 0;
                            objFOCSKU.PRMFOCBtl = 0;
                            objFOCSKU.PRMRemain = objFOCSKU.PRMBroughtForward;
                            objFOCSKU.WSFOCBtl = 0;
                            objFOCSKU.WSRemain = objFOCSKU.WSBroughtForward;
                        }
                        if (objFOCSKU != null) {
                            objCALFOC.skuFOCs.put(idString, objFOCSKU);
                            //IF(idSKU == 'a7HM00000008ppMMAQ')
                            //    System.debug('objCALFOC.skuFOCs : ' + objCALFOC.skuFOCs.get(idString));
                        }
                    }
                }
                /*if (objCalFOC != null) {
                    mapRes.put(strKey, objCalFOC);
                    System.debug('mapRes : ' + mapRes);
                }*/
                
                if(isRecord == TRUE){
                    mapReturn.put(strKey, objCalFOC);
                }
            }
        }
        system.debug('@@@after mapRemain@@@: '+mapRemain);
        return mapReturn; // mapRes;
    }
	
    
    public map<String, CALFOC> genFOCPayment(set<id> idOutlet, date dteGenDate /*id idOutlet*/) {
        // Declaration
        id idRT_Outlet = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        id idRT_POutlet = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        id idRT_ContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
        set<id> setRTOutlet = new set<id>();
        set<id> setRTContract = new set<id>();
        set<id> setOutletGrp = new set<id>();
        set<id> setContracts = new set<id>();
        mapContracts = new map<id, ASI_TH_CRM_Contract__c>();
        map<id, map<id, list<OFFTAKE_INV_DATE>>> mapResOfftakeSummary = new map<id, map<id, list<OFFTAKE_INV_DATE>>>(); // <OutletID, <SKUID, count>>
        map<string, CALFOC> mapRes = new map<string, CALFOC>(); // <OutletID_ContractID, <SKUID, CALFOC_SKU>>
        map<string, CALFOC> mapOtherRes = new map<string, CALFOC>();
        map<string, CALFOC> mapResPayment = new map<string, CALFOC>(); // <OutletID_ContractID, <SKUID, CALFOC_SKU>>
        map<string, ASI_CRM_Calculated_Payment_Item__c> mapRemain = new map<string, ASI_CRM_Calculated_Payment_Item__c>();
        map<string, CALFOC> mapReturn = new map<string, CALFOC>(); // <OutletID_ContractID, <SKUID, CALFOC_SKU>>
        boolean isRecord = FALSE;
        date conDateStart;
        date conDateEnd;
        // Declaration - End
    
        
        setRTOutlet.add(idRT_Outlet); 
        setRTOutlet.add(idRT_POutlet);
        setRTContract.add(idRT_ContractFinal);
        
        // Set the outlet involve
        for (ASI_CRM_AccountsAdditionalField__c objOutlet : [
            SELECT id, ASI_CRM_CN_Parent_Outlet__c
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE (id IN :idOutlet 
            OR ASI_CRM_CN_Parent_Outlet__c IN :idOutlet)
            AND ASI_CRM_CN_Inactive_Flag__c = false
            AND RecordTypeId IN :setRTOutlet
        ]) {
            setOutletGrp.add(objOutlet.id);
            if(objOutlet.ASI_CRM_CN_Parent_Outlet__c != NULL)
                setOutletGrp.add(objOutlet.ASI_CRM_CN_Parent_Outlet__c);
        }
        
        map<String, date> mapOfftakeDate = getPaymentOfftakeMaxMinDate(setOutletGrp, dteGenDate);
        conDateStart = mapOfftakeDate.get('min');
        conDateEnd = mapOfftakeDate.get('max');
        
        // Get all contract under the outlet group
        for (ASI_TH_CRM_Contract__c objContract : [
            SELECT 
            	id, 
            	name, 
            	ASI_TH_CRM_Start_Date__c, 
            	ASI_TH_CRM_End_Date__c, 
            	ASI_CRM_IsParentContract__c,
            	OwnerId
            FROM ASI_TH_CRM_Contract__c
            WHERE RecordTypeID IN :setRTContract
            AND ASI_TH_CRM_Contract_Status__c = 'Final'
            AND ASI_CRM_Terminate__c = false
            AND ASI_CRM_Obsolete_Version__c = false
            AND (
                (ASI_TH_CRM_Start_Date__c <= :conDateStart AND ASI_TH_CRM_End_Date__c >= :conDateStart)
                OR (ASI_TH_CRM_Start_Date__c <= :conDateEnd AND ASI_TH_CRM_End_Date__c >= :conDateEnd)
                //(ASI_TH_CRM_Start_Date__c >= :conDateStart OR ASI_TH_CRM_End_Date__c >= :conDateEnd)
            )
            AND ASI_CRM_CN_Outlet_WS__c IN :setOutletGrp
        ]) {
            setContracts.add(objContract.id);
            mapContracts.put(objContract.id, objContract);
        }
        
        if(Test.isRunningTest()){
            for(ASI_TH_CRM_Contract__c objContract : [SELECT id FROM ASI_TH_CRM_Contract__c LIMIT 1]){
                setContracts.add(objContract.id);
            }     
        }
        
        system.debug('--------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC setOutletGrp : ' + setOutletGrp);
        system.debug('--------------------------------------ASI_CRM_MY_CalculatedFOC.genFOC setContracts : ' + setContracts);
        
        // Get the figures before merge
        mapResOfftakeSummary = getOfftakeSummary(setOutletGrp, dteGenDate, PAYMENT_STATUS); // Offtake of current month, Date
        mapRemain = genPreviousMthCalculatedFOCPayment(setOutletGrp, setContracts, dteGenDate); // Previous Month Carry Forward //TODO
        mapRes = getContractPaymentSummary(idOutlet, setOutletGrp, setContracts); // Contract and FOC factor of the outlet
        mapOtherRes = getContractOtherPaymentSummary(idOutlet, setOutletGrp, setContracts);
        this.mapOfPaymentActualPurchase = getPaymentActualPurchaseSummary(setContracts, dteGenDate);
        System.debug('Start Merging calcualted FOC & contract summary ');
        // Merging calcualted FOC & contract summary
        
		        
        if (mapRes != null && !mapRes.isEmpty()) {
            for (String strKey : mapRes.keySet()) {
                String[] strTemp = strKey.split('_', 2);
                String strOutletID = strTemp[0];
                String strContractID = strTemp[1];
                System.debug('Key: Outlet: ' + strOutletID + ', Contract: ' + strContractID + ' strKey: ' + strKey);
                CALFOC objCALFOC = mapRes.get(strKey);
                System.debug(objCALFOC);
                //isRecord = FALSE;
               	String voloumeType = objCALFOC.voloumeType;
				
                if (objCALFOC.skuFOCs != null && !objCALFOC.skuFOCs.isEmpty() && mapResOfftakeSummary.get((id) strOutletID) != NULL) {
                    //System.debug('!objCALFOC.skuFOCs.isEmpty');
                    for (string idString : objCALFOC.skuFOCs.keySet()) {
                        System.debug('id idString : objCALFOC.skuFOCs.keySet : >>>>>> ' + idString);
                        String[] strKey2 = idString.split('_', 2);
                        ID idSKU = (ID) strKey2[1];
                        String strSKU = strKey2[1];
                        
                        CALFOC_SKU objFOCSKU = objCALFOC.skuFOCs.get(idString);
                        objFOCSKU = objFOCSKU.clone();
                        isRecord = FALSE;
                        map<id, list<OFFTAKE_INV_DATE>> mapSKUCount = new map<id, list<OFFTAKE_INV_DATE>>();
                        string strKey_BF = strOutletID + '_' + strContractID  + '_' + voloumeType + '_' + string.valueOf(idSKU);
                        
                        if (objFOCSKU.AchievedBtl == null) objFOCSKU.AchievedBtl = 0;
                        objFOCSKU.ActualBtl = 0;
                        ASI_CRM_Calculated_Payment_Item__c paymentLine = mapRemain.containsKey(strKey_BF) ? mapRemain.get(strKey_BF) : new ASI_CRM_Calculated_Payment_Item__c();
                        objFOCSKU.PRMBroughtForward = paymentLine.ASI_CRM_Carried_Forward__c != null  ? paymentLine.ASI_CRM_Carried_Forward__c : 0;
                        objFOCSKU.PRMFOCBtl = 0;
                        objFOCSKU.WSFOCBtl = 0;
                        if (objFOCSKU.PRMFOCFactor == null) objFOCSKU.PRMFOCFactor = 0;
                        if (objFOCSKU.WSFOCFactor == null) objFOCSKU.WSFOCFactor = 0;
                        if (objFOCSKU.PRMRemain == null) objFOCSKU.PRMRemain = 0;
                        if (objFOCSKU.WSRemain == null) objFOCSKU.WSRemain = 0;
                        if (objFOCSKU.CashInc == null) objFOCSKU.CashInc = 0;
                        
                        System.debug('ASI_CRM_MY_CalculatedFOC.genFOC mapResOfftakeSummary: >>>>>> ' + mapResOfftakeSummary);
                        system.debug('ASI_CRM_MY_CalculatedFOC.genFOC mapResOfftakeSummary: strOutletID >>>>>> ' + strOutletID + ' on ' + idString);
                        
                        mapSKUCount = mapResOfftakeSummary.get((id) strOutletID);
                        System.debug('ASI_CRM_MY_CalculatedFOC.genFOC mapSKUCount : >>>>>> ' + mapSKUCount + ' on ' + idString);
                        
                        if (mapSKUCount != null) {
                            isRecord = TRUE;
                            System.debug('Doing SKUID: ' + String.valueOf(idSKU) + ' on ' + idString);
                            if (mapSKUCount.get(idSKU) != null) {
                                Map<String, decimal> mapFOCTemp = new Map<String, decimal>();
                                OFFTAKE_INV_DATE objOfftakeInvDate = new OFFTAKE_INV_DATE();
                                
                                objFOCSKU.ActualBtl = 0;
                                for (OFFTAKE_INV_DATE obj : mapSKUCount.get(idSKU)) {
                                    if (obj.InvDate >= objCALFOC.SDate && obj.InvDate <= objCALFOC.EDate) {
                                        objFOCSKU.ActualBtl += (decimal) obj.Bottle;
                                    }
                                }
                                
                                System.debug('objFOCSKU.CashInc : ' + objFOCSKU.CashInc);
                                mapFOCTemp = FOCRemainPayment(objFOCSKU.ActualBtl + objFOCSKU.PRMBroughtForward, objFOCSKU.AchievedBtl, objFOCSKU.CashInc);
                                //objFOCSKU.CashInc = mapFOCTemp.get('Cash');
                                objFOCSKU.PRMRemain = mapFOCTemp.get('Remain');
                                System.debug('objFOCSKU.CashInc : ' + objFOCSKU.CashInc);
                                System.debug('objFOCSKU.PRMRemain : ' + objFOCSKU.PRMRemain);
                                
                            } else {
                                // Bring remaining from previous month to current month
                                if ((objFOCSKU.PRMBroughtForward != null && objFOCSKU.PRMBroughtForward != 0)
                                    || (objFOCSKU.WSBroughtForward != null && objFOCSKU.WSBroughtForward != 0)
                                ) {
                                    objFOCSKU.PRMRemain = objFOCSKU.PRMBroughtForward;
                                    objFOCSKU.WSBroughtForward = objFOCSKU.WSBroughtForward;
                                }
                            }
                        } else {
                            objFOCSKU.ActualBtl = 0;
                            objFOCSKU.PRMFOCBtl = 0;
                            objFOCSKU.PRMRemain = objFOCSKU.PRMBroughtForward;
                            objFOCSKU.WSFOCBtl = 0;
                            objFOCSKU.WSRemain = objFOCSKU.WSBroughtForward;
                        }
                        if (objFOCSKU != null) {
                            objCALFOC.skuFOCs.put(idString, objFOCSKU);
                            //IF(idSKU == 'a7HM00000008ppMMAQ')
                            //    System.debug('objCALFOC.skuFOCs : ' + objCALFOC.skuFOCs.get(idString));
                        }
                    }
                }
                
                if(isRecord == TRUE){
                    strKey += '_volume';
                    mapReturn.put(strKey, objCalFOC);
                }
            }
        }
        
        
        
        if (mapOtherRes != null && !mapOtherRes.isEmpty()) {
            for (String strKey : mapOtherRes.keySet()) {
                String[] strTemp = strKey.split('_', 2);
                String strOutletID = strTemp[0];
                String strContractID = strTemp[1];
                System.debug('Key: Outlet: ' + strOutletID + ', Contract: ' + strContractID + ' strKey: ' + strKey);
                CALFOC objCALFOC = mapOtherRes.get(strKey);
                System.debug(objCALFOC);
                //isRecord = FALSE;
				
                String voloumeType = objCALFOC.voloumeType;
                if (objCALFOC.skuFOCs != null && !objCALFOC.skuFOCs.isEmpty() && mapResOfftakeSummary.get((id) strOutletID) != NULL) {
                    //System.debug('!objCALFOC.skuFOCs.isEmpty');
                    for (string idString : objCALFOC.skuFOCs.keySet()) {
                        System.debug('id idString : objCALFOC.skuFOCs.keySet : >>>>>> ' + idString);
                        String[] strKey2 = idString.split('_', 2);
                        ID idSKU = (ID) strKey2[1];
                        String strSKU = strKey2[1];
                        
                        CALFOC_SKU objFOCSKU = objCALFOC.skuFOCs.get(idString);
                        objFOCSKU = objFOCSKU.clone();
                        isRecord = FALSE;
                        map<id, list<OFFTAKE_INV_DATE>> mapSKUCount = new map<id, list<OFFTAKE_INV_DATE>>();
                        
                        string strKey_BF = strOutletID + '_' + strContractID  + '_' + voloumeType + '_' + string.valueOf(idSKU);
                        
                        if (objFOCSKU.AchievedBtl == null) objFOCSKU.AchievedBtl = 0;
                        objFOCSKU.ActualBtl = 0;
                        ASI_CRM_Calculated_Payment_Item__c paymentLine = mapRemain.containsKey(strKey_BF) ? mapRemain.get(strKey_BF) : new ASI_CRM_Calculated_Payment_Item__c();
                        objFOCSKU.PRMBroughtForward = paymentLine.ASI_CRM_Carried_Forward__c != null  ? paymentLine.ASI_CRM_Carried_Forward__c : 0;
                        objFOCSKU.PRMFOCBtl = 0;
                        objFOCSKU.WSFOCBtl = 0;
                        if (objFOCSKU.PRMFOCFactor == null) objFOCSKU.PRMFOCFactor = 0;
                        if (objFOCSKU.WSFOCFactor == null) objFOCSKU.WSFOCFactor = 0;
                        if (objFOCSKU.PRMRemain == null) objFOCSKU.PRMRemain = 0;
                        if (objFOCSKU.WSRemain == null) objFOCSKU.WSRemain = 0;
                        if (objFOCSKU.CashInc == null) objFOCSKU.CashInc = 0;
                        
                        
                        mapSKUCount = mapResOfftakeSummary.get((id) strOutletID);
                        System.debug('ASI_CRM_MY_CalculatedFOC.genFOC mapSKUCount : >>>>>> ' + mapSKUCount + ' on ' + idString);
                        
                        if (mapSKUCount != null) {
                            isRecord = TRUE;
                            System.debug('Doing SKUID: ' + String.valueOf(idSKU) + ' on ' + idString);
                            if (mapSKUCount.get(idSKU) != null) {
                                Map<String, decimal> mapFOCTemp = new Map<String, decimal>();
                                OFFTAKE_INV_DATE objOfftakeInvDate = new OFFTAKE_INV_DATE();
                                
                                objFOCSKU.ActualBtl = 0;
                                for (OFFTAKE_INV_DATE obj : mapSKUCount.get(idSKU)) {
                                    if (obj.InvDate >= objCALFOC.SDate && obj.InvDate <= objCALFOC.EDate) {
                                        objFOCSKU.ActualBtl += (decimal) obj.Bottle;
                                    }
                                }
                                
                                mapFOCTemp = FOCRemainPayment(objFOCSKU.ActualBtl + objFOCSKU.PRMBroughtForward, objFOCSKU.AchievedBtl, objFOCSKU.CashInc);
                                // objFOCSKU.CashInc = mapFOCTemp.get('Cash');
                                objFOCSKU.PRMRemain = mapFOCTemp.get('Remain');
                                
                            } else {
                                // Bring remaining from previous month to current month
                                if ((objFOCSKU.PRMBroughtForward != null && objFOCSKU.PRMBroughtForward != 0)
                                    || (objFOCSKU.WSBroughtForward != null && objFOCSKU.WSBroughtForward != 0)
                                ) {
                                    objFOCSKU.PRMRemain = objFOCSKU.PRMBroughtForward;
                                    objFOCSKU.WSBroughtForward = objFOCSKU.WSBroughtForward;
                                }
                            }
                        } else {
                            objFOCSKU.ActualBtl = 0;
                            objFOCSKU.PRMFOCBtl = 0;
                            objFOCSKU.PRMRemain = objFOCSKU.PRMBroughtForward;
                            objFOCSKU.WSFOCBtl = 0;
                            objFOCSKU.WSRemain = objFOCSKU.WSBroughtForward;
                        }
                        if (objFOCSKU != null) {
                            objCALFOC.skuFOCs.put(idString, objFOCSKU);
                            //IF(idSKU == 'a7HM00000008ppMMAQ')
                            //    System.debug('objCALFOC.skuFOCs : ' + objCALFOC.skuFOCs.get(idString));
                        }
                    }
                }
                
                if(isRecord == TRUE){
                    strKey += '_other';
                    mapReturn.put(strKey, objCalFOC);
                }
            }
        }
        
        
        return mapReturn; // mapRes;
    }

    /**
        To calculate FOC and Remain based on the actual and contract setting
    */
    public Map<String, decimal> FOCRemain(decimal dblActualBtl, decimal dblAchieved, decimal dblFOCBtl) {
        
        Map<String, decimal> mapRes = new Map<String, decimal>();
        decimal decFOC = 0;
        decimal decRemain = 0;
        
        
        if (dblAchieved > 0 && dblFOCBtl > 0) {
            if (dblFOCBtl == 0.5) {
                dblAchieved *= 2;
                dblFOCBtl *= 2;
            }
            //if (dblFOCBtl >= 1 && Math.Mod((integer) dblAchieved, (integer) dblFOCBtl) == 0) {
            //    dblAchieved = dblAchieved / dblFOCBtl;
            //    dblFOCBtl = 1;
            //}
            if ((integer) dblActualBtl == 0) {
                decRemain = 0;
                decFOC = 0;
            } else if ((integer) dblActualBtl < 0) {
                decRemain = dblActualBtl;
                decFOC = 0;
            } else {
                Integer dblAchieved_int = (integer) dblAchieved;
                if(dblAchieved_int > 0){
                    //system.debug('@@@(integer) dblActualBtl: '+(integer) dblActualBtl);
                    //system.debug('@@@(integer) dblAchieved: '+(integer) dblAchieved);
                    decRemain = Math.Mod((integer) dblActualBtl, dblAchieved_int);
                    //Decimal factor = dblAchieved/dblFOCBtl;
                    //decRemain = Math.Mod((integer) dblActualBtl, (integer) factor);
                    decFOC = Math.floor((dblActualBtl / dblAchieved) * dblFOCBtl);
                    //decRemain = ((dblActualBtl / dblAchieved) - Math.floor((dblActualBtl / dblAchieved))) * dblAchieved;
                }
            }
        }
        
        
        mapRes.put('Remain', decRemain); // Remain
        mapRes.put('FOC', decFOC); // FOC
        
        return mapRes;
    }
    
    
    public Map<String, decimal> FOCRemainPayment(decimal dblActualBtl, decimal dblAchieved, decimal dblFOCBtl) {
        
        Map<String, decimal> mapRes = new Map<String, decimal>();
        decimal decRemain = 0;
        decimal decCash = 0;
        
        if (dblAchieved > 0 && dblFOCBtl > 0) {
            if (dblFOCBtl == 0.5) {
                dblAchieved *= 2;
                dblFOCBtl *= 2;
            }
            //if (dblFOCBtl >= 1 && Math.Mod((integer) dblAchieved, (integer) dblFOCBtl) == 0) {
            //    dblAchieved = dblAchieved / dblFOCBtl;
            //    dblFOCBtl = 1;
            //}
            if ((integer) dblActualBtl == 0) {
                decRemain = 0;
                decCash = 0;
            } else if ((integer) dblActualBtl < 0) {
                decRemain = dblActualBtl;
                decCash = 0;
            } else {
                Integer dblAchieved_int = (integer) dblAchieved;
                if(dblAchieved_int > 0){
                	decRemain = Math.Mod((integer) dblActualBtl, dblAchieved_int);
                    //decCash = Math.floor(dblActualBtl / dblAchieved) * dblFOCBtl;
                    //decCash = Math.floor(dblActualBtl / dblAchieved) > 0 ? dblFOCBtl : 0;
                    decCash = Math.floor((dblActualBtl / dblAchieved) * dblFOCBtl);    
                }
            }
        }
        
        
        mapRes.put('Remain', decRemain); // Remain
        mapRes.put('Cash', decCash); // FOC
        
        return mapRes;
    }
    
    /*
    public void regenFOCData(){
        Date dteDate = System.today(); //.addDays(-1);
        regenFOCData(dteDate, null); // Generate All Offtake of all outlets
    }
	*/
    
    /*
    public void regenFOCData(Date dteRunDate, set<id> setOutlet){
        
        // Declaration
        id idRT_AOHeader = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
        id idRT_CalFOCHeader = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC__cASI_CRM_MY_Calculated_FOC');
        id idRT_CalFOCItem = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC_Line__cASI_CRM_MY_Calculated_FOC_Item');
        
        //integer intCutOffDay;
        boolean blnTodayCutoff = false;
        
        set<id> setCustomer = new set<id>();
        set<id> setContracts = new set<id>();
        set<id> setRTContract = new set<id>();
        
        date dteStart;
        date dteEnd;
            
        ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstCalculatedFOC = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        list<ASI_CRM_Calculated_FOC__c> lstCalFOC_Header = new list<ASI_CRM_Calculated_FOC__c>();
        list<ASI_CRM_Calculated_FOC_Line__c> lstCalFOC_Item = new list<ASI_CRM_Calculated_FOC_Line__c>();
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstCalFOC_ALL = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        
        map<string, list<ASI_CRM_MY_CalculatedFOC.FOCdata>> mapCalculatedFOC = new map<string, list<ASI_CRM_MY_CalculatedFOC.FOCdata>>();
        map<string, id> mapCalFOCHeader = new map<string, id>();
        
        
        List<ASI_CRM_ActualOfftakeHeader__c> lstAOHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
        // Declaration - End
   
        
        if(Test.isRunningTest()){
			intCutOffDay = System.today().day();
            blnTodayCutoff = true;
        }
		
        // Run 
        if(dteRunDate.Day() >= intCutOffDay) {
            dteStart = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            // To include one more day if this is the start the offtake month
            // To cater the case the the job run at 21:00 on the last cutoff but missed the 2100-2359 offtake
            if (dteRunDate.Day() == intCutOffDay) {
                dteStart.addDays(-1);
            }
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }else{
            dteStart = date.newinstance(dteRunDate.addMonths(-1).Year(), dteRunDate.addMonths(-1).Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
        if (dteRunDate.addDays(1).Day() == intCutoffDay) {
            blnTodayCutoff = true;
        }
        
        system.debug('------------------------ASI_CRM_MY_CalculatedFOC_Regen dteStart : ' + dteStart + ' dteEnd : ' + dteEnd + ', setOutlet: ' + setOutlet);

        lstAOHeader = null;
        if (setOutlet == null) {
            lstAOHeader = [
                SELECT 
                	id, 
                	ASI_CRM_ToOutlet__c,
                	ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c,
                	ASI_CRM_Status__c,
               		ASI_CRM_Calculated_Payment_Status__c,
                	ASI_CRM_OfftakeDate__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE ASI_CRM_OfftakeDate__c >= :dteStart 
                AND ASI_CRM_OfftakeDate__c <= :dteEnd
                AND RecordTypeid = :idRT_AOHeader
                AND ASI_CRM_Status__c = 'Draft'
            ];
        } else {
            lstAOHeader = [
                SELECT 
                	id, 
                	ASI_CRM_ToOutlet__c, 
                	ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, 
                	ASI_CRM_Status__c,
                	ASI_CRM_Calculated_Payment_Status__c,
                	ASI_CRM_OfftakeDate__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE ASI_CRM_OfftakeDate__c >= :dteStart 
                AND ASI_CRM_OfftakeDate__c <= :dteEnd 
                AND RecordTypeid = :idRT_AOHeader
                AND ASI_CRM_Status__c = 'Draft'
                AND ASI_CRM_ToOutlet__c IN :setOutlet
            ];
        }
        for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
            setCustomer.add(i.ASI_CRM_ToOutlet__c);
            i.ASI_CRM_Status__c = 'Final';
        }
        if (setCustomer == null && setOutlet != null) {
            setCustomer = setOutlet;
        }

        system.debug('----------------------------------ASI_CRM_MY_CalculatedFOC_Regen setCustomer : ' + setCustomer);
        
        
        if(setCustomer != NULL && setCustomer.size() > 0) {
            lstCalculatedFOC = clsFOC.genFOC_List(setCustomer, dteEnd);
        }

        for(ASI_CRM_MY_CalculatedFOC.FOCdata j : lstCalculatedFOC){
            lstCalFOC_ALL.add(j);
        }
                
        system.debug('----------------------------------ASI_CRM_MY_CalculatedFOC_Schedule lstCalFOC_ALL : ' + lstCalFOC_ALL);
        
	        
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : lstCalFOC_ALL){
            string strTemp = i.CustomerId + '_' + i.ContractId;
            list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstTemp = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
            
            if(mapCalculatedFOC.get(strTemp) != NULL)
                lstTemp = mapCalculatedFOC.get(strTemp);
                
            lstTemp.add(i);
            
            mapCalculatedFOC.put(strTemp, lstTemp);
        }
        
        
        // Clean the previous generated data
        String strPY = String.valueOf(dteEnd.year());
        String strPM = String.valueOf(dteEnd.month());
        strPM = strPM.length() == 1 ? '0' + strPM : strPM;
        
        list<ASI_CRM_Calculated_FOC__c> lstToDelete = 
            [SELECT id FROM ASI_CRM_Calculated_FOC__c 
             WHERE ASI_CRM_Year__c = :strPY 
             AND ASI_CRM_Month__c = :strPM 
             AND ASI_CRM_Customer__c IN :setCustomer 
             LIMIT 1000];
        
        
        if (lstToDelete != null && lstToDelete.size() > 0) {
            delete lstToDelete;
        }
        // Clean the previous generated data
        
        
        // upsert header
        Set<Id> foc_contract_set = new Set<Id>();
        for(string strKey : mapCalculatedFOC.keySet()){
            string[] strTemp = strKey.split('_', 2);
            string strCustomerId = strTemp[0];
            string strContractId = strTemp[1];
            string strY = String.valueOf(dteEnd.year());
            string strM = String.valueOf(dteEnd.month());
            strM = strM.length() == 1 ? '0' + strM : strM;
            
          
            id idCustomer = (ID) strCustomerId; 
            id idContract = (ID) strContractId;
            foc_contract_set.add(idContract);
            lstCalFOC_Header.add(new ASI_CRM_Calculated_FOC__c(ASI_CRM_Customer__c = idCustomer, 
                                                               ASI_CRM_Contract__c = idContract, 
                                                               ASI_CRM_Year__c = strY, 
                                                               ASI_CRM_Month__c = strM, 
                                                               RecordTypeId = idRT_CalFOCHeader));
        }
        if(lstCalFOC_Header != NULL && lstCalFOC_Header.size() > 0) {
            upsert lstCalFOC_Header;
            system.debug('lstCalFOC_Header count: ' + lstCalFOC_Header.size());
        }
        // upsert header
        
    	
        // upsert item 
        for(ASI_CRM_Calculated_FOC__c i : lstCalFOC_Header){
            string strId = String.valueOf(i.ASI_CRM_Customer__c) + '_' + String.valueOf(i.ASI_CRM_Contract__c);
            mapCalFOCHeader.put(strId, i.id);
        }
        
        
        Map<String, Decimal> mapOfFOCActualPurchase = clsFOC.mapOfFOCActualPurchase;
        Map<String, ASI_CRM_Calculated_FOC_Line__c> mapfocLine = clsFOC.mapRemain;

        system.debug('@@@mapOfFOCActualPurchase@@@: '+mapOfFOCActualPurchase);
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : lstCalFOC_ALL){
            string strId = i.CustomerId + '_' + i.ContractId;
            id idHeader = mapCalFOCHeader.get(strId);
            String key = i.CustomerId + '_' + i.ContractId + '_' +i.OriginalSKUId;
            system.debug('@@@sum_purchasekey@@@: '+key);
            Decimal sum_purchase = mapOfFOCActualPurchase.get(key) != null ? mapOfFOCActualPurchase.get(key) : 0;
            system.debug('@@@sum_purchase@@@: '+sum_purchase);
        	
            Decimal contract_target_achieved_bottle = i.contract_target_achieved_bottle;
            Decimal achievedBtl = i.AchievedBtl;
            Decimal foc_ws_dozen = i.WSFOCFactor > 0 ? ((min_offtake/achievedBtl) * i.WSFOCFactor) : 0;
            Decimal foc_prm_dozen = i.PRMFOCFactor > 0 ? ((min_offtake/achievedBtl) * i.PRMFOCFactor) : 0;
            
            system.debug('@@@contract_target_achieved_bottle@@@: '+contract_target_achieved_bottle);
            
            
            
            if(i.AP_Btl == 0){
                Decimal previous_remain = i.PRMBroughtForward;
                lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                  ASI_CRM_Actual_Purchase__c = i.AP_Btl, 
                                                                  ASI_CRM_FOC__c = 0, 
                                                                  ASI_CRM_FOC_WS__c = 0, 
                                                                  ASI_CRM_Remain__c = previous_remain, 
                                                                  ASI_CRM_Pervious_Remain_PRM__c = 0,
                                                                  ASI_CRM_SKU__c = i.SKUId,
                                                                  ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                  ASI_CRM_SetupCode__c = i.SetupCode,
                                                                  ASI_CRM_JDECOA__c = i.JDECOA, 
                                                                  ASI_CRM_ExcessQuantity__c = false,
                                                                  RecordTypeid = idRT_CalFOCItem));
            }
            else if(contract_target_achieved_bottle == 0){
                
                // not excess
                Decimal actual_purchase = i.AP_Btl;
                Decimal previous_remain = i.PRMBroughtForward;
                Decimal entitled_bottle = actual_purchase + previous_remain;
                Decimal foc_ws = Math.floor(entitled_bottle / min_offtake) * foc_ws_dozen;
                Decimal foc_prm = Math.floor(entitled_bottle / min_offtake) * foc_prm_dozen;
                Decimal current_remain = Math.Mod((integer)entitled_bottle, min_offtake);
                
                
                lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                              ASI_CRM_Actual_Purchase__c = i.AP_Btl,
                                                              ASI_CRM_FOC__c = foc_prm, 
                                                              ASI_CRM_FOC_WS__c = foc_ws, 
                                                              ASI_CRM_Remain__c = current_remain, 
                                                              ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                              ASI_CRM_SKU__c = i.SKUId,
                                                              ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                              ASI_CRM_SetupCode__c = i.SetupCode,
                                                              ASI_CRM_JDECOA__c = i.JDECOA,
                                                              ASI_CRM_ExcessQuantity__c = false,
                                                              RecordTypeid = idRT_CalFOCItem));
            }
            else{
                if(sum_purchase >= contract_target_achieved_bottle){
                    // excess
                    
                    Decimal actual_purchase = i.AP_Btl;
                    Decimal previous_remain = i.PRMBroughtForward;
                    Decimal entitled_bottle = actual_purchase + previous_remain;
                    Decimal foc_ws = Math.floor(entitled_bottle / min_offtake) * foc_ws_dozen;
                    Decimal foc_prm = Math.floor(entitled_bottle / min_offtake) * foc_prm_dozen;
                    Decimal current_remain =  Math.Mod((integer)entitled_bottle, min_offtake);
                    
                    lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                      ASI_CRM_Actual_Purchase__c = i.AP_Btl, 
                                                                      ASI_CRM_FOC__c = foc_prm, 
                                                                      ASI_CRM_FOC_WS__c = foc_ws, 
                                                                      ASI_CRM_Remain__c = current_remain, 
                                                                      ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                                      ASI_CRM_SKU__c = i.SKUId,
                                                                      ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                      ASI_CRM_SetupCode__c = i.SetupCode,
                                                                      ASI_CRM_JDECOA__c = i.JDECOA, 
                                                                      ASI_CRM_ExcessQuantity__c = true,
                                                                      RecordTypeid = idRT_CalFOCItem));
                    
                    
                }
                else{
                    Decimal new_sum_purchase = sum_purchase + i.AP_Btl;
                    if(new_sum_purchase > contract_target_achieved_bottle){
                        
                        // Decimal actual_purchase = i.AP_Btl;
                        Decimal previous_remain = i.PRMBroughtForward;
                        Decimal current_remain = 0;
                        Decimal not_excess_actual_purchase = contract_target_achieved_bottle - sum_purchase;
                        Decimal previous_excess_remain =  Math.Mod((integer)not_excess_actual_purchase, min_offtake);
                    	Decimal actual_purchase = not_excess_actual_purchase - previous_excess_remain;
                        Decimal foc_ws = Math.floor(actual_purchase / min_offtake) * foc_ws_dozen;
                        Decimal foc_prm = Math.floor(actual_purchase / min_offtake) * foc_prm_dozen;
                        
                        // not excess
                        lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                      ASI_CRM_Actual_Purchase__c = actual_purchase, 
                                                                      ASI_CRM_FOC__c = foc_prm, 
                                                                      ASI_CRM_FOC_WS__c = foc_ws, 
                                                                      ASI_CRM_Remain__c = current_remain, 
                                                                      ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                                      ASI_CRM_SKU__c = i.SKUId,
                                                                      ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                      ASI_CRM_SetupCode__c = i.SetupCode,
                                                                      ASI_CRM_JDECOA__c = i.JDECOA,        
                                                                      ASI_CRM_ExcessQuantity__c = false,
                                                                      RecordTypeid = idRT_CalFOCItem));
                        
                        
                        // excess                    
                        Decimal excess_actual_purchase = i.AP_Btl - not_excess_actual_purchase + previous_excess_remain;
                        Decimal current_excess_remain = Math.Mod((integer)excess_actual_purchase, min_offtake);
                        Decimal excess_foc_prm = Math.floor(excess_actual_purchase / min_offtake) * foc_prm_dozen;                                       
                        Decimal excess_foc_ws = Math.floor(excess_actual_purchase / min_offtake) * foc_ws_dozen;
                        
                        lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                      ASI_CRM_Actual_Purchase__c = excess_actual_purchase, 
                                                                      ASI_CRM_FOC__c = excess_foc_prm, 
                                                                      ASI_CRM_FOC_WS__c = excess_foc_ws, 
                                                                      ASI_CRM_Remain__c = current_excess_remain, 
                                                                      ASI_CRM_Pervious_Remain_PRM__c = 0,
                                                                      ASI_CRM_SKU__c = i.SKUId,
                                                                      ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                      ASI_CRM_SetupCode__c = i.SetupCode,
                                                                      ASI_CRM_JDECOA__c = i.JDECOA,      
                                                                      ASI_CRM_ExcessQuantity__c = true,
                                                                      RecordTypeid = idRT_CalFOCItem));
                    }
                    else{
                        
                        // not excess
                        Decimal actual_purchase = i.AP_Btl;
                        Decimal previous_remain = i.PRMBroughtForward;
                        Decimal entitled_bottle = actual_purchase + previous_remain;
                        Decimal foc_ws = Math.floor(entitled_bottle / min_offtake) * foc_ws_dozen;
                        Decimal foc_prm = Math.floor(entitled_bottle / min_offtake) * foc_prm_dozen;
                        Decimal current_remain = Math.Mod((integer)entitled_bottle, min_offtake);
                        
                        
                        lstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                      ASI_CRM_Actual_Purchase__c = i.AP_Btl,
                                                                      ASI_CRM_FOC__c = i.PRMFOCBtl, 
                                                                      ASI_CRM_FOC_WS__c = i.WSFOCBtl, 
                                                                      ASI_CRM_Remain__c = current_remain, 
                                                                      ASI_CRM_Pervious_Remain_PRM__c = previous_remain,
                                                                      ASI_CRM_SKU__c = i.SKUId,
                                                                      ASI_CRM_Original_SKU__c = i.OriginalSKUId,
                                                                      ASI_CRM_SetupCode__c = i.SetupCode,
                                                                      ASI_CRM_JDECOA__c = i.JDECOA,
                                                                      ASI_CRM_ExcessQuantity__c = false,
                                                                      RecordTypeid = idRT_CalFOCItem));
                    }
                }
            }
        }
        
        if(lstCalFOC_Item != NULL && lstCalFOC_Item.size() > 0) {
            upsert lstCalFOC_Item;
            system.debug('lstCalFOC_Item count: ' + lstCalFOC_Item.size());
        }
        
        if (lstAOHeader != null && lstAOHeader.size() > 0) { // && (blnTodayCutoff || blnOverOneBatch)) {
            update lstAOHeader; // to Set the AO status to 'Final' or Mark 'Draft-Processing'
        }
        
        calPreviousFOCRemain(foc_contract_set, dteEnd);
    }
    */
    
    /*
    public void regenCalculatedPaymentData(Date dteRunDate, set<id> setOutlet){
        
        // Declaration
        id idRT_AOHeader = Global_RecordTypeCache.getRTId('ASI_CRM_ActualOfftakeHeader__cASI_CRM_MY_ActualOfftakeHeader');
        id idRT_CalFOCPaymentHeader = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment__cASI_CRM_MY_Calculated_FOC_Payment_Type');
        id idRT_CalFOCPaymentItem = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment_Item__cASI_CRM_Calculated_Payment_Item_Type');
        
        //integer intCutOffDay;
        boolean blnTodayCutoff = false;
        
        set<id> setCustomer = new set<id>();
        set<id> setContracts = new set<id>();
        set<id> setRTContract = new set<id>();
        
        date dteStart;
        date dteEnd;
            
        ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstCalculatedFOCPayment = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        list<ASI_CRM_Calculated_Payment__c> lstCalFOCPayment_Header = new list<ASI_CRM_Calculated_Payment__c>();
        list<ASI_CRM_Calculated_Payment_Item__c> lstCalFOCPayment_Item = new list<ASI_CRM_Calculated_Payment_Item__c>();
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstCalFOCPayment_ALL = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        
        map<string, list<ASI_CRM_MY_CalculatedFOC.FOCdata>> mapCalculatedFOCPayment = new map<string, list<ASI_CRM_MY_CalculatedFOC.FOCdata>>();
        map<string, id> mapCalPaymentHeader = new map<string, id>();
        
        
        List<ASI_CRM_ActualOfftakeHeader__c> lstAOHeader = new List<ASI_CRM_ActualOfftakeHeader__c>();
        List<ASI_TH_CRM_Actual_Offtake__c> lstAO = new List<ASI_TH_CRM_Actual_Offtake__c>();
        
        // Declaration - End
        
        if(Test.isRunningTest()){
			intCutOffDay = System.today().day();
            blnTodayCutoff = true;
        }

        // Run 
        if(dteRunDate.Day() >= intCutOffDay) {
            dteStart = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            // To include one more day if this is the start the offtake month
            // To cater the case the the job run at 21:00 on the last cutoff but missed the 2100-2359 offtake
            if (dteRunDate.Day() == intCutOffDay) {
                dteStart.addDays(-1);
            }
            dteEnd = date.newinstance(dteRunDate.addMonths(1).Year(), dteRunDate.addMonths(1).Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }else{
            dteStart = date.newinstance(dteRunDate.addMonths(-1).Year(), dteRunDate.addMonths(-1).Month(), intCutOffDay);
            dteEnd = date.newinstance(dteRunDate.Year(), dteRunDate.Month(), intCutOffDay);
            dteEnd = dteEnd.addDays(-1);
        }
        if (dteRunDate.addDays(1).Day() == intCutoffDay) {
            blnTodayCutoff = true;
        }
        
        system.debug('------------------------ASI_CRM_MY_CalculatedFOC_Regen dteStart : ' + dteStart + ' dteEnd : ' + dteEnd + ', setOutlet: ' + setOutlet);

        lstAOHeader = null;
        if (setOutlet == null) {
            lstAOHeader = [
                SELECT 
                	id, 
                	ASI_CRM_ToOutlet__c,
                	ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c,
                	ASI_CRM_Status__c,
               		ASI_CRM_Calculated_Payment_Status__c,
                	ASI_CRM_OfftakeDate__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE ASI_CRM_OfftakeDate__c >= :dteStart 
                AND ASI_CRM_OfftakeDate__c <= :dteEnd AND RecordTypeid = :idRT_AOHeader
                AND ASI_CRM_Calculated_Payment_Status__c  = 'Draft'
            ];
        } else {
            lstAOHeader = [
                SELECT 
                	id, 
                	ASI_CRM_ToOutlet__c, 
                	ASI_CRM_ToOutlet__r.ASI_CRM_MY_CustomerCode__c, 
                	ASI_CRM_Status__c,
                	ASI_CRM_Calculated_Payment_Status__c,
                	ASI_CRM_OfftakeDate__c
                FROM ASI_CRM_ActualOfftakeHeader__c
                WHERE ASI_CRM_OfftakeDate__c >= :dteStart 
                AND ASI_CRM_OfftakeDate__c <= :dteEnd AND RecordTypeid = :idRT_AOHeader
                AND ASI_CRM_Calculated_Payment_Status__c  = 'Draft'
                AND ASI_CRM_ToOutlet__c IN :setOutlet
            ];
        }
        for(ASI_CRM_ActualOfftakeHeader__c i : lstAOHeader) {
            setCustomer.add(i.ASI_CRM_ToOutlet__c);
            i.ASI_CRM_Calculated_Payment_Status__c  = 'Final';
        }
        if (setCustomer == null && setOutlet != null) {
            setCustomer = setOutlet;
        }

  
                if(setCustomer != NULL && setCustomer.size() > 0) {
            lstCalculatedFOCPayment = clsFOC.genFOCPayment_List(setCustomer, dteEnd);
        }
        
        for(ASI_CRM_MY_CalculatedFOC.FOCdata j : lstCalculatedFOCPayment){
            lstCalFOCPayment_ALL.add(j);
        }
        
             
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : lstCalFOCPayment_ALL){
            string strTemp = i.CustomerId + '_' + i.ContractId+'_'+i.voloumeType;
            list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstTemp = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
            
            if(mapCalculatedFOCPayment.get(strTemp) != NULL)
                lstTemp = mapCalculatedFOCPayment.get(strTemp);
                
            lstTemp.add(i);
            
            mapCalculatedFOCPayment.put(strTemp, lstTemp);
        }
        
        
        // Clean the previous generated data
        String strPY = String.valueOf(dteEnd.year());
        String strPM = String.valueOf(dteEnd.month());
        strPM = strPM.length() == 1 ? '0' + strPM : strPM;
        system.debug('@@@strPY@@@ '+strPY);
        system.debug('@@@strPM@@@ '+strPM);
        system.debug('@@@setCustomer@@@ '+setCustomer);
        list<ASI_CRM_Calculated_Payment__c> FOCPaymentListToDelete = 
            [SELECT id FROM ASI_CRM_Calculated_Payment__c 
             WHERE ASI_CRM_Year__c = :strPY 
             AND ASI_CRM_Month__c = :strPM 
             AND ASI_CRM_Customer__c IN :setCustomer 
             LIMIT 1000];
        system.debug('@@@FOCPaymentListToDelete@@@ '+FOCPaymentListToDelete);
        if (FOCPaymentListToDelete != null && FOCPaymentListToDelete.size() > 0) {
            delete FOCPaymentListToDelete;
        }
        // Clean the previous generated data
        
        
        // upsert header
        Set<Id> payment_contract_set = new Set<Id>();
        for(string strKey : mapCalculatedFOCPayment.keySet()){
            string[] strTemp = strKey.split('_', 3);
            string strCustomerId = strTemp[0];
            string strContractId = strTemp[1];
            String voloumeType = strTemp[2];
            system.debug('@@@voloumeType@@@ : '+voloumeType);
            string strY = String.valueOf(dteEnd.year());
            string strM = String.valueOf(dteEnd.month());
            strM = strM.length() == 1 ? '0' + strM : strM;
            
            id idCustomer = (ID) strCustomerId;
            id idContract = (ID) strContractId;
            payment_contract_set.add(idContract);
            
            
            lstCalFOCPayment_Header.add(new ASI_CRM_Calculated_Payment__c(ASI_CRM_Customer__c = idCustomer, 
                                                                              ASI_CRM_Contract__c = idContract, 
                                                                              ASI_CRM_Year__c = strY, 
                                                                              ASI_CRM_Month__c = strM, 
                                                                              ASI_CRM_Incentive_Type__c = voloumeType,
                                                                              RecordTypeId = idRT_CalFOCPaymentHeader));
        }
        
        
        if(lstCalFOCPayment_Header != NULL && lstCalFOCPayment_Header.size() > 0) {
            upsert lstCalFOCPayment_Header;
            system.debug('lstCalFOCPayment_Header count: ' + lstCalFOCPayment_Header.size());
        }
        
        
        // upsert item 
        for(ASI_CRM_Calculated_Payment__c i : lstCalFOCPayment_Header){
            string strId = String.valueOf(i.ASI_CRM_Customer__c) + '_' + String.valueOf(i.ASI_CRM_Contract__c)+ '_' + String.valueOf(i.ASI_CRM_Incentive_Type__c);
            mapCalPaymentHeader.put(strId, i.id);
        }
        
		Map<String, Decimal> mapOfPaymentActualPurchase = clsFOC.mapOfPaymentActualPurchase;
        system.debug('@@@mapOfPaymentActualPurchase@@@: '+mapOfPaymentActualPurchase);        
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : lstCalFOCPayment_ALL){
            
            string strId = i.CustomerId + '_' + i.ContractId+'_'+i.voloumeType;
            id idHeader = mapCalPaymentHeader.get(strId);
            
            String key = i.CustomerId + '_' + i.ContractId + '_' + i.voloumeType + '_' + i.OriginalSKUId;
            Decimal sum_purchase = mapOfPaymentActualPurchase.get(key) != null ? mapOfPaymentActualPurchase.get(key) : 0;
            system.debug('@@@sum_purchase@@@: '+sum_purchase);
        	
            Decimal achievedBtl = i.AchievedBtl;
            Decimal cash_dozen = achievedBtl > 0 ? ((min_offtake/achievedBtl) * i.CashInc) : 0;
            system.debug('@@@achievedBtl@@@: '+achievedBtl); 
            system.debug('@@@CashInc@@@: '+i.CashInc);
            system.debug('@@@cash_dozen@@@: '+cash_dozen);
            
	
             if(i.AP_Btl == 0){
                Decimal previous_remain = i.PRMBroughtForward; 
                lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = i.AP_Btl, 
                                                                             ASI_CRM_Cash__c = 0, 
                                                                             ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                             ASI_CRM_SetupCode__c = i.SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = 0, 
                                                                             ASI_CRM_Carried_Forward__c = previous_remain,
                                                                             ASI_CRM_ExcessQuantity__c = false,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));
                 
                 
            }   
            else if(sum_purchase >= achievedBtl){
                // excess 
                Decimal actual_purchase = i.AP_Btl;
                Decimal previous_remain = i.PRMBroughtForward;
                Decimal entitled_bottle = actual_purchase + previous_remain;   
                Decimal cash = Math.floor(entitled_bottle / min_offtake) * cash_dozen;
                cash = cash.setScale(2, System.RoundingMode.FLOOR);
                Decimal current_remain =  Math.Mod((integer)entitled_bottle, min_offtake);
                
                lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = i.AP_Btl, 
                                                                             ASI_CRM_Cash__c = cash, 
                                                                             ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                             ASI_CRM_SetupCode__c = i.SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = previous_remain, 
                                                                             ASI_CRM_Carried_Forward__c = current_remain,
                                                                             ASI_CRM_ExcessQuantity__c = true,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));
            }
            else{
                Decimal new_sum_purchase = sum_purchase + i.AP_Btl;
                if(new_sum_purchase > achievedBtl){
                    
                    //Decimal actual_purchase = i.AP_Btl;
                    Decimal previous_remain = i.PRMBroughtForward;
                    Decimal current_remain = 0;
                    Decimal not_excess_actual_purchase = achievedBtl - sum_purchase;
                    Decimal previous_excess_remain =  Math.Mod((integer)not_excess_actual_purchase, min_offtake);
                    Decimal actual_purchase = not_excess_actual_purchase - previous_excess_remain;
                    Decimal cash = Math.floor(actual_purchase / min_offtake) * cash_dozen;
                    cash = cash.setScale(2, System.RoundingMode.FLOOR);
                    system.debug('@@@cash@@@: '+cash);
                    // not excess
                    
                    lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = actual_purchase, 
                                                                             ASI_CRM_Cash__c = cash, 
                                                                             ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                             ASI_CRM_SetupCode__c = i.SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = previous_remain, 
                                                                             ASI_CRM_Carried_Forward__c = current_remain,
                                                                             ASI_CRM_ExcessQuantity__c = false,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));
                    
                    
                    
                    
                   	Decimal excess_actual_purchase = i.AP_Btl - not_excess_actual_purchase + previous_excess_remain;
                    Decimal current_excess_remain = Math.Mod((integer)excess_actual_purchase, min_offtake);
                    Decimal excess_cash = Math.floor(excess_actual_purchase / min_offtake) * cash_dozen;
                    excess_cash = excess_cash.setScale(2, System.RoundingMode.FLOOR);
                    
                    system.debug('@@@excess_cash@@@: '+excess_cash);
                    
                    // excess 
                    lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = excess_actual_purchase, 
                                                                             ASI_CRM_Cash__c = excess_cash, 
                                                                             ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                             ASI_CRM_SetupCode__c = i.SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = 0, 
                                                                             ASI_CRM_Carried_Forward__c = current_excess_remain,
                                                                             ASI_CRM_ExcessQuantity__c = true,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));
                }
                else{
                    // not excess
                    Decimal actual_purchase = i.AP_Btl;
                    
                    Decimal previous_remain = i.PRMBroughtForward;
                    Decimal entitled_bottle = actual_purchase + previous_remain;
                    Decimal cash = Math.floor(entitled_bottle / min_offtake) * cash_dozen;
                    cash = cash.setScale(2, System.RoundingMode.FLOOR);
                    Decimal current_remain = Math.Mod((integer)entitled_bottle, min_offtake);
                    
                    
                    lstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = i.AP_Btl, 
                                                                             ASI_CRM_Cash__c = cash, 
                                                                             ASI_CRM_SKU__c = i.OriginalSKUId, 
                                                                             ASI_CRM_SetupCode__c = i.SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = previous_remain, 
                                                                             ASI_CRM_Carried_Forward__c = current_remain,
                                                                             ASI_CRM_ExcessQuantity__c = false,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));
                } 
            }
        }
        
        if(lstCalFOCPayment_Item != NULL && lstCalFOCPayment_Item.size() > 0) {
            upsert lstCalFOCPayment_Item;
            system.debug('lstCalFOCPayment_Item count: ' + lstCalFOCPayment_Item.size());
        }
        
        
        if (lstAOHeader != null && lstAOHeader.size() > 0) { // && (blnTodayCutoff || blnOverOneBatch)) {
            update lstAOHeader; // to Set the AO status to 'Final' or Mark 'Draft-Processing'
        }
        
        calPreviousPaymentRemain(payment_contract_set, dteEnd);
    }
    */
    
    public void calPreviousFOCRemain(Set<String> foc_customer_contract_set, date dteEnd){
        list<ASI_CRM_Calculated_FOC__c> notIncludedLstCalFOC_Header = new list<ASI_CRM_Calculated_FOC__c>();
        list<ASI_CRM_Calculated_FOC_Line__c> notIncludedLstCalFOC_Item = new list<ASI_CRM_Calculated_FOC_Line__c>();
        map<string, id> notIncludedMapCalFOCHeader = new map<string, id>();
        id idRT_CalFOCItem = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC_Line__cASI_CRM_MY_Calculated_FOC_Item');
       	id idRT_CalFOCHeader = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC__cASI_CRM_MY_Calculated_FOC');
   		
        
        date dteDate = dteEnd;
        //system.assertEquals(dteDate, dteEnd);
        dteDate = dteDate.addMonths(-1); 
        string strY = String.valueOf(dteDate.year());
        string strM = String.valueOf(dteDate.month());
        strM = strM.length() == 1 ? '0' + strM : strM;
        
        List<ASI_CRM_Calculated_FOC_Line__c> notIncludedFocLine = new List<ASI_CRM_Calculated_FOC_Line__c>();
        notIncludedFocLine = 
             [SELECT 
                id, 
                ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id, 
                ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id,
                ASI_CRM_SKU__c,
                ASI_CRM_Original_SKU__c,
                ASI_CRM_Remain__c,
                ASI_CRM_Remain_WS__c,
                ASI_CRM_FOC__c,
                ASI_CRM_FOC_WS__c,
                ASI_CRM_SetupCode__c,
                ASI_CRM_JDECOA__c,
                ASI_CRM_Pervious_Remain_PRM__c,
                ASI_CRM_ExcessQuantity__c
             FROM ASI_CRM_Calculated_FOC_Line__c
             WHERE ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c = 'Final'
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_CRM_Terminate__c = false
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = false
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Year__c = :strY
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Month__c = :strM
             AND RecordTypeId = :idRT_CalFOCItem
             AND ASI_CRM_Remain__c > 0];
        
        
        Set<String> notIncluded_customer_contract_set = new Set<String>();
        for(ASI_CRM_Calculated_FOC_Line__c focLine : notIncludedFocLine){
            String strOutletID = focLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id;
            String strContractID = focLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id;
            String key = strOutletID+'_'+strContractID;
            if(foc_customer_contract_set.contains(key)){
                
            }
            else{
            	notIncluded_customer_contract_set.add(strOutletID+'_'+strContractID);    
            }
        }
        
        
        //system.assertEquals(dteEnd, dteEnd.addmonths(-1));
        for(String customer_contract : notIncluded_customer_contract_set){
            string[] strTemp = customer_contract.split('_', 2);
            string strCustomerId = strTemp[0];
            string strContractId = strTemp[1];
            string theStrY = String.valueOf(dteEnd.year());
            string theStrM = String.valueOf(dteEnd.month());
            //system.assertEquals(dteEnd, dteEnd.addmonths(-1));
            theStrM = theStrM.length() == 1 ? '0' + theStrM : theStrM;
            
            notIncludedLstCalFOC_Header.add(new ASI_CRM_Calculated_FOC__c(
                ASI_CRM_Customer__c = strCustomerId, 
                ASI_CRM_Contract__c = strContractId, 
                ASI_CRM_Year__c = theStrY, 
                ASI_CRM_Month__c = theStrM, 
                RecordTypeId = idRT_CalFOCHeader));
        }
        
        
        if(notIncludedLstCalFOC_Header != NULL && notIncludedLstCalFOC_Header.size() > 0) {
            upsert notIncludedLstCalFOC_Header;
            system.debug('notIncludedLstCalFOC_Header count: ' + notIncludedLstCalFOC_Header.size());
        }
        // upsert header
        
    	
        // upsert item 
        for(ASI_CRM_Calculated_FOC__c i : notIncludedLstCalFOC_Header){
            string strId = String.valueOf(i.ASI_CRM_Customer__c) + '_' + String.valueOf(i.ASI_CRM_Contract__c);
            notIncludedMapCalFOCHeader.put(strId, i.id);
        }
        
        for(ASI_CRM_Calculated_FOC_Line__c focLine : notIncludedFocLine){
            String OriginalSKUId = focLine.ASI_CRM_Original_SKU__c;
			String SKUId = focLine.ASI_CRM_SKU__c; 
            String SetupCode = focLine.ASI_CRM_SetupCode__c != null ? focLine.ASI_CRM_SetupCode__c : '';
            String JDECOA = focLine.ASI_CRM_JDECOA__c != null ? focLine.ASI_CRM_JDECOA__c : '';
           	Boolean isExcessQuantity = focLine.ASI_CRM_ExcessQuantity__c;
            String strOutletID = focLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id;
            String strContractID = focLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id;
             
            string strId = strOutletID + '_' + strContractID;
            if(foc_customer_contract_set.contains(strId)){
                
            }
            else{
                id idHeader = notIncludedMapCalFOCHeader.get(strId);
                String key = strOutletID + '_' + strContractID + '_' + OriginalSKUId;
                Decimal carried_forward = focLine.ASI_CRM_Remain__c;
                notIncludedLstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                  ASI_CRM_Actual_Purchase__c = 0,
                                                                  ASI_CRM_FOC__c = 0, 
                                                                  ASI_CRM_FOC_WS__c = 0, 
                                                                  ASI_CRM_Remain__c = carried_forward, 
                                                                  ASI_CRM_Pervious_Remain_PRM__c = carried_forward,
                                                                  ASI_CRM_SKU__c = SKUId,
                                                                  ASI_CRM_Original_SKU__c = OriginalSKUId,
                                                                  ASI_CRM_SetupCode__c = SetupCode,
                                                                  ASI_CRM_JDECOA__c = JDECOA,
                                                                  ASI_CRM_ExcessQuantity__c = isExcessQuantity,
                                                                  RecordTypeid = idRT_CalFOCItem));
            }
        }
      
        if(notIncludedLstCalFOC_Item != NULL && notIncludedLstCalFOC_Item.size() > 0) {
            upsert notIncludedLstCalFOC_Item;
            system.debug('notIncludedLstCalFOC_Item count: ' + notIncludedLstCalFOC_Item.size());
        }
    }
    
    
    public void calRegenPreviousFOCRemain(Set<Id> foc_customer, Set<String> foc_customer_contract_set, date dteEnd){
        list<ASI_CRM_Calculated_FOC__c> notIncludedLstCalFOC_Header = new list<ASI_CRM_Calculated_FOC__c>();
        list<ASI_CRM_Calculated_FOC_Line__c> notIncludedLstCalFOC_Item = new list<ASI_CRM_Calculated_FOC_Line__c>();
        map<string, id> notIncludedMapCalFOCHeader = new map<string, id>();
        id idRT_CalFOCItem = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC_Line__cASI_CRM_MY_Calculated_FOC_Item');
       	id idRT_CalFOCHeader = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_FOC__cASI_CRM_MY_Calculated_FOC');
   		
        
        date dteDate = dteEnd;
        //system.assertEquals(dteDate, dteEnd);
        dteDate = dteDate.addMonths(-1); 
        string strY = String.valueOf(dteDate.year());
        string strM = String.valueOf(dteDate.month());
        strM = strM.length() == 1 ? '0' + strM : strM;
        
        List<ASI_CRM_Calculated_FOC_Line__c> notIncludedFocLine = new List<ASI_CRM_Calculated_FOC_Line__c>();
        notIncludedFocLine = 
             [SELECT 
                id, 
                ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id, 
                ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id,
                ASI_CRM_SKU__c,
                ASI_CRM_Original_SKU__c,
                ASI_CRM_Remain__c,
                ASI_CRM_Remain_WS__c,
                ASI_CRM_FOC__c,
                ASI_CRM_FOC_WS__c,
                ASI_CRM_SetupCode__c,
                ASI_CRM_JDECOA__c,
                ASI_CRM_Pervious_Remain_PRM__c,
                ASI_CRM_ExcessQuantity__c
             FROM ASI_CRM_Calculated_FOC_Line__c
             WHERE ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c = 'Final'
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__c IN :foc_customer
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_CRM_Terminate__c = false
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = false
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Year__c = :strY
             AND ASI_CRM_Calculated_FOC__r.ASI_CRM_Month__c = :strM
             AND RecordTypeId = :idRT_CalFOCItem
             AND ASI_CRM_Remain__c > 0];
        
        
        Set<String> notIncluded_customer_contract_set = new Set<String>();
        for(ASI_CRM_Calculated_FOC_Line__c focLine : notIncludedFocLine){
            String strOutletID = focLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id;
            String strContractID = focLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id;
            String key = strOutletID+'_'+strContractID;
            if(foc_customer_contract_set.contains(key)){
                
            }
            else{
            	notIncluded_customer_contract_set.add(strOutletID+'_'+strContractID);    
            }
        }
        
        
        //system.assertEquals(dteEnd, dteEnd.addmonths(-1));
        for(String customer_contract : notIncluded_customer_contract_set){
            string[] strTemp = customer_contract.split('_', 2);
            string strCustomerId = strTemp[0];
            string strContractId = strTemp[1];
            string theStrY = String.valueOf(dteEnd.year());
            string theStrM = String.valueOf(dteEnd.month());
            //system.assertEquals(dteEnd, dteEnd.addmonths(-1));
            theStrM = theStrM.length() == 1 ? '0' + theStrM : theStrM;
            
            notIncludedLstCalFOC_Header.add(new ASI_CRM_Calculated_FOC__c(
                ASI_CRM_Customer__c = strCustomerId, 
                ASI_CRM_Contract__c = strContractId, 
                ASI_CRM_Year__c = theStrY, 
                ASI_CRM_Month__c = theStrM, 
                RecordTypeId = idRT_CalFOCHeader));
        }
        
        
        if(notIncludedLstCalFOC_Header != NULL && notIncludedLstCalFOC_Header.size() > 0) {
            upsert notIncludedLstCalFOC_Header;
            system.debug('notIncludedLstCalFOC_Header count: ' + notIncludedLstCalFOC_Header.size());
        }
        // upsert header
        
    	
        // upsert item 
        for(ASI_CRM_Calculated_FOC__c i : notIncludedLstCalFOC_Header){
            string strId = String.valueOf(i.ASI_CRM_Customer__c) + '_' + String.valueOf(i.ASI_CRM_Contract__c);
            notIncludedMapCalFOCHeader.put(strId, i.id);
        }
        
        for(ASI_CRM_Calculated_FOC_Line__c focLine : notIncludedFocLine){
            String OriginalSKUId = focLine.ASI_CRM_Original_SKU__c;
			String SKUId = focLine.ASI_CRM_SKU__c; 
            String SetupCode = focLine.ASI_CRM_SetupCode__c != null ? focLine.ASI_CRM_SetupCode__c : '';
            String JDECOA = focLine.ASI_CRM_JDECOA__c != null ? focLine.ASI_CRM_JDECOA__c : '';
           	Boolean isExcessQuantity = focLine.ASI_CRM_ExcessQuantity__c;
            String strOutletID = focLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Customer__r.id;
            String strContractID = focLine.ASI_CRM_Calculated_FOC__r.ASI_CRM_Contract__r.id;
             
            string strId = strOutletID + '_' + strContractID;
            if(foc_customer_contract_set.contains(strId)){
                
            }
            else{
                id idHeader = notIncludedMapCalFOCHeader.get(strId);
                String key = strOutletID + '_' + strContractID + '_' + OriginalSKUId;
                Decimal carried_forward = focLine.ASI_CRM_Remain__c;
                notIncludedLstCalFOC_Item.add(new ASI_CRM_Calculated_FOC_Line__c(ASI_CRM_Calculated_FOC__c = idHeader, 
                                                                  ASI_CRM_Actual_Purchase__c = 0,
                                                                  ASI_CRM_FOC__c = 0, 
                                                                  ASI_CRM_FOC_WS__c = 0, 
                                                                  ASI_CRM_Remain__c = carried_forward, 
                                                                  ASI_CRM_Pervious_Remain_PRM__c = carried_forward,
                                                                  ASI_CRM_SKU__c = SKUId,
                                                                  ASI_CRM_Original_SKU__c = OriginalSKUId,
                                                                  ASI_CRM_SetupCode__c = SetupCode,
                                                                  ASI_CRM_JDECOA__c = JDECOA,
                                                                  ASI_CRM_ExcessQuantity__c = isExcessQuantity,
                                                                  RecordTypeid = idRT_CalFOCItem));
            }
        }
      
        if(notIncludedLstCalFOC_Item != NULL && notIncludedLstCalFOC_Item.size() > 0) {
            upsert notIncludedLstCalFOC_Item;
            system.debug('notIncludedLstCalFOC_Item count: ' + notIncludedLstCalFOC_Item.size());
        }
    }
    
        
    public void calPreviousPaymentRemain(Set<String> payment_customer_contract_voloumetype_set, date dteEnd){
        
        list<ASI_CRM_Calculated_Payment__c> previousLstPayment_Header = new list<ASI_CRM_Calculated_Payment__c>();
        list<ASI_CRM_Calculated_Payment_Item__c> previousLstCalFOCPayment_Item = new list<ASI_CRM_Calculated_Payment_Item__c>();
        map<string, id> mapPreviousCalPaymentHeader = new map<string, id>();
        id idRT_CalFOCPaymentItem = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment_Item__cASI_CRM_Calculated_Payment_Item_Type');
        id idRT_CalFOCPaymentHeader = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment__cASI_CRM_MY_Calculated_FOC_Payment_Type');
        
        date dteDate = dteEnd;
        dteDate = dteDate.addMonths(-1); 
        string strY = String.valueOf(dteDate.year());
        string strM = String.valueOf(dteDate.month());
        strM = strM.length() == 1 ? '0' + strM : strM;
        
        List<ASI_CRM_Calculated_Payment_Item__c> notIncludedPaymentLine  = new List<ASI_CRM_Calculated_Payment_Item__c>();

        notIncludedPaymentLine = 
             [SELECT 
                id, 
                ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id, 
                ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id,
                ASI_CRM_SKU__c,
                ASI_CRM_Carried_Forward__c,
                ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c,
                ASI_CRM_ExcessQuantity__c,
                ASI_CRM_SetupCode__c 
             FROM ASI_CRM_Calculated_Payment_Item__c
             WHERE ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c = 'Final'
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_CRM_Terminate__c = false
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = false
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c = :strY
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c = :strM
             AND RecordTypeId = :idRT_CalFOCPaymentItem
             AND ASI_CRM_Carried_Forward__c > 0];

        
        Set<String> notIncluded_customer_contract_set = new Set<String>();
        for(ASI_CRM_Calculated_Payment_Item__c paymentLine : notIncludedPaymentLine){
            String strOutletID = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id;
            String strContractID = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id;
            String incentive_type = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c;
            String key = strOutletID+'_'+strContractID+'_'+incentive_type;
            if(payment_customer_contract_voloumetype_set.contains(key)){
                
            }
            else{
            	notIncluded_customer_contract_set.add(strOutletID+'_'+strContractID+'_'+incentive_type);    
            }
        }
        
		
        for(String customer_contract : notIncluded_customer_contract_set){
            string[] strTemp = customer_contract.split('_', 3);
            string strCustomerId = strTemp[0];
            string strContractId = strTemp[1];
            String voloumeType = strTemp[2];
            string theStrY = String.valueOf(dteEnd.year());
            string theStrM = String.valueOf(dteEnd.month());
            theStrM = theStrM.length() == 1 ? '0' + theStrM : theStrM;
            
            
            previousLstPayment_Header.add(new ASI_CRM_Calculated_Payment__c(ASI_CRM_Customer__c = strCustomerId, 
                                                                              ASI_CRM_Contract__c = strContractId, 
                                                                              ASI_CRM_Year__c = theStrY, 
                                                                              ASI_CRM_Month__c = theStrM, 
                                                                              ASI_CRM_Incentive_Type__c = voloumeType,
                                                                              RecordTypeId = idRT_CalFOCPaymentHeader));
        }
        
        if(previousLstPayment_Header != NULL && previousLstPayment_Header.size() > 0) {
            upsert previousLstPayment_Header;
            system.debug('previousLstPayment_Header count: ' + previousLstPayment_Header.size());
        }
        
        
        for(ASI_CRM_Calculated_Payment__c i : previousLstPayment_Header){
            string strId = String.valueOf(i.ASI_CRM_Customer__c) + '_' + String.valueOf(i.ASI_CRM_Contract__c)+ '_' + String.valueOf(i.ASI_CRM_Incentive_Type__c);
            mapPreviousCalPaymentHeader.put(strId, i.id);
        }
        
        
        for(ASI_CRM_Calculated_Payment_Item__c paymentLine : notIncludedPaymentLine){
            String SKUId = paymentLine.ASI_CRM_SKU__c; 
            String SetupCode = paymentLine.ASI_CRM_SetupCode__c != null ? paymentLine.ASI_CRM_SetupCode__c : '';
           	Boolean isExcessQuantity = paymentLine.ASI_CRM_ExcessQuantity__c;
            String strOutletID = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id;
            String strContractID = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id;
            String incentive_type = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c;
            Decimal carried_forward = paymentLine.ASI_CRM_Carried_Forward__c; 
            
            string strId = strOutletID + '_' + strContractID+'_'+incentive_type;
            if(payment_customer_contract_voloumetype_set.contains(strId)){
                
            }
            else{
            	id idHeader = mapPreviousCalPaymentHeader.get(strId);
                previousLstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = 0, 
                                                                             ASI_CRM_Cash__c = 0, 
                                                                             ASI_CRM_SKU__c = SKUId, 
                                                                             ASI_CRM_SetupCode__c = SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = carried_forward, 
                                                                             ASI_CRM_Carried_Forward__c = carried_forward,
                                                                             ASI_CRM_ExcessQuantity__c = isExcessQuantity,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));   
            }
            
        }
        
        
        if(previousLstCalFOCPayment_Item != NULL && previousLstCalFOCPayment_Item.size() > 0) {
            upsert previousLstCalFOCPayment_Item;
            system.debug('previousLstCalFOCPayment_Item count: ' + previousLstCalFOCPayment_Item.size());
        }
        
    }
    
    public void calRegenPreviousPaymentRemain(Set<Id> payment_customer_set, Set<String> payment_customer_contract_voloumetype_set, date dteEnd){
        
        list<ASI_CRM_Calculated_Payment__c> previousLstPayment_Header = new list<ASI_CRM_Calculated_Payment__c>();
        list<ASI_CRM_Calculated_Payment_Item__c> previousLstCalFOCPayment_Item = new list<ASI_CRM_Calculated_Payment_Item__c>();
        map<string, id> mapPreviousCalPaymentHeader = new map<string, id>();
        id idRT_CalFOCPaymentItem = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment_Item__cASI_CRM_Calculated_Payment_Item_Type');
        id idRT_CalFOCPaymentHeader = Global_RecordTypeCache.getRTId('ASI_CRM_Calculated_Payment__cASI_CRM_MY_Calculated_FOC_Payment_Type');
        
        date dteDate = dteEnd;
        dteDate = dteDate.addMonths(-1); 
        string strY = String.valueOf(dteDate.year());
        string strM = String.valueOf(dteDate.month());
        strM = strM.length() == 1 ? '0' + strM : strM;
        
        List<ASI_CRM_Calculated_Payment_Item__c> notIncludedPaymentLine  = new List<ASI_CRM_Calculated_Payment_Item__c>();

        notIncludedPaymentLine = 
             [SELECT 
                id, 
                ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id, 
                ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id,
                ASI_CRM_SKU__c,
                ASI_CRM_Carried_Forward__c,
                ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c,
                ASI_CRM_ExcessQuantity__c,
                ASI_CRM_SetupCode__c 
             FROM ASI_CRM_Calculated_Payment_Item__c
             WHERE ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c = 'Final'
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__c IN :payment_customer_set
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_CRM_Terminate__c = false
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.ASI_CRM_Obsolete_Version__c = false
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Year__c = :strY
             AND ASI_CRM_Calculated_Payment__r.ASI_CRM_Month__c = :strM
             AND RecordTypeId = :idRT_CalFOCPaymentItem
             AND ASI_CRM_Carried_Forward__c > 0];

        
        Set<String> notIncluded_customer_contract_set = new Set<String>();
        for(ASI_CRM_Calculated_Payment_Item__c paymentLine : notIncludedPaymentLine){
            String strOutletID = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id;
            String strContractID = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id;
            String incentive_type = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c;
            String key = strOutletID+'_'+strContractID+'_'+incentive_type;
            if(payment_customer_contract_voloumetype_set.contains(key)){
                
            }
            else{
            	notIncluded_customer_contract_set.add(strOutletID+'_'+strContractID+'_'+incentive_type);    
            }
        }
        
		
        for(String customer_contract : notIncluded_customer_contract_set){
            string[] strTemp = customer_contract.split('_', 3);
            string strCustomerId = strTemp[0];
            string strContractId = strTemp[1];
            String voloumeType = strTemp[2];
            string theStrY = String.valueOf(dteEnd.year());
            string theStrM = String.valueOf(dteEnd.month());
            theStrM = theStrM.length() == 1 ? '0' + theStrM : theStrM;
            
            
            previousLstPayment_Header.add(new ASI_CRM_Calculated_Payment__c(ASI_CRM_Customer__c = strCustomerId, 
                                                                              ASI_CRM_Contract__c = strContractId, 
                                                                              ASI_CRM_Year__c = theStrY, 
                                                                              ASI_CRM_Month__c = theStrM, 
                                                                              ASI_CRM_Incentive_Type__c = voloumeType,
                                                                              RecordTypeId = idRT_CalFOCPaymentHeader));
        }
        
        if(previousLstPayment_Header != NULL && previousLstPayment_Header.size() > 0) {
            upsert previousLstPayment_Header;
            system.debug('previousLstPayment_Header count: ' + previousLstPayment_Header.size());
        }
        
        
        for(ASI_CRM_Calculated_Payment__c i : previousLstPayment_Header){
            string strId = String.valueOf(i.ASI_CRM_Customer__c) + '_' + String.valueOf(i.ASI_CRM_Contract__c)+ '_' + String.valueOf(i.ASI_CRM_Incentive_Type__c);
            mapPreviousCalPaymentHeader.put(strId, i.id);
        }
        
        
        for(ASI_CRM_Calculated_Payment_Item__c paymentLine : notIncludedPaymentLine){
            String SKUId = paymentLine.ASI_CRM_SKU__c; 
            String SetupCode = paymentLine.ASI_CRM_SetupCode__c != null ? paymentLine.ASI_CRM_SetupCode__c : '';
           	Boolean isExcessQuantity = paymentLine.ASI_CRM_ExcessQuantity__c;
            String strOutletID = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Customer__r.id;
            String strContractID = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Contract__r.id;
            String incentive_type = paymentLine.ASI_CRM_Calculated_Payment__r.ASI_CRM_Incentive_Type__c;
            Decimal carried_forward = paymentLine.ASI_CRM_Carried_Forward__c; 
            
            string strId = strOutletID + '_' + strContractID+'_'+incentive_type;
            if(payment_customer_contract_voloumetype_set.contains(strId)){
                
            }
            else{
            	id idHeader = mapPreviousCalPaymentHeader.get(strId);
                previousLstCalFOCPayment_Item.add(new ASI_CRM_Calculated_Payment_Item__c(ASI_CRM_Calculated_Payment__c = idHeader, 
                                                                             ASI_CRM_Actual_Volume__c = 0, 
                                                                             ASI_CRM_Cash__c = 0, 
                                                                             ASI_CRM_SKU__c = SKUId, 
                                                                             ASI_CRM_SetupCode__c = SetupCode,
                                                                             ASI_CRM_Brought_Forward__c = carried_forward, 
                                                                             ASI_CRM_Carried_Forward__c = carried_forward,
                                                                             ASI_CRM_ExcessQuantity__c = isExcessQuantity,
                                                                             RecordTypeid = idRT_CalFOCPaymentItem));   
            }
            
        }
        
        
        if(previousLstCalFOCPayment_Item != NULL && previousLstCalFOCPayment_Item.size() > 0) {
            upsert previousLstCalFOCPayment_Item;
            system.debug('previousLstCalFOCPayment_Item count: ' + previousLstCalFOCPayment_Item.size());
        }
        
    }
    
}