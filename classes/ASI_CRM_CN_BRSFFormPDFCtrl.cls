/***********************************************************
Created by Stella Sing (IntroV Limited)     7 May 2014
Modified by Stella Sing (IntroV Limited)    4 June 2014

************************************************************/
public with sharing class ASI_CRM_CN_BRSFFormPDFCtrl {

    public ASI_CRM_CN_BRSFFormPDFCtrl() {

    }

    public String PageId {set;get;}
    public ASI_TH_CRM_PaymentRequest__c thisPR {set;get;}
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> BRSFList {set;get;}
    public Map<string, Map <string,List<ASI_TH_CRM_PaymentRequestLineItem__c>>> BRSFList_Map {set;get;}
    public Map<string, BRSFTotal> BRSFTotal_Map {set;get;}
    //20151201 Ben @ Elufa System
    public decimal offTakeSum {set;get;}
    public decimal payableVolSum {set;get;}
    //20151201 End
    public decimal BottleSum {set;get;}
    public decimal ActVolSum {set;get;}
    public decimal CompletionRateSum {set;get;}
    public decimal PayableSum {set;get;}
    public decimal BottleCollectionSum {set;get;}
    public decimal BolColRateSum {set;get;}
    public string strPeriod {set;get;}
    public decimal ActualPayment {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public ASI_CRM_CN_BRSFFormPDFCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
        try {
             thisPR = [SELECT id, Name, ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c, 
                        ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_OutletWS__r.Name, 
                        ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c,
                        ASI_CRM_CN_Region__c, ASI_CRM_CN_Bottle_Collection_Rate__c
                        FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
        }catch(Exception e){
            system.debug('thisPR Try Exception: ' + e);
        }
        init();
    }
    public boolean init(){
        BRSFList_Map = new Map<string, Map<string, List<ASI_TH_CRM_PaymentRequestLineItem__c>>>();
        BRSFTotal_Map = new Map<string, BRSFTotal>();
        system.debug('PageId: ' + PageId);
        if (thisPR != null){
            string strMonth1;
            string strMonth2;
            if (thisPR.ASI_CRM_CN_BRSF_Start_Date__c != null && thisPR.ASI_CRM_CN_BRSF_End_Date__c != null){
                if (thisPR.ASI_CRM_CN_BRSF_Start_Date__c.MONTH() <= 9)
                    strMonth1 = '0' + string.valueof(thisPR.ASI_CRM_CN_BRSF_Start_Date__c.MONTH());
                else
                    strMonth1 = string.valueof(thisPR.ASI_CRM_CN_BRSF_Start_Date__c.MONTH());
                if (thisPR.ASI_CRM_CN_BRSF_End_Date__c.MONTH() <= 9)
                    strMonth2 = '0' + string.valueof(thisPR.ASI_CRM_CN_BRSF_End_Date__c.MONTH());
                else
                    strMonth2 = string.valueof(thisPR.ASI_CRM_CN_BRSF_End_Date__c.Month());
                strPeriod = thisPR.ASI_CRM_CN_BRSF_Start_Date__c.YEAR() + strMonth1 + ' - ' + thisPR.ASI_CRM_CN_BRSF_End_Date__c.YEAR() + strMonth2;
            }else{
                strPeriod = '--';
            }
            
            BRSFList = [SELECT id, Name, 
                        ASI_CRM_CN_Actual_Vol__c, ASI_TH_CRM_Amount__c,ASI_CRM_CN_Bottle_Collected__c,
                        ASI_CRM_CN_Collection_Rate__c, ASI_CRM_CN_Completion_Rate__c, 
                        ASI_CRM_CN_Offtake_Vol__c, ASI_CRM_CN_Payable_Vol__c, ASI_CRM_CN_Target_BT__c,
                        ASI_CRM_CN_Total_Payable__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, 
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c, ASI_CRM_CN_Incentive_BT__c,
                        ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                        ASI_CRM_CN_Allow_Changing_Incentive__c//20151202 Ben @ Elufa System
                        FROM ASI_TH_CRM_PaymentRequestLineItem__c
                        WHERE ASI_TH_CRM_Payment_Request__c = :thisPR.id
                        AND RecordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_BRSF'];
            system.debug('BRSFList: ' + BRSFList.size());
            if (BRSFList.size() > 0){
                integer i = 0;
                //20151201 Ben @ Elufa Sytem
                offTakeSum = 0;
                payableVolSum = 0;
                //20151201 End
                BottleSum = 0;
                ActVolSum = 0;
                CompletionRateSum = 0;
                PayableSum = 0;
                BottleCollectionSum = 0;
                BolColRateSum = 0;
                string sbGradeSort;
                integer intlength; //Added by Twinkle 20141205
                integer intRP6; //Added by Twinkle 20141205
                for (ASI_TH_CRM_PaymentRequestLineItem__c a : BRSFList){
                    i++;
                    Map <string,List<ASI_TH_CRM_PaymentRequestLineItem__c>> SBgrade_map = new map<string, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();
                    List <ASI_TH_CRM_PaymentRequestLineItem__c> newBRSFList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
                    string sbGrade;
                    string sbGrade_Chi;
                    //20151201 Ben @ Elufa Sytem
                    if (a.ASI_CRM_CN_Offtake_Vol__c != null)
                        offTakeSum += a.ASI_CRM_CN_Offtake_Vol__c;
                    if (a.ASI_CRM_CN_Payable_Vol__c != null)
                        payableVolSum += a.ASI_CRM_CN_Payable_Vol__c;
                    //20151201 End
                    if (a.ASI_CRM_CN_Target_BT__c != null)
                        BottleSum += a.ASI_CRM_CN_Target_BT__c;
                    if (a.ASI_CRM_CN_Actual_Vol__c != null)
                        ActVolSum += a.ASI_CRM_CN_Actual_Vol__c;
                    if (a.ASI_CRM_CN_Total_Payable__c != null)
                        PayableSum += a.ASI_CRM_CN_Total_Payable__c;
                    if (thisPR.ASI_CRM_CN_Adjustment__c != null && PayableSum != null){
                        ActualPayment = PayableSum * thisPR.ASI_CRM_CN_Adjustment__c / 100;
                    }else if (thisPR.ASI_CRM_CN_Adjustment__c == null && PayableSum != null){
                        ActualPayment = PayableSum;
                    }
                    if (a.ASI_CRM_CN_Bottle_Collected__c != null)
                        BottleCollectionSum += a.ASI_CRM_CN_Bottle_Collected__c;
                    if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                        sbGrade = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        
                        if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c != null){
                            intlength = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c.length();
                            intRP6 = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c.lastIndexOf('-');     
                           /* if(intlength >= 4){
                                if(intRP6 == (intlength-4)){
                                    sbGrade_Chi = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c.substring(0, (intlength-4));
                                }
                                else{
                                    sbGrade_Chi = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                                }
*/
                            sbGrade_Chi = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_Chinese_Name__c;
                          //  }
                        }else{
                            sbGrade_Chi = '未有中文档次名称';
                    }
                    }else{
                        sbGrade = 'No Sub Brand Grade specified';
                        sbGrade_Chi = '未指定档次';
                    }
                    system.debug('sbGrade_Chi: ' + sbGrade_Chi);
                    system.debug('sbGrade: ' + sbGrade);
                    if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                        sbGradeSort = sbGradeSorting(a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c) + sbGrade;
                    }
                    
                    if (BRSFList_Map.containskey(sbGradeSort)){
                        system.debug('BRSFList_Map containskey');
                        //Added by Twinkle 20141205 - Don't add empty record
                        if((a.ASI_CRM_CN_Incentive_BT__c != null && a.ASI_CRM_CN_Incentive_BT__c != 0) ||
                            (a.ASI_CRM_CN_Target_BT__c != null && a.ASI_CRM_CN_Target_BT__c != 0) ||
                            (a.ASI_CRM_CN_Actual_Vol__c != null && a.ASI_CRM_CN_Actual_Vol__c != 0) ||
                            (a.ASI_CRM_CN_Completion_Rate__c != null && a.ASI_CRM_CN_Completion_Rate__c != 0) ||
                            (a.ASI_CRM_CN_Total_Payable__c != null && a.ASI_CRM_CN_Total_Payable__c != 0) ||
                            (a.ASI_CRM_CN_Payable_Vol__c != null && a.ASI_CRM_CN_Payable_Vol__c != 0) ||
                            (a.ASI_CRM_CN_Bottle_Collected__c != null && a.ASI_CRM_CN_Bottle_Collected__c != 0) ||
                            (a.ASI_CRM_CN_Collection_Rate__c != null && a.ASI_CRM_CN_Collection_Rate__c != 0) ||
                            (a.ASI_CRM_CN_Offtake_Vol__c != null && a.ASI_CRM_CN_Offtake_Vol__c != 0)){
                            if(a.ASI_CRM_CN_Sub_Brand__r.Name != null){
                                intlength = a.ASI_CRM_CN_Sub_Brand__r.Name.length();
                                intRP6 = a.ASI_CRM_CN_Sub_Brand__r.Name.lastIndexOf('-');     
                                if(intlength >= 4 && intRP6 == (intlength-4)){
                                    a.ASI_CRM_CN_Sub_Brand__r.Name = a.ASI_CRM_CN_Sub_Brand__r.Name.substring(0, (intlength-4));
                                }
                            }
                            //End Twinkle 20141205
                            BRSFList_Map.get(sbGradeSort).get(sbGrade_chi).add(a);
                        }
                        
                    }else{
                        //Added by Twinkle 20141205 - Don't add empty record
                        if((a.ASI_CRM_CN_Incentive_BT__c != null && a.ASI_CRM_CN_Incentive_BT__c != 0) ||
                            (a.ASI_CRM_CN_Target_BT__c != null && a.ASI_CRM_CN_Target_BT__c != 0) ||
                            (a.ASI_CRM_CN_Actual_Vol__c != null && a.ASI_CRM_CN_Actual_Vol__c != 0) ||
                            (a.ASI_CRM_CN_Completion_Rate__c != null && a.ASI_CRM_CN_Completion_Rate__c != 0) ||
                            (a.ASI_CRM_CN_Total_Payable__c != null && a.ASI_CRM_CN_Total_Payable__c != 0) ||
                            (a.ASI_CRM_CN_Payable_Vol__c != null && a.ASI_CRM_CN_Payable_Vol__c != 0) ||
                            (a.ASI_CRM_CN_Bottle_Collected__c != null && a.ASI_CRM_CN_Bottle_Collected__c != 0) ||
                            (a.ASI_CRM_CN_Collection_Rate__c != null && a.ASI_CRM_CN_Collection_Rate__c != 0) ||
                            (a.ASI_CRM_CN_Offtake_Vol__c != null && a.ASI_CRM_CN_Offtake_Vol__c != 0)){
                            if(a.ASI_CRM_CN_Sub_Brand__r.Name != null){
                                intlength = a.ASI_CRM_CN_Sub_Brand__r.Name.length();
                                intRP6 = a.ASI_CRM_CN_Sub_Brand__r.Name.lastIndexOf('-');     
                                if(intlength >= 4 && intRP6 == (intlength-4)){
                                    a.ASI_CRM_CN_Sub_Brand__r.Name = a.ASI_CRM_CN_Sub_Brand__r.Name.substring(0, (intlength-4));
                                }
                            }
                            //End Twinkle 20141205
                            newBRSFList.add(a);
                        }
                        if(newBRSFList != null && newBRSFList.size() > 0){
                            SBgrade_map.put(sbGrade_Chi, newBRSFList);
                            BRSFList_Map.put(sbGradeSort, SBgrade_map);
                        }   
                    }
                
                    system.debug('BRSFList_Map: ' + BRSFList_Map.size());
                    system.debug('BRSFList_Map: ' + BRSFList_Map);
                    if (BRSFTotal_Map.containskey(sbGradeSort)){
                        BRSFTotal_Map.get(sbGradeSort).RowNo += 1;

                        if (a.ASI_CRM_CN_Target_BT__c != null)
                            BRSFTotal_Map.get(sbGradeSort).TotalBottle += a.ASI_CRM_CN_Target_BT__c;
                        if (a.ASI_CRM_CN_Actual_Vol__c != null)
                            BRSFTotal_Map.get(sbGradeSort).TotalActVol += a.ASI_CRM_CN_Actual_Vol__c;
                        if (a.ASI_CRM_CN_Total_Payable__c != null)
                            BRSFTotal_Map.get(sbGradeSort).TotalPayable += a.ASI_CRM_CN_Total_Payable__c;
                        if (a.ASI_CRM_CN_Payable_Vol__c != null)
                            BRSFTotal_Map.get(sbGradeSort).TotalPayableVol += a.ASI_CRM_CN_Payable_Vol__c;
                        if (a.ASI_CRM_CN_Bottle_Collected__c != null)
                            BRSFTotal_Map.get(sbGradeSort).TotalBtlCollection += a.ASI_CRM_CN_Bottle_Collected__c;
                        if (a.ASI_CRM_CN_Offtake_Vol__c != null)
                            BRSFTotal_Map.get(sbGradeSort).TotalOfftakeVol += a.ASI_CRM_CN_Offtake_Vol__c;
                        
                    }else{
                        BRSFTotal BRSFTotal_data = new BRSFTotal();
                        if (a.ASI_CRM_CN_Target_BT__c != null)
                            BRSFTotal_data.TotalBottle = a.ASI_CRM_CN_Target_BT__c;
                        else
                            BRSFTotal_data.TotalBottle = 0;
                        if (a.ASI_CRM_CN_Actual_Vol__c != null)
                            BRSFTotal_data.TotalActVol = a.ASI_CRM_CN_Actual_Vol__c;
                        else
                            BRSFTotal_data.TotalActVol = 0;
                        if (a.ASI_CRM_CN_Total_Payable__c != null)
                            BRSFTotal_data.TotalPayable = a.ASI_CRM_CN_Total_Payable__c;
                        else
                            BRSFTotal_data.TotalPayable = 0;
                        if (a.ASI_CRM_CN_Bottle_Collected__c != null)
                            BRSFTotal_data.TotalBtlCollection = a.ASI_CRM_CN_Bottle_Collected__c;
                        else
                            BRSFTotal_data.TotalBtlCollection = 0;
                        if (a.ASI_CRM_CN_Offtake_Vol__c != null)
                            BRSFTotal_data.TotalOfftakeVol = a.ASI_CRM_CN_Offtake_Vol__c;
                        else
                            BRSFTotal_data.TotalOfftakeVol = 0;
                        if (a.ASI_CRM_CN_Payable_Vol__c != null)
                            BRSFTotal_data.TotalPayableVol = a.ASI_CRM_CN_Payable_Vol__c;
                        else
                            BRSFTotal_data.TotalPayableVol = 0;
                        
                        BRSFTotal_data.RowNo = 1;
                        BRSFTotal_Map.put(sbGradeSort, BRSFTotal_data);
                    }                    
                }
                
                if (BottleCollectionSum!= 0 && ActVolSum != 0)
                    BolColRateSum = BottleCollectionSum/ActVolSum * 100;
                if (ActVolSum != 0 && BottleSum != 0)
                    CompletionRateSum = ActVolSum / BottleSum * 100;
            }
            if (BRSFTotal_Map.size() > 0 ){
                for (string temp : BRSFTotal_Map.keyset()){
                if (BRSFTotal_Map.get(temp).TotalActVol != null && BRSFTotal_Map.get(temp).TotalActVol != 0 && BRSFTotal_Map.get(temp).TotalBottle != 0 && BRSFTotal_Map.get(temp).TotalBottle != null ){
                    BRSFTotal_Map.get(temp).TotalCompletionRate = BRSFTotal_Map.get(temp).TotalActVol / BRSFTotal_Map.get(temp).TotalBottle * 100;
                }else{
                    BRSFTotal_Map.get(temp).TotalCompletionRate = 0;
                }
                system.debug('TotalCompletionRate: ' + BRSFTotal_Map.get(temp).TotalActVol + ' / ' + BRSFTotal_Map.get(temp).TotalBottle + ' = '+ BRSFTotal_Map.get(temp).TotalCompletionRate);
                if (BRSFTotal_Map.get(temp).TotalBtlCollection != null &&  BRSFTotal_Map.get(temp).TotalBtlCollection != 0 &&  BRSFTotal_Map.get(temp).TotalActVol != null && BRSFTotal_Map.get(temp).TotalActVol != 0){
                    BRSFTotal_Map.get(temp).TotalBoCollectionRate = BRSFTotal_Map.get(temp).TotalBtlCollection / BRSFTotal_Map.get(temp).TotalActVol * 100;
                }else{
                    BRSFTotal_Map.get(temp).TotalBoCollectionRate = 0;
                }
                system.debug('TotalBoCollectionRate : ' + BRSFTotal_Map.get(temp).TotalBtlCollection + ' / ' + BRSFTotal_Map.get(temp).TotalActVol + ' = ' + BRSFTotal_Map.get(temp).TotalBoCollectionRate );
            }
        }
        system.debug('BRSFTotal_Map: ' + BRSFTotal_Map);
        }else{
            thisPR = new ASI_TH_CRM_PaymentRequest__c();
            BRSFList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        }
        
        return true;
    }
    public class BRSFTotal{
        public decimal TotalBottle {set;get;}
        public decimal TotalActVol {set;get;}
        public decimal TotalCompletionRate {set;get;}
        public decimal TotalPayable {set;get;}
        public decimal TotalPayableVol {set;get;}
        public decimal TotalBtlCollection {set;get;}
        public decimal TotalBoCollectionRate {set;get;}
        public decimal TotalOfftakeVol {set;get;}
        public decimal RowNo {set;get;}
        
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