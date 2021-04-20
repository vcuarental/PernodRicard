/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffPOModificationPDFCtrl
 * Description: Apex class for ASI_CRM_CN_OffPOModificationPDFCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-16       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_OffPOModificationPDFCtrl {
    public id currentHeaderId {set;get;}
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public boolean boolCheckCCPeriod {set;get;}
    public string strPDF {set;get;}
    public ASI_CRM_CN_OffPOModificationPDFCtrl(){ }
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator V0Contract  {set;get;} {
        V0Contract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();
    }
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator HistoricalContract  {set;get;} {
        HistoricalContract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();
    }
    public ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator CurrentContract  {set;get;} {
        CurrentContract = new ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator ();
    }

    public string td_end {set;get;}
    public string positiveGreen {set;get;}
    public string negativeRed {set;get;}
    public string normalBlack {set;get;}
    public string positiveGreen_bottom {set;get;}
    public string negativeRed_bottom {set;get;}
    public string normalBlack_bottom {set;get;}

    public string positiveGreen_Top_bottom {set;get;}
    public string negativeRed_Top_bottom {set;get;}
    public string normalBlack_Top_bottom {set;get;}


    //get Contract Approval Comments
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}{lstApprovalComment= new List<ASI_CRM_Approval_Comment__c> ();}
    public String ApprovalComment {set;get;}

    public list<ASI_CRM_CN_ContractOffUtilClass.PaymentSummary> paymentRequestSummary {set;get;}
    public boolean ADorAbove {set;get;}
    public Decimal Mod_VCost {set;get;} {Mod_VCost=0.0;}
    public Decimal ActVSEst_Vol  {set;get;} {ActVSEst_Vol=0.0;}
    public Decimal strv0FixCost  {set;get;} {strv0FixCost=0.0;}
    public boolean boolFixedCost {set;get;}
    public boolean boolVariableCost {set;get;}
    public Decimal GrossSalesRateVariance  {set;get;} {GrossSalesRateVariance =0.0;}
    public Integer CurrentCoveredOutletSize {set;get;}{CurrentCoveredOutletSize=0;}
    public Integer PreviousCoveredOutletSize {set;get;}{PreviousCoveredOutletSize=0;}
    public Decimal theoreticalDisplayCost {get; set;} {theoreticalDisplayCost = 0.0;}
    
    public String addOutletListString {get; set;} { addOutletListString = ''; }
    public String removeOutletListString {get; set;} { removeOutletListString = ''; }

    public ASI_CRM_CN_CustomSetting__c CustomSetting{set;get;}
    public Decimal RevisedEstAmount{get;set;}{RevisedEstAmount=0.0;}
    public Boolean showEstVsTotal{get;set;}//show Revised Est Amount%Contract Amount
    public Decimal EstVsTotalValue{get;set;}{EstVsTotalValue = 0.0;}//the value of Revised Est Amount%Contract Amount

    public boolean init(){
        positiveGreen = '<td style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed = '<td style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack = '<td style="border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';


        positiveGreen_bottom = '<td style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed_bottom = '<td style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack_bottom = '<td style="border-bottom:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';
        td_end = '</td>';

        positiveGreen_Top_bottom = '<td style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#FF0000;">';
        negativeRed_Top_bottom = '<td style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;color:#33CC33;">';
        normalBlack_Top_bottom = '<td style="border-bottom:1px solid black;border-top:1px solid black;border-left:1px solid black;border-right:1px solid black;text-align:right;margin-left:30px;">';

        this.ContractSelected = [SELECT Id,
							            Name,
										Owner.Name,
										createddate,
										lastModifiedDate,
										recordtypeid,
										ASI_CRM_CN_Bottle_Collection_Rate__c,
										ASI_CRM_CN_Budget_LE__c,
										ASI_CRM_CN_Business_License__c,
										ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c,
										ASI_CRM_CN_Contract_Fixed_Cost_Total__c,
										ASI_CRM_CN_Contract_Upload__c,
										ASI_CRM_CN_Currency__c,
										ASI_CRM_CN_Description__c,
										ASI_CRM_CN_Effective_Date__c,
										ASI_CRM_CN_Exchange_Rate__c,
										ASI_CRM_CN_Expected_BRSF_Est_Total__c,
										ASI_CRM_CN_Expected_Display_Est_Total__c,
										ASI_CRM_CN_Expected_PSF_Est_Total__c,
										ASI_CRM_CN_Group_Contract__r.Name,
										ASI_CRM_CN_Last_PO_version__c,
										ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c,
										ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,
										ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__c,
										ASI_CRM_CN_Last_PO_version__r.ASI_CRM_National_Group__r.Name,
										ASI_CRM_CN_Last_Rejected_Date__c,
										ASI_CRM_CN_Last_Submitted_Date__c,
										ASI_CRM_CN_National_Group_Contract__c,
										ASI_CRM_CN_No_of_Months__c,
										ASI_CRM_CN_Outlet_WS__c,
										ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name,
										ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,
										ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,
										ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,
										ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_NewChannel__r.Name,
										ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_New_Image__c,
										ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name,
										ASI_CRM_CN_Outlet_WS__r.Name,
										ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,
										ASI_CRM_CN_PO_End_Date__c,
										ASI_CRM_CN_PO_Modification__c,
										ASI_CRM_CN_PO_No__c,
										ASI_CRM_CN_PO_Start_Date__c,
										ASI_CRM_CN_PO_Version__c,
										ASI_CRM_CN_PP_No__c,
										ASI_CRM_CN_Reason_without_Budget__c,
										ASI_CRM_CN_Source_Others__c,
										ASI_CRM_CN_Source_of_Contract__c,
										ASI_CRM_CN_Special_Promotion__c,
										ASI_CRM_CN_Status__c,
										ASI_CRM_CN_Total_Contract_Amount__c,
										ASI_CRM_CN_Vol_Budget_LE__c,
										ASI_CRM_Copied_From__c,
										ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_BRSF_Est_Total__c,
										ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_Display_Est_Total__c,
										ASI_CRM_Copied_From__r.ASI_CRM_CN_Expected_PSF_Est_Total__c,
										ASI_CRM_Copied_From__r.ASI_CRM_EVC_Cost_Estimate_Total__c,
										ASI_CRM_EVC_Cost_Estimate_Total__c,
										ASI_CRM_Investment_Type__c,
										ASI_CRM_National_Group__c,
										ASI_CRM_National_Group__r.Name,
										ASI_CRM_New_FY_PO__c,
										ASI_CRM_PO_Channel__c,
										ASI_CRM_PO_Channel__r.Name,
										ASI_CRM_PO_City__c,
										ASI_CRM_PO_City__r.Name,
										ASI_CRM_PO_Province__c,
										ASI_CRM_PO_Province__r.Name,
										ASI_CRM_PSFGrand_ContractTotal_BeforeAdj__c,
										ASI_CRM_PSF_Contract_Adjustment_Amount__c,
										ASI_CRM_PSF_Estimate_Adjustment_Amount__c,
										ASI_CRM_PSF_Grand_Contract_Total__c,
										ASI_CRM_PSF_Grand_Estimate_Total__c,
										ASI_CRM_PSF_Grd_Est_Total_before_Adj__c,
										ASI_CRM_Volume_Option__c,
										ASI_TH_CRM_Promotion_Type__c,
										ASI_TH_CRM_Summary_Contract_Spending__c,
            ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_CN_Total_RContract_Amount__c,ASI_CRM_CN_Is_Dolphin__c,
        								(SELECT Id, 
        									Name, 
        									ASI_CRM_CN_Last_Payment__c, 
        									ASI_TH_CRM_Contract__c,
        									ASI_CRM_CN_PO_Version__c, 
        									ASI_CRM_CN_PO_Start_Date__c,
        									ASI_CRM_CN_PO_End_Date__c,
        									ASI_TH_CRM_Status__c,
        									ASI_CRM_CN_Channel__c, 
        									ASI_CRM_CN_Total_Payment__c,
        									ASI_CRM_CN_Paid__c,
        									ASI_CRM_CN_Paid_In_Progress__c, 
        									ASI_CRM_CN_Payment_Raised_Date__c
        								FROM ASI_TH_CRM_PaymentRequests_Contract__r)
							        FROM ASI_TH_CRM_Contract__c
							        WHERE id =:currentHeaderId ];


        List<ASI_CRM_CN_Covered_Outlet__c> CurrentContractOutletList = [SELECT id, 
        																	ASI_CRM_CN_Contract__c, 
        																	ASI_CRM_CN_Outlet__r.Name
        																FROM ASI_CRM_CN_Covered_Outlet__c   
        																WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id];
        																
		List<ASI_CRM_CN_Covered_Outlet__c> PreviousContractOutletList = [SELECT id, 
																			ASI_CRM_CN_Contract__c,
																			ASI_CRM_CN_Outlet__r.Name 
																		FROM ASI_CRM_CN_Covered_Outlet__c   
																		WHERE ASI_CRM_CN_Contract__c = :ContractSelected.ASI_CRM_CN_Last_PO_version__c];
        CurrentCoveredOutletSize = CurrentContractOutletList.size();
        PreviousCoveredOutletSize = PreviousContractOutletList.size();
		
		//Compare Outlet List
		//1. Get all Current Outlet Name (A)
		//2. Compare with Previous Outlet Name (B)
		//3A. If (A and not B), it is added
		//3D. If (B and not A), it is removed
		Set<String> currentOutletNameSet = new Set<String>();
		List<String> addOutletNameList = new List<String>();
		List<String> removeOutletNameList = new List<String>();
		
		for (ASI_CRM_CN_Covered_Outlet__c outlet : CurrentContractOutletList){
			if (outlet.ASI_CRM_CN_Outlet__c != null){
				currentOutletNameSet.add(outlet.ASI_CRM_CN_Outlet__r.Name);
			}
		}
		
		for (ASI_CRM_CN_Covered_Outlet__c previousOutlet : PreviousContractOutletList){
			if (previousOutlet.ASI_CRM_CN_Outlet__c != null){
				if (!currentOutletNameSet.contains(previousOutlet.ASI_CRM_CN_Outlet__r.Name)){
					removeOutletNameList.add(previousOutlet.ASI_CRM_CN_Outlet__r.Name);
				}
				currentOutletNameSet.remove(previousOutlet.ASI_CRM_CN_Outlet__r.Name);	
			}
		}
		addOutletNameList.addAll(currentOutletNameSet);
		
		addOutletListString = String.join(addOutletNameList, '\r\n');
		removeOutletListString = String.join(removeOutletNameList , '\r\n');
		
		//Compare Outlet List END

        lstApprovalComment = [SELECT id, 
        							recordtypeid, 
        							ASI_CRM_BA_comments__c, 
        							ASI_CRM_Background_Objective__c,
        							ASI_CRM_New_contract_Analsysis__c, 
        							ASI_CRM_Historical_Contract_Performance__c 
        						FROM ASI_CRM_Approval_Comment__c
        						WHERE ASI_CRM_Contract__c =:ContractSelected.id];
        if(lstApprovalComment==null || lstApprovalComment.size()==0){
            ApprovalComment ='';
            lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
        } else {
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
        List<ASI_Attachment__c> AttachmentList = [SELECT id,
        												ASI_CRM_Historical_Financial_Data__c,
        												ASI_CRM_Contract__c,
        												ASI_CRM_Type__c
        											FROM ASI_Attachment__c 
        											WHERE (ASI_CRM_Contract__c = :ContractSelected.Id OR ASI_CRM_Contract__c = :ContractSelected.ASI_CRM_CN_V0_0_PO_version__c)
        											AND (ASI_CRM_Type__c ='Contract Data' 
        												OR ASI_CRM_Type__c ='PO Modification Data'
        												OR ASI_CRM_Type__c ='Historical Modi Data')];
        if(AttachmentList.size()>0){
            for(ASI_Attachment__c att:AttachmentList){
                String JsonString = att.ASI_CRM_Historical_Financial_Data__c.replaceAll('&quot;','"');
                List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator> ContractList =(List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>)System.JSON.deserialize(JsonString,List<ASI_CRM_CN_OffContractUtilitiesClass.FinancialIndicator>.class);
                if (att.ASI_CRM_Type__c=='Contract Data' && ContractList.size() == 2){
                    V0Contract= ContractList[1]; // Contract Data
                } else if (att.ASI_CRM_Type__c=='Historical Modi Data' && ContractList.size() > 0){
                	HistoricalContract = ContractList[0];
                }else if(att.ASI_CRM_Type__c=='PO Modification Data' && ContractList.size()>0 ){
                    CurrentContract= ContractList[0]; //POModiContractFI
                    Map<String,Decimal> TempMap = (Map<String,Decimal>)System.JSON.deserialize(ContractList[0].AddOnString,Map<String,Decimal>.class);
                    if( TempMap.containsKey('ActVSEst_Vol')  ){
                        ActVSEst_Vol= TempMap.get('ActVSEst_Vol');
                    }


                }
            }
        }
		theoreticalDisplayCost = ContractSelected.ASI_CRM_CN_Expected_Display_Est_Total__c;
        paymentRequestSummary = ASI_CRM_CN_ContractOffUtilClass.PaymentSummaryTable(ContractSelected);
		system.debug('paymentRequestSummary: ' + paymentRequestSummary);
        List<integer> lstRemove = new List<integer>();
        Integer indexNum=0;
        integer c = 0;
        if (paymentRequestSummary != null && paymentRequestSummary.size() > 0){
            for(ASI_CRM_CN_ContractOffUtilClass.PaymentSummary displayLine:paymentRequestSummary){
                if(displayLine.LastVersion_POEstimatedAmount==0 && displayLine.PaymentRequestAmount==0 && displayLine.POEstimatedAmount==0){
                    //paymentRequestSummary.remove(indexNum);
                    lstRemove.add(indexNum);
                }
                indexNum++;
            }

            for(integer n : lstRemove){
                if(n!=0){
                    if(c>0)
                        n=n-c;
                    paymentRequestSummary.remove(n);
                    c++;
                }else{
                    paymentRequestSummary.remove(0);
                    c++;
                }
            }
        }
        
        //Calculation
        if(V0Contract.GrossSalesRate !=0 && V0Contract.GrossSalesRate !=null){
            GrossSalesRateVariance = ((CurrentContract.GrossSalesRate - V0Contract.GrossSalesRate)/V0Contract.GrossSalesRate)*100;
        }

        if(ContractSelected != null && ContractSelected.ASI_CRM_CN_Last_PO_version__c !=null){
            if(ContractSelected.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c == ContractSelected.ASI_CRM_CN_PO_Start_Date__c && ContractSelected.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c == ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                boolCheckCCPeriod = true;
            }
            else{
                boolCheckCCPeriod = false;
            }
        }

        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>  ContractLineList = [SELECT ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c,ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_CN_Contract_Monthly_Vol9L__c,ASI_CRM_CN_Estimate_Volume_9L_Month__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
        FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id];

        //Mod_VCost+=ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c!=NULL?ContractSelected.ASI_CRM_CN_Expected_BRSF_Est_Total__c:0;
        Mod_VCost+=ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c!=NULL?ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c:0;
        //Mod_VCost+=ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c!=NULL?ContractSelected.ASI_CRM_EVC_Cost_Estimate_Total__c:0;


        //ContractSelected.ASI_CRM_CN_Expected_PSF_Est_Total__c,ASI_CRM_CN_Expected_BRSF_Est_Total__c,ASI_CRM_EVC_Cost_Estimate_Total__c,
        if (ContractSelected != null && ContractSelected.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c != null)
            strv0FixCost = ContractSelected.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c;


        if((ActVSEst_Vol == null || ActVSEst_Vol == 0) && (Mod_VCost == null || Mod_VCost == 0) && (theoreticalDisplayCost == 0 || theoreticalDisplayCost == null) )
            boolVariableCost = false;
        else
            boolVariableCost = true;

        if((strv0FixCost == null || strv0FixCost == 0) && (ContractSelected.ASI_CRM_CN_Contract_Fixed_Cost_Total__c == null || ContractSelected.ASI_CRM_CN_Contract_Fixed_Cost_Total__c == 0))
            boolFixedCost = false;
        else
            boolFixedCost = true;



        if (strPDF == '1'){
            ADorAbove = ASI_CRM_CN_OffContractUtilitiesClass.checkUserID();
        }else if (strPDF == '0'){
            ADorAbove=ASI_CRM_CN_OffContractUtilitiesClass.checkApprover(ContractSelected.id);
        }

		V0Contract.DataRounding();
		CurrentContract.DataRounding();

        if(ContractSelected.ASI_CRM_CN_Is_Dolphin__c){
            CustomSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
                for(ASI_CRM_CN_ContractOffUtilClass.PaymentSummary displayLine:paymentRequestSummary){
                    RevisedEstAmount+=displayLine.POEstimatedAmount;
                }

                if(RevisedEstAmount <= (ContractSelected.ASI_CRM_CN_Total_RContract_Amount__c*CustomSetting.ASI_CRM_CN_Dolphin_POModi_Threshold__c/100)){
                    showEstVsTotal = true;
                }else{
                    showEstVsTotal = false;
                }
                if(RevisedEstAmount!=0 && RevisedEstAmount!=null && ContractSelected.ASI_CRM_CN_Total_RContract_Amount__c!=0 && ContractSelected.ASI_CRM_CN_Total_RContract_Amount__c!=null){
                    EstVsTotalValue = RevisedEstAmount/ContractSelected.ASI_CRM_CN_Total_RContract_Amount__c*100;
                }
        }

        return true;
    }




    public String SplitLineIntoRow(String InputString,integer CutNumber ){
        String outputString ='';
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
                outputString =  InputString;
            }
        }
        return outputString;
    }

}