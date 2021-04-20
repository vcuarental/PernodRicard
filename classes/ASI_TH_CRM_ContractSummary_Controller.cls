/*
Created by Stella Sing 2014-03-17
*/

public with sharing class ASI_TH_CRM_ContractSummary_Controller{
    public String PageId {get;set;}
    public Boolean ShowYearTotal {get;set;}
    public String strSCS {get;set;}
    public String strSVPM {get;set;}
    public String strOthers{get;set;}
    public String strPOSPOP{get;set;}
    public Integer strStartYear{get;set;}
    public Integer strEndYear{get;set;} 
    public Integer strStartMonth{get;set;} 
    public Integer strEndMonth{get;set;}
    public string strEndName {get;set;}
    public Date strStartDate{get;set;}
    public Date strEndDate{get;set;}
    public String strMediaSupport{get;set;}
    public map <Integer, Map<String, PromotionApproval>> YearItemMap {set;get;}
    public map <Integer, PromotionApproval> YearSubTotalMap {set;get;}
    public map <Integer, PromotionApproval> ShowYearSubTotal {set;get;}
    public Integer strYearSubTotal {set;get;}
    decimal t1t;
    decimal t2t;
    decimal t3t;
    decimal t4t;
    decimal t5t;
    decimal t6t;
    
    public List <ASI_TH_CRM_Contract_Spending__c> CSLineItem = new List <ASI_TH_CRM_Contract_Spending__c>();
    public List <ASI_TH_CRM_Contract__c> CSList = new List <ASI_TH_CRM_Contract__c>();
    
    public ASI_TH_CRM_ContractSummary_Controller(ApexPages.StandardController stdController){
        PageId = ApexPages.CurrentPage().getParameters().get('id');
        
        ASI_TH_CRM_Contract__c contract = (ASI_TH_CRM_Contract__c)stdController.getRecord();
        CSList = [SELECT ASI_TH_CRM_Start_Date__c , ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Summary_Contract_Spending__c, ASI_TH_CRM_Summary_Volume_Per_Month__c, ASI_TH_CRM_Others__c, ASI_TH_CRM_POS_POP__c,ASI_TH_CRM_Media_Support__c
        FROM ASI_TH_CRM_Contract__c WHERE id = :PageId];
        for (ASI_TH_CRM_Contract__c a : CSList){
            if (a.ASI_TH_CRM_Start_Date__c != null){
                strStartDate = a.ASI_TH_CRM_Start_Date__c;
                strStartYear = strStartDate.Year();
                strStartMonth = strStartDate.Month();
            }
            if (a.ASI_TH_CRM_End_Date__c != null){
                strEndDate = a.ASI_TH_CRM_End_Date__c;
                strEndYear = strEndDate.Year();
                strEndMonth = strEndDate.Month();
                strEndName = string.valueof(strEndYear) + ' - ' + MonthMap.get(string.valueof(strEndMonth));
            }
            if (a.ASI_TH_CRM_Summary_Contract_Spending__c != null){
                String strSCS0 = a.ASI_TH_CRM_Summary_Contract_Spending__c;
                String[] strSCS1 = strSCS0.split('\n');
                strSCS  = String.join(strSCS1, '<br/>');
            }
            if (a.ASI_TH_CRM_Summary_Volume_Per_Month__c!= null){
                String strSVPM0 = a.ASI_TH_CRM_Summary_Volume_Per_Month__c;
                String[] strSVPM1 = strSVPM0.split('\n');
                strSVPM = String.join(strSVPM1, '<br/>');
            }
            if (a.ASI_TH_CRM_Others__c!= null){
                String strOthers0 = a.ASI_TH_CRM_Others__c;
                String[] strOthers1 = strOthers0.split('\n');
                strOthers = String.join(strOthers1, '<br/>');
            }
            if (a.ASI_TH_CRM_POS_POP__c!= null){
                String strPOSPOP0 = a.ASI_TH_CRM_POS_POP__c;
                String[] strPOSPOP1 = strPOSPOP0.split('\n');
                strPOSPOP = String.join(strPOSPOP1, '<br/>');
            }
            if (a.ASI_TH_CRM_Media_Support__c!= null){
                String strMediaSupport0 = a.ASI_TH_CRM_Media_Support__c;
                String[] strMediaSupport1 = strMediaSupport0.split('\n');
                strMediaSupport = String.join(strMediaSupport1, '<br/>');
            }
        }

        CSLineItem = [SELECT Name, ASI_TH_CRM_Activity_Cash__c, ASI_TH_CRM_Activity_FOC__c, ASI_TH_CRM_Date__c, ASI_TH_CRM_Fund_Advance__c,
        ASI_TH_CRM_Fund_Cash__c, ASI_TH_CRM_Fund_FOC__c, ASI_TH_CRM_Fund_Rebate__c FROM ASI_TH_CRM_Contract_Spending__c
        WHERE ASI_TH_CRM_Contract__c = :PageId AND Name != null ]; 
        Integer strNoYears = CheckfiscalYear(contract.ASI_TH_CRM_End_Date__c) - CheckfiscalYear(contract.ASI_TH_CRM_Start_Date__c) +1;
        system.debug('Number of years: ' + strNoYears);
        
        YearSubTotalMap = new Map<Integer, PromotionApproval>();
        YearItemMap = new map <Integer, Map<String, PromotionApproval>> ();
        Integer FYStart = CheckfiscalYear(contract.ASI_TH_CRM_Start_Date__c);
        Integer FYEnd = CheckfiscalYear(contract.ASI_TH_CRM_End_Date__c);
        system.debug('FYStart: ' + FYStart);
        system.debug('FYEnd: ' + FYEnd);
        for (Integer i=0; i < strNoYears; i++){
            PromotionApproval pa1 = new PromotionApproval();
            PromotionApproval pa2 = new PromotionApproval();
            PromotionApproval pa3 = new PromotionApproval();
            PromotionApproval pa4 = new PromotionApproval();
            PromotionApproval pa5 = new PromotionApproval();
            PromotionApproval pa6 = new PromotionApproval();
            PromotionApproval patotal = new PromotionApproval();
            system.debug('Debug 1');
            pa1.t1 = 0;             
            pa1.t2 = 0;
            pa1.t3 = 0;
            pa1.t4 = 0;
            pa1.t5 = 0;
            pa1.t6 = 0;
            pa2.t1 = 0;             
            pa2.t2 = 0;
            pa2.t3 = 0;
            pa2.t4 = 0;
            pa2.t5 = 0;
            pa2.t6 = 0;
            pa3.t1 = 0;             
            pa3.t2 = 0;
            pa3.t3 = 0;
            pa3.t4 = 0;
            pa3.t5 = 0;
            pa3.t6 = 0;
            pa4.t1 = 0;             
            pa4.t2 = 0;
            pa4.t3 = 0;
            pa4.t4 = 0;
            pa4.t5 = 0;
            pa4.t6 = 0;
            pa5.t1 = 0;             
            pa5.t2 = 0;
            pa5.t3 = 0;
            pa5.t4 = 0;
            pa5.t5 = 0;
            pa5.t6 = 0;
            pa6.t1 = 0;             
            pa6.t2 = 0;
            pa6.t3 = 0;
            pa6.t4 = 0;
            pa6.t5 = 0;
            pa6.t6 = 0;
            patotal.t1 = 0;             
            patotal.t2 = 0;
            patotal.t3 = 0;
            patotal.t4 = 0;
            patotal.t5 = 0;
            patotal.t6 = 0;
            system.debug('Debug 2');
            Map<String, PromotionApproval> typeMap = new  Map<String, PromotionApproval>();
            system.debug('Debug 3');
            typeMap.put('Fund - Advance', pa1);
            typeMap.put('Fund - Cash', pa2);
            typeMap.put('Fund - FOC', pa3);
            typeMap.put('Rebate (Historical)', pa4);
            typeMap.put('Activity - Cash', pa5);
            typeMap.put('Activity - FOC', pa6);
            system.debug('Debug 4');
            YearSubTotalMap.put((FYStart+i), patotal); 
            system.debug('Debug 5');
            YearItemMap.put((FYStart+i), typeMap);
            system.debug('Debug 6');
            
        }
        
        system.debug('Debug YearItemMap.size() ' + YearItemMap.size());
        if (CSLineItem.size() > 0)
        system.debug('CSLineItem: ' + CSLineItem);
        for (ASI_TH_CRM_Contract_Spending__c abc : CSLineItem){
            Integer fiscalYear = CheckfiscalYear(abc.ASI_TH_CRM_Date__c);
            system.debug('FiscalYear: ' + fiscalYear);
            //Decimal demo = YearItemMap.get(fiscalYear).get('ASI_TH_CRM_Fund_Advance__c').t1;
            //system.debug('Sample: ' + demo );
            InputToMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Fund - Advance' , abc.ASI_TH_CRM_Fund_Advance__c);
            InputToMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Fund - Cash' , abc.ASI_TH_CRM_Fund_Cash__c);  
            InputToMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Fund - FOC' , abc.ASI_TH_CRM_Fund_FOC__c);
            //InputToMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Rebate (Historical)' , abc.ASI_TH_CRM_Fund_Rebate__c);  
            InputToMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Activity - Cash' , abc.ASI_TH_CRM_Activity_Cash__c);
            InputToMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Activity - FOC' , abc.ASI_TH_CRM_Activity_FOC__c);
        }
        
        for(Integer year : YearItemMap.keySet()){
            //decimal t1t += YearItemMap.get(strYear).get(strType).t1;
            InputToSubTotalMap(year, 'Fund - Advance');
            InputToSubTotalMap(year, 'Fund - Cash');
            InputToSubTotalMap(year, 'Fund - FOC');
            //InputToSubTotalMap(year, 'Rebate (Historical)');
            InputToSubTotalMap(year, 'Activity - Cash');
            InputToSubTotalMap(year, 'Activity - FOC');
            /*
            InputToSubTotalMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Fund - Advance' , abc.ASI_TH_CRM_Fund_Advance__c);
            InputToSubTotalMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Fund - Cash' , abc.ASI_TH_CRM_Fund_Cash__c);  
            InputToSubTotalMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Fund - FOC' , abc.ASI_TH_CRM_Fund_FOC__c);
            //InputToSubTotalMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Rebate (Historical)' , abc.ASI_TH_CRM_Fund_Rebate__c);  
            InputToSubTotalMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Activity - Cash' , abc.ASI_TH_CRM_Activity_Cash__c);
            InputToSubTotalMap(abc.ASI_TH_CRM_Date__c, fiscalYear, 'Activity - FOC' , abc.ASI_TH_CRM_Activity_FOC__c);
            */
        }
        
        //system.debug('GET YearItemMap.size(): ' + YearItemMap.size());
        //system.debug('GET YearSubTotalMap.size(): ' + YearSubTotalMap.size());
        strYearSubTotal = YearSubTotalMap.size();
        for(Integer year : YearItemMap.keySet()){
            system.debug('Remove ZERO value item');
            system.debug('year: ' + year);
            //system.debug('YearItemMap.get(year).Key: ' + YearItemMap.get(year).Key);
            CheckZero(year, 'Fund - Advance');
            CheckZero(year, 'Fund - Cash');
            CheckZero(year, 'Fund - FOC');
            CheckZero(year, 'Rebate (Historical)');
            CheckZero(year, 'Activity - Cash');
            CheckZero(year, 'Activity - FOC');
            CheckYearZero(year);
            system.debug('GET YearItemMap.size() after removal: ' + YearItemMap.size());
        }
        if (strYearSubTotal > 0){
            ShowYearTotal = true;
        }else{
            ShowYearTotal = false;
        }
    }
    public void InputToSubTotalMap(Integer strYear, String strType){
    
   // if (strField != 0 || strField != null){
            //if ((strDate).Month() == 1 || (strDate).Month() == 7){
                YearSubTotalMap.get(strYear).T1 +=  YearItemMap.get(strYear).get(strType).t1;
                system.debug('t1: ' + YearSubTotalMap.get(strYear).t1);
            //}else if ((strDate).Month() == 2 || (strDate).Month() == 8){
                YearSubTotalMap.get(strYear).T2 +=  YearItemMap.get(strYear).get(strType).t2;
                system.debug('t2: ' + YearSubTotalMap.get(strYear).t2);
           // }else if ((strDate).Month() == 3 || (strDate).Month() == 9){
                YearSubTotalMap.get(strYear).T3 +=  YearItemMap.get(strYear).get(strType).t3;
                system.debug('t3: ' + YearSubTotalMap.get(strYear).t3);
           // }else if ((strDate).Month() == 4 || (strDate).Month() == 10){
                YearSubTotalMap.get(strYear).T4 +=  YearItemMap.get(strYear).get(strType).t4;
                system.debug('t4: ' + YearSubTotalMap.get(strYear).t4);
            //}else if ((strDate).Month() == 5 || (strDate).Month() == 11){
                YearSubTotalMap.get(strYear).T5 +=  YearItemMap.get(strYear).get(strType).t5;
                system.debug('t5: ' + YearSubTotalMap.get(strYear).t5);
            //}else if ((strDate).Month() == 6 || (strDate).Month() == 12){
                YearSubTotalMap.get(strYear).T6 +=  YearItemMap.get(strYear).get(strType).t6;
                system.debug('t6: ' + YearSubTotalMap.get(strYear).t6);
            //}    
       // }
    }
    public void InputToMap(Date strDate, Integer strYear, String strType, Decimal strField){
    system.debug('Date: '+ strDate + 'Integer: ' +  strYear + 'String: ' + strType + ' Decimal: ' + strField);
        if (strField != 0 || strField != null){
            if ((strDate).Month() == 1 || (strDate).Month() == 7){
            system.debug('t1: ' + strYear + ' & ' + strType + ' 1/7');
                system.debug('YearItemMap.get('+ strYear + ').get(' + strType + ').t1: ' + strField + ' + ' + YearItemMap.get(strYear).get(strType).t1);
                YearItemMap.get(strYear).get(strType).t1 += strField;
                //YearSubTotalMap.get(strYear).T1 += strField;
                system.debug('t1: ' + YearItemMap.get(strYear).get(strType).t1);
            }else if ((strDate).Month() == 2 || (strDate).Month() == 8){
            system.debug('t2: ' + strYear + ' & ' + strType + ' 2/8');
            system.debug('YearItemMap.get('+ strYear + ').get(' + strType + ').t2: ' + strField + ' + ' + YearItemMap.get(strYear).get(strType).t2);
                YearItemMap.get(strYear).get(strType).t2 += strField;
                //YearSubTotalMap.get(strYear).T2 += strField;
                system.debug('t2: ' + YearItemMap.get(strYear).get(strType).t2);
            }else if ((strDate).Month() == 3 || (strDate).Month() == 9){
            system.debug('t3: ' + strYear + ' & ' + strType + ' 3/9');
                system.debug('YearItemMap.get('+ strYear + ').get(' + strType + ').t3: ' + strField + ' + ' + YearItemMap.get(strYear).get(strType).t3);
                YearItemMap.get(strYear).get(strType).t3 += strField;
                //YearSubTotalMap.get(strYear).T3 += strField;
                system.debug('t3: ' + YearItemMap.get(strYear).get(strType).t3);
            }else if ((strDate).Month() == 4 || (strDate).Month() == 10){
            system.debug('t4: ' + strYear + ' & ' + strType + ' 4/10');
                system.debug('YearItemMap.get('+ strYear + ').get(' + strType + ').t4: ' + strField + ' + ' + YearItemMap.get(strYear).get(strType).t4);
                YearItemMap.get(strYear).get(strType).t4 += strField;
                //YearSubTotalMap.get(strYear).T4 += strField;
                system.debug('t4: ' + YearItemMap.get(strYear).get(strType).t4);
            }else if ((strDate).Month() == 5 || (strDate).Month() == 11){
            system.debug('t5: ' + strYear + ' & ' + strType + ' 5/11');
                system.debug('YearItemMap.get('+ strYear + ').get(' + strType + ').t5: ' + strField + ' + ' + YearItemMap.get(strYear).get(strType).t5);
                YearItemMap.get(strYear).get(strType).t5 += strField;
                //YearSubTotalMap.get(strYear).T5 += strField;
                system.debug('t5: ' + YearItemMap.get(strYear).get(strType).t5);
            }else if ((strDate).Month() == 6 || (strDate).Month() == 12){
            system.debug('t6: ' + strYear + ' & ' + strType  + ' 6/12');
                system.debug('YearItemMap.get('+ strYear + ').get(' + strType + ').t6: ' + strField + ' + ' + YearItemMap.get(strYear).get(strType).t6);
                YearItemMap.get(strYear).get(strType).t6 += strField;
                //YearSubTotalMap.get(strYear).T6 += strField;
                system.debug('t6: ' + YearItemMap.get(strYear).get(strType).t6);
            }
            
        }
        
    }
    
    public Integer CheckfiscalYear(Date strDate){
        system.debug('ChecfiscalYear() ' + strDate);
        Integer fys = strDate.Year();
        Integer fysm = strDate.Month();
        Integer s;
        if (fysm < 7)
            s = fys-1;
        else
            s = fys;
        system.debug('ChecfiscalYear() return:' + s);
        return s;
    }
    public void CheckZero(Integer strYear, String strType){
        system.debug('CheckZero() ' + strYear+ ' - ' + strType);
        if (YearItemMap.get(strYear).get(strType).t1 ==0 && YearItemMap.get(strYear).get(strType).t2 == 0
                && YearItemMap.get(strYear).get(strType).t3 == 0&& YearItemMap.get(strYear).get(strType).t4 == 0
                && YearItemMap.get(strYear).get(strType).t5 ==0 && YearItemMap.get(strYear).get(strType).t6 == 0){
            system.debug('All Zero!');
            YearItemMap.get(strYear).remove(strType);
            system.debug(strType + ' - Zeros Removed!');
        }
    }
    public void CheckYearZero(Integer strYear){
        system.debug('CheckYearZero() ' + strYear);
        system.debug('YearSubTotalMap.get(strYear).t1 ' + YearSubTotalMap.get(strYear).t1);
        
        if (YearSubTotalMap.get(strYear).t1 ==0  && YearSubTotalMap.get(strYear).t2 ==0 && YearSubTotalMap.get(strYear).t3 ==0 
            && YearSubTotalMap.get(strYear).t4 ==0  && YearSubTotalMap.get(strYear).t5 ==0 && YearSubTotalMap.get(strYear).t6 ==0)
            {
                //YearSubTotalMap.remove(strYear);
                //YearSubTotalMap.get(strYear).remove();
                YearItemMap.remove(strYear);
            }
            
    }
    
    public static Map <String, String> ACCodeMap = new Map <String, String>();
    public static Map <String, String> MonthMap= new Map <String, String>();
    static{
        ACCodeMap.put('Fund - Advance', '5558.2010');
        ACCodeMap.put('Fund - Cash', '5558.2020');
        ACCodeMap.put('Fund - FOC', '5558.2050');
        ACCodeMap.put('Rebate (Historical)', '5220.302');
        ACCodeMap.put('Activity - Cash', '5558.2120');
        ACCodeMap.put('Activity - FOC', '5558.2150');
        
        MonthMap.put('1', 'Jan');
        MonthMap.put('2', 'Feb');
        MonthMap.put('3', 'Mar');
        MonthMap.put('4', 'Apr');
        MonthMap.put('5', 'May');
        MonthMap.put('6', 'Jun');
        MonthMap.put('7', 'Jul');
        MonthMap.put('8', 'Aug');
        MonthMap.put('9', 'Sep');
        MonthMap.put('10', 'Oct');
        MonthMap.put('11', 'Nov');
        MonthMap.put('12', 'Dec');
    }

    public class PromotionApproval{
        public ASI_TH_CRM_Contract_Spending__c ApprovalItem {set;get;}
        public sObject PromotionApproval{set;get;}
        public decimal t1{set;get;}
        public decimal t2{set;get;}
        public decimal t3{set;get;}
        public decimal t4{set;get;}
        public decimal t5{set;get;}
        public decimal t6{set;get;}


        
        public PromotionApproval(ASI_TH_CRM_Contract_Spending__c item){
            ApprovalItem = item;         
        }
        
        public PromotionApproval(){
            
        }
    }
}