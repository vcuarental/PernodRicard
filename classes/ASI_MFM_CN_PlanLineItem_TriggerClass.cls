/* Filename:    ASI_MFM_CN_PlanLineItem_TriggerClass.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Trigger Class for CN plan line item
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2012-12-20   michael.yip@introv.com      Created
 * 2012-12-27   michael.yip@introv.com      Modified validation on total cost and month cost
 * 2014-05-17   michael.yip@introv.com      Add default value '/' to list item description
 * 2014-12-12   daniel.wong@introv.com      Added by Daniel for PRCN-MFM Log #85
 */

public with sharing class ASI_MFM_CN_PlanLineItem_TriggerClass {
        public static void routineBeforeDelete(list<ASI_MFM_Plan_Line_Item__c> trigger_old) {
// Not allowed to delete if the plan is in final or complete status
        set<id> pid_set = new set<id>();
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            pid_set.add(pi.ASI_MFM_Plan__c);
        }
        map<id, ASI_MFM_Plan__c> plan_map = new map<id, ASI_MFM_Plan__c>([select id from ASI_MFM_Plan__c where id in :pid_set and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Complete')]); 
        
        // Check if any sub-brand IN PO line item
        // Added by Daniel WONG 2014-12-11
        // for recordtype = CN
        set<id> setOfPlan = new set<id>();
        for(ASI_MFM_Plan_Line_Item__c pi : trigger_old){
             if(pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_CN_Plan_Line_Item'))
                setOfPlan.add(pi.ASI_MFM_Plan__c);
        }
        
        set<id> setOfPO = new set<id>();
        map <ID, set<ID>> mapOfPlanWithPO = new map <ID, set<ID>>();
        
        for(ASI_MFM_PO__c i : [SELECT ASI_MFM_Plan__c FROM ASI_MFM_PO__c WHERE ASI_MFM_Plan__c IN :setOfPlan]){
            id idKey = i.ASI_MFM_Plan__c;
            set<id> setOfID = new set<id>();
            
            if(mapOfPlanWithPO.get(idKey) != NULL)
                setOfID = mapOfPlanWithPO.get(idKey);
            setOfID.add(i.id);
            
            mapOfPlanWithPO.put(idKey, setOfID);
            setOfPO.add(i.id);
        }
        
        map <ID, set<ID>> mapOfPOWithSubBrand = new map <ID, set<ID>>();
        
        for(ASI_MFM_PO_Line_Item__c i : [SELECT ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c
                                           FROM ASI_MFM_PO_Line_Item__c
                                           WHERE ASI_MFM_Sub_brand_Code__c != NULL
                                           AND ASI_MFM_PO__c IN :setOfPO
                                          ]){
            id idKey = i.ASI_MFM_PO__c;
            set <ID> setOfID = new set <ID>();
            if(mapOfPOWithSubBrand.get(idKey) != NULL)
                setOfID = mapOfPOWithSubBrand.get(idKey);
            setOfID.add(i.ASI_MFM_Sub_brand_Code__c);
            
            mapOfPOWithSubBrand.put(idKey, setOfID);
        }
       
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            if (plan_map.containsKey(pi.ASI_MFM_Plan__c)) {
                pi.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
            }
            
            // Check if any sub-brand IN PO line item
            // Added by Daniel WONG 2014-12-11
            if(pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_CN_Plan_Line_Item')){
                if(pi.ASI_MFM_Sub_brand_Code__c != NULL){
                    //2015-09-07 Ben @ Elufa
                    set<id> setOfKey = new Set<id>();
                    if(mapOfPlanWithPO.containsKey(pi.ASI_MFM_Plan__c))
                    	setOfKey = mapOfPlanWithPO.get(pi.ASI_MFM_Plan__c);
                    if(setOfKey.size() > 0){
                    //2015-09-07 End
                        for(id i : setOfKey){
                            if(mapOfPOWithSubBrand.get(i) != NULL){
                                set<id> setOfID = mapOfPOWithSubBrand.get(i);
                                if(setOfID.contains(pi.ASI_MFM_Sub_brand_Code__c))
                                    pi.addError('The sub-brand is connected with other PO.');
                            }
                        }
                    }
                }
            }
        }
    }//---------------------------------------------------------------------------------------------------------------------------end delete

    public static void routineBeforeUpsert(list<ASI_MFM_Plan_Line_Item__c> trigger_new, map<id, ASI_MFM_Plan_Line_Item__c> trigger_oldMap) {
        // Check if any sub-brand IN PO line item
        // Added by Daniel WONG 2014-12-11
        // for recordtype == CN
        set<id> setOfPlan = new set<id>();
        for (ASI_MFM_Plan_Line_Item__c pi : trigger_new){
            if(pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_CN_Plan_Line_Item'))
                setOfPlan.add(pi.ASI_MFM_Plan__c);
        }
        set<id> setOfPO = new set<id>();
        map <ID, set<ID>> mapOfPlanWithPO = new map <ID, set<ID>>();
        
        for(ASI_MFM_PO__c i : [SELECT ASI_MFM_Plan__c FROM ASI_MFM_PO__c WHERE ASI_MFM_Plan__c IN :setOfPlan]){
            id idKey = i.ASI_MFM_Plan__c;
            set<id> setOfID = new set<id>();
            
            if(mapOfPlanWithPO.get(idKey) != NULL)
                setOfID = mapOfPlanWithPO.get(idKey);
            setOfID.add(i.id);
            
            mapOfPlanWithPO.put(idKey, setOfID);
            setOfPO.add(i.id);
        }
        
        map <ID, set<ID>> mapOfPOWithSubBrand = new map <ID, set<ID>>();
        
        for(ASI_MFM_PO_Line_Item__c i : [SELECT ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c
                                           FROM ASI_MFM_PO_Line_Item__c
                                           WHERE ASI_MFM_Sub_brand_Code__c != NULL
                                           AND ASI_MFM_PO__c IN :setOfPO
                                          ]){
            id idKey = i.ASI_MFM_PO__c;
            set <ID> setOfID = new set <ID>();
            if(mapOfPOWithSubBrand.get(idKey) != NULL)
                setOfID = mapOfPOWithSubBrand.get(idKey);
            setOfID.add(i.ASI_MFM_Sub_brand_Code__c);
            
            mapOfPOWithSubBrand.put(idKey, setOfID);
        }

// Set default BU code if not input by user
        //recordType rt = [select developerName from recordType where id = :trigger_new[0].recordTypeId];
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        if (bu_list.size() == 1) {
            for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                    pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                }
            } 
        }           
        String CNCustomerDefault;
        String CNBUCodeDefault;
        String CNACCodeDefault;
        String CNAPCodeDefault;
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            //Added by Steve on 20140617, Default Customer
            if(Setting.ASI_MFM_Object__c == 'ASI_MFM_Plan_Line_Item__c' && Setting.name == 'CN_A_C_Code__c' && Setting.Country__c == 'CN'){
                CNACCodeDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.ASI_MFM_Object__c == 'ASI_MFM_Plan_Line_Item__c' && Setting.name == 'CN_Plan_Customer_Name__c' && Setting.Country__c == 'CN'){
                CNCustomerDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.ASI_MFM_Object__c == 'ASI_MFM_Plan_Line_Item__c' && Setting.name == 'CN_BU_Code__c' && Setting.Country__c == 'CN'){
                CNBUCodeDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.ASI_MFM_Object__c == 'ASI_MFM_Plan_Line_Item__c' && Setting.name == 'CN_AP_Code__c' && Setting.Country__c == 'CN'){
                CNAPCodeDefault = Setting.ASI_MFM_value__c;
            }
        }
        System.debug(ASI_MFM_Default_Value__c.getAll().values());
        
               
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {

            //Update default value
            if(pi.ASI_MFM_Customer_Name__c == null &&  CNCustomerDefault != null && CNCustomerDefault != ''){
                     pi.ASI_MFM_Customer_Name__c = CNCustomerDefault ;
            }
            if(pi.ASI_MFM_BU_Code__c == null &&  CNBUCodeDefault != null && CNBUCodeDefault != ''){
                 pi.ASI_MFM_BU_Code__c = CNBUCodeDefault ;
            }
            if(pi.ASI_MFM_A_C_Code__c == null &&  CNACCodeDefault!= null && CNACCodeDefault!= ''){
                 pi.ASI_MFM_A_C_Code__c = CNACCodeDefault;
            }
            if(pi.ASI_MFM_AP_Code__c == null &&  CNAPCodeDefault!= null && CNAPCodeDefault!= ''){
                 pi.ASI_MFM_AP_Code__c = CNAPCodeDefault;
            }
            
            // Modified by Michael Yip (Introv) 17May2014
            if(pi.ASI_MFM_List_Item_Description__c == null){
                pi.ASI_MFM_List_Item_Description__c = '/';
            }
            
            // Check if any sub-brand IN PO line item
            // Added by Daniel WONG 2014-12-12
            if(pi != null && pi.recordtypeid == Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_CN_Plan_Line_Item')){
                if(trigger_oldMap != null && trigger_oldMap.get(pi.id) != null && pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c){
                    ID idOldSubBrand = trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c;
                    if(pi.ASI_MFM_Sub_brand_Code__c != NULL){
                        //2015-09-07 Ben @ Elufa
                        set<id> setOfKey = new Set<id>();
                        if(mapOfPlanWithPO.containsKey(pi.ASI_MFM_Plan__c))
                        	setOfKey = mapOfPlanWithPO.get(pi.ASI_MFM_Plan__c);
                        if(setOfKey.size() > 0){
                        //2015-09-07 End
                            for(id iKey : setOfKey){
                                if(mapOfPOWithSubBrand.get(iKey) != NULL){
                                    set<id> setOfID = mapOfPOWithSubBrand.get(iKey);
                                    if(setOfID.contains(idOldSubBrand))
                                        pi.addError('The sub-brand is connected with other PO.');
                                }
                            }
                        }
                    }else{
                        pi.addError('The sub-brand code CANNOT be NULL.');
                    } 
                }
            }
            

// Calculate total cost from quantity and unit cost         
            if (pi.ASI_MFM_Total_Cost__c == null && pi.ASI_MFM_Quantity__c != null && pi.ASI_MFM_Unit_Cost__c != null) {
                pi.ASI_MFM_Total_Cost__c = pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Cost__c;
            }           
            System.debug('Plan Line Item Total Cost: ' + pi.ASI_MFM_Total_Cost__c);
// Set values to monthly cost fields if they are not input by user          
            if (pi.ASI_MFM_Total_Cost__c != null && pi.ASI_MFM_Plan_End_Date__c > pi.ASI_MFM_Plan_Start_Date__c &&
                pi.ASI_MFM_Month_1_Cost__c == null && pi.ASI_MFM_Month_2_Cost__c == null && 
                pi.ASI_MFM_Month_3_Cost__c == null && pi.ASI_MFM_Month_4_Cost__c == null && 
                pi.ASI_MFM_Month_5_Cost__c == null && pi.ASI_MFM_Month_6_Cost__c == null && 
                pi.ASI_MFM_Month_7_Cost__c == null && pi.ASI_MFM_Month_8_Cost__c == null &&     
                pi.ASI_MFM_Month_9_Cost__c == null && pi.ASI_MFM_Month_10_Cost__c == null && 
                pi.ASI_MFM_Month_11_Cost__c == null && pi.ASI_MFM_Month_12_Cost__c == null) {

                integer number_of_months = pi.ASI_MFM_Plan_Start_Date__c.monthsBetween(pi.ASI_MFM_Plan_End_Date__c) + 1;    
                decimal monthly_cost = (pi.ASI_MFM_Total_Cost__c / number_of_months).setScale(2);                       
                decimal rounding_err = monthly_cost * number_of_months - pi.ASI_MFM_Total_Cost__c;
                map<integer, decimal> mc_map = new map<integer, decimal>();
                for (integer i = 1; i < 13; i++) {
                    mc_map.put(i, null);
                }
                integer start_month = pi.ASI_MFM_Plan_Start_Date__c.month();
                integer end_month = start_month + number_of_months - 1;
                
                if (start_month < 7) {
                    start_month += 12;
                    end_month += 12;
                }
                decimal monthly_cost_x, cum_cost;
                integer idx;                
                for (integer i = start_month; i <= end_month; i++) {
                    monthly_cost_x = monthly_cost;
                    if (i == end_month) monthly_cost_x -= rounding_err;
                    idx = i - 6;
                    if (idx < 13) {

                        mc_map.put(idx, monthly_cost_x);
                    }
                    else {
                        cum_cost = mc_map.get(12) + monthly_cost_x;
                        mc_map.put(12, cum_cost);                       

                    }
                }
                
                pi.ASI_MFM_Month_1_Cost__c = mc_map.get(1); 
                pi.ASI_MFM_Month_2_Cost__c = mc_map.get(2); 
                pi.ASI_MFM_Month_3_Cost__c = mc_map.get(3); 
                pi.ASI_MFM_Month_4_Cost__c = mc_map.get(4); 
                pi.ASI_MFM_Month_5_Cost__c = mc_map.get(5); 
                pi.ASI_MFM_Month_6_Cost__c = mc_map.get(6);                 
                pi.ASI_MFM_Month_7_Cost__c = mc_map.get(7); 
                pi.ASI_MFM_Month_8_Cost__c = mc_map.get(8); 
                pi.ASI_MFM_Month_9_Cost__c = mc_map.get(9); 
                pi.ASI_MFM_Month_10_Cost__c = mc_map.get(10);   
                pi.ASI_MFM_Month_11_Cost__c = mc_map.get(11);   
                pi.ASI_MFM_Month_12_Cost__c = mc_map.get(12);   
            }
            // Sum up total cost by month cost if total cost is empty and month cost is filled
            else if(pi.ASI_MFM_Total_Cost__c == null &&
                (pi.ASI_MFM_Month_1_Cost__c != null || pi.ASI_MFM_Month_2_Cost__c != null || 
                pi.ASI_MFM_Month_3_Cost__c != null || pi.ASI_MFM_Month_4_Cost__c != null || 
                pi.ASI_MFM_Month_5_Cost__c != null || pi.ASI_MFM_Month_6_Cost__c != null || 
                pi.ASI_MFM_Month_7_Cost__c != null || pi.ASI_MFM_Month_8_Cost__c != null ||     
                pi.ASI_MFM_Month_9_Cost__c != null || pi.ASI_MFM_Month_10_Cost__c != null || 
                pi.ASI_MFM_Month_11_Cost__c != null || pi.ASI_MFM_Month_12_Cost__c != null)){
                    pi.ASI_MFM_Total_Cost__c = 0;
                    if(pi.ASI_MFM_Month_1_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_1_Cost__c;
                    if(pi.ASI_MFM_Month_2_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_2_Cost__c;
                    if(pi.ASI_MFM_Month_3_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_3_Cost__c;
                    if(pi.ASI_MFM_Month_4_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_4_Cost__c;
                    if(pi.ASI_MFM_Month_5_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_5_Cost__c;
                    if(pi.ASI_MFM_Month_6_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_6_Cost__c;
                    if(pi.ASI_MFM_Month_7_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_7_Cost__c;
                    if(pi.ASI_MFM_Month_8_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_8_Cost__c;
                    if(pi.ASI_MFM_Month_9_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_9_Cost__c;
                    if(pi.ASI_MFM_Month_10_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_10_Cost__c;
                    if(pi.ASI_MFM_Month_11_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_11_Cost__c;
                    if(pi.ASI_MFM_Month_12_Cost__c != null)
                        pi.ASI_MFM_Total_Cost__c += pi.ASI_MFM_Month_12_Cost__c;
                }
            // Check consistency of total cost and month cost
            else if(pi.ASI_MFM_Total_Cost__c != null &&
                (pi.ASI_MFM_Month_1_Cost__c != null || pi.ASI_MFM_Month_2_Cost__c != null || 
                pi.ASI_MFM_Month_3_Cost__c != null || pi.ASI_MFM_Month_4_Cost__c != null || 
                pi.ASI_MFM_Month_5_Cost__c != null || pi.ASI_MFM_Month_6_Cost__c != null || 
                pi.ASI_MFM_Month_7_Cost__c != null || pi.ASI_MFM_Month_8_Cost__c != null ||     
                pi.ASI_MFM_Month_9_Cost__c != null || pi.ASI_MFM_Month_10_Cost__c != null || 
                pi.ASI_MFM_Month_11_Cost__c != null || pi.ASI_MFM_Month_12_Cost__c != null)){
                    Decimal tempSum = 0;
                    if(pi.ASI_MFM_Month_1_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_1_Cost__c;
                    if(pi.ASI_MFM_Month_2_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_2_Cost__c;
                    if(pi.ASI_MFM_Month_3_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_3_Cost__c;
                    if(pi.ASI_MFM_Month_4_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_4_Cost__c;
                    if(pi.ASI_MFM_Month_5_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_5_Cost__c;
                    if(pi.ASI_MFM_Month_6_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_6_Cost__c;
                    if(pi.ASI_MFM_Month_7_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_7_Cost__c;
                    if(pi.ASI_MFM_Month_8_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_8_Cost__c;
                    if(pi.ASI_MFM_Month_9_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_9_Cost__c;
                    if(pi.ASI_MFM_Month_10_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_10_Cost__c;
                    if(pi.ASI_MFM_Month_11_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_11_Cost__c;
                    if(pi.ASI_MFM_Month_12_Cost__c != null)
                        tempSum += pi.ASI_MFM_Month_12_Cost__c;
                    if(tempSum != pi.ASI_MFM_Total_Cost__c){
                        pi.addError('Item with Sub-Brand Code: '+pi.ASI_MFM_Sub_Brand_Code_Name__c+' Plan Line Amount('+pi.ASI_MFM_Total_Cost__c+') does not match sum of P1-P12 Cost('+tempSum+')');
                    }
                }
            /*
//Added by Wilken on 20130904 Auto fill A/C Code if user input AP Code only
            if (pi.ASI_MFM_AP_Code__c != null && pi.ASI_MFM_A_C_Code__c == null){
                System.debug('A/C Code: ' + pi.ASI_MFM_AP_Code__r.ASI_MFM_A_C_Code__c);
                ASI_MFM_AP_Code__c apCode = [select ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where id = :pi.ASI_MFM_AP_Code__c];
                if (apCode.ASI_MFM_A_C_Code__c != null){
                    pi.ASI_MFM_A_C_Code__c = apCode.ASI_MFM_A_C_Code__c;
                }
            }*/
             
        }
    }

    
    
    
}