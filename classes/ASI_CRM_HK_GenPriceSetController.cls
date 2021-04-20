// 20151112: adding 2 components
// - Adding URGENT checkbox
// - a free text box
public with sharing class ASI_CRM_HK_GenPriceSetController {  
    public boolean haveValue {get;set;}
    public String PAF_Number;
    public Id PAFId {get;set;}
    private Set<String> ChannelSet {get; set;}
    public list<selectOption> available_channels {get; private set;}
    public List<ASI_MFM_SKU_Code__c> sku_values{get; set;}
    public List<String> skuResult{get; set;}
    public string selected_channel {get; set;}
    //public string Channel {set; get;}
    public ASI_HK_CRM_Pre_Approval_Form__c searchPAFObj {get; set;}
    public List<ResultSet> resultPAF {get;set;}
    public String Msg {get;set;}
    public Boolean haveError {get;set;}
    //20151112 - adding 2 components
    public Boolean urgentBox {set; get;}
    public String freeText {set; get;}
    //20151127
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> lineItemList {get; set;}
    
    
    //20151231, Leo@Elufa
    public Map<Id, Set<lineItemClass>> skuMap {get;set;} //map<paf line, list<sku>>, (sku list filter by paf line pricing code)
    //20151231, Leo@Elufa
    
    public boolean clicked {get;set;} //20160406, added by Leo
    
    private ApexPages.StandardController sctrl;

    public class ResultSet {
        public Boolean checked {set; get;}
        public ASI_HK_CRM_Pre_Approval_Form__c PAF {get; set;}
    }

    public ASI_CRM_HK_GenPriceSetController(ApexPages.StandardController controller) {
        haveError = false;
        sku_values = new List<ASI_MFM_SKU_Code__c>();
        skuResult = new List<String>();
        lineItemList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        skuMap = new Map<Id, Set<lineItemClass>>();
        PAFId = ApexPages.currentPage().getParameters().get('id');
        system.debug('PAF : '+ PAFId);
        
        lineItemList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>([SELECT id
                                                                       , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name
                                                                       , ASI_CRM_HK_Free_SKU__r.Name
                                                                       , ASI_CRM_HK_Free_SKU__c
                                                                       , ASI_HK_CRM_SKU_Lookup__c
                                                                       , ASI_HK_CRM_SKU_Lookup__r.Name
                                                                       , ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_Inventory__c
                                                                       , ASI_CRM_HK_Pricing_Item__c
                                                                       , ASI_HK_CRM_Mechanic__c
                                                                       , ASI_HK_CRM_Mechanic__r.Name
                                                                       , ASI_CRM_HK_Pricing_Code__c
                                                                       , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__c
                                                                       FROM ASI_HK_CRM_Pre_Approval_Form_Item__c 
                                                                       WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c = : PAFId
                                                                       And (ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC' //20160322, edited by Leo
                                                                            OR ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC Bulk') //20160322, edited by Leo
                                                                       Order BY ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name Asc]);//Add filter logic here
        if(lineItemList.size() > 0 || Test.isRunningTest())
        {
            Set<String> pricingCodeSet = new Set<String>();
            Map<String,Set<lineItemClass>> pcSKUmap = new Map<String,Set<lineItemClass>>(); //map<item group name, list<sku>>
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c line: lineItemList)
            {
                if(line.ASI_CRM_HK_Pricing_Code__c != NULL && line.ASI_CRM_HK_Pricing_Code__c != '')
                    pricingCodeSet.add(line.ASI_CRM_HK_Pricing_Code__c); //set of line item pricing code
                if(line.ASI_CRM_HK_Free_SKU__c == null)
                {
                    Set<lineItemClass> tmpClass = new Set<lineItemClass>();
                    lineItemClass tmpClass2 = new lineItemClass();
                    tmpClass2.id = '';
                    tmpClass2.FreeSKU = '';
                    tmpClass2.inventory = 'Inventory: -'; //20160406, added by Leo
                    tmpClass.add(tmpClass2);
                    pcSKUmap.put(line.ASI_CRM_HK_Pricing_Code__c, tmpClass);
                }
                System.Debug('CHECK 1.0: '+pricingCodeSet);
            }//end for
            
            List<ASI_MFM_SKU_Code__c> skuList //list of sku, filter by record type, item group name (paf line pricing code)
                = new List<ASI_MFM_SKU_Code__c>([SELECT id, Name, 
                                                 ASI_MFM_Item_Group__c,
                                                 ASI_MFM_Item_Group__r.Name,
                                                 ASI_HK_CRM_Inventory__c
                                                 FROM ASI_MFM_SKU_Code__c 
                                                 WHERE recordType.DeveloperName = 'ASI_HK_CRM_SKU' 
                                                 AND ASI_MFM_Item_Group__r.Name IN: pricingCodeSet 
                                                 AND ASI_HK_CRM_Active__c = TRUE 
                                                 ORDER BY ASI_HK_CRM_Inventory__c DESC]);
            System.Debug('CHECK 2.0: '+skuList);
            
            for(ASI_MFM_SKU_Code__c sku: skuList)
            {
                if(!pcSKUmap.containsKey(sku.ASI_MFM_Item_Group__r.Name)) //if map does not contains key(item group name), add in map
                {
                    Set<lineItemClass> tmpClass = new Set<lineItemClass>();
                    lineItemClass tmpClass2 = new lineItemClass();
                    
                    tmpClass2.id = sku.id;
                    tmpClass2.FreeSKU = sku.Name;
                    tmpClass2.inventory = 'Inventory: '+sku.ASI_HK_CRM_Inventory__c; //20160406, added by Leo
                    tmpClass.add(tmpClass2);
                    pcSKUmap.put(sku.ASI_MFM_Item_Group__r.Name, tmpClass);
                    this.sku_values.add(sku);
                    System.Debug('CHECK 3.0: '+pcSKUmap);
                }//end if
                else
                {
                    Set<lineItemClass> tmpClass = pcSKUmap.get(sku.ASI_MFM_Item_Group__r.Name);                    
                    lineItemClass tmpClass2 = new lineItemClass();
                    
                    tmpClass2.id = sku.id;
                    tmpClass2.FreeSKU = sku.Name;
                    tmpClass2.inventory = 'Inventory: '+sku.ASI_HK_CRM_Inventory__c; //20160406, added by Leo
                    tmpClass.add(tmpClass2);
                    
                    pcSKUmap.put(sku.ASI_MFM_Item_Group__r.Name, tmpClass);
                    this.sku_values.add(sku);
                    
                    System.Debug('CHECK 3.1: '+pcSKUmap);
                }//end else
            }//end for
            
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c line: lineItemList)
            {
                if(pcSKUmap.containsKey(line.ASI_CRM_HK_Pricing_Code__c))
                {
                    skuMap.put(line.id, pcSKUmap.get(line.ASI_CRM_HK_Pricing_Code__c));
                    System.Debug('CHECK 4.0: '+skuMap);
                }//end if
                else
                {
                    Set<lineItemClass> tmpClass = new Set<lineItemClass>();
                    
                    lineItemClass tmpClass2 = new lineItemClass();
                    
                    tmpClass2.id = '';
                    tmpClass2.FreeSKU = '';
                    tmpClass2.inventory = 'Inventory: -'; //20160406, added by Leo
                    tmpClass.add(tmpClass2);
                    skuMap.put(line.id, tmpClass);
                    System.Debug('CHECK 4.1: '+skuMap);
                }//end else
            }//end for
        }
        else
        {
            haveError = true;
            showPageError('No SKUs found for this PAF');
        }
        if(sku_values.size()>0)
        {
            for(ASI_MFM_SKU_Code__c sku : sku_values)
            {
                String a = sku.ASI_HK_CRM_Inventory__c != NULL ? String.valueOf(sku.ASI_HK_CRM_Inventory__c) : '0';
                
                skuResult.add(sku.Name + '$$$' + a + '%%%%' + sku.id);
            }
        }
        system.debug('skuresult :' + skuResult);
        this.sctrl = controller;
        
    }
    
    public ASI_CRM_HK_GenPriceSetController() {
        init();
    }
    
    public void init(){
        resultPAF = new List<ResultSet>();
        lineItemList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        //20151231, Leo@Elufa
        skuMap = new Map<Id, Set<lineItemClass>>(); //new map
        //20151231, Leo@Elufa
        haveValue = true;
        haveError = false;
        clicked = false; //20160406, added by Leo
        ChannelSet = new Set<string>();
        available_channels = new list<selectOption>();        
        searchPAFObj = new ASI_HK_CRM_Pre_Approval_Form__c();
        selected_channel = '';
        available_channels.add(new selectOption('', ''));
        List<Account> accountchannel = [select id, ASI_HK_CRM_Channel__c 
                                        FROM Account 
                                        WHERE ASI_HK_CRM_Channel__c != '' 
                                        AND  (RecordType.DeveloperName = 'ASI_HK_CRM_Outlet' 
                                              OR RecordType.DeveloperName = 'ASI_HK_CRM_Potential_Account')
                                       ];
        //System.debug('init check point');
        for (Account tmpac: accountchannel) {
            if(!ChannelSet.contains(tmpac.ASI_HK_CRM_Channel__c))
            {
                ChannelSet.add(tmpac.ASI_HK_CRM_Channel__c);
                available_channels.add(new selectOption(tmpac.ASI_HK_CRM_Channel__c, tmpac.ASI_HK_CRM_Channel__c));
            }
        }
        available_channels.sort();
    }
    
    public PageReference searchPAF() 
    {
        //resultPAF.clear();
     	String filter = '';
        String soql = 'Select id, Name, ASI_HK_CRM_Adjusted_Start_Date__c, ASI_HK_CRM_Adjusted_End_Date__c, ASI_HK_CRM_PAF_Raised_Date__c, Owner.name, ASI_HK_CRM_PAF_Status__c, ASI_CRM_Approved_Date__c, ASI_HK_CRM_PAF_Contract_Requirement__c, ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c, ASI_HK_CRM_PAF_Customer__c, ASI_HK_CRM_PAF_Start_Date__c, ASI_HK_CRM_PAF_End_Date__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE recordType.developerName=\'ASI_HK_Pre_Approval_Form_Date_Adjustment\' AND (NOT ASI_HK_CRM_PAF_Status__c LIKE \'%Reject%\')';//20160518, edited by Leo/*ASI_CRM_Approved_Date__c != null AND (NOT ASI_HK_CRM_PAF_Status__c LIKE \'%Reject%\')'; //20160406, edited by Leo/*(NOT( ASI_HK_CRM_PAF_Status__c Like \'Draft\' OR ASI_HK_CRM_PAF_Status__c LIKE \'%Reject%\' OR ASI_HK_CRM_PAF_Status__c Like \'Submitted\')) ';*///20160107 Ben @ Elufa Systems//AND ( ASI_CRM_Price_Set_Generation_Status__c = \'\' OR ASI_CRM_Price_Set_Generation_Status__c = \'Reject\') ';
        if(selected_channel != null) {
            filter += ' AND ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c Like \'' + String.escapeSingleQuotes(selected_channel) + '\' ';
        }
        if(searchPAFObj.ASI_HK_CRM_PAF_Customer__c != null) {
            filter += ' AND ASI_HK_CRM_PAF_Customer__c = \'' + String.escapeSingleQuotes(searchPAFObj.ASI_HK_CRM_PAF_Customer__c) + '\' ';
        }
        if(searchPAFObj.ASI_CRM_HK_PAF_no__c != null) {  //PAF no. //20160405, edited by Leo
            filter += ' AND Id = \'' + String.escapeSingleQuotes(searchPAFObj.ASI_CRM_HK_PAF_no__c) + '\' '; //20160405, edited by Leo
        }
        //20160405, added by Leo
        if(searchPAFObj.ASI_HK_CRM_SYS_Sales_Director_Approver__c != null) {  //PAF no. //20160405, edited by Leo
            filter += ' AND OwnerId = \'' + String.escapeSingleQuotes(searchPAFObj.ASI_HK_CRM_SYS_Sales_Director_Approver__c) + '\' '; //20160405, edited by Leo
        }
        //20160405, added by Leo
        if(searchPAFObj.ASI_HK_CRM_Adjusted_Start_Date__c != null) {
            String fromDate = DateTime.newInstance(searchPAFObj.ASI_HK_CRM_Adjusted_Start_Date__c.year(),searchPAFObj.ASI_HK_CRM_Adjusted_Start_Date__c.month(),searchPAFObj.ASI_HK_CRM_Adjusted_Start_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            filter += ' AND ASI_HK_CRM_Adjusted_Start_Date__c >= ' + fromDate + ''; 
        }
        if(searchPAFObj.ASI_HK_CRM_Adjusted_End_Date__c != null) {
            String toDate = DateTime.newInstance(searchPAFObj.ASI_HK_CRM_Adjusted_End_Date__c.year(),searchPAFObj.ASI_HK_CRM_Adjusted_End_Date__c.month(),searchPAFObj.ASI_HK_CRM_Adjusted_End_Date__c.day(), 0,0,0).format('yyyy-MM-dd');
            filter += ' AND ASI_HK_CRM_Adjusted_End_Date__c <= ' + toDate + ''; 
        }
        system.debug('SOQL:::' +  soql + filter);
        soql += filter;
        String ordering = ' ORDER BY ASI_CRM_Approved_Date__c DESC';
        soql += ordering;
        List<ASI_HK_CRM_Pre_Approval_Form__c> tmp = database.query(soql);
        for (ASI_HK_CRM_Pre_Approval_Form__c tmpPaf : tmp){
            ResultSet tmprs = new ResultSet();
            tmprs.PAF = tmpPaf;
            tmprs.checked = false;
            resultPAF.add(tmprs);
        }
		PageReference redirect = null; 
        
        
        return redirect;
    }
    
    public PageReference clearSearchResult() 
    {
        resultPAF.clear();
		PageReference redirect = null; 
        return redirect;
    }
    
    public PageReference clearSKUForm()
    {
        //skuMap.clear();
        lineItemList.clear();
        PageReference redirect = null;
        return redirect;
    }
    /*public PageReference GenPriceSet() 
    {
        haveError = true;
        Msg = 'Please select Pre-Approval Form';
        for (ResultSet res: resultPAF) {
            if (res.checked) {
                haveError = false;
            }   
        }

        if (!haveError) {
            
            //20151231 Ben @ Elufa Systems
            
            Map<String, Set<ASI_HK_CRM_Pre_Approval_Form__c>> mapPAFByChannel = new Map<String, Set<ASI_HK_CRM_Pre_Approval_Form__c>>();
            
            for(ResultSet obj : resultPAF){
                if(obj.checked){
                    
                    Set<ASI_HK_CRM_Pre_Approval_Form__c> tmpPAFSet = new Set<ASI_HK_CRM_Pre_Approval_Form__c>();
                    
                    if(mapPAFByChannel.containsKey(obj.PAF.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c))
                        tmpPAFSet = mapPAFByChannel.get(obj.PAF.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c);
                    
                    tmpPAFSet.add(obj.PAF);
                    
                    mapPAFByChannel.put(obj.PAF.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c, tmpPAFSet);
                }
            }
            
            Map<Id, Set<String>> mapChannelAdmin = new Map<Id, Set<String>>();
            Map<String, Id> mapAdminByChannel = new Map<String, Id>();
            
            for(ASI_HK_CRM_Channel_Local_Channel_Map__c obj : [SELECT id
                                                               , ASI_HK_CRM_Channel_Map_Unique_ID__c
                                                               , ASI_CRM_Channel_Admin__c 
                                                               FROM ASI_HK_CRM_Channel_Local_Channel_Map__c 
                                                               WHERE recordType.DeveloperName Like 'ASI_HK_CRM_Channel_to_Local_Channel_Map'
                                                              ]){
                                                                  mapAdminByChannel.put(obj.ASI_HK_CRM_Channel_Map_Unique_ID__c, obj.ASI_CRM_Channel_Admin__c);
                                                                  
                                                                  Set<String> tmpChannelSet = new Set<String>();
                                                                  
                                                                  if(mapChannelAdmin.containsKey(obj.ASI_CRM_Channel_Admin__c))
                                                                      tmpChannelSet = mapChannelAdmin.get(obj.ASI_CRM_Channel_Admin__c);
                                                                  
                                                                  tmpChannelSet.add(obj.ASI_HK_CRM_Channel_Map_Unique_ID__c);
                                                                  
                                                                  mapChannelAdmin.put(obj.ASI_CRM_Channel_Admin__c, tmpChannelSet);
                                                              }
            
            List<ASI_CRM_Price_Set_Generation_Log__c> priceSetLogList = new List<ASI_CRM_Price_Set_Generation_Log__c>([SELECT id
                                                                                                                       , OwnerId
                                                                                                                       FROM ASI_CRM_Price_Set_Generation_Log__c
                                                                                                                       WHERE OwnerId IN : mapChannelAdmin.keySet()
                                                                                                                       AND ASI_CRM_Status__c = 'Draft'
                                                                                                                       ORDER BY createdDate ASC
                                                                                                                      ]);
            
            List<ASI_CRM_Price_Set_Generation_Log_Detail__c> priceSetLogDetail = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>();
            Map<Id, Set<ASI_HK_CRM_Pre_Approval_Form__c>> mapPAFByChannelAdmin = new Map<Id, Set<ASI_HK_CRM_Pre_Approval_Form__c>>();
            Map<Id, ASI_CRM_Price_Set_Generation_Log__c> priceSetLogMap = new Map<Id, ASI_CRM_Price_Set_Generation_Log__c>();
			Set<Id> pafId = new Set<Id>();			
            
            if(priceSetLogList.size() > 0){
                for(ASI_CRM_Price_Set_Generation_Log__c obj : priceSetLogList){
                    priceSetLogMap.put(obj.OwnerId, obj);
                }
                for(ASI_CRM_Price_Set_Generation_Log__c obj : priceSetLogMap.values()){
                    
                    if(mapChannelAdmin.containsKey(obj.OwnerId)){
                        
                        for(String channel : mapPAFByChannel.keySet()){
                            if(mapChannelAdmin.get(obj.OwnerId).contains(channel)){
                                
                                Set<ASI_HK_CRM_Pre_Approval_Form__c> tmpPAF = new Set<ASI_HK_CRM_Pre_Approval_Form__c>();
                                
                                if(mapPAFByChannelAdmin.containsKey(obj.OwnerId))
                                	tmpPAF = mapPAFByChannelAdmin.get(obj.OwnerId);
                                
                                tmpPAF.addAll(mapPAFByChannel.get(channel));
                                
                                mapPAFByChannelAdmin.put(obj.OwnerId, tmpPAF);
                                
                            }
                        }
                        
                        if(mapPAFByChannelAdmin.containsKey(obj.OwnerId)){
                            for(ASI_HK_CRM_Pre_Approval_Form__c paf : mapPAFByChannelAdmin.get(obj.OwnerId)){
                                
                                ASI_CRM_Price_Set_Generation_Log_Detail__c tmpDetail = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
                                
                                tmpDetail.ASI_CRM_Pre_Approval_Form__c = paf.id;
                                tmpDetail.ASI_CRM_Price_Set_Generation_Log__c = obj.id;
                                pafId.add(paf.id);
                                priceSetLogDetail.add(tmpDetail);
                            }
                        }
                    }
                }
                try{
                    
                    insert priceSetLogDetail;
                }catch(dmlexception e){
                    
                    return NULL;
                }
            }
            
            Set<Id> adminIdSet = new Set<Id>();
            List<ASI_CRM_Price_Set_Generation_Log__c> insertPriceSetLog = new List<ASI_CRM_Price_Set_Generation_Log__c>();
            //ASI_CRM_Price_Set_Generation_Log__c PriceSetLog = new ASI_CRM_Price_Set_Generation_Log__c(ASI_CRM_Status__c = 'Draft', ASI_CRM_Urgent_PriceSet__c = urgentBox, ASI_CRM_FreeText_Remark__c = freeText);
            System.debug('PS Error:');
            //insert PriceSetLog;
            
            List<ASI_CRM_Price_Set_Generation_Log_Detail__c> LogItems = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>();
            Map<Id, Id> mapHeaderbyOwner = new Map<Id, Id>();
            
            for (ResultSet res: resultPAF) {
                if (res.checked && !pafId.contains(res.PAF.id)) {//20151231 Ben @ Elufa Systems added !pafId.contains(res.PAF.id
                    
                    if(mapAdminByChannel.containsKey(res.PAF.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c)){
                        adminIdSet.add(mapAdminByChannel.get(res.PAF.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c));
                    }
                    
                    //ASI_CRM_Price_Set_Generation_Log_Detail__c Item = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
                    //Item.ASI_CRM_Pre_Approval_Form__c = res.PAF.id;
                    //Item.ASI_CRM_Price_Set_Generation_Log__c = PriceSetLog.id;
                    //LogItems.add(Item);
                }   
            }
            
            for(Id adminId : adminIdSet){
                
                ASI_CRM_Price_Set_Generation_Log__c PriceSetLog = new ASI_CRM_Price_Set_Generation_Log__c(OwnerId = adminId, ASI_CRM_Status__c = 'Draft', ASI_CRM_Urgent_PriceSet__c = urgentBox, ASI_CRM_FreeText_Remark__c = freeText);
                insertPriceSetLog.add(PriceSetLog);
            }
            try{
                
                insert insertPriceSetLog;
            }catch(dmlexception e){
                
                return NULL;
            }
            
            for(ASI_CRM_Price_Set_Generation_Log__c obj : insertPriceSetLog){
                
                mapHeaderbyOwner.put(obj.OwnerId, obj.Id);
            }
            
            for (ResultSet res: resultPAF) {
                if (res.checked && !pafId.contains(res.PAF.id) && mapAdminByChannel.containsKey(res.PAF.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c) && mapHeaderbyOwner.containsKey(mapAdminByChannel.get(res.PAF.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c))){//20151231 Ben @ Elufa Systems added !pafId.contains(res.PAF.id
                    
                    ASI_CRM_Price_Set_Generation_Log_Detail__c Item = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
                    Item.ASI_CRM_Pre_Approval_Form__c = res.PAF.id;
                    Item.ASI_CRM_Price_Set_Generation_Log__c = mapHeaderbyOwner.get(mapAdminByChannel.get(res.PAF.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c));
                    LogItems.add(Item);
                }   
            }
            try{
                
            	insert LogItems;
            }catch(dmlexception e){
                
                return NULL;
            }
            
            
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
            String listKey = gd.get('ASI_CRM_Price_Set_Generation_Log__c').getDescribe().getKeyPrefix();
            
            PageReference redirect = new PageReference('/' + listKey );//PriceSetLog.id);
            return redirect;
        }
 		//20151231 End
        else {
            return null;
        }
    }*/
    
    public PageReference GenPriceSet() 
    {
        //20160406, added by Leo
        if(!clicked)
        {
            Msg = 'Please click input free SKU before submit!';
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Msg));
            return null;
        }
        //20160406, added by Leo
            
        haveError = true;
        
        for (ResultSet res: resultPAF) {
            if (res.checked) {
                haveError = false;
            }   
        }
        if (!haveError) {
            
            //20160106 Ben @ Elufa Systems
            
            Set<Id> pafIdSet = new Set<Id>();
            
            for (ResultSet res: resultPAF) {
                if (res.checked) {
                    pafIdSet.add(res.PAF.id);
                }   
            }
            //20160125 Ray
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> PAFitemList 
                 = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>([SELECT id
                                                                   , ASI_CRM_HK_Free_SKU__c
                                                                   FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
                                                                   WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c IN : pafIdSet
                                                                   //And ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c In ('V0001', 'V0007') //20160406, edited by Leo
                                                                   And (ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC' //20160406, edited by Leo
                                                                        OR ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC Bulk') //20160406, edited by Leo
                                                                  ]);
            if (PAFitemList.size() > 0){
                for (ASI_HK_CRM_Pre_Approval_Form_Item__c tmp: PAFitemList){
                    system.debug(tmp.ASI_CRM_HK_Free_SKU__c);
                    if (tmp.ASI_CRM_HK_Free_SKU__c == null){//} || tmp.ASI_CRM_HK_Free_SKU__c == ''){
                        haveError = true;
                    	Msg = 'Please input all free SKUs before submit';
                        apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Msg));
                    	return null;
                    }
                }
            }
            
            
            if(pafIdSet.size() > 0){
                List<ASI_HK_CRM_Pre_Approval_Form__c> pafList = new List<ASI_HK_CRM_Pre_Approval_Form__c>([SELECT id
                                                                                                           FROM ASI_HK_CRM_Pre_Approval_Form__c
                                                                                                           WHERE id IN : pafIdSet
                                                                                                           AND ASI_HK_CRM_PAF_Customer__r.recordType.DeveloperName LIKE 'ASI_HK_CRM_Potential%'
                                                                                                           AND ( ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c = ''
                                                                                                                OR ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c = NULL )
                                                                                                           AND (NOT ASI_HK_CRM_PAF_Customer__r.Name LIKE 'OUTLET_%')
                                                                                                          ]);
                
                if(pafList.size() > 0){
                    haveError = true;
                    Msg = 'For Potential Customer JDE Code can not be null';
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Msg));
                    return null;
                }
            }
            
        //20160106 End
            
            List<ASI_CRM_HK_PriceSetOwner__c> customSetting = new List<ASI_CRM_HK_PriceSetOwner__c>([SELECT ASI_CRM_HK_PriceSet_OwnerId__c FROM ASI_CRM_HK_PriceSetOwner__c WHERE ASI_CRM_HK_isActive__c = TRUE ORDER BY CreatedDate DESC]);
            
            String owernIdStr;
            if(customSetting.size() > 0)
            	owernIdStr = customSetting[0].ASI_CRM_HK_PriceSet_OwnerId__c;
            
            List<ASI_CRM_Price_Set_Generation_Log__c> priceSetLogList = new List<ASI_CRM_Price_Set_Generation_Log__c>();
            if(owernIdStr != '' && owernIdStr != NULL){
                priceSetLogList = [SELECT id
                                   FROM ASI_CRM_Price_Set_Generation_Log__c
                                   WHERE OwnerId = : owernIdStr
                                   AND ASI_CRM_Status__c = 'Draft'
                                   ORDER BY createdDate DESC
                                  ];
            }
            ASI_CRM_Price_Set_Generation_Log__c PriceSetLog;
            
            if(priceSetLogList.size() > 0){
                PriceSetLog = priceSetLogList[0];
            }else{
                //Cange owner
                //PriceSetLog = new ASI_CRM_Price_Set_Generation_Log__c(ASI_CRM_Status__c = 'Draft', ASI_CRM_Urgent_PriceSet__c = urgentBox, ASI_CRM_FreeText_Remark__c = freeText, OwnerId = (owernIdStr != '' && owernIdStr != NULL ? owernIdStr : userInfo.getUserId()));
                PriceSetLog = new ASI_CRM_Price_Set_Generation_Log__c(ASI_CRM_Status__c = 'Draft', ASI_CRM_Urgent_PriceSet__c = urgentBox, ASI_CRM_FreeText_Remark__c = freeText, OwnerId = userInfo.getUserId());
                System.debug('PS Error:');
                insert PriceSetLog;
            }
            
            
            List<ASI_CRM_Price_Set_Generation_Log_Detail__c> LogItems = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>();
            for (ResultSet res: resultPAF) {
                if (res.checked) {
                    ASI_CRM_Price_Set_Generation_Log_Detail__c Item = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
                    Item.ASI_CRM_Pre_Approval_Form__c = res.PAF.id;
                    Item.ASI_CRM_Price_Set_Generation_Log__c = PriceSetLog.id;
                    LogItems.add(Item);
                }   
            }
            try{
                insert LogItems;
            }catch(dmlException e){
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
                return NULL;
            }
            
            PageReference redirect = new PageReference('/' + PriceSetLog.id); 
            return redirect;
        }
        else {
            Msg = 'Please select Pre-Approval Form';
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Msg));
            return null;
        }
    }
    
    public PageReference GenPriceSetForONEPAF() 
    {            
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> PAFitemList 
            = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>([SELECT id
                                                              , ASI_CRM_HK_Free_SKU__c
                                                              FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
                                                              WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c = : PAFId
                                                              //And ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c In ('V0001', 'V0007') //20160406, edited by Leo
                                                              And (ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC' //20160406, edited by Leo
                                                                   OR ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC Bulk') //20160406, edited by Leo
                                                             ]);
        
        if (PAFitemList.size() > 0){
            for (ASI_HK_CRM_Pre_Approval_Form_Item__c tmp: PAFitemList){
                system.debug('tmp.ASI_CRM_HK_Free_SKU__c : '+tmp.ASI_CRM_HK_Free_SKU__c);
                if (tmp.ASI_CRM_HK_Free_SKU__c == null){//} || tmp.ASI_CRM_HK_Free_SKU__c == ''){
                    haveError = true;
                    Msg = 'Please input all free SKUs before submit';
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Msg));
                    return null;
                }
            }
        }
        
        
        List<ASI_HK_CRM_Pre_Approval_Form__c> pafList = new List<ASI_HK_CRM_Pre_Approval_Form__c>([SELECT id
                                                                                                   FROM ASI_HK_CRM_Pre_Approval_Form__c
                                                                                                   WHERE id = : PAFId
                                                                                                   AND ASI_HK_CRM_PAF_Customer__r.recordType.DeveloperName LIKE 'ASI_HK_CRM_Potential%'
                                                                                                   AND ( ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c = ''
                                                                                                        OR ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_JDE_Account_Number__c = NULL )
                                                                                                   AND (NOT ASI_HK_CRM_PAF_Customer__r.Name LIKE 'OUTLET_%')
                                                                                                  ]);
        
        if(pafList.size() > 0){
            haveError = true;
            Msg = 'For Potential Customer JDE Code can not be null';
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Msg));
            return null;
        }
        
        
        //20160106 End
        
        List<ASI_CRM_HK_PriceSetOwner__c> customSetting = new List<ASI_CRM_HK_PriceSetOwner__c>([SELECT ASI_CRM_HK_PriceSet_OwnerId__c FROM ASI_CRM_HK_PriceSetOwner__c WHERE ASI_CRM_HK_isActive__c = TRUE ORDER BY CreatedDate DESC]);
        
        String owernIdStr;
        if(customSetting.size() > 0)
            owernIdStr = customSetting[0].ASI_CRM_HK_PriceSet_OwnerId__c;
        
        List<ASI_CRM_Price_Set_Generation_Log__c> priceSetLogList = new List<ASI_CRM_Price_Set_Generation_Log__c>();
        if(owernIdStr != '' && owernIdStr != NULL){
            priceSetLogList = [SELECT id
                               FROM ASI_CRM_Price_Set_Generation_Log__c
                               WHERE OwnerId = : owernIdStr
                               AND ASI_CRM_Status__c = 'Draft'
                               ORDER BY createdDate DESC
                              ];
        }
        ASI_CRM_Price_Set_Generation_Log__c PriceSetLog;
        
        if(priceSetLogList.size() > 0){
            PriceSetLog = priceSetLogList[0];
        }else{
            //Cange owner
            //PriceSetLog = new ASI_CRM_Price_Set_Generation_Log__c(ASI_CRM_Status__c = 'Draft', ASI_CRM_Urgent_PriceSet__c = urgentBox, ASI_CRM_FreeText_Remark__c = freeText, OwnerId = (owernIdStr != '' && owernIdStr != NULL ? owernIdStr : userInfo.getUserId()));
            PriceSetLog = new ASI_CRM_Price_Set_Generation_Log__c(ASI_CRM_Status__c = 'Draft', ASI_CRM_Urgent_PriceSet__c = urgentBox, ASI_CRM_FreeText_Remark__c = freeText, OwnerId = userInfo.getUserId());
            System.debug('PS Error:');
            insert PriceSetLog;
        }
        
        
        List<ASI_CRM_Price_Set_Generation_Log_Detail__c> LogItems = new List<ASI_CRM_Price_Set_Generation_Log_Detail__c>();
        ASI_CRM_Price_Set_Generation_Log_Detail__c Item = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
        Item.ASI_CRM_Pre_Approval_Form__c = PAFId;
        Item.ASI_CRM_Price_Set_Generation_Log__c = PriceSetLog.id;
        LogItems.add(Item);
        try{
            insert LogItems;
        }catch(dmlException e){
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
            return NULL;
        }
        
        PageReference redirect = new PageReference('/' + PriceSetLog.id); 
        return redirect;        
    } 
    
    public PageReference Cancel() 
    {
        PageReference redirect = new PageReference(ApexPages.currentPage().getHeaders().get('Referer')); 
        return redirect;
    }
    
    public PageReference ReturnPage() 
    {
        PageReference returnPage = sctrl.cancel();
        return returnPage;
    }
    
    //****** SAPL Line Item - functions - (end) ******
    @RemoteAction
    public static String[] findCustSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        Map<String, id> MRecType = ASI_MFM_Function.getRecordTypeId('account');
        List<String> types = qry.split(';');
        List<string> rts = new List<String>();
        for(String rt : types){
            rts.add(MRecType.get(rt));
        }
        String filter;
        filter = ' WHERE recordtypeid IN :rts ';
        
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
    
    //****** End Other Method ****//
    
    //20151127 Ben @ Elufa System
    Public PageReference lineItemMethod(){
        clicked = true; //20160406, added by Leo
        lineItemList.clear();
        skuMap.clear();
        Set<String> PAFid = new Set<String>();
        Boolean haveError2 = true;
        for (ResultSet res: resultPAF) {
            if (res.checked) {
                haveError2 = false;
            }   
        }
        if (!haveError2) {
            
            for (ResultSet res: resultPAF) {
                if (res.checked) {
                    PAFid.add(res.PAF.id);
                }   
            }
            
            lineItemList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>([SELECT id
                                                                          , ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name
                                                                          , ASI_CRM_HK_Free_SKU__r.Name
                                                                          , ASI_CRM_HK_Free_SKU__c
                                                                          , ASI_HK_CRM_SKU_Lookup__c
                                                                          , ASI_HK_CRM_SKU_Lookup__r.Name
                                                                          , ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_Inventory__c
                                                                          , ASI_CRM_HK_Pricing_Item__c
                                                                          , ASI_HK_CRM_Mechanic__c
                                                                          , ASI_HK_CRM_Mechanic__r.Name
                                                                          , ASI_CRM_HK_Pricing_Code__c //20151231, Leo@Elufa
                                                                          , ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__c //20151231, Leo@Elufa
                                                                          FROM ASI_HK_CRM_Pre_Approval_Form_Item__c 
                                                                          WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c IN : PAFid
                                                                          //And ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c In ('V0001', 'V0007')
                                                                          And (ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC' //20160322, edited by Leo
                                                                               OR ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC Bulk') //20160322, edited by Leo
                                                                          Order BY ASI_HK_CRM_Pre_Approval_Form_Lookup__r.Name Asc]);//Add filter logic here
            
            //20151231, Leo@Elufa
            Set<String> pricingCodeSet = new Set<String>();
            Map<String,Set<lineItemClass>> pcSKUmap = new Map<String,Set<lineItemClass>>(); //map<item group name, list<sku>>
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c line: lineItemList)
            {
				if(line.ASI_CRM_HK_Pricing_Code__c != NULL && line.ASI_CRM_HK_Pricing_Code__c != '')
					pricingCodeSet.add(line.ASI_CRM_HK_Pricing_Code__c); //set of line item pricing code
                if(line.ASI_CRM_HK_Free_SKU__c == null)
                {
                    Set<lineItemClass> tmpClass = new Set<lineItemClass>();
                    lineItemClass tmpClass2 = new lineItemClass();
                    tmpClass2.id = '';
                    tmpClass2.FreeSKU = '';
                    tmpClass2.inventory = 'Inventory: -'; //20160406, added by Leo
                    tmpClass.add(tmpClass2);
                    //Set<SelectOption> tempList = new Set<SelectOption>();
                    //tempList.add(new SelectOption('', ''));
                	pcSKUmap.put(line.ASI_CRM_HK_Pricing_Code__c, tmpClass);
                }//end if
                /*else if(line.ASI_CRM_HK_Free_SKU__c != null)
                {
                    Set<lineItemClass> tmpClass = new Set<lineItemClass>();
                    lineItemClass tmpClass2 = new lineItemClass();
                    tmpClass2.id = line.ASI_CRM_HK_Free_SKU__c;
                    tmpClass2.FreeSKU = line.ASI_CRM_HK_Free_SKU__r.Name;
                    tmpClass.add(tmpClass2);
                    //Set<SelectOption> tempList = new Set<SelectOption>();
                    //tempList.add(new SelectOption(line.ASI_CRM_HK_Free_SKU__c, line.ASI_CRM_HK_Free_SKU__r.Name));
                	pcSKUmap.put(line.ASI_CRM_HK_Pricing_Code__c, tmpClass); 
                }//end else*/
                System.Debug('CHECK 1.0: '+pricingCodeSet);
            }//end for
            
            List<ASI_MFM_SKU_Code__c> skuList //list of sku, filter by record type, item group name (paf line pricing code)
                = new List<ASI_MFM_SKU_Code__c>([SELECT id, Name, 
                                                 ASI_MFM_Item_Group__c,
                                                 ASI_MFM_Item_Group__r.Name,
                                                 ASI_HK_CRM_Inventory__c
                                                 FROM ASI_MFM_SKU_Code__c 
                                                 WHERE recordType.DeveloperName = 'ASI_HK_CRM_SKU' 
                                                 AND ASI_MFM_Item_Group__r.Name IN: pricingCodeSet 
                                                 AND ASI_HK_CRM_Active__c = TRUE 
                                                 ORDER BY ASI_HK_CRM_Inventory__c DESC]);
            System.Debug('CHECK 2.0: '+skuList);
            
            for(ASI_MFM_SKU_Code__c sku: skuList)
            {
                if(!pcSKUmap.containsKey(sku.ASI_MFM_Item_Group__r.Name)) //if map does not contains key(item group name), add in map
                {
                    Set<lineItemClass> tmpClass = new Set<lineItemClass>();
                    lineItemClass tmpClass2 = new lineItemClass();
                    
                    tmpClass2.id = sku.id;
                    tmpClass2.FreeSKU = sku.Name;
                    tmpClass2.inventory = 'Inventory: '+sku.ASI_HK_CRM_Inventory__c; //20160406, added by Leo
                    tmpClass.add(tmpClass2);
                    
                    //Set<SelectOption> tempList = new Set<SelectOption>();
                    //tempList.add(new SelectOption(sku.id, sku.Name));
                    pcSKUmap.put(sku.ASI_MFM_Item_Group__r.Name, tmpClass);
                    System.Debug('CHECK 3.0: '+pcSKUmap);
                }//end if
                else
                {
                    Set<lineItemClass> tmpClass = pcSKUmap.get(sku.ASI_MFM_Item_Group__r.Name);
                    //Set<SelectOption> tempList = pcSKUmap.get(sku.ASI_MFM_Item_Group__r.Name);
                    
                    lineItemClass tmpClass2 = new lineItemClass();
                    
                    tmpClass2.id = sku.id;
                    tmpClass2.FreeSKU = sku.Name;
                    tmpClass2.inventory = 'Inventory: '+sku.ASI_HK_CRM_Inventory__c; //20160406, added by Leo
                    tmpClass.add(tmpClass2);
                    
                    //tempList.add(new SelectOption(sku.id, sku.Name));
                    pcSKUmap.put(sku.ASI_MFM_Item_Group__r.Name, tmpClass);
                    System.Debug('CHECK 3.1: '+pcSKUmap);
                }//end else
            }//end for
            
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c line: lineItemList)
            {
                if(pcSKUmap.containsKey(line.ASI_CRM_HK_Pricing_Code__c))
                {
                    skuMap.put(line.id, pcSKUmap.get(line.ASI_CRM_HK_Pricing_Code__c));
                    System.Debug('CHECK 4.0: '+skuMap);
                }//end if
                else
                {
                    Set<lineItemClass> tmpClass = new Set<lineItemClass>();
                    
                    lineItemClass tmpClass2 = new lineItemClass();
                    
                    tmpClass2.id = '';
                    tmpClass2.FreeSKU = '';
                    tmpClass2.inventory = 'Inventory: -'; //20160406, added by Leo
                    //Set<SelectOption> tempList = new Set<SelectOption>();
                    //tempList.add(new SelectOption('', ''));
                    tmpClass.add(tmpClass2);
                    skuMap.put(line.id, tmpClass);
                    System.Debug('CHECK 4.1: '+skuMap);
                }//end else
            }//end for
            //20151231, Leo@Elufa
        }
        
        PageReference redirect = null;
        
        return redirect;
    }
    
    @RemoteAction
    public static String[] findCustSObjects2(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        Map<String, id> MRecType = ASI_MFM_Function.getRecordTypeId('ASI_MFM_SKU_Code__c');
        List<String> types = qry.split(';');
        List<string> rts = new List<String>();
        for(String rt : types){
            rts.add(MRecType.get(rt));
        }
        String filter;
        filter = ' WHERE recordtypeid IN :rts ';//Add filter logic here
        
        //begin building the dynamic soql query
        
        String soql = 'select id, Name, ASI_HK_CRM_Inventory__c from ' + obj + filter +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            
            for(sObject sobj : sobjs){
                String a = sobj.get('ASI_HK_CRM_Inventory__c') != NULL && sobj.get('ASI_HK_CRM_Inventory__c') != '' ? String.valueOf(sobj.get('ASI_HK_CRM_Inventory__c')) : '0';
                results.add(String.valueOf(sobj.get('Name')) + '$$$' + a + '%%%%' + sobj.id);//20160103
            }
            System.debug('results:' + results);
        }
        catch (QueryException e) {
            return null;
        }
        return results;
    }
    
    @RemoteAction
    Public static Boolean saveResult(List<lineItemClass> lineItems) {
        //20160104, modified by Leo@Elufa
        //List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>([SELECT id, name FROM ASI_MFM_SKU_Code__c WHERE recordType.DeveloperName = 'ASI_HK_CRM_SKU']);//Add filter logic here
        //Map<String, String> mapSKUByName = new Map<String, String>();
        //20160104, modified by Leo@Elufa
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> updateLineItemList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        
        /*for(ASI_MFM_SKU_Code__c obj : skuList){
            mapSKUByName.put(obj.Name, Obj.id);
        }*/ //20160104, modified by Leo@Elufa
        
        Set<String> pafLineItemId = new Set<String>(); 
        //add 20160121
        for(lineItemClass obj : lineItems){
            ASI_HK_CRM_Pre_Approval_Form_Item__c updateLineItem = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
            system.debug('check111 ' + obj.FreeSKU);
            updateLineItem.id = obj.id;
            
            pafLineItemId.add(obj.id);
            
            //updateLineItem.ASI_CRM_HK_Free_SKU__c = mapSKUByName.containsKey(obj.FreeSKU) ? mapSKUByName.get(obj.FreeSKU) : NULL; 
            //20160104, modified by Leo@Elufa
            if(obj.FreeSKU != null && obj.FreeSKU !='')
            	updateLineItem.ASI_CRM_HK_Free_SKU__c = obj.FreeSKU;
            else
                updateLineItem.ASI_CRM_HK_Free_SKU__c = null;
            //20160104, modified by Leo@Elufa
            
            updateLineItemList.add(updateLineItem);
        }
        
        if(updateLineItemList.size() > 0){
            try{
                update updateLineItemList;
                return true;
            }catch(dmlException e){
                return false;
            }
        }
        return true;
    }
    //@RemoteAction
    Public static void passMsgToCtl(String eMsg){
        //this.Msg = eMsg;
    }
    
    Public class lineItemClass{
        public String id { get; set; }
        public String FreeSKU { get; set; }
        public String inventory {get; set;} //20160406, added by Leo
    }
    //20151127 End
    //
    private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
    private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }
}