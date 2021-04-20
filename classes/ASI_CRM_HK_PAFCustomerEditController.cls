public with sharing class ASI_CRM_HK_PAFCustomerEditController {
    public ApexPages.StandardController standardController {get;set;}
    
    public ASI_HK_CRM_Pre_Approval_Form__c Header {get;set;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    public Map<String, tmpAccount> allChannelAccMap {get;set;}
    public Map<String, tmpPAFCustomer> allPAFCustomerMap {get;set;}{ allPAFCustomerMap = new Map<String, tmpPAFCustomer>();}
    
    public List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();}
    
    public boolean SaveSuccess {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public boolean NotAllowEdit {get;set;} //Flag to able/disable editing
    public String Msg {get;set;} 
    set<ID> AccountID_set {get; set;}
    private static final Set<String> STATUS_NOT_ALLOW_EDIT = new Set<String>{
        'FM Approved'
        , 'FD Approved'
        , 'MD Final'
    };
    
    public Class tmpPAFCustomer{
        public ASI_CRM_HK_Pre_Approval_Form_Customer__c PAFC {get;set;}
        public id CustomerID {get; set;}
        public string CustomerName {get; set;}
        public string LocalChannel {get; set;}
        public Decimal CreditLimit {get; set;}
        public string PADA {get; set;}
        public Boolean GenPriceSet {get; set;}
        public Boolean Checked {get; set;}
        public string parentID {get;set;} //20160628, edited by Leo
        public string parentName {get;set;} //20160628, edited by Leo
    }
    
    public Class tmpAccount{
        public Account Acc {get;set;}
        public id AccountID {get; set;}
        public string AccountName {get; set;}
        public string LocalChannel {get; set;}
        public Decimal CreditLimit {get; set;}
        public string PADA {get; set;}
        public Boolean Checked {get; set;}
        public string parentID {get;set;} //20160628, edited by Leo
        public string parentName {get;set;} //20160628, edited by Leo
    }
    
    // Define the constructor
    public ASI_CRM_HK_PAFCustomerEditController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.Header = (ASI_HK_CRM_Pre_Approval_Form__c) this.standardController.getRecord();
        if(this.Header !=null && this.Header.Id !=null){
            for(ASI_HK_CRM_Pre_Approval_Form__c paf : [Select id, Name, ASI_HK_CRM_PAF_Status__c
                                                       , ASI_HK_CRM_PAF_Start_Date__c
                                                       , ASI_HK_CRM_PAF_End_Date__c
                                                       , ASI_HK_CRM_PAF_Customer__c
                                                       , ASI_HK_CRM_PAF_Customer__r.Name
                                                       , ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c
                                                       , ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c 
                                                       FROM ASI_HK_CRM_Pre_Approval_Form__c 
                                                       where Id =: this.Header.Id limit 1]){
                this.Header = paf;
                this.NotAllowEdit = STATUS_NOT_ALLOW_EDIT.contains(paf.ASI_HK_CRM_PAF_Status__c);
            }
        }
    }
    
    // Initialize
    public void init() {
        SaveSuccess=false;
        if (this.Header.ASI_HK_CRM_PAF_Customer__c == null)
            return;
        if(this.Header !=null && this.Header.Id !=null){
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustomerList =[select id
                                                                             , name
                                                                             , ASI_CRM_PA_DA__c
                                                                             , ASI_CRM_HK_Customer__c
                                                                             , ASI_CRM_HK_Customer__r.Name
                                                                             , ASI_CRM_HK_Customer__r.ASI_HK_CRM_Local_Channel__c
                                                                             , ASI_CRM_HK_Customer__r.ASI_HK_CRM_Credit_Limit__c
                                                                             , ASI_CRM_HK_Customer__r.ParentId //20160628, edited by Leo
                                                                             , ASI_CRM_HK_Customer__r.Parent.Name //20160628, edited by Leo
                                                                             from ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                                                                             where ASI_CRM_HK_Pre_Approval_Form__c=:Header.id
                                                                             Order by ASI_CRM_PA_DA__c, ASI_CRM_HK_Customer__r.Name];
            AccountID_set = new set<ID>();
            if(!PAFCustomerList.isEmpty()){
                for(ASI_CRM_HK_Pre_Approval_Form_Customer__c PAFCustomer : PAFCustomerList){
                    String CustomerId = (String)(PAFCustomer.ASI_CRM_HK_Customer__c);
                    if(!allPAFCustomerMap.containsKey(CustomerId)){
                        tmpPAFCustomer tmp = new tmpPAFCustomer();
                        tmp.PAFC = PAFCustomer;
                        tmp.CustomerID = PAFCustomer.ASI_CRM_HK_Customer__c;
                        tmp.CustomerName = PAFCustomer.ASI_CRM_HK_Customer__r.Name;
                        tmp.LocalChannel = PAFCustomer.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Local_Channel__c;
                        tmp.CreditLimit = PAFCustomer.ASI_CRM_HK_Customer__r.ASI_HK_CRM_Credit_Limit__c;
                        tmp.PADA = PAFCustomer.ASI_CRM_PA_DA__c;
                        //20160628, edited by Leo
                        if(tmp.PADA == 'PA')
                        {
                            tmp.parentID = PAFCustomer.ASI_CRM_HK_Customer__r.ParentId;
                            tmp.parentName = PAFCustomer.ASI_CRM_HK_Customer__r.Parent.Name;
                        }
                        else
                        {
                            tmp.parentID = null;
                            tmp.parentName = '';
                        }
                        //20160628, edited by Leo
                        tmp.GenPriceSet = false;
						tmp.Checked = False;
                        allPAFCustomerMap.put(CustomerId, tmp);
                        AccountID_set.add(PAFCustomer.ASI_CRM_HK_Customer__c);
                    }
                    
                }    
            }
            getAccount();            
        }      
    }
    
    public void getAccount(){
        if (this.Header.ASI_HK_CRM_PAF_Customer__c == null)
            return;
        string PADA = Apexpages.currentPage().getParameters().get('PADA');
        string filter = '';
        string PAfilter = '';
        string channel =  Header.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c;
        string custType = Header.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c;
        String CustName = Header.ASI_HK_CRM_PAF_Customer__r.Name;
        String CustId = Header.ASI_HK_CRM_PAF_Customer__c;
        if (PADA == 'PA') {
            filter = ' AND ParentId = null';
        } 
        else if (PADA == 'DA') {
            filter = ' AND ParentId != null';
        }
        
        if (!CustName.contains('OUTLET_'))
        {
            //20160331, added by Leo
            if(CustName.contains('\''))
            {
                Integer index = CustName.indexOf('\'');
                String temp01 = CustName.subString(0, index);
                String temp02 = CustName.substring(index);
                temp01 += '\\';
                CustName = temp01+temp02;
            }//20160331, added by Leo
            PAfilter = ' AND (Name = \'' + CustName + '\' Or ParentId = \'' + CustId + '\')';
        }
            
        allChannelAccMap = new Map<String, tmpAccount>();
        //string soql = 'select id, name, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Credit_Limit__c, ParentId from Account where (ASI_HK_CRM_Channel__c =: channel Or ASI_HK_CRM_Customer_Type__c =: custType) and id not in: AccountID_set AND ASI_HK_CRM_Status__c = \'Active\' ' + filter + PAfilter;// + 'Order by ParentId ASC, Name'; 
        string soql = 'select id, name, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Credit_Limit__c, ParentId, Parent.Name from Account where (ASI_HK_CRM_Channel__c =: channel) and id not in: AccountID_set AND ASI_HK_CRM_Status__c = \'Active\' ' + filter + PAfilter;// + 'Order by ParentId ASC, Name';
        //List<Account> ChannelAccount = [select id, name, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Credit_Limit__c, ParentId from Account where ASI_HK_CRM_Channel__c =: Header.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c and id not in: AccountID_set AND ASI_HK_CRM_Status__c = 'Active' :filter];
        List<Account> ChannelAccount = database.query(soql);
        system.debug(soql);
        if(!ChannelAccount.isEmpty()){   
            for(Account ChannelAcc:ChannelAccount){ 
                tmpAccount tmp = new tmpAccount();
                tmp.Acc = ChannelAcc;
                tmp.AccountID = ChannelAcc.id;
                tmp.AccountName = ChannelAcc.Name;
                tmp.LocalChannel = ChannelAcc.ASI_HK_CRM_Local_Channel__c;
                tmp.CreditLimit = ChannelAcc.ASI_HK_CRM_Credit_Limit__c;
                if(ChannelAcc.ParentId == null){
                    tmp.PADA = 'PA';
                    tmp.parentName = '';
                    tmp.parentID = null;
                } else {
                    tmp.PADA = 'DA';
                    tmp.parentID = ChannelAcc.ParentId;
                    tmp.parentName = ChannelAcc.Parent.Name;
                }
                tmp.Checked = False;    
                String Accid=(String)(ChannelAcc.id);
                if(!allChannelAccMap.containsKey(Accid)){
                    allChannelAccMap.put(Accid,tmp);
                }
            }
        }
        
    }
    
    // 1. Remove this Payment Line from the upper table 
    public void removeLine() {
        if (this.Header.ASI_HK_CRM_PAF_Customer__c == null)
            return;
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        if(allPAFCustomerMap.containsKey(param_Id) && !allPAFCustomerMap.isEmpty() ){      
            tmpAccount tmp = new tmpAccount();
            String AccID = (String)allPAFCustomerMap.get(param_Id).CustomerID;
            tmp.Acc =  new Account(id = allPAFCustomerMap.get(param_Id).PAFC.ASI_CRM_HK_Customer__c, Name = allPAFCustomerMap.get(param_Id).CustomerName);
            tmp.AccountName = allPAFCustomerMap.get(param_Id).CustomerName;
            tmp.LocalChannel = allPAFCustomerMap.get(param_Id).LocalChannel;
            tmp.CreditLimit = allPAFCustomerMap.get(param_Id).CreditLimit;
            tmp.PADA = allPAFCustomerMap.get(param_Id).PADA;
            tmp.Checked = False;
            tmp.parentID = allPAFCustomerMap.get(param_Id).parentID; //20160628, edited by Leo
            tmp.parentName = allPAFCustomerMap.get(param_Id).parentName; //20160628, edited by Leo
            allChannelAccMap.put(AccID, tmp);
            ASI_CRM_HK_Pre_Approval_Form_Customer__c delTarget = allPAFCustomerMap.get(param_Id).PAFC;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allPAFCustomerMap.remove(param_Id);   
        }
    }
    
    public void RemoveAllLinetems(){
        if (this.Header.ASI_HK_CRM_PAF_Customer__c == null)
            return;
        SaveSuccess=false;
        UpsertPermission=true;
        
        Set<String> keySet = new Set<String>();
        keyset = allPAFCustomerMap.keySet();
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        
        if(keyset.size() > 0) {
            for(string key : keyset) {
                tmpAccount tmp = new tmpAccount();
                String AccID = (String)allPAFCustomerMap.get(key).CustomerID;
                tmp.Acc =  new Account(id = allPAFCustomerMap.get(key).PAFC.ASI_CRM_HK_Customer__c, Name = allPAFCustomerMap.get(key).CustomerName);
                tmp.AccountName = allPAFCustomerMap.get(key).CustomerName;
                tmp.LocalChannel = allPAFCustomerMap.get(key).LocalChannel;
                tmp.CreditLimit = allPAFCustomerMap.get(key).CreditLimit;
                tmp.PADA = allPAFCustomerMap.get(key).PADA;
                tmp.Checked = False;
                tmp.parentID = allPAFCustomerMap.get(key).parentID; //20160628, edited by Leo
                tmp.parentName = allPAFCustomerMap.get(key).parentName; //20160628, edited by Leo
                allChannelAccMap.put(AccID, tmp);
                ASI_CRM_HK_Pre_Approval_Form_Customer__c delTarget = allPAFCustomerMap.get(key).PAFC;
                if(delTarget.id != null){
                    deleteLineItemList.add(delTarget);
                }
                allPAFCustomerMap.remove(key);
            }
        }  
    }
    
    public void RemoveSelectedLinetems(){
        if (this.Header.ASI_HK_CRM_PAF_Customer__c == null)
            return;
        SaveSuccess=false;
        UpsertPermission=true;
        
        Set<String> keySet = new Set<String>();
        keyset = allPAFCustomerMap.keySet();
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        
        if(keyset.size() > 0) {
            for(string key : keyset) {
                if(allPAFCustomerMap.get(key).Checked) {
                    tmpAccount tmp = new tmpAccount();
                    String AccID = (String)allPAFCustomerMap.get(key).CustomerID;
                    tmp.Acc =  new Account(id = allPAFCustomerMap.get(key).PAFC.ASI_CRM_HK_Customer__c, Name = allPAFCustomerMap.get(key).CustomerName);
                    tmp.AccountID = allPAFCustomerMap.get(key).CustomerID;
                    tmp.AccountName = allPAFCustomerMap.get(key).CustomerName;
                    tmp.LocalChannel = allPAFCustomerMap.get(key).LocalChannel;
                    tmp.CreditLimit = allPAFCustomerMap.get(key).CreditLimit;
                    tmp.PADA = allPAFCustomerMap.get(key).PADA;
                    tmp.Checked = False;
                    tmp.parentID = allPAFCustomerMap.get(key).parentID; //20160628, edited by Leo
                    tmp.parentName = allPAFCustomerMap.get(key).parentName; //20160628, edited by Leo
                    allChannelAccMap.put(AccID, tmp);
                    ASI_CRM_HK_Pre_Approval_Form_Customer__c delTarget = allPAFCustomerMap.get(key).PAFC;
                    if(delTarget.id != null){
                        deleteLineItemList.add(delTarget);
                    }
                    allPAFCustomerMap.remove(key);
                }
            }
        }  
    }

    // 1. Add PO Line, 
    // 2. convert into Payment line
    // 3. Remove this PO Line from bottom table 
    public void addLineItem(){
        if (this.Header.ASI_HK_CRM_PAF_Customer__c == null)
            return;
        SaveSuccess=false;
        UpsertPermission=true;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_POLINE_SOURCE_ITEM_ID');
        //String KeyId;
        if(allChannelAccMap.containsKey(param_SourceItemId)){
            tmpPAFCustomer temp = new tmpPAFCustomer();
            string newIDCounter = newCounterCreatorLine();
            temp.PAFC = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
            temp.PAFC.ASI_CRM_HK_Pre_Approval_Form__c = Header.id;
			temp.PAFC.ASI_CRM_HK_Customer__c = param_SourceItemId;
            temp.CustomerID = allChannelAccMap.get(param_SourceItemId).AccountID;
            temp.CustomerName = allChannelAccMap.get(param_SourceItemId).AccountName;
            temp.LocalChannel = allChannelAccMap.get(param_SourceItemId).LocalChannel;
            temp.CreditLimit = allChannelAccMap.get(param_SourceItemId).CreditLimit;
            temp.PADA = allChannelAccMap.get(param_SourceItemId).PADA;
            temp.Checked = False;
            temp.parentID = allChannelAccMap.get(param_SourceItemId).parentID; //20160628, edited by Leo
            temp.parentName = allChannelAccMap.get(param_SourceItemId).parentName; //20160628, edited by Leo
            allPAFCustomerMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            allChannelAccMap.remove(param_SourceItemId);
        }
        
    }
    
    public void AddAllLinetems(){
        if (this.Header.ASI_HK_CRM_PAF_Customer__c == null)
            return;
        SaveSuccess=false;
        UpsertPermission=true;
        
        Set<String> keySet = new Set<String>();
        keyset = allChannelAccMap.keySet();

        if (keyset.size() > 0) {
            for (String key : keyset) {
                tmpPAFCustomer temp = new tmpPAFCustomer();
                string newIDCounter = newCounterCreatorLine();
                temp.PAFC = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
                temp.PAFC.ASI_CRM_HK_Pre_Approval_Form__c = Header.id;
                temp.PAFC.ASI_CRM_HK_Customer__c = key;
                temp.CustomerID = allChannelAccMap.get(key).AccountId;
                temp.CustomerName = allChannelAccMap.get(key).AccountName;
                temp.LocalChannel = allChannelAccMap.get(key).LocalChannel;
                temp.CreditLimit = allChannelAccMap.get(key).CreditLimit;
                temp.PADA = allChannelAccMap.get(key).PADA;
                temp.Checked = False;
                temp.parentID = allChannelAccMap.get(key).parentID; //20160628, edited by Leo
                temp.parentName = allChannelAccMap.get(key).parentName; //20160628, edited by Leo
                allPAFCustomerMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
                allChannelAccMap.remove(key);
            }
        } 
    }
    
    public void AddSelectedLinetems(){
        if (this.Header.ASI_HK_CRM_PAF_Customer__c == null)
            return;
        SaveSuccess=false;
        UpsertPermission=true;
        
        Set<String> keySet = new Set<String>();
        keyset = allChannelAccMap.keySet();

        if (keyset.size() > 0) {
            for (String key : keyset) {
                if (allChannelAccMap.get(key).Checked) {
                    tmpPAFCustomer temp = new tmpPAFCustomer();
                    string newIDCounter = newCounterCreatorLine();
                    temp.PAFC = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
                    temp.PAFC.ASI_CRM_HK_Pre_Approval_Form__c = Header.id;
                    temp.PAFC.ASI_CRM_HK_Customer__c = key;
                    temp.CustomerID = allChannelAccMap.get(key).AccountId;
                    temp.CustomerName = allChannelAccMap.get(key).AccountName;
                    temp.LocalChannel = allChannelAccMap.get(key).LocalChannel;
                    temp.PADA = allChannelAccMap.get(key).PADA;
                    temp.CreditLimit = allChannelAccMap.get(key).CreditLimit;
                    temp.parentID = allChannelAccMap.get(key).parentID; //20160628, edited by Leo
                    temp.parentName = allChannelAccMap.get(key).parentName; //20160628, edited by Leo
                    allPAFCustomerMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
                    allChannelAccMap.remove(key);
                }
            }
        } 
    }
    
    public PageReference saveLinetems(){
        
        onCommitted();
        PageReference pageRef ;
        if(UpsertPermission){
            pageRef=new PageReference('/'+Header.id);
        }else{
            pageRef=null;
        }
        return pageRef;
    }
    
    public void onCommitted(){
        
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        UpsertPermission=true;
        Set<id> ParentIdSet = new Set<id>();
        Set<id> PAFC = new Set<id>();
        List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> upsertTargetList = new List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
		List<Account> tmpacc = new List<Account>();
        if(UpsertPermission){
            for(String key : allPAFCustomerMap.keySet()){
                PAFC.add(allPAFCustomerMap.get(key).PAFC.ASI_CRM_HK_Customer__c);
                allPAFCustomerMap.get(key).PAFC.ASI_CRM_Generate_Price_Set__c = allPAFCustomerMap.get(key).GenPriceSet;
                upsertTargetList.add(allPAFCustomerMap.get(key).PAFC);
            }
            tmpacc = [SELECT id, ParentId from Account WHERE id IN:PAFC];
            for (Account acc: tmpacc) {
                if (acc.ParentId != null) {
                    ParentIdSet.add(acc.ParentId);
                }
            }
            for (id insertCusId: PAFC) {
                if (ParentIdSet.contains(insertCusId)) {
                    UpsertPermission = false;
                    Msg = 'You cannot add PA and DA of same customer at the same time';
                }
            }
            
        }
        
        try{
            if(UpsertPermission){
                if(deleteLineItemList.size()>0) {
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteLineItemList.clear();
                }
                if(upsertTargetList.size()>0){
                    upsertTarget = Database.upsert(upsertTargetList);
                }
                SaveSuccess=true;
                Msg = '';
            }else{
                SaveSuccess=false;
            }
            
        }catch(Exception e){
            UpsertPermission = false;
            Msg = 'Save Error:' + e.getMessage();
        }
        
    }
    
    public String newCounterCreatorLine() {      
        String idNew;        
        IF(LINE_ITEM_NEWRECORD_COUNTER == null) {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            LINE_ITEM_NEWRECORD_COUNTER+=1;
        }       
        String zParser = '';
        Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;      
        if(LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
        }       
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
        
    }
    
    
    public PageReference cancel() {    
        Pagereference ref;
        ref = new PageReference('/'+Header.id);
        ref.setRedirect(true);
        return ref;		
    }
}