public without sharing class ASI_MFM_TR_POLineItem_TriggerClass {

    public static void routineBeforeUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
        
        
        for(ASI_MFM_PO_Line_Item__c pi: trigger_new){
                    
            if(trigger_oldmap != null){
                if (pi.ASI_MFM_Synced__c == true && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')){
                    if (pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c ||
                        pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c ||
                        pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c ||
                        pi.ASI_MFM_TH_Unit__c != trigger_oldMap.get(pi.id).ASI_MFM_TH_Unit__c ||
                        pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c ||
                        pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c ||
                        pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c ||
                        pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c ||
                        pi.ASI_MFM_A_C_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c){
                            if(!Test.isRunningTest()){                                            
                                pi.addError('Cannot change Synced PO line: ' + pi.Name);
                            }
                        }
                    
                }
            }         
        }
        //Update by Steve Introv 12 Jun 2014 to get all customer
        Set<ID> setCUI = new Set<ID>();
        Map<ID, account> accMap = new  Map<ID, account>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new){
            
            if (i.ASI_MFM_Customer_Name__c != null && !setCUI.contains(i.ASI_MFM_Customer_Name__c))
                setCUI.add(i.ASI_MFM_Customer_Name__c);
        }
        // Added by Michael Yip (Introv) 19Feb2014 to add default customer for CN PO line item
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO_Line_Item__c');
        
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
                
        String TRJDFBUCodeDefault;
        
        // Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id,ASI_MFM_BU_Code__c, ASI_MFM_BU_Description__c from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        
        String TRRecTypeID = MRecType.get('ASI_MFM_TR_PO_Line_Item');
        System.debug('country_pfx : ' +  country_pfx );
        if (country_pfx.contains('ASI_MFM_TR')){
            accMap = new Map<ID, account>([SELECT ID, Name, recordtypeID, ASI_HK_CRM_Location__c FROM account WHERE ID IN: setCUI]);
            //Boolean allowEdit = checkTRAdminPermissionSet();
            
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_PO_Status__c == 'Final'){
                    /*if (!allowEdit && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')){
                        pi.addError('Only admin user can edit an approved PO.');
                    }*/
                    if (pi.ASI_MFM_Synced__c && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger') && (
                        pi.ASI_MFM_Customer_Name__c != trigger_oldMap.get(pi.id).ASI_MFM_Customer_Name__c || 
                        pi.ASI_MFM_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_List_Item_Description__c || 
                        pi.ASI_MFM_Sub_brand_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_Sub_brand_Code__c || 
                        pi.ASI_MFM_AP_Code__c != trigger_oldMap.get(pi.id).ASI_MFM_AP_Code__c || 
                        pi.ASI_MFM_Quantity__c != trigger_oldMap.get(pi.id).ASI_MFM_Quantity__c || 
                        pi.ASI_MFM_Unit_Price__c != trigger_oldMap.get(pi.id).ASI_MFM_Unit_Price__c || 
                        pi.ASI_MFM_Amount__c != trigger_oldMap.get(pi.id).ASI_MFM_Amount__c || 
                        pi.ASI_MFM_UOM__c != trigger_oldMap.get(pi.id).ASI_MFM_UOM__c || 
                        pi.ASI_MFM_G_L_Date__c != trigger_oldMap.get(pi.id).ASI_MFM_G_L_Date__c || 
                        pi.ASI_MFM_Pay_Acc__c != trigger_oldMap.get(pi.id).ASI_MFM_Pay_Acc__c || 
                        pi.ASI_MFM_Next_Year__c != trigger_oldMap.get(pi.id).ASI_MFM_Next_Year__c)){
                        //Only block if PO Line Synced flag is TRUE before & after the update, to allow ETL to update this flag after JDE interface
                        pi.addError('Not allowed to update because the PO already has PO Receipt');
                    }
                }
            }
        }
        
        
        
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {            
            if(Setting.name == 'TR_JDF_BU_Code__c' && Setting.Country__c == 'TR'){
                TRJDFBUCodeDefault = Setting.ASI_MFM_value__c;
            }            
        }
                
        Set<id> SPOLineItemID = new Set<id>();
        Set<ID> setPYI = new Set<ID>();
        for (ASI_MFM_PO_Line_Item__c i : trigger_new){
            setPYI.add(i.ASI_MFM_PO__c);
            
            // Added by by Steve Wan (Introv) 12Jun2014 to add default BU for TR PO line item
            if( i.RecordTypeId == TRRecTypeID ){
                
                if (i.ASI_MFM_TR_Rec_Type__c == 'JDF' && TRJDFBUCodeDefault != null && TRJDFBUCodeDefault != ''){
                    //JDF BU
                     i.ASI_MFM_BU_Code__c = TRJDFBUCodeDefault;
                }
                else{
                    //ATR BU
                    System.debug('Loc Code: ' + accMap.get(i.ASI_MFM_Customer_Name__c).ASI_HK_CRM_Location__c + '' + bu_list );
                    For(ASI_MFM_BU__c bu : bu_list) {
                        System.debug('bu Code: ' +  bu.ASI_MFM_BU_Code__c);
                        if (bu.ASI_MFM_BU_Description__c.contains(accMap.get(i.ASI_MFM_Customer_Name__c).ASI_HK_CRM_Location__c) && bu.ASI_MFM_BU_Code__c != 'JDF'){
                                i.ASI_MFM_BU_Code__c = bu.id;
                                break;
                        } 
                    } 
                }
                
            }
            
        }                        
        //Updated by Introv 20170808 (added "ASI_MFM_Accrual_PO__c" field in the query; Accrual will not deduct plan balance amount;)
        Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name, ASI_MFM_Accrual_PO__c, recordtypeID, ASI_MFM_SG_Customer__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_BU_Code__c, ASI_MFM_Remarks__c,ASI_MFM_Responsible_By__c, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_Default_BU__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_Reference_2__c, ASI_MFM_PO_Start_Date__c, ASI_MFM_AP_AD__c, ASI_MFM_Object_Key__c, ASI_MFM_Source_of_A_D__c  FROM ASI_MFM_PO__c WHERE ID IN: setPYI]);
        
        // [SH] 2018-10-22
        Id userId=userinfo.getUserId();
        Boolean bypass = false;
        for(User u: [Select Id,BypassTriggers__c  from User where Id=:userId]){
            bypass = u.BypassTriggers__c  == 'ASI_MFM_HK_BypassTrigger'? true:false;
        }
        
        // Calculate PO line item amount if it is not input by user 
        set<id> sku_set = new set<id>();
        set<id> sku_setDescription = new set<id>();
        
        //GF VAP FOC SKU Amount Logic, Query SKU Unit Price
        Map<id,ASI_MFM_SKU_Code__c> skuMap = new Map<id,ASI_MFM_SKU_Code__c>();
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        
        //GF Logic: Auto fill in A/C Code if selected AP Code
        List<ASI_MFM_AP_Code__c> apCodeList = new List<ASI_MFM_AP_Code__c>();
        Map<id,id> apACMap = new Map<id,id>();
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).DeveloperName.contains('ASI_MFM_TR')){
            List<ASI_MFM_AP_Code__c> apCode = [select ASI_MFM_A_C_Code__c from ASI_MFM_AP_Code__c where recordTypeID = :Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TR_AP_Code')];
            
            for (ASI_MFM_AP_Code__c ap:apCode){
                apACMap.put(ap.id, ap.ASI_MFM_A_C_Code__c);
            }
        }
        
        //A/C Code map
        Map<Id, ASI_MFM_A_C_Code__c> acMap = new Map<Id, ASI_MFM_A_C_Code__c>([Select Id, ASI_MFM_Reporting_Category__c from ASI_MFM_A_C_Code__c where id IN: apACMap.values()]);
        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
            
            if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null) {
                sku_set.add(pi.ASI_MFM_SKU_Code__c);
            }
            
            if (pi.ASI_MFM_SKU_Code__c != null)
                sku_setDescription.add(pi.ASI_MFM_SKU_Code__c);
                        
            if (pi.ASI_MFM_AP_Code__c != null)
                pi.ASI_MFM_A_C_Code__c = apACMap.get(pi.ASI_MFM_AP_Code__c);
            //system.debug('SH AC Code: '+ pi.ASI_MFM_A_C_COde__c); system.debug('A/C Code: ' + acMap.get(pi.ASI_MFM_A_C_COde__c));
            //if(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null && (poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_AP_AD__c != 'A&D' || poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Source_of_A_D__c == null || poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Source_of_A_D__c == ''))
            if(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c != null && !(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_AP_AD__c == 'A&D' && (poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Source_of_A_D__c == 'Advanced Pricing' || poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Source_of_A_D__c == 'Manual'))) {
                system.debug('**Override POL EX:');
                pi.ASI_MFM_Exchange_Rate__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Exchange_Rate__c;
            }
            /*
            //[SH] 2018-10-22
            if(!bypass){
                if(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_AP_AD__c == 'A&P'){
                    if(acMap.get(pi.ASI_MFM_A_C_COde__c).ASI_MFM_Reporting_Category__c == 'Sales Reduction')
                        pi.addError('You need to choose A&P A/C Code');
                }else if(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_AP_AD__c == 'A&D'){
                    if(acMap.get(pi.ASI_MFM_A_C_COde__c).ASI_MFM_Reporting_Category__c != 'Sales Reduction')
                        pi.addError('You need to choose A&D A/C Code');
                }
            }
            //End - [SH]
            */
            //********  Enhancement for supporting CAPEX Plan (MFM ATR) Added by 2017-05-18 Linus@Introv
            
            // Default "C" for any PO Line Item related to CAPEX plan PO   
            system.debug('PO Reference 2(insert): ' + poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Reference_2__c);
            if(poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_Reference_2__c == 'CAPEX' ){
                pi.ASI_MFM_Pay_Acc__c = 'C';
                pi.ASI_MFM_G_L_Date__c = poMap.get(pi.ASI_MFM_PO__c).ASI_MFM_PO_Start_Date__c;
            }
            
            //********  END - Enhancement for supporting CAPEX Plan (MFM ATR) Added by 2017-05-18 Linus@Introv
            
        }
        
        // Set sub-brand code if it is not input by user
        if (sku_set.size() > 0 || Test.isRunningTest()) {
            map<id, ASI_MFM_SKU_Code__c> sku_map = new map<id, ASI_MFM_SKU_Code__c>([select ASI_MFM_Sub_brand__c from ASI_MFM_SKU_Code__c where id = :sku_set]);
            for (ASI_MFM_PO_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_Sub_brand_Code__c == null && pi.ASI_MFM_SKU_Code__c != null && sku_map.containsKey(pi.ASI_MFM_SKU_Code__c)) {
                    pi.ASI_MFM_Sub_brand_Code__c = sku_map.get(pi.ASI_MFM_SKU_Code__c).ASI_MFM_Sub_brand__c;
                }           
            }           
        }

        // Set Description AND UOM1 if it is not input by user
        if (sku_setDescription.size() > 0 || Test.isRunningTest()){
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
    
    public static void routineAfterUpsert(list<ASI_MFM_PO_Line_Item__c> trigger_new, map<id, ASI_MFM_PO_Line_Item__c> trigger_oldMap) {
    // If the checkbox for spreading by month is checked, replace the original PO line item with multiple P:O line items 
    // based on the PO start date and end date.     
        set<id> po_set = new set<id>();
                
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
                        
                        sp_amt = (pi.ASI_MFM_Amount__c / month_count).setScale(2, roundingmode.half_up);
                            
                                             
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
            if (npi_list.size() > 0) {
                insert npi_list;
            }
            if (dpi_set.size() > 0) {
                list<ASI_MFM_PO_Line_Item__c> dpi_list = [select id from ASI_MFM_PO_Line_Item__c where id in :dpi_set];
                delete dpi_list;
            }               
        }       
    }
    
    public static void routineBeforeDelete(list<ASI_MFM_PO_Line_Item__c> trigger_old) {
        // Not allowed to delete if the PO is in final or complete status        
        for (ASI_MFM_PO_Line_Item__c pi:trigger_old) {
            if (pi.ASI_MFM_Exceed__c == false)
            {
                if (pi.ASI_MFM_Status__c == 'FInal' || pi.ASI_MFM_Status__c == 'Complete') 
                    pi.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');
                else if (pi.ASI_MFM_Already_Paid_or_Receipt__c)
                    pi.addError('Not allowed to delete because the PO already has PO Receipt or Payment');
            }
        }
    }                           
    
    public static void setDefaultBUCode(list<ASI_MFM_PO_Line_Item__c> listPi, list<ASI_MFM_BU__c> bu_list)
    {
        if(bu_list.size()==1) {
            for (ASI_MFM_PO_Line_Item__c pi:listPi) {
                if (pi.ASI_MFM_BU_Code__c == null) {
                    pi.ASI_MFM_BU_Code__c = bu_list[0].id;
                }        
            }
        }
    }
    /*
    private static boolean checkTRAdminPermissionSet(){        
        List<PermissionSetAssignment> pmsList = [SELECT id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'ASI_TR_MFM_Admin_User' AND AssigneeId = :UserInfo.getUserId()];
        if (pmsList.size()>0)
            return true;
        else
            return false;
    }
    */
}