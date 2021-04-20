/*********************************************************************************
* Name:        ASI_CRM_SG_ActualOfftake_TriggerCls
* Description: 
* Related Test Class: ASI_CRM_SG_TestClass, 
*            ASI_CRM_SG_AdjustOfftakesControllerTest
*            ASI_CRM_SG_GenContractMargin_Test
*            ASI_CRM_SG_MassUploadByBatchCtrlTest
*
* Version History
*  Date             Developer               Comments
*  ---------------  --------------------    --------------------------------------------------------------------------------
*  2016-04-06       Wilken Lee               [WL 1.0] Created
*  2017-02-03       Wilken Lee               [WL 2.0] Fix blind bonus assignment logic
*  2017-05-19       Wilken Lee               [WL 3.0] Update External ID when patched or unique key changed
*  2017-05-30       Wilken Lee               [WL 4.0] Requested by SSBI Team, Retrieve SKU Price/Cost by G/L Date if no contract is linked 
*  2017-11-23       Wilken Lee               [WL 5.0] Do not append Contract ID in external ID as ETL will upsert without Contract as unique key
*  2018-01-03       Wilken Lee               [WL 6.0] Use RTM PRS-WS price for offtake on RTM contracts
*  2018-01-14     Vincent Lam        [VL 1.0] SG P4.1B logic, convert outlet from customer code based on Customer Mapping
*  2018-01-26     Vincent Lam        [VL 2.0] SG P4.2 logic, populate price compensation and wholesaler margin to offtake
*  2018-02-22     Vincent Lam        [VL 3.0] SG P4.1B logic, user prefer to maintain customer mapping by wholesaler record type
*  2018-03-12     Vincent Lam        [VL 4.0] SG P4.2 logic, populate W1 (Open Outlet), W2 (incentive) and W3 (special incentive) price
*  2018-03-13     Vincent Lam        [VL 5.0] SG P4.1B fix soql limit, add one more step before recaculate: check if contract start date is the same
*  2018-04-04     Vincent Lam        [VL 6.0] SG P4.1B, set cutoff date on Jan 2018, to calculate in different price
*  2018-05-03     Vincent Lam        [VL 7.0] CHM118002075 , get RTM price from SKU mapping
*  2018-05-08     Jeffrey               [JC 8.0] SG P4.2, handle offtrade upload
*  2018-05-03       Vincent Lam                 [VL 8.0] SG P4.2, handle offtrade upload
*  2018-10-11       Vincent Lam                 [VL 9.0] CHM118869563, get effective price/cost from G/L Date instead of contract start date
*  2021-01-08     Mark NG            [MN 1.0] remove lpad '0' on sku code
*********************************************************************************/

public without sharing class ASI_CRM_SG_ActualOfftake_TriggerCls{
    public static String className = 'ASI_CRM_SG_ActualOfftake_TriggerCls';
    /* [VL 2.0] BEGIN */
    public static String PRICECOMPENSATION = '_PRICECOMPENSATION';
    public static String WHOLESALERMARGIN = '_WHOLESALERMARGIN';
    /* [VL 2.0] END */
    /* [VL 6.0] BEGIN */
    public static String STRING_BEFORE = 'BEFORE_';
    public static String STRING_AFTER = 'AFTER_';
    /* [VL 6.0] END */
    /* [VL 8.0] BEGIN */
    public static String OFFTAKETYPE_ONTRADE = 'INV';
    public static String OFFTAKETYPE_OFFTRADE = 'Off-Trade';
    public static map<string, string> map_offtradeWholesalerCode = new map<string, string>{
        'CS' => '19855',
        'GH' => '19855'
    };
    public static map<string, string> map_offtradeOutletToWholesaler = new map<string, string>{
        '19855' => '19854'
    };
    /* [VL 8.0] END */
    
    public static void routineBeforeUpsert(list<ASI_TH_CRM_Actual_Offtake__c> trigger_new, Map<id,ASI_TH_CRM_Actual_Offtake__c> oldMap){ 
        if(!ASI_CRM_MY_Function.IsBypassTrigger(className)) {      
            Set<id> skuIDSet = new Set<id>();
            Set<id> sbIDSet = new Set<id>();
            Set<id> validRTSet = new Set<id>();
            Set<id> contractIDSet = new Set<id>();
            /* [VL 1.0] BEGIN */
            map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_wholesalerToCustomerKey_offtakes = new map<string, list<ASI_TH_CRM_Actual_Offtake__c>>();
            set<string> set_SKUcode = new set<string>();
            set<string> set_wineCategoryCode = new set<string>();
            map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_skuCodeLessThan6Digit = new map<string, list<ASI_TH_CRM_Actual_Offtake__c>>();
            /* [VL 1.0] END */
            /* [VL 2.0] BEGIN */
            map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_contractId_offtakes = new map<string, list<ASI_TH_CRM_Actual_Offtake__c>>();
            /* [VL 2.0] END */
            /* [VL 3.0] BEGIN */
            set<string> set_wholesalerCode = new set<string>();
            /* [VL 3.0] END */
            /* [VL 8.0] BEGIN */
            map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_customerToItemKey_offtakes = new map<string, list<ASI_TH_CRM_Actual_Offtake__c>>();
            map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_customerKey_offtakes = new map<string, list<ASI_TH_CRM_Actual_Offtake__c>>();
            map<string, string> map_customerKey_parent = new map<string, string>();
            /* [VL 8.0] END */
            
            validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler'));
            /*[WL 6.0] BEGIN*/
            validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'));
            /*[WL 6.0] BEGIN*/
            validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle'));
            validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle'));
            validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'));
            /*[VL 4.0] BEGIN*/
            validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Open_Outlet_Price_Per_Bottle'));
            validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Incentive_Price_Per_Bottle'));
            validRTSet.add(Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Quarterly_Promo_Price'));
            /*[VL 4.0] BEGIN*/
            
            /* [VL 1.0] BEGIN */
            for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new){
                if(i.recordTypeId ==  Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake')){
                    if(i.ASI_CRM_Mass_Uploaded__c && (
                        oldMap == null
                        // || (oldMap != null && (i.ASI_CRM_FromWS__c != oldMap.get(i.id).ASI_CRM_FromWS__c))
                    )
                    /* [VL 8.0] BEGIN */
                    && i.ASI_CRM_Type_Uploaded__c == OFFTAKETYPE_ONTRADE
                    /* [VL 8.0] BEGIN */
                      ){
                          // prepare for SKU mapping
                          String skuCode = i.ASI_CRM_SKU_Code_Uploaded__c;
                   /*[MN 1.0]        if (skuCode.isNumeric()){
                              i.ASI_CRM_SKU_Code_Uploaded__c = skuCode.leftPad(6,'0');
                          } else */  //Mark NG @IN01341658
                              if (skuCode.length()<6){
                                  set_wineCategoryCode.add(skuCode+'%');
                                  list<ASI_TH_CRM_Actual_Offtake__c> list_i = map_skuCodeLessThan6Digit.containsKey(skuCode) ? map_skuCodeLessThan6Digit.get(skuCode) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                                  list_i.add(i);
                                  map_skuCodeLessThan6Digit.put(skuCode,list_i);
                              }
                          
                          /* [VL 3.0] BEGIN */
                          set_wholesalerCode.add(i.ASI_CRM_Wholesaler_Code_Uploaded__c);
                          /* [VL 3.0] END */
                          set_SKUcode.add(i.ASI_CRM_SKU_Code_Uploaded__c);
                          // prepare for wholesaler and customer mapping
                          string key = i.ASI_CRM_Wholesaler_Code_Uploaded__c + '_' + i.ASI_CRM_Customer_Code_Uploaded__c;
                          list<ASI_TH_CRM_Actual_Offtake__c> list_offtakes = map_wholesalerToCustomerKey_offtakes.containsKey(key) ? map_wholesalerToCustomerKey_offtakes.get(key) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                          list_offtakes.add(i);
                          map_wholesalerToCustomerKey_offtakes.put(key,list_offtakes);
                      }
                    /* [VL 8.0] BEGIN */
                      if(i.ASI_CRM_Mass_Uploaded__c && oldMap == null && i.ASI_CRM_Type_Uploaded__c == OFFTAKETYPE_OFFTRADE){
                          
                          String skuCode = i.ASI_CRM_SKU_Code_Uploaded__c;
 /*  [MN 1.0]         if (skuCode.isNumeric()){
                              i.ASI_CRM_SKU_Code_Uploaded__c = skuCode.leftPad(6,'0');
                          }*/ //Mark NG @IN01341658
                          string key = map_offtradeWholesalerCode.get(i.ASI_CRM_Wholesaler_Code_Uploaded__c) + '_' + i.ASI_CRM_SKU_Code_Uploaded__c;
                          list<ASI_TH_CRM_Actual_Offtake__c> list_offtakes = map_customerToItemKey_offtakes.containsKey(key) ? map_customerToItemKey_offtakes.get(key) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                          list_offtakes.add(i);
                          map_customerToItemKey_offtakes.put(key,list_offtakes);
                          
                          i.ASI_CRM_Customer_Name_Uploaded__c = i.ASI_CRM_Customer_Name_Uploaded__c.toUpperCase();
                          string keyCustomer = i.ASI_CRM_Customer_Name_Uploaded__c + '_' + i.ASI_CRM_Customer_Code_Uploaded__c;
                          list<ASI_TH_CRM_Actual_Offtake__c> list_offtakesC = map_customerKey_offtakes.containsKey(keyCustomer) ? map_customerKey_offtakes.get(keyCustomer) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                          list_offtakesC.add(i);
                          map_customerKey_offtakes.put(keyCustomer,list_offtakesC);
                          
                          map_customerKey_parent.put(keyCustomer, map_offtradeWholesalerCode.get(i.ASI_CRM_Wholesaler_Code_Uploaded__c));
                          
                      }
                    /* [VL 8.0] BEGIN */
                }
            }
            
            if (set_wineCategoryCode.size()>0){
                populateLatestSKUfromWineCategory(set_wineCategoryCode, map_skuCodeLessThan6Digit);
            }
            
            if (map_wholesalerToCustomerKey_offtakes.keySet().size()>0){
                populateOutletAndLatestOfftake(map_wholesalerToCustomerKey_offtakes, set_SKUcode/* [VL 3.0] BEGIN */, set_wholesalerCode/* [VL 3.0] END */);
            }
            /* [VL 1.0] END */
            
            /* [VL 8.0] BEGIN */
            if (map_customerToItemKey_offtakes.keySet().size()>0 || map_customerKey_offtakes.keySet().size()>0 || map_customerKey_parent.keySet().size()>0){
                completeOfftradeConversion(map_customerToItemKey_offtakes, map_customerKey_offtakes, map_customerKey_parent);
            }
            /* [VL 8.0] END */
            
            /* [VL 5.0] BEGIN */
            set<string> set_contractIdtoCheckStartDate = new set<string>();
            map<string, date> map_contract_startDate = new map<string, date>();
            for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new){
                if(i.recordTypeId ==  Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake')
                    /* [VL 8.0] BEGIN */
                    && i.ASI_CRM_Type_Uploaded__c != OFFTAKETYPE_OFFTRADE
                    /* [VL 8.0] END */
                ){
                    if(oldMap != null && i.ASI_CRM_Contract__c != oldMap.get(i.id).ASI_CRM_Contract__c){
                        if(i.ASI_CRM_Contract__c != null){
                            set_contractIdtoCheckStartDate.add(i.ASI_CRM_Contract__c);
                        }
                        if(oldMap.get(i.id).ASI_CRM_Contract__c != null){
                            set_contractIdtoCheckStartDate.add(oldMap.get(i.id).ASI_CRM_Contract__c);
                        }
                    }
                }
            }
            if (set_contractIdtoCheckStartDate.size()>0){
                map_contract_startDate = getContractStartDateMap(set_contractIdtoCheckStartDate);
            }
            /* [VL 5.0] END */
            
            /* [VL 2.0] BEGIN */
            Map<String, String> map_oldSKU_newSKU = getSKUMapping();
            /* [VL 2.0] BEGIN */
            
            for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new){
                //Wilken 20160923 Added Adjustment checkbox for triggering re-calculation of existing offtake
                if(i.recordTypeId ==  Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake')
                    /* [VL 8.0] BEGIN */
                    && i.ASI_CRM_Type_Uploaded__c != OFFTAKETYPE_OFFTRADE
                    /* [VL 8.0] END */
                ){
                    if (oldMap == null || 
                        (oldMap != null && 
                         (i.ASI_CRM_SKU__c != oldMap.get(i.id).ASI_CRM_SKU__c || i.ASI_TH_CRM_Quantity__c != oldMap.get(i.id).ASI_TH_CRM_Quantity__c 
                          || i.ASI_CRM_FromWS__c != oldMap.get(i.id).ASI_CRM_FromWS__c || i.ASI_CRM_SG_Customer__c != oldMap.get(i.id).ASI_CRM_SG_Customer__c
                          || i.ASI_TH_CRM_Offtake_G_L_Date__c != oldMap.get(i.id).ASI_TH_CRM_Offtake_G_L_Date__c
                          || 
                          /* [VL 5.0] BEGIN */
                          /*
                            i.ASI_CRM_Contract__c != oldMap.get(i.id).ASI_CRM_Contract__c 
                            */
                          (i.ASI_CRM_Contract__c != oldMap.get(i.id).ASI_CRM_Contract__c && 
                           (map_contract_startDate.containsKey(i.ASI_CRM_Contract__c) ? map_contract_startDate.get(i.ASI_CRM_Contract__c) : null) != (map_contract_startDate.containsKey(oldMap.get(i.id).ASI_CRM_Contract__c) ? map_contract_startDate.get(oldMap.get(i.id).ASI_CRM_Contract__c) : null)
                          )
                          /* [VL 5.0] END */
                         )
                        ) ||
                        i.ASI_CRM_Adjustment__c == true)
                    {
                        //Prepare a set of SKU which need to retrieve latest PRS-WS Price for calculating Gross Sales on offtake record
                        skuIDSet.add(i.ASI_CRM_SKU__c);
                        /* [VL 7.0] BEGIN */
                        if(map_oldSKU_newSKU.containsKey(i.ASI_CRM_SKU__c)){
                            skuIDSet.add(map_oldSKU_newSKU.get(i.ASI_CRM_SKU__c));
                        }
                        /* [VL 7.0] END */
                        
                        //Prepare a set of Sub-brand for retrieving Wholesaler Blind Bonus Rate
                        sbIDSet.add(i.ASI_TH_CRM_Sub_brand__c);
                        
                        //Prepare a set of Contract for retrieving Contract Start Date for comparing with price & cost effective date
                        contractIDSet.add(i.ASI_CRM_Contract__c);
                        
                        //Wilken 20170519 Keep Adjustment checkbox selected to allow ETL to exclude this patched Offtake record from default mapping logic
                        //Wilken 20180103 ETL doesn't map offtake to contract anymore, no need to have exclusion using this checkbox
                        i.ASI_CRM_Adjustment__c = false;
                        
                        //Construct External ID again after contract change
                        //[WL 3.0 Begin]
                        /*[WL 5.0 BEGIN]*/
                        /*String tempExternalID;
                        if (i.ASI_TH_CRM_Actual_Offtake_External_ID__c != null && i.ASI_TH_CRM_Actual_Offtake_External_ID__c.length() >= 32)
                        tempExternalID = i.ASI_TH_CRM_Actual_Offtake_External_ID__c.substring(0,32);
                        else 
                        tempExternalID = i.ASI_TH_CRM_Actual_Offtake_External_ID__c;

                        if (i.ASI_CRM_Contract__c != null)
                        tempExternalID = tempExternalID + '_' + i.ASI_CRM_Contract__c;

                        i.ASI_TH_CRM_Actual_Offtake_External_ID__c = tempExternalID;
                        system.debug('Offtake External ID After Trigger Code: ' + i.ASI_TH_CRM_Actual_Offtake_External_ID__c);*/
                        /*[WL 5.0 END]*/
                        //[WL 3.0 End]
                    }
                }                
            }
            
            if (skuIDSet.size() > 0 || sbIDSet.size() > 0){
                List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = [select id, ASI_CRM_Price__c, ASI_CRM_Cost__c, ASI_CRM_EffectiveDate__c, ASI_CRM_SKU__c, recordTypeID from ASI_CRM_MY_SKUPriceCost__c 
                                                                 where ASI_CRM_SKU__c = :skuIDSet and recordTypeID = :validRTSet order by ASI_CRM_SKU__c, ASI_CRM_EffectiveDate__c desc];
                
                /* [VL 2.0] BEGIN */
                Map<id,ASI_MFM_SKU_Code__c> mapSKU = new Map<id,ASI_MFM_SKU_Code__c>([
                    select id, ASI_MFM_Sub_brand__c, ASI_CRM_Regular_Size__c, ASI_HK_CRM_Std_Bottle_Size__c, ASI_HK_CRM_Packaging_Size__c 
                    from ASI_MFM_SKU_Code__c where id in :skuIDSet
                ]);
                /* [VL 2.0] END */
                
                List<ASI_TH_CRM_Contract__c> contractList = [select id, ASI_TH_CRM_Start_Date__c, ASI_CRM_Contract_Exist_Before_RTM__c
                                                             /* [VL 2.0] BEGIN */
                                                             , (
                                                                 SELECT 
                                                                 ASI_CRM_SKU__c,
                                                                 ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c,
                                                                 ASI_CRM_Subbrand__c,
                                                                 ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c,
                                                                 ASI_CRM_SG_Consumer_Price_Offer__c,
                                                                 ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c,
                                                                 ASI_CRM_SG_Wholesaler_Margin__c,
                                                                 ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c,
                                                                 ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c,
                                                                 ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c
                                                                 FROM Contract_Target__r 
                                                                 where recordtypeid = :Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target')
                                                                 Order by ASI_CRM_Sequence_No__c asc
                                                             )
                                                             /* [VL 2.0] END */
                                                             from ASI_TH_CRM_Contract__c 
                                                             where id in :contractIDSet];
                
                Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUPrice = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
                /*[WL 6.0] BEGIN*/
                Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKURTMPrice = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
                /*[WL 6.0] END*/
                Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUDuty = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
                Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUFOB = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
                Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUHandling = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
                /*[VL 4.0] BEGIN*/
                Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUW1Price = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
                Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUW2Price = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
                Map<id,List<ASI_CRM_MY_SKUPriceCost__c>> mapSKUW3Price = new Map<id,List<ASI_CRM_MY_SKUPriceCost__c>>();
                /*[VL 4.0] END*/
                Map<id,ASI_TH_CRM_Contract__c> mapContract = new Map<id,ASI_TH_CRM_Contract__c>(contractList);
                
                for (ASI_CRM_MY_SKUPriceCost__c price:skuPriceList){
                    //Add PRS-WS Price into map for calculating Gross Sales
                    if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler')){
                        if (mapSKUPrice.containsKey(price.ASI_CRM_SKU__c))
                            mapSKUPrice.get(price.ASI_CRM_SKU__c).add(price);
                        else 
                            mapSKUPrice.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
                    }
                    /*[WL 6.0] BEGIN*/
                    else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle')){
                        if (mapSKURTMPrice.containsKey(price.ASI_CRM_SKU__c))
                            mapSKURTMPrice.get(price.ASI_CRM_SKU__c).add(price);
                        else 
                            mapSKURTMPrice.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
                    }
                    /*[WL 6.0] END*/
                    else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle')){
                        if (mapSKUDuty.containsKey(price.ASI_CRM_SKU__c))
                            mapSKUDuty.get(price.ASI_CRM_SKU__c).add(price);
                        else 
                            mapSKUDuty.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
                    }
                    else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle')){
                        if (mapSKUFOB.containsKey(price.ASI_CRM_SKU__c))
                            mapSKUFOB.get(price.ASI_CRM_SKU__c).add(price);
                        else 
                            mapSKUFOB.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
                    }
                    else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle')){
                        if (mapSKUHandling.containsKey(price.ASI_CRM_SKU__c))
                            mapSKUHandling.get(price.ASI_CRM_SKU__c).add(price);
                        else 
                            mapSKUHandling.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
                    }
                    /*[VL 4.0] BEGIN*/
                    else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Open_Outlet_Price_Per_Bottle')){
                        if (mapSKUW1Price.containsKey(price.ASI_CRM_SKU__c))
                            mapSKUW1Price.get(price.ASI_CRM_SKU__c).add(price);
                        else 
                            mapSKUW1Price.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
                    }
                    else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Incentive_Price_Per_Bottle')){
                        if (mapSKUW2Price.containsKey(price.ASI_CRM_SKU__c))
                            mapSKUW2Price.get(price.ASI_CRM_SKU__c).add(price);
                        else 
                            mapSKUW2Price.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
                    }
                    else if (price.recordTypeID == Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Quarterly_Promo_Price')){
                        if (mapSKUW3Price.containsKey(price.ASI_CRM_SKU__c))
                            mapSKUW3Price.get(price.ASI_CRM_SKU__c).add(price);
                        else 
                            mapSKUW3Price.put(price.ASI_CRM_SKU__c, new List<ASI_CRM_MY_SKUPriceCost__c>{price});
                    }
                    /*[VL 4.0] END*/
                }
                
                /* [VL 2.0] BEGIN */
                Map<string, Map<string, decimal>> map_contractId_ctMap = getContractTargetMap(contractList);
                /* [VL 2.0] BEGIN */
                
                for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new){
                    //20160804 Wilken: Only calculate Price & Cost if Offtake has Contract linked. Because Price & Cost uses Contract Start Date as Effective Date
                    /*[WL 4.0 Begin]*/
                    //Change all comparison using offtakeEffectiveDate (use Contract Start Date if linked to contract, if not, use Offtake G/L Date), instead of always using Contract Start Date
                    //if (i.ASI_CRM_Contract__c != null && mapContract.get(i.ASI_CRM_Contract__c) != null){
                    if ((i.ASI_CRM_Contract__c != null && mapContract.get(i.ASI_CRM_Contract__c) != null)
                        || i.ASI_TH_CRM_Offtake_G_L_Date__c != null){
                            
                            Date offtakeEffectiveDate = date.newinstance(2000, 1, 1);
                            /* [VL 9.0] BEGIN */
                            /*
                            if (i.ASI_CRM_Contract__c != null && mapContract.get(i.ASI_CRM_Contract__c) != null)
                                offtakeEffectiveDate = mapContract.get(i.ASI_CRM_Contract__c).ASI_TH_CRM_Start_Date__c;
                            else
                            */
                            /* [VL 9.0] END */
                                offtakeEffectiveDate = i.ASI_TH_CRM_Offtake_G_L_Date__c;
                            /*[WL 4.0 End]*/
                            
                            //Calculate Gross Sales
                            ASI_CRM_MY_SKUPriceCost__c lastMatchedPrice;
                            
                            /*[WL 6.0] BEGIN]*/
                            if (mapContract.get(i.ASI_CRM_Contract__c) != null && mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Contract_Exist_Before_RTM__c){
                                //Existing contract before RTM, use old PRS-WS price
                                if (mapSKUPrice.get(i.ASI_CRM_SKU__c) != null){                        
                                    for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUPrice.get(i.ASI_CRM_SKU__c)){
                                        //Retrive the latest SKU Price Cost which the Price Effective Date matches Contract Start Date
                                        system.debug('lastMatchedPrice is null: ' + lastMatchedPrice == null + ' matched price details: ' + lastMatchedPrice + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake: ' + offtakeEffectiveDate);
                                        if ((lastMatchedPrice == null  && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c) 
                                            || (lastMatchedPrice != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                                && price.ASI_CRM_EffectiveDate__c > lastMatchedPrice.ASI_CRM_EffectiveDate__c))
                                            lastMatchedPrice = price;
                                    }                
                                    
                                    if (lastMatchedPrice != null){
                                        system.debug('Offtake Qty: ' + i.ASI_TH_CRM_Quantity__c + ' latest matched SKU Price: ' + lastMatchedPrice.ASI_CRM_Price__c + ' matched Price Effective Date: ' + lastMatchedPrice.ASI_CRM_EffectiveDate__c + ' offtake effective date: ' + offtakeEffectiveDate);
                                        i.ASI_CRM_Gross_Sales__c = i.ASI_TH_CRM_Quantity__c * lastMatchedPrice.ASI_CRM_Price__c;
                                    }
                                }
                            }
                            else if (mapContract.get(i.ASI_CRM_Contract__c) != null && !mapContract.get(i.ASI_CRM_Contract__c).ASI_CRM_Contract_Exist_Before_RTM__c){
                                //RTM Contract, use new RTM PRS-WS price
                                if (mapSKURTMPrice.get(i.ASI_CRM_SKU__c) != null){                        
                                    for (ASI_CRM_MY_SKUPriceCost__c price:mapSKURTMPrice.get(i.ASI_CRM_SKU__c)){
                                        //Retrive the latest SKU Price Cost which the Price Effective Date matches Contract Start Date
                                        system.debug('lastMatchedPrice is null: ' + lastMatchedPrice == null + ' matched price details: ' + lastMatchedPrice + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake: ' + offtakeEffectiveDate);
                                        if ((lastMatchedPrice == null  && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c) 
                                            || (lastMatchedPrice != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                                && price.ASI_CRM_EffectiveDate__c > lastMatchedPrice.ASI_CRM_EffectiveDate__c))
                                            lastMatchedPrice = price;
                                    }                
                                    
                                    /* [VL 7.0] BEGIN */
                                    /*
                                    if (lastMatchedPrice != null){
                                    system.debug('Offtake Qty: ' + i.ASI_TH_CRM_Quantity__c + ' latest matched SKU Price: ' + lastMatchedPrice.ASI_CRM_Price__c + ' matched Price Effective Date: ' + lastMatchedPrice.ASI_CRM_EffectiveDate__c + ' offtake effective date: ' + offtakeEffectiveDate);
                                    i.ASI_CRM_Gross_Sales__c = i.ASI_TH_CRM_Quantity__c * lastMatchedPrice.ASI_CRM_Price__c;
                                    }
                                    */
                                    /* [VL 7.0] END */
                                }
                                /* [VL 7.0] BEGIN */
                                else if(map_oldSKU_newSKU.containsKey(i.ASI_CRM_SKU__c)){
                                    string skuL = map_oldSKU_newSKU.get(i.ASI_CRM_SKU__c);
                                    if (mapSKURTMPrice.get(skuL) != null){
                                        for (ASI_CRM_MY_SKUPriceCost__c price:mapSKURTMPrice.get(skuL)){
                                            //Retrive the latest SKU Price Cost which the Price Effective Date matches Contract Start Date
                                            system.debug('lastMatchedPrice is null: ' + lastMatchedPrice == null + ' matched price details: ' + lastMatchedPrice + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake: ' + offtakeEffectiveDate);
                                            if ((lastMatchedPrice == null  && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c) 
                                                || (lastMatchedPrice != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                                    && price.ASI_CRM_EffectiveDate__c > lastMatchedPrice.ASI_CRM_EffectiveDate__c))
                                                lastMatchedPrice = price;
                                        }
                                    }
                                }
                                if (lastMatchedPrice != null){
                                    system.debug('Offtake Qty: ' + i.ASI_TH_CRM_Quantity__c + ' latest matched SKU Price: ' + lastMatchedPrice.ASI_CRM_Price__c + ' matched Price Effective Date: ' + lastMatchedPrice.ASI_CRM_EffectiveDate__c + ' offtake effective date: ' + offtakeEffectiveDate);
                                    i.ASI_CRM_Gross_Sales__c = i.ASI_TH_CRM_Quantity__c * lastMatchedPrice.ASI_CRM_Price__c;
                                }
                                /* [VL 7.0] END */
                            }
                            /*[WL 6.0] END]*/
                            
                            //Retrieve latest Duty Cost
                            ASI_CRM_MY_SKUPriceCost__c lastMatchedDuty;
                            
                            if (mapSKUDuty.get(i.ASI_CRM_SKU__c) != null){                      
                                for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUDuty.get(i.ASI_CRM_SKU__c)){
                                    //Retrive the latest SKU Duty Cost which the Cost Effective Date matches Offtake GL Date
                                    system.debug('lastMatchedDuty is null: ' + lastMatchedDuty == null + ' matched cost details: ' + lastMatchedDuty + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake effective date: ' + offtakeEffectiveDate);
                                    if ((lastMatchedDuty == null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c)
                                        || (lastMatchedDuty != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                            && price.ASI_CRM_EffectiveDate__c > lastMatchedDuty.ASI_CRM_EffectiveDate__c))
                                        lastMatchedDuty = price;
                                }
                            }
                            
                            //Retrieve latest FOB Cost
                            ASI_CRM_MY_SKUPriceCost__c lastMatchedFOB;
                            
                            if (mapSKUFOB.get(i.ASI_CRM_SKU__c) != null){
                                for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUFOB.get(i.ASI_CRM_SKU__c)){
                                    //Retrive the latest SKU FOB Cost which the Cost Effective Date matches Offtake GL Date
                                    system.debug('lastMatchedFOB is null: ' + lastMatchedFOB == null + ' matched cost details: ' + lastMatchedFOB + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake effective Date: ' + offtakeEffectiveDate);
                                    if ((lastMatchedFOB == null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c)
                                        || (lastMatchedFOB != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                            && price.ASI_CRM_EffectiveDate__c > lastMatchedFOB.ASI_CRM_EffectiveDate__c))
                                        lastMatchedFOB = price;
                                }
                            }
                            
                            //Retrieve latest Handling Cost
                            ASI_CRM_MY_SKUPriceCost__c lastMatchedHandling;
                            
                            if (mapSKUHandling.get(i.ASI_CRM_SKU__c) != null){
                                for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUHandling.get(i.ASI_CRM_SKU__c)){
                                    //Retrive the latest SKU Handling Cost which the Cost Effective Date matches Offtake GL Date
                                    system.debug('lastMatchedHandling is null: ' + lastMatchedHandling == null + ' matched cost details: ' + lastMatchedHandling + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake effective Date: ' + offtakeEffectiveDate);
                                    if ((lastMatchedHandling == null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c)
                                        || (lastMatchedHandling != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                            && price.ASI_CRM_EffectiveDate__c > lastMatchedHandling.ASI_CRM_EffectiveDate__c))
                                        lastMatchedHandling = price;
                                }
                            }
                            
                            /* [VL 4.0] BEGIN */
                            //Retrieve latest W1 Cost
                            ASI_CRM_MY_SKUPriceCost__c lastMatchedW1;

                            if (mapSKUW1Price.get(i.ASI_CRM_SKU__c) != null){
                                for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUW1Price.get(i.ASI_CRM_SKU__c)){
                                    //Retrive the latest SKU W1 Cost which the Cost Effective Date matches Offtake GL Date
                                    system.debug('lastMatchedW1 is null: ' + lastMatchedW1 == null + ' matched cost details: ' + lastMatchedW1 + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake effective Date: ' + offtakeEffectiveDate);
                                    if ((lastMatchedW1 == null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c)
                                        || (lastMatchedW1 != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                            && price.ASI_CRM_EffectiveDate__c > lastMatchedW1.ASI_CRM_EffectiveDate__c))
                                        lastMatchedW1 = price;
                                }
                            }

                            //Retrieve latest W2 Cost
                            ASI_CRM_MY_SKUPriceCost__c lastMatchedW2;

                            if (mapSKUW2Price.get(i.ASI_CRM_SKU__c) != null){
                                for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUW2Price.get(i.ASI_CRM_SKU__c)){
                                //Retrive the latest SKU W1 Cost which the Cost Effective Date matches Offtake GL Date
                                system.debug('lastMatchedW2 is null: ' + lastMatchedW2 == null + ' matched cost details: ' + lastMatchedW2 + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake effective Date: ' + offtakeEffectiveDate);
                                if ((lastMatchedW2 == null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c)
                                    || (lastMatchedW2 != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                        && price.ASI_CRM_EffectiveDate__c > lastMatchedW2.ASI_CRM_EffectiveDate__c))
                                    lastMatchedW2 = price;
                                }
                            }

                            //Retrieve latest W3 Cost
                            ASI_CRM_MY_SKUPriceCost__c lastMatchedW3;

                            if (mapSKUW3Price.get(i.ASI_CRM_SKU__c) != null){
                                for (ASI_CRM_MY_SKUPriceCost__c price:mapSKUW3Price.get(i.ASI_CRM_SKU__c)){
                                //Retrive the latest SKU W3 Cost which the Cost Effective Date matches Offtake GL Date
                                system.debug('lastMatchedW3 is null: ' + lastMatchedW3 == null + ' matched cost details: ' + lastMatchedW3 + ' current effective date: ' + price.ASI_CRM_EffectiveDate__c + ' offtake effective Date: ' + offtakeEffectiveDate);
                                if ((lastMatchedW3 == null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c)
                                    || (lastMatchedW3 != null && offtakeEffectiveDate >= price.ASI_CRM_EffectiveDate__c 
                                        && price.ASI_CRM_EffectiveDate__c > lastMatchedW3.ASI_CRM_EffectiveDate__c))
                                    lastMatchedW3 = price;
                                }
                            }
                            /* [VL 4.0] END */
                            
                            Decimal totalCOSperBottle = 0;
                            if (lastMatchedDuty != null){
                                i.ASI_CRM_Duty_Cost__c = lastMatchedDuty.ASI_CRM_Cost__c;
                                totalCOSperBottle += lastMatchedDuty.ASI_CRM_Cost__c;
                                system.debug('Duty: ' +  lastMatchedDuty.ASI_CRM_Cost__c);
                            }
                            
                            if (lastMatchedFOB != null){
                                i.ASI_CRM_FOB_Cost__c = lastMatchedFOB.ASI_CRM_Cost__c;
                                totalCOSperBottle += lastMatchedFOB.ASI_CRM_Cost__c;
                                system.debug('FOB: ' + lastMatchedFOB.ASI_CRM_Cost__c);
                            }
                            
                            if (lastMatchedHandling != null){
                                i.ASI_CRM_Handling_Cost__c = lastMatchedHandling.ASI_CRM_Cost__c;
                                totalCOSperBottle += lastMatchedHandling.ASI_CRM_Cost__c;
                                system.debug('Handling: ' + lastMatchedHandling.ASI_CRM_Cost__c);
                            }
                            
                            if (lastMatchedPrice != null){
                                totalCOSperBottle += lastMatchedPrice.ASI_CRM_Price__c * i.ASI_CRM_Distribution_Rate__c / 100;
                                system.debug('Dist Rate: ' + i.ASI_CRM_Distribution_Rate__c + ' Price: ' + lastMatchedPrice.ASI_CRM_Price__c);
                            }
                            
                            /* [VL 4.0] BEGIN */
                            if (lastMatchedW1 != null){
                                i.ASI_CRM_Open_Outlet_Price__c = lastMatchedW1.ASI_CRM_Price__c;
                                system.debug('W1: ' +  lastMatchedW1.ASI_CRM_Price__c);
                            }

                            if (lastMatchedW2 != null){
                                i.ASI_CRM_Incentive_Price__c = lastMatchedW2.ASI_CRM_Price__c;
                                system.debug('W2: ' +  lastMatchedW2.ASI_CRM_Price__c);
                            }

                            if (lastMatchedW3 != null){
                                i.ASI_CRM_Special_Incentive_Price__c = lastMatchedW3.ASI_CRM_Price__c;
                                system.debug('W3: ' +  lastMatchedW3.ASI_CRM_Price__c);
                            } else {
                                i.ASI_CRM_Special_Incentive_Price__c = i.ASI_CRM_Incentive_Price__c;
                            }
                            /* [VL 4.0] END */
                            
                            system.debug('Total Cost of Sales per Bottle: ' + totalCOSperBottle);
                            
                            i.ASI_CRM_Cost_of_Sales__c = totalCOSperBottle * i.ASI_TH_CRM_Quantity__c;
                            
                            /* [VL 2.0] BEGIN */
                            String lastestSkuId = map_oldSKU_newSKU.containsKey(i.ASI_CRM_SKU__c) ? map_oldSKU_newSKU.get(i.ASI_CRM_SKU__c) : i.ASI_CRM_SKU__c;
                            String subBrandId = i.ASI_TH_CRM_Sub_brand__c;
                            String key_sku_ws = lastestSkuId + WHOLESALERMARGIN;
                            String key_subBrand_ws = subBrandId + WHOLESALERMARGIN;
                            String key_sku_pc = lastestSkuId + PRICECOMPENSATION;
                            String key_subBrand_pc = subBrandId + PRICECOMPENSATION;
                            
                            /* [VL 6.0] BEGIN */
                            /*
                            if(map_contractId_ctMap.containsKey(i.ASI_CRM_Contract__c)){
                            Map<string, decimal> map_ct = map_contractId_ctMap.get(i.ASI_CRM_Contract__c);
                            if(map_ct.containsKey(key_sku_ws)){
                            i.ASI_CRM_Wholesaler_Margin__c = map_ct.get(key_sku_ws);
                            } else
                            if(map_ct.containsKey(key_subBrand_ws) && mapSKU.get(i.ASI_CRM_SKU__c).ASI_CRM_Regular_Size__c){
                            i.ASI_CRM_Wholesaler_Margin__c = map_ct.get(key_subBrand_ws);
                            } else {
                            i.ASI_CRM_Wholesaler_Margin__c = 0;
                            }
                            if(map_ct.containsKey(key_sku_pc)){
                            i.ASI_CRM_Price_Compensation__c = map_ct.get(key_sku_pc);
                            } else
                            if(map_ct.containsKey(key_subBrand_pc) && mapSKU.get(i.ASI_CRM_SKU__c).ASI_CRM_Regular_Size__c){
                            i.ASI_CRM_Price_Compensation__c = map_ct.get(key_subBrand_pc);
                            } else {
                            i.ASI_CRM_Price_Compensation__c = 0;
                            }
                            }
                            */
                            Date cutoffDate = Date.newInstance(2018, 1, 1);
                            String BEFOREorAFTER = i.ASI_TH_CRM_Offtake_G_L_Date__c < cutoffDate ? STRING_BEFORE : STRING_AFTER;
                            if(map_contractId_ctMap.containsKey(i.ASI_CRM_Contract__c)){
                                Map<string, decimal> map_ct = map_contractId_ctMap.get(i.ASI_CRM_Contract__c);
                                if(map_ct.containsKey(BEFOREorAFTER + key_sku_ws)){
                                    i.ASI_CRM_Wholesaler_Margin__c = map_ct.get(BEFOREorAFTER + key_sku_ws);
                                } else
                                    if(map_ct.containsKey(BEFOREorAFTER + key_subBrand_ws) && mapSKU.get(i.ASI_CRM_SKU__c).ASI_CRM_Regular_Size__c){
                                        i.ASI_CRM_Wholesaler_Margin__c = map_ct.get(BEFOREorAFTER + key_subBrand_ws);
                                    } else {
                                        i.ASI_CRM_Wholesaler_Margin__c = 0;
                                    }
                                if(map_ct.containsKey(BEFOREorAFTER + key_sku_pc)){
                                    i.ASI_CRM_Price_Compensation__c = map_ct.get(BEFOREorAFTER + key_sku_pc);
                                } else
                                    if(map_ct.containsKey(BEFOREorAFTER + key_subBrand_pc) && mapSKU.get(i.ASI_CRM_SKU__c).ASI_CRM_Regular_Size__c){
                                        i.ASI_CRM_Price_Compensation__c = map_ct.get(BEFOREorAFTER + key_subBrand_pc);
                                    } else {
                                        i.ASI_CRM_Price_Compensation__c = 0;
                                    }
                            }
                            /* [VL 6.0] END */
                            
                            if(i.ASI_CRM_Contract__c == null){
                                i.ASI_CRM_Wholesaler_Margin__c = 0;
                                i.ASI_CRM_Price_Compensation__c = 0;
                            }
                            /* [VL 2.0] END */
                        }
                    /* [VL 2.0] BEGIN */
                    // for those offtake without a contract or no G/L date, put all price/cost to null
                    else {
                        i.ASI_CRM_Gross_Sales__c = 0;
                        i.ASI_CRM_Duty_Cost__c = 0;
                        i.ASI_CRM_FOB_Cost__c = 0;
                        i.ASI_CRM_Handling_Cost__c = 0;
                        i.ASI_CRM_Cost_of_Sales__c = 0;
                        i.ASI_CRM_Wholesaler_Margin__c = 0;
                        i.ASI_CRM_Price_Compensation__c = 0;
                    }
                    /* [VL 2.0] END */
                }
                
                //Start retriving Wholesaler Blind Bonus Rate
                List<ASI_CRM_Blind_Bonus__c> bbList = [select id, ASI_CRM_Customer__c, ASI_CRM_Effective_Date__c, ASI_CRM_Sub_brand__c, 
                                                       ASI_CRM_Blind_Bonus_Amount_Per_9L__c, ASI_CRM_Blind_Bonus_Amount_per_Case__c from ASI_CRM_Blind_Bonus__c
                                                       where recordTypeID = :Global_RecordTypeCache.getRTId('ASI_CRM_Blind_Bonus__cASI_CRM_SG_Wholesaler') and ASI_CRM_Default_Est_Blind_Bonus_Amount__c = false
                                                       and ASI_CRM_Sub_brand__c = :sbIDSet and ASI_CRM_Customer__c != null order by ASI_CRM_Sub_brand__c, ASI_CRM_Effective_Date__c desc];
                
                Map<id,List<ASI_CRM_Blind_Bonus__c>> mapsbBlindBonus = new Map<id,List<ASI_CRM_Blind_Bonus__c>>();
                
                system.debug('BB List size: ' + bbList.size());
                for (ASI_CRM_Blind_Bonus__c bb:bbList){
                    //Add Blind Bonus into map for iterating to get latest effective date BB rate
                    
                    if (mapsbBlindBonus.containsKey(bb.ASI_CRM_Sub_brand__c))
                        mapsbBlindBonus.get(bb.ASI_CRM_Sub_brand__c).add(bb);
                    else 
                        mapsbBlindBonus.put(bb.ASI_CRM_Sub_brand__c, new List<ASI_CRM_Blind_Bonus__c>{bb});
                }
                
                for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new){
                    /*[WL 4.0 Begin]*/
                    //if (i.ASI_CRM_Contract__c != null && mapContract.get(i.ASI_CRM_Contract__c) != null){
                    if ((i.ASI_CRM_Contract__c != null && mapContract.get(i.ASI_CRM_Contract__c) != null) 
                        || i.ASI_TH_CRM_Offtake_G_L_Date__c != null){
                            
                            Date offtakeEffectiveDate = date.newinstance(2000, 1, 1);
                            /* [VL 9.0] BEGIN */
                            /*
                            if (i.ASI_CRM_Contract__c != null && mapContract.get(i.ASI_CRM_Contract__c) != null)
                                offtakeEffectiveDate = mapContract.get(i.ASI_CRM_Contract__c).ASI_TH_CRM_Start_Date__c;
                            else
                                */
                            /* [VL 9.0] END */
                                offtakeEffectiveDate = i.ASI_TH_CRM_Offtake_G_L_Date__c;
                            /*[WL 4.0 End]*/
                            
                            //Calculate BB Rate per 9L
                            ASI_CRM_Blind_Bonus__c lastMatchedBB;
                            if (mapsbBlindBonus.get(i.ASI_TH_CRM_Sub_brand__c) != null){                        
                                for (ASI_CRM_Blind_Bonus__c bb:mapsbBlindBonus.get(i.ASI_TH_CRM_Sub_brand__c)){
                                    //Retrive the latest Blind Bonus Rate matching wholesaler which the Effective Date matches Offtake GL Date
                                    if (bb.ASI_CRM_Customer__c == i.ASI_CRM_FromWS__c)
                                        //[WL 2.0] Fix blind bonus assignment logic
                                        if ((lastMatchedBB == null && offtakeEffectiveDate >= bb.ASI_CRM_Effective_Date__c) || (lastMatchedBB != null && offtakeEffectiveDate >= bb.ASI_CRM_Effective_Date__c && bb.ASI_CRM_Effective_Date__c > lastMatchedBB.ASI_CRM_Effective_Date__c))
                                        lastMatchedBB = bb;
                                }
                                
                                if (lastMatchedBB != null){
                                    if (lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_Per_9L__c != null)
                                        i.ASI_CRM_Blind_Bonus_Amount_per_9L__c = lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_Per_9L__c;
                                    else if (lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_per_Case__c != null){
                                        /* [VL 2.0] BEGIN */
                                        /*
                                        i.ASI_CRM_Blind_Bonus_Amount_per_9L__c = lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_per_Case__c / (i.ASI_CRM_Std_Bottle_Size__c * i.ASI_CRM_Packaging_Size__c) * 900;
                                        */
                                        i.ASI_CRM_Blind_Bonus_Amount_per_9L__c = lastMatchedBB.ASI_CRM_Blind_Bonus_Amount_per_Case__c / (mapSKU.get(i.ASI_CRM_SKU__c).ASI_HK_CRM_Std_Bottle_Size__c * mapSKU.get(i.ASI_CRM_SKU__c).ASI_HK_CRM_Packaging_Size__c) * 900;
                                        /* [VL 2.0] BEGIN */
                                    }
                                    
                                    System.debug('BB Rate per 9L: ' + i.ASI_CRM_Blind_Bonus_Amount_per_9L__c + ' SKU Code: ' + i.ASI_CRM_SKUCode__c);
                                }
                            }
                        }
                }
                
                /* [JC 8.0] BEGIN */
                /*
                List<String> customerNames = new List<String>();
                List<String> customerCodes = new List<String>();
                for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new) {
                    if (String.isNotEmpty(i.ASI_CRM_Customer_Name_Uploaded__c)) {
                        customerNames.add(i.ASI_CRM_Customer_Name_Uploaded__c);
                    }
                    if (String.isNotEmpty(i.ASI_CRM_Customer_Code_Uploaded__c)) {
                        customerCodes.add(i.ASI_CRM_Customer_Code_Uploaded__c);
                    }
                }
                List<ASI_CRM_AccountsAdditionalField__c> outlets = [SELECT id, name, ASI_CRM_MY_CustomerCode__c FROM ASI_CRM_AccountsAdditionalField__c
                                                                    WHERE recordtype.developername IN ('ASI_CRM_SG_Potential_Outlet', 'ASI_CRM_SG_Converted_Outlets', 'ASI_CRM_SG_Outlet')
                                                                    AND ASI_CRM_CN_Parent_Outlet__r.RecordType.DeveloperName = 'ASI_CRM_SG_Outlet'
                                                                    AND ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_MY_CustomerCode__c = '19855'
                                                                    AND name IN :customerNames
                                                                    AND ASI_CRM_MY_CustomerCode__c IN :customerCodes
                                                                   ];
                Map<String, ASI_CRM_AccountsAdditionalField__c> nameCodeToOutlet = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
                for (ASI_CRM_AccountsAdditionalField__c outlet : outlets) {
                    nameCodeToOutlet.put(outlet.Name + outlet.ASI_CRM_MY_CustomerCode__c, outlet);
                }
                
                
                List<ASI_CRM_AccountsAdditionalField__c> accountsAdditionalFields = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE recordtype.developername = 'ASI_CRM_SG_customer' AND ASI_CRM_MY_CustomerCode__c = '19854' LIMIT 1 ];
                Id accountsAdditionalFieldId = (accountsAdditionalFields.size() == 1)? accountsAdditionalFields.get(0).Id : null;
                
                List<ASI_CRM_AccountsAdditionalField__c> parentOutlets = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c WHERE  recordtype.developername = 'ASI_CRM_SG_Outlet' AND ASI_CRM_MY_CustomerCode__c = '19855' LIMIT 1];
                Id parentOutletId = (parentOutlets.size() == 1)? parentOutlets.get(0).Id : null;
                
                
                List<ASI_CRM_SKU_Mapping__c> skuMappings = [SELECT ASI_CRM_Item_Number__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c FROM ASI_CRM_SKU_Mapping__c WHERE recordtype.developername = 'ASI_CRM_SG_Offtrade_SKU_Mapping' AND ASI_CRM_Customer_Number__c = '19855'];
                
                List<ASI_CRM_AccountsAdditionalField__c> newOutlets = new List<ASI_CRM_AccountsAdditionalField__c>();
                
                for(ASI_TH_CRM_Actual_Offtake__c i : trigger_new) {
                    if (i.recordTypeId != Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake')
                        || !i.ASI_CRM_Mass_Uploaded__c || oldMap != null || i.ASI_CRM_Type_Uploaded__c != 'off-trade' ) {
                            continue;
                        }
                    if (i.ASI_CRM_Wholesaler_Code_Uploaded__c == 'CS' || i.ASI_CRM_Wholesaler_Code_Uploaded__c == 'GH') {
                        i.ASI_CRM_FromWS__c = accountsAdditionalFieldId;
                        
                        i.ASI_CRM_SG_Customer__c = null;
                        if (nameCodeToOutlet.get(i.ASI_CRM_Customer_Name_Uploaded__c + i.ASI_CRM_Customer_Code_Uploaded__c) != null) {
                            i.ASI_CRM_SG_Customer__c = nameCodeToOutlet.get(i.ASI_CRM_Customer_Name_Uploaded__c + i.ASI_CRM_Customer_Code_Uploaded__c).Id;
                        } else {
                            // create a new outlet
                            ASI_CRM_AccountsAdditionalField__c newOutlet = new ASI_CRM_AccountsAdditionalField__c();
                            newOutlet.Name = i.ASI_CRM_Customer_Name_Uploaded__c;
                            newOutlet.ASI_CRM_MY_CustomerCode__c = i.ASI_CRM_Customer_Code_Uploaded__c;
                            newOutlet.ASI_CRM_CN_Parent_Outlet__c = parentOutletId;
                            newOutlet.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Potential_Outlet');
                            
                            newOutlets.add(newOutlet);
                        }
                        
                        // Set sku to null first, if sku is still null after looping, throw error
                        i.ASI_CRM_SKU__c = null;
                        for (ASI_CRM_SKU_Mapping__c mapping : skuMappings) {
                            if (mapping.ASI_CRM_Item_Number__c == i.ASI_CRM_SKU_Code_Uploaded__c) {
                                i.ASI_CRM_SKU__c =  mapping.ASI_CRM_SKU__c;
                                i.ASI_TH_CRM_Sub_brand__c = mapping.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                            }
                        }
                        if (i.ASI_CRM_SKU__c == null) {
                            i.addError('ITEM NO ' + i.ASI_CRM_SKU_Code_Uploaded__c + 'does not exist.');
                        }
                        
                        i.ASI_TH_CRM_Quantity__c = i.ASI_CRM_Original_Quantity__c;
                        
                    }
                    
                }
                
                // insert new outlets and populate new Id into offtake.ASI_CRM_SG_Customer__c
                insert newOutlets;
                for (ASI_TH_CRM_Actual_Offtake__c i : trigger_new) {
                    if (i.recordTypeId != Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake')
                        || !i.ASI_CRM_Mass_Uploaded__c || oldMap != null || i.ASI_CRM_Type_Uploaded__c != 'off-trade') {
                            continue;
                        }
                    if (i.ASI_CRM_Wholesaler_Code_Uploaded__c == 'CS' || i.ASI_CRM_Wholesaler_Code_Uploaded__c == 'GH') {
                        if (i.ASI_CRM_SG_Customer__c == null && nameCodeToOutlet.get(i.ASI_CRM_Customer_Name_Uploaded__c + i.ASI_CRM_Customer_Code_Uploaded__c) != null) {
                            i.ASI_CRM_SG_Customer__c = nameCodeToOutlet.get(i.ASI_CRM_Customer_Name_Uploaded__c + i.ASI_CRM_Customer_Code_Uploaded__c).Id;
                        }
                    }
                }
                */
                /* [JC 8.0] END */
            }
        }
    }
    
    /* [VL 1.0] BEGIN */
    public static void populateOutletAndLatestOfftake(map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_wholesalerToCustomerKey_offtakes, set<string> set_SKUcode/* [VL 3.0] BEGIN */, set<string> set_wholesalerCode/* [VL 3.0] END */){
        /* [VL 3.0] BEGIN */
        Map<string, string> map_wholesalerCode_outlet_ws = getActualWholesalerCode(set_wholesalerCode);
        /* [VL 3.0] END */
        Map<string,ASI_MFM_SKU_Code__c> map_skuCode_ID = getSKUID(set_SKUcode);
        Set<string> set_key = map_wholesalerToCustomerKey_offtakes.keySet();
        System.debug('set_key: ' + set_key);
        System.debug('set_wholesalerCode: ' + set_wholesalerCode);
        map<string, ASI_CRM_Customer_Mapping__c> map_key_mapping = getCustomerMapping(set_key/* [VL 3.0] BEGIN */, map_wholesalerCode_outlet_ws/* [VL 3.0] END */);
        // no need to populate latest SKU
        /*
        Map<String, String> map_oldSKU_newSKU = getSKUMapping();
        */
        
        for (string key : set_key){
            list<ASI_TH_CRM_Actual_Offtake__c> list_offtakes = map_wholesalerToCustomerKey_offtakes.get(key);
            for (ASI_TH_CRM_Actual_Offtake__c i : list_offtakes){
                string errorMsg = '';
                if (i.ASI_CRM_SKU__c == null){
                    if (map_skuCode_ID.containsKey(i.ASI_CRM_SKU_Code_Uploaded__c)){
                        ASI_MFM_SKU_Code__c sku = map_skuCode_ID.get(i.ASI_CRM_SKU_Code_Uploaded__c);
                        i.ASI_CRM_SKU__c = sku.Id;
                        i.ASI_TH_CRM_Sub_brand__c = sku.ASI_MFM_Sub_brand__c;
                    } else {
                        errorMsg += 'SKU '+i.ASI_CRM_SKU_Code_Uploaded__c+' does not exist; ';
                    }
                }
                // no need to populate latest SKU
                /*
                // populate new SKU
                system.debug(i.ASI_CRM_SKU__c);
                system.debug(map_oldSKU_newSKU.containsKey(i.ASI_CRM_SKU__c));
                if (map_oldSKU_newSKU.containsKey(i.ASI_CRM_SKU__c)){
                i.ASI_CRM_SKU__c = map_oldSKU_newSKU.get(i.ASI_CRM_SKU__c);
                }
                */
                // populate outlet Id
                /* [VL 3.0] BEGIN */
                /*
                string keyInOfftake = i.ASI_CRM_Wholesaler_Code_Uploaded__c + '_' + i.ASI_CRM_Customer_Code_Uploaded__c;
                */
                String wsCode = map_wholesalerCode_outlet_ws.containsKey(i.ASI_CRM_Wholesaler_Code_Uploaded__c) ? map_wholesalerCode_outlet_ws.get(i.ASI_CRM_Wholesaler_Code_Uploaded__c) : i.ASI_CRM_Wholesaler_Code_Uploaded__c;
                string keyInOfftake = wsCode + '_' + i.ASI_CRM_Customer_Code_Uploaded__c;
                /* [VL 3.0] END */
                if (map_key_mapping.containsKey(keyInOfftake)){
                    ASI_CRM_Customer_Mapping__c m = map_key_mapping.get(keyInOfftake);
                    /* [VL 3.0] BEGIN */
                    /*
                    i.ASI_CRM_FromWS__c = m.ASI_CRM_SYS_Wholesaler_ID__c;
                    */
                    i.ASI_CRM_FromWS__c = m.ASI_CRM_Wholesaler__c;
                    /* [VL 3.0] END */
                    i.ASI_CRM_SG_Customer__c = m.ASI_CRM_JDE_Customer__c;
                } else {
                    errorMsg += 'Wholesaler '+i.ASI_CRM_Wholesaler_Code_Uploaded__c+' / Customer '+i.ASI_CRM_Customer_Code_Uploaded__c+' does not exist; ';
                }
                if (errorMsg != ''){
                    i.addError(errorMsg);
                }
            }
        }
    }
    
    private static Map<string,string> getActualWholesalerCode(set<string> set_wholesalerCode){
        Map<string,string> map_wholesalerCode_outlet_ws = new Map<string,string>();
        string outletRTid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet');
        string wsRTid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Wholesaler');
        
        for (ASI_CRM_AccountsAdditionalField__c s : [
            select id, ASI_CRM_MY_CustomerCode__c, ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_MY_CustomerCode__c
            from ASI_CRM_AccountsAdditionalField__c
            where 
            recordtypeid = :outletRTid
            and ASI_CRM_CN_Parent_Outlet__r.recordtypeid = :wsRTid
            and ASI_CRM_MY_CustomerCode__c in :set_wholesalerCode
        ]){
            map_wholesalerCode_outlet_ws.put(s.ASI_CRM_MY_CustomerCode__c, s.ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_MY_CustomerCode__c);
        }
        return map_wholesalerCode_outlet_ws;
    }
    
    private static Map<string,ASI_MFM_SKU_Code__c> getSKUID(set<string> set_SKUcode){
        Map<string,ASI_MFM_SKU_Code__c> map_skuCode_ID = new Map<string,ASI_MFM_SKU_Code__c>();
        string skuRTid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU');
        
        for (ASI_MFM_SKU_Code__c s : [
            select id, ASI_MFM_SKU_Code__c, ASI_MFM_Sub_brand__c
            //, ASI_HK_CRM_Std_Bottle_Size__c, ASI_HK_CRM_Packaging_Size__c
            from ASI_MFM_SKU_Code__c
            where recordtypeid = :skuRTid
            and ASI_MFM_SKU_Code__c in :set_SKUcode
        ]){
            map_skuCode_ID.put(s.ASI_MFM_SKU_Code__c, s);
        }
        return map_skuCode_ID;
    }
    
    private static map<string, ASI_CRM_Customer_Mapping__c> getCustomerMapping(Set<string> set_key/* [VL 3.0] BEGIN */, Map<string, string> map_wholesalerCode_outlet_ws/* [VL 3.0] END */){
        map<string, ASI_CRM_Customer_Mapping__c> map_key_mapping = new map<string, ASI_CRM_Customer_Mapping__c>();
        string customerMappingRTid = Global_RecordTypeCache.getRTId('ASI_CRM_Customer_Mapping__cASI_CRM_SG_Customer_Mapping');
        
        /* [VL 3.0] BEGIN */
        /*
        Set<string> set_key_new = set_key;
        */
        System.debug('set_key: ' + set_key);
        Set<string> set_key_new = new Set<string>();
        for(String key : set_key){
            String wsCode_original = key.split('_')[0];
            String wsCode = map_wholesalerCode_outlet_ws.containsKey(wsCode_original) ? map_wholesalerCode_outlet_ws.get(wsCode_original) : wsCode_original;
            System.debug('wsCode: ' + wsCode);
            System.debug(wsCode + '_' + key.split('_')[1]);
            set_key_new.add(wsCode + '_' + key.split('_')[1]);
        }
        /* [VL 3.0] END */
        System.debug('set_key_new: ' + set_key_new);
        for (ASI_CRM_Customer_Mapping__c m: [
            select id, ASI_CRM_JDE_Customer__c, ASI_CRM_SYS_Wholesaler_to_Outlet_Key__c, ASI_CRM_SYS_Wholesaler_ID__c, ASI_CRM_Wholesaler__c 
            from ASI_CRM_Customer_Mapping__c
            where recordtypeid = :customerMappingRTid
            and ASI_CRM_SYS_Wholesaler_to_Outlet_Key__c in :set_key_new
        ]){
            map_key_mapping.put(m.ASI_CRM_SYS_Wholesaler_to_Outlet_Key__c, m);
        }
        
        return map_key_mapping;
    }
    
    private static Map<String, String> getSKUMapping() {
        Map<String, String> skuMappingMap = new Map<String, String>();
        
        String sgSKUMappingRecordType = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cSG_SKU_Mapping');
        
        for(ASI_CRM_SKU_Mapping__c skuMapping : [SELECT ASI_CRM_SKU__c, ASI_CRM_New_SKU__c 
                                                 FROM ASI_CRM_SKU_Mapping__c
                                                 WHERE RecordTypeId = :sgSKUMappingRecordType]) {
                                                     
                                                     skuMappingMap.put(skuMapping.ASI_CRM_SKU__c, skuMapping.ASI_CRM_New_SKU__c);
                                                     
                                                 }
        
        for(String skuId : skuMappingMap.keySet()) {
            
            String tempSKUId = skuMappingMap.get(skuId);
            
            while(skuMappingMap.containsKey(tempSKUId)) {
                
                tempSKUId = skuMappingMap.get(tempSKUId);
                
            }
            
            skuMappingMap.put(skuId, tempSKUId);
            
        }
        
        return skuMappingMap;
    }
    
    public static void populateLatestSKUfromWineCategory(set<string> set_wineCategoryCode, map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_skuCodeLessThan6Digit){
        for(ASI_CRM_SG_Wine_Category__c w : [Select 
                                             id, 
                                             (select id, ASI_MFM_SKU_Code__c, ASI_MFM_Sub_brand__c from ASI_CRM_SG_SKUs__r order by ASI_MFM_SKU_Code__c desc limit 1) 
                                             from 
                                             ASI_CRM_SG_Wine_Category__c 
                                             where id in (
                                                 select ASI_CRM_SG_Wine_Category__c 
                                                 from ASI_MFM_SKU_Code__c 
                                                 where recordtypeId = :Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU') and
                                                 ASI_CRM_SG_Wine_Category__c <> null and 
                                                 ASI_MFM_SKU_Code__c like :set_wineCategoryCode
                                             )]){
                                                 for(ASI_MFM_SKU_Code__c sku : w.ASI_CRM_SG_SKUs__r){
                                                     for(String skuCode : map_skuCodeLessThan6Digit.keySet()){
                                                         if(sku.ASI_MFM_SKU_Code__c.contains(skuCode)){
                                                             for(ASI_TH_CRM_Actual_Offtake__c i : map_skuCodeLessThan6Digit.get(skuCode)){
                                                                 i.ASI_CRM_SKU__c = sku.Id;
                                                                 i.ASI_TH_CRM_Sub_brand__c = sku.ASI_MFM_Sub_brand__c;
                                                             }
                                                             map_skuCodeLessThan6Digit.remove(skuCode);
                                                         }
                                                     }
                                                 }
                                             }
    }
    /* [VL 1.0] END */
    
    /* [VL 2.0] BEGIN */
    public static Map<string, Map<string, decimal>> getContractTargetMap(List<ASI_TH_CRM_Contract__c> list_c){
        Map<string, Map<string, decimal>> map_contractId_ctMap = new Map<string, Map<string, decimal>>();
        Map<String, String> map_oldSKU_newSKU = getSKUMapping();
        
        for (ASI_TH_CRM_Contract__c c : list_c){
            Map<string, decimal> map_ct = new Map<string, decimal>();
            for (ASI_CRM_ContractTarget__c contractTarget: c.Contract_Target__r){
                String lastestSkuId = map_oldSKU_newSKU.containsKey(contractTarget.ASI_CRM_SKU__c) ? map_oldSKU_newSKU.get(contractTarget.ASI_CRM_SKU__c) : contractTarget.ASI_CRM_SKU__c;
                String subBrandId = contractTarget.ASI_CRM_Subbrand__c != null ? contractTarget.ASI_CRM_Subbrand__c : contractTarget.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                String key_sku_ws = lastestSkuId + WHOLESALERMARGIN;
                String key_subBrand_ws = subBrandId + WHOLESALERMARGIN;
                String key_sku_pc = lastestSkuId + PRICECOMPENSATION;
                String key_subBrand_pc = subBrandId + PRICECOMPENSATION;
                // use RTM price for compensation
                decimal pricePRSWS = contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
                decimal pricePRSWS_RTM = contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c;
                decimal priceWSOT_RTM = contractTarget.ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c != null ? contractTarget.ASI_CRM_RTM_Price_Per_Bottle_WS_OT__c : contractTarget.ASI_CRM_SG_Selling_Price_Btl_WS_On_Trade__c;
                //decimal pricePRSWS_RTM = contractTarget.ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c != null ? contractTarget.ASI_CRM_RTM_Price_Per_Bottle_PRS_WS__c : (contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c != null ? contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c : 0);
                /* [VL 6.0] BEGIN */
                /*
                if ( 
                contractTarget.ASI_CRM_SKU__c != null &&
                contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c != null &&
                pricePRSWS_RTM != null &&
                contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c < pricePRSWS_RTM
                ){
                if(!map_ct.containsKey(key_sku_pc)){
                map_ct.put(key_sku_pc, (pricePRSWS_RTM-contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c));
                }
                if(!map_ct.containsKey(key_subBrand_pc) && contractTarget.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c){
                map_ct.put(key_subBrand_pc, (pricePRSWS_RTM-contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c));
                }
                }
                if ( 
                contractTarget.ASI_CRM_SG_Wholesaler_Margin__c != null && 
                contractTarget.ASI_CRM_SG_Wholesaler_Margin__c > 0
                ){
                if(!map_ct.containsKey(key_sku_ws)){
                map_ct.put(key_sku_ws, contractTarget.ASI_CRM_SG_Wholesaler_Margin__c);
                }
                if(!map_ct.containsKey(key_subBrand_ws) && contractTarget.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c){
                map_ct.put(key_subBrand_ws, contractTarget.ASI_CRM_SG_Wholesaler_Margin__c);
                }
                }
                */
                // before Jan 2018
                if ( 
                    contractTarget.ASI_CRM_SKU__c != null &&
                    contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c != null &&
                    pricePRSWS != null
                ){
                    if(!map_ct.containsKey(key_sku_pc)){
                        map_ct.put(STRING_BEFORE + key_sku_pc, (pricePRSWS-contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c));
                    }
                    if(!map_ct.containsKey(key_subBrand_pc) && contractTarget.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c){
                        map_ct.put(STRING_BEFORE + key_subBrand_pc, (pricePRSWS-contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c));
                    }
                }
                if ( 
                    contractTarget.ASI_CRM_SG_Wholesaler_Margin__c != null
                ){
                    if(!map_ct.containsKey(STRING_BEFORE + key_sku_ws)){
                        map_ct.put(STRING_BEFORE + key_sku_ws, contractTarget.ASI_CRM_SG_Wholesaler_Margin__c);
                    }
                    if(!map_ct.containsKey(STRING_BEFORE + key_subBrand_ws) && contractTarget.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c){
                        map_ct.put(STRING_BEFORE + key_subBrand_ws, contractTarget.ASI_CRM_SG_Wholesaler_Margin__c);
                    }
                }
                // Jan 2018 onwards
                if ( 
                    contractTarget.ASI_CRM_SKU__c != null &&
                    contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c != null &&
                    priceWSOT_RTM != null
                ){
                    if(!map_ct.containsKey(STRING_AFTER + key_sku_pc)){
                        map_ct.put(STRING_AFTER + key_sku_pc, (priceWSOT_RTM-contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c));
                    }
                    if(!map_ct.containsKey(STRING_AFTER + key_subBrand_pc) && contractTarget.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c){
                        map_ct.put(STRING_AFTER + key_subBrand_pc, (priceWSOT_RTM-contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c));
                    }
                }
                /* [VL 6.0] END */
            }
            map_contractId_ctMap.put(c.id, map_ct);
        }
        return map_contractId_ctMap;
    }
    /* [VL 2.0] END */
    
    /* [VL 5.0] BEGIN */
    public static map<string, date> getContractStartDateMap(Set<string> set_contractIdtoCheckStartDate){
        map<string, date> map_contract_startDate = new map<string, date>();
        for (ASI_TH_CRM_Contract__c c : [select id, ASI_TH_CRM_Start_Date__c from ASI_TH_CRM_Contract__c where id in :set_contractIdtoCheckStartDate]){
            map_contract_startDate.put(c.id, c.ASI_TH_CRM_Start_Date__c);
        }
        return map_contract_startDate;
    }
    /* [VL 5.0] END */
    
    /* [VL 8.0] BEGIN */
    private static void completeOfftradeConversion(map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_customerToItemKey_offtakes, map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_customerKey_offtakes, map<string, string> map_customerKey_parent){
        set<string> set_newCustomer = map_customerKey_offtakes.keySet().clone(); 
        
        system.debug('map_offtradeWholesalerCode.values()');
        system.debug(map_offtradeWholesalerCode.values());
        system.debug('map_customerKey_offtakes.keySet()');
        system.debug(map_customerKey_offtakes.keySet());
        
        string rtId_potentialOutlet = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Potential_Outlet');
        string rtId_convertedOutlet = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Converted_Outlets');
        string rtId_Outlet = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet');
        string rtId_Customer = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Customer');
        
        // get existing outlet
        Map<String, ASI_CRM_AccountsAdditionalField__c> nameCodeToOutlet = new Map<String, ASI_CRM_AccountsAdditionalField__c>();
        for (ASI_CRM_AccountsAdditionalField__c outlet : [
            SELECT id, ASI_CRM_SYS_Name_Customer_Code_Key__c 
            FROM ASI_CRM_AccountsAdditionalField__c WHERE recordtypeid IN (:rtId_potentialOutlet, :rtId_convertedOutlet, :rtId_Outlet)
            AND ASI_CRM_CN_Parent_Outlet__r.RecordTypeid = :rtId_Outlet
            AND ASI_CRM_CN_Parent_Outlet__r.ASI_CRM_MY_CustomerCode__c in :map_offtradeWholesalerCode.values()
            AND ASI_CRM_SYS_Name_Customer_Code_Key__c IN :map_customerKey_offtakes.keySet()
        ]) {
            nameCodeToOutlet.put(outlet.ASI_CRM_SYS_Name_Customer_Code_Key__c, outlet);
            set_newCustomer.remove(outlet.ASI_CRM_SYS_Name_Customer_Code_Key__c);
        }
        
        // insert new outlet
        if(set_newCustomer.size()>0){
            map<string, string> map_parentCode = new map<string, string>();
            for(ASI_CRM_AccountsAdditionalField__c c : [
                SELECT Id, ASI_CRM_MY_CustomerCode__c 
                FROM ASI_CRM_AccountsAdditionalField__c WHERE  recordtypeid = :rtId_Outlet 
                AND ASI_CRM_MY_CustomerCode__c in :map_offtradeWholesalerCode.values()
            ]){
                map_parentCode.put(c.ASI_CRM_MY_CustomerCode__c, c.id);
            }
            list<ASI_CRM_AccountsAdditionalField__c> list_cToInsert = new list<ASI_CRM_AccountsAdditionalField__c>();
            for(string s : set_newCustomer){
                string customerName = s.split('_')[0];
                string customerCode = s.split('_')[1];
                ASI_CRM_AccountsAdditionalField__c c = new ASI_CRM_AccountsAdditionalField__c(
                    recordtypeid = rtId_potentialOutlet,
                    name = customerName,
                    ASI_CRM_Customer_Code_Original__c = customerCode,
                    ASI_CRM_CN_Parent_Outlet__c = map_parentCode.get(map_customerKey_parent.get(s))
                );
                list_cToInsert.add(c);
                nameCodeToOutlet.put(s, c);
            }
            insert list_cToInsert;
        }
        
        // get wholesaler
        map<string, string> map_wholesaler = new map<string, string>();
        for(ASI_CRM_AccountsAdditionalField__c c : [
            SELECT Id, ASI_CRM_MY_CustomerCode__c 
            FROM ASI_CRM_AccountsAdditionalField__c WHERE  recordtypeid = :rtId_Customer 
            AND ASI_CRM_MY_CustomerCode__c in :map_offtradeOutletToWholesaler.values()
        ]){
            map_wholesaler.put(c.ASI_CRM_MY_CustomerCode__c, c.id);
        }
        
        // populate customer and wholesaler id into offtakes
        for(string s : map_customerKey_offtakes.keySet()){
            string cid = nameCodeToOutlet.get(s).id;
            for(ASI_TH_CRM_Actual_Offtake__c i : map_customerKey_offtakes.get(s)){
                if(!map_wholesaler.containsKey(map_offtradeOutletToWholesaler.get(map_offtradeWholesalerCode.get(i.ASI_CRM_Wholesaler_Code_Uploaded__c)))){
                    i.addError('Wholesaler '+i.ASI_CRM_Wholesaler_Code_Uploaded__c+' does not exist.');
                } else {
                    i.ASI_CRM_FromWS__c = map_wholesaler.get(map_offtradeOutletToWholesaler.get(map_offtradeWholesalerCode.get(i.ASI_CRM_Wholesaler_Code_Uploaded__c)));
                    i.ASI_CRM_SG_Customer__c = cid;
                }
            }
        }
        
        // get sku mapping
        map<string, ASI_CRM_SKU_Mapping__c> map_key_sku = new map<string,ASI_CRM_SKU_Mapping__c>();
        for(ASI_CRM_SKU_Mapping__c m : [
            SELECT ASI_CRM_SYS_Customer_to_Item_Key__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c 
            FROM ASI_CRM_SKU_Mapping__c 
            WHERE recordtype.developername = 'ASI_CRM_SG_Offtrade_SKU_Mapping' 
            AND ASI_CRM_Customer_Number__c in :map_offtradeWholesalerCode.values()
        ]){
            map_key_sku.put(m.ASI_CRM_SYS_Customer_to_Item_Key__c, m);
        }
        
        // populate sku and subbrand id into offtakes
        for(string s : map_customerToItemKey_offtakes.keySet()){
            for(ASI_TH_CRM_Actual_Offtake__c i : map_customerToItemKey_offtakes.get(s)){
                if(!map_key_sku.containsKey(s)){
                    i.addError('ITEM NO '+i.ASI_CRM_SKU_Code_Uploaded__c+' does not exist.');
                } else {
                    ASI_CRM_SKU_Mapping__c m = map_key_sku.get(s);
                    i.ASI_CRM_SKU__c = m.ASI_CRM_SKU__c;
                    i.ASI_TH_CRM_Sub_brand__c = m.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                }
            }
        }
    } 
    /* [VL 8.0] END */    
}