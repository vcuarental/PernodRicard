public with sharing class ASI_CRM_MO_GenerateWSOfftakeCtl {

    public SelectOption[] yearOptions { public get; private set; }
    public SelectOption[] monthOptions { public get; private set; }
    public String strYear { public get; public set; }
    public String strMonth { public get; public set; }
    
    public ASI_CRM_MO_GenerateWSOfftakeCtl() {
        this.yearOptions = new SelectOption[]{};
        this.monthOptions = new SelectOption[]{};
        integer currentYear = system.today().Year();
        integer Year_lower = currentYear - 3;
              
        for (integer i = Year_lower; i <= currentYear; i++) {
            this.yearOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        for (integer i = 1; i <= 12; i++) {
            this.monthOptions.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
    }
    
    public void reGen(){
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter value' + String.valueOf(strYear) ));    
        //Commission objCom = new Commission();
        //objCom.monthlyCommission(date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1));
        
        integer intY = integer.valueOf(strYear);
        integer intM = integer.valueOf(strMonth);
        
        //get all ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_MO_WSOfftakeDetail under intY and intM
        
        list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> lstOT = new list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        
        lstOT = [
            SELECT id, ASI_TH_CRM_Date__c, ASI_TH_CRM_Account__c, ASI_CRM_SKU__c, ASI_CRM_Quantity_Bottle__c
            FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c
            WHERE RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_MO_WSOfftakeDetail')
            AND (Calendar_Year(ASI_TH_CRM_Date__c) = :intY AND Calendar_Month(ASI_TH_CRM_Date__c) = :intM)
        ];
        
        system.debug('-------------------------------- ASI_CRM_MO_GenerateWSOfftakeCtl lstOT : ' + lstOT);
        if(lstOT != NULL && lstOT.size() > 0){
            ASI_CRM_MO_Offtake_Stock_In_Trade_Common.generateWSOfftakeIncentive(lstOT, true);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Total ' + lstOT.size() + ' records has been updated.'));
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'NO records matched in this period.'));
        }
    }
}