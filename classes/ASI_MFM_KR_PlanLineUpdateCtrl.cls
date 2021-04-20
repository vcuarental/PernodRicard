public class ASI_MFM_KR_PlanLineUpdateCtrl {
    public ASI_MFM_KR_PlanLineUpdateCtrl(apexpages.standardController sc)
    {
       Plan = [select Id,recordTypeId from ASI_MFM_Plan__c where id = :sc.getId()]; 
        lstwrapper = new List<wrapper>();
        //https://pernod-ricard--asisb6conf--c.cs8.visual.force.com/apex/ASI_MFM_KR_PlanLineUpdatePage?Id=a9EL00000000MTS
    }
    ASI_MFM_Plan__c Plan = new ASI_MFM_Plan__c();
    public List<wrapper> lstwrapper {get; set;}
    
    public void exportToExcel(){
        string queryString = 'Select Id,ASI_MFM_Plan__r.Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_KR_subLedger__r.Name,ASI_MFM_Venue_Where__r.ASI_CRM_MY_CustomerCode__c,ASI_MFM_AccountsAdditionalField__r.ASI_CRM_MY_CustomerCode__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Total_Cost__c,ASI_MFM_Plan_Line_Item_External_IDUpload__c from ASI_MFM_Plan_Line_Item__c  where ASI_MFM_Plan__c =\''+Plan.Id+'\'';
        
        List<ASI_MFM_Plan_Line_Item__c> lstConsignmentSearchData = DataBase.Query(queryString);
        if(lstConsignmentSearchData.size()>0){
            for(ASI_MFM_Plan_Line_Item__c csd :lstConsignmentSearchData){
                wrapper w = new wrapper();
                W.PlanExternalID=csd.ASI_MFM_Plan__r.Name;
                w.SubBrandCode=csd.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c;
                w.Subledger=csd.ASI_MFM_KR_subLedger__r.Name;
                w.APCode=csd.ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c;
                if(csd.ASI_MFM_AccountsAdditionalField__r.ASI_CRM_MY_CustomerCode__c!=null){
                    w.Customer=csd.ASI_MFM_AccountsAdditionalField__r.ASI_CRM_MY_CustomerCode__c;
                }
                
                if(csd.ASI_MFM_Venue_Where__r.ASI_CRM_MY_CustomerCode__c!=null){
                   w.VenueWhere=csd.ASI_MFM_Venue_Where__r.ASI_CRM_MY_CustomerCode__c; 
                }
                
                if(csd.ASI_MFM_Total_Cost__c!=null){
                     w.PlanLineAmount=csd.ASI_MFM_Total_Cost__c;
                } 
                
                if(csd.ASI_MFM_List_Item_Description__c!=null){
                    w.LineItemExternalID=csd.ASI_MFM_List_Item_Description__c;
                }
                
                if(csd.ASI_MFM_Plan_Line_Item_External_IDUpload__c!=null){
                    w.LineItemExternalID=csd.ASI_MFM_Plan_Line_Item_External_IDUpload__c;
                }
                
                lstwrapper.add(w);
                
            }
        }
    }
    
    public class wrapper
    {
        public string PlanExternalID {get; set;}{PlanExternalID='';}
        public string SubBrandCode {get; set;}{SubBrandCode='';}
        public string Subledger {get; set;}{Subledger='';}
        public string APCode {get; set;}{APCode='';}
        public string Customer {get; set;}{Customer='';}
        public string VenueWhere {get; set;}{VenueWhere='';}
        public string ListItemDescription {get; set;}{ListItemDescription='';}
        public decimal PlanLineAmount {get; set;} {PlanLineAmount=0.0;}
        public String LineItemExternalID  {get; set;}{LineItemExternalID='';}
    }
    
    
}