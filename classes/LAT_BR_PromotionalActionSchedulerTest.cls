// SEE ALL DATA -> Can't Insert CollaborationGroup in Test Class
@isTest (seeAllData=true)
private class LAT_BR_PromotionalActionSchedulerTest {

    @isTest static void LAT_BR_PromotionalActionSchedulerT() {

        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        ap.LAT_StartDate__c =   date.today().addDays(30);
        update ap;
        LAT_ClientByRegionHandlerTest.generateLATConfig('Promotional_Action_Task_Days', '10');
        LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
        List<LAT_CHATTER_POST_BODY__c> lg2 = [Select Name from LAT_CHATTER_POST_BODY__c where Name = 'LAT_BR_AP_IniciarAcao'];
        if(lg2.size() == 0) {
            LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
            lg.Name = 'LAT_BR_AP_IniciarAcao';
            lg.Body__c = 'Ação Promocional xx_ACTION_NAME_xx iniciará em xx_START_DATE_xx';
            insert lg;

        }
        
        
        


        Test.StartTest();
            SchedulableContext sc = null;
            LAT_BR_PromotionalActionScheduler tsc = new LAT_BR_PromotionalActionScheduler();
            tsc.execute(sc);
        Test.StopTest();
    }




}