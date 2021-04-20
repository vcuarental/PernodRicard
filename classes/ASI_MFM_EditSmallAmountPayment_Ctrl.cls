public with sharing class ASI_MFM_EditSmallAmountPayment_Ctrl {
    public List <SAPHeaderObj> LSAPHeader {set;get;}
   
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
    
    public ASI_MFM_EditSmallAmountPayment_Ctrl() {
        init();
    }
    
    //Add By elufa 20151215
    public Id BatchId {set;get;}
    public boolean savesuccess{set;get;}{savesuccess=false;}
    public string Msg {set;get;}
    PUBLIC ASI_MFM_Mass_Upload_Log__c MFMlog {set;get;}{MFMlog= new ASI_MFM_Mass_Upload_Log__c();}
    //public List<string> parts {set;get;}
    public string poid {set;get;}{poid=null;}
    public string paid {set;get;}{paid=null;}
    public string[] statusMsgs {
        get {
            string s = Msg==null? '': Msg;
            if(BatchId!=null) {
                list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
                if(aajs.size()>0) {
                    s = aajs[0].Status;
                    if(aajs[0].Status=='Holding'){
                      s='Waiting....';
                    }
                    
                    if(aajs[0].Status=='Completed' || Test.isRunningTest()) { 
                       ASI_MFM_Mass_Upload_Log__c logshow=[select ASI_MFM_Status__c,ASI_MFM_Configuration__c,ASI_MFM_Error_Message__c from ASI_MFM_Mass_Upload_Log__c where id=:MFMlog.id];
                        
                        if(logshow.ASI_MFM_Error_Message__c!=null || logshow.ASI_MFM_Configuration__c!=null){
                            if(logshow.ASI_MFM_Status__c=='Success'){
                                s='Redirect Page..';
                                List<string> parts=logshow.ASI_MFM_Configuration__c.split('/');
                                poid=parts[0];
                                paid=parts[1];
                                savesuccess=true;
                            }else{
                                s=logshow.ASI_MFM_Error_Message__c;
                            }
                        }else{
                            s = aajs[0].Status;
                        }
                    }
                }
            }
            return s.split('\n');
        }
    }
    //Add By elufa 
    
    public void init(){
    
        if (checkPrefixes())
        {
            Msg='';
        showEdit  = true;
            LSAPHeader = new List<SAPHeaderObj>();
            SAPHeaderObj smp = new SAPHeaderObj();
            smp.id = '1';
            smp.po = new ASI_MFM_PO__c ();
            smp.pay = new ASI_MFM_Payment__c();
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
            showEdit  = false;
        }
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
        
        //Validate Payment amount cannot exceed $1000 which requires PO
        ASI_MFM_Approval_Setting__c setting = ASI_MFM_Approval_Setting__c.getInstance('GF');
        double maxDirectPayAmount = 0;
        
        if (setting != null && setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c != null){
                maxDirectPayAmount = setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c;
        }
        
        //Retrieve Exchange Rate
        double exchangeRate = 0;
        double totalPaymentAmt = 0;
        string country = 'GF';
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
             
            if (sapl.pol.ASI_MFM_Sub_brand_Code__c == null && sapl.pol.ASI_MFM_Sub_brand_Allocation_Type__c == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter either Sub-brand or Sub-brand Allocation Type.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
        //Validation: Ensure Direct Payment Line is entered
        if (SAPL_Item_Map.isEmpty()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Direct Payment Line.');
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        
      
        
        if (totalPaymentAmt != null && exchangeRate != null && maxDirectPayAmount != null){
            //Direct Payment cannot exceed $1000 USD (no limit if AMEX Payment)
            if (totalPaymentAmt * exchangeRate > maxDirectPayAmount && !LSAPHeader[0].pay.ASI_MFM_Is_AMEX_Payment__c){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Payment amount exceeded $' + maxDirectPayAmount + ' . Please submit PO.');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
        //Add By Elufa Support 20151215
        upsert MFMlog;
        BatchId= Database.executeBatch(new ASI_MFM_GF_DirectPaymentProcess(po_prefixes,payment_prefixes,LSAPHeader[0],SAPL_Item_Map,totalPaymentAmt,MFMlog),1);
        Boolean isRedirect = true;
        //Add By Elufa Support 20151215--End
        
        // system.assertEquals(aajs, null);  list<AsyncApexJob> aajs = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE ID =: BatchId ];
        /*
        //1st create PO Header
        create_po = new ASI_MFM_PO__c();
        
        //1st create PO Header
        create_po.ASI_MFM_Plan__c = LSAPHeader[0].po.ASI_MFM_Plan__c;
        create_po.ASI_MFM_Prefix__c = po_prefixes.id;
        create_po.ASI_MFM_Supplier_Name__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c ;
        create_po.ASI_MFM_Currency__c = LSAPHeader[0].pay.ASI_MFM_Currency__c ;
        create_po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO_Read_Only');
        create_po.ASI_MFM_Status__c = 'Final';
        create_po.ASI_MFM_PO_Type__c = 'Normal';
        create_po.ASI_MFM_Is_Direct_Payment__c = true;
        create_po.ASI_MFM_PO_Start_Date__c = System.Today();
        create_po.ASI_MFM_PO_End_Date__c = System.Today();
        
        create_pa = new ASI_MFM_Payment__c();
        create_pa.ASI_MFM_Prefix__c = payment_prefixes.id;
        create_pa.ASI_MFM_Supplier_Name__c = LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c ;
        create_pa.ASI_MFM_Currency__c = LSAPHeader[0].pay.ASI_MFM_Currency__c ;
        create_pa.ASI_MFM_Invoice_Number__c = LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c;
        create_pa.ASI_MFM_Invoice_Date__c =LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c;
        create_pa.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment_Read_Only');
        create_pa.ASI_MFM_Status__c = 'Final';
        //Modify by Alan Wong(Elufa) - Direct Payment Email Notification Error 20150326 
        //create_pa.ASI_MFM_Status__c = 'Draft';
        create_pa.ASI_MFM_Is_Direct_Payment__c = true;
        create_pa.ASI_MFM_G_L_Date__c = System.Today();
        create_pa.ASI_MFM_Is_AMEX_Payment__c = LSAPHeader[0].pay.ASI_MFM_Is_AMEX_Payment__c;
        create_pa.ASI_MFM_Payment_Amount__c = totalPaymentAmt;
        
        Save_SAPL_POItem = new List<ASI_MFM_PO_Line_Item__c>();
        
        System.Savepoint sp = database.setSavepoint();
        Boolean isRedirect = false;
        try {
            insert create_po;
            system.debug('create_po: ' + create_po.id);
            insert create_pa;
            system.debug('create_pa : ' + create_pa .id);
            system.debug('SAPL_Item_Map Size : ' + SAPL_Item_Map.size());
            Save_SAPL_POItem = new List <ASI_MFM_PO_Line_Item__c> () ;
            Save_SAPL_PAYItem = new List <ASI_MFM_Payment_Line_Item__c> () ; 
            for (integer i : SAPL_Item_Map.keySet())
            {
                SAPLineObj sapl = SAPL_Item_Map.get(i);
                ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c();
                poline.ASI_MFM_PO__c = create_po.id;
                poline.ASI_MFM_AP_Code__c = sapl.pol.ASI_MFM_AP_Code__c ;
                poline.ASI_MFM_A_C_Code__c = sapl.pol.ASI_MFM_AP_Code__r.ASI_MFM_A_C_Code__c ;
                poline.ASI_MFM_Customer_Name__c = sapl.pol.ASI_MFM_Customer_Name__c;
                //poline.ASI_MFM_Reference__c = sapl.pol.ASI_MFM_Reference__c;
                poline.ASI_MFM_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c ;
                poline.ASI_MFM_Distributor_Amount__c = sapl.pl.ASI_MFM_Payment_Amount_Distributor__c ;
                poline.ASI_MFM_Sub_brand_Code__c = sapl.pol.ASI_MFM_Sub_brand_Code__c ;
                poline.ASI_MFM_Sub_brand_Allocation_Type__c = sapl.pol.ASI_MFM_Sub_brand_Allocation_Type__c ;
                poline.ASI_MFM_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c ;
                poline.ASI_MFM_G_L_Date__c = System.Today();
                poline.ASI_MFM_Receipt_Date__c = System.Today();
                
                system.debug('PO Line Receipt Date: ' + poline.ASI_MFM_Receipt_Date__c);
                
                ASI_MFM_Payment_Line_Item__c paline = new ASI_MFM_Payment_Line_Item__c();
                paline.ASI_MFM_Payment__c = create_pa.id;
                paline.ASI_MFM_Payee__c = create_pa.ASI_MFM_Supplier_Name__c ;
                paline.ASI_MFM_Payment_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c ;
                paline.ASI_MFM_Payment_Amount_Distributor__c = sapl.pl.ASI_MFM_Payment_Amount_Distributor__c ;
                paline.ASI_MFM_Payment_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c ;
                Save_SAPL_POItem.add(poline);
                Save_SAPL_PAYItem.add(paline);
            }
            insert Save_SAPL_POItem;
            
            for (Integer p = 0;p < Save_SAPL_POItem.size();p++)
            {
                Save_SAPL_PAYItem[p].ASI_MFM_PO_Line_Item__c = Save_SAPL_POItem[p].id;
            }
            insert Save_SAPL_PAYItem;
            //Modify by Alan Wong(Elufa) - Direct Payment Email Notification Error 20150326 
            //create_pa.ASI_MFM_Status__c = 'Final';
            //update create_pa;
            isRedirect = true;
        } catch (DmlException dmle) {
          database.rollback(sp);
           apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
          apexpages.addmessage(err);
        } catch (Exception e) {
          database.rollback(sp);
          apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
          apexpages.addmessage(err);
        } 
        //2nd create PO Line
        
        //3rd create Payment Header
        
        //4th create Payment Line
        
        */
        
        
        
        PageReference redirect;
        if (isRedirect)
        {
            //redirect = new PageReference('/apex/ASI_MFM_GF_EditSmallAmountPaymentP2_Page'); 
           // redirect.getParameters().put('poid', create_po.id);
           // redirect.getParameters().put('paid', create_pa.id);
           redirect = null;
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
        //sapl_Clone.pol.ASI_MFM_Reference__c = sapl.pol.ASI_MFM_Reference__c;
        sapl_Clone.pol.ASI_MFM_Sub_brand_Code__c = sapl.pol.ASI_MFM_Sub_brand_Code__c;
        sapl_Clone.pol.ASI_MFM_Sub_brand_Allocation_Type__c = sapl.pol.ASI_MFM_Sub_brand_Allocation_Type__c;
        sapl_Clone.pl.ASI_MFM_Payment_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c;
        sapl_Clone.pl.ASI_MFM_Payment_Amount_Distributor__c = sapl.pl.ASI_MFM_Payment_Amount_Distributor__c;
        sapl_Clone.pol.ASI_MFM_AP_Code__c= sapl.pol.ASI_MFM_AP_Code__c;
        sapl_Clone.pol.ASI_MFM_Customer_Name__c = sapl.pol.ASI_MFM_Customer_Name__c;
        // Added by 2017-12-28 Linus@introv
        sapl_Clone.pl.ASI_MFM_GF_VAT_Rate__c = sapl.pl.ASI_MFM_GF_VAT_Rate__c;
        sapl_Clone.pol.ASI_MFM_GF_VAT_Rate__c = sapl.pl.ASI_MFM_GF_VAT_Rate__c;
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
          
          //Wilken 20170103 - Add TR Record Type in prefix SOQL, also retrieve active Prefix only
            for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name, asi_mfm_prefix__r.ASI_MFM_TR_Rec_Type__c, asi_mfm_prefix__r.asi_mfm_module__c  from asi_mfm_role_prefix_relationship__c
                where asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c  and ASI_MFM_Prefix__r.ASI_MFM_Inactive__c = false order by asi_mfm_prefix__r.name]) {
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
        
        //Wilken 20170103 - Add TR Record Type as filter for Customer SOQL
        String TRRecordType;
        if (qry == 'ASI_GF_Customer'){
            user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
          
            for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__r.ASI_MFM_TR_Rec_Type__c, asi_mfm_prefix__r.asi_mfm_module__c  from asi_mfm_role_prefix_relationship__c
                where asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c  and ASI_MFM_Prefix__r.ASI_MFM_Inactive__c = false order by asi_mfm_prefix__r.name]) {
                
                if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('PO')){
                    TRRecordType = px.asi_mfm_prefix__r.ASI_MFM_TR_Rec_Type__c;
                }
            }
            
            filter += ' and ASI_HK_CRM_Type__c = \'' + TRRecordType + '\' ';
        }    
                
        //begin building the dynamic soql query
        
        String soql = 'select Name from ' + obj + filter +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('findCustSObjects qry: ' + qry + ' soql:' + soql);
        
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