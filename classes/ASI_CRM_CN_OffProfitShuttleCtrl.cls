/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffProfitShuttleCtrl
 * Description: Controller for Page ASI_CRM_CN_OffPDFRedirectPage 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-07       Hector Tsang          Created
 ****************************************************************************************************************************/

public with sharing class ASI_CRM_CN_OffProfitShuttleCtrl {
    public String PageId {set;get;}
    public ASI_TH_CRM_Contract__c thisCC {set;get;}
    public string strPDF {set;get;}
    public boolean AdorAbove {set;get;}
    
    public boolean IsEmail  {set;get;}{IsEmail=false;}
    public String IsEmailStr  {set;get;}{IsEmailStr='0';}
    
    //Date to the String 
    public string thisCCStart {set;get;}
    public string thisCCEnd {set;get;}
    public string previousCCStart {set;get;}
    public string previousCCEnd {set;get;}
    public string PreviousCCSalesRep {set;get;} {PreviousCCSalesRep='';}
    
    public boolean showCN {set;get;}
    
    //get Contract Approval Comments
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}{lstApprovalComment= new List<ASI_CRM_Approval_Comment__c> ();}
    public String ApprovalComment {set;get;}
    
    public Set<String> SubbrandGroupNameSet {set;get;} {SubbrandGroupNameSet = new Set<String>(); }
    
    public Map<String, String> sbGroup_map {set;get;} {sbGroup_map = new Map<String, String>();}
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public Boolean ExistHistoricalData {set;get;} {ExistHistoricalData=true;}
    public ASI_CRM_Module__c BRSFModule {set;get;} {BRSFModule = new ASI_CRM_Module__c();}
    public List<ASI_CRM_Module__c> PSFModuleList {set;get;} {PSFModuleList = new List<ASI_CRM_Module__c>();}
    public List<ASI_CRM_Module__c> DisplayModuleList {set;get;} {DisplayModuleList = new List<ASI_CRM_Module__c>();}

    public map<String, ASI_CRM_Module__c> PSF_Item_Map {set;get;} {PSF_Item_Map= new map<String, ASI_CRM_Module__c>();}
    public map<String, ASI_CRM_Module__c> Display_Item_Map {set;get;} {Display_Item_Map= new map<String, ASI_CRM_Module__c>();}
    
    public Boolean displayBRSF {set;get;} {displayBRSF=false;}

    public boolean ShowPSF_VXTable {set;get;} {ShowPSF_VXTable=false;}
    public boolean ShowFixCostable {set;get;} {ShowFixCostable=false;}
    public boolean ShowGroupShuttle {set;get;} {ShowGroupShuttle = false;}

    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HistoricalV00Contract  {set;get;} { HistoricalV00Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HistoricalVFinalContract  {set;get;} { HistoricalVFinalContract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContractV0Estimate  {set;get;} { NewContractV0Estimate = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator NewContactV0Contract  {set;get;} { NewContactV0Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HistoricalContractCompared  {set;get;} { HistoricalContractCompared = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HVfinalComparedContract  {set;get;} { HVfinalComparedContract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}

    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator GroupContract  {set;get;} { GroupContract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();}
    
    public Map<String,ASI_CRM_CN_OffContractUtilitiesClass.ContractLine> SubBrandContractMap  {set;get;}  { SubBrandContractMap = new Map<String,ASI_CRM_CN_OffContractUtilitiesClass.ContractLine> ();}
    public Map<String,ASI_CRM_CN_OffContractUtilitiesClass.ContractLine> FixExpense_Map  {set;get;}  { FixExpense_Map = new Map<String,ASI_CRM_CN_OffContractUtilitiesClass.ContractLine> ();}
    
    public Map<String,Decimal> HistoricalAAndP_Map  {set;get;}  { HistoricalAAndP_Map = new Map<String,Decimal> ();}
    public Map<String,Decimal> ContractAAndP_Map  {set;get;}  { ContractAAndP_Map = new Map<String,Decimal> ();}

    public ASI_CRM_CN_OffContractUtilitiesClass.ContractLine PSFDetailTotal {set;get;} {PSFDetailTotal = new ASI_CRM_CN_OffContractUtilitiesClass.ContractLine();}
    public ASI_CRM_CN_OffContractUtilitiesClass.ContractLine VECDetailTotal {set;get;} {VECDetailTotal = new ASI_CRM_CN_OffContractUtilitiesClass.ContractLine();}
    
    public Decimal HistoricalPSFEstTotal {set;get;}  {HistoricalPSFEstTotal=0;}
    
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
    public boolean showDisplay{set;get;} {showDisplay = true;}
    public ASI_CRM_CN_OffProfitShuttleCtrl(){}
    
    public ASI_CRM_CN_OffProfitShuttleCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public Map<String, Decimal> categoriesMap {set;get;} {categoriesMap = new Map<String, Decimal>();}
    public Map<String, String> categoriesDisplayMap {set;get;} {categoriesDisplayMap = new Map<String, String>();}

    //TODO: In best case, HistoricalContractCompared should be removed
    public boolean init(){
    	//Data initialization
        showCN = USerInfo.getLanguage()=='zh_CN';
        
        td_end = '</td>';
        ExistHistoricalDataTD ='<td style=" border-right: 1px solid black; border-bottom: 1px solid black; " align="right">';
        ExistHisDataTD_noBottom ='<td style=" border-right: 1px solid black;" align="right">';
        
        ExistHisDataTD_dotted ='<td style="border-bottom: 1px solid black; border-right: 1px dotted gray;" align="right">';
        ExistHisDataTD_dottednoBottom ='<td style=" border-right: 1px dotted gray;" align="right">';
        
        ExistHistoricalData1='<td colspan="3" style=" border-right: 1px solid black; border-bottom: 1px solid black;" align="center">Historical Contract<br/>历史合同</td> <td colspan="3" style="border-right: 1px solid black; border-bottom: 1px solid black;" align="center">New Contract<br/>新合同</td>';
        ExistHistoricalData2='<td colspan="2" style="border-right: 1px solid black; border-bottom: 1px solid black;" align="center">New Contract<br/>新合同</td>';
        
        MainTableHeader1='<td colspan="9" bgcolor="#99CCFF" style="border:1px solid black;" align="center" ><strong>P&L REVIEW (in RMB) 利润分析表 （元）</strong></td>';
        MainTableHeader2='<td colspan="5" bgcolor="#99CCFF" style="border:1px solid black;" align="center" ><strong>P&L REVIEW (in RMB) 利润分析表 （元）</strong></td>';
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
            HistoricalContractCompared = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();
            try{
                thisCC = [SELECT id,Name,Owner.Name,
                				ASI_CRM_CN_BRSF_Contract_Total__c,
								ASI_CRM_CN_Bottle_Collection_Rate__c,
								ASI_CRM_CN_Budget_LE__c,
								ASI_CRM_CN_Contract_Cost_Total__c,
								ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
								ASI_CRM_CN_Contract_Est_Var_Cost_Total__c,
								ASI_CRM_CN_Contract_Estimate_Cost_Total__c,
								ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
								ASI_CRM_CN_Contract_Variable_Cost_Total__c,
								ASI_CRM_CN_Description__c,
								ASI_CRM_CN_Group_Contract__c,
								ASI_CRM_CN_Group_Contract__r.Name,
								ASI_CRM_CN_Last_PO_version__c,
								ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
								ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
								ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
								ASI_CRM_CN_No_of_Months__c,
								ASI_CRM_CN_Outlet_WS__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,
								ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
								ASI_CRM_CN_Outlet_WS__r.ASI_TH_CRM_OutletType__c,
								ASI_CRM_CN_Outlet_WS__r.Name,
								ASI_CRM_CN_PO_End_Date__c,
								ASI_CRM_CN_PO_Modification__c,
								ASI_CRM_CN_PO_No__c,
								ASI_CRM_CN_PO_Start_Date__c,
								ASI_CRM_CN_PO_Version__c,
								ASI_CRM_CN_Source_of_Contract__c,
								ASI_CRM_CN_Status__c,
								ASI_CRM_CN_Total_Contract_Amount__c,
								ASI_CRM_CN_V0_0_PO_version__c,
								ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
								ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
								ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c,
								ASI_CRM_CN_Vol_Budget_LE__c,
								ASI_CRM_Last_RBA_Approver__c,
								ASI_CRM_Martell_BC_Rate__c,
								ASI_CRM_New_FY_PO__c,
								ASI_CRM_PO_Channel__c,
								ASI_CRM_PO_Channel__r.Name,
								ASI_CRM_PO_City__c,
								ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c,
								ASI_CRM_PO_City__r.Name,
								ASI_CRM_PO_Province__c,
								ASI_CRM_PO_Province__r.Name,
								ASI_CRM_Volume_Option__c,
								ASI_TH_CRM_Promotion_Type__c,
                                ASI_CRM_CN_Is_Dolphin__c
                          FROM ASI_TH_CRM_Contract__c 
                          WHERE id = :PageId];
                
                if (thisCC.ASI_CRM_CN_PO_Start_Date__c!= null){
                    if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH()))
                        thisCCStart = (thisCC.ASI_CRM_CN_PO_Start_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_Start_Date__c).MONTH());
                } else
                    thisCCStart = '';
                
                if (thisCC.ASI_CRM_CN_PO_End_Date__c!= null){
                    if (MonthMapping.containskey((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH()))
                        thisCCEnd = (thisCC.ASI_CRM_CN_PO_End_Date__c).YEAR() + ' ' + MonthMapping.get((thisCC.ASI_CRM_CN_PO_End_Date__c).MONTH());
                } else
                    thisCCEnd = '';
                
                
                if(thisCC.ASI_CRM_CN_Vol_Budget_LE__c==null){
                    thisCC.ASI_CRM_CN_Vol_Budget_LE__c=0;
                }
                if(thisCC.ASI_CRM_CN_Budget_LE__c==null){
                    thisCC.ASI_CRM_CN_Budget_LE__c=0;
                }
                lstApprovalComment = [SELECT id, recordtypeid, 
                							ASI_CRM_BA_comments__c, 
                							ASI_CRM_Background_Objective__c, 
                							ASI_CRM_New_contract_Analsysis__c, 
                							ASI_CRM_Historical_Contract_Performance__c 
                					  FROM ASI_CRM_Approval_Comment__c 
                                      WHERE ASI_CRM_Contract__c =:thisCC.id];  
                
                
                if(lstApprovalComment==null || lstApprovalComment.size()==0){
                    ApprovalComment ='';
                    lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
                }
                else{
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
                ASI_CRM_CN_ContractUtilities_Cls.convertCommentLineBreak(lstApprovalComment);
                
            }catch(exception e){
                String msg = 'Save Error : ' +e.getMessage() + '</br>';
                ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_OffProfitShuttleCtrl in init class have Error  '+msg,'ASI_CRM_CN_OffProfitShuttleCtrl','PDF function failed! with contract Id: '+PageId );
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
        

        //Getting HistoricalV0.0 and VFinal Data and Group PO
        if (thisCC.ASI_CRM_CN_Group_Contract__c != null){
        	ASI_CRM_CN_OffContractUtilitiesClass.calculateGroupFI(thisCC.ASI_CRM_CN_Group_Contract__c, thisCC.Id);
        }
        List<ASI_Attachment__c> AttachmentList= [SELECT id,
        												ASI_CRM_Historical_Financial_Data__c,
        												ASI_CRM_Contract__c,
        												ASI_CRM_Type__c 
        										FROM ASI_Attachment__c 
        										WHERE (ASI_CRM_Contract__c = :thisCC.Id
                                                    OR (ASI_CRM_Contract__c = :thisCC.ASI_CRM_CN_Group_Contract__c
        												AND ASI_CRM_Type__c = 'Group Contract Data'))];
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){
            	String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&lt;','<');
                JsonString = JsonString.replaceAll('&quot;','"');//system.debug('Test Contract Data : ' + JsonString);
                    
            	if (att.ASI_CRM_Type__c == 'Group Contract Data'){
            		ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator groupContractFI = (ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator)System.JSON.deserialize(JsonString,ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator.class);
            		GroupContract = groupContractFI;
            		ShowGroupShuttle = true;
            	} else if(att.ASI_CRM_Type__c=='Historical Data'){
                    List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> HistoricalContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                    if(HistoricalContractList.size()>0){
                        HistoricalV00Contract = HistoricalContractList[0];
                        HistoricalVFinalContract = HistoricalContractList[1];

                        HistoricalV00Contract.DataRounding();
                        HistoricalVFinalContract.DataRounding();
                        
                        if(HistoricalVFinalContract.AddOnString!=''){
                            
                            Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(HistoricalVFinalContract.AddOnString,Map<String,Decimal>.class);
                            if( TempMap.containsKey('PSFEstTotal')  ){
                                HistoricalPSFEstTotal= TempMap.get('PSFEstTotal');
                            }
                        }                        
                    } 
                } else if(att.ASI_CRM_Type__c=='Contract Data'){
                    List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                    if(ContractList.size()>0){
                        NewContractV0Estimate = ContractList[0];
                        NewContactV0Contract = ContractList[1];

                        NewContractV0Estimate.DataRounding();
                        NewContactV0Contract.DataRounding();

                    } 
                }
                
            }
        }
        
        if(thisCC.ASI_CRM_CN_Is_Dolphin__c){
            List<ASI_TH_CRM_Contract__c> HistoryV0Contract = [SELECT Id,ASI_CRM_CN_Is_Dolphin__c FROM ASI_TH_CRM_Contract__c WHERE Id =: HistoricalV00Contract.ContractId];
            List<ASI_TH_CRM_Contract__c> HistoryVFinalContract = [SELECT Id,ASI_CRM_CN_Is_Dolphin__c FROM ASI_TH_CRM_Contract__c WHERE Id =: HistoricalVFinalContract.ContractId];
            if(HistoryV0Contract.size() > 0 && HistoryVFinalContract.size() >0){
                if(HistoryV0Contract[0].ASI_CRM_CN_Is_Dolphin__c && HistoryVFinalContract[0].ASI_CRM_CN_Is_Dolphin__c){
                    showDisplay = false;
                }
            }else{
                showDisplay = false;
            }
        }

        String BRSFDefaultMethodology='';
        String PSFDefaultMethodology='';
        
        ASI_CRM_Methodology__c BRSFMethodology_Default= new ASI_CRM_Methodology__c();
        ASI_CRM_Methodology__c PSFMethodology_Default=new ASI_CRM_Methodology__c();
        
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
        }
        

        
        String moduleQuery = 'SELECT ' +
            'Id,' +
            'ASI_CRM_Is_Default_Methodology__c,' +
            'ASI_CRM_Remark_Display__c,' +
            'ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,' +
            'ASI_CRM_Unit__c,ASI_CRM_Volume_Base__c,' +
            'ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,' +
            'ASI_CRM_Methodology__c,' +
            'ASI_CRM_Methodology__r.Name,' +
            'ASI_CRM_Reason_Not_NCD_Methodology__c,' +
            'ASI_CRM_CN_Contract_Volume_Base__c,' +
            'ASI_CRM_Reason_NCD_Volume_Base__c ' +
            'FROM ASI_CRM_Module__c ' +
            'WHERE ';

        // Archived contract does not have module
        if (thisCC.ASI_CRM_CN_Status__c != 'Archived') {
            moduleQuery += 'ASI_CRM_Contract__c =:pageId ';
        } else {//contract version != v0.0
            moduleQuery += 'ASI_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c =:pageId ';
        }

        Map<String, ASI_CRM_Module__c> ModuleMap = new Map<String, ASI_CRM_Module__c>((List<ASI_CRM_Module__c>) Database.query(moduleQuery));


        displayBRSF=false;
        
        //Variable Cost Investment Methodology (变动费用投资方式)
        Set<Id> DisplayIdSet= new Set<Id>();
        Set<Id> PSFIdSet= new Set<Id>();

        Display_Item_Map= new map<String, ASI_CRM_Module__c>();
        PSF_Item_Map= new map<String, ASI_CRM_Module__c>();
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:[SELECT Id, 
        															ASI_CRM_CN_Activity_Code__c,
																	ASI_CRM_CN_Contract_BRSF_Per_Bottle__c,
																	ASI_CRM_CN_Contract_Monthly_Qty__c,
																	ASI_CRM_CN_Contract_Total_Dummy__c,
																	ASI_CRM_CN_Contract_Total__c,
																	ASI_CRM_CN_Contract__c,
																	ASI_CRM_CN_Est_BRSF_Per_Bottle__c,
																	ASI_CRM_CN_Est_Monthly_Qty__c,
																	ASI_CRM_CN_Est_Total_Dummy__c,
																	ASI_CRM_CN_Est_Total__c,
																	ASI_CRM_CN_No_of_Months__c,
																	ASI_CRM_CN_Sub_Brand__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
																	ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
																	ASI_CRM_CN_Sub_Brand__r.Name,
																	ASI_CRM_Contract_Total_QTY_CR12_Eqv__c,
																	ASI_CRM_Contract_Total_QTY_std_Btl__c,
																	ASI_CRM_Est_Total_QTY_CR12_Eqv__c,
																	ASI_CRM_Est_Total_QTY_std_Btl__c,
																	ASI_CRM_Key_Sub_brand__c,
																	ASI_CRM_Max_Incentive__c,
																	ASI_CRM_Module__c,
																	ASI_CRM_Module__r.ASI_CRM_Methodology__r.ASI_CRM_Sequence__c,
																	ASI_CRM_Module__r.ASI_CRM_Methodology__r.Name,
																	ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
																	ASI_CRM_Product_Category__c,
																	ASI_CRM_Sub_Brand_Grade__c,
																	ASI_CRM_Type__c,
																	ASI_CRM_Volume_Base__c 
															FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                            WHERE ASI_CRM_CN_Contract__c = :PageId] )
        {
            
            if(ModuleMap.containsKey(BRSFLine.ASI_CRM_Module__c)){
            	if(BRSFLine.ASI_CRM_Type__c=='BRSF'){
                    BRSFModule=ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                }
                if(BRSFLine.ASI_CRM_Type__c=='PSF' && !PSFIdSet.contains(BRSFLine.ASI_CRM_Module__c) ||
                	(BRSFLine.ASI_CRM_Type__c=='Display' && !DisplayIdSet.contains(BRSFLine.ASI_CRM_Module__c))){
                    ASI_CRM_Module__c TempModule =ModuleMap.get(BRSFLine.ASI_CRM_Module__c);
                    if(BRSFLine.ASI_CRM_Type__c=='PSF' && !PSFIdSet.contains(BRSFLine.ASI_CRM_Module__c)){
		                PSFModuleList.add(TempModule);
	                    PSFIdSet.add(BRSFLine.ASI_CRM_Module__c);

	                    if(!PSF_Item_Map.containsKey(BRSFLine.ASI_CRM_Module__c)){
	                        PSF_Item_Map.put(BRSFLine.ASI_CRM_Module__c, TempModule);
	                    }
                    }
                    if (BRSFLine.ASI_CRM_Type__c=='Display' && !DisplayIdSet.contains(BRSFLine.ASI_CRM_Module__c)){
                    	DisplayModuleList.add(TempModule);
	                    DisplayIdSet.add(BRSFLine.ASI_CRM_Module__c);

	                    if(!Display_Item_Map.containsKey(BRSFLine.ASI_CRM_Module__c)){
	                        Display_Item_Map.put(BRSFLine.ASI_CRM_Module__c, TempModule);
	                    }
                    }

                }
                IF(BRSFLine.ASI_CRM_Type__c=='PSF'){
                    PSFDetailTotal.ContractTotalFees += BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c !=null?BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c : 0;
                    PSFDetailTotal.EstimateTotalFees += BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c!=null?BRSFLine.ASI_CRM_CN_Est_Total_Dummy__c : 0;
                }

            }
        }
        DataFixing(MonthMapping);
      
        return true;
    }
    
    

    
    
    
    

    
    
    public void DataFixing( map<integer, string> MonthMapping){
    	List<ASI_HK_CRM_Product_Category__c> productCategoryList = [SELECT name, ASI_HK_CRM_English_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_HK_CRM_Sequence__c
			        													FROM ASI_HK_CRM_Product_Category__c
			        													WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Product_Category'
			        													AND ASI_HK_CRM_English_Name__c != 'RTD'
			        													AND ASI_HK_CRM_English_Name__c != 'Baijiu'
			        													ORDER BY ASI_HK_CRM_Sequence__c];
        for (ASI_HK_CRM_Product_Category__c productCategory : productCategoryList){
        	String categoriesMapKey = productCategory.ASI_HK_CRM_Sequence__c + '. ' + productCategory.ASI_HK_CRM_English_Name__c + ' - ' + productCategory.ASI_CRM_CN_Chinese_Name__c;
        	categoriesMap.put(productCategory.ASI_HK_CRM_English_Name__c, 0);
        	categoriesDisplayMap.put(categoriesMapKey, productCategory.ASI_HK_CRM_English_Name__c);

        	fillMap(HistoricalV00Contract.CategoryVolumeMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(HistoricalVFinalContract.CategoryVolumeMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(HistoricalContractCompared.CategoryVolumeMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(NewContractV0Estimate.CategoryVolumeMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(NewContactV0Contract.CategoryVolumeMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);

        	fillMap(HistoricalV00Contract.CategoryValueMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(HistoricalVFinalContract.CategoryValueMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(HistoricalContractCompared.CategoryValueMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(NewContractV0Estimate.CategoryValueMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(NewContactV0Contract.CategoryValueMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);

        	fillMap(HistoricalV00Contract.CategoryGSMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(HistoricalVFinalContract.CategoryGSMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(HistoricalContractCompared.CategoryGSMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(NewContractV0Estimate.CategoryGSMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(NewContactV0Contract.CategoryGSMap, productCategory.ASI_HK_CRM_English_Name__c, 0.0);

        	if (HistoricalV00Contract.PSFLineMap.get('00000null') == null){
        		HistoricalV00Contract.PSFLineMap.put('00000null', new ASI_CRM_CN_OffContractUtilitiesClass.contractLine());
        	}
        	if (NewContactV0Contract.PSFLineMap.get('00000null') == null){
        		NewContactV0Contract.PSFLineMap.put('00000null', new ASI_CRM_CN_OffContractUtilitiesClass.contractLine());
        	}
        	if (NewContractV0Estimate.PSFLineMap.get('00000null') == null){
        		NewContractV0Estimate.PSFLineMap.put('00000null', new ASI_CRM_CN_OffContractUtilitiesClass.contractLine());
        	}

        	fillMap(HistoricalAAndP_Map, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        	fillMap(ContractAAndP_Map, productCategory.ASI_HK_CRM_English_Name__c, 0.0);
        }
        system.debug('categoriesMap:' + categoriesMap);
        system.debug('categoriesDisplayMap:' + categoriesDisplayMap);

        //Edit: All data in Investment by Category used Estimate instead of Contract value
        //PSF: [Contract FI].PSFLineMap.EstimatePSFFees
        //Display: Contract's ASI_CRM_CN_Expected_V0_Display_Est_Total__c
        //Others: [Contract FI].OtherExpensesMap.EstimateFees

        //Calculate A&P by category: PSF (By Sub-brand) + PSF (By Category) + ((PSF (By Total) + Display + Other Cost) * Category% )
        // 		Category% = Category's Contract Purchase Value / All Contract Purchase Value

        //PSF (By Sub-brand) + PSF (By Category)
        if (HistoricalV00Contract.PSFLineMap != null && HistoricalV00Contract.PSFLineMap.size() > 0){
        	for(String ContractLineKey:HistoricalV00Contract.PSFLineMap.keySet()){
	        	ASI_CRM_CN_OffContractUtilitiesClass.ContractLine PSFLine = HistoricalV00Contract.PSFLineMap.get(ContractLineKey);
	        	HistoricalAAndP_Map = addToDecimalMap(HistoricalAAndP_Map, PSFLine.SubBrandCategory, PSFLine.EstimatePSFFees);
	        }
        }
        if (NewContactV0Contract.PSFLineMap != null && NewContactV0Contract.PSFLineMap.size() > 0){
        	for(String ContractLineKey:NewContactV0Contract.PSFLineMap.keySet()){
	        	ASI_CRM_CN_OffContractUtilitiesClass.ContractLine PSFLine = NewContactV0Contract.PSFLineMap.get(ContractLineKey);
	        	ContractAAndP_Map = addToDecimalMap(ContractAAndP_Map, PSFLine.SubBrandCategory, PSFLine.EstimatePSFFees);
	        }
        }

        //((PSF (By Total) + Display + Other Cost) * Category%
        Decimal historicalCost, contractCost;
        if (HistoricalV00Contract.TradeExpenses != null && HistoricalV00Contract.PSFExpensesTotal != null)
        	historicalCost = HistoricalV00Contract.TradeExpenses - HistoricalV00Contract.PSFExpensesTotal + HistoricalV00Contract.PSFLineMap.get('00000null').ContractPSFFees;
        if (NewContractV0Estimate.TradeExpenses != null && NewContractV0Estimate.PSFExpensesTotal != null)
        	contractCost = NewContractV0Estimate.TradeExpenses - NewContractV0Estimate.PSFExpensesTotal + NewContactV0Contract.PSFLineMap.get('00000null').EstimatePSFFees;
        system.debug('NewContractV0Estimate.TradeExpenses - NewContractV0Estimate.PSFExpensesTotal + NewContactV0Contract.PSFLineMap.get(\'00000null\').EstimatePSFFees;');
        system.debug('contractCost: ' + NewContractV0Estimate.TradeExpenses + ' - ' + NewContractV0Estimate.PSFExpensesTotal + ' + ' + NewContactV0Contract.PSFLineMap.get('00000null').EstimatePSFFees);

        for (ASI_HK_CRM_Product_Category__c productCategory : productCategoryList){
        	Decimal historicalCategoryPercentage = HistoricalV00Contract.Value > 0 ? HistoricalV00Contract.CategoryValueMap.get(productCategory.ASI_HK_CRM_English_Name__c)/HistoricalV00Contract.Value : 0;
        	Decimal contractCategoryPercentage = NewContractV0Estimate.Value > 0 ? NewContractV0Estimate.CategoryValueMap.get(productCategory.ASI_HK_CRM_English_Name__c)/NewContractV0Estimate.Value : 0;

        	HistoricalAAndP_Map = addToDecimalMap(HistoricalAAndP_Map, productCategory.ASI_HK_CRM_English_Name__c, historicalCost*historicalCategoryPercentage);
        	ContractAAndP_Map = addToDecimalMap(ContractAAndP_Map, productCategory.ASI_HK_CRM_English_Name__c, contractCost*contractCategoryPercentage);
        }
        


        SubBrandContractMap = new Map<String, ASI_CRM_CN_OffContractUtilitiesClass.ContractLine>(NewContactV0Contract.ContractLineMap);
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
            } else {
                //Data Fixing
                integer intlength = SubBrandContractMap.get(SubBrandContractKey).SubBrandName.length();
                if(intlength >= 4 && SubBrandContractMap.get(SubBrandContractKey).SubBrandName.contains('-')){
                    SubBrandContractMap.get(SubBrandContractKey).strSubBrand =  SubBrandContractMap.get(SubBrandContractKey).SubBrandName.substring(0, (intlength-4));
                }
                if(SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles!=null){
                    SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles = SubBrandContractMap.get(SubBrandContractKey).HistoricalBottles.setScale(0, RoundingMode.HALF_UP);
                }
                
                HistoricalTotalFees+=SubBrandContractMap.get(SubBrandContractKey).HistoricalTotalFees;
                Sum_EstimateTotalFees +=SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees!=null?SubBrandContractMap.get(SubBrandContractKey).EstimateTotalFees:0;
                Sum_ContractTotalFees +=SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees!=null? SubBrandContractMap.get(SubBrandContractKey).ContractTotalFees:0;
            }
        }

         if(HistoricalPSFEstTotal!=0 || PSFDetailTotal.EstimateTotalFees!=0 || PSFDetailTotal.ContractTotalFees!=0 ){
            ShowPSF_VXTable=true;
        }

        FixExpense_Map = new Map<String, ASI_CRM_CN_OffContractUtilitiesClass.ContractLine>(NewContactV0Contract.OtherExpensesMap);
        for(String ContractLineKey:HistoricalVFinalContract.OtherExpensesMap.keySet()){
            if(FixExpense_Map.containsKey(ContractLineKey)){
                FixExpense_Map.get(ContractLineKey).HistoricalFees = HistoricalVFinalContract.OtherExpensesMap.get(ContractLineKey).HistoricalFees;
            }else{
                FixExpense_Map.put(ContractLineKey, HistoricalVFinalContract.OtherExpensesMap.get(ContractLineKey));
            }
        }
        
        if(FixExpense_Map.size()>0){
            for(string FXMapKey:FixExpense_Map.keySet()){
                if(FixExpense_Map.get(FXMapKey).HistoricalFees==0 && FixExpense_Map.get(FXMapKey).EstimateFees==0 && FixExpense_Map.get(FXMapKey).ContractFees==0 ){
                    FixExpense_Map.remove(FXMapKey);
                }
            }
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
            
            HVfinalComparedContract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();
            
            if(HistoricalVFinalContract.Volumes !=0.0){
                HVfinalComparedContract.Volumes = ((NewContractV0Estimate.Volumes - HistoricalVFinalContract.Volumes)/HistoricalVFinalContract.Volumes)*100;
            }
            if(HistoricalV00Contract.Volumes !=0.0){
                HistoricalContractCompared.Volumes = ((HistoricalVFinalContract.Volumes-HistoricalV00Contract.Volumes)/HistoricalV00Contract.Volumes)*100;
            }
            if(HistoricalV00Contract.InvestmentCR12 !=0.0){
                HistoricalContractCompared.InvestmentCR12 = ((HistoricalVFinalContract.InvestmentCR12-HistoricalV00Contract.InvestmentCR12)/HistoricalV00Contract.InvestmentCR12)*100;
            }
            if(HistoricalV00Contract.OtherExpensesTotal !=0.0){
                HistoricalContractCompared.OtherExpensesTotal = ((HistoricalVFinalContract.OtherExpensesTotal-HistoricalV00Contract.OtherExpensesTotal)/HistoricalV00Contract.OtherExpensesTotal)*100;
            }
            
            if(HistoricalV00Contract.MarginAfterAnP !=0.0){
                HistoricalContractCompared.MarginAfterAnP = ((HistoricalVFinalContract.MarginAfterAnP-HistoricalV00Contract.MarginAfterAnP)/HistoricalV00Contract.MarginAfterAnP)*100;
            }

            HistoricalContractCompared.ROIIntake =HistoricalVFinalContract.ROIIntake-HistoricalV00Contract.ROIIntake;
            HistoricalContractCompared.ROIProForma =HistoricalVFinalContract.ROIProForma-HistoricalV00Contract.ROIProForma;
        } else {
            HistoricalVFinalContract.NoOfMonths=null;
            ExistHistoricalData=false;
        }
        
        
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
    
    public Map<String,Decimal> fillMap(Map<String,Decimal> inputMap, String key, Decimal defaultValue){
    	if (inputMap == null) return null;
    	if (!inputMap.containskey(key)){
    		inputMap.put(key,defaultValue);
    	}
    	return inputMap;
    }

    public static Map<String,Decimal> addToDecimalMap(Map<String,Decimal> fullMap, String key, Decimal value){
    	if (fullMap.containskey(key)){
    		fullMap.put(key, fullMap.get(key) + value);
    	} else {
    		fullMap.put(key, value);
    	}
    	return fullMap;
    }
}