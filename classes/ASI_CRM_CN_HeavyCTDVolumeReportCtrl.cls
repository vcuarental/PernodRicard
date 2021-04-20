public class ASI_CRM_CN_HeavyCTDVolumeReportCtrl {
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;} {ContractSelected = new ASI_TH_CRM_Contract__c();}
    public String StartDateStr {get; set;}{StartDateStr='';}
    public String EndDateStr {get; set;}{EndDateStr='';}
    
    public id currentHeaderId {set;get;}
    public ASI_CRM_CN_HeavyCTDVolumeReportCtrl(){}
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public boolean init(){
        //String ContractId = ApexPages.currentPage().getParameters().get('id');     
          
        
        if (currentHeaderId != null){
            ContractSelected = [SELECT id,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                ASI_CRM_CN_V0_0_PO_version__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name, ASI_CRM_Volume_Option__c, ASI_CRM_CN_Region__c, Owner.Name, ASI_CRM_CN_V0_0_PO_version__c,ASI_CRM_New_FY_PO__c,ASI_CRM_PO_Channel__r.Name,ASI_CRM_PO_Province__r.Name ,ASI_CRM_PO_City__c  ,ASI_CRM_PO_City__r.Name ,ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c 
                                FROM ASI_TH_CRM_Contract__c  WHERE Id = :currentHeaderId];
            /*
            Date SystemToday = system.today();
            
            if(ContractSelected.ASI_CRM_CN_PO_Start_Date__c < SystemToday){
                 StartDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(ContractSelected.ASI_CRM_CN_PO_Start_Date__c,'yyyy-MM-dd' );
         
            }else{
                 StartDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(system.today(),'yyyy-MM-dd' );
         
            }*/
            StartDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(ContractSelected.ASI_CRM_CN_PO_Start_Date__c,'yyyy-MM-dd' );
             Date CutOffDay =ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
             if(CutOffDay < ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                 EndDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(CutOffDay,'yyyy-MM-dd' ); 
             }else{
                 EndDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(ContractSelected.ASI_CRM_CN_PO_End_Date__c,'yyyy-MM-dd' ); 
             }
            
            /*
            if(SystemToday<ContractSelected.ASI_CRM_CN_PO_End_Date__c){
                EndDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(system.today(),'yyyy-MM-dd' ); 
            }else{
                EndDateStr= ASI_CRM_CN_HeavyContractUtilitiesClass.DateToString(ContractSelected.ASI_CRM_CN_PO_End_Date__c,'yyyy-MM-dd' );
            }*/
              //
        }
        
        
        return true;   
        
    }
}