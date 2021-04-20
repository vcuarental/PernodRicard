/* Filename  :  ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.cls
* Author     :  Laputa
* Purpose    :  Controller for Payment PDF 
* Study From :  ASI_CRM_CN_HeavyPaymentRequestForm
* Testing    :  
* History
* -----------------------------------------------------------------------------
* 2017-10-06   Laputa      Created
* 2019-09-25   Laputa      Update INC0102304
* 2020-04-01   Laputa      Update BluelinkSys

*/ 
public without sharing class ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl{
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = initPage();} return dummyVar; } set; }
    public id HeaderId {set;get;}
    public string strPDF {set;get;}
    public ASI_TH_CRM_PaymentRequest__c thisPR {set;get;}
    public ASI_TH_CRM_Contract__c  ContractSelected {set;get;}{ContractSelected = new ASI_TH_CRM_Contract__c(); }
    public Decimal ContractBCRate {set;get;}{ContractBCRate=0;}


    public Decimal MartellBCRate {set;get;}{MartellBCRate=0;}


    public date CutOffDay {set;get;} //Pending Custom Setting follow for Sub Brand Volume 
    //AD or Above Identity checking
    public boolean AdorAbove {set;get;}
    public string UserId {set;get;}
    public list<ASI_CRM_CN_PH_Payee_Line_Item__c> PayeeList {set;get;}{PayeeList=new list<ASI_CRM_CN_PH_Payee_Line_Item__c>(); }
    public List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary> PaymentSummaryList {set;get;}{PaymentSummaryList = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary>();}
    public decimal Other_VOL_CR12 {set;get;} {Other_VOL_CR12 =0;}
    public decimal BRSF_CTD_CR12=0;// Total BRSF Volume all period 
    public decimal PaymentSpeed {set;get;}
    public decimal PaymentSpeedexcFixCost {set;get;}
    public date strStart;
    Public Decimal TotalPaymentAmount=0;
    //BA Comment
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}

    public Map<String, String> sbGroup_map {set;get;} {sbGroup_map = ASI_CRM_CN_HeavyContractUtilitiesClass.SUB_BRAND_GRADE_GROUPING_MAP;}
    public Integer BRSFmonthsBetween   {set;get;} {BRSFmonthsBetween=1;}
    //BRSF
    public interimData BRSFItemMap {set;get;} {BRSFItemMap= new interimData();}
    //PSF
    public map<String, interimData> PSF_Item_Map {set;get;} {PSF_Item_Map= new map<String, interimData>();}

    public Map<String,VolumeObject> VolumeMap {set;get;} {VolumeMap= new Map<String,VolumeObject>(); }

    public Map<String,VolumeObject> VolumeByCategoryMap {set;get;} {VolumeByCategoryMap= new Map<String,VolumeObject>(); }
    public Map<String, String> sortCategoryMap{GET;SET;} {sortCategoryMap= new Map<String, String>();}

    public ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl(){}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0Esitimate2nd  {set;get;} { NewContractV0Esitimate2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactV0Contract2nd  {set;get;} { 
        NewContactV0Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContractV0Esitimate  {set;get;} { NewContractV0Esitimate = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ActualPerformance2nd  {set;get;} {
         ActualPerformance2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
    }
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ActualPerformance  {set;get;} { ActualPerformance = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}

    public map<string, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data> v0_ROI_newMap  {set;get;} {
        v0_ROI_newMap=new map<string, ASI_CRM_CN_HeavyContractUtilitiesClass.subbrand_data>();
    }
    public Decimal TotalPaymentVariableAmount {set;get;} {
        TotalPaymentVariableAmount=0;
    }
    public Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine> SubBrandContractMap  {set;get;}  { 
        SubBrandContractMap = new Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine> ();
    }

    public Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> tradExpenseBreakMap{GET;SET;}{
        tradExpenseBreakMap = new Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>();
    }

    public Boolean DisplayBRSFPart {set;get;} {DisplayBRSFPart=false;}
    public Boolean DisplayPSFPart {set;get;} {DisplayPSFPart=false;}

    // author: Bluelinksys_PC Date : 2020-03-30
    public Boolean ExistHistoricalData {set;get;} {ExistHistoricalData=true;}
    public String MainTableHeader1 {set;get;}
    public String MainTableHeader2 {set;get;}
    public String MarginafterTableHeader{GET;SET;}
    public String BelongGroup{GET;SET;} {BelongGroup = UserOrGroupInit();}

    public Boolean Ishave999 {get;set;} {Ishave999 = false;}

    /*
        First key is Sub-brand Id, second key is either historical, estimate or contract.
        Value is the tradeExpenseBreakdown2nd object
    */
   public Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown>> investmentBySubBrandByContractBySubBrand {set;get;} {investmentBySubBrandByContractBySubBrand= new Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown>>{};}
    public Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> investmentBySubBrandByContractBySubBrand2nd {set;get;} {investmentBySubBrandByContractBySubBrand2nd= new Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>{};}

    public Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> sortBySubBrandByContractBySubBrand {set;get;} {sortBySubBrandByContractBySubBrand= new Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>{};}

    public Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> investmentBySubBrandByContractByLastVolume {set;get;} {investmentBySubBrandByContractByLastVolume= new Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>{};}

    public Map<String, Map<String, Decimal>> investmentByCategeryByContract {set;get;} {investmentByCategeryByContract= new Map<String, Map<String, Decimal>>{};}
    public String selectedSubBrandDescription {set;get;} {selectedSubBrandDescription = ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();}
    public Map<String, String> byCategoryMap {set;get;}
    public Map<Decimal,String> subBrandNameMap{GET;SET;}{subBrandNameMap = new Map<Decimal,String>{};}
    public Map<String, Decimal> NewContractV0EsitimateMap{GET;SET;}{NewContractV0EsitimateMap = new Map<String, Decimal>();}
    public Map<String, Decimal> NewContactV0ContractMap{GET;SET;}{NewContactV0ContractMap = new Map<String, Decimal>();}
    public Map<String, Decimal> ActualPerformanceMap{GET;SET;}{ActualPerformanceMap = new Map<String, Decimal>();}

    public ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl(ApexPages.StandardController controller) {

    }

    public boolean initPage() {
        if (String.isNotBlank(HeaderId)) {
            thisPR = [SELECT Id, ASI_TH_CRM_Contract__c ,ASI_CRM_CN_Payment_Raised_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_Martell_BC_Rate__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Eng_Name__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Total_BRSF_Amount__c,
                ASI_CRM_CN_Total_PSF_Amount__c, ASI_CRM_CN_Total_Other_Amount__c , ASI_CRM_CN_PO_Remain_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_PO_Version__c,
                ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.Name,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,  ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Sub_Channel__r.Name, ASI_CRM_CN_Payment_Type__c, ASI_CRM_CN_Overpayment_Reason__c, ASI_CRM_CN_Other_Reason__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_PO_End_Date__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PSF_End__c , ASI_CRM_CN_PSF_Start__c ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
                Owner.Name, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Contract_Cost_Total__c ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c, ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.Name, ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Currency__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_National_Group_Contract__c,
                ASI_CRM_CN_BRSF_End_Date__c , ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_BRSF_Start_Date__c, ASI_CRM_CN_Bottle_Collection_Rate__c,
                ASI_CRM_CN_PO_No__c, ASI_CRM_CN_Region__c, ASI_CRM_CN_OutletWS__r.Name, name,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Group_Contract__r.Name,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Group_Contract__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_No_of_Months__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
                ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
                ASI_CRM_CN_Total_Payment__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c,
                ASI_CRM_New_FY_Payment__c, ASI_TH_CRM_Contract__r.ASI_CRM_PO_Province__r.Name, ASI_TH_CRM_Contract__r.ASI_CRM_PO_Channel__r.Name ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__c ,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__r.Name,ASI_TH_CRM_Contract__r.ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c ,
                ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_NewChannel__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
                ASI_TH_CRM_Contract__r.ASI_CRM_Investment_Type__c,ASI_TH_CRM_Contract__r.Name,OwnerId
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE id = :HeaderId];
            if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                return init2nd();
            } else {
                return init();
            }
        }
        return true;
    }

    public boolean init2nd(){
        System.debug('BelongGroup'+BelongGroup);
        MainTableHeader1='<td colspan="6" bgcolor="#99CCFF" style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;border-bottom:1px solid black;" align="center" ><strong>P&L REVIEW (in RMB) 利润分析表 （元）</strong></td>';
        MainTableHeader2='<td colspan="6" bgcolor="#99CCFF" style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;border-bottom:1px solid black;" align="center" ><strong>P&L REVIEW (in RMB) 利润分析表 （元）</strong></td>';
        MarginafterTableHeader='<td style="border-bottom: 1px solid black;border-left: 1px solid black; border-right: 1px solid black;"><strong>Cont. Margin after A &P 销售净利</strong></td>';
        /*
            Author:Bowen
            Date:2019-10-16
            update:InitVariable()的方法原来是在if判断外面的，但由于InitVariable()方法中有thisPR的使用，所以应当先判断thisPR是否为空，方能进入这个方法，所以将其置于if判断后
         */
        // InitVariable();
        if (thisPR != null){
            InitVariable2nd();
            ContractSelected = ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(thisPR.ASI_TH_CRM_Contract__c);

            try{
                PayeeList = [SELECT id, ASI_CRM_CN_Type__c, ASI_CRM_CN_Amount__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T2_lookup__c,ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Payee_Name_T1__r.Name,ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name,ASI_CRM_CN_Cash_Amount__c
                FROM ASI_CRM_CN_PH_Payee_Line_Item__c WHERE ASI_CRM_CN_Payment_Request__c = :thisPR.id];
            }catch(exception e){
                PayeeList = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            }


            PaymentSummaryList = ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable2nd(thisPR,ContractSelected);

            List<integer> lstRemove = new List<integer>();
            Integer indexNum=0;
            integer c = 0;
            if (PaymentSummaryList != null && PaymentSummaryList.size() > 0){
                for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary displayLine:PaymentSummaryList){
                    if(displayLine.POEstimatedAmount==0 && displayLine.PaymentRequestAmount==0){
                        lstRemove.add(indexNum);
                    }
                    indexNum++;
                }

                for(integer n : lstRemove){
                    if(n!=0){
                        if(c>0)
                            n=n-c;
                        PaymentSummaryList.remove(n);
                        c++;
                    }else{
                        PaymentSummaryList.remove(0);
                        c++;
                    }
                }
            }




            //Will calculate Total Paid Amount and Variable Amount
            TotalPaymentAmount = RetrieveTotalPaidAmount();


            Decimal V0FixCostAmount=CalculateV0FixCostAmount();

            Decimal V0ContractAmount =  CalculateV0ContractDetailCost2nd();
            if (V0ContractAmount != null && V0ContractAmount !=0 && TotalPaymentVariableAmount != null && TotalPaymentVariableAmount != 0){
                PaymentSpeedexcFixCost = (TotalPaymentVariableAmount / V0ContractAmount) * 100; // No inculding Fix Cost
            }



            V0ContractAmount=V0ContractAmount+V0FixCostAmount;
            if (V0ContractAmount != null && V0ContractAmount !=0 && TotalPaymentAmount != null && TotalPaymentAmount != 0){
                PaymentSpeed = (TotalPaymentAmount / V0ContractAmount) * 100;
            }


            LoopingSubBrandVolumeCMGSList();

            LoopingPaymentRequestLine();



            lstApprovalComment = [SELECT id, ASI_CRM_BA_comments__c FROM ASI_CRM_Approval_Comment__c
            WHERE ASI_CRM_Payment_Request__c =:thisPR.id];
            if(lstApprovalComment==null || lstApprovalComment.size()==0){
                lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
            }else{
                lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
            }
        }

        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd historical = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
        String V0ContractId=GenerateV0ContractId();

        List<ASI_Attachment__c> attachments = [SELECT Id,
                                                      ASI_CRM_Historical_Financial_Data__c,
                                                      ASI_CRM_Historical_Financial_Data2__c,
                                                      ASI_CRM_Historical_Financial_Data3__c,
                                                      ASI_CRM_Historical_Financial_Data4__c,
                                                      ASI_CRM_Contract__c,ASI_CRM_Type__c 
                                               FROM ASI_Attachment__c 
                                               WHERE ASI_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__c];

        if(attachments.size()<=0 && attachments.isEmpty()) {
            if (ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null) {
               attachments = [SELECT Id,
                                     ASI_CRM_Historical_Financial_Data__c,
                                     ASI_CRM_Historical_Financial_Data2__c,
                                     ASI_CRM_Historical_Financial_Data3__c,
                                     ASI_CRM_Historical_Financial_Data4__c,
                                     ASI_CRM_Contract__c,ASI_CRM_Type__c 
                              FROM ASI_Attachment__c 
                              WHERE ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c];
            }
        }

        //List<ASI_Attachment__c> attachments = [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :V0ContractId];
        /*
            Author:Bowen
            Date:2019-10-16
            update:因为这次修改的原因就是在json转译为list的时候出现空指针异常，所以为了跳出报错，在每个转译的时候，都加上trycatch，保证代码的顺利执行
         */
        if(attachments.size() > 0 && !attachments.isEmpty()) {
            for (ASI_Attachment__c att : attachments) { 
                if(att.ASI_CRM_Type__c=='Historical Data'){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');
                    try{
                        System.debug(LoggingLevel.INFO, '*** JsonString: ' + JsonString);
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(HistoricalContractList.size()>0){
                            historical= HistoricalContractList[0];
                        }
                        System.debug(LoggingLevel.INFO, '*** historical: ' + historical);
                    }catch(Exception e){

                    }
                }
                else if(att.ASI_CRM_Type__c=='Last Payment Data'){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&lt;','<'):'');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    try
                    {
                        System.debug(LoggingLevel.INFO, '*** JsonString: ' + JsonString);
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(ContractList.size()>0){
                            ActualPerformance2nd = ContractList[0];
                        }
                        System.debug(LoggingLevel.INFO, '*** ActualPerformance2nd: ' + ActualPerformance2nd);
                    }catch(Exception e){

                    }
                } else if(att.ASI_CRM_Type__c=='Contract Data'){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&lt;','<'):'');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    try
                    {
                        System.debug(LoggingLevel.INFO, '*** JsonString: ' + JsonString);
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                        if(ContractList.size()>0){
                            NewContractV0Esitimate2nd = DataRounding2nd(ContractList[0]);
                            NewContactV0Contract2nd= DataRounding2nd(ContractList[1]);
                        }
                        System.debug(LoggingLevel.INFO, '*** NewContractV0Esitimate: ' + NewContractV0Esitimate2nd);
                        System.debug(LoggingLevel.INFO, '*** NewContactV0Contract: ' + NewContactV0Contract2nd);
                    }catch(Exception e){

                    }
                }
            }
        }

        if (ContractSelected.ASI_CRM_CN_V0_0_PO_version__r != null && !ContractSelected.ASI_CRM_CN_IS_Manual_Refresh__c) {
            ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData2nd(ContractSelected.ASI_CRM_CN_V0_0_PO_version__r);
        }
        
        /*for (ASI_Attachment__c att : [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c]) {
            if(att.ASI_CRM_Type__c=='Contract Data'){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<');
                JsonString = JsonString.replaceAll('&quot;','"');
                List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                if(ContractList.size()>0){
                    NewContractV0Esitimate = ContractList[0];
                    NewContactV0Contract = ContractList[1];
                }
            }
        }*/
        


        // Because FI only have key that has value, we need to add missing item
        // In Profit Shuttle all Grade grouping must be shown
        /*
            Author:Bowen
            Date:2019-10-16
            update:为了防止报空指针异常，对map的空进行判断下，保证先执行if前面一段，如果为空就跳出判断，这样就不执行&&后面的逻辑
         */
        for(String SBGName: sbGroup_map.keySet()){

            if(!NewContractV0Esitimate2nd.SubBrandGradeMap.isEmpty() && !NewContractV0Esitimate2nd.SubBrandGradeMap.containskey(SBGName)){
                NewContractV0Esitimate2nd.SubBrandGradeMap.put(SBGName,0.0);
            }
            if(!NewContactV0Contract2nd.SubBrandGradeMap.isEmpty() && !NewContactV0Contract2nd.SubBrandGradeMap.containskey(SBGName)){
                NewContactV0Contract2nd.SubBrandGradeMap.put(SBGName,0.0);
            }
            if(!ActualPerformance2nd.SubBrandGradeMap.isEmpty() && !ActualPerformance2nd.SubBrandGradeMap.containskey(SBGName)){
                ActualPerformance2nd.SubBrandGradeMap.put(SBGName,0.0);
            }

            SubBrandContractMap = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>(ActualPerformance2nd.ContractLineMap);
            for(String ContractLineKey:ActualPerformance2nd.ContractLineMap.keySet()){
                System.debug('ContractLineKey'+ContractLineKey);
                if(SubBrandContractMap.containsKey(ContractLineKey)){
                    SubBrandContractMap.get(ContractLineKey).HistoricalBottles=ActualPerformance2nd.ContractLineMap.get(ContractLineKey).HistoricalBottles;
                    SubBrandContractMap.get(ContractLineKey).HistoricalFees = ActualPerformance2nd.ContractLineMap.get(ContractLineKey).HistoricalFees;
                    SubBrandContractMap.get(ContractLineKey).HistoricalTotalFees = ActualPerformance2nd.ContractLineMap.get(ContractLineKey).HistoricalTotalFees;
                }else{
                    SubBrandContractMap.put(ContractLineKey, ActualPerformance2nd.ContractLineMap.get(ContractLineKey));
                }
            }
        }

        byCategoryMap = new Map<String, String>();
        Map<String, String> allcategoryMap = new Map<String,String>();
        for(ASI_HK_CRM_Product_Category__c ProductCategory:[SELECT Id,Name,ASI_CRM_CN_Chinese_Name__c,ASI_HK_CRM_English_Name__c,ASI_HK_CRM_Sequence__c 
                                                            FROM ASI_HK_CRM_Product_Category__c 
                                                            WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Product_Category']){
            byCategoryMap.put(ProductCategory.name , ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c);
            allcategoryMap.put(ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c,ProductCategory.name);
        }

        Set<String> removeSBGNameSet = new Set<String>();
        

        for(String SBGName: byCategoryMap.keySet()){
            Boolean isHave = false;

            if(NewContractV0Esitimate2nd.CategoryMap==null || !NewContractV0Esitimate2nd.CategoryMap.containskey(SBGName)){
                NewContractV0Esitimate2nd.CategoryMap.put(SBGName,0.0);
                NewContractV0EsitimateMap.put(byCategoryMap.get(SBGName),0.0);
            }
            else {
                NewContractV0EsitimateMap.put(byCategoryMap.get(SBGName),NewContractV0Esitimate2nd.CategoryMap.get(SBGName));
                isHave=true;
            }

            if(NewContactV0Contract2nd.CategoryMap==null || !NewContactV0Contract2nd.CategoryMap.containskey(SBGName)){
                NewContactV0Contract2nd.CategoryMap.put(SBGName,0.0);
                NewContactV0ContractMap.put(byCategoryMap.get(SBGName),0.0);
            }
            else {
                NewContactV0ContractMap.put(byCategoryMap.get(SBGName),NewContactV0Contract2nd.CategoryMap.get(SBGName));
                isHave=true;
            }

            if(ActualPerformance2nd.CategoryMap==null || !ActualPerformance2nd.CategoryMap.containskey(SBGName)){
                ActualPerformance2nd.CategoryMap.put(SBGName,0.0);
                ActualPerformanceMap.put(byCategoryMap.get(SBGName),0.0);
            }
            else {
                ActualPerformanceMap.put(byCategoryMap.get(SBGName),ActualPerformance2nd.CategoryMap.get(SBGName));
                isHave=true;
            }

            if (!isHave) {
                removeSBGNameSet.add(SBGName);
                NewContractV0Esitimate2nd.CategoryMap.remove(SBGName);
                NewContactV0Contract2nd.CategoryMap.remove(SBGName);
                ActualPerformance2nd.CategoryMap.remove(SBGName);
                NewContractV0EsitimateMap.remove(SBGName);
                NewContactV0ContractMap.remove(SBGName);
                ActualPerformanceMap.remove(SBGName);
            } 
        }

        if (!removeSBGNameSet.isEmpty()) {
            for (String SBGName : removeSBGNameSet){
                byCategoryMap.remove(SBGName);
            }
        }

        
        if(!byCategoryMap.isEmpty()){
            List<String> bycategoryList = byCategoryMap.values();
            bycategoryList.sort();
            for(String str : bycategoryList){
                sortCategoryMap.put(str,str);
            }
        }
        
        /* 
            Case Number:INC0102304
            Author: Bowen
            Date: 2019-09-25 
            原始代码:对数据进行判空，直接放到list中，传到了ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand中，导致了空指针异常
        */
        // investmentBySubBrandByContractBySubBrand2nd = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        //     new List<String>{'lastPayment' ,'historical', 'estimate'},
        //     new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{
        //         ActualPerformance, historical, NewContractV0Esitimate
        //     }
        // );
        /*
            Case Number:INC0102304
            Author:Bowen
            Date:2019-09-25
            因为原来的代码不对数据进行判空，直接放到list中，传到了ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand中，导致了空指针异常
            先对数据先进行了判断，再放到list，就可以避免空指针异常的情况发生。

         */
        System.debug('ActualPerformance'+ActualPerformance2nd);
        System.debug('historical'+historical);
        System.debug('NewContractV0Esitimate'+NewContractV0Esitimate2nd);
        List<String> keys = new List<String>();
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> financialIndicators = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>();
        if(ActualPerformance2nd != null){
            keys.add('lastPayment');
            financialIndicators.add(ActualPerformance2nd);
        }

        // if(historical != null){
        //     keys.add('historical');
        //     financialIndicators.add(historical);
        // }

        if(NewContractV0Esitimate2nd != null){
            keys.add('estimate');
            financialIndicators.add(NewContractV0Esitimate2nd);
        }
        if(NewContactV0Contract2nd != null){
            keys.add('contractData');
            financialIndicators.add(NewContactV0Contract2nd);
        }
        if(keys.size() > 0 && financialIndicators.size() > 0)
        {
            try
            {   
                investmentByCategeryByContract = getInvestmentByCategory(keys,financialIndicators);
                investmentBySubBrandByContractBySubBrand2nd = getInvestmentBySubBrand(keys,financialIndicators);
                investmentBySubBrandByContractByLastVolume = investmentBySubBrandByContractByLastVolume(investmentBySubBrandByContractBySubBrand2nd);
                sortBySubBrandByContractBySubBrand = ActualPerformanceSortBRSFAmt(investmentBySubBrandByContractBySubBrand2nd);
            }
            catch(Exception ex){}
        }
        return true;
    }

    public boolean init(){
        /*
            Author:Bowen
            Date:2019-10-16
            update:InitVariable()的方法原来是在if判断外面的，但由于InitVariable()方法中有thisPR的使用，所以应当先判断thisPR是否为空，方能进入这个方法，所以将其置于if判断后
         */
        // InitVariable();
        if (thisPR != null){
            InitVariable();
            ContractSelected = ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(thisPR.ASI_TH_CRM_Contract__c);

            try{
                PayeeList = [SELECT id, ASI_CRM_CN_Type__c, ASI_CRM_CN_Amount__c, ASI_CRM_CN_Payee_Name_T1__c, ASI_CRM_CN_Payee_Name_T2_lookup__c,ASI_CRM_CN_Payee_Name_T2_lookup__r.Name, ASI_CRM_CN_Payee_Name_T1__r.Name,ASI_CRM_CN_Cash_Payee_Name_T1__c, ASI_CRM_CN_Cash_Payee_Name_T1__r.Name,ASI_CRM_CN_Cash_Amount__c
                FROM ASI_CRM_CN_PH_Payee_Line_Item__c WHERE ASI_CRM_CN_Payment_Request__c = :thisPR.id];
            }catch(exception e){
                PayeeList = new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
            }


            PaymentSummaryList = ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummaryTable(thisPR,ContractSelected);

            List<integer> lstRemove = new List<integer>();
            Integer indexNum=0;
            integer c = 0;
            if (PaymentSummaryList != null && PaymentSummaryList.size() > 0){
                for(ASI_CRM_CN_HeavyContractUtilitiesClass.PaymentSummary displayLine:PaymentSummaryList){
                    if(displayLine.POEstimatedAmount==0 && displayLine.PaymentRequestAmount==0){
                        lstRemove.add(indexNum);
                    }
                    indexNum++;
                }

                for(integer n : lstRemove){
                    if(n!=0){
                        if(c>0)
                            n=n-c;
                        PaymentSummaryList.remove(n);
                        c++;
                    }else{
                        PaymentSummaryList.remove(0);
                        c++;
                    }
                }
            }




            //Will calculate Total Paid Amount and Variable Amount
            TotalPaymentAmount = RetrieveTotalPaidAmount();


            Decimal V0FixCostAmount=CalculateV0FixCostAmount();

            Decimal V0ContractAmount =  CalculateV0ContractDetailCost();
            if (V0ContractAmount != null && V0ContractAmount !=0 && TotalPaymentVariableAmount != null && TotalPaymentVariableAmount != 0){
                PaymentSpeedexcFixCost = (TotalPaymentVariableAmount / V0ContractAmount) * 100; // No inculding Fix Cost
            }



            V0ContractAmount=V0ContractAmount+V0FixCostAmount;
            if (V0ContractAmount != null && V0ContractAmount !=0 && TotalPaymentAmount != null && TotalPaymentAmount != 0){
                PaymentSpeed = (TotalPaymentAmount / V0ContractAmount) * 100;
            }


            LoopingSubBrandVolumeCMGSList();

            LoopingPaymentRequestLine();



            lstApprovalComment = [SELECT id, ASI_CRM_BA_comments__c FROM ASI_CRM_Approval_Comment__c
            WHERE ASI_CRM_Payment_Request__c =:thisPR.id];
            if(lstApprovalComment==null || lstApprovalComment.size()==0){
                lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
            }else{
                lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
            }

        }

        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator historical = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();
        String V0ContractId=GenerateV0ContractId();
        
        /*
            Author:BLS
            Date:2020-05-10
            update : Last Payment Request 中的合同ROI与合同利润分析表中不一致,最新版本合同的Contract Date还是老的，可能CM，GS已经发生变化
        */
        //List<ASI_Attachment__c> attachments =   [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__c];
        // if(attachments.size()<=0 && attachments.isEmpty()) {
        //     if (ContractSelected.ASI_CRM_CN_V0_0_PO_version__c != null) {
        //        attachments = [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c];
        //     }
        // }
        List<ASI_Attachment__c> attachments= new List<ASI_Attachment__c>();
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c == null) {
            attachments = [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c ,ASI_CRM_Contract__r.ASI_CRM_CN_PO_Version__c
                FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c != null and ASI_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__c ORDER BY LastModifiedDate desc];
        }else {
            attachments = [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c ,ASI_CRM_Contract__r.ASI_CRM_CN_PO_Version__c
                FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c != null and (ASI_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__c or ASI_CRM_Contract__c = :thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c) ORDER BY LastModifiedDate desc];
        }
        //List<ASI_Attachment__c> attachments = [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :V0ContractId];
        /*
            Author:Bowen
            Date:2019-10-16
            update:因为这次修改的原因就是在json转译为list的时候出现空指针异常，所以为了跳出报错，在每个转译的时候，都加上trycatch，保证代码的顺利执行
            update：2020-05-10 CRMTypeRead
         */
        if(attachments.size() > 0 && !attachments.isEmpty()) {
            String CRMTypeRead = '';
            for (ASI_Attachment__c att : attachments) { 
                if(att.ASI_CRM_Type__c=='Historical Data' && !CRMTypeRead.contains(att.ASI_CRM_Type__c)){
                    CRMTypeRead += '-'+att.ASI_CRM_Type__c;
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');//
                    try
                    {
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(HistoricalContractList.size()>0){
                            historical= HistoricalContractList[0];
                        }
                    }catch(Exception e){}
                }
                else if(att.ASI_CRM_Type__c=='Last Payment Data' && !CRMTypeRead.contains(att.ASI_CRM_Type__c)){
                    CRMTypeRead += '-'+att.ASI_CRM_Type__c;
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    try
                    {
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){
                            ActualPerformance = ContractList[0];
                        }
                    }catch(Exception e){}
                } else if(att.ASI_CRM_Type__c=='Contract Data' && !CRMTypeRead.contains(att.ASI_CRM_Type__c)){
                    CRMTypeRead += '-'+att.ASI_CRM_Type__c;
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    try
                    {
                        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                        if(ContractList.size()>0){
                            NewContractV0Esitimate = DataRounding(ContractList[0]);
                            NewContactV0Contract= DataRounding(ContractList[1]);
                        }
                    }catch(Exception e){}
                }
            }
        }

        if (ContractSelected.ASI_CRM_CN_V0_0_PO_version__r != null) {
            ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorData(ContractSelected.ASI_CRM_CN_V0_0_PO_version__r);
        }
        
        /*for (ASI_Attachment__c att : [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c]) {
            if(att.ASI_CRM_Type__c=='Contract Data'){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<');
                JsonString = JsonString.replaceAll('&quot;','"');
                List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                if(ContractList.size()>0){
                    NewContractV0Esitimate = ContractList[0];
                    NewContactV0Contract = ContractList[1];
                }
            }
        }*/
        


        // Because FI only have key that has value, we need to add missing item
        // In Profit Shuttle all Grade grouping must be shown
        /*
            Author:Bowen
            Date:2019-10-16
            update:为了防止报空指针异常，对map的空进行判断下，保证先执行if前面一段，如果为空就跳出判断，这样就不执行&&后面的逻辑
         */
        for(String SBGName: sbGroup_map.keySet()){
            if(!NewContractV0Esitimate.SubBrandGradeMap.isEmpty() && !NewContractV0Esitimate.SubBrandGradeMap.containskey(SBGName)){
                NewContractV0Esitimate.SubBrandGradeMap.put(SBGName,0.0);
            }
            if(!NewContactV0Contract.SubBrandGradeMap.isEmpty() && !NewContactV0Contract.SubBrandGradeMap.containskey(SBGName)){
                NewContactV0Contract.SubBrandGradeMap.put(SBGName,0.0);
            }
            if(!ActualPerformance.SubBrandGradeMap.isEmpty() && !ActualPerformance.SubBrandGradeMap.containskey(SBGName)){
                ActualPerformance.SubBrandGradeMap.put(SBGName,0.0);
            }
        }



        /* 
            Case Number:INC0102304
            Author: Bowen
            Date: 2019-09-25 
            原始代码:对数据进行判空，直接放到list中，传到了ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand中，导致了空指针异常
        */
        // investmentBySubBrandByContractBySubBrand = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
        //     new List<String>{'lastPayment' ,'historical', 'estimate'},
        //     new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>{
        //         ActualPerformance, historical, NewContractV0Esitimate
        //     }
        // );
        /*
            Case Number:INC0102304
            Author:Bowen
            Date:2019-09-25
            因为原来的代码不对数据进行判空，直接放到list中，传到了ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand中，导致了空指针异常
            先对数据先进行了判断，再放到list，就可以避免空指针异常的情况发生。

         */
        List<String> keys = new List<String>();
        List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> financialIndicators = new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>();
        if(ActualPerformance != null)
        {
            keys.add('lastPayment');
            financialIndicators.add(ActualPerformance);
        }

        if(historical != null)
        {
            keys.add('historical');
            financialIndicators.add(historical);
        }

        if(NewContractV0Esitimate != null)
        {
            keys.add('estimate');
            financialIndicators.add(NewContractV0Esitimate);
        }
        if(keys.size() > 0 && financialIndicators.size() > 0)
        {
            try
            {
                investmentBySubBrandByContractBySubBrand = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(keys,financialIndicators);
            }
            catch(Exception ex){}
        }


        return true;
    }
    
    /** 
    * @description 
    * @author pengchen@bluelinksys.com | 4/26/2020 
    * @param Map<String Map<String ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> ActualPerformanceSortBRSFAmtMap 
    * @return Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> 
    **/
    public Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> investmentBySubBrandByContractByLastVolume(
        Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> ActualPerformanceSortBRSFAmtMap){

        System.debug('ActualPerformanceSortBRSFAmtMap'+ActualPerformanceSortBRSFAmtMap);
        Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> result = new Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>();
        Map<String,String> subBrandValueMap = new Map<String,String>();
        if(BelongGroup.contains('D')){
            subBrandValueMap = eNgetSelectedSubBrandName();
        }else{
            subBrandValueMap = cNgetSelectedSubBrandName();
        }

        List<Decimal> sortESCLsit = new List<Decimal>();
        List<Decimal> sortDESCLsit = new List<Decimal>();

        List<Decimal> sortEstEscList = new List<Decimal>();
        List<Decimal> sortEstDEscList = new List<Decimal>();

        List<Decimal> sortConEscList = new List<Decimal>();
        List<Decimal> sortConDEscList= new List<Decimal>();

        String nineId = getSelectedNineIds();
        for(String key : ActualPerformanceSortBRSFAmtMap.keySet()){
            if(key != nineId){
                if (ActualPerformanceSortBRSFAmtMap.get(key).get('lastPayment').volumeSTD != null && ActualPerformanceSortBRSFAmtMap.get(key).get('lastPayment').volumeSTD !=0)
                {
                    sortESCLsit.add(ActualPerformanceSortBRSFAmtMap.get(key).get('lastPayment').volumeSTD);
                }
                else if (ActualPerformanceSortBRSFAmtMap.get(key).get('estimate').volumeSTD != null && ActualPerformanceSortBRSFAmtMap.get(key).get('estimate').volumeSTD !=0)
                {
                    sortEstEscList.add(ActualPerformanceSortBRSFAmtMap.get(key).get('estimate').volumeSTD);
                }
                else //if (ActualPerformanceSortBRSFAmtMap.get(key).get('contractData').volumeSTD != null && ActualPerformanceSortBRSFAmtMap.get(key).get('contractData').volumeSTD !=0)
                {
                    sortConEscList.add(ActualPerformanceSortBRSFAmtMap.get(key).get('contractData').volumeSTD);
                }
            }else{
                Ishave999 = true;
                result.put(999,ActualPerformanceSortBRSFAmtMap.get(key));
                subBrandNameMap.put(999,'999');
            }

        }
        sortESCLsit.sort();
        System.debug('sortESCLsit'+sortESCLsit);
        sortEstEscList.sort();
        System.debug('sortEstEscList'+sortEstEscList);
        sortConEscList.sort();
        System.debug('sortConEscList'+sortConEscList);
        // DESC
        for(Integer i = sortESCLsit.size()-1; i>=0;i--){
            sortDESCLsit.add(sortESCLsit.get(i));
        }
        System.debug('sortDESCLsit'+sortDESCLsit);
        
        // DESC
        for(Integer i = sortEstEscList.size()-1; i>=0;i--){
            sortEstDEscList.add(sortEstEscList.get(i));
        }
        System.debug('sortEstDEscList'+sortEstDEscList);

        // DESC
        for(Integer i = sortConEscList.size()-1; i>=0;i--){
            sortConEscList.add(sortConEscList.get(i));
        }
        System.debug('sortConDEscList'+sortConDEscList);
        Decimal i = 0;
        Set<String> checkSet = new Set<String>();
        
        for(Decimal dec : sortDESCLsit){
            i++;
            if (i==21 && Ishave999) {
                result.put(i,result.get(999));
                subBrandNameMap.put(i,'999');
                i++;
            }
            for(String key : ActualPerformanceSortBRSFAmtMap.keySet()){
                if(ActualPerformanceSortBRSFAmtMap.get(key).get('lastPayment').volumeSTD == dec && !checkSet.contains(key) && key != nineId){
                    result.put(i,ActualPerformanceSortBRSFAmtMap.get(key));
                    subBrandNameMap.put(i,subBrandValueMap.get(key));
                    checkSet.add(key);
                    break;
                }
            }
        }

        if (!sortEstDEscList.isEmpty()) {
            for(Decimal dec : sortEstDEscList){
                i++;
                if (i==21 && Ishave999) {
                    result.put(i,result.get(999));
                    subBrandNameMap.put(i,'999');
                    i++;
                }
                for(String key : ActualPerformanceSortBRSFAmtMap.keySet()){
                    if(ActualPerformanceSortBRSFAmtMap.get(key).get('estimate').volumeSTD == dec && !checkSet.contains(key) && key != nineId){
                        result.put(i,ActualPerformanceSortBRSFAmtMap.get(key));
                        subBrandNameMap.put(i,subBrandValueMap.get(key));
                        checkSet.add(key);
                        break;
                    }
                }
            }
        }
            
        if (!sortConDEscList.isEmpty()) {
            for(Decimal dec : sortConDEscList){
                i++;
                if (i==21 && Ishave999) {
                    result.put(i,result.get(999));
                    subBrandNameMap.put(i,'999');
                    i++;
                }
                for(String key : ActualPerformanceSortBRSFAmtMap.keySet()){
                    if(ActualPerformanceSortBRSFAmtMap.get(key).get('contractData').volumeSTD == dec && !checkSet.contains(key) && key != nineId){
                        result.put(i,ActualPerformanceSortBRSFAmtMap.get(key));
                        subBrandNameMap.put(i,subBrandValueMap.get(key));
                        checkSet.add(key);
                        break;
                    }
                }
            }
        }


        System.debug('result'+result);
        return result;

    }

    /**
    * @description 
    * @author pengchen@bluelinksys.com | 4/2/2020 
    * @param Map<String Map<String ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> ActualPerformanceSortBRSFAmtMap 
    * @return Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> 
    **/
    public static Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> ActualPerformanceSortBRSFAmt(
        Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> ActualPerformanceSortBRSFAmtMap){

        System.debug('ActualPerformanceSortBRSFAmtMap'+ActualPerformanceSortBRSFAmtMap);
        Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> result = new Map<Decimal, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>();

        List<Decimal> sortESCLsit = new List<Decimal>();
        List<Decimal> sortDESCLsit = new List<Decimal>();
        String nineId = getSelectedNineIds();
        for(String key : ActualPerformanceSortBRSFAmtMap.keySet()){
            sortESCLsit.add(ActualPerformanceSortBRSFAmtMap.get(key).get('lastPayment').propByStdTotal);
        }
        sortESCLsit.sort();

        // DESC
        for(Integer i = sortESCLsit.size()-1; i>=0;i--){
            sortDESCLsit.add(sortESCLsit.get(i));
        }

        System.debug('sortDESCLsit'+sortDESCLsit);
        Decimal i = 0;

        Set<String> checkSet = new Set<String>();
        for(Decimal dec : sortDESCLsit){
            Decimal num = i++;
            for(String key : ActualPerformanceSortBRSFAmtMap.keySet()){
                if(num<10){
                    if(ActualPerformanceSortBRSFAmtMap.get(key).get('lastPayment').propByStdTotal == dec && !checkSet.contains(key)){
                        result.put(num,ActualPerformanceSortBRSFAmtMap.get(key));
                        checkSet.add(key);
                        break;
                    }
                }
            }
        }

        System.debug('result'+result);
        return result;

    }

    public static Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> getInvestmentBySubBrand(List<String> keys, List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> financialIndicators){
        Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> result = new Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>();

        Set<String> existSubids = new Set<String>();
        for (Integer i = 0; i < keys.size(); i++) {
            String key = keys[i];
            if (financialIndicators[i].TradeExpenseBySubBrand == null) {
                continue;
            }
            
            for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : financialIndicators[i].TradeExpenseBySubBrand) {
                existSubids.add(breakdown.subBrandId);
            }
        }

        for (String subBrandId : getSelectedSubBrandIds(existSubids)) {
            result.put(subBrandId, new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>());
            for (String key : keys) {
                result.get(subBrandId).put(key, new ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd());
            }
        }
        for (Integer i = 0; i < keys.size(); i++) {
            String key = keys[i];
            if (financialIndicators[i].TradeExpenseBySubBrand == null) {
                continue;
            }
            
            for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : financialIndicators[i].TradeExpenseBySubBrand) {
                if (!result.containsKey(breakdown.subBrandId)) {
                    continue;
                }
                result.get(breakdown.subBrandId).put(key, breakdown);
            }

        }
        // Remove empty map
        for (String subBrandId : result.keySet()) {
            Boolean allEmpty = true;
            for (ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd breakdown : result.get(subBrandId).values()) {
                if (breakdown.subBrandId != null) {
                    allEmpty = false;
                }
            }
            if (allEmpty) {
                result.remove(subBrandId);
            }
        }

        // Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> DESCresult = new Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>();


        // String nineId = getSelectedNineIds();
        // Integer num = 0;
        // for(String str : result.KeySet()){
        //     if(str != nineId){
        //         DESCresult.put(num+str,result.get(str));
        //         // num++;
        //     }else{
        //         //DESCresult.put(String.valueof(result.size())+str,result.get(str));
        //         DESCresult.put('999'+str,result.get(str));
        //     }
        // }
        // System.debug('DESCresult'+DESCresult);
        return result;
    }

    public static Map<String, Map<String, Decimal>> getInvestmentByCategory(List<String> keys, List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> financialIndicators){
        Map<String, Map<String, Decimal>> result = new Map<String, Map<String, Decimal>>();

        for (String cateroryName : getSelectedCategory()) {

            result.put(cateroryName, new Map<String, Decimal>());
            for (String key : keys) {
                Decimal catValue = 0;
                result.get(cateroryName).put(key, catValue);
            }
        }
        for (Integer i = 0; i < keys.size(); i++) {
            String key = keys[i];

            if (financialIndicators[i].CategoryMap.isEmpty()) {
                continue;
            }
            for (String catKey : financialIndicators[i].CategoryMap.KeySet()) {
                if (!result.containsKey(catKey)) {
                    continue;
                }
                result.get(catKey).put(key, financialIndicators[i].CategoryMap.get(catKey));
            }

        }

        // Remove empty map
        for (String cateroryName : result.keySet()) {
            if(result.get(cateroryName).get('contractData') == 0 && result.get(cateroryName).get('estimate') == 0 
                && result.get(cateroryName).get('historical') == 0 && result.get(cateroryName).get('lastPayment') == 0){
                result.remove(cateroryName);
            }
        }
        System.debug('resultcateroryName'+result);
        return result;
    }

    public static Set<Id> getSelectedSubBrandIds(Set<String> existSubids){
        return (new Map<Id, ASI_MFM_Sub_brand__c>([SELECT Id  FROM ASI_MFM_Sub_brand__c where id in :existSubids]).keySet());
    }
    public Map<String, String> eNgetSelectedSubBrandName(){
        Map<String, String> subbrandNameMap = new Map<String, String>();
        for(ASI_MFM_Sub_brand__c amsb : [SELECT Id, Name,ASI_HK_CRM_English_Name__c FROM ASI_MFM_Sub_brand__c WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand' OR Name = '999']){
            subbrandNameMap.put(amsb.Id, amsb.ASI_HK_CRM_English_Name__c);
        }
        return subbrandNameMap;
    }

    public Map<String, String> cNgetSelectedSubBrandName(){
        Map<String, String> subbrandNameMap = new Map<String, String>();
        for(ASI_MFM_Sub_brand__c amsb : [SELECT Id, Name,ASI_CRM_CN_CHI_NAME_C__c FROM ASI_MFM_Sub_brand__c WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand' OR Name = '999']){
            subbrandNameMap.put(amsb.Id, amsb.ASI_CRM_CN_CHI_NAME_C__c);
        }
        return subbrandNameMap;
    }

    public static String getSelectedNineIds(){
        List<ASI_MFM_Sub_brand__c> amsbList = [SELECT Id  FROM ASI_MFM_Sub_brand__c WHERE Name = :'999'];
        if(!amsbList.isEmpty()){
            return amsbList[0].Id;
        }else{
            return '';
        }
    }

    public static Set<String> getSelectedCategory(){
        Set<String> categorySet = new Set<String>();
        for(ASI_HK_CRM_Product_Category__c ahcpc : [SELECT Id,
                                                           RecordType.DeveloperName,
                                                           Name 
                                                    FROM ASI_HK_CRM_Product_Category__c 
                                                    WHERE RecordType.DeveloperName = :'ASI_CRM_CN_Product_Category']){
        categorySet.add(ahcpc.Name);
    }
        return categorySet;
    }

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd DataRounding2nd(ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd InputData){
        //ROIIntake setScale

        InputData.GrossSalesRate = InputData.GrossSalesRate!=null? InputData.GrossSalesRate.setScale(1):0;
        InputData.ROIIntake = InputData.ROIIntake!=null? InputData.ROIIntake.setScale(2):0;

        return InputData;
    }

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator DataRounding(ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator InputData){
        //ROIIntake setScale

        InputData.GrossSalesRate = InputData.GrossSalesRate!=null? InputData.GrossSalesRate.setScale(1):0;
        InputData.ROIIntake = InputData.ROIIntake!=null? InputData.ROIIntake.setScale(2):0;

        return InputData;
    }

    //setup init variable
    public void InitVariable2nd(){
        MartellBCRate=0;
        ContractBCRate=0;
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null){
            ContractBCRate=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c;
        }else{
            ContractBCRate=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c;
        }


        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null){
            MartellBCRate=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c;
        }else{
            MartellBCRate=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Martell_BC_Rate__c;
        }

        TotalPaymentVariableAmount=0;
        BRSF_CTD_CR12=0;
        PayeeList=new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        CutOffDay=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        if (strPDF == '1'){
            AdorAbove = ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
            BelongGroup = UserOrGroupInit();
        }else if (strPDF == '0'){
            AdorAbove=ASI_CRM_CN_HeavyContractUtilitiesClass.checkApprover(thisPR.id);
            set<Id> userIds = new set<Id>();
            for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : thisPR.id]){
                userIds.add(piw.ActorId);
            }
            BelongGroup = checkOtherUserGroup(userIds);
        }else if (strPDF == '2'){
            AdorAbove= checkAdorAbove(thisPR.OwnerId);
            set<Id> userIds = new set<Id>();
            userIds.add(thisPR.OwnerId);
            BelongGroup = checkOtherUserGroup(userIds);
        }


    }

    public void InitVariable(){
        MartellBCRate=0;
        ContractBCRate=0;
        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null){
            ContractBCRate=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Bottle_Collection_Rate__c;
        }else{
            ContractBCRate=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Bottle_Collection_Rate__c;
        }


        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c != null){
            MartellBCRate=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_Martell_BC_Rate__c;
        }else{
            MartellBCRate=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_Martell_BC_Rate__c;
        }

        TotalPaymentVariableAmount=0;
        BRSF_CTD_CR12=0;
        PayeeList=new list<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        CutOffDay=ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        if (strPDF == '1'){
            AdorAbove = ASI_CRM_CN_HeavyContractUtilitiesClass.checkUserID();
        }else if (strPDF == '0'){
            AdorAbove=ASI_CRM_CN_HeavyContractUtilitiesClass.checkApprover(thisPR.id);
        }


    }

    public String checkOtherUserGroup(Set<Id> userIds){
        // AdorAbove = false;
        
        // list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];

        String groupAName = 'ASI_CN_GS_Commercial_team';
        String groupBName = 'ASI_CN_Commercial_team_ex_GS';
        String groupCName = 'ASI_CN_Finance';
        String groupDName = 'ASI_CN_HQ_Management';

        String belongGroup = 'Group ';

        if (userIds != null && !userIds.isEmpty())
        {
            Set<String> groupNames = new Set<String>();
            for (GroupMember gm: [SELECT group.name,
                                         group.DeveloperName
                                  FROM GroupMember
                                  WHERE UserOrGroupId IN: userIds]) {
                groupNames.add(gm.group.DeveloperName);
            }
            if (groupNames.contains(groupAName)) {
                belongGroup += 'A';
            }
            if (groupNames.contains(groupBName)) {
                belongGroup += 'B';
            }
            if (groupNames.contains(groupCName)) {
                belongGroup += 'C';
            }
            if (groupNames.contains(groupDName)) {
                belongGroup += 'D';
            }
        }
        return belongGroup;
        // if(gms.size()>0)
        //     AdorAbove = true;
    }

    public static Boolean checkAdorAbove(String userId){
        Boolean AdorAbove =false;
        List<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:userId];
        if(gms.size()>0){
            AdorAbove = true;
        }
        return AdorAbove;
    }


    // Calculate Payment V0.0 Contract Detail Line Contact Cost (not including Fix cost)
    Public Decimal CalculateV0ContractDetailCost2nd(){
        Decimal ContractAmount=0;
        Set<String> SubBrandIdSet = new Set<String> ();
        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLines = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();

        String V0ContractId=GenerateV0ContractId();
        try{
            //query ContractBRSF Sub Brands & Data
            ContractLines = [SELECT id, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Contract_Total__c,ASI_CRM_Type__c , ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Monthly_Qty__c , ASI_CRM_CN_Sub_Brand_Conversion_Factor__c,  ASI_CRM_CN_Contract__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c,ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CategoryName__c
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0ContractId];
        }catch(exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.CalculateV0EstCost  class have Error  '+msg,'ASI_CRM_CN_HeavyContractUtilitiesClass',' function failed! with Payment Id: '+thisPR.id );
        }

        //1st Time Looping
        // public Map<String,VolumeObject> VolumeMap {set;get;} {VolumeMap= new Map<String,VolumeObject>(); }
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractDetail:ContractLines){
            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                Decimal ContractTarget=ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractDetail.ASI_CRM_CN_No_of_Months__c:0;

                String Mapkeystr= NameSortingASC(ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+ ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;

                if(VolumeMap.containsKey(Mapkeystr)){
                    VolumeObject TempObject= VolumeMap.get(Mapkeystr);
                    TempObject.FullContractTarget +=ContractTarget.setScale(0);
                    VolumeMap.remove(Mapkeystr);
                    VolumeMap.put(Mapkeystr, TempObject);
                }else{
                    VolumeObject TempObject= new VolumeObject();
                    TempObject.CategoryName = ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CategoryName__c;
                    TempObject.SubBrandGradeName=ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    TempObject.SubBrandGradeCNName = ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                    TempObject.FullContractTarget=ContractTarget.setScale(0);
                    VolumeMap.put(Mapkeystr, TempObject);
                }


                SubBrandIdSet.add(ContractDetail.ASI_CRM_CN_Sub_Brand__c);//ASI_CRM_CN_Estimate_Volume_9L_Month__c
            }
        }

        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractDetail:ContractLines){
            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                Decimal ContractTarget=ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractDetail.ASI_CRM_CN_No_of_Months__c:0;
                String categoryName = ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CategoryName__c;

                if(VolumeByCategoryMap.containsKey(categoryName)){
                    VolumeObject TempObject= VolumeByCategoryMap.get(categoryName);
                    TempObject.FullContractTarget += ContractTarget.setScale(0);
                    VolumeByCategoryMap.remove(categoryName);
                    VolumeByCategoryMap.put(categoryName,TempObject);
                }else{
                    VolumeObject TempObject= new VolumeObject();
                    TempObject.CategoryName = categoryName;
                    TempObject.FullContractTarget=ContractTarget.setScale(0);
                    VolumeByCategoryMap.put(categoryName,TempObject);
                }
            }
        }

        if(SubBrandIdSet.size()>0){
            CR12FactorMap=GenerateCR12FactorMap(SubBrandIdSet);
        }


        //2nd Time Looping
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetail:ContractLines){
            ContractAmount+= contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c!=null? contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            Decimal CR12Factor=CR12FactorMap.containsKey(contractDetail.ASI_CRM_CN_Sub_Brand__c) ? CR12FactorMap.get(contractDetail.ASI_CRM_CN_Sub_Brand__c) :1;


            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                BRSF_CTD_CR12+=CR12Factor*contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c* contractDetail.ASI_CRM_CN_No_of_Months__c;
            }


        }



        return ContractAmount;
    }

    // Calculate Payment V0.0 Contract Detail Line Contact Cost (not including Fix cost)
    Public Decimal CalculateV0ContractDetailCost(){
        Decimal ContractAmount=0;
        Set<String> SubBrandIdSet = new Set<String> ();
        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ContractLines = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();

        String V0ContractId=GenerateV0ContractId();
        try{
            //query ContractBRSF Sub Brands & Data
            ContractLines = [SELECT id, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                ASI_CRM_CN_Est_Total_Dummy__c,ASI_CRM_CN_Contract_Total__c,ASI_CRM_Type__c , ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Est_Monthly_Qty__c , ASI_CRM_CN_Sub_Brand_Conversion_Factor__c,  ASI_CRM_CN_Contract__c, ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c,ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c, ASI_CRM_CN_Contract_Monthly_Qty__c,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Standard_Bottle_Size__c,
                ASI_CRM_CN_Contract__r.ASI_CRM_CN_PO_Version__c
            FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :V0ContractId];
        }catch(exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.CalculateV0EstCost  class have Error  '+msg,'ASI_CRM_CN_HeavyContractUtilitiesClass',' function failed! with Payment Id: '+thisPR.id );
        }

        //1st Time Looping
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractDetail:ContractLines){
            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                Decimal ContractTarget=ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?ContractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractDetail.ASI_CRM_CN_No_of_Months__c:0;

                String Mapkeystr= NameSortingASC(ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+ ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c;

                if(VolumeMap.containsKey(Mapkeystr)){
                    VolumeObject TempObject= VolumeMap.get(Mapkeystr);
                    TempObject.FullContractTarget +=ContractTarget.setScale(0);
                    VolumeMap.remove(Mapkeystr);
                    VolumeMap.put(Mapkeystr, TempObject);
                }else{
                    VolumeObject TempObject= new VolumeObject();
                    TempObject.SubBrandGradeName=ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    TempObject.SubBrandGradeCNName = ContractDetail.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                    TempObject.FullContractTarget=ContractTarget.setScale(0);
                    VolumeMap.put(Mapkeystr, TempObject);
                }


                SubBrandIdSet.add(ContractDetail.ASI_CRM_CN_Sub_Brand__c);//ASI_CRM_CN_Estimate_Volume_9L_Month__c
            }
        }

        if(SubBrandIdSet.size()>0){
            CR12FactorMap=GenerateCR12FactorMap(SubBrandIdSet);
        }


        //2nd Time Looping
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractDetail:ContractLines){
            ContractAmount+= contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c!=null? contractDetail.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            Decimal CR12Factor=CR12FactorMap.containsKey(contractDetail.ASI_CRM_CN_Sub_Brand__c) ? CR12FactorMap.get(contractDetail.ASI_CRM_CN_Sub_Brand__c) :1;


            if(ContractDetail.ASI_CRM_Type__c=='BRSF'){
                BRSF_CTD_CR12+=CR12Factor*contractDetail.ASI_CRM_CN_Contract_Monthly_Qty__c* contractDetail.ASI_CRM_CN_No_of_Months__c;
            }


        }



        return ContractAmount;
    }







    public void LoopingSubBrandVolumeCMGSList(){
        Decimal Vol_CR12_1 =0; //All Payment Period




        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
            FROM ASI_CRM_CN_Covered_Outlet__c
            WHERE ASI_CRM_CN_Contract__c = :thisPR.ASI_TH_CRM_Contract__c];
        }catch(exception e){
            CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }
        set<id> AllOutlet = new set<id>();
        ASI_TH_CRM_PaymentRequest__c tempPR = [SELECT id, ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :thisPR.id];
        if (tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ){
            AllOutlet.add(thisPR.ASI_CRM_CN_OutletWS__c);
        }
        if (tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Normal' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || tempPR.ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c == null ) {
            if (CoveredOutlet.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c CO_temp: CoveredOutlet){
                    AllOutlet.add(CO_temp.ASI_CRM_CN_Outlet__c);
                }
            }
        }
        date TillEnd = ASI_CRM_CN_HeavyContractUtilitiesClass.getEndDate(ASI_CRM_CN_HeavyContractUtilitiesClass.FindMinMaxDate(CutOffDay, thisPR.ASI_CRM_CN_PO_End_Date__c, 'MIN'));


        list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c> ();

        try{
            SB_Vol_List = [SELECT Id,Name,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c , ASI_CRM_T1_Depletion_Std_Billing__c,ASI_CRM_Cap_with_Issues_Std_Billing__c,ASI_CRM_DeductibleCapWithIssues_Std_Btl__c, ASI_CRM_T1_Depletion_CR12__c,ASI_CRM_T2_Depletion_Std_Billing__c,
                ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,ASI_CRM_Subbrand__r.ASI_MFM_Sub_brand_External_ID__c,ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c,
                ASI_CRM_T2_Depletion_CR12__c,ASI_CRM_PR_Direct_Std_Billing__c, ASI_CRM_PR_Direct_CR12__c,ASI_CRM_End_Date__c, ASI_CRM_Subbrand__c,
                ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name,ASI_CRM_Green_Cap_Std_Billing__c  , ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion__c,ASI_CRM_PR_Direct__c,
                ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                ASI_CRM_T1_Depletion_STD__c, ASI_CRM_T2_Depletion_STD__c,ASI_CRM_PR_Direct_STD__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c, ASI_CRM_Green_Cap_STD__c,
                ASI_CRM_Empty_Bottle_Std_Btl__c, ASI_CRM_Offtake_Std_Billing__c,ASI_CRM_Subbrand__r.ASI_CRM_CN_CategoryName__c
            FROM ASI_CRM_Subbrand_Volume__c
            WHERE ASI_CRM_End_Date__c >= :thisPR.ASI_CRM_CN_PO_Start_Date__c AND ASI_CRM_End_Date__c <= :TillEnd  AND ASI_CRM_CN_Competitor_Sub_brand__c != true
            AND ASI_CRM_Account__c IN :AllOutlet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =false and ASI_CRM_Subbrand__c !=null];

        }catch(exception e){
            SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c >();
        }




        //Looping Sub-brand Volume
        for (ASI_CRM_Subbrand_Volume__c  SB_Vol_temp : SB_Vol_List){
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T1_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c!=null?SB_Vol_temp.ASI_CRM_T2_Depletion_CR12__c:0;
            Vol_CR12_1 += SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c!=null?SB_Vol_temp.ASI_CRM_PR_Direct_CR12__c:0;


            String Mapkeystr= NameSortingASC(SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c;
            Decimal CTDActualVol=0.0;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c;
            CTDActualVol+= SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c;
            CTDActualVol=CTDActualVol.setScale(0);

            if(VolumeMap.containsKey(Mapkeystr)){
                VolumeObject TempObject= VolumeMap.get(Mapkeystr);
                TempObject.CTDActualVol +=CTDActualVol;
                VolumeMap.remove(Mapkeystr);
                VolumeMap.put(Mapkeystr, TempObject);
            }else{
                VolumeObject TempObject= new VolumeObject();
                TempObject.SubBrandGradeName=SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                TempObject.SubBrandGradeCNName = SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                TempObject.CTDActualVol=CTDActualVol;
                VolumeMap.put(Mapkeystr, TempObject);
            }
        }

        if (thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            for(ASI_CRM_Subbrand_Volume__c  SB_Vol_temp : SB_Vol_List){
                Decimal CTDActualVol=0.0;
                CTDActualVol+= SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_PR_Direct_STD_Billing__c;
                CTDActualVol+= SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T1_Depletion_STD_Billing__c;
                CTDActualVol+= SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c == null ? 0 :SB_Vol_temp.ASI_CRM_T2_Depletion_STD_Billing__c;
                CTDActualVol=CTDActualVol.setScale(0);

                String categoryName = SB_Vol_temp.ASI_CRM_Subbrand__r.ASI_CRM_CN_CategoryName__c;

                if(VolumeByCategoryMap.containsKey(categoryName)){
                    VolumeObject TempObject= VolumeByCategoryMap.get(categoryName);
                    TempObject.CTDActualVol+=CTDActualVol;
                    VolumeByCategoryMap.remove(categoryName);
                    VolumeByCategoryMap.put(categoryName,TempObject);
                }else{
                    VolumeObject TempObject= new VolumeObject();
                    TempObject.CategoryName = categoryName;
                    TempObject.CTDActualVol=CTDActualVol;
                    VolumeByCategoryMap.put(categoryName,TempObject);
                }
                
            }
        }
        





        for (String  VolumeMapKey:VolumeMap.keySet()){
            if(VolumeMap.get(VolumeMapKey).FullContractTarget==0 && VolumeMap.get(VolumeMapKey).CTDActualVol==0){
                VolumeMap.remove(VolumeMapKey);
            }
        }


        //************************Calculation****************************************
        if (BRSF_CTD_CR12 != null && BRSF_CTD_CR12 != 0){
            Other_VOL_CR12 =  (Vol_CR12_1 / BRSF_CTD_CR12)  * 100;
        }
    }







    public void LoopingPaymentRequestLine(){
        Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>();
        for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Parent_Module__c,ASI_CRM_Payment_Reference__c,ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,ASI_CRM_End_Date__c,ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,ASI_CRM_Other_Comments__c,ASI_CRM_Overpayment_Reason__c,ASI_CRM_Actual_Payment__c,ASI_CRM_Adjustment__c,ASI_CRM_Application_Payment_Amount__c,ASI_CRM_Historical_Paid_Amount__c, ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c
        from ASI_CRM_Module__c where ASI_CRM_Payment_Request__c =:thisPR.Id AND (ASI_CRM_Line_Type__c='PSF' or ASI_CRM_Line_Type__c='BRSF')])
        {
            if(Module.ASI_CRM_Line_Type__c=='BRSF'){
                if(Module.ASI_CRM_End_Date__c!=null){
                    DisplayBRSFPart=true;
                }
                interimData TempData= new interimData(Module);
                BRSFItemMap=TempData;
            }
            if(Module.ASI_CRM_Line_Type__c=='PSF'){
                interimData TempData= new interimData(Module);
                if(Module.ASI_CRM_End_Date__c!=null){
                    PSF_Item_Map.put(Module.ID,TempData);
                }


            }
            ModuleMap.put(Module.Id,Module);
        }


        for(ASI_TH_CRM_PaymentRequestLineItem__c payline:[SELECT id, ASI_CRM_Suggested_Value__c ,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_TH_CRM_Payment_Request__c,ASI_CRM_Volume_Base__c ,
            ASI_CRM_Product_Category__c,ASI_CRM_Sub_Brand_Grade__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
            ASI_CRM_CTD_Actual_Vol__c , ASI_CRM_CN_Standard__c ,ASI_CRM_CTD_Cap_Collection_Vol__c ,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_CN_Sequence__c,
            ASI_CRM_CN_Payable_Vol__c  , ASI_CRM_Key_Sub_Brand__c, ASI_CRM_CN_Completion_Rate__c,
            ASI_CRM_V0_0_Full_Contract_Target__c, ASI_CRM_CN_Total_Payable__c , ASI_CRM_CN_Actual_Vol__c ,
            ASI_CRM_CN_Bottle_Collected__c, ASI_CRM_CN_Collection_Rate__c ,ASI_CRM_CN_Incentive_BT__c , ASI_CRM_CN_Allow_Changing_Incentive__c ,
            ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_Module__c ,ASI_CRM_CN_Sub_Brand__c,RecordType.DeveloperName,
            ASI_CRM_CN_Expense_Type__c, ASI_CRM_CN_Comment__c, ASI_TH_CRM_Amount__c, ASI_CRM_CN_Remaining_Amount__c, recordtypeid , ASI_CRM_CNY_Est__c,
            ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_TH_CRM_Payment_Request__r.ASI_CRM_CN_Promotion_Type__c, ASI_CRM_CN_AC_Code__c
        FROM ASI_TH_CRM_PaymentRequestLineItem__c
        WHERE ASI_TH_CRM_Payment_Request__c =:thisPR.id ])
        {
            if(payline.ASI_CRM_Module__c !=null){
                if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_BRSF'){
                    BRSFItemMap.TotalIntake+=payline.ASI_CRM_CTD_Actual_Vol__c!=null?payline.ASI_CRM_CTD_Actual_Vol__c:0;
                    BRSFItemMap.TotalBC+=payline.ASI_CRM_CTD_Cap_Collection_Vol__c!=null?payline.ASI_CRM_CTD_Cap_Collection_Vol__c:0;
                    BRSFItemMap.DetailLineMap.put(payline.ASI_CRM_CN_Sub_Brand__c,payline);

                    //ASI_CRM_V0_0_Full_Contract_Target__c
                }else if(payline.RecordType.DeveloperName=='ASI_CRM_CN_Payment_Request_Detail_PSF'){
                    if(PSF_Item_Map.containsKey(payline.ASI_CRM_Module__c)){
                        PSF_Item_Map.get(payline.ASI_CRM_Module__c).DetailLineMap.put(payline.Id,payline);
                    }
                }

            }

        }


        if(PSF_Item_Map.size()>0){
            DisplayPSFPart=true;
        }

        if(BRSFItemMap.TotalIntake!=null && BRSFItemMap.TotalIntake!=0 && BRSFItemMap.TotalBC!=null ){
            BRSFItemMap.BCRate = (BRSFItemMap.TotalBC / BRSFItemMap.TotalIntake)*100;
        }
        if(BRSFItemMap.Module.ASI_CRM_End_Date__c !=null){
            BRSFmonthsBetween =  ContractSelected.ASI_CRM_CN_PO_Start_Date__c.monthsBetween(BRSFItemMap.Module.ASI_CRM_End_Date__c);
            //BRSFItemMap.Module.ASI_CRM_End_Date__c.monthsBetween(ContractSelected.ASI_CRM_CN_PO_Start_Date__c);
            BRSFmonthsBetween= BRSFmonthsBetween+1;
        }

    }



    //Get all Payment Amount(Approved/Submitted/Paid) 
    public decimal RetrieveTotalPaidAmount(){

        decimal allPaymentTotal = 0;
        //Query all payment request with vFinal contract
        list<ASI_TH_CRM_PaymentRequest__c> AllPaymentRequest = new list<ASI_TH_CRM_PaymentRequest__c>();
        try{
            AllPaymentRequest = [SELECT Id,Name,ASI_CRM_CN_Total_VEC_Amount__c,
                ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
                ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c
            FROM ASI_TH_CRM_PaymentRequest__c
            WHERE ASI_TH_CRM_Contract__c =:thisPR.ASI_TH_CRM_Contract__c
            AND (id = :thisPR.id OR ASI_TH_CRM_Status__c = 'Approved' OR ASI_TH_CRM_Status__c = 'Submitted'  OR ASI_TH_CRM_Status__c = 'Paid')];
        }catch(exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyPaymentCheckCtrl. RetrieveTotalPaidAmount  class have Error  '+msg,'ASI_CRM_CN_HeavyContractUtilitiesClass',' function failed! with Payment Id: '+thisPR.id );
        }

        //Sum up previous payments amounts
        if (AllPaymentRequest.size() > 0){
            for (ASI_TH_CRM_PaymentRequest__c allPR_temp : AllPaymentRequest){
                if (allPR_temp.ASI_CRM_CN_Total_Payment__c != null){
                    allPaymentTotal += allPR_temp.ASI_CRM_CN_Total_Payment__c;

                    if(allPR_temp.ASI_CRM_CN_Promotion_Type__c=='Heavy Contract On'){
                        if(allPR_temp.Name.length()>3 && (allPR_temp.Name.substring(allPR_temp.Name.length()-3, allPR_temp.Name.length()) == '000')){///000-Payment
                            TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                            TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                            TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c:0;
                        }else{
                            TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_Total_Variable_Amount__c!=NULL?allPR_temp.ASI_CRM_Total_Variable_Amount__c:0;
                        }

                    }else{
                        TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_BRSF_Amount__c:0;
                        TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_PSF_Amount__c:0;
                        TotalPaymentVariableAmount+=allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c!=NULL?allPR_temp.ASI_CRM_CN_Total_VEC_Amount__c:0;
                    }

                }
            }
        }
        return allPaymentTotal;
    }




    //Looping Fix cost 
    Public Decimal CalculateV0FixCostAmount(){
        Decimal FixCostAmount=0;
        String V0ContractId=GenerateV0ContractId();
        list<ASI_CRM_Contract_Cost__c>  v0_EstCostList = new list<ASI_CRM_Contract_Cost__c>();
        try{
            v0_EstCostList = [SELECT Id,Name,ASI_CRM_CN_Estimate_Amount__c, ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Contract_Amount__c
            FROM ASI_CRM_Contract_Cost__c
            WHERE ASI_CRM_CN_Contract__c = :V0ContractId and ASI_CRM_CN_Cost_Type__c='Fixed'];
        }catch(exception e){
            system.debug('Try v0_EstCostList failed: ' + e);
        }


        if (v0_EstCostList.size() > 0){
            for (ASI_CRM_Contract_Cost__c V0ContractCost : v0_EstCostList){
                FixCostAmount += V0ContractCost.ASI_CRM_CN_Contract_Amount__c!=null?V0ContractCost.ASI_CRM_CN_Contract_Amount__c:0;
            }
        }
        return FixCostAmount;
    }



    //generate V0.0 Contract Id
    public String GenerateV0ContractId(){
        string V0ContractId='';
        if(thisPR.ASI_TH_CRM_Contract__c!=null && thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c;
        }else if(thisPR.ASI_TH_CRM_Contract__c!=null){
            V0ContractId=thisPR.ASI_TH_CRM_Contract__c;
        }
        return V0ContractId;
    }




    //Generate CR12 Factor Mapping table : Sub-Brand Id, CR12 Factor 
    private Map<String,Decimal> GenerateCR12FactorMap(Set<String> SBIdSet){
        Map<String,Decimal> CR12FactorMap = new Map<String,Decimal> ();
        for(ASI_MFM_Sub_brand__c SubBrand: [select Id,ASI_CRM_CN_COnvfactor_Ltocr12_C__c,(select id,ASI_CRM_CR12_Conversion_Factor__c,ASI_CRM_Commercial_Team__c,ASI_CRM_CN_Region__c from ASI_CRM_CR12_Factors__r) from ASI_MFM_Sub_brand__c  where id in : SBIdSet ]){
            Decimal CR12Factor=1;
            Boolean FoundFactor = false;
            for(ASI_CRM_Sub_Brand_Line__c SubBrandLine: SubBrand.ASI_CRM_CR12_Factors__r){
                if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c !=null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c !=null && SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c !=null &&  SubBrandLine.ASI_CRM_Commercial_Team__c == ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c && SubBrandLine.ASI_CRM_CN_Region__c == ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c ){
                    CR12Factor=SubBrandLine.ASI_CRM_CR12_Conversion_Factor__c;
                    FoundFactor=true;
                }
            }
            if(!FoundFactor && SubBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c!=NULL ){
                CR12Factor=SubBrand.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                FoundFactor=true;
            }
            if(FoundFactor){
                CR12FactorMap.put(SubBrand.Id, CR12Factor);
            }
        }
        return CR12FactorMap;
    }


    public String NameSortingASC(decimal strSeq){
        if(strSeq==0){
            strSeq=9;
        }
        string returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = string.valueof(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString =  string.valueof(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString =  string.valueof(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = string.valueof(strSeq);
            }
        }else{
            returnString = '0';
        }
        return returnString;
    }


    public map<date, decimal> checkFYDayPeriod(date startDate, date endDate){
        map<date, decimal> returnDateMap = new map<date, decimal>();
        Integer EndFY;
        Integer StartFY;
        date returnDate;
        date tempDate = startDate;
        if (startDate != null && endDate != null){
            if (startDate.Month() > 6 && startDate.Month() < 13){
                StartFY = startDate.Year() + 1;
            }
            if (startDate.Month() < 7 && startDate.Month() > 0){
                StartFY = startDate.Year();
            }
            if (endDate.Month() > 6 && endDate.Month() < 13){
                EndFY = endDate.Year() + 1;
            }
            if (endDate.Month() < 7 && endDate.Month() > 0){
                EndFY = endDate.Year();
            }
            integer strPeriod = EndFY - StartFY + 1;
            integer strtemp = 0;
            if (strPeriod >= 0){
                for (integer i=0; i<strPeriod; i++){
                    returnDate = Date.newinstance(StartFY,6,30);
                    if (returnDate <= startDate){
                        strtemp = MonthDiff(returnDate, startDate);
                        //system.debug('returnDate <= startDate: ' + returnDate + ' - ' + startDate);
                    }else if (returnDate > startDate && returnDate < endDate){
                        strtemp = MonthDiff(tempDate, returnDate);
                        //system.debug('(returnDate > startDate && returnDate < endDate): ' + tempDate + ' - ' + returnDate);
                    }else if (returnDate >= endDate){
                        strtemp = MonthDiff(tempDate, endDate);
                        //system.debug('returnDate >= endDate: ' + endDate + ' - ' + returnDate);
                    }else if (returnDate >= startDate && returnDate >= endDate){
                        strtemp = MonthDiff(startDate, returnDate);
                        //system.debug('returnDate >= startDate && returnDate >= endDate: ' + startDate + ' - ' + returnDate);
                    }
                    returnDateMap.put(returnDate, decimal.valueof(strtemp));
                    tempDate = Date.newinstance(StartFY,7,1);
                    //system.debug('tempDate: ' + tempDate );
                    StartFY++;
                }
            }
            return returnDateMap;
        }else{
            return null;
        }
    }

    public static integer MonthDiff(date startDate, date endDate){
        Integer monthDiff;
        if (startDate != null && endDate != null){
            monthDiff = ((endDate.YEAR() - startDate.YEAR() - 1) *12) + (12 - startDate.MONTH() +1) + endDate.MONTH();
            return monthDiff;
        }else{
            return null;
        }
    }



    //*******************************************************************************************************
    //* @description custom class for Line Detail
    // ********************************************************************************************************
    public Class interimData{
        public ASI_CRM_Module__c Module {set;get;}
        public String MethodologyValue  {set;get;}
        public map<String, ASI_TH_CRM_PaymentRequestLineItem__c> DetailLineMap{set;get;}
        public Decimal TotalIntake {set;get;}{TotalIntake=0;}
        public Decimal TotalBC {set;get;}{TotalBC=0;}
        public Decimal BCRate {set;get;}{BCRate=0;}

        public interimData(){
            Module=new ASI_CRM_Module__c();
            MethodologyValue='';
            DetailLineMap= new map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        }

        public interimData( ASI_CRM_Module__c ModuleInput){
            Module=ModuleInput;
            MethodologyValue=ModuleInput.ASI_CRM_Methodology__r.Name;
            DetailLineMap= new map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();
        }

        public interimData( ASI_CRM_Module__c ModuleInput,boolean ClickRefresh){
            Module=ModuleInput;
            MethodologyValue=ModuleInput.ASI_CRM_Methodology__r.Name;
            DetailLineMap= new map<String, ASI_TH_CRM_PaymentRequestLineItem__c>();

        }
    }

    public static String UserOrGroupInit() {
        String groupAName = 'ASI_CN_GS_Commercial_team';
        String groupBName = 'ASI_CN_Commercial_team_ex_GS';
        String groupCName = 'ASI_CN_Finance';
        String groupDName = 'ASI_CN_HQ_Management';

        String belongGroup = 'Group ';

        Set<String> groupNames = new Set<String>();
        for (GroupMember gm: [SELECT group.name,
                                     group.DeveloperName
                              FROM GroupMember
                              WHERE UserOrGroupId =: UserInfo.getUserId()]) {
            groupNames.add(gm.group.DeveloperName);
        }
        if (groupNames.contains(groupAName)) {
            belongGroup += 'A';
        }
        if (groupNames.contains(groupBName)) {
            belongGroup += 'B';
        }
        if (groupNames.contains(groupCName)) {
            belongGroup += 'C';
        }
        if (groupNames.contains(groupDName)) {
            belongGroup += 'D';
        }
        return belongGroup;
    }
    
    public Class VolumeObject{
        //V0.0 Full Contract Target/合同销量目标

        public Decimal FullContractTarget {set;get;}{FullContractTarget=0;}
        //Actual Performance
        public Decimal CTDActualVol {set;get;}{CTDActualVol=0;}
        public String SubBrandGradeName {set;get;}{SubBrandGradeName='';}
        public String SubBrandGradeCNName {set;get;}{SubBrandGradeCNName='';}
        public String CategoryName {set;get;}{CategoryName='';}
        public VolumeObject(){

        }
    }
}