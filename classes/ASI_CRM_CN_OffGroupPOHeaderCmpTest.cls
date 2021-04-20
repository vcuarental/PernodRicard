/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffGroupPOHeaderCmpTest 
 * Description: Test class for ASI_CRM_CN_OffGroupPOHeaderEditCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-08-29       Canter Duan             Created
 ****************************************************************************************************************************/
 @isTest
public class ASI_CRM_CN_OffGroupPOHeaderCmpTest {
    static testMethod void ASI_CRM_CN_OffGroupPOHeaderCmpTest(){
        ASI_CRM_CN_OffGroupPOHeaderCmpController cmp = new ASI_CRM_CN_OffGroupPOHeaderCmpController();
        List<SelectOption> selList = cmp.getPoType();
    }
}