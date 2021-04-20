/* Filename:    ASI_CRM_CN_HeavyBRSFFormCtrl.cls
* Author:       Laputa
* Purpose:      Controller for Payment BRSF
* Refernce :    ASI_CRM_CN_BRSFFormPDFPage, ASI_CRM_CN_BRSFForm_Cmpnt, ASI_CRM_CN_BRSFFormPDFCtrl
* Copyright 2017 Laputa Limited. All rights reserved.
* Customer confidential. Do not distribute.
* History     
* -----------------------------------------------------------------------------
* 2017-09-01    Laputa      Created

*/


public class ASI_CRM_CN_HeavyBRSFFormCtrl {
    
    public ASI_CRM_CN_HeavyBRSFFormCtrl() {
        
    }
    public Boolean HavePSFLine {set;get;} {HavePSFLine=true;}
    public String PageId {set;get;}
    public ASI_TH_CRM_PaymentRequest__c thisPR {set;get;}
    public Boolean HaveHistoricalPaymentSummary {set;get;}  {HaveHistoricalPaymentSummary=false;}
    public List<ASI_CRM_Module__c> HistoricalModuleList {set;get;} {HistoricalModuleList =new List<ASI_CRM_Module__c>();}
    public Map<string, interimData> BRSFMap {set;get;} {BRSFMap = NEW Map<string, interimData>();}
    public decimal HistoricalPaidAmount {set;get;}{HistoricalPaidAmount=0;}
    
    public ASI_CRM_Module__c BRSFModule {set;get;}{BRSFModule= new ASI_CRM_Module__c();}
        
    //public decimal payableVolSum {set;get;}
    //public decimal BottleSum {set;get;}
    //public decimal ActVolSum {set;get;}
    //public decimal CompletionRateSum {set;get;}
    public decimal PayableSum {set;get;}
    //public decimal BottleCollectionSum {set;get;}
    //public decimal BolColRateSum {set;get;}
    
    public string strPeriod {set;get;}
    public decimal ActualPayment {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    
    public ASI_CRM_CN_HeavyBRSFFormCtrl(ApexPages.StandardController controller) {
    }
    
    
    
    public boolean init(){
        BRSFModule= new ASI_CRM_Module__c();
        HistoricalPaidAmount=0; //PageId = ApexPages.currentPage().getParameters().get('id');
        
        try{
            thisPR = [SELECT id, Name, ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_OutletWS__r.Name,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Region__c, ASI_CRM_CN_Bottle_Collection_Rate__c
                      FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
        }catch(Exception e){
            String msg = 'Save Error : ' +e.getMessage() + '</br>';
            system.debug('Failed' +msg );
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyBRSFFormCtrl thisPR Try Exception:  class have Error  '+msg,'ASI_CRM_CN_HeavyBRSFFormCtrl','  Id: '+PageId);
        }
        
        BRSFMap = new Map<string, interimData>();
        if (thisPR != null){
            string strMonth1;
            string strMonth2;
            Date EndDate =RetrieveBRSFEndDate();
            if (thisPR.ASI_CRM_CN_PO_Start_Date__c != null && EndDate != null){
                if (thisPR.ASI_CRM_CN_PO_Start_Date__c.MONTH() <= 9)
                    strMonth1 = '0' + string.valueof(thisPR.ASI_CRM_CN_PO_Start_Date__c.MONTH());
                else
                    strMonth1 = string.valueof(thisPR.ASI_CRM_CN_PO_Start_Date__c.MONTH());
                
                if (EndDate.MONTH() <= 9)
                    strMonth2 = '0' + string.valueof(EndDate.MONTH());
                else
                    strMonth2 = string.valueof(EndDate.Month());
                strPeriod = thisPR.ASI_CRM_CN_PO_Start_Date__c.YEAR() + strMonth1 + ' - ' + EndDate.YEAR() + strMonth2;
            }else{
                strPeriod = '--';
            }
        }
        
        Set<Id> BRSFModuleParentSet = new Set<Id>();
        
        for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Completion_Ratio__c,ASI_CRM_Methodology__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Parent_Module__r.ASI_CRM_Payment_Reference__c,ASI_CRM_Parent_Module__r.ASI_CRM_Remark__c,
                                       ASI_CRM_Suggested_Payable_Amount__c,ASI_CRM_Parent_Module__r.ASI_CRM_Reason_NCD_Volume_Base__c,
                                       ASI_CRM_Parent_Module__r.ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Parent_Module__c,ASI_CRM_Methodology__r.ASI_CRM_Methodology_Code__c,
                                       ASI_CRM_End_Date__c,ASI_CRM_Parent_Module__r.ASI_CRM_Unit__c,ASI_CRM_Parent_Module__r.ASI_CRM_Volume_Base__c,ASI_CRM_Other_Comments__c,ASI_CRM_Overpayment_Reason__c,
                                       ASI_CRM_Actual_Payment__c,ASI_CRM_Adjustment__c,ASI_CRM_Application_Payment_Amount__c,ASI_CRM_Historical_Paid_Amount__c, ASI_CRM_Line_Type__c,ASI_CRM_Remark__c,ASI_CRM_Unit__c,
                                       ASI_CRM_Volume_Base__c,ASI_CRM_Methodology__c,ASI_CRM_Methodology__r.Name,ASI_CRM_Reason_Not_NCD_Methodology__c,ASI_CRM_Reason_NCD_Volume_Base__c  from ASI_CRM_Module__c 
                                       where ASI_CRM_Payment_Request__c =:thisPR.id and ASI_CRM_Line_Type__c='BRSF'])
        {
            BRSFModule= Module;
            HistoricalPaidAmount= Module.ASI_CRM_Historical_Paid_Amount__c!=NULL?Module.ASI_CRM_Historical_Paid_Amount__c:0;
            thisPR.ASI_CRM_CN_Adjustment__c=Module.ASI_CRM_Adjustment__c!=NULL?Module.ASI_CRM_Adjustment__c:0;
            ActualPayment= Module.ASI_CRM_Actual_Payment__c!=NULL?Module.ASI_CRM_Actual_Payment__c:0;
            BRSFModuleParentSet.add(Module.ASI_CRM_Parent_Module__c);
            
        }        
        
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> BRSFList = new  List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        
        BRSFList = [SELECT id, Name,ASI_CRM_CN_Over_Paid__c,ASI_CRM_Suggested_Value__c ,ASI_CRM_Module__c,ASI_CRM_Module__r.ASI_CRM_Parent_Module__c,ASI_CRM_CN_Actual_Vol__c, ASI_TH_CRM_Amount__c,ASI_CRM_CTD_Actual_Vol__c ,ASI_CRM_CTD_Cap_Collection_Vol__c, ASI_CRM_CN_Allow_Changing_Incentive__c ,ASI_CRM_CN_Bottle_Collected__c,ASI_CRM_CN_Collection_Rate__c, ASI_CRM_CN_Completion_Rate__c, ASI_CRM_CN_Offtake_Vol__c, ASI_CRM_CN_Payable_Vol__c, ASI_CRM_CN_Target_BT__c,ASI_CRM_CN_Total_Payable__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,  ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c, ASI_CRM_CN_Incentive_BT__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c
                    FROM ASI_TH_CRM_PaymentRequestLineItem__c
                    WHERE ASI_TH_CRM_Payment_Request__c = :thisPR.id
                    AND RecordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_BRSF'];
        if(BRSFList.size() > 0){
            integer i = 0;
            
            //offTakeSum = 0;
            //payableVolSum = 0;
            //BottleSum = 0;
            //ActVolSum = 0;
            //CompletionRateSum = 0;
            PayableSum = 0;
            //BottleCollectionSum = 0;
            //BolColRateSum = 0;
            string sbGradeSort;
            integer intlength; 
            integer intRP6;
            for (ASI_TH_CRM_PaymentRequestLineItem__c a : BRSFList){
                if(a.ASI_CRM_CN_Payable_Vol__c==null){
                    a.ASI_CRM_CN_Payable_Vol__c=0;
                }
                if(a.ASI_CRM_Suggested_Value__c==null){
                    a.ASI_CRM_Suggested_Value__c=0;
                }
                
                if(a.ASI_CRM_CN_Payable_Vol__c>a.ASI_CRM_Suggested_Value__c){
                    a.ASI_CRM_CN_Over_Paid__c=true;
                }else{
                    a.ASI_CRM_CN_Over_Paid__c=false;
                }
                
                if(a.ASI_CRM_Module__c!=null && a.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c!=null){
                    BRSFModuleParentSet.add(a.ASI_CRM_Module__r.ASI_CRM_Parent_Module__c);
                }
                
                
                i++;
                string sbGrade;
                string sbGrade_Chi;
                
                
                if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                    sbGrade = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                    if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null){
                        intlength = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c.length();
                        intRP6 = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c.lastIndexOf('-');
                        sbGrade_Chi = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                    }else{
                        sbGrade_Chi = '未有中文档次名称';
                    }
                }else{
                    sbGrade = 'No Sub Brand Grade specified';
                    sbGrade_Chi = '未指定档次';
                }
                if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                    sbGradeSort = sbGradeSorting(a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + sbGrade;
                }
                //BRSFMap
                
                if (BRSFMap.containskey(sbGradeSort)){
                    // Don't add empty record
                    if((a.ASI_CRM_CN_Incentive_BT__c != null && a.ASI_CRM_CN_Incentive_BT__c != 0) || (a.ASI_CRM_CN_Target_BT__c != null && a.ASI_CRM_CN_Target_BT__c != 0) ||
                       (a.ASI_CRM_CN_Actual_Vol__c != null && a.ASI_CRM_CN_Actual_Vol__c != 0) || (a.ASI_CRM_CN_Completion_Rate__c != null && a.ASI_CRM_CN_Completion_Rate__c != 0) ||
                       (a.ASI_CRM_CN_Total_Payable__c != null && a.ASI_CRM_CN_Total_Payable__c != 0) || (a.ASI_CRM_CN_Payable_Vol__c != null && a.ASI_CRM_CN_Payable_Vol__c != 0) || (a.ASI_CRM_CN_Bottle_Collected__c != null && a.ASI_CRM_CN_Bottle_Collected__c != 0) || (a.ASI_CRM_CN_Collection_Rate__c != null && a.ASI_CRM_CN_Collection_Rate__c != 0) ||
                       (a.ASI_CRM_CN_Offtake_Vol__c != null && a.ASI_CRM_CN_Offtake_Vol__c != 0)){
                           if(a.ASI_CRM_CN_Sub_Brand__r.Name != null){
                               intlength = a.ASI_CRM_CN_Sub_Brand__r.Name.length();
                               intRP6 = a.ASI_CRM_CN_Sub_Brand__r.Name.lastIndexOf('-');     
                               if(intlength >= 4 && intRP6 == (intlength-4)){
                                   a.ASI_CRM_CN_Sub_Brand__r.Name = a.ASI_CRM_CN_Sub_Brand__r.Name.substring(0, (intlength-4));
                               }
                           }
                           BRSFMap.get(sbGradeSort).PaymentRequestLine.add(a);
                       }
                    
                }else{
                    interimData TempData = new interimData(); 
                    BRSFMap.put(sbGradeSort, TempData);
                    
                    if((a.ASI_CRM_CN_Incentive_BT__c != null && a.ASI_CRM_CN_Incentive_BT__c != 0) || (a.ASI_CRM_CN_Target_BT__c != null && a.ASI_CRM_CN_Target_BT__c != 0) ||
                       (a.ASI_CRM_CN_Actual_Vol__c != null && a.ASI_CRM_CN_Actual_Vol__c != 0) || (a.ASI_CRM_CN_Completion_Rate__c != null && a.ASI_CRM_CN_Completion_Rate__c != 0) || (a.ASI_CRM_CN_Total_Payable__c != null && a.ASI_CRM_CN_Total_Payable__c != 0) || (a.ASI_CRM_CN_Payable_Vol__c != null && a.ASI_CRM_CN_Payable_Vol__c != 0) || (a.ASI_CRM_CN_Bottle_Collected__c != null && a.ASI_CRM_CN_Bottle_Collected__c != 0) ||
                       (a.ASI_CRM_CN_Collection_Rate__c != null && a.ASI_CRM_CN_Collection_Rate__c != 0) || (a.ASI_CRM_CN_Offtake_Vol__c != null && a.ASI_CRM_CN_Offtake_Vol__c != 0)){
                           if(a.ASI_CRM_CN_Sub_Brand__r.Name != null){
                               intlength = a.ASI_CRM_CN_Sub_Brand__r.Name.length();
                               intRP6 = a.ASI_CRM_CN_Sub_Brand__r.Name.lastIndexOf('-');     
                               if(intlength >= 4 && intRP6 == (intlength-4)){
                                   a.ASI_CRM_CN_Sub_Brand__r.Name = a.ASI_CRM_CN_Sub_Brand__r.Name.substring(0, (intlength-4));
                               }
                           }
                           BRSFMap.get(sbGradeSort).SBGradeCN = sbGrade_Chi;
                           BRSFMap.get(sbGradeSort).PaymentRequestLine.add(a);
                           //newBRSFList.add(a);
                       }
                    /*if(newBRSFList != null && newBRSFList.size() > 0){SBgrade_map.put(sbGrade_Chi, newBRSFList);BRSFList_Map.put(sbGradeSort, SBgrade_map);} */
                }
                
                
                
                if (a.ASI_CRM_CN_Offtake_Vol__c != null){
                    //offTakeSum += a.ASI_CRM_CN_Offtake_Vol__c;
                    BRSFMap.get(sbGradeSort).TotalOfftakeVol += a.ASI_CRM_CN_Offtake_Vol__c;
                }
                
                if (a.ASI_CRM_CN_Payable_Vol__c != null){
                    //payableVolSum += a.ASI_CRM_CN_Payable_Vol__c;
                    BRSFMap.get(sbGradeSort).TotalPayableVol += a.ASI_CRM_CN_Payable_Vol__c;
                }
                
                if (a.ASI_CRM_CN_Target_BT__c != null){
                    //BottleSum += a.ASI_CRM_CN_Target_BT__c;
                    BRSFMap.get(sbGradeSort).TotalBottle += a.ASI_CRM_CN_Target_BT__c;
                }
                
                if (a.ASI_CRM_CN_Actual_Vol__c != null){
                    //ActVolSum += a.ASI_CRM_CN_Actual_Vol__c;
                    BRSFMap.get(sbGradeSort).TotalActVol += a.ASI_CRM_CN_Actual_Vol__c;
                }
                
                if (a.ASI_CRM_CN_Total_Payable__c != null){
                    BRSFMap.get(sbGradeSort).TotalPayable += a.ASI_CRM_CN_Total_Payable__c;
                    PayableSum += a.ASI_CRM_CN_Total_Payable__c;
                }
                
                
                if (a.ASI_CRM_CN_Bottle_Collected__c != null){
                    BRSFMap.get(sbGradeSort).TotalBtlCollection += a.ASI_CRM_CN_Bottle_Collected__c;
                    //BottleCollectionSum += a.ASI_CRM_CN_Bottle_Collected__c;
                }

/*                
                if (thisPR.ASI_CRM_CN_Adjustment__c != null && PayableSum != null){
                    ActualPayment = PayableSum * thisPR.ASI_CRM_CN_Adjustment__c / 100;
                }else if (thisPR.ASI_CRM_CN_Adjustment__c == null && PayableSum != null){
                    ActualPayment = PayableSum;
                }
               */
            }           
            
        }
        else{
            HavePSFLine=false;
        }
        
        
        
        if(BRSFModuleParentSet.size()>0){
            // Getting Historical Module List 
            list<ASI_CRM_Module__c> HistoricalPaidModulelist = ASI_CRM_CN_HeavyContractUtilitiesClass.HistoricalModuleQuerying(BRSFModuleParentSet , thisPR.id);
            for(ASI_CRM_Module__c ModuleItem:HistoricalPaidModulelist){
                HistoricalModuleList.add(ModuleItem);
                HaveHistoricalPaymentSummary=true;
                
                
            }
        }
        
        return true;
    }
    
    
    
    private Date RetrieveBRSFEndDate(){
        Date BRSFEndDate = system.today();
        for(ASI_CRM_Module__c Module: [select Id,ASI_CRM_Line_Type__c,ASI_CRM_Parent_Module__c,ASI_CRM_End_Date__c from ASI_CRM_Module__c where ASI_CRM_Payment_Request__c =:PageId ]){
            if(Module.ASI_CRM_Line_Type__c=='BRSF'){
                BRSFEndDate=Module.ASI_CRM_End_Date__c;
            }
        }
        return BRSFEndDate;
    }
    
    public class interimData{
        public decimal TotalBottle {set;get;}{TotalBottle=0.0;}
        public decimal TotalActVol {set;get;} {TotalActVol=0.0;}
        public decimal TotalCompletionRate {set;get;} {TotalCompletionRate=0.0;}
        public decimal TotalPayable {set;get;} {TotalPayable=0.0;}
        public decimal TotalPayableVol {set;get;} {TotalPayableVol=0.0;}
        public decimal TotalBtlCollection {set;get;} {TotalBtlCollection=0.0;}
        public decimal TotalBoCollectionRate {set;get;} {TotalBoCollectionRate=0.0;}
        public decimal TotalOfftakeVol {set;get;} {TotalOfftakeVol=0.0;} 
        public decimal RowNo {set;get;} {RowNo=0.0;}
        
        
        
        public String SBGradeCN {set;get;} {SBGradeCN = '';}
        public List<ASI_TH_CRM_PaymentRequestLineItem__c> PaymentRequestLine {set;get;} {PaymentRequestLine =new List<ASI_TH_CRM_PaymentRequestLineItem__c>(); }
        public interimData(){ }
    }
    
    public string SBGradeSorting(decimal strSeq){
        string returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = '0000' + string.valueof(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString = '000' + string.valueof(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString = '00' + string.valueof(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = '0' + string.valueof(strSeq);
            }
        }else{
            returnString = '00000';
        }
        system.debug('SBGradeSorting: ' + returnString);
        return returnString;
    }
    
    
}