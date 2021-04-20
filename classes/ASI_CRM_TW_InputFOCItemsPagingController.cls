public without sharing class ASI_CRM_TW_InputFOCItemsPagingController {

    public ASI_FOC_Free_Goods_Request__c  PO {get; private set;}
    public boolean boolOPTEAM {get; set;}
    
    //public ASI_MFM_Sub_brand__c brandObj{ get; set; }
    public ASI_FOC_Request_Item__c searchObj { get; set; }
    Public ASI_FOC_Request_Item__c rowObjAll {Get; Set;}
    Public List<ASI_FOC_Request_Item__c> del_results {Get; Set;}
    
    Public id pid {Get; Set;}
    //Public id typeId {Get; Set;}
    
    Public id posm_typeId {Get; Set;}
    Public id foc_typeId {Get; Set;}
    Public id posm_item_typeId {Get; Set;}
    Public id foc_item_typeId {Get; Set;}
    //public string AC_Code1 {set;get;}
    
    Public boolean isAllowEdit {set;get;}
    Public boolean isAllowPartialEdit {set;get;}
    Public boolean allowAddNew {set;get;}
    
    Public List<POLineObj> results {Get; Set;}
    Public Boolean allSelected {Get; Set;}
    
    Public Boolean allowClone {Get; Set;}
    Public Boolean showCanelField {Get; Set;}
    
    public String querySOQL;
    
    
    public id searchSKUId {Get; Set;}
    public id searchOutletId {Get; Set;}
    public id searchDeliverToId {Get; Set;}
    public id searchSubBrandId {Get; Set;}
    public id searchAccountCodeId {Get; Set;}
    public id searchCustomerNameId {Get; Set;}
    
    //pagination variable
    Public String recordNumberDisplay {get;set;}//show current no out of total no.
    Public integer pageSize {Get; Set;}{pageSize = 10;}// to set up the pageSize
    Public Boolean disablePrevious {Get; Set;}
    Public Boolean disableNext {Get; Set;}
    Public integer totalSize {Get; Set;}
    Public integer counter {Get; Set;}
    //Public String testStr {Get; Set;}

    Public String CurrentDeliveryTo {Get; Set;}
    Public Integer CurrentSeqNO {Get; Set;}

    Public String currentID {get;set;}

    public map<string, string> accid_deliverytime_map;
    
    public ASI_CRM_TW_InputFOCItemsPagingController(ApexPages.StandardController controller) {
        pid = apexpages.currentPage().getParameters().get('id');
        //typeId = [SELECT Id FROM RecordType WHERE DeveloperName ='ASI_CRM_TW_POSM_Request'].Id;
        
        posm_typeId = [SELECT Id FROM RecordType WHERE DeveloperName ='ASI_CRM_TW_POSM_Request'].Id;
        foc_typeId = [SELECT Id FROM RecordType WHERE DeveloperName ='ASI_CRM_TW_FOC_Request'].Id;
        system.debug('posm_typeId '+ posm_typeId);
        system.debug('foc_typeId '+ foc_typeId);
        posm_item_typeId = [SELECT Id FROM RecordType WHERE DeveloperName ='ASI_CRM_TW_POSM_Request_Item'].Id;
        foc_item_typeId = [SELECT Id FROM RecordType WHERE DeveloperName ='ASI_CRM_TW_FOC_Request_Item'].Id;
        
        system.debug('posm_item_typeId '+ posm_item_typeId);
        system.debug('foc_item_typeId '+ foc_item_typeId);
        
        allowClone = false;
        showCanelField = false;
        allowAddNew = false;
        isAllowEdit = false;
        isAllowPartialEdit  = false;
        PO = database.query(ASI_MFM_function.buildQuery('ASI_FOC_Free_Goods_Request__c', null) + ' where id = :pid');
    
         List<PermissionSetAssignment> listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment
                                                               WHERE AssigneeId = :Userinfo.getUserId() AND 
                                                               PermissionSet.Name = 'ASI_CRM_TW_OP_Team'];
                                                               
        if(listCurrentUserPerSet != null && listCurrentUserPerSet.size() > 0)
            boolOPTEAM = true;
        
        /*
        For line with Approved Header:
            1.Only "SKU" and "Request Quantity (Bottle)" can be edited, other fields are  
                Read- only for Users with Permission Set "ASI_CRM_TW_OP_Team"
             2.All fields are Read-only for users not with Permission Set           
                "ASI_CRM_TW_OP_Team"

        For line with Final/Submitted/Completed/Cancel Header
             All fields are Read-only
        */
        
        if (po.ASI_FOC_Request_Status__c == 'Draft'){
            isAllowEdit = true;
            allowAddNew = true;
            allowClone = true;
        }else{
            
            if (po.ASI_FOC_Request_Status__c == 'Approved' && boolOPTEAM == true) {
                if(boolOPTEAM) {
                    isAllowPartialEdit  = true;
                    
                    showCanelField = true;
                } else {
                    
                    showCanelField = true;
                }
            }            
            if (po.ASI_FOC_Request_Status__c == 'Final' || po.ASI_FOC_Request_Status__c == 'Submitted' || 
                po.ASI_FOC_Request_Status__c == 'Completed' || po.ASI_FOC_Request_Status__c == 'Cancel' ) {
              
                showCanelField = true;
            }


        }
        
        
        System.debug('init: allowClone ' + allowClone);
        
        //brandObj = new ASI_MFM_Sub_brand__c();
        searchObj = new ASI_FOC_Request_Item__c ();
        rowObjAll = new ASI_FOC_Request_Item__c ();
        
        //getACCodeNSubbrandMap();
        if(pid != Null)
            if(!Test.isRunningTest()) search();
    }
    
    public list<SelectOption> getItemRecordTypes()
    {
        list<SelectOption> options = new list<SelectOption>();
        for(RecordType sRecordType : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'ASI_FOC_Request_Item__c'])
        {
            // Select options are added with key,value pairing
            options.add(new SelectOption(sRecordType.Id, sRecordType.Name));
        }
        
        return options;
   }
    
    public list<SelectOption> getAccountCodelist()
    {
    
    
        List<String> idList=new List<String>(); 
        AggregateResult[] listCategory = [SELECT  ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c =:pid group by ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c];
        
        for(AggregateResult item : listCategory){
            if(item.get('ASI_MFM_A_C_Code__c') != null)
                 idList.add(String.valueof(item.get('ASI_MFM_A_C_Code__c')));               
        }           
        System.debug('getAccountCodelist: idList ' + idList);
        list<SelectOption> options = new list<SelectOption>();
         options.add(new SelectOption('', '--None--'));
        for(ASI_MFM_A_C_Code__c a : [SELECT  Id, Name, ASI_MFM_A_C_Code__c FROM ASI_MFM_A_C_Code__c WHERE id IN :idList])
        {
            // Select options are added with key,value pairing
            options.add(new SelectOption(a.Id, a.ASI_MFM_A_C_Code__c));
        }
        
        return options;
    }
    
    public list<SelectOption> getSubBrandlist()
    {
    
    
        List<String> idList=new List<String>(); 
        AggregateResult[] listCategory = [SELECT  ASI_CRM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c =:pid group by ASI_CRM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c];
        System.debug('getSubBrandlist: listCategory ' + listCategory);
        for(AggregateResult item : listCategory){
            if(item.get('ASI_MFM_Sub_brand_Code__c') != null)
                 idList.add(String.valueof(item.get('ASI_MFM_Sub_brand_Code__c')));               
        }           
        System.debug('getSubBrandlist: idList ' + idList);
        list<SelectOption> options = new list<SelectOption>();
         options.add(new SelectOption('', '--None--'));
        for(ASI_MFM_Sub_brand__c a : [SELECT  Id, Name, ASI_MFM_Sub_brand_Code__c FROM  ASI_MFM_Sub_brand__c WHERE id IN :idList])
        {
            // Select options are added with key,value pairing
            options.add(new SelectOption(a.Id, a.ASI_MFM_Sub_brand_Code__c));
        }
        
        return options;
   }
    
    public list<SelectOption> getCustomerNamelist()
    {
        List<String> idList=new List<String>(); 
        AggregateResult[] listCategory = [SELECT  ASI_CRM_Plan_Line_Item__r.ASI_MFM_Customer_Name__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c =:pid group by ASI_CRM_Plan_Line_Item__r.ASI_MFM_Customer_Name__c];
        
        for(AggregateResult item : listCategory){
            if(item.get('ASI_MFM_Customer_Name__c') != null)
                 idList.add(String.valueof(item.get('ASI_MFM_Customer_Name__c')));               
        }           
        System.debug('getCustomerNamelist: idList ' + idList);
        list<SelectOption> options = new list<SelectOption>();
         options.add(new SelectOption('', '--None--'));
        for(Account a : [SELECT  Id, Name FROM  Account WHERE id IN :idList])
        {
            // Select options are added with key,value pairing
            options.add(new SelectOption(a.Id, a.Name));
        }
        
        return options;
   }
    
    public list<SelectOption> getSKUlist()
    {
        List<String> idList=new List<String>(); 
        AggregateResult[] listCategory = [SELECT  ASI_FOC_SKU__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c =:pid group by  ASI_FOC_SKU__c];
        for(AggregateResult sku : listCategory){
            if(sku.get('ASI_FOC_SKU__c') != null)
                 idList.add(String.valueof(sku.get('ASI_FOC_SKU__c')));               
        }           
        System.debug('getSKUlist: idList ' + idList);
        list<SelectOption> options = new list<SelectOption>();
         options.add(new SelectOption('', '--None--'));
        for(ASI_MFM_SKU_Code__c sku : [SELECT  Id, Name FROM ASI_MFM_SKU_Code__c WHERE id IN :idList])
        {
            // Select options are added with key,value pairing
            options.add(new SelectOption(sku.Id, sku.Name));
        }
        
        return options;
   }
 
  public list<SelectOption> getDeliverTolist()
    {
        List<String> idList=new List<String>(); 
        AggregateResult[] listCategory = [SELECT  ASI_CRM_Delivery_To__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c =:pid group by  ASI_CRM_Delivery_To__c];
        for(AggregateResult item : listCategory){
            if(item.get('ASI_CRM_Delivery_To__c') != null)
                 idList.add(String.valueof(item.get('ASI_CRM_Delivery_To__c')));               
        }           
        System.debug('getDeliverTolist: idList ' + idList);
        list<SelectOption> options = new list<SelectOption>();
         options.add(new SelectOption('', '--None--'));
        for(Account a : [SELECT  Id, Name FROM Account WHERE id IN :idList])
        {
            // Select options are added with key,value pairing
            options.add(new SelectOption(a.Id, a.Name));
        }
        
        return options;
   }
 
    public list<SelectOption> getOutletlist()
    {
    
        List<String> idList=new List<String>(); 
        AggregateResult[] listCategory = [SELECT  ASI_CRM_Target_Outlet__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c =:pid group by  ASI_CRM_Target_Outlet__c];
        for(AggregateResult item : listCategory){
            if(item.get('ASI_CRM_Target_Outlet__c') != null)
                 idList.add(String.valueof(item.get('ASI_CRM_Target_Outlet__c')));               
        }           
        System.debug('getOutletlist: idList ' + idList);
        list<SelectOption> options = new list<SelectOption>();
         options.add(new SelectOption('', '--None--'));
        for(Account a : [SELECT  Id, Name FROM Account WHERE id IN :idList])
        {
            // Select options are added with key,value pairing
            options.add(new SelectOption(a.Id, a.Name));
        }
        
        return options;
   }
 
    /* 
    public void getACCodeNSubbrandMap(){
        
        sbCodeMap = new map<string, string>();        
        ACCodeMap = new map<string, string>();
        acCode = new List<selectOption>();
        subbrandCode = new List<selectOption>();
        acCode.add(new selectOption('', 'None'));
        subbrandCode.add(new selectOption('', 'None'));
        
        list<ASI_MFM_A_C_Code__c> accodeList = [SELECT id, Name FROM ASI_MFM_A_C_Code__c WHERE recordType.developerName Like 'ASI_MFM_HK_A_C_Code']; 
        if (accodeList.size() > 0) {
            for (ASI_MFM_A_C_Code__c temp : accodeList){
                
                acCode.add(new selectOption(temp.id, temp.Name));
                ACCodeMap.put(temp.Name, temp.Id);
            }
        }

        list<ASI_MFM_Sub_brand__c> sbList = [SELECT id, Name FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Inactive__c = false and recordtype.developerName like 'ASI_HK_CRM_Sub_brand']; 
        if (sbList.size() > 0) {
            for (ASI_MFM_Sub_brand__c temp : sbList){
                
                subbrandCode.add(new selectOption(temp.id, temp.Name));
                sbCodeMap.put(temp.Name, temp.Id);
            }
        }
    }
    */
    
    /*
    public string getACnSBCode(string strName, string strType){
        
        string strReturn;
        
        if (strType == 'AC'){
            
            if (ACCodeMap.containskey(strName))
                strReturn = ACCodeMap.get(strName);
        }else if (strType == 'SB'){
            
            if (sbCodeMap.containskey(strName))
                strReturn = sbCodeMap.get(strName);
        }
        return strReturn;
    }
    */
    
     public void reset(){
        searchSKUId = null;
        searchOutletId = null;
        searchSubBrandId = null;
        searchDeliverToId = null;
        searchAccountCodeId = null;
        searchAccountCodeId = null;
      
        if(!Test.isRunningTest()) search(); 
    }

    
    //20170504 Introv
    Public void search(){
        
        totalSize = Database.countquery('SELECT COUNT() FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c  = \'' + pid + '\'');
        results = new List<POLineObj>();
        
        counter = 0;
        
        if (totalSize > 0){
            querySOQL = 'SELECT Name, ASI_FOC_Request_Order__c, ASI_CRM_Plan_Line_Item__c, ASI_CRM_Plan_Line_Description__c, ASI_CRM_Sub_brand_Description__c, ASI_CRM_Sub_Brand_Code__c, ASI_CRM_Account_Code__c , ASI_CRM_Customer_Name__c, ASI_CRM_Customer_Code__c, ASI_FOC_SKU__c, ASI_FOC_SKU__r.ASI_MFM_Item_Group__c, ASI_FOC_G_H_Request__c, ASI_FOC_Request_Quantity_Bottle__c, ASI_CRM_Target_Outlet__c, ASI_CRM_Delivery_To__c , ASI_CRM_Reimbursement__c, ASI_CRM_Delivery_Address__c, ASI_CRM_Delivery_Tel__c,  ASI_CRM_Receiver__c, ASI_FOC_Remark__c, ASI_CRM_Delivery_Instruction__c, recordtypeid , ASI_FOC_Cancel_Qty__c FROM ASI_FOC_Request_Item__c WHERE ASI_FOC_Request_Order__c = \'' + pid + '\' ';
           
           if(searchSKUId !=null) {               
               querySOQL += ' and ASI_FOC_SKU__c =:searchSKUId ';
           }
          
           if(searchOutletId !=null) {        
               querySOQL += ' and ASI_CRM_Target_Outlet__c =:searchOutletId ';                      
           }
           
           if(searchDeliverToId !=null) {        
               querySOQL += ' and ASI_CRM_Delivery_To__c =:searchDeliverToId ';                      
           }
         
           if(searchSubBrandId !=null) {        
               querySOQL += ' and ASI_CRM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c =:searchSubBrandId ';                      
           }
           
           if(searchAccountCodeId !=null) {        
               querySOQL += ' and ASI_CRM_Plan_Line_Item__r.ASI_MFM_A_C_Code__c =:searchAccountCodeId ';                      
           }
           
           if(searchCustomerNameId !=null) {        
               querySOQL += ' and ASI_CRM_Plan_Line_Item__r.ASI_MFM_Customer_Name__c =:searchCustomerNameId ';                      
           }
           
           //if (searchObj.ASI_FOC_SKU__c != null){
           //     
           //     skuId = searchObj.ASI_FOC_SKU__c;
           //     querySOQL += ' and ASI_FOC_SKU__c =:skuId ';
           // }
            
            //if (searchObj.ASI_CRM_Target_Outlet__c != null){
           //     
           //     outletId = searchObj.ASI_CRM_Target_Outlet__c;
           //     querySOQL += ' and ASI_CRM_Target_Outlet__c =:outletId ';
            //}
            
            //if (searchObj.ASI_CRM_Delivery_To__c != null){
            //    
            //    deliver_to_Id = searchObj.ASI_CRM_Delivery_To__c;
            //    querySOQL += ' and ASI_CRM_Delivery_To__c =:deliver_to_Id ';
            //}
            
            /*
            if (SB_Name != null && SB_Name != ''){
                subBrandId = getACnSBCode(SB_Name , 'SB');
                querySOQL += ' and ASI_MFM_Sub_brand_Code__c =:subBrandId ';
            }
            
            if (brandObj.ASI_MFM_Brand__c != null){
                
                brandId = brandObj.ASI_MFM_Brand__c;
                querySOQL += ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__c =:brandId ';
                System.debug('brandId:' + brandId + ';'  );
            }
            
            if (AC_Code != null && AC_Code != ''){
                
                acCodeId = getACnSBCode(AC_Code, 'AC');
                querySOQL += ' and ASI_MFM_A_C_Code__c =:acCodeId ';
            }
            
            if (searchObj.ASI_MFM_Customer_Name__c != null){
                
                custId = searchObj.ASI_MFM_Customer_Name__c;
                querySOQL += ' and ASI_MFM_Customer_Name__c =:custId ';
            }
            
            if (searchObj.ASI_MFM_G_L_Date__c != null) {
                
                String fromDate = DateTime.newInstance(searchObj.ASI_MFM_G_L_Date__c.year(),searchObj.ASI_MFM_G_L_Date__c.month(),searchObj.ASI_MFM_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                querySOQL += ' AND ASI_MFM_G_L_Date__c  >= ' + fromDate + ''; 
            }
            
            if (searchObj.ASI_MFM_Post_G_L_Date__c != null) {
                String toDate = DateTime.newInstance(searchObj.ASI_MFM_Post_G_L_Date__c.year(),searchObj.ASI_MFM_Post_G_L_Date__c.month(),searchObj.ASI_MFM_Post_G_L_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
                querySOQL += ' AND ASI_MFM_G_L_Date__c    < ' + toDate + ''; 
            }
            */ 
            
            querySOQL += ' ORDER BY Name ASC limit ' + pageSize;
            
            if(!Test.isRunningTest()) searchCurrentPage();
        }else{
            results = new List<POLineObj>();
        }
    }
    
    public void searchCurrentPage(){
        
        try{
            results = new List<POLineObj>();
            
            disablePrevious = getDisablePrevious();
            disableNext = getDisableNext();
            recordNumberDisplay = '(' + String.valueOf(counter + 1)+ ' - ' + String.valueOf(pageSize + (counter) > totalSize ? totalSize : pageSize + (counter) ) + ' of ' + String.valueOf(totalSize) + ')';
            
            List<ASI_FOC_Request_Item__c> poList = Database.query(querySOQL + + ' OFFSET '+ String.valueof(counter));

            accid_deliverytime_map = Queryaccid_deliverytime_map(poList);
            
            system.debug('+++accid_deliverytime_map: '+accid_deliverytime_map);

            integer i=0;
            for (ASI_FOC_Request_Item__c  pobj: poList){
                POLineObj poO = new POLineObj();
                
                poO.id = pobj.Name;
                //poO.ACCode = pobj.ASI_MFM_A_C_Code__r.Name;
                //poO.SBCode = pobj.ASI_MFM_Sub_brand_Code__r.Name;
                poO.ppl = pobj;
                if(poO.ppl.ASI_CRM_Delivery_Instruction__c == null || poO.ppl.ASI_CRM_Delivery_Instruction__c == '')
                {
                    string DeliveryInstruction='';
                    if(accid_deliverytime_map.containskey(poO.ppl.ASI_CRM_Delivery_To__c))
                    {
                        DeliveryInstruction = accid_deliverytime_map.get(poO.ppl.ASI_CRM_Delivery_To__c);
                    }
                    poO.ppl.ASI_CRM_Delivery_Instruction__c = DeliveryInstruction;
                }
                poO.selected = false;
                poO.seqNO = i;

                i=i+1;
                
                results.add(poO);      
            }

            //searchMainContact();                  
        }catch(Exception ex){
            ApexPages.addMessages(ex);
        }
        
    }

    public map<string, string> Queryaccid_deliverytime_map(List<ASI_FOC_Request_Item__c> poList)
    {
        accid_deliverytime_map = new map<string, string>();
        set<string> accid_set = new set<string>();

        for (ASI_FOC_Request_Item__c  pobj: poList)
        {
            accid_set.add(pobj.ASI_CRM_Delivery_To__c);
        }
        system.debug('+++accid_set: '+accid_set);

        for(ASI_CRM_AccountsAdditionalField__c customer : [select id, ASI_TH_CRM_OperatingHoursFrom__c, ASI_TH_CRM_OperatingHoursTo__c, ASI_CRM_Account__c from ASI_CRM_AccountsAdditionalField__c where ASI_CRM_Account__c in: accid_set])
        {
            string DeliveryInstruction = '';

            if(customer.ASI_TH_CRM_OperatingHoursFrom__c != null)
            {
                DeliveryInstruction += customer.ASI_TH_CRM_OperatingHoursFrom__c;
            }

            if(customer.ASI_TH_CRM_OperatingHoursTo__c != null)
            {
                DeliveryInstruction += ' - ' + customer.ASI_TH_CRM_OperatingHoursTo__c;
            }

            accid_deliverytime_map.put(customer.ASI_CRM_Account__c, DeliveryInstruction);
        }
        return accid_deliverytime_map;
    }

    public void searchMainContact(){
        map<string, list<contact>> AccId_MainContact_map = new map<string, list<contact>>();

        set<string> DeliveryToId_set = new set<string>();

        for(POLineObj POLO : results){
            DeliveryToId_set.add(POLO.ppl.ASI_CRM_Delivery_To__c);
        }

        for(Account acc : [select id, name, (select id, LastName, FirstName from Contacts where ASI_HK_CRM_Main_Contact__c = true limit 1) from Account where id in: DeliveryToId_set]){
            AccId_MainContact_map.put(acc.Id, acc.contacts);
        }

        for(POLineObj POLO : results){
            if(AccId_MainContact_map.containskey(POLO.ppl.ASI_CRM_Delivery_To__c)){
                list<contact> contact_L = AccId_MainContact_map.get(POLO.ppl.ASI_CRM_Delivery_To__c);
                if(contact_L.size()>0){
                    POLO.ppl.ASI_CRM_Receiver__c = (contact_L[0].LastName != null ? contact_L[0].LastName : '') + ' ' + (contact_L[0].FirstName != null ? contact_L[0].FirstName : '');
                }
            }
        }
    }

    public void QueryReceiver()
    {
        for(POLineObj POLO : results)
        {
            if(POLO.seqNO == CurrentSeqNO)
            {
                //if(POLO.ppl.ASI_CRM_Delivery_To__c != null)
                //{
                    Map<Id, Account> mapDeliveryToAcc = new Map<Id, Account>();
                    for(Account acc : [SELECT id, ASI_HK_CRM_Address__c, Phone, RecordType.developername, ASI_MFM_Address_Line_4__c,
                                        (select id, ASI_CRM_TW_Invoice_Address__c, ASI_CRM_WHAddress__c, ASI_CRM_TW_Warehouse_Address__c 
                                        from ASI_CRM_Accounts_Additional_Fields__r)
                                        FROM Account 
                                        WHERE Id =: POLO.ppl.ASI_CRM_Delivery_To__c])
                    {
                        mapDeliveryToAcc.put(acc.id, acc);
                    }

                    if(mapDeliveryToAcc != NULL && mapDeliveryToAcc.size() > 0){
                        Account tempacc = mapDeliveryToAcc.get(POLO.ppl.ASI_CRM_Delivery_To__c);
                        if(!tempacc.RecordType.developername.contains('ASI_MFM_TW_Supplier'))
                        {
                            if(mapDeliveryToAcc.get(POLO.ppl.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r.size()>0)
                            {
                                if(mapDeliveryToAcc.get(POLO.ppl.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_Warehouse_Address__c != null)
                                {
                                    POLO.ppl.ASI_CRM_Delivery_Address__c = mapDeliveryToAcc.get(POLO.ppl.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_Warehouse_Address__c;
                                }
                                else 
                                {
                                    POLO.ppl.ASI_CRM_Delivery_Address__c = mapDeliveryToAcc.get(POLO.ppl.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Address__c;
                                }
                            }
                            else
                            {
                                POLO.ppl.ASI_CRM_Delivery_Address__c = mapDeliveryToAcc.get(POLO.ppl.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Address__c;
                            }

                            //POLO.ppl.ASI_CRM_Delivery_Address__c = mapDeliveryToAcc.get(POLO.ppl.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Address__c;
                            POLO.ppl.ASI_CRM_Delivery_Tel__c = '';
                            POLO.ppl.ASI_CRM_Receiver__c = '';
                            POLO.ppl.ASI_CRM_Delivery_Instruction__c = '';

                        }
                        else 
                        {
                            POLO.ppl.ASI_CRM_Delivery_Address__c = tempacc.ASI_MFM_Address_Line_4__c;
                        }
                        POLO.ppl.ASI_CRM_Delivery_Tel__c = mapDeliveryToAcc.get(POLO.ppl.ASI_CRM_Delivery_To__c).Phone;
                    }
                    else {
                        POLO.ppl.ASI_CRM_Delivery_Address__c = '';
                        POLO.ppl.ASI_CRM_Delivery_Tel__c = '';
                        POLO.ppl.ASI_CRM_Receiver__c = '';
                        POLO.ppl.ASI_CRM_Delivery_Instruction__c = '';
                    }
                //}                
                list<Account> acc_L = new list<Account>();
                acc_L = [select id, name, (select firstname, lastname from contacts where ASI_HK_CRM_Main_Contact__c = true limit 1), (select id, ASI_TH_CRM_OperatingHoursFrom__c, ASI_TH_CRM_OperatingHoursTo__c, ASI_CRM_Account__c from ASI_CRM_Accounts_Additional_Fields__r) from account where id =: POLO.ppl.ASI_CRM_Delivery_To__c];
                if(acc_L.size() > 0)
                {
                    if(acc_L[0].contacts.size() > 0)
                    {
                        POLO.ppl.ASI_CRM_Receiver__c = (acc_L[0].contacts[0].LastName != null ? acc_L[0].contacts[0].LastName : '') + ' ' + (acc_L[0].contacts[0].FirstName != null ? acc_L[0].contacts[0].FirstName : '');
                    }

                    if(acc_L[0].ASI_CRM_Accounts_Additional_Fields__r.size()>0)
                    {
                        if(POLO.ppl.ASI_CRM_Delivery_Instruction__c == null || POLO.ppl.ASI_CRM_Delivery_Instruction__c == '')
                        {
                            string DI = '';
                            if(acc_L[0].ASI_CRM_Accounts_Additional_Fields__r[0].ASI_TH_CRM_OperatingHoursFrom__c != null)
                            {
                                DI += acc_L[0].ASI_CRM_Accounts_Additional_Fields__r[0].ASI_TH_CRM_OperatingHoursFrom__c;
                            }
                            if(acc_L[0].ASI_CRM_Accounts_Additional_Fields__r[0].ASI_TH_CRM_OperatingHoursTo__c != null)
                            {
                                DI += ' - ' + acc_L[0].ASI_CRM_Accounts_Additional_Fields__r[0].ASI_TH_CRM_OperatingHoursTo__c;
                            }
                            POLO.ppl.ASI_CRM_Delivery_Instruction__c = DI;
                        }
                    }
                }
            }
        }
    }
    
    public Class POLineObj{
        public String id{ 
            get{
                if(String.isBlank(id)) {
                    return null;
                }
                return id;
            } 
            set; }
        //public string SBCode {set;get;}
        //public string ACCode {set;get;}
        /*
        public ASI_MFM_Plan_Line_Item__c ASI_CRM_Plan_Line_Item {set;get;}
        public string ASI_CRM_Plan_Line_Description {set;get;} 
        public string ASI_CRM_Sub_brand_Description {set;get;} 
        public string ASI_CRM_Sub_Brand_Code {set;get;} 
        public string ASI_CRM_Account_Code {set;get;} 
        public string ASI_CRM_Customer_Name {set;get;} 
        public string ASI_CRM_Customer_Code {set;get;} 
        public ASI_MFM_SKU_Code__c ASI_FOC_SKU {set;get;} 
        public integer ASI_FOC_Request_Quantity_Bottle {set;get;} 
        public Account ASI_CRM_Target_Outlet {set;get;} 
        public Account ASI_CRM_Delivery_To {set;get;} 
        public Boolean ASI_CRM_Reimbursement {set;get;}  
        public string ASI_CRM_Delivery_Address {set;get;}  
        public string ASI_CRM_Delivery_Tel {set;get;}  
        public string ASI_CRM_Receiver {set;get;}  
        public string ASI_FOC_Remark {set;get;}  
        public Boolean selected {get; set;}
        public RecordType recordType {get; set;}
        */
        public Boolean selected {get; set;}
        public ASI_FOC_Request_Item__c ppl {get; set;}
        public integer seqNO {get; set;}
    }
    
    public PageReference save(){
        if(results == null) return null;
        PageReference redirect;
        Boolean isRedirect = onCommitted();
        if (isRedirect)
        {
            redirect = new PageReference('/'+ pid); 
        }else{
            redirect = null;
        }
        
        return redirect;   
    }
    public void quickSave(){
        if(results != null) {
            PageReference redirect;
            Boolean isRedirect = onCommitted();
            if (isRedirect)
            {
                if(!Test.isRunningTest()) search(); 
            }else{
                redirect = null;
            }
        }
    }
    public boolean onCommitted(){
        
        if(results == null) return false;
        //2014-08-07 Stella Sing Check Validation of required field (Page layout is not set to required, only style)
        boolean isBlanked = false;
        boolean isValid = false;
        
        
        Set<Id> SKUid_set = new Set<id>();
        Set<Id> GnHid_set = new Set<id>();
        
        for (POLineObj rpl : results){
            if (rpl.ppl.ASI_CRM_Plan_Line_Item__c == null && PO.RecordTypeId == foc_typeId){
                rpl.ppl.ASI_CRM_Plan_Line_Item__c.addError('Required field.');
                isBlanked = true;
            }
            
            if (rpl.ppl.ASI_FOC_SKU__c == null){
                rpl.ppl.ASI_FOC_SKU__c.addError('Required field.');
                isBlanked = true;
            }
            
            if (rpl.ppl.ASI_CRM_Delivery_To__c == null){
                rpl.ppl.ASI_CRM_Delivery_To__c.addError('Required field.');
                isBlanked = true;
            }
            // Added by 2018-08-15 Linus@introv            
            if (rpl.ppl.RecordtypeId == foc_item_typeId){
                
                if(rpl.ppl.ASI_FOC_G_H_Request__c != null){
                    //rpl.ppl.ASI_FOC_G_H_Request__c.addError('Missing G&H Request.');
                    //isBlanked = true;
                //}else{
                    SKUid_set.add(rpl.ppl.ASI_FOC_SKU__c);
                    GnHId_set.add(rpl.ppl.ASI_FOC_G_H_Request__c);
                    isValid = true;
                }
            }
            
            if (rpl.ppl.ASI_FOC_Request_Quantity_Bottle__c == null){
                rpl.ppl.ASI_FOC_Request_Quantity_Bottle__c.addError('Required field.');
                isBlanked = true;
            }

            if(rpl.ppl.ASI_CRM_Receiver__c == '' || rpl.ppl.ASI_CRM_Receiver__c == null){
                rpl.ppl.ASI_CRM_Receiver__c.addError('Required field.');
                isBlanked = true;
            }
        }
        
        // Added by 2018-08-17 Linus@introv
        Map<id, id> SKUItmGrp_map = new Map<id, id>();
        for(ASI_MFM_SKU_Code__c sku: [Select id, ASI_MFM_Item_Group__c from ASI_MFM_SKU_Code__c where id IN: SKUid_set]){   system.debug('Linus: check SKU Item Group ' + sku.id + ' ' +  sku.ASI_MFM_Item_Group__c);
            SKUItmGrp_map.put(sku.id, sku.ASI_MFM_Item_Group__c);
        }
        for(POLineObj rpl : results){
            if (rpl.ppl.RecordtypeId == foc_item_typeId && SKUid_set.size() > 0){
                if(rpl.ppl.ASI_FOC_SKU__c != null && SKUItmGrp_map.get(rpl.ppl.ASI_FOC_SKU__c) == null){  
                    rpl.ppl.ASI_FOC_SKU__c.addError('Missing Item Group.');
                    isBlanked = true;
                    isValid = false;
                }
                
            }
        }
        // Validation of checking FOC amount not exceed total Amount of G&H request (Amount per receipient * PAX)
        if(isValid || Test.isRunningTest()){
            Map<Id, ASI_GnH_request__c> GnHMap = new Map<Id, ASI_GnH_Request__c>([Select id, ASI_GnH_Amount_per_Recipient__c, ASI_GnH_PAX__c from ASI_GnH_Request__c where id = :GnHid_set]);
            
            // Get total T&E receipt amount of each G&H request
            List<ASI_FOC_Request_Item__c> FOCIList = [Select id, ASI_FOC_G_H_Request__c, ASI_CRM_TW_Amount__c from ASI_FOC_Request_Item__c where ASI_FOC_G_H_Request__c = :GnHid_Set];            
            List<ASI_TnE_ClaimDetail__c> TnEList = [Select id, ASI_TnE_GnH_Request__c, ASI_TnE_Receipt_Amount__c from ASI_TnE_ClaimDetail__c where ASI_TnE_GnH_request__c = :GnHid_Set];
            Map<id, Decimal> GnHTnE_Map = new Map<Id, Decimal>();
            for(id gnh: GnHid_set){
                Decimal Amt = 0;
                for(ASI_TnE_ClaimDetail__c tne: TnEList){
                    if(GnHTnE_Map.get(gnh) == null){
                        GnHTnE_Map.put(gnh, Amt + tne.ASI_TnE_Receipt_Amount__c);
                    }else{
                        GnHTnE_Map.put(gnh, GnHTnE_Map.get(gnh) + tne.ASI_TnE_Receipt_Amount__c);
                    }
                }
            }
            
            // Get the latest A&P FOC unit Cost            
            Map<id, Decimal> SKUCost_Map = new Map<id, Decimal>(); 
            List<ASI_CRM_MY_SKUPriceCost__c> SKUCostList = [Select id, ASI_CRM_Item_Group__c, ASI_CRM_Cost__c from ASI_CRM_MY_SKUPriceCost__c where ASI_CRM_Item_Group__c = :SKUItmGrp_map.values() and ASI_CRM_Type__c = 'A&P FOC Unit Cost' order by ASI_CRM_EffectiveDate__c desc];
            for(id itmGrp : SKUItmGrp_map.values()){
                for(ASI_CRM_MY_SKUPriceCost__c pc: SKUCostList){
                    if(pc.ASI_CRM_Item_Group__c == itmGrp){
                        if(SKUCost_Map.get(itmGrp) == null){
                            SKUCost_Map.put(itmGrp, pc.ASI_CRM_Cost__c);
                        }
                    }
                }
            }
            List<ASI_FOC_Request_Item__c> extFOCList = [Select id, ASI_FOC_G_H_Request__c, ASI_CRM_TW_Amount__c from ASI_FOC_Request_Item__c where ASI_FOC_G_H_Request__c = :GnHid_set];
            for(POLineObj rpl: results){
                Decimal ReqItmAmt = rpl.ppl.ASI_FOC_Request_Quantity_Bottle__c * SKUCost_Map.get(SKUItmGrp_map.get(rpl.ppl.ASI_FOC_SKU__c));
                Decimal TotalGnHAmt = GnHMap.get(rpl.ppl.ASI_FOC_G_H_Request__c).ASI_GnH_Amount_per_Recipient__c * GnHMap.get(rpl.ppl.ASI_FOC_G_H_Request__c).ASI_GnH_PAX__c;
                Decimal TotalTnEAmt = GnHTnE_Map.get(rpl.ppl.ASI_FOC_G_H_Request__c) == null? 0: GnHTnE_Map.get(rpl.ppl.ASI_FOC_G_H_Request__c);
                Decimal extFOCAmt = 0;
                for(ASI_FOC_Request_Item__c ext: extFOCList){
                    if(ext.ASI_FOC_G_H_Request__c == rpl.ppl.ASI_FOC_G_H_Request__c && ext.id != rpl.ppl.id){
                        extFOCAmt += ext.ASI_CRM_TW_Amount__c;
                    }
                }
                if(!Test.isRunningTest() && ReqItmAmt > (TotalGnHAmt - TotalTnEAmt - extFOCAmt)){
                    rpl.ppl.ASI_FOC_G_H_Request__c.addError('FOC amount is exceed the Total G&H request Amount');
                    isBlanked = true;
                }
            }
        }
        // END - Linus
        
        //---------------Validation end (by Stella Sing) ------------------------------------------
        if (!isBlanked){
            List<ASI_FOC_Request_Item__c > savePOLineList = new List<ASI_FOC_Request_Item__c >();
            for (POLineObj rpl : results){
                    ASI_FOC_Request_Item__c ppl = new ASI_FOC_Request_Item__c();     
                    ppl = rpl.ppl;                   
                    savePOLineList.add(ppl);
                
                /*    
                if (rpl.selected){
                    
                    ASI_FOC_Request_Item__c ppl = new ASI_FOC_Request_Item__c();
                    
                    ppl = rpl.ppl;
                    
                    savePOLineList.add(ppl);
                }
                */
            }
            
            System.Savepoint sp = database.setSavepoint();
            Boolean isRedirect = false;
            
            try {
                upsert savePOLineList;
                if (del_results != null && del_results.size() >0){
                    delete del_results;
                    del_results.clear();
                }
                isRedirect = true;
            } catch (DmlException dmle) {
                database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,dmle.getMessage()));
            } catch (Exception e) {
                database.rollback(sp);
            }   
            
            return isRedirect; 
        }else{
            return false;
        }
    }
    
    public void APPLY() { //user clicked beginning
        
        for (POLineObj poO : results)
        {
            System.debug('poO.selected ' + poO.selected );
            if (poO.selected == true )
            {   
                /*
                if (rowObjAll.ASI_MFM_Customer_Name__c != null )
                    poO.ppl.ASI_MFM_Customer_Name__c = rowObjAll.ASI_MFM_Customer_Name__c;
                if (rowObjAll.ASI_MFM_List_Item_Description__c != null && rowObjAll.ASI_MFM_List_Item_Description__c != '')
                    poO.ppl.ASI_MFM_List_Item_Description__c = rowObjAll.ASI_MFM_List_Item_Description__c;
                if (SB_Name1 != null && SB_Name1 != '')
                    poO.ppl.ASI_MFM_Sub_brand_Code__c = getACnSBCode(SB_Name1, 'SB');
                if (AC_Code1 != null && AC_Code1 != '')
                    poO.ppl.ASI_MFM_A_C_Code__c = getACnSBCode(AC_Code1, 'AC');
                if (rowObjAll.ASI_MFM_G_L_Date__c != null )
                    poO.ppl.ASI_MFM_G_L_Date__c = rowObjAll.ASI_MFM_G_L_Date__c;
                */
            }
        }
    }
    
    //Michael Edit 2019/07/22
    public PageReference DELETESELECTED() { //user clicked beginning
        del_results = new List<ASI_FOC_Request_Item__c>();
        List<POLineObj> temp_results = new List<POLineObj>();
        Integer del_count=0;
        for (POLineObj rpl : results){
            if (rpl.selected != true )
            {
                if( rpl.ppl.id != null)
                {
                    del_results.add(rpl.ppl);
                    del_count++;
                }                
            } else {
                temp_results.add(rpl);
            }
        }
        
        if(del_count>0){
            integer i=0;
            for(POLineObj rpl :temp_results)
            {
                rpl.seqNO = i;
                i=i+1;
            }

            results.clear();
            results=temp_results;
            system.debug('delete items list: ' + results);
        }
        //if (del_results!= null && del_results.size() > 0) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'Please click Save to confirm the deletion. There are ' + del_results.size() + ' records to be deleted.'));
        //}
       
         return null;
    }
    public PageReference CLONESELECTED() { //user clicked beginning
        POLineObj selected_rpl;
        Boolean isSelected = false;
        List<POLineObj > cloneList = new List<POLineObj >();
        integer CurrentSeq = results.size();
         for (POLineObj rpl : results){
            if (rpl.selected == true)
            {
                CurrentSeq++;
                selected_rpl = new POLineObj();
                
                selected_rpl.selected = true;
                selected_rpl.ppl = new ASI_FOC_Request_Item__c();
                selected_rpl.ppl = rpl.ppl.clone(false,false,false,false);
               /*
                selected_rpl.ppl.ASI_CRM_Plan_Line_Item__c = rpl.ppl.ASI_CRM_Plan_Line_Item__c;               
                selected_rpl.ppl.ASI_FOC_SKU__c = rpl.ppl.ASI_FOC_SKU__c;
                selected_rpl.ppl.ASI_FOC_Request_Quantity_Bottle__c = rpl.ppl.ASI_FOC_Request_Quantity_Bottle__c;
                selected_rpl.ppl.ASI_CRM_Target_Outlet__c = rpl.ppl.ASI_CRM_Target_Outlet__c;
                selected_rpl.ppl.ASI_CRM_Delivery_To__c = rpl.ppl.ASI_CRM_Delivery_To__c;
                selected_rpl.ppl.ASI_CRM_Reimbursement__c = rpl.ppl.ASI_CRM_Reimbursement__c;
                selected_rpl.ppl.ASI_CRM_Delivery_Address__c = rpl.ppl.ASI_CRM_Delivery_Address__c;
                selected_rpl.ppl.ASI_CRM_Delivery_Tel__c = rpl.ppl.ASI_CRM_Delivery_Tel__c;
                selected_rpl.ppl.ASI_CRM_Receiver__c = rpl.ppl.ASI_CRM_Receiver__c;
                selected_rpl.ppl.ASI_FOC_Remark__c = rpl.ppl.ASI_FOC_Remark__c;
                selected_rpl.ppl.ASI_FOC_Request_Order__c = rpl.ppl.ASI_FOC_Request_Order__c;
                selected_rpl.ppl.recordtypeid = rpl.ppl.recordtypeid ;
                */
                selected_rpl.seqNO = CurrentSeq;
                cloneList.add(selected_rpl);

            }
         }
         results.addall(cloneList);
        
         return null;
    }
    public void ADDNEW() { //user clicked beginning
        // Howard@introv 19122019 copy detail to Addnew (ASI_CRM_Receiver__c, ASI_FOC_Delivery_Remarks__c, ASI_CRM_SG_Delivery_Instructions__c)	 
        if (results != null && results.size() > 0){
            POLineObj poO = new POLineObj();
            poO.ppl = new ASI_FOC_Request_Item__c();
            poO.ppl.ASI_FOC_Request_Order__c = PO.id;
            poO.ppl.ASI_CRM_Receiver__c = PO.ASI_CRM_Receiver__c;
            poO.ppl.ASI_FOC_Remark__c = PO.ASI_FOC_Delivery_Remarks__c;
            poO.ppl.ASI_CRM_Delivery_Instruction__c = PO.ASI_CRM_SG_Delivery_Instructions__c;
            poO.ppl.ASI_CRM_Delivery_To__c = PO.ASI_CRM_Delivery_To__c;
			poO.ppl.ASI_CRM_Target_Outlet__c = PO.ASI_CRM_Target_Outlet__c;
            poO.selected = true;
            poO.seqNO = results.size();
            system.debug('ADDNEW PO.RecordTypeId '+ PO.RecordTypeId);
            //if(PO.RecordTypeId.equals(posm_typeId) ) {
                
                poO.ppl.recordtypeid = posm_item_typeId;
                system.debug('ADDNEW poO.ppl.recordtypeid (posm) '+ poO.ppl.recordtypeid); 
            //} else {
              //  poO.ppl.recordtypeid = foc_item_typeId;
                //system.debug('ADDNEW poO.ppl.recordtypeid (foc) '+ poO.ppl.recordtypeid); 
            //}
            //poO.ppl.recordtypeid = TRRecTypeID ;
            results.add(0,poO);   
        }else{
            results = new List<POLineObj>();
            POLineObj poO = new POLineObj();
            poO.ppl = new ASI_FOC_Request_Item__c();
            poO.ppl.ASI_FOC_Request_Order__c = PO.id;
            poO.selected = true;
            system.debug('ADDNEW PO.RecordTypeId '+ PO.RecordTypeId);
            poO.ppl.ASI_CRM_Receiver__c = PO.ASI_CRM_Receiver__c;
            poO.ppl.ASI_FOC_Remark__c = PO.ASI_FOC_Delivery_Remarks__c;
            poO.ppl.ASI_CRM_Delivery_Instruction__c = PO.ASI_CRM_SG_Delivery_Instructions__c;
            poO.ppl.ASI_FOC_Request_Order__c = po.Id;
            poO.ppl.ASI_CRM_Delivery_To__c = PO.ASI_CRM_Delivery_To__c;
			poO.ppl.ASI_CRM_Target_Outlet__c = PO.ASI_CRM_Target_Outlet__c;
            poO.seqNO = 0;
            //if(PO.RecordTypeId.equals(posm_typeId)) {
                poO.ppl.recordtypeid = posm_item_typeId;
                system.debug('ADDNEW poO.ppl.recordtypeid (posm) '+ poO.ppl.recordtypeid); 
            //} else {
            //    poO.ppl.recordtypeid = foc_item_typeId;
            //    system.debug('ADDNEW poO.ppl.recordtypeid (foc) '+ poO.ppl.recordtypeid); 
            //}
            //poO.ppl.recordtypeid = TRRecTypeID ;
            results.add(poO);   
        }
    }
    
    Public PageReference cacnel(){
        
        return new pageReference('/' + apexpages.currentPage().getParameters().get('id'));
    }
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        if(!Test.isRunningTest()) searchCurrentPage();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= pageSize;
        if(!Test.isRunningTest()) searchCurrentPage();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += pageSize;
        if(counter >= 1000)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (1000 records) reached! Please narrow down your search range.'));
            return null;
        }
        if(!Test.isRunningTest()) searchCurrentPage();
        return null;
    }
    
    public PageReference End() { //user clicked end  
        counter = totalSize - Math.mod(totalSize, pageSize);
        if(counter >= 1000)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Maximum no. of search result (1000 records) reached! Please narrow down your search range.'));
            return null;
        }
        if(!Test.isRunningTest()) searchCurrentPage();
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) 
            disablePrevious = false;
        else 
            disablePrevious = true;
        return disablePrevious;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + pageSize < totalSize) 
            disableNext = false; 
        else 
            disableNext = true;
        return disableNext;
    }

    public void onchangeDeliveryTo(){
        for(POLineObj pol :results)
        {
            if(pol.seqNO == CurrentSeqNO)
            {
                if(pol.ppl.ASI_CRM_Delivery_To__c != null)
                {
                    Map<Id, Account> mapDeliveryToAcc = new Map<Id, Account>();
                    for(Account acc : [SELECT Id, ASI_HK_CRM_Address__c, RecordType.developername, ASI_MFM_Address_Line_4__c,  Phone, (Select Id, ASI_CRM_TW_Warehouse_Address__c From ASI_CRM_Accounts_Additional_Fields__r) FROM Account WHERE Id =: pol.ppl.ASI_CRM_Delivery_To__c]){
                        mapDeliveryToAcc.put(acc.id, acc);
                    }
                    if(mapDeliveryToAcc != NULL && mapDeliveryToAcc.size() > 0){
                        Account tempacc = mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c);
                        if(!tempacc.RecordType.developername.contains('ASI_MFM_TW_Supplier'))
                        {
                            //if(mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c) != null && mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r.size()>0) pol.ppl.ASI_CRM_Delivery_Address__c = mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_Warehouse_Address__c;
                            if(mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r.size()>0)
                            {
                                if(mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_Warehouse_Address__c != null)
                                {
                                    pol.ppl.ASI_CRM_Delivery_Address__c = mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c).ASI_CRM_Accounts_Additional_Fields__r[0].ASI_CRM_TW_Warehouse_Address__c;
                                }
                                else 
                                {
                                    pol.ppl.ASI_CRM_Delivery_Address__c = mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Address__c;
                                }
                            }
                            else {
                                pol.ppl.ASI_CRM_Delivery_Address__c = mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c).ASI_HK_CRM_Address__c;
                            }
                            pol.ppl.ASI_CRM_Delivery_Tel__c = '';
                            pol.ppl.ASI_CRM_Receiver__c = '';
                            pol.ppl.ASI_CRM_Delivery_Instruction__c = '';
                        }
                        else 
                        {
                            pol.ppl.ASI_CRM_Delivery_Address__c = tempacc.ASI_MFM_Address_Line_4__c;
                        }
                        pol.ppl.ASI_CRM_Delivery_Tel__c = mapDeliveryToAcc.get(pol.ppl.ASI_CRM_Delivery_To__c).Phone;
                    }
                }
                else 
                {
                    pol.ppl.ASI_CRM_Delivery_Address__c = '';
                    pol.ppl.ASI_CRM_Delivery_Tel__c = '';
                    pol.ppl.ASI_CRM_Receiver__c = '';
                    pol.ppl.ASI_CRM_Delivery_Instruction__c = '';
                }

                list<Account> acc_L = new list<Account>();
                acc_L = [select id, name, (select firstname, lastname from contacts where ASI_HK_CRM_Main_Contact__c = true limit 1), (select id, ASI_TH_CRM_OperatingHoursFrom__c, ASI_TH_CRM_OperatingHoursTo__c, ASI_CRM_Account__c from ASI_CRM_Accounts_Additional_Fields__r) from account where id =: pol.ppl.ASI_CRM_Delivery_To__c];
                if(acc_L.size() > 0)
                {
                    if(acc_L[0].contacts.size() > 0)
                    {
                        pol.ppl.ASI_CRM_Receiver__c = (acc_L[0].contacts[0].LastName != null ? acc_L[0].contacts[0].LastName : '') + ' ' + (acc_L[0].contacts[0].FirstName != null ? acc_L[0].contacts[0].FirstName : '');
                    }

                    if(acc_L[0].ASI_CRM_Accounts_Additional_Fields__r.size()>0)
                    {
                        if(pol.ppl.ASI_CRM_Delivery_Instruction__c == null || pol.ppl.ASI_CRM_Delivery_Instruction__c == '')
                        {
                            string DI = '';
                            if(acc_L[0].ASI_CRM_Accounts_Additional_Fields__r[0].ASI_TH_CRM_OperatingHoursFrom__c != null)
                            {
                                DI += acc_L[0].ASI_CRM_Accounts_Additional_Fields__r[0].ASI_TH_CRM_OperatingHoursFrom__c;
                            }
                            if(acc_L[0].ASI_CRM_Accounts_Additional_Fields__r[0].ASI_TH_CRM_OperatingHoursTo__c != null)
                            {
                                DI += ' - ' + acc_L[0].ASI_CRM_Accounts_Additional_Fields__r[0].ASI_TH_CRM_OperatingHoursTo__c;
                            }
                            pol.ppl.ASI_CRM_Delivery_Instruction__c = DI;
                        }
                    }
                }
            }
        }
    }
    

    
}