public with sharing class ASI_MFM_PH_Payment_PDF_PageController {
    public id paymentID {set;get;}
    public string RT {set;get;}
    public Decimal TaxRate {set;get;}
    public ASI_MFM_Payment__c paymentCurrent{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> paymentLineList{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> payeeList{get;set;}
    public List<List<ASI_MFM_Payment_Line_Item__c>> payment{get;set;}
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }  
    
    public ASI_MFM_PH_Payment_PDF_PageController(){}
    
    public ASI_MFM_PH_Payment_PDF_PageController(ApexPages.StandardController controller) {
            this.paymentCurrent = (ASI_MFM_Payment__c)controller.getRecord();
    }
    
    public boolean init(){
        paymentCurrent = [select Name,RecordType.DeveloperName, Owner.Name, ASI_MFM_Payment_Date__c, ASI_MFM_Currency__c, ASI_MFM_Remarks__c, ASI_MFM_One_Off_Payee__c, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment_Amount__c,CreatedDate from ASI_MFM_Payment__c where id = :paymentID];//From ASI_MFM_Payment__c  

        if(paymentCurrent.RecordType.DeveloperName.contains('ASI_MFM_PH_DF')){
            RT='DF';
        }else{
            RT='DP';
        }
        
        paymentLineList =[
            select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_VAT__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Tax_Rate__c,ASI_MFM_Payee__r.Name, ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.Name,
                ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name, ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name, 
                    ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_Payment_Amount__c,ASI_MFM_Payment_Amount_Distributor__c  from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentID order by Name];// From ASI_MFM_Payment_Line_Item__c            
       
        
        if(paymentLineList.size()>0){
            TaxRate=paymentLineList[0].ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_VAT__c;
        }
		payeeList =[select ASI_MFM_Payee__r.Name from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentID order by ASI_MFM_Payee__c]; // Payee only
         
        Set<String> myset = new Set<String>();
         List<String> result  = new List<String>();
         for (ASI_MFM_Payment_Line_Item__c pe :payeeList){           
           myset.add(pe.ASI_MFM_Payee__r.Name);  
         }   
        result.addAll(myset);
         for (String r: result){
             Double subtotal = 0;
             for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                 if (r == p.ASI_MFM_Payee__r.Name){
                     subtotal += p.ASI_MFM_Payment_Amount__c;
                 }
             }
             for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                 if (r == p.ASI_MFM_Payee__r.Name){
                     p.ASI_MFM_Payment_Amount_Distributor__c = subtotal;
                 }
             }
         }
         
        List<List<ASI_MFM_Payment_Line_Item__c>> tmplist = new List<List<ASI_MFM_Payment_Line_Item__c>>();
         for (String r: result){
             List<ASI_MFM_Payment_Line_Item__c> subList = new List<ASI_MFM_Payment_Line_Item__c>();
             for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                 if (r == p.ASI_MFM_Payee__r.Name){				
					subList.add(p);
                 }
             }
             tmplist.add(subList);
         }
         payment = tmplist;
         
         return true;        
    }
}