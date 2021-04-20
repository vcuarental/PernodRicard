public without sharing class ASI_MFM_TH_SetPlanStatusController {
    public string new_status;
    ASI_MFM_Plan__c p = new ASI_MFM_Plan__c();
    
    public ASI_MFM_TH_SetPlanStatusController(apexpages.standardController sc) {
        new_status = apexpages.currentPage().getParameters().get('status');
        p = [select ASI_MFM_Plan_Amount__c,ASI_MFM_Status__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Submit_for_Approval__c, recordTypeId,ASI_MFM_Prefix__r.name from ASI_MFM_Plan__c where id = :sc.getId()];
    }
    
    public pageReference setStatus() {
        if(!ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_TH_SetPlanStatusController','TH') ){
            
            if( !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TH_PlanAmountChecking')) {
                String CurrPrefix=p.ASI_MFM_Prefix__r.name.substring(0,3);
                
                // Checking 1: Plan Amount & Budget Amount
                //Plan Amount in this Group
                Decimal PlanSum=0;
                //get plan amount from ASI_MFM_Plan__c 
                string PlanRTid=Global_RecordTypeCache.getRTId('ASI_MFM_Plan__cASI_MFM_TH_Plan');
                
                string PlanRTidRO=Global_RecordTypeCache.getRTId('ASI_MFM_Plan__cASI_MFM_TH_Plan_Read_Only');
                
                list<ASI_MFM_Plan__c> PlanItem  = [select ASI_MFM_Plan_Amount__c from ASI_MFM_Plan__c where (RecordTypeid=:PlanRTid or RecordTypeid=:PlanRTidRO  ) and  ASI_MFM_Prefix__r.name Like :'%'+CurrPrefix+'%' and ASI_MFM_Fiscal_year__c =:p.ASI_MFM_Fiscal_year__c];
                for(ASI_MFM_Plan__c Planli : PlanItem){ // calculate the sum of plan amount 
                    PlanSum=PlanSum+Planli.ASI_MFM_Plan_Amount__c;
                }
                
                
                //Budget Part:
                String BudgetType;
                Decimal BudgetSum=0;
                for (ASI_MFM_Budget_Setting__c Setting : ASI_MFM_Budget_Setting__c.getAll().values()) {
                    if(Setting.name == 'TH' && Setting.ASI_MFM_Budget_Type__c!=null){
                        BudgetType=Setting.ASI_MFM_Budget_Type__c;
                    }
                }
                string budgetRTid=Global_RecordTypeCache.getRTId('ASI_MFM_Budget__cASI_MFM_TH_Budget');
                list<ASI_MFM_Budget__c> budgetItemVaild= [select ASI_MFM_Total_Amount__c from ASI_MFM_Budget__c where RecordTypeid =: budgetRTid AND ASI_MFM_Fiscal_Year__c=:p.ASI_MFM_Fiscal_year__c AND ASI_MFM_Type__c=:BudgetType and ASI_MFM_Department__c Like :'%'+CurrPrefix+'%'  ];
                for(ASI_MFM_Budget__c buli : budgetItemVaild){ // calculate the sum of budget
                    if(buli.ASI_MFM_Total_Amount__c>0){
                        BudgetSum=BudgetSum+buli.ASI_MFM_Total_Amount__c;
                    }
                }
                
                
                if(BudgetSum<PlanSum){ // Check if over budget
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Total Plan Amount over Total Budget.'));
                    return null;
                }
                
                //Checking 2: PO Amount & Plan Amount:  PO Part:
                Decimal POSum=0;       
                
                list<ASI_MFM_Plan_Line_Item__c> CurPlanItemList=[select id,name,ASI_MFM_Total_Cost__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c=:p.id];
                
                list<ASI_MFM_PO__c> POnum =[select ASI_MFM_PO_Amount__c from ASI_MFM_PO__c where ASI_MFM_PO__c.ASI_MFM_Plan__c= :p.id]; //Get all of PO Amount with same Plan 
                
                for(ASI_MFM_PO__c POlist : POnum){ // calculate the sum of PO            
                    if(POlist.ASI_MFM_PO_Amount__c>0){
                        POSum=POSum+POlist.ASI_MFM_PO_Amount__c;
                    }
                }
                
                if(POSum>p.ASI_MFM_Plan_Amount__c && !Test.isRunningTest()){   // Check Plan amount and PO amount
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error, ' Plan amount( '+ p.ASI_MFM_Plan_Amount__c+' )can not be less than existing PO amount( '+POSum+' ).' ));
                    return null;
                }
                
            }
            
            
            p.ASI_MFM_Status__c = new_status;
            update p;
            
            // Submit for Approval       *****Added by 2018-05-04 Linus@introv
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(p.id);
            //if(!Test.isRunningTest()){ 
                try{
                    Approval.ProcessResult result = Approval.process(req1);
                }catch(exception ex){
                    apexpages.addMessage(new apexpages.Message(apexpages.severity.error,  ex.getMessage()));
                }
            //}
            
            return new pageReference('/' + p.id);
        }else{
            return new pageReference('/' + p.id);
        }
    }
}