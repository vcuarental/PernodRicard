/********************************************************************************
 *  This class contains unit tests for validating the behavior of Apex classes
 *  and triggers.
 *
 *  Unit tests are class methods that verify whether a particular piece
 *  of code is working properly. Unit test methods take no arguments,
 *  commit no data to the database, and are flagged with the testMethod
 *  keyword in the method definition.
 *
 *  All test methods in an organization are executed whenever Apex code is
 *  deployed to a production organization to confirm correctness, ensure code
 *  coverage, and prevent regressions. All Apex classes are required to have at
 *  least 75% code coverage in order to be deployed to a production organization.
 *  In addition, all triggers must have some code coverage.
 *
 *  The @isTest class annotation indicates this class only contains test
 *  methods. Classes defined with the @isTest annotation do not count against
 *  the organization size limit for all Apex scripts.
 *
 *  See the Apex Language Reference for more information about Testing
 *  and Code Coverage.
 *
 * NAME         :   GDT_ManageActivity_TEST.cls
 * AUTHOR       :   Simon GAZIN
 * DATE         :   27.05.2014
 *
 * MAINTENANCE  :
 * AUTHOR       :
 * DATE         :
 ********************************************************************************/
@isTest (SeeAllData = true)
public class GDT_ManageActivity_TEST {

    //Variable Declaration
    public static GDT_Activity__c objActivity01 {get;set;}
    public static GDT_Activity__c objActivity02 {get;set;}
    public static GDT_Services__c objService01 {get;set;}
    public static GDT_Services__c objService02 {get;set;}
    public static Id bmcImpact = [SELECT Id FROM BMCServiceDesk__Impact__c WHERE Name LIKE '2%' LIMIT 1].Id;
    public static Id bmcUrgency = [SELECT Id FROM BMCServiceDesk__Urgency__c WHERE Name LIKE '2%' LIMIT 1].Id;

    /**
     * [initializes01 description]
     */
    public static void initializes01() {

        objService01 = new GDT_Services__c();
            objService01.Counter__c     = 1;
            objService01.Label__c       = 'New SandBox (include Q&A environment';
            objService01.Code__c        = 'SFDC-S01';
            objService01.ReportGroup__c = 'Sandbox Management (New, Refresh, ...)';
            objService01.Name           = 'SFDC - S01 New SandBox';
            objService01.BMCImpact__c   = bmcImpact;
            objService01.BMCUrgency__c  = bmcUrgency;

        objActivity01 = new GDT_Activity__c();
            objActivity01.GDT_Services__c               = objService01.Id;
            objActivity01.Affiliate_Group__c            = 'PR Asia';
            objActivity01.Project_Name__c               = 'PR Asia-Asia Combined system';
            objActivity01.Environment_Destination__c    = 'PRODUCTION';
            objActivity01.Environment_Source__c         = 'STAGING';
            objActivity01.Sandbox_Name__c               = 'SGDEV';
            objActivity01.Sandbox_Type__c               = 'Developer';
            objActivity01.Status__c                     = 'In Progress';
            objActivity01.Commentary__c                 = 'Commentary Test';
            objActivity01.Date_Request__c               = Date.newInstance(2014, 11, 28);
            objActivity01.Date_Delivery__c              = Date.newInstance(2014, 11, 28);

        if([SELECT count() FROM GDT_Services__c WHERE Code__c = 'SFDC-S01'] == 0) {
            insert objService01;
        }
        else{
            objActivity01.GDT_Services__c = [SELECT Id FROM GDT_Services__c WHERE Code__c = 'SFDC-S01'].Id;
        }

        //Trigger BeforeInsert
        GDT_ManageActivity ma = new GDT_ManageActivity();
        ma.ResetCounter(objActivity01);
        ma.EditName(objActivity01);
        ma.CreateIncident(objActivity01);
        ma.RecordFormat(objActivity01);

        insert objActivity01;
        ma.UpdateCounter(objActivity01);
    }

    /**
     * [initializes02 description]
     */
    public static void initializes02() {

        objService02 = new GDT_Services__c();
            objService02.Counter__c     = 1;
            objService02.Label__c       = 'Request of release';
            objService02.Code__c        = 'SFDC-S02';
            objService02.ReportGroup__c = 'Request of release';
            objService02.Name           = 'SFDC - S02 Request of release';
            objService02.BMCImpact__c   = bmcImpact;
            objService02.BMCUrgency__c  = bmcUrgency;

        objActivity02 = new GDT_Activity__c();
            objActivity02.GDT_Services__c               = objService02.Id;
            objActivity02.Affiliate_Group__c            = 'PR Asia';
            objActivity02.Project_Name__c               = 'PR Asia-Asia Combined system';
            objActivity02.Project_Description__c        = 'Description of project';
            objActivity02.Environment_Destination__c    = 'PRODUCTION';
            objActivity02.Environment_Source__c         = 'STAGING';
            objActivity02.Sandbox_Name__c               = NULL;
            objActivity02.Sandbox_Type__c               = 'Developer';
            objActivity02.Status__c                     = 'In Progress';
            objActivity02.Commentary__c                 = 'Commentary Test';
            objActivity02.Date_Request__c               = Date.newInstance(2014, 11, 28);
            objActivity02.Date_Delivery__c              = Date.newInstance(2014, 11, 28);

        if([SELECT count() FROM GDT_Services__c WHERE Code__c = 'SFDC-S02'] == 0) {
            insert objService02;
        }
        else{
            objActivity02.GDT_Services__c = [SELECT Id FROM GDT_Services__c WHERE Code__c = 'SFDC-S02'].Id;
        }

        //Trigger BeforeInsert
        GDT_ManageActivity ma = new GDT_ManageActivity();
        ma.ResetCounter(objActivity02);
        ma.EditName(objActivity02);
        ma.CreateIncident(objActivity02);
        ma.RecordFormat(objActivity02);

        insert objActivity02;
        ma.UpdateCounter(objActivity02);
    }

    /*
     * TEST GDT_ManageActivity_Controller_Activity
     */
    static testMethod void myUnitTest_Activity() {
    
        GDT_ManageActivity_TEST.initializes01();
        
        //Start the test
        Test.startTest();

        //Instantiate a new controller with all parametres in the page
        ApexPages.StandardController sc = new ApexPages.StandardController(objActivity01);
        GDT_ManageActivity_Controller_Activity maca = new GDT_ManageActivity_Controller_Activity(sc);

        //Page Reference
        PageReference pageRef = Page.GDT_ManageActivity_TabActivity;
        Test.setCurrentPage(pageRef);

        System.debug(objActivity01.Template_Code__c);
        
        maca.slService = 2;
        maca.SelectService();
        //Picklist for the sorts of activities
        List<SelectOption> soServices = maca.optServices;
        System.debug('so Services : ' + soServices);
        List<SelectOption> soStatus = maca.optStatus;
        System.debug('so status : ' + soServices);
        List<SelectOption> soAffiliate = maca.optAffiliates;
        System.debug('so affiliate : ' + soAffiliate);
        List<SelectOption> soEnvironmentDest = maca.optEnvironmentDest;
        System.debug('so environment dest : ' + soEnvironmentDest);
        List<SelectOption> soAffiliateGroup = maca.optAffiliatesGroup;
        List<SelectOption> soProjectName = maca.optProjectName;

        //Testing function 
        objActivity01.GDT_Services__c = objService01.Id; //S02
        //maca.SelectService();
        maca.CompleteEmail();
        maca.toggleSort();

        //Testing the sorts of activities
        maca.slSortService = 1;
        maca.slSortAffiliate = 0;
        maca.slSortStatus = 0;
            maca.sortActivities();
        maca.slSortService = 0;
        maca.slSortAffiliate = 1;
        maca.slSortStatus = 0;
            maca.sortActivities();
        maca.slSortService = 0;
        maca.slSortAffiliate = 0;
        maca.slSortStatus = 1;
            maca.sortActivities();
        maca.slSortService = 3;
        maca.slSortAffiliate = 1;
        maca.slSortStatus = 0;
            maca.sortActivities();
        maca.slSortService = 5;
        maca.slSortAffiliate = 0;
        maca.slSortStatus = 1;
            maca.sortActivities();
        maca.slSortService = 0;
        maca.slSortAffiliate = 1;
        maca.slSortStatus = 1;
            maca.sortActivities();
        maca.slSortService = 5;
        maca.slSortAffiliate = 1;
        maca.slSortStatus = 1;
            maca.sortActivities();
            maca.sortReset();

        //Pagination
        System.debug('Pagination : '+ maca.startRecord +'-'+ maca.endRecord +' of '+ maca.totalRecord);
        System.debug('Pagination : Page '+ maca.currentPage +' of '+ maca.nbPage);

        //Stop the test
        Test.stopTest();
    }

    /*
     * TEST GDT_ManageActivity_Controller_Report
     */
    static testMethod void myUnitTest_Report() {
        //Variable Declaration
        objActivity02 = new GDT_Activity__c();

        //Page Reference
        ApexPages.StandardController sc = new ApexPages.StandardController(objActivity02);
        GDT_ManageActivity_Controller_Report macr = new GDT_ManageActivity_Controller_Report(sc);

        //Instantiate a new controller with all parametres in the page
        PageReference pageRef = Page.GDT_ManageActivity_ViewReport;
        Test.setCurrentPage(pageRef);

        //Start the test, this changes governor limit context to
        //that of trigger rather than test.
        Test.startTest();

            Integer rYear = 0;
            Integer rMonth = 0;
            //
            rYear = macr.thisYear;
            rMonth = macr.thisMonth;
            System.debug('This Year : ' + rYear);
            System.debug('This Month : ' + rMonth);
            //
            rYear = macr.lastYear;
            rMonth = macr.lastMonth;
            System.debug('Last Year : ' + rYear);
            System.debug('Last Month : ' + rMonth);

            Integer nbData;
            //
            nbData = macr.nbRequest;
            System.debug('Request : ' + nbData);
            nbData = macr.nbDeploymentS02;
            System.debug('Deployment : ' + nbData);
            nbData = macr.nbRequestS02;
            System.debug('Request S02 : ' + nbData);

            //Last Month
            nbData = macr.nbRequest_lm;
            System.debug('Request (LastMonth) : ' + nbData);
            nbData = macr.nbDeploymentS02_lm;
            System.debug('Deployment : ' + nbData);
            nbData = macr.nbRequestS02_lm;
            System.debug('Request S02 : ' + nbData);
            
             //Last Week
            nbData = macr.nbRequest_lw;
            System.debug('Request (LastWeek) : ' + nbData);
            nbData = macr.nbDeploymentS02_lw;
            System.debug('Deployment : ' + nbData);
            nbData = macr.nbRequestS02_lw;
            System.debug('Request S02 : ' + nbData);

            String idReport;
            //
            try {
                idReport = macr.reportId_FocusS02;
                idReport = macr.reportId_AllServicesRequested;
                idReport = macr.reportId_ServicesRequestedByAffiliate;                

                idReport = macr.reportId_FocusS02_LastMonth;
                idReport = macr.reportId_AllServicesRequested_LastMonth;
                idReport = macr.reportId_ServicesRequestedByAffiliate_LastMonth;
                
                idReport = macr.reportId_FocusS02_LastWeek;
                idReport = macr.reportId_AllServicesRequested_LastWeek;
                idReport = macr.reportId_ServicesRequestedByAffiliate_LastWeek;

                idReport = macr.reportId_StatusActivities;
            } catch(Exception e) {
              System.debug(e.getMessage());
            }
            

        Test.stopTest();
        //Stop the test, this changes limit context back to test from trigger.
    }

    /*
     * TEST GDT_ManageActivity_Controller_Line
     */
    static testMethod void myUnitTest_Line() {
        //
        GDT_ManageActivity_TEST.initializes02();
                
        //Start the test, this changes governor limit context to
        //that of trigger rather than test.
        Test.startTest();
            //Instantiate a new controller with all parametres in the page
            PageReference pageRef = Page.GDT_ManageActivity_NewLine;
            pageRef.getParameters().put('retURL', objActivity02.Id);
            pageRef.setRedirect(false);

            Test.setCurrentPage(pageRef);

            GDT_Activity_line__c objLine = new GDT_Activity_line__c(GDT_Activity_Relationship__c=objActivity02.Id);

            //Page Reference
            ApexPages.StandardController sc = new ApexPages.StandardController(objLine);
            GDT_ManageActivity_Controller_Line macl = new GDT_ManageActivity_Controller_Line(sc);

            macl.saveCustom();
        Test.stopTest();
        //Stop the test, this changes limit context back to test from trigger.
    }

    /*
     * TEST 
     */
    static testMethod void myUnitTest_Incident() {
        //
        GDT_ManageActivity_TEST.initializes02();

        //Start the test, this changes governor limit context to
        //that of trigger rather than test.
        Test.startTest();   
            //Instantiate a new controller with all parametres in the page
            ApexPages.StandardController sc = new ApexPages.StandardController(objActivity02);
            GDT_ManageActivity_Controller_Activity maca = new GDT_ManageActivity_Controller_Activity(sc);

            //Page Reference
            PageReference pageRef = Page.GDT_ManageActivity_ViewActivity;
            Test.setCurrentPage(pageRef);

            maca.WaitingForUserIncident();

            GDT_ManageActivity ma = new GDT_ManageActivity();
            ma.UpdateIncident(objActivity02);
            ma.CheckStatus(objActivity02);

            maca.InProgressIncident();
            maca.OpenIncident();
            
            objActivity02.Status__c = 'Resolved';
            update objActivity02;
            ma.CheckStatus(objActivity02);
            maca.ResolvedIncident();

            maca.CloseIncident();

            System.debug(objActivity02);
            System.debug(objActivity02.Incident__c);

            ma.DeleteIncident(objActivity02);
            delete objActivity02;

        Test.stopTest();
        //Stop the test, this changes limit context back to test from trigger.
    }


    static testMethod void testRequests(){
        GDT_Services__c objService02 = new GDT_Services__c();
        objService02.Counter__c     = 1;
        objService02.Label__c       = 'Request of release';
        objService02.Code__c        = 'SFDC-S020';
        objService02.ReportGroup__c = 'Request of release';
        objService02.Name           = 'SFDC - S02 Request of release';
        objService02.BMCImpact__c   = bmcImpact;
        objService02.BMCUrgency__c  = bmcUrgency;
        insert objService02;

        GDT_Activity__c objActivity02 = new GDT_Activity__c();
        objActivity02.GDT_Services__c               = objService02.Id;
        objActivity02.Affiliate_Group__c            = 'PR Asia';
        objActivity02.Project_Name__c               = 'PR Asia-Asia Combined system';
        objActivity02.Project_Description__c        = 'Description of project';
        objActivity02.Environment_Destination__c    = 'PRODUCTION';
        objActivity02.Environment_Source__c         = 'STAGING';
        objActivity02.Sandbox_Name__c               = NULL;
        objActivity02.Sandbox_Type__c               = 'Developer';
        objActivity02.Status__c                     = 'In Progress';
        objActivity02.Commentary__c                 = 'Commentary Test';
        objActivity02.Date_Request__c               = Date.newInstance(2014, 11, 28);
        objActivity02.Date_Delivery__c              = Date.newInstance(2014, 11, 28);

        ApexPages.StandardController controller = new ApexPages.StandardController(objActivity02);
        Apexpages.currentPage().getParameters().put('id', objActivity02.Id); 
        insert objActivity02;

        GDT_ManageActivity_Activity_Request con = new GDT_ManageActivity_Activity_Request(controller);

        GDT_ManageActivity_Activity_Request.getServiceOptions();
        GDT_ManageActivity_Activity_Request.getFields('SFDC-S03');
        GDT_ManageActivity_Activity_Request.getActivityRequests();
        GDT_ManageActivity_Activity_Request.getAttachments('');
        GDT_ManageActivity_Activity_Request.setStatus(objActivity02.Id, 'Resolved');

        Attachment atta = GDT_ManageActivity_Activity_Request.saveAttachment(objActivity02.Id, 'test','', 'text/plain; charset=UTF-8');


        GDT_Activity_Line__c line = GDT_ManageActivity_Activity_Request.createLine(objActivity02.Id)[0];
        GDT_ManageActivity_Activity_Request.deleteLineCtr(line.id,objActivity02.Id);
        GDT_ManageActivity_Activity_Request.deleteAttachments(atta.id);
        con.redirectView();
        con.redirectEdit();
        con.redirectNew();

    }


    static testMethod void testRequestsLines(){
        GDT_Services__c objService02 = new GDT_Services__c();
        objService02.Counter__c     = 1;
        objService02.Label__c       = 'Request of release';
        objService02.Code__c        = 'SFDC-S020';
        objService02.ReportGroup__c = 'Request of release';
        objService02.Name           = 'SFDC - S02 Request of release';
        objService02.BMCImpact__c   = bmcImpact;
        objService02.BMCUrgency__c  = bmcUrgency;
        insert objService02;

        GDT_Activity__c objActivity02 = new GDT_Activity__c();
        objActivity02.GDT_Services__c               = objService02.Id;
        objActivity02.Affiliate_Group__c            = 'PR Asia';
        objActivity02.Project_Name__c               = 'PR Asia-Asia Combined system';
        objActivity02.Project_Description__c        = 'Description of project';
        objActivity02.Environment_Destination__c    = 'PRODUCTION';
        objActivity02.Environment_Source__c         = 'STAGING';
        objActivity02.Sandbox_Name__c               = NULL;
        objActivity02.Sandbox_Type__c               = 'Developer';
        objActivity02.Status__c                     = 'In Progress';
        objActivity02.Commentary__c                 = 'Commentary Test';
        objActivity02.Date_Request__c               = Date.newInstance(2014, 11, 28);
        objActivity02.Date_Delivery__c              = Date.newInstance(2014, 11, 28);
        insert objActivity02;

        GDT_Activity_line__c objLine = new GDT_Activity_line__c(GDT_Activity_Relationship__c=objActivity02.Id);
        insert objLine;


        ApexPages.StandardController controller = new ApexPages.StandardController(objLine);
        Apexpages.currentPage().getParameters().put('id', objLine.Id); 

        GDT_ManageActivity_Line_Request con = new GDT_ManageActivity_Line_Request(controller);
        GDT_ManageActivity_Line_Request.getAttachments('');
        Attachment atta = GDT_ManageActivity_Line_Request.saveAttachment(objLine.Id, 'test','', 'text/plain; charset=UTF-8');
        GDT_ManageActivity_Line_Request.deleteAttachments(atta.id);

    }



}