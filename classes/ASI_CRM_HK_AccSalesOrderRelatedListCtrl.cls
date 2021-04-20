public without sharing class ASI_CRM_HK_AccSalesOrderRelatedListCtrl {
    public ApexPages.StandardController standardController {get;set;}
    public Account Header {get;set;}
    public id AccountID {get;Set;}
    private String soql {get;set;} 
    Transient List<ASI_HK_CRM_Sales_Order__c> lineItem;
    Transient List<ASI_HK_CRM_Sales_Order_Item__c> SOItemList;
    Transient Map<string, List<ASI_HK_CRM_Sales_Order_Item__c>> SOLinesMap;
    
    public List<ASI_HK_CRM_Sales_Order__c> getLineItem(){
        return lineItem;
    }
        
    //public List<ASI_HK_CRM_Sales_Order__c> lineItem {get;set;}
    //public List<ASI_HK_CRM_Sales_Order_Item__c> SOItemList {get;set;}
    //public Map<string, List<ASI_HK_CRM_Sales_Order_Item__c>> SOLinesMap {set;get;}{ SOLinesMap = new Map<string, List<ASI_HK_CRM_Sales_Order_Item__c>>(); }
    public String mapSOlineJSON {get{return JSON.serialize(SOLinesMap);}}
    
    public Class interimData{
        public ASI_HK_CRM_Sales_Order__c so {get; set;}
        public List<ASI_HK_CRM_Sales_Order_Item__c> sol{set;get;} //related so line 
    }
    public List<interimData> soitems {set;get;}{soitems = new List<interimData>();}
    
    public ASI_CRM_HK_AccSalesOrderRelatedListCtrl(ApexPages.StandardController controller){
        this.standardController = controller;
        this.Header = (Account) this.standardController.getRecord();   
        
        SOLinesMap = new Map<string, List<ASI_HK_CRM_Sales_Order_Item__c>>();
        
        if(this.Header !=null && this.Header.Id !=null){
            for(Account outlet : [Select id, Name, Parent.Id FROM Account where Id =: this.Header.Id limit 1]){
                this.Header = outlet;
                system.debug('----Header: '+this.Header);
            }  
            init(); 
        } else {system.debug('Null Header');}
    }
    
    public Set<id> soSet {set; get;}
    public void init(){
        soSet = new set<id>();
        AccountID = this.header.id;
        List<ASI_HK_CRM_Sales_Order_Item__c> SOLines = new List<ASI_HK_CRM_Sales_Order_Item__c>();
       /* SOLines = [select id, ASI_HK_CRM_Sales_Order__c from ASI_HK_CRM_Sales_Order_Item__c WHERE ASI_CRM_HK_Customer__c = :header.id];
        for (ASI_HK_CRM_Sales_Order_Item__c pol : SOLines){
            soSet.add(pol.ASI_HK_CRM_Sales_Order__c);
        }*/
        system.debug('SO SET::::::::::::::::::::::' +soSet);
        soql = 'Select ' + 
                    '(select id' +
                    ', name ' +
                    ', ASI_HK_CRM_Sub_brand__c' + 
                    ', ASI_HK_CRM_SKU_Code__c' +
                    ', ASI_HK_CRM_SKU__r.Name' +
                    ', ASI_HK_CRM_Quantity__c ' + 
                    ', ASI_HK_CRM_Cancel_Qty__c ' + 
                    ', ASI_HK_CRM_Price__c' + 
                    ', ASI_HK_CRM_Amount__c' + 
                ', ASI_HK_CRM_Sales_Order__c' +
                ' from ASI_HK_CRM_Sales_Order_Request_Items__r) ,' +
              ' id' +
              ', Name'+
              ', ASI_HK_CRM_JDE_Order_Type_Code__c' +
              ', ASI_HK_CRM_JDE_Order_No__c' +
              ', ASI_HK_CRM_Order_Date__c' +
              ', CreatedBy.Name' +
              ', ASI_HK_CRM_Delivery_Date__c' +
              ', ASI_HK_CRM_Urgent_Order__c' +
              ', ASI_HK_CRM_Order_Status_Name__c' +
              ' From ASI_HK_CRM_Sales_Order__c' +
                ' where ASI_HK_CRM_Customer_DA__c = :AccountID'+
              ' Order by ASI_HK_CRM_Order_Date__c DESC limit 50'
              //' WHERE id IN :soSet' 
             ;
        system.debug(soql);
        runQuery();
    }
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
            }            
            setCon.setPageSize(1000);//setCon.setPageSize(50); 20160823 Ben @ Elufa
            return setCon;
        }
        set;
    }
    // Initialize setCon and return a list of record    
     
    public List<ASI_HK_CRM_Sales_Order__c> getSOHeaders() {
         return (List<ASI_HK_CRM_Sales_Order__c>) setCon.getRecords();
    }
    
    public void runQuery(){
        LineItem = new List<ASI_HK_CRM_Sales_Order__c>();
        SOItemList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        
        LineItem = getSOHeaders();
        system.debug('SO No of records::::::::::::::::::::::::::'+LineItem.size());
        
        List<ASI_HK_CRM_Sales_Order__c> SOTEST= NEW list<ASI_HK_CRM_Sales_Order__c>();
        
        for(ASI_HK_CRM_Sales_Order__c sos:LineItem ){
            // POTEST.add(pos);
            List<ASI_HK_CRM_Sales_Order_Item__c> Templine= new List<ASI_HK_CRM_Sales_Order_Item__c>();
            interimData temp= new interimData();
            temp.so=sos;
            
            try{
                SOItemList = sos.getSObjects('ASI_HK_CRM_Sales_Order_Request_Items__r'); 
               
                    
                //if (SOItemList.size() > 0){
                    for(ASI_HK_CRM_Sales_Order_Item__c sol:SOItemList){ 
                        if(sol.ASI_HK_CRM_Sales_Order__c == sos.id){
                            Templine.add(sol);
                        }
                    }
                //}
                
                temp.sol=Templine;
                SOLinesMap.put(sos.name, Templine);
                soitems.add(temp);
            }catch (exception e){}
        }
    }
    
    public PageReference NewSOHK(){
        //https://pernod-ricard--asisb5conf.cs7.my.salesforce.com/
        //setup/ui/recordtypeselect.jsp?ent=01IM00000000hIe&
        //retURL=/apex/Global_Account_Detail?id=001M000000hPz56IAC&
        //save_new_url=/a7I/e?CF00NM0000000qOgT=CHOI+FOOK+ROYAL+BANQUET+(NP)+(1302999)&
        //CF00NM0000000qOgT_lkid=001M000000hPz56&
        //scontrolCaching=1&
        //retURL=/apex/Global_Account_Detail?id=001M000000hPz56IAC
     ASI_CRM_HK_FieldIdMapping__c CustomSetting = [SELECT ASI_CRM_Object_Short__c, ASI_CRM_Customer_Field_Id__c, ASI_CRM_Custom_Obj_Id__c FROM ASI_CRM_HK_FieldIdMapping__c WHERE Name = 'ASI_CRM_HK_NewSOFields' Limit 1];
        string headerDesc = encodingutil.urlEncode(this.Header.Name, 'UTF-8');
        //string headerDesc = this.Header.Name.replace(' ', '+');
        System.debug('headerDesc:::::::::::::'+headerDesc);
        string url = '/setup/ui/recordtypeselect.jsp?ent=' + 
                CustomSetting.ASI_CRM_Custom_Obj_Id__c + 
                '&retURL=/apex/Global_Account_Detail?id=' +
                this.Header.id +
                '&save_new_url=/' +
                CustomSetting.ASI_CRM_Object_Short__c +
                '/e?' +  CustomSetting.ASI_CRM_Customer_Field_Id__c + '_lkid=' + this.Header.Id + //20160201, changed by Leo, change url sequence, id first than value
                '&'+ CustomSetting.ASI_CRM_Customer_Field_Id__c + '=' + headerDesc + //20160201, changed by Leo, change url sequence, id first than value
                '&scontrolCaching=1&retURL=/apex/Global_Account_Detail?id=' +
                this.Header.id;
        //url = encodingutil.urlEncode(url, 'UTF-8');
        system.debug('url:::::::::::::'+ url);
        PageReference pageRef = new PageReference(url);
        return pageRef;
    }
    
}