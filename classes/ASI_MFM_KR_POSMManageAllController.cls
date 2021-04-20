public class ASI_MFM_KR_POSMManageAllController {
    
    public final String STATUS_LOCKED = 'Locked';
    
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;} 
    public boolean EmailUpsertPermission {get;set;}{EmailUpsertPermission=true;}  
    public boolean SaveSuccess {get;set;}
    public boolean SentSuccess {get;set;}
    public ASI_KOR_POSM_Order_Request__c posmReqHeader { get; set; }
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public String msg {get;set;}    
    
    public ASI_KOR_POSM_Order_Detail__c create_POSMdetailrtID  {get;set;}
    
    
    public List<ASI_KOR_POSM_Order_Detail__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_KOR_POSM_Order_Detail__c>();}
    
    public Map<String, interimData> allPOSMLineMap {get;set;}{ allPOSMLineMap = new Map<String, interimData>();}
    public Map<String, ASI_MFM_Sub_brand__c> allSubBrandMap {get;set;}{ allSubBrandMap = new Map<String, ASI_MFM_Sub_brand__c>();}
    public Map<String, ASI_KOR_POSM_Product__c> POSMproductMap {get;set;}{ POSMproductMap = new Map<String, ASI_KOR_POSM_Product__c>();}
    
    //For email 
    public Map<id, List<ASI_KOR_POSM_Order_Detail__c>> SupplierLinesMap {get;set;}{ SupplierLinesMap = new Map<id,  List<ASI_KOR_POSM_Order_Detail__c>> ();}
    public Map<id, ASI_KOR_POSM_Order_Detail__c> LinesMap {get;set;}{ LinesMap = new Map<id,  ASI_KOR_POSM_Order_Detail__c> ();}
    public Map<ID, List<Attachment>> LineIdAttMap {get;set;}{ LineIdAttMap = new Map<ID,  List<Attachment>> ();}
    public Map<String, List<Attachment>> SupplierAttMap {get;set;}{ SupplierAttMap = new Map<String,  List<Attachment>> ();}
    
    
    public Class interimData{
        public ASI_KOR_POSM_Order_Detail__c linesItems {get; set;}
        public String BrandGroup {set;get;}   
        public String Brand {set;get;} 
        public String SubBrand {set;get;} 
        public String SalesBrand {set;get;}    
        public String ProductItem {set;get;} 
        public String BrandGroupID {set;get;}   
        public String BrandID {set;get;} 
        public String SubBrandID {set;get;} 
        public String ProductItemID {set;get;} 
        public String SupplierID {set;get;} 
        public String Supplier {set;get;}
        public Decimal Amount {get; set;}
        public Boolean isProcess {set;get;}
        public String SalesBranch {set;get;}    //Sales Branch Name - default from header
    } 
    
    
    public ASI_MFM_KR_POSMManageAllController(ApexPages.StandardSetController stdSetController) {
        String posmReqHeaderId = ApexPages.currentPage().getParameters().get('id');
        this.posmReqHeader = [SELECT Id,Name, ownerid, ASI_KOR_Request_Date__c, ASI_KOR_Status__c,ASI_MFM_Item_Category__c,
                              ASI_MFM_KR_Email_Sent__c,ASI_MFM_KR_EmailSentTime__c, ASI_KOR_POSM_TO_Venue__c,ASI_KOR_Requested_Date__c ,   ASI_KOR_POSM_TO_Venue__r.name,ASI_MFM_Sales_Branch__c,
                              (SELECT Id, ASI_KOR_Item_Name__c FROM ASI_KOR_POSM_Order_Details__r) FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReqHeaderId];
        
        
    }
    
    //public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public pageReference init(){  
        //if(posmReqHeader.ASI_MFM_Item_Category__c!=null && posmReqHeader.ASI_MFM_Item_Category__c=='Brand'){
          //  return new pageReference('/apex/ASI_MFM_KR_POSMManageAllPage2?scontrolCaching=1&id='+posmReqHeader.Id);
        //}
        //POSM Line 
        
        List<ASI_KOR_POSM_Order_Detail__c> POSMlineItemList = [select id, name, ASI_KOR_POSM_Order_Request__c,ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__c, ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__r.name, ASI_KOR_POSM_Order_Request__r.ASI_KOR_Status__c, ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c, ASI_KOR_Remarks__c, ASI_KOR_Quantity__c,
                                                               ASI_KOR_Item_Name__r.name, ASI_KOR_Item_Name__c,ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__c, ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.ASI_MFM_Brand__c, 
                                                               ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__c,
                                                               ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.name, ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.ASI_MFM_Brand__r.name, ASI_KOR_Supplier__c,ASI_KOR_Supplier__r.name,
                                                               ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.name, 
                                                               ASI_KOR_UnitCost__c, ASI_KOR_TotalAmount__c  ,   ASI_KOR_SequenceNumber__c, ASI_KOR_UOM__c ,
                                                               ASI_MFM_KR_Supplier_Email__c, ASI_KOR_POSM_Order_Request__r.ASI_MFM_KR_Email_Sent__c, ASI_KOR_POSM_Order_Request__r.ASI_MFM_Sales_Branch__c
                                                               from ASI_KOR_POSM_Order_Detail__c where ASI_KOR_POSM_Order_Request__c =: posmReqHeader.id];
        
        
        if(!POSMlineItemList.isEmpty()){ // Get existing data
            for(ASI_KOR_POSM_Order_Detail__c POSMline : POSMlineItemList){   
                String porlId = (String)(POSMline.id); 
                if(!allPOSMLineMap.containsKey(porlId)){   
                    interimData temp= new interimData();
                    temp.linesItems=POSMline;
                    
                    // temp.SalesBrand = POSMline.ASI_KOR_Sales_Branch__r.ASI_eForm_Employee_Branch_Code__c;
                    temp.BrandGroup=POSMline.ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.name;
                    temp.Brand=POSMline.ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.ASI_MFM_Brand__r.name;
                    temp.SubBrand=POSMline.ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.name;
                    temp.BrandGroupID=POSMline.ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__c;
                    temp.BrandID=POSMline.ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__r.ASI_MFM_Brand__c;
                    temp.SubBrandID=POSMline.ASI_KOR_Item_Name__r.ASI_MFM_Sub_Brand__c;
                    
                    temp.ProductItemID =POSMline.ASI_KOR_Item_Name__c;
                    temp.ProductItem =POSMline.ASI_KOR_Item_Name__r.name;
                    
                    temp.SupplierID =  POSMline.ASI_KOR_Supplier__c;
                    temp.Supplier =  POSMline.ASI_KOR_Supplier__r.name;   
                    
                    temp.SalesBranch = POSMline.ASI_KOR_POSM_Order_Request__r.ASI_MFM_Sales_Branch__c;
                    
                    // system.assertEquals(temp.SalesBranch, null);
                    if(POSMline.ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c != null && POSMline.ASI_KOR_Quantity__c !=null){
                        temp.Amount = POSMline.ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c * POSMline.ASI_KOR_Quantity__c;}
                    
                    allPOSMLineMap.put(porlId, temp);
                    
                    //porlineID_set.add(porlId); 
                    
                    LinesMap.put(POSMline.id, POSMline);
                    
                    //For supplier email:
                    //SupplierEmailMap.put(POSMline.ASI_KOR_Supplier__c, POSMline);
                    SupplierLinesMap.put(POSMline.ASI_KOR_Supplier__c, POSMlineItemList);
                    //system.assertEquals(SupplierEmailMap, null);
                }
            }
        }
        return null;
    }
    
    
    public void addLineItem(){
        UpsertPermission = true;
        SaveSuccess = false;
        
        
        string newIDCounter = newCounterCreatorLine();
        interimData temp= new interimData();
        
        temp.linesItems=new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_POSM_Order_Request__c=posmReqHeader.id);
        
        allPOSMLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
        
        
    }
    
    
    public String newCounterCreatorLine()
    {
        String idNew;
        if(LINE_ITEM_NEWRECORD_COUNTER == null)
        {
            LINE_ITEM_NEWRECORD_COUNTER = 0;
        }//end if
        else
        {
            LINE_ITEM_NEWRECORD_COUNTER+=1;
        }//end else
        
        String zParser = '';
        Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;
        
        if(LINE_ITEM_NEWRECORD_COUNTER > 9)
        {
            Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++)
            {
                zParser += 'z';
            }//end for
            oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
        }//end if
        
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
    }//end method: newCounterCreatorLine
    
    
    
    
    /*Method: For Auto-Complete*/
    @RemoteAction
    public static List<sObject> findSObjects(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        // create the filter text
        String filter = qry;
        
        
        //begin building the dynamic soql query
        
        //String soql = 'select Id, Name from ' + obj + filter +' order by Name limit 100';
        String soql = 'select Id, Name, ASI_LUX_Email_Business__c from ' + obj + filter +' order by Name';
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            return sobjs; 
        }
        catch (QueryException e) {
            return null;
        }
        return sobjs;
    }
    
    
    
    @RemoteAction
    public static List<sObject> findPOSMproduct(string obj, string qry) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        // create the filter text
        String filter = qry;
        
        
        
        //begin building the dynamic soql query
        
        String soql = 'select Id, Name, ASI_MFM_Sub_Brand__c, ASI_MFM_Sub_Brand__r.Name,ASI_MFM_UnitCost__c, ASI_KOR_UOM__c from ' + obj   +' where   ASI_MFM_Sub_Brand__c !=null  and recordtype.developername = \'ASI_KOR_POSM_Product\' and  ASI_MFM_Item_Category__c = \'Trade MKT\' order by Name'; 
        //String soql = 'select Id, Name, ASI_MFM_Sub_Brand__c, ASI_MFM_Sub_Brand__r.Name, ASI_MFM_UnitCost__c from ' + obj + filter  +' where ASI_MFM_Sub_Brand__c !=null  order by Name'; 
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        
        try {
            sobjs = Database.query(soql);
            return sobjs; 
        }
        catch (QueryException e) { 
            return null;
        }
        return sobjs;
    }
    
    
    //kammy start:
    public PageReference saveLinetems(){
        PageReference pageRef = null;
        
        UpsertPermission = true;
        SaveSuccess = false;        
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);    
        
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        
        List<ASI_KOR_POSM_Order_Detail__c> upsertTargetList = new List<ASI_KOR_POSM_Order_Detail__c>();
        
        Boolean isRedirect = True; 
        
        if(!allPOSMLineMap.isEmpty())
        {
            isRedirect =  valdationCheckingStep(allPOSMLineMap);
            
        }//end if
        
        
        if(!isRedirect)
        {
            UpsertPermission = false;
            SaveSuccess = false;
            return null;
        }//end if
        
        system.debug('isRedirect:' + isRedirect);
        
        create_POSMdetailrtID = new ASI_KOR_POSM_Order_Detail__c();
        create_POSMdetailrtID.recordTypeID = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail');
        string developername = create_POSMdetailrtID.recordTypeID;
        if(UpsertPermission)
        {
            for(String key : allPOSMLineMap.keySet())
            {
                ASI_KOR_POSM_Order_Detail__c PLtemp =new ASI_KOR_POSM_Order_Detail__c();
                PLtemp=allPOSMLineMap.get(key).linesitems;
                
                //Sub brand
                if(String.isNotEmpty(allPOSMLineMap.get(key).SubBrandID))
                {
                    PLtemp.ASI_KOR_SubBrand__c= Id.valueOf(allPOSMLineMap.get(key).SubBrandID);
                }//end if
                
                //ProductItemID
                if(String.isNotEmpty(allPOSMLineMap.get(key).ProductItemID))
                {
                    PLtemp.ASI_KOR_Item_Name__c= Id.valueOf(allPOSMLineMap.get(key).ProductItemID);
                }//end if
                
                //Record Type
                if(developername != null)  
                {
                    PLtemp.recordtypeid= Id.valueOf(developername);
                }//end if
                
                //system.assertEquals(Id.valueOf(allPOSMLineMap.get(key).SupplierID),null);
                
                //SupplierID    
                if(String.isNotEmpty(allPOSMLineMap.get(key).SupplierID) && String.isNotEmpty(allPOSMLineMap.get(key).Supplier))
                {
                    PLtemp.ASI_KOR_Supplier__c= Id.valueOf(allPOSMLineMap.get(key).SupplierID);
                }//end if 
                
                // system.assertEquals(allPOSMLineMap.get(key).Supplier,null);
                if(allPOSMLineMap.get(key).Supplier == '' || allPOSMLineMap.get(key).Supplier == null)
                {
                    PLtemp.ASI_KOR_Supplier__c = null;
                }//end if 
                
                if( PLtemp.recordtypeid != null)
                {
                    if(String.isNotEmpty(allPOSMLineMap.get(key).ProductItemID) &&
                       String.isNotEmpty(allPOSMLineMap.get(key).SubBrandID))//&&
                        // String.isNotEmpty(allPOSMLineMap.get(key).SupplierID)) 
                    {
                        
                        upsertTargetList.add(PLtemp);
                    }//end if
                }
                
            }//end for
        }//end if
        system.debug('Upsert:' + upsertTargetList);
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try
        {
            if(deleteLineItemList.size()>0)
            {
                deleteTarget = Database.delete(deleteLineItemList);
                deleteLineItemList.clear();
            }//end if
            if(upsertTargetList.size()>0)
            {
                upsertTarget = Database.upsert(upsertTargetList);
                SaveSuccess = true;
            }
            else
            {
                SaveSuccess = false;
            }
        }//end try
        catch(Exception e)
        {
            //string msg = '';
            //msg += 'Save Error : ' +e.getMessage() + '</br>';
            pageRef = null;
            Database.rollback(pSavepoint);      
            UpsertPermission = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,e.getDmlMessage(0)));
            return null;
        }//end catch
        
        if (!isQuickSave && UpsertPermission)
        {
            pageRef = new PageReference('/'+posmReqHeader.Id);
            pageRef.setRedirect(true);
        }//end if
        else
        {
            pageRef=null;
        }//end else
        
        return pageRef;  
    }
    
    public Boolean valdationCheckingStep(Map<String, interimData>allPOSMLineMap )
    {
        Boolean isProcess = true;
        Decimal totalamount=0;
        Integer idx = 1;
        msg = '';   
        
        //system.assertEquals(allPOSMLineMap,null);
        if(allPOSMLineMap == null) return false;
        
        for(String key : allPOSMLineMap.keySet())
        {
            //initalize isProcess for Line
            allPOSMLineMap.get(key).isProcess = true;
            
            //check sub-brand
            if(String.isEmpty(allPOSMLineMap.get(key).SubBrand) || String.isEmpty(allPOSMLineMap.get(key).SubBrandId))
            {
                allPOSMLineMap.get(key).linesitems.addError('Please select Sub-Brand');
                msg += 'Line ' + idx + ' : Please select Sub-Brand' + '</br>';
                allPOSMLineMap.get(key).isProcess = false;
                isProcess = false;  
                system.debug('sub-brand error:'+ allPOSMLineMap); 
            }//end if
            
            
            //check POSM product name
            if(String.isEmpty(allPOSMLineMap.get(key).ProductItemID) || String.isEmpty(allPOSMLineMap.get(key).ProductItem))
            {
                allPOSMLineMap.get(key).linesitems.addError('Please select Product Item');
                msg += 'Line ' + idx + ' : Please select Product Item' + '</br>';
                allPOSMLineMap.get(key).isProcess = false;
                isProcess = false;  
            }//end if
            
            /*
//check Supplier
if(String.isEmpty(allPOSMLineMap.get(key).Supplier) || String.isEmpty(allPOSMLineMap.get(key).SupplierID))
{
allPOSMLineMap.get(key).linesitems.addError('Please select Supplier');
msg += 'Line ' + idx + ' : Please select Supplier' + '</br>';
allPOSMLineMap.get(key).isProcess = false;
isProcess = false;  
}//end if

*/        
            
            //check Unit Cost
            if(allPOSMLineMap.get(key).linesitems.ASI_KOR_UnitCost__c==null)
            {
                allPOSMLineMap.get(key).linesitems.addError('Unit Cost can not be null.');
                //msg += 'Line ' + idx + ' : Unit Cost can not be null.' + '</br>';
                allPOSMLineMap.get(key).isProcess = false;
                isProcess = false;                
            }//end if
            
            //check Quantity
            if(allPOSMLineMap.get(key).linesitems.ASI_KOR_Quantity__c==null)
            {
                allPOSMLineMap.get(key).linesitems.addError('Quantity can not be null.');
                msg += 'Line ' + idx + ' : Please input Quantity' + '</br>';
                allPOSMLineMap.get(key).isProcess = false;
                isProcess = false;                
            }//end if
            
            //check UOM
            /*
            if(allPOSMLineMap.get(key).linesitems.ASI_KOR_UOM__c==null)
            {
            allPOSMLineMap.get(key).linesitems.addError('UOM can not be null.');
            msg += 'Line ' + idx + ' : UOM can not be null.' + '</br>';
            allPOSMLineMap.get(key).isProcess = false;
            isProcess = false;                
            }//end if
            */
            
            //check Sales Branch Name
            /*
            if(allPOSMLineMap.get(key).linesitems.ASI_KOR_Sales_Branch__c==null)
            {
            allPOSMLineMap.get(key).linesitems.addError('Sales Branch can not be null.');
            msg += 'Line ' + idx + ' : Sales Branch can not be null.' + '</br>';
            allPOSMLineMap.get(key).isProcess = false;
            isProcess = false;                
            }//end if
            */
                        
                        
            /*
            //Check Requested Date
            if(allPOSMLineMap.get(key).linesitems.ASI_KOR_Requested_Date__c==null)
            {
            allPOSMLineMap.get(key).linesitems.addError('Requested Date can not be null.');
            msg += 'Line ' + idx + ' : Requested Date can not be null.' + '</br>';
            allPOSMLineMap.get(key).isProcess = false;
            isProcess = false;                
            }//end if
            */
            if(allPOSMLineMap.get(key).linesitems.ASI_KOR_Quantity__c !=null&& allPOSMLineMap.get(key).linesitems.ASI_KOR_UnitCost__c !=null){
                allPOSMLineMap.get(key).linesitems.ASI_KOR_TotalAmount__c= allPOSMLineMap.get(key).linesitems.ASI_KOR_Quantity__c * allPOSMLineMap.get(key).linesitems.ASI_KOR_UnitCost__c;
            }
            //check Total Amount
            if(allPOSMLineMap.get(key).linesitems.ASI_KOR_TotalAmount__c==null)
            {
                allPOSMLineMap.get(key).linesitems.addError('Total Amount can not be null.');   
                //msg += 'Line ' + idx + ' : Total Amount can not be null.' + '</br>';
                allPOSMLineMap.get(key).isProcess = false;
                isProcess = false;                
            }//end if
            
            idx++;
        }//end for: loop keySet
        return isProcess;
    }
    
    
    public void removePOSMLine() {
        
        UpsertPermission = true;
        SaveSuccess = false;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_Line_ID');
        if(allPOSMLineMap.containsKey(param_Id) && !allPOSMLineMap.isEmpty())
        {
            ASI_KOR_POSM_Order_Detail__c delTarget = allPOSMLineMap.get(param_Id).linesItems;
            if(delTarget.id != null)
            {
                deleteLineItemList.add(delTarget); 
            }
            
            allPOSMLineMap.remove(param_Id);
            SaveSuccess=false;
        }
    }
    public void cloneLine()
    {
        
        UpsertPermission = true;  
        SaveSuccess = false;
        
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_clone_ID');
        if(allPOSMLineMap.containsKey(param_Id) && !allPOSMLineMap.isEmpty()){
            
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            temp.linesItems=new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_POSM_Order_Request__c=posmReqHeader.id, 
                                                             ASI_KOR_Remarks__c=allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_Remarks__c,
                                                             ASI_KOR_Quantity__c =allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_Quantity__c,
                                                             ASI_KOR_TotalAmount__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_TotalAmount__c,
                                                             ASI_KOR_UnitCost__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_UnitCost__c,
                                                             //ASI_KOR_Requested_Date__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_Requested_Date__c, 
                                                             ASI_KOR_UOM__c =  allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_UOM__c,
                                                             //ASI_KOR_Sales_Branch__c =  allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_Sales_Branch__c,
                                                             ASI_MFM_KR_Supplier_Email__c = allPOSMLineMap.get(param_Id).linesItems.ASI_MFM_KR_Supplier_Email__c);
            
            temp.SalesBranch = allPOSMLineMap.get(param_Id).SalesBranch;
            temp.Brand=allPOSMLineMap.get(param_Id).Brand; 
            temp.SubBrand=allPOSMLineMap.get(param_Id).SubBrand;
            temp.BrandID=allPOSMLineMap.get(param_Id).BrandID;  
            temp.SubBrandID=allPOSMLineMap.get(param_Id).SubBrandID;
            temp.ProductItemID =allPOSMLineMap.get(param_Id).ProductItemID;
            temp.ProductItem =allPOSMLineMap.get(param_Id).ProductItem;
            temp.SupplierID =  allPOSMLineMap.get(param_Id).SupplierID;
            temp.Supplier = allPOSMLineMap.get(param_Id).Supplier;
            temp.Amount = allPOSMLineMap.get(param_Id).Amount;
            allPOSMLineMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            
        }
    }
    
    public Boolean EmailvaldationCheckingStep(Map<String, interimData>allPOSMLineMap )
    {
        msg ='';
        Integer idx = 1;
        
        if(allPOSMLineMap == null) return false;
        
        for(String key : allPOSMLineMap.keySet())
        {
            ASI_KOR_POSM_Order_Detail__c PLtemp =new ASI_KOR_POSM_Order_Detail__c();
            PLtemp=allPOSMLineMap.get(key).linesitems;  
            
            //KAMMY
            //PLtemp.ASI_KOR_UOM__c = 'EA';
            
            if(allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c =='undefined' ||
               allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c ==null ||
               allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c ==''){
                   
                   msg += 'Line ' + idx + ' : Please input Supplier Email Address' + '</br>';
                   EmailUpsertPermission = false;
                   return false;   
                   
               }
            
            if(allPOSMLineMap.get(key).Supplier == null){
                msg += 'Line ' + idx + ' : Please input Supplier' + '</br>';
                EmailUpsertPermission = false;
                return false; 
            } 
            
            if(PLtemp.recordtypeid == null) {
                EmailUpsertPermission = false;
                EmailUpsertPermission = false;
                return false;
                // msg += 'Line ' + idx + ' : Can not be null.' + '</br>';
            }
            
            idx++;
            
        }
        
        return true;
        
    }
    

    
    public void sendEmail2(){
        //Prepare 
        EmailUpsertPermission = true;
        Integer idx = 1;
        msg = ''; 
        
        Boolean isRedirect = True; 
        
        Database.upsertResult[] upsertTarget;
        List<ASI_KOR_POSM_Order_Detail__c> upsertTargetList = new List<ASI_KOR_POSM_Order_Detail__c>();
        if(!allPOSMLineMap.isEmpty()){
            isRedirect =  EmailvaldationCheckingStep(allPOSMLineMap);
        }//end if
        
        if(!isRedirect)
        {
            EmailUpsertPermission = false;
            SentSuccess = false;
            
        }// end of sending email.
        
        
        if((EmailUpsertPermission && isRedirect) || Test.isRunningTest() ){

            Id templateId = [select id, name from EmailTemplate where developername = : 'ASI_KOR_POSM_Request'].id;
            if(templateId != null && SupplierLinesMap.size()>0 ){
                SupplierAttMap = new Map<String,  List<Attachment>> ();
                
                Set<string> SupplierIDSet = new Set<string>();
                Map<String,  List<String>>  SupplierEmailMap = new Map<String,  List<String>> ();
                Map<String,  List<String>>  SupplierLineMap = new Map<String,  List<String>> ();
                List <Attachment> AllLines = [select id, name,body,contenttype, ParentID from Attachment where ParentId in : LinesMap.keyset()]; //All related lines' attachments
                
                if(AllLines.size() > 0) {
                    for(Attachment att:  AllLines){     //for each attachment
                        string supplierCode = LinesMap.containsKey(att.ParentId)?   LinesMap.get(att.ParentId).ASI_KOR_Supplier__c:'';
                        if(SupplierAttMap.containsKey(supplierCode)){
                            SupplierAttMap.get(supplierCode).add(att);
                        }else{
                            List<Attachment> AttList = new List<Attachment>();
                            AttList.add(att);
                            SupplierAttMap.put(supplierCode,AttList);    //Map SupplierAttMap <String, <List>>
                        }
                        
                    }  
                }// End of map - supplier & Attachments
                
                for(String key : allPOSMLineMap.keySet()) {
                    ASI_KOR_POSM_Order_Detail__c PLtemp =new ASI_KOR_POSM_Order_Detail__c();
                    PLtemp=allPOSMLineMap.get(key).linesitems;  
                    
                    if(PLtemp.recordtypeid != null && String.isNotEmpty(allPOSMLineMap.get(key).ProductItemID) && String.isNotEmpty(allPOSMLineMap.get(key).SubBrandID) && String.isNotEmpty(allPOSMLineMap.get(key).SupplierID) && String.isNotEmpty(allPOSMLineMap.get(key).Supplier) && String.isNotEmpty(allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c) &&  allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c !='undefined' && allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c !=null && allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c !=''){
                        if(!SupplierEmailMap.containsKey(allPOSMLineMap.get(key).SupplierID)){
                            List<String> EmailList = new List<String>();
                            EmailList.add(allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c );
                            SupplierEmailMap.put(allPOSMLineMap.get(key).SupplierID,EmailList);
                            List<String> TempLineList = new List<String>();
                            TempLineList.add(string.valueOf(allPOSMLineMap.get(key).linesitems.id));
                            SupplierLineMap.put(allPOSMLineMap.get(key).SupplierID, TempLineList);
                        }else{
                            SupplierLineMap.get(allPOSMLineMap.get(key).SupplierID).add(string.valueOf(allPOSMLineMap.get(key).linesitems.id));
                            SupplierEmailMap.get(allPOSMLineMap.get(key).SupplierID).add(allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c);
                        }
                        
                        //Set Header
                        posmReqHeader.ASI_MFM_KR_Email_Sent__c=true;  
                        posmReqHeader.ASI_MFM_KR_EmailSentTime__c = System.now();
                        //Set Line
                        PLtemp.ASI_KOR_Supplier__c= Id.valueOf(allPOSMLineMap.get(key).SupplierID);
                        upsertTargetList.add(PLtemp); 
                        
                    }
                    else{
                        EmailUpsertPermission = false; //msg += 'Line ' + idx + ' : Please input Supplier Email Address' + '</br>';
                    }
                    
                } // End of for loop orignal map
                
                
                for(String key : SupplierEmailMap.keySet()) {
                    
                    system.debug('Test SupplierEmailMap '+SupplierEmailMap.get(key));
                    
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
                    if(SupplierAttMap.containsKey(key)){
                        for (Integer i = 0; i < SupplierAttMap.get(key).size(); i++){
                            Messaging.EmailFileAttachment efa = NEW Messaging.EmailFileAttachment();   //Define the email
                            efa.setFileName(SupplierAttMap.get(key)[i].name);  
                            efa.setBody(SupplierAttMap.get(key)[i].body);
                            efa.setContentType(SupplierAttMap.get(key)[i].contenttype);
                            
                            efaList.add(efa);       
                        } 
                    }
                    email.setTargetObjectId(this.posmReqHeader.ownerid);
                    email.setToAddresses(SupplierEmailMap.get(key)); 
                    email.setWhatId(SupplierLineMap.get(key)[0]);    
                    email.setSaveAsActivity(false);  
                    email.setBccSender(false);
                    email.setUseSignature(false);  
                    email.setTemplateId(templateId);
                    
                   if(efaList.size()>0){
                       email.setFileAttachments(efaList);
                        
                   }
                    
                   
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   //Send the email  system.debug(efaList+ 'Final Test Email: '+r.get(0).isSuccess());
                    if (!r.get(0).isSuccess()) {
                        isRedirect = false;
                    }else{
                         isRedirect = true;
                        SentSuccess = true;
                    }          
                    
                }
                
                 
                if(isRedirect && upsertTargetList.size()>0)
                {
                    try{
                        upsertTarget = Database.upsert(upsertTargetList);
                        update posmReqHeader;
                        SentSuccess = true;
                        EmailUpsertPermission = true;
                    }
                    catch (DmlException dmle) {
                        EmailUpsertPermission = false;
                    }
                    catch (Exception e){
                        
                        EmailUpsertPermission = false;
                    }
                }
                else{
                    EmailUpsertPermission = false;
                    SentSuccess = false;//msg += 'Line ' + idx + ' : Can not be null.' + '</br>';
                }
                
            }
            
        }
           
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    
    
    
    
    
    
    public void sendEmail()
    {
        EmailUpsertPermission = true;
        Integer idx = 1;
        msg = ''; 
        
        Boolean isRedirect = True; 
        
        Database.upsertResult[] upsertTarget;
        
        
        List<ASI_KOR_POSM_Order_Detail__c> upsertTargetList = new List<ASI_KOR_POSM_Order_Detail__c>();
        
        
        create_POSMdetailrtID = new ASI_KOR_POSM_Order_Detail__c();
        create_POSMdetailrtID.recordTypeID = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail');
        string developername = create_POSMdetailrtID.recordTypeID;
        
        if(!allPOSMLineMap.isEmpty())
        {
            isRedirect =  EmailvaldationCheckingStep(allPOSMLineMap);
            
            
        }//end if
        
        
        if(!isRedirect)
        {
            EmailUpsertPermission = false;
            SentSuccess = false;
            
        }//end
        if(EmailUpsertPermission= true){
            
            for(String key : allPOSMLineMap.keySet())
            {
                ASI_KOR_POSM_Order_Detail__c PLtemp =new ASI_KOR_POSM_Order_Detail__c();
                PLtemp=allPOSMLineMap.get(key).linesitems;  
                if(PLtemp.recordtypeid != null) {
                    if(String.isNotEmpty(allPOSMLineMap.get(key).ProductItemID) &&
                       String.isNotEmpty(allPOSMLineMap.get(key).SubBrandID)&&
                       String.isNotEmpty(allPOSMLineMap.get(key).SupplierID) &&
                       String.isNotEmpty(allPOSMLineMap.get(key).Supplier) &&
                       String.isNotEmpty(allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c)&&
                       allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c !='undefined' &&
                       allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c !=null &&
                       allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c !=''){
                           
                           
                           PLtemp.ASI_KOR_Supplier__c= Id.valueOf(allPOSMLineMap.get(key).SupplierID);
                           
                           if(allPOSMLineMap.get(key).linesitems.ASI_KOR_POSM_Order_Request__r.ASI_MFM_KR_Email_Sent__c != true){
                               posmReqHeader.ASI_MFM_KR_Email_Sent__c=true;
                               
                           }
                           posmReqHeader.ASI_MFM_KR_EmailSentTime__c = System.now();
                           upsertTargetList.add(PLtemp); 
                           
                       }
                    else{
                        EmailUpsertPermission = false; //msg += 'Line ' + idx + ' : Please input Supplier Email Address' + '</br>';
                    }
                }
                
                if(PLtemp.recordtypeid == null) {
                    EmailUpsertPermission = false;// msg += 'Line ' + idx + ' : Can not be null.' + '</br>';
                }
                
                idx++;
                
            }   
            
        }
        
        
        if(isRedirect == true && upsertTargetList.size()>0)
        {
            try{
                upsertTarget = Database.upsert(upsertTargetList);
                update posmReqHeader;
                SentSuccess = true;
                EmailUpsertPermission = true;
            }
            catch (DmlException dmle) {
                EmailUpsertPermission = false;
            }
            catch (Exception e){
                
                EmailUpsertPermission = false;
            }
        }
        else{
            EmailUpsertPermission = false;
            SentSuccess = false;//msg += 'Line ' + idx + ' : Can not be null.' + '</br>';
        }
        
        
        //Send Email:        
        if(EmailUpsertPermission == true && isRedirect == true){
            
            Id templateId;// ID userid = UserInfo.getUserId();
            String templateApiName = 'ASI_KOR_POSM_Request';     //  Set Email template          
            List <String> ToAddresses = new List <String>(); 
            
            templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
            
            
            
            if(templateId != null){  //if the Email template is found
                
                //Send email by Supplier's group 
                //***Only ONE Line will pass to email's component ==>need to loop other lines manually***
                if(SupplierLinesMap.size()>0){ // if there is POSM Line
                    
                    List <Attachment> AllLines = [select id, name,body,contenttype, ParentID from Attachment where ParentId in : LinesMap.keyset()]; //All related lines' attachments
                    
                    if(AllLines.size() > 0) {
                        for(Attachment att:  AllLines){     //for each attachment
                            string supplierCode = LinesMap.containsKey(att.ParentId)?   LinesMap.get(att.ParentId).ASI_KOR_Supplier__c:'';
                            if(SupplierAttMap.containsKey(supplierCode)){
                                SupplierAttMap.get(supplierCode).add(att);
                            }else{
                                List<Attachment> AttList = new List<Attachment>();
                                AttList.add(att);
                                SupplierAttMap.put(supplierCode,AttList);    //Map SupplierAttMap <String, <List>>
                            }
                            
                        }  
                    }
                    
                    for(String SupplierLinesItems: SupplierAttMap.keyset()){       //for each supplier
                        
                        for (ASI_KOR_POSM_Order_Detail__c POSMLINE : LinesMap.values()){
                            
                            if(POSMLINE.ASI_KOR_Supplier__c == SupplierLinesItems){
                                //ID LineID = SupplierAttMap.get(SupplierLinesItems).ParentID;
                                //ToAddresses.add('prsg.sfdc@gmail.com');
                                // ToAddresses.add(LinesMap.get(SupplierLinesItems.ParentId).ASI_MFM_KR_Supplier_Email__c);
                                ToAddresses.add(POSMLINE.ASI_MFM_KR_Supplier_Email__c);
                                
                            }  
                        }
                        
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        
                        List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
                        
                        Integer numAttsBySupplier= SupplierAttMap.get(SupplierLinesItems).size();
                        // system.assertEquals(numAttsBySupplier, null);  
                        
                        
                        if(numAttsBySupplier>0){  
                            
                            for (Integer i = 0; i < numAttsBySupplier; i++){
                                Messaging.EmailFileAttachment efa = NEW Messaging.EmailFileAttachment();   //Define the email
                                efa.setFileName(SupplierAttMap.get(SupplierLinesItems)[i].name);  
                                efa.setBody(SupplierAttMap.get(SupplierLinesItems)[i].body);
                                efa.setContentType(SupplierAttMap.get(SupplierLinesItems)[i].contenttype);
                                
                                efaList.add(efa);       
                            } 
                        }  
                        
                        
                        email.setTargetObjectId(this.posmReqHeader.ownerid);
                        email.setToAddresses(ToAddresses); 
                        email.setWhatId(SupplierAttMap.get(SupplierLinesItems)[0].ParentId);    
                        //email.setWhatId('a6bL00000008QB2'); 
                        // system.assertEquals(email, null);  
                        email.setSaveAsActivity(false);  
                        email.setBccSender(false);
                        email.setUseSignature(false);  
                        email.setTemplateId(templateId);
                        
                        if(efaList.size()>0){
                            email.setFileAttachments(efaList);
                            
                        }
                        
                        system.debug('Test : '+email);
                        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   //Send the email
                        
                        /* for(Messaging.SendEmailResult res:r){
                        system.debug('Test :Messaging.SendEmailResult : '+res);
                        }*/
                        
                    } 
                }
            } // end of //if the Email template is found
            
            
        }
    }
}