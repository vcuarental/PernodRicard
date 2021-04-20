/*Filename:        ASI_CRM_TW_PAFConvertToPlan_Ctrl.cls
* Author:          Twinkle LI (Introv Limited)
* Purpose:         Controller Class for converting PAF to Plan
* Created Date:    2016/10/27
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_PAFConvertToPlan_Ctrl{
    map<string, asi_mfm_role_prefix_relationship__c> px_map = new map<string, asi_mfm_role_prefix_relationship__c>();       
    public list<selectOption> available_prefixes {get; private set;}
    public string selected_prefix {get; set;}
    
    //get header info.
    public id preAppFormId {set; get;}
    public List<ASI_HK_CRM_Pre_Approval_Form__c> preAppForm {set; get;}
    
    //get detail items info.
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listPreAppFormItem {set; get;}
    
    //plan
    public List<ASI_MFM_Plan__c> convertedPlan {set; get;}
    
    public Boolean boolAllowConverted {set; get;}
    
    //controller
    public ASI_CRM_TW_PAFConvertToPlan_Ctrl(ApexPages.StandardController controller) {
        preAppFormId = ApexPages.currentPage().getParameters().get('id');
        system.debug(preAppFormId);
        init();
    }

    public String sizeConverter(Decimal sizeNumber) {
        if(sizeNumber < 1000)
            return String.valueof(sizeNumber) + 'ml';
        else 
            return String.valueof((sizeNumber / 1000).setScale(2, roundingmode.half_up)) + 'L';
    }
    
    public void init(){
        boolAllowConverted = true;
        
        if(preAppFormId != NULL){
            preAppForm = [SELECT id, Name, OwnerId, ASI_HK_CRM_PAF_Status__c, ASI_CRM_Commitment_No__c, ASI_HK_CRM_PAF_Customer__c, ASI_HK_CRM_PAF_Start_Date__c, ASI_HK_CRM_PAF_End_Date__c, 
                          ASI_CRM_Valid_Invoice__c, ASI_CRM_Region__c, ASI_CRM_Outlet_Type__c, ASI_CRM_Outlet_Grade__c, ASI_CRM_Channel__c, ASI_CRM_Sub_Channel__c, 
                          ASI_CRM_Sales_Representative__c, ASI_HK_CRM_PAF_Customer__r.ASI_TH_CRM_Region__c, ASI_CRM_Customer__r.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c,
                          ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c, ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c, ASI_CRM_Converted_Date__c, ASI_CRM_Commitment_Status__c,
						  ASI_CRM_Channel__r.ASI_CRM_TW_Default_FOC_A_C_Code__c, ASI_CRM_Channel__r.ASI_CRM_TW_Default_Cash_A_C_Code__c
                          FROM ASI_HK_CRM_Pre_Approval_Form__c 
                          WHERE id =: preAppFormId LIMIT 1];
            
            if(preAppForm[0].ASI_CRM_Commitment_No__c != NULL){          
                convertedPlan = [SELECT id, ASI_CRM_Converted_Date__c FROM ASI_MFM_Plan__c WHERE id =: preAppForm[0].ASI_CRM_Commitment_No__c LIMIT 1];
            }
        }
    }
    
    public pageReference getPrefixes(){
        system.debug(preAppForm[0].ASI_CRM_Commitment_Status__c);
        String fiscalYear;
        if(preAppForm[0].ASI_CRM_Commitment_Status__c != null && preAppForm[0].ASI_CRM_Commitment_Status__c != 'Draft'){
            boolAllowConverted = false;
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Convert failed, Converted Plan is not in \'Draft\' Status.');
            apexpages.addmessage(err); 
            
            return null;
        }
        /*else if(preAppForm[0].ASI_HK_CRM_PAF_Status__c == 'Rejected'){
            boolAllowConverted = false;
            apexpages.message err = new apexpages.message(apexpages.severity.error, '\'Rejected\' PAF cannot be converted anymore.');
            apexpages.addmessage(err); 
            
            return null;
        }*/
        else if(preAppForm[0].ASI_HK_CRM_PAF_Status__c == 'Draft'){
            boolAllowConverted = false;
            apexpages.message err = new apexpages.message(apexpages.severity.error, '\'Draft\' PAF cannot be converted.');
            apexpages.addmessage(err); 
            
            return null;
        }
            
        if(preAppForm[0].ASI_CRM_Commitment_No__c != NULL){
            return proceed();
        }
        else{
            user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
            if (u.userRole.developerName == null) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The role of the user is not defined yet');
                apexpages.addmessage(err); 
            }
            else if (u.asi_mfm_country__c == null) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The country of the user is not defined yet');
                apexpages.addmessage(err); 
            }
            else {
                list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();
                fiscalYear = getFiscalYear(preAppForm[0].ASI_HK_CRM_PAF_Start_Date__c); //and asi_mfm_prefix__r.ASI_MFM_Fiscal_year__c =:fiscalYear

                /* 2019-01-14 Mofify by Michael Wu (Introv)
                     Revise ASI_CRM_TW_PAFConvertToPlan_Page to select PAF Prefix only
                */
                for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name,asi_mfm_prefix__r.RecordType.DeveloperName, asi_mfm_prefix__r.ASI_MFM_PAF_Prefix__c from asi_mfm_role_prefix_relationship__c
                                                             where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Plan' 
                                                             and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c
                                                             order by asi_mfm_prefix__r.name]) {
                                                                 px_map.put(px.asi_mfm_prefix__c, px);
                                                                 px_list.add(px);    
                                                                 
                                                             }

                if (px_list.size() == 0) {
                    apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input plans');
                    apexpages.addmessage(err); 
                }
                else if (px_list.size() == 1) {
                    if(u.asi_mfm_country__c != 'TW')
                    {
                        selected_prefix = px_list[0].asi_mfm_prefix__c;
                        return proceed();
                    }
                    else
                    {
                        if(px_list[0].asi_mfm_prefix__r.ASI_MFM_PAF_Prefix__c == true)
                        {
                            selected_prefix = px_list[0].asi_mfm_prefix__c;
                            return proceed();
                        }
                        else
                        {
                            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input plans');
                            apexpages.addmessage(err); 
                        }
                        return null;
                    }
                }
                else {
                    available_prefixes = new list<selectOption>();
                    available_prefixes.add(new selectOption('', '-- None --'));
                    if(u.asi_mfm_country__c != 'TW'){
                        for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                            available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                        }
                    }
                    else{
                        for (asi_mfm_role_prefix_relationship__c rp:px_list) {
                            if(rp.asi_mfm_prefix__r.ASI_MFM_PAF_Prefix__c == true){
                                available_prefixes.add(new selectOption(rp.asi_mfm_prefix__c, rp.asi_mfm_prefix__r.name));
                            }
                        }
                    }

                    if(available_prefixes.size()==0){
                        apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input plans');
                        apexpages.addmessage(err);
                    }
                    else if(available_prefixes.size()==1){
                        selected_prefix = available_prefixes[0].getvalue();
                        return proceed();
                    }
                }
            }       
        }
        return null;
    }
    
    private static string getFiscalYear(Date startDate){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = startDate;
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;

        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }       
        return Current_Fiscal_year;
    }
    
    public pageReference proceed() {
        Boolean allSuccess = TRUE;
        System.Savepoint sp = database.setSavepoint();
        
        List<Account> listAccount = new List<Account>();
        List<ASI_MFM_Plan_Line_Item__c> listConvertedPlanItm = new List<ASI_MFM_Plan_Line_Item__c>();
        List<ASI_MFM_Plan_Line_Item__c> listToDeletePlanItm = new List<ASI_MFM_Plan_Line_Item__c>();
         
        //if no prefix selected
        if (preAppForm[0].ASI_CRM_Commitment_No__c == NULL && (selected_prefix == null || selected_prefix == '')) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Please select prefix first.');
            apexpages.addmessage(err); 
            return null;            
        }
        else {
            if(this.preAppForm.size() > 0 && this.preAppForm[0] != NULL){
                //find the matching TW Supplier for Plan Line Item
                listAccount = [SELECT id FROM Account WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('AccountASI_MFM_TW_Customer') AND ASI_MFM_Channel__c =: preAppForm[0].ASI_CRM_Customer__r.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c AND ASI_TH_CRM_Region__c =: preAppForm[0].ASI_HK_CRM_PAF_Customer__r.ASI_TH_CRM_Region__c];
                
                listPreAppFormItem = [SELECT id, Name, RecordTypeId, ASI_HK_CRM_Pre_Approval_Form_Lookup__c, ASI_CRM_Cash_or_FOC__c, ASI_CRM_AD_or_AP__c, ASI_CRM_Contracted_Item__c, ASI_CRM_FOC_Item__c, ASI_CRM_Cash_Per_Bottle_w_VAT__c, 
                                     ASI_CRM_Expenses_Product__c, ASI_CRM_FOC_Volume__c, ASI_CRM_Q1_hrs__c, ASI_CRM_Q2_hrs__c, ASI_CRM_Q3_hrs__c, ASI_CRM_Q4_hrs__c, ASI_CRM_Sub_Total_hrs__c, ASI_CRM_Cost_Hr_w_VAT__c, 
                                     ASI_CRM_Total_PG_Cost__c, ASI_CRM_Cash_Amounts_w_VAT__c, ASI_HK_CRM_Target_Volume_Qty__c, ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Free_Bottle_Option_1__c, ASI_HK_CRM_Mechanic__c , 
                                     ASI_HK_CRM_Mechanic__r.Name, ASI_CRM_Contracted_Item__r.ASI_MFM_Sub_brand__c, ASI_CRM_Contracted_Item__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c,
                                     ASI_CRM_FOC_Item__r.ASI_MFM_Sub_brand__c, ASI_CRM_FOC_Item__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c, ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c, ASI_CRM_Contracted_Item__r.ASI_MFM_Item_Group_Code__c,
                                     ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_No_of_Outlets__c, ASI_CRM_Expenses_Product__r.ASI_MFM_Sub_brand__c, ASI_CRM_Expenses_Product__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c, 
                                     ASI_HK_CRM_Mechanic__r.ASI_CRM_A_C_Code__c, ASI_HK_CRM_Mechanic__r.ASI_CRM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c, ASI_HK_CRM_Mechanic__r.ASI_CRM_Exclude_from_Plan_Conversion__c, ASI_CRM_Mechanic_Detail__c,
                                     ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c, ASI_CRM_Expenses_Product__r.ASI_MFM_Item_Group_Code__c, ASI_CRM_FOC_Item__r.ASI_MFM_Item_Group_Code__c
                                      FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
                                      WHERE (RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment') OR
                                             RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') OR
                                             RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'))
                                            AND ASI_HK_CRM_Pre_Approval_Form_Lookup__c =: preAppFormId Order By CreatedDate ASC];
            }
            
           //Convert PAF to Plan
            if(this.preAppForm.size() > 0 && this.preAppForm[0] != NULL && preAppForm[0].ASI_CRM_Commitment_No__c == NULL){
                convertedPlan = new List<ASI_MFM_Plan__c>();
                convertedPlan.add(new ASI_MFM_Plan__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), ASI_MFM_Prefix__c = selected_prefix));
                convertedPlan[0].OwnerId = preAppForm[0].OwnerId;
                convertedPlan[0].ASI_MFM_TW_Related_PAF__c =preAppForm[0].Id;
            }
            
            system.debug(preAppForm[0].ASI_HK_CRM_PAF_Customer__c);
            convertedPlan[0].ASI_MFM_Account__c = preAppForm[0].ASI_HK_CRM_PAF_Customer__c;
            convertedPlan[0].ASI_MFM_Start_Date__c = preAppForm[0].ASI_HK_CRM_PAF_Start_Date__c;
            convertedPlan[0].ASI_MFM_End_Date__c = preAppForm[0].ASI_HK_CRM_PAF_End_Date__c; 
            convertedPlan[0].ASI_CRM_Converted_Date__c = System.now();
            
            //upsert Plan
            //try {        
            upsert convertedPlan;
            system.debug(convertedPlan);
            /*}catch (DmlException dmle) {
                allSuccess = FALSE;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '-'+dmle));
                system.debug(dmle);
                database.rollback(sp);
            }*/
            
            //get previous Plan Line Items to delete
            if(convertedPlan != NULL && convertedPlan.size() > 0 && convertedPlan[0].id != NULL){
                listToDeletePlanItm = [SELECT id FROM ASI_MFM_Plan_Line_Item__c WHERE ASI_MFM_Plan__c =: convertedPlan[0].id];
            }
            
            //get set of item group id included in paf items
            Set<id> setItmGroupId = new Set<id>();
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem : listPreAppFormItem){
                if(pafItem.ASI_CRM_Contracted_Item__c != NULL)
                    setItmGroupId.add(pafItem.ASI_CRM_Contracted_Item__c);
                if(pafItem.ASI_CRM_FOC_Item__c != NULL)
                    setItmGroupId.add(pafItem.ASI_CRM_FOC_Item__c);
                if(pafItem.ASI_CRM_Expenses_Product__c != NULL)
                    setItmGroupId.add(pafItem.ASI_CRM_Expenses_Product__c);
            }
            
            //get account Channel & Sub-Channel for retrieve Item Group
            //String strCh = preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c + ';,'+ preAppForm[0].ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c;
            List<String> strChannels = new List<String>();
            strChannels.add('\''+ preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c +'\'');
            strChannels.add('\''+ preAppForm[0].ASI_CRM_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c +'\'');

            List<String> listType = new List<String>();
            listType.add('A&D FOC Unit Cost');
            listType.add('A&P FOC Unit Cost');    
                
            //Map effective SKU Cost/Price for Item Group
            Map<String, ASI_CRM_MY_SKUPriceCost__c> mapSKUpc = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();
            ASI_CRM_TW_ItemGroup_UtilityCls utilityCls = new ASI_CRM_TW_ItemGroup_UtilityCls();
            //for(ASI_CRM_MY_SKUPriceCost__c skupc : [SELECT id, ASI_CRM_Item_Group__c, ASI_CRM_Cost__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE ASI_CRM_Item_Group__c IN: setItmGroupId AND ASI_CRM_Type__c = 'Unit Cost' AND ASI_CRM_EffectiveDate__c <= TODAY Order By ASI_CRM_EffectiveDate__c ASC]){
            
            //for(ASI_CRM_MY_SKUPriceCost__c skupc : utilityCls.getAllEffectiveSKUpc(strCh, setItmGroupId, listType, preAppForm[0].ASI_HK_CRM_PAF_Start_Date__c)){
            //for(ASI_CRM_MY_SKUPriceCost__c skupc : utilityCls.getAllEffectiveSKUpc(strCh, setItmGroupId, listType, preAppForm[0].ASI_HK_CRM_PAF_Start_Date__c)){
            for(ASI_CRM_MY_SKUPriceCost__c skupc : utilityCls.getAllEffectiveSKUpc(strChannels, setItmGroupId, listType, preAppForm[0].ASI_HK_CRM_PAF_Start_Date__c)){
                mapSKUpc.put(skupc.ASI_CRM_Item_Group__c+skupc.ASI_CRM_Type__c, skupc);
            }
            system.debug('mapSKUpc: '+ mapSKUpc);
           
            //Map AC Code
            Map<String, ASI_MFM_A_C_Code__c> mapACcode = new Map<String, ASI_MFM_A_C_Code__c>();
            for(ASI_MFM_A_C_Code__c ac : [SELECT id, Name, ASI_CRM_Default_For__c FROM ASI_MFM_A_C_Code__c WHERE RecordTypeId =:  Global_RecordTypeCache.getRTId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code') AND ASI_CRM_Default_For__c != NULL]){
                mapACcode.put(ac.ASI_CRM_Default_For__c, ac);
            }
            system.debug('A/C Code: '+mapACcode);
            
            //Convert PAF Items to Plan Line Items
			Map<String, Boolean> outletMap = new Map<String, Boolean>();
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem : listPreAppFormItem){
                if(!pafItem.ASI_HK_CRM_Mechanic__r.ASI_CRM_Exclude_from_Plan_Conversion__c){
                    ASI_MFM_Plan_Line_Item__c planItm = new ASI_MFM_Plan_Line_Item__c();
                    
                    //Convert Variable Investment items to Plan Line items
                    if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment') && 
                       pafItem.ASI_HK_CRM_Target_Volume_Qty__c != 0){
                        planItm.ASI_MFM_Plan__c = convertedPlan[0].id;
                        planItm.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item');
                        planItm.ASI_MFM_Sub_brand_Code__c = pafItem.ASI_CRM_FOC_Item__c != null ? pafItem.ASI_CRM_FOC_Item__r.ASI_MFM_Sub_brand__c : pafItem.ASI_CRM_Contracted_Item__r.ASI_MFM_Sub_brand__c;

						//planItm.ASI_MFM_Size__c = String.valueof(pafItem.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c);
                        if(pafItem.ASI_CRM_FOC_Item__c != NULL && pafItem.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c != null)
                            planItm.ASI_MFM_Size__c = sizeConverter(pafItem.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c);
                        else if (pafItem.ASI_CRM_FOC_Item__c == NULL && pafItem.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c != null) 
                            planItm.ASI_MFM_Size__c = sizeConverter(pafItem.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c);
                        
                        if(listAccount != NULL && listAccount.size() > 0)
                            planItm.ASI_MFM_Customer_Name__c = listAccount[0].id;
                        
                        if(pafItem.ASI_HK_CRM_Target_Volume_Qty__c != NULL && pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != NULL && pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != 0 && pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c != NULL)
                            planItm.ASI_MFM_Quantity__c = Math.floor((pafItem.ASI_HK_CRM_Target_Volume_Qty__c/pafItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c)*pafItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c);
                        
                        if(mapSKUpc != NULL && (pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC' || pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash & FOC')) {
                            if(pafItem.ASI_CRM_FOC_Item__c != null) {
                                if(pafItem.ASI_CRM_AD_or_AP__c == 'A&D' && mapSKUpc.get(pafItem.ASI_CRM_FOC_Item__c+'A&D FOC Unit Cost') != null)
                                    planItm.ASI_MFM_Unit_Cost__c = mapSKUpc.get(pafItem.ASI_CRM_FOC_Item__c+'A&D FOC Unit Cost').ASI_CRM_Cost__c;
                                else if((pafItem.ASI_CRM_AD_or_AP__c == 'MKT A&P' || pafItem.ASI_CRM_AD_or_AP__c == 'Trade A&P') && mapSKUpc.get(pafItem.ASI_CRM_FOC_Item__c+'A&P FOC Unit Cost') != null)
                                    planItm.ASI_MFM_Unit_Cost__c = mapSKUpc.get(pafItem.ASI_CRM_FOC_Item__c+'A&P FOC Unit Cost').ASI_CRM_Cost__c;
                                system.debug('ASI_MFM_Unit_Cost__c: ' + planItm.ASI_MFM_Unit_Cost__c);
                            }
                            else {
                                if(pafItem.ASI_CRM_AD_or_AP__c == 'A&D' && mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c+'A&D FOC Unit Cost') != null)
                                    planItm.ASI_MFM_Unit_Cost__c = mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c+'A&D FOC Unit Cost').ASI_CRM_Cost__c;
                                else if((pafItem.ASI_CRM_AD_or_AP__c == 'MKT A&P' || pafItem.ASI_CRM_AD_or_AP__c == 'Trade A&P') && mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c+'A&P FOC Unit Cost') != null)
                                    planItm.ASI_MFM_Unit_Cost__c = mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c+'A&P FOC Unit Cost').ASI_CRM_Cost__c;
                                system.debug('ASI_MFM_Unit_Cost__c: ' + planItm.ASI_MFM_Unit_Cost__c);
                            }
                            system.debug('ASI_MFM_Unit_Cost__c: ' + planItm.ASI_MFM_Unit_Cost__c);
                            
                        }
                        
                        system.debug('Cash or FOC: '+pafItem.ASI_CRM_Cash_or_FOC__c);
                        if(pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC'){
                            //planItm.ASI_MFM_FOC_Size__c = String.valueof(pafItem.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c);
                            if(pafItem.ASI_CRM_FOC_Item__c != NULL && pafItem.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c != null)
                                planItm.ASI_MFM_FOC_Size__c = sizeConverter(pafItem.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c);    
                            else if (pafItem.ASI_CRM_FOC_Item__c == NULL && pafItem.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c != null) 
                                planItm.ASI_MFM_FOC_Size__c = sizeConverter(pafItem.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c);
                            
							if (preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_FOC_A_C_Code__c != null)
								planItm.ASI_MFM_A_C_Code__c = preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_FOC_A_C_Code__c;
                            else if(mapACcode != NULL && mapACcode.get('FOC') != NULL)
                                planItm.ASI_MFM_A_C_Code__c = mapACcode.get('FOC').id;
                            

                            planItm.ASI_MFM_List_Item_Description__c = pafItem.ASI_CRM_Contracted_Item__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c + '-FOC-';
                            planItm.ASI_MFM_List_Item_Description__c += pafItem.ASI_CRM_FOC_Item__c != null ? pafItem.ASI_CRM_FOC_Item__r.ASI_MFM_Item_Group_Code__c : pafItem.ASI_CRM_Contracted_Item__r.ASI_MFM_Item_Group_Code__c;
                            system.debug('ASI_MFM_List_Item_Description__c: ' + pafItem.ASI_CRM_Contracted_Item__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c +';'+ pafItem.ASI_CRM_FOC_Item__r.ASI_MFM_Item_Group_Code__c);
                            /*
                            if(mapSKUpc != NULL && mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c) != NULL && mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Cost__c != NULL)
                                planItm.ASI_MFM_Total_Cost__c =  = (planItm.ASI_MFM_Quantity__c)*(mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Cost__c);
                            */
                            if(planItm.ASI_MFM_Quantity__c != null && planItm.ASI_MFM_Quantity__c != 0 && planItm.ASI_MFM_Unit_Cost__c != null && planItm.ASI_MFM_Unit_Cost__c != 0)
                                planItm.ASI_MFM_Total_Cost__c = planItm.ASI_MFM_Quantity__c * planItm.ASI_MFM_Unit_Cost__c;
                        }
                        else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash'){
							if (preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_Cash_A_C_Code__c != null)
								planItm.ASI_MFM_A_C_Code__c = preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_Cash_A_C_Code__c;
                            else if (mapACcode != NULL && mapACcode.get('Cash') != NULL)
                                planItm.ASI_MFM_A_C_Code__c = mapACcode.get('Cash').id;
                            planItm.ASI_MFM_List_Item_Description__c = 'Cash';
                            planItm.ASI_MFM_Total_Cost__c = pafItem.ASI_HK_CRM_Target_Volume_Qty__c * pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c;
                            if(preAppForm[0].ASI_CRM_Valid_Invoice__c)
                                planItm.ASI_MFM_Total_Cost__c = planItm.ASI_MFM_Total_Cost__c / 1.05;
                        }
                        else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash & FOC'){
                            //Cash
                            ASI_MFM_Plan_Line_Item__c planItm2 = planItm.clone(false, true);
                            planItm2.ASI_MFM_Plan_Line_Item_External_IDUpload__c = null;//Clear planItm's external id

							if (preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_Cash_A_C_Code__c != null)
								planItm2.ASI_MFM_A_C_Code__c = preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_Cash_A_C_Code__c;
                            else if (mapACcode != NULL && mapACcode.get('Cash') != NULL)
                                planItm2.ASI_MFM_A_C_Code__c = mapACcode.get('Cash').id;
                            planItm2.ASI_MFM_List_Item_Description__c = 'Cash';
                            planItm2.ASI_MFM_Total_Cost__c = pafItem.ASI_HK_CRM_Target_Volume_Qty__c * pafItem.ASI_CRM_Cash_Per_Bottle_w_VAT__c;
                            if(preAppForm[0].ASI_CRM_Valid_Invoice__c)
                                planItm2.ASI_MFM_Total_Cost__c = planItm2.ASI_MFM_Total_Cost__c / 1.05;
                            
                            planItm2.ASI_MFM_TW_Related_PAF_Item__c  = pafItem.id;
                            if(planItm2.ASI_MFM_Total_Cost__c != null && planItm2.ASI_MFM_Total_Cost__c != 0)
                                planItm2.ASI_MFM_Total_Cost__c = planItm2.ASI_MFM_Total_Cost__c.round(System.RoundingMode.CEILING);
                            listConvertedPlanItm.add(planItm2);
                            
                            //FOC
                            //planItm.ASI_MFM_FOC_Size__c = String.valueof(pafItem.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c);
                            if(pafItem.ASI_CRM_FOC_Item__c != NULL && pafItem.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c != null)
                                planItm.ASI_MFM_FOC_Size__c = sizeConverter(pafItem.ASI_CRM_FOC_Item__r.ASI_CRM_Size_ml__c);    
                            else if(pafItem.ASI_CRM_FOC_Item__c == NULL && pafItem.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c != null) 
                                planItm.ASI_MFM_FOC_Size__c = sizeConverter(pafItem.ASI_CRM_Contracted_Item__r.ASI_CRM_Size_ml__c);

                            if (preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_FOC_A_C_Code__c != null)
								planItm.ASI_MFM_A_C_Code__c = preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_FOC_A_C_Code__c;
							else if (mapACcode != NULL && mapACcode.get('FOC') != NULL)
                                planItm.ASI_MFM_A_C_Code__c = mapACcode.get('FOC').id;

                            planItm.ASI_MFM_List_Item_Description__c = pafItem.ASI_CRM_Contracted_Item__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c + '-FOC-';
                            planItm.ASI_MFM_List_Item_Description__c += pafItem.ASI_CRM_FOC_Item__c != null ? pafItem.ASI_CRM_FOC_Item__r.ASI_MFM_Item_Group_Code__c : pafItem.ASI_CRM_Contracted_Item__r.ASI_MFM_Item_Group_Code__c;
                            /*
                            if(mapSKUpc != NULL && mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c) != NULL && mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Cost__c != NULL)
                                planItm.ASI_MFM_Total_Cost__c = (planItm.ASI_MFM_Quantity__c)*(mapSKUpc.get(pafItem.ASI_CRM_Contracted_Item__c).ASI_CRM_Cost__c);
                            */


                            if(planItm.ASI_MFM_Quantity__c != null && planItm.ASI_MFM_Quantity__c != 0 && planItm.ASI_MFM_Unit_Cost__c != null && planItm.ASI_MFM_Unit_Cost__c != 0)
                                planItm.ASI_MFM_Total_Cost__c = planItm.ASI_MFM_Quantity__c * planItm.ASI_MFM_Unit_Cost__c;

                            String key = String.valueOf(planItm2.ASI_MFM_Sub_brand_Code__c) + String.valueOf(planItm2.ASI_MFM_A_C_Code__c) + planItm2.ASI_MFM_Customer_Name__c + planItm2.ASI_MFM_List_Item_Description__c;
                            if (outletMap.get(key) == null)
                            {
                                planItm2.ASI_MFM_Number_of_Outlets__c = pafItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_No_of_Outlets__c;
                                outletMap.put(key, true);
                            }
                        }

                        planItm.ASI_CRM_TW_PAFItem_Item_Group__c = pafItem.ASI_CRM_Contracted_Item__r.ASI_MFM_Item_Group_Code__c;

                        //if plan line amount is null, make it 0
                        if(planItm.ASI_MFM_Total_Cost__c == null)
                            planItm.ASI_MFM_Total_Cost__c = 0;
                        
                        planItm.ASI_MFM_Expected_Volume__c = pafItem.ASI_HK_CRM_Target_Volume_Qty__c;
                        
                        planItm.ASI_MFM_TW_Related_PAF_Item__c  = pafItem.id;
                        if(planItm.ASI_MFM_Total_Cost__c != null && planItm.ASI_MFM_Total_Cost__c != 0)
                                planItm.ASI_MFM_Total_Cost__c = planItm.ASI_MFM_Total_Cost__c.round(System.RoundingMode.CEILING);
                        listConvertedPlanItm.add(planItm);
                    }
                    //Convert Conditional/Fixed Investment items to Plan Line items
                    else if(pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') ||
                           (pafItem.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment') && pafItem.ASI_HK_CRM_Mechanic__r.Name != 'Market Visit')){
                        planItm.ASI_MFM_Plan__c = convertedPlan[0].id;
                        planItm.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item');
                        planItm.ASI_MFM_Sub_brand_Code__c = pafItem.ASI_CRM_Expenses_Product__r.ASI_MFM_Sub_brand__c;
                        planItm.ASI_MFM_A_C_Code__c = pafItem.ASI_HK_CRM_Mechanic__r.ASI_CRM_A_C_Code__c;
                        planItm.ASI_MFM_Quantity__c = pafItem.ASI_CRM_FOC_Volume__c;
                        planItm.ASI_MFM_Number_of_Outlets__c = pafItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_No_of_Outlets__c;
                        
                        if(mapSKUpc != NULL && pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC'){
                            if(pafItem.ASI_CRM_AD_or_AP__c == 'A&D' && mapSKUpc.get(pafItem.ASI_CRM_Expenses_Product__c+'A&D FOC Unit Cost') != null)
                                planItm.ASI_MFM_Unit_Cost__c = mapSKUpc.get(pafItem.ASI_CRM_Expenses_Product__c+'A&D FOC Unit Cost').ASI_CRM_Cost__c;
                            else if((pafItem.ASI_CRM_AD_or_AP__c == 'MKT A&P' || pafItem.ASI_CRM_AD_or_AP__c == 'Trade A&P') && mapSKUpc.get(pafItem.ASI_CRM_Expenses_Product__c+'A&P FOC Unit Cost') != null)
                                planItm.ASI_MFM_Unit_Cost__c = mapSKUpc.get(pafItem.ASI_CRM_Expenses_Product__c+'A&P FOC Unit Cost').ASI_CRM_Cost__c;
                        }
                        
                        if(listAccount != NULL && listAccount.size() > 0)
                            planItm.ASI_MFM_Customer_Name__c = listAccount[0].id;
                        
                        if(pafItem.ASI_CRM_Cash_or_FOC__c == 'FOC'){
                            //planItm.ASI_MFM_FOC_Size__c = String.valueof(pafItem.ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c);
                            if(pafItem.ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c != null) planItm.ASI_MFM_FOC_Size__c = sizeConverter(pafItem.ASI_CRM_Expenses_Product__r.ASI_CRM_Size_ml__c);
                            
                            planItm.ASI_MFM_List_Item_Description__c = pafItem.ASI_CRM_Expenses_Product__r.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c +'-FOC-'+ pafItem.ASI_CRM_Mechanic_Detail__c;
                            /*
                            if(mapSKUpc != NULL && mapSKUpc.get(pafItem.ASI_CRM_Expenses_Product__c) != NULL && mapSKUpc.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_CRM_Cost__c != NULL)
                                planItm.ASI_MFM_Total_Cost__c = (planItm.ASI_MFM_Quantity__c)*(mapSKUpc.get(pafItem.ASI_CRM_Expenses_Product__c).ASI_CRM_Cost__c);
                            */
                            if(planItm.ASI_MFM_Quantity__c != null && planItm.ASI_MFM_Quantity__c != 0 && planItm.ASI_MFM_Unit_Cost__c != null && planItm.ASI_MFM_Unit_Cost__c != 0)
                                planItm.ASI_MFM_Total_Cost__c = planItm.ASI_MFM_Quantity__c * planItm.ASI_MFM_Unit_Cost__c;
							
                            /* [SH] 2019-07-15
                            if (preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_FOC_A_C_Code__c != null)
								planItm.ASI_MFM_A_C_Code__c = preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_FOC_A_C_Code__c;
							*/
                        }
                        else if(pafItem.ASI_CRM_Cash_or_FOC__c == 'Cash'){
                            planItm.ASI_MFM_List_Item_Description__c = 'Cash-'+ pafItem.ASI_CRM_Mechanic_Detail__c;
                            if(preAppForm[0].ASI_CRM_Valid_Invoice__c)
                                planItm.ASI_MFM_Total_Cost__c = pafItem.ASI_CRM_Cash_Amounts_w_VAT__c/1.05;
                            else
                                planItm.ASI_MFM_Total_Cost__c = pafItem.ASI_CRM_Cash_Amounts_w_VAT__c;

                            /* [SH] 2019-07-15
                            if (preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_Cash_A_C_Code__c != null)
								planItm.ASI_MFM_A_C_Code__c = preAppForm[0].ASI_CRM_Channel__r.ASI_CRM_TW_Default_Cash_A_C_Code__c;
							*/
                        }
                        
                        planItm.ASI_CRM_TW_PAFItem_Item_Group__c = pafItem.ASI_CRM_Expenses_Product__r.ASI_MFM_Item_Group_Code__c;
                        //if plan line amount is null, make it 0
                        if(planItm.ASI_MFM_Total_Cost__c == null)
                            planItm.ASI_MFM_Total_Cost__c = 0;
                        
                        planItm.ASI_MFM_TW_Related_PAF_Item__c  = pafItem.id;
                        if(planItm.ASI_MFM_Total_Cost__c != null && planItm.ASI_MFM_Total_Cost__c != 0)
                                planItm.ASI_MFM_Total_Cost__c = planItm.ASI_MFM_Total_Cost__c.round(System.RoundingMode.CEILING);
                        listConvertedPlanItm.add(planItm);
                    }

					String key = String.valueOf(planItm.ASI_MFM_Sub_brand_Code__c) + String.valueOf(planItm.ASI_MFM_A_C_Code__c) + planItm.ASI_MFM_Customer_Name__c + planItm.ASI_MFM_List_Item_Description__c;
					if (outletMap.get(key) == null)
					{
						planItm.ASI_MFM_Number_of_Outlets__c = pafItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_No_of_Outlets__c;
						outletMap.put(key, true);
					}
                }
            }
            system.debug(listConvertedPlanItm);
            
            if(allSuccess){
                //try {       
                //Delete previous Plan line items & Insert new set of Plan line items
                delete listToDeletePlanItm; 
                insert listConvertedPlanItm;
                
                //Update PAF
                preAppForm[0].ASI_CRM_Commitment_No__c = convertedPlan[0].id;
                
                preAppForm[0].ASI_CRM_Converted_Date__c = System.now();
                update preAppForm;
                    
                /*}catch (DmlException dmle) {
                    allSuccess = FALSE;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '-'+dmle));
                    system.debug(dmle);
                    database.rollback(sp);
                }*/
            }
            
            return new pageReference('/'+convertedPlan[0].id+'/e?retURL=%2F'+convertedPlan[0].id);
        }
    }   
}