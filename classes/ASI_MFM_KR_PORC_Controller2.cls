/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Tony Ren                                                                  
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI Korea user                                                                              
|                       |                                                                                    
|     - Object(s)       | ASI_MFM_Settings__c                                                                                
|     - Description     |  PO Receipt closing display             
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 21/01/2017                                                                       
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                              
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ASI_MFM_KR_PORC_Controller2 {
    public integer counter=0;  //keeps track of the offset
    public integer list_size=5; //sets the page size or number of rows
    
    public integer total_size{get;set;} //used to show user the total size of the list
    public integer start_index{set;get;}
    public integer end_index{set;get;}
    
    public integer pageNumber{set;get;}
    public integer totalPages{set;get;}
    private String Version='V0';
    
    //SQL
    Public String QuerySQL {set;get;}{QuerySQL='';}
    Public String CountSQL {set;get;}{CountSQL='';}
    Public String FilterSQL {set;get;}{FilterSQL='';}
    Public String LimitSQL {set;get;}{LimitSQL='';}
    
    //Result Data
    public transient list<interimData> ResultList {set;get;}
    public transient String ListJSON  {set;get;}{ListJSON=null;} 
    
    //Search filter 
    public integer CurrentMonth{get;set;}
    public transient String Fiscal_Years {get;set;} 
    public transient String PRPONeed {get;set;} 
    public transient String CompanyFilter {get;set;} 
    public transient String SelectStatus {get;set;} 
    public transient String PlanRequester {get;set;} {PlanRequester=null;}
    public transient String selectedAPType {get;set;} {selectedAPType='';}
    public transient String SBCode {get;set;}{SBCode=null;}
    
    public transient String MinPORAmount {get;set;}
    public transient String MaxPORAmount  {get;set;}
    public transient String MinPOBalance  {get;set;}
    public transient String MaxPOBalance  {get;set;}
    public transient String MinPaymentAmount  {get;set;}  //Feb 1 - Payment amount checking (E Col)
    public transient String MaxPaymentAmount  {get;set;} //Feb 1 - Payment amount checking (E Col)
    
    public transient Decimal TotalPlanAmount {get;set;}{TotalPlanAmount=0;}
    public transient Decimal TotalPOAmount {get;set;}{TotalPOAmount=0;}
    public transient Decimal TotalM1Amount {get;set;}{TotalM1Amount=0;}
    public transient Decimal TotalMTDAmount {get;set;}{TotalMTDAmount=0;}
    public transient Decimal TotalPaidAmount {get;set;}{TotalPaidAmount=0;}
    public transient Decimal PlanBalance {get;set;}{PlanBalance=0;}
    public transient Decimal POBalance {get;set;}{POBalance=0;}
    
    public transient ASI_MFM_PO_Receipt_Item__c PostGLDate { get; set; }
    
    
    public ASI_MFM_KR_PORC_Controller2(){
        init();
    }
    
    public void init(){
        total_size=0;
        CurrentMonth=system.today().month();
        
        PostGLDate = new ASI_MFM_PO_Receipt_Item__c();
        Date SelectedDate =  Date.today(); 
        Date firstDate = SelectedDate.toStartOfMonth();
        
        Date SelectedDateMonthEnd= firstDate.addDays(date.daysInMonth(SelectedDate.year() , SelectedDate.month())  - 1);
        PostGLDate.ASI_MFM_Post_G_L_Date__c=SelectedDateMonthEnd;
        
        //Fiscal Year 
        Fiscal_Years='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            Fiscal_Years=Fiscal_Years+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            Fiscal_Years=Fiscal_Years+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        
        
        
        ListJSON=null;
        Version=String.valueOf(ASI_MFM_Setting__c.getOrgDefaults().ASI_MFM_KR_POReceiptClosing_DataVersion__c) ;
        list_size=integer.valueOf(ASI_MFM_Setting__c.getOrgDefaults().ASI_MFM_KR_PORC_List_No_Of_Row__c) ;
        counter=0;
        end_index = list_size;
        start_index=1;
        pageNumber=1;
        
        FilterSQL=' where ASI_MFM_Plan__c !=null and ASI_MFM_Version__c =  \''+Version+'\' AND   ASI_MFM_PRPO_Needed__c = true and ASI_MFM_Sub_brand__r.ASI_MFM_Company_Code__c = \'222\' AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Years)+'%\' and ( ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\' OR ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\' ) ';
        
        String Allfield='Id,Name,ASI_MFM_Version__c,ASI_MFM_Email_Notification__c,ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c,ASI_MFM_PO_Receipt_Line__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.Name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c,ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Activity_Group__c,ASI_MFM_Sub_brand__r.Name,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.Name,ASI_MFM_PRPO_Needed__c,ASI_MFM_A_P_Type__c,ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,ASI_MFM_Plan__r.ASI_MFM_End_Date__c,ASI_MFM_Plan__r.Owner.Name,ASI_MFM_Plan__r.ASI_MFM_Status__c ,ASI_MFM_PlanAmount_YTD_1__c , ASI_MFM_PlanAmount_YTD_2__c , ASI_MFM_PlanAmount_YTD_3__c , ASI_MFM_PlanAmount_YTD_4__c , ASI_MFM_PlanAmount_YTD_5__c , ASI_MFM_PlanAmount_YTD_6__c , ASI_MFM_PlanAmount_YTD_7__c , ASI_MFM_PlanAmount_YTD_8__c , ASI_MFM_PlanAmount_YTD_9__c , ASI_MFM_PlanAmount_YTD_10__c , ASI_MFM_PlanAmount_YTD_11__c , ASI_MFM_PlanAmount_YTD_12__c ,ASI_MFM_POAmount_YTD_1__c , ASI_MFM_POAmount_YTD_2__c , ASI_MFM_POAmount_YTD_3__c , ASI_MFM_POAmount_YTD_4__c , ASI_MFM_POAmount_YTD_5__c , ASI_MFM_POAmount_YTD_6__c , ASI_MFM_POAmount_YTD_7__c , ASI_MFM_POAmount_YTD_8__c , ASI_MFM_POAmount_YTD_9__c , ASI_MFM_POAmount_YTD_10__c , ASI_MFM_POAmount_YTD_11__c , ASI_MFM_POAmount_YTD_12__c , ASI_MFM_PORAmount_M1YTD_1__c , ASI_MFM_PORAmount_M1YTD_2__c , ASI_MFM_PORAmount_M1YTD_3__c , ASI_MFM_PORAmount_M1YTD_4__c , ASI_MFM_PORAmount_M1YTD_5__c , ASI_MFM_PORAmount_M1YTD_6__c , ASI_MFM_PORAmount_M1YTD_7__c , ASI_MFM_PORAmount_M1YTD_8__c , ASI_MFM_PORAmount_M1YTD_9__c , ASI_MFM_PORAmount_M1YTD_10__c , ASI_MFM_PORAmount_M1YTD_11__c , ASI_MFM_PORAmount_M1YTD_12__c , ASI_MFM_Month_1_PORAmount__c , ASI_MFM_Month_2_PORAmount__c , ASI_MFM_Month_3_PORAmount__c , ASI_MFM_Month_4_PORAmount__c , ASI_MFM_Month_5_PORAmount__c , ASI_MFM_Month_6_PORAmount__c , ASI_MFM_Month_7_PORAmount__c , ASI_MFM_Month_8_PORAmount__c , ASI_MFM_Month_9_PORAmount__c , ASI_MFM_Month_10_PORAmount__c , ASI_MFM_Month_11_PORAmount__c , ASI_MFM_Month_12_PORAmount__c , ASI_MFM_PaymentAmount_YTD_1__c , ASI_MFM_PaymentAmount_YTD_2__c , ASI_MFM_PaymentAmount_YTD_3__c , ASI_MFM_PaymentAmount_YTD_4__c , ASI_MFM_PaymentAmount_YTD_5__c , ASI_MFM_PaymentAmount_YTD_6__c , ASI_MFM_PaymentAmount_YTD_7__c , ASI_MFM_PaymentAmount_YTD_8__c , ASI_MFM_PaymentAmount_YTD_9__c , ASI_MFM_PaymentAmount_YTD_10__c , ASI_MFM_PaymentAmount_YTD_11__c , ASI_MFM_PaymentAmount_YTD_12__c , ASI_MFM_Plan_Balance_POR_1__c , ASI_MFM_Plan_Balance_POR_2__c , ASI_MFM_Plan_Balance_POR_3__c , ASI_MFM_Plan_Balance_POR_4__c , ASI_MFM_Plan_Balance_POR_5__c , ASI_MFM_Plan_Balance_POR_6__c , ASI_MFM_Plan_Balance_POR_7__c , ASI_MFM_Plan_Balance_POR_8__c , ASI_MFM_Plan_Balance_POR_9__c , ASI_MFM_Plan_Balance_POR_10__c , ASI_MFM_Plan_Balance_POR_11__c , ASI_MFM_Plan_Balance_POR_12__c , ASI_MFM_PO_Balance_POR_1__c , ASI_MFM_PO_Balance_POR_2__c , ASI_MFM_PO_Balance_POR_3__c , ASI_MFM_PO_Balance_POR_4__c , ASI_MFM_PO_Balance_POR_5__c , ASI_MFM_PO_Balance_POR_6__c , ASI_MFM_PO_Balance_POR_7__c , ASI_MFM_PO_Balance_POR_8__c , ASI_MFM_PO_Balance_POR_9__c , ASI_MFM_PO_Balance_POR_10__c , ASI_MFM_PO_Balance_POR_11__c , ASI_MFM_PO_Balance_POR_12__c,ASI_MFM_Month_10_PaymentAmount__c , ASI_MFM_Month_2_PaymentAmount__c , ASI_MFM_Month_6_PaymentAmount__c , ASI_MFM_Month_8_PaymentAmount__c , ASI_MFM_Month_7_PaymentAmount__c , ASI_MFM_Month_1_PaymentAmount__c , ASI_MFM_Month_12_PaymentAmount__c , ASI_MFM_Month_9_PaymentAmount__c , ASI_MFM_Month_11_PaymentAmount__c , ASI_MFM_Month_5_PaymentAmount__c , ASI_MFM_Month_4_PaymentAmount__c , ASI_MFM_Month_3_PaymentAmount__c ';
        
        CountSQL='SELECT count() FROM ASI_MFM_Settings__c ';
        
        QuerySQL='SELECT '+Allfield+' FROM ASI_MFM_Settings__c ';
        
        queryRecord();
        
    }
    
    public void queryRecord(){
        LimitSQL= ' order by '+sortField+'  '+sortDir+'  limit  '+list_size+' offset  '+counter;
        ResultList = new list<interimData>();//system.debug('Now SQL2: '+QuerySQL+FilterSQL+LimitSQL);//system.debug('Now SQL: '+FilterSQL+LimitSQL);
        List<ASI_MFM_Settings__c> TempList = new list<ASI_MFM_Settings__c>();
        //Get Total size
        total_size=Database.countQuery(CountSQL+FilterSQL);
        if (total_size > 0){ //system.assertEquals(null, QuerySQL+FilterSQL+LimitSQL);
            TempList=Database.query(QuerySQL+FilterSQL+LimitSQL);
        }
        
        
        
        if(TempList.size()>0){
            String PORStr='';
            for(ASI_MFM_Settings__c item:TempList){
                if(item.ASI_MFM_PO_Receipt_Line__c!=null && item.ASI_MFM_PO_Receipt_Line__c!=''){
                    PORStr+=item.ASI_MFM_PO_Receipt_Line__c;
                }
            }
            
            Map<ID, ASI_MFM_PO_Receipt_Item__c> mapPOR = new Map<ID,ASI_MFM_PO_Receipt_Item__c>();
            //Get All PO Receipt Line
            if(PORStr!=null && PORStr!=''){
                List<String> PORID = PORStr.split(';'); //List<ASI_MFM_PO_Receipt_Item__c> PORList=[select Id,Name from ASI_MFM_PO_Receipt_Item__c where id in: PORID];
                mapPOR = new Map<ID,ASI_MFM_PO_Receipt_Item__c>([SELECT Id,Name,ASI_MFM_PO_Receipt__r.ASI_MFM_Status__c,
                                                                 ASI_MFM_ACC_Verify__c,ASI_MFM_Remark__c,ASI_MFM_Plan_Line_Item__c,
                                                                 ASI_MFM_Plan_Line_Item__r.Name,ASI_MFM_Venue_Where__c,ASI_MFM_Venue_Where__r.Name,
                                                                 ASI_MFM_AccountsAdditionalField__c,ASI_MFM_AccountsAdditionalField__r.Name,
                                                                 ASI_MFM_Receipt_Amount_in_Local_Currency__c,
                                                                 ASI_MFM_Amount__c,ASI_MFM_Receipt_Date__c,
                                                                 ASI_MFM_PO_Line_Item__r.Name,ASI_MFM_PO_Line_Item__c,
                                                                 ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,
                                                                 ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c FROM ASI_MFM_PO_Receipt_Item__c WHERE id in: PORID]);
            }
            
            
            String FieldNumber=  string.valueOf(MonthMap.get(string.valueOf(CurrentMonth)));
            
            for(ASI_MFM_Settings__c item:TempList){
                interimData temp= new interimData();
                temp.PlanAmtYTD=item.get('ASI_MFM_PlanAmount_YTD_'+FieldNumber+'__c')!=null?(Decimal)item.get('ASI_MFM_PlanAmount_YTD_'+FieldNumber+'__c'):0;//temp.PlanAmtYTD=Decimal(item.get('ASI_MFM_PlanAmount_YTD_'+FieldNumber+'__c'));//ASI_MFM_PlanAmount_YTD_10__c
                temp.POAmtYTD=item.get('ASI_MFM_POAmount_YTD_'+FieldNumber+'__c')!=null?(Decimal)item.get('ASI_MFM_POAmount_YTD_'+FieldNumber+'__c'):0; 
                temp.PORAmtM1YTD=item.get('ASI_MFM_PORAmount_M1YTD_'+FieldNumber+'__c')!=null?(Decimal)item.get('ASI_MFM_PORAmount_M1YTD_'+FieldNumber+'__c'):0;
                temp.PORAmtMTD=item.get('ASI_MFM_Month_'+FieldNumber+'_PORAmount__c')!=null?(Decimal)item.get('ASI_MFM_Month_'+FieldNumber+'_PORAmount__c'):0;
                temp.PaymentAmtMTD = item.get('ASI_MFM_Month_'+FieldNumber+'_PaymentAmount__c')!=null?(Decimal)item.get('ASI_MFM_Month_'+FieldNumber+'_PaymentAmount__c'):0;
                temp.PaymentAmtYTD=item.get('ASI_MFM_PaymentAmount_YTD_'+FieldNumber+'__c')!=null?(Decimal)item.get('ASI_MFM_PaymentAmount_YTD_'+FieldNumber+'__c'):0; 
                temp.PlanBalance=item.get('ASI_MFM_Plan_Balance_POR_'+FieldNumber+'__c')!=null?(Decimal)item.get('ASI_MFM_Plan_Balance_POR_'+FieldNumber+'__c'):0;
                temp.POBalance=item.get('ASI_MFM_PO_Balance_POR_'+FieldNumber+'__c')!=null?(Decimal)item.get('ASI_MFM_PO_Balance_POR_'+FieldNumber+'__c'):0;
                temp.linetems=item;
                if(item.Id!=null){
                    temp.Bid=item.Id;
                }
                
                String PORLString='';
                if(item.ASI_MFM_PO_Receipt_Line__c !=null && item.ASI_MFM_PO_Receipt_Line__c!=''){
                    List<String> PORLIDList = item.ASI_MFM_PO_Receipt_Line__c.split(';');
                    for(String polid:PORLIDList){//system.debug('Test polid : '+polid);
                        if(polid!=null && polid !='' && mapPOR!=null && mapPOR.containsKey(polid)){
                            temp.PORLine.add(mapPOR.get(polid));
                        }
                    }
                }
                
                if(temp.PORLine.size()>0){
                    temp.HasLine=true; 
                }
                
                ResultList.add(temp);
            }//End Of For Loop  system.debug('Test ResultList : '+ResultList);
            
            if(ResultList.size()>0){
                ListJSON=JSON.serialize(ResultList);
            } 
            
            
            //Get Sum of Amount
            AggregateResult[] PlanAmountResults=Database.query('select sum(ASI_MFM_PlanAmount_YTD_'+FieldNumber+'__c) TotalAmount from ASI_MFM_Settings__c '+FilterSQL);
            for (AggregateResult ar : PlanAmountResults) {
                TotalPlanAmount=(Decimal) ar.get('TotalAmount');
            }
            
            AggregateResult[] POAmountResults=Database.query('select sum(ASI_MFM_POAmount_YTD_'+FieldNumber+'__c) TotalAmount from ASI_MFM_Settings__c '+FilterSQL);
            for (AggregateResult ar : POAmountResults) {
                TotalPOAmount=(Decimal) ar.get('TotalAmount');
            }
            
            AggregateResult[] M1AmountResults=Database.query('select sum(ASI_MFM_PORAmount_M1YTD_'+FieldNumber+'__c) TotalAmount from ASI_MFM_Settings__c '+FilterSQL);
            for (AggregateResult ar : M1AmountResults) {
                TotalM1Amount=(Decimal) ar.get('TotalAmount');
            }
            
            AggregateResult[] MTDAmountResults=Database.query('select sum(ASI_MFM_Month_'+FieldNumber+'_PORAmount__c) TotalAmount from ASI_MFM_Settings__c '+FilterSQL);
            for (AggregateResult ar : MTDAmountResults) {
                TotalMTDAmount=(Decimal) ar.get('TotalAmount');
            }
            
            
            AggregateResult[] PaidAmountResults=Database.query('select sum(ASI_MFM_PaymentAmount_YTD_'+FieldNumber+'__c) TotalAmount from ASI_MFM_Settings__c '+FilterSQL);
            for (AggregateResult ar : PaidAmountResults) {
                TotalPaidAmount=(Decimal) ar.get('TotalAmount');
            }
            
            AggregateResult[] PlanBalanceResults=Database.query('select sum(ASI_MFM_Plan_Balance_POR_'+FieldNumber+'__c) TotalAmount from ASI_MFM_Settings__c '+FilterSQL);
            for (AggregateResult ar : PlanBalanceResults) {
                PlanBalance=(Decimal) ar.get('TotalAmount');
            }
            
            AggregateResult[] POBalanceResults=Database.query('select sum(ASI_MFM_PO_Balance_POR_'+FieldNumber+'__c) TotalAmount from ASI_MFM_Settings__c '+FilterSQL);
            for (AggregateResult ar : POBalanceResults) {
                POBalance=(Decimal) ar.get('TotalAmount');
            }
            
        }
    }    
    
    
    public PageReference runSearch() {
        
        FilterSQL=' where ASI_MFM_Plan__c !=null and ASI_MFM_Version__c =  \''+Version+'\' ';
        
        integer fy=2000;
        if(CurrentMonth>0 && CurrentMonth<7){
            fy+=integer.valueOf(Fiscal_Years.substring(4, 6));            
        }else{
            fy+=integer.valueOf(Fiscal_Years.substring(2, 4));
        }
        
        Date SelectedDate = Date.newInstance(fy, integer.valueOf(CurrentMonth),1);
        
        
        Date SelectedDateMonthEnd= SelectedDate.addDays(date.daysInMonth(SelectedDate.year() , SelectedDate.month())  - 1);
        PostGLDate = new ASI_MFM_PO_Receipt_Item__c();
        PostGLDate.ASI_MFM_Post_G_L_Date__c=SelectedDateMonthEnd;
        
        // the first part: SelectStatus
        
        if(SelectStatus!=null && SelectStatus.length()>0){
            if(SelectStatus=='Approved'){
                FilterSQL +=  ' And ( ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\' )';  
                
            }
            if(SelectStatus=='Closed'){
                FilterSQL +=  ' and  (ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\' )';
            }
        }else{
            FilterSQL+=' And ( ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\' OR ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\' )';
        }
        
        if( CompanyFilter!=null && CompanyFilter.length()>0){
            FilterSQL+='  and ASI_MFM_Sub_brand__r.ASI_MFM_Company_Code__c = \''+CompanyFilter+'\' ';
        }
        
        if(Fiscal_Years!=null && Fiscal_Years.length()>0){
            FilterSQL+= ' AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Years)+'%\' ';
        }// 
        
        
        if(selectedAPType!=null && selectedAPType.length()>0){
            // [SH 1.0] 2018-10-15
            // [Jake: Correct typo] 2018-10-31
            if(selectedAPType=='Consumer A&P'){
                FilterSQL+= ' and ( ASI_MFM_A_P_Type__c LIKE \'%Other A&P%\'  OR ASI_MFM_A_P_Type__c LIKE \'%Media A&P%\' OR ASI_MFM_A_P_Type__c LIKE \'%Consumer A&P%\') '; 
            }else{
                FilterSQL+= ' and ( ASI_MFM_A_P_Type__c LIKE \'%A&D%\'  OR ASI_MFM_A_P_Type__c LIKE \'%Trade A&P%\' OR ASI_MFM_A_P_Type__c LIKE \'%SPTD%\') ';
            }
            
            
        }
        if(PlanRequester!=null && PlanRequester.length()>0){
            FilterSQL+= ' and ASI_MFM_Plan__r.Owner.Name LIKE \'%'+String.escapeSingleQuotes(PlanRequester)+'%\' '; 
        }
        
        /*
        if(PRPONeed=='Yes'){
            FilterSQL +=  ' and ASI_MFM_PRPO_Needed__c = true ';  
        }else{
            FilterSQL +=  ' and ASI_MFM_PRPO_Needed__c = false ';
        }*/
        FilterSQL +=  ' and ASI_MFM_PRPO_Needed__c = true ';  
        
        if (SBCode!=null && SBCode.length()>0){
            FilterSQL +=  ' and ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(SBCode)+'%\'';
        }
        
        String FieldNumber=  string.valueOf(MonthMap.get(string.valueOf(CurrentMonth)));
        
        
        if(MinPORAmount!=null && !String.isEmpty(MinPORAmount)){
            FilterSQL += ' and ASI_MFM_Month_'+FieldNumber+'_PORAmount__c >= '+ ConvertStringToDecimal(MinPORAmount);
        }
        if(MaxPORAmount!=null && !String.isEmpty(MaxPORAmount)){
            FilterSQL += ' and ASI_MFM_Month_'+FieldNumber+'_PORAmount__c <= '+ ConvertStringToDecimal(MaxPORAmount);
        }
        
        
        if(MinPOBalance!=null && !String.isEmpty(MinPOBalance)){
            FilterSQL += ' and ASI_MFM_PO_Balance_POR_'+FieldNumber+'__c >= '+ ConvertStringToDecimal(MinPOBalance);
        }
        
        if(MaxPOBalance!=null && !String.isEmpty(MaxPOBalance)){
            FilterSQL += ' and ASI_MFM_Month_'+FieldNumber+'_PORAmount__c <= '+ ConvertStringToDecimal(MaxPOBalance);
        }
        
        //Feb 1 - Payment amount checking (E Col)
        
        if(MinPaymentAmount!=null && !String.isEmpty(MinPaymentAmount)){
            FilterSQL += ' and ASI_MFM_PaymentAmount_YTD_' + FieldNumber+'__c>= '+ ConvertStringToDecimal(MinPaymentAmount);
        }
        if(MaxPaymentAmount!=null && !String.isEmpty(MaxPaymentAmount)){
            FilterSQL += ' and ASI_MFM_PaymentAmount_YTD_' + FieldNumber+'__c<= '+ ConvertStringToDecimal(MaxPaymentAmount);
        }
        
        
        system.debug('MinPORAmount:'+MinPORAmount);
        system.debug('MaxPORAmount'+MaxPORAmount);
        system.debug('MinPOBalance'+MinPOBalance);
        system.debug('MaxPOBalance'+MaxPOBalance);
        system.debug('MinPaymentAmount'+MinPaymentAmount);
        system.debug('MMaxPaymentAmount'+MaxPaymentAmount);        
        //system.assertEquals(FilterSQL, null);
        queryRecord();
        return null; 
    }
    
    public Decimal ConvertStringToDecimal(String inputString){
        Integer isNegative = inputString.contains('-')?-1:1;
        inputString = inputString.replaceAll(',','').replaceAll('-','');
        Decimal outputDecimal =  0.00;
        if(inputString.isNumeric())
            outputDecimal = isNegative* Decimal.valueOf(inputString==null||inputString.trim()==''?'':inputString.trim()).setScale(2);      
        return outputDecimal ;
    }
    
    @RemoteAction
    public static string SendingEmail(List<String> CheckedList, List<String> UnCheckedList,string MonthNumber){//✓, ✔
        string Mesg='';
        Boolean HasError= false;        
        Set<id> CheckedIdSet = new Set<id> ();
        for(String str:CheckedList){
            CheckedIdSet.add(str);
        }
        Set<id> UnCheckedIdSet = new Set<id> ();
        for(String str:UnCheckedList){
            UnCheckedIdSet.add(str);
        }
        //User , List of Data 
        Map<Id,List<ASI_MFM_Settings__c>> PORMap= new Map<Id,List<ASI_MFM_Settings__c>>(); 
        
        try{
            List<ASI_MFM_Settings__c> UnChexList=[select id,ASI_MFM_Email_Sent_Time__c,ASI_MFM_Email_Notification__c from ASI_MFM_Settings__c 
                                                  where id in : UnCheckedIdSet ];
            for(ASI_MFM_Settings__c s:UnChexList){
                s.ASI_MFM_Email_Sent_Time__c=null;
                s.ASI_MFM_Email_Notification__c=false;
                
            }
            if(UnChexList.size()>0){
                update UnChexList;
            }
            
            
            //Checked  List 
            List<ASI_MFM_Settings__c> ChexList=[select id,ASI_MFM_Email_Sent_Time__c,ASI_MFM_PO_Line_ID__c,ASI_MFM_Plan_Line_ID__c,ASI_MFM_Plan__r.Owner.Id,Name,ASI_MFM_Version__c,ASI_MFM_Email_Notification__c,ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c,ASI_MFM_PO_Receipt_Line__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.Name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c,ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Activity_Group__c,ASI_MFM_Sub_brand__r.Name,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.Name,ASI_MFM_PRPO_Needed__c,ASI_MFM_A_P_Type__c,ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,ASI_MFM_Plan__r.ASI_MFM_End_Date__c,ASI_MFM_Plan__r.Owner.Name,ASI_MFM_Plan__r.ASI_MFM_Status__c ,ASI_MFM_PlanAmount_YTD_1__c , ASI_MFM_PlanAmount_YTD_2__c , ASI_MFM_PlanAmount_YTD_3__c , ASI_MFM_PlanAmount_YTD_4__c , ASI_MFM_PlanAmount_YTD_5__c , ASI_MFM_PlanAmount_YTD_6__c , ASI_MFM_PlanAmount_YTD_7__c , ASI_MFM_PlanAmount_YTD_8__c , ASI_MFM_PlanAmount_YTD_9__c , ASI_MFM_PlanAmount_YTD_10__c , ASI_MFM_PlanAmount_YTD_11__c , ASI_MFM_PlanAmount_YTD_12__c ,ASI_MFM_POAmount_YTD_1__c , ASI_MFM_POAmount_YTD_2__c , ASI_MFM_POAmount_YTD_3__c , ASI_MFM_POAmount_YTD_4__c , ASI_MFM_POAmount_YTD_5__c , ASI_MFM_POAmount_YTD_6__c , ASI_MFM_POAmount_YTD_7__c , ASI_MFM_POAmount_YTD_8__c , ASI_MFM_POAmount_YTD_9__c , ASI_MFM_POAmount_YTD_10__c , ASI_MFM_POAmount_YTD_11__c , ASI_MFM_POAmount_YTD_12__c , ASI_MFM_PORAmount_M1YTD_1__c , ASI_MFM_PORAmount_M1YTD_2__c , ASI_MFM_PORAmount_M1YTD_3__c , ASI_MFM_PORAmount_M1YTD_4__c , ASI_MFM_PORAmount_M1YTD_5__c , ASI_MFM_PORAmount_M1YTD_6__c , ASI_MFM_PORAmount_M1YTD_7__c , ASI_MFM_PORAmount_M1YTD_8__c , ASI_MFM_PORAmount_M1YTD_9__c , ASI_MFM_PORAmount_M1YTD_10__c , ASI_MFM_PORAmount_M1YTD_11__c , ASI_MFM_PORAmount_M1YTD_12__c , ASI_MFM_Month_1_PORAmount__c , ASI_MFM_Month_2_PORAmount__c , ASI_MFM_Month_3_PORAmount__c , ASI_MFM_Month_4_PORAmount__c , ASI_MFM_Month_5_PORAmount__c , ASI_MFM_Month_6_PORAmount__c , ASI_MFM_Month_7_PORAmount__c , ASI_MFM_Month_8_PORAmount__c , ASI_MFM_Month_9_PORAmount__c , ASI_MFM_Month_10_PORAmount__c , ASI_MFM_Month_11_PORAmount__c , ASI_MFM_Month_12_PORAmount__c , ASI_MFM_PaymentAmount_YTD_1__c , ASI_MFM_PaymentAmount_YTD_2__c , ASI_MFM_PaymentAmount_YTD_3__c , ASI_MFM_PaymentAmount_YTD_4__c , ASI_MFM_PaymentAmount_YTD_5__c , ASI_MFM_PaymentAmount_YTD_6__c , ASI_MFM_PaymentAmount_YTD_7__c , ASI_MFM_PaymentAmount_YTD_8__c , ASI_MFM_PaymentAmount_YTD_9__c , ASI_MFM_PaymentAmount_YTD_10__c , ASI_MFM_PaymentAmount_YTD_11__c , ASI_MFM_PaymentAmount_YTD_12__c , ASI_MFM_Plan_Balance_POR_1__c , ASI_MFM_Plan_Balance_POR_2__c , ASI_MFM_Plan_Balance_POR_3__c , ASI_MFM_Plan_Balance_POR_4__c , ASI_MFM_Plan_Balance_POR_5__c , ASI_MFM_Plan_Balance_POR_6__c , ASI_MFM_Plan_Balance_POR_7__c , ASI_MFM_Plan_Balance_POR_8__c , ASI_MFM_Plan_Balance_POR_9__c , ASI_MFM_Plan_Balance_POR_10__c , ASI_MFM_Plan_Balance_POR_11__c , ASI_MFM_Plan_Balance_POR_12__c , ASI_MFM_PO_Balance_POR_1__c , ASI_MFM_PO_Balance_POR_2__c , ASI_MFM_PO_Balance_POR_3__c , ASI_MFM_PO_Balance_POR_4__c , ASI_MFM_PO_Balance_POR_5__c , ASI_MFM_PO_Balance_POR_6__c , ASI_MFM_PO_Balance_POR_7__c , ASI_MFM_PO_Balance_POR_8__c , ASI_MFM_PO_Balance_POR_9__c , ASI_MFM_PO_Balance_POR_10__c , ASI_MFM_PO_Balance_POR_11__c , ASI_MFM_PO_Balance_POR_12__c
                                                from ASI_MFM_Settings__c where id in : CheckedIdSet ];
            system.debug('Test ChexList'+ChexList);
            Set<String> PlanLineIDSet = new Set<String>();
            Set<String> POLineIDSet = new Set<String>();
            for(ASI_MFM_Settings__c s:ChexList){
                //Plan Line
                String[] splitString = s.ASI_MFM_Plan_Line_ID__c.split(';');
                for(String str: splitString) {
                    if(str.length()>0){
                        PlanLineIDSet.add(str);
                    }
                }
                
                //PO Line
                String[] splitString2 = s.ASI_MFM_PO_Line_ID__c.split(';');
                for(String str: splitString2) {
                    if(str.length()>0){
                        POLineIDSet.add(str);
                    }
                }
                
                s.ASI_MFM_Email_Sent_Time__c=system.now();
                s.ASI_MFM_Email_Notification__c=true;
                if(PORMap.containsKey(s.ASI_MFM_Plan__r.Owner.Id)){ // in the map 
                    PORMap.get(s.ASI_MFM_Plan__r.Owner.Id).add(s);// 
                }else{
                    List<ASI_MFM_Settings__c> tempList= new List<ASI_MFM_Settings__c>();
                    tempList.add(s);
                    PORMap.put(s.ASI_MFM_Plan__r.Owner.Id,tempList);
                }
            }
            if(ChexList.size()>0){
                update ChexList;
            }
            
            Map<Id,ASI_MFM_Plan_Line_Item__c> PlanLineMap=new Map<ID,ASI_MFM_Plan_Line_Item__c>([select Id,Name from ASI_MFM_Plan_Line_Item__c where id in : PlanLineIDSet ]);
            
            Map<Id,ASI_MFM_PO_Line_Item__c> POlineMap=new Map<ID,ASI_MFM_PO_Line_Item__c>([select Id,Name,ASI_MFM_PO__c,ASI_MFM_PO__r.Name from ASI_MFM_PO_Line_Item__c where id in : POLineIDSet ]);
            
            
            
            //Sending Email
            Map<ID, User> mapUser = new Map<ID,User>([SELECT ID, Name, Email  FROM User WHERE id in : PORMap.keySet() or id=: UserInfo.getUserId()  ]);
            // OrgWideEmailAddress owe = [SELECT ID FROM OrgWideEmailAddress WHERE DisplayName like 'IT Service Desk'];
            
            Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};
                String BccAddresses='prasia.mobile@pernod-ricard.com'; 
            String CCAddresses='prasia.mobile@pernod-ricard.com'; 
            if(mapUser.containsKey(UserInfo.getUserId())){
                CCAddresses=mapUser.get(UserInfo.getUserId()).Email;
            }
            
            for(Id key:PORMap.keySet()){
                if(mapUser.containsKey(key)){
                    Map<String, Integer> MonthMap = new Map<String, Integer>{ '1' => 7, '2' => 8, '3' => 9, '4' => 10, '5' => 11, '6' => 12, '7' => 1, '8' => 2, '9' => 3, '10' => 4, '11' => 5, '12' => 6 };
                        
                        List <String> ToAddresses = new List <String>(); 
                    ToAddresses.add(mapUser.get(key).Email);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();//message.setOrgWideEmailAddressId(owe.Id);
                    message.setToAddresses(ToAddresses);
                    message.setBccAddresses(new String[] {BccAddresses});
                    message.setCcAddresses(new String[] {CCAddresses});
                    message.setTargetObjectId(key); 
                    message.setUseSignature(false); 
                    message.setSaveAsActivity(false); 
                    
                    String subject = 'ACTION REQUIRED : PO Receipt'; 
                    String body = '<p style="font-family: Century Gothic;font-size:10px;">Dear MFM user,</p><br/><p style="font-family: Century Gothic;font-size:10px;">PO 수령 확인(PO Receipt)이 아래 table과 진행되지 않았습니다.</p><p style="font-family: Century Gothic;font-size:10px;"><b><u>PO Receipt 및 수령한 인보이스(세금계산서, 계산서 포함)가 일치하는지 확인하시고 PO Receipt를 진행하여 주시기 바랍니다</u></b></p><p style="font-family: Century Gothic;font-size:10px;"> PO receipt이 늦어지는 이유가 따로 있으면 BA팀과 공유해주세요.</p>'; 
                    String FieldNumber=  string.valueOf(MonthMap.get(string.valueOf(MonthNumber)));//A and P Type
                    body+='<p style="font-family: Century Gothic;font-size:10px;">감사합니다. </p> <br/><p style="font-family: Century Gothic;font-size:10px;">You have not completed PO receipt as below outstanding balance. </p>' ;
                    body+='<table style="border-collapse: collapse;font-family: Century Gothic;font-size:10px;"><tr style="border: 1px solid black;"><th style="border: 1px solid black;">Plan Code</th><th style="border: 1px solid black;">Plan Description</th><th style="border: 1px solid black;">Sub-Brand Code Description</th><th style="border: 1px solid black;">A and P Type</th><th style="border: 1px solid black;">AP Type</th><th style="border: 1px solid black;">Plan Line</th><th style="border: 1px solid black;">PO</th><th style="border: 1px solid black;">Requester</th><th style="border: 1px solid black;">Plan Status</th><th style="border: 1px solid black;">Plan Amount<br/>(YTD)<br/>(A)</th><th style="border: 1px solid black;">PO Amount<br/>(YTD)<br/>(B)</th><th style="border: 1px solid black;">PO Receipt <br/>(M-1 YTD)<br/>(C)</th><th style="border: 1px solid black;">PO Receipt<br/>(MTD)<br/>(D)</th><th style="border: 1px solid black;">Payment Amount<br/>(YTD)</th><th style="border: 1px solid black;">Plan Balance vs. PO receipt <br/>(E=A-C-D)</th><th style="border: 1px solid black;">PO Balance vs. PO receipt<br/>(F=B-C-D)</th><tr/>';
                    for(ASI_MFM_Settings__c items:PORMap.get(key)){ 
                        body+='<tr style="border: 1px solid black;"><td style="border: 1px solid black;">'+items.ASI_MFM_Plan__r.Name+'</td><td style="border: 1px solid black;">'+
                            items.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c+'</td><td style="border: 1px solid black;">'+items.ASI_MFM_Sub_brand__r.Name+'</td><td style="border: 1px solid black;">';
                        
                        if(items.ASI_MFM_A_P_Type__c=='Other A&P' || items.ASI_MFM_A_P_Type__c=='Media A&P' ){
                            body+='Customer A&P </td><td style="border: 1px solid black;">';
                        }else{
                            body+='Consumer A&P </td><td style="border: 1px solid black;">';
                        }
                        
                        body+=items.ASI_MFM_A_P_Type__c+'</td><td style="border: 1px solid black;">';
                        
                         //Plan Line
                         String[] splitString = items.ASI_MFM_Plan_Line_ID__c.split(';');
                         for(String str: splitString) {
                            if(str.length()>0){
                                if(PlanLineMap.containsKey(str)){
                                    String URLLink = URL.getSalesforceBaseUrl().toExternalForm()   + '/' + PlanLineMap.get(str).Id ;
                                    body += '<a href=\"'+URLLink+'\">'+PlanLineMap.get(str).Name+'</a>' + '<br/>' ;
                                }
                            }
                        }
                        
                        body+='</td><td style="border: 1px solid black;">';
                         String[] splitString2 = items.ASI_MFM_PO_Line_ID__c.split(';');
                         Set<id> tempPOset= new Set<id>();
                         for(String str: splitString2) {
                             if(str.length()>0){
                                 if(POlineMap.containsKey(str) && !tempPOset.contains(str)){
                                     tempPOset.add(str);
                                      String URLLink = URL.getSalesforceBaseUrl().toExternalForm()   + '/' + POlineMap.get(str).ASI_MFM_PO__c ;
                                       body += '<a href=\"'+URLLink+'\">'+POlineMap.get(str).ASI_MFM_PO__r.Name+'</a>' + '<br/>' ;
                                 }
                             }
                         }
                        body+='</td><td style="border: 1px solid black;">'+items.ASI_MFM_Plan__r.Owner.Name+'</td><td style="border: 1px solid black;">'+
                            items.ASI_MFM_Plan__r.ASI_MFM_Status__c+'</td><td style="border: 1px solid black;text-align:right;">'+
                            ((Decimal)items.get('ASI_MFM_PlanAmount_YTD_'+FieldNumber+'__c')).format()+'</td><td style="border: 1px solid black;text-align:right;">'+
                            ((Decimal)items.get('ASI_MFM_POAmount_YTD_'+FieldNumber+'__c')).format()+'</td><td style="border: 1px solid black;text-align:right;">'+
                            ((Decimal)items.get('ASI_MFM_PORAmount_M1YTD_'+FieldNumber+'__c')).format()+'</td><td style="border: 1px solid black;text-align:right;">'+
                            ((Decimal)items.get('ASI_MFM_Month_'+FieldNumber+'_PORAmount__c')).format()+'</td><td style="border: 1px solid black;text-align:right;">'+
                            ((Decimal)items.get('ASI_MFM_PaymentAmount_YTD_'+FieldNumber+'__c')).format()+'</td><td style="border: 1px solid black;text-align:right;">'+
                            ((Decimal)items.get('ASI_MFM_Plan_Balance_POR_'+FieldNumber+'__c')).format()+'</td><td style="border: 1px solid black;text-align:right;">'+
                            ((Decimal)items.get('ASI_MFM_PO_Balance_POR_'+FieldNumber+'__c')).format()+'</td></tr>';
                    }
                    body+='</table>';
                    body+='<b><u style="font-family: Century Gothic;font-size:10px;">If you already received goods or service, please proceed PO receipt. Also, please submit payment request and ensure the invoice agrees with actual goods/services received and approved PO.</u> </b>' + '<br/><br/>';
                    body+='<p style="font-family: Century Gothic;font-size:10px;">  If there is delay of receipt, please share with me status of PO. </p>';
                    body+='<p style="font-family: Century Gothic;font-size:10px;">Thank you </p>';
                    
                    
                    message.setSubject(subject);
                    message.setHtmlBody(body);///message.setBccSender(false); 
                    
                    mailList.add(message);
                }
            }
            //system.assertEquals(null, mailList);
            Messaging.sendEmail(mailList);
            
            Mesg+=' Email Sent Success !';
        }catch (DmlException dmle) {
            HasError=true;
            Mesg+='Send email error : '+dmle.getMessage();
        }catch(Exception e){
            HasError=true;
            
            Mesg+='Send email Exception : '+e.getMessage() ;
        }
        
        if(HasError){ //Error handling
            ASI_MFM_ByPass_Setting.ErrorHandling(Mesg,'ASI_MFM_KR_PORC_Controller2','Sending Email');
        }
        return Mesg;
    }
    
    
    @RemoteAction
    public static string uncheckallflag(String inputdata){
        string Mesg='';
        string Version='V1';
        Version=String.valueOf(ASI_MFM_Setting__c.getOrgDefaults().ASI_MFM_KR_POReceiptClosing_DataVersion__c) ;
        List<ASI_MFM_Settings__c> CheckedList= [select id,ASI_MFM_Email_Sent_Time__c,ASI_MFM_Email_Notification__c from ASI_MFM_Settings__c where ASI_MFM_Email_Notification__c =true and ASI_MFM_Version__c =:  Version];
        for(ASI_MFM_Settings__c s:CheckedList){
            s.ASI_MFM_Email_Sent_Time__c=null;
            s.ASI_MFM_Email_Notification__c=false;
            
        }
        if(CheckedList.size()>0){
            Boolean HasError= false; 
            try{
                update CheckedList;
                Mesg+='Uncheck All Flag Success !';
            } catch (DmlException dmle) {
                HasError=true;
                Mesg+='Send email error : '+dmle.getMessage();
            }catch(Exception e){
                HasError=true;
                Mesg+='Send email Exception : '+e.getMessage() ;
            }
            
            if(HasError){ //Error handling
                ASI_MFM_ByPass_Setting.ErrorHandling(Mesg,'ASI_MFM_KR_PORC_Controller2','Uncheck all Email Flag');
            }
            
        }else{
            Mesg+=' No records is checked email Sent !';
        }
        return Mesg;  
    }
    
    
    @RemoteAction
    public static string poReceiptClose(string yearstr,string monthstr,string datestr){
        //init
        List<ASI_MFM_PO_Receipt_Item__c> PORList =new list<ASI_MFM_PO_Receipt_Item__c> ();
        string Mesg='';
        set<string> PORLineIdSet =new set<string>();
        
        date postgldate=Date.newInstance(integer.valueOf(yearstr), integer.valueOf(monthstr)+1, integer.valueOf(datestr));
        try{
            List<ASI_MFM_PO_Receipt_Item__c> POReceiptItemList=[select id ,name,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_ACC_Verify__c,ASI_MFM_Receipt_Date__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_Opening_Balance__c from ASI_MFM_PO_Receipt_Item__c where  RecordType.DeveloperName= 'ASI_MFM_KR_PO_Receipt_item' and ASI_MFM_ACC_Verify__c=false];
            integer num=0;
            
            for(ASI_MFM_PO_Receipt_Item__c porl: POReceiptItemList){
                //Update current Month
                if(porl.ASI_MFM_ACC_Verify__c==false){//if(porl.ASI_MFM_Receipt_Date__c.month()==CurrentMon){
                    //construct fIscal year 
                    string NowFY='FY';
                    if(porl.ASI_MFM_Receipt_Date__c.month()>0 && porl.ASI_MFM_Receipt_Date__c.month()<7){  
                        NowFY=NowFY+string.valueof(porl.ASI_MFM_Receipt_Date__c.year()-1).substring(2,4)+string.valueof(porl.ASI_MFM_Receipt_Date__c.year()).substring(2,4);
                    }else{
                        NowFY=NowFY+string.valueof(porl.ASI_MFM_Receipt_Date__c.year()).substring(2,4)+string.valueof(porl.ASI_MFM_Receipt_Date__c.year()+1).substring(2,4);
                    }
                    
                    //count total amount 
                    num++;
                    //update JDE Accruals  in po receipt line 
                    
                    if(NowFY== porl.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c){
                        //Only in current Fiscal year can update 'open Balance '
                        PORList.add(new ASI_MFM_PO_Receipt_Item__c(id=porl.id,ASI_MFM_ACC_Verify__c = true,ASI_MFM_Post_G_L_Date__c=postgldate, ASI_MFM_Opening_Balance__c=porl.ASI_MFM_Remaining_Balance__c)); 
                    }else{
                        PORList.add(new ASI_MFM_PO_Receipt_Item__c(id=porl.id,ASI_MFM_ACC_Verify__c = true,ASI_MFM_Post_G_L_Date__c=postgldate)); 
                    }
                    
                }
                
            }
            //Update 
            if(PORList.size()>0){
                update PORList;
            }
            Mesg+=' Save Success ! Total '+num+ ' Records Updated.';
        }catch (DmlException dmle) {
            Mesg+=dmle.getMessage();
        }catch(Exception e){
            Mesg+=e.getMessage() ;
        }
        
        return Mesg;
    }
    
    
    //***************************************Function********************************************************************
    
    public void toggleSort() {
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        
        queryRecord();
    }
    
    
    public String sortField {
        get  { 
            if (sortField == null){
                sortField = ' ASI_MFM_Plan__c '; 
                return sortField;   
            }else{
                system.debug('Now sortField'+sortField);
                String FieldNumber=  string.valueOf(MonthMap.get(string.valueOf(CurrentMonth)));
                if(sortField=='ASI_MFM_PlanAmount_YTD_'){
                    sortField='ASI_MFM_PlanAmount_YTD_'+FieldNumber+'__c';
                }
                
                if(sortField=='ASI_MFM_POAmount_YTD_'){
                    sortField='ASI_MFM_POAmount_YTD_'+FieldNumber+'__c';
                }
                
                if(sortField=='ASI_MFM_PORAmount_M1YTD_'){
                    sortField='ASI_MFM_PORAmount_M1YTD_'+FieldNumber+'__c';
                }
                if(sortField=='ASI_MFM_Month_'){
                    sortField='ASI_MFM_Month_'+FieldNumber+'_PORAmount__c';
                }
                if(sortField=='ASI_MFM_PaymentAmount_YTD_'){
                    sortField='ASI_MFM_PaymentAmount_YTD_'+FieldNumber+'__c';
                }
                
                if(sortField=='ASI_MFM_Plan_Balance_POR_'){
                    sortField='ASI_MFM_Plan_Balance_POR_'+FieldNumber+'__c';
                }
                
                if(sortField=='ASI_MFM_PO_Balance_POR_'){
                    sortField= 'ASI_MFM_PO_Balance_POR_'+FieldNumber+'__c';
                }
                return sortField;   
            } 
            
        }
        set;
    }
    
    public String sortAmountField {
        get  { if (sortField == null) {sortField = ' ASI_MFM_Plan__c '; } return sortField;  }
        set;
    }
    
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
    
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter = Test.isRunningTest() ? 0 : counter-list_size;
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        queryRecord();
        pageNumber=getPageNumber();
        return null;
    }
    
    
    public Integer getTotalPages() {
        system.debug(list_size+' || '+total_size+'Current Page:' + math.mod(total_size, list_size) );
        if (math.mod(total_size, list_size) > 0) {
            
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    // Data Structure
    public Class interimData{
        public ASI_MFM_Settings__c linetems {get; set;}
        public List<ASI_MFM_PO_Receipt_Item__c> PORLine{set;get;}{PORLine=new List<ASI_MFM_PO_Receipt_Item__c>();}
        public boolean HasLine {get; set;} {HasLine=false;} 
        Public string Bid  {set;get;}{Bid='';}
        Public Decimal PlanAmtYTD {set;get;} {PlanAmtYTD=0;}//Plan Amount YTD Apr(P10) ASI_MFM_PlanAmount_YTD_10__c
        Public Decimal POAmtYTD {set;get;} {POAmtYTD=0;} //PO Amount YTD Apr(P10) ASI_MFM_POAmount_YTD_10__c
        Public Decimal PORAmtM1YTD {set;get;} {PORAmtM1YTD=0;} //POR Amount M-1YTD Apr(P10) ASI_MFM_PORAmount_M1YTD_10__c 
        Public Decimal PORAmtMTD {set;get;} {PORAmtMTD=0;}   //POR Amount Mar(P9) ASI_MFM_Month_9_PORAmount__c
        Public Decimal PaymentAmtYTD {set;get;} {PaymentAmtYTD=0;} //Payment Amount YTD Sep(P3) ASI_MFM_PaymentAmount_YTD_3__c
        
        Public Decimal PlanBalance {set;get;} {PORAmtMTD=0;} //Plan Balance Mar(P9) ASI_MFM_Plan_Balance_POR_9__c
        Public Decimal POBalance {set;get;} {PORAmtMTD=0;} //PO Balance Apr(P10) ASI_MFM_PO_Balance_POR_10__c
        
        Public Decimal PaymentAmtMTD {set;get;} {PaymentAmtMTD=0;} //Payment Amount MTD
        
    }
    
    
    private static Map<String, Integer> MonthMap = new Map<String, Integer>{
        '1' => 7,
            '2' => 8,
            '3' => 9,
            '4' => 10,
            '5' => 11,
            '6' => 12,
            '7' => 1,
            '8' => 2,
            '9' => 3,
            '10' => 4,
            '11' => 5,
            '12' => 6
            
            };
                
                
                
                }