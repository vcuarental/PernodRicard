public with sharing class ASI_CRM_CN_EOL_PDFController{
    
    public ASI_CRM_EOL__c header;
    public String currentHeaderID {set;get;}
    public string strPDF {set;get;}
    public ASI_CRM_CN_EOL_PDFController(){}
    public ASI_CRM_CN_EOL_PDFController(ApexPages.StandardController stdController){}
    
    //Add by Tony
    public List<ASI_Attachment__c> att_list{get;set;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    
    public ASI_CRM_EOL__c getheader(){
        if(header == null && currentHeaderID != null){
            header = [SELECT ASI_CRM_Action_Plan_Execution__c,  ASI_CRM_Brand__c, ASI_CRM_Category__c,Owner.Name,
                      ASI_CRM_Current_Inventory__c, ASI_CRM_Date__c, ASI_CRM_Depletion_Plan_Vol__c,ASI_CRM_New_Product_Launch_No__r.name,
                      ASI_CRM_Item_Group_No__c, ASI_CRM_Marketing_Contact__c, ASI_CRM_Packing__c,ASI_CRM_Subbrand__r.name,
                      ASI_CRM_Product_Name_Chinese__c, ASI_CRM_Product_Name_English__c, ASI_CRM_SKU_Type__c,ASI_CRM_Marketing_Contact__r.name,
                      AsI_CRM_Status__c, ASI_CRM_Status_Update_After_12_Months__c, ASI_CRM_Status_Update_After_3_Months__c,
                      ASI_CRM_Status_Update_After_6_Months__c, ASI_CRM_Substitute_Product__c, ASI_CRM_When_To_EOL__c,
                      Name, ASI_CRM_Request_Type__c
                      FROM ASI_CRM_EOL__c
                      WHERE id = : currentHeaderID];
        }
        return header;
    }
    public boolean init(){
        att_list = new List<ASI_Attachment__c>();
        att_list=[select id,name,ASI_Image_URL__c from ASI_Attachment__c where ASI_Product_End_of_Life_Request__c =: currentHeaderID];
        
        return true;
    }
}