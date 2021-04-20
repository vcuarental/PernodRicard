/*********************************************************************************
 * Name:ASI_CRM_JP_MassCreateAndUpdateAbstract
 * Description: Interface class essential to MassCreateAndUpdate component. Modify with care.
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Conrad          Created
*********************************************************************************/
public interface ASI_CRM_JP_MassCreateAndUpdateAbstract extends ASI_CRM_PageInterface {    
    List<ASI_CRM_JP_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(ASI_CRM_JP_MassCreateAndUpdateController controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_CRM_JP_MassCreateAndUpdateController controller, String actionKey, sObject sObj);
}