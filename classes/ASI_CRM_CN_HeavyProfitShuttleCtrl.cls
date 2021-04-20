/**
 * @File Name          : ASI_CRM_CN_HeavyProfitShuttleCtrl.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 4/15/2020, 12:16:06 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    4/12/2020   pengchen@bluelinksys.com     Initial Version
**/
public with sharing class ASI_CRM_CN_HeavyProfitShuttleCtrl {
    public String PageId {set;get;}
    public ASI_TH_CRM_Contract__c thisCC {set;get;}
    public string strPDF {set;get;}
    public boolean AdorAbove {set;get;}

    public boolean IsEmail  {set;get;}{IsEmail=false;}
    public String IsEmailStr  {set;get;}{IsEmailStr='0';} 

    public String groupStr {get;set;}

    public List<CategoryName> nameList {get;set;}

    //Date to the String 
    public string thisCCStart {set;get;}
    public string thisCCEnd {set;get;}
    public string previousCCStart {set;get;}
    public string previousCCEnd {set;get;}
    public string PreviousCCSalesRep {set;get;} {PreviousCCSalesRep='';}

    public Decimal TotalHistoricalBottles {get;set;}
    public Decimal TotalEstimateBottles {get;set;}
    public Decimal TotalContractBottles {get;set;}

    public Decimal AllHistoricalTotalFees {get;set;}
    public Decimal AllEstimateTotalFees {get;set;}
    public Decimal AllContractTotalFees {get;set;}

    public List<SubbrandVolume> subbrandList {get;set;}
    public Boolean Ishave999 {get;set;} {Ishave999 = false;}

    public Map<String,String> subbrandNameMap {get;set;}


    public boolean showCN {set;get;}

    //get Contract Approval Comments
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}{lstApprovalComment= new List<ASI_CRM_Approval_Comment__c> ();}
    public String ApprovalComment {set;get;}


    public Map<String, String> sbGroup_map2nd {set;get;} //{sbGroup_map2nd = ASI_CRM_CN_HeavyContractUtilitiesClass.SUB_BRAND_CATEGORY_GROUPING_MAP2ND;}
    public Map<String, String> sbGroup_map {set;get;} {sbGroup_map = ASI_CRM_CN_HeavyContractUtilitiesClass.SUB_BRAND_GRADE_GROUPING_MAP;}

    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = initPage();} return dummyVar; } set; }
    public Boolean ExistHistoricalData {set;get;} {ExistHistoricalData=true;}
    public ASI_CRM_Module__c BRSFModule {set;get;} {BRSFModule = new ASI_CRM_Module__c();}
    public List<ASI_CRM_Module__c> PSFModuleList {set;get;} {PSFModuleList = new List<ASI_CRM_Module__c>();}

    public map<String, ASI_CRM_Module__c> PSF_Item_Map {set;get;} {PSF_Item_Map= new map<String, ASI_CRM_Module__c>();}


    public ASI_CRM_Module__c VECModule {set;get;} {VECModule = new ASI_CRM_Module__c();}

    public Boolean displayBRSF {set;get;} {displayBRSF=false;}
    public Boolean displayVEC {set;get;} {displayVEC=false;}

    public boolean ShowPSF_VXTable {set;get;} {ShowPSF_VXTable=false;}
    public boolean ShowVEC_VXTable {set;get;} {ShowVEC_VXTable=false;}
    public boolean ShowFixCostable {set;get;} {ShowFixCostable=false;}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalV00Contract2nd  {set;get;} { HistoricalV00Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalVFinalContract2nd  {set;get;} { HistoricalVFinalContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0Estimate2nd {set;get;} { NewContractV0Estimate2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContactV0Contract2nd  {set;get;} { NewContactV0Contract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HistoricalContractCompared2nd  {set;get;} { HistoricalContractCompared2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd HVfinalComparedContract2nd  {set;get;} { HVfinalComparedContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalV00Contract  {set;get;} { HistoricalV00Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalVFinalContract  {set;get;} { HistoricalVFinalContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContractV0Estimate {set;get;} { NewContractV0Estimate = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HistoricalContractCompared  {set;get;} { HistoricalContractCompared = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator HVfinalComparedContract  {set;get;} { HVfinalComparedContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}

    public Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine> SubBrandContractMap  {set;get;}  { SubBrandContractMap = new Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine> ();}

    public Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine> FixExpense_Map  {set;get;}  { FixExpense_Map = new Map<String,ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine> ();}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine PSFDetailTotal {set;get;} {PSFDetailTotal = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();}

    public ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine VECDetailTotal {set;get;} {VECDetailTotal = new ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine();}

    public Decimal HistoricalPSFEstTotal {set;get;}  {HistoricalPSFEstTotal=0;}
    public Decimal HistoricalVECEstTotal {set;get;}  {HistoricalVECEstTotal=0;}

    public Decimal HistoricalVEAdjustment{set;get;}  {HistoricalVEAdjustment=0;} // HistoricalVariableExpenseAdjustment
    public Decimal EstimateVEAdjustment{set;get;}  {EstimateVEAdjustment=0;}
    public Decimal ContractVEAdjustment{set;get;}  {ContractVEAdjustment=0;}

    //HTML
    public string td_end {set;get;}
    public String ExistHistoricalDataTD {set;get;}
    public String ExistHisDataTD_dotted {set;get;}

    public String ExistHistoricalData1 {set;get;}
    public String ExistHistoricalData2 {set;get;}
    public String ExistHisDataTD_noBottom {set;get;}

    public String MainTableHeader1 {set;get;}
    public String MainTableHeader2 {set;get;}

    public String ExistHisDataTD_dottednoBottom {set;get;}
    public String MainTableHeader3 {set;get;}
    public String MainTableHeader4 {set;get;}
    public String MainTableHeaderdotted {set;get;}
    public String ExistHisDataTD_TradeExpenses {set;get;}

    Public Boolean ShowAchievementRecognition  {set;get;}  {ShowAchievementRecognition=false;}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ActualPerformance2nd  {set;get;} { ActualPerformance2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();}
    public ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ActualPerformance  {set;get;} { ActualPerformance = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();}
    
    /*
    First key is Sub-brand Id, second key is either historical, estimate or contract.
    Value is the tradeExpenseBreakdown2nd object
     */
    public Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>> investmentBySubBrandByContractBySubBrand2nd { set; get; } {
        investmentBySubBrandByContractBySubBrand2nd = new Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd>>{
        };
    }

    public Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown>> investmentBySubBrandByContractBySubBrand { set; get; } {
        investmentBySubBrandByContractBySubBrand = new Map<String, Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown>>{
        };
    }
    public String selectedSubBrandDescription {set;get;} {selectedSubBrandDescription = ASI_CRM_CN_HeavyContractUtilitiesClass.getSelectedSubBrandDescription();}

    public ASI_CRM_CN_HeavyProfitShuttleCtrl(){}

    public ASI_CRM_CN_HeavyProfitShuttleCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
        // if (String.isNotBlank(PageId)) {
        //     thisCC = ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(PageId);
        //     if (dummyVar != true) {
        //         if (thisCC.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
        //             dummyVar = init2nd();
        //         } else {
        //             dummyVar = init();
        //         }
        //     }
        // }

    }

    public boolean initPage() {
        if (String.isNotBlank(PageId)) {
            thisCC = ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(PageId);
            if (thisCC.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                return init2nd();
            } else {
                return init();
            }
        }
        return true;
    }


    public boolean init2nd(){

        // groupStr = ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.UserOrGroupInit();
        System.debug(LoggingLevel.INFO, '*** groupStr: ' + groupStr);
        showCN = USerInfo.getLanguage()=='zh_CN';

        td_end = '</td>';
        ExistHistoricalDataTD ='<td style=" border-right: 1px solid black; border-bottom: 1px solid black; " align="right">';
        ExistHisDataTD_noBottom ='<td style=" border-right: 1px solid black;" align="right">';

        ExistHisDataTD_dotted ='<td style="border-bottom: 1px solid black; border-right: 1px dotted gray;" align="right">';
        ExistHisDataTD_dottednoBottom ='<td style=" border-right: 1px dotted gray;" align="right">';

        ExistHistoricalData1='<td colspan="3" style=" border-right: 1px solid black; border-bottom: 1px solid black;" align="center">Historical Contract<br/>历史合同</td> <td colspan="3" style="border-right: 1px solid black; border-bottom: 1px solid black;" align="center">New Contract<br/>新合同</td>';
        ExistHistoricalData2='<td colspan="2" style="border-right: 1px solid black; border-bottom: 1px solid black;" align="center">New Contract<br/>新合同</td>';

        MainTableHeader1='<td colspan="7" bgcolor="#99CCFF" style="border:1px solid black;border-bottom: 1px solid black;" align="center" ><strong>P&L REVIEW (in RMB) 利润分析表 （元）</strong></td>';
        MainTableHeader2='<td colspan="3" bgcolor="#99CCFF" style="border:1px solid black;border-bottom: 1px solid black;" align="center" ><strong>P&L REVIEW (in RMB) 利润分析表 （元）</strong></td>';
        MainTableHeader3='<td style=" border-right: 1px solid black; border-bottom: 1px solid black;" align="center">';
        MainTableHeaderdotted='<td style=" border-right: 1px dotted gray; border-bottom: 1px solid black;" align="center">';

        ExistHisDataTD_TradeExpenses='<td style=" border-bottom: 1px solid black; border-right: 1px dotted gray;" align="right"  bgcolor="#E3DFDA">';

        IsEmail = IsEmailStr == '1' ? true : false;
        map<integer, string> MonthMapping = new map<integer, string>();
        MonthMapping.put(1,'Jan');
        MonthMapping.put(2,'Feb');
        MonthMapping.put(3,'Mar');
        MonthMapping.put(4,'Apr');
        MonthMapping.put(5,'May');
        MonthMapping.put(6,'Jun');
        MonthMapping.put(7,'Jul');
        MonthMapping.put(8,'Aug');
        MonthMapping.put(9,'Sept');
        MonthMapping.put(10,'Oct');
        MonthMapping.put(11,'Nov');
        MonthMapping.put(12,'Dec');


        if (PageId != null){
            HistoricalContractCompared2nd= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();
            try{
                // thisCC = ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(PageId);

                if (thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
                    if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH()))
                        thisCCStart = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
                }else
                    thisCCStart = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + (thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH();

                if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
                    if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH()))
                        thisCCEnd = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
                }else
                    thisCCEnd = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + (thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH();



                if(thisCC.ASI_CRM_CN_Vol_Budget_LE__c==null){
                    thisCC.ASI_CRM_CN_Vol_Budget_LE__c=0;
                }
                if(thisCC.ASI_CRM_CN_Budget_LE__c==null){
                    thisCC.ASI_CRM_CN_Budget_LE__c=0;
                }
                lstApprovalComment = [SELECT id, recordtypeid, ASI_CRM_BA_comments__c, ASI_CRM_Background_Objective__c, ASI_CRM_New_contract_Analsysis__c, ASI_CRM_Historical_Contract_Performance__c FROM ASI_CRM_Approval_Comment__c
                WHERE ASI_CRM_Contract__c =:thisCC.id];


                if(lstApprovalComment==null || lstApprovalComment.size()==0){
                    ApprovalComment ='';
                    lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
                }
                else{
                    lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
                    for(ASI_CRM_Approval_Comment__c ac : lstApprovalComment){
                        if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')){
                            ApprovalComment = 'new';
                            lstApprovalComment[0] = ac;
                        }
                        else if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')){
                            ApprovalComment = 'po';
                            lstApprovalComment[0] = ac;
                            break;
                        }

                    }
                }


            }catch(exception e){
                String msg = 'Save Error : ' +e.getMessage() + '</br>';
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyProfitShuttleCtrl in init class have Error  '+msg,'ASI_CRM_CN_HeavyProfitShuttleCtrl','PDF function failed! with contract Id: '+PageId );
            }

        }
        System.debug(LoggingLevel.INFO, '*** strPDF: ' + strPDF);
        if (strPDF == '1'){
            groupStr = ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.UserOrGroupInit();
        } else if (strPDF == '0'){
            set<Id> userIds = new set<Id>();
            for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : thisCC.id]){
                userIds.add(piw.ActorId);
            }
            groupStr = checkApprover2nd(userIds);
            // checkApprover();
        } else if (strPDF == '2'){
            set<Id> userIds = new set<Id>();
            userIds.add(thisCC.OwnerId);
            groupStr = checkApprover2nd(userIds);
        }
        else if (strPDF == '3'){// check last RBA
            if(thisCC.ASI_CRM_Last_RBA_Approver__c!=null){
                // checkLastRBAID();
                groupStr = checkLastRBAID2nd();
            }else{
                groupStr = ASI_CRM_CN_Heavy_PRForm_Cmpnt_Ctrl.UserOrGroupInit();
            }
        }


        //Geting HistoricalV0.0 and VFinal Data
        //
        
         List<ASI_Attachment__c> AttachmentList = [SELECT Id,
                                                          ASI_CRM_Historical_Financial_Data__c,
                                                          ASI_CRM_Historical_Financial_Data2__c,
                                                          ASI_CRM_Historical_Financial_Data3__c,
                                                          ASI_CRM_Historical_Financial_Data4__c,
                                                          ASI_CRM_Contract__c,
                                                          ASI_CRM_Type__c 
                                                   FROM ASI_Attachment__c 
                                                   WHERE ASI_CRM_Contract__c = :thisCC.Id];
        if(AttachmentList.size()<=0 && AttachmentList.isEmpty()) {
            if (thisCC.ASI_CRM_CN_V0_0_PO_version__c != null) {
               AttachmentList = [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Historical_Financial_Data2__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :thisCC.ASI_CRM_CN_V0_0_PO_version__c];
            }
        }  
        
        //List<ASI_Attachment__c> AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c where ASI_CRM_Contract__c = :thisCC.Id ];
        if(AttachmentList.size() > 0 && !AttachmentList.isEmpty()) {
            for(ASI_Attachment__c att:AttachmentList){
                if(att.ASI_CRM_Type__c=='Historical Data'){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&quot;','"'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&quot;','"'):'');
                    // System.debug(LoggingLevel.INFO, '*** : JsonString' + JsonString);
                    // JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);

                    if(HistoricalContractList.size()>0){
                        HistoricalV00Contract2nd= DataRounding2nd(HistoricalContractList[0]);
                        HistoricalVFinalContract2nd = DataRounding2nd(HistoricalContractList[1]);
                        if(HistoricalVFinalContract2nd.AddOnString!=''){    
                            Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(HistoricalVFinalContract2nd.AddOnString,Map<String,Decimal>.class);
                            if( TempMap.containsKey('PSFEstTotal')  ){
                                HistoricalPSFEstTotal= TempMap.get('PSFEstTotal');
                            }    
                            if( TempMap.containsKey('VECEstTotal')  ){
                                HistoricalVECEstTotal= TempMap.get('VECEstTotal');
                            }
                        }
                    }
                } else if(att.ASI_CRM_Type__c=='Last Payment Data'){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&lt;','<'):'');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);
                    if(ContractList.size()>0){
                        ActualPerformance2nd = ContractList[0];
                    }
                } else if(att.ASI_CRM_Type__c=='Contract Data'){
                    String JsonString = (att.ASI_CRM_Historical_Financial_Data__c != null?att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data2__c != null?att.ASI_CRM_Historical_Financial_Data2__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data3__c != null?att.ASI_CRM_Historical_Financial_Data3__c.replaceAll('&lt;','<'):'')
                                        +(att.ASI_CRM_Historical_Financial_Data4__c != null?att.ASI_CRM_Historical_Financial_Data4__c.replaceAll('&lt;','<'):'');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    // System.debug(LoggingLevel.INFO, '*** : JsonString' + JsonString);
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>.class);

                    if(ContractList.size()>0){
                        NewContractV0Estimate2nd = DataRounding2nd(ContractList[0]);
                        NewContactV0Contract2nd= DataRounding2nd(ContractList[1]);
                    }
                }    
            }
        }


        String BRSFDefaultMethodology='';
        String PSFDefaultMethodology='';
        String VECDefaultMethodology='';



        ASI_CRM_Methodology__c BRSFMethodology_Default= new ASI_CRM_Methodology__c();
        ASI_CRM_Methodology__c PSFMethodology_Default=new ASI_CRM_Methodology__c();
        ASI_CRM_Methodology__c VECMethodology_Default=new ASI_CRM_Methodology__c();


        for(ASI_CRM_Methodology__c meth: [Select Id,Name,ASI_CRM_Sequence__c,ASI_CRM_Type__c,ASI_CRM_Default__c,RecordType.DeveloperName
        from ASI_CRM_Methodology__c where RecordType.DeveloperName like 'ASI_CRM_CN%' AND ASI_CRM_Default__c =TRUE ])
        {
            if(meth.ASI_CRM_Type__c=='BRSF'){
                BRSFDefaultMethodology=meth.Id;
                BRSFMethodology_Default=meth;
            }
            if(meth.ASI_CRM_Type__c=='PSF'){
                PSFDefaultMethodology=meth.Id;
                PSFMethodology_Default=meth;
            }
            if(meth.ASI_CRM_Type__c=='Variable Event Cost'){
                VECDefaultMethodology=meth.Id;
                VECMethodology_Default=meth;
            }
        }

        //system.assertEquals(PSFDefaultMethodology, 'Tony Testing');
        Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>(); // Map <Id, ASI_CRM_Module__c>


        //If contract version = v0.0
        if(thisCC.ASI_CRM_CN_Status__c!='Archived'){
            for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Is_Default_Methodology__c,ASI_CRM_Remark_Display__c,ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c from ASI_CRM_Module__c
            where ASI_CRM_Contract__c =:pageId ])
            {
                ModuleMap.put(Module.Id,Module);
            }
        }else{//contract version != v0.0
            for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Is_Default_Methodology__c,ASI_CRM_Remark_Display__c,ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c from ASI_CRM_Module__c
            where ASI_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c =:pageId ])
            {
                ModuleMap.put(Module.Id,Module);
            }
        }

        displayBRSF=false;
        displayVEC=false;

        Set<Id> PSFIdSet= new Set<Id>();
        PSF_Item_Map= new map<String, ASI_CRM_Module__c>();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:[SELECT Id, ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c ,ASI_CRM_Max_Incentive__c,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c, ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,  ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :PageId] )
        {

            if(ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                if(BRSFLine.ASI_CRM_Type__c=='BRSF'){
                    BRSFModule=ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                    if(BRSFMethodology_Default.Id ==BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c || BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c<BRSFMethodology_Default.ASI_CRM_Sequence__c){
                        BRSFModule.ASI_CRM_Is_Default_Methodology__c=true;
                        displayBRSF=true;
                    }
                    if(thisCC.ASI_CRM_CN_Group_Contract__c!=null){
                        BRSFModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }
                }

                if(BRSFLine.ASI_CRM_Type__c=='PSF' && !PSFIdSet.contains(BRSFLine.ASI_CRM_Module__c)){
                    ASI_CRM_Module__c TempModule =ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                    if( (PSFMethodology_Default.Id ==BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c || BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c<PSFMethodology_Default.ASI_CRM_Sequence__c ) && (BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand' || BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Grade')){
                        TempModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }
                    if(thisCC.ASI_CRM_CN_Group_Contract__c!=null){
                        TempModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }

                    PSFModuleList.add(TempModule);
                    PSFIdSet.add(BRSFLine.ASI_CRM_Module__c);

                    if(!PSF_Item_Map.containsKey(BRSFLine.ASI_CRM_Module__c)){
                        PSF_Item_Map.put(BRSFLine.ASI_CRM_Module__c, TempModule);
                    }
                }
                IF(BRSFLine.ASI_CRM_Type__c=='PSF'){
                    PSFDetailTotal.ContractTotalFees +=BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    PSFDetailTotal.EstimateTotalFees+=BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

                }
                if(BRSFLine.ASI_CRM_Type__c=='Variable Event Cost'){
                    displayVEC=true;
                    VECModule=ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                    if( VECDefaultMethodology ==BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c ||  BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c<VECMethodology_Default.ASI_CRM_Sequence__c ){
                        VECModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }
                    if(thisCC.ASI_CRM_CN_Group_Contract__c!=null){
                        VECModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }

                    VECDetailTotal.ContractTotalFees +=BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    VECDetailTotal.EstimateTotalFees+=BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

                }


            }
        }
        DataFixing2nd(MonthMapping);

        // System.debug(LoggingLevel.INFO, '*** HistoricalVFinalContract2nd: ' + JSON.serialize(HistoricalVFinalContract2nd));

        // System.debug(LoggingLevel.INFO, '*** HistoricalV00Contract2nd: ' + JSON.serialize(HistoricalV00Contract2nd));
        // System.debug(LoggingLevel.INFO, '*** : investmentBySubBrandByContractBySubBrand2nd' + investmentBySubBrandByContractBySubBrand2nd);
        // System.debug(LoggingLevel.INFO, '*** AdorAbove: ' + AdorAbove);
        // System.debug(LoggingLevel.INFO, '*** IsEmail: ' + IsEmail);
        return true;
    }

    public boolean init(){
        showCN = USerInfo.getLanguage()=='zh_CN';

        td_end = '</td>';
        ExistHistoricalDataTD ='<td style=" border-right: 1px solid black; border-bottom: 1px solid black; " align="right">';
        ExistHisDataTD_noBottom ='<td style=" border-right: 1px solid black;" align="right">';

        ExistHisDataTD_dotted ='<td style="border-bottom: 1px solid black; border-right: 1px dotted gray;" align="right">';
        ExistHisDataTD_dottednoBottom ='<td style=" border-right: 1px dotted gray;" align="right">';

        ExistHistoricalData1='<td colspan="3" style=" border-right: 1px solid black; border-bottom: 1px solid black;white-space: pre;" align="center">Historical Contract<br/>历史合同</td> <td colspan="3" style="border-right: 1px solid black; border-bottom: 1px solid black;white-space: pre;" align="center">New Contract<br/>新合同</td>';
        ExistHistoricalData2='<td colspan="2" style="border-right: 1px solid black; border-bottom: 1px solid black;white-space: pre;" align="center">New Contract<br/>新合同</td>';

        MainTableHeader1='<td colspan="9" bgcolor="#99CCFF" style="border:1px solid black;" align="center" ><strong>P&L REVIEW (in RMB) 利润分析表 （元）</strong></td>';
        MainTableHeader2='<td colspan="5" bgcolor="#99CCFF" style="border:1px solid black;" align="center" ><strong>P&L REVIEW (in RMB) 利润分析表 （元）</strong></td>';
        MainTableHeader3='<td style=" border-right: 1px solid black; border-bottom: 1px solid black;white-space: pre;" align="center">';
        MainTableHeaderdotted='<td style=" border-right: 1px dotted gray; border-bottom: 1px solid black;white-space: pre;" align="center">';

        ExistHisDataTD_TradeExpenses='<td style=" border-bottom: 1px solid black; border-right: 1px dotted gray;" align="right"  bgcolor="#E3DFDA">';

        IsEmail = IsEmailStr == '1' ? true : false;
        map<integer, string> MonthMapping = new map<integer, string>();
        MonthMapping.put(1,'Jan');
        MonthMapping.put(2,'Feb');
        MonthMapping.put(3,'Mar');
        MonthMapping.put(4,'Apr');
        MonthMapping.put(5,'May');
        MonthMapping.put(6,'Jun');
        MonthMapping.put(7,'Jul');
        MonthMapping.put(8,'Aug');
        MonthMapping.put(9,'Sept');
        MonthMapping.put(10,'Oct');
        MonthMapping.put(11,'Nov');
        MonthMapping.put(12,'Dec');


        if (PageId != null){
            HistoricalContractCompared= new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();
            try{
                // thisCC = ASI_CRM_CN_HeavyContractUtilitiesClass.getContract(PageId);

                if (thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
                    if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH()))
                        thisCCStart = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
                }else
                    thisCCStart = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + (thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH();

                if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
                    if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH()))
                        thisCCEnd = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
                }else
                    thisCCEnd = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + (thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH();



                if(thisCC.ASI_CRM_CN_Vol_Budget_LE__c==null){
                    thisCC.ASI_CRM_CN_Vol_Budget_LE__c=0;
                }
                if(thisCC.ASI_CRM_CN_Budget_LE__c==null){
                    thisCC.ASI_CRM_CN_Budget_LE__c=0;
                }
                lstApprovalComment = [SELECT id, recordtypeid, ASI_CRM_BA_comments__c, ASI_CRM_Background_Objective__c, ASI_CRM_New_contract_Analsysis__c, ASI_CRM_Historical_Contract_Performance__c FROM ASI_CRM_Approval_Comment__c
                WHERE ASI_CRM_Contract__c =:thisCC.id];


                if(lstApprovalComment==null || lstApprovalComment.size()==0){
                    ApprovalComment ='';
                    lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
                }
                else{
                    lstApprovalComment = ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
                    for(ASI_CRM_Approval_Comment__c ac : lstApprovalComment){
                        if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_New_Contract_Comment')){
                            ApprovalComment = 'new';
                            lstApprovalComment[0] = ac;
                        }
                        else if(ac.recordtypeid == Global_RecordTypeCache.getRTId('ASI_CRM_Approval_Comment__cASI_CRM_CN_PO_Contract_Comment')){
                            ApprovalComment = 'po';
                            lstApprovalComment[0] = ac;
                            break;
                        }

                    }
                }


            }catch(exception e){
                String msg = 'Save Error : ' +e.getMessage() + '</br>';
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyProfitShuttleCtrl in init class have Error  '+msg,'ASI_CRM_CN_HeavyProfitShuttleCtrl','PDF function failed! with contract Id: '+PageId );
            }

        }
        if (strPDF == '1'){
            checkUserID();
        }

        if (strPDF == '0'){
            checkApprover();
        }
        if (strPDF == '3'){// check last RBA
            if(thisCC.ASI_CRM_Last_RBA_Approver__c!=null){
                checkLastRBAID();
            }else{
                checkUserID();
            }
        }


        //Geting HistoricalV0.0 and VFinal Data
        //
        
         List<ASI_Attachment__c> AttachmentList = [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :thisCC.Id];
        if(AttachmentList.size()<=0 && AttachmentList.isEmpty()) {
            if (thisCC.ASI_CRM_CN_V0_0_PO_version__c != null) {
               AttachmentList = [SELECT Id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c FROM ASI_Attachment__c WHERE ASI_CRM_Contract__c = :thisCC.ASI_CRM_CN_V0_0_PO_version__c];
            }
        }  
        
        //List<ASI_Attachment__c> AttachmentList= [select id,ASI_CRM_Historical_Financial_Data__c,ASI_CRM_Contract__c,ASI_CRM_Type__c from ASI_Attachment__c where ASI_CRM_Contract__c = :thisCC.Id ];
        if(AttachmentList.size() > 0 && !AttachmentList.isEmpty()) {
            for(ASI_Attachment__c att:AttachmentList){
                if(att.ASI_CRM_Type__c=='Historical Data'){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');//    
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                    system.debug('===============>JsonString'+JsonString);
                    system.debug('================>'+List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                    if(HistoricalContractList.size()>0){
                        HistoricalV00Contract= DataRounding(HistoricalContractList[0]);
                        system.debug('HistoricalV00Contract'+HistoricalV00Contract);
                        HistoricalVFinalContract= DataRounding(HistoricalContractList[1]);
                        system.debug('HistoricalVFinalContract'+HistoricalVFinalContract);
                        if(HistoricalVFinalContract.AddOnString!=''){    
                            Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(HistoricalVFinalContract.AddOnString,Map<String,Decimal>.class);
                            if( TempMap.containsKey('PSFEstTotal')  ){
                                HistoricalPSFEstTotal= TempMap.get('PSFEstTotal');
                            }    
                            if( TempMap.containsKey('VECEstTotal')  ){
                                HistoricalVECEstTotal= TempMap.get('VECEstTotal');
                            }
                        }
                    }
                } else if(att.ASI_CRM_Type__c=='Last Payment Data'){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        ActualPerformance = ContractList[0];
                    }
                } else if(att.ASI_CRM_Type__c=='Contract Data'){
                    String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<');
                    JsonString = JsonString.replaceAll('&quot;','"');
                    List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContractV0Estimate = DataRounding(ContractList[0]);
                        NewContactV0Contract= DataRounding(ContractList[1]);
                    }
                }    
            }
        }


        String BRSFDefaultMethodology='';
        String PSFDefaultMethodology='';
        String VECDefaultMethodology='';



        ASI_CRM_Methodology__c BRSFMethodology_Default= new ASI_CRM_Methodology__c();
        ASI_CRM_Methodology__c PSFMethodology_Default=new ASI_CRM_Methodology__c();
        ASI_CRM_Methodology__c VECMethodology_Default=new ASI_CRM_Methodology__c();


        for(ASI_CRM_Methodology__c meth: [Select Id,Name,ASI_CRM_Sequence__c,ASI_CRM_Type__c,ASI_CRM_Default__c,RecordType.DeveloperName
        from ASI_CRM_Methodology__c where RecordType.DeveloperName like 'ASI_CRM_CN%' AND ASI_CRM_Default__c =TRUE ])
        {
            if(meth.ASI_CRM_Type__c=='BRSF'){
                BRSFDefaultMethodology=meth.Id;
                BRSFMethodology_Default=meth;
            }
            if(meth.ASI_CRM_Type__c=='PSF'){
                PSFDefaultMethodology=meth.Id;
                PSFMethodology_Default=meth;
            }
            if(meth.ASI_CRM_Type__c=='Variable Event Cost'){
                VECDefaultMethodology=meth.Id;
                VECMethodology_Default=meth;
            }
        }

        //system.assertEquals(PSFDefaultMethodology, 'Tony Testing');
        Map<String,ASI_CRM_Module__c> ModuleMap= new Map<String,ASI_CRM_Module__c>(); // Map <Id, ASI_CRM_Module__c>


        //If contract version = v0.0
        if(thisCC.ASI_CRM_CN_Status__c!='Archived'){
            for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Is_Default_Methodology__c,ASI_CRM_Remark_Display__c,ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c from ASI_CRM_Module__c
            where ASI_CRM_Contract__c =:pageId ])
            {
                ModuleMap.put(Module.Id,Module);
            }
        }else{//contract version != v0.0
            for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Is_Default_Methodology__c,ASI_CRM_Remark_Display__c,ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c from ASI_CRM_Module__c
            where ASI_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c =:pageId ])
            {
                ModuleMap.put(Module.Id,Module);
            }
        }

        displayBRSF=false;
        displayVEC=false;

        Set<Id> PSFIdSet= new Set<Id>();
        PSF_Item_Map= new map<String, ASI_CRM_Module__c>();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:[SELECT Id, ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c ,ASI_CRM_Max_Incentive__c,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c, ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Est_Total_QTY_std_Btl__c,ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,ASI_CRM_Est_Total_QTY_CR12_Eqv__c,ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,  ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c , ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c, ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c, ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
        WHERE ASI_CRM_CN_Contract__c = :PageId] )
        {

            if(ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
                if(BRSFLine.ASI_CRM_Type__c=='BRSF'){
                    BRSFModule=ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                    if(BRSFMethodology_Default.Id ==BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c || BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c<BRSFMethodology_Default.ASI_CRM_Sequence__c){
                        BRSFModule.ASI_CRM_Is_Default_Methodology__c=true;
                        displayBRSF=true;
                    }
                    if(thisCC.ASI_CRM_CN_Group_Contract__c!=null){
                        BRSFModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }
                }

                if(BRSFLine.ASI_CRM_Type__c=='PSF' && !PSFIdSet.contains(BRSFLine.ASI_CRM_Module__c)){
                    ASI_CRM_Module__c TempModule =ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                    if( (PSFMethodology_Default.Id ==BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c || BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c<PSFMethodology_Default.ASI_CRM_Sequence__c ) && (BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Sub-Brand' || BRSFLine.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c=='By Grade')){
                        TempModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }
                    if(thisCC.ASI_CRM_CN_Group_Contract__c!=null){
                        TempModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }

                    PSFModuleList.add(TempModule);
                    PSFIdSet.add(BRSFLine.ASI_CRM_Module__c);

                    if(!PSF_Item_Map.containsKey(BRSFLine.ASI_CRM_Module__c)){
                        PSF_Item_Map.put(BRSFLine.ASI_CRM_Module__c, TempModule);
                    }
                }
                IF(BRSFLine.ASI_CRM_Type__c=='PSF'){
                    PSFDetailTotal.ContractTotalFees +=BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    PSFDetailTotal.EstimateTotalFees+=BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

                }
                if(BRSFLine.ASI_CRM_Type__c=='Variable Event Cost'){
                    displayVEC=true;
                    VECModule=ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                    if( VECDefaultMethodology ==BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__c ||  BRSFLine.ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c<VECMethodology_Default.ASI_CRM_Sequence__c ){
                        VECModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }
                    if(thisCC.ASI_CRM_CN_Group_Contract__c!=null){
                        VECModule.ASI_CRM_Is_Default_Methodology__c=true;
                    }

                    VECDetailTotal.ContractTotalFees +=BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    VECDetailTotal.EstimateTotalFees+=BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;

                }


            }
        }
        DataFixing(MonthMapping);

        return true;
    }


   @TestVisible
    private String SplitLineIntoRow(String InputString,integer CutNumber ){
        String outputString ='';

        //if there is not english Character and all of them are Chinese, then break lines
        if(InputString!=null){
            if(!ASI_CRM_CN_HeavyContracFunctionClass.containsEnglishCharacters(InputString) && ASI_CRM_CN_HeavyContracFunctionClass.containsChineseCharacters(InputString) ){
                try{
                    if(InputString.length() >= CutNumber ){
                        while(InputString.length() >= CutNumber ){
                            outputString = outputString + InputString.subString(0,CutNumber) + '<br/>';
                            InputString= InputString.subString(CutNumber);
                        }
                    }
                    outputString = outputString + InputString;
                }catch(exception e){
                    outputString =  InputString;
                }

            }else{
                outputString=InputString;
            }
        }

        return outputString;
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

    public void DataFixing2nd( map<integer, string> MonthMapping){
        sbGroup_map2nd = new Map<String, String>();

        List<String> englishNames = new List<String>();

        Map<String, ASI_HK_CRM_Product_Category__c> categoryMap = new Map<String, ASI_HK_CRM_Product_Category__c>();
        for(ASI_HK_CRM_Product_Category__c ProductCategory:[select Id,Name,ASI_CRM_CN_Chinese_Name__c,ASI_HK_CRM_English_Name__c,ASI_HK_CRM_Sequence__c from ASI_HK_CRM_Product_Category__c where RecordType.DeveloperName  ='ASI_CRM_CN_Product_Category'])
        {
            sbGroup_map2nd.put(ProductCategory.name , ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c);   
            categoryMap.put(ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c, ProductCategory);
            englishNames.add(ProductCategory.ASI_HK_CRM_English_Name__c + ProductCategory.ASI_CRM_CN_Chinese_Name__c);
        }

        englishNames.sort();


        nameList = new List<CategoryName>();
        for (String enName : englishNames) {
            if (categoryMap.containsKey(enName)) {
                CategoryName cn = new CategoryName();
                cn.Cname = categoryMap.get(enName).name;
                cn.CEnName = categoryMap.get(enName).ASI_HK_CRM_English_Name__c + categoryMap.get(enName).ASI_CRM_CN_Chinese_Name__c;
                nameList.add(cn);
            }
        }

        Set<String> removeSBGNameSet = new Set<String>();
        for(String SBGName: sbGroup_map2nd.keySet()){
            Boolean isHave = false;

            if(HistoricalV00Contract2nd.CategoryMap==null || !HistoricalV00Contract2nd.CategoryMap.containskey(SBGName)){
                HistoricalV00Contract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }

            if(HistoricalVFinalContract2nd.CategoryMap==null || !HistoricalVFinalContract2nd.CategoryMap.containskey(SBGName)){
                HistoricalVFinalContract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }

            if(NewContractV0Estimate2nd.CategoryMap==null || !NewContractV0Estimate2nd.CategoryMap.containskey(SBGName)){
                NewContractV0Estimate2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }
            if(NewContactV0Contract2nd.CategoryMap==null || !NewContactV0Contract2nd.CategoryMap.containskey(SBGName)){
                NewContactV0Contract2nd.CategoryMap.put(SBGName,0.0);
            }
            else {
                isHave=true;
            }

            if (!isHave) {
                removeSBGNameSet.add(SBGName);
                HistoricalV00Contract2nd.CategoryMap.remove(SBGName);
                HistoricalVFinalContract2nd.CategoryMap.remove(SBGName);
                NewContractV0Estimate2nd.CategoryMap.remove(SBGName);
                NewContactV0Contract2nd.CategoryMap.remove(SBGName);
            } 
            else {
                if(HistoricalContractCompared2nd.CategoryMap==null || !HistoricalContractCompared2nd.CategoryMap.containskey(SBGName)){
                    Decimal ComparedRate=0;
                    if(HistoricalV00Contract2nd.CategoryMap.get(SBGName)!=0){
                        ComparedRate=((HistoricalVFinalContract2nd.CategoryMap.get(SBGName)-HistoricalV00Contract2nd.CategoryMap.get(SBGName))*100)/HistoricalV00Contract2nd.CategoryMap.get(SBGName);
                    }
                    HistoricalContractCompared2nd.CategoryMap.put(SBGName,ComparedRate);
                }
            }

        }

        if (!removeSBGNameSet.isEmpty()) {
            for (String SBGName : removeSBGNameSet){
                sbGroup_map2nd.remove(SBGName);
                for (Integer i = nameList.size() - 1;i >= 0; i--) {
                    CategoryName cn = nameList.get(i);
                    if (SBGName == cn.Cname) {
                        nameList.remove(i);
                    }
                }
            }
        }

        SubBrandContractMap = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>(NewContactV0Contract2nd.ContractLineMap);
        for(String ContractLineKey:HistoricalVFinalContract2nd.ContractLineMap.keySet()){
            if(SubBrandContractMap.containsKey(ContractLineKey)){
                SubBrandContractMap.get(ContractLineKey).HistoricalBottles=HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey).HistoricalBottles;
                SubBrandContractMap.get(ContractLineKey).HistoricalFees = HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey).HistoricalFees;
                SubBrandContractMap.get(ContractLineKey).HistoricalTotalFees = HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey).HistoricalTotalFees;
            }else{
                SubBrandContractMap.put(ContractLineKey, HistoricalVFinalContract2nd.ContractLineMap.get(ContractLineKey));
            }
        }


        Decimal HistoricalTotalFees=0;
        Decimal Sum_EstimateTotalFees=0;
        Decimal Sum_ContractTotalFees=0;
        for(String SubBrandContractKey:SubBrandContractMap.keySet()){
            SubBrandContractMap.get(SubBrandContractKey).HistoricalFees=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalFees);
            SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles);

            if(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateBottles==0 && SubBrandContractMap.get(SubBrandContractKey).ContractBottles ==0 && SubBrandContractMap.get(SubBrandContractKey).HistoricalFees ==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateFees==0 && SubBrandContractMap.get(SubBrandContractKey).ContractFees ==0 && SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees==0){
                SubBrandContractMap.remove(SubBrandContractKey);
            }else{
                //Data Fixing
                integer intlength = SubBrandContractMap.get(SubBrandContractKey).SubBrandName.length();
                if(intlength >= 4 && SubBrandContractMap.get(SubBrandContractKey).SubBrandName.contains('-')){
                    SubBrandContractMap.get(SubBrandContractKey).strSubBrand =  SubBrandContractMap.get(SubBrandContractKey).SubBrandName.substring(0, (intlength-4));
                }
                if(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles!=null){
                    SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles = SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles.setScale(0, RoundingMode.HALF_UP);
                }
                //  if(SubBrandContractMap.get(SubBrandContractKey).HistoricalFees<1 && SubBrandContractMap.get(SubBrandContractKey).HistoricalFees>0){
                //    SubBrandContractMap.get(SubBrandContractKey).HistoricalFees=0;
                // }

                HistoricalTotalFees+=SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees;
                Sum_EstimateTotalFees +=SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees!=null?SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees:0;
                Sum_ContractTotalFees +=SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees!=null? SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees:0;
            }
        }
        HistoricalVEAdjustment= -(HistoricalVFinalContract2nd.VariableExpense-HistoricalPSFEstTotal-HistoricalVECEstTotal-HistoricalTotalFees);
        EstimateVEAdjustment=-(NewContractV0Estimate2nd.VariableExpense-PSFDetailTotal.EstimateTotalFees-VECDetailTotal.EstimateTotalFees-Sum_EstimateTotalFees);
        ContractVEAdjustment=-(NewContactV0Contract2nd.VariableExpense-PSFDetailTotal.ContractTotalFees-VECDetailTotal.ContractTotalFees-Sum_ContractTotalFees);
        if(HistoricalVEAdjustment!=0 || EstimateVEAdjustment!=0 && ContractVEAdjustment!=0){
            ShowAchievementRecognition=true;
        }

        if(HistoricalVECEstTotal!=0 || VECDetailTotal.EstimateTotalFees!=0 || VECDetailTotal.ContractTotalFees!=0 ){
            ShowVEC_VXTable=true;
        }

        if(HistoricalPSFEstTotal!=0 || PSFDetailTotal.EstimateTotalFees!=0 || PSFDetailTotal.ContractTotalFees!=0 ){
            ShowPSF_VXTable=true;
        }

        FixExpense_Map = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>(NewContactV0Contract2nd.FixedExpensesMap);
        for(String ContractLineKey:HistoricalVFinalContract2nd.FixedExpensesMap.keySet()){
            if(FixExpense_Map.containsKey(ContractLineKey)){
                FixExpense_Map.get(ContractLineKey).HistoricalFees =HistoricalVFinalContract2nd.FixedExpensesMap.get(ContractLineKey).HistoricalFees;
            }else{
                FixExpense_Map.put(ContractLineKey, HistoricalVFinalContract2nd.FixedExpensesMap.get(ContractLineKey));
            }
        }

        if(FixExpense_Map.size()>0){

            for(string FXMapKey:FixExpense_Map.keySet()){
                if(FixExpense_Map.get(FXMapKey).HistoricalFees==0 && FixExpense_Map.get(FXMapKey).EstimateFees==0 && FixExpense_Map.get(FXMapKey).ContractFees==0 ){
                    FixExpense_Map.remove(FXMapKey);
                }
            }
        }

        if(FixExpense_Map.size()>0){
            ShowFixCostable=true;
        }
        // System.debug(LoggingLevel.INFO, '*** JSON.serialize(NewContactV0Contract2nd): ' + JSON.serialize(NewContactV0Contract2nd));

        // System.debug(LoggingLevel.INFO, '*** JSON.serialize(NewContractV0Estimate2nd): ' + JSON.serialize(NewContractV0Estimate2nd));

        // System.debug(LoggingLevel.INFO, '*** JSON.serialize(HistoricalVFinalContract2nd): ' + JSON.serialize(HistoricalVFinalContract2nd));


        if(HistoricalVFinalContract2nd.ContractId !=null && HistoricalVFinalContract2nd.ContractId !=''){
            if (HistoricalVFinalContract2nd.POStartDate!= null){
                if (MonthMapping != null && MonthMapping.containskey((HistoricalVFinalContract2nd.POStartDate).MONTH()))
                    previousCCStart = (HistoricalVFinalContract2nd.POStartDate).YEAR() + ' ' + MonthMapping.get((HistoricalVFinalContract2nd.POStartDate).MONTH());
            } else{
                previousCCStart = (HistoricalVFinalContract2nd.POStartDate).YEAR() + ' ' + (HistoricalVFinalContract2nd.POStartDate).MONTH();
            }

            if (HistoricalVFinalContract2nd.POEndDate!= null){
                if (MonthMapping != null && MonthMapping.containskey((HistoricalVFinalContract2nd.POEndDate).MONTH()))
                    previousCCEnd = (HistoricalVFinalContract2nd.POEndDate).YEAR() + ' ' + MonthMapping.get((HistoricalVFinalContract2nd.POEndDate).MONTH());
            }else{
                previousCCEnd = (HistoricalVFinalContract2nd.POEndDate).YEAR() + ' ' + (HistoricalVFinalContract2nd.POEndDate).MONTH();
            }

        }




        if((HistoricalV00Contract2nd.ContractId !=null && HistoricalV00Contract2nd.ContractId !='') || Test.isRunningTest() ){ 
            if (Test.isRunningTest()) {
                previousCCStart = null;
                previousCCEnd = null;
            }
            //system.assertEquals(HistoricalV00Contract2nd.ContractId, Null);
            if (previousCCStart == null && previousCCEnd == null) {
                HistoricalVFinalContract2nd.NoOfMonths = HistoricalV00Contract2nd.NoOfMonths;
                if (HistoricalV00Contract2nd.POStartDate!= null){
                    if (MonthMapping != null && MonthMapping.containskey((HistoricalV00Contract2nd.POStartDate).MONTH()))
                        previousCCStart = (HistoricalV00Contract2nd.POStartDate).YEAR() + ' ' + MonthMapping.get((HistoricalV00Contract2nd.POStartDate).MONTH());
                } else{
                    previousCCStart = (HistoricalV00Contract2nd.POStartDate).YEAR() + ' ' + (HistoricalV00Contract2nd.POStartDate).MONTH();
                }

                if (HistoricalV00Contract2nd.POEndDate!= null){
                    if (MonthMapping != null && MonthMapping.containskey((HistoricalV00Contract2nd.POEndDate).MONTH()))
                        previousCCEnd = (HistoricalV00Contract2nd.POEndDate).YEAR() + ' ' + MonthMapping.get((HistoricalV00Contract2nd.POEndDate).MONTH());
                }else{
                    previousCCEnd = (HistoricalV00Contract2nd.POEndDate).YEAR() + ' ' + (HistoricalV00Contract2nd.POEndDate).MONTH();
                }
            }
            
            ASI_TH_CRM_Contract__c PreviousCC =new ASI_TH_CRM_Contract__c();
            try{

                PreviousCC = [select Id,OwnerId,Owner.Name from ASI_TH_CRM_Contract__c where Id =:HistoricalV00Contract2nd.ContractId];
            }catch(exception e){
                PreviousCC =new ASI_TH_CRM_Contract__c();
            }

            if(previousCC.Owner != null){
                PreviousCCSalesRep = previousCC.Owner.Name;
            }

            HVfinalComparedContract2nd = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd ();

            if(HistoricalVFinalContract2nd.Volumes !=0.0){
                HVfinalComparedContract2nd.Volumes = ((NewContractV0Estimate2nd.Volumes - HistoricalVFinalContract2nd.Volumes)/HistoricalVFinalContract2nd.Volumes)*100;
            }

            HistoricalContractCompared2nd = computeFinancialIndicatorDifference2nd(HistoricalContractCompared2nd, HistoricalV00Contract2nd, HistoricalVFinalContract2nd);
        }else{
            HistoricalVFinalContract2nd.NoOfMonths=null;
            ExistHistoricalData=false;
        }

        
        if (!Test.isRunningTest()) {
            investmentBySubBrandByContractBySubBrand2nd = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand2nd(
                new List<String>{'historical' ,'estimate', 'contract'},
                new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd>{HistoricalVFinalContract2nd, NewContractV0Estimate2nd ,NewContactV0Contract2nd}
            );
        }
         
        // System.debug(LoggingLevel.INFO, '*** investmentBySubBrandByContractBySubBrand2nd: ' + JSON.serialize(investmentBySubBrandByContractBySubBrand2nd));
         Set<String> subbrandIds = new Set<String>();
        SubbrandVolume sub999 = new SubbrandVolume();
        subbrandList = new List<SubbrandVolume>();
        List<SubbrandVolume> historicSubbrandList = new List<SubbrandVolume>();
        List<SubbrandVolume> conSubbrandList = new List<SubbrandVolume>();
        ASI_MFM_Sub_brand__c subbrand999 = [SELECT Id FROM ASI_MFM_Sub_brand__c WHERE ASI_MFM_Active_for_CRM__c = true  AND ASI_MFM_Sub_brand_Code__c = '999'  AND recordtypeid = :Global_RecordTypeCache.getRTid('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand') LIMIT 1];
        for (String key : investmentBySubBrandByContractBySubBrand2nd.keySet()) {
            Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.TradeExpenseBreakdown2nd> subbrandExpenseMap = investmentBySubBrandByContractBySubBrand2nd.get(key);
            if (subbrandExpenseMap.containsKey('estimate')) {
                if (subbrand999.Id != key) {
                    if (subbrandExpenseMap.get('estimate').volumeSTD == null || subbrandExpenseMap.get('estimate').volumeSTD == 0) {
                        if (subbrandExpenseMap.get('contract').volumeSTD != null && subbrandExpenseMap.get('contract').volumeSTD != 0) {
                            SubbrandVolume sv = new SubbrandVolume();
                            sv.subbrandId = key;
                            sv.volume = subbrandExpenseMap.get('contract').volumeSTD;
                            conSubbrandList.add(sv);
                            subbrandIds.add(key);
                        } else {
                            if (subbrandExpenseMap.get('historical').volumeSTD != null && subbrandExpenseMap.get('historical').volumeSTD != 0) {
                                SubbrandVolume sv = new SubbrandVolume();
                                sv.subbrandId = key;
                                sv.volume = subbrandExpenseMap.get('historical').volumeSTD;
                                historicSubbrandList.add(sv);
                                subbrandIds.add(key);
                            }
                        }
                    } else {
                        SubbrandVolume sv = new SubbrandVolume();
                        sv.subbrandId = key;
                        sv.volume = subbrandExpenseMap.get('estimate').volumeSTD;
                        subbrandList.add(sv);
                        subbrandIds.add(key);
                    }
                } else {
                    sub999.subbrandId = key;
                    sub999.volume = subbrandExpenseMap.get('estimate').volumeSTD;
                    subbrandIds.add(key);
                }
            }
        }

        for(Integer i = 1; i< subbrandList.size(); i++) {
            Integer j;
            SubbrandVolume temp = subbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(subbrandList[j].volume < temp.volume) {
                    subbrandList[j+1] = subbrandList[j];
                }else{
                    break;
                }
            }
            subbrandList[j+1]=temp;
        }

        for(Integer i = 1; i< conSubbrandList.size(); i++) {
            Integer j;
            SubbrandVolume temp = conSubbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(conSubbrandList[j].volume < temp.volume) {
                    conSubbrandList[j+1] = conSubbrandList[j];
                }else{
                    break;
                }
            }
            conSubbrandList[j+1]=temp;
        }

        for(Integer i = 1; i< historicSubbrandList.size(); i++) {
            Integer j;
            SubbrandVolume temp = historicSubbrandList[i];
            for(j = i-1; j >= 0; j--) {
                if(historicSubbrandList[j].volume < temp.volume) {
                    historicSubbrandList[j+1] = historicSubbrandList[j];
                }else{
                    break;
                }
            }
            historicSubbrandList[j+1]=temp;
        }

        subbrandList.addAll(conSubbrandList);
        subbrandList.addAll(historicSubbrandList);

        if (String.isNotBlank(sub999.subbrandId)) {
            Ishave999 = true;
            if (subbrandList.size() > 21) {
                subbrandList.add(20, sub999);
            } else {
                subbrandList.add(sub999);
            }
        }


        TotalHistoricalBottles = 0;
        TotalEstimateBottles = 0;
        TotalContractBottles = 0;

        AllHistoricalTotalFees = 0;
        AllEstimateTotalFees = 0;
        AllContractTotalFees = 0;
        for (SubbrandVolume sv : subbrandList) {
            TotalHistoricalBottles += investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('historical').monthlyVolumeSTD != null ? investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('historical').monthlyVolumeSTD : 0;

            TotalEstimateBottles += investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('estimate').monthlyVolumeSTD != null ? investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('estimate').monthlyVolumeSTD : 0;

            TotalContractBottles += investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('contract').monthlyVolumeSTD != null ? investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('contract').monthlyVolumeSTD : 0;

            AllHistoricalTotalFees += investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('historical').totalTradeExpense != null ? investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('historical').totalTradeExpense : 0;

            AllEstimateTotalFees += investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('estimate').totalTradeExpense != null ? investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('estimate').totalTradeExpense : 0;

            AllContractTotalFees += investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('contract').totalTradeExpense != null ? investmentBySubBrandByContractBySubBrand2nd.get(sv.subbrandId).get('contract').totalTradeExpense : 0;
        }

        subbrandNameMap = new Map<String,String>();
        System.debug(LoggingLevel.INFO, '*** JSON.serialize(subbrandList): ' + JSON.serialize(subbrandList));
        // System.debug(LoggingLevel.INFO, '*** groupStr: ' + groupStr);
        for (ASI_MFM_Sub_brand__c sb : [SELECT Name,Id,ASI_HK_CRM_English_Name__c,ASI_CRM_CN_CHI_NAME_C__c FROM ASI_MFM_Sub_brand__c WHERE Id IN: subbrandIds]) {
            if (String.isNotBlank(groupStr) && groupStr.contains('D')) {
                subbrandNameMap.put(sb.Id, sb.ASI_HK_CRM_English_Name__c);
            } else {
                subbrandNameMap.put(sb.Id, sb.ASI_CRM_CN_CHI_NAME_C__c);
            }
        }
    }

    public void DataFixing( map<integer, string> MonthMapping){
        for(String SBGName: sbGroup_map.keySet()){


            if(HistoricalV00Contract.SubBrandGradeMap==null || !HistoricalV00Contract.SubBrandGradeMap.containskey(SBGName)){
                HistoricalV00Contract.SubBrandGradeMap.put(SBGName,0.0);
            }
            if(HistoricalVFinalContract.SubBrandGradeMap==null || !HistoricalVFinalContract.SubBrandGradeMap.containskey(SBGName)){
                HistoricalVFinalContract.SubBrandGradeMap.put(SBGName,0.0);
            }
            if(NewContractV0Estimate.SubBrandGradeMap==null || !NewContractV0Estimate.SubBrandGradeMap.containskey(SBGName)){
                NewContractV0Estimate.SubBrandGradeMap.put(SBGName,0.0);
            }
            if(NewContactV0Contract.SubBrandGradeMap==null || !NewContactV0Contract.SubBrandGradeMap.containskey(SBGName)){
                NewContactV0Contract.SubBrandGradeMap.put(SBGName,0.0);
            }

            if(HistoricalContractCompared.SubBrandGradeMap==null || !HistoricalContractCompared.SubBrandGradeMap.containskey(SBGName)){
                Decimal ComparedRate=0;
                if(HistoricalV00Contract.SubBrandGradeMap.get(SBGName)!=0){
                    ComparedRate=((HistoricalVFinalContract.SubBrandGradeMap.get(SBGName)-HistoricalV00Contract.SubBrandGradeMap.get(SBGName))*100)/HistoricalV00Contract.SubBrandGradeMap.get(SBGName);
                }
                HistoricalContractCompared.SubBrandGradeMap.put(SBGName,ComparedRate);
            }

        }

        SubBrandContractMap = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>(NewContactV0Contract.ContractLineMap);
        for(String ContractLineKey:HistoricalVFinalContract.ContractLineMap.keySet()){
            if(SubBrandContractMap.containsKey(ContractLineKey)){
                SubBrandContractMap.get(ContractLineKey).HistoricalBottles=HistoricalVFinalContract.ContractLineMap.get(ContractLineKey).HistoricalBottles;
                SubBrandContractMap.get(ContractLineKey).HistoricalFees = HistoricalVFinalContract.ContractLineMap.get(ContractLineKey).HistoricalFees;
                SubBrandContractMap.get(ContractLineKey).HistoricalTotalFees = HistoricalVFinalContract.ContractLineMap.get(ContractLineKey).HistoricalTotalFees;
            }else{
                SubBrandContractMap.put(ContractLineKey, HistoricalVFinalContract.ContractLineMap.get(ContractLineKey));
            }
        }


        Decimal HistoricalTotalFees=0;
        Decimal Sum_EstimateTotalFees=0;
        Decimal Sum_ContractTotalFees=0;
        for(String SubBrandContractKey:SubBrandContractMap.keySet()){
            SubBrandContractMap.get(SubBrandContractKey).HistoricalFees=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalFees);
            SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles=DecimalRounding(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles);

            if(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateBottles==0 && SubBrandContractMap.get(SubBrandContractKey).ContractBottles ==0 && SubBrandContractMap.get(SubBrandContractKey).HistoricalFees ==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateFees==0 && SubBrandContractMap.get(SubBrandContractKey).ContractFees ==0 && SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees==0 && SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees==0){
                SubBrandContractMap.remove(SubBrandContractKey);
            }else{
                //Data Fixing
                integer intlength = SubBrandContractMap.get(SubBrandContractKey).SubBrandName.length();
                if(intlength >= 4 && SubBrandContractMap.get(SubBrandContractKey).SubBrandName.contains('-')){
                    SubBrandContractMap.get(SubBrandContractKey).strSubBrand =  SubBrandContractMap.get(SubBrandContractKey).SubBrandName.substring(0, (intlength-4));
                }
                if(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles!=null){
                    SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles = SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles.setScale(0, RoundingMode.HALF_UP);
                }
                //  if(SubBrandContractMap.get(SubBrandContractKey).HistoricalFees<1 && SubBrandContractMap.get(SubBrandContractKey).HistoricalFees>0){
                //    SubBrandContractMap.get(SubBrandContractKey).HistoricalFees=0;
                // }

                HistoricalTotalFees+=SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees;
                Sum_EstimateTotalFees +=SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees!=null?SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees:0;
                Sum_ContractTotalFees +=SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees!=null? SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees:0;
            }
        }
        HistoricalVEAdjustment= -(HistoricalVFinalContract.VariableExpense-HistoricalPSFEstTotal-HistoricalVECEstTotal-HistoricalTotalFees);
        EstimateVEAdjustment=-(NewContractV0Estimate.VariableExpense-PSFDetailTotal.EstimateTotalFees-VECDetailTotal.EstimateTotalFees-Sum_EstimateTotalFees);
        ContractVEAdjustment=-(NewContactV0Contract.VariableExpense-PSFDetailTotal.ContractTotalFees-VECDetailTotal.ContractTotalFees-Sum_ContractTotalFees);
        if(HistoricalVEAdjustment!=0 || EstimateVEAdjustment!=0 && ContractVEAdjustment!=0){
            ShowAchievementRecognition=true;
        }

        if(HistoricalVECEstTotal!=0 || VECDetailTotal.EstimateTotalFees!=0 || VECDetailTotal.ContractTotalFees!=0 ){
            ShowVEC_VXTable=true;
        }

        if(HistoricalPSFEstTotal!=0 || PSFDetailTotal.EstimateTotalFees!=0 || PSFDetailTotal.ContractTotalFees!=0 ){
            ShowPSF_VXTable=true;
        }

        FixExpense_Map = new Map<String, ASI_CRM_CN_HeavyContractUtilitiesClass.ContractLine>(NewContactV0Contract.FixedExpensesMap);
        for(String ContractLineKey:HistoricalVFinalContract.FixedExpensesMap.keySet()){
            if(FixExpense_Map.containsKey(ContractLineKey)){
                FixExpense_Map.get(ContractLineKey).HistoricalFees =HistoricalVFinalContract.FixedExpensesMap.get(ContractLineKey).HistoricalFees;
            }else{
                FixExpense_Map.put(ContractLineKey, HistoricalVFinalContract.FixedExpensesMap.get(ContractLineKey));
            }
        }

        if(FixExpense_Map.size()>0){

            for(string FXMapKey:FixExpense_Map.keySet()){
                if(FixExpense_Map.get(FXMapKey).HistoricalFees==0 && FixExpense_Map.get(FXMapKey).EstimateFees==0 && FixExpense_Map.get(FXMapKey).ContractFees==0 ){
                    FixExpense_Map.remove(FXMapKey);
                }
            }
        }

        if(FixExpense_Map.size()>0){
            ShowFixCostable=true;
        }



        if(HistoricalVFinalContract.ContractId !=null && HistoricalVFinalContract.ContractId !=''){
            if (HistoricalVFinalContract.POStartDate!= null){
                if (MonthMapping != null && MonthMapping.containskey((HistoricalVFinalContract.POStartDate).MONTH()))
                    previousCCStart = (HistoricalVFinalContract.POStartDate).YEAR() + ' ' + MonthMapping.get((HistoricalVFinalContract.POStartDate).MONTH());
            } else{
                previousCCStart = (HistoricalVFinalContract.POStartDate).YEAR() + ' ' + (HistoricalVFinalContract.POStartDate).MONTH();
            }

            if (HistoricalVFinalContract.POEndDate!= null){
                if (MonthMapping != null && MonthMapping.containskey((HistoricalVFinalContract.POEndDate).MONTH()))
                    previousCCEnd = (HistoricalVFinalContract.POEndDate).YEAR() + ' ' + MonthMapping.get((HistoricalVFinalContract.POEndDate).MONTH());
            }else{
                previousCCEnd = (HistoricalVFinalContract.POEndDate).YEAR() + ' ' + (HistoricalVFinalContract.POEndDate).MONTH();
            }

        }




        if((HistoricalV00Contract.ContractId !=null && HistoricalV00Contract.ContractId !='') || Test.isRunningTest() ){ //system.assertEquals(HistoricalV00Contract.ContractId, Null);


            ASI_TH_CRM_Contract__c PreviousCC =new ASI_TH_CRM_Contract__c();
            try{

                PreviousCC = [select Id,OwnerId,Owner.Name from ASI_TH_CRM_Contract__c where Id =:HistoricalV00Contract.ContractId];
            }catch(exception e){
                PreviousCC =new ASI_TH_CRM_Contract__c();
            }





            if(previousCC.Owner != null){
                PreviousCCSalesRep = previousCC.Owner.Name;
            }

            HVfinalComparedContract = new ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator ();

            if(HistoricalVFinalContract.Volumes !=0.0){
                HVfinalComparedContract.Volumes = ((NewContractV0Estimate.Volumes - HistoricalVFinalContract.Volumes)/HistoricalVFinalContract.Volumes)*100;
            }
            system.debug('HistoricalV00Contract'+HistoricalV00Contract);
                
                    system.debug('HistoricalVFinalContract'+HistoricalVFinalContract);
            HistoricalContractCompared = computeFinancialIndicatorDifference(HistoricalContractCompared, HistoricalV00Contract, HistoricalVFinalContract);
        }else{
            HistoricalVFinalContract.NoOfMonths=null;
            ExistHistoricalData=false;
        }

        investmentBySubBrandByContractBySubBrand = ASI_CRM_CN_HeavyContractUtilitiesClass.getInvestmentBySubBrand(
            new List<String>{'historical' ,'estimate', 'contract'},
            new List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator>{HistoricalV00Contract, NewContractV0Estimate ,NewContactV0Contract}
        );

    }


    /**
     * Compare financialIndicator1 and financialIndicator2, and store in result.
     * Note that the original input will be altered.
     * TODO compute the difference of trade expense by Grade
     *
     * @param result
     * @param financialIndicator1 The older financial indicator, for example v0.0.
     * @param financialIndicator2 The new financial indicator, for example vFinal.
     *
     * @return
     */
    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd computeFinancialIndicatorDifference2nd(
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd result,
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd financialIndicator1,
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd financialIndicator2) {
            // system.debug('=================>result'+result);
            // system.debug('=================>financialIndicator1'+financialIndicator1);
            // system.debug('=================>financialIndicator2'+financialIndicator2);
            
        if (financialIndicator1.Volumes != 0.0) {
            result.Volumes = ((financialIndicator2.Volumes - financialIndicator1.Volumes) / financialIndicator1.Volumes) * 100;
        }
        if (financialIndicator1.TradeExpenses != 0.0) {
            result.TradeExpenses = ((financialIndicator2.TradeExpenses - financialIndicator1.TradeExpenses) / financialIndicator1.TradeExpenses) * 100;
        }



        result.GrossSalesRate = financialIndicator2.GrossSalesRate - financialIndicator1.GrossSalesRate;

        result.GrossSalesRateProForma = financialIndicator2.GrossSalesRateProForma - financialIndicator1.GrossSalesRateProForma;

        result.CMNSRate = financialIndicator2.CMNSRate - financialIndicator1.CMNSRate;

        result.CMNSRateProForma = financialIndicator2.CMNSRateProForma - financialIndicator1.CMNSRateProForma;

        result.DomesticContractIndex = ((financialIndicator2.DomesticContractIndex - financialIndicator1.DomesticContractIndex) / financialIndicator1.DomesticContractIndex) * 100;

        result.DomesticContractIndexProForma = ((financialIndicator2.DomesticContractIndexProForma - financialIndicator1.DomesticContractIndexProForma) / financialIndicator1.DomesticContractIndexProForma) * 100;


        result.RegionalTargetIndex = ((financialIndicator2.RegionalTargetIndex - financialIndicator1.RegionalTargetIndex) / financialIndicator1.RegionalTargetIndex) * 100;

        result.RegionalTargetIndexProForma = ((financialIndicator2.RegionalTargetIndexProForma - financialIndicator1.RegionalTargetIndexProForma) / financialIndicator1.RegionalTargetIndexProForma) * 100;

        result.VsRegionalAverageIndex = ((financialIndicator2.VsRegionalAverageIndex - financialIndicator1.VsRegionalAverageIndex) / financialIndicator1.VsRegionalAverageIndex) * 100;

        result.VsRegionalAverageIndexProForma = financialIndicator2.VsRegionalAverageIndexProForma - financialIndicator1.VsRegionalAverageIndexProForma;


            system.debug('===========================>financialIndicator2.GrossSalesRateExcl'+financialIndicator2.GrossSalesRateExcl);
            system.debug('===========================>financialIndicator1.GrossSalesRateExcl'+financialIndicator1.GrossSalesRateExcl);
            system.debug('===========================>result.GrossSalesRateExcl'+result.GrossSalesRateExcl);
        result.GrossSalesRateExcl = financialIndicator2.GrossSalesRateExcl - financialIndicator1.GrossSalesRateExcl;
            
        if (financialIndicator1.InvestmentCR12 != 0.0) {
            result.InvestmentCR12 = ((financialIndicator2.InvestmentCR12 - financialIndicator1.InvestmentCR12) / financialIndicator1.InvestmentCR12) * 100;
        }
        if (financialIndicator1.VariableExpense != 0.0) {
            result.VariableExpense = ((financialIndicator2.VariableExpense - financialIndicator1.VariableExpense) / financialIndicator1.VariableExpense) * 100;
        }
        if (financialIndicator1.FixedExpense != 0.0) {
            result.FixedExpense = ((financialIndicator2.FixedExpense - financialIndicator1.FixedExpense) / financialIndicator1.FixedExpense) * 100;
        }

        result.FixedExpenseRate = financialIndicator2.FixedExpenseRate - financialIndicator1.FixedExpenseRate;

        if (financialIndicator1.MarginAfterAnP != 0.0) {
            result.MarginAfterAnP = ((financialIndicator2.MarginAfterAnP - financialIndicator1.MarginAfterAnP) / financialIndicator1.MarginAfterAnP) * 100;
        }


        if (financialIndicator1.MarginPerBottle != 0.0) {
            result.MarginPerBottle = ((financialIndicator2.MarginPerBottle - financialIndicator1.MarginPerBottle) / financialIndicator1.MarginPerBottle) * 100;
        }

        result.ROIIntake = financialIndicator2.ROIIntake - financialIndicator1.ROIIntake;
        result.ROIIntakeExcl = financialIndicator2.ROIIntakeExcl - financialIndicator1.ROIIntakeExcl;

        result.ROIProForma = financialIndicator2.ROIProForma - financialIndicator1.ROIProForma;
        result.ROIProFormaExcl = financialIndicator2.ROIProFormaExcl - financialIndicator1.ROIProFormaExcl;

        result.BCRate = financialIndicator2.BCRate - financialIndicator1.BCRate;
        result.TotalBCRate = financialIndicator2.TotalBCRate - financialIndicator1.BCRate;

        result.TotalMBCRate = financialIndicator2.TotalMBCRate - financialIndicator1.TotalMBCRate;

        return result;
    }

    /**
     * Compare financialIndicator1 and financialIndicator2, and store in result.
     * Note that the original input will be altered.
     * TODO compute the difference of trade expense by Grade
     *
     * @param result
     * @param financialIndicator1 The older financial indicator, for example v0.0.
     * @param financialIndicator2 The new financial indicator, for example vFinal.
     *
     * @return
     */
    public static ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator computeFinancialIndicatorDifference(
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator result,
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator financialIndicator1,
        ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator financialIndicator2) {
            system.debug('=================>result'+result);
            system.debug('=================>financialIndicator1'+financialIndicator1);
            system.debug('=================>financialIndicator2'+financialIndicator2);
            
        if (financialIndicator1.Volumes != 0.0) {
            result.Volumes = ((financialIndicator2.Volumes - financialIndicator1.Volumes) / financialIndicator1.Volumes) * 100;
        }
        if (financialIndicator1.TradeExpenses != 0.0) {
            result.TradeExpenses = ((financialIndicator2.TradeExpenses - financialIndicator1.TradeExpenses) / financialIndicator1.TradeExpenses) * 100;
        }

        result.GrossSalesRate = financialIndicator2.GrossSalesRate - financialIndicator1.GrossSalesRate;
            system.debug('===========================>financialIndicator2.GrossSalesRateExcl'+financialIndicator2.GrossSalesRateExcl);
            system.debug('===========================>financialIndicator1.GrossSalesRateExcl'+financialIndicator1.GrossSalesRateExcl);
            system.debug('===========================>result.GrossSalesRateExcl'+result.GrossSalesRateExcl);
        result.GrossSalesRateExcl = financialIndicator2.GrossSalesRateExcl - financialIndicator1.GrossSalesRateExcl;
            
        if (financialIndicator1.InvestmentCR12 != 0.0) {
            result.InvestmentCR12 = ((financialIndicator2.InvestmentCR12 - financialIndicator1.InvestmentCR12) / financialIndicator1.InvestmentCR12) * 100;
        }
        if (financialIndicator1.VariableExpense != 0.0) {
            result.VariableExpense = ((financialIndicator2.VariableExpense - financialIndicator1.VariableExpense) / financialIndicator1.VariableExpense) * 100;
        }
        if (financialIndicator1.FixedExpense != 0.0) {
            result.FixedExpense = ((financialIndicator2.FixedExpense - financialIndicator1.FixedExpense) / financialIndicator1.FixedExpense) * 100;
        }

        result.FixedExpenseRate = financialIndicator2.FixedExpenseRate - financialIndicator1.FixedExpenseRate;

        if (financialIndicator1.MarginAfterAnP != 0.0) {
            result.MarginAfterAnP = ((financialIndicator2.MarginAfterAnP - financialIndicator1.MarginAfterAnP) / financialIndicator1.MarginAfterAnP) * 100;
        }


        if (financialIndicator1.MarginPerBottle != 0.0) {
            result.MarginPerBottle = ((financialIndicator2.MarginPerBottle - financialIndicator1.MarginPerBottle) / financialIndicator1.MarginPerBottle) * 100;
        }

        result.ROIIntake = financialIndicator2.ROIIntake - financialIndicator1.ROIIntake;
        result.ROIIntakeExcl = financialIndicator2.ROIIntakeExcl - financialIndicator1.ROIIntakeExcl;

        result.ROIProForma = financialIndicator2.ROIProForma - financialIndicator1.ROIProForma;
        result.ROIProFormaExcl = financialIndicator2.ROIProFormaExcl - financialIndicator1.ROIProFormaExcl;

        result.BCRate = financialIndicator2.BCRate - financialIndicator1.BCRate;
        result.TotalBCRate = financialIndicator2.TotalBCRate - financialIndicator1.BCRate;

        result.TotalMBCRate = financialIndicator2.TotalMBCRate - financialIndicator1.TotalMBCRate;

        return result;
    }


    public Decimal DecimalRounding(Decimal InputNumber){
        if(InputNumber!=null){
            if(InputNumber<1 && InputNumber>0){
                InputNumber=0;
            }
        }

        return InputNumber;
    }


    public void checkLastRBAID(){
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:thisCC.ASI_CRM_Last_RBA_Approver__c];
        if(gms.size()>0)
            AdorAbove = true;
    }

    public String checkLastRBAID2nd(){
        String groupAName = 'ASI_CN_GS_Commercial_team';
        String groupBName = 'ASI_CN_Commercial_team_ex_GS';
        String groupCName = 'ASI_CN_Finance';
        String groupDName = 'ASI_CN_HQ_Management';

        String belongGroup = 'Group ';
        // list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:thisCC.ASI_CRM_Last_RBA_Approver__c];
        Set<String> groupNames = new Set<String>();
        for (GroupMember gm: [SELECT group.name,
                                     group.DeveloperName
                              FROM GroupMember
                              WHERE UserOrGroupId =: thisCC.ASI_CRM_Last_RBA_Approver__c]) {
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
        // if(gms.size()>0)
        //     AdorAbove = true;
    }

    public void checkUserID(){
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId=:UserInfo.getUserId()];
        if(gms.size()>0)
            AdorAbove = true;
    }



    public void checkApprover(){
        AdorAbove = false;
        set<Id> actorIds = new set<Id>();
        for(ProcessInstanceWorkitem piw :[SELECT ActorId FROM ProcessInstanceWorkitem WHERE processinstance.status = 'Pending' AND processinstance.targetobjectid = : thisCC.id]){
            actorIds.add(piw.ActorId);
        }
        list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];

        if(gms.size()>0)
            AdorAbove = true;
    }

    public String checkApprover2nd(Set<Id> userIds){
        // AdorAbove = false;
        // list<GroupMember> gms = [SELECT Id FROM GroupMember WHERE Group.DeveloperName='ASI_CRM_CN_AD_or_Above' AND UserOrGroupId in :actorIds];

        String groupAName = 'ASI_CN_GS_Commercial_team';
        String groupBName = 'ASI_CN_Commercial_team_ex_GS';
        String groupCName = 'ASI_CN_Finance';
        String groupDName = 'ASI_CN_HQ_Management';

        String belongGroup = 'Group ';

        if (userIds != null && !userIds.isEmpty()) {
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


    public class SubbrandVolume {
        public String subbrandId {get;set;}
        public Decimal volume {get;set;}
    }

    public class CategoryName {
        public String Cname {get;set;}
        public String CEnName {get;set;}
    }


}