public class ASI_CRM_KR_ListedMenuPriceMgtAllCtrl {
    
    public ApexPages.StandardController standardController {get;set;}
    public ASI_CRM_KR_Listed_Menu_Price__c HeaderData { get; set; }
    public ASI_CRM_KR_Listed_Menu_Price__c  header{get;set;}
    
    public set<ID> ExistItemGroupCode {get;set;} {ExistItemGroupCode = new set<ID>();}  
    public List<ASI_KOR_Venue_Listed_Menu_Product__c> MenuPriceLineList {get;set;} {MenuPriceLineList = new List<ASI_KOR_Venue_Listed_Menu_Product__c>();}   //Menu Price Details
    public Map<String, interimData> allPriceMap {get;set;}{ allPriceMap = new Map<String, interimData>();}   //Menu Price Details
    public List<ASI_KOR_Item_Group__c> ItemGpList {get;set;} {ItemGpList = new List<ASI_KOR_Item_Group__c>();}   //Item Group 
    public Map<String, ASI_KOR_Item_Group__c> allItemGpMap {get;set;}{ allItemGpMap = new Map<String, ASI_KOR_Item_Group__c>();}   //Item Group 
    
    public List<ASI_KOR_Venue_Listed_Menu_Product__c> deletePriceList {get;set;}{deletePriceList = new List<ASI_KOR_Venue_Listed_Menu_Product__c>();}
    
    public ASI_KOR_Venue_Listed_Menu_Product__c create_PricedetailrtID  {get;set;}
    
    public String Msg {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;} 
    public boolean SaveSuccess {get;set;}
    public boolean CloneLastMonthResult {get;set;}{CloneLastMonthResult=false;} 
    
    public String HeaderQuarter {get;set;}{HeaderQuarter='';}
    public String HeaderYear {get;set;}{HeaderYear='';}
    public boolean CloneFromLastQuarter {get;set;} {CloneFromLastQuarter=false;}
    
    public Class interimData{
        public ASI_KOR_Venue_Listed_Menu_Product__c linesItems {get; set;}
        public Boolean Checked {get; set;} { this.checked = false; }
        public string Description  {get; set;} {Description='';}
    }
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    // Define the constructor  
    public ASI_CRM_KR_ListedMenuPriceMgtAllCtrl(ApexPages.StandardController standardController){
        this.standardController = standardController;
        String HeaderId = ApexPages.currentPage().getParameters().get('id');
        this.header = (ASI_CRM_KR_Listed_Menu_Price__c)standardController.getRecord();  
        this.HeaderData = [SELECT Id, Name,ASI_CRM_KR_Venue__c,ASI_CRM_KR_Quarter__c, ASI_CRM_KR_Fiscal_Year__c ,ASI_CRM_KR_Clone_From_Last_Quarter__c from ASI_CRM_KR_Listed_Menu_Price__c where Id = :HeaderId];
        HeaderQuarter = HeaderData.ASI_CRM_KR_Quarter__c;
        HeaderYear = HeaderData.ASI_CRM_KR_Fiscal_Year__c;  
    }
    
    
    
    public void init(){   
        
        allPriceMap = new Map<String, interimData>();
        
        if(this.header !=null && this.header.Id !=null){
            
            //Menu Price Details
            MenuPriceLineList = [SELECT id, ASI_KOR_Item_Group_Code__c,ASI_KOR_Listed_Price__c, ASI_CRM_KR_Listed_Menu_Product_Header__c, ASI_KOR_ListedMenuProduct_to_Venue_Link__c,
                                 ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c, ASI_KOR_Item_Group_Code__r.ASI_KOR_Name_Kor__c
                                 FROM ASI_KOR_Venue_Listed_Menu_Product__c 
                                 WHERE ASI_CRM_KR_Listed_Menu_Product_Header__c =: header.id];
            
            //Item Group 
            ItemGpList = [SELECT id, ASI_KOR_Item_Group_Code__c, ASI_KOR_Name_Kor__c, ASI_KOR_Sub_Brand__c, 
                          ASI_KOR_Product_Grade__c, ASI_KOR_Standard_Bottle_Size__c,
                          ASI_CRM_KR_StockInTradeSIT__c,ASI_CRM_KR_Priority_Item__c,
                          ASI_KOR_Description__c   /* Added by Kammy at 3 May 2016 */
                          FROM ASI_KOR_Item_Group__c 
                          where ASI_KOR_Item_Group_Code__c!=null 
                          AND ASI_CRM_KR_Priority_Item__c = TRUE];      
            
            
            
            //Put item group data in ItemGpList into allItemGpMap
            if(!ItemGpList.isEmpty()){
                for(ASI_KOR_Item_Group__c EachItem : ItemGpList){
                    
                    //if(!ExistItemGroupCode.contains(EachItem.ASI_KOR_Item_Group_Code__c)){
                    
                    
                    //if(EachItem.ASI_KOR_Item_Group_Code__c)
                    allItemGpMap.put(EachItem.ASI_KOR_Item_Group_Code__c,EachItem);
                    
                    
                    // }
                    
                }
                
                
            }
            
            
            //For Menu Price Map
            
            if(!MenuPriceLineList.isEmpty()){
                
                
                for(ASI_KOR_Venue_Listed_Menu_Product__c EachItemPrice : MenuPriceLineList){
                    
                    interimData temp= new interimData();
                    temp.linesItems=EachItemPrice;
                    temp.Description=EachItemPrice.ASI_KOR_Item_Group_Code__r.ASI_KOR_Name_Kor__c;
                    allPriceMap.put(EachItemPrice.id,temp);  
                    //ExistItemGroupCode.add(EachItemPrice.ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c);
                    allItemGpMap.remove(EachItemPrice.ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c);
                }
                
            }
            
            
            
        }
        
        //system.assertEquals(allPriceMap,null);
        
    }
    
    
    //Add One item line to Menu Price Map 
    public void addLineItem(){
        CloneLastMonthResult = false;
        Msg = null;
        UpsertPermission = true;
        SaveSuccess = false;
        
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_POLINE_SOURCE_ITEM_ID');
        
        if(allItemGpMap.containsKey(param_SourceItemId)){
            
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            temp.Description=allItemGpMap.get(param_SourceItemId).ASI_KOR_Name_Kor__c;
            temp.linesItems=new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_CRM_KR_Listed_Menu_Product_Header__c=header.id, 
                                                                     ASI_KOR_Item_Group_Code__c = allItemGpMap.get(param_SourceItemId).id,
                                                                     ASI_KOR_ListedMenuProduct_to_Venue_Link__c =HeaderData.ASI_CRM_KR_Venue__c);
            
            allPriceMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            allItemGpMap.remove(param_SourceItemId);
            
        }
        
    }
    
    
    public void removeLine() {  
        UpsertPermission = true;
        SaveSuccess = false;
        Msg = null;
        CloneLastMonthResult = false;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PRICELINE_SOURCE_ITEM_ID');
        if(allPriceMap.containsKey(param_Id) && !allPriceMap.isEmpty())
        {
            ASI_KOR_Venue_Listed_Menu_Product__c delTarget = allPriceMap.get(param_Id).linesItems;
            if(delTarget.id != null)
            {
                deletePriceList.add(delTarget); 
            }
            
            
            
            //system.assertEquals(allPriceMap.get(param_Id).linesItems.ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c,null);
            string ItemCodeName = '';
            ItemCodeName = allPriceMap.get(param_Id).linesItems.ASI_KOR_Item_Group_Code__c;
            
            if(ItemCodeName != null){
                ASI_KOR_Item_Group__c Item = [SELECT id, ASI_KOR_Item_Group_Code__c, ASI_KOR_Name_Kor__c, ASI_KOR_Sub_Brand__c, ASI_KOR_Product_Grade__c, ASI_KOR_Standard_Bottle_Size__c,
                                                     ASI_KOR_Description__c
                                              FROM ASI_KOR_Item_Group__c  
                                              WHERE ID =:ItemCodeName];
                
                if(Item !=null){
                    allItemGpMap.put(Item.ASI_KOR_Item_Group_Code__c,Item);
                    
                }
                
            }
            
            allPriceMap.remove(param_Id);
            
            SaveSuccess=false;
        }
        
    }
    
    public String newCounterCreatorLine(){
        
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
    
    public PageReference saveLinetems(){
        PageReference pageRef = null;
        UpsertPermission = true;
        SaveSuccess = false;     
        CloneLastMonthResult = false;
        //msg = '';
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);    
        
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        
        List<ASI_KOR_Venue_Listed_Menu_Product__c> upsertTargetList = new List<ASI_KOR_Venue_Listed_Menu_Product__c>();
        
        Boolean isRedirect = True; 
        
        if(!allPriceMap.isEmpty()){
            isRedirect =  valdationCheckingStep(allPriceMap);
            
        }
        
        if(!isRedirect)
        {
            UpsertPermission = false;
            SaveSuccess = false;
            // SYSTEM.assertEquals(MSG,NULL);
            return null;
        }//end if
        
        //system.debug('isRedirect:' + isRedirect);
        
        create_PricedetailrtID = new ASI_KOR_Venue_Listed_Menu_Product__c();
        //create_PricedetailrtID.recordTypeID =  Global_RecordTypeCache.getRtId('ASI_KOR_Venue_Listed_Menu_Product__cASI_KOR_POSM_Order_Detail');
        
        if(UpsertPermission){
            for(String key : allPriceMap.keySet()){
                
                ASI_KOR_Venue_Listed_Menu_Product__c PLtemp = new ASI_KOR_Venue_Listed_Menu_Product__c();
                PLtemp = allPriceMap.get(key).linesitems;
                
                if(allPriceMap.get(key).linesitems.ASI_KOR_Listed_Price__c != null ){
                    
                    PLtemp.ASI_KOR_Listed_Price__c= allPriceMap.get(key).linesitems.ASI_KOR_Listed_Price__c;
                }//end if
                
                
                if(String.isNotEmpty(allPriceMap.get(key).linesitems.ASI_CRM_KR_Listed_Menu_Product_Header__c) &&
                   String.isNotEmpty(allPriceMap.get(key).linesitems.ASI_KOR_Item_Group_Code__c) &&
                   String.isNotEmpty(allPriceMap.get(key).linesitems.ASI_KOR_ListedMenuProduct_to_Venue_Link__c) &&
                   allPriceMap.get(key).linesitems.ASI_KOR_Listed_Price__c != null ){  
                       
                       //allPriceMap.get(key).linesitems.ASI_CRM_KR_Listed__c = 1;
                       
                       upsertTargetList.add(PLtemp);
                       
                   }
            }
            
            
            
        }
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try
        {
            if(UpsertPermission){
                
                if(deletePriceList.size()>0)
                {
                    deleteTarget = Database.delete(deletePriceList);
                    deletePriceList.clear();
                    SaveSuccess = true;
                    UpsertPermission = true;
                    
                }//end if
                
                if(upsertTargetList.size() != 0)
                {
                    //  system.assertEquals(upsertTargetList,null);
                    upsertTarget = Database.upsert(upsertTargetList);
                    SaveSuccess = true;
                    UpsertPermission=true;
                    //system.assertEquals(SaveSuccess, null);    
                    //system.assertEquals(upsertTargetList.size(), null);
                    
                }  
                if(CloneFromLastQuarter){
                    //
                    ASI_CRM_KR_Listed_Menu_Price__c LMP=new ASI_CRM_KR_Listed_Menu_Price__c(id= header.Id, ASI_CRM_KR_Clone_From_Last_Quarter__c=true);
                    update LMP;
                }                
                // SaveSuccess=true;
                
            }
            
            
        }//end try
        catch(Exception e)
        {
            //Msg = '';
            //msg += 'Save Error : ' +e.getMessage() + '</br>';
            pageRef = null;
            Database.rollback(pSavepoint);      
            UpsertPermission = false;
            system.assertEquals(null, e.getMessage() );
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,e.getDmlMessage(0)));
            return null;
        }//end catch
        
        if (!isQuickSave && UpsertPermission)
        {
            pageRef = new PageReference('/'+ header.id);
            pageRef.setRedirect(true);
        }//end if
        else
        {
            pageRef=null;
        }//end else
        
        return pageRef;     
        
        
    }
    
    public PageReference cancel() {
        
        Pagereference ref;
        ref = new PageReference('/'+ header.id);
        ref.setRedirect(true);
        return ref;
    }
    
    
    public Boolean valdationCheckingStep(Map<String, interimData>allPriceMap){
        Integer idx = 1; 
        Msg='';
        Boolean isProcess = true;
        
        for(String key : allPriceMap.keySet()){
            if(allPriceMap.get(key).linesitems.ASI_KOR_Item_Group_Code__c == null){
                allPriceMap.get(key).linesitems.adderror('Item Group Code can not be null');
                Msg += 'Line ' + idx + ' : Item Group Code can not be null'+'</br>';
                isProcess=false;
            }
            
            if(allPriceMap.get(key).linesitems.ASI_KOR_Listed_Price__c == null){
                allPriceMap.get(key).linesitems.adderror('Menu Price Code can not be null');
                Msg += 'Line ' + idx + ' : Menu Price can not be null'+'</br>';
                isProcess=false;
            }
            //SYSTEM.assertEquals(MSG,NULL);
            idx++; 
        }
        return isProcess;
    }
    
    
    //Clone 
    public void CloneFromLastQuarter(){
        
        UpsertPermission = true;
        SaveSuccess = false;
        CloneLastMonthResult = true;
        
        String GetYear = '';
        String GetQuarter = '';
        //if(HeaderData.ASI_CRM_KR_Clone_From_Last_Quarter__c || CloneFromLastQuarter){  //Commented by Kammy at 6 May 2016
        if(HeaderData.ASI_CRM_KR_Clone_From_Last_Quarter__c){
            msg = 'Have already Copied from Last Month.';
            CloneLastMonthResult = true;
        }else if(HeaderQuarter != null & HeaderYear != null){
            //system.assertEquals(string.valueOf(integer.valueOf(HeaderYear.substring(4,6))-1),null);
            if(HeaderQuarter == 'Q1'){
                
                GetYear = 'FY' + string.valueOf(integer.valueOf(HeaderYear.substring(2,4))-1) + string.valueOf(integer.valueOf(HeaderYear.substring(4,6))-1);
                //GetYear = string.valueof(Integer.valueOf(HeaderYear) - 1);
                GetQuarter = 'Q4';
            }
            
            else{
                
                GetYear = HeaderYear;
            }
            
            
            if(HeaderQuarter == 'Q4'){
                GetQuarter = 'Q3';
            }
            if(HeaderQuarter == 'Q3'){
                GetQuarter = 'Q2';
            }
            if(HeaderQuarter == 'Q2'){
                GetQuarter = 'Q1';
            }
            // system.assertEquals(GetQuarter,null); 
            List<ASI_KOR_Venue_Listed_Menu_Product__c> LastQuarterPriceList 
                = new List<ASI_KOR_Venue_Listed_Menu_Product__c>([SELECT id, ASI_KOR_Item_Group_Code__c,ASI_KOR_Listed_Price__c, ASI_CRM_KR_Listed_Menu_Product_Header__c, ASI_KOR_ListedMenuProduct_to_Venue_Link__c,
                                                                  ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Venue__c, ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Quarter__c, 
                                                                   ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c,
                                                                  ASI_KOR_Item_Group_Code__r.ASI_KOR_Description__c,ASI_KOR_Item_Group_Code__r.ASI_KOR_Name_Kor__c
                                                                  FROM ASI_KOR_Venue_Listed_Menu_Product__c 
                                                                  WHERE ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Venue__c =: HeaderData.ASI_CRM_KR_Venue__c and 
                                                                  ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Quarter__c =: GetQuarter and
                                                                  ASI_CRM_KR_Listed_Menu_Product_Header__r.ASI_CRM_KR_Fiscal_Year__c =: GetYear]);
            
            
            
            
            if(!LastQuarterPriceList.isEmpty()){
                
                
                for(ASI_KOR_Venue_Listed_Menu_Product__c EachLineFromLastQuarter : LastQuarterPriceList){
                    
                    string newIDCounter = newCounterCreatorLine();
                    interimData temp= new interimData();
                    temp.Description=EachLineFromLastQuarter.ASI_KOR_Item_Group_Code__r.ASI_KOR_Name_Kor__c;
                    temp.linesItems=new ASI_KOR_Venue_Listed_Menu_Product__c(ASI_CRM_KR_Listed_Menu_Product_Header__c=header.id, 
                                                                             ASI_KOR_Item_Group_Code__c = EachLineFromLastQuarter.ASI_KOR_Item_Group_Code__c,
                                                                             ASI_KOR_ListedMenuProduct_to_Venue_Link__c =HeaderData.ASI_CRM_KR_Venue__c,
                                                                             ASI_KOR_Listed_Price__c = EachLineFromLastQuarter.ASI_KOR_Listed_Price__c);
                    
                    
                    
                    
                    if(allPriceMap.size() > 0) {
                        for (String LineID : allPriceMap.keySet()){
                            string existItemCode = allPriceMap.get(LineID).linesItems.ASI_KOR_Item_Group_Code__c;
                            
                            
                            if(existItemCode == EachLineFromLastQuarter.ASI_KOR_Item_Group_Code__c){
                                allPriceMap.remove(LineID);
                            }
                            
                            
                            
                            //allPriceMap.put(EachLineFromLastQuarter.id,temp);   
                            allPriceMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
                            
                            if(allItemGpMap.containsKey(EachLineFromLastQuarter.ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c)){
                                
                                allItemGpMap.remove(EachLineFromLastQuarter.ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c);
                            }
                        }
                    }
                    else{
                        //allPriceMap.put(EachLineFromLastQuarter.id,temp);   
                        allPriceMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp); 
                        
                        if(allItemGpMap.containsKey(EachLineFromLastQuarter.ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c)){
                            
                            allItemGpMap.remove(EachLineFromLastQuarter.ASI_KOR_Item_Group_Code__r.ASI_KOR_Item_Group_Code__c);
                        }
                    }
                }    
                msg = '';
                if(LastQuarterPriceList.size() == 1){
                    msg = LastQuarterPriceList.size() + ' line is found.';
                }
                else{
                    msg = LastQuarterPriceList.size() + ' lines are found.';
                }
                CloneLastMonthResult = true;
                CloneFromLastQuarter=true;
            }
            else{
                msg = '';
                msg = 'No result found.';
                CloneLastMonthResult = true;
            }
        }
    }
    
    
    
}