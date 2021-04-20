public with sharing class ASI_MFM_JP_POReceiptManageAllCtrler {

    public ApexPages.StandardController standardController {get;set;}
    
    public ASI_MFM_PO_Receipt__c Header {get;set;}
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    
    public Map<String, interimPOL> allPOLineMap {get;set;}{ allPOLineMap = new Map<String, interimPOL>();}
    public Map<String, interimData> allPORItemMap {get;set;}{ allPORItemMap = new Map<String, interimData>();}
    
    public List<ASI_MFM_PO_Receipt_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_PO_Receipt_Item__c>();}
   
  
    public ASI_MFM_objectPickListHelper subBrandPickList { get; set;}
    public boolean SaveSuccess {get;set;}
    public boolean DisplayPOL {get;set;}{DisplayPOL=true;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    //Search: Attributes used for filtering POLs
    public String subBrandNameFilter {get;set;}
    public String Msg {get;set;}
    
    //Attributes used for remove payment line 
    public String removePaymentLine {get;set;}
    

     public Class interimData{
         public ASI_MFM_PO_Receipt_Item__c por {get; set;}
         public String AC_Code {get; set;}
         public String AC_CodeID {get; set;}
         public String AP_Code {get; set;}
         public String AP_CodeID {get; set;}
         public String SB_Code {get; set;}
         public String SB_CodeID {get; set;}
         public String Customer {get; set;}
         public String CustomerID {get; set;}
         public String Description {get; set;}
         
         public Decimal PoAmount {get; set;}
         public Decimal PoRemaining {get; set;}
    }
    
    public Class interimPOL{
        public ASI_MFM_PO_Line_Item__c pol {get; set;}
        public Decimal RemainAmt {get; set;}
    }
    
    
    // Define the constructor
    public ASI_MFM_JP_POReceiptManageAllCtrler(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.Header = (ASI_MFM_PO_Receipt__c) this.standardController.getRecord();
        if(this.Header !=null && this.Header.Id !=null){
            for(ASI_MFM_PO_Receipt__c por : [Select id, Name,ASI_MFM_PO__r.ASI_MFM_PO_Balance__c,ASI_MFM_PO__r.ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_PO__r.ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Receipt_Date__c,CreatedDate,ASI_MFM_PO__r.ASI_MFM_PO_End_Date__c,ASI_MFM_Status__c,ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c,ASI_MFM_PO__r.name,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.name,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_Remarks__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Currency__c  FROM ASI_MFM_PO_Receipt__c where Id =: this.Header.Id limit 1]){
                this.Header = por;
            }
        }
    }
    
     // Initialize
    public void init() {
        SaveSuccess=false;
        if(this.Header !=null && this.Header.Id !=null){
            //get PO Receipt Items Lines  
            
            //List<ASI_MFM_PO_Receipt_Item__c> PORlineItemList = queryAll(Header.id,'ASI_MFM_PO_Receipt_Item__c', 'ASI_MFM_PO_Receipt__c', '');
            List<ASI_MFM_PO_Receipt_Item__c> PORlineItemList =[select id,name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c,ASI_MFM_Marketing_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_Brand_Name__c,ASI_MFM_PO_Line_Item__c,ASI_MFM_Amount__c,ASI_MFM_Receipt_Date__c,ASI_MFM_Remark__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Receipt__c=:Header.id];
            set<ID> polineID_set = new set<ID>();
            if(!PORlineItemList.isEmpty()){
                boolean ALLverified=true;
                for(ASI_MFM_PO_Receipt_Item__c Porline : PORlineItemList){
                    String polId = (String)(Porline.ASI_MFM_PO_Line_Item__c);
                  if(!allPORItemMap.containsKey(polId)){
                        if(!Porline.ASI_MFM_Marketing_Verify__c){
                            ALLverified=false;
                        }
                         interimData temp= new interimData();
                        temp.por=Porline;
                        temp.AC_Code=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.name;
                        temp.AC_CodeID=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c;
                        temp.AP_Code=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__r.name;
                        temp.AP_CodeID=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_AP_Code__c;
                        temp.SB_Code=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name;
                        temp.SB_CodeID=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c;
                        temp.Customer=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__r.name;
                        temp.CustomerID=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c;
                        temp.Description=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c; 
                        if(Porline.ASI_MFM_Amount__c!=null){
                            temp.PoRemaining=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c+Porline.ASI_MFM_Amount__c;
                        }else{
                            temp.PoRemaining=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_CN_Remaining_Receipt_Balance__c;
                        }
                        
                        temp.PoAmount=Porline.ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c;
                        allPORItemMap.put(polId, temp);
                        polineID_set.add(Porline.ASI_MFM_PO_Line_Item__c);
                        
                  }
                }
                if(ALLverified || Header.ASI_MFM_PO__r.ASI_MFM_Status__c=='Complete'){
                    DisplayPOL=false;
                }
                
                
            }
            
            //get PO line 
            List<ASI_MFM_PO_Line_Item__c> POlineList = [select id,name,ASI_MFM_Sub_Brand_Name__c,ASI_MFM_CN_Remaining_Receipt_Balance__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_Customer_Name__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_PO__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_AP_Code__r.name,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Customer_Name__r.name 
                                                        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c=: Header.ASI_MFM_PO__c and id not in: polineID_set and ASI_MFM_CN_Remaining_Receipt_Balance__c >0 ];//List<ASI_MFM_PO_Line_Item__c> POlineList = queryAll(Header.ASI_MFM_PO__c,'ASI_MFM_PO_Line_Item__c', 'ASI_MFM_PO__c', '');
            if(!POlineList.isEmpty()){   //allPOLineMap
                for(ASI_MFM_PO_Line_Item__c pol:POlineList){
                    String polid=(String)(pol.id);
                    if(!allPOLineMap.containsKey(polid)){
                         interimPOL temp= new interimPOL();
                        temp.pol=pol;
                        temp.RemainAmt=pol.ASI_MFM_CN_Remaining_Receipt_Balance__c;
                        allPOLineMap.put(polid,temp);
                    }
                }
            }
            
            
        }
       
    }
     
     // 1. Remove this Payment Line from the upper table 
    public void removeLine() {
        SaveSuccess=false;
        UpsertPermission=true;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_PORLine_ID');
        if(allPORItemMap.containsKey(param_Id) && !allPORItemMap.isEmpty() ){
            
            ASI_MFM_PO_Line_Item__c POline = [select id,name,ASI_MFM_Sub_Brand_Name__c,ASI_MFM_CN_Remaining_Receipt_Balance__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Customer_Name__r.name,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.name,ASI_MFM_Customer_Name__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_PO__c from ASI_MFM_PO_Line_Item__c where id=:allPORItemMap.get(param_Id).por.ASI_MFM_PO_Line_Item__c];
            if(POline!=null){
                String polid=(String)(POline.id);
                if(!allPOLineMap.containsKey(polid)){
                    interimPOL temp= new interimPOL();
                    temp.pol=POline;
                    temp.RemainAmt=allPORItemMap.get(param_Id).PoRemaining;
                   // if(allPORItemMap.get(param_Id).por.ASI_MFM_Amount__c!=null){
                  //      temp.RemainAmt=POline.ASI_MFM_CN_Remaining_Receipt_Balance__c+allPORItemMap.get(param_Id).PoRemaining;
                  //  }else{
                   //     temp.RemainAmt=POline.ASI_MFM_CN_Remaining_Receipt_Balance__c;
                   // }                    
                    allPOLineMap.put(polid,temp);
                }
            }
            
            ASI_MFM_PO_Receipt_Item__c delTarget=allPORItemMap.get(param_Id).por;
            if(delTarget.id != null){
                deleteLineItemList.add(delTarget);
            }
            allPORItemMap.remove(param_Id);
            
            
        }
    }
    
    
    
    // 1. Add PO Line, 
    // 2. convert into Payment line
    // 3. Remove this PO Line from bottom table 
    public void addLineItem(){
        SaveSuccess=false;
        UpsertPermission=true;

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_SourceItemId = params.get('PARAM_POLINE_SOURCE_ITEM_ID');
        //String KeyId;
        if(allPOLineMap.containsKey(param_SourceItemId)){
            //KeyId = (String)(allPOLineMap.get(param_SourceItemId).id);
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            
            temp.por=new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_PO_Receipt__c=Header.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Receipt_Item__cASI_MFM_JP_PO_Receipt_item'),
                                                    ASI_MFM_PO_Line_Item__c=allPOLineMap.get(param_SourceItemId).pol.id,
                                                    ASI_MFM_PO__c=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_PO__c,
                                                    ASI_MFM_Amount__c=allPOLineMap.get(param_SourceItemId).RemainAmt,
                                                    ASI_MFM_Receipt_Date__c=Date.today()
                                                   );
            temp.AC_CodeID=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_A_C_Code__c;
            temp.AC_Code=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_A_C_Code__r.name;
            
            temp.AP_Code=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__r.name;
            temp.AP_CodeID=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_AP_Code__c;
            temp.SB_Code=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Sub_brand_Code__r.name;
            temp.SB_CodeID=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Sub_brand_Code__c;
            temp.Customer=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Customer_Name__r.name;
            temp.CustomerID=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Customer_Name__c;
            temp.Description=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_List_Item_Description__c; 
            temp.PoRemaining=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_CN_Remaining_Receipt_Balance__c;
            temp.PoAmount=allPOLineMap.get(param_SourceItemId).pol.ASI_MFM_Amount__c;
            allPORItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            allPOLineMap.remove(param_SourceItemId);
        }
        
    }
    
    public PageReference saveLinetems(){
        
        onCommitted();
        PageReference pageRef ;
        if(UpsertPermission){
             pageRef=new PageReference('/'+Header.ASI_MFM_PO__c);
        }else{
            pageRef=null;
        }
       
        return pageRef;
    }
    
    public void onCommitted(){
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        UpsertPermission=true;
        List<ASI_MFM_PO_Receipt_Item__c> upsertTargetList = new List<ASI_MFM_PO_Receipt_Item__c>();
        
        //Checking Validation 
        /*
        for(String key : allPORItemMap.keySet()){
           // if(allPORItemMap.get(key).por.ASI_MFM_Amount__c+allPORItemMap.get(key).PoRemaining>allPORItemMap.get(key).PoAmount*1.2){
            //    UpsertPermission=false;
            //    Msg=allPORItemMap.get(key).Description+'Total Receipt Amount: '+string.valueOf(allPORItemMap.get(key).por.ASI_MFM_Amount__c+allPORItemMap.get(key).PoRemaining)+'Po Remaining'+string.valueOf(allPORItemMap.get(key).PoAmount);
            //}
            if(allPORItemMap.get(key).por.ASI_MFM_Receipt_Date__c< Header.ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c ){  //|| allPORItemMap.get(key).por.ASI_MFM_Receipt_Date__c> Header.ASI_MFM_PO__r.ASI_MFM_PO_End_Date__c
                UpsertPermission=false;
                Msg='Receipt Date has to be within PO Start Date : '+string.valueOf(Header.ASI_MFM_PO__r.ASI_MFM_PO_Start_Date__c);//+'and End Date : '+string.valueOf(Header.ASI_MFM_PO__r.ASI_MFM_PO_End_Date__c);
            }
            upsertTargetList.add(allPORItemMap.get(key).por);
            
        }
        
        */
        UpsertPermission=valdationCheckingStep(allPORItemMap);
        if(UpsertPermission){
            for(String key : allPORItemMap.keySet()){
                
                upsertTargetList.add(allPORItemMap.get(key).por);
            }
        }
        
        try{
            if(UpsertPermission){
                if(deleteLineItemList.size()>0){
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteTarget.clear();
                }
                    
                if(upsertTargetList.size()>0){
                    upsertTarget = Database.upsert(upsertTargetList);
                }
                SaveSuccess=true;
            }else{
                SaveSuccess=false;
            }
            
        }catch(Exception e){
             msg += 'Save Error!'+  e.getMessage() +'</br>';
            UpsertPermission = false;
            SaveSuccess= false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Error!' + e));
        }
        
    }
    
    public Boolean valdationCheckingStep(Map<String, interimData> allLineItemMap ){
        
        Boolean isProcess = true;
        Integer idx = 1; 
        Decimal totalPORAmt=0;
		Decimal totalPOLAmt=0;        
        
        Msg = '';
        if(allLineItemMap == null) return false;
         
        for(String key : allLineItemMap.keySet()){
            if(Header.ASI_MFM_PO__r.ASI_MFM_Currency__c=='JPY'){
                allLineItemMap.get(key).por.ASI_MFM_Amount__c=allLineItemMap.get(key).por.ASI_MFM_Amount__c.setScale(0, roundingMode.half_up);
            }else{
                allLineItemMap.get(key).por.ASI_MFM_Amount__c=allLineItemMap.get(key).por.ASI_MFM_Amount__c.setScale(0, roundingMode.half_up);
            }
            
            
            //Receipt Date can not be null
            if(allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c==null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Receipt Date can not be null'+'</br>';
            }
            
            
            //Requirement 1: PO Receipt Date needs to be in between 1st day of the current fiscal year and today’s date //Date selectedDate =  Date.today();
            Date selectedDate= date.newinstance(Header.CreatedDate.year(), Header.CreatedDate.month(), Header.CreatedDate.day());           
            Date firstDate =date.newinstance(integer.valueof('20'+Header.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c.substring(2,4)),7, 1); //Date firstDate = selectedDate.toStartOfMonth();
            if(allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c<firstDate && allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c!=null){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Receipt Date can not before the first day of this Fiscal Year.'+firstDate.format() +'</br>';
            }
            if(allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c>selectedDate && allLineItemMap.get(key).por.ASI_MFM_Receipt_Date__c!=null ){
                isProcess=false;
                Msg += 'Line ' + idx + ' : Receipt Date can not after Created Date:' + selectedDate.format()+'.</br>';
            }
            
            
            
            // Requirement 2: PO Receipt Amount could be no more than 10% of the PO Line Amount  Header.ASI_MFM_PO__r.ASI_MFM_Currency__c=='JPY' &&
            if(allLineItemMap.get(key).por.ASI_MFM_Amount__c!=null){
                if(allLineItemMap.get(key).por.ASI_MFM_Amount__c>(allLineItemMap.get(key).PoRemaining+100000)){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Amount >PO Line Amount :'+allLineItemMap.get(key).PoRemaining +'</br>';
                }
                if(allLineItemMap.get(key).por.ASI_MFM_Amount__c>allLineItemMap.get(key).PoRemaining*1.1){
                    isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Amount > 10% more of the PO Line Amount :'+allLineItemMap.get(key).PoRemaining +'</br>';
                }
            }
            
            
            totalPORAmt=totalPORAmt+allLineItemMap.get(key).por.ASI_MFM_Amount__c;
            totalPOLAmt=totalPOLAmt+allLineItemMap.get(key).PoRemaining;
            //Receipt Amount can not be null
            if(allLineItemMap.get(key).por.ASI_MFM_Amount__c==null){
                isProcess=false;
                    Msg += 'Line ' + idx + ' : Receipt Amount can not be null'+'</br>';
            }
           
            
            idx++;
        }
        //Amount Checking
       //  if(totalPORAmt>totalPOLAmt*1.1){
        //        isProcess=false;
         //       Msg += ' Total Receipt Amount ('+totalPORAmt+') larger than Total PO Line Amount:'+totalPOLAmt*1.1+'</br>';
        //    }    
        
        return isProcess;
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
        if(allPORItemMap.isEmpty()){
            ASI_MFM_PO_Receipt__c por=new ASI_MFM_PO_Receipt__c();
            por.id=Header.id;
            delete por;
        }
        Pagereference ref;
        ref = new PageReference('/'+Header.ASI_MFM_PO__c);
        ref.setRedirect(true);
        return ref;
    }
    
     @RemoteAction
    public static List<ASI_MFM_Payment_Line_Item__c>  PaymentLineItems (ID headerID){
            //get Payment Lines  
            List<ASI_MFM_Payment_Line_Item__c> PaymentlineItemList = new List<ASI_MFM_Payment_Line_Item__c>([Select id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =: headerID ]);
            
            return PaymentlineItemList;
        
    }   
    
}