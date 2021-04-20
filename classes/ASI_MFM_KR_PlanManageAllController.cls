public class ASI_MFM_KR_PlanManageAllController {
    public ApexPages.StandardController standardController {get;set;}
    public ASI_MFM_Plan__c Header {get;set;}
    public boolean SaveSuccess {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public Integer startMonth {get;set;}   
    public Integer EndMonth {get;set;}  
    public boolean CrossYear {get;set;}
    public Integer monthDiff {get;set;}
    public Integer avamonth {get;set;}
    public String Msg {get;set;}    
    public String SQLstatement {get;set;} {SQLstatement='';}
    
    public Map<String, interimData> allLineItemMap {get;set;}
    public List<ASI_MFM_Plan_Line_Item__c> deleteLineItemList {get;set;}{deleteLineItemList = new List<ASI_MFM_Plan_Line_Item__c>();}
    
    //Index
    public static String LINE_ITEM_NEWRECORD_PREFIX {get{ return 'z';}}
    public Integer LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    
    String planOwnerId = '';
    String branchCode = '';
    public Transient Map<String,ASI_TnE_Branch_Channel__c> branchMap = new Map<String,ASI_TnE_Branch_Channel__c>();
    public Transient String subLedgerRecordType {set;get;}{subLedgerRecordType='ASI_TnE_KR_Branch_Channel';}
    public transient Map<id, id> APACMap { get; set; } {APACMap = new Map<id, id>();}//id is AP Code ID
    
    // A/C Code: ASI_MFM_A_C_Code__c
    public Transient String AC_Code_RecordType_Developer_Name {set;get;}{AC_Code_RecordType_Developer_Name='ASI_MFM_KR_A_C_Code';}
     // AP Code
    public Transient String AP_Code_RecordType_Developer_Name {set;get;}{AP_Code_RecordType_Developer_Name='ASI_KR_AP_Code';}
    public Transient String Sub_brand_RecordType_Developer_Name {set;get;}{Sub_brand_RecordType_Developer_Name='ASI_MFM_KR_Sub_Brand';}
    
    // Sub Brand *** [SH]  2019-06-26
    public Map<Id, ASI_MFM_Sub_brand__c> sbMap = new Map<Id, ASI_MFM_Sub_brand__c>([Select id, name from ASI_MFM_Sub_brand__c where recordtype.developerName ='ASI_MFM_KR_Sub_Brand' and ASI_MFM_Active_for_MFM__c =true]);
    
     //Customer
    public Transient String Customer_Developer_Name {set;get;}
    //Budget
    public static final String Budget_RecordType_Developer_Name = 'ASI_MFM_KR_Budget';
    
    public static final String Plan_Line_RecordType_Developer_Name =  'ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item';
    
    /*
    For approved plan, Plan owner should be able to add Plan line with different AP code with
    amount 0. Clone the existing lines, only AP code is editable, and AP code must be under same
    AP type with existing lines.
    */
    public set<String> relevantAPTypes {set;get;}
    
    
    
    
    public ASI_MFM_KR_PlanManageAllController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        this.Header = (ASI_MFM_Plan__c) this.standardController.getRecord();
        if(this.Header !=null && this.Header.Id !=null)
        {
            for(ASI_MFM_Plan__c plan:[select id,name,ASI_MFM_Project_Code__r.id,ASI_MFM_Need_Attachment__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c, ASI_MFM_Plan_Name__c ,RecordType.DeveloperName, CreatedById,
                                      ASI_MFM_Status__c,ownerId,ASI_MFM_Other_Remark__c,ASI_MFM_Cross_Fiscal_Year__c,ASI_MFM_Project_Code__c,ASI_MFM_Promotion_Code__c,ASI_MFM_KR_AP_Type__c, ASI_MFM_KR_Sub_brand__c,  // Added by 2018-06-22 Linus@introv
                                      ASI_MFM_Fiscal_year__c ,ASI_MFM_Plan_Raised_Date__c ,ASI_MFM_Objectives_Others__c ,ASI_MFM_Mechanics__c,ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where Id =: this.Header.Id limit 1])
            {
                this.Header = plan;
                planOwnerId = plan.ownerId;// ----- 2015-12-21
            }//end for: get current plan detail info
            
            //BOOM BOOM ----- sub ledger ----- 2015-12-21
            branchCode = [SELECT ASI_KOR_User_Branch_Code__c FROM User WHERE Id =: planOwnerId].ASI_KOR_User_Branch_Code__c;
            List<ASI_TnE_Branch_Channel__c> branchList 
                = new List<ASI_TnE_Branch_Channel__c>([SELECT Id, Name
                                                       FROM ASI_TnE_Branch_Channel__c
                                                       WHERE ASI_TnE_Branch_Default__c = TRUE
                                                       AND recordType.developerName = 'ASI_TnE_KR_Branch_Channel']);
            for(ASI_TnE_Branch_Channel__c bc: branchList)
            {
                branchMap.put(bc.Name.subString(1,4),bc);
            }//end for
            Customer_Developer_Name='ASI_CRM_KR_Venue';//      ASI_CRM_KR_Wholesaler      
        }//end if
    }//end method: constructor
    
    
    
    public void init()
    {
        //Month Cost Calculation start
        //calculate month between start date and end date
        Date a = Header.ASI_MFM_Start_Date__c;
        Date b = Header.ASI_MFM_End_Date__c;
        monthDiff = a.monthsBetween(b);
        monthDiff++;
        
        //calculate month between start date and this fiscal year's last month
        Date c = Header.ASI_MFM_Start_Date__c;
        Date d =  Date.newInstance(Integer.valueOf('20'+Header.ASI_MFM_Fiscal_year__c.substring(4,6)),6,30);
        avamonth = c.monthsBetween(d);
        avamonth++;
        
        SQLstatement=ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_KR_findCustomers','Initialization','KR');
        
        startMonth=Header.ASI_MFM_Start_Date__c.month();
        EndMonth=Header.ASI_MFM_End_Date__c.month();
        if(Header.ASI_MFM_End_Date__c.year()!=Header.ASI_MFM_Start_Date__c.year())
        {
            CrossYear=true;
        }//end if
        else
        {
            CrossYear=false;
        }//end else
        //Month Cost Calculation End
       
        
        allLineItemMap = new Map<String, interimData>();
        List<ASI_MFM_Plan_Line_Item__c> lineItemList=[select id ,name,ASI_MFM_AccountsAdditionalField__r.Name,ASI_MFM_PRPO_Needed__c,
                                                      ASI_MFM_AP_Code__r.Name,ASI_MFM_Product_Item__r.Name,ASI_MFM_Carry_Forward__c,
                                                      ASI_MFM_Total_Cost__c,ASI_MFM_Plan__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,
                                                      ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,
                                                      ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,
                                                      ASI_MFM_KR_subLedger__c,ASI_MFM_AP_Category__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,
                                                      ASI_MFM_KR_subLedger__r.Name,ASI_MFM_Venue_Where__c,
                                                      ASI_MFM_A_C_Code__c,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Venue_Where__r.Name,
                                                      ASI_MFM_Customer_Name__r.name,ASI_MFM_List_Item_Description__c,
                                                      ASI_MFM_Product_Item__c,ASI_MFM_AP_Type__c,
                                                      ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_A_C_Code__r.name, ASI_MFM_Plan__r.ASI_MFM_KR_AP_Type__c, ASI_MFM_Plan__r.ASI_MFM_KR_Sub_brand__c ,   // Added by 2018-06-22 Linus@introv
                                                      ASI_MFM_Sub_brand_Code__c, (select id,name from PO_Line_Items__r )
                                                      from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c=:Header.id];
        
        if(!lineItemList.isEmpty())
        {   
            relevantAPTypes = new Set<String>();
            
            for(ASI_MFM_Plan_Line_Item__c lines:lineItemList)
            {
                String porlId = (String)(lines.id);
                interimData temp= new interimData();
                
                temp.linetems=lines;
                temp.linetems.ASI_MFM_AP_Type__c= lines.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c;
                temp.linetems.ASI_MFM_AP_Category__c=lines.ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c;
                                
                for (Integer i = 0; i < 12; i++)
                {
                    String mapField = 'ASI_MFM_Month_' + (i + 1) + '_Cost__c';
                    if((Header.ASI_MFM_Status__c!='Approved' && Header.ASI_MFM_Status__c!='Closed') ){
                        temp.AmountEditList[i]=MonthChecking(i);
                    }                                       
                    temp.linetems.put( mapField,  temp.linetems.get(mapField)==null?0.00:(Decimal)temp.linetems.get(mapField));
                    
                }//end for system.debug('Test'+lines.PO_Line_Items__r.size());
                if(lines.ASI_MFM_Total_Cost__c!=0 &&  (Header.ASI_MFM_Status__c=='Approved' || Header.ASI_MFM_Status__c=='Closed') ){
                    temp.ReadOnly=true;
                    
                }
                if(Header.ASI_MFM_Status__c=='Approved' || Header.ASI_MFM_Status__c=='Closed'){
                    temp.AmountReadOnly=true;
                    temp.APReadOnly=true;           // Added by 2018-07-10 Linus@introv
                    if(!String.isEmpty(temp.linetems.ASI_MFM_AP_Type__c))
                    relevantAPTypes.add(temp.linetems.ASI_MFM_AP_Type__c);
                }
                
                // [SH] 2019-06-26
                if(Header.ASI_MFM_KR_Sub_Brand__c != null)
                    temp.SBReadOnly = true;
                
                if(lines.PO_Line_Items__r.size()>0){
                    temp.HasPOLines=true;
                }
                temp.PRPONeeded=lines.ASI_MFM_PRPO_Needed__c;
                temp.SubBrand=lines.ASI_MFM_Sub_brand_Code__r.Name;
                temp.SubbrandId=lines.ASI_MFM_Sub_brand_Code__c;
                temp.ACCode=lines.ASI_MFM_A_C_Code__r.Name;
                temp.ACCodeId=lines.ASI_MFM_A_C_Code__c;
                temp.APCode=lines.ASI_MFM_AP_Code__r.Name;
                temp.APCodeId=lines.ASI_MFM_AP_Code__c;
                temp.Customer=lines.ASI_MFM_AccountsAdditionalField__r.Name;
                 temp.CustomerId=lines.ASI_MFM_AccountsAdditionalField__c;
                temp.VenueWhere=lines.ASI_MFM_Venue_Where__r.Name;
                temp.VenueWhereId=lines.ASI_MFM_Venue_Where__c;
                
                if(lines.ASI_MFM_KR_subLedger__c != null)// ----- 2015-12-21
                {
                    temp.subLedgerId = lines.ASI_MFM_KR_subLedger__c;
                    temp.subLedger = lines.ASI_MFM_KR_subLedger__r.Name;
                }//end if
                else if(lines.ASI_MFM_KR_subLedger__c == null && (branchCode != '' || branchCode != null) && branchMap.containsKey(branchCode) ){
                    temp.subLedgerId = branchMap.get(branchCode).Id;
                    temp.subLedger = branchMap.get(branchCode).Name;
                }//end else // ----- 2015-12-21
                
                allLineItemMap.put(porlId, temp);
            }//end for
        }//end if
    }//end method: init
    
    public void resetIsProcessFlag()
    {
        if(allLineItemMap == null) return;
        
        for(String key : allLineItemMap.keySet())
        {
            allLineItemMap.get(key).isProcess = true; 
         }//end for
    }//end method
    
    private boolean MonthChecking(integer i){
        map<Integer,Integer> MonthMap= new map<Integer,Integer> {1 => 7, 2 => 8, 3 => 9, 4 => 10, 5=> 11, 6 => 12, 7 => 1, 8 => 2, 9 => 3, 10 => 4, 11 => 5, 12 => 6};
        boolean edit=false;
        if(MonthMap.get(i+1)>6){
            if(CrossYear){
                if(startMonth<=MonthMap.get(i+1)){
                    edit=true;
                }else{
                    edit=false;
                }
            }else{
                if(startMonth<=MonthMap.get(i+1) && EndMonth>=MonthMap.get(i+1)){
                    edit=true;
                }else{
                    edit=false;
                }
            }
        }else{
            if(CrossYear){
                if(EndMonth>=MonthMap.get(i+1)){
                    edit=true;
                }else{
                    edit=false;
                }
            }else{
                if(startMonth<=MonthMap.get(i+1) && EndMonth>=MonthMap.get(i+1)){
                    edit=true;
                }else{
                    edit=false;
                }
            }
        }
        
        return edit;
    }
    
    public void cloneLine()
    {
        UpsertPermission = true;
        SaveSuccess = false;
        resetIsProcessFlag();
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_clone_ID');
        if(allLineItemMap.containsKey(param_Id) && !allLineItemMap.isEmpty()){
            string newIDCounter = newCounterCreatorLine();
            interimData temp= new interimData();
            temp.linetems=new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c=Header.id,
                                                        ASI_MFM_AccountsAdditionalField__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_AccountsAdditionalField__c,
                                                        ASI_MFM_List_Item_Description__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_List_Item_Description__c,
                                                        ASI_MFM_Carry_Forward__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_Carry_Forward__c,
                                                        ASI_MFM_AP_Type__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_AP_Type__c,
                                                        ASI_MFM_AP_Category__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_AP_Category__c,
                                                        ASI_MFM_Total_Cost__c=allLineItemMap.get(param_Id).linetems.ASI_MFM_Total_Cost__c,
                                                        recordtypeid = Global_RecordTypeCache.getRTId(Plan_Line_RecordType_Developer_Name)
                                                       );
            
            
            for (Integer i = 0; i < 12; i++) {
                String mapField = 'ASI_MFM_Month_' + (i + 1) + '_Cost__c';
                if((Header.ASI_MFM_Status__c!='Approved' && Header.ASI_MFM_Status__c!='Closed') ){
                    temp.AmountEditList[i]=MonthChecking(i);  
                    temp.linetems.put( mapField, (Decimal)allLineItemMap.get(param_Id).linetems.get(mapField)) ;
                }else{
                    temp.linetems.put( mapField,0.00);
                    temp.AmountReadOnly=true;
                    temp.APReadOnly=true;     // Added by 2018-07-10 Linus@introv
                    temp.linetems.ASI_MFM_Total_Cost__c=0;
                    temp.linetems.ASI_MFM_Remarks__c='This line is added after approved.';
                    
                    temp.SBReadOnly=true;    // [SH]  2019-06-26
                }
                
            }                                                
            temp.PRPONeeded=allLineItemMap.get(param_Id).PRPONeeded;
            temp.SubBrand=allLineItemMap.get(param_Id).SubBrand;
            temp.SubbrandId=allLineItemMap.get(param_Id).SubbrandId;
            temp.ACCode=allLineItemMap.get(param_Id).ACCode;
            temp.ACCodeId=allLineItemMap.get(param_Id).ACCodeId;
            temp.APCode=allLineItemMap.get(param_Id).APCode;
            temp.APCodeId=allLineItemMap.get(param_Id).APCodeId;
            temp.Customer = allLineItemMap.get(param_Id).Customer;
            temp.CustomerId = allLineItemMap.get(param_Id).CustomerId;
            temp.subLedger = allLineItemMap.get(param_Id).subLedger;// ----- 2015-12-21
            temp.subLedgerId = allLineItemMap.get(param_Id).subLedgerId;// ----- 2015-12-21
            temp.VenueWhere=allLineItemMap.get(param_Id).VenueWhere; // linetems.ASI_MFM_Venue_Where__r.Name;
            temp.VenueWhereId=allLineItemMap.get(param_Id).VenueWhereId;//.linetems.ASI_MFM_Venue_Where__c;
            
            allLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
            SaveSuccess=false;
        }
    }//end method: cloneLine
    
    //Remove one line 
    public void removeLine()
    {
        UpsertPermission = true;
        SaveSuccess = false;
        resetIsProcessFlag();
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_Id = params.get('PARAM_Line_ID');
        if(allLineItemMap.containsKey(param_Id) && !allLineItemMap.isEmpty())
        {
            ASI_MFM_Plan_Line_Item__c delTarget=allLineItemMap.get(param_Id).linetems;
            if(delTarget.id != null)
            {
                deleteLineItemList.add(delTarget);
            }//end if
            
            allLineItemMap.remove(param_Id);
            SaveSuccess=false;
        }//end if
    }//end method: removeLine
    
    //Add One Line
    public void addLineItem()
    {
        UpsertPermission = true;
        SaveSuccess = false;
        resetIsProcessFlag();
        
        string newIDCounter = newCounterCreatorLine();
        interimData temp= new interimData();
       
        temp.linetems=new ASI_MFM_Plan_Line_Item__c(ASI_MFM_Plan__c=Header.id,recordtypeid = Global_RecordTypeCache.getRTId(Plan_Line_RecordType_Developer_Name));
        if( Header.ASI_MFM_Status__c=='Approved' || Header.ASI_MFM_Status__c=='Closed'){
            temp.AmountReadOnly=true;
            temp.linetems.ASI_MFM_Total_Cost__c=0;
            temp.linetems.ASI_MFM_Remarks__c='This line is added after approved.';
            for (Integer i = 0; i < 12; i++){
                String mapField = 'ASI_MFM_Month_' + (i + 1) + '_Cost__c';
                temp.linetems.put( mapField,0.00);
            }
        }else{            
            for (Integer i = 0; i < 12; i++){
                temp.AmountEditList[i]=MonthChecking(i);  
            }
        }
        
        if(branchMap!=null && branchMap.containsKey(branchCode)){
            temp.subLedgerId = branchMap.get(branchCode).Id;
            temp.subLedger = branchMap.get(branchCode).Name;
        }
        // Added by 2018-06-22 Linus@introv
        // set AP Type from Project Code(referred to AP Type in plan header) by Defualt 
        temp.linetems.ASI_MFM_AP_Type__c = Header.ASI_MFM_KR_AP_Type__c != null ? Header.ASI_MFM_KR_AP_Type__c: null;
        temp.APReadOnly = Header.ASI_MFM_KR_AP_Type__c != null ? true:false;
        
        // [SH] 2019-06-26 
        // set Sub-Brand from Project Code(If not empty) by default
        if(Header.ASI_MFM_KR_Sub_Brand__c != null){
            temp.Subbrand = sbMap.get(Header.ASI_MFM_KR_Sub_brand__c).name;
            temp.SubbrandId = Header.ASI_MFM_KR_Sub_brand__c;
            temp.SBReadOnly = true;
        }
        
        allLineItemMap.put(LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, temp);
        SaveSuccess=false;
    }//end method: addLineItem
    
    
    public void Recalculate(){
        if(!allLineItemMap.isEmpty()){
            for(String key : allLineItemMap.keySet()){
                if(allLineItemMap.get(key).linetems.ASI_MFM_Total_Cost__c!=null){
                    integer count=1;
                    Decimal monthAmt=(allLineItemMap.get(key).linetems.ASI_MFM_Total_Cost__c/monthDiff).SetSCale(0);
                    Decimal lastamount=(allLineItemMap.get(key).linetems.ASI_MFM_Total_Cost__c-(monthDiff-1)*monthAmt).SetSCale(2);
                    
                    //monthAmt=monthAmt.SetSCale(0);
                    
                    if(allLineItemMap.get(key).AmountEditList[0]){
                        if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_1_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_1_Cost__c=lastamount; 
                        }
                        count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[1]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_2_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_2_Cost__c=lastamount; 
                        }
                         count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[2]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_3_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_3_Cost__c=lastamount; 
                        }
                         count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[3]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_4_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_4_Cost__c=lastamount; 
                        }
                         count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[4]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_5_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_5_Cost__c=lastamount; 
                        }
                         count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[5]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_6_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_6_Cost__c=lastamount; 
                        }
                         count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[6]){
                        if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_7_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_7_Cost__c=lastamount; 
                        }
                         count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[7]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_8_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_8_Cost__c=lastamount; 
                        }
                         count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[8]){
                        if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_9_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_9_Cost__c=lastamount; 
                        }
                         count++;
                         
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[9]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_10_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_10_Cost__c=lastamount; 
                        }
                         count++;
                         
                    }
                    
                    if(allLineItemMap.get(key).AmountEditList[10]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_11_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_11_Cost__c=lastamount; 
                        }
                        count++;
                    }
                    
                     if(allLineItemMap.get(key).AmountEditList[11]){
                         if( count!=monthDiff){
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_12_Cost__c=monthAmt; 
                        }else{
                            allLineItemMap.get(key).linetems.ASI_MFM_Month_12_Cost__c=lastamount; 
                        }
                         count++;
                    }
                    
                    
                }
            }
        }
    }
    
    
    
    //Save the record 
    public PageReference saveItems()
    {
        if(header.ASI_MFM_Status__c =='Draft'){
            Recalculate();
        }
        
        
        PageReference pageRef = null;
        UpsertPermission = true;
        SaveSuccess = false;        

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);    

        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;
        
        List<ASI_MFM_Plan_Line_Item__c> upsertTargetList = new List<ASI_MFM_Plan_Line_Item__c>();
        
        Boolean isRedirect = True; 
        
        //Check the Map
        if(!allLineItemMap.isEmpty()){
            isRedirect =  valdationCheckingStep(allLineItemMap);
        }//end if
        
        
        if(!isRedirect){
            UpsertPermission = false;
            SaveSuccess = false;
            return null;
        }//end if


        if(UpsertPermission)
        {
            APACMap = new Map<id, id>();
            for(ASI_MFM_AP_AC_Code_Map__c apac:[select id,ASI_MFM_A_C_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.id , ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c from ASI_MFM_AP_AC_Code_Map__c where ASI_MFM_AP_Code__r.RecordType.DeveloperName='ASI_KR_AP_Code']){
                if(!APACMap.containsKey(apac.ASI_MFM_AP_Code__r.id)){
                    APACMap.put(apac.ASI_MFM_AP_Code__r.id, apac.ASI_MFM_A_C_Code__c);
                }
            }
            
            set<id> SetAP =new set<id>();
            //put the Map to list to upsert
            for(String key : allLineItemMap.keySet())
            {
                ASI_MFM_Plan_Line_Item__c PLtemp =new ASI_MFM_Plan_Line_Item__c();
                PLtemp=allLineItemMap.get(key).linetems;
                
                if(Header.ASI_MFM_Project_Code__c!=null) PLtemp.ASI_MFM_Project_Code__c=string.valueOf(Header.ASI_MFM_Project_Code__r.id);

                if(String.isNotEmpty(allLineItemMap.get(key).SubBrandId)) PLtemp.ASI_MFM_Sub_brand_Code__c= Id.valueOf(allLineItemMap.get(key).SubBrandId);
                
                if(String.isNotEmpty(allLineItemMap.get(key).subLedgerId)) PLtemp.ASI_MFM_KR_subLedger__c= Id.valueOf(allLineItemMap.get(key).subLedgerId);
                
                //AP Code
                if(String.isNotEmpty(allLineItemMap.get(key).APCodeId))
                {
                    PLtemp.ASI_MFM_AP_Code__c= Id.valueOf(allLineItemMap.get(key).APCodeId);
                    SetAP.add(Id.valueOf(allLineItemMap.get(key).APCodeId));
                    //add AC Code in APAC Code Map
                    if(APACMap.containsKey(allLineItemMap.get(key).APCodeId)){
                        PLtemp.ASI_MFM_A_C_Code__c=APACMap.get(allLineItemMap.get(key).APCodeId);
                    }else{
                        PLtemp.ASI_MFM_A_C_Code__c=null;
                    }
                }//end if
        
                for (Integer i = 0; i < 12; i++){
                    String mapField = 'ASI_MFM_Month_' + (i + 1) + '_Cost__c';
                    if(PLtemp.get(mapField)== null){
                        PLtemp.put(mapField,0);
                    }
                }
                
                if(String.isNotEmpty(allLineItemMap.get(key).SubBrandId) && String.isNotEmpty(allLineItemMap.get(key).APCodeId) && String.isNotEmpty(allLineItemMap.get(key).subLedgerId))
                {
                    upsertTargetList.add(PLtemp);
                }//end if
            }//end for  
            
            //Check if need Attachment
            List<ASI_MFM_AP_Code__c> aplist=[select ASI_MFM_Attachments_for_Plan__c from ASI_MFM_AP_Code__c where id in: SetAP and ASI_MFM_Attachments_for_Plan__c!=null ];
            if(aplist.size()>0){
                Header.ASI_MFM_Need_Attachment__c=true;
            }else{
                Header.ASI_MFM_Need_Attachment__c=false;  
            }
            
        }//end if
        
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try
        {
            if(UpsertPermission){
                if(deleteLineItemList.size()>0)
                {
                    deleteTarget = Database.delete(deleteLineItemList);
                    deleteLineItemList.clear();
                }//end if
                
                if(upsertTargetList.size()>0)
                {
                    upsertTarget = Database.upsert(upsertTargetList);
                    
                    
                } 
                update Header;
                SaveSuccess = true;
            }
        }//end try
        catch(Exception e)
        {
            msg += 'Save Error : ' +e.getMessage() + '</br>';
            
            pageRef = null;
            Database.rollback(pSavepoint);      
            UpsertPermission = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,e.getDmlMessage(0)));
            return null;
        }//end catch
        
        if (!isQuickSave && UpsertPermission)
        {
            pageRef = new PageReference('/'+Header.Id);
            pageRef.setRedirect(true);
        }//end if
        else
        {
            pageRef=null;
        }//end else
        
        return pageRef;     
    }//end method: SaveItems
    
    
    //Checking
    public Boolean valdationCheckingStep(Map<String, interimData>allLineItemMap )
    {
        Boolean isProcess = true;
        Decimal totalamount=0;
        Integer idx = 1;
        msg = '';
        
        if(allLineItemMap == null) return false;
        
        for(String key : allLineItemMap.keySet())
        {
            //initalize isProcess for Line
            allLineItemMap.get(key).isProcess = true;
            //check total cost not equals to null
            if(allLineItemMap.get(key).linetems.ASI_MFM_Total_Cost__c==null)
            {
                allLineItemMap.get(key).linetems.addError('Total Amount can not be null.');
                msg += 'Line ' + idx + ' : Total Amount can not be null.' + '</br>';
                allLineItemMap.get(key).isProcess = false;
                isProcess = false;                
            }//end if
            
            //check total cost not less or equals than 0
            if(allLineItemMap.get(key).linetems.ASI_MFM_Total_Cost__c<0)
            {
                allLineItemMap.get(key).linetems.addError('Total Amount should be larger than 0.');
                msg += 'Line ' + idx + ' : Total Amount should be larger than 0.' + '</br>';
                allLineItemMap.get(key).isProcess = false;
                isProcess = false;                
            }//end if
            
            
            //check sub-brand
            if(String.isEmpty(allLineItemMap.get(key).Subbrand) || String.isEmpty(allLineItemMap.get(key).SubbrandId))
            {
                allLineItemMap.get(key).linetems.addError('Please select Sub-Brand');
                msg += 'Line ' + idx + ' : Please select Sub-Brand' + '</br>';
                allLineItemMap.get(key).isProcess = false;
                isProcess = false;  
            }//end if
            else
            {
                if(!String.isEmpty(allLineItemMap.get(key).SubbrandId))
                {
                    try
                    {
                        /*Need to map back the ID to ASI_MFM_Sub_brand_Code__c*/
                        Id SubbrandId = Id.valueOf(allLineItemMap.get(key).SubbrandId);
                        allLineItemMap.get(key).linetems.ASI_MFM_Sub_brand_Code__c = SubbrandId;
                    }//end try
                    catch(exception e)
                    {
                        msg += 'Line ' + idx + ' : Please select Sub-Brand' + '</br>';
                        allLineItemMap.get(key).isProcess = false;
                        isProcess = false;  
                    }//end catch
                }//end if
            }//end else
            
            //check sub ledger
            if(String.isEmpty(allLineItemMap.get(key).subLedger) || String.isEmpty(allLineItemMap.get(key).subLedgerId))
            {
                allLineItemMap.get(key).linetems.addError('Please select Sub Ledger');
                msg += 'Line ' + idx + ' : Please select Sub Ledger' + '</br>';
                allLineItemMap.get(key).isProcess = false;
                isProcess = false;  
            }//end if
            else
            {
                if(!String.isEmpty(allLineItemMap.get(key).subLedgerId))
                {
                    try
                    {
                        /*Need to map back the ID to ASI_MFM_KR_subLedger__c*/
                        Id subLedgerId = Id.valueOf(allLineItemMap.get(key).subLedgerId);
                        allLineItemMap.get(key).linetems.ASI_MFM_KR_subLedger__c = subLedgerId;
                    }//end try
                    catch(exception e)
                    {
                        msg += 'Line ' + idx + ' : Please select Sub Ledger' + '</br>';
                        allLineItemMap.get(key).isProcess = false;
                        isProcess = false;  
                    }//end catch
                }//end if
            }//end else
            
            //check customer
            if(!String.isEmpty(allLineItemMap.get(key).CustomerId)){
                try
                {
                    /*Need to map back the ID to Customer*/
                    Id CusId = Id.valueOf(allLineItemMap.get(key).CustomerId);
                    allLineItemMap.get(key).linetems.ASI_MFM_AccountsAdditionalField__c = CusId;
                }//end try
                catch(exception e)
                {
                    msg += 'Line ' + idx + ' : Please select Customer' + '</br>';
                    allLineItemMap.get(key).isProcess = false;
                    isProcess = false;  
                }//end catch
            }
            
            if(String.isEmpty(allLineItemMap.get(key).Customer)){
                allLineItemMap.get(key).linetems.ASI_MFM_AccountsAdditionalField__c = null;
            }
            
            //check customer
            if(!String.isEmpty(allLineItemMap.get(key).VenueWhereId)){
                try
                {
                    /*Need to map back the ID to Customer*/
                    Id CusId = Id.valueOf(allLineItemMap.get(key).VenueWhereId);
                    allLineItemMap.get(key).linetems.ASI_MFM_Venue_Where__c = CusId;
                }//end try
                catch(exception e)
                {
                    msg += 'Line ' + idx + ' : Please select Venue Where' + '</br>';
                    allLineItemMap.get(key).isProcess = false;
                    isProcess = false;  
                }//end catch
            }
            if(String.isEmpty(allLineItemMap.get(key).VenueWhere)){
                allLineItemMap.get(key).linetems.ASI_MFM_Venue_Where__c = null;
            }
            //end if
                        
            //check AP code
            if(String.isEmpty(allLineItemMap.get(key).APCode) || String.isEmpty(allLineItemMap.get(key).APCodeId))
            {
                allLineItemMap.get(key).linetems.addError('Please select AP Code');
                msg += 'Line ' + idx + ' : Please select AP Code' + '</br>';
                isProcess = false;  
            }//end if
            else
            {
                if(!String.isEmpty(allLineItemMap.get(key).APCodeId))
                {
                    try
                    {
                        /*Need to map back the ID to ASI_MFM_AP_Code__c*/
                        Id APId = Id.valueOf(allLineItemMap.get(key).APCodeId);
                        allLineItemMap.get(key).linetems.ASI_MFM_AP_Code__c = APId;
                    }//end try
                    catch(exception e)
                    {
                        msg += 'Line ' + idx + ' : Please select AP Code' + '</br>';
                        allLineItemMap.get(key).isProcess = false;
                        isProcess = false;  
                    }//end catch
                }//end if
                
                
                if(header.ASI_MFM_Status__c =='Approved' && relevantAPTypes!=null && relevantAPTypes.size()>0){
                    /*13 Feb 2017 Elufa PRA Support check AP Type*/
                    system.debug(relevantAPTypes);
                    if(!String.isEmpty(allLineItemMap.get(key).linetems.ASI_MFM_AP_Type__c) && !allLineItemMap.get(key).ReadOnly && !relevantAPTypes.contains(allLineItemMap.get(key).linetems.ASI_MFM_AP_Type__c)){
                        msg += 'Line ' + idx + ' : AP code must be under same AP type'+ relevantAPTypes +' with existing lines.' + '</br>';
                        system.debug('incorrect AP Type: ' +allLineItemMap.get(key).linetems.ASI_MFM_AP_Type__c);
                        allLineItemMap.get(key).isProcess = false;
                        isProcess = false;                          
                    }
                    
                }
            }//end else
            
            idx++;
        }//end for: loop keySet
        return isProcess;
    }//end method: valdationCheckingStep
    
    public PageReference cancel()
    {
        return standardController.cancel();
    }
    
    
    public Class interimData{
        public ASI_MFM_Plan_Line_Item__c linetems {get; set;}
        public Boolean HasPOLines{get;set;} {HasPOLines=false;}
        public Decimal Amount {get;set;}
        public String ACCode {set;get; }
        public String ACCodeId {set;get;}
        public String APCode {set;get;}
        public String APCodeId {set;get;}
        public String Subbrand {set;get;}
        public String SubbrandId {set;get;}
        public String budgetAmount {set;get;}
        public String Customer {set;get;}   
        public String CustomerId {set;get;}
        public Boolean isProcess {set;get;}
        public Boolean PRPONeeded {set;get;}
        public String subLedger{set;get;}
        public String subLedgerId{set;get;}
        public String VenueWhere {set;get;}
        public String VenueWhereId {set;get;}
        public boolean ReadOnly {set;get;} {ReadOnly=false;}
        public boolean AmountReadOnly {set;get;} {ReadOnly=false;}
        public boolean APReadOnly {set;get;} {ReadOnly=false;}                        // Added by 2018-07-10 Linus@introv 
        public boolean SBReadOnly {set;get;} {ReadOnly=false;}              // [SH] 2019-06-26
        public List<boolean> AmountEditList {set;get;} {AmountEditList = new list<boolean> {false, false,false, false,false, false,false, false,false, false,false, false};}
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
    
    
    
    
    
    //********************************************RemoteAction Start **************************************************************
    // Method: For Auto-Complete
      @RemoteAction
    public static List<sObject> findAPACCodeMap(string obj, string qry)
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
        // ASI_MFM_AP_Code__r.RecordType.DeveloperName='ASI_KR_AP_Code'
        String soql;
        if(filter != '' || filter != null)
            soql = 'select ASI_MFM_AP_Code__r.Id, ASI_MFM_A_C_Code__r.Id,ASI_MFM_AP_Code__r.Name,ASI_MFM_A_C_Code__r.Name from ' + obj + filter +' order by Name';
        else
            soql = 'select ASI_MFM_AP_Code__r.Id, ASI_MFM_A_C_Code__r.Id,ASI_MFM_AP_Code__r.Name,ASI_MFM_A_C_Code__r.Name from ' + obj +' order by Name';
        
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
    
    
    //
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
            soql = 'select Id, Name, RecordType.DeveloperName,ASI_CRM_CN_Address__c, ASI_CRM_CN_Phone_Number__c from ' + obj + filter ;
        else 
            soql = 'select Id, Name, RecordType.DeveloperName,ASI_CRM_CN_Address__c, ASI_CRM_CN_Phone_Number__c from ' + obj ; 
        
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
    }//end method    
    
    
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
     //********************************************End : RemoteAction**************************************************************
    
    
}//end class