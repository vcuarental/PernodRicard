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
 * Name     :   GDT_ManageLicense_TEST.cls
 * Class, GDT_ManageLicense_Controller_Prchase.cls
 * 
 * Author   :   Simon GAZIN
 * Date     :   11.03.2015
 *********************************************************/
@isTest (SeeAllData = false)
private class GDT_ManageLicense_TEST
{
    //public GDT_ManageLicense_Purchase__c objPurchase_01 = new GDT_ManageLicense_Purchase__c();

    public static void initializes() {
        GDT_CustomSettings_Profile__c csProfile = new GDT_CustomSettings_Profile__c();
        csProfile.ProfileID__c = '00e1i000000YLVWAA4';
        csProfile.ProfileName__c = 'BMC_RF_ServiceDesk Client Only';
        csProfile.UserLicenseID__c ='Salesforce Platform';
        csProfile.AffiliateGroup__c = 'Pernod Ricard';
        csProfile.ApplicationName__c = 'BMC Remedyforce';
        csProfile.name = 'name';
        insert csProfile;

        GDT_ManageLicense_License__c objLicense_Salesforce = new GDT_ManageLicense_License__c();
        objLicense_Salesforce.Name = 'Sales Cloud Unlimited';
        objLicense_Salesforce.GDT_License_APIName__c = 'Salesforce';
        insert objLicense_Salesforce;
        
        GDT_ManageLicense_License__c objLicense_SalesforcePlatform = new GDT_ManageLicense_License__c();
        objLicense_SalesforcePlatform.Name = 'Force.com Unliited Apps';
        objLicense_SalesforcePlatform.GDT_License_APIName__c = 'Salesforce Platform';
        insert objLicense_SalesforcePlatform;
    }

    /**
     * LIMITS Salesforce
     */
    public static void getLimits() {
        System.debug('1. Number of SOQL queries: '+ Limits.getQueries() +' out of '+ Limits.getLimitQueries());
        System.debug('2. Number of DML rows: '+ Limits.getDMLRows() +' out of '+ Limits.getLimitDmlRows());
        System.debug('3. Number of records that have been returned by issuing SOQL queries: '+ Limits.getQueryRows() +' out of '+ Limits.getLimitQueryRows());
    }

    /** Test method for the controller: GDT_ManageLicense_Controller_Purchase */
    static testmethod void myUnitTest_ControllerPurchase() {
        Test.startTest();
            GDT_ManageLicense_TEST.getLimits();

            //
            GDT_ManageLicense_TEST.initializes();

            //Instantiate a new controller with all parametres in the page
            GDT_ManageLicense_Purchase__c objPurchase = new GDT_ManageLicense_Purchase__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(objPurchase);
            GDT_ManageLicense_Controller_Purchase mlcp = new GDT_ManageLicense_Controller_Purchase(sc);

            //Page Reference
            PageReference pageRef = Page.GDT_ManageLicense_Analysis;
            Test.setCurrentPage(pageRef);

            mlcp.addRecord_Purchase();

            System.debug('List: ' + mlcp.listAll_Purchase);

            GDT_ManageLicense_TEST.getLimits();
        Test.stopTest();
    }
 
    /** Test method for the controller: GDT_ManageLicense_Controller_Purchase */
    static testmethod void myTestBatch() {
        initializes();
        GDT_ManageLicense_Batch controller = new GDT_ManageLicense_Batch();
        controller.start(null);
        controller.execute_Update([SELECT Id, ProfileId, Name,Profile.UserLicense.Name FROM User WHERE isActive = true and Profile.UserLicense.Name in ('Salesforce', 'Salesforce Platform') limit 200]);
        
    }

    /** Test method for the controller: GDT_ManageLicense_Controller_cs */
    static testmethod void myUnitTest_ControllerCustomSettings_Profile(){
        Test.startTest();
            GDT_ManageLicense_TEST.getLimits();

            //
            GDT_ManageLicense_TEST.initializes();

            //Instantiate a new controller with all parametres in the page
            GDT_CustomSettings_Profile__c csProfile = new GDT_CustomSettings_Profile__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(csProfile);
            GDT_ManageLicense_Controller_cs mlcc = new GDT_ManageLicense_Controller_cs(sc);

            //Page Reference
            PageReference pageRef = Page.GDT_ManageLicense_Analysis;
            Test.setCurrentPage(pageRef);


            System.debug('Number of profile' + mlcc.nbProfile_All);

            System.debug('CustomSettings Profile: ' + mlcc.list_csProfile_All);
            //Refresh Custom Settings
            mlcc.refresh_CustomSettings_Profile();
            System.debug('CustomSettings Profile: ' + mlcc.list_csProfile_All);
            mlcc.refresh_CustomSettings_Profile();

            mlcc.saveCustomSettings_Profile();

            GDT_ManageLicense_TEST.getLimits();
        Test.stopTest();
    }

    /** Test method for the controller: GDT_ManageLicense_Controller_cs */
    static testmethod void myUnitTest_ControllerCustomSettings_Domaine(){
        Test.startTest();
            GDT_ManageLicense_TEST.getLimits();

            //
            GDT_ManageLicense_TEST.initializes();

            //Instantiate a new controller with all parametres in the page
            GDT_CustomSettings_ADDomaine__c csDomaine = new GDT_CustomSettings_ADDomaine__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(csDomaine);
            GDT_ManageLicense_Controller_cs mlcc = new GDT_ManageLicense_Controller_cs(sc);
            
            //Page Reference
            PageReference pageRef = Page.GDT_ManageLicense_Analysis;
            Test.setCurrentPage(pageRef);

            System.debug('Number of AD Domaine: ' + mlcc.nbDomaine_All);

            //System.debug('CustomSettings AD Domaine: ' + mlcc.list_csDomaine_All);
            //Refresh Custom Settings
            //mlcc.refresh_CustomSettings_ADDomaine();
            //System.debug('CustomSettings AD Domaine: ' + mlcc.list_csDomaine_All);
            //mlcc.refresh_CustomSettings_ADDomaine();

            //mlcc.saveCustomSettings_Domaine();

            GDT_ManageLicense_TEST.getLimits();
        Test.stopTest();
    }

    /** */
    public static void initializes_Analysis() {
        GDT_ManageLicense_TEST.initializes();

        GDT_ManageLicense_Purchase__c objPurchase = new GDT_ManageLicense_Purchase__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(objPurchase);
        GDT_ManageLicense_Controller_cs mlcc = new GDT_ManageLicense_Controller_cs(sc);
        //Add records in CustomSettings
        mlcc.refresh_CustomSettings_Profile();
        //Add Affiliate
        for(GDT_CustomSettings_Profile__c p : mlcc.list_csProfile_All){
            if((p.ProfileName__c).startsWith('EUR') == true){
                p.AffiliateGroup__c = 'PR Europe';
            }
        }
        mlcc.saveCustomSettings_Profile();
        System.debug('CustomSettings Profile: ' + mlcc.list_csProfile_All);

        //Insert new purchase
        objPurchase.GDT_Purchase_LicenseType__c = [SELECT Id FROM GDT_ManageLicense_License__c WHERE GDT_License_APIName__c = 'Salesforce'].Id;
        objPurchase.GDT_Purchase_AffiliateGroup__c = 'PR Europe';
        objPurchase.GDT_Purchase_AppName__c = '';
        objPurchase.GDT_Purchase_PurchaseDate__c = Date.today() - 1;
        objPurchase.GDT_Purchase_ExpirationDate__c = Date.today() + 1;
        objPurchase.GDT_Purchase_TotalLicenses__c = 200;
        insert objPurchase;
        System.debug(objPurchase);
    }

    /** Test method for the controller: GDT_ManageLicense_Controller_Analysis */
    static testmethod void myUnitTest_ControllerAnalysis(){
        Test.startTest();
            //
            GDT_ManageLicense_TEST.initializes_Analysis();

            //Page Reference
            PageReference pageRef = Page.GDT_ManageLicense_Analysis;
            Test.setCurrentPage(pageRef);

            GDT_ManageLicense_TEST.getLimits();

            GDT_ManageLicense_Analysis__c oAnalysis = new GDT_ManageLicense_Analysis__c();
            oAnalysis.GDT_Analysis_LicenseType__c = [SELECT Id FROM GDT_ManageLicense_License__c WHERE GDT_License_APIName__c = 'Salesforce'].Id;
            oAnalysis.GDT_Analysis_AffiliateGroup__c = 'aff';
            oAnalysis.GDT_Analysis_AppName__c = 'app';
            oAnalysis.GDT_Analysis_UsedLicenses__c = 0;
            oAnalysis.GDT_Analysis_TotalLicenses__c = 0;
            oAnalysis.GDT_Analysis_LastUpdate__c = true;
            insert oAnalysis;

            //Instantiate a new controller with all parametres in the page
            GDT_ManageLicense_Analysis__c objAnalysis = new GDT_ManageLicense_Analysis__c();
            ApexPages.StandardController sc = new ApexPages.StandardController(objAnalysis);
            GDT_ManageLicense_Controller_Analysis mlca = new GDT_ManageLicense_Controller_Analysis(sc);
            mlca.initializes();

            System.debug('Size() List User: ' + (mlca.listAll_User).size());
            System.debug('Size() ListLicense: ' + (mlca.listAll_License).size());
            System.debug('Size() List Purchase: ' + (mlca.listAll_Purchase).size());

            System.debug('List AD Domaine: ' + mlca.listAll_ADDomaine);

            /* Affiliate */
            System.debug(mlca.slAffiliate + ' : ' + mlca.optAffiliate);
            mlca.slAffiliate = String.valueOf(mlca.optAffiliate.get(mlca.optAffiliate.size() -1));
            System.debug(mlca.slAffiliate);
            mlca.onChangeFilter();
            System.debug('listAll_Analysis (filter Affiliate): ' + mlca.listAll_Analysis);
            /* License */
            System.debug(mlca.slLicenseName + ' : ' + mlca.optLicenseName);
            mlca.slLicenseName = String.valueOf(mlca.optLicenseName.get(mlca.optLicenseName.size() -1));
            System.debug(mlca.slLicenseName);
            mlca.onChangeFilter();
            System.debug('listAll_Analysis (filter LicenseName): ' + mlca.listAll_Analysis);

            System.debug(mlca.slLicenseApiName + ' : ' + mlca.optLicenseApiName);
            mlca.slLicenseApiName = String.valueOf(mlca.optLicenseApiName.get(mlca.optLicenseApiName.size() -1));
            System.debug(mlca.slLicenseApiName);
            mlca.onChangeFilter();
            System.debug('listAll_Analysis (filter LicenseApiName): ' + mlca.listAll_Analysis);
            
            //Picklist license
            System.debug('LicenseName GETSET: '+ mlca.getlicenseName());
            mlca.setlicenseName('License Test');
            System.debug('LicenseName GETSET: '+ mlca.getlicenseName());
            System.debug('SelectOption: '+ mlca.soLicenseObject);

           /* Application */
            System.debug(mlca.slAppName + ' : ' + mlca.optAppName);
            mlca.slAppName = String.valueOf(mlca.optAppName.get(mlca.optAppName.size() -1));
            System.debug(mlca.slAppName);
            mlca.onChangeFilter();
            System.debug('listAll_Analysis (filter AppName): ' + mlca.listAll_Analysis);

            /** Test getter and setter */
            //Filter report
            String filterReport = '';

            filterReport = mlca.filterReport_Affiliate;
            System.debug('Filter Report: ' + filterReport);

            filterReport = mlca.filterReport_License;
            System.debug('Filter Report: ' + filterReport);

            filterReport = mlca.filterReport_Application;
            System.debug('Filter Report: ' + filterReport);
            
            //Report ID
            System.debug('Report ID (License):' + mlca.reportID_License);
            System.debug('Report ID (Affiliate):' +  mlca.reportID_Affiliate);
            System.debug('Report ID (Application):' + mlca.reportID_Application);


            /* */
            mlca.updatingLicenseUsed();


            GDT_ManageLicense_TEST.getLimits();
        Test.stopTest();
    }

}