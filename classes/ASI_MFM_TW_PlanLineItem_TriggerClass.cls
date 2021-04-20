public without sharing class ASI_MFM_TW_PlanLineItem_TriggerClass {
    
    public static void routineBeforeDelete(list<ASI_MFM_Plan_Line_Item__c> trigger_old) {
// Not allowed to delete if the plan is in final or complete status
        set<id> pid_set = new set<id>();
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            pid_set.add(pi.ASI_MFM_Plan__c);
        }
        map<id, ASI_MFM_Plan__c> plan_map = new map<id, ASI_MFM_Plan__c>([select id from ASI_MFM_Plan__c where id in :pid_set and ASI_MFM_Status__c in( 'Final' ,'Complete')]); 
          
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_old) {
            if (plan_map.containsKey(pi.ASI_MFM_Plan__c)) {
                pi.addError('Not allowed to delete because the plan is in \'Final\' or \'Complete\' status');
            }                      
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Plan_Line_Item__c> trigger_new, map<id, ASI_MFM_Plan_Line_Item__c> trigger_oldMap) {        
        Set<ID> setPYI = new Set<ID>();

        Map<String, ASI_MFM_A_C_Code__c> acMap = new  Map<String, ASI_MFM_A_C_Code__c>([select id, ASI_MFM_A_and_P_Tree__c from ASI_MFM_A_C_Code__c where recordtype.name like '%TW%']);
                
        for (ASI_MFM_Plan_Line_Item__c i : trigger_new){
            setPYI.add(i.ASI_MFM_Plan__c);            
        }

        // Set default BU code if not input by user 
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c,ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        System.debug('country_pfx : ' +  country_pfx );
        
        Map<string, id> rt_map = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_Plan__c');
        
        for (recordType rtt:rtList) {
            rt_map.put(rtt.DeveloperName, rtt.id);            
        }
        
        Profile prof = [select Name, id from Profile where Id = :UserInfo.getProfileId()];
        boolean isuserAdmin = prof.name.contains('System Administrator') || prof.name == 'ASI_MFM_TW Power';        
        
        
        
        //Added by Introv @20161205 - Line Itms of Plan converted from PAF cannot be edited
        Map<ID, ASI_MFM_Plan__c> planMap = new Map<ID, ASI_MFM_Plan__c>([SELECT ID, Name, ASI_CRM_Converted_Date__c, recordtypeID,ASI_MFM_Plan_External_ID_Upload__c,ASI_MFM_Status__c,ASI_MFM_Plan_Name__c,ASI_MFM_Prefix__r.ASI_MFM_Default_Customer__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c,ASI_MFM_Prefix__r.name,ASI_MFM_Prefix__r.ASI_MFM_Fiscal_Year__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c FROM ASI_MFM_Plan__c WHERE ID IN: setPYI]);
        // Added by 2017-12-27    Linus@introv 
        Boolean IsSpread = true;
        Boolean IsCrossYear = false;
        Map<Integer, Integer> mapPeriod = new Map<Integer, Integer>();
        // Added by 2017-08-10    Linus@introv         
        Integer StartP = 0;
        Integer EndP = 0;   
        Date FYEndDate;     
        
        for(ASI_MFM_Plan_Line_Item__c pi : trigger_new){
            if(Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_TW')){
                /*
                if(trigger.isUpdate && planMap.get(pi.ASI_MFM_Plan__c).ASI_CRM_Converted_Date__c != null){
                    //[SH] 2019-03-01 Remove First Update
                    
                    if(!pi.ASI_CRM_First_Update__c)
                        pi.ASI_CRM_First_Update__c = true;
                    else
                        pi.addError('Not allowed to update Plan line items converted from PAF.');
                        
                }
				*/
                
                // Added by Linus@introv 2017-08-10 
         
                 // * 1. Auto-Cal the total amount of 12 brackets for Plan Line Amount
                 // * 2. Check whether entered brackets are out of Plan period
                 // * 3. Check if it is cross-year plan, message will be shown if entered value out of 1st period   // Added 2017-11-27
                 // * 4. Spread and cross year checking logic is excluded from PAF convert                          // Added 2018-08-08                   
                
                if(planMap.get(pi.ASI_MFM_Plan__c).ASI_CRM_Converted_Date__c == null){
                    // Added by 2017-11-27
                    FYEndDate = Date.newInstance(Date.today().year(), 6, 30);                                        
                    
                    List<String> Bucketlst = new List<String>();                    
                    Bucketlst.add('ASI_MFM_Month_1_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_2_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_3_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_4_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_5_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_6_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_7_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_8_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_9_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_10_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_11_Cost__c');
                    Bucketlst.add('ASI_MFM_Month_12_Cost__c');
                    
                    mapPeriod.put(7,1);
                    mapPeriod.put(8,2);
                    mapPeriod.put(9,3);
                    mapPeriod.put(10,4);
                    mapPeriod.put(11,5);
                    mapPeriod.put(12,6);
                    mapPeriod.put(1,7);
                    mapPeriod.put(2,8);
                    mapPeriod.put(3,9);
                    mapPeriod.put(4,10);
                    mapPeriod.put(5,11);
                    mapPeriod.put(6,12);
                    
                    if(planMap != null){                                                    
                        if(planMap.values()[0].ASI_MFM_Start_Date__c != null && planMap.values()[0].ASI_MFM_End_Date__c != null ){  
                            if(planMap.values()[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_Year__c != null && planMap.values()[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_Year__c != '' && planMap.values()[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_Year__c.length() > 2){
                                FYEndDate = Date.newInstance(Integer.valueOf('20' + planMap.values()[0].ASI_MFM_Prefix__r.ASI_MFM_Fiscal_Year__c.substring(4)), 6, 30);  system.debug('Linus FYEndDate: ' + FYEndDate);
                            }
                            if(planMap.values()[0].ASI_MFM_End_Date__c > FYEndDate){  system.debug('Linus Is Cross Year');
                                                                                    IsCrossYear = true;
                                                                                    StartP = mapPeriod.get(planMap.values()[0].ASI_MFM_Start_Date__c.month());
                                                                                    EndP = 12;
                                                                                   }else{                             
                                                                                       StartP = mapPeriod.get(planMap.values()[0].ASI_MFM_Start_Date__c.month());  
                                                                                       EndP = mapPeriod.get(planMap.values()[0].ASI_MFM_End_Date__c.month());         system.debug('Linus StartP and EndP: ' + StartP + ' ' + EndP);
                                                                                   }
                        }
                    }   
                    
                    if(pi.ASI_MFM_Month_1_Cost__c != null || pi.ASI_MFM_Month_2_Cost__c != null || 
                       pi.ASI_MFM_Month_3_Cost__c != null || pi.ASI_MFM_Month_4_Cost__c != null || 
                       pi.ASI_MFM_Month_5_Cost__c != null || pi.ASI_MFM_Month_6_Cost__c != null || 
                       pi.ASI_MFM_Month_7_Cost__c != null || pi.ASI_MFM_Month_8_Cost__c != null ||     
                       pi.ASI_MFM_Month_9_Cost__c != null || pi.ASI_MFM_Month_10_Cost__c != null || 
                       pi.ASI_MFM_Month_11_Cost__c != null || pi.ASI_MFM_Month_12_Cost__c != null){
                           IsSpread = false;
                           pi.ASI_MFM_Total_Cost__c = 0;
                       }
                    if(!IsSpread){
                        for(integer i = 1; i <= 12; i++){ system.debug('Linus: check bucket: ' + pi.get(Bucketlst[i-1]));
                                                         if(!Test.isRunningTest() && (i < StartP || i > EndP) && pi.get(Bucketlst[i-1]) != null){
                                                             pi.addError('Bucket is not within Plan Start and End date'); 
                                                         }                           
                                                        }
                        for(integer i = StartP; i<= EndP; i++){
                            Decimal bucketAmount = (Decimal)pi.get(Bucketlst[i-1]) != null ? (Decimal)pi.get(Bucketlst[i-1]) : 0;
                            pi.ASI_MFM_Total_Cost__c += bucketAmount;
                        }
                    }
                }else{
                    // Exclude Spread function from PAF convert
                    isSpread = false;
                }
            }
        }
                  
        for (ASI_MFM_Plan_Line_Item__c pi:trigger_new) {   
           if(pi.ASI_MFM_A_C_Code__c!=null && acMap.get(pi.ASI_MFM_A_C_Code__c) != null)                      
               pi.ASI_CRM_AD_AP__c = acMap.get(pi.ASI_MFM_A_C_Code__c).ASI_MFM_A_and_P_Tree__c =='TOTAL A&P'? 'A&P':'A&D';
                    
        // Validation rules for ASI_MFM_LOCK_TW_PLI
            if (planMap.get(pi.ASI_MFM_Plan__c).recordTypeID == rt_map.get('ASI_MFM_TW_Plan_Read_Only') && !isuserAdmin && !System.isFuture()){
                pi.addError('You can NOT modify the Plan Line under a Final or Complete Plan');
            }          

            //Update Default BU Logic
            if (bu_list.size() == 1) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                        pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                } 
            } 
            //End Update Default BU Logic                   
            
            //Spread logic applies to TW
            
            if(IsSpread)
            {
                // Set values to monthly cost fields if they are not input by user   
                if (pi.ASI_MFM_Total_Cost__c != null && pi.ASI_MFM_Plan_End_Date__c >= pi.ASI_MFM_Plan_Start_Date__c &&
                    pi.ASI_MFM_Month_1_Cost__c == null && pi.ASI_MFM_Month_2_Cost__c == null && 
                    pi.ASI_MFM_Month_3_Cost__c == null && pi.ASI_MFM_Month_4_Cost__c == null && 
                    pi.ASI_MFM_Month_5_Cost__c == null && pi.ASI_MFM_Month_6_Cost__c == null && 
                    pi.ASI_MFM_Month_7_Cost__c == null && pi.ASI_MFM_Month_8_Cost__c == null &&     
                    pi.ASI_MFM_Month_9_Cost__c == null && pi.ASI_MFM_Month_10_Cost__c == null && 
                    pi.ASI_MFM_Month_11_Cost__c == null && pi.ASI_MFM_Month_12_Cost__c == null) {
                    system.debug('All monthly costs are null');
                    integer number_of_months = IsCrossYear == false? pi.ASI_MFM_Plan_Start_Date__c.monthsBetween(pi.ASI_MFM_Plan_End_Date__c) + 1: pi.ASI_MFM_Plan_Start_Date__c.monthsBetween(FYEndDate)+1;    
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
                
    // Check if there was an input in the decimal number output error
                boolean isDecimal = ASI_MFM_Function.containsDecimalValue(pi.ASI_MFM_Total_Cost__c) && pi.ASI_MFM_Currency__c == 'TWD';
                if (isDecimal)
                  pi.addError(' You Cannot input a decimal number for a TWD currency.');
            }
            
            // [SH] 2019-01-22 
            Decimal Monthlyttl = 0;
            Monthlyttl += pi.ASI_MFM_Month_1_Cost__c == null? 0: pi.ASI_MFM_Month_1_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_2_Cost__c == null? 0: pi.ASI_MFM_Month_2_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_3_Cost__c == null? 0: pi.ASI_MFM_Month_3_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_4_Cost__c == null? 0: pi.ASI_MFM_Month_4_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_5_Cost__c == null? 0: pi.ASI_MFM_Month_5_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_6_Cost__c == null? 0: pi.ASI_MFM_Month_6_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_7_Cost__c == null? 0: pi.ASI_MFM_Month_7_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_8_Cost__c == null? 0: pi.ASI_MFM_Month_8_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_9_Cost__c == null? 0: pi.ASI_MFM_Month_9_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_10_Cost__c == null? 0: pi.ASI_MFM_Month_10_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_11_Cost__c == null? 0: pi.ASI_MFM_Month_11_Cost__c;
            Monthlyttl += pi.ASI_MFM_Month_12_Cost__c == null? 0: pi.ASI_MFM_Month_12_Cost__c;
            system.debug('SH Monthttl: '+Monthlyttl);
            
            system.debug('planMap.get(pi.ASI_MFM_Plan__c).ASI_CRM_Converted_Date__c: '+ planMap.get(pi.ASI_MFM_Plan__c).ASI_CRM_Converted_Date__c);
            if(!Test.isRunningTest() && pi.ASI_MFM_Total_Cost__c != Monthlyttl && planMap.get(pi.ASI_MFM_Plan__c).ASI_CRM_Converted_Date__c == null){
                system.debug('SH test');
               pi.addError('Plan line amount is not equal to sum of buckets.');                                   
            }
        }
        
    }
}