/*********************************************************************************
 * Name: ASI_MFM_CAP_TH_EditSmallAmountPay_Ctrl
 * Description: Controller class for Edit Small Amount Pay Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/05/2016       Laputa:Hugo             Created
 *              
*/
public with sharing class ASI_MFM_CAP_TH_EditSmallAmountPay_Ctrl {

    public final static String TH_AC_CODE_DEFAULT_NUMBER = '2281';

    public List <SAPHeaderObj> LSAPHeader {set;get;}
    // Option Items for Type of Payment: CAPEX or OPEX
    private final List<String> typeOptions = new String[]{'--None--','Brand Owner Invoice', 'Structured Cost Invoice'};
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

    public List<SelectOption> acSelectionList {get;set;}{acSelectionList = new List<SelectOption>();}
    
    private ASI_MFM_A_C_Code__c defaultACCode;

    private List<ASI_MFM_A_C_Code__c> acList;

    public ASI_MFM_CAP_TH_EditSmallAmountPay_Ctrl() {
        init();
    }
    
    public void init(){

        if (checkPrefixes())
        {
            showEdit  = true;
            LSAPHeader = new List<SAPHeaderObj>();
            SAPHeaderObj smp = new SAPHeaderObj();
            smp.id = '1';
            smp.po = new ASI_MFM_PO__c ();
            smp.pay = new ASI_MFM_Payment__c();
            smp.pay.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_TH_Payment');
            smp.pay.ASI_MFM_Currency__c = 'THB';
            LSAPHeader.add(smp);
            
            
            Del_SAPL_Item = new List<SAPLineObj>();
            SAPL_Item_Map = new Map<Integer, SAPLineObj>();
            indexSAPL = 0;
           
        }else
        {
            showEdit  = false;
        }

        acList = [SELECT ID, Name FROM ASI_MFM_A_C_Code__c WHERE recordtype.developername = 'ASI_MFM_CAP_TH_A_C_Code'];
        
        for(ASI_MFM_A_C_Code__c ac : acList) {

            if(ac.Name.startsWith(TH_AC_CODE_DEFAULT_NUMBER)) {

                 acSelectionList.add(new SelectOption(ac.Id, ac.Name));

            }

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
    
    public PageReference SaveRecord() 
    {
    
        //1st create PO Header
        create_po = new ASI_MFM_PO__c();
        
        //Validate Payment amount cannot exceed $1000 which requires PO
        ASI_MFM_Approval_Setting__c setting = ASI_MFM_Approval_Setting__c.getInstance('TH');
        double maxDirectPayAmount = 0;
        
        if (setting != null && setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c != null){
                maxDirectPayAmount = setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c;
        }
        
        //Retrieve Exchange Rate
        double exchangeRate = 0;
        double totalPaymentAmt = 0;
        string country = 'TH';
        string base_ccy = 'THB';
        string counter_ccy = LSAPHeader[0].pay.ASI_MFM_Currency__c;
        date last_effective_date = LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c;

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
            if(sapl.pl.ASI_MFM_Payment_Amount__c != null) {
                totalPaymentAmt += sapl.pl.ASI_MFM_Payment_Amount__c ;
            }
             
        }
        
        System.debug('Total Payment Amount: ' + totalPaymentAmt + ' Exchange Rate: ' + exchangeRate);
        
        // CAPEX OPEX Logic: Checking if Plan is required or not
        if (LSAPHeader[0].type == '--None--')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Header type is a required field');//Same old drama 
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        //1st create PO Header
        create_po.ASI_MFM_PO_Type__c = LSAPHeader[0].type;
        create_po.ASI_MFM_Plan__c = LSAPHeader[0].pay.ASI_MFM_Plan__c;
        create_po.ASI_MFM_Prefix__c = po_prefixes.id;
        create_po.ASI_MFM_Supplier_Name__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c ;
        create_po.ASI_MFM_Currency__c = LSAPHeader[0].pay.ASI_MFM_Currency__c ;
        create_po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_TH_PO');
        create_po.ASI_MFM_Status__c = 'Draft';
        create_po.ASI_MFM_Is_Direct_Payment__c = true;
        create_po.ASI_MFM_PO_Start_Date__c = LSAPHeader[0].po.ASI_MFM_FY_Start_Date__c;
        create_po.ASI_MFM_PO_End_Date__c = LSAPHeader[0].po.ASI_MFM_FY_End_Date__c;
        
        create_pa = new ASI_MFM_Payment__c();
        create_pa = LSAPHeader[0].pay.clone(false, true, false, false);
        create_pa.ASI_MFM_Plan__c = LSAPHeader[0].pay.ASI_MFM_Plan__c;
        create_pa.ASI_MFM_Payment_Type__c = LSAPHeader[0].type;
        create_pa.ASI_MFM_Prefix__c = payment_prefixes.id;
        create_pa.ASI_MFM_Supplier_Name__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c ;
        create_pa.ASI_MFM_Currency__c = LSAPHeader[0].pay.ASI_MFM_Currency__c ;
        create_pa.ASI_MFM_Invoice_Number__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c;
        create_pa.ASI_MFM_Invoice_Date__c =LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c;
        create_pa.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_TH_Payment');
        create_pa.ASI_MFM_Status__c = 'Draft';
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
            boolean isError = false;
            for (integer i : SAPL_Item_Map.keySet())
            {
                SAPLineObj sapl = SAPL_Item_Map.get(i);
                ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c();
                poline.ASI_MFM_PO__c = create_po.id;
                poline.ASI_MFM_A_C_Code__c = sapl.pol.ASI_MFM_A_C_Code__c ;
                //poline.ASI_MFM_A_C_Code__c = sapl.pol.ASI_MFM_A_C_Code__c ;
                poline.ASI_MFM_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c ;
                poline.ASI_MFM_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c ;
                poline.ASI_MFM_G_L_Date__c = sapl.pl.ASI_MFM_Payment_Date__c ;
                poline.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_TH_PO_Line_Item');
                
                ASI_MFM_Payment_Line_Item__c paline = new ASI_MFM_Payment_Line_Item__c();
                paline = sapl.pl;
                paline.ASI_MFM_Invoice_Number__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c;
                paline.ASI_MFM_Invoice_Date__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c;
                paline.ASI_MFM_Payment__c = create_pa.id;
                paline.ASI_MFM_A_C_Code__c = (ID)(sapl.ACSelected) ;
                paline.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_TH_Payment_Line_Item');
                
                Save_SAPL_POItem.add(poline);
                Save_SAPL_PAYItem.add(paline);
            }
            
            if(isError) {
                Save_SAPL_POItem.clear();
                Save_SAPL_PAYItem.clear();
                return null;
            }
            
            insert Save_SAPL_POItem;
            
            for (Integer p = 0;p < Save_SAPL_POItem.size();p++)
            {
                Save_SAPL_PAYItem[p].ASI_MFM_PO_Line_Item__c = Save_SAPL_POItem[p].id;
            }
            insert Save_SAPL_PAYItem;
            isRedirect = true;
        } catch (DmlException dmle) {
          system.debug('systemTesterror ' + dmle.getDmlMessage(0));
          database.rollback(sp);
           apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getDmlMessage(0));
          apexpages.addmessage(err);
        }
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
        sapl.ACSelectOption = this.acSelectionList;
        sapl.ACSelected = defaultACCode.Id;
        
        SAPL_Item_Map.put(indexSAPL++, sapl);
        system.debug('AddNew_SAPL: ' + SAPL_Item_Map.size()+ 'rowid:' + indexSAPL);
        
    }

    public void Clone_SAPL(){
    
        system.debug('Clone_SAPL: ' + SAPL_Item_Map + 'rowid:' + rowidSAPL + 'indexSAPL:' + indexSAPL);
        SAPLineObj sapl = SAPL_Item_Map.get(rowidSAPL);
        SAPLineObj sapl_Clone = new SAPLineObj();

        sapl_Clone.ACSelectOption = this.acSelectionList;
        sapl_Clone.ACSelected = sapl.ACSelected;

        sapl_Clone.pl = sapl.pl.clone(false, true, false, false);
        sapl_Clone.pol= sapl.pol.clone(false, true, false, false);
        SAPL_Item_Map.put(indexSAPL++, sapl_Clone);
        
    }

    public void RemoveRow_SAPL(){   
        Del_SAPL_Item.add(SAPL_Item_Map.get(rowidSAPL));
        SAPL_Item_Map.remove(rowidSAPL);
        system.debug('RemoveRow_SAPL: ' + SAPL_Item_Map.size() + 'rowid:' + rowidSAPL);
    }    
    
    public void updateACPick() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String acChoice = params.get('ACChoice');
        Integer cpiKey = Integer.valueof(params.get('cpiKey'));

        if(SAPL_Item_Map.containsKey(cpiKey)){
            SAPLineObj sapl_update = SAPL_Item_Map.get(cpiKey);
            sapl_update.ACSelected = acChoice;
            sapl_update.updateAC();
        }
    }

    public void updateDefaultACCode() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String supplierName = params.get('SupplierName');
        
        List<Account> supplierList = [SELECT ASI_MFM_Customer_Supplier_Number__c FROM Account WHERE Name = :supplierName];
        
        if(supplierList.size() > 0) {

            Account supplier = supplierList.get(0);

            for(ASI_MFM_A_C_Code__c ac : acList) {

                if(ac.Name.startsWith(TH_AC_CODE_DEFAULT_NUMBER + '.' + supplier.ASI_MFM_Customer_Supplier_Number__c)) {
                    defaultACCode = ac;
                }

            }

            for(Integer key : SAPL_Item_Map.keySet()) {

                SAPLineObj sapl = SAPL_Item_Map.get(key);
                sapl.pl.ASI_MFM_A_C_Code__c = defaultACCode.Id;
                sapl.pol.ASI_MFM_A_C_Code__c = defaultACCode.Id;

            }
        }
        
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
            AND asi_mfm_prefix__r.ASI_MFM_Inactive__c = false order by asi_mfm_prefix__r.name]) {
            if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('Payment'))
                paypx_list.add(px);
            else if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('PO'))
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
        public List<SelectOption> ACSelectOption {get;set;}
        public String ACSelected {get;set;}

        public void updateAC() {
            this.pl.ASI_MFM_A_C_Code__c = (ID)ACSelected;
        }
        
    }
    //******End Wapper Class***********
}