public class ASI_MFM_KR_PlanLineExport
{
    //https://pernod-ricard--asisb6conf--c.cs8.visual.force.com/apex/ASI_MFM_KR_PlanLineExportPage2?Id=aHJL00000004HML
    public ASI_MFM_KR_PlanLineExport(apexpages.standardController sc)
    {
        ShowSKU=false;
        Filetype = '';
        lstwrapper = new List<wrapper>();
        header = 'Plan Line Item,Customer,Sub Ledger,Sub-brand,Description,Basic POSM,AP Code,AP Description,Plan Amount,Quantity,UOM,Estimated PR Budget,Delivery Date,Purchase Requests Line External ID'; // header = 'Ship To,Search Number,Account Name,Business Unit,Date,Expiration Date,Expiration End Date,Expiration Start Date,Group,Implant Date ,Invoice Date,Invoice Number\r\n';                     
        pr = [select Id,ASI_MFM_Company_Code__c,ASI_MFM_Plan__c,ASI_MFM_Service_Item_POSM__c,recordTypeId from ASI_MFM_Purchase_Request__c where id = :sc.getId()];
        if(pr.ASI_MFM_Service_Item_POSM__c=='Item'){
            ShowSKU=true;
        }
    }
    
    ASI_MFM_Purchase_Request__c pr = new ASI_MFM_Purchase_Request__c();
    public Boolean ShowSKU  {get;set;}{ShowSKU=false;}
    public string header {get;set;}
    public List<wrapper> lstwrapper {get; set;}
    
    public class wrapper
    {
        public string Name {get; set;}
        public string BasicPOSM{get; set;}{BasicPOSM='';} 
        public string ItemDescription {get; set;} {ItemDescription='';}
        public integer Quantity {get; set;}
        public string UOM {get; set;}{UOM='EA';}
        public string APCode {get; set;}
        public string APDescription{get; set;}{APDescription='';}
        public decimal Amount{get; set;} {Amount=0.0;}
        public decimal PlanAmount{get; set;} {PlanAmount=0.0;}
        public string DeliveryDate {get; set;}{DeliveryDate = String.valueOf(system.today());}
        
        public Date DeliveryDate2  {get; set;}{DeliveryDate2=system.today();}
        
        
        public string Customer {get; set;} {Customer='';} 
        public string SubLedger {get; set;} {SubLedger='';}
        public string SubBrandCode {get; set;}{SubBrandCode='';}
        public String ExternalID {get; set;}{ExternalID='';}
    }
    
    public string Filetype{get;set;}
    public boolean isExcel {get;set;}
    public boolean isCsv {get;set;}
    
    
    public void update_Excel(){
        
        string queryString = 'Select Id,Name,ASI_MFM_Quantity__c,ASI_MFM_Basic_POSM__r.Name,ASI_MFM_UOM__c,ASI_MFM_Description__c,ASI_MFM_Delivery_Date__c,ASI_MFM_Estimated_PR_budget__c,ASI_MFM_Plan_Line_Item__r.Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c,ASI_MFM_PurchaseRequests_Line_ExternalID__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Customer__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_Brand_Code_Only__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__r.Name,ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__c,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_brand_Code__c  from ASI_MFM_Purchase_Request_Line__c  where ASI_MFM_Purchase_Request__c =\''+pr.Id+'\'';
        
        List<ASI_MFM_Purchase_Request_Line__c> lstConsignmentSearchData = DataBase.Query(queryString);
        if(lstConsignmentSearchData.size()>0){
            for(ASI_MFM_Purchase_Request_Line__c csd :lstConsignmentSearchData){
                wrapper w = new wrapper();
                w.Name = csd.ASI_MFM_Plan_Line_Item__r.Name ;
                if(csd.ASI_MFM_Quantity__c !=null){
                    w.Quantity=integer.valueOf(csd.ASI_MFM_Quantity__c);                    
                }
                
                if(csd.ASI_MFM_Delivery_Date__c!=null){
                     w.UOM=csd.ASI_MFM_UOM__c;
                }
               
                if(csd.ASI_MFM_Basic_POSM__r.Name!=null){
                    w.BasicPOSM=csd.ASI_MFM_Basic_POSM__r.Name;
                }
                if(csd.ASI_MFM_Delivery_Date__c!=null){
                    w.DeliveryDate2=csd.ASI_MFM_Delivery_Date__c;
                }
                
                if(csd.ASI_MFM_Description__c!=null){
                    w.ItemDescription=csd.ASI_MFM_Description__c;
                }
                
                
                w.PlanAmount=csd.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Total_Cost__c;
                
                w.APCode=csd.ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c;
                w.APDescription=csd.ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c;//.replaceAll(',',' ');
                
                if(csd.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Customer__c!=null){
                    w.Customer =csd.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Customer__c;
                }
                if(csd.ASI_MFM_Description__c!=null){
                    w.ItemDescription = csd.ASI_MFM_Description__c;
                }
                if(csd.ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__c!=null){
                    w.SubLedger=csd.ASI_MFM_Plan_Line_Item__r.ASI_MFM_KR_subLedger__r.Name;
                }
                if(csd.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_Brand_Code_Only__c !=null){
                    w.SubBrandCode=csd.ASI_MFM_Plan_Line_Item__r.ASI_MFM_Sub_Brand_Code_Only__c;
                }
                //Added on 22 Feb 2017
                if(csd.ASI_MFM_Estimated_PR_budget__c!=null){
                    w.amount = csd.ASI_MFM_Estimated_PR_budget__c;
                }
                
                if(csd.ASI_MFM_PurchaseRequests_Line_ExternalID__c !=null){
                    w.ExternalID=csd.ASI_MFM_PurchaseRequests_Line_ExternalID__c;
                }
                //
                lstwrapper.add(w);
            } 
        }
        
    }
    
    
    public void exportToExcel()
    {
        string queryString = 'Select Id,ASI_MFM_List_Item_Description__c, Name,ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c,ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c,ASI_MFM_Total_Cost__c,ASI_MFM_Customer__c,ASI_MFM_Sub_Brand_Code_Only__c,ASI_MFM_KR_subLedger__r.Name,ASI_MFM_KR_subLedger__c,ASI_MFM_Sub_brand_Code__r.Name,ASI_MFM_Sub_brand_Code__c  from ASI_MFM_Plan_Line_Item__c  where ASI_MFM_AP_Code__r.ASI_MFM_PRPO_Needed__c=true and ASI_MFM_Plan__c =\''+pr.ASI_MFM_Plan__c+
            '\' and    ASI_MFM_Sub_brand_Code__r.ASI_MFM_Company_Code__c =\''+pr.ASI_MFM_Company_Code__c+'\''; //c where User_ID__c=\''+UserInfo.getUserId()+'\'';
        
        List<ASI_MFM_Plan_Line_Item__c> lstConsignmentSearchData = DataBase.Query(queryString);
        
        system.debug('lstConsignmentSearchData :'+lstConsignmentSearchData.size());
        if(lstConsignmentSearchData.size()>0){
            for(ASI_MFM_Plan_Line_Item__c csd :lstConsignmentSearchData){
                wrapper w = new wrapper();
                w.Name = csd.Name ;
                w.Quantity=1;
                w.PlanAmount=csd.ASI_MFM_Total_Cost__c;
                
                w.APCode=csd.ASI_MFM_AP_Code__r.ASI_MFM_AP_Code__c;
                w.APDescription=csd.ASI_MFM_AP_Code__r.ASI_MFM_AP_Description__c;//.replaceAll(',',' ');
                
                if(csd.ASI_MFM_Customer__c!=null){
                   w.Customer =csd.ASI_MFM_Customer__c;
                }
                if(csd.ASI_MFM_List_Item_Description__c!=null){
                    w.ItemDescription = csd.ASI_MFM_List_Item_Description__c;
                }
                if(csd.ASI_MFM_KR_subLedger__c!=null){
                     w.SubLedger=csd.ASI_MFM_KR_subLedger__r.Name;
                }
                if(csd.ASI_MFM_Sub_Brand_Code_Only__c !=null){
                    w.SubBrandCode=csd.ASI_MFM_Sub_Brand_Code_Only__c;
                }
                lstwrapper.add(w);
            }
        }//system.debug('lstwrapper :'+lstwrapper.size());
    }    
    
}