public without sharing class ASI_MFM_KR_DirectPaymentCtler {
    //************************ Definition  ******************* 
    public asi_mfm_prefix__c payment_prefixes;
    public asi_mfm_prefix__c po_prefixes;
    public HeaderObj Header {set;get;}
    public map<integer, LineObj> ItemMap {set;get;}
    public Integer ItemMapIndex {set;get;}
    public boolean ShowReport {set;get;}    
    public String CurrencyName {get;set;} 
    public double exchangeRate {get;set;} {exchangeRate= 1;} 
    public String Company {get;set;}{Company='';}
    public String reportURL {set;get;}{reportURL='';}
    
    //For Checking Use
    public boolean SaveSuccess {get;set;}
    public boolean UpsertPermission {get;set;}
    public String Msg {get;set;} {Msg='';}
    public boolean IsProcess {get;set;}{IsProcess=true;}
    public boolean PostError {get;set;}{PostError=false;}
    
    //For over-payment calculation
    public Decimal paylAmount_current {set; get;}
    public Decimal paylAmount_last {set; get;}
    public Boolean isRedirect {set; get;}
    public String SQLstatement {get;set;} {SQLstatement='';}
    
    //Save Record
    public ASI_MFM_PO__c create_po {set; get;}
    public ASI_MFM_Payment__c create_pa {set; get;}
    public List <ASI_MFM_PO_Line_Item__c> Save_POItem {set;get;}  
    public List <ASI_MFM_Payment_Line_Item__c> Save_PAYItem {set;get;}
    public Map<id, ASI_MFM_AP_AC_Code_Map__c> APACMap {set;get;}{APACMap=new Map<id, ASI_MFM_AP_AC_Code_Map__c>();}
    public Map<id, ASI_MFM_AP_Code__c> AP_Map {set;get;}{AP_Map=new Map<id, ASI_MFM_AP_Code__c>();}
    
    String branchCode = '';
    double totalPaymentAmt = 0;
    public Map<String,ASI_TnE_Branch_Channel__c> branchMap = new Map<String,ASI_TnE_Branch_Channel__c>();
    
    // ********************  Initiate ******************* 
    public ASI_MFM_KR_DirectPaymentCtler() {
        init();
        
        
    }
    
    public void init(){
        if (checkPrefixes())
        {
            SQLstatement=ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_KR_findCustomers','Initialization','KR');
            ShowReport=false;
            //Header
            Header= new HeaderObj();
            Header.id = '1';
            Header.po = new ASI_MFM_PO__c (recordTypeId=Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            Header.pay = new ASI_MFM_Payment__c();
            //Line
            ItemMapIndex=0;
            ItemMap = new Map<Integer, LineObj>();
            UpsertPermission=true;
            paylAmount_last = 0;
            isRedirect = false;
            SaveSuccess=false;
            CurrencyName='KRW';
            
            //----- sub ledger ----- 2015-12-21
            branchCode = [SELECT ASI_KOR_User_Branch_Code__c FROM User WHERE Id =: userInfo.getUserId()].ASI_KOR_User_Branch_Code__c;
            List<ASI_TnE_Branch_Channel__c> branchList 
                = new List<ASI_TnE_Branch_Channel__c>([SELECT Id, Name
                                                       FROM ASI_TnE_Branch_Channel__c
                                                       WHERE ASI_TnE_Branch_Default__c = TRUE
                                                       AND recordType.developerName = 'ASI_TnE_KR_Branch_Channel']);
            for(ASI_TnE_Branch_Channel__c bc: branchList)
            {
                branchMap.put(bc.Name.subString(1,4),bc);
            }//end for
            
            
            APACMap = new Map<id, ASI_MFM_AP_AC_Code_Map__c>();
            for(ASI_MFM_AP_AC_Code_Map__c apac:[select id,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.id,ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c from ASI_MFM_AP_AC_Code_Map__c where ASI_MFM_AP_Code__r.RecordType.DeveloperName='ASI_KR_AP_Code']){
                if(!APACMap.containsKey(apac.ASI_MFM_AP_Code__r.id)){
                    APACMap.put(apac.ASI_MFM_AP_Code__r.id, apac);
                }
            }// APMap
            AP_Map = new Map<id, ASI_MFM_AP_Code__c>();
            for(ASI_MFM_AP_Code__c ap:[select id,name,ASI_MFM_Beneficiary_WS_Venue__c from ASI_MFM_AP_Code__c where RecordType.DeveloperName='ASI_KR_AP_Code']){
                if(!AP_Map.containsKey(ap.id)){
                    AP_Map.put(ap.id,ap);
                }
            }
            
        }else
        {
            ItemMap = new Map<Integer, LineObj>();
            UpsertPermission=false;
        }
    }
    
    
    
    // Prefix Checking
    public boolean checkPrefixes()
    {
        user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
        if (u.userRole.developerName == null) {
            Msg='The role of the user is not defined yet.';
            return false;
        }
        else if (u.asi_mfm_country__c == null) {
            Msg='The country of the user is not defined yet.';
            return false;
        }/*
        else {
            list<asi_mfm_role_prefix_relationship__c> paypx_list = new list<asi_mfm_role_prefix_relationship__c>();
            list<asi_mfm_role_prefix_relationship__c> popx_list = new list<asi_mfm_role_prefix_relationship__c>();
            for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name, asi_mfm_prefix__r.asi_mfm_module__c  from asi_mfm_role_prefix_relationship__c where asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c order by asi_mfm_prefix__r.name]) {
                if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('Payment'))
                    paypx_list.add(px);
                else if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('PO'))
                    popx_list.add(px);
            }      
            if (paypx_list.size() == 0) {
                Msg='The user is not entitled to input payments.';
                return false;
            } 
            if (popx_list.size() == 0) {
                Msg='The user is not entitled to input POs.';
                return false; 
            }
            
        } */
        return true;
    }
    
    
    public void CopyFromPlan(){
        
        id defaultTaxCodeid=null;
        ASI_MFM_Tax_Code__c defaultTax = new ASI_MFM_Tax_Code__c();
        IsProcess=true;
        ApexPages.getMessages().clear();
        ItemMap.clear();
        
        string CompanyCode='';
        
        if(Company=='PRK'){
            CompanyCode='222';
        }else{
            CompanyCode='286';
        }
        
        
        ASI_MFM_Plan__c plan=[select id,name,ASI_MFM_Status__c,ASI_MFM_Project_Code__c,ASI_MFM_Budget_Type__c from ASI_MFM_Plan__c where id=:Header.po.ASI_MFM_Plan__c];
        if(plan.ASI_MFM_Status__c!='Approved'){
            IsProcess=false;
            Msg='<a href="/'+plan.id+'">'+plan.name+'</a> Status:'+plan.ASI_MFM_Status__c+'    .Please select Approved Plan.';
        }
        
        if(plan.ASI_MFM_Budget_Type__c=='DISC'){
            IsProcess=false;
            Msg='Budget Type is \' DISC \'.  No need create Direct Payment. ';
        }
        if(Header.pay.ASI_MFM_Supplier_Name__c==null){
            IsProcess=false;
            Msg='Please select Supplier Again. Cannot Find Supplier. ';
            
        }
        
        if(exchangeRate==0.0){
            IsProcess=false;
            Msg='Please Exchange Rate. ';
        }
        
        
        if(IsProcess){
            Header.po.ASI_MFM_Project_Code__c=plan.ASI_MFM_Project_Code__c;
            
            List<ASI_MFM_Plan_Line_Item__c> listPlanLineItem = [SELECT id, ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c,ASI_MFM_Company_Code__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_KR_subLedger__r.Name,ASI_MFM_KR_subLedger__c,ASI_MFM_AP_Code__r.name, ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_Venue_Where__c,ASI_MFM_Venue_Where__r.name,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_AccountsAdditionalField__r.name,ASI_MFM_AP_Code__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_A_C_Code__r.Name, ASI_MFM_Customer_Name__c, ASI_MFM_Customer_Name__r.Name, ASI_MFM_A_C_Code__c, ASI_MFM_List_Item_Description__c, ASI_MFM_Quantity__c, ASI_MFM_Unit_Cost__c, ASI_MFM_Total_Cost__c
                                                                FROM ASI_MFM_Plan_Line_Item__c 
                                                                WHERE ASI_MFM_Plan__c=:Header.po.ASI_MFM_Plan__c AND 
                                                                RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item') AND
                                                                ASI_MFM_AP_Code__r.ASI_MFM_PRPO_Needed__c=false and ASI_MFM_Company_Code__c=:CompanyCode
                                                                ORDER BY id];
            ItemMapIndex = 0;
            
            if(Header.pay.ASI_MFM_Supplier_Name__c!=null){
                Account acc= [select id , ASI_HK_CRM_Payment_Term_Code__c from Account where id=:Header.pay.ASI_MFM_Supplier_Name__c];
                ASI_MFM_Tax_Code__c[] tx;
                if(acc.ASI_HK_CRM_Payment_Term_Code__c!=null){
                    tx=[select id,name from ASI_MFM_Tax_Code__c where name =:[select ASI_MFM_Site_Code__c from Account where id=:Header.pay.ASI_MFM_Supplier_Name__c ].ASI_MFM_Site_Code__c and ASI_MFM_Tax_Expl_Code__c=:acc.ASI_HK_CRM_Payment_Term_Code__c limit 1];
                }else{
                    tx=[select id,name from ASI_MFM_Tax_Code__c where name =:[select ASI_MFM_Site_Code__c from Account where id=:Header.pay.ASI_MFM_Supplier_Name__c].ASI_MFM_Site_Code__c limit 1];
                    
                }
                if(tx.size()>0){
                    defaultTax=tx[0];
                }
                
            }
            
            for(ASI_MFM_Prefix__c px_List: [select id,name,ASI_MFM_Module__c from ASI_MFM_Prefix__c where (ASI_MFM_Module__c='Direct PO' OR ASI_MFM_Module__c='Payment') and ASI_MFM_country_name__c='KR' and ASI_MFM_Inactive__c=false AND NAME=: Company]){
                if(px_List.ASI_MFM_Module__c=='Direct PO'){
                    po_prefixes=px_List;
                }
                if(px_List.ASI_MFM_Module__c=='Payment'){
                    payment_prefixes=px_List;
                }
            }        
            //ASI_MFM_Project_Code__c
            
            
            if(listPlanLineItem.size()>0){
                if(plan.name!=null){ 
                    user u = [select id,ASI_OBIEE_Domain__c from user where id = : System.UserInfo.getUserId()];
                    if(u.ASI_OBIEE_Domain__c!=null){
                        reportURL='https://obiee.pernod-ricard-asia.com:'+u.ASI_OBIEE_Domain__c+'/analytics/saw.dll?PortalGo&Action=extract&path=%2Fshared%2FPRK%2FMFM%2FReport%2FBudget%20Checking%20for%20New%20Promotion%2FBudget%20Checking%20for%20New%20Promotion&P0=1&P1=eq&P2=%22Plan Dim%22.%22Plan No%22&P3=%22'+plan.name+'%22';
                    }else{
                        reportURL='https://obiee.pernod-ricard-asia.com:8622/analytics/saw.dll?PortalGo&Action=extract&path=%2Fshared%2FPRK%2FMFM%2FReport%2FBudget%20Checking%20for%20New%20Promotion%2FBudget%20Checking%20for%20New%20Promotion&P0=1&P1=eq&P2=%22Plan Dim%22.%22Plan No%22&P3=%22'+plan.name+'%22'; 
                    }
                }
                for (ASI_MFM_Plan_Line_Item__c pl : listPlanLineItem){
                    LineObj temp = new LineObj();
                    temp.PlanLine=pl;
                    temp.boolSelected = FALSE;
                    temp.pl = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_Payment_Amount__c = (pl.ASI_MFM_Total_Cost__c/exchangeRate).setScale(2, roundingMode.half_up),ASI_MFM_Invoice_Number__c =Header.pay.ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c =Header.pay.ASI_MFM_Invoice_Date__c, ASI_MFM_Payee__c=Header.pay.ASI_MFM_Supplier_Name__c);
                    temp.pol= new ASI_MFM_PO_Line_Item__c(ASI_MFM_Sub_brand_Code__c = pl.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Plan_Line_Item__c=pl.id);
                    temp.tx=defaultTax;
                    if(pl.ASI_MFM_KR_subLedger__c != null){
                        temp.subLedgerId = pl.ASI_MFM_KR_subLedger__c;
                        temp.subLedger = pl.ASI_MFM_KR_subLedger__r.Name;
                    }else if(pl.ASI_MFM_KR_subLedger__c == null &&(branchCode != '' || branchCode != null)){
                        temp.subLedgerId = branchMap.get(branchCode).Id;
                        temp.subLedger = branchMap.get(branchCode).Name;
                    }//end else 
                    temp.APCode=pl.ASI_MFM_AP_Code__r.name;
                    temp.NeedCustomer = pl.ASI_MFM_AP_Code__r.ASI_MFM_Beneficiary_WS_Venue__c;
                    temp.APCodeId=pl.ASI_MFM_AP_Code__c;  
                    temp.APType=pl.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c;
                    temp.APCategory=pl.ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c; 
                    temp.VenueWhere= pl.ASI_MFM_Venue_Where__r.name;
                    temp.VenueWhereId=pl.ASI_MFM_Venue_Where__c;
                    temp.Customer=pl.ASI_MFM_AccountsAdditionalField__r.name;
                    temp.CustomerId=pl.ASI_MFM_AccountsAdditionalField__c;
                    temp.boolSelected=true;
                    ItemMap.put(ItemMapIndex++, temp);
                }
                ShowReport=true;
            }else{
                IsProcess=false;
                Msg= 'No Line For Direct Payment.';
            }
            
        }  
        
    }
    
    // remove boolSelected is false
    public void Refresh(){  
        
        if(ItemMap.size() >0 && ItemMap != NULL){
            for (integer i : ItemMap.keySet()){
                
                if(!ItemMap.get(i).boolSelected){
                    ItemMap.remove(i); 
                }     
            }
        }
    }
    
    //Fuction:  Remove Line
    public void removeLine()
    {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_RLine_ID');
        //system.assertEquals(param_Id, null);
        ItemMap.remove(integer.valueOf(param_Id));
        ItemMapIndex--;
        
    }
    
    //Fuction:  Clone Line
    public void cloneLine(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_clone_ID');
        LineObj OriLine = ItemMap.get(integer.valueOf(param_Id));
        LineObj CloneLine = new LineObj();
        ItemMap.put(ItemMapIndex++, OriLine);
    }
    
    
    //Fuction: Save
    public void SaveRecord() 
    {
        //End: Get Exchange Rate
        IsProcess=ValdationChecking(ItemMap);
        
        if(IsProcess){
            onCommitted(exchangeRate);
        }
    }
    
    public Boolean ValdationChecking(map<integer, LineObj> allLineItemMap){
        Msg='';
        boolean ReturnResult=true;
        if (ItemMap.isEmpty()){
            ReturnResult=false;
            Msg+='Please enter Direct Payment Line.';
        }
        
        if(Header.pay.ASI_MFM_KR_TotalPayAmtIncludeVAT__c==null || Header.pay.ASI_MFM_KR_TotalPayAmtIncludeVAT__c==0){
            msg += 'Please Input Total Payment Amount (Including VAT). </br>';
            ReturnResult = false;  
        }
        
        for (integer i : allLineItemMap.keySet()){
            
            if(allLineItemMap.get(i).boolSelected){
                integer idx=i+1;
                LineObj LObjt = allLineItemMap.get(i);
                if(LObjt.pl.ASI_MFM_Payment_Amount__c != NULL){
                    totalPaymentAmt += LObjt.pl.ASI_MFM_Payment_Amount__c ;
                }
                
                if(String.isEmpty(LObjt.pl.ASI_MFM_AP_Remark__c)){
                    msg += 'Line ' + idx + ' : Please Input AP Remark' + '</br>';
                    ReturnResult = false;  
                }
                
                //check sub ledger
                if(String.isEmpty(LObjt.subLedger) || String.isEmpty(LObjt.subLedgerId))
                {
                    msg += 'Line ' + idx + ' : Please select Sub Ledger' + '</br>';
                    ReturnResult = false;  
                }//end if
                else
                {
                    if(!String.isEmpty(LObjt.subLedgerId))
                    {
                        try
                        {//Need to map back the ID to ASI_MFM_KR_subLedger__c
                            Id subLedgerId = Id.valueOf(allLineItemMap.get(i).subLedgerId);
                            allLineItemMap.get(i).pl.ASI_MFM_KR_subLedger__c = subLedgerId;
                        }//end try
                        catch(exception e)
                        {
                            msg += 'Line ' + idx + ' : Please select Sub Ledger' + '</br>';
                            ReturnResult = false;  
                        }//end catch
                    }//end if
                }//end else
                
                
                
                //check AP code
                if(String.isEmpty(LObjt.APCode) || String.isEmpty(LObjt.APCodeId))
                {
                    msg += 'Line ' + idx + ' : Please select AP Code' + '</br>';
                    ReturnResult = false;  
                }//end if
                else
                {
                    if(!String.isEmpty(LObjt.APCodeId))
                    {
                        try
                        {//Need to map back the ID to ASI_MFM_AP_Code__c
                            Id APId = Id.valueOf(LObjt.APCodeId);
                            allLineItemMap.get(i).pl.ASI_MFM_AP_Code__c = APId;
                            string apidstring=LObjt.APCodeId;
                            if(APACMap.containsKey(apidstring)){
                                allLineItemMap.get(i).pol.ASI_MFM_A_C_Code__c=APACMap.get(apidstring).ASI_MFM_A_C_Code__c;
                            }
                            
                            if(AP_Map.containsKey(string.valueOf(LObjt.APCodeId))){
                                if(AP_Map.get(string.valueOf(LObjt.APCodeId)).ASI_MFM_Beneficiary_WS_Venue__c){
                                    if(String.isEmpty(LObjt.Customer)){
                                        msg += 'Line ' + idx + ' : Please select Customer' + '</br>';
                                        ReturnResult = false;  
                                    }
                                    if(String.isEmpty(LObjt.VenueWhere)){
                                        msg += 'Line ' + idx + ' : Please select Venue' + '</br>';
                                        ReturnResult = false;  
                                    }
                                }
                            }
                        }//end try
                        catch(exception e)
                        {
                            msg += 'Line ' + idx+' :Please select AP Code' +e+'</br>';
                            ReturnResult = false;  
                        }//end catch
                        
                        
                    }//end if
                }//end else
                
                
                
                //check customer
                if(!String.isEmpty(LObjt.CustomerId)){
                    try
                    { //Need to map back the ID to Customer
                        Id CusId = Id.valueOf(LObjt.CustomerId);
                        allLineItemMap.get(i).pl.ASI_MFM_Beneficiary_Customer__c = CusId;
                    }//end try
                    catch(exception e)
                    {
                        msg += 'Line ' + idx + ' : Please select Customer' + '</br>';
                        ReturnResult = false;  
                    }//end catch
                }
                
                if(String.isEmpty(LObjt.Customer)){
                    allLineItemMap.get(i).pl.ASI_MFM_Beneficiary_Customer__c = null;
                }
                
                //check customer
                if(!String.isEmpty(LObjt.VenueWhereId)){
                    try
                    {//Need to map back the ID to Customer
                        Id CusId = Id.valueOf(LObjt.VenueWhereId);
                        allLineItemMap.get(i).pl.ASI_MFM_Where_Customer__c = CusId;
                    }//end try
                    catch(exception e)
                    {
                        msg += 'Line ' + idx + ' : Please select Venue Where' + '</br>';
                        ReturnResult = false;  
                    }//end catch
                }
                if(String.isEmpty(LObjt.VenueWhere)){
                    allLineItemMap.get(i).pl.ASI_MFM_Where_Customer__c = null;
                }
                //end if
                
                
                
            }
            
        }
        return ReturnResult;
    }
    
    public void onCommitted( double exchangeRate ){
        isRedirect = false;
        string InvoiceNumber='';
        Msg='';
        System.Savepoint sp = database.setSavepoint();
        
        //1st create PO Header
        create_po = new ASI_MFM_PO__c();
        create_po.ASI_MFM_Currency__c = CurrencyName;
        create_po.ASI_MFM_Project_Code__c=Header.po.ASI_MFM_Project_Code__c;
        create_po.ASI_MFM_Exchange_Rate__c=exchangeRate;
        create_po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO');
        create_po.ASI_MFM_Plan__c = Header.po.ASI_MFM_Plan__c;
        create_po.ASI_MFM_Prefix__c = po_prefixes.id;
        create_po.ASI_MFM_Supplier_Name__c = Header.pay.ASI_MFM_Supplier_Name__c ;
        create_po.ASI_MFM_Status__c = 'Draft';
        create_po.ASI_MFM_Is_Direct_Payment__c = true;
        create_po.ASI_MFM_PO_Start_Date__c = System.Today();
        create_po.ASI_MFM_PO_End_Date__c = System.Today();
        
        try {    
            insert create_po; // insert po
            isRedirect = true;
        } catch (DmlException dmle) {          
            apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
            apexpages.addmessage(err); 
            isRedirect = false;
            IsProcess=false;
            Msg+=err;
            database.rollback(sp); //system.assertEquals(null, err);
        } catch (Exception e) {
            apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());//apexpages.addmessage(err);
            isRedirect = false;
            IsProcess=false;
            Msg+=err;
            database.rollback(sp);
        }
        
        //2nd create Payment Header
        create_pa = new ASI_MFM_Payment__c(ASI_MFM_Exchange_Rate__c=exchangeRate,
                                           ASI_MFM_Currency__c =CurrencyName,
                                           recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                           ASI_MFM_Prefix__c = payment_prefixes.id,
                                           ASI_MFM_Plan__c = Header.po.ASI_MFM_Plan__c,
                                           ASI_MFM_Status__c = 'Draft',
                                           ASI_MFM_Is_Direct_Payment__c = true,
                                           ASI_MFM_G_L_Date__c = System.Today(),
                                           ASI_MFM_Payment_Amount__c = totalPaymentAmt,ASI_MFM_PO__c=create_po.id,
                                           ASI_MFM_Supplier_Name__c = Header.pay.ASI_MFM_Supplier_Name__c,
                                           ASI_MFM_Invoice_Number__c = Header.pay.ASI_MFM_Invoice_Number__c,
                                           ASI_MFM_Invoice_Date__c =Header.pay.ASI_MFM_Invoice_Date__c
                                           ,ASI_MFM_KR_TotalPayAmtIncludeVAT__c = Header.pay.ASI_MFM_KR_TotalPayAmtIncludeVAT__c //20170207, added by Leo
                                          );
        
        if(isRedirect == true){
            try {    
                insert create_pa; // insert payment
                isRedirect = true;
                if(Header.pay.ASI_MFM_Invoice_Number__c==null){
                    InvoiceNumber=[select ASI_MFM_Invoice_Number__c from ASI_MFM_Payment__c where id=:create_pa.Id].ASI_MFM_Invoice_Number__c;
                }
            } catch (DmlException dmle) {
                database.rollback(sp);
                apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                apexpages.addmessage(err); 
                isRedirect = false;
                IsProcess=false;
                Msg+=err;
                //system.assertEquals(null, err);
            } catch (Exception e) {
                database.rollback(sp);
                apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                apexpages.addmessage(err);
                isRedirect = false;
                IsProcess=false;
                Msg+=err;//system.assertEquals(null, err);
            }
        }
        
        Save_POItem = new List <ASI_MFM_PO_Line_Item__c> () ;
        Save_PAYItem = new List <ASI_MFM_Payment_Line_Item__c> () ; 
        
        for (integer i : ItemMap.keySet()){
            LineObj sapl = ItemMap.get(i);
            
            if(ItemMap.get(i).boolSelected){
                //3rd create PO Line Item
                ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_AccountsAdditionalField__c=sapl.pl.ASI_MFM_Beneficiary_Customer__c,
                                                                             recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                             ASI_MFM_PO__c = create_po.id,
                                                                             ASI_MFM_Project_Code__c=string.valueOf(Header.po.ASI_MFM_Project_Code__c),
                                                                             ASI_MFM_G_L_Date__c = System.Today(),
                                                                             ASI_MFM_Sub_brand_Code__c = sapl.pol.ASI_MFM_Sub_brand_Code__c,
                                                                             ASI_MFM_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c,
                                                                             ASI_MFM_AP_Code__c = Id.valueOf(sapl.APCodeId),
                                                                             ASI_MFM_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c,
                                                                             ASI_MFM_Plan_Line_Item__c = sapl.pol.ASI_MFM_Plan_Line_Item__c,
                                                                             ASI_MFM_KR_subLedger__c=sapl.pl.ASI_MFM_KR_subLedger__c,
                                                                             ASI_MFM_A_C_Code__c=sapl.pol.ASI_MFM_A_C_Code__c
                                                                            );
                
                //4th create Payment Line Item               
                ASI_MFM_Payment_Line_Item__c paline = new ASI_MFM_Payment_Line_Item__c(ASI_MFM_KR_subLedger__c=sapl.pl.ASI_MFM_KR_subLedger__c,
                                                                                       ASI_MFM_A_C_Code__c=sapl.pol.ASI_MFM_A_C_Code__c,
                                                                                       recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                       ASI_MFM_Payment__c = create_pa.id,
                                                                                       ASI_MFM_Plan_Number__c=Header.po.ASI_MFM_Plan__c,
                                                                                       //ASI_MFM_Payee__c = Header.pay.ASI_MFM_Supplier_Name__c,
                                                                                       ASI_MFM_Payee__c = sapl.pl.ASI_MFM_Payee__c,
                                                                                       ASI_MFM_Payment_List_Item_Description__c = sapl.pl.ASI_MFM_Payment_List_Item_Description__c,
                                                                                       ASI_MFM_Beneficiary_Customer__c =sapl.pl.ASI_MFM_Beneficiary_Customer__c,
                                                                                       ASI_MFM_Where_Customer__c =sapl.pl.ASI_MFM_Where_Customer__c,
                                                                                       ASI_MFM_Plan_Line_Item__c = sapl.pol.ASI_MFM_Plan_Line_Item__c,
                                                                                       ASI_MFM_Payment_Amount__c = sapl.pl.ASI_MFM_Payment_Amount__c,
                                                                                       ASI_MFM_PO__c = create_po.id,
                                                                                       ASI_MFM_AP_Remark__c=sapl.pl.ASI_MFM_AP_Remark__c,
                                                                                       ASI_MFM_Company__c=Company
                                                                                      );
                if(sapl.pl.ASI_MFM_Invoice_Number__c!=null){
                    paline.ASI_MFM_Invoice_Number__c = sapl.pl.ASI_MFM_Invoice_Number__c;
                }else{
                    paline.ASI_MFM_Invoice_Number__c = InvoiceNumber;
                }
                
                //only local currency can have exchange rate
                if(CurrencyName=='KRW'){
                    poline.ASI_MFM_Tax_Code__c=sapl.tx.id;
                    paline.ASI_MFM_Tax_Code__c=sapl.tx.id;
                }
                
                if(sapl.pl.ASI_MFM_Invoice_Date__c!=null){
                    paline.ASI_MFM_Invoice_Date__c = sapl.pl.ASI_MFM_Invoice_Date__c;
                }else{
                    paline.ASI_MFM_Invoice_Date__c =system.today();
                }
                
                if(Company=='PRK'){
                    paline.ASI_MFM_Business_Unit__c='P830';
                }else{
                    paline.ASI_MFM_Business_Unit__c='J520';
                }
                Save_POItem.add(poline);
                Save_PAYItem.add(paline);
                
            }
            
        }
        
        if(isRedirect == true || Test.isRunningTest()){
            try {    
                insert Save_POItem; // insert po line item
                isRedirect = true;
            } /*catch (DmlException dmle) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());// system.assertEquals(null, err);apexpages.addmessage(err); 
                IsProcess=false;
                Msg+=err;
                isRedirect = false;
                database.rollback(sp);
            }*/ catch (Exception e) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                //apexpages.addmessage(err);
                IsProcess=false;
                Msg+=err; // system.assertEquals(null,'PO Line'+ err);
                isRedirect = false;
                database.rollback(sp);
            }
        }
        
        for (Integer p = 0;p < Save_POItem.size();p++){
            Save_PAYItem[p].ASI_MFM_PO_Line_Item__c = Save_POItem[p].id;
        }
        
        if(isRedirect == true || Test.isRunningTest()){
            try {    
                insert Save_PAYItem; // insert payment line item
                
                isRedirect = true;
            } /*catch (DmlException dmle) {
                database.rollback(sp);
                apexpages.message err = new apexpages.message(apexpages.severity.error, dmle.getMessage());
                
                isRedirect = false;
                IsProcess=false;
                Msg+=err; 
                //system.assertEquals(null,'Payment Line'+ err); apexpages.addmessage(err); 
            } */catch (Exception e) {
                database.rollback(sp);
                apexpages.message err = new apexpages.message(apexpages.severity.error, e.getMessage());
                IsProcess=false;
                Msg+=err; 
                isRedirect = false;
                //system.assertEquals(null, 'Payment Line'+err); apexpages.addmessage(err);
            }
        }
        
        if(isRedirect){
            SaveSuccess=true;
        }        
    }
    
    
    public PageReference Reset() {
        ApexPages.getMessages().clear();
        PageReference redirect = new PageReference(ApexPages.currentPage().getHeaders().get('Referer')); 
        return redirect;
    }
    
    @RemoteAction
    public static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        String soql;
        if(filter != '' || filter != null)
            soql = 'select '+statement+' from ' + obj + filter +' order by Name';
        else
            soql = 'select '+statement+' from ' + obj +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try
        {
            sobjs = Database.query(soql);
            return sobjs; 
        }//end try
        catch (QueryException e)
        {
            return null;
        }//end catch
        return sobjs;
    }
    
    
    @RemoteAction
    public static List<sObject> findCustomers(string obj, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        
        String soql;
        if(filter != '' || filter != null)
            soql = 'select Id, Name,RecordType.DeveloperName, ASI_CRM_CN_Address__c, ASI_CRM_CN_Phone_Number__c from ' + obj + filter ;
        else 
            soql = 'select Id, Name,RecordType.DeveloperName, ASI_CRM_CN_Address__c, ASI_CRM_CN_Phone_Number__c from ' + obj ; 
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try
        {
            sobjs = Database.query(soql);
            return sobjs; 
        }//end try
        catch (QueryException e)
        {
            return null;
        }//end catch
        return sobjs;
    }//end method: findSObjects
    
    @RemoteAction
    public static List<sObject> findSObjects(string obj, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        
        String soql;
        if(filter != '' || filter != null)
            soql = 'select Id, Name from ' + obj + filter +' order by Name';
        else
            soql = 'select Id, Name from ' + obj +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try
        {
            sobjs = Database.query(soql);
            return sobjs; 
        }//end try
        catch (QueryException e)
        {
            return null;
        }//end catch
        return sobjs;
    }//end method: findSObjects
    
    
    @RemoteAction
    public static Map<String, Decimal> retrieveExchangeRate(){
        Map<String, Decimal> exchangeRateTable = new  Map<String, Decimal>();
        string country = 'KR';
        Map<String, String> CurrencyEffectiveMap = new Map<String, String>();
        List<String> availableCurrency = new List<String> { 'KRW', 'AUD', 'EUR', 'GBP', 'HKD' ,'SGD' ,'USD'};
            
            AggregateResult[] CurrencyEffective =[Select ASI_MFM_Counter_Currency__c , Id, MAX(ASI_MFM_Effective_Date__c) from ASI_MFM_Exchange_Rate__c 
                                                  where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = : country
                                                  and ASI_MFM_Base_Currency__c ='KRW' and ASI_MFM_Effective_Date__c <= :date.today()  
                                                  and (ASI_MFM_Counter_Currency__c in: availableCurrency) group by ASI_MFM_Counter_Currency__c, Id];
        
        //extract currency and id from CurrencyEffective to CurrencyEffectiveMap
        if(CurrencyEffective!=null){
            for(AggregateResult ar : CurrencyEffective){ 
                CurrencyEffectiveMap.put(String.ValueOf(ar.get('ASI_MFM_Counter_Currency__c')), String.ValueOf(ar.get('Id')));
            }
        }
        //store currency, exchange rate to a list called exchangeRates
        List<ASI_MFM_Exchange_Rate__c> exchangeRates = new List<ASI_MFM_Exchange_Rate__c>();
        
        exchangeRates =   [Select ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c  where id in: CurrencyEffectiveMap.values()];
        
        //if there is record in exchangeRate list, records will be inserted into exchangeRateTable which is a Map
        if(exchangeRates!=null && exchangeRates.size()>0){
            
            for(ASI_MFM_Exchange_Rate__c ae : exchangeRates){
                exchangeRateTable.put(ae.ASI_MFM_Counter_Currency__c, ae.ASI_MFM_Exchange_Rate__c);
            }
            system.debug('exchangeRateTable :' + exchangeRateTable);       
        }
        
        return exchangeRateTable;
    }
    
    //********************************************End : RemoteAction**************************************************************
    
    
    
    
    
    //***** Wapper Class **********
    public Class HeaderObj{
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
        public ASI_MFM_Plan_Line_Item__c PlanLineItem {get; set;}
    }
    
    
    public Class LineObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
            } 
            set; }
        public ASI_MFM_Plan_Line_Item__c PlanLine {get; set;}
        public ASI_MFM_PO_Line_Item__c pol {get; set;}
        public ASI_MFM_Payment_Line_Item__c pl {get; set;}
        public ASI_MFM_Tax_Code__c tx {get; set;}
        public ASI_CRM_PayeeVAT__c payee{get; set;}
        public String Customer {set;get;}
        public String CustomerId {set;get;}
        public boolean NeedCustomer {set;get;}
        public String VenueWhere {set;get;}
        public String VenueWhereId {set;get;}
        public String subLedger{set;get;}
        public String subLedgerId{set;get;}
        public String APCode {set;get;}
        public String APCodeId {set;get;}
        public string APType {set;get;}
        public string APCategory {set;get;}
        public Boolean boolSelected {get; set;}
    }
    //******End Wapper Class***********
    
}