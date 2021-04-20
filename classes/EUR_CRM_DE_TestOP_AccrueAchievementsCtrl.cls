@isTest
public class EUR_CRM_DE_TestOP_AccrueAchievementsCtrl{
    
    @isTest
    public static void test(){
    
        EUR_CRM_OP_AccrueAchievementsController con = new EUR_CRM_OP_AccrueAchievementsController();
        con.getVisitActions();
        con.accrue();
        con.refresh();
    }

}