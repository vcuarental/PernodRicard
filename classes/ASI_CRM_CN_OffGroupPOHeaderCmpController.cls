/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffGroupPOHeaderCmpController
 * Description: Apex class for ASI_CRM_CN_OffGroupPOHeaderCmp
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-06       Keith Yip               Created
 ****************************************************************************************************************************/
public class ASI_CRM_CN_OffGroupPOHeaderCmpController {
    public ASI_CRM_CN_OffGroupPOHeaderCmpController() {

    }

    public List<SelectOption> getPoType() {
        List<SelectOption> stOptions = new List<SelectOption>();
        stOptions.add(new SelectOption('TOT/MOT Group PO','TOT/MOT Group PO'));
        stOptions.add(new SelectOption('Outlet Promotion','Outlet Promotion'));
        stOptions.add(new SelectOption('Consumer Promotion','Consumer Promotion'));
        stOptions.add(new SelectOption('Wholesaler Promotion','Wholesaler Promotion'));
        return stOptions;
    }

}