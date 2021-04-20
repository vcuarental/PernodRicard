/***************************************************************************************************************************
 * Name:        ASI_MFM_VN_PO_TestClass
 * Description:
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-2-11        Andy Zhang (LAPUTA)     Cloned from ASI_MFM_PH_PO_TestClass
 ****************************************************************************************************************************/

@isTest
private class ASI_MFM_VN_PO_TestClass {
    //---------------ASI_MFM_SelectPOPrefixController -------------------Start --------------------

    static testMethod void testPODFPrefix()
    {
        //DF :  2 PO Prefix with 2 DF
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_VN_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DFVNPO1', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='DFVNPO2', ASI_MFM_Module__c='PO');
        prefixList.add(pxa);
        insert prefixList;

        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1), ASI_MFM_Status__c = 'Final');
        insert plan;


        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id); //    Final
        insert po;

        ApexPages.currentPage().getParameters().put('pid',po.ASI_MFM_Plan__c);
        ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO') );


        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
        ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
        ASI_MFM_SelectPOPrefixController.getPrefixes();
        ASI_MFM_SelectPOPrefixController.proceed();

    }



    static testMethod void testPODFPrefix2()
    {
        //DF :  2 PO Prefix with one DF
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_VN_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DFVNPO1', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='VNPO2', ASI_MFM_Module__c='PO');
        prefixList.add(pxa);
        insert prefixList;

        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1), ASI_MFM_Status__c = 'Final');
        insert plan;


        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id); //    Final
        insert po;

        ApexPages.currentPage().getParameters().put('pid',po.ASI_MFM_Plan__c);
        string tempid=String.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO')).substring(0,15);
        ApexPages.currentPage().getParameters().put('RecordType',tempid );


        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
        ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
        ASI_MFM_SelectPOPrefixController.getPrefixes();
        ASI_MFM_SelectPOPrefixController.proceed();

    }


    static testMethod void testPODPPrefix()
    {
        //DP :  2 PO Prefix with 2 DP
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_VN_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DPVNPO1', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='DPVNPO2', ASI_MFM_Module__c='PO');
        prefixList.add(pxa);
        insert prefixList;

        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DP_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1), ASI_MFM_Status__c = 'Final');
        insert plan;


        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id,ASI_MFM_Tax_Rate__c='12%');
        insert po;

        ApexPages.currentPage().getParameters().put('pid',po.ASI_MFM_Plan__c);
        ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DP_PO') );


        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
        ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
        ASI_MFM_SelectPOPrefixController.getPrefixes();
        ASI_MFM_SelectPOPrefixController.proceed();

    }



    static testMethod void testPODPPrefix2()
    {
        //DP :  2 PO Prefix with one DP
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_VN_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DPVNPO1', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='VNPO2', ASI_MFM_Module__c='PO');
        prefixList.add(pxa);
        insert prefixList;

        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DP_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1), ASI_MFM_Status__c = 'Final');
        insert plan;


        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id,ASI_MFM_Tax_Rate__c='12%');
        insert po;

        ApexPages.currentPage().getParameters().put('pid',po.ASI_MFM_Plan__c);
        ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DP_PO') );


        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
        ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
        ASI_MFM_SelectPOPrefixController.getPrefixes();
        ASI_MFM_SelectPOPrefixController.proceed();

    }


    static testMethod void testPODPPrefix3()
    {
        //DP :  2 PO Prefix with 2 DP
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_VN_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='DPVNPO1', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='DPVNPO2', ASI_MFM_Module__c='PO');
        prefixList.add(pxa);
        insert prefixList;

        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DP_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1), ASI_MFM_Status__c = 'Final');
        insert plan;


        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId= Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DP_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id,ASI_MFM_Tax_Rate__c='12%');
        insert po;

        ApexPages.currentPage().getParameters().put('pid',po.ASI_MFM_Plan__c);
        ApexPages.currentPage().getParameters().put('RecordType',Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DP_PO'));


        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);
        ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
        ASI_MFM_SelectPOPrefixController.getPrefixes();
        //ASI_MFM_SelectPOPrefixController.proceed();

    }



    //---------------ASI_MFM_SelectPOPrefixController ------------------- End --------------------

    static testMethod void  SupplierEditSupplierNoCtrlTest() {
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_VN_Supplier'),Name='Name2');
        insert acc1;

        Test.startTest();
        ASI_MFM_PH_SupplierEditSupplierNoCtrl ext2 = new ASI_MFM_PH_SupplierEditSupplierNoCtrl(new ApexPages.StandardController(acc1));
        ext2.supplierNumber='1234';
        ext2.customsave();
        ext2.cancel();
        test.stopTest();
    }



    static testMethod void SetPOSatus_Test() {

        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'VN';
        update u;


        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_VN_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        insert prefixList;



        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);

        insert RPList;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        List<Account> accList = ASI_MFM_VN_TestClassHelper.createDFAccount();

        ASI_MFM_A_C_Code__c ac = ASI_MFM_VN_TestClassHelper.createACVNDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_VN_TestClassHelper.CreateDFSBrand();

        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),ASI_MFM_Currency__c='SGD',
                ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;


        // Create PO

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;



        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_VN_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);
        insert poLineList;





        Test.startTest();
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PODetailPage');
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('status', 'Complete');   // change status as draft
        ASI_MFM_SetPOStatusController ext1 = new ASI_MFM_SetPOStatusController(new ApexPages.StandardController(po));
        ext1.setStatus();
        test.stopTest();
    }



    static testMethod void POPDF_Test() {
        user u = [SELECT ID, ASI_MFM_Country__c, userRole.DeveloperName FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'VN';
        update u;

        // ASI_MFM_VN_PO_PDF_PageController  and ASI_MFM_VN_BAverifyController
        ASI_MFM_Plan__c plan = ASI_MFM_VN_TestClassHelper.createVNDPPlanReadOnly();
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_VN_TestClassHelper.createVNPlanLines1(plan);

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        insert pxo;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        List<Account> accList = ASI_MFM_VN_TestClassHelper.createDFAccount();

        ASI_MFM_A_C_Code__c ac = ASI_MFM_VN_TestClassHelper.createACVNDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_VN_TestClassHelper.CreateDFSBrand();
        Test.startTest();
        ASI_MFM_PO__c po= new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DP_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                ASI_MFM_Currency__c='VND', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        

        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_VN_TestClassHelper.createVNPOLines2(po);



        ASI_MFM_VN_PO_PDF_PageController ext = new ASI_MFM_VN_PO_PDF_PageController(new ApexPages.StandardController(po));

        ext.POID= po.Id;
        ext.dummyVar = ext.init();

        ASI_MFM_VN_BAverifyController ext2 = new ASI_MFM_VN_BAverifyController();
        ext2.initDP();
        ext2.save();
        ext2.BAVerify='Checked';
        ext2.Plan_ID='t';

        ext2.PO_ID='1';
        ext2.POLine_ID='1';
        ext2.Suppl='1';
        ext2.Fiscalyear='1';
        ext2.ACCode='1';
        ext2.SBCode='1';
        ext2.Userfilter='1';

        ext2.runSearch();
        test.stopTest();
    }

    static testMethod void POTrigger_Test() {

        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'VN';
        update u;


        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=ASI_MFM_VN_TestClassHelper.getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        insert prefixList;



        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);

        insert RPList;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        List<Account> accList = ASI_MFM_VN_TestClassHelper.createDFAccount();

        ASI_MFM_A_C_Code__c ac = ASI_MFM_VN_TestClassHelper.createACVNDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_VN_TestClassHelper.CreateDFSBrand();
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_TnE_VN_BU'), name ='test bu');

        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),ASI_MFM_Currency__c='SGD',
                ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;


        // Create PO

        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        Test.startTest();
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),ASI_MFM_Cloned_PO_ID__c=po.id,
                ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Draft', ASI_MFM_PO_Start_Date__c=date.today(),ASI_MFM_PO_End_Date__c=date.today().addDays(1));
        insert po1;

        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_VN_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_VN_PO_Line_Item'), ASI_MFM_PO__c=po1.id,ASI_MFM_Amount__c=10000,ASI_MFM_Spread_by_Months__c=true,
                ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_PH_Allocation_Percentage__c=10);
        poLineList.add(poi);
        poLineList.add(poi1);
        insert poLineList;

        po1.ASI_MFM_Exchange_Rate__c = 1.5;
        po1.ASI_MFM_PH_Total_PO_Amount_Allocation__c = 100;
        update po1;

        List<Database.DeleteResult> deleteResults  = new List<Database.DeleteResult>();
        deleteResults = Database.delete(poLineList, false);
        delete po1;
        test.stopTest();
    }
    /*
    static testMethod void InputPOItems_Test() {
        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'VN';
        update u;
        // Test class:  ASI_MFM_VN_InputPOItemsController     
         
        ASI_MFM_VN_TestClasshelper.createMFMDefaultValues();
        
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
            (
                Name = 'Test Plan2',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'),
                ASI_MFM_Start_Date__c = date.today().adddays(1),
                ASI_MFM_End_Date__c = date.today().adddays(1),
                ASI_MFM_Prefix__c = ASI_MFM_VN_TestClasshelper.createVNDFPrefixPlan().id,
                ASI_MFM_Status__c = 'Final'
            );
        
        insert plan;
        
        ASI_MFM_Plan_Line_Item__c planLine = ASI_MFM_VN_TestClassHelper.createVNPlanLines1(plan);
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;
        
        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;
        
        List<Account> accList = ASI_MFM_VN_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_VN_TestClassHelper.createACVNDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_VN_TestClassHelper.CreateDFSBrand();
        Test.startTest();
        ASI_MFM_PO__c po= new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                            ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_VN_TestClassHelper.createVNPOLines1(po);
        
        List<ASI_MFM_PO__c> poSet = new List<ASI_MFM_PO__c>();
        poSet.add(po);
        List<ASI_MFM_PO_Line_Item__c> poLineSet = new List<ASI_MFM_PO_Line_Item__c>();
        poLineSet.add(poLine);
        
        ApexPages.standardSetController sc = new ApexPages.standardSetController(poLineSet);
        
        PageReference inputPOItemsPage = Page.ASI_MFM_VN_InputPOItemsPage;
        Map<String, String> pageParams = inputPOItemsPage.getParameters();
        System.debug('Linus CP1: ' + Limits.getAggregateQueries());
        
        System.debug('Linus CP2: ' + Limits.getAggregateQueries());        
        
        ApexPages.Standardsetcontroller stdController = new ApexPages.Standardsetcontroller(poSet);
        stdController.setSelected(poSet); 
        pageParams.put('id', po.Id);
        ASI_MFM_VN_InputPOItemsController POManageAllCtler = new ASI_MFM_VN_InputPOItemsController(stdController);
        //Test function
        POManageAllCtler.init();

        POManageAllCtler.addLineItem();
        System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)poLine.id);
        POManageAllCtler.cloneLine();                        
        
        POManageAllCtler.cancel();
        List<Account> remo= ASI_MFM_VN_InputPOItemsController.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_VN_DP_Customer');
        
        System.debug('Linus CP3: ' + Limits.getAggregateQueries());
        test.stopTest(); 
     }
*/
    static testMethod void InputPOItems_Test() {
        user u = [SELECT ID, ASI_MFM_Country__c, userRole.DeveloperName FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'VN';
        update u;
        // Test class:  ASI_MFM_VN_InputPOItemsController     

        ASI_MFM_VN_TestClasshelper.createMFMDefaultValues();

        ASI_MFM_Sub_brand__c sb = ASI_MFM_VN_TestClassHelper.CreateDPSBrand();
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_VN_DF_Customer'),Name='Name3');

        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                        Name = 'Test Plan2',
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_VN_DF_Plan'),
                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                        ASI_MFM_End_Date__c = date.today().adddays(1),
                        ASI_MFM_Prefix__c = ASI_MFM_VN_TestClasshelper.createVNDFPrefixPlan().id,
                        ASI_MFM_Status__c = 'Final'
                );

        insert plan;

        ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_VN_Plan_Line_Item'),
                        ASI_MFM_List_Item_Description__c = 'test description',
                        ASI_MFM_Total_Cost__c = 1234,
                        ASI_MFM_Plan__c = plan.id,
                        ASI_MFM_Sub_brand_Code__c=sb.id,
                        ASI_MFM_A_C_Code__c=ASI_MFM_VN_testClasshelper.createACVNDPCode().id,
                        ASI_MFM_Customer_Name__c=acc2.id,
                        ASI_MFM_Month_1_Cost__c=100,
                        ASI_MFM_Month_2_Cost__c=100,
                        ASI_MFM_Month_3_Cost__c=100,
                        ASI_MFM_Month_4_Cost__c=100,
                        ASI_MFM_Month_5_Cost__c=100,
                        ASI_MFM_Month_6_Cost__c=100,
                        ASI_MFM_Month_7_Cost__c=100,
                        ASI_MFM_Month_8_Cost__c=100,
                        ASI_MFM_Month_9_Cost__c=100,
                        ASI_MFM_Month_10_Cost__c=100,
                        ASI_MFM_Month_11_Cost__c=100,
                        ASI_MFM_Month_12_Cost__c=100,
                        ASI_MFM_Carry_Forward__c=100
                );
        insert planLine;

        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_Year__c=ASI_MFM_VN_TestClasshelper.getFiscalYear());
        insert pxo;

        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
        insert rt;

        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;

        List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
        ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
        ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
        ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
        ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
        ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
        ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
        ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
        ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
        ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
        rrdlist.add(rrd1);
        rrdlist.add(rrd2);
        rrdlist.add(rrd3);
        rrdlist.add(rrd4);
        rrdlist.add(rrd5);
        rrdlist.add(rrd6);
        rrdlist.add(rrd7);
        rrdlist.add(rrd8);
        rrdlist.add(rrd9);
        insert rrdlist;

        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
        insert rtm;

        ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
        insert rtbr;

        List<Account> accList = ASI_MFM_VN_TestClassHelper.createDFAccount();

        ASI_MFM_A_C_Code__c ac = ASI_MFM_VN_TestClassHelper.createACVNDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_VN_TestClassHelper.CreateDFSBrand();
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name ='test ap', recordtypeid =Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_VN_DF_AP_Code'));
        insert ap;
        Test.startTest();
        ASI_MFM_PO__c po= new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_VN_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=plan.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final', ASI_MFM_PO_Start_Date__c=date.today(), ASI_MFM_PO_End_Date__c=date.today().addDays(1));
        insert po;

        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
                (
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_VN_PO_Line_Item'),
                        ASI_MFM_List_Item_Description__c = 'test description',
                        ASI_MFM_Amount__c = 124,
                        ASI_MFM_G_L_Date__c=date.today().adddays(1),
                        ASI_MFM_PO__c = po.id,
                        ASI_MFM_Sub_brand_Code__c=ASI_MFM_VN_TestClassHelper.CreateDPSBrand().id,
                        ASI_MFM_A_C_Code__c=ASI_MFM_VN_TestClassHelper.createACVNDPCode().id,
                        ASI_MFM_AP_Code__c=ap.id,
                        ASI_MFM_Customer_Name__c=ASI_MFM_VN_TestClassHelper.createDPAccount()[1].id
                );
        insert poLine;

        List<ASI_MFM_PO__c> poSet = new List<ASI_MFM_PO__c>();
        poSet.add(po);
        List<ASI_MFM_PO_Line_Item__c> poLineSet = new List<ASI_MFM_PO_Line_Item__c>();
        poLineSet.add(poLine);

        ApexPages.standardSetController sc = new ApexPages.standardSetController(poLineSet);

        PageReference inputPOItemsPage = Page.ASI_MFM_VN_InputPOItemsPage;
        Map<String, String> pageParams = inputPOItemsPage.getParameters();



        ApexPages.Standardsetcontroller stdController = new ApexPages.Standardsetcontroller(poSet);
        stdController.setSelected(poSet);
        pageParams.put('id', po.Id);
        ASI_MFM_VN_InputPOItemsController POManageAllCtler = new ASI_MFM_VN_InputPOItemsController(stdController);
        //Test function
        System.currentPageReference().getParameters().put('split', 'true');
        POManageAllCtler.init();
        System.currentPageReference().getParameters().put('IS_QUICK_SAVE', 'true');
        POManageAllCtler.SaveItems();
        POManageAllCtler.addLineItem();
        System.currentPageReference().getParameters().put('PARAM_clone_ID', (String)poLine.id);
        POManageAllCtler.cloneLine();
        System.currentPageReference().getParameters().put('mode', 'full');
        POManageAllCtler.copyPlan();
        POManageAllCtler.removeLine();
        POManageAllCtler.cancel();
        List<Account> remo= ASI_MFM_VN_InputPOItemsController.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_VN_DP_Customer');

        test.stopTest();
    }

}