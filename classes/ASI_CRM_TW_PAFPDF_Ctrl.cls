/*Filename:        ASI_CRM_TW_PAFPDF_Ctrl.cls
* Author:          TC (Introv Limited)
* Purpose:         Controller Class for Pre-approval Form PDF
* Created Date:    2017/05/24
*
* History
* -----------------------------------------------------------------------------
*/

public without sharing class ASI_CRM_TW_PAFPDF_Ctrl {
    public Id PAFId {set; get;}
    public List< ASI_HK_CRM_Pre_Approval_Form_Item__c>  PAFItems;
    public Map<Integer,productCat_VariableItem_Wrapper> Map_ProductCat_VariableItem{set; get;}
    public ASI_HK_CRM_Pre_Approval_Form__c  currentPAF {set; get;}
    //public List<bucketPeriod> bucketPeriods {get;set;}
    public List< ASI_CRM_Terms__c > appliedFixTerms ;
    public List< ASI_CRM_Terms_Application__c> appliedVarTerms ;
    public Map<Integer, terms_wrapper> Map_Section_Terms{get;set;}
    public List<Integer> outputControl {get;set;}    //Work as the output panel to control the content
    public Map<String,investment_wrapper> Map_Class_InvestmentLine{get;set;}
    public Integer noOfMonthPeriod{get;set;}
    public Integer sponsorshipSection {get; private set;}
    public String SupplierNameHeader {get;set;}    // [SH] 2019-06-13    
    public String SupplierNameFooter {get;set;}    // [SH] 2019-06-13    
    public Boolean hasLineRecord {get;set;}
    public Boolean hasInvestLine {get;set;}
    public Boolean hasDataError {get;set;}
    public String errorMsg{get;set;}
    
    public Boolean G_IsType_OnTrade{get;set;}
    public Boolean G_IsType_OnTrade2{get;set;}
    public Boolean G_IsType_LS{get;set;}
    //public Boolean IsONTrade {get;set;}
    //public Boolean IsLS {get;set;}

    public Map<Integer, quarterPeriod > map_QuarterPeriod{get;set;}
    public List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>childOutlets;
    public String childOutletNames{get;set;}
    public String summaryText{get;set;}
    public Decimal DefaultValue = 0;
    public String DefaultValueStr = '';
    
    public List<Id> TWvariable_itemID;
    
    public class productCat_VariableItem_Wrapper {
        public List< ASI_HK_CRM_Pre_Approval_Form_Item__c>  var_itemlines{get;set;}
        public List< variableItem_forDisplay>  variable_itemlines{get;set;}
        public String productCat {get;set;}
        public Integer getLineSize(){
            return variable_itemlines.size();
        }
        public productCat_VariableItem_Wrapper(){
            var_itemlines = new List< ASI_HK_CRM_Pre_Approval_Form_Item__c> ();
            variable_itemlines = new List< variableItem_forDisplay> ();
        }
    }
    
    public class variableItem_forDisplay{
        public Id itemLineId {get;set;}
        public String productCat {get;set;}
        public String itemName {get;set;}
        public Decimal pocketPrice {get;set;}
        public String keyLimitedSKU {get;set;} 
        public Integer noOfMonthPeriod {get;set;}
        public List<Integer> qtyTargets {get;set;}
        public Integer totalQty {get;set;}
        public List<Decimal> QuarterSum {get;set;}
        public Decimal FYSum {get;set;}
        //public Decimal totalCashPrize {get;set;}
        public String reward {get;set;}
        public Integer productCatSeq{get;set;}
        public Boolean isFirstItem{get;set;}
        public Boolean isLastRow{get;set;}
        
        public variableItem_forDisplay(){
            qtyTargets = new List<Integer>();
            QuarterSum = new List<Decimal>();
            isFirstItem= false;
            isLastRow  = false;
        }
    }
    
    /**
    public class bucketPeriod{
        public Integer fromMonth{get;set;}
        public Integer fromYear{get;set;}
        public Integer toMonth{get;set;}
        public Integer toYear{get;set;}
    }
    **/
    public class quarterPeriod{
        public Integer fromMonth{get;set;}
        public Integer fromYear{get;set;}
        public Integer fromDateId{get;set;}
        public Integer toMonth{get;set;}
        public Integer toYear{get;set;}
        public Integer toDateId{get;set;}
        public Integer noOfMonths{get;set;}
        
    }
    
    public class terms_wrapper{
        public Boolean noDetails{get;set;}
        public Integer sectionId{get;set;}
        public String setionTitle{get;set;}
        public List< String> subTerms {get;set;}
        public terms_wrapper(){
            setionTitle ='';
            noDetails=false;
            subTerms = new List< String> ();
        }
    }
    
    public class investment_wrapper{
        public String categoryName{get;set;}
        public Map<String, ASI_HK_CRM_Pre_Approval_Form_Item__c >Map_Seq_InvestmentItemLine {get;set;}
        
        public investment_wrapper(){
            Map_Seq_InvestmentItemLine= new Map<String,ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        }
    }
    
    public ASI_CRM_TW_PAFPDF_Ctrl(ApexPages.StandardController controller) {
        PAFId = ApexPages.currentPage().getParameters().get('id');
        init();
    }
    
    public void init(){
        hasLineRecord =false;
        hasDataError = false;
        hasInvestLine =false;
        errorMsg ='';
        G_IsType_OnTrade = TRUE;
        G_IsType_OnTrade2 = FALSE;
        G_IsType_LS = FALSE;
        
        if(String.isEmpty(PAFId)){
            hasDataError =true;
            errorMsg += 'Missing Pre-Approval Form Id.';
            return;
        }else{
            currentPAF = [Select Id, Name, ASI_HK_CRM_PAF_Customer__c , ASI_HK_CRM_PAF_Customer__r.name,ASI_CRM_No_of_Month_for_Print_Out__c, ASI_CRM_TW_Supplier__c, ASI_HK_CRM_PAF_Start_Date__c, ASI_HK_CRM_PAF_End_Date__c, ASI_CRM_TW_Act_on_behalf_of__c, ASI_CRM_Channel__r.ASI_CRM_PDF_Type__c, ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c
                          FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE Id = :PAFId];
            
            if (currentPAF.ASI_CRM_Channel__r.ASI_CRM_PDF_Type__c == 'ON Trade 2') {
                G_IsType_OnTrade = FALSE;
                G_IsType_OnTrade2 = TRUE;
        		G_IsType_LS = FALSE;
            }
            if (currentPAF.ASI_CRM_Channel__r.ASI_CRM_PDF_Type__c == 'LS') {
                G_IsType_OnTrade = FALSE;
                G_IsType_OnTrade2 = FALSE;
        		G_IsType_LS = TRUE;
            }
            
            PAFItems =[SELECT id, name, ASI_CRM_Contracted_Item__c, ASI_HK_CRM_Sub_brand__c, ASI_CRM_Contracted_Item__r.name, ASI_CRM_Contracted_Item__r.ASI_CRM_Item_Group_Chinese_Name__c, ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c, ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category__c, ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Chinese_Name__c, ASI_CRM_Reward_Method__c,
                        ASI_HK_CRM_Pre_Approval_Form_Lookup__c, ASI_CRM_Cash_Per_Bottle_w_VAT__c,RecordTypeId, ASI_HK_CRM_Mechanic__c,ASI_HK_CRM_Mechanic__r.name, ASI_HK_CRM_Mechanic__r.ASI_CRM_Mechanic_Class__c, ASI_HK_CRM_Mechanic__r.ASI_CRM_Exclude_from_Plan_Conversion__c, ASI_HK_CRM_Mechanic_Category__c, ASI_CRM_Mechanic_Detail__c, ASI_CRM_Cash_or_FOC__c, ASI_CRM_FOC_with_Orders__c,
                        ASI_HK_CRM_Target_Volume_Qty__c, ASI_CRM_Target_Volume_Qty_P1__c,ASI_CRM_Target_Volume_Qty_P2__c,ASI_CRM_Target_Volume_Qty_P3__c,ASI_CRM_Target_Volume_Qty_P4__c,ASI_CRM_Target_Volume_Qty_P5__c,ASI_CRM_Target_Volume_Qty_P6__c,
                        ASI_CRM_Target_Volume_Qty_P7__c,ASI_CRM_Target_Volume_Qty_P8__c,ASI_CRM_Target_Volume_Qty_P9__c,ASI_CRM_Target_Volume_Qty_P10__c,ASI_CRM_Target_Volume_Qty_P11__c,ASI_CRM_Target_Volume_Qty_P12__c,
                        ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Free_Bottle_Option_1__c, ASI_CRM_Cash_Amounts_w_VAT__c, ASI_CRM_FOC_Volume__c, ASI_CRM_Expenses_Product__r.Name, ASI_CRM_Expenses_Product__r.ASI_CRM_Item_Group_Chinese_Name__c,
                        ASI_HK_CRM_Mechanic__r.ASI_CRM_Display_Name__c,
                        ASI_CRM_Key_Limited_SKU__c, ASI_CRM_FOC_Free_Bottle__c, ASI_CRM_FOC_Buy_Bottle__c
                        FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
                        WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c =:PAFId 
                        AND ASI_HK_CRM_Mechanic__r.ASI_CRM_Exclude_from_Plan_Conversion__c = FALSE
                        AND (RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment') 
                        OR RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment') 
                        OR RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment')) 
                        ORDER BY ASI_CRM_Mechanic_Detail__c, ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c ASC, ASI_CRM_Contracted_Item__r.ASI_MFM_Item_Group_Code__c ASC
                        ];
            system.debug('PAFItems='+PAFItems.size());
            
            if(PAFItems.size() >0){ 
                hasLineRecord =true;
                TWvariable_itemID = new List<Id>();
                for(ASI_HK_CRM_Pre_Approval_Form_Item__c PAFI : PAFItems){
                    if(PAFI.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')){
                        TWvariable_itemID.add(PAFI.ASI_CRM_Contracted_Item__c);
                    }
                }
            }else{
                errorMsg+='Missing Pre-Approval Form Lines. Please input first.';
                return;
            }

            //For output layout control:
            outputControl = new List<Integer>();
            outputControl.add(1);
            
            //Error Checking:
            if(currentPAF.ASI_HK_CRM_PAF_Start_Date__c ==null || currentPAF.ASI_HK_CRM_PAF_End_Date__c ==null){
                hasDataError =true;
                errorMsg += 'Pre-Approval Form\'s Start Date or End Date is missing! Pleae input first.';
                return;
            }else if(currentPAF.ASI_HK_CRM_PAF_Start_Date__c>currentPAF.ASI_HK_CRM_PAF_End_Date__c ){
                hasDataError =true;
                errorMsg += 'Start Date should smaller than End Date';
                return;
            }
            
            // [SH] 2019-06-13   
            SupplierNameHeader = ''; 
            List<String> SupplierTemp = currentPAF.ASI_CRM_TW_Supplier__c != null? currentPAF.ASI_CRM_TW_Supplier__c.split('，'): new List<String>(); 
            for(integer i = 0; i<SupplierTemp.size();i++){
                SupplierNameHeader += SupplierTemp[i];
                if(i<SupplierTemp.size()-1)
                    SupplierNameHeader += '，\n';                                
            }
            
            SupplierNameFooter = currentPAF.ASI_CRM_TW_Supplier__c != null? currentPAF.ASI_CRM_TW_Supplier__c.replace('，', '，\n'): null;
            // END - SH
            
            //Sponsorship Section(default value=3):
            sponsorshipSection =3;
            ASI_CRM_TW_Settings__c  TWSettings= ASI_CRM_TW_Settings__c.getInstance();
            if(TWSettings!=null && TWSettings.ASI_CRM_TW_Section_Sponsorship_Display__c!=null ){
                sponsorshipSection = Integer.valueOf(TWSettings.ASI_CRM_TW_Section_Sponsorship_Display__c);
            }

            /**
            Integer startMonth = currentPAF.ASI_HK_CRM_PAF_Start_Date__c.month();
            Integer endMonth = currentPAF.ASI_HK_CRM_PAF_End_Date__c.month();
            Integer startYear = currentPAF.ASI_HK_CRM_PAF_Start_Date__c.year();
            Integer endYear = currentPAF.ASI_HK_CRM_PAF_End_Date__c.year();
            Integer totalMonths=0;
            Integer remainderMonth=0;
            Integer noOfColumns=0;
            Integer interval =Integer.valueOf(currentPAF.ASI_CRM_No_of_Month_for_Print_Out__c);
            
            totalMonths = Math.abs(currentPAF.ASI_HK_CRM_PAF_Start_Date__c.monthsBetween (currentPAF.ASI_HK_CRM_PAF_End_Date__c))+1;
            
            if(interval==null || interval==0){
                hasDataError =true;
                errorMsg = 'Invaild or missing "No. of Month for Print-out" value, which is to control the target quantity columns of the table. Please input first.';
                return;
            }**/
            
            /*****Split months by quarters start:****/
            map_QuarterPeriod = new Map<Integer,quarterPeriod>();
            Date tempDate = currentPAF.ASI_HK_CRM_PAF_Start_Date__c;
            noOfMonthPeriod =1;
            Integer tempMonth=tempDate.Month();
            Integer tempYear = tempDate.Year();
            Integer tempDateInt = tempYear*100+tempMonth;
            Integer endDateInt = currentPAF.ASI_HK_CRM_PAF_End_Date__c.Year()*100+currentPAF.ASI_HK_CRM_PAF_End_Date__c.Month();
            
            
            Do{
                Integer quarter =0;
                if(tempMonth>=1 && tempMonth<=3){
                    quarter =1;
                }else if(tempMonth>=4 && tempMonth<=6){
                    quarter =2;
                }else if(tempMonth>=7 && tempMonth<=9){
                    quarter =3;
                }else if(tempMonth>=10 && tempMonth<=12){
                    quarter =4;
                }
                
                Integer qIndex = tempYear*100+quarter;
                
                if(map_QuarterPeriod.get(qIndex)== null){
                
                    quarterPeriod qp = new quarterPeriod();
                    qp.fromMonth = tempMonth;
                    qp.fromYear = tempYear;
                    qp.fromDateId = tempYear*100+tempMonth;
                    qp.toMonth = tempMonth;
                    qp.toYear =tempYear;
                    qp.toDateId = tempYear*100+tempMonth;
                    qp.noOfMonths =1;
                    map_QuarterPeriod.put(qIndex,qp);
                    
                }else{
                    quarterPeriod qp = map_QuarterPeriod.get(qIndex);
                    Integer tempDateId = tempYear*100+tempMonth;
                    
                    if(tempDateId> qp.toDateId){
                        qp.toMonth =tempMonth;
                        qp.toYear =tempYear;
                        qp.toDateId = tempDateId;
                    }else if(tempDateId < qp.fromDateId){
                        qp.fromMonth =tempMonth;
                        qp.fromYear =tempYear;
                        qp.fromDateId = tempDateId;
                    }
                    qp.noOfMonths++;
                    map_QuarterPeriod.put(qIndex,qp);
                }
                
                tempDate= tempDate.addMonths(1);
                tempMonth=tempDate.Month();
                tempYear = tempDate.Year();
                tempDateInt =tempYear*100+tempMonth;
            }While(tempDateInt<=endDateInt);
            if(map_QuarterPeriod!=null && map_QuarterPeriod.size()>0)
                noOfMonthPeriod = map_QuarterPeriod.size();
                
            system.debug('map_QuarterPeriod='+map_QuarterPeriod);
            /*****Split months by quarters End****/
            
            /****
            remainderMonth = Math.Mod(totalMonths,interval);
            if(remainderMonth ==0){
                noOfColumns=  Integer.valueOf(Math.floor(totalMonths/interval));
            }else{
                noOfColumns=  Integer.valueOf(Math.floor(totalMonths/interval))+1;
            }
            
            system.debug('totalMonths='+totalMonths);
            system.debug('Interval='+currentPAF.ASI_CRM_No_of_Month_for_Print_Out__c);
            system.debug('remainderMonth='+remainderMonth);
            system.debug('noOfColumns='+noOfColumns);
            
            
            //To Create the Bucket/Month Period Table Headers:
            bucketPeriods = new List<bucketPeriod>();
            if(totalMonths<=interval){
                bucketPeriod bp = new bucketPeriod();
                bp.fromMonth = startMonth;
                bp.toMonth = endMonth;
                bp.fromYear = startYear;
                bp.toYear = endYear;
                bucketPeriods.add(bp);
            }else{
                Integer monthCounter =1;
                for(Integer m =0;m<noOfColumns ; m++){
                    bucketPeriod bp = new bucketPeriod();
                    bp.fromMonth = startMonth+m*interval;
                    
                    if((m+1)*interval<=totalMonths){
                        bp.toMonth = startMonth+m*interval+interval-1;
                    }else{
                        bp.toMonth = startMonth+totalMonths-1;
                    }
                    
                    if(Math.mod(bp.fromMonth,12)==0){
                        bp.fromYear = startYear+Integer.valueOf(Math.floor(bp.fromMonth/12.0))-1;
                    }else{
                        bp.fromYear = startYear+Integer.valueOf(Math.floor(bp.fromMonth/12.0));
                    }
                    if(Math.mod(bp.toMonth,12)==0){
                        bp.toYear = startYear+Integer.valueOf(Math.floor(bp.toMonth/12.0))-1;
                    }else{
                        bp.toYear = startYear+Integer.valueOf(Math.floor(bp.toMonth/12.0));
                    }
                    
                    if(bp.fromMonth>12){
                        bp.fromMonth = Math.mod(bp.fromMonth,12);
                    }
                    if(bp.toMonth>12){
                        bp.toMonth = Math.mod(bp.toMonth,12);
                    }
                    
                    bucketPeriods.add(bp);
                    
                }
            }
             system.debug(bucketPeriods);
            ***/
            
            //Sub total parameters & init the list first:
            List<Integer> subtotal_columnQty = new List<Integer> ();
            List<Decimal> subtotal_Quarter = new List<Decimal> ();

            Integer subtotal_totalQty = 0;
            Decimal subtotal_FY = 0;

            //Decimal subtotal_cashPrize =0;
            /**
            for(Integer i=0;noOfColumns>0 && i<noOfColumns; i++){
                Integer temp =0;
                subtotal_columnQty.add(temp);
            }
            **/
            for(Integer i=0; i<map_QuarterPeriod.size(); i++){
                Integer temp =0;
                subtotal_columnQty.add(temp);
                subtotal_Quarter.add(temp);
            }
           
            //To Build the map for data table:
            Map_ProductCat_VariableItem = new Map<Integer,productCat_VariableItem_Wrapper>();
            Map_Class_InvestmentLine = new Map<String,investment_wrapper>();
            
            
            //To get PAF Item Mechanic's Mechanic Class's pick list values and labels:
            Map<String,String> Mechanic_Name_Label = new Map <String, String>();
            Schema.DescribeFieldResult fieldResult = ASI_HK_CRM_Pre_Approval_Form_Mechanic__c.ASI_CRM_Mechanic_Class__c.getDescribe();
            List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry v : values) {
                Mechanic_Name_Label.put(v.getValue(), v.getLabel());
            }
            system.debug('Mechanic_Name_Label='+Mechanic_Name_Label);
            
            Map<String,String> mapKeyLimitedSKU = new Map <String, String>();
            Schema.DescribeFieldResult oKeyLimitedSKUResult = ASI_CRM_MY_SKUPriceCost__c.ASI_CRM_Key_Limited_SKU__c.getDescribe();
            List<Schema.PicklistEntry> oKeyLimitedSKUValues = oKeyLimitedSKUResult.getPicklistValues();
            for (Schema.PicklistEntry v : oKeyLimitedSKUValues) {
                mapKeyLimitedSKU.put(v.getValue(), v.getLabel());
            }
            
            Map<Id, ASI_CRM_MY_SKUPriceCost__c> PocketPriceMap = new Map<Id, ASI_CRM_MY_SKUPriceCost__c>();
            List<ASI_CRM_MY_SKUPriceCost__c> SKUPriceCostList = new List<ASI_CRM_MY_SKUPriceCost__c>();
            SKUPriceCostList = [Select Id, ASI_CRM_Type__c, ASI_CRM_Price__c, ASI_CRM_EffectiveDate__c, ASI_CRM_Applied_To__c, ASI_CRM_Item_Group__c
                                FROM ASI_CRM_MY_SKUPriceCost__c
                                Where ASI_CRM_Type__c = 'Pocket Price'
                                AND ASI_CRM_Applied_To__c includes (:currentPAF.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c)
                                AND ASI_CRM_EffectiveDate__c <= :currentPAF.ASI_HK_CRM_PAF_End_Date__c
                                AND ASI_CRM_Item_Group__c in :TWvariable_itemID
                                ORDER BY ASI_CRM_EffectiveDate__c DESC];
            For(ASI_CRM_MY_SKUPriceCost__c PocketPrice : SKUPriceCostList){
                if(PocketPriceMap.get(PocketPrice.ASI_CRM_Item_Group__c) != null){
                    ASI_CRM_MY_SKUPriceCost__c tempPP = PocketPriceMap.get(PocketPrice.ASI_CRM_Item_Group__c);
                    if(PocketPrice.ASI_CRM_EffectiveDate__c > tempPP.ASI_CRM_EffectiveDate__c){
                        PocketPriceMap.put(PocketPrice.ASI_CRM_Item_Group__c, PocketPrice);
                    }
                }else{
                    PocketPriceMap.put(PocketPrice.ASI_CRM_Item_Group__c, PocketPrice);
                }
            }
            /* get Key/Limited SKU */
            Map<Id, ASI_CRM_MY_SKUPriceCost__c> Key_Limited_SKUMap = new Map<Id, ASI_CRM_MY_SKUPriceCost__c>();
            List<ASI_CRM_MY_SKUPriceCost__c> SKUPriceCostList2 = new List<ASI_CRM_MY_SKUPriceCost__c>();
            SKUPriceCostList2 = [Select Id, ASI_CRM_Type__c, ASI_CRM_Key_Limited_SKU__c, ASI_CRM_EffectiveDate__c, ASI_CRM_Applied_To__c, ASI_CRM_Item_Group__c
                                FROM ASI_CRM_MY_SKUPriceCost__c
                                Where ASI_CRM_Type__c = 'Product Selection'
                                AND ASI_CRM_Applied_To__c includes (:currentPAF.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c)
                                AND ASI_CRM_EffectiveDate__c <= :currentPAF.ASI_HK_CRM_PAF_End_Date__c
                                AND ASI_CRM_Item_Group__c in :TWvariable_itemID
                                ORDER BY ASI_CRM_EffectiveDate__c DESC];             
            For(ASI_CRM_MY_SKUPriceCost__c Key_Limited_SKU : SKUPriceCostList2){
                if(Key_Limited_SKUMap.get(Key_Limited_SKU.ASI_CRM_Item_Group__c) != null){
                    ASI_CRM_MY_SKUPriceCost__c tempPP2 = Key_Limited_SKUMap.get(Key_Limited_SKU.ASI_CRM_Item_Group__c);
                    if(Key_Limited_SKU.ASI_CRM_EffectiveDate__c > tempPP2.ASI_CRM_EffectiveDate__c){
                        Key_Limited_SKUMap.put(Key_Limited_SKU.ASI_CRM_Item_Group__c, Key_Limited_SKU);
                    }
                }else{
                    Key_Limited_SKUMap.put(Key_Limited_SKU.ASI_CRM_Item_Group__c, Key_Limited_SKU);
                }
            }
            /*
            Map<String,String> Key_Limited_SKU_Label = new Map <String, String>();
            Schema.DescribeFieldResult fieldResult_SKU = ASI_HK_CRM_Pre_Approval_Form_Item__c.ASI_CRM_Key_Limited_SKU__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult_SKU.getPicklistValues();
            for( Schema.PicklistEntry v : ple) {
                Key_Limited_SKU_Label.put(v.getValue(), v.getLabel());
            }*/
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c  PAFI :PAFItems){
                system.debug('Handling Id='+PAFI.Id);
                //VaiableItems Handling:
                
                if(PAFI.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment')){

                    if(Map_ProductCat_VariableItem.get(Integer.valueOf(PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c))!=null){
                        system.debug('11VaiableItems exist start');
                        
                        variableItem_forDisplay itemLine = new variableItem_forDisplay();
                        itemLine.isLastRow = false;
                        itemLine.itemLineId = PAFI.Id;
                        itemLine.productCat= PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Chinese_Name__c;
                        //itemLine.itemName =PAFI.ASI_CRM_Contracted_Item__r.name;
                        itemLine.itemName =PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Item_Group_Chinese_Name__c != null && PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Item_Group_Chinese_Name__c != '' ? PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Item_Group_Chinese_Name__c : PAFI.ASI_CRM_Contracted_Item__r.name;
                        itemLine.pocketPrice = PocketPriceMap.get(PAFI.ASI_CRM_Contracted_Item__c) != null && PocketPriceMap.get(PAFI.ASI_CRM_Contracted_Item__c).ASI_CRM_Price__c != null? PocketPriceMap.get(PAFI.ASI_CRM_Contracted_Item__c).ASI_CRM_Price__c : DefaultValue;
                        //itemLine.keyLimitedSKU = Key_Limited_SKU_Label.get(PAFI.ASI_CRM_Key_Limited_SKU__c);
                        itemLine.keyLimitedSKU =  Key_Limited_SKUMap.get(PAFI.ASI_CRM_Contracted_Item__c) != null && Key_Limited_SKUMap.get(PAFI.ASI_CRM_Contracted_Item__c).ASI_CRM_Key_Limited_SKU__c != null? mapKeyLimitedSKU.get(Key_Limited_SKUMap.get(PAFI.ASI_CRM_Contracted_Item__c).ASI_CRM_Key_Limited_SKU__c) : DefaultValueStr;
                        
                        itemLine.noOfMonthPeriod =noOfMonthPeriod;                        
                        itemLine.totalQty =Integer.valueOf(PAFI.ASI_HK_CRM_Target_Volume_Qty__c);
                        
                        itemLine.productCatSeq = Integer.valueOf(PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c);
                        /*if(PAFI.ASI_CRM_Cash_Per_Bottle_w_VAT__c!=null ){
                            itemLine.totalCashPrize = itemLine.totalQty* PAFI.ASI_CRM_Cash_Per_Bottle_w_VAT__c;
                        }else{
                            itemLine.totalCashPrize=0;
                        }*/
                        
                        /* 20200708 - KL@Introv Start*/
                        //if(PAFI.ASI_CRM_Cash_or_FOC__c == 'Cash')
                        if((PAFI.ASI_CRM_Cash_or_FOC__c == 'Cash')|| (PAFI.ASI_CRM_Cash_or_FOC__c == 'Cash & FOC'))
                            itemLine.reward = 'NT$'+Integer.valueOf(PAFI.ASI_CRM_Cash_Per_Bottle_w_VAT__c).format();
                        else
                            itemLine.reward = '買'+Integer.valueOf(PAFI.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c).format()+'瓶送'+Integer.valueOf(PAFI.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c).format()+'瓶';
                        //Added by Victor for PAF合約不列印瓶費獎勵
                        //if(PAFI.ASI_CRM_FOC_with_Orders__c) itemLine.reward = '';
                        if((PAFI.ASI_CRM_FOC_with_Orders__c) && (PAFI.ASI_CRM_Cash_or_FOC__c != 'Cash & FOC')) itemLine.reward = '';
                        
                        /* 20200708 - KL@Introv End*/
                        
                        /***
                        Integer qtyFieldCounter =1;
                        for(Integer i=0;noOfColumns>0 && i<noOfColumns; i++){
                            Integer columnQty = 0;
                            for(Integer j=0;interval>0 && j<interval && qtyFieldCounter<=totalMonths && qtyFieldCounter<=12; j++){
                                String fieldName = 'ASI_CRM_Target_Volume_Qty_P'+qtyFieldCounter+'__c';
                                Decimal fieldQtyVal= (Decimal) PAFI.get(fieldName);
                                if(fieldQtyVal!=null ){
                                    columnQty+= Integer.valueOf(fieldQtyVal);
                                }
                                qtyFieldCounter++;
                            }
                            itemLine.qtyTargets.add(columnQty);
                            subtotal_columnQty[i]+=columnQty;
                        }
                        **/
                        
                        Integer qtyFieldCounter =1;
                        Integer loopCounter =0;
                        for(Integer periodId :map_QuarterPeriod.keySet()){
                            loopCounter++; 
                            Integer columnQty = 0;
                            for(Integer j = 0; j<map_QuarterPeriod.get(periodId).noOfMonths && qtyFieldCounter<=12; j++){
                                String fieldName = 'ASI_CRM_Target_Volume_Qty_P'+qtyFieldCounter+'__c';
                                Decimal fieldQtyVal= (Decimal) PAFI.get(fieldName);
                                if(fieldQtyVal!=null ){
                                    columnQty+= Integer.valueOf(fieldQtyVal);
                                }
                                qtyFieldCounter++;
                            }
                            
                            itemLine.qtyTargets.add(columnQty);
                            subtotal_columnQty[loopCounter-1]+=columnQty;
                            subtotal_Quarter[loopCounter-1] = subtotal_Quarter[loopCounter-1]+(columnQty*itemLine.pocketPrice);
                        }
                        
                        Map_ProductCat_VariableItem.get(Integer.valueOf(PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c)).variable_itemlines.add(itemLine);
                        Map_ProductCat_VariableItem.get(Integer.valueOf(PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c)).var_itemlines.add(PAFI);
                        
                        subtotal_totalQty+=itemLine.totalQty;
                        subtotal_FY=subtotal_FY+(itemLine.totalQty*itemLine.pocketPrice);
                        //subtotal_cashPrize+=itemLine.totalCashPrize;
                        
                        system.debug('1VaiableItems exist end');
                    }else{
                        system.debug('11VaiableItems new start');
                        productCat_VariableItem_Wrapper vi_wrapper = new productCat_VariableItem_Wrapper();
                        vi_wrapper.productCat = PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Chinese_Name__c;
                        variableItem_forDisplay itemLine = new variableItem_forDisplay();
                        itemLine.isLastRow = false;
                        itemLine.itemLineId = PAFI.Id;
                        itemLine.productCat= PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Chinese_Name__c;
                        //itemLine.itemName =PAFI.ASI_CRM_Contracted_Item__r.name;
                        itemLine.itemName =PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Item_Group_Chinese_Name__c != null && PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Item_Group_Chinese_Name__c != '' ? PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Item_Group_Chinese_Name__c : PAFI.ASI_CRM_Contracted_Item__r.name;
                        itemLine.pocketPrice = PocketPriceMap.get(PAFI.ASI_CRM_Contracted_Item__c) != null && PocketPriceMap.get(PAFI.ASI_CRM_Contracted_Item__c).ASI_CRM_Price__c != null? PocketPriceMap.get(PAFI.ASI_CRM_Contracted_Item__c).ASI_CRM_Price__c : DefaultValue;
                        //itemLine.keyLimitedSKU = Key_Limited_SKU_Label.get(PAFI.ASI_CRM_Key_Limited_SKU__c);
						itemLine.keyLimitedSKU =  Key_Limited_SKUMap.get(PAFI.ASI_CRM_Contracted_Item__c) != null && Key_Limited_SKUMap.get(PAFI.ASI_CRM_Contracted_Item__c).ASI_CRM_Key_Limited_SKU__c != null? mapKeyLimitedSKU.get(Key_Limited_SKUMap.get(PAFI.ASI_CRM_Contracted_Item__c).ASI_CRM_Key_Limited_SKU__c) : DefaultValueStr;                                                
                        
                        itemLine.noOfMonthPeriod =noOfMonthPeriod;                        
                        itemLine.totalQty =Integer.valueOf(PAFI.ASI_HK_CRM_Target_Volume_Qty__c);                    
                        
                        itemLine.productCatSeq = Integer.valueOf(PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c);
                        itemLine.isFirstItem = true;
                        /*if(PAFI.ASI_CRM_Cash_Per_Bottle_w_VAT__c!=null ){
                            itemLine.totalCashPrize = itemLine.totalQty* PAFI.ASI_CRM_Cash_Per_Bottle_w_VAT__c;
                        }else{
                            itemLine.totalCashPrize=0;
                        }*/
                        
                        /* 20200708 - KL@Introv Start*/
                        //if(PAFI.ASI_CRM_Cash_or_FOC__c == 'Cash')
                        if((PAFI.ASI_CRM_Cash_or_FOC__c == 'Cash') || (PAFI.ASI_CRM_Cash_or_FOC__c == 'Cash & FOC'))
                            itemLine.reward = 'NT$'+Integer.valueOf(PAFI.ASI_CRM_Cash_Per_Bottle_w_VAT__c).format();
                        else
                            itemLine.reward = '買'+Integer.valueOf(PAFI.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c).format()+'瓶送'+Integer.valueOf(PAFI.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c).format()+'瓶';
                        
                        //Added by Victor for PAF合約不列印瓶費獎勵
                        //if(PAFI.ASI_CRM_FOC_with_Orders__c) itemLine.reward = '';                        
                        if((PAFI.ASI_CRM_FOC_with_Orders__c) && (PAFI.ASI_CRM_Cash_or_FOC__c != 'Cash & FOC')) itemLine.reward = '';
                                            
                        /* 20200708 - KL@Introv End*/
                        
                        /***
                        Integer qtyFieldCounter =1;
                        for(Integer i=0;noOfColumns>0 && i<noOfColumns; i++){
                            Integer columnQty = 0;
                            for(Integer j=0;interval>0 && j<interval && qtyFieldCounter<=totalMonths && qtyFieldCounter<=12; j++){
                                String fieldName = 'ASI_CRM_Target_Volume_Qty_P'+qtyFieldCounter+'__c';
                                Decimal fieldQtyVal= (Decimal) PAFI.get(fieldName);
                                if(fieldQtyVal!=null ){
                                    columnQty+= Integer.valueOf(fieldQtyVal);
                                }
                                
                                qtyFieldCounter++;
                            }
                            itemLine.qtyTargets.add(columnQty);
                            subtotal_columnQty[i]+=columnQty;
                        }
                        **/
                        
                        Integer qtyFieldCounter =1;
                        Integer loopCounter =0;
                        for(Integer periodId :map_QuarterPeriod.keySet()){
                            loopCounter++; 
                            Integer columnQty = 0;
                            for(Integer j = 0; j<map_QuarterPeriod.get(periodId).noOfMonths && qtyFieldCounter<=12; j++){
                                String fieldName = 'ASI_CRM_Target_Volume_Qty_P'+qtyFieldCounter+'__c';
                                Decimal fieldQtyVal= (Decimal) PAFI.get(fieldName);
                                if(fieldQtyVal!=null ){
                                    columnQty+= Integer.valueOf(fieldQtyVal);
                                }
                                qtyFieldCounter++;
                            }
                            itemLine.qtyTargets.add(columnQty);
                            subtotal_columnQty[loopCounter-1]+=columnQty;
                            subtotal_Quarter[loopCounter-1] = subtotal_Quarter[loopCounter-1]+(columnQty*itemLine.pocketPrice);
                        }
                        vi_wrapper.variable_itemlines = new List<variableItem_forDisplay>{itemLine};
                        vi_wrapper.var_itemlines=new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>{PAFI};
                        Map_ProductCat_VariableItem.put(Integer.valueOf(PAFI.ASI_CRM_Contracted_Item__r.ASI_CRM_Product_Category_Sequence__c), vi_wrapper);
                        
                        subtotal_totalQty+=itemLine.totalQty;
                        //subtotal_cashPrize+=itemLine.totalCashPrize;
                        subtotal_FY=subtotal_FY+(itemLine.totalQty*itemLine.pocketPrice);
                        system.debug('1VaiableItems new end');
                    }
                }
                
                //Fixed & Conditional Investment Item Lines Handling:
                else
                {
                    if (PAFI.ASI_HK_CRM_Mechanic__c == null)
                    {
                        continue;
                    }
                    
                    String mechanicClass = PAFI.ASI_HK_CRM_Mechanic__r.ASI_CRM_Mechanic_Class__c;
                    if (mechanicClass != null && mechanicClass != '')
                    {
                        String InvRecdIndex = '';
                        //20200724:AM@Introv - ignore type for sorting
                        /*if (PAFI.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment'))
                        {
                            InvRecdIndex += '1';
                        }
                        else if(PAFI.RecordTypeId == Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'))
                        {
                            InvRecdIndex += '2';
                        }*/
                        
                        //InvRecdIndex += mechanicClass
                        //                + '|' + PAFI.ASI_HK_CRM_Mechanic__r.Id
                        //                + '|' + PAFI.ASI_CRM_Mechanic_Detail__c
                        //                + '|' + PAFI.ASI_CRM_Cash_or_FOC__c
                        //                + '|' + PAFI.ASI_CRM_Reward_Method__c;
                        InvRecdIndex += mechanicClass
                            			+ '|' + PAFI.ASI_CRM_Mechanic_Detail__c
                                        + '|' + PAFI.ASI_CRM_Cash_or_FOC__c
                                        + '|' + PAFI.ASI_CRM_Reward_Method__c
                            			+ '|' + PAFI.ASI_HK_CRM_Mechanic__r.Id;

                        if (Map_Class_InvestmentLine.get(mechanicClass) == null)
                        {
                            investment_wrapper investment = new investment_wrapper();
                            investment.categoryName = Mechanic_Name_Label.get(PAFI.ASI_HK_CRM_Mechanic__r.ASI_CRM_Mechanic_Class__c);
                            Map_Class_InvestmentLine.put(mechanicClass, investment);
                        }

                        ASI_HK_CRM_Pre_Approval_Form_Item__c item = Map_Class_InvestmentLine.get(mechanicClass).Map_Seq_InvestmentItemLine.get(InvRecdIndex);
                        
                        if (PAFI.ASI_CRM_Cash_or_FOC__c == 'Cash')
                        {
                            if (item != null)
                            {
                                item.ASI_CRM_Cash_Amounts_w_VAT__c += PAFI.ASI_CRM_Cash_Amounts_w_VAT__c;
                                Map_Class_InvestmentLine.get(mechanicClass).Map_Seq_InvestmentItemLine.put(InvRecdIndex, item);
                            }
                            else
                            {
                                Map_Class_InvestmentLine.get(mechanicClass).Map_Seq_InvestmentItemLine.put(InvRecdIndex, PAFI);
                            }
                        }
                        else
                        {
                            if (item != null)
                            {
                                /*item.ASI_CRM_Cash_or_FOC__c += '<hr style="position: relative; border: 1px solid #6699CC; left: -1%; width: 101%;"><div>' + PAFI.ASI_CRM_Expenses_Product__r.ASI_CRM_Item_Group_Chinese_Name__c
                                                                + ' ' + Integer.valueOf(PAFI.ASI_CRM_FOC_Volume__c).format() + '瓶</div>';*/
                                
                                //20200723 - KL@Introv -Start
                                //20200728:AM@Introv - fix error of argument null
                                //if ( Integer.valueOf(PAFI.ASI_CRM_FOC_Volume__c) ==0){
                                if (Integer.valueOf(PAFI.ASI_CRM_FOC_Volume__c)==0 || PAFI.ASI_CRM_FOC_Volume__c==NULL){
                                    item.ASI_CRM_Cash_or_FOC__c += '<hr style="position: relative; border: 1px solid #6699CC; left: -1%; width: 101%;"><div></div>';                                    
                                }
                                else
                                {
                                    item.ASI_CRM_Cash_or_FOC__c += '<hr style="position: relative; border: 1px solid #6699CC; left: -1%; width: 101%;"><div>' + PAFI.ASI_CRM_Expenses_Product__r.ASI_CRM_Item_Group_Chinese_Name__c
                                                                + ' ' + Integer.valueOf(PAFI.ASI_CRM_FOC_Volume__c).format() + '瓶</div>';
                                }                                
                                //20200723 - KL@Introv -End
                                Map_Class_InvestmentLine.get(mechanicClass).Map_Seq_InvestmentItemLine.put(InvRecdIndex, item);
                            }
                            else
                            {
                                /*PAFI.ASI_CRM_Cash_or_FOC__c = '<div>' + PAFI.ASI_CRM_Expenses_Product__r.ASI_CRM_Item_Group_Chinese_Name__c
                                                            + ' ' + Integer.valueOf(PAFI.ASI_CRM_FOC_Volume__c).format() + '瓶</div>';*/
                                //20200723 - KL@Introv -Start
                                //20200728:AM@Introv - fix error of argument null
                                //if ( Integer.valueOf(PAFI.ASI_CRM_FOC_Volume__c) ==0){
                                if (Integer.valueOf(PAFI.ASI_CRM_FOC_Volume__c)==0 || PAFI.ASI_CRM_FOC_Volume__c==NULL){
                                    PAFI.ASI_CRM_Cash_or_FOC__c = '<div></div>';                                    
                                }
                                else
                                {
                                    PAFI.ASI_CRM_Cash_or_FOC__c = '<div>' + PAFI.ASI_CRM_Expenses_Product__r.ASI_CRM_Item_Group_Chinese_Name__c
                                                            + ' ' + Integer.valueOf(PAFI.ASI_CRM_FOC_Volume__c).format() + '瓶</div>';
                                }
                                //20200723 - KL@Introv -End
                                Map_Class_InvestmentLine.get(mechanicClass).Map_Seq_InvestmentItemLine.put(InvRecdIndex, PAFI);
                            }
                        }
                    }
                    
                }
            }

            if (Map_Class_InvestmentLine.size() > 0)
            {
                hasInvestLine = true;

                for (String key : Map_Class_InvestmentLine.keySet())
                {
                    investment_wrapper wrapper = Map_Class_InvestmentLine.get(key);
                    
                    for (String key2 : wrapper.Map_Seq_InvestmentItemLine.keySet())
                    {
                        ASI_HK_CRM_Pre_Approval_Form_Item__c item = wrapper.Map_Seq_InvestmentItemLine.get(key2);

                        if (item.ASI_CRM_Cash_or_FOC__c != null && item.ASI_CRM_Cash_or_FOC__c == 'Cash')
                        {
                            item.ASI_CRM_Cash_or_FOC__c = 'NT$' + Integer.valueOf(item.ASI_CRM_Cash_Amounts_w_VAT__c).format();
                            //20200723 - KL@Introv -Start
                            if (Integer.valueOf(item.ASI_CRM_Cash_Amounts_w_VAT__c) == 0) item.ASI_CRM_Cash_or_FOC__c = '';                        
                            //20200723 - KL@Introv -End
                        }
                    }
                }
            }
            
            system.debug('1111' + Map_Class_InvestmentLine);
            
             //Create the subtotal record as the last line:
            if(Map_ProductCat_VariableItem.size()>0){
                List<Integer> mapKeys =new List<Integer>();
                mapKeys.addAll(Map_ProductCat_VariableItem.keySet());
                Integer LastIndex =mapKeys[mapKeys.size()-1];
                //20200728:AM@Introv - fix missing total
                //if(currentPAF.ASI_CRM_Channel__r.ASI_CRM_PDF_Type__c == 'ON Trade' || currentPAF.ASI_CRM_Channel__r.ASI_CRM_PDF_Type__c == 'ON Trade 2'){
                if (G_IsType_OnTrade || G_IsType_OnTrade2) {
                    productCat_VariableItem_Wrapper vi_wrapper = new productCat_VariableItem_Wrapper();
                    
                    vi_wrapper.productCat = '總計';
                    
                    variableItem_forDisplay itemLine = new variableItem_forDisplay();
                    itemLine.productCat= '總計';
                    itemLine.itemName =' ';
                    //itemLine.pocketPrice =' ';  //new
                    itemLine.keyLimitedSKU =' ';  //new
                    itemLine.reward =' ';  
                    itemLine.noOfMonthPeriod = noOfMonthPeriod;
                    itemLine.totalQty = subtotal_totalQty;
                    itemLine.productCatSeq = LastIndex+1;
                    itemLine.isFirstItem = true;
                    itemLine.isLastRow = True;

                    //itemLine.totalCashPrize=subtotal_cashPrize;
                    itemLine.qtyTargets=subtotal_columnQty;

                    vi_wrapper.variable_itemlines = new List<variableItem_forDisplay>{itemLine};
                        Map_ProductCat_VariableItem.put(itemLine.productCatSeq, vi_wrapper);
                }else if(currentPAF.ASI_CRM_Channel__r.ASI_CRM_PDF_Type__c == 'LS'){
                   
                    productCat_VariableItem_Wrapper vi_wrapperLS = new productCat_VariableItem_Wrapper();
                    vi_wrapperLS.productCat = '進貨金額 總計(NT$)';
                    
                    variableItem_forDisplay itemLineLS = new variableItem_forDisplay();
                    itemLineLS.productCat= '進貨金額 總計(NT$)';
                    
                   itemLineLS.itemName =' ';
                    //itemLine.pocketPrice =' ';  //new
                    itemLineLS.keyLimitedSKU =' ';  //new
                    itemLineLS.reward =' ';  
                    itemLineLS.noOfMonthPeriod =noOfMonthPeriod;
                    itemLineLS.FYSum = subtotal_FY;
                    //itemLine.productCatSeq = LastIndex+1;
                    //itemLine.totalCashPrize=subtotal_cashPrize;
                    itemLineLS.QuarterSum = subtotal_Quarter;
                    itemLineLS.productCatSeq = LastIndex+2;
                    itemLineLS.isFirstItem = true;
                    itemLineLS.isLastRow = True;

                    vi_wrapperLS.variable_itemlines = new List<variableItem_forDisplay>{itemLineLS};
                        Map_ProductCat_VariableItem.put(itemLineLS.productCatSeq, vi_wrapperLS);
                }
            }
            
           
            system.debug(Map_ProductCat_VariableItem);
            
            
            //Handle PAF Terms:
            Map_Section_Terms = new Map<Integer, terms_wrapper>();
            appliedFixTerms = [SELECT Id, Name, ASI_CRM_Section__c,ASI_CRM_Section_Title__c,ASI_CRM_Terms_Details__c,ASI_CRM_Type__c, ASI_CRM_Channel__c
                               FROM ASI_CRM_Terms__c 
                               WHERE ASI_CRM_Inactive__c =false 
                               AND ASI_TW_Apply_To__c = 'PAF'
                               AND ASI_CRM_Type__c ='Fixed'
                               AND ASI_CRM_Channel__c includes (:currentPAF.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c)
                               AND RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_Terms__cASI_CRM_TW_Terms') 
                               ORDER BY ASI_CRM_Section__c ASC, ASI_CRM_Terms_Details_Sequence__c ASC
                              ];
            //Channel and Channel'PDF

            appliedVarTerms = [SELECT Id, Name, ASI_CRM_Pre_Approval_Form__c, ASI_CRM_Terms__c, ASI_CRM_Terms__r.ASI_CRM_Section__c,ASI_CRM_Terms__r.ASI_CRM_Section_Title__c, 
                               ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c, ASI_CRM_Terms__r.ASI_CRM_Type__c, ASI_CRM_Terms__r.ASI_CRM_Channel__c
                               FROM ASI_CRM_Terms_Application__c 
                               WHERE ASI_CRM_Pre_Approval_Form__c=:PAFId 
                               AND ASI_CRM_Terms__r.ASI_CRM_Inactive__c =false 
                               AND ASI_CRM_Terms__r.ASI_TW_Apply_To__c = 'PAF'
                               AND ASI_CRM_Terms__r.ASI_CRM_Type__c ='Variable'
                               AND ASI_CRM_Terms__r.ASI_CRM_Channel__c includes (:currentPAF.ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c)
                               //recordtype
                               ORDER BY ASI_CRM_Terms__r.ASI_CRM_Section__c ASC, ASI_CRM_Variable_Terms_Sequence__c ASC
                              ];
                            
            for( ASI_CRM_Terms__c ft: appliedFixTerms){
            
                if(Map_Section_Terms.get(Integer.valueOf(ft.ASI_CRM_Section__c))==null){
                    terms_wrapper term = new terms_wrapper();
                    term.sectionId = Integer.valueOf(ft.ASI_CRM_Section__c);
                    term.setionTitle = ft.ASI_CRM_Section_Title__c;
                    if(ft.ASI_CRM_Terms_Details__c == null || ft.ASI_CRM_Terms_Details__c ==''){
                        term.noDetails =true;
                    }else{
                        term.subTerms.add(ft.ASI_CRM_Terms_Details__c);
                    }
                    
                    Map_Section_Terms.put (term.sectionId,term);
                }else{
                    if(ft.ASI_CRM_Terms_Details__c == null || ft.ASI_CRM_Terms_Details__c ==''){
                        Map_Section_Terms.get(Integer.valueOf(ft.ASI_CRM_Section__c)).noDetails =true;
                    }else{
                        Map_Section_Terms.get(Integer.valueOf(ft.ASI_CRM_Section__c)).subTerms.add(ft.ASI_CRM_Terms_Details__c);
                    }
                }
                
            }
            
            for( ASI_CRM_Terms_Application__c vt: appliedVarTerms){
            
                if(Map_Section_Terms.get(Integer.valueOf(vt.ASI_CRM_Terms__r.ASI_CRM_Section__c))==null){
                    terms_wrapper term = new terms_wrapper();
                    term.sectionId = Integer.valueOf(vt.ASI_CRM_Terms__r.ASI_CRM_Section__c);
                    term.setionTitle = vt.ASI_CRM_Terms__r.ASI_CRM_Section_Title__c;
                    if(vt.ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c == null || vt.ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c ==''){
                        term.noDetails =true;
                    }else{
                        term.subTerms.add(vt.ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c);
                    }
                    
                    Map_Section_Terms.put (term.sectionId,term);
                }else{
                    if(vt.ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c == null || vt.ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c ==''){
                        Map_Section_Terms.get(Integer.valueOf(vt.ASI_CRM_Terms__r.ASI_CRM_Section__c)).noDetails =true;
                    }else{
                        Map_Section_Terms.get(Integer.valueOf(vt.ASI_CRM_Terms__r.ASI_CRM_Section__c)).subTerms.add(vt.ASI_CRM_Terms__r.ASI_CRM_Terms_Details__c);
                    }
                }
            }
            system.debug(Map_Section_Terms);
        }
        
        childOutlets = new List< ASI_CRM_HK_Pre_Approval_Form_Customer__c>();
        childOutlets =[SELECT Id, name, ASI_CRM_HK_Customer__c, ASI_CRM_HK_Customer__r.ASI_KOR_Legal_Name__c, ASI_CRM_HK_Pre_Approval_Form__c FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Pre_Approval_Form__c =:currentPAF.Id AND ASI_CRM_HK_Customer__c!=:currentPAF.ASI_HK_CRM_PAF_Customer__c ];
        if(childOutlets!=null && childOutlets.size()>0){
            childOutletNames ='：';
            Integer counter =1;
            for(ASI_CRM_HK_Pre_Approval_Form_Customer__c child :childOutlets){
                childOutletNames+='（'+counter+'）'+child.ASI_CRM_HK_Customer__r.ASI_KOR_Legal_Name__c;
                if(counter<childOutlets.size()){
                    childOutletNames+='、\n';
                }
                counter++;
            }
            
        }
        
    }
}