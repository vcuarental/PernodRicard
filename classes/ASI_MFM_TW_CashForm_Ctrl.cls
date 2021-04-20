/*Filename:    ASI_MFM_TW_CashForm_Ctrl.cls
* Author:      Clone from ASI_MFM_EditSmallAmountPayment_Ctrl
* Modified By: Twinkle LI (Introv Limited)
* Purpose:     Controller Class for Direct Payment - TW CRM
*
* History
* -----------------------------------------------------------------------------
*/public with sharing class ASI_MFM_TW_CashForm_Ctrl{
    public List <SAPHeaderObj> LSAPHeader {set;get;}
   
    //---- variables for SAPL list - by leo ----
    public map<integer, SAPLineObj> SAPL_Item_Map {set;get;}
    public List <SAPLineObj> Del_SAPL_Item {set;get;}
    public List <ASI_MFM_PO_Line_Item__c> Save_SAPL_POItem {set;get;}  
    public List <ASI_MFM_Payment_Line_Item__c> Save_SAPL_PAYItem {set;get;}    
    public Integer indexSAPL {set;get;}
    public Integer rowidSAPL {set;get;}
    public asi_mfm_prefix__c payment_prefixes;
    public asi_mfm_prefix__c po_prefixes;
    public boolean showEdit {set;get;}    
    public ASI_MFM_PO__c create_po;
    public ASI_MFM_Payment__c create_pa;
    public Decimal dec_PlanTotalAmt;
    public String userLanguage {set; get;}
    public Boolean isRedirect {set; get;}
    public double ToleranceNumber {set; get;} {ToleranceNumber=0;}
    private Map<id,ASI_MFM_Plan_Line_Item__c> PlanLineMap;

    private Map<id,decimal> POLineMap;    
    private Map<id,decimal> FOCLineMap;    
    
    private Decimal TotalFOCAmt; // All Foc 
    // A&P Amount
    private Decimal TotalAPFOCAmt=0; // 
    private Decimal TotalAPPlanAmount=0;
    private Decimal TotalAPPOAmount=0; //  (Draft/Approved/Completed)  
    private Decimal TotalAPPaymentAmt=0;
    private Decimal TnENon_AD_Amount=0;
    // A&D Amount
    private Decimal TotalADFOCAmt=0; //  
    private Decimal TotalADPlanAmount=0;
    private Decimal TotalADPOAmount=0; //  (Draft/Approved/Completed)  
    private Decimal TotalADPaymentAmt=0;
    private Decimal TnE_AD_Amount=0;
    
    public ASI_MFM_Payment__c dummy_pa {get; set;}
    //For over-payment calculation
    public Decimal paylAmount_current {set; get;}    // A&P Payment Amount    
    public Decimal paylAmount_current_AD {set; get;} // A&D Payment Amount 
    
    //***** Wapper Class **********
    public Class SAPHeaderObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
            } set; 
        }
        public ASI_MFM_PO__c po {get; set;}
        public ASI_MFM_Payment__c pay {get; set;}
    }
    public Class SAPLineObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
              } set;
            }
        public ASI_MFM_PO_Line_Item__c pol {get; set;}
        public ASI_MFM_Payment_Line_Item__c payl {get; set;}
        public ASI_MFM_Plan_Line_Item__c planl {get; set;}
        public Boolean boolSelected {get; set;}
        public String subBrandCode {get;set;}
        public String ACCode {get;set;}
        public String AnPTree {get;set;}
        public String customerName {get;set;}
        public Id customerId {get;set;}
    }
    //******End Wapper Class***********
    
    public ASI_MFM_TW_CashForm_Ctrl() {
        init();
    }
    
    public void init(){
        userLanguage = UserInfo.getLanguage();
        paylAmount_current = 0;
        paylAmount_current_AD = 0;
        ToleranceNumber=0;
        if (checkPrefixes()){
            showEdit = true;
            LSAPHeader = new List<SAPHeaderObj>();
            SAPHeaderObj smp = new SAPHeaderObj();
            smp.id = '1';
            smp.po = new ASI_MFM_PO__c ();
            smp.pay = new ASI_MFM_Payment__c();
            LSAPHeader.add(smp);
            dummy_pa = new ASI_MFM_Payment__c();
            Del_SAPL_Item = new List<SAPLineObj>();
            SAPL_Item_Map = new Map<Integer, SAPLineObj>();
            indexSAPL = 0;
        }else{
            showEdit = false;
        }
    }
    
    public PageReference Reset() {
        ApexPages.getMessages().clear();
        PageReference redirect = new PageReference(ApexPages.currentPage().getHeaders().get('Referer')); 
        return redirect;
    }
    
    public PageReference CopyFromPlan(){
        
        ApexPages.getMessages().clear();
        SAPL_Item_Map.clear();
        ToleranceNumber=0;
        TnENon_AD_Amount=0;
        TotalAPFOCAmt=0;
        TotalFOCAmt=0;
        TotalAPPOAmount=0;
        TotalAPPlanAmount=0;
        
        system.debug(LSAPHeader[0].pay.ASI_MFM_WT_Percentage__c);
        
        if(LSAPHeader[0].pay.ASI_MFM_VAT_Percentage__c != NULL && (LSAPHeader[0].pay.ASI_MFM_WT_Percentage__c != NULL || LSAPHeader[0].pay.ASI_MFM_One_Off_Payee__c != NULL)){
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'WT% and One-Off Payee must be empty.');
            apexpages.addmessage(err); 
            return null;
        }
        
        //Query Plan line items Description contains 'FOC' with Plan that user input   
        List<ASI_MFM_Plan_Line_Item__c> listPlanLineItem = [SELECT id, ASI_MFM_Plan__r.ASI_MFM_TnE_Non_A_D_Amount__c,ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Over_Spending_Checking__c,ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c,ASI_MFM_Plan__r.name,ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_A_C_Code__r.Name, ASI_MFM_Customer_Name__c, ASI_MFM_Customer_Name__r.Name, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Quantity__c, ASI_MFM_Unit_Cost__c, ASI_MFM_Total_Cost__c
                                                            FROM ASI_MFM_Plan_Line_Item__c 
                                                            WHERE ASI_MFM_Plan__c=:LSAPHeader[0].pay.ASI_MFM_Plan__c AND 
                                                                  RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item') AND
                                                                  (NOT ASI_MFM_List_Item_Description__c LIKE '%FOC%')
                                                            ORDER BY id];
        indexSAPL = 0;
        dec_PlanTotalAmt = 0;
        
        PlanLineMap = new Map<id,ASI_MFM_Plan_Line_Item__c>();
        
        for (ASI_MFM_Plan_Line_Item__c pl : listPlanLineItem){
            if(pl.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Over_Spending_Checking__c && pl.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c!=null){
                ToleranceNumber=pl.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c;
            }
            SAPLineObj sapl = new SAPLineObj();
            sapl.boolSelected = FALSE;
            sapl.payl = new ASI_MFM_Payment_Line_Item__c();
            sapl.payl.ASI_MFM_Payee__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c; 
            sapl.payl.ASI_MFM_Invoice_Number__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c;
            sapl.payl.ASI_MFM_Invoice_Date__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c;
            if(LSAPHeader[0].pay.ASI_MFM_Bank_Details__c != null && LSAPHeader[0].pay.ASI_MFM_Bank_Details__c != '')
                sapl.payl.ASI_MFM_Payment_List_Item_Description__c = LSAPHeader[0].pay.ASI_MFM_Bank_Details__c + ' ' + pl.ASI_MFM_List_Item_Description__c;
            else
                sapl.payl.ASI_MFM_Payment_List_Item_Description__c = pl.ASI_MFM_List_Item_Description__c;   
            sapl.pol = new ASI_MFM_PO_Line_Item__c();        
            sapl.planl = pl; 
            
            //Add by Elufa support 20160426
            if(!PlanLineMap.containsKey(pl.ASI_MFM_A_C_Code__c)){
                PlanLineMap.put(pl.ASI_MFM_A_C_Code__c, pl);
            }else{
                ASI_MFM_Plan_Line_Item__c planline= new ASI_MFM_Plan_Line_Item__c();
                planline=pl.clone(false, true);
                if(pl.ASI_MFM_Total_Cost__c!=null){
                    planline.ASI_MFM_Total_Cost__c=PlanLineMap.get(pl.ASI_MFM_A_C_Code__c).ASI_MFM_Total_Cost__c+pl.ASI_MFM_Total_Cost__c;
                }
                PlanLineMap.remove(pl.ASI_MFM_A_C_Code__c);
                
                PlanLineMap.put(pl.ASI_MFM_A_C_Code__c,planline);
            }
            /*
            if(pl.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c=='TOTAL A&P' && pl.ASI_MFM_Total_Cost__c != null ){
                TotalAPPlanAmount+=pl.ASI_MFM_Total_Cost__c;
            }
            */
            sapl.subBrandCode = pl.ASI_MFM_Sub_brand_Code__r.Name;
            sapl.ACCode = pl.ASI_MFM_A_C_Code__r.Name;
            sapl.AnPTree=pl.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c;
            if(pl.ASI_MFM_Customer_Name__c != null)
            {
                sapl.customerId = pl.ASI_MFM_Customer_Name__c;
                sapl.customerName = pl.ASI_MFM_Customer_Name__r.Name;
            }
            if(pl.ASI_MFM_Total_Cost__c != null){
                dec_PlanTotalAmt += pl.ASI_MFM_Total_Cost__c;
                
            }
            
            if(pl.ASI_MFM_Plan__r.ASI_MFM_TnE_Non_A_D_Amount__c!=null){
                TnENon_AD_Amount=pl.ASI_MFM_Plan__r.ASI_MFM_TnE_Non_A_D_Amount__c;
            }
                
            SAPL_Item_Map.put(indexSAPL++, sapl);
        }//End Plan Line
        
        // get Plan information
        For(ASI_MFM_Plan__c plan: [Select id, ASI_CRM_FOC_Amount_w_o_A_D__c, ASI_MFM_TW_Plan_Amount_AnP__c, ASI_MFM_TW_PO_AP_Amount__c, ASI_MFM_TW_Payment_AP_Amount__c, ASI_MFM_TnE_Non_A_D_Amount__c, ASI_MFM_TW_AP_overspend__c, 
                                              ASI_CRM_TW_FOC_Amount_A_D__c, ASI_MFM_TW_Plan_Amount_AnD__c, ASI_MFM_TW_PO_AD_Amount__c, ASI_MFM_TW_Payment_AD_Amount__c, ASI_MFM_TW_TnE_A_D_Amount__c, ASI_MFM_TW_AD_overspend__c from ASI_MFM_Plan__c where id = :LSAPHeader[0].pay.ASI_MFM_Plan__c]){            
            // A&P Amount        
            TotalAPFOCAmt=plan.ASI_CRM_FOC_Amount_w_o_A_D__c;  
            TotalAPPlanAmount=plan.ASI_MFM_TW_Plan_Amount_AnP__c;
            TotalAPPOAmount=plan.ASI_MFM_TW_PO_AP_Amount__c; 
            TotalAPPaymentAmt=plan.ASI_MFM_TW_Payment_AP_Amount__c;                                       
            TnENon_AD_Amount=plan.ASI_MFM_TnE_Non_A_D_Amount__c;
            // A&D Amount
            TotalADFOCAmt=plan.ASI_CRM_TW_FOC_Amount_A_D__c; 
            TotalADPlanAmount=plan.ASI_MFM_TW_Plan_Amount_AnD__c;
            TotalADPOAmount=plan.ASI_MFM_TW_PO_AD_Amount__c; 
            TotalADPaymentAmt=plan.ASI_MFM_TW_Payment_AD_Amount__c;                                      
            TnE_AD_Amount=plan.ASI_MFM_TW_TnE_A_D_Amount__c;
        }
        /*
        List <ASI_MFM_PO_Line_Item__c> POLineList= [select id,ASI_MFM_A_C_Code__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c  from ASI_MFM_PO_Line_Item__c 
                                                    where  ASI_MFM_PO__r.ASI_MFM_Status__c != 'Draft' and ASI_MFM_PO__r.ASI_MFM_Plan__c=:LSAPHeader[0].pay.ASI_MFM_Plan__c AND 
                                                    RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item') 
                                                    and ASI_MFM_Base_Currency_Amount__c !=null ]; 
        POLineMap= new Map<id,decimal>();
        if(POLineList!=null && POLineList.size()>0){
            for(ASI_MFM_PO_Line_Item__c pol : POLineList){
                TotalAPPOAmount+= pol.ASI_MFM_Base_Currency_Amount__c;
                if(pol.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c.contains('A&P')){
                    if(!POLineMap.containsKey(pol.ASI_MFM_A_C_Code__c)){
                        POLineMap.put(pol.ASI_MFM_A_C_Code__c, pol.ASI_MFM_Base_Currency_Amount__c);
                    }else{
                        decimal PLamount=POLineMap.get(pol.ASI_MFM_A_C_Code__c)+pol.ASI_MFM_Base_Currency_Amount__c;
                        POLineMap.remove(pol.ASI_MFM_A_C_Code__c);
                        POLineMap.put(pol.ASI_MFM_A_C_Code__c,PLamount);
                    }
                }
                
            }
        } // end of po line grouping
        */
        
        /*
        List<ASI_FOC_Request_Item__c> FOCLines=[select id,ASI_CRM_Plan_Line_Item__r.ASI_MFM_Unit_Cost__c,ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c,ASI_FOC_Request_Quantity_Bottle__c,ASI_CRM_TW_Amount__c,ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c from ASI_FOC_Request_Item__c where 
                                                ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c!='Draft' AND ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c != 'Cancel' and ASI_CRM_TW_Amount__c!=null and
                                                ASI_CRM_Plan_Line_Item__r.ASI_MFM_Plan__c=:LSAPHeader[0].pay.ASI_MFM_Plan__c and ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c !=null and 
                                                RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_FOC_Request_Item')  ];
       FOCLineMap= new Map<id,decimal>();
        for(ASI_FOC_Request_Item__c focl:FOCLines){
             TotalFOCAmt+=focl.ASI_CRM_TW_Amount__c;
             if(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c=='TOTAL A&P'){
                 system.debug('Now Amount :  '+focl.ASI_CRM_TW_Amount__c);
                 //TotalAPFOCAmt+=focl.ASI_CRM_TW_Amount__c;
                 if(!FOCLineMap.containsKey(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c)){
                     FOCLineMap.put(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c,focl.ASI_CRM_TW_Amount__c);
                 }else{ //system.debug('Ac cODE : '+FOCLineMap.get(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c));
                     decimal FOCAmount=FOCLineMap.get(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c)+((Decimal)focl.ASI_CRM_TW_Amount__c);
                     FOCLineMap.remove(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c);
                     FOCLineMap.put(focl.ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c,FOCAmount);
                 }
             }
        }
		*/
        return null;
    }
    
    public void Refresh(){  
        
        if(SAPL_Item_Map.size() >0 && SAPL_Item_Map != NULL){
            for (integer i : SAPL_Item_Map.keySet()){
               
                if(!SAPL_Item_Map.get(i).boolSelected){
                    SAPL_Item_Map.remove(i); 
                }     
            }
        }
        
    }
    
    public void Clone_SAPL(){   
        ApexPages.getMessages().clear();
        
        SAPLineObj sapl = SAPL_Item_Map.get(rowidSAPL);
        SAPLineObj sapl_Clone = new SAPLineObj();
        
        sapl_Clone.payl = new ASI_MFM_Payment_Line_Item__c();
        sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
        sapl_Clone.planl = new ASI_MFM_Plan_Line_Item__c();
        
        sapl_Clone.boolSelected = TRUE;
        
        sapl_Clone.planl.ASI_MFM_Sub_brand_Code__c = sapl.planl.ASI_MFM_Sub_brand_Code__c;
        sapl_Clone.planl.ASI_MFM_A_C_Code__c = sapl.planl.ASI_MFM_A_C_Code__c;
        sapl_Clone.planl.ASI_MFM_List_Item_Description__c = sapl.planl.ASI_MFM_List_Item_Description__c;
        sapl_Clone.planl.ASI_MFM_Quantity__c = sapl.planl.ASI_MFM_Quantity__c;
        sapl_Clone.planl.ASI_MFM_Unit_Cost__c = sapl.planl.ASI_MFM_Unit_Cost__c;
        sapl_Clone.planl.ASI_MFM_Total_Cost__c = sapl.planl.ASI_MFM_Total_Cost__c;
        sapl_Clone.planl.ASI_MFM_Unit_Cost__c = sapl.planl.ASI_MFM_Unit_Cost__c;
        
        sapl_Clone.payl.ASI_MFM_Payee__c = sapl.payl.ASI_MFM_Payee__c;
        sapl_Clone.payl.ASI_MFM_Invoice_Number__c = sapl.payl.ASI_MFM_Invoice_Number__c;
        sapl_Clone.payl.ASI_MFM_Invoice_Date__c = sapl.payl.ASI_MFM_Invoice_Date__c;
        sapl_Clone.payl.ASI_MFM_Payment_List_Item_Description__c = sapl.payl.ASI_MFM_Payment_List_Item_Description__c;
        
        sapl_Clone.payl.ASI_MFM_AP_Remark__c = sapl.payl.ASI_MFM_AP_Remark__c;
        sapl_Clone.payl.ASI_MFM_Recipient_Name__c = sapl.payl.ASI_MFM_Recipient_Name__c;
        sapl_Clone.payl.ASI_MFM_Print_Sequence__c = sapl.payl.ASI_MFM_Print_Sequence__c;
        
        sapl_Clone.subBrandCode = sapl.subBrandCode;
        sapl_Clone.ACCode = sapl.ACCode;
        sapl_Clone.customerId = sapl.customerId;
        sapl_Clone.customerName = sapl.customerName;
        sapl_Clone.AnPTree = sapl.AnPTree;
        
        SAPL_Item_Map.put(indexSAPL++, sapl_Clone);
        system.debug('###Clone_SAPL: ' + SAPL_Item_Map + 'rowid:' + rowidSAPL + 'indexSAPL:' + indexSAPL);
    }
    
    public boolean checkPrefixes(){
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        if (u.userRole.developerName == null) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The role of the user is not defined yet');
            apexpages.addmessage(err); 
        }
        else if (u.asi_mfm_country__c == null) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'The country of the user is not defined yet');
            apexpages.addmessage(err);
            return false;
        }
        else {
            list<asi_mfm_role_prefix_relationship__c> paypx_list = new list<asi_mfm_role_prefix_relationship__c>();
            list<asi_mfm_role_prefix_relationship__c> popx_list = new list<asi_mfm_role_prefix_relationship__c>();
          
            for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name, asi_mfm_prefix__r.asi_mfm_module__c  from asi_mfm_role_prefix_relationship__c
              where asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name]) {
              if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('Payment'))
                  paypx_list.add(px);
              else if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('PO'))
                  popx_list.add(px);
            }    
            
            if (paypx_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input payments');
                apexpages.addmessage(err); 
                return false;
            } else if (popx_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input POs');
                apexpages.addmessage(err); 
                return false;
            }
            else { 
                payment_prefixes = paypx_list[0].asi_mfm_prefix__r;
                po_prefixes = popx_list[0].asi_mfm_prefix__r;
                system.debug('PO Prefix: ' + po_prefixes.name);
                system.debug('Payment Prefix: ' + payment_prefixes.name);        
            }
        }    
        return true;
    }
    
    public PageReference SaveRecord() {
        //Validate Payment amount cannot exceed $1000 which requires PO
        isRedirect = false;
        ASI_MFM_Approval_Setting__c setting = ASI_MFM_Approval_Setting__c.getInstance('TW');
        double maxDirectPayAmount = 0;
        
        //Remarked by William Yang (Introv) @ 20160620
        //LSAPHeader[0].pay.ASI_MFM_Currency__c = 'TWD';
        
        if (setting != null && setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c != null){
            maxDirectPayAmount = setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c;
        }
        
        //Retrieve Exchange Rate
        double exchangeRate = 0;
        double totalPaymentAmt = 0;
        string country = 'TW';
        string base_ccy = 'USD';
        string counter_ccy = LSAPHeader[0].pay.ASI_MFM_Currency__c;
        date last_effective_date = System.Today();

        list<ASI_MFM_Exchange_Rate__c> xr_list = [SELECT ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                                                  WHERE ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country AND 
                                                  ASI_MFM_Base_Currency__c = :base_ccy AND 
                                                  ASI_MFM_Counter_Currency__c = :counter_ccy AND 
                                                  ASI_MFM_Effective_Date__c <= :last_effective_date
                                                  ORDER BY ASI_MFM_Counter_Currency__c ASC, ASI_MFM_Effective_Date__c DESC];        
        System.debug('LSAPHeader[0].pay.ASI_MFM_Currency__c: ' + LSAPHeader[0].pay.ASI_MFM_Currency__c + ' base_ccy:' + base_ccy);
        
        //Calculate total payment amount for this Plan
        decimal dec_PaymentTotalAmt = 0;
        List<ASI_MFM_Payment__c> listPayment = [SELECT id, ASI_MFM_Payment_Amount__c FROM ASI_MFM_Payment__c WHERE ASI_MFM_Plan__c=:LSAPHeader[0].pay.ASI_MFM_Plan__c];
        for(ASI_MFM_Payment__c p:listPayment){
            if(p.ASI_MFM_Payment_Amount__c != NULL)
                dec_PaymentTotalAmt += p.ASI_MFM_Payment_Amount__c;
        }
        
        if (LSAPHeader[0].pay.ASI_MFM_Currency__c == base_ccy){
            exchangeRate = 1;
        }
        else {
            for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                System.debug('xr.ASI_MFM_Counter_Currency__c: ' + xr.ASI_MFM_Counter_Currency__c + ' counter_ccy: ' + counter_ccy + ' xr.ASI_MFM_Effective_Date__c: ' + xr.ASI_MFM_Effective_Date__c + ' last_effective_date: ' + last_effective_date);
                if (xr.ASI_MFM_Counter_Currency__c == counter_ccy && xr.ASI_MFM_Effective_Date__c <= last_effective_date) {
                    exchangeRate = xr.ASI_MFM_Exchange_Rate__c;
                    break;
                }
                else if (xr.ASI_MFM_Counter_Currency__c > counter_ccy) {
                    break;
                }
            }
        }                   
        
        //Calculate Total Payment Amount
        for (integer i : SAPL_Item_Map.keySet()){
            SAPLineObj sapl = SAPL_Item_Map.get(i);
            if(sapl.payl.ASI_MFM_Payment_Amount__c != NULL)
                totalPaymentAmt += sapl.payl.ASI_MFM_Payment_Amount__c ;
           
            if(LSAPHeader[0].pay.ASI_MFM_VAT_Percentage__c == NULL && LSAPHeader[0].pay.ASI_MFM_WT_Percentage__c != NULL && LSAPHeader[0].pay.ASI_MFM_One_Off_Payee__c != NULL){
                if (sapl.payl.ASI_MFM_Invoice_Date__c == NULL || sapl.payl.ASI_MFM_Payment_List_Item_Description__c == NULL){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter all Invoice Date and Payment Line Item Description.');
                    ApexPages.addMessage(myMsg);
                    return null;
                } 
            }
            else{
                if (sapl.payl.ASI_MFM_Invoice_Number__c == NULL || sapl.payl.ASI_MFM_Invoice_Date__c == NULL || sapl.payl.ASI_MFM_Payment_List_Item_Description__c == NULL){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter all Invoice Number, Invoice Date and Payment Line Item Description.');
                    ApexPages.addMessage(myMsg);
                    return null;
                } 
            }        
        }
        
        //Validation: Ensure Direct Payment Line is entered
        if (SAPL_Item_Map.isEmpty()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Direct Payment Line.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        //Added by Elufa 20151229 Prohibit Plan overspending on Direct Payment
        ASI_MFM_Plan__c plan = [SELECT id, ASI_MFM_Plan_Amount__c,ASI_MFM_Plan_Balance__c,ASI_MFM_Prefix__r.ASI_MFM_Over_Spending_Checking__c,ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c FROM ASI_MFM_Plan__c WHERE id=:LSAPHeader[0].pay.ASI_MFM_Plan__c];
        if(plan.ASI_MFM_Prefix__r.ASI_MFM_Over_Spending_Checking__c){
            if( plan.ASI_MFM_Plan_Amount__c!=null && plan.ASI_MFM_Plan_Amount__c!=0){
                double tolerance=plan.ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c!=null? plan.ASI_MFM_Prefix__r.ASI_MFM_Tolerance__c:0;
                double balance =(plan.ASI_MFM_Plan_Balance__c-totalPaymentAmt)/plan.ASI_MFM_Plan_Amount__c;
                if(balance<0 && (math.abs(balance)>(tolerance/100))){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment Amount greater than Tolerance');
                    ApexPages.addMessage(myMsg);
                    return null;  
                }
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Plan Amount canot be null or 0.');
                ApexPages.addMessage(myMsg);
                return null;   
            } 
        }
        //Added by Elufa 20151229 Prohibit Plan overspending on Direct Payment
        System.Savepoint sp = database.setSavepoint();
        
        //1st create PO Header
        create_po = new ASI_MFM_PO__c();
        create_po.ASI_MFM_Currency__c = LSAPHeader[0].pay.ASI_MFM_Currency__c;
        create_po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO_Read_Only');
        create_po.ASI_MFM_Plan__c = LSAPHeader[0].pay.ASI_MFM_Plan__c;
        create_po.ASI_MFM_Prefix__c = po_prefixes.id;
        create_po.ASI_MFM_Supplier_Name__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c ;
        create_po.ASI_MFM_Status__c = 'Final';
        create_po.ASI_MFM_PO_Type__c = 'Normal';
        create_po.ASI_MFM_Is_Direct_Payment__c = true;
        create_po.ASI_MFM_PO_Start_Date__c = System.Today();
        create_po.ASI_MFM_PO_End_Date__c = System.Today();
        
        try {    
            insert create_po; // insert po
            isRedirect = true;
        } catch (DmlException dmle) {
            
          database.rollback(sp);
          apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
          apexpages.addmessage(err); 
          isRedirect = false;
        } catch (Exception e) {
          database.rollback(sp);
          apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
          apexpages.addmessage(err);
          isRedirect = false;
        }
        
        //2nd create Payment Header
        create_pa = new ASI_MFM_Payment__c();
        create_pa.ASI_MFM_Currency__c = LSAPHeader[0].pay.ASI_MFM_Currency__c;
        if(dummy_pa.ASI_MFM_G_L_Date__c != NULL)
            create_pa.ASI_MFM_Cashflow_Date__c = dummy_pa.ASI_MFM_G_L_Date__c;
        else
            create_pa.ASI_MFM_Cashflow_Date__c = System.today();
        create_pa.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_TW_Payment_Read_Only');
        create_pa.ASI_MFM_Prefix__c = payment_prefixes.id;
        create_pa.ASI_MFM_PO__c = create_po.id;
        create_pa.ASI_MFM_Plan__c = LSAPHeader[0].pay.ASI_MFM_Plan__c;
        create_pa.ASI_MFM_Status__c = 'Draft';
        create_pa.ASI_MFM_Is_Direct_Payment__c = true;
        create_pa.ASI_MFM_G_L_Date__c = System.Today();
        create_pa.ASI_MFM_Payment_Amount__c = totalPaymentAmt;
        create_pa.ASI_MFM_Supplier_Name__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c ;
        if(LSAPHeader[0].pay.ASI_MFM_VAT_Percentage__c == NULL && LSAPHeader[0].pay.ASI_MFM_WT_Percentage__c != NULL && LSAPHeader[0].pay.ASI_MFM_One_Off_Payee__c != NULL)
            create_pa.ASI_MFM_Invoice_Number__c = null;
        else
            create_pa.ASI_MFM_Invoice_Number__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c;
        create_pa.ASI_MFM_Invoice_Date__c =LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c;
        create_pa.ASI_MFM_One_Off_Payee__c = LSAPHeader[0].pay.ASI_MFM_One_Off_Payee__c;
        create_pa.ASI_MFM_VAT_Percentage__c = LSAPHeader[0].pay.ASI_MFM_VAT_Percentage__c;
        create_pa.ASI_MFM_Insurance_Percentage__c = LSAPHeader[0].pay.ASI_MFM_Insurance_Percentage__c;
        create_pa.ASI_MFM_WT_Percentage__c = LSAPHeader[0].pay.ASI_MFM_WT_Percentage__c;
        create_pa.ASI_MFM_Payment_Amount__c = totalPaymentAmt;
        
        if(isRedirect == true){
            try {    
                insert create_pa; // insert payment
                isRedirect = true;
            } catch (DmlException dmle) {
              database.rollback(sp);
              apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
              apexpages.addmessage(err); 
              isRedirect = false;
            } catch (Exception e) {
              database.rollback(sp);
              apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
              apexpages.addmessage(err);
              isRedirect = false;
            }
        }
        
        //ASI_MFM_Payment__c insertedPayment = [SELECT id, Name FROM ASI_MFM_Payment__c WHERE Id =: create_pa.id LIMIT 1];
        Save_SAPL_POItem = new List <ASI_MFM_PO_Line_Item__c> () ;
        Save_SAPL_PAYItem = new List <ASI_MFM_Payment_Line_Item__c> () ; 
        
        for (integer i : SAPL_Item_Map.keySet()){
            SAPLineObj sapl = SAPL_Item_Map.get(i);
            
            //3rd create PO Line Item
            ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c();
            poline.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item');
            poline.ASI_MFM_PO__c = create_po.id;
            poline.ASI_MFM_G_L_Date__c = System.Today();
            poline.ASI_MFM_Sub_brand_Code__c = sapl.planl.ASI_MFM_Sub_brand_Code__c ;
            poline.ASI_MFM_List_Item_Description__c = sapl.payl.ASI_MFM_Payment_List_Item_Description__c ;
            poline.ASI_MFM_A_C_Code__c = sapl.planl.ASI_MFM_A_C_Code__c;
            poline.ASI_MFM_GnH_Recipient_Name__c = sapl.payl.ASI_MFM_Recipient_Name__c;
            poline.ASI_MFM_Print_Sequence__c = sapl.payl.ASI_MFM_Print_Sequence__c;
            poline.ASI_MFM_Amount__c = sapl.payl.ASI_MFM_Payment_Amount__c;
            poline.ASI_MFM_Customer_Name__c = sapl.customerId;
            
            //4th create Payment Line Item               
            ASI_MFM_Payment_Line_Item__c paline = new ASI_MFM_Payment_Line_Item__c();
            paline.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_TW_Payment_Line_Item');
            paline.ASI_MFM_Payment__c = create_pa.id;
            paline.ASI_MFM_Payee__c = sapl.payl.ASI_MFM_Payee__c;
            if(LSAPHeader[0].pay.ASI_MFM_VAT_Percentage__c == NULL && LSAPHeader[0].pay.ASI_MFM_WT_Percentage__c != NULL && LSAPHeader[0].pay.ASI_MFM_One_Off_Payee__c != NULL)
                //paline.ASI_MFM_Invoice_Number__c = insertedPayment.Name;
                paline.ASI_MFM_Invoice_Number__c = create_pa.Name;
            else
                paline.ASI_MFM_Invoice_Number__c = sapl.payl.ASI_MFM_Invoice_Number__c;
                
            paline.ASI_MFM_Invoice_Date__c = sapl.payl.ASI_MFM_Invoice_Date__c;
            paline.ASI_MFM_Payment_List_Item_Description__c = sapl.payl.ASI_MFM_Payment_List_Item_Description__c ;
            
            if(sapl.payl.ASI_MFM_Payment_List_Item_Description__c != null && sapl.payl.ASI_MFM_Payment_List_Item_Description__c != '')
                if(sapl.payl.ASI_MFM_Payment_List_Item_Description__c.length() < 30)
                    paline.ASI_MFM_AP_Remark__c = sapl.payl.ASI_MFM_Payment_List_Item_Description__c.substring(0);   
                else
                    paline.ASI_MFM_AP_Remark__c = sapl.payl.ASI_MFM_Payment_List_Item_Description__c.substring(0,30); 
            
        	paline.ASI_MFM_Recipient_Name__c = sapl.payl.ASI_MFM_Recipient_Name__c;
            paline.ASI_MFM_Print_Sequence__c = sapl.payl.ASI_MFM_Print_Sequence__c;
            paline.ASI_MFM_Payment_Amount__c = sapl.payl.ASI_MFM_Payment_Amount__c;
            
            Save_SAPL_POItem.add(poline);
            Save_SAPL_PAYItem.add(paline);
        }
        
        if(isRedirect == true){
            try {    
                insert Save_SAPL_POItem; // insert po line item
    
                isRedirect = true;
            } catch (DmlException dmle) {
              database.rollback(sp);
              apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
              apexpages.addmessage(err); 
              isRedirect = false;
            } catch (Exception e) {
              database.rollback(sp);
              apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
              apexpages.addmessage(err);
              isRedirect = false;
            }
        }
        
        for (Integer p = 0;p < Save_SAPL_POItem.size();p++){
            Save_SAPL_PAYItem[p].ASI_MFM_PO_Line_Item__c = Save_SAPL_POItem[p].id;
        }
        if(isRedirect == true){
            try {    
                insert Save_SAPL_PAYItem; // insert payment line item
    
                isRedirect = true;
            } catch (DmlException dmle) {
              database.rollback(sp);
              apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
              apexpages.addmessage(err); 
              isRedirect = false;
            } catch (Exception e) {
              database.rollback(sp);
              apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
              apexpages.addmessage(err);
              isRedirect = false;
            }
        }
        PageReference redirect;
        if (isRedirect){
            redirect = new PageReference('/apex/ASI_MFM_TW_CashFormP2_Page'); 
            redirect.getParameters().put('poid', create_po.id);
            redirect.getParameters().put('paid', create_pa.id);
        }else{
            redirect = null;
        }        
        return redirect;
    }     
    /*
    public void ValidateRecord(){
        ASI_MFM_Plan__c plan = [SELECT id, ASI_MFM_Plan_Amount__c FROM ASI_MFM_Plan__c WHERE id=:LSAPHeader[0].pay.ASI_MFM_Plan__c];
        if(paylAmount_current > plan.ASI_MFM_Plan_Amount__c){
            ApexPages.addMessage(new apexpages.message(apexpages.severity.warning, 'Total amount '+paylAmount_current+' is larger than Plan amount '+plan.ASI_MFM_Plan_Amount__c+'.'));
            ApexPages.addMessage(new apexpages.message(apexpages.severity.warning, 'Please click Save button again if you confirm this changes.'));
        }
        else{
            SaveRecord();  
        }
    }
    */
    public PageReference SaveAction(){
         //PlanLineMap  POLineMap  system.assertEquals(null,ToleranceNumber);
        PageReference redirect;
        isRedirect = false;
        paylAmount_current = 0;
        paylAmount_current_AD = 0;
        Boolean Isprocess=true;
        Boolean IsTAP=false;
        String Msg='';
        Map<id,decimal> CurrentLineMap = new Map<id,decimal>();
        for (integer i : SAPL_Item_Map.keySet()){
            SAPLineObj sapl = SAPL_Item_Map.get(i);
            
            
            if(sapl.payl.ASI_MFM_Payment_Amount__c == null || sapl.payl.ASI_MFM_Payment_Amount__c == 0){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Payment Amount.');
                ApexPages.addMessage(myMsg);
                return null;
            }  
            
            //Add byElufa support 20160421
            if(sapl.AnPTree.contains('A&P') && sapl.payl.ASI_MFM_Payment_Amount__c != null && sapl.planl.ASI_MFM_Plan__r.name!=null){
                /*if(sapl.planl.ASI_MFM_Plan__r.name.substring(0,1)=='F' || sapl.planl.ASI_MFM_Plan__r.name.substring(0,1)=='M'){
                    IsTAP=true;
                    if(!CurrentLineMap.containsKey(sapl.planl.ASI_MFM_A_C_Code__c)){
                        CurrentLineMap.put(sapl.planl.ASI_MFM_A_C_Code__c, sapl.payl.ASI_MFM_Payment_Amount__c);                     
                    }else{
                        decimal PLamount=CurrentLineMap.get(sapl.planl.ASI_MFM_A_C_Code__c)+sapl.payl.ASI_MFM_Payment_Amount__c;
                        CurrentLineMap.remove(sapl.planl.ASI_MFM_A_C_Code__c);
                        CurrentLineMap.put(sapl.planl.ASI_MFM_A_C_Code__c,PLamount);  
                    }
                }*/
                paylAmount_current += sapl.payl.ASI_MFM_Payment_Amount__c;               
            }else if(sapl.AnPTree.contains('A&D') && sapl.payl.ASI_MFM_Payment_Amount__c != null && sapl.planl.ASI_MFM_Plan__r.name!=null){
            	paylAmount_current_AD += sapl.payl.ASI_MFM_Payment_Amount__c;               
            }
            //if(SAPL_Item_Map.get(i) != NULL && SAPL_Item_Map.get(i).payl != NULL && SAPL_Item_Map.get(i).payl.ASI_MFM_Payment_Amount__c != NULL)
            //    paylAmount_current += SAPL_Item_Map.get(i).payl.ASI_MFM_Payment_Amount__c;
        } //End of For Loop
                
        /*
        if(!CurrentLineMap.isEmpty() && IsTAP){
            for(string k:POLineMap.keySet()){
                if(CurrentLineMap.containsKey(k)){//Changed-20160826 Elufa Support
                    decimal PLamount=CurrentLineMap.get(k)+POLineMap.get(k);
                    CurrentLineMap.remove(k);
                    CurrentLineMap.put(k,PLamount);  
                }
            }
            
            for(string k:FOCLineMap.keySet()){
                if(CurrentLineMap.containsKey(k)){//Changed-20170209 Elufa Support
                    decimal PLamount=CurrentLineMap.get(k)+FOCLineMap.get(k);
                    CurrentLineMap.remove(k);
                    CurrentLineMap.put(k,PLamount);  
                }
            }
            
            for (string k : CurrentLineMap.keySet()){
                if(PlanLineMap.containsKey(k)){
                    if((PlanLineMap.get(k).ASI_MFM_Total_Cost__c)<CurrentLineMap.get(k)){
                        Isprocess=false;
                        Msg+='A/C Code: '+ PlanLineMap.get(k).ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c+': Total Spending Amount ( $'+CurrentLineMap.get(k).intValue().format()+') greater than Plan Amount :( $' +(PlanLineMap.get(k).ASI_MFM_Total_Cost__c*(1+ToleranceNumber/100)).intValue().format()+') . <br/>';
                    }
                }
            }
            //Total AP Balance checking : Total AP Balance = total A&P Plan Amount - total A&P PO Amount (Approved/Completed)-Total FOC Amount (w/o A&D) – Total T&E Amount (w/o A&D). 
            decimal TotalAPBalanceChecking= TotalAPPlanAmount-TotalAPPOAmount-TotalAPFOCAmt-TnENon_AD_Amount;
            if((TotalAPBalanceChecking)<0){
                Msg+='Total AP Amount Balance('+TotalAPBalanceChecking.format()+')=Total A&P Plan Amount('+TotalAPPlanAmount.format()+')-Total A&P PO Amount (Approved/Completed)('+TotalAPPOAmount.format()+') -Total FOC Amount (w/o A&D) ('+TnENon_AD_Amount.format()+')  <0. <br/>';
            }
            
        }
		*/
        // Added by 2018-09-13 Linus@introv
        // A&P Balance Checking
        Decimal APBalance = TotalAPPlanAmount - TotalAPPOAmount - TotalAPPaymentAmt - paylAmount_current - TotalAPFOCAmt - TnENon_AD_Amount;
        if(APBalance<0){
            Msg+='<br/> <b>A&P Checking</b>: A&P Balance is (' + APBalance.format() + ') < 0 <br/>';    
            IsProcess=false;
        }
        Decimal ADBalance = TotalADPlanAmount - TotalADPOAmount - TotalADPaymentAmt - paylAmount_current_AD - TotalADFOCAmt - TnE_AD_Amount;
        if(ADBalance<0){
            Msg+='<br/> <b>A&D Checking</b>: A&D Balance is (' + ADBalance.format() + ') < 0 <br/>';    
            IsProcess=false;
        }
        //modify by Elufa 20151229 Prohibit Plan overspending on PO & Direct Payment
        
        if(Isprocess){
            SaveRecord();
        }else{
            Msg = Msg.removeEnd('<br/>');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Msg);
            ApexPages.addMessage(myMsg);
            return null;
        }
            
        if (isRedirect){
            redirect = new PageReference('/apex/ASI_MFM_TW_CashFormP2_Page'); 
            redirect.getParameters().put('poid', create_po.id);
            redirect.getParameters().put('paid', create_pa.id);
        }else{
            redirect = null;
        }  
       // }
        return redirect;
    }
    
    @RemoteAction
    public static String[] findSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            System.debug('sot is null' );        
            return null;
        }
        
        // create the filter text
        String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
        //begin building the dynamic soql query
        
        String soql = 'select Name from ' + obj  +' order by Name';
        List<sObject> sobjs = new List<sObject>();       
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
               results.add(String.valueOf(sobj.get('Name'))); 
            }
            System.debug('results:' + results);
        }
        catch (QueryException e) {
            return null;
        }
        return results;
   }
}