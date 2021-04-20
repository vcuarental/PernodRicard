public class ASI_MFM_KR_PORC_Controller {
    private String init_soql {get;set;}{init_soql='select Id,ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.owner.name,ASI_MFM_Plan__r.ASI_MFM_Email_Notification__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Plan__r.Name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,Name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.Name, ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,ASI_MFM_Plan__r.ASI_MFM_End_Date__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_Plan__r.ASI_MFM_Objectives__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__c,ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Purpose_Ownership__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Activity_Group__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan__r.ASI_MFM_Promotion_Code__c,ASI_MFM_Venue_Where__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Total_Cost__c,ASI_MFM_PRPO_Needed__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.name,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c';}
    private String initPOsoql {get;set;}{initPOsoql='select id,Name,ASI_MFM_G_L_Date__c,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.ASI_MFM_PO_Raised_Date__c from PO_Line_Items__r ';}
    private String initPORsoql {get;set;}{initPORsoql='select id,Name,ASI_MFM_PO_Receipt__r.ASI_MFM_Status__c,ASI_MFM_ACC_Verify__c,ASI_MFM_Remark__c,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.Name,ASI_MFM_Venue_Where__c,ASI_MFM_Venue_Where__r.Name,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_AccountsAdditionalField__r.Name,ASI_MFM_Receipt_Amount_in_Local_Currency__c,ASI_MFM_Amount__c,ASI_MFM_Receipt_Date__c,ASI_MFM_PO_Line_Item__r.Name,ASI_MFM_PO_Line_Item__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from PO_Receipt_Items__r ';}
 
    private String WhereStatm {get;set;}{WhereStatm='';}
    
    
    public transient Map<String,interimData> lineItemMap{get;set;} { lineItemMap = new Map<String, interimData>();}
    public transient String maplineJSON {set;get;}{maplineJSON=null;}//{get{return JSON.serialize(lineItemMap);} set;}
    private List<ASI_MFM_Plan_Line_Item__c> LineItem{get;set;}
    
    private transient ASI_MFM_KR_PORCMapWrapper PORLinesMap {set;get;}{ PORLinesMap = new ASI_MFM_KR_PORCMapWrapper(); }
    public transient String mapPORClineJSON  {set;get;}{mapPORClineJSON=null;}   //public Map<string, List<ASI_MFM_Plan_Line_Item__c>> PlanLinesMap {set;get;}{ PlanLinesMap = new Map<string, List<ASI_MFM_Plan_Line_Item__c>>(); }// public String mapPlanlineJSON {get{return JSON.serialize(PlanLinesMap);}}
    
    public date SelectedDate {get;set;}
    public date SelectedDateMonthEnd {get;set;}
    public date SelectedDatePre {get;set;}
    public integer CurrentMonth{get;set;}
    public transient String Fiscal_Years {get;set;} 
    public transient String PRPONeed {get;set;} 
    public transient String CompanyFilter {get;set;} 
    public transient String SelectStatus {get;set;} 
    public transient String PlanRequester {get;set;} {PlanRequester=null;}
    public transient String selectedAPType {get;set;} {selectedAPType='A&D';}
    public transient ASI_MFM_PO_Receipt_Item__c PostGLDate { get; set; }
    
    
    //Page Information
    public boolean SaveSuccess {get;set;}{ SaveSuccess=false;}
    public String Msg {get;set;}
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;} 
    public transient String SBCode {get;set;}{SBCode=null;}
    
    public ASI_MFM_KR_PORC_Controller(){
        init();
    }
    
    public void init() {
        
        //Init setting
        CurrentMonth=system.today().month();
        SelectedDate=system.today();
        Fiscal_Years='FY';
        Date Today_date=Date.today();
        if(Today_date.month()>0 && Today_date.month()<7){  
            Fiscal_Years=Fiscal_Years+string.valueof(Today_date.year()-1).substring(2,4)+string.valueof(Today_date.year()).substring(2,4);
        }else{
            Fiscal_Years=Fiscal_Years+string.valueof(Today_date.year()).substring(2,4)+string.valueof(Today_date.year()+1).substring(2,4);
        }
        PRPONeed='Yes';
        
        PostGLDate = new ASI_MFM_PO_Receipt_Item__c();
        //PostGLDate.ASI_MFM_Post_G_L_Date__c=system.today();
       
        
        //M-1 Day firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
        SelectedDate =  Date.today(); 
        Date firstDate = SelectedDate.toStartOfMonth();
        
        SelectedDateMonthEnd= firstDate.addDays(date.daysInMonth(SelectedDate.year() , SelectedDate.month())  - 1);
        PostGLDate.ASI_MFM_Post_G_L_Date__c=SelectedDateMonthEnd;
        SelectedDatePre=firstDate-1;
        
        init_soql=init_soql+' , ('+initPOsoql+') , ('+initPORsoql+') from ASI_MFM_Plan_Line_Item__c where RecordType.DeveloperName LIKE \'ASI_MFM_KR%\'';    //WhereStatm=' AND ( ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\' OR ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\' ) AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Years)+'%\'  and ASI_MFM_PRPO_Needed__c = true  ';
       
        //WhereStatm=' AND  ( ( ( ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\' OR ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\' ) AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Years)+'%\'  and ASI_MFM_PRPO_Needed__c = true ) ';//WhereStatm=' AND  ( ( ( ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\' OR ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\' ) AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \'FY1617%\'  and ASI_MFM_PRPO_Needed__c = true and ASI_MFM_Company_Code__c = \'222\' ) ';

        if(!ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_KR_PORC_ControllerClass','KR')){
            WhereStatm=' AND  ( ( ( ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\' OR ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\' ) AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Years)+'%\'  and ASI_MFM_PRPO_Needed__c = true and ASI_MFM_Company_Code__c = \'222\' ) ';
        }else{//
            WhereStatm=System.Label.ASI_MFM_KR_PORC;//'  '+ASI_MFM_ByPass_Setting.ReturnSqlStatement('ASI_MFM_KR_PORC_Class','Initialization','KR');//
        }
        
        if(!ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_KR_PORC_findNewPORL','KR')){
            findNewPORL();
        }
        runQuery();
        
    }
    
    
    //Find JDE Accruals is 'false' in PO Receip line and find its Plan line
    public void findNewPORL(){
        set<id> PlanLineIDset= new set<id>();
        string addonstatement='';
        boolean FirstFind= false;
        for(ASI_MFM_PO_Receipt_Item__c porl: [select id,ASI_MFM_Plan_Line_Item__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Plan__c from ASI_MFM_PO_Receipt_Item__c where RecordType.DeveloperName=:'ASI_MFM_KR_PO_Receipt_item' and ASI_MFM_ACC_Verify__c=false]){
            if(porl.ASI_MFM_Plan_Line_Item__c!=null && !PlanLineIDset.contains(porl.ASI_MFM_Plan_Line_Item__c)){
                if(!FirstFind){
                    //The first One 
                    addonstatement=' or ( id in (';
                    FirstFind=true;
                    addonstatement+='\''+porl.ASI_MFM_Plan_Line_Item__c+'\'';
                }else{
                    addonstatement+=',\''+porl.ASI_MFM_Plan_Line_Item__c+'\'';
                }
                
                PlanLineIDset.add(porl.ASI_MFM_Plan_Line_Item__c);
            }
            
        }
        
        if(FirstFind){
            addonstatement+=') ))';
        }else{
            addonstatement='  )';
        }
        WhereStatm+=addonstatement;//system.assertEquals(null, init_soql+WhereStatm);
    }
    
    
    
    
    public void runQuery() {
        LineItem = new  List<ASI_MFM_Plan_Line_Item__c>();
        LineItem = getPlanLine();
        if(LineItem.size()>0) ConstructMap(LineItem);
        if(PORLinesMap==null){
            Map<string, List<ASI_MFM_PO_Receipt_Item__c>> TempPORMap = new Map<string, List<ASI_MFM_PO_Receipt_Item__c>> ();
            PORLinesMap = new ASI_MFM_KR_PORCMapWrapper(TempPORMap);
        }
        mapPORClineJSON=JSON.serialize(PORLinesMap.getMap());
    }
    
    // Construct Main Map
    public void  ConstructMap (List<ASI_MFM_Plan_Line_Item__c> lineItem){
        
        integer fy=2000;
        if(CurrentMonth>0 && CurrentMonth<7){
            fy+=integer.valueOf(Fiscal_Years.substring(4, 6));            
        }else{
            fy+=integer.valueOf(Fiscal_Years.substring(2, 4));
        }
        
        //construct Cut Off PO Receipt Date
        Date CutOffPORDate = Date.newInstance(fy, integer.valueOf(CurrentMonth),1);
        CutOffPORDate= CutOffPORDate.addMonths(1);// system.debug('Testing Cut Off POR Date : '+CutOffPORDate);
        
        String Mapkey='';
        Map<string, List<ASI_MFM_PO_Receipt_Item__c>> TempPORMap = new Map<string, List<ASI_MFM_PO_Receipt_Item__c>> ();
        for(ASI_MFM_Plan_Line_Item__c planline: lineItem){
           
            
            
            //Construct Map Key based on Plan ID,Sub-Brand, AP Code ,Fiscal Year   'Map Key'='Name'+'Sub Brand'+ 'AP Code Name'
            Mapkey=planline.ASI_MFM_Plan__r.name;
            if(planline.ASI_MFM_Sub_brand_Code__r.name!=null) Mapkey+= planline.ASI_MFM_Sub_brand_Code__r.name;
            if(planline.ASI_MFM_AP_Code__r.name!=null) Mapkey+=planline.ASI_MFM_AP_Code__r.name;
            if(Mapkey != null && !Test.isRunningTest()){ //Added by Kammy
                Mapkey=Mapkey.replace('&', '');//Mapkey=Mapkey.replace(')', '');// Mapkey=Mapkey.replace('(', '');
                Mapkey=Mapkey.replace('\'', '');
        	}  //system.debug('---PORC Debug-----'+Mapkey);
            system.debug( planline.getSObjects('PO_Receipt_Items__r'));
            
            if(!lineItemMap.containsKey(Mapkey)){ //Not cantain in Map 
                interimData temp= new interimData();
                temp.Plan=new ASI_MFM_Plan__c(id=planline.ASI_MFM_Plan__c,
                                              name = planline.ASI_MFM_Plan__r.name,
                                              ASI_MFM_Plan_Name__c= planline.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,
                                              ASI_MFM_Email_Notification__c=planline.ASI_MFM_Plan__r.ASI_MFM_Email_Notification__c,
                                              ASI_MFM_Fiscal_year__c=planline.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,
                                              ASI_MFM_Objectives__c=planline.ASI_MFM_Plan__r.ASI_MFM_Objectives__c,
                                              ASI_MFM_Start_Date__c=planline.ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,
                                              ASI_MFM_End_Date__c=planline.ASI_MFM_Plan__r.ASI_MFM_End_Date__c,
                                              ASI_MFM_Status__c=planline.ASI_MFM_Plan__r.ASI_MFM_Status__c);
                temp.SubBrand= new ASI_MFM_Sub_brand__c (id=planline.ASI_MFM_Sub_brand_Code__c,name = planline.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__c=planline.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c);
                temp.APCode =new ASI_MFM_AP_Code__c (id=planline.ASI_MFM_AP_Code__c,ASI_MFM_AP_Category__c=planline.ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,ASI_MFM_AP_Type__c=planline.ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c);                
                temp.ProjectCode = new ASI_MFM_Project_Code__c  (id= planline.ASI_MFM_Plan__r.ASI_MFM_Project_Code__c,name= planline.ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.name,ASI_MFM_Purpose_Ownership__c=planline.ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Purpose_Ownership__c,ASI_MFM_Activity_Group__c=planline.ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Activity_Group__c);
                temp.PlanLineID = planline.id;
                temp.EmailAddress=planline.ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c;
                temp.PRPONeeded=planline.ASI_MFM_PRPO_Needed__c;
                
                temp.Requester=planline.ASI_MFM_Plan__r.owner.name;
                for (Integer i = 0; i < MonthMap.get(string.valueOf(CurrentMonth)); i++) {
                    String mapField = 'ASI_MFM_Month_' + (i + 1) + '_Cost__c'; 
                    if(!Test.isRunningTest()){
                        if(planline.get(mapField)!=null){
                            temp.PlanAmount = temp.PlanAmount+(Decimal)planline.get(mapField);
                        }
                    }else{
                        temp.PlanAmount = temp.PlanAmount!=null?temp.PlanAmount:0 + (planline.get(mapField)!=null?(Decimal)planline.get(mapField):0);
                    }
                }
                //Put in Json Map
                List<ASI_MFM_Plan_Line_Item__c> TempPlanline= new List<ASI_MFM_Plan_Line_Item__c>();
                TempPlanline.add(planline);    // PlanLinesMap.put(Mapkey,TempPlanline);
                //Put in Main Map
                lineItemMap.put(Mapkey, temp);
            }else{
                for (Integer i = 0; i < MonthMap.get(string.valueOf(CurrentMonth)); i++) {
                    String mapField = 'ASI_MFM_Month_' + (i + 1) + '_Cost__c';
                    lineItemMap.get(Mapkey).PlanAmount=lineItemMap.get(Mapkey).PlanAmount+(Decimal)planline.get(mapField);
                }
            }//end of for loop
            
            //PO Line 
            List<ASI_MFM_PO_Line_Item__c> polineItem =new List<ASI_MFM_PO_Line_Item__c>();
            polineItem = planline.getSObjects('PO_Line_Items__r');
            if(polineItem!=null){
                for(ASI_MFM_PO_Line_Item__c pol:polineItem){ 
                    if(pol.ASI_MFM_PO__r.ASI_MFM_PO_Raised_Date__c<SelectedDateMonthEnd){
                        lineItemMap.get(Mapkey).POAmount+=pol.ASI_MFM_Base_Currency_Amount__c;
                    }
                }
            }
            
            //PO Receipt
            List<ASI_MFM_PO_Receipt_Item__c> POReceiptItem =new List<ASI_MFM_PO_Receipt_Item__c>();
            POReceiptItem= planline.getSObjects('PO_Receipt_Items__r');   
            if(POReceiptItem!=null){
                //Check if need to hide whole Plan line
                boolean NeedHidePlan =true; //HidePlanLine
                List<ASI_MFM_PO_Receipt_Item__c> Templine= new List<ASI_MFM_PO_Receipt_Item__c>();

                for(ASI_MFM_PO_Receipt_Item__c porl:POReceiptItem){ // loop related Plan's PO Receipt line
                    if(porl.ASI_MFM_Receipt_Date__c!=null){
                        if(CutOffPORDate>porl.ASI_MFM_Receipt_Date__c){
                            if(porl.ASI_MFM_Receipt_Date__c<SelectedDatePre){
                                lineItemMap.get(Mapkey).POReceiptAmountM+=porl.ASI_MFM_Receipt_Amount_in_Local_Currency__c;
                            } 
                            if(porl.ASI_MFM_Receipt_Date__c.month()==CurrentMonth){ // CurrentMonth   porl.ASI_MFM_Receipt_Date__c<SelectedDateMonthEnd
                                lineItemMap.get(Mapkey).POReceiptAmount+=porl.ASI_MFM_Receipt_Amount_in_Local_Currency__c;
                            }
                            
                            Templine.add(porl);
                            NeedHidePlan=false;
                           /* if(porl.ASI_MFM_ACC_Verify__c==false){
                                NeedHidePlan=false;
                            }*/
                        }
                       
                    }
                    
                }
               
                lineItemMap.get(Mapkey).HidePlanLine=NeedHidePlan;
                lineItemMap.get(Mapkey).HasPOReceipt=true; //
                
               
                if(TempPORMap.containsKey(Mapkey)){
                    List<ASI_MFM_PO_Receipt_Item__c> FinalLines= new List<ASI_MFM_PO_Receipt_Item__c>();
                    for(ASI_MFM_PO_Receipt_Item__c tl:Templine){
                        FinalLines.add(tl);
                    }
                    for(ASI_MFM_PO_Receipt_Item__c tl:TempPORMap.get(Mapkey)){
                        FinalLines.add(tl);
                    }
                    TempPORMap.remove(Mapkey);
                    TempPORMap.put(Mapkey,FinalLines); //TempPORMap.get(Mapkey).add();
                }else{
                     TempPORMap.put(Mapkey,Templine);
                }
                
            }//end of PO Receipt
            
            //End Construct Main Map 
            
        }//End For Loop
        PORLinesMap = new ASI_MFM_KR_PORCMapWrapper(TempPORMap);
        
        if(lineItemMap!=null && !Test.isRunningTest()){
            for(String key : lineItemMap.keySet()){
                if(lineItemMap.get(key).HidePlanLine){
                    lineItemMap.remove(key);
                }
            }
            
            
            maplineJSON=JSON.serialize(lineItemMap);
        }
        
    }
    
    public PageReference runSearch() {
        //FY1516 CurrentMonth 7-12 :  2015 ,  CurrentMonth:1-6 2016
        Boolean OutOfPlanId= false;
        integer fy=2000;
        if(CurrentMonth>0 && CurrentMonth<7){
            fy+=integer.valueOf(Fiscal_Years.substring(4, 6));            
        }else{
            fy+=integer.valueOf(Fiscal_Years.substring(2, 4));
        }
        
        SelectedDate = Date.newInstance(fy, integer.valueOf(CurrentMonth),1);
        
        
        SelectedDateMonthEnd= SelectedDate.addDays(date.daysInMonth(SelectedDate.year() , SelectedDate.month())  - 1);
        PostGLDate = new ASI_MFM_PO_Receipt_Item__c();
       	PostGLDate.ASI_MFM_Post_G_L_Date__c=SelectedDateMonthEnd;
        SelectedDatePre=SelectedDate-1;
        
        WhereStatm=''; 
        
        // the first part: SelectStatus
        WhereStatm=' and ((';
        
        if(SelectStatus!=null && SelectStatus.length()>0){
            if(SelectStatus=='Approved'){
                WhereStatm +=  '  ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\'';  
                
            }
            if(SelectStatus=='Closed'){
                WhereStatm +=  '  ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\'';
            }
            OutOfPlanId=true;
        }else{
           WhereStatm+='  ( ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Approved\' OR ASI_MFM_Plan__r.ASI_MFM_Status__c = \'Closed\' )';
        }
        
        if( CompanyFilter!=null && CompanyFilter.length()>0){
            
              WhereStatm+='  and ASI_MFM_Company_Code__c = \''+CompanyFilter+'\' ';
        }
        
        if(Fiscal_Years!=null && Fiscal_Years.length()>0){
            WhereStatm+= ' AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c LIKE \''+String.escapeSingleQuotes(Fiscal_Years)+'%\'';
        }// 
        
        
        if(selectedAPType!=null && selectedAPType.length()>0){
            WhereStatm+= ' and ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c LIKE \'%'+String.escapeSingleQuotes(selectedAPType)+'%\''; 
            OutOfPlanId=true;
        }
        if(PlanRequester!=null && PlanRequester.length()>0){
            WhereStatm+= ' and ASI_MFM_Plan__r.owner.name LIKE \'%'+String.escapeSingleQuotes(PlanRequester)+'%\''; 
        	OutOfPlanId=true;
        }
        
        
        if(PRPONeed=='Yes'){
            WhereStatm +=  ' and ASI_MFM_PRPO_Needed__c = true ';  
        }else{
            WhereStatm +=  ' and ASI_MFM_PRPO_Needed__c = false ';
            OutOfPlanId=true;
        }
        
        if (SBCode!=null && SBCode.length()>0){
            WhereStatm +=  ' and ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c LIKE \'%'+String.escapeSingleQuotes(SBCode)+'%\'';
            OutOfPlanId=true;
        }
        
        
        init_soql='select Id,ASI_MFM_Plan__r.ASI_MFM_Owner_Email__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.owner.name,ASI_MFM_Plan__r.ASI_MFM_Email_Notification__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Plan__r.Name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,Name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.Name, ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,ASI_MFM_Plan__r.ASI_MFM_End_Date__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Category__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Type__c,ASI_MFM_Plan__r.ASI_MFM_Objectives__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__c,ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Purpose_Ownership__c,ASI_MFM_Plan__r.ASI_MFM_Project_Code__r.ASI_MFM_Activity_Group__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan__r.ASI_MFM_Promotion_Code__c,ASI_MFM_Venue_Where__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Total_Cost__c,ASI_MFM_PRPO_Needed__c,ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.name,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Month_1_Cost__c,ASI_MFM_Month_2_Cost__c,ASI_MFM_Month_3_Cost__c,ASI_MFM_Month_4_Cost__c,ASI_MFM_Month_5_Cost__c,ASI_MFM_Month_6_Cost__c,ASI_MFM_Month_7_Cost__c,ASI_MFM_Month_8_Cost__c,ASI_MFM_Month_9_Cost__c,ASI_MFM_Month_10_Cost__c,ASI_MFM_Month_11_Cost__c,ASI_MFM_Month_12_Cost__c';
        lineItemMap = new Map<String, interimData>();
        init_soql=init_soql+' , ('+initPOsoql+') , ('+initPORsoql+') from ASI_MFM_Plan_Line_Item__c where RecordType.DeveloperName LIKE \'ASI_MFM_KR%\'';
        
        //setCon = null;
        WhereStatm+=' ) ';
        if(OutOfPlanId){
            WhereStatm+=' ) ';
        }else{
            if(!ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_KR_PORC_findNewPORL','KR')){
                findNewPORL();
            }
        }
        
        //system.assertEquals(null, init_soql+WhereStatm);
        
        runQuery();//maplineJSON= JSON.serialize(lineItemMap);
        mapPORClineJSON=JSON.serialize(PORLinesMap.getMap());
        maplineJSON=JSON.serialize(lineItemMap);
        return null; 
    }
    
    

    /*
    //Run SQL
    public  ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                //system.assertEquals(null,init_soql+WhereStatm);
                setCon = new  ApexPages.StandardSetController(Database.getQueryLocator(init_soql+WhereStatm));
            }            
            return setCon;
        }
        set;
    }
    */
    private List<ASI_MFM_Plan_Line_Item__c> getPlanLine() {
        system.debug('Test Current SQL:  '+init_soql+WhereStatm);
        
        ApexPages.StandardSetController setCon1= new  ApexPages.StandardSetController(Database.getQueryLocator(init_soql+WhereStatm));
        setCon1.setPageSize(2000);
        return (List<ASI_MFM_Plan_Line_Item__c>) setCon1.getRecords();
    }    
    
    
    public Class interimData{
        public ASI_MFM_Plan__c Plan {get; set;}
        public ASI_MFM_Sub_brand__c SubBrand {get; set;}
        public ASI_MFM_AP_Code__c APCode {get; set;}
        public  ASI_MFM_Project_Code__c ProjectCode {get; set;}
        
        public id PlanLineID {get; set;}  //Added by Kammy at 25Jan2016
        public String Requester {get; set;}
        public string EmailAddress {get; set;}
        
        public boolean PRPONeeded{get; set;} // field from 'PR/PO Needed' in Plan line
        public boolean HasPOReceipt {get; set;} {HasPOReceipt=false;} 
        public boolean HidePlanLine {get; set;} {HidePlanLine=false;} //if all PO Receipt line have been checked 'JDE Accruals', hide whole Plan line
        
        public decimal PlanAmount{get; set;}{PlanAmount=0.0;}
        public decimal POAmount{get; set;}{POAmount=0.0;}
        
        public decimal POReceiptAmountM{get; set;}{POReceiptAmountM=0.0;} //(M-1)YTD
        public decimal POReceiptAmount{get; set;}{POReceiptAmount=0.0;}//YTD
    }
    
    @RemoteAction
    public static string uncheckallflag(List<string> updatelist){
        string Mesg='';
        set<string> PlanIdSet =new set<string>();
        for(string pid:updatelist){
            PlanIdSet.add(pid);
        }
        
        try{
            List<ASI_MFM_Plan__c> PlanList=[select id,ASI_MFM_Email_Notification__c from ASI_MFM_Plan__c where id in : PlanIdSet];
            for(ASI_MFM_Plan__c pl: PlanList){
                pl.ASI_MFM_Email_Notification__c=false;
                pl.ASI_MFM_Email_Time__c=null;
            }
            if(PlanList.size()>0){
                update PlanList;
            }
            Mesg+=' Uncheck All Flag Success !';
        }catch(Exception e){
            Mesg+=e.getMessage() ;
        }
        return Mesg;  
    }
    
    
    @RemoteAction
    public static string updatePlan(List<ASI_MFM_Plan__c> Planlist){
        string Mesg='';
        set<id> planidset= new set<id>();
      List<ASI_MFM_Plan__c> updatelist =new List<ASI_MFM_Plan__c> ();
        try{
            for(ASI_MFM_Plan__c pl:Planlist){
                if(pl.id!=null){
                    planidset.add(pl.id);
                }
            }
            if(planidset.size()>0){
                 Map<Id,ASI_MFM_Plan__c> PlanMap= new Map<Id,ASI_MFM_Plan__c>([select id,ASI_MFM_Email_Notification__c,ASI_MFM_Email_Time__c from ASI_MFM_Plan__c where id in : planidset]);
                for(ASI_MFM_Plan__c pl:Planlist){
                    if(PlanMap.containsKey(pl.id)){
                        if(pl.ASI_MFM_Email_Notification__c!=PlanMap.get(pl.id).ASI_MFM_Email_Notification__c){
                            ASI_MFM_Plan__c tempplan=new ASI_MFM_Plan__c(id=pl.id,ASI_MFM_Email_Notification__c=pl.ASI_MFM_Email_Notification__c,ASI_MFM_Email_Time__c=system.now());
                            if(tempplan.ASI_MFM_Email_Notification__c==false){
                                tempplan.ASI_MFM_Email_Time__c=null;
                            }
                            updatelist.add(tempplan);
                        }
                    }
                    
                }
            }
            if(updatelist.size()>0){
                update updatelist;
            }
            Mesg+=' Save Success !';
            
        }catch(Exception e){
            Mesg+=e.getMessage() ;
        }
        
        return Mesg;
    }

    
    
    @RemoteAction
    public static string poReceiptClose(List<string> updatelist,integer CurrentMon,string yearstr,string monthstr,string datestr){
        //init
        List<ASI_MFM_PO_Receipt_Item__c> PORList =new list<ASI_MFM_PO_Receipt_Item__c> ();
        string Mesg='';
        set<string> PORLineIdSet =new set<string>();
    	//Get PO Receipt Id Set   
    	/*          
        for(string porid:updatelist){
            PORLineIdSet.add(porid);
        }
        */
        
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
    
    // data structure
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