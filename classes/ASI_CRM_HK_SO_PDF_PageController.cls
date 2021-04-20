public class ASI_CRM_HK_SO_PDF_PageController {
    public ASI_CRM_HK_SO_PDF_PageController(ApexPages.StandardController controller) {
        this.soCurrent = (ASI_HK_CRM_Sales_Order__c)controller.getRecord();
        
    }
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public string BarCodestring  {set;get;} {BarCodestring = '';}
    public id SOID {set;get;}
    public String Year {set;get;}
    public ASI_HK_CRM_Sales_Order__c soCurrent{get;set;}
    public List<ASI_HK_CRM_Sales_Order_Item__c> SODetail {get;set;} {SODetail = new List<ASI_HK_CRM_Sales_Order_Item__c>  ();} 
    public List<ASI_CRM_EDI_SO_Item__c> EDISOList {get;set;} {EDISOList = new List<ASI_CRM_EDI_SO_Item__c>();} 
    public ASI_CRM_HK_SO_PDF_PageController(){ }
    
    public boolean init(){
        //Map<String,ASI_CRM_EDI_SO_Item__c> EDISOMap = new Map<String,ASI_CRM_EDI_SO_Item__c>(); // subbrand / Map<String,ASI_CRM_EDI_SO_Item__c>
        
        soCurrent = [select Id,Name,ASI_HK_CRM_JDE_Order_No__c,ASI_HK_CRM_Delivery_Date__c,ASI_HK_CRM_Order_Date__c,ASI_HK_CRM_EDI_SO__c,
                     ASI_HK_CRM_Delivery_Address__c,ASI_HK_CRM_Customer_DA__r.Name,ASI_HK_CRM_Cust_PO__c
                     from ASI_HK_CRM_Sales_Order__c where id =: SOID];
        
        SODetail=[select id,ASI_HK_CRM_SKU__c,ASI_HK_CRM_SKU__r.Name,ASI_HK_CRM_SKU_Packing_Description__c,ASI_HK_CRM_Price__c, ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Description__c,
                  ASI_HK_CRM_Quantity__c,ASI_CRM_EDI_Sales_Order_Item__r.ASI_CRM_SKU_Code__c,ASI_CRM_EDI_Sales_Order_Item__r.ASI_CRM_Product_EAN_Code__c
                  from ASI_HK_CRM_Sales_Order_Item__c where ASI_HK_CRM_Sales_Order__c =: SOID ];
        
        IF(soCurrent.ASI_HK_CRM_EDI_SO__c!=null){
            List<Attachment> attList = [select id from Attachment where ParentId = :soCurrent.ASI_HK_CRM_EDI_SO__c ];
            if(attList.size()>0){
                BarCodestring = '/servlet/servlet.FileDownload?file='+attList[0].Id; //URL.getSalesforceBaseUrl().toExternalForm()
            }
            EDISOList =  new List<ASI_CRM_EDI_SO_Item__c>();
            EDISOList = [select id,ASI_CRM_PR_SKU__c,ASI_CRM_SKU_Code__c,ASI_CRM_Product_EAN_Code__c,ASI_CRM_SKU_Description__c,
                         ASI_CRM_SKU_Description_2__c,ASI_CRM_EDI_Per_Bottle_Price__c,ASI_CRM_Order_Quantity__c 
                         from ASI_CRM_EDI_SO_Item__c
                         where ASI_CRM_EDI_Sales_Order_Header__c = :soCurrent.ASI_HK_CRM_EDI_SO__c  ];

        }

        
        return false;   
    }

}