global without sharing class ASI_CRM_CN_HeavyContractFinanceBatch implements Database.Batchable<sObject> ,Database.Stateful{

    Private Date cutOffDate;
    
    global ASI_CRM_CN_HeavyContractFinanceBatch(Date cutOffDate){
        
        this.cutOffDate = cutOffDate;
        
        if(this.cutOffDate == Null) {
            Date returndate = Date.today();
            Integer EndFY = returndate.year() -3;
            this.cutOffDate = Date.newInstance(EndFY,6,30);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String whereClausePO = 'ASI_CRM_CN_PO_End_Date__c > : cutOffDate AND RecordType.DeveloperName = \'ASI_CRM_CN_Contract\' and ASI_TH_CRM_Promotion_Type__c=\'Heavy Contract On\' AND  ASI_CRM_CN_Status__c!=\'Archived\' and ASI_CRM_CN_Status__c!=\'FY landing Archive\' and ASI_CRM_CN_Is_2nd_KPI_PO__c=true';
        
        String soqlQuery = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_TH_CRM_Contract__c', whereClausePO, '');
        
        return Database.getQueryLocator(soqlQuery);
    }

    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        calcContract((List<ASI_TH_CRM_Contract__c>) scope);
    }
    
    public void calcContract(List<ASI_TH_CRM_Contract__c> scope){

        Boolean AllowcalCulation=true;
        List<ASI_TH_CRM_Contract__c> ContractList= scope;// for(ASI_TH_CRM_Contract__c ContractSelected:ContractList){
        ASI_TH_CRM_Contract__c ContractSelected = new ASI_TH_CRM_Contract__c();
        
        if(ContractList.size()>0 && ContractList.size()==1){
            ContractSelected=ContractList[0];
        }
        
        
        
        if( ContractSelected.ASI_CRM_CN_V0_0_PO_version__c == null){ // current contract is v0.0 and vFinal
            // Calculate new contract V0.0  estimate and Contract AMount
            List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> CurrentContractList =ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(ContractSelected);
            ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0Esitimate = CurrentContractList.get(0);
            //VO.0 Est ETL
            ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(ContractSelected, NewContractV0Esitimate, null);
        }else{// Finding v0.0
            // v0.0 estimate and Contract AMount
            String V00ContractId = ContractSelected.ASI_CRM_CN_V0_0_PO_version__c;
            ASI_TH_CRM_Contract__c V0Contract = new ASI_TH_CRM_Contract__c();
            V0Contract.id = V00ContractId; // = [SELECT id, Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,  ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_Budget_LE__c, ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, ASI_CRM_CN_Vol_Budget_LE__c,ASI_CRM_CN_PO_Modification__c,  ASI_CRM_CN_Contract_Est_Var_Cost_Total__c, ASI_CRM_CN_Contract_Estimate_Cost_Total__c,ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_PO_Start_Date__c,  ASI_CRM_CN_PO_End_Date__c,   ASI_CRM_CN_PO_No__c, ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Grade__c,ASI_CRM_CN_BRSF_Contract_Total__c, ASI_CRM_CN_Contract_Cost_Total__c, ASI_CRM_CN_Contract_Fixed_Cost_Total__c,ASI_CRM_CN_Contract_Variable_Cost_Total__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Eng_Name__c,   ASI_CRM_CN_Outlet_WS__r.ASI_TH_CRM_OutletType__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sales_Rep__r.Name,  ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Image__c,ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_City_Tier__c, ASI_CRM_CN_Description__c,  ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Sub_Channel__r.Name, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,  ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_Last_PO_version__c, ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_End_Date__c, ASI_CRM_CN_V0_0_PO_version__c, Owner.Name, ASI_CRM_CN_Status__c , ASI_CRM_Volume_Option__c,  ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_Contract_Est_Fixed_Cost_Total__c, ASI_CRM_CN_Bottle_Collection_Rate__c,ASI_CRM_New_FY_PO__c, ASI_CRM_PO_Channel__c, ASI_CRM_PO_Province__c,  ASI_CRM_PO_Channel__r.Name, ASI_CRM_PO_Province__r.Name,ASI_CRM_PO_City__c ,ASI_CRM_PO_City__r.Name ,ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c  FROM ASI_TH_CRM_Contract__c  WHERE id = :V00ContractId];
            List<ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd> CurrentContractList =ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureCurrentFinancialIndicatorDataList2nd(V0Contract);
            ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd NewContractV0Esitimate = CurrentContractList.get(0);
            

            //Calculate new contract Vfinal Data
            ASI_CRM_CN_HeavyContractUtilitiesClass.FinancialIndicator2nd VFinalContract;
            if (ContractSelected.ASI_CRM_Auto_PO_Modification__c) {
                List<ASI_TH_CRM_PaymentRequest__c> LastPaymentRequest = [SELECT Id,Name,ASI_CRM_CN_Total_VEC_Amount__c,
                             ASI_CRM_Total_Variable_Amount__c,ASI_CRM_CN_Promotion_Type__c,ASI_CRM_CN_Total_BRSF_Amount__c, ASI_CRM_CN_Total_PSF_Amount__c,
                             ASI_CRM_CN_Total_Other_Amount__c,ASI_TH_CRM_Contract__c, ASI_CRM_CN_Total_Payment__c,ASI_TH_CRM_Contract__r.ASI_CRM_Volume_Option__c,
                             ASI_CRM_CN_OutletWS__c,ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_PO_Start_Date__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                             ASI_TH_CRM_Contract__r.ASI_CRM_CN_V0_0_PO_version__c
                            FROM ASI_TH_CRM_PaymentRequest__c
                             WHERE 
                             ASI_CRM_CN_PO_No__c = :ContractSelected.ASI_CRM_CN_PO_No__c
                            AND ASI_CRM_CN_Last_Payment__c = TRUE
                            Order By CreatedDate desc];
                if (LastPaymentRequest.isEmpty()) {
                    VFinalContract =  ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(ContractSelected).get(0);
                }
                else {
                    if (!test.isRunningTest()) {
                        VFinalContract = ASI_CRM_CN_HeavyPaymentUtilitiesClass.ReconstructLastPaymentFIDataList2nd(LastPaymentRequest.get(0)).get(0);
                    }
                }
                
            }
            else {
                VFinalContract =  ASI_CRM_CN_HeavyContractUtilitiesClass.ReconstructCurrentPOModiFIDataList2nd(ContractSelected).get(0);
            }
            ASI_CRM_CN_HeavyContractUtilitiesClass.UpsertKPIData(ContractSelected, NewContractV0Esitimate, VFinalContract);
        }
       
       ASI_TH_CRM_Contract__c updateContract = new ASI_TH_CRM_Contract__c();
       updateContract.id = ContractSelected.Id;
       updateContract.ASI_CRM_CN_ETL_Cutoff_Date__c = System.today();
       update updateContract;
    }

    global void finish(Database.BatchableContext BC) {
        
    }
}