public without sharing class ASI_MFM_TW_POLineItem_TriggerClass {
    /*
    public static void routineAfterAll(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        Set<id> planList=new Set<id>();
        Set<id> poList=new Set<id>();
        
        if(trigger_new!=null){
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                if(!poList.contains(pi.ASI_MFM_PO__c))
                    poList.add(pi.ASI_MFM_PO__c);      
            }
        }
        
        if(trigger_oldMap!=null){
            for (ASI_MFM_PO_Line_Item__c pi:trigger_oldmap.values())  {
                if(!poList.contains(pi.ASI_MFM_PO__c)){
                System.debug(pi.ASI_MFM_PO__c);
                    poList.add(pi.ASI_MFM_PO__c);     
                } 
            }
        }
        
        List<asi_mfm_po__c> plansqlList=[select asi_mfm_plan__c, ASI_MFM_Is_Direct_Payment__c from asi_mfm_po__c where ASI_MFM_Is_Direct_Payment__c = false and id in :poList];
        for (ASI_MFM_Po__c p:plansqlList) {
            if(!planList.contains(p.asi_mfm_plan__c))
                planList.add(p.asi_mfm_plan__c);      
        }
                      
        List<ASI_MFM_PO_Line_Item__c> poLineItemList = [SELECT ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c, ASI_MFM_BaseCurrencyAmount__c
                                                            FROM ASI_MFM_PO_Line_Item__c
                                                            WHERE ASI_MFM_PO__r.ASI_MFM_Accrual_PO__c =false and ASI_MFM_PO__r.ASI_MFM_Plan__c in :planList AND                                                                   
                                                                  ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c in ('TOTAL A&P', 'TOTAL A&D')
                                                           ];
        Map<Id, Decimal> planPOTotalAnPAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> planPOTotalAnDAmountMap = new Map<Id, Decimal>();
        
        for(ASI_MFM_PO_Line_Item__c poLineItem : poLineItemList) {
            Decimal poLineItemAmount = 0;
 System.debug('amount='+poLineItem.ASI_MFM_BaseCurrencyAmount__c);           
            if(poLineItem.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c=='TOTAL A&P') {
                if(planPOTotalAnPAmountMap.containsKey(poLineItem.ASI_MFM_PO__r.ASI_MFM_Plan__c)) {
                    poLineItemAmount = planPOTotalAnPAmountMap.get(poLineItem.ASI_MFM_PO__r.ASI_MFM_Plan__c);
                }
                poLineItemAmount += poLineItem.ASI_MFM_BaseCurrencyAmount__c;
                planPOTotalAnPAmountMap.put(poLineItem.ASI_MFM_PO__r.ASI_MFM_Plan__c, poLineItemAmount);
            }else{
                if(planPOTotalAnDAmountMap.containsKey(poLineItem.ASI_MFM_PO__r.ASI_MFM_Plan__c)) {
                    poLineItemAmount = planPOTotalAnDAmountMap.get(poLineItem.ASI_MFM_PO__r.ASI_MFM_Plan__c);
                }
                poLineItemAmount += poLineItem.ASI_MFM_BaseCurrencyAmount__c;
                planPOTotalAnDAmountMap.put(poLineItem.ASI_MFM_PO__r.ASI_MFM_Plan__c, poLineItemAmount);
            }
        } 
        
        List <asi_mfm_plan__c> planUpdateList= new List <asi_mfm_plan__c>();
        
        for(id planid :planList){
            asi_mfm_plan__c p= new asi_mfm_plan__c();
            System.debug('planid='+planid+','+planPOTotalAnDAmountMap.get(planid)+','+planPOTotalAnPAmountMap.get(planid));
            p.id=planid;
            p.ASI_MFM_TW_PO_AD_Amount__c = planPOTotalAnDAmountMap.get(planid);
            p.ASI_MFM_TW_PO_AP_Amount__c = planPOTotalAnPAmountMap.get(planid); 
            planUpdateList.add(p);          
        }
        
        update planUpdateList;
        
        
    }
    */

    public static void routineAfterUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {  
        set<id> po_set = new set<id>();
        
        //Added by Michael (Introv) 21Feb2014 to update receipt balance and remaining
        Map<String, id> MRecType = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_PO_Line_Item__c')){
            MRecType.put(rec.developername,rec.id);
        }
        // end of Changes

        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            
            if (pi.ASI_MFM_Spread_by_Months__c && pi.ASI_MFM_Amount__c != null) {
                po_set.add(pi.ASI_MFM_PO__c);
            }
        }
        
        
        
        if (po_set.size() > 0) {
            map<id, ASI_MFM_PO__c> po_map = new map<id, ASI_MFM_PO__c>([select ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c, ASI_MFM_Is_Direct_Payment__c, recordType.developerName from ASI_MFM_PO__c where id in :po_set]);
            list<ASI_MFM_PO_Line_Item__c> npi_list = new list<ASI_MFM_PO_Line_Item__c>();
            set<id> dpi_set = new set<id>();
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_Spread_by_Months__c && pi.ASI_MFM_Amount__c != null) {   
                    ASI_MFM_PO__c po = po_map.get(pi.ASI_MFM_PO__c);
                    if (po.ASI_MFM_PO_End_Date__c > po.ASI_MFM_PO_Start_Date__c) {
                        integer month_count = po.ASI_MFM_PO_Start_Date__c.monthsBetween(po.ASI_MFM_PO_End_Date__c) + 1;
                        decimal sp_amt;
                        decimal gf_sp_amt;
                        
                        if (po.recordType.DeveloperName.startsWith('ASI_MFM_TW') && pi.ASI_MFM_Currency__c == 'TWD') {
                            sp_amt = (pi.ASI_MFM_Amount__c / month_count).setScale(0, roundingmode.half_up);
                        }
                        else {
                            sp_amt = (pi.ASI_MFM_Amount__c / month_count).setScale(2, roundingmode.half_up);                           
                        }                       
                        decimal rounding_err = sp_amt * month_count - pi.ASI_MFM_Amount__c;
                        date sp_date = po.ASI_MFM_PO_Start_Date__c;
                        for (integer i=0; i<month_count; i++) {
                            ASI_MFM_PO_Line_Item__c npi = pi.clone(false, true);
                            npi.ASI_MFM_Amount__c = sp_amt;
                                                       
                            npi.ASI_MFM_G_L_Date__c = po.ASI_MFM_PO_Start_Date__c.addMonths(i);
                            npi.ASI_MFM_Quantity__c = null;
                            npi.ASI_MFM_PO_Percentage__c = null;
                            npi.ASI_MFM_Spread_by_Months__c = false;
                           
                                
                            if (month_count > 1 && i + 1 == month_count) {                               
                                npi.ASI_MFM_Amount__c -= rounding_err;
                                npi.ASI_MFM_G_L_Date__c = po.ASI_MFM_PO_End_Date__c;
                            }
                            npi_list.add(npi);                          
                        }
                        dpi_set.add(pi.id);
                    }
                }
            }
            if (npi_list.size() > 0 && !Test.isRunningTest()) {
                insert npi_list;
            }
            if (dpi_set.size() > 0 && !Test.isRunningTest()) {
                list<ASI_MFM_PO_Line_Item__c> dpi_list = [select id from ASI_MFM_PO_Line_Item__c where id in :dpi_set];
                delete dpi_list;
            }               
        }       
    }

    public static void routineBeforeUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {

        // Added by Michael Yip (Introv) 19Feb2014 to add default customer for CN PO line item
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO_Line_Item__c');
        
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        
        Map<String, ASI_MFM_A_C_Code__c> acMap = new  Map<String, ASI_MFM_A_C_Code__c>([select id, ASI_MFM_A_and_P_Tree__c from ASI_MFM_A_C_Code__c where recordtype.name like '%TW%']);
        
                
        // Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c, ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        
        System.debug('country_pfx : ' +  country_pfx );

        
        Map<string, id> rt_map = new map<string, id>();
        List<recordType> portList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:portList) {
            rt_map.put(rtt.DeveloperName, rtt.id);            
        }
        
        Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
        boolean isuserAdmin = prof.name.contains('System Administrator') || prof.name == 'ASI_MFM_TW Power';
        
        Set<ID> setPYI = new Set<ID>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new)
            setPYI.add(i.ASI_MFM_PO__c);
        
        //Updated by Introv 20170808 (added "ASI_MFM_Accrual_PO__c" field in the query; Accrual will not deduct plan balance amount;)
        Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name, ASI_MFM_Accrual_PO__c, recordtypeID, ASI_MFM_SG_Customer__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_BU_Code__c, ASI_MFM_Remarks__c,ASI_MFM_Responsible_By__c, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c , ASI_MFM_Exchange_Rate__c , ASI_MFM_Status__c FROM ASI_MFM_PO__c WHERE ID IN: setPYI]);
        
        // Calculate PO line item amount if it is not input by user 
        set<id> sku_set = new set<id>();
        set<id> sku_setDescription = new set<id>();
       
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            // Check if there was an input in the decimal number output error
            boolean isDecimal = (ASI_MFM_Function.containsDecimalValue(pi.ASI_MFM_Amount__c)) && pi.ASI_MFM_Currency__c == 'TWD';
            
            pi.ASI_MFM_AD_AP__c = pi.ASI_MFM_A_C_Code__c!=null && acMap.get(pi.ASI_MFM_A_C_Code__c) != null ? acMap.get(pi.ASI_MFM_A_C_Code__c).ASI_MFM_A_and_P_Tree__c =='TOTAL A&P'? 'A&P':'A&D' : null;
            
            if (pomap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null)
                pi.ASI_MFM_Exchange_Rate__c = pomap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c;
            
            if (isDecimal)
                pi.addError(' You Cannot input a decimal number for a TWD currency.');
                
            // Bypass checking if roll up summary payment item related is updated
            // Updated by Introv at 20170808 (Exclude the case when PO Header's "ASI_MFM_Accrual_PO__c = true")
            /*
            if(trigger_oldMap != NULL ){
                if (poMap != NULL && !isuserAdmin && poMap.get(pi.ASI_MFM_PO__c) != NULL &&  poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Is_Direct_Payment__c != TRUE && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Accrual_PO__C == FALSE && !System.isFuture() && poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Status__c !='Draft') {
                    pi.addError('You can NOT modify the PO Line under a Final or Complete PO');                
                }
            }
            */
            if (pi.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item')){
                pi = asi_mfm_POLineItem.setAmount(pi);
            }
            
            if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null) {
                sku_set.add(pi.ASI_MFM_SKU_Code__c);
            }
            
            if (pi.ASI_MFM_SKU_Code__c != null)
                sku_setDescription.add(pi.ASI_MFM_SKU_Code__c);
            
            // Updated by Michael Yip (Introv) 6 Jan 2014 to exclude CN PO Line item    
            // Updated by Steve Wan (Introv) 24 Feb 2014 to exclude JP PO Line item
            if (pi.ASI_MFM_SKU_Code__c == null && pi.ASI_MFM_List_Item_Description__c == null )
                pi.adderror('SKU code and Item Line Description cannot be both empty');
                      
        }
        
// Set sub-brand code if it is not input by user
        if (sku_set.size() > 0) {
            map<id, ASI_MFM_SKU_Code__c> sku_map = new map<id, ASI_MFM_SKU_Code__c>([select ASI_MFM_Sub_brand__c from ASI_MFM_SKU_Code__c where id = :sku_set]);
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null && sku_map.containsKey(pi.ASI_MFM_SKU_Code__c)) {
                    pi.ASI_MFM_Sub_brand_Code__c = sku_map.get(pi.ASI_MFM_SKU_Code__c).ASI_MFM_Sub_brand__c;
                }           
            }           
        }

// Set Description AND UOM1 if it is not input by user
        if (sku_setDescription.size() > 0){
            map<id, ASI_MFM_SKU_Code__c> sku_map = new map<id, ASI_MFM_SKU_Code__c>([select ASI_MFM_SKU_Description__c, ASI_HK_CRM_UOM1__c from ASI_MFM_SKU_Code__c where id = :sku_setDescription]);
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) 
            {
                if (pi.ASI_MFM_List_Item_Description__c == null && pi.ASI_MFM_SKU_Code__c != null && sku_map.containsKey(pi.ASI_MFM_SKU_Code__c))
                    pi.ASI_MFM_List_Item_Description__c = sku_map.get(pi.ASI_MFM_SKU_Code__c).ASI_MFM_SKU_Description__c;
                    
                if (pi.ASI_MFM_UOM__c == null && pi.ASI_MFM_SKU_Code__c != null && sku_map.containsKey(pi.ASI_MFM_SKU_Code__c))
                    pi.ASI_MFM_UOM__c = sku_map.get(pi.ASI_MFM_SKU_Code__c).ASI_HK_CRM_UOM1__c;
            }
        }       
        
// Set default BU code if not input by user
       
        setDefaultBUCode(trigger_new, bu_list);             
    }                   
    
    public static void setDefaultBUCode(list<ASI_MFM_PO_Line_Item__c> listPi, list<ASI_MFM_BU__c> bu_list){
        if(bu_list.size()==1) {
            for (ASI_MFM_PO_Line_Item__c pi:listPi) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                    pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                }        
            }
        }
    }
    
}