global class ASI_MFM_TW_submitBudgetCheck {
    
    
    public static Set<id> subBrandIds = new Set<id>();
    public static Set<id> acCodeIds = new Set<id>();
    public static String msg{get;set;}
    
    public class printObj
    {
        public String brand {get;set;}
        public String acCode {get;set;}
        public String lineNo {get;set;}
        public Decimal budgetAmt {get;set;}
        public Boolean hasBudget {get;set;}
        public Decimal planAmt {get;set;}
        public Decimal leAmt {get;set;}
        public Boolean hasLE {get;set;}
        public String budType {get;set;}
        public String budType2 {get;set;}
    }//end inner class
    
    webService static String calOVerBud(Id recordId, String fiscalYear)
    {
        msg = '';
        Map<String,printObj> printList = new Map<String,printObj>();
        
        List<ASI_MFM_Plan_Line_Item__c> curPlanLines = [SELECT 
                                                        ASI_MFM_Total_Cost__c
                                                        , ASI_MFM_Sub_brand_Code__c
                                                        , ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c
                                                        , ASI_MFM_A_C_Code__c
                                                        , ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c
                                                        , Name
                                                        FROM ASI_MFM_Plan_Line_Item__c 
                                                        WHERE ASI_MFM_Plan__c =: recordId
                                                        AND ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c LIKE '%A&P%'
                                                        ORDER BY ASI_MFM_Print_Sequence__c, name
                                                       ];
        if(curPlanLines.size()>0)
        {
            for(ASI_MFM_Plan_Line_Item__c line: curPlanLines)
            {
                subBrandIds.add(line.ASI_MFM_Sub_brand_Code__c);
                acCodeIds.add(line.ASI_MFM_A_C_Code__c);
                if(!printList.containsKey(''+line.ASI_MFM_Sub_brand_Code__c+line.ASI_MFM_A_C_Code__c))
                {
                    printObj temp = new printObj();
                    temp.planAmt = line.ASI_MFM_Total_Cost__c;
                    temp.brand = line.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c;
                    temp.acCode = line.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c;
                    temp.budgetAmt = 0;
                    temp.hasBudget = false;
                    temp.leAmt = 0;
                    temp.hasLE = false;
                    temp.lineNo = line.Name;
                    temp.budType = '';
                    temp.budType2 = '';
                    printList.put(''+line.ASI_MFM_Sub_brand_Code__c+line.ASI_MFM_A_C_Code__c, temp);
                }//end if
                else
                {
                    printObj temp = printList.get(''+line.ASI_MFM_Sub_brand_Code__c+line.ASI_MFM_A_C_Code__c);
                    temp.planAmt += line.ASI_MFM_Total_Cost__c;
                }//end else
            }//end for
        }//end if
        
        String FY = fiscalYear;
        String bType = 'LE4';
        
        List<ASI_MFM_Budget_Setting__c> bSetting = [SELECT ASI_MFM_Fiscal_Year__c
                                                    ,ASI_MFM_Budget_Type__c
                                                    FROM ASI_MFM_Budget_Setting__c
                                                    WHERE Name = 'TW'
                                                    LIMIT 1];
        if(bSetting.size()>0 && FY.equals(bSetting[0].ASI_MFM_Fiscal_Year__c))
            bType = bSetting[0].ASI_MFM_Budget_Type__c;
        
        List<ASI_MFM_Plan_Line_Item__c> planLines = [SELECT 
                                                     ASI_MFM_Sub_brand_Code__c
                                                     , ASI_MFM_A_C_Code__c
                                                     , ASI_MFM_Total_Cost__c
                                                     FROM ASI_MFM_Plan_Line_Item__c
                                                     WHERE ASI_MFM_Plan__c !=: recordId
                                                     AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c =: FY
                                                     AND ASI_MFM_Plan__r.ASI_MFM_Status__c != 'Draft'
                                                     AND ASI_MFM_A_C_Code__c IN: acCodeIds
                                                     AND ASI_MFM_Sub_brand_Code__c IN: subBrandIds
                                                     AND ASI_MFM_A_C_Code__r.ASI_MFM_A_and_P_Tree__c LIKE '%A&P%'];
        if(planLines.size()>0)
        {
            for(ASI_MFM_Plan_Line_Item__c line: planLines)
            {
                if(printList.containsKey(''+line.ASI_MFM_Sub_brand_Code__c+line.ASI_MFM_A_C_Code__c))
                {
                    printObj temp = printList.get(''+line.ASI_MFM_Sub_brand_Code__c+line.ASI_MFM_A_C_Code__c);
                    temp.planAmt += line.ASI_MFM_Total_Cost__c;
                }//end if
            }//end for
        }//end if
        
        //---get budget---//
        List<ASI_MFM_Budget__c> budgetList = new List<ASI_MFM_Budget__c>();
        if(acCodeIds.size() > 0 && subBrandIds.size() > 0 && FY != '' && FY != null)
        {
            budgetList = [SELECT id, Name
                          , ASI_MFM_Total_Amount__c
                          , ASI_MFM_Type__c
                          , ASI_MFM_A_C_Code__c
                          , ASI_MFM_Sub_brand_Code__c
                          FROM ASI_MFM_Budget__c
                          WHERE ASI_MFM_Fiscal_Year__c =: FY
                          AND (ASI_MFM_Type__c =: bType 
                               OR ASI_MFM_Type__c = 'Budget')
                          AND ASI_MFM_A_C_Code__c IN: acCodeIds
                          AND ASI_MFM_Sub_brand_Code__c IN: subBrandIds
                          ORDER BY ASI_MFM_Type__c];
        }//end if
        //---loooop budget---//
        if(budgetList !=null && budgetList.size() > 0)
        {
            for(ASI_MFM_Budget__c budgetRec: budgetList)
            {
                if(printList.containsKey(''+budgetRec.ASI_MFM_Sub_brand_Code__c+budgetRec.ASI_MFM_A_C_Code__c))
                {
                    printObj temp = printList.get(''+budgetRec.ASI_MFM_Sub_brand_Code__c+budgetRec.ASI_MFM_A_C_Code__c);
                    if(budgetRec.ASI_MFM_Type__c == 'Budget')
                    {
                        temp.budgetAmt += budgetRec.ASI_MFM_Total_Amount__c;
                        temp.hasBudget = true;
                        temp.budType = budgetRec.ASI_MFM_Type__c;
                    }//end if
                    else if(budgetRec.ASI_MFM_Type__c.contains('LE'))
                    {
                        temp.leAmt += budgetRec.ASI_MFM_Total_Amount__c;
                        temp.hasLE = true;
                        if(temp.budType != '')
                            temp.budType2 = budgetRec.ASI_MFM_Type__c;
                        else
                        	temp.budType = budgetRec.ASI_MFM_Type__c;
                    }//end elseif
                }//end if
            }//end for
        }//end if
        
        //calculate result
        if(printList.size()>0)
        for(printObj print: printList.values())
        {
            if(print.hasBudget && (print.budgetAmt - print.planAmt) < 0)
            {
                //msg += 'Plan Line: '+print.lineNo+' was Over Budget, Budget Type: '+print.budType+'\n';
                Decimal diff = (print.budgetAmt - print.planAmt)*-1;
                List<String> args = new String[]{'0','number','###,###,##0.00'};
                String amt = String.format(diff.format(), args);
                msg += 'AC Code: '+print.acCode+' Brand: '+print.brand+' was over '+print.budType+' amount by $'+amt+'.\n';
            }//end if
            if(print.hasLE && (print.leAmt - print.planAmt) < 0)
            {
                //msg += 'Plan Line: '+print.lineNo+' was Over Budget, Budget Type: '+print.budType+'\n';
                Decimal diff = (print.leAmt - print.planAmt)*-1;
                List<String> args = new String[]{'0','number','###,###,##0.00'};
                String amt = String.format(diff.format(), args);
                if(print.budType2 != '')
                	msg += 'AC Code: '+print.acCode+' Brand: '+print.brand+' was over '+print.budType2+' amount by $'+amt+'.\n';
                else
                    msg += 'AC Code: '+print.acCode+' Brand: '+print.brand+' was over '+print.budType+' amount by $'+amt+'.\n';
            }//end if
        }//end for
        if(msg!='')
            msg+='\nConfirm to submit for approval?';
        return msg;
    }//end method
}