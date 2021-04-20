/*********************************************************************************
 * Name: ASI_CRM_SG_AutoCreateSKUPrice
 * Description: Auto create SKU Price record with effective date 01/01/2010, Only execute if insert a new SKU Price record
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/02/2017       Laputa:Hugo             Created
 * 2017-11-28       Vincent Lam             [VL 1.0] handle P4.1 price
 * 2018-02-27       Vincent Lam             [VL 2.0] P4.2, mark flag for all offtakes that needs to be recalculate the price
 * 2018-03-12       Vincent Lam             [VL 3.0] P4.2, also handle special incentive price
 * 2020-04-09       Wilken Lee              [WL 4.0] SG Wholesaler Base Price does not need to perform checking to auto create 2000-01-01 back date price in CRM
 *              
*/
public with sharing class ASI_CRM_SG_AutoCreateSKUPrice extends ASI_CRM_SG_TriggerAbstract {

    private final static Map<String, Schema.SObjectField> SKU_PRICE_FIELD_MAP = Schema.SObjectType.ASI_CRM_MY_SKUPriceCost__c.fields.getMap();

    private final static Date INIT_SKU_PRICE_DATE = Date.newInstance(2010, 01, 01);

    //The record type of SKU Price that related to CRM SG
    private static Set<String> SKU_PRICE_RECORD_TYPE_SET = new Set<String> {
        'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',
        'ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',
        'ASI_CRM_SG_IGC',
        'ASI_CRM_SG_CRM_Duty_Per_Bottle',
        'ASI_CRM_SG_CRM_FOB_Per_Bottle',
        'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',
        'ASI_CRM_SG_CRM_Standard_Cost_Per_Bottle'
    /* [VL 1.0] BEGIN */
        ,'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'
        ,'ASI_CRM_SG_Open_Outlet_Price_Per_Bottle'
        ,'ASI_CRM_SG_CRM_Incentive_Price_Per_Bottle'
    /* [VL 1.0] END */
    /* [VL 3.0] BEGIN */
        ,'ASI_CRM_SG_Quarterly_Promo_Price'
    /* [VL 3.0] END */
    };
    
    /* [VL 2.0] BEGIN */
    // map SKU price/cost ID with SKU price/cost
    public Map<string, ASI_CRM_MY_SKUPriceCost__c> map_skuPriceId_skuPrice;
    // map key (SKU id + recordtypeid) with list of SKU price/cost
    public Map<string, List<ASI_CRM_MY_SKUPriceCost__c>> map_skuPriceIdRT_skuPrice;
    // store the closest effective date after the new price
    public Map<string, date> map_skuPrice_dateAfter;
    // store the closest effective date before the new price
    public Map<string, date> map_skuPrice_dateBefore;
    /* [VL 2.0] END */
    

    public ASI_CRM_SG_AutoCreateSKUPrice() {
        super('ASI_CRM_SG_AutoCreateSKUPrice');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = (List<ASI_CRM_MY_SKUPriceCost__c>) sObjList;
        
        /*[WL 4.0] BEGIN*/
        Schema.DescribeSObjectResult skuPriceCostDescribe = Schema.SObjectType.ASI_CRM_MY_SKUPriceCost__c;
        Map<Id,Schema.RecordTypeInfo> rtMapById = skuPriceCostDescribe.getRecordTypeInfosById();

        if (skuPriceList != null){
            Schema.RecordTypeInfo rtById =  rtMapById.get(skuPriceList.get(0).recordTypeID);
            String devName = rtById.getDeveloperName();
            
            if (SKU_PRICE_RECORD_TYPE_SET.contains(devName)){   //[WL 4.0] Only check auto create 2000-01-01 price for selected record type
        /*[WL 4.0] END*/
                //Set<Id> skuIdSet = retrieveSKUIdSet(skuPriceList);
                Set<string> skuPriceSet = retrieveSKUPriceSet(skuPriceList);

                /* [VL 2.0] BEGIN */
                Map<string, ASI_CRM_MY_SKUPriceCost__c> map_skuPriceId_skuPrice = new Map<string, ASI_CRM_MY_SKUPriceCost__c>(skuPriceList);
                map_skuPriceIdRT_skuPrice = getSKUPriceMap(skuPriceList);
                map_skuPrice_dateAfter = new Map<string, date>();
                map_skuPrice_dateBefore = new Map<string, date>();
                /* [VL 2.0] END */
                
                //Set<String> existingSKUPriceSet = retrieveExistingSKUPriceSet(skuIdSet);
                Map<String, ASI_CRM_MY_SKUPriceCost__c> existingSKUPriceMap = retrieveExistingSKUPriceMap(skuPriceSet);

                //List<ASI_CRM_MY_SKUPriceCost__c> insertSKUPriceList = retrieveInsertSKUPriceList(skuPriceList, existingSKUPriceSet); 
                List<ASI_CRM_MY_SKUPriceCost__c> insertSKUPriceList = retrieveInsertSKUPriceList(skuPriceList, existingSKUPriceMap); 

                if(insertSKUPriceList.size() > 0) {
                    insert cloneSKUPriceList(insertSKUPriceList);
                }
                
                /* [VL 2.0] BEGIN */
                List<ASI_TH_CRM_Actual_Offtake__c> list_offtakeToRecalculate = getOfftakeToRecalculate();
                if (list_offtakeToRecalculate.size() > 0){
                    updateOfftakeToRecalculate(list_offtakeToRecalculate);
                }
                /* [VL 2.0] END */
            }
        }
    }

    /*
    //Logic for retrieving sku id from sku price record
    private Set<Id> retrieveSKUIdSet(List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList) {
        Set<Id> skuIdSet = new Set<Id>();

        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceList) {
            skuIdSet.add(skuPrice.ASI_CRM_SKU__c);
        }

        return skuIdSet;
    }
    */

    //Logic for retrieving sku id from sku price record
    private Set<String> retrieveSKUPriceSet(List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList) {
        Set<String> skuIdSet = new Set<String>();

        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceList) {
            skuIdSet.add(skuPrice.ASI_CRM_SKU__c+'_'+skuPrice.recordtypeid);
        }

        return skuIdSet;
    }

    /*
    //Logic for retrieving the sku price records that need to be created with effective date 01/01/2010
    private List<ASI_CRM_MY_SKUPriceCost__c> retrieveInsertSKUPriceList(List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList, Set<String> existingSKUPriceSet) {
        //Structure : Map<Sku Id + Sku Price Record Type, Sku Price record>  
        Map<String, ASI_CRM_MY_SKUPriceCost__c> insertSKUPriceMap = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();

        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceList) {
            String key = skuPrice.ASI_CRM_SKU__c + skuPrice.RecordTypeId;
            //If the sku price with effective date 01/01/2010 does not existing, create new sku price  
            if(!existingSKUPriceSet.contains(key)) {
                //If sku contains multi sku price records with same record type, only retrieve the effective date earlier one 
                if(insertSKUPriceMap.containsKey(key)) {
                    if(skuPrice.ASI_CRM_EffectiveDate__c < insertSKUPriceMap.get(key).ASI_CRM_EffectiveDate__c) {
                        insertSKUPriceMap.put(key, skuPrice);
                    }
                } else {
                    insertSKUPriceMap.put(key, skuPrice);
                }
            }
        }

        return insertSKUPriceMap.values();
    }
    */
    //Logic for retrieving the sku price records that need to be created with effective date 01/01/2010
    private List<ASI_CRM_MY_SKUPriceCost__c> retrieveInsertSKUPriceList(List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList, Map<String, ASI_CRM_MY_SKUPriceCost__c> existingSKUPriceMap) {
        //Structure : Map<Sku Id + Sku Price Record Type, Sku Price record>  
        Map<String, ASI_CRM_MY_SKUPriceCost__c> insertSKUPriceMap = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();

        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceList) {
            if (skuPrice.ASI_CRM_EffectiveDate__c == INIT_SKU_PRICE_DATE) continue;
            String key = skuPrice.ASI_CRM_SKU__c + '' + skuPrice.RecordTypeId;
            //If the sku price does not existing, create new sku price  
            if(!existingSKUPriceMap.containsKey(key)) {
                //If sku contains multi sku price records with same record type, only retrieve the effective date earlier one 
                if(insertSKUPriceMap.containsKey(key)) {
                    if(skuPrice.ASI_CRM_EffectiveDate__c < insertSKUPriceMap.get(key).ASI_CRM_EffectiveDate__c) {
                        insertSKUPriceMap.put(key, skuPrice);
                    }
                } else {
                    insertSKUPriceMap.put(key, skuPrice);
                }
            } else {
                ASI_CRM_MY_SKUPriceCost__c existingSKUprice = existingSKUPriceMap.get(key);
                if (existingSKUprice.ASI_CRM_EffectiveDate__c != INIT_SKU_PRICE_DATE){
                    insertSKUPriceMap.put(key, existingSKUprice);
                }
            }
        }

        return insertSKUPriceMap.values();
    }

    //Logic for cloning the SKU Price records and set those effective date to 01/01/2010
    private List<ASI_CRM_MY_SKUPriceCost__c> cloneSKUPriceList(List<ASI_CRM_MY_SKUPriceCost__c> insertSKUPriceList) {
        List<ASI_CRM_MY_SKUPriceCost__c> clonedSKUPriceList = new List<ASI_CRM_MY_SKUPriceCost__c>();
        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : insertSKUPriceList) {
            ASI_CRM_MY_SKUPriceCost__c clonedSKUPrice = skuPrice.clone(false, true, false, false);
            clonedSKUPrice.ASI_CRM_EffectiveDate__c = INIT_SKU_PRICE_DATE;
            clonedSKUPrice.ASI_CRM_External_ID__c = null;
            clonedSKUPriceList.add(clonedSKUPrice);
        }
        return clonedSKUPriceList;
    }

    /***************
    Data Retrievement Function
    ***************/
    /*
    //Retrieve which type of sku price is existing for each sku
    private Set<String> retrieveExistingSKUPriceSet(Set<Id> skuIdSet) {
        //Structure : Set<Sku Id + Sku Price Record Type>
        Set<String> existingSKUPriceSet = new Set<String>();

        String query = 'SELECT ' + genQueryField(SKU_PRICE_FIELD_MAP) +
                       ', RecordType.DeveloperName ' +
                       'FROM ASI_CRM_MY_SKUPriceCost__c ' +
                       'WHERE RecordType.DeveloperName in : SKU_PRICE_RECORD_TYPE_SET ' + 
                       'AND ASI_CRM_SKU__c in : skuIdSet ' + 
                       'AND ASI_CRM_EffectiveDate__c = :INIT_SKU_PRICE_DATE';

        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : (List<ASI_CRM_MY_SKUPriceCost__c>) Database.query(query)) {
            existingSKUPriceSet.add(skuPrice.ASI_CRM_SKU__c + skuPrice.RecordTypeId);
        }

        return existingSKUPriceSet;
    } 
    */
    //Retrieve which type of sku price is existing for each sku
    private Map<string, ASI_CRM_MY_SKUPriceCost__c> retrieveExistingSKUPriceMap(Set<string> skuIdSet) {
        //Structure : Set<Sku Id + Sku Price Record Type>
        Set<String> existingSKUPriceSet = new Set<String>();
        Map<string, ASI_CRM_MY_SKUPriceCost__c> existingSKUPriceMap = new Map<string, ASI_CRM_MY_SKUPriceCost__c>();

        String query = 'SELECT ' + genQueryField(SKU_PRICE_FIELD_MAP) + ' ' +
                       'FROM ASI_CRM_MY_SKUPriceCost__c ' +
                       'WHERE (' ;
        for (string skuPrice : skuIdSet){
            list<string> skuPriceList = skuPrice.split('_');
            string skuid = skuPriceList[0];
            string recordtypeid = skuPriceList[1];
            query += '(RecordtypeId = \'' + recordtypeid + '\' and ASI_CRM_SKU__c = \'' + skuid + '\') or ' ;
        }
        query = query.subString(0, query.length() - 4);
        query +=       ') ';
        //query +=       'AND ASI_CRM_EffectiveDate__c >= :INIT_SKU_PRICE_DATE ';
        query +=       'order by ASI_CRM_EffectiveDate__c ASC';

        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : (List<ASI_CRM_MY_SKUPriceCost__c>) Database.query(query)) {
            string key = skuPrice.ASI_CRM_SKU__c + '' + skuPrice.RecordTypeId;
            //if (existingSKUPriceMap.containsKey(key)) continue;
            if (existingSKUPriceMap.containsKey(key)) {
                ASI_CRM_MY_SKUPriceCost__c skuPriceTemp = existingSKUPriceMap.get(key);
                if (Math.abs(INIT_SKU_PRICE_DATE.daysBetween(skuPriceTemp.ASI_CRM_EffectiveDate__c)) > Math.abs(INIT_SKU_PRICE_DATE.daysBetween(skuPrice.ASI_CRM_EffectiveDate__c))){
                    existingSKUPriceMap.put(key, skuPrice);
                }
            } else {
                existingSKUPriceMap.put(key, skuPrice);
            }
            /* [VL 2.0] BEGIN */
            if (map_skuPriceIdRT_skuPrice.containsKey(key)){
                for (ASI_CRM_MY_SKUPriceCost__c s : map_skuPriceIdRT_skuPrice.get(key)){
                    // compare closest after date
                    if(s.id != skuPrice.id){
                        if(map_skuPrice_dateAfter.containsKey(s.id)){
                            Date dateAfter = map_skuPrice_dateAfter.get(s.id);
                            if(s.ASI_CRM_EffectiveDate__c < skuPrice.ASI_CRM_EffectiveDate__c && 
                                Math.abs(s.ASI_CRM_EffectiveDate__c.daysBetween(dateAfter)) > Math.abs(s.ASI_CRM_EffectiveDate__c.daysBetween(skuPrice.ASI_CRM_EffectiveDate__c))
                            ){
                                map_skuPrice_dateAfter.put(s.id, skuPrice.ASI_CRM_EffectiveDate__c);
                            }
                        } else {
                            map_skuPrice_dateAfter.put(s.id, skuPrice.ASI_CRM_EffectiveDate__c);
                        }
                        // compare closest before date
                        if(map_skuPrice_dateBefore.containsKey(s.id)){
                            Date dateBefore = map_skuPrice_dateBefore.get(s.id);
                            if(s.ASI_CRM_EffectiveDate__c > skuPrice.ASI_CRM_EffectiveDate__c && 
                                Math.abs(s.ASI_CRM_EffectiveDate__c.daysBetween(dateBefore)) > Math.abs(s.ASI_CRM_EffectiveDate__c.daysBetween(skuPrice.ASI_CRM_EffectiveDate__c))
                            ){
                                map_skuPrice_dateBefore.put(s.id, skuPrice.ASI_CRM_EffectiveDate__c);
                            }
                        } else {
                            map_skuPrice_dateBefore.put(s.id, skuPrice.ASI_CRM_EffectiveDate__c);
                        }
                    }
                }
            }
            /* [VL 2.0] END */
            
        }
        
        /* [VL 2.0] BEGIN */
        // handle scenario that this key is the only one price/cost to this SKU
        for(string key : map_skuPriceIdRT_skuPrice.keySet()){
            for (ASI_CRM_MY_SKUPriceCost__c s : map_skuPriceIdRT_skuPrice.get(key)){
                if(!map_skuPrice_dateBefore.containsKey(s.id)){
                    map_skuPrice_dateBefore.put(s.id, s.ASI_CRM_EffectiveDate__c);
                }
                /*
                if(!map_skuPrice_dateAfter.containsKey(s.id)){
                    map_skuPrice_dateAfter.put(s.id, s.ASI_CRM_EffectiveDate__c + 1);
                }
                */
            }
        }
        /* [VL 2.0] END */
        

        return existingSKUPriceMap;
    } 
    
    /* [VL 2.0] BEGIN */
    private Map<string, List<ASI_CRM_MY_SKUPriceCost__c>> getSKUPriceMap(List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList) {
        Map<string, List<ASI_CRM_MY_SKUPriceCost__c>> map_skuPriceIdRT_skuPrice = new Map<string, List<ASI_CRM_MY_SKUPriceCost__c>>();

        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceList) {
            string key = skuPrice.ASI_CRM_SKU__c+'_'+skuPrice.recordtypeid;
            List<ASI_CRM_MY_SKUPriceCost__c> list_s = map_skuPriceIdRT_skuPrice.containsKey(key) ? map_skuPriceIdRT_skuPrice.get(key) : new List<ASI_CRM_MY_SKUPriceCost__c>();
            list_s.add(skuPrice);
            map_skuPriceIdRT_skuPrice.put(key, list_s);
        }

        return map_skuPriceIdRT_skuPrice;
    }
    
    private List<ASI_TH_CRM_Actual_Offtake__c> getOfftakeToRecalculate() {
        String query = 'SELECT id ' +
                       'FROM ASI_TH_CRM_Actual_Offtake__c ' +
                       'WHERE ' +
                       'Recordtype.developername = \'ASI_CRM_SG_Actual_offtake\' and (';
        for(string key : map_skuPriceIdRT_skuPrice.keySet()){
            for (ASI_CRM_MY_SKUPriceCost__c s : map_skuPriceIdRT_skuPrice.get(key)){
                query += '(';
                query += '(ASI_CRM_SKU__c = \'' + s.ASI_CRM_SKU__c + '\')';
                if(map_skuPrice_dateBefore.containsKey(s.id)){
                    Datetime dateBefore = map_skuPrice_dateBefore.get(s.id);
                    query += ' and (ASI_CRM_Effective_Date_Reference__c >= ' + dateBefore.format('yyyy-MM-dd') + ')';
                }
                if(map_skuPrice_dateAfter.containsKey(s.id)){
                    Datetime dateAfter = map_skuPrice_dateAfter.get(s.id);
                    query += ' and (ASI_CRM_Effective_Date_Reference__c < ' + dateAfter.format('yyyy-MM-dd') + ') ';
                }
                query += ') or ';
            }
        }
        query = query.subString(0, query.length() - 4);
        query +=       ') ';

        system.debug(query);
        
        return (List<ASI_TH_CRM_Actual_Offtake__c>) Database.query(query);
    }
    
    private void updateOfftakeToRecalculate(List<ASI_TH_CRM_Actual_Offtake__c> list_offtakeToRecalculate){
        for (ASI_TH_CRM_Actual_Offtake__c a : list_offtakeToRecalculate){
            a.ASI_CRM_Adjustment__c = true;
        }
        update list_offtakeToRecalculate;
    }
    /* [VL 2.0] END */

    /***************
    Tools Function
    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

}