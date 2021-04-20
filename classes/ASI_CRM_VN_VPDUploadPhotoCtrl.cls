/*********************************************************************************
 * Name: ASI_CRM_VN_VPDUploadPhotoCtrl
 * Description: Controller for ASI_CRM_VN_VPDUploadPhotoPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 1/12/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_VPDUploadPhotoCtrl {
    
	public Attachment attachment {
    	get {
      		if (attachment == null) attachment = new Attachment();
      		return attachment;
    	}
  		set;
  	}
    
    public ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail {get; set;}
    
    public ASI_CRM_VN_VPDUploadPhotoCtrl(ApexPages.StandardController stdController) {
        visitationPlanDetail = (ASI_HK_CRM_Visitation_Plan_Detail__c) stdController.getRecord();
    }
 
	public PageReference upload() {
        Map<String, String> pageParameterMap = ApexPages.currentPage().getParameters();
        String fileName  = pageParameterMap.get('fileName');
        String fileBody  = pageParameterMap.get('fileBody');
        String latitude  = pageParameterMap.get('latitude');
        String longitude = pageParameterMap.get('longitude');
        
        attachment.name        = fileName;
        attachment.body        = EncodingUtil.base64Decode(fileBody);
		attachment.OwnerId     = UserInfo.getUserId();
		attachment.ParentId    = visitationPlanDetail.Id; 
    	attachment.IsPrivate   = true;
        attachment.Description = latitude + ',' + longitude;
		System.debug('Debug Log : ' + attachment);
    	insert attachment;
        
    	PageReference pageRef = new PageReference('/' + visitationPlanDetail.Id);
        pageRef.setRedirect(true);
        return pageRef;
	}
}