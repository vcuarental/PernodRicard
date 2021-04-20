public without sharing class ASI_MFM_Callout {

    @future (callout=true)  
    public static void deletePayment(list<id> pid_list) {
        ASI_MFM_DWInterface.DWInterfaceSoap dwi = new ASI_MFM_DWInterface.DWInterfaceSoap();
        ASI_MFM_DWInterface.WSResult resp = new ASI_MFM_DWInterface.WSResult();
        ASI_MFM_Callout_Limits__c lmt = getCalloutLimits(); 
        dwi.timeout_x = lmt.ASI_MFM_Timeout_Limit__c.intValue();               
        for (id pid:pid_list) {
            boolean stop_callout = false;
            integer retry_count = 0;
            while (!stop_callout) {
                try {
                    resp = dwi.deletePayment(pid);
                    ASI_MFM_Function.displayCalloutCount('deletePayment');
                    stop_callout = true;
                    system.debug('Callout response: ' + resp.succeed);
                    system.debug('Callout response message: ' + resp.message); 
                }
                catch (exception ex) { 
                    if (ex.getMessage().contains('Read timed out') && retry_count < lmt.ASI_MFM_Timeout_Retry_Limit__c) {
                        retry_count++;
                    }
                    else {
                        stop_callout = true;
                        resp.succeed = 0;
                        resp.message = ex.getMessage();
                        system.debug('Callout exception: ' + ex.getMessage());                  
                    }
                }           
            }           
        }
    }

    @future (callout=true)  
    public static void deletePlan(list<id> pid_list) {
        ASI_MFM_DWInterface.DWInterfaceSoap dwi = new ASI_MFM_DWInterface.DWInterfaceSoap();
        ASI_MFM_DWInterface.WSResult resp = new ASI_MFM_DWInterface.WSResult();
        ASI_MFM_Callout_Limits__c lmt = getCalloutLimits(); 
        dwi.timeout_x = lmt.ASI_MFM_Timeout_Limit__c.intValue();        
        for (id pid:pid_list) {
            boolean stop_callout = false;
            integer retry_count = 0;
            while (!stop_callout) {
                try {
                    resp = dwi.deletePlan(pid);
                    ASI_MFM_Function.displayCalloutCount('deletePlan');
                    stop_callout = true;
                    system.debug('Callout response: ' + resp.succeed);
                    system.debug('Callout response message: ' + resp.message); 
                }
                catch (exception ex) { 
                    if (ex.getMessage().contains('Read timed out') && retry_count < lmt.ASI_MFM_Timeout_Retry_Limit__c) {
                        retry_count++;
                    }
                    else {
                        stop_callout = true;
                        resp.succeed = 0;
                        resp.message = ex.getMessage();
                        system.debug('Callout exception: ' + ex.getMessage());                  
                    }
                }           
            }           
        }
    }

    @future (callout=true)  
    public static void deletePO(list<id> pid_list) {
        ASI_MFM_DWInterface.DWInterfaceSoap dwi = new ASI_MFM_DWInterface.DWInterfaceSoap();
        ASI_MFM_DWInterface.WSResult resp = new ASI_MFM_DWInterface.WSResult();
        ASI_MFM_Callout_Limits__c lmt = getCalloutLimits(); 
        dwi.timeout_x = lmt.ASI_MFM_Timeout_Limit__c.intValue();        
        for (id pid:pid_list) {
            boolean stop_callout = false;
            integer retry_count = 0;
            while (!stop_callout) {
                try {
                    resp = dwi.deletePO(pid);
                    ASI_MFM_Function.displayCalloutCount('deletePO');
                    stop_callout = true;
                    system.debug('Callout response: ' + resp.succeed);
                    system.debug('Callout response message: ' + resp.message); 
                }
                catch (exception ex) { 
                    if (ex.getMessage().contains('Read timed out') && retry_count < lmt.ASI_MFM_Timeout_Retry_Limit__c) {
                        retry_count++;
                    }
                    else {
                        stop_callout = true;
                        resp.succeed = 0;
                        resp.message = ex.getMessage();
                        system.debug('Callout exception: ' + ex.getMessage());                  
                    }
                }           
            }           
        }
    }

    @future (callout=true)  
    public static void updatePayment(set<id> Payment_set) {
        string additional_fields = 'LastModifiedBy.name, createdBy.name, owner.name, recordType.developerName';
        string query_string = ASI_MFM_Function.buildQuery('ASI_MFM_Payment__c', additional_fields) + ' where id in :Payment_set for update';
        list<ASI_MFM_Payment__c> Payment_list = database.query(query_string);
        list<ASI_MFM_DWInterface.SFDCPaymentHeaderType> hdr_list = new list<ASI_MFM_DWInterface.SFDCPaymentHeaderType>();
        for (ASI_MFM_Payment__c p:Payment_list) {
            ASI_MFM_DWInterface.SFDCPaymentHeaderType hdr = new ASI_MFM_DWInterface.SFDCPaymentHeaderType();
            hdr.CASHFLOW_DATE = p.ASI_MFM_Cashflow_Date__c;
            hdr.CREATED_USER = p.createdBy.name;
            hdr.INVOICE_NUMBER = p.ASI_MFM_Invoice_Number__c;
            hdr.LAST_UPDATED_DATE = p.lastModifiedDate;
            hdr.LAST_UPDATED_USER = p.LastModifiedBy.name;
            hdr.OWNER = p.owner.name;
            hdr.PAYMENT_AMOUNT = p.ASI_MFM_Payment_Amount__c;
            hdr.PAYMENT_DATE = p.ASI_MFM_Payment_Date__c;
            hdr.PAYMENT_ID = p.name;
            hdr.SFID = p.id;
            system.debug('Header values: ' + hdr);
            hdr_list.add(hdr);
        }
        ASI_MFM_DWInterface.SFDCPaymentHeadersType header_list = new ASI_MFM_DWInterface.SFDCPaymentHeadersType();
        header_list.SFDCPaymentHeader = hdr_list;
        
        additional_fields = 'ASI_MFM_PO_Line_Item__r.name';
        query_string = ASI_MFM_Function.buildQuery('ASI_MFM_Payment_Line_Item__c', additional_fields) + ' where ASI_MFM_Payment__c in :Payment_set for update';
        list<ASI_MFM_Payment_Line_Item__c> item_list = database.query(query_string);
        list<ASI_MFM_DWInterface.SFDCPaymentDetailType> dtl_list = new list<ASI_MFM_DWInterface.SFDCPaymentDetailType>();
        for (ASI_MFM_Payment_Line_Item__c i:item_list) {
            ASI_MFM_DWInterface.SFDCPaymentDetailType dtl = new ASI_MFM_DWInterface.SFDCPaymentDetailType();
            dtl.DTL_SFID = i.id;
            dtl.HDR_SFID = i.ASI_MFM_Payment__c;
            dtl.PAYMENT_AMOUNT = i.ASI_MFM_Payment_Amount__c;
            dtl.PO_LINE_ITEM_ID = i.ASI_MFM_PO_Line_Item__r.name;
            system.debug('Detail values: ' + dtl);          
            dtl_list.add(dtl);
        }
        ASI_MFM_DWInterface.SFDCPaymentDetailsType detail_list = new ASI_MFM_DWInterface.SFDCPaymentDetailsType();
        detail_list.SFDCPaymentDetail = dtl_list;       
                        
        ASI_MFM_DWInterface.DWInterfaceSoap dwi = new ASI_MFM_DWInterface.DWInterfaceSoap();
        ASI_MFM_DWInterface.WSResult resp = new ASI_MFM_DWInterface.WSResult();
        ASI_MFM_Callout_Limits__c lmt = getCalloutLimits(); 
        dwi.timeout_x = lmt.ASI_MFM_Timeout_Limit__c.intValue();        
        boolean stop_callout = false;
        integer retry_count = 0;
        while (!stop_callout) {
            try {
                resp = dwi.updatePaymentStrong(header_list, detail_list);
                ASI_MFM_Function.displayCalloutCount('updatePayment');
                stop_callout = true;
                system.debug('Callout response: ' + resp.succeed);
                system.debug('Callout response message: ' + resp.message); 
            }
            catch (exception ex) { 
                if (ex.getMessage().contains('Read timed out') && retry_count < lmt.ASI_MFM_Timeout_Retry_Limit__c) {
                    retry_count++;
                }
                else {
                    stop_callout = true;
                    resp.succeed = 0;
                    resp.message = ex.getMessage();
                    system.debug('Callout exception: ' + ex.getMessage());                  
                }
            }           
        }
        
        datetime sync_time = datetime.now(); 
        for (ASI_MFM_Payment__c p:Payment_list) {
            p.ASI_MFM_Web_Service_Failed__c = resp.succeed == 1 ? false : true;
            p.ASI_MFM_Web_Service_Error_Message__c = resp.succeed == 1 ? null : resp.message;
            p.ASI_MFM_Sys_Sync_Time__c = sync_time;
            system.debug('Callout for Payment ' + p.id + ' @ ' + sync_time.format());           
        }
        update Payment_list;   
        for (ASI_MFM_Payment_Line_Item__c i:item_list) {
            i.ASI_MFM_Web_Service_Failed__c = resp.succeed == 1 ? false : true;
            i.ASI_MFM_Sys_Sync_Time__c = sync_time;
        }
        update item_list;       
    }

    @future (callout=true)  
    public static void updatePlan(set<id> plan_set) {
        string additional_fields = 'LastModifiedBy.name, createdBy.name, owner.name, recordType.developerName';
        string query_string = ASI_MFM_Function.buildQuery('ASI_MFM_Plan__c', additional_fields) + ' where id in :plan_set for update';
        list<ASI_MFM_Plan__c> plan_list = database.query(query_string);
        list<ASI_MFM_DWInterface.SFDCPlanHeaderType> hdr_list = new list<ASI_MFM_DWInterface.SFDCPlanHeaderType>();
        for (ASI_MFM_Plan__c p:plan_list) {
            ASI_MFM_DWInterface.SFDCPlanHeaderType hdr = new ASI_MFM_DWInterface.SFDCPlanHeaderType();
            hdr.CREATED_DATE = p.createdDate;
            hdr.CREATED_USER = p.createdBy.name;
            hdr.END_DATE = p.ASI_MFM_End_Date__c;
            hdr.EVALUATION_DATE = p.ASI_MFM_Evaluation_Date__c;
            hdr.EVALUATION_DUE_DATE = p.ASI_MFM_Evaluation_Due_Date__c;
            hdr.EVALUATION_REQUIRED = p.ASI_MFM_Evaluation_Required__c ? '1' : '0';
            hdr.LAST_UPDATED_DATE = p.lastModifiedDate;
            hdr.LAST_UPDATED_USER = p.LastModifiedBy.name;
            hdr.MARKET_CODE = p.recordType.developerName.substring(8, 10);
            hdr.MECHANICS = p.ASI_MFM_Mechanics__c;
            hdr.OBJECTIVES_OTHERS = p.ASI_MFM_Objectives_Others__c;
            hdr.OBJECTIVES_QUANTIFIED = p.ASI_MFM_Objectives_Quantified__c;
            hdr.OWNER = p.owner.name;
            hdr.PLAN_ID = p.name;
            hdr.PLAN_NAME = p.ASI_MFM_Plan_Name__c;
            hdr.PROJECT_DESCRIPTION = p.ASI_MFM_Plan_Description__c;
            hdr.RAISED_DATE = p.ASI_MFM_Plan_Raised_Date__c;
            hdr.REFERENCE_1 = p.ASI_MFM_Reference_1__c;
            hdr.REFERENCE_2 = p.ASI_MFM_Reference_2__c;
            hdr.SFID = p.id;
            hdr.START_DATE = p.ASI_MFM_Start_Date__c;
            hdr.STATUS = p.ASI_MFM_Status__c;
            hdr.STRATEGY_CODE = p.ASI_MFM_Strategy_Code__c;
            hdr.STRATEGY_NAME = p.ASI_MFM_Strategy_Name__c;
            system.debug('Header values: ' + hdr);
            hdr_list.add(hdr);
        }
        ASI_MFM_DWInterface.SFDCPlanHeadersType header_list = new ASI_MFM_DWInterface.SFDCPlanHeadersType();
        header_list.SFDCPlanHeader = hdr_list;
        
        additional_fields = 'ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_MFM_BU_Code__r.ASI_MFM_BU_Code__c, ASI_MFM_Customer_Name__r.name, ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c';
        query_string = ASI_MFM_Function.buildQuery('ASI_MFM_Plan_Line_Item__c', additional_fields) + ' where ASI_MFM_Plan__c in :plan_set for update';
        list<ASI_MFM_Plan_Line_Item__c> item_list = database.query(query_string);
        list<ASI_MFM_DWInterface.SFDCPlanDetailType> dtl_list = new list<ASI_MFM_DWInterface.SFDCPlanDetailType>();
        for (ASI_MFM_Plan_Line_Item__c i:item_list) {
            ASI_MFM_DWInterface.SFDCPlanDetailType dtl = new ASI_MFM_DWInterface.SFDCPlanDetailType();
            dtl.ACTIVITIES = i.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c;
            dtl.AP_CODE = i.ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c;
            dtl.COMPANY_LOCATION = i.ASI_MFM_BU_Code__r.ASI_MFM_BU_Code__c;
            dtl.CUST_SIZE = i.ASI_MFM_Size__c;
            dtl.CUSTOMER = i.ASI_MFM_Customer_Name__r.name;
            dtl.DTL_SFID = i.id;
            dtl.EXPECTED_VOLUME = string.valueOf(i.ASI_MFM_Expected_Volume__c);
            dtl.FY_PERIOD = null;
            dtl.FY_YEAR = i.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c;
            dtl.HDR_SFID = i.ASI_MFM_Plan__c;
            dtl.LIST_ITEMS = i.ASI_MFM_List_Item_Description__c;
            dtl.MONTH_COST_01 = i.ASI_MFM_Month_1_Cost__c;
            dtl.MONTH_COST_02 = i.ASI_MFM_Month_2_Cost__c;  
            dtl.MONTH_COST_03 = i.ASI_MFM_Month_3_Cost__c;
            dtl.MONTH_COST_04 = i.ASI_MFM_Month_4_Cost__c;  
            dtl.MONTH_COST_05 = i.ASI_MFM_Month_5_Cost__c;
            dtl.MONTH_COST_06 = i.ASI_MFM_Month_6_Cost__c;  
            dtl.MONTH_COST_07 = i.ASI_MFM_Month_7_Cost__c;
            dtl.MONTH_COST_08 = i.ASI_MFM_Month_8_Cost__c;  
            dtl.MONTH_COST_09 = i.ASI_MFM_Month_9_Cost__c;
            dtl.MONTH_COST_10 = i.ASI_MFM_Month_10_Cost__c; 
            dtl.MONTH_COST_11 = i.ASI_MFM_Month_11_Cost__c;
            dtl.MONTH_COST_12 = i.ASI_MFM_Month_12_Cost__c;                                             
            dtl.PERIOD_END = i.ASI_MFM_Plan_End_Date__c;
            dtl.PERIOD_START = i.ASI_MFM_Plan_Start_Date__c;
            dtl.PLAN_LINE_ITEM_ID = i.Name;
            dtl.QUANTITY = i.ASI_MFM_Quantity__c;
            dtl.SUB_BRAND = i.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c;
            dtl.UNIT_COST = i.ASI_MFM_Unit_Cost__c;
            system.debug('Detail values: ' + dtl);          
            dtl_list.add(dtl);
        }
        ASI_MFM_DWInterface.SFDCPlanDetailsType detail_list = new ASI_MFM_DWInterface.SFDCPlanDetailsType();
        detail_list.SFDCPlanDetail = dtl_list;      
                        
        ASI_MFM_DWInterface.DWInterfaceSoap dwi = new ASI_MFM_DWInterface.DWInterfaceSoap();
        ASI_MFM_DWInterface.WSResult resp = new ASI_MFM_DWInterface.WSResult();
        ASI_MFM_Callout_Limits__c lmt = getCalloutLimits(); 
        dwi.timeout_x = lmt.ASI_MFM_Timeout_Limit__c.intValue();        
        boolean stop_callout = false;
        integer retry_count = 0;
        while (!stop_callout) {
            try {
                resp = dwi.updatePlanStrong(header_list, detail_list);
                ASI_MFM_Function.displayCalloutCount('updatePlan');
                stop_callout = true;
                system.debug('Callout response: ' + resp.succeed);
                system.debug('Callout response message: ' + resp.message); 
            }
            catch (exception ex) { 
                if (ex.getMessage().contains('Read timed out') && retry_count < lmt.ASI_MFM_Timeout_Retry_Limit__c) {
                    retry_count++;
                }
                else {
                    stop_callout = true;
                    resp.succeed = 0;
                    resp.message = ex.getMessage();
                    system.debug('Callout exception: ' + ex.getMessage());                  
                }
            }           
        }
        
        datetime sync_time = datetime.now();
        for (ASI_MFM_Plan__c p:plan_list) {
            p.ASI_MFM_Web_Service_Failed__c = resp.succeed == 1 ? false : true;
            p.ASI_MFM_Web_Service_Error_Message__c = resp.succeed == 1 ? null : resp.message;
            p.ASI_MFM_Sys_Sync_Time__c = sync_time;
            system.debug('Callout for plan ' + p.id + ' @ ' + sync_time.format());          
        }
        update plan_list;
         
        for (ASI_MFM_Plan_Line_Item__c i:item_list) {
            i.ASI_MFM_Web_Service_Failed__c = resp.succeed == 1 ? false : true;
            system.debug('Old sync time: ' + i.ASI_MFM_Sys_Sync_Time__c);
            i.ASI_MFM_Sys_Sync_Time__c = sync_time;
            i.ASI_MFM_Sys_Sync_Time_Milli__c = datetime.now().getTime();
            system.debug('New sync time: ' + i.ASI_MFM_Sys_Sync_Time__c);            
        }
        update item_list;       
    }

    @future (callout=true)  
    public static void updatePO(set<id> PO_set) {
        string additional_fields = 'LastModifiedBy.name, createdBy.name, owner.name, recordType.developerName, ASI_MFM_BU_Code__r.ASI_MFM_BU_Code__c';
        string query_string = ASI_MFM_Function.buildQuery('ASI_MFM_PO__c', additional_fields) + ' where id in :PO_set for update';
        list<ASI_MFM_PO__c> PO_list = database.query(query_string);
        list<ASI_MFM_DWInterface.SFDCPOHeaderType> hdr_list = new list<ASI_MFM_DWInterface.SFDCPOHeaderType>();
        for (ASI_MFM_PO__c p:PO_list) {
            ASI_MFM_DWInterface.SFDCPOHeaderType hdr = new ASI_MFM_DWInterface.SFDCPOHeaderType();
            hdr.BU_CODE = p.ASI_MFM_BU_Code__r.ASI_MFM_BU_Code__c;
            hdr.CREATED_USER = p.createdBy.name;
            hdr.CURRENCY_x = p.ASI_MFM_Currency__c;
            hdr.EXCHANGE_RATE = p.ASI_MFM_Exchange_Rate__c;
            hdr.LAST_UPDATED_DATE = p.lastModifiedDate;
            hdr.LAST_UPDATED_USER = p.LastModifiedBy.name;
            hdr.MARKET_CODE = p.recordType.developerName.substring(8, 10);
            hdr.MARKETING_COMMENTS = p.ASI_MFM_Marketing_Comment__c;
            hdr.OWNER = p.owner.name;
            hdr.PAYMENT_DATE = p.ASI_MFM_Payment_Date__c;
            hdr.PAYMENT_TERMS = p.ASI_MFM_Payment_Terms__c;
            hdr.PO_END_DATE = p.ASI_MFM_PO_End_Date__c;
            hdr.PO_NUMBER = p.Name;
            hdr.PO_RAISED_DATE = p.ASI_MFM_PO_Raised_Date__c;
            hdr.PO_START_DATE = p.ASI_MFM_PO_Start_Date__c;
            hdr.REFERENCE_1 = p.ASI_MFM_Reference_1__c;
            hdr.REFERENCE_2 = p.ASI_MFM_Reference_2__c;
            hdr.REMARKS = p.ASI_MFM_Remarks__c;
            hdr.SFID = p.id;
            hdr.STATUS = p.ASI_MFM_Status__c;
            hdr.SUPPLIER_FAX_NUMBER = p.ASI_MFM_Supplier_Fax_Number__c;
            hdr.SUPPLIER_NUMBER = p.ASI_MFM_Supplier_Number__c;
            hdr.VAT = string.valueOf(p.ASI_MFM_VAT__c);
            system.debug('Header values: ' + hdr);
            hdr_list.add(hdr);
        }
        ASI_MFM_DWInterface.SFDCPOHeadersType header_list = new ASI_MFM_DWInterface.SFDCPOHeadersType();
        header_list.SFDCPOHeader = hdr_list;
        
        additional_fields = 'ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c, ASI_MFM_BU_Code__r.ASI_MFM_BU_Code__c, ASI_MFM_Customer_Name__r.name, ASI_MFM_PO__r.ASI_MFM_Plan__r.name, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c, ASI_MFM_PO__r.owner.name';
        query_string = ASI_MFM_Function.buildQuery('ASI_MFM_PO_Line_Item__c', additional_fields) + ' where ASI_MFM_PO__c in :PO_set for update';
        list<ASI_MFM_PO_Line_Item__c> item_list = database.query(query_string);
        list<ASI_MFM_DWInterface.SFDCPODetailType> dtl_list = new list<ASI_MFM_DWInterface.SFDCPODetailType>();
        for (ASI_MFM_PO_Line_Item__c i:item_list) {
            ASI_MFM_DWInterface.SFDCPODetailType dtl = new ASI_MFM_DWInterface.SFDCPODetailType();
            dtl.A_AND_P_FLAG = null;
            dtl.ACTIVITIES = i.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c;
            dtl.AP_CODE = i.ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c;
            dtl.COMPANY_LOCATION = i.ASI_MFM_BU_Code__r.ASI_MFM_BU_Code__c;
            dtl.CUSTOMER = i.ASI_MFM_Customer_Name__r.name;
            dtl.DTL_SFID = i.id;
            dtl.GL_DATE = i.ASI_MFM_G_L_Date__c;
            dtl.HDR_SFID = i.ASI_MFM_PO__c;
            dtl.LIST_ITEMS = i.ASI_MFM_List_Item_Description__c;
            dtl.ORIGINAL_AMOUNT = i.ASI_MFM_Original_Amount__c;
            dtl.ORIGINAL_EQUIV_AMOUNT = 0;
            dtl.OWNER = i.ASI_MFM_PO__r.owner.name;
            dtl.PLAN_ID = i.ASI_MFM_PO__r.ASI_MFM_Plan__r.name;
            dtl.PO_LINE_ITEM_ID = i.name;
            dtl.QUANTITY = i.ASI_MFM_Quantity__c;
            dtl.STATUS = i.ASI_MFM_Status__c;
            dtl.SUB_BRAND = i.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c;
            dtl.SUPPLIER = i.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Name__c;
            dtl.SUPPLIER_NUMBER = i.ASI_MFM_PO_Supplier_Number__c;
            dtl.UNIT_PRICE = i.ASI_MFM_Unit_Price__c;
            system.debug('Detail values: ' + dtl);          
            dtl_list.add(dtl);
        }
        ASI_MFM_DWInterface.SFDCPODetailsType detail_list = new ASI_MFM_DWInterface.SFDCPODetailsType();
        detail_list.SFDCPODetail = dtl_list;        
                        
        ASI_MFM_DWInterface.DWInterfaceSoap dwi = new ASI_MFM_DWInterface.DWInterfaceSoap();
        ASI_MFM_DWInterface.WSResult resp = new ASI_MFM_DWInterface.WSResult();
        ASI_MFM_Callout_Limits__c lmt = getCalloutLimits(); 
        dwi.timeout_x = lmt.ASI_MFM_Timeout_Limit__c.intValue();        
        boolean stop_callout = false;
        integer retry_count = 0;
        while (!stop_callout) {
            try {
                resp = dwi.updatePOStrong(header_list, detail_list);
                ASI_MFM_Function.displayCalloutCount('updatePO');
                stop_callout = true;
                system.debug('Callout response: ' + resp.succeed);
                system.debug('Callout response message: ' + resp.message); 
            }
            catch (exception ex) { 
                if (ex.getMessage().contains('Read timed out') && retry_count < lmt.ASI_MFM_Timeout_Retry_Limit__c) {
                    retry_count++;
                }
                else {
                    stop_callout = true;
                    resp.succeed = 0;
                    resp.message = ex.getMessage();
                    system.debug('Callout exception: ' + ex.getMessage());                  
                }
            }           
        }
        
        datetime sync_time = datetime.now();
        for (ASI_MFM_PO__c p:PO_list) {
            p.ASI_MFM_Web_Service_Failed__c = resp.succeed == 1 ? false : true;
            p.ASI_MFM_Web_Service_Error_Message__c = resp.succeed == 1 ? null : resp.message;
            p.ASI_MFM_Sys_Sync_Time__c = sync_time;
            system.debug('Callout for PO ' + p.id + ' @ ' + sync_time.format());            
        }
        update PO_list;   
        for (ASI_MFM_PO_Line_Item__c i:item_list) {
            i.ASI_MFM_Web_Service_Failed__c = resp.succeed == 1 ? false : true;
            i.ASI_MFM_Sys_Sync_Time__c = sync_time;
        }
        update item_list;       
    }
    
    private static ASI_MFM_Callout_Limits__c getCalloutLimits() {
        ASI_MFM_Callout_Limits__c lmt = ASI_MFM_Callout_Limits__c.getValues('ASI_MFM');
        if (lmt == null) {
            lmt = new ASI_MFM_Callout_Limits__c();
            lmt.ASI_MFM_Timeout_Limit__c = 2000;
            lmt.ASI_MFM_Timeout_Retry_Limit__c = 0;
        }
        return lmt;
    }   
}