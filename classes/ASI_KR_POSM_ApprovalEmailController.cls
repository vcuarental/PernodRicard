public class ASI_KR_POSM_ApprovalEmailController {

    public Id posmlineID {get;set;}
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
   
   
    public set<ID> supplierName                                      {get;set;}{supplierName = new set<ID>();}   
    public set<ID> HeaderID                                          {get;set;}{HeaderID = new set<ID>();}   
    public Map<ID, ASI_KOR_POSM_Order_Detail__c> AllRelatedLineMap   {get;set;}{ AllRelatedLineMap = new Map<ID, ASI_KOR_POSM_Order_Detail__c>();}
   // public List<ASI_KOR_POSM_Order_Request__c>   HeaderList          {get;set;}{HeaderList = new List<ASI_KOR_POSM_Order_Request__c>();}
    public ASI_KOR_POSM_Order_Request__c HeaderList{get;set;}
     

    public boolean init()
    {

        //1.1 POSM Line: find the line that line ID = posmlineID   ==>Put into List<ASI_KOR_POSM_Order_Detail__c> posmLineList
        List<ASI_KOR_POSM_Order_Detail__c> posmLineList = [select Id, Name, ASI_KOR_POSM_Order_Request__c,  ASI_KOR_Supplier__c 
                                                           from ASI_KOR_POSM_Order_Detail__c where id  =: posmlineID]; 
        
        //1.2 Get Supplier Name         ==> add to set<ID> supplierName 
        //1.3 Get Header ID             ==> add to set<ID> HeaderID 
        if(posmLineList.size()>0){ 
            for (ASI_KOR_POSM_Order_Detail__c line: posmLineList){
            supplierName.ADD(line.ASI_KOR_Supplier__c);                     //Supplier
            HeaderID.ADD(line.ASI_KOR_POSM_Order_Request__c);               //HEADER   
            }
        }
        
        
        //1.4 Get ALL POSM Lines that has same POSM Header and Supplier  ==> put to Map<ID, ASI_KOR_POSM_Order_Detail__c> AllRelatedLineMap 
        for(ASI_KOR_POSM_Order_Detail__c LineItems : [select Id, Name, ASI_KOR_POSM_Order_Request__c,ASI_KOR_Remarks__c,
                                                            ASI_KOR_POSM_Order_Request__r.ASI_KOR_Request_No__c, ASI_KOR_POSM_Order_Request__r.ASI_KOR_Requestor__c, 
                                                            ASI_KOR_Supplier__c,ASI_KOR_Supplier__r.Name, ASI_KOR_Item_Name__r.name,
                                                            ASI_KOR_SubBrand__r.ASI_MFM_Sub_brand_Code__c,ASI_KOR_Item_Code__c, 
                                                            ASI_KOR_Quantity__c, ASI_KOR_Item_Name__r.ASI_KOR_UOM__c,ASI_KOR_Ship_To_Address__c,
                                                             ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__r.name,
                                                            ASI_KOR_SubBrand__r.name
                                                      from ASI_KOR_POSM_Order_Detail__c
                                                      where ASI_KOR_POSM_Order_Request__c IN : HeaderID AND ASI_KOR_Supplier__c IN : supplierName]){
                                                             
        AllRelatedLineMap.put(LineItems.id, LineItems);
        }  
         
        HeaderList = [select Id, Name , ASI_KOR_Request_No__c , ASI_KOR_Requestor__c, ASI_KOR_POSM_TO_Venue__R.NAME, ASI_KOR_POSM_TO_Venue__R.ASI_MFM_Address_Line_1__c,
                             ASI_KOR_POSM_TO_Venue__R.ASI_MFM_Address_Line_2__c,ASI_KOR_POSM_TO_Venue__c
                      from ASI_KOR_POSM_Order_Request__c where id IN: HeaderID lIMIT 1];
       // system.assertEquals(posmLineList, null);   
        
        
        
        
        return true; 
    }
}