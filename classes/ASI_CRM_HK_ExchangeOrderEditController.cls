public with sharing class ASI_CRM_HK_ExchangeOrderEditController {
    
    public ApexPages.StandardController standardController {get;set;}
    public String mapPORlineJSON {get{return JSON.serialize(allSKUMap);}}
    public ASI_CRM_Exchange_Order__c Header {get;set;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public boolean SaveSuccess {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public Map<String, tmpExItems> allExItemsMap {get;set;}{ allExItemsMap = new Map<String, tmpExItems>();}
    public Map<String, tmpSKUItems> allSKUMap {get;set;}{ allSKUMap = new Map<String, tmpSKUItems>();}
    public List<tmpSKUItems> displayList {get;set;} //20160428, added by Leo
    public List<ASI_CRM_Exchange_Order_Item__c> deleteLineItemList {get; set;}
    public String Msg {get;set;} 
    public ASI_HK_CRM_Sales_Order__c searchSOObj {get;set;} {searchSOObj = new ASI_HK_CRM_Sales_Order__c();}
    public string searchSKU {get;set;}{searchSKU = '';}
    public string searchSOH {get;set;}{searchSOH = '';}
    public set<ID> SOIID_set {get;set;}
    public Class tmpExItems{
        public ASI_CRM_Exchange_Order_Item__c EXI {get;set;}
        public id SOIID {get; set;}
        public id SKUID {get; set;}
        public id SOID {get; set;}
        public string SOIName {get; set;}
        public string SOName {get; set;}
        public string SKUCode {get; set;}
        public string SKUDescription {get; set;}
        public Decimal SKUQyt {get; set;}
        public Decimal SKUQytInput {get; set;}
        public string SKURemark {get; set;}
        public string Type {get; set;}
        public Boolean Checked {get; set;}
        public Date SODate {get; set;} //20160307, added by Leo
        public String JDENo {get;set;} //20160307, added by Leo
        public String CRMName {get;set;} //20160307, added by Leo
        public String CRMId {get;set;} //20160307, added by Leo
        public String soAddress {get;set;} //20160307, added by Leo
    }
    
    public Class tmpSKUItems{
        public ASI_HK_CRM_Sales_Order_History_Detail__c SOI {get;set;}
        public id SOIID {get; set;}
        public string SOIName {get;set;}
        public id SKUID {get; set;}
        public id SOID {get; set;}
        public string SOName {get; set;}
        public date SODate {get; set;} //added on 20151012
        public string SKUCode {get; set;}
        public string SKUDescription {get; set;}
        public Decimal SKUQyt {get; set;}
        public string SKURemark {get; set;}
        public Boolean Checked {get; set;}
        public String JDENo {get;set;} //20160307, added by Leo
        public String CRMName {get;set;} //20160307, added by Leo
        public String CRMId {get;set;} //20160307, added by Leo
        public String soAddress {get;set;} //20160307, added by Leo
    }
    public Map<String, ASI_HK_CRM_Sales_Order__c> numSOmap{get;set;} //20160307, added by Leo
    public Set<String> jdeNoSet {get;set;} //20160307, added by Leo
    public Map<String, ASI_HK_CRM_Sales_Order__c> numSOmap2{get;set;} //20160307, added by Leo
    public Set<String> jdeNoSet2 {get;set;} //20160307, added by Leo
    
    // Filter
    public String SKUFilter {get;set;}
    public String SOStartFilter {get;set;}
    public String SOEndFilter {get;set;} 
    // Filter End
    
    public ASI_CRM_HK_ExchangeOrderEditController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.Header = (ASI_CRM_Exchange_Order__c) this.standardController.getRecord();
        if(this.Header !=null && this.Header.Id !=null){
            for(ASI_CRM_Exchange_Order__c exo : [Select id, Name, ASI_CRM_Collection_Date__c, ASI_CRM_Collection_Time__c, ASI_CRM_Customer__c, ASI_CRM_Reasons__c, ASI_CRM_Remarks__c, ASI_CRM_HK_Request_Date__c, ASI_CRM_Status__c FROM ASI_CRM_Exchange_Order__c where Id =: this.Header.Id limit 1]){
                this.Header = exo;
            }
        }
    }
    
    public void init() {
        SKUFilter = null;
        SOStartFilter = null;
        SOEndFilter = null;
        SaveSuccess=false;
        deleteLineItemList = new List<ASI_CRM_Exchange_Order_Item__c>();
        if(this.Header !=null && this.Header.Id !=null){
            jdeNoSet = new Set<String>(); //20160307, added by Leo
            numSOmap = new Map<String, ASI_HK_CRM_Sales_Order__c>(); //20160307, added by Leo
            jdeNoSet2 = new Set<String>(); //20160307, added by Leo
            numSOmap2 = new Map<String, ASI_HK_CRM_Sales_Order__c>(); //20160307, added by Leo
            displayList = new List<tmpSKUItems>(); //20160428, added by Leo
            //List<ASI_CRM_Exchange_Order_Item__c> ExItemList =[select id, name, ASI_CRM_Type__c, ASI_CRM_Qty_Bt_PC__c, ASI_CRM_Remark__c, ASI_CRM_HK_Sales_Order_Item__c, ASI_CRM_HK_Sales_Order_Item__r.id,ASI_CRM_HK_Sales_Order_Item__r.Name, ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__c, ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Sales_Order__r.Name , ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_SKU__c, ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Code__c, ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Description__c , ASI_CRM_HK_Sales_Order_Item__r.ASI_HK_CRM_Quantity__c from ASI_CRM_Exchange_Order_Item__c where ASI_CRM_Exchange_Order__c=:Header.id];
            //modified on 20151007: adding JDE code
   			List<ASI_CRM_Exchange_Order_Item__c> ExItemList =[select id, name, ASI_CRM_Type__c, ASI_CRM_Qty_Bt_PC__c, ASI_CRM_Remark__c, 
                                                              ASI_CRM_Sales_Order_History_Detail__c, ASI_CRM_Sales_Order_History_Detail__r.id, 
                                                              ASI_CRM_Sales_Order_History_Detail__r.Name,
                                                              ASI_CRM_HK_Remark__c,
                                                              ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c,
                                                              ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c,
															  ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c,
                                                              ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__c, ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.Name,
                                                              ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Product_SKU__c, ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c,
                                                              ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Description__c,
                                                              ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Quantity_in_Bottles__c 
                                                              from ASI_CRM_Exchange_Order_Item__c 
                                                              where 
                                                              ASI_CRM_Exchange_Order__c=:Header.id];
            SOIID_set = new set<ID>();
            
            if(!ExItemList.isEmpty()){
                for(ASI_CRM_Exchange_Order_Item__c ExItem : ExItemList){
                    String SOIID = (String)(ExItem.ASI_CRM_Sales_Order_History_Detail__c);
                    if(!allExItemsMap.containsKey(SOIID)){
                        tmpExItems tmp = new tmpExItems();
                        tmp.EXI = ExItem;
                        tmp.SOIID = ExItem.ASI_CRM_Sales_Order_History_Detail__c;
                        tmp.SOIName = ExItem.ASI_CRM_Sales_Order_History_Detail__r.Name;
                        tmp.SOID = ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__c;
                        tmp.SOName = ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.Name;
                        tmp.SKUID = ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Product_SKU__c;
                        tmp.SKUCode = ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c;
                        tmp.SKUDescription = ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Description__c;
						tmp.SKUQyt = ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Quantity_in_Bottles__c;
                        tmp.SKUQytInput = ExItem.ASI_CRM_Qty_Bt_PC__c;
                        //Change remark from JDE code 20151007
						tmp.SKURemark = ExItem.ASI_CRM_HK_Remark__c; 
                        tmp.Type = ExItem.ASI_CRM_Type__c;
						tmp.Checked = False;
                        //20160307, added by Leo
                        tmp.SODate = ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c;
                        if(ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c != null)
                        {
							//20161130 Wilken, added Document Type of SO History JDE SO# for searching CRM SO as there are multiple orders with same Document# but different Document Type
                            tmp.JDENo = ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c + '-' + ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c;
                            jdeNoSet2.add(ExItem.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c);
                        }//end if
                        else
                            tmp.JDENo = '';
                        //20160307, added by Leo
                        allExItemsMap.put(SOIID, tmp);
                        SOIID_set.add(ExItem.ASI_CRM_Sales_Order_History_Detail__c);
                    }  
                }
				
				system.debug('Set of JDE SO Number added from SO History: ' + jdeNoSet2);
				
                //20160307, added by Leo
                if(jdeNoSet2.size() > 0)
                {
                    List<ASI_HK_CRM_Sales_Order__c> soListBYjdeNo2 
                        = [SELECT Id, Name, ASI_HK_CRM_JDE_Order_No__c, ASI_HK_CRM_JDE_Order_Type_Code__c, ASI_HK_CRM_Delivery_Address__c
                           FROM ASI_HK_CRM_Sales_Order__c
                           WHERE ASI_HK_CRM_JDE_Order_No__c IN: jdeNoSet2];
                    if(soListBYjdeNo2.size() > 0)
                    {
                        for(ASI_HK_CRM_Sales_Order__c so: soListBYjdeNo2)
                        {
                            numSOmap2.put(so.ASI_HK_CRM_JDE_Order_Type_Code__c + '-' + so.ASI_HK_CRM_JDE_Order_No__c, so);
                        }//end for
                    }//end if
                }//end if
				
				system.debug('CRM SO Number and Document Type Map Key Set: ' + numSOmap2.keySet());
				
                if(!allExItemsMap.isEmpty())
                {
                    for(String id: allExItemsMap.keySet())
                    {
                        if(allExItemsMap.get(id).JDENo != '' && numSOmap2.containsKey(allExItemsMap.get(id).JDENo))
                        {
                            if(numSOmap2.get(allExItemsMap.get(id).JDENo).ASI_HK_CRM_Delivery_Address__c != null)
                            	allExItemsMap.get(id).soAddress = numSOmap2.get(allExItemsMap.get(id).JDENo).ASI_HK_CRM_Delivery_Address__c;
                            else
                                allExItemsMap.get(id).soAddress = '';
							
							system.debug('Assign CRM SO to SO History Items for display. SO History JDE SO#: ' + allExItemsMap.get(id).JDENo + ' CRM Order Ref Number: ' + numSOmap2.get(allExItemsMap.get(id).JDENo).Name);
                            allExItemsMap.get(id).CRMName = numSOmap2.get(allExItemsMap.get(id).JDENo).Name;
                            allExItemsMap.get(id).CRMId = numSOmap2.get(allExItemsMap.get(id).JDENo).Id;
                        }//end if
                    }//end for
                }//end if
                //20160307, added by Leo
            }//end if
  
            List<ASI_HK_CRM_Sales_Order_History_Detail__c> SOItemsList = [select id, name, ASI_HK_CRM_Sales_Order_History__c
                                                                          , ASI_HK_CRM_Sales_Order_History__r.Name
                                                                          , ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c
                                                                          , ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Status__c
                                                                          , ASI_HK_CRM_Product_SKU__c
                                                                          , ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c
                                                                          , ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Description__c
                                                                          , ASI_HK_CRM_Quantity_in_Bottles__c
                                                                          , ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c
                                                                          , ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c
                                                                          , ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Account_PA__c
                                                                          , ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_JDE_Invoice_No__c
                                                                          from ASI_HK_CRM_Sales_Order_History_Detail__c 
                                                                          where 
                                                                          id NOT IN:SOIID_set
                                                                          AND  RecordType.DeveloperName = 'ASI_HK_CRM_Sales_Order_History_Detail'
                                                                          AND ASI_HK_CRM_Quantity_in_Bottles__c > 0
                                                                          AND ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Account_PA__c =: Header.ASI_CRM_Customer__c
                                                                          AND (ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c = LAST_N_MONTHS:12
                                                                               OR ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c = THIS_MONTH) //20160428, added by Leo
                                                                          ORDER BY ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c DESC
																		  LIMIT 500 //20170112 Wilken, limit SOQL result to avoid error for outlet with large number of SO History
                                                                         ];
            system.debug('Customer::::::::::::::::' + Header.ASI_CRM_Customer__c);
            
            if(!SOItemsList.isEmpty()){   
                for(ASI_HK_CRM_Sales_Order_History_Detail__c SOItem :SOItemsList){
                    system.debug('CustomerHISTORY::::::::::::::::' + SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Account_PA__c);
                    tmpSKUItems tmp = new tmpSKUItems();
                    tmp.SOI = SOItem;
                    tmp.SOIID = SOItem.id;
                    tmp.SOIName = SOItem.Name;
                    tmp.SOID = SOItem.ASI_HK_CRM_Sales_Order_History__c;
                    tmp.SOName = SOItem.ASI_HK_CRM_Sales_Order_History__r.Name;
                    tmp.SODate = SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c;
                    tmp.SKUID = SOItem.ASI_HK_CRM_Product_SKU__c;
                    tmp.SKUCode = SOItem.ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c;
                    tmp.SKUDescription = SOItem.ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Description__c;
                    tmp.SKUQyt = SOItem.ASI_HK_CRM_Quantity_in_Bottles__c;
                    if (SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c != Null)
                    {
                    	tmp.SKURemark = SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c
                    					+ ' - ' + SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c;
                        tmp.JDENo = SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c + '-' + SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c; //20160307, added by Leo
                        jdeNoSet.add(SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c);
                    }//end if
                    else
                    {
                        tmp.SKURemark = '';
                        tmp.JDENo = ''; //20160307, added by Leo
                    }//end else
                    tmp.Checked = False;  
                    String soiid=(String)(SOItem.id);
                    if(!allSKUMap.containsKey(soiid)){
                        allSKUMap.put(soiid,tmp);
                    }
                }//end for
                //20160307, added by Leo
                if(jdeNoSet.size() > 0)
                {
                    List<ASI_HK_CRM_Sales_Order__c> soListBYjdeNo 
                        = [SELECT Id, Name, ASI_HK_CRM_JDE_Order_No__c, ASI_HK_CRM_JDE_Order_Type_Code__c, ASI_HK_CRM_Delivery_Address__c
                           FROM ASI_HK_CRM_Sales_Order__c
                           WHERE ASI_HK_CRM_JDE_Order_No__c IN: jdeNoSet];
                    if(soListBYjdeNo.size() > 0)
                    {
                        for(ASI_HK_CRM_Sales_Order__c so: soListBYjdeNo)
                        {
                            numSOmap.put(so.ASI_HK_CRM_JDE_Order_Type_Code__c + '-' + so.ASI_HK_CRM_JDE_Order_No__c, so);
                        }//end for
                    }//end if
                }//end if
                if(!allSKUMap.isEmpty())
                {
                    for(String id: allSKUMap.keySet())
                    {
                        if(allSKUMap.get(id).JDENo != '' && numSOmap.containsKey(allSKUMap.get(id).JDENo))
                        {
                            if(numSOmap.get(allSKUMap.get(id).JDENo).ASI_HK_CRM_Delivery_Address__c != null)
                            	allSKUMap.get(id).soAddress = numSOmap.get(allSKUMap.get(id).JDENo).ASI_HK_CRM_Delivery_Address__c;
                            else
                                allSKUMap.get(id).soAddress = '';
                            allSKUMap.get(id).CRMName = numSOmap.get(allSKUMap.get(id).JDENo).Name;
                            allSKUMap.get(id).CRMId = numSOmap.get(allSKUMap.get(id).JDENo).Id;
                        }//end if
                    }//end for
                }//end if
                //20160307, added by Leo
            }//end if
        }
        if(allSKUMap.values().size()>0)
            displayList = sortingMethod(allSKUMap.values());
        else
            displayList.clear();
    }
    
    public void removeLine() {
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        if(allExItemsMap.containsKey(param_Id) && !allExItemsMap.isEmpty() ){  
            tmpSKUItems tmp = new tmpSKUItems();
            tmp.SOI = new ASI_HK_CRM_Sales_Order_History_Detail__c (id=allExItemsMap.get(param_Id).EXI.ASI_CRM_Sales_Order_History_Detail__c);
            tmp.SOIID = allExItemsMap.get(param_Id).SOIID;
            tmp.SOIName = allExItemsMap.get(param_Id).SOIName;
            tmp.SOID = allExItemsMap.get(param_Id).SOID;
            tmp.SOName = allExItemsMap.get(param_Id).SOName;
            tmp.SKUID = allExItemsMap.get(param_Id).SKUID;
            tmp.SKUCode = allExItemsMap.get(param_Id).SKUCode;
            tmp.SKUDescription = allExItemsMap.get(param_Id).SKUDescription;
            tmp.SKUQyt = allExItemsMap.get(param_Id).SKUQyt;
            tmp.SKURemark = allExItemsMap.get(param_Id).SKURemark;
            tmp.Checked = False;
            tmp.SODate = allExItemsMap.get(param_Id).SODate; //20160307, added by Leo
            tmp.JDENo = allExItemsMap.get(param_Id).JDENo; //20160307, added by Leo
            tmp.CRMName = allExItemsMap.get(param_Id).CRMName; //20160307, added by Leo
            tmp.CRMId = allExItemsMap.get(param_Id).CRMId; //20160307, added by Leo
            tmp.soAddress = allExItemsMap.get(param_Id).soAddress; //20160307, added by Leo
            
            allSKUMap.put(tmp.SOIID,tmp);
            ASI_CRM_Exchange_Order_Item__c delTarget = allExItemsMap.get(param_Id).EXI;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allExItemsMap.remove(param_Id);
            SOIID_set.remove(tmp.SOIID);
            
        }
        if(allSKUMap.values().size()>0)
        	displayList = sortingMethod(allSKUMap.values());
        else
            displayList.clear();
    }
    
    public void RemoveAllLinetems(){
        
        SaveSuccess=false;
        UpsertPermission=true;
        
        Set<String> keySet = new Set<String>();
        keyset = allExItemsMap.keySet();

        if(keyset.size() > 0) {
            for(string key : keyset) {
                tmpSKUItems tmp = new tmpSKUItems();
                tmp.SOI = new ASI_HK_CRM_Sales_Order_History_Detail__c (id=allExItemsMap.get(key).EXI.ASI_CRM_Sales_Order_History_Detail__c);
                tmp.SOIID = allExItemsMap.get(key).SOIID;
                tmp.SOIName = allExItemsMap.get(key).SOIName;
                tmp.SOID = allExItemsMap.get(key).SOID;
                tmp.SOName = allExItemsMap.get(key).SOName;
                tmp.SKUID = allExItemsMap.get(key).SKUID;
                tmp.SKUCode = allExItemsMap.get(key).SKUCode;
                tmp.SKUDescription = allExItemsMap.get(key).SKUDescription;
                tmp.SKUQyt = allExItemsMap.get(key).SKUQyt;
                tmp.SKURemark = allExItemsMap.get(key).SKURemark;
                tmp.Checked = False;
                tmp.SODate = allExItemsMap.get(key).SODate; //20160307, added by Leo
                tmp.JDENo = allExItemsMap.get(key).JDENo; //20160307, added by Leo
                tmp.CRMName = allExItemsMap.get(key).CRMName; //20160307, added by Leo
                tmp.CRMId = allExItemsMap.get(key).CRMId; //20160307, added by Leo
                tmp.soAddress = allExItemsMap.get(key).soAddress; //20160307, added by Leo
                
                allSKUMap.put(tmp.SOIID,tmp);
                ASI_CRM_Exchange_Order_Item__c delTarget = allExItemsMap.get(key).EXI;
                if(delTarget.id != null){
                    deleteLineItemList.add(delTarget);
                }
                allExItemsMap.remove(key);
                SOIID_set.remove(tmp.SOIID);
            }
        }
        if(allSKUMap.values().size()>0)
        	displayList = sortingMethod(allSKUMap.values());
        else
            displayList.clear();
    }
    
    public void RemoveSelectedLinetems(){
        
        SaveSuccess=false;
        UpsertPermission=true;
        
        Set<String> keySet = new Set<String>();
        keyset = allExItemsMap.keySet();
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        
        if(keyset.size() > 0) {
            for(string key : keyset) {
                if(allExItemsMap.get(key).Checked) {
                    tmpSKUItems tmp = new tmpSKUItems();
                    tmp.SOI = new ASI_HK_CRM_Sales_Order_History_Detail__c (id=allExItemsMap.get(key).EXI.ASI_CRM_Sales_Order_History_Detail__c);
                    tmp.SOIID = allExItemsMap.get(key).SOIID;
                    tmp.SOIName = allExItemsMap.get(key).SOIName;
                    tmp.SOID = allExItemsMap.get(key).SOID;
                    tmp.SOName = allExItemsMap.get(key).SOName;
                    tmp.SKUID = allExItemsMap.get(key).SKUID;
                    tmp.SKUCode = allExItemsMap.get(key).SKUCode;
                    tmp.SKUDescription = allExItemsMap.get(key).SKUDescription;
                    tmp.SKUQyt = allExItemsMap.get(key).SKUQyt;
                    tmp.Checked = False;  
                    tmp.SKURemark = allExItemsMap.get(key).SKURemark;
                    tmp.SODate = allExItemsMap.get(key).SODate; //20160307, added by Leo
            		tmp.JDENo = allExItemsMap.get(key).JDENo; //20160307, added by Leo
            		tmp.CRMName = allExItemsMap.get(key).CRMName; //20160307, added by Leo
            		tmp.CRMId = allExItemsMap.get(key).CRMId; //20160307, added by Leo
                    tmp.soAddress = allExItemsMap.get(key).soAddress; //20160307, added by Leo
                    
                    allSKUMap.put(tmp.SOIID,tmp);
                    ASI_CRM_Exchange_Order_Item__c delTarget = allExItemsMap.get(key).EXI;
                    if(delTarget.id != null){
                        deleteLineItemList.add(delTarget);
                    }
                    allExItemsMap.remove(key);
                    SOIID_set.remove(tmp.SOIID);
                }
            }
        }
        if(allSKUMap.values().size()>0)
        	displayList = sortingMethod(allSKUMap.values());
        else
            displayList.clear();
    }

    public void addLineItem(){
        
        SaveSuccess=false;
        UpsertPermission=true;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_POLINE_SOURCE_ITEM_ID');

        if(allSKUMap.containsKey(param_SourceItemId)){
            tmpExItems tmp = new tmpExItems();
            string newIDCounter = newCounterCreatorLine();
            tmp.EXI = new ASI_CRM_Exchange_Order_Item__c();
            tmp.EXI.ASI_CRM_Exchange_Order__c = Header.Id;
            tmp.EXI.ASI_CRM_Sales_Order_History_Detail__c = allSKUMap.get(param_SourceItemId).SOIID;
            tmp.EXI.ASI_CRM_SKU__c = allSKUMap.get(param_SourceItemId).SKUID;
            tmp.SOIID = allSKUMap.get(param_SourceItemId).SOIID;
            tmp.SOIName = allSKUMap.get(param_SourceItemId).SOIName;
            tmp.SOID = allSKUMap.get(param_SourceItemId).SOID;
            tmp.SOName = allSKUMap.get(param_SourceItemId).SOName;
            tmp.SKUID = allSKUMap.get(param_SourceItemId).SKUID;
            tmp.SKUCode = allSKUMap.get(param_SourceItemId).SKUCode;
            tmp.SKUDescription = allSKUMap.get(param_SourceItemId).SKUDescription;
            tmp.SKUQyt = allSKUMap.get(param_SourceItemId).SKUQyt;
            tmp.SKUQytInput = allSKUMap.get(param_SourceItemId).SKUQyt;
            tmp.SKURemark = allSKUMap.get(param_SourceItemId).SKURemark; 
            tmp.Checked = False;
            tmp.SODate = allSKUMap.get(param_SourceItemId).SODate; //20160307, added by Leo
            tmp.JDENo = allSKUMap.get(param_SourceItemId).JDENo; //20160307, added by Leo
            tmp.CRMName = allSKUMap.get(param_SourceItemId).CRMName; //20160307, added by Leo
            tmp.CRMId = allSKUMap.get(param_SourceItemId).CRMId; //20160307, added by Leo
            tmp.soAddress = allSKUMap.get(param_SourceItemId).soAddress; //20160307, added by Leo
            
            allExItemsMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, tmp);
            SOIID_set.add(tmp.SOIID);
            allSKUMap.remove(param_SourceItemId);
        }
        if(allSKUMap.values().size()>0)
        	displayList = sortingMethod(allSKUMap.values());
        else
            displayList.clear();
    }
    
    public void AddAllLinetems(){
        
        SaveSuccess=false;
        UpsertPermission=true;
        
        Set<String> keySet = new Set<String>();
        keyset = allSKUMap.keySet();

        if (keyset.size() > 0) {
            for (String key : keyset) {
                tmpExItems tmp = new tmpExItems();
                string newIDCounter = newCounterCreatorLine();
                tmp.EXI = new ASI_CRM_Exchange_Order_Item__c();
                tmp.EXI.ASI_CRM_Exchange_Order__c = Header.Id;
                tmp.EXI.ASI_CRM_Sales_Order_History_Detail__c = allSKUMap.get(key).SOIID;
                tmp.EXI.ASI_CRM_SKU__c = allSKUMap.get(key).SKUID;
                tmp.SOIID = allSKUMap.get(key).SOIID;
                tmp.SOIName = allSKUMap.get(key).SOIName;
                tmp.SOID = allSKUMap.get(key).SOID;
                tmp.SOName = allSKUMap.get(key).SOName;
                tmp.SKUID = allSKUMap.get(key).SKUID;
                tmp.SKUCode = allSKUMap.get(key).SKUCode;
                tmp.SKUDescription = allSKUMap.get(key).SKUDescription;
                tmp.SKUQyt = allSKUMap.get(key).SKUQyt;
                tmp.SKUQytInput = allSKUMap.get(key).SKUQyt;
                tmp.SKURemark = allSKUMap.get(key).SKURemark;
                tmp.Checked = False;
                tmp.SODate = allSKUMap.get(key).SODate; //20160307, added by Leo
            	tmp.JDENo = allSKUMap.get(key).JDENo; //20160307, added by Leo
            	tmp.CRMName = allSKUMap.get(key).CRMName; //20160307, added by Leo
            	tmp.CRMId = allSKUMap.get(key).CRMId; //20160307, added by Leo
                tmp.soAddress = allSKUMap.get(key).soAddress; //20160307, added by Leo
                
                allExItemsMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, tmp);
                SOIID_set.add(tmp.SOIID);
                allSKUMap.remove(key);
            }
        } 
        if(allSKUMap.values().size()>0)
        	displayList = sortingMethod(allSKUMap.values());
        else
            displayList.clear();
    }
    
    public void AddSelectedLinetems(){
        
        SaveSuccess=false;
        UpsertPermission=true;
        
        Set<String> keySet = new Set<String>();
        keyset = allSKUMap.keySet();

        if (keyset.size() > 0) {
            for (String key : keyset) {
                if (allSKUMap.get(key).Checked) {
                    tmpExItems tmp = new tmpExItems();
                    string newIDCounter = newCounterCreatorLine();
                    tmp.EXI = new ASI_CRM_Exchange_Order_Item__c();
                    tmp.EXI.ASI_CRM_Exchange_Order__c = Header.Id;
                    tmp.EXI.ASI_CRM_Sales_Order_History_Detail__c = allSKUMap.get(key).SOIID;
                    tmp.EXI.ASI_CRM_SKU__c = allSKUMap.get(key).SKUID;
                    tmp.SOIID = allSKUMap.get(key).SOIID;
                    tmp.SOIName = allSKUMap.get(key).SOIName;
                    tmp.SOID = allSKUMap.get(key).SOID;
                    tmp.SOName = allSKUMap.get(key).SOName;
                    tmp.SKUID = allSKUMap.get(key).SKUID;
                    tmp.SKUCode = allSKUMap.get(key).SKUCode;
                    tmp.SKUDescription = allSKUMap.get(key).SKUDescription;
                    tmp.SKUQyt = allSKUMap.get(key).SKUQyt;
                    tmp.SKUQytInput = allSKUMap.get(key).SKUQyt;
                    tmp.SKURemark = allSKUMap.get(key).SKURemark;
                    tmp.Checked = False;
                    tmp.SODate = allSKUMap.get(key).SODate; //20160307, added by Leo
            		tmp.JDENo = allSKUMap.get(key).JDENo; //20160307, added by Leo
            		tmp.CRMName = allSKUMap.get(key).CRMName; //20160307, added by Leo
            		tmp.CRMId = allSKUMap.get(key).CRMId; //20160307, added by Leo
                    tmp.soAddress = allSKUMap.get(key).soAddress; //20160307, added by Leo
                    
                    allExItemsMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, tmp);
                    SOIID_set.add(tmp.SOIID);
                    allSKUMap.remove(key);
                }
            }
        } 
        if(allSKUMap.values().size()>0)
        	displayList = sortingMethod(allSKUMap.values());
        else
            displayList.clear();
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
        Msg = '';
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        UpsertPermission=true;
        List<ASI_CRM_Exchange_Order_Item__c> upsertTargetList = new List<ASI_CRM_Exchange_Order_Item__c>();
        if(UpsertPermission){
            for(String key : allExItemsMap.keySet()){
                if(allExItemsMap.get(key).Type == 'None'){
                    UpsertPermission = false;
                    Msg += 'Please identify the Exchange Order Item Type :Return / Exchange for SKU: ' + allExItemsMap.get(key).SKUCode + '<br />';
                }
                if(allExItemsMap.get(key).SKUQytInput > allExItemsMap.get(key).SKUQyt){
                    UpsertPermission = false;
                    Msg += 'Return / Exchange Qty(Bt/Pc) cannot be greater than Original Request Qty for SKU: ' + allExItemsMap.get(key).SKUCode + '<br />';
                }
                allExItemsMap.get(key).EXI.ASI_CRM_Type__c = allExItemsMap.get(key).Type;
                allExItemsMap.get(key).EXI.ASI_CRM_Qty_Bt_PC__c = allExItemsMap.get(key).SKUQytInput; 
                allExItemsMap.get(key).EXI.ASI_CRM_Remark__c = allExItemsMap.get(key).SKURemark;
                upsertTargetList.add(allExItemsMap.get(key).EXI);
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
            }else{
                SaveSuccess=false;
            }
            
        }catch(Exception e){
            UpsertPermission = false;
            Msg = 'Save Error:' + e.getMessage();
        }
        
    }
    
    public void search(){
		//String soql = 'select id, name, ASI_HK_CRM_Sales_Order__c, 
      //      ASI_HK_CRM_Sales_Order__r.Name, ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Order_Status_Name__c, 
    //        ASI_HK_CRM_SKU__c, ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Code__c, ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Description__c, 
     //       ASI_HK_CRM_Quantity__c from ASI_HK_CRM_Sales_Order_Item__c where ASI_HK_CRM_Sales_Order__r.ASI_HK_CRM_Order_Status_Name__c = \'Approved\' AND id NOT IN: SOIID_set';
        String tmpAcc = Header.ASI_CRM_Customer__c;
        String soql = 'select id, name, ASI_HK_CRM_Sales_Order_History__c, ASI_HK_CRM_Sales_Order_History__r.Name, ';
               soql += 'ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c, ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Status__c, ';
               soql += 'ASI_HK_CRM_Product_SKU__c, ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c, ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Description__c, ';
               soql += 'ASI_HK_CRM_Quantity_in_Bottles__c, ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c, ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c ';
               soql += 'from ASI_HK_CRM_Sales_Order_History_Detail__c ';
               soql += 'where ';
               soql += 'id NOT IN:SOIID_set ';
               soql += 'AND  RecordType.DeveloperName = \'ASI_HK_CRM_Sales_Order_History_Detail\' ';
               soql += 'AND ASI_HK_CRM_Quantity_in_Bottles__c > 0';
        	   soql += 'AND ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Account_PA__c =: tmpAcc';
         if(searchSOH!=null && searchSOH.length()>0){
            //soql += ' and ASI_HK_CRM_Sales_Order_History__r.Name LIKE \'%'+String.escapeSingleQuotes(searchSOH)+'%\'';
            soql += ' and ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c LIKE \'%'+String.escapeSingleQuotes(searchSOH)+'%\''; //20160307, edited by Leo
        }
        
        if(searchSKU!=null && searchSKU.length()>0){
            soql += ' and ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c LIKE \'%'+String.escapeSingleQuotes(searchSKU)+'%\'';
        }
        
        if(searchSOObj.ASI_HK_CRM_Cheque_Date_4__c != null) {
            String fromDate = DateTime.newInstance(searchSOObj.ASI_HK_CRM_Cheque_Date_4__c.year(),searchSOObj.ASI_HK_CRM_Cheque_Date_4__c.month(),searchSOObj.ASI_HK_CRM_Cheque_Date_4__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c >= ' + fromDate + ''; 
        }
        if(searchSOObj.ASI_HK_CRM_Cheque_Date_5__c != null) {
            String toDate = DateTime.newInstance(searchSOObj.ASI_HK_CRM_Cheque_Date_5__c.year(),searchSOObj.ASI_HK_CRM_Cheque_Date_5__c.month(),searchSOObj.ASI_HK_CRM_Cheque_Date_5__c.day(), 0,0,0).format('yyyy-MM-dd');
            soql += ' AND ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c <= ' + toDate + ''; 
        }
        if(searchSOObj.ASI_HK_CRM_Cheque_Date_4__c == null && searchSOObj.ASI_HK_CRM_Cheque_Date_5__c == null)
        {
            soql += ' AND (ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c = LAST_N_MONTHS:12 OR ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c = THIS_MONTH)';
        }

        system.debug(soql);
        List<ASI_HK_CRM_Sales_Order_History_Detail__c> SOItemsList=Database.query(soql);
        allSKUMap = new Map<String, tmpSKUItems>(); 
        if(!SOItemsList.isEmpty()){  
            for(ASI_HK_CRM_Sales_Order_History_Detail__c SOItem :SOItemsList){ 
                tmpSKUItems tmp = new tmpSKUItems();
                tmp.SOI = SOItem;
                tmp.SOIID = SOItem.id;
                tmp.SOIName = SOItem.Name;
                tmp.SOID = SOItem.ASI_HK_CRM_Sales_Order_History__c;
                tmp.SOName = SOItem.ASI_HK_CRM_Sales_Order_History__r.Name;
                tmp.SODate = SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Date__c;
                tmp.SKUID = SOItem.ASI_HK_CRM_Product_SKU__c;
                tmp.SKUCode = SOItem.ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Code__c;
                tmp.SKUDescription = SOItem.ASI_HK_CRM_Product_SKU__r.ASI_MFM_SKU_Description__c;
                tmp.SKUQyt = SOItem.ASI_HK_CRM_Quantity_in_Bottles__c;
                tmp.SKURemark = SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c
                				+ '-' + SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_Type__c;
                if (SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c != null)
                {
                    tmp.JDENo = SOItem.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c; //20160307, Added by Leo
                    jdeNoSet.add(tmp.JDENo);
                }
                else
                    tmp.JDENo = '';
                tmp.Checked = False;  
                String soiid=(String)(SOItem.id);
                if(!allSKUMap.containsKey(soiid)){
                    allSKUMap.put(soiid,tmp);
                }
            }
            //20160307, added by Leo
            if(jdeNoSet.size() > 0)
            {
                List<ASI_HK_CRM_Sales_Order__c> soListBYjdeNo 
                    = [SELECT Id, Name, ASI_HK_CRM_JDE_Order_No__c,
                       ASI_HK_CRM_Delivery_Address__c
                       FROM ASI_HK_CRM_Sales_Order__c
                       WHERE ASI_HK_CRM_JDE_Order_No__c IN: jdeNoSet];
                if(soListBYjdeNo.size() > 0)
                {
                    for(ASI_HK_CRM_Sales_Order__c so: soListBYjdeNo)
                    {
                        numSOmap.put(so.ASI_HK_CRM_JDE_Order_No__c, so);
                    }//end for
                }//end if
            }//end if
            if(!allSKUMap.isEmpty())
            {
                for(String id: allSKUMap.keySet())
                {
                    if(allSKUMap.get(id).JDENo != '' && numSOmap.containsKey(allSKUMap.get(id).JDENo))
                    {
                        if(numSOmap.get(allSKUMap.get(id).JDENo).ASI_HK_CRM_Delivery_Address__c != null)
                            allSKUMap.get(id).soAddress = numSOmap.get(allSKUMap.get(id).JDENo).ASI_HK_CRM_Delivery_Address__c;
                        else
                            allSKUMap.get(id).soAddress = '';
                        allSKUMap.get(id).CRMName = numSOmap.get(allSKUMap.get(id).JDENo).Name;
                        allSKUMap.get(id).CRMId = numSOmap.get(allSKUMap.get(id).JDENo).Id;
                    }//end if
                }//end for
            }//end if
            //20160307, added by Leo
        }//end if
        if(allSKUMap.values().size()>0)
        	displayList = sortingMethod(allSKUMap.values());
        else
            displayList.clear();
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
    
    @RemoteAction
    public static List<ASI_MFM_SKU_Code__c> InitializeSKUList(String SKUFilter){
       list <ASI_MFM_SKU_Code__c> SKULists = new List<ASI_MFM_SKU_Code__c>();
        if(SKUFilter != ''){
            String query = 'select  id, name from ASI_MFM_SKU_Code__c where  RecordType.DeveloperName LIKE \'ASI_HK_CRM_SKU%\' and Name like \'%' + SKUFilter+ '%\'';
            SKULists = database.query(query);
        }    
        return SKULists;
    }
    
    public PageReference cancel() {    
        Pagereference ref;
        ref = new PageReference('/'+Header.id);
        ref.setRedirect(true);
        return ref;		
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
        String filter = ' Where RecordType.DeveloperName = \'' + String.escapeSingleQuotes(qry) + '\'';
        //begin building the dynamic soql query
        
        String soql = 'select ASI_MFM_SKU_Code__c from ' + obj  + filter +' order by ASI_MFM_SKU_Code__c';
        List<ASI_MFM_SKU_Code__c> sobjs = new List<ASI_MFM_SKU_Code__c>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            
            for(ASI_MFM_SKU_Code__c sobj : sobjs){
                String tmp = sobj.ASI_MFM_SKU_Code__c;
                results.add(tmp); 
            }
            System.debug('results:' + results);
        }
        catch (QueryException e) {
            return null;
        }
        return results;
    }
    
    public List<tmpSKUItems> sortingMethod(List<tmpSKUItems> sohList)
    {
        List<tmpSKUItems> tempList = new List<tmpSKUItems>();
        Date k;
        integer l;
        integer i = 0;
        Boolean sorting = TRUE;
        while(sorting){
            
            Date j = sohList[i].SODate;
            
            k = k == NULL ? j : k;
            
            if(j >= k){
                k = j;
                l = i;
            }
            
            i++;
            if(i > sohList.size() - 1){
                i = 0;
                tempList.add(sohList[l]);
                sohList.remove(l);
                k = NULL;
                l = NULL;
            }
            
            sorting = !sohList.isEmpty();
        }
        return tempList;
    }
    
}