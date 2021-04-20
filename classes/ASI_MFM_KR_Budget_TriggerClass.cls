public  without sharing  class ASI_MFM_KR_Budget_TriggerClass
{
    public static void routineBeforeUpsert(list<ASI_MFM_Budget__c> trigger_new, map<id, ASI_MFM_Budget__c> trigger_oldMap)
    {
        Map<id, id> ProjectCode_map = new Map<id, id>();
        for(ASI_MFM_Budget__c b: trigger_new){
            ProjectCode_map.put(b.id, b.ASI_MFM_Code__c);
        }
        Map<id, ASI_MFM_Project_Code__c> pcode_map = new Map<id, ASI_MFM_Project_Code__c>();
        for(ASI_MFM_Project_Code__c p :[Select id, ASI_MFM_AP_Type__c from ASI_MFM_Project_Code__c where id IN: ProjectCode_map.values()]){
         	pcode_map.put(p.id, p);   
        }
        for(ASI_MFM_Budget__c b: trigger_new){
            if(pcode_map.get(ProjectCode_map.get(b.id)).ASI_MFM_AP_Type__c != null){
                if(b.ASI_MFM_KR_AP_Type__c != pcode_map.get(ProjectCode_map.get(b.id)).ASI_MFM_AP_Type__c){
             		b.ASI_MFM_KR_AP_Type__c = pcode_map.get(ProjectCode_map.get(b.id)).ASI_MFM_AP_Type__c;     
                }
            }
        }
        /*
        //Requirement:Once activated, then it will be locked and no changes are allowed. Before activation, they can modify, reupload as well as changing activation date
        String ActBudgetType;
        String ActFY; // FiscalYear
        list<ASI_MFM_KR_Budget_Setting__c> setting;
        Map<String,Date> settingMap = new Map<String,Date>();
        String ActNum;
                //Get activated Budget Type and Fiscal Year from Custom Setting: 'ASI MFM Budget Setting'
                /*for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
        if(Setting.name == 'KR')
        {
        ActBudgetType= Setting.ASI_MFM_Budget_Type__c;
        ActFY=Setting.ASI_MFM_Fiscal_Year__c; 
        }//end if
        }//end for*/
        /*
        setting = [SELECT Id, Name,
                   ASI_MFM_Activation_Time__c,
                   ASI_MFM_Budget_Type__c  
                   FROM ASI_MFM_KR_Budget_Setting__c 
                   ORDER BY Name];
        
        for(ASI_MFM_KR_Budget_Setting__c cs: setting)
        {
            if(Date.today()>cs.ASI_MFM_Activation_Time__c)
            {
                ActNum = cs.Name;
                ActBudgetType = cs.ASI_MFM_Budget_Type__c;
                if(cs.ASI_MFM_Activation_Time__c.month()>=7)
                {
                    ActFY = 'FY' + String.valueOf(cs.ASI_MFM_Activation_Time__c.year()-2000) + String.valueOf(cs.ASI_MFM_Activation_Time__c.year()-1999);
                }//end if
                else
                {
                    ActFY = 'FY' + String.valueOf(cs.ASI_MFM_Activation_Time__c.year()-2001) + String.valueOf(cs.ASI_MFM_Activation_Time__c.year()-2000);
                }//end else
            }//end if
            settingMap.put(cs.ASI_MFM_Budget_Type__c, cs.ASI_MFM_Activation_Time__c);
        }//end for
        
        //Based on activated time to determine whether the budget still can be updated or not
        //ASI_MFM_Brand__c,ASI_MFM_Code__c,ASI_MFM_Fiscal_Year__c,ASI_MFM_Type__c,ASI_MFM_Budget_External_ID_Upload__c,ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c,ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c,ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c,ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c
        
        for(ASI_MFM_Budget__c budget : trigger_new)
        {
            if(ActBudgetType!=null && ActFY!=null && trigger_oldMap.get(budget.Id)!=null)
            {
                if((budget.ASI_MFM_Type__c == ActBudgetType && budget.ASI_MFM_Fiscal_Year__c==ActFY)
                   ||(budget.ASI_MFM_Type__c != ActBudgetType && settingMap.get(budget.ASI_MFM_Type__c)<=settingMap.get(ActBudgetType)))
                {
                    /*if(trigger_oldMap.get(budget.Id).ASI_MFM_Sub_brand_Code__c !=budget.ASI_MFM_Sub_brand_Code__c 
                    || trigger_oldMap.get(budget.Id).ASI_MFM_Code__c !=budget.ASI_MFM_Code__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_Fiscal_Year__c !=budget.ASI_MFM_Fiscal_Year__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_Type__c !=budget.ASI_MFM_Type__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P1_Amount__c !=budget.ASI_MFM_P1_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P2_Amount__c !=budget.ASI_MFM_P2_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P3_Amount__c !=budget.ASI_MFM_P3_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P4_Amount__c !=budget.ASI_MFM_P4_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P5_Amount__c !=budget.ASI_MFM_P5_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P6_Amount__c !=budget.ASI_MFM_P6_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P7_Amount__c !=budget.ASI_MFM_P7_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P8_Amount__c !=budget.ASI_MFM_P8_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P9_Amount__c !=budget.ASI_MFM_P9_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P10_Amount__c !=budget.ASI_MFM_P10_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P11_Amount__c !=budget.ASI_MFM_P11_Amount__c
                    || trigger_oldMap.get(budget.Id).ASI_MFM_P12_Amount__c !=budget.ASI_MFM_P12_Amount__c)
                    {
                  	budget.addError('Not allow to change "Activiated" Budget ID:  '+budget.Name+' Budgets Type:  '+budget.ASI_MFM_Type__c+' Fiscal Year:  '+budget.ASI_MFM_Fiscal_Year__c);
                    //}//end if
                }//end if
            }//end if 
        }//end for
		*/
    }//end method: routineBeforeUpsert
    
}//end class: ASI_MFM_KR_Budget_TriggerClass