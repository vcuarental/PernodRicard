@isTest(seealldata=false)
public class EUR_CRM_DE_TestAdminConsoleController{
    
    @isTest
    public static void testAccrue(){
        EUR_CRM_DE_AdminConsoleController adminCon = new EUR_CRM_DE_AdminConsoleController();
        //-achievement
            adminCon.prepareVisitActions();
            adminCon.getTotalPages();
            adminCon.accrue();
            adminCon.refresh();
            adminCon.firstPage();
            adminCon.nextPage();
            adminCon.previousPage();
    }
    @isTest
    public static void testOnTradeActivities(){
        User mktUser  = EUR_CRM_DE_TestClassUtilityHelper.createUser('EUR System Admin',  'EUR_DE_National_Sales_Manager_On_Trade','testdezxc4@testemail.com', 'testdezxc4@testemail.com', 'testdezxc4');
           system.runas(mktUser){
            EUR_CRM_DE_AdminConsoleController adminCon = new EUR_CRM_DE_AdminConsoleController(); 
            //-activities
            adminCon.getProsTable();
            adminCon.retrieveVariationTypeOptions();  
            adminCon.quickSaveParticipants();
        }
    }
}