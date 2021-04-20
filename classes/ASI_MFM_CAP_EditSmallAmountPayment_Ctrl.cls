public with sharing class ASI_MFM_CAP_EditSmallAmountPayment_Ctrl {
    public List <SAPHeaderObj> LSAPHeader {set;get;}
    // Option Items for Type of Payment: CAPEX or OPEX
    private final List<String> typeOptions = new String[]{'--None--','CAPEX', 'OPEX'};
    public string[] selectedType = new String[]{};
    
    //---- variables for SAPL list - by leo ----
    public List <SAPLineObj> SAPL_Item {set;get;}
    public map<integer, SAPLineObj> SAPL_Item_Map {set;get;}
    public List <SAPLineObj> Del_SAPL_Item {set;get;}
    public List <ASI_MFM_PO_Line_Item__c> Save_SAPL_POItem {set;get;}  
    public List <ASI_MFM_Payment_Line_Item__c> Save_SAPL_PAYItem {set;get;}    
    public Integer indexSAPL {set;get;}
    public Integer rowidSAPL {set;get;}
    public String recordtypeSelected {set;get;}
    public asi_mfm_prefix__c payment_prefixes;
    public asi_mfm_prefix__c po_prefixes;
    public boolean showEdit {set;get;}    
    public ASI_MFM_PO__c create_po;
    public ASI_MFM_Payment__c create_pa;
        User userInstance;
    // Default AP Code if the plan selected has AP prefix
    private String defaultAPCode {get;set;}
    
    public ASI_MFM_CAP_EditSmallAmountPayment_Ctrl() {
        init();
    }
    
    public void init(){
        // Initialize the custom setting MFM default values for AP Code Consulting
        List<ASI_MFM_Default_Value__c> mfmDefaultList = [SELECT ID, Name, ASI_MFM_Value__c, Country__c 
                                                            FROM ASI_MFM_Default_Value__c
                                                            WHERE Country__c = 'HK'];
        
        for(ASI_MFM_Default_Value__c mfmDefault : mfmDefaultList)
        {
            if (mfmDefault.name == 'CAP_AP_Consulting_Code__c')
                defaultAPCode = mfmDefault.ASI_MFM_Value__c;
        }
                
                userInstance = [SELECT  Id,
                                        ASI_MFM_Country__c
                                  FROM User
                                 WHERE Id = :UserInfo.getUserId()];
                
        if (checkPrefixes()){
            system.debug('checkPrefixes:' + checkPrefixes());
            
            showEdit  = true;
            LSAPHeader = new List<SAPHeaderObj>();
            SAPHeaderObj smp = new SAPHeaderObj();
            smp.id = '1';
            smp.po = new ASI_MFM_PO__c ();
            smp.pay = new ASI_MFM_Payment__c();
            if(ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c) != NULL) {
                smp.pay.ASI_MFM_Currency__c = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).Currency__c;
            } else {
                smp.pay.ASI_MFM_Currency__c = 'HKD';
            }
            LSAPHeader.add(smp);
            
            
            Del_SAPL_Item = new List<SAPLineObj>();
            SAPL_Item_Map = new Map<Integer, SAPLineObj>();
            indexSAPL = 0;
            /*SAPLineObj sapl = new SAPLineObj();
            //sapl.id = string.valueOf(indexSAPL);
            sapl.pl= new ASI_MFM_Payment_Line_Item__c();
            sapl.pol= new ASI_MFM_PO_Line_Item__c();
            SAPL_Item_Map.put(indexSAPL++, sapl);*/
           
        }else
        {
            system.debug('checkPrefixes:' + checkPrefixes());
            showEdit  = false;
        }
    }
    
    public List<SelectOption> getTypeItems() {
        List<SelectOption> options = new List<SelectOption>();
        for (String i : typeOptions){
            options.add(new SelectOption(i,i));
        }

        return options;
    }
    
    public String[] getselectedType() {
        return selectedType;
    }
 
    public void setselectedType (String[] selectedType) {
        this.selectedType = selectedType;
    }
    
    //***** Wapper Class **********
    public Class SAPHeaderObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
              } 
            set; }
        public ASI_MFM_PO__c po {get; set;}
        public ASI_MFM_Payment__c pay {get; set;}
        public String Type {get;set;}
        public Boolean isTnE {get;set;}
    }
    public Class SAPLineObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
              } 
            set; }
        public ASI_MFM_PO_Line_Item__c pol {get; set;}
        public ASI_MFM_Payment_Line_Item__c pl {get; set;}
    }
    //******End Wapper Class***********
    public PageReference SaveRecord() 
    {
    
        //1st create PO Header
        create_po = new ASI_MFM_PO__c();
        
        //Validate Payment amount cannot exceed $1000 which requires PO
        ASI_MFM_Approval_Setting__c setting = ASI_MFM_Approval_Setting__c.getInstance('HK');
        double maxDirectPayAmount = 0;
        
        if (setting != null && setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c != null){
                maxDirectPayAmount = setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c;
        }
        
        //Retrieve Exchange Rate
        double exchangeRate = 0;
        double totalPaymentAmt = 0;
        string country = 'HK';
        string base_ccy = 'USD';
        string counter_ccy = LSAPHeader[0].pay.ASI_MFM_Currency__c;
        date last_effective_date = System.Today();

        list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
            where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                and ASI_MFM_Counter_Currency__c = :counter_ccy and ASI_MFM_Effective_Date__c <= :last_effective_date
                    order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
        
        System.debug('LSAPHeader[0].pay.ASI_MFM_Currency__c: ' + LSAPHeader[0].pay.ASI_MFM_Currency__c + ' base_ccy:' + base_ccy);
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
             totalPaymentAmt += sapl.pl.ASI_MFM_Payment_Amount__c ;
             
        }
        
        System.debug('Total Payment Amount: ' + totalPaymentAmt + ' Exchange Rate: ' + exchangeRate);
        
        // CAPEX OPEX Logic: Checking if Plan is required or not
        if (LSAPHeader[0].type == '--None--')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Header type is a required field');//Same old drama 
            ApexPages.addMessage(myMsg);
            return null;
        }
        
       /* if (LSAPHeader[0].pay.ASI_MFM_Plan__c == null && LSAPHeader[0].type == 'CAPEX')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Plan is required if the Payment Type is \'CAPEX\'');//Same old drama 
            ApexPages.addMessage(myMsg);
            return null;
        }
        else if (LSAPHeader[0].pay.ASI_MFM_Plan__c != null && LSAPHeader[0].type == 'OPEX')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Plan must be empty if the Payment Type is \'OPEX\'');//Same old drama 
            ApexPages.addMessage(myMsg);
            return null;
        }*/
        
        //Create PO Header
        create_po.ASI_MFM_PO_Type__c = LSAPHeader[0].type;
        create_po.ASI_MFM_Plan__c = LSAPHeader[0].pay.ASI_MFM_Plan__c;
        create_po.ASI_MFM_Prefix__c = po_prefixes.id;
        create_po.ASI_MFM_Supplier_Name__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c ;
        create_po.ASI_MFM_Currency__c = LSAPHeader[0].pay.ASI_MFM_Currency__c ;
        String recordTypeName = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).ASI_MFM_PO_RT__c;
        Id recordTypeId = ASI_MFM_PO__c.SObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
                create_po.recordTypeID = recordTypeId;
                // create_po.recordTypeID = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).ASI_MFM_PO_RT__c;
                // create_po.recordTypeID = ApexPages.currentPage().getParameters().get('potwrt');
                // create_po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_TW_PO');
        
        if (LSAPHeader[0].isTnE){
            create_po.ASI_MFM_Status__c = 'Manually Processed';
        }
        else {
            create_po.ASI_MFM_Status__c = 'Draft';
        }
        
        create_po.ASI_MFM_Is_Direct_Payment__c = true;
        create_po.ASI_MFM_PO_Start_Date__c = LSAPHeader[0].po.ASI_MFM_FY_Start_Date__c;
        create_po.ASI_MFM_PO_End_Date__c = LSAPHeader[0].po.ASI_MFM_FY_End_Date__c;
        
        
        //Create Payment Header
        create_pa = new ASI_MFM_Payment__c();
        create_pa.ASI_MFM_Plan__c = LSAPHeader[0].pay.ASI_MFM_Plan__c;
        create_pa.ASI_MFM_Payment_Type__c = LSAPHeader[0].type;
        create_pa.ASI_MFM_Prefix__c = payment_prefixes.id;
        create_pa.ASI_MFM_Supplier_Name__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c ;
        create_pa.ASI_MFM_Currency__c = LSAPHeader[0].pay.ASI_MFM_Currency__c ;
        
        if (LSAPHeader[0].isTnE){
            create_pa.ASI_MFM_Invoice_Number__c = [select Name from ASI_MFM_Plan__c where id = :LSAPHeader[0].pay.ASI_MFM_Plan__c].Name + '-'  +Datetime.Now().format('yyyymmdd');
            create_pa.ASI_MFM_Status__c = 'Manually Processed';
        }
        else {
            create_pa.ASI_MFM_Invoice_Number__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c;
            create_pa.ASI_MFM_Status__c = 'Draft';
        }
        // DC - 02/04/2016 - Added logic for saving VAT%
        create_pa.ASI_MFM_VAT_Percentage__c =LSAPHeader[0].pay.ASI_MFM_VAT_Percentage__c;
        create_pa.ASI_MFM_Invoice_Date__c =LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c;
        recordTypeName = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).ASI_MFM_Payment_RT__c;
        recordTypeId = ASI_MFM_Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        // DC - 03/09/2016 - Updated isTnE check for setting CAP T&E record type.
        Id tneRecordTypeId;
        if(!ApexPages.currentPage().getUrl().containsIgnoreCase('OTH')) {
            tneRecordTypeId = ASI_MFM_Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('CAP T&E Payment').getRecordTypeId();
        } else if(ApexPages.currentPage().getUrl().containsIgnoreCase('OTH')) {
            tneRecordTypeId = ASI_MFM_Payment__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('CAP TW T&E Payment').getRecordTypeId();
        }
        create_pa.recordTypeID = LSAPHeader[0].isTnE ? tneRecordTypeId : recordTypeId;
                /*ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).ASI_MFM_Payment_RT__c;*/
                /*ApexPages.currentPage().getParameters().get('patwrt');*/
                /*create_pa.recordTypeID = LSAPHeader[0].isTnE ? Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_T_E_Payment') : Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_TW_Payment');*/
        create_pa.ASI_MFM_Is_Direct_Payment__c = true;
        
        Save_SAPL_POItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        // CAPEX: Do not allow empty payment list
        if (SAPL_Item_Map.size() == 0)
        {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Not allowed to save without any Detail Line.');
            apexpages.addmessage(err);
            return null;
        }
        
        System.Savepoint sp = database.setSavepoint();
        Boolean isRedirect = false;
        try {
            insert create_po;
            system.debug('create_po: ' + create_po.id);
            insert create_pa;
            system.debug('create_pa : ' + create_pa.id);
            system.debug('SAPL_Item_Map Size : ' + SAPL_Item_Map.size());
            Save_SAPL_POItem = new List <ASI_MFM_PO_Line_Item__c> () ;
            Save_SAPL_PAYItem = new List <ASI_MFM_Payment_Line_Item__c> () ; 
            for (integer i : SAPL_Item_Map.keySet())
            {
                SAPLineObj sapl = SAPL_Item_Map.get(i);
                ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c();
                poline.ASI_MFM_PO__c = create_po.id;
				poline.ASI_MFM_Pay_Acc__c = 'P';
                poline.ASI_MFM_AP_Code__c = sapl.pol.ASI_MFM_AP_Code__c ;
                poline.ASI_MFM_A_C_Code__c = sapl.pol.ASI_MFM_A_C_Code__c ;
                poline.ASI_MFM_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c ;
                poline.ASI_MFM_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c ;
                poline.ASI_MFM_G_L_Date__c = sapl.pl.ASI_MFM_Payment_Date__c ;
                poline.ASI_MFM_BU_Code__c = sapl.pol.ASI_MFM_BU_Code__c ;
                recordTypeName = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).PO_LI_RT__c;
                recordTypeId = ASI_MFM_PO_Line_Item__c.SObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
                poline.recordTypeID = recordTypeId;
                                // poline.recordTypeID = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).PO_LI_RT__c;
                                // poline.recordTypeID = ApexPages.currentPage().getParameters().get('poltwrt');
                                // poline.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_TW_PO_Line_Item');
                
                ASI_MFM_Payment_Line_Item__c paline = new ASI_MFM_Payment_Line_Item__c();
                paline.ASI_MFM_Invoice_Number__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c;
                paline.ASI_MFM_Invoice_Date__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c;
                paline.ASI_MFM_Payment__c = create_pa.id;
                paline.ASI_MFM_Payee__c = create_pa.ASI_MFM_Supplier_Name__c ;
                paline.ASI_MFM_AP_Code__c = sapl.pol.ASI_MFM_AP_Code__c ;
                paline.ASI_MFM_A_C_Code__c = sapl.pol.ASI_MFM_A_C_Code__c ;
                paline.ASI_MFM_Payment_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c ;
                paline.ASI_MFM_Payment_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c ;
                paline.ASI_MFM_Payment_Date__c = sapl.pl.ASI_MFM_Payment_Date__c ;
                paline.ASI_MFM_BU__c = sapl.pol.ASI_MFM_BU_Code__c ;
                paline.ASI_MFM_BU_Allocation__c = sapl.pl.ASI_MFM_BU_Allocation__c ;
                paline.ASI_MFM_Employee__c = sapl.pl.ASI_MFM_Employee__c ;
                paline.ASI_MFM_Serial_Number__c = sapl.pl.ASI_MFM_Serial_Number__c ;
                // DC - 02/09/2016 - Reverted logic for saving quantity, UOM and unit price
                /*
                // DC - 02/04/2016 - Added logic for saving quantity, UOM and unit price
                paline.ASI_MFM_Quantity__c = sapl.pl.ASI_MFM_Quantity__c ;
                paline.ASI_MFM_UOM__c = sapl.pl.ASI_MFM_UOM__c ;
                paline.ASI_MFM_Unit_Price__c = sapl.pl.ASI_MFM_Unit_Price__c ;
                */
                recordTypeName = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).ASI_MFM_Payment_LI_RT__c;
                recordTypeId = ASI_MFM_Payment_Line_Item__c.SObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
                                paline.recordtypeid = recordTypeId;
                                // paline.recordtypeid = ASI_MFM_Country_Recordtype_Mapping__c.getInstance(userInstance.ASI_MFM_Country__c).ASI_MFM_Payment_LI_RT__c;
                                // paline.recordtypeid = ApexPages.currentPage().getParameters().get('paltwrt');
                                // paline.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_TW_Payment_Line_Item');
                Save_SAPL_POItem.add(poline);
                Save_SAPL_PAYItem.add(paline);
            }
            
            Set<Id> setBuCodeIds = new Set<Id>();
            Set<Id> setApCodeIds = new Set<Id>();
            
            for(ASI_MFM_PO_Line_Item__c POItemIterator : Save_SAPL_POItem) {
                if(POItemIterator.ASI_MFM_BU_Code__c != NULL) {
                    setBuCodeIds.add(POItemIterator.ASI_MFM_BU_Code__c);
                }
                if(POItemIterator.ASI_MFM_AP_Code__c != NULL) {
                    setApCodeIds.add(POItemIterator.ASI_MFM_AP_Code__c);
                }
            }
            
            List<ASI_MFM_BU__c> lstRelatedBuCodes = [SELECT ASI_MFM_OPEX__c
                                                       FROM ASI_MFM_BU__c
                                                      WHERE Id IN :setBuCodeIds];
            
            List<ASI_MFM_AP_Code__c> lstRelatedApCodes = [SELECT ASI_MFM_OPEX__c
                                                            FROM ASI_MFM_AP_Code__c
                                                           WHERE Id IN :setApCodeIds];
            
            for(ASI_MFM_BU__c buCodeIterator : lstRelatedBuCodes) {
                System.debug('IN FOR LOOP!');
                if(!create_po.ASI_MFM_PO_Type__c.equalsIgnoreCase('OPEX')) {
                    System.debug('IN IF Negative!');
                    if(buCodeIterator.ASI_MFM_OPEX__c == true) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Header type and selected BU do not match.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
                if(create_po.ASI_MFM_PO_Type__c.equalsIgnoreCase('OPEX')) {
                    System.debug('IN IF Positive!');
                    System.debug('------- buCodeIterator ------- : ' + buCodeIterator);
                    if(buCodeIterator.ASI_MFM_OPEX__c == false) {
                        
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Header type and selected BU do not match.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
            }
            
            for(ASI_MFM_AP_Code__c apCodeIterator : lstRelatedApCodes) {
                System.debug('IN FOR LOOP!');
                if(!create_po.ASI_MFM_PO_Type__c.equalsIgnoreCase('OPEX')) {
                    System.debug('IN IF Negative!');
                    if(apCodeIterator.ASI_MFM_OPEX__c == true) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Header type and selected AP Code do not match.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
                if(create_po.ASI_MFM_PO_Type__c.equalsIgnoreCase('OPEX')) {
                    System.debug('IN IF Positive!');
                    System.debug('------- buCodeIterator ------- : ' + apCodeIterator);
                    if(apCodeIterator.ASI_MFM_OPEX__c == false) {
                        
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Header type and selected AP Code do not match.');
                        ApexPages.addMessage(myMsg);
                        return null;
                    }
                }
            }
            
            System.debug('------ Save_SAPL_POItem ------ : ' + Save_SAPL_POItem);
            System.debug('------ Save_SAPL_PAYItem ------ : ' + Save_SAPL_PAYItem);
            insert Save_SAPL_POItem;
            
            for (Integer p = 0;p < Save_SAPL_POItem.size();p++)
            {
                Save_SAPL_PAYItem[p].ASI_MFM_PO_Line_Item__c = Save_SAPL_POItem[p].id;
            }
            System.debug('------ Save_SAPL_PAYItem 1 ------ : ' + Save_SAPL_PAYItem);
            insert Save_SAPL_PAYItem;
            isRedirect = true;
        } catch (DmlException dmle) {
          system.debug('systemTesterror ' + dmle.getDmlMessage(0));
          database.rollback(sp);
           apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getDmlMessage(0));
          apexpages.addmessage(err);
        }/* catch (Exception e) {
          database.rollback(sp);
          apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
          apexpages.addmessage(err);
        } */
        //2nd create PO Line
        
        //3rd create Payment Header
        
        //4th create Payment Line
        PageReference redirect;
        if (isRedirect)
        {
            redirect = new PageReference('/'+create_pa.id); 
        }else{
            redirect = null;
        }
        
        return redirect;
    }
    public PageReference Cancel() 
    {
        PageReference redirect = new PageReference(ApexPages.currentPage().getHeaders().get('Referer')); 
        
        return redirect;
    }
    
    //****** SAPL Line Item - functions - (start) ******
    public void AddNew_SAPL(){
        
        SAPLineObj sapl = new SAPLineObj();
        //sapl.id = string.valueOf(indexSAPL);
        sapl.pl= new ASI_MFM_Payment_Line_Item__c();
        sapl.pol= new ASI_MFM_PO_Line_Item__c();
        
        // Detect prefix of plan
        if(LSAPHeader != null)
        {
            if(LSAPHeader[0].pay.ASI_MFM_Plan__c != null)
            {
                List<ASI_MFM_Plan__c> planList = [SELECT ID, Name, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.name, ASI_MFM_Status__c 
                                                    FROM ASI_MFM_Plan__c WHERE ID = : LSAPHeader[0].pay.ASI_MFM_Plan__c];
                if (planList.size() > 0)
                {
                   ASI_MFM_Plan__c headerplan = planList.get(0);
                   try
                   {
                       //Handle non final plans and output error
                       if(headerplan.ASI_MFM_Status__c != 'Final')
                       {
                            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Cannot input non Final Plan');
                            apexpages.addmessage(err);
                       }
                       if (headerplan.ASI_MFM_Prefix__r.name.startsWith('AP') && LSAPHeader[0].type == 'CAPEX')
                       {
                           /*sapl.pl.ASI_MFM_AP_Code__c = Id.valueOf(defaultAPCode);
                           sapl.pol.ASI_MFM_AP_Code__c = Id.valueOf(defaultAPCode);*/
                       }
                   }
                   catch (exception e)
                   {
                       apexpages.message err = new apexpages.message(apexpages.severity.error, e.getDmlMessage(0));
                       apexpages.addmessage(err);
                   }
                }
            }
        }
        
        SAPL_Item_Map.put(indexSAPL++, sapl);
        system.debug('AddNew_SAPL: ' + SAPL_Item_Map.size()+ 'rowid:' + indexSAPL);
        
    }

    public void Clone_SAPL(){
    
        system.debug('Clone_SAPL: ' + SAPL_Item_Map + 'rowid:' + rowidSAPL + 'indexSAPL:' + indexSAPL);
        SAPLineObj sapl = SAPL_Item_Map.get(rowidSAPL);
        SAPLineObj sapl_Clone = new SAPLineObj();
        //sapl_Clone.id = string.valueOf(indexSAPL);
        sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
        sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
        sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c;
        sapl_Clone.pl.ASI_MFM_Payment_Date__c = sapl.pl.ASI_MFM_Payment_Date__c ;
        sapl_Clone.pl.ASI_MFM_Payment_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c;
        sapl_Clone.pl.ASI_MFM_Invoice_Date__c = sapl.pl.ASI_MFM_Invoice_Date__c;
        sapl_Clone.pl.ASI_MFM_Invoice_Number__c = sapl.pl.ASI_MFM_Invoice_Number__c;
        sapl_Clone.pl.ASI_MFM_BU__c = sapl.pol.ASI_MFM_BU_Code__c ;
        sapl_Clone.pl.ASI_MFM_BU_Allocation__c = sapl.pl.ASI_MFM_BU_Allocation__c ;
        sapl_Clone.pol.ASI_MFM_AP_Code__c= sapl.pol.ASI_MFM_AP_Code__c;
        sapl_Clone.pol.ASI_MFM_BU_Code__c = sapl.pol.ASI_MFM_BU_Code__c ;
        sapl_Clone.pol.ASI_MFM_A_C_Code__c= sapl.pol.ASI_MFM_A_C_Code__c;
        SAPL_Item_Map.put(indexSAPL++, sapl_Clone);
        system.debug('Clone_SAPL: ' + SAPL_Item_Map + 'rowid:' + rowidSAPL + 'indexSAPL:' + indexSAPL);
        
    }

    public void RemoveRow_SAPL(){   
        Del_SAPL_Item.add(SAPL_Item_Map.get(rowidSAPL));
        SAPL_Item_Map.remove(rowidSAPL);
        system.debug('RemoveRow_SAPL: ' + SAPL_Item_Map.size() + 'rowid:' + rowidSAPL);
    }    
    
    //****** SAPL Line Item - functions - (end) ******
    //****** Other Mehtod *******
    public boolean checkPrefixes()
    {
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
            where asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c
            AND asi_mfm_prefix__r.ASI_MFM_Inactive__c = false order by asi_mfm_prefix__r.name desc]) {
            if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('Payment'))
                paypx_list.add(px);
            else if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('PO') && px.asi_mfm_prefix__r.Name.startsWith('PO'))
                popx_list.add(px);
          }      
          if (paypx_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input payments');
                apexpages.addmessage(err); 
                return false;
          } else  if (popx_list.size() == 0) {
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
    @RemoteAction
    public static String[] findCustSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        Map<String, id> MRecType = ASI_MFM_Function.getRecordTypeId('account');
        string recTypeID = MRecType.get(qry);
        String filter;
        filter = ' WHERE recordtypeid = \'' + String.escapeSingleQuotes(recTypeID) + '\' ';
        
        //begin building the dynamic soql query
        
        String soql = 'select Name from ' + obj + filter +' order by Name';
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

    //****** End Other Method ****
}