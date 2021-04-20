public without sharing class ASI_CRM_CN_TOV_PDF_Controller {
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public String currentHeaderID {set;get;}
    public List<ASI_FOC_Request_Item__c> lineItemFGR{get;set;}
    public ASI_CRM_TOV__c TOCurrent{get;set;}
    public List<ASI_CRM_TOV_Detail__c> lineItem{get;set;}
    //20200710 Added by Leo BLS start.
    //The assembly page displays the required TOV Line Items information
    public List<IineItemShowBean> IineItemShowBeanList{get;set;}
    //Controls whether the page displays the owner column
    public boolean showPOSM{get;set;}
    //20200710 Added by Leo BLS end.
    public Double totalQty {get;set;}
    
    public boolean init(){
        {
            TOCurrent = [select id
                         , ASI_CRM_Customer_Code__c
                         , ASI_CRM_SO_Number__c
                         , ASI_CRM_Order_Date__c
                         , ASI_CRM_SF_SO_Request_Number__r.name
                         , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Address__c
                         , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Legal_Name__c
                         , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CRM_Code__c
                         , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Tel_Mobile__c
                         , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_SG_Order_Date__c
                         , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Other_Requirement__c
                         , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Contact_Person__c
                         , ASI_CRM_Free_Goods_Request__r.name
                         , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Receiptor_Name__c
                         , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Deliver_to_Address_Line_1__c
                         , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Date_of_Delivery__c
                         , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Receiptor_Mobile__c
                         , ASI_CRM_Free_Goods_Request__r.ASI_MFM_DetailAddress__c 
                         , ASI_CRM_Free_Goods_Request__r.ASI_FOC_To_Regional_Warehouse__r.Name 
                         , ASI_CRM_Free_Goods_Request__r.ASI_FOC_To_Regional_Warehouse__r.ASI_FOC_Warehouse_Type__c 
                         , ASI_CRM_Free_Goods_Request__r.ASI_CRM_Outlet__r.name
                         , ASI_CRM_Free_Goods_Request__r.ASI_MFM_Supplier_Name__r.name
                         , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Delivery_Instruction_1__c 
                         , ASI_CRM_Free_Goods_Request__r.ASI_MFM_Request_Category__c 
                         , ASI_CRM_Free_Goods_Request__r.ASI_MFM_Request_Category_Recipient__c 
                         from ASI_CRM_TOV__c 
                         where id = : currentHeaderID
                        ]; 
            lineItem = new list<ASI_CRM_TOV_Detail__c>();
            lineItem = [select id,ASI_CRM_SKU__c
                        , ASI_CRM_Order_QTY__c
                        , ASI_CRM_UOM__c 
                        , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c
                        , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.name
                        , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c
                        , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_BT_Size_C__c
                        , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_MFM_Item_Group_Code__c
                        , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c
                        , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c
                        , ASI_CRM_SF_FOC_Request_Line_Number__r.ASI_FOC_CN_Packing_Description__c
                        , ASI_CRM_SF_FOC_Request_Line_Number__r.ASI_FOC_SKU_Chinese_Description__c
                        , ASI_CRM_SF_FOC_Request_Line_Number__r.ASI_FOC_SKU__r.Name
                        , ASI_CRM_Item_Group__c
                        , ASI_CRM_Pack_Description__c
                        , ASI_CRM_SKU_Description__c
                        , ASI_CRM_SF_FOC_Request_Line_Number__c//ASI_FOC_Request_Item__c
                        from ASI_CRM_TOV_Detail__c 
                        where ASI_CRM_TOV__c = : currentHeaderID]; 

            //20200710 Added by Leo BLS start.
            //ASI_FOC_Request_Item__c - id Set
            Set<Id> requestItemSet = new Set<Id>();
            for (ASI_CRM_TOV_Detail__c tovd : lineItem) {
                requestItemSet.add(tovd.ASI_CRM_SF_FOC_Request_Line_Number__c);
            }
            List<ASI_FOC_Request_Item__c> requestItemList = new List<ASI_FOC_Request_Item__c>();
            requestItemList = [ SELECT Id,(SELECT Id,ASI_MFM_User__r.Name FROM Request_Item_User_Assignments__r) FROM  ASI_FOC_Request_Item__c WHERE Id IN: requestItemSet];
            //MAP< ASI_FOC_Request_Item__c-id , Request Item User Assignments - ASI_MFM_User__r.Name >
            Map<Id,String> userAssignmentMap = new Map<Id, String>();
            for(ASI_FOC_Request_Item__c reqItem : requestItemList)
            {
                String userStr = '';
                if (reqItem.Request_Item_User_Assignments__r.size() > 0) {
                    for(ASI_MFM_RequestItem_UserAssignment__c ua : reqItem.Request_Item_User_Assignments__r)
                    {
                        userStr += ua.ASI_MFM_User__r.Name + ',';
                    }
                    userStr = userStr.Substring(0, userStr.Length() - 1);
                    userAssignmentMap.put(reqItem.Id, userStr); 
                    showPOSM = true;
                }else{
                    showPOSM = false;
                    break;
                }                
            }
                       
            IineItemShowBeanList = new List<IineItemShowBean>();    
            for (ASI_CRM_TOV_Detail__c tovd : lineItem ) {  
                //  Load each row of TOV TOV Line Items into a Bean and add Request Item User Assignments-ASI_MFM_User__r.Name       
                IineItemShowBean itBean = new IineItemShowBean();
                itBean.ASI_CRM_SKU = tovd.ASI_CRM_SKU__c;
                itBean.ASI_CRM_Item_Group = tovd.ASI_CRM_Item_Group__c;
                itBean.ASI_CRM_CN_Chinese_Name = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c;
                itBean.ASI_CRM_CN_Eng_Name = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c;
                itBean.ASI_CRM_Order_QTY = tovd.ASI_CRM_Order_QTY__c;
                itBean.ASI_CRM_UOM = tovd.ASI_CRM_UOM__c;
                itBean.ASI_FOC_SKU_Chinese_Description = tovd.ASI_CRM_SF_FOC_Request_Line_Number__r.ASI_FOC_SKU_Chinese_Description__c;
                itBean.ASI_FOC_SKU_Name = tovd.ASI_CRM_SF_FOC_Request_Line_Number__r.ASI_FOC_SKU__r.Name;
                itBean.ASI_MFM_RequestItem_UserAssignment_User = userAssignmentMap.get(tovd.ASI_CRM_SF_FOC_Request_Line_Number__c);
                IineItemShowBeanList.add(itBean);                
            }
            //20200710 Added by Leo BLS end.
            for(ASI_CRM_TOV_Detail__c obj : lineItem){
                if(totalQty == NULL)totalQty = 0;
                if(obj.ASI_CRM_Order_QTY__c != NULL)totalQty += obj.ASI_CRM_Order_QTY__c;
            }
            return true;           
        }
    }
    //20200710 Added by Leo BLS start.
    public class IineItemShowBean  {

        public String ASI_CRM_SKU { get; set; }
        public String ASI_CRM_Item_Group { get; set; }
        public String ASI_CRM_CN_Chinese_Name { get; set; }
        public String ASI_CRM_CN_Eng_Name { get; set; }
        public Double ASI_CRM_Order_QTY { get; set; }
        public String ASI_CRM_UOM { get; set; }        
        public String ASI_FOC_SKU_Chinese_Description { get; set; }        
        public String ASI_FOC_SKU_Name { get; set; }
        public String ASI_MFM_RequestItem_UserAssignment_User{ get; set; }
    }
    //20200710 Added by Leo BLS end.
}