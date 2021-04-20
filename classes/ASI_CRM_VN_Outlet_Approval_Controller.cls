public class ASI_CRM_VN_Outlet_Approval_Controller {
    public Id customerId {get;set;}
    public List<ASI_CRM_Pros_Image_Level__c> getProsImage() {
        List<ASI_CRM_Pros_Image_Level__c> ProsImage;
        List<ASI_CRM_Pros_Segmentation__c> list_PROS = [SELECT id, name from ASI_CRM_Pros_Segmentation__c WHERE ASI_CRM_SG_Customer__c = :customerId];
        if (list_PROS.size() > 0) {
           ProsImage = [SELECT ASI_CRM_SG_Statement__c, ASI_CRM_SG_Answer__c, ASI_CRM_Score__c FROM ASI_CRM_Pros_Image_Level__c WHERE ASI_CRM_SG_Pros_Segmentation__c = :list_PROS[0].id];
        }
        return ProsImage;
    }
}